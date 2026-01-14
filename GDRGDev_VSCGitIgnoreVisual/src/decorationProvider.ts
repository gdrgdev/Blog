import * as vscode from 'vscode';
import { IgnoreParser } from './ignoreParser';

export class IgnoreDecorationProvider implements vscode.FileDecorationProvider {
    private _onDidChangeFileDecorations = new vscode.EventEmitter<vscode.Uri | vscode.Uri[]>();
    readonly onDidChangeFileDecorations = this._onDidChangeFileDecorations.event;
    
    private ignoreParser: IgnoreParser;

    constructor() {
        this.ignoreParser = new IgnoreParser();
    }

    provideFileDecoration(uri: vscode.Uri): vscode.ProviderResult<vscode.FileDecoration> {
        if (uri.fsPath.endsWith('.gitignore')) {
            return undefined;
        }

        const { ignored, rule, gitignorePath } = this.ignoreParser.isIgnored(uri);
        
        if (!ignored) {
            return undefined;
        }

        const config = vscode.workspace.getConfiguration('gitignoreVisual');
        const badgeIcon = config.get<string>('badgeIcon', '⦻');

        const tooltip = gitignorePath 
            ? `Ignored by rule "${rule}" in:\n${gitignorePath}`
            : `Ignored by: ${rule}`;

        return {
            badge: badgeIcon,
            tooltip: tooltip,
            color: new vscode.ThemeColor('textLink.foreground'),
        };
    }

    public refresh(): void {
        this.ignoreParser.refresh();
        this._onDidChangeFileDecorations.fire(undefined as any);
    }
}
