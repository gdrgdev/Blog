codeunit 88891 "GDRG Pseudonymizer"
{
    procedure GetValue(SourceValue: Text; MaxLength: Integer): Text
    var
        Prefix: Text;
        Salt: Text;
        HashText: Text;
    begin
        if SourceValue = '' then
            exit('');

        Salt := GetSalt();
        HashText := BuildToken(Salt + '|' + UpperCase(SourceValue));
        Prefix := 'ANON-';

        if MaxLength <= StrLen(Prefix) then
            exit(CopyStr(HashText, 1, MaxLength));

        exit(CopyStr(Prefix + HashText, 1, MaxLength));
    end;

    local procedure BuildToken(InputText: Text): Text
    var
        Index: Integer;
        DigitIndex: Integer;
        ResultText: Text;
        Digits: array[20] of Integer;
    begin
        for Index := 1 to StrLen(InputText) do
            for DigitIndex := 1 to ArrayLen(Digits) do
                Digits[DigitIndex] := (Digits[DigitIndex] + (InputText[Index] * (Index + DigitIndex * 17))) mod 10;

        for DigitIndex := 1 to ArrayLen(Digits) do
            ResultText += Format(Digits[DigitIndex]);

        exit(ResultText);
    end;

    local procedure GetSalt(): Text
    var
        Salt: Text;
        NewSalt: Guid;
    begin
        if IsolatedStorage.Get('GDRG-ENV-CLEANUP-SALT', DataScope::Module, Salt) then
            exit(Salt);

        NewSalt := CreateGuid();
        Salt := Format(NewSalt);
        IsolatedStorage.Set('GDRG-ENV-CLEANUP-SALT', Salt, DataScope::Module);
        exit(Salt);
    end;
}