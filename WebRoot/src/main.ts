import './styles/main.css';
import { router } from './utils/router';
import { fetchMarkdown, contentIndex } from './utils/markdown';

const app = document.querySelector<HTMLDivElement>('#app')!;

app.innerHTML = `
  <div class="container">
    <header class="header">
      <h1 class="logo" onclick="router.navigate('/')" style="cursor:pointer">Rootfolio<span>🌳</span></h1>
      
      <!-- Desktop Nav -->
      <nav class="nav desktop-nav">
        <a href="/" class="nav-link" data-path="/">Home</a>
        <a href="/studies" class="nav-link" data-path="/studies">Studies</a>
        <a href="/apps" class="nav-link" data-path="/apps">Apps</a>
        <a href="/logs" class="nav-link" data-path="/logs">Logs</a>
      </nav>

      <!-- Mobile Menu Toggle -->
      <button class="mobile-menu-toggle" id="menu-toggle" aria-label="Toggle menu">
        <span></span>
        <span></span>
        <span></span>
      </button>
    </header>

    <!-- Mobile Navigation Overlay -->
    <div class="mobile-nav-overlay" id="mobile-overlay">
      <nav class="mobile-nav">
        <a href="/" class="mobile-nav-link" data-path="/">Home</a>
        <a href="/studies" class="mobile-nav-link" data-path="/studies">Studies</a>
        <a href="/apps" class="mobile-nav-link" data-path="/apps">Apps</a>
        <a href="/logs" class="mobile-nav-link" data-path="/logs">Logs</a>
      </nav>
    </div>
    
    <div id="app-content-wrapper">
      <div id="app-content">
        <!-- Content will be injected here -->
      </div>
    </div>
  </div>
`;

// Mobile menu toggle logic
const menuToggle = document.getElementById('menu-toggle');
const mobileOverlay = document.getElementById('mobile-overlay');

const toggleMenu = () => {
  menuToggle?.classList.toggle('active');
  mobileOverlay?.classList.toggle('active');
  document.body.classList.toggle('menu-open');
};

menuToggle?.addEventListener('click', toggleMenu);

// Close menu when clicking a link
document.querySelectorAll('.mobile-nav-link').forEach(link => {
  link.addEventListener('click', (e) => {
    e.preventDefault();
    const path = (link as HTMLElement).getAttribute('href')!;
    router.navigate(path);
    toggleMenu();
  });
});

// Helper to update active link
const updateActiveLink = (path: string) => {
  document.querySelectorAll('.nav-link').forEach(link => {
    link.classList.toggle('active', link.getAttribute('data-path') === path);
  });
};

// Override router.navigate to handle transitions
const originalNavigate = router.navigate;
router.navigate = async (path: string) => {
  const content = document.getElementById('app-content');
  if (content) {
    content.style.opacity = '0';
    content.style.transform = 'translateY(10px)';
    setTimeout(async () => {
      await originalNavigate.call(router, path);
      updateActiveLink(path);
      content.style.opacity = '1';
      content.style.transform = 'translateY(0)';
    }, 200);
  } else {
    await originalNavigate.call(router, path);
    updateActiveLink(path);
  }
};

// Define View Handlers
router.add('/', () => `
  <main class="hero">
    <h2 class="hero-title animate-up">Roots for Growth,<br/>Portfolio for Achievement</h2>
    <p class="hero-desc animate-up delay-1">학습 여정, 개발 프로젝트, 개인적인 성찰을 위한 프리미엄 디지털 생태계</p>
    <div class="cta-group animate-up delay-2">
      <button class="btn btn-primary" onclick="router.navigate('/studies')">
        탐색 시작하기 <span>🚀</span>
      </button>
      <button class="btn btn-outline" onclick="router.navigate('/logs')">
        최근 로그 보기
      </button>
    </div>
  </main>
`);

router.add('/studies', async () => {
  const listItems = contentIndex.studies.map(item => `
    <article class="content-card" onclick="router.navigate('/studies/view?path=${item.path}')">
      <h3>${item.title}</h3>
      <span class="date">${item.date}</span>
    </article>
  `).join('');

  return `
    <section class="page-section animate-up">
      <h2 class="section-title">Knowledge Base</h2>
      <p class="section-desc">기술과 과학, 도전에 대한 심도 있는 기록들입니다.</p>
      <div class="content-grid">${listItems}</div>
    </section>
  `;
});

router.add('/studies/view', async () => {
  const params = new URLSearchParams(window.location.search);
  const path = params.get('path');
  if (!path) return '<p>경로가 올바르지 않습니다.</p>';

  const content = await fetchMarkdown(path);
  return `
    <article class="view-content animate-up">
      <button class="btn-text" onclick="window.history.back()">← 뒤로 가기</button>
      <div class="markdown-body">${content}</div>
    </article>
  `;
});

router.add('/apps', async () => {
  const response = await fetch('/apps-metadata.json');
  const apps = await response.json().catch(() => []);

  const listItems = apps.length > 0 ? apps.map((app: any) => `
    <article class="content-card" onclick="router.navigate('/apps/view?id=${app.id}')">
      <div class="card-icon">${app.icon || '📦'}</div>
      <h3>${app.name}</h3>
      <p>${app.description}</p>
      <div class="date">v${app.version || '0.1.0'}</div>
    </article>
  `).join('') : '<p style="color: var(--text-dim)">등록된 앱이 없습니다.</p>';

  return `
    <section class="page-section animate-up">
      <h2 class="section-title">App Showcase</h2>
      <p class="section-desc">Flutter와 Web으로 구현된 인터랙티브 애플리케이션입니다.</p>
      <div class="content-grid">${listItems}</div>
    </section>
  `;
});

router.add('/apps/view', async () => {
  const params = new URLSearchParams(window.location.search);
  const id = params.get('id');
  const response = await fetch('/apps-metadata.json');
  const apps = await response.json().catch(() => []);
  const app = apps.find((a: any) => a.id === id);

  if (!app) return '<p>앱을 찾을 수 없습니다.</p>';

  return `
    <section class="app-viewer animate-up">
      <div class="viewer-header">
        <button class="btn-text" onclick="window.history.back()">← 목록으로</button>
        <h2>${app.name}</h2>
      </div>
      <div class="iframe-container">
        <iframe 
          id="app-iframe"
          src="${app.path}" 
          frameborder="0" 
          sandbox="allow-scripts allow-same-origin"
          onload="window.initAppBridge()"
        ></iframe>
      </div>
    </section>
  `;
});

// Bridge Initialization Logic
(window as any).initAppBridge = () => {
  const iframe = document.getElementById('app-iframe') as HTMLIFrameElement;
  if (iframe && iframe.contentWindow) {
    console.log('🔗 Initializing Bridge for:', iframe.src);
  }
};

router.add('/logs', async () => {
  const listItems = contentIndex.logs.map(item => `
    <article class="content-card" onclick="router.navigate('/studies/view?path=${item.path}')">
      <h3>${item.title}</h3>
      <span class="date">${item.date}</span>
    </article>
  `).join('');

  return `
    <section class="page-section animate-up">
      <h2 class="section-title">Daily Logs</h2>
      <p class="section-desc">매일의 성장과 고민을 담은 기록입니다.</p>
      <div class="content-grid">${listItems}</div>
    </section>
  `;
});

// To make router.navigate accessible via onclick
(window as any).router = router;

router.init();
updateActiveLink(window.location.pathname);
