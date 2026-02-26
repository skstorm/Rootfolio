import { DeployEngine } from '../packages/deploy-engine/index.js';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = path.resolve(__dirname, '..');

const engine = new DeployEngine(
    path.join(ROOT_DIR, 'WebRoot', 'public'),
    path.join(ROOT_DIR, 'WebRoot', 'public', 'apps-metadata.json')
);

const appName = process.argv[2];
const appPath = path.join(ROOT_DIR, 'AppRoots', appName);

engine.deploy({
    id: appName,
    name: appName,
    type: 'flutter', // Auto-detected by engine anyway
    path: appPath
}).then(url => {
    console.log(`✅ Deployed to: ${url}`);
}).catch(err => {
    console.error(`❌ Deployment failed: ${err.message}`);
});
