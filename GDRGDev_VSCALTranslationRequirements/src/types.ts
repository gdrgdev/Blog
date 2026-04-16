/**
 * Type Definitions
 * 
 * TypeScript type definitions for the AL Translation Requirements extension.
 * These interfaces provide type safety and IntelliSense support throughout
 * the extension codebase.
 * 
 * @module types
 * @author Gerardo Renteria
 */

/**
 * Extension configuration for translation requirements
 */
export interface TranslationConfig {
    /** Array of required language codes (e.g., ['es-ES', 'fr-FR']) */
    required: string[];
    /** Mappings from base languages to equivalent language variants */
    equivalents: Array<{base: string; equivalent: string}>;
}

/**
 * Result of translation validation operation
 */
export interface ValidationResult {
    /** Whether all required translations are present */
    success: boolean;
    /** Array of missing language codes */
    missing: string[];
    /** Complete list of required languages (including equivalents) */
    allRequired: string[];
}

/**
 * Business Central app.json file structure (partial)
 */
export interface AppJson {
    /** Application name */
    name: string;
    /** Optional array of enabled features */
    features?: string[];
}

/**
 * XLIFF translation file information
 */
export interface XliffFile {
    /** Full file system path to the XLIFF file */
    path: string;
    /** Language code (e.g., 'es-ES', 'fr-FR') */
    language: string;
    /** Whether the file exists on disk */
    exists: boolean;
}
