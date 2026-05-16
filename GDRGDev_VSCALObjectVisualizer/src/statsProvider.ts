/**
 * AL Stats Tree Provider
 *
 * Drives the "AL Object Visualizer" panel. Scans all .al files in the workspace,
 * counts objects by type, and groups them by folder. Supports filtering and
 * multi-root workspaces (each workspace folder gets its own top-level node).
 *
 * @module statsProvider
 * @author Gerardo Renteria
 * @license MIT
 */

import * as vscode from 'vscode';
import { detectObjectInfo } from './objectDetector';
import { hexToThemeColorName } from './colorUtils';

type FileInfo = { uri: vscode.Uri; name: string; fileName: string; id?: string; folder: string };

/** Provides the AL Object Visualizer tree view with object counts and folder grouping. */
export class ALStatsProvider implements vscode.TreeDataProvider<StatsItem> {
    private _onDidChangeTreeData = new vscode.EventEmitter<StatsItem | undefined | null | void>();
    readonly onDidChangeTreeData = this._onDidChangeTreeData.event;
    private stats: Map<string, number> = new Map();
    private filesByType: Map<string, FileInfo[]> = new Map();
    private folderStats: Map<string, Map<string, number>> = new Map();
    private currentDepth: number = -1;
    private isScanning: boolean = false;
    private scanDuration: number = 0;
    private filterText: string = '';
    private filteredStats: Map<string, number> = new Map();
    private filteredFilesByType: Map<string, FileInfo[]> = new Map();
    private filteredFolderStats: Map<string, Map<string, number>> = new Map();

    constructor() {}

    /** Forces a full rescan of the workspace and refreshes the tree. */
    refresh(): void {
        this.currentDepth = -1;
        this._onDidChangeTreeData.fire();
    }

    /** Returns the tree item for the given element. */
    getTreeItem(element: StatsItem): vscode.TreeItem {
        return element;
    }

    /**
     * Returns child items for the tree. Triggers a workspace scan when needed.
     *
     * @param element - Parent item, or undefined for the root level
     */
    async getChildren(element?: StatsItem): Promise<StatsItem[]> {
        const config = vscode.workspace.getConfiguration('alObjectVisualizer');
        const depth = config.get<number>('folderGroupingDepth', 0);

        // Rescan only if depth changed or no data
        if (this.currentDepth !== depth || this.stats.size === 0) {
            if (!this.isScanning) {
                this.isScanning = true;
                await this.scanWorkspace();
                this.currentDepth = depth;
                this.isScanning = false;
                // Re-apply active filter against fresh scan data
                if (this.filterText) {
                    this.clearFilteredData();
                    this.recomputeFilteredData(depth);
                }
            }
        }

        if (depth === 0) {
            return this.getFlatView(element);
        } else {
            return this.getFolderView(element);
        }
    }

    private getFlatView(element?: StatsItem): StatsItem[] {
        if (element) {
            return [];
        }

        const items: StatsItem[] = [];
        const statsToUse = this.filterText ? this.filteredStats : this.stats;
        const sortedTypes = Array.from(statsToUse.entries()).sort((a, b) => a[0].localeCompare(b[0]));
        
        for (const [type, count] of sortedTypes) {
            items.push(new StatsItem(type, count, 'type'));
        }

        const total = sumMapValues(statsToUse);
        items.push(new StatsItem('Total', total, 'total', undefined, this.scanDuration));

        return items;
    }

    private getFolderView(element: StatsItem | undefined): StatsItem[] {
        const isMultiRoot = (vscode.workspace.workspaceFolders?.length ?? 0) > 1;
        const folderStatsToUse = this.filterText ? this.filteredFolderStats : this.folderStats;

        if (!element) {
            const grandTotal = sumMapValues2D(folderStatsToUse);

            if (isMultiRoot) {
                // Top level: one node per workspace folder
                const workspaceMap = new Map<string, number>();
                for (const [key, stats] of folderStatsToUse.entries()) {
                    const wsName = key.split('/')[0];
                    workspaceMap.set(wsName, (workspaceMap.get(wsName) || 0) + sumMapValues(stats));
                }
                const items = Array.from(workspaceMap.entries())
                    .sort((a, b) => a[0].localeCompare(b[0]))
                    .map(([name, total]) => new StatsItem(name, total, 'workspace'));
                items.push(new StatsItem('Total', grandTotal, 'total', undefined, this.scanDuration));
                return items;
            } else {
                // Single root: one node per folder path
                const items = Array.from(folderStatsToUse.keys()).sort().map(folder =>
                    new StatsItem(folder, sumMapValues(folderStatsToUse.get(folder)!), 'folder')
                );
                items.push(new StatsItem('Total', grandTotal, 'total', undefined, this.scanDuration));
                return items;
            }
        }

        if (element.itemType === 'workspace') {
            // Sub-folders within the workspace folder
            const wsName = element.objectType;
            const items: StatsItem[] = [];
            for (const [key, stats] of folderStatsToUse.entries()) {
                if (key === wsName || key.startsWith(wsName + '/')) {
                    const subLabel = key === wsName ? '(root)' : key.substring(wsName.length + 1);
                    items.push(new StatsItem(key, sumMapValues(stats), 'folder', undefined, undefined, subLabel));
                }
            }
            items.sort((a, b) => (a.displayLabel || a.objectType).localeCompare(b.displayLabel || b.objectType));
            return items;
        }

        if (element.itemType === 'folder') {
            const folderStats = folderStatsToUse.get(element.objectType);
            if (folderStats) {
                const items = Array.from(folderStats.entries())
                    .sort((a, b) => a[0].localeCompare(b[0]))
                    .map(([type, count]) => new StatsItem(type, count, 'type', element.objectType));
                items.push(new StatsItem('Total', sumMapValues(folderStats), 'total'));
                return items;
            }
        }

        return [];
    }

    /**
     * Returns the scanned files for a given object type, optionally scoped to a folder.
     *
     * @param objectType - AL object type (e.g. "table", "page")
     * @param folder - Optional folder path to narrow the results
     */
    getFilesForType(objectType: string, folder?: string): FileInfo[] {
        const filesToUse = this.filterText ? this.filteredFilesByType : this.filesByType;
        const files = filesToUse.get(objectType.toLowerCase()) || [];
        if (folder) {
            return files.filter(f => f.folder === folder);
        }
        return files;
    }

    /**
     * Filters the tree to objects whose name, filename, or ID match the given text.
     * Supports regular expressions. Pass an empty string to clear the filter.
     *
     * @param filterText - Search string or regex pattern
     */
    applyFilter(filterText: string): void {
        this.filterText = filterText.trim();
        this.clearFilteredData();

        if (this.filterText) {
            const config = vscode.workspace.getConfiguration('alObjectVisualizer');
            const depth = config.get<number>('folderGroupingDepth', 0);
            this.recomputeFilteredData(depth);
        }

        this._onDidChangeTreeData.fire();
    }

    /**
     * Recomputes filtered maps from the current scan data and active filter text.
     * Called by both `applyFilter` (user-initiated) and after a rescan when a filter is active.
     *
     * @param depth - Current folder grouping depth
     */
    private recomputeFilteredData(depth: number): void {
        let regex: RegExp | null = null;
        try { regex = new RegExp(this.filterText, 'i'); } catch { /* invalid regex — use plain text */ }

        const filterTextLower = this.filterText.toLowerCase();

        for (const [type, files] of this.filesByType.entries()) {
            const matchingFiles = files.filter(f => regex
                ? regex.test(f.name) || regex.test(f.fileName) || (f.id !== undefined && regex.test(f.id))
                : f.name.toLowerCase().includes(filterTextLower) ||
                  f.fileName.toLowerCase().includes(filterTextLower) ||
                  (f.id !== undefined && f.id.toLowerCase().includes(filterTextLower))
            );

            if (matchingFiles.length > 0) {
                this.filteredFilesByType.set(type, matchingFiles);
                this.filteredStats.set(type, matchingFiles.length);

                if (depth > 0) {
                    for (const file of matchingFiles) {
                        if (!this.filteredFolderStats.has(file.folder)) {
                            this.filteredFolderStats.set(file.folder, new Map());
                        }
                        const folderMap = this.filteredFolderStats.get(file.folder)!;
                        folderMap.set(type, (folderMap.get(type) || 0) + 1);
                    }
                }
            }
        }
    }

    private clearFilteredData(): void {
        this.filteredStats.clear();
        this.filteredFilesByType.clear();
        this.filteredFolderStats.clear();
    }

    private getFolderPath(uri: vscode.Uri, depth: number, workspaceFolder: vscode.WorkspaceFolder): string {
        const isMultiRoot = (vscode.workspace.workspaceFolders?.length ?? 0) > 1;
        const workspaceName = workspaceFolder.name;

        const workspacePath = workspaceFolder.uri.fsPath;
        const filePath = uri.fsPath;

        if (!filePath.startsWith(workspacePath)) {
            return isMultiRoot ? workspaceName : '(root)';
        }

        const relativePath = filePath.substring(workspacePath.length).replace(/^[\\\/]/, '');
        const parts = relativePath.split(/[\/\\]/);

        if (parts.length <= 1 || depth === 0) {
            return isMultiRoot ? workspaceName : '(root)';
        }

        const folderParts = parts.slice(0, Math.min(depth, parts.length - 1));
        const subPath = folderParts.join('/');
        return isMultiRoot ? `${workspaceName}/${subPath}` : subPath;
    }

    private async scanWorkspace(): Promise<void> {
        const startTime = Date.now();
        this.stats.clear();
        this.filesByType.clear();
        this.folderStats.clear();
        
        const config = vscode.workspace.getConfiguration('alObjectVisualizer');
        const depth = config.get<number>('folderGroupingDepth', 0);
        
        // Get only files from workspace folders (avoid duplicates in multi-root workspaces)
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (!workspaceFolders) {
            return;
        }

        const processedFiles = new Set<string>();
        const BATCH_SIZE = 100; // Process 100 files in parallel

        for (const folder of workspaceFolders) {
            const pattern = new vscode.RelativePattern(folder, '**/*.al');
            const alFiles = await vscode.workspace.findFiles(pattern, '**/node_modules/**');

            // Process files in batches for better performance
            for (let i = 0; i < alFiles.length; i += BATCH_SIZE) {
                const batch = alFiles.slice(i, i + BATCH_SIZE);
                
                // Process batch in parallel
                const results = await Promise.all(
                    batch.map(async (file) => {
                        const fileKey = file.toString();
                        if (processedFiles.has(fileKey)) {
                            return null;
                        }
                        processedFiles.add(fileKey);

                        const info = await detectObjectInfo(file);
                        if (info) {
                            const folderPath = this.getFolderPath(file, depth, folder);
                            const fileName = file.fsPath.split(/[\\/]/).pop() || '';
                            return { file, info, folderPath, fileName };
                        }
                        return null;
                    })
                );

                // Aggregate results
                for (const result of results) {
                    if (!result) continue;

                    const { file, info, folderPath, fileName } = result;
                    const type = info.type;
                    
                    this.stats.set(type, (this.stats.get(type) || 0) + 1);
                    
                    if (!this.filesByType.has(type)) {
                        this.filesByType.set(type, []);
                    }
                    
                    this.filesByType.get(type)!.push({
                        uri: file,
                        name: info.name,
                        fileName: fileName,
                        id: info.id,
                        folder: folderPath
                    });

                    if (depth > 0) {
                        if (!this.folderStats.has(folderPath)) {
                            this.folderStats.set(folderPath, new Map());
                        }
                        const folderMap = this.folderStats.get(folderPath)!;
                        folderMap.set(type, (folderMap.get(type) || 0) + 1);
                    }
                }
            }
        }
        
        this.scanDuration = (Date.now() - startTime) / 1000;
    }
}

class StatsItem extends vscode.TreeItem {
    constructor(
        public readonly objectType: string,
        public readonly count: number,
        public readonly itemType: 'type' | 'total' | 'folder' | 'workspace',
        public readonly folderPath?: string,
        public readonly scanDuration?: number,
        public readonly displayLabel?: string
    ) {
        let label: string;
        let collapsibleState = vscode.TreeItemCollapsibleState.None;
        let objConfig: { color?: string; badge?: string } | undefined;

        if (itemType === 'type') {
            const objectTypes = vscode.workspace
                .getConfiguration('alObjectVisualizer')
                .get<Record<string, { color?: string; badge?: string }>>('objectTypes', {});
            objConfig = objectTypes[objectType.toLowerCase()];
            const badge = objConfig?.badge || '';
            label = badge ? `${badge} ${objectType}: ${count}` : `${objectType}: ${count}`;
        } else if (itemType === 'workspace' || itemType === 'folder') {
            label = `${displayLabel || objectType} (${count})`;
            collapsibleState = vscode.TreeItemCollapsibleState.Collapsed;
        } else {
            label = scanDuration ? `∑ Total: ${count} (${scanDuration.toFixed(2)}s)` : `∑ Total: ${count}`;
        }

        super(label, collapsibleState);

        if (itemType === 'workspace') {
            this.iconPath = new vscode.ThemeIcon('folder-library');
        } else if (itemType === 'folder') {
            this.iconPath = new vscode.ThemeIcon('folder');
        } else if (itemType === 'total') {
            this.iconPath = new vscode.ThemeIcon('symbol-number');
        } else if (objConfig?.color) {
            this.iconPath = new vscode.ThemeIcon('circle-filled', new vscode.ThemeColor(hexToThemeColorName(objConfig.color)));
        }

        if (itemType === 'type') {
            this.command = {
                command: 'alObjectVisualizer.showFiles',
                title: 'Show Files',
                arguments: [objectType, folderPath]
            };
        }
    }
}

/** Sums all values in a `Map<string, number>`. */
function sumMapValues(map: Map<string, number>): number {
    let total = 0;
    for (const v of map.values()) { total += v; }
    return total;
}

/** Sums all values in a nested `Map<string, Map<string, number>>`. */
function sumMapValues2D(map: Map<string, Map<string, number>>): number {
    let total = 0;
    for (const inner of map.values()) { total += sumMapValues(inner); }
    return total;
}
