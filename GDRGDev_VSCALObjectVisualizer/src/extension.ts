/**
 * AL Object Visualizer
 *
 * Main extension entry point. Registers the file decoration provider,
 * the stats tree view, and all user-facing commands.
 *
 * @module extension
 * @author Gerardo Renteria
 * @license MIT
 */

import * as vscode from 'vscode';
import { ALObjectDecorationProvider } from './decorationProvider';
import { ALStatsProvider } from './statsProvider';

/**
 * Activates the extension.
 * Registers the decoration provider, tree view, and all commands.
 *
 * @param context - VS Code extension context
 */
export function activate(context: vscode.ExtensionContext) {
    const decorationProvider = new ALObjectDecorationProvider();
    const statsProvider = new ALStatsProvider();
    
    context.subscriptions.push(
        vscode.window.registerFileDecorationProvider(decorationProvider)
    );

    const treeView = vscode.window.createTreeView('alObjectStats', {
        treeDataProvider: statsProvider
    });

    context.subscriptions.push(treeView);

    if (treeView.onDidChangeVisibility) {
        context.subscriptions.push(
            treeView.onDidChangeVisibility(e => {
                if (e.visible) {
                    statsProvider.refresh();
                }
            })
        );
    }

    context.subscriptions.push(
        vscode.commands.registerCommand('alObjectVisualizer.refreshStats', () => {
            statsProvider.refresh();
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('alObjectVisualizer.filterObjects', async () => {
            const filterText = await vscode.window.showInputBox({
                prompt: 'Filter objects by name, filename, or ID (supports regex)',
                placeHolder: 'e.g., Invoice, ^Post, .*Mgt$, Post.*Codeunit',
                value: ''
            });
            
            if (filterText !== undefined) {
                statsProvider.applyFilter(filterText);
            }
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('alObjectVisualizer.clearFilter', () => {
            statsProvider.applyFilter('');
            vscode.window.showInformationMessage('Filter cleared');
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('alObjectVisualizer.showFiles', async (objectType: string, folder?: string) => {
            const files = statsProvider.getFilesForType(objectType, folder);

            if (files.length === 0) {
                vscode.window.showInformationMessage(`No ${objectType} files found`);
                return;
            }

            const matchingFiles = files.map(f => ({
                label: f.fileName,
                description: f.id ? `${f.id} · ${f.name}` : f.name,
                detail: vscode.workspace.asRelativePath(f.uri),
                uri: f.uri
            }));

            const selected = await vscode.window.showQuickPick(matchingFiles, {
                placeHolder: `🔍 Type to filter by filename, ID, or object name (${matchingFiles.length} files)`,
                matchOnDescription: true,
                matchOnDetail: true
            });

            if (selected?.uri) {
                const doc = await vscode.workspace.openTextDocument(selected.uri);
                await vscode.window.showTextDocument(doc);
            }
        })
    );

    context.subscriptions.push(
        vscode.workspace.onDidChangeConfiguration((e: vscode.ConfigurationChangeEvent) => {
            if (e.affectsConfiguration('alObjectVisualizer')) {
                decorationProvider.refresh();
                statsProvider.refresh();
            }
        })
    );

    context.subscriptions.push(
        vscode.workspace.onDidSaveTextDocument((document: vscode.TextDocument) => {
            if (document.fileName.endsWith('.al')) {
                decorationProvider.onFileChanged(document.uri);
                statsProvider.refresh();
            }
        })
    );
}

/**
 * Deactivates the extension.
 * VS Code disposes all registered subscriptions automatically.
 */
export function deactivate() {}
