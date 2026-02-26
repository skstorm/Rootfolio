export interface BridgeMessage {
    type: string;
    payload: any;
}

export class Bridge {
    private targetWindow: Window | null = null;
    private origin: string = '*';
    private handlers: Map<string, (payload: any) => void> = new Map();

    constructor(targetWindow: Window | null, origin: string = '*') {
        this.targetWindow = targetWindow;
        this.origin = origin;
        window.addEventListener('message', this.handleMessage.bind(this));
    }

    public on(type: string, handler: (payload: any) => void) {
        this.handlers.set(type, handler);
    }

    public send(type: string, payload: any) {
        if (this.targetWindow) {
            const message: BridgeMessage = { type, payload };
            this.targetWindow.postMessage(message, this.origin);
        }
    }

    private handleMessage(event: MessageEvent) {
        // Basic origin check (can be improved with whitelist)
        if (this.origin !== '*' && event.origin !== this.origin) return;

        const data = event.data as BridgeMessage;
        if (data && data.type && this.handlers.has(data.type)) {
            this.handlers.get(data.type)!(data.payload);
        }
    }

    public destroy() {
        window.removeEventListener('message', this.handleMessage.bind(this));
    }
}
