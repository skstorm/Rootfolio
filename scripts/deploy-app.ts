import path from 'path';
import fs from 'fs-extra';
import { fileURLToPath } from 'url';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
import { DeployEngine } from './../packages/deploy-engine/index.ts';

const ROOT_DIR = path.resolve(__dirname, '..');
const WEB_PUBLIC_DIR = path.join(ROOT_DIR, 'WebRoot', 'public');
const METADATA_PATH = path.join(WEB_PUBLIC_DIR, 'apps-metadata.json');
const APP_ROOT_DIR = path.join(ROOT_DIR, 'AppRoot');

async function main() {
    const appId = process.argv[2];
    if (!appId) {
        console.error('❌ Error: Please provide an App ID (e.g., npm run deploy-app my-app)');
        process.exit(1);
    }

    const appPath = path.join(APP_ROOT_DIR, appId);
    if (!fs.existsSync(appPath)) {
        console.error(`❌ Error: App folder not found at ${appPath}`);
        process.exit(1);
    }

    const engine = new DeployEngine(WEB_PUBLIC_DIR, METADATA_PATH);

    // Basic config - in a real scenario, this might come from a project-specific config file
    const appConfig: any = {
        id: appId,
        name: appId.charAt(0).toUpperCase() + appId.slice(1).replace(/-/g, ' '),
        type: 'flutter', // Defaulting to flutter for now as it's the only builder
        path: appPath
    };

    try {
        const url = await engine.deploy(appConfig);
        console.log(`✅ Successfully deployed ${appId}!`);
        console.log(`🔗 Accessible at: ${url}`);
    } catch (error) {
        console.error(`❌ Deployment failed:`, error);
        process.exit(1);
    }
}

main();
