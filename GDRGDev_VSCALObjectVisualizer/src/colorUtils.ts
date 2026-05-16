/**
 * Color Utilities
 *
 * Maps a hex color string to the nearest VS Code charts theme color name.
 * Used by both the decoration provider and the stats tree provider.
 *
 * @module colorUtils
 * @author Gerardo Renteria
 * @license MIT
 */

/**
 * Returns the VS Code charts theme color name closest to the given hex color.
 *
 * @param hex - Hex color string (e.g. "#FF0000" or "FF0000")
 */
export function hexToThemeColorName(hex: string): string {
    const normalized = hex.toUpperCase().replace('#', '');
    const r = parseInt(normalized.substring(0, 2), 16);
    const g = parseInt(normalized.substring(2, 4), 16);
    const b = parseInt(normalized.substring(4, 6), 16);
    const max = Math.max(r, g, b);

    if (r === max && r > 200 && g < 150 && b < 150) { return 'charts.red'; }
    if (g === max && g > 150 && r < 150 && b < 150) { return 'charts.green'; }
    if (b === max && b > 150 && r < 150 && g < 150) { return 'charts.blue'; }
    if (r > 100 && b > 150 && g < b)                { return 'charts.purple'; }
    if (r > 200 && g > 100 && g < 200 && b < 150 && r > g) { return 'charts.orange'; }
    if (r > 200 && g > 180 && b < 150)              { return 'charts.yellow'; }

    return 'charts.blue';
}
