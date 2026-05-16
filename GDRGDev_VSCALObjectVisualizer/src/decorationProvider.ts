/**
 * AL Object Decoration Provider
 *
 * Applies badge and color decorations to .al files in the VS Code Explorer
 * based on the AL object type. Results are cached per file and invalidated on save.
 *
 * @module decorationProvider
 * @author Gerardo Renteria
 * @license MIT
 */

import * as vscode from 'vscode';
import { detectObjectType } from './objectDetector';
import { hexToThemeColorName } from './colorUtils';

/** Applies badge and color decorations to .al files in the VS Code Explorer. */
export class ALObjectDecorationProvider implements vscode.FileDecorationProvider {
    private _onDidChangeFileDecorations = new vscode.EventEmitter<vscode.Uri | vscode.Uri[] | undefined>();
    readonly onDidChangeFileDecorations = this._onDidChangeFileDecorations.event;
    private cache = new Map<string, string | null>();

    /**
     * Returns badge and color for the given file, or undefined if not a recognized AL object.
     *
     * @param uri - URI of the file to decorate
     */
    async provideFileDecoration(uri: vscode.Uri): Promise<vscode.FileDecoration | undefined> {
        if (!uri.fsPath.endsWith('.al')) {
            return undefined;
        }

        const objectType = await this.getObjectType(uri);
        if (!objectType) {
            return undefined;
        }

        const config = this.getConfig(objectType);
        if (!config) {
            return undefined;
        }

        const decoration: vscode.FileDecoration = {};
        
        if (config.badge) {
            decoration.badge = config.badge;
        }
        
        if (config.color) {
            decoration.color = this.hexToThemeColor(config.color);
        }

        return (decoration.badge || decoration.color) ? decoration : undefined;
    }

    private async getObjectType(uri: vscode.Uri): Promise<string | null> {
        const key = uri.toString();
        if (this.cache.has(key)) {
            return this.cache.get(key)!;
        }

        const objectType = await detectObjectType(uri);
        this.cache.set(key, objectType);
        return objectType;
    }

    private getConfig(objectType: string): { color?: string; badge?: string } | undefined {
        const config = vscode.workspace.getConfiguration('alObjectVisualizer');
        const objectTypes = config.get<Record<string, { color?: string; badge?: string }>>('objectTypes', {});
        const objConfig = objectTypes[objectType.toLowerCase()];
        
        if (!objConfig || (!objConfig.color && !objConfig.badge)) {
            return undefined;
        }
        
        return objConfig;
    }

    /**
     * Clears the entire cache and triggers re-decoration of all files.
     * Called when extension configuration changes.
     */
    refresh(): void {
        this.cache.clear();
        this._onDidChangeFileDecorations.fire(undefined);
    }

    /**
     * Invalidates the cache for a single file and triggers re-decoration.
     * Called when an .al file is saved.
     *
     * @param uri - URI of the changed file
     */
    onFileChanged(uri: vscode.Uri): void {
        this.cache.delete(uri.toString());
        this._onDidChangeFileDecorations.fire(uri);
    }

    private hexToThemeColor(hex: string): vscode.ThemeColor {
        return new vscode.ThemeColor(hexToThemeColorName(hex));
    }
}