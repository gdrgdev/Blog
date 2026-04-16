/**
 * Utility Functions Module
 * 
 * Provides shared utility functions for working with Business Central AL projects
 * and XLIFF translation files. This module contains helper functions used across
 * the extension for file system operations, configuration management, and validation.
 * 
 * Key utilities:
 * - Workspace and configuration access
 * - app.json file detection and parsing
 * - Translation folder and XLIFF file discovery
 * - Language code expansion and validation
 * 
 * All functions are designed to be pure and side-effect free where possible,
 * making them easily testable and reusable.
 * 
 * @module utils
 * @author Gerardo Renteria
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { AppJson, TranslationConfig } from './types';

/**
 * Gets the current workspace folder path.
 * Prefers the folder that contains app.json (the AL project) over the first folder.
 * 
 * @returns Workspace folder path or undefined if no workspace is open
 */
export function getWorkspacePath(): string | undefined {
    const folders = vscode.workspace.workspaceFolders;
    if (!folders || folders.length === 0) { return undefined; }

    for (const folder of folders) {
        const appJsonPath = path.join(folder.uri.fsPath, 'app.json');
        if (fs.existsSync(appJsonPath)) {
            return folder.uri.fsPath;
        }
    }

    return folders[0].uri.fsPath;
}

/**
 * Retrieves the extension configuration.
 * Uses the AL project folder (the one containing app.json) as the configuration scope
 * so that folder-level .vscode/settings.json is read correctly in multi-root workspaces.
 * 
 * @returns Configuration object with required languages and equivalents
 */
export function getConfig(): TranslationConfig {
    const folders = vscode.workspace.workspaceFolders;
    let scope: vscode.WorkspaceFolder | undefined;

    if (folders && folders.length > 0) {
        scope = folders.find(f => fs.existsSync(path.join(f.uri.fsPath, 'app.json'))) ?? folders[0];
    }

    const config = vscode.workspace.getConfiguration('alTranslationRequirements', scope);
    return {
        required: config.get<string[]>('required') || [],
        equivalents: config.get<Array<{base: string; equivalent: string}>>('equivalents') || []
    };
}

/**
 * Expands required languages to include equivalent variants.
 * 
 * If a required language has equivalents configured, they are automatically
 * added to the list of required languages for validation.
 * 
 * @param config - Extension configuration
 * @returns Array of all required language codes including equivalents
 */
export function getExpandedRequiredLanguages(config: TranslationConfig): string[] {
    const expanded = new Set(config.required);
    
    for (const item of config.equivalents) {
        if (expanded.has(item.base)) {
            expanded.add(item.equivalent);
        }
    }
    
    return Array.from(expanded);
}

/**
 * Finds the app.json file in the workspace.
 * 
 * @param workspacePath - Root path of the workspace
 * @returns Path to app.json or undefined if not found
 */
export function findAppJson(workspacePath: string): string | undefined {
    const appJsonPath = path.join(workspacePath, 'app.json');
    return fs.existsSync(appJsonPath) ? appJsonPath : undefined;
}

/**
 * Reads and parses the app.json file.
 * 
 * @param appJsonPath - Path to the app.json file
 * @returns Parsed app.json object or undefined if read/parse fails
 */
export function readAppJson(appJsonPath: string): AppJson | undefined {
    try {
        const content = fs.readFileSync(appJsonPath, 'utf8');
        return JSON.parse(content);
    } catch {
        return undefined;
    }
}

/**
 * Checks if the TranslationFile feature is enabled in app.json.
 * 
 * @param appJson - Parsed app.json object
 * @returns True if TranslationFile feature is enabled
 */
export function hasTranslationFeature(appJson: AppJson): boolean {
    return appJson.features?.includes('TranslationFile') ?? false;
}

/**
 * Gets the path to the Translations folder.
 * 
 * @param workspacePath - Root path of the workspace
 * @returns Path to the Translations folder
 */
export function getTranslationsFolder(workspacePath: string): string {
    return path.join(workspacePath, 'Translations');
}

/**
 * Scans for XLIFF translation files in the translations folder.
 * 
 * Finds all .xlf files (excluding .g.xlf) and extracts their language codes.
 * 
 * @param translationsFolder - Path to the Translations folder
 * @returns Map of language codes to file paths
 */
export function getXliffFilesMap(translationsFolder: string): Map<string, string> {
    const files = new Map<string, string>();
    
    if (!fs.existsSync(translationsFolder)) {
        return files;
    }
    
    const entries = fs.readdirSync(translationsFolder);
    
    for (const entry of entries) {
        if (entry.endsWith('.xlf') && !entry.endsWith('.g.xlf')) {
            const match = entry.match(/\.([a-z]{2}-[A-Z]{2}(?:_[a-zA-Z]+)?)\.xlf$/);
            if (match) {
                files.set(match[1], path.join(translationsFolder, entry));
            }
        }
    }
    
    return files;
}

/**
 * Escapes special regex characters in a string.
 * 
 * @param str - The string to escape
 * @returns Escaped string safe for use in RegExp
 */
export function escapeRegex(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/**
 * Validates that equivalent base languages are in the required list.
 * 
 * Logs warnings to output channel if configuration is invalid.
 * 
 * @param config - Extension configuration
 * @param outputChannel - Output channel for warning messages
 * @returns True if configuration is valid
 */
export function validateConfigLanguages(config: TranslationConfig, outputChannel: vscode.OutputChannel): boolean {
    let valid = true;
    
    for (const item of config.equivalents) {
        if (!config.required.includes(item.base)) {
            outputChannel.appendLine(`⚠️ Configuration Warning: Base language '${item.base}' in equivalents must be in required languages`);
            valid = false;
        }
    }
    
    return valid;
}
