/**
 * AL Translation Requirements Extension
 * 
 * Main entry point for the VS Code extension that enforces translation requirements
 * for Business Central AL extensions. This extension provides:
 * - Visual indicators for missing or incomplete translations
 * - Validation of required language files
 * - Automatic management of equivalent language variants
 * - Hover tooltips showing translation status across all languages
 * 
 * @module extension
 * @author Gerardo Renteria
 * @license MIT
 */

import * as vscode from 'vscode';
import { validateTranslations } from './validator';
import { syncEquivalentLanguages } from './syncEquivalents';
import { activateDecorator, deactivateDecorator } from './decorator';
import { registerHoverProvider } from './hoverProvider';

let outputChannel: vscode.OutputChannel;
let diagnosticCollection: vscode.DiagnosticCollection;

/**
 * Activates the AL Translation Requirements extension.
 * 
 * This function is called by VS Code when the extension is activated (when an app.json file is found).
 * It initializes:
 * - Output channel for logging
 * - Diagnostic collection for problems panel
 * - Validation and sync commands
 * - Visual decorators and hover providers
 * 
 * @param context - Extension context provided by VS Code
 */
export function activate(context: vscode.ExtensionContext) {
    outputChannel = vscode.window.createOutputChannel('AL Translation Requirements');
    diagnosticCollection = vscode.languages.createDiagnosticCollection('alTranslationRequirements');
    
    context.subscriptions.push(outputChannel);
    context.subscriptions.push(diagnosticCollection);
    
    const validateCommand = vscode.commands.registerCommand('alTranslationRequirements.validate', async () => {
        await validateTranslations(outputChannel, diagnosticCollection);
    });
    
    const syncCommand = vscode.commands.registerCommand('alTranslationRequirements.syncEquivalents', async () => {
        await syncEquivalentLanguages(outputChannel);
    });
    
    context.subscriptions.push(validateCommand);
    context.subscriptions.push(syncCommand);
    
    activateDecorator(context);
    registerHoverProvider(context);
}

/**
 * Deactivates the extension and cleans up resources.
 * 
 * Called by VS Code when the extension is deactivated.
 * Disposes of output channel, diagnostics, and decorators.
 */
export function deactivate() {
    if (outputChannel) {
        outputChannel.dispose();
    }
    if (diagnosticCollection) {
        diagnosticCollection.dispose();
    }
    deactivateDecorator();
}
