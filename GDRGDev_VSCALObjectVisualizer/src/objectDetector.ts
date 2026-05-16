/**
 * AL Object Detector
 *
 * Parses AL source files to identify the object type, name, and ID.
 * Only the first 30 lines are read — AL object declarations always appear at the top.
 *
 * @module objectDetector
 * @author Gerardo Renteria
 * @license MIT
 */

import * as vscode from 'vscode';

const OBJECT_TYPE_REGEX = /^\s*(table|tableextension|page|pageextension|pagecustomization|codeunit|report|xmlport|query|enum|enumextension|interface|controladdin|profile|permissionset|permissionsetextension|entitlement)\s+(\d+\s+)?("?[^"{]+|'[^']+)/i;

/**
 * Returns the AL object type of the given file, or null if not recognized.
 *
 * @param uri - URI of the AL file
 */
export async function detectObjectType(uri: vscode.Uri): Promise<string | null> {
    const info = await detectObjectInfo(uri);
    return info?.type || null;
}

/**
 * Returns the type, name, and optional ID of the AL object declared in the file.
 *
 * @param uri - URI of the AL file
 */
export async function detectObjectInfo(uri: vscode.Uri): Promise<{ type: string; name: string; id?: string } | null> {
    try {
        const document = await vscode.workspace.openTextDocument(uri);
        
        // Only read first 100 lines - AL objects always declare at the top,
        // but files with many 'using' / 'namespace' statements may push the declaration further down
        const maxLines = Math.min(100, document.lineCount);
        
        for (let i = 0; i < maxLines; i++) {
            const line = document.lineAt(i).text.trim();
            
            if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*') || line.startsWith('///')) {
                continue;
            }
            
            if (line.startsWith('using ') || line.startsWith('namespace ')) {
                continue;
            }
            
            const match = line.match(OBJECT_TYPE_REGEX);
            if (match) {
                let name = match[3].trim();
                name = name.replace(/^["']|["']$/g, '');
                
                const id = match[2] ? match[2].trim() : undefined;
                
                return {
                    type: match[1].toLowerCase(),
                    name: name,
                    id: id
                };
            }
        }
        
        return null;
    } catch {
        return null;
    }
}
