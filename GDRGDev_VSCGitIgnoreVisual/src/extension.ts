import * as vscode from 'vscode';
import { IgnoreDecorationProvider } from './decorationProvider';

let decorationProvider: IgnoreDecorationProvider | undefined;

export function activate(context: vscode.ExtensionContext) {
    decorationProvider = new IgnoreDecorationProvider();
    context.subscriptions.push(
        vscode.window.registerFileDecorationProvider(decorationProvider)
    );

    const refreshCommand = vscode.commands.registerCommand('gitignoreVisual.refresh', () => {
        decorationProvider?.refresh();
        vscode.window.showInformationMessage('GitIgnore Visual refreshed');
    });

    const watcher = vscode.workspace.createFileSystemWatcher('**/.gitignore');
    watcher.onDidChange(() => decorationProvider?.refresh());
    watcher.onDidCreate(() => decorationProvider?.refresh());
    watcher.onDidDelete(() => decorationProvider?.refresh());

    context.subscriptions.push(refreshCommand, watcher);
}

export function deactivate() {
    decorationProvider = undefined;
}
