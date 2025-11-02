codeunit 90000 "GDRG Masking Management"
{
    Permissions =
        tabledata "GDRG Field Masking Setup" = R;
    procedure GetPartialValue(TableNo: Integer; FieldNo: Integer; FieldValue: Text): Text
    var
        MaskingSetup: Record "GDRG Field Masking Setup";
    begin
        if FieldValue = '' then
            exit('');

        if not MaskingSetup.Get(TableNo, FieldNo) then
            exit(FieldValue);

        if not MaskingSetup.Enabled then
            exit(FieldValue);

        exit(GetPartialMaskedValue(FieldValue, MaskingSetup."Mask Pattern"));
    end;

    procedure GetPartialMaskedValue(FieldValue: Text; MaskPattern: Enum "GDRG Mask Pattern"): Text
    begin
        if FieldValue = '' then
            exit('');

        case MaskPattern of
            MaskPattern::LastFourDigits:
                exit(MaskLastFourDigits(FieldValue));
            MaskPattern::FirstAndLastTwo:
                exit(MaskFirstAndLastTwo(FieldValue));
            MaskPattern::MiddleVisible:
                exit(MaskMiddle(FieldValue));
            MaskPattern::FullMask:
                exit(MaskFull(FieldValue));
            else
                exit(FieldValue);
        end;
    end;

    local procedure MaskLastFourDigits(Value: Text): Text
    var
        valueLength: Integer;
        maskedPart: Text;
        visiblePart: Text;
    begin
        valueLength := StrLen(Value);

        if valueLength <= 4 then
            exit(PadStr('', valueLength, '*'));

        visiblePart := CopyStr(Value, valueLength - 3, 4);
        maskedPart := PadStr('', valueLength - 4, '*');

        exit(maskedPart + visiblePart);
    end;

    local procedure MaskFirstAndLastTwo(Value: Text): Text
    var
        valueLength: Integer;
        firstPart: Text;
        lastPart: Text;
        maskedPart: Text;
    begin
        valueLength := StrLen(Value);

        if valueLength <= 4 then
            exit(PadStr('', valueLength, '*'));

        firstPart := CopyStr(Value, 1, 2);
        lastPart := CopyStr(Value, valueLength - 1, 2);
        maskedPart := PadStr('', valueLength - 4, '*');

        exit(firstPart + maskedPart + lastPart);
    end;

    local procedure MaskFull(Value: Text): Text
    begin
        exit(PadStr('', StrLen(Value), '*'));
    end;

    local procedure MaskMiddle(Value: Text): Text
    var
        valueLength: Integer;
        maskedChars: Integer;
        startMask: Text;
        middlePart: Text;
        endMask: Text;
        startPos: Integer;
        middleLength: Integer;
    begin
        valueLength := StrLen(Value);

        if valueLength <= 4 then
            exit(PadStr('', valueLength, '*'));

        maskedChars := Round(valueLength * 0.25, 1);
        if maskedChars < 2 then
            maskedChars := 2;

        middleLength := valueLength - (maskedChars * 2);
        startPos := maskedChars + 1;

        startMask := PadStr('', maskedChars, '*');
        middlePart := CopyStr(Value, startPos, middleLength);
        endMask := PadStr('', maskedChars, '*');

        exit(startMask + middlePart + endMask);
    end;
}
