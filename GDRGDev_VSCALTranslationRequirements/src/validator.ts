/**
 * Translation Validation Module
 * 
 * This module handles validation of translation files in Business Central AL extensions.
 * It checks that all required language files exist and provides diagnostic feedback
 * through VS Code's Problems panel.
 * 
 * Key features:
 * - Validates presence of required translation files
 * - Expands validation to include equivalent language variants
 * - Outputs detailed validation reports to the Output channel
 * - Creates diagnostic entries for missing translations
 * 
 * @module validator
 * @author Gerardo Renteria
 */

import * as vscode from 'vscode';
import * as path from 'path';
import { 
    getWorkspacePath, 
    getConfig, 
    getExpandedRequiredLanguages,
    findAppJson,
    readAppJson,
    hasTranslationFeature,
    getTranslationsFolder,
    getXliffFilesMap,
    validateConfigLanguages
} from './utils';
import { ValidationResult } from './types';

/**
 * Validates that all required translation files exist in the workspace.
 * 
 * This function performs comprehensive validation:
 * 1. Checks workspace and app.json existence
 * 2. Expands required languages to include equivalents
 * 3. Scans for existing XLIFF files
 * 4. Reports missing translations to Problems panel and Output channel
 * 
 * @param outputChannel - VS Code output channel for detailed logging
 * @param diagnosticCollection - Diagnostic collection for Problems panel
 * @returns Validation result with success status and list of missing languages
 */
export async function validateTranslations(outputChannel: vscode.OutputChannel, diagnosticCollection: vscode.DiagnosticCollection): Promise<ValidationResult> {
    outputChannel.clear();
    diagnosticCollection.clear();
    
    outputChannel.appendLine('=== AL Translation Requirements Validation ===');
    outputChannel.appendLine('');

    const workspacePath = getWorkspacePath();
    if (!workspacePath) {
        outputChannel.appendLine('❌ No workspace folder found');
        return { success: false, missing: [], allRequired: [] };
    }
    
    const config = getConfig();
    outputChannel.appendLine(`Configuration:`);
    outputChannel.appendLine(`  Required: [${config.required.join(', ')}]`);
    outputChannel.appendLine(`  Equivalents: ${JSON.stringify(config.equivalents)}`);
    outputChannel.appendLine('');
    
    if (config.required.length === 0) {
        outputChannel.appendLine('⚠️ No required languages configured.');
        outputChannel.appendLine('Add language codes to alTranslationRequirements.required in settings.');
        outputChannel.show(true);
        return { success: true, missing: [], allRequired: [] };
    }

    if (!validateConfigLanguages(config, outputChannel)) {
        outputChannel.appendLine('');
    }
    
    const allRequired = getExpandedRequiredLanguages(config);
    outputChannel.appendLine(`Expanded Required: [${allRequired.join(', ')}]`);
    outputChannel.appendLine('');
    
    const appJsonPath = findAppJson(workspacePath);
    if (!appJsonPath) {
        outputChannel.appendLine('❌ app.json not found');
        return { success: false, missing: [], allRequired };
    }
    
    const appJson = readAppJson(appJsonPath);
    if (!appJson) {
        outputChannel.appendLine('❌ Failed to read app.json');
        return { success: false, missing: [], allRequired };
    }
    
    outputChannel.appendLine(`App Name: ${appJson.name}`);
    
    if (!hasTranslationFeature(appJson)) {
        outputChannel.appendLine('⚠️ TranslationFile feature not enabled in app.json');
        outputChannel.appendLine('');
    }
    
    const translationsFolder = getTranslationsFolder(workspacePath);
    const xliffFiles = getXliffFilesMap(translationsFolder);
    
    outputChannel.appendLine('');
    outputChannel.appendLine(`Found XLF files: ${xliffFiles.size}`);
    for (const [lang, filePath] of xliffFiles) {
        outputChannel.appendLine(`  ✓ ${lang} - ${path.basename(filePath)}`);
    }
    
    outputChannel.appendLine('');
    outputChannel.appendLine('Validation Results:');
    
    const missing: string[] = [];
    const diagnostics: vscode.Diagnostic[] = [];
    
    for (const lang of allRequired) {
        if (xliffFiles.has(lang)) {
            outputChannel.appendLine(`  ✅ ${lang} - OK`);
        } else {
            outputChannel.appendLine(`  ❌ ${lang} - MISSING`);
            missing.push(lang);
            
            const diagnostic = new vscode.Diagnostic(
                new vscode.Range(0, 0, 0, 0),
                `Required translation file missing: ${lang}`,
                vscode.DiagnosticSeverity.Warning
            );
            diagnostic.source = 'AL Translation Requirements';
            diagnostics.push(diagnostic);
        }
    }
    
    if (diagnostics.length > 0 && appJsonPath) {
        diagnosticCollection.set(vscode.Uri.file(appJsonPath), diagnostics);
    }
    
    outputChannel.appendLine('');
    if (missing.length === 0) {
        outputChannel.appendLine('✅ All required translations present');
    } else {
        outputChannel.appendLine(`⚠️ Missing ${missing.length} required translation(s)`);
    }
    
    outputChannel.show(true);
    
    return { success: missing.length === 0, missing, allRequired };
}
