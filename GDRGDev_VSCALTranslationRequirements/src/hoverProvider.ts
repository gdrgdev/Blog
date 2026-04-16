/**
 * Hover Information Provider Module
 * 
 * Provides interactive hover tooltips for translation status in g.xlf files.
 * When hovering over a trans-unit in the generated XLIFF file, this module
 * displays the translation status across all language files in the workspace.
 * 
 * Features:
 * - Shows translation status with visual indicators (✅ ⚠️ 🔍 ❌)
 * - Clickable language codes to open specific translation files
 * - Only active in g.xlf files (generated XLIFF)
 * 
 * Status indicators:
 * - ✅ Translated: Complete translation with content
 * - ⚠️ No target / Empty target / Needs translation
 * - 🔍 Needs review: Requires adaptation or review
 * - ❌ Missing trans-unit or file read errors
 * 
 * @module hoverProvider
 * @author Gerardo Renteria
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { escapeRegex } from './utils';

/**
 * Registers the hover provider for g.xlf files.
 * 
 * The hover provider shows translation status across all language files
 * when hovering over trans-unit elements in the generated XLIFF file.
 * 
 * @param context - Extension context for subscription management
 */
export function registerHoverProvider(context: vscode.ExtensionContext) {
    const hoverProvider = vscode.languages.registerHoverProvider(
        { scheme: 'file', pattern: '**/*.g.xlf' },
        {
            provideHover(document, position, token) {
                return provideTranslationStatusHover(document, position);
            }
        }
    );
    
    context.subscriptions.push(hoverProvider);
}

function provideTranslationStatusHover(document: vscode.TextDocument, position: vscode.Position): vscode.Hover | undefined {
    const line = document.lineAt(position.line);
    const lineText = line.text;
    
    const transUnitMatch = lineText.match(/<trans-unit\s+id="([^"]+)"/);
    if (!transUnitMatch) {
        return undefined;
    }
    
    const transUnitId = transUnitMatch[1];
    const translationsFolder = path.dirname(document.fileName);
    const baseFileName = path.basename(document.fileName).replace('.g.xlf', '');
    
    // Get all XLF files dynamically
    const xliffFiles = getLanguageFilesForBase(translationsFolder, baseFileName);
    
    if (xliffFiles.length === 0) {
        return undefined;
    }
    
    // Check translation status for each language
    const statusLines: string[] = ['**Translation Status:**\n'];
    
    for (const xliffFile of xliffFiles) {
        const status = getTranslationStatus(xliffFile.path, transUnitId);
        const langCode = xliffFile.language;
        const fileUri = vscode.Uri.file(xliffFile.path).toString();
        
        statusLines.push(`${status} [${langCode}](${fileUri})`);
    }
    
    const markdown = new vscode.MarkdownString(statusLines.join('\n\n'));
    markdown.isTrusted = true;
    
    return new vscode.Hover(markdown);
}

function getLanguageFilesForBase(translationsFolder: string, baseFileName: string): Array<{language: string, path: string}> {
    const files: Array<{language: string, path: string}> = [];
    
    if (!fs.existsSync(translationsFolder)) {
        return files;
    }
    
    const entries = fs.readdirSync(translationsFolder);
    
    for (const entry of entries) {
        const match = entry.match(/^(.+)\.([a-z]{2}-[A-Z]{2}(?:_[a-zA-Z]+)?)\.xlf$/);
        
        if (match && match[1] === baseFileName) {
            const language = match[2];
            const filePath = path.join(translationsFolder, entry);
            
            files.push({
                language: language,
                path: filePath
            });
        }
    }
    
    files.sort((a, b) => a.language.localeCompare(b.language));
    
    return files;
}

function getTranslationStatus(xliffFilePath: string, transUnitId: string): string {
    try {
        const content = fs.readFileSync(xliffFilePath, 'utf8');
        const transUnitRegex = new RegExp(`<trans-unit[^>]*id="${escapeRegex(transUnitId)}"[^>]*>([\\s\\S]*?)</trans-unit>`, 'i');
        const match = content.match(transUnitRegex);
        
        if (!match) {
            return '❌ Missing trans-unit';
        }
        
        const transUnitContent = match[1];

        const targetMatch = transUnitContent.match(/<target[^>]*>([\s\S]*?)<\/target>/i);
        
        if (!targetMatch) {
            return '⚠️ No target';
        }
        
        const targetContent = targetMatch[1].trim();
        
        if (targetContent === '') {
            return '⚠️ Empty target';
        }
        
        const stateMatch = targetMatch[0].match(/state="([^"]+)"/i);
        if (stateMatch) {
            const state = stateMatch[1];
            if (state === 'needs-translation' || state === 'new') {
                return '⚠️ Needs translation';
            }
            if (state === 'needs-adaptation' || state === 'needs-review-translation') {
                return '🔍 Needs review';
            }
        }
        
        return '✅ Translated';
        
    } catch (error) {
        return '❌ Error reading file';
    }
}


