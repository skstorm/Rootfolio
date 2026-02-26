import './styles/main.css';
import { router } from './utils/router';
import { fetchMarkdown, contentIndex } from './utils/markdown';

const app = document.querySelector<HTMLDivElement>('#app')!;

app.innerHTML = `
  <div class="container">
    <header class="header">
      <h1 class="logo" onclick="router.navigate('/')" style="cursor:pointer">Rootfolio<span>🌳</span></h1>
      <nav class="nav">
        <a href="/" class="nav-link">Home</a>
        <a href="/studies" class="nav-link">Studies</a>
        <a href="/apps" class="nav-link">Apps</a>
        <a href="/logs" class="nav-link">Logs</a>
      </nav>
    </header>
    
    <div id="app-content">
      <!-- Content will be injected here -->
    </div>
  </div>
`;

// Define View Handlers
router.add('/', () => `
  <main class="hero">
    <h2 class="hero-title animate-up">Roots for Growth,<br/>Portfolio for Achievement</h2>
    <p class="hero-desc animate-up delay-1">학습 여정, 개발 프로젝트, 개인적인 성찰을 위한 프리미엄 디지털 생태계</p>
    <div class="cta-group animate-up delay-2">
      <button class="btn btn-primary" onclick="router.navigate('/studies')">탐색 시작하기</button>
      <button class="btn btn-outline" onclick="router.navigate('/logs')">최근 로그 보기</button>
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
  const apps = await response.json();

  const listItems = apps.map((app: any) => `
    <article class="content-card" onclick="router.navigate('/apps/view?id=${app.id}')">
      <div class="card-icon">${app.icon}</div>
      <h3>${app.name}</h3>
      <p>${app.description}</p>
    </article>
  `).join('');

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
  const apps = await response.json();
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
    // Future: const bridge = new Bridge(iframe.contentWindow);
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
