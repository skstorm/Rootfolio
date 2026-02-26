type RouteHandler = () => string | Promise<string>;

class Router {
    private routes: Record<string, RouteHandler> = {};

    add(path: string, handler: RouteHandler) {
        this.routes[path] = handler;
    }

    async navigate(path: string) {
        window.history.pushState({}, '', path);
        await this.resolve();
    }

    async resolve() {
        const path = window.location.pathname;
        const handler = this.routes[path] || this.routes['/'];
        const content = await handler();

        const appContainer = document.querySelector('#app-content');
        if (appContainer) {
            appContainer.innerHTML = content;
            this.updateActiveLinks(path);
        }
    }

    private updateActiveLinks(currentPath: string) {
        document.querySelectorAll('.nav-link').forEach(link => {
            const href = link.getAttribute('href');
            if (href === currentPath) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    }

    init() {
        window.addEventListener('popstate', () => this.resolve());

        document.addEventListener('click', (e) => {
            const target = e.target as HTMLElement;
            const link = target.closest('a');
            if (link && link.getAttribute('href')?.startsWith('/')) {
                e.preventDefault();
                this.navigate(link.getAttribute('href')!);
            }
        });

        this.resolve();
    }
}

export const router = new Router();
