table 60001 "GDRG Zip Code Info"
{
    Caption = 'Zip Code Information';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Zip Code Info List";
    DrillDownPageId = "GDRG Zip Code Info List";
    Permissions = tabledata "GDRG Zip Code Info" = RI;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number for the zip code record.';
        }
        field(10; "Zip Code"; Code[20])
        {
            Caption = 'Zip Code';
            NotBlank = true;
            ToolTip = 'Specifies the zip code.';
        }
        field(20; Country; Code[10])
        {
            Caption = 'Country';
            NotBlank = true;
            ToolTip = 'Specifies the country code.';
        }
        field(30; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the location.';
        }
        field(40; Latitude; Decimal)
        {
            Caption = 'Latitude';
            DecimalPlaces = 0 : 6;
            ToolTip = 'Specifies the latitude coordinate.';
        }
        field(50; Longitude; Decimal)
        {
            Caption = 'Longitude';
            DecimalPlaces = 0 : 6;
            ToolTip = 'Specifies the longitude coordinate.';
        }
        field(60; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            ToolTip = 'Specifies when the record was created.';
        }
        field(70; "Last Updated"; DateTime)
        {
            Caption = 'Last Updated';
            ToolTip = 'Specifies when the record was last updated.';
        }
    }

    keys
    {
        key(PK; "Zip Code", Country)
        {
            Clustered = true;
        }
        key(EntryNo; "Entry No.")
        {
        }
        key(Name; Name)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Zip Code", Country, Name)
        {
        }
        fieldgroup(Brick; "Zip Code", Country, Name, Latitude, Longitude)
        {
        }
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();

        "Created Date" := CurrentDateTime();
        "Last Updated" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Last Updated" := CurrentDateTime();
    end;

    local procedure GetNextEntryNo(): Integer
    var
        ZipCodeInfo: Record "GDRG Zip Code Info";
    begin
        ZipCodeInfo.SetCurrentKey("Entry No.");
        if ZipCodeInfo.FindLast() then
            exit(ZipCodeInfo."Entry No." + 1);
        exit(1);
    end;

    procedure ZipCodeExists(ZipCode: Code[20]; CountryCode: Code[10]): Boolean
    var
        ZipCodeInfo: Record "GDRG Zip Code Info";
    begin
        ZipCodeInfo.SetRange("Zip Code", ZipCode);
        ZipCodeInfo.SetRange(Country, CountryCode);
        exit(not ZipCodeInfo.IsEmpty());
    end;

    procedure GetZipCodeInfo(ZipCode: Code[20]; CountryCode: Code[10]; var ZipCodeInfo: Record "GDRG Zip Code Info"): Boolean
    begin
        ZipCodeInfo.SetRange("Zip Code", ZipCode);
        ZipCodeInfo.SetRange(Country, CountryCode);
        exit(ZipCodeInfo.FindFirst());
    end;
}
