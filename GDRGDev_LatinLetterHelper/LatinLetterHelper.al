codeunit 50100 "Latin Letter Helper"
{
    Access = Public;

    /// <summary>
    /// Extends Type Helper's IsLatinLetter by adding support for Spanish characters
    /// </summary>
    /// <param name="ch">Character to evaluate</param>
    /// <returns>True if it's a basic Latin letter OR Spanish character</returns>
    procedure IsLatinLetterWithSpanish(ch: Char): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        // First check with original function (A-Z, a-z)
        if TypeHelper.IsLatinLetter(ch) then
            exit(true);

        // Add only Spanish-specific characters
        exit(IsSpanishSpecificChar(ch));
    end;

    /// <summary>
    /// Checks only Spanish-specific characters (ñ, accents, diaeresis)
    /// </summary>
    /// <param name="ch">Character to evaluate</param>
    /// <returns>True if it's a Spanish-specific character</returns>
    procedure IsSpanishSpecificChar(ch: Char): Boolean
    var
        CharCode: Integer;
    begin
        CharCode := ch;

        // Only Spanish-specific characters
        case CharCode of
            209:
                exit(true); // Ñ
            241:
                exit(true); // ñ
            193:
                exit(true); // Á
            201:
                exit(true); // É  
            205:
                exit(true); // Í
            211:
                exit(true); // Ó
            218:
                exit(true); // Ú
            220:
                exit(true); // Ü
            225:
                exit(true); // á
            233:
                exit(true); // é
            237:
                exit(true); // í
            243:
                exit(true); // ó
            250:
                exit(true); // ú
            252:
                exit(true); // ü
            else
                exit(false);
        end;
    end;

    /// <summary>
    /// Full support for European languages with extended Latin alphabet
    /// </summary>
    /// <param name="ch">Character to evaluate</param>
    /// <returns>True if it's a basic Latin letter OR extended European character</returns>
    procedure IsLatinLetterEuropean(ch: Char): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        CharCode: Integer;
    begin
        // First check basic letters (A-Z, a-z)
        if TypeHelper.IsLatinLetter(ch) then
            exit(true);

        CharCode := ch;

        // Latin-1 Supplement range (192-255)
        // Exclude mathematical symbols and other non-letters
        if (CharCode >= 192) and (CharCode <= 255) then
            // Exclude characters that are NOT letters in this range
            case CharCode of
                215, // × (multiplication symbol)
                247: // ÷ (division symbol)
                    exit(false);
                else
                    exit(true); // The rest are letters from European languages
            end;

        exit(false);
    end;

    /// <summary>
    /// Checks if a character is French-specific
    /// </summary>
    /// <param name="ch">Character to evaluate</param>
    /// <returns>True if it's a French-specific character</returns>
    procedure IsFrenchSpecificChar(ch: Char): Boolean
    var
        CharCode: Integer;
    begin
        CharCode := ch;

        case CharCode of
            192:
                exit(true); // À
            194:
                exit(true); // Â
            199:
                exit(true); // Ç
            200:
                exit(true); // È
            201:
                exit(true); // É
            202:
                exit(true); // Ê
            203:
                exit(true); // Ë
            206:
                exit(true); // Î
            207:
                exit(true); // Ï
            212:
                exit(true); // Ô
            217:
                exit(true); // Ù
            219:
                exit(true); // Û
            224:
                exit(true); // à
            226:
                exit(true); // â
            231:
                exit(true); // ç
            232:
                exit(true); // è
            233:
                exit(true); // é
            234:
                exit(true); // ê
            235:
                exit(true); // ë
            238:
                exit(true); // î
            239:
                exit(true); // ï
            244:
                exit(true); // ô
            249:
                exit(true); // ù
            251:
                exit(true); // û
            255:
                exit(true); // ÿ
            else
                exit(false);
        end;
    end;

    /// <summary>
    /// Checks if a character is German-specific
    /// </summary>
    /// <param name="ch">Character to evaluate</param>
    /// <returns>True if it's a German-specific character</returns>
    procedure IsGermanSpecificChar(ch: Char): Boolean
    var
        CharCode: Integer;
    begin
        CharCode := ch;

        case CharCode of
            196:
                exit(true); // Ä
            214:
                exit(true); // Ö
            220:
                exit(true); // Ü
            223:
                exit(true); // ß
            228:
                exit(true); // ä
            246:
                exit(true); // ö
            252:
                exit(true); // ü
            else
                exit(false);
        end;
    end;

    /// <summary>
    /// Checks if a character is Nordic-specific (Danish, Norwegian, Swedish)
    /// </summary>
    /// <param name="ch">Character to evaluate</param>
    /// <returns>True if it's a Nordic-specific character</returns>
    procedure IsNordicSpecificChar(ch: Char): Boolean
    var
        CharCode: Integer;
    begin
        CharCode := ch;

        case CharCode of
            197:
                exit(true); // Å
            198:
                exit(true); // Æ
            216:
                exit(true); // Ø
            229:
                exit(true); // å
            230:
                exit(true); // æ
            248:
                exit(true); // ø
            else
                exit(false);
        end;
    end;
}