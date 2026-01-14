import * as vscode from 'vscode';
import * as path from 'path';
import ignore, { Ignore } from 'ignore';
import * as fs from 'fs';

export class IgnoreParser {
    private ignoreInstances: Map<string, Ignore> = new Map();
    private gitignoreRules: Map<string, string[]> = new Map();

    constructor() {
        this.loadAllGitignores();
    }

    private async loadAllGitignores(): Promise<void> {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (!workspaceFolders) {
            return;
        }

        for (const folder of workspaceFolders) {
            await this.loadGitignoreForFolder(folder.uri.fsPath);
        }
    }

    private async loadGitignoreForFolder(folderPath: string): Promise<void> {
        const gitignorePath = path.join(folderPath, '.gitignore');

        try {
            if (fs.existsSync(gitignorePath)) {
                const content = fs.readFileSync(gitignorePath, 'utf8');
                const ig = ignore().add(content);

                this.ignoreInstances.set(folderPath, ig);

                const rules = content
                    .split('\n')
                    .map(line => line.trim())
                    .filter(line => line && !line.startsWith('#'));
                this.gitignoreRules.set(folderPath, rules);
            }
        } catch (error) {
            console.error(`Error loading .gitignore from ${folderPath}:`, error);
        }
    }

    public isIgnored(uri: vscode.Uri): { ignored: boolean; rule?: string; gitignorePath?: string } {
        const workspaceFolder = vscode.workspace.getWorkspaceFolder(uri);
        if (!workspaceFolder) {
            return { ignored: false };
        }

        const ig = this.ignoreInstances.get(workspaceFolder.uri.fsPath);
        if (!ig) {
            return { ignored: false };
        }

        const gitignorePath = path.join(workspaceFolder.uri.fsPath, '.gitignore');

        const relativePath = path.relative(workspaceFolder.uri.fsPath, uri.fsPath);
        const normalizedPath = relativePath.replace(/\\/g, '/');

        let isIgnored = ig.ignores(normalizedPath);
        
        if (!isIgnored) {
            try {
                const stats = fs.statSync(uri.fsPath);
                if (stats.isDirectory()) {
                    isIgnored = ig.ignores(normalizedPath + '/');
                }
            } catch (error) {
                // Path no accesible, asumir que no es carpeta
            }
        }

        if (isIgnored) {
            const rules = this.gitignoreRules.get(workspaceFolder.uri.fsPath) || [];
            const matchingRule = this.findMatchingRule(normalizedPath, rules);
            return { ignored: true, rule: matchingRule, gitignorePath };
        }

        return { ignored: false };
    }

    private findMatchingRule(filePath: string, rules: string[]): string {
        for (const rule of rules) {
            const ig = ignore().add(rule);
            if (ig.ignores(filePath) || ig.ignores(filePath + '/')) {
                return rule;
            }
        }
        return 'unknown';
    }

    public refresh(): void {
        this.ignoreInstances.clear();
        this.gitignoreRules.clear();
        this.loadAllGitignores();
    }
}
