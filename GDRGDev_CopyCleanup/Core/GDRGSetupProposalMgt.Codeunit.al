codeunit 88893 "GDRG Setup Proposal Mgt"
{
    Permissions = tabledata "GDRG Anonymize Setup" = rim,
                  tabledata "GDRG Anonymize Field Setup" = rim;

    procedure AddTable(TableNo: Integer): Boolean
    var
        AnonymizeSetup: Record "GDRG Anonymize Setup";
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if TableNo = 0 then
            exit(false);

        if AnonymizeSetup.Get(TableNo) then begin
            if not AnonymizeSetup.Enabled then begin
                AnonymizeSetup.Enabled := true;
                AnonymizeSetup.Modify(true);
            end;
            exit(false);
        end;

        if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableNo) then
            exit(false);

        AnonymizeSetup.Init();
        AnonymizeSetup.Validate("Table No.", TableNo);
        AnonymizeSetup.Enabled := true;
        AnonymizeSetup.Insert(true);
        exit(true);
    end;

    procedure AddField(TableNo: Integer; FieldNo: Integer): Boolean
    var
        AnonymizeFieldSetup: Record "GDRG Anonymize Field Setup";
        FieldMetadata: Record Field;
    begin
        if (TableNo = 0) or (FieldNo = 0) then
            exit(false);

        if AnonymizeFieldSetup.Get(TableNo, FieldNo) then begin
            if not AnonymizeFieldSetup.Enabled then begin
                AnonymizeFieldSetup.Enabled := true;
                AnonymizeFieldSetup.Modify(true);
            end;
            exit(false);
        end;

        if not FieldMetadata.Get(TableNo, FieldNo) then
            exit(false);

        if not IsSupportedField(FieldMetadata) then
            exit(false);

        AnonymizeFieldSetup.Init();
        AnonymizeFieldSetup.Validate("Table No.", TableNo);
        AnonymizeFieldSetup.Validate("Field No.", FieldNo);
        AnonymizeFieldSetup.Enabled := true;
        AnonymizeFieldSetup.Insert(true);
        exit(true);
    end;

    procedure AddSuggestedFields(TableNo: Integer): Integer
    var
        FieldMetadata: Record Field;
        AddedCount: Integer;
    begin
        if TableNo = 0 then
            exit(0);

        FieldMetadata.SetRange(TableNo, TableNo);
        if FieldMetadata.FindSet() then
            repeat
                if IsSuggestedField(FieldMetadata) then
                    if AddField(TableNo, FieldMetadata."No.") then
                        AddedCount += 1;
            until FieldMetadata.Next() = 0;

        exit(AddedCount);
    end;

    procedure AddSuggestedTables(): Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
        AddedCount: Integer;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        if AllObjWithCaption.FindSet() then
            repeat
                if IsSuggestedTable(AllObjWithCaption) then
                    if AddSuggestedTableWithFields(AllObjWithCaption."Object ID") then
                        AddedCount += 1;
            until AllObjWithCaption.Next() = 0;

        exit(AddedCount);
    end;

    procedure AddSuggestedTableWithFields(TableNo: Integer): Boolean
    begin
        if not AddTable(TableNo) then
            exit(false);

        AddSuggestedFields(TableNo);
        exit(true);
    end;

    local procedure IsSuggestedTable(AllObjWithCaption: Record AllObjWithCaption): Boolean
    begin
        case AllObjWithCaption."Object ID" of
            Database::Customer,
            Database::Vendor,
            Database::Contact,
            Database::Employee,
            Database::Item,
            Database::"Company Information",
            Database::"Ship-to Address",
            Database::"Order Address",
            Database::"Customer Bank Account",
            Database::"Vendor Bank Account",
            Database::"Bank Account",
            Database::"Bank Account Posting Group",
            Database::"Responsibility Center",
            Database::"Salesperson/Purchaser",
            Database::"Standard Customer Sales Code",
            Database::"Standard Vendor Purchase Code":
                exit(true);
        end;

        exit(false);
    end;

    local procedure IsSuggestedField(FieldMetadata: Record Field): Boolean
    var
        FieldNameUpper: Text;
        FieldCaptionUpper: Text;
    begin
        if not IsSupportedField(FieldMetadata) then
            exit(false);

        FieldNameUpper := UpperCase(FieldMetadata.FieldName);
        FieldCaptionUpper := UpperCase(FieldMetadata."Field Caption");

        if ContainsSensitiveKeyword(FieldNameUpper) then
            exit(true);

        exit(ContainsSensitiveKeyword(FieldCaptionUpper));
    end;

    local procedure IsSupportedField(FieldMetadata: Record Field): Boolean
    begin
        case FieldMetadata.Type of
            FieldMetadata.Type::Text,
            FieldMetadata.Type::Code:
                exit(true);
        end;

        exit(false);
    end;

    local procedure ContainsSensitiveKeyword(Value: Text): Boolean
    var
        Keyword: Text;
    begin
        if Value = '' then
            exit(false);

        foreach Keyword in GetSensitiveKeywords() do
            if StrPos(Value, Keyword) > 0 then
                exit(true);

        exit(false);
    end;

    local procedure GetSensitiveKeywords(): List of [Text]
    var
        Keywords: List of [Text];
    begin
        Keywords.Add('NAME');
        Keywords.Add('E-MAIL');
        Keywords.Add('EMAIL');
        Keywords.Add('PHONE');
        Keywords.Add('MOBILE');
        Keywords.Add('ADDRESS');
        Keywords.Add('CONTACT');
        Keywords.Add('BANK');
        Keywords.Add('IBAN');
        Keywords.Add('SWIFT');
        Keywords.Add('VAT');
        Keywords.Add('REGISTRATION');
        Keywords.Add('POST CODE');
        Keywords.Add('POSTCODE');
        Keywords.Add('CITY');
        Keywords.Add('COUNTY');
        Keywords.Add('COUNTRY');
        exit(Keywords);
    end;
}