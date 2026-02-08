import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import * as jsoncParser from 'jsonc-parser';

interface BCLaunchProfile {
    name: string;
    environmentType: string;
    environmentName: string;
    tenant: string;
}

interface BCLaunchProfilesFile {
    profiles: BCLaunchProfile[];
}

export function activate(context: vscode.ExtensionContext) {
    console.log('BC Launch Profile Switcher is now active');

    const applyCommand = vscode.commands.registerCommand('bcLaunchProfileSwitcher.applyProfile', async () => {
        await handleProfileOperation(false);
    });

    const duplicateCommand = vscode.commands.registerCommand('bcLaunchProfileSwitcher.duplicateAndApplyProfile', async () => {
        await handleProfileOperation(true);
    });

    context.subscriptions.push(applyCommand, duplicateCommand);
}

async function handleProfileOperation(shouldDuplicate: boolean) {
    const editor = vscode.window.activeTextEditor;
    
    if (!editor || !editor.document.fileName.endsWith('launch.json')) {
        vscode.window.showErrorMessage('Please open a launch.json file');
        return;
    }

    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (!workspaceFolders) {
        vscode.window.showErrorMessage('No workspace folder found');
        return;
    }

    const bcProfilesPath = path.join(workspaceFolders[0].uri.fsPath, 'bclaunchprofiles.json');
    
    if (!fs.existsSync(bcProfilesPath)) {
        vscode.window.showErrorMessage('bclaunchprofiles.json not found in workspace root');
        return;
    }

    let profiles: BCLaunchProfile[];
    try {
        const content = fs.readFileSync(bcProfilesPath, 'utf8');
        const parsed: BCLaunchProfilesFile = jsoncParser.parse(content);
        profiles = parsed.profiles;
    } catch (error) {
        vscode.window.showErrorMessage('Error reading bclaunchprofiles.json: ' + error);
        return;
    }

    if (!profiles || profiles.length === 0) {
        vscode.window.showErrorMessage('No profiles found in bclaunchprofiles.json');
        return;
    }

    const items = profiles.map(p => ({
        label: p.name,
        description: p.environmentType + ' - ' + p.environmentName,
        detail: p.tenant ? 'Tenant: ' + p.tenant : 'OnPrem',
        profile: p
    }));

    const selected = await vscode.window.showQuickPick(items, {
        placeHolder: shouldDuplicate ? 'Select profile for duplicated configuration' : 'Select a BC Launch Profile to apply',
        matchOnDescription: true,
        matchOnDetail: true
    });

    if (!selected) {
        return;
    }

    await applyProfileToLaunch(editor, selected.profile, shouldDuplicate);
}

async function applyProfileToLaunch(editor: vscode.TextEditor, profile: BCLaunchProfile, shouldDuplicate: boolean = false) {
    const document = editor.document;
    const text = document.getText();
    
    try {
        const launchConfig = jsoncParser.parse(text);
        const cursorPosition = editor.selection.active;
        const configIndex = findConfigurationAtPosition(launchConfig, text, cursorPosition);
        
        if (configIndex === -1) {
            vscode.window.showErrorMessage('Could not determine which configuration to update. Place cursor inside a configuration block.');
            return;
        }

        const config = launchConfig.configurations[configIndex];
        
        if (shouldDuplicate) {
            const newConfig = JSON.parse(JSON.stringify(config));
            newConfig.name = profile.name;
            newConfig.environmentType = profile.environmentType;
            newConfig.environmentName = profile.environmentName;
            newConfig.tenant = profile.tenant;
            launchConfig.configurations.splice(configIndex + 1, 0, newConfig);
        } else {
            config.name = profile.name;
            config.environmentType = profile.environmentType;
            config.environmentName = profile.environmentName;
            config.tenant = profile.tenant;
        }

        const edit = new vscode.WorkspaceEdit();
        const fullRange = new vscode.Range(document.positionAt(0), document.positionAt(text.length));
        const formatted = JSON.stringify(launchConfig, null, 4);
        edit.replace(document.uri, fullRange, formatted);
        const success = await vscode.workspace.applyEdit(edit);
        
        if (success) {
            const action = shouldDuplicate ? 'Duplicated and applied profile' : 'Applied profile';
            vscode.window.showInformationMessage(action + ': ' + profile.name);
        } else {
            vscode.window.showErrorMessage('Failed to apply profile');
        }
    } catch (error) {
        vscode.window.showErrorMessage('Error parsing launch.json: ' + error);
    }
}

function findConfigurationAtPosition(launchConfig: any, text: string, position: vscode.Position): number {
    if (!launchConfig.configurations || launchConfig.configurations.length === 0) {
        return -1;
    }
    if (launchConfig.configurations.length === 1) {
        return 0;
    }
    
    const lines = text.split('\n');
    const cursorLine = position.line;
    
    let inConfigurations = false;
    let currentConfigIndex = -1;
    let braceDepth = 0;
    let configStartLines: number[] = [];
    let configEndLines: number[] = [];
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        
        if (line.includes('"configurations"')) {
            inConfigurations = true;
            continue;
        }
        
        if (!inConfigurations) {
            continue;
        }
        
        for (const char of line) {
            if (char === '{') {
                if (braceDepth === 0) {
                    currentConfigIndex++;
                    configStartLines.push(i);
                }
                braceDepth++;
            } else if (char === '}') {
                braceDepth--;
                if (braceDepth === 0 && currentConfigIndex >= 0) {
                    configEndLines.push(i);
                }
            }
        }
    }
    
    for (let i = 0; i < configStartLines.length; i++) {
        if (cursorLine >= configStartLines[i] && cursorLine <= (configEndLines[i] || cursorLine)) {
            return i;
        }
    }
    
    return 0;
}

export function deactivate() {}
