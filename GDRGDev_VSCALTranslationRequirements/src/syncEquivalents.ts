/**
 * Equivalent Languages Synchronization Module
 * 
 * Manages automatic creation and synchronization of equivalent language translation files.
 * This module enables maintaining regional language variants by copying and adapting
 * base language files to equivalent languages.
 * 
 * Use cases:
 * - Spanish variants: es-ES → es-MX, es-ES → es-AR, es-ES → es-ES_tradnl
 * - French variants: fr-FR → fr-CA, fr-FR → fr-CH
 * - English variants: en-US → en-GB, en-US → en-AU
 * 
 * Process:
 * 1. Reads base language file
 * 2. Updates target-language attribute to equivalent code
 * 3. Creates/overwrites equivalent language file
 * 4. Provides detailed logging of operations
 * 
 * @module syncEquivalents
 * @author Gerardo Renteria
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import {
    getWorkspacePath,
    getConfig,
    findAppJson,
    getTranslationsFolder,
    getXliffFilesMap
} from './utils';

/**
 * Synchronizes equivalent language files from base languages.
 * 
 * For each configured equivalent language mapping:
 * 1. Validates that the base language file exists
 * 2. Copies the base file to the equivalent language filename
 * 3. Updates the target-language attribute
 * 4. Overwrites any existing equivalent file
 * 
 * @param outputChannel - VS Code output channel for detailed logging
 */
export async function syncEquivalentLanguages(outputChannel: vscode.OutputChannel): Promise<void> {
    outputChannel.clear();
    outputChannel.appendLine('=== Sync Equivalent Languages ===');
    outputChannel.appendLine('');
    
    const workspacePath = getWorkspacePath();
    if (!workspacePath) {
        vscode.window.showErrorMessage('No workspace folder found');
        return;
    }
    
    const config = getConfig();
    if (config.equivalents.length === 0) {
        outputChannel.appendLine('No equivalent languages configured');
        outputChannel.show(true);
        return;
    }
    
    const appJsonPath = findAppJson(workspacePath);
    if (!appJsonPath) {
        vscode.window.showErrorMessage('app.json not found');
        return;
    }
    
    const translationsFolder = getTranslationsFolder(workspacePath);
    
    if (!fs.existsSync(translationsFolder)) {
        fs.mkdirSync(translationsFolder, { recursive: true });
    }
    
    const xliffFiles = getXliffFilesMap(translationsFolder);
    
    let synced = 0;
    
    for (const item of config.equivalents) {
        outputChannel.appendLine(`Processing: ${item.base} → ${item.equivalent}`);
        
        if (!xliffFiles.has(item.base)) {
            outputChannel.appendLine(`  ⚠️ Base language ${item.base} not found, skipping`);
            continue;
        }
        
        const baseFilePath = xliffFiles.get(item.base)!;
        const equivalentFileName = path.basename(baseFilePath).replace(`.${item.base}.xlf`, `.${item.equivalent}.xlf`);
        const equivalentFilePath = path.join(translationsFolder, equivalentFileName);
        
        try {
            let content = fs.readFileSync(baseFilePath, 'utf8');
            content = content.replace(new RegExp(`target-language="${item.base}"`, 'g'), `target-language="${item.equivalent}"`);
            
            fs.writeFileSync(equivalentFilePath, content, 'utf8');
            
            outputChannel.appendLine(`  ✅ Created ${equivalentFileName}`);
            synced++;
        } catch (error) {
            outputChannel.appendLine(`  ❌ Failed to create ${equivalentFileName}: ${error}`);
        }
    }
    
    outputChannel.appendLine('');
    outputChannel.appendLine(`Sync complete: ${synced} file(s) created`);
    outputChannel.show(true);
    
    if (synced > 0) {
        vscode.window.showInformationMessage(`✅ Sync Equivalents: ${synced} file(s) created. Check the Output panel for details.`);
    } else {
        vscode.window.showWarningMessage('Sync Equivalents: No files were created. Check the Output panel for details.');
    }
}
