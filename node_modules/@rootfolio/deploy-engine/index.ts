import fs from 'fs-extra';
import path from 'path';
import crypto from 'crypto';
import { execSync } from 'child_process';

export interface AppConfig {
    id: string;
    name: string;
    type: 'flutter' | 'npm' | 'custom';
    path: string;
}

export abstract class AppBuilder {
    abstract detect(appPath: string): boolean;
    abstract build(appPath: string): void;
    abstract getArtifactsDir(appPath: string): string;
}

export class FlutterBuilder extends AppBuilder {
    detect(appPath: string): boolean {
        return fs.existsSync(path.join(appPath, 'pubspec.yaml'));
    }
    build(appPath: string): void {
        execSync('flutter build web --release', { cwd: appPath, stdio: 'inherit' });
    }
    getArtifactsDir(appPath: string): string {
        return path.join(appPath, 'build', 'web');
    }
}

export class DeployEngine {
    private builders: AppBuilder[] = [new FlutterBuilder()];

    constructor(
        private webPublicDir: string,
        private metadataPath: string
    ) { }

    async deploy(appConfig: AppConfig) {
        const builder = this.builders.find(b => b.detect(appConfig.path));
        if (!builder) throw new Error(`No suitable builder found for ${appConfig.id}`);

        console.log(`🚀 Deploying ${appConfig.id} using ${builder.constructor.name}...`);

        // BUILD
        builder.build(appConfig.path);

        // HASH & VERSION
        const hash = crypto.randomBytes(4).toString('hex');
        const versionDir = `v-${new Date().toISOString().split('T')[0]}-${hash}`;
        const targetDir = path.join(this.webPublicDir, 'apps', appConfig.id, versionDir);

        // COPY
        await fs.ensureDir(targetDir);
        await fs.copy(builder.getArtifactsDir(appConfig.path), targetDir);

        // METADATA UPDATE (Atomic)
        await this.updateMetadata(appConfig, versionDir);

        return `/apps/${appConfig.id}/${versionDir}/index.html`;
    }

    private async updateMetadata(appConfig: AppConfig, version: string) {
        let metadata = [];
        if (fs.existsSync(this.metadataPath)) {
            metadata = await fs.readJson(this.metadataPath);
        }

        const appPath = `/apps/${appConfig.id}/${version}/index.html`;
        const appInfo = {
            ...appConfig,
            path: appPath,
            version,
            updatedAt: new Date().toISOString()
        };

        const index = metadata.findIndex(m => m.id === appConfig.id);
        if (index > -1) {
            metadata[index] = { ...metadata[index], ...appInfo };
        } else {
            metadata.push(appInfo);
        }

        const tempPath = `${this.metadataPath}.tmp`;
        await fs.writeJson(tempPath, metadata, { spaces: 2 });
        await fs.move(tempPath, this.metadataPath, { overwrite: true });
    }
}
