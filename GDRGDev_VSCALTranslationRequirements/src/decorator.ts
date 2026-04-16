/**
 * Visual Decoration Module
 * 
 * Provides visual highlighting for translation issues in XLIFF files.
 * This module decorates trans-unit elements that have missing or incomplete translations.
 * 
 * Behavior:
 * - In g.xlf files: Highlights trans-units with issues in ANY language file
 * - In language-specific files: Highlights only issues in that specific file
 * 
 * Highlighting triggers:
 * - Missing <target> element
 * - Empty <target> element
 * - Target state is 'needs-translation' or 'new'
 * 
 * The background color is configurable via extension settings.
 * 
 * @module decorator
 * @author Gerardo Renteria
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { escapeRegex } from './utils';

let decorationType: vscode.TextEditorDecorationType | undefined;

/**
 * Activates the visual decoration feature.
 * 
 * Registers event listeners for:
 * - Active editor changes
 * - Document content changes
 * - Configuration changes
 * 
 * @param context - Extension context for subscription management
 */
export function activateDecorator(context: vscode.ExtensionContext) {
    updateDecorationType();
    
    if (vscode.window.activeTextEditor) {
        decorateEditor(vscode.window.activeTextEditor);
    }
    
    context.subscriptions.push(
        vscode.window.onDidChangeActiveTextEditor(editor => {
            if (editor) {
                decorateEditor(editor);
            }
        })
    );
    
    context.subscriptions.push(
        vscode.workspace.onDidChangeTextDocument(event => {
            const editor = vscode.window.activeTextEditor;
            if (editor && event.document === editor.document) {
                decorateEditor(editor);
            }
        })
    );
    
    context.subscriptions.push(
        vscode.workspace.onDidChangeConfiguration(event => {
            if (event.affectsConfiguration('alTranslationRequirements.decoration')) {
                updateDecorationType();
                if (vscode.window.activeTextEditor) {
                    decorateEditor(vscode.window.activeTextEditor);
                }
            }
        })
    );
}

function updateDecorationType() {
    const config = vscode.workspace.getConfiguration('alTranslationRequirements.decoration');
    const backgroundColor = config.get<string>('backgroundColor', '#F0D269');
    
    if (decorationType) {
        decorationType.dispose();
    }
    
    decorationType = vscode.window.createTextEditorDecorationType({
        backgroundColor: backgroundColor,
        isWholeLine: true
    });
}

function decorateEditor(editor: vscode.TextEditor) {
    const config = vscode.workspace.getConfiguration('alTranslationRequirements.decoration');
    const enabled = config.get<boolean>('enabled', true);
    
    if (!enabled || !decorationType) {
        return;
    }
    
    const document = editor.document;
    const decorations: vscode.DecorationOptions[] = [];
    
    if (document.fileName.endsWith('.g.xlf')) {
        const text = document.getText();
        const lines = text.split('\n');
        const translationsFolder = path.dirname(document.fileName);
        const baseFileName = path.basename(document.fileName).replace('.g.xlf', '');
        
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const transUnitMatch = line.match(/<trans-unit\s+id="([^"]+)"/);
            
            if (transUnitMatch && hasTranslationIssues(translationsFolder, baseFileName, transUnitMatch[1])) {
                decorations.push({ 
                    range: new vscode.Range(new vscode.Position(i, 0), new vscode.Position(i, line.length)) 
                });
            }
        }
    } else if (document.fileName.endsWith('.xlf') && !document.fileName.endsWith('.g.xlf')) {
        const text = document.getText();
        const lines = text.split('\n');
        
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            
            if (line.includes('<trans-unit')) {
                let transUnitContent = line;
                let j = i + 1;
                
                while (j < lines.length && !transUnitContent.includes('</trans-unit>')) {
                    transUnitContent += '\n' + lines[j];
                    j++;
                }
                
                const targetMatch = transUnitContent.match(/<target[^>]*>([\s\S]*?)<\/target>/i);
                
                if (!targetMatch) {
                    // No target element
                    decorations.push({ 
                        range: new vscode.Range(new vscode.Position(i, 0), new vscode.Position(i, line.length)) 
                    });
                } else {
                    const targetContent = targetMatch[1].trim();
                    
                    if (targetContent === '') {
                        // Empty target
                        decorations.push({ 
                            range: new vscode.Range(new vscode.Position(i, 0), new vscode.Position(i, line.length)) 
                        });
                    } else {
                        // Check for needs-translation or new states
                        const stateMatch = targetMatch[0].match(/state="([^"]+)"/i);
                        if (stateMatch) {
                            const state = stateMatch[1];
                            if (state === 'needs-translation' || state === 'new') {
                                decorations.push({ 
                                    range: new vscode.Range(new vscode.Position(i, 0), new vscode.Position(i, line.length)) 
                                });
                            }
                        }
                    }
                }
            }
        }
    }
    
    editor.setDecorations(decorationType, decorations);
}

function hasTranslationIssues(translationsFolder: string, baseFileName: string, transUnitId: string): boolean {
    if (!fs.existsSync(translationsFolder)) {
        return false;
    }
    
    const entries = fs.readdirSync(translationsFolder);
    const escapedId = escapeRegex(transUnitId);
    
    for (const entry of entries) {
        if (entry.endsWith('.g.xlf') || !entry.endsWith('.xlf')) {
            continue;
        }
        
        const match = entry.match(/^(.+?)\.([a-z]{2}-[A-Z]{2}(?:_[a-zA-Z]+)?)\.xlf$/);
        
        if (match && match[1] === baseFileName) {
            try {
                const content = fs.readFileSync(path.join(translationsFolder, entry), 'utf8');
                const transUnitRegex = new RegExp(`<trans-unit[^>]*id="${escapedId}"[^>]*>([\\s\\S]*?)</trans-unit>`, 'i');
                const transUnitMatch = content.match(transUnitRegex);
                
                if (!transUnitMatch) {
                    return true;
                }
                
                const transUnitContent = transUnitMatch[1];
                const targetMatch = transUnitContent.match(/<target[^>]*>([\s\S]*?)<\/target>/i);
                
                if (!targetMatch) {
                    return true;
                }
                
                const targetContent = targetMatch[1].trim();
                
                if (targetContent === '') {
                    return true;
                }
                
                // Check for needs-translation or new states
                const stateMatch = targetMatch[0].match(/state="([^"]+)"/i);
                if (stateMatch) {
                    const state = stateMatch[1];
                    if (state === 'needs-translation' || state === 'new') {
                        return true;
                    }
                }
            } catch (error) {
                return true;
            }
        }
    }
    
    return false;
}

/**
 * Deactivates the decorator and disposes of resources.
 */
export function deactivateDecorator() {
    if (decorationType) {
        decorationType.dispose();
    }
}
