table 50101 "GDRG Personal Tag Master"
{
    Caption = 'Personal Tag Master';
    LookupPageId = "GDRG Personal Tag Master";
    DrillDownPageId = "GDRG Personal Tag Master";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the user who owns the tag.';
            TableRelation = User."User Name";
            DataClassification = EndUserIdentifiableInformation;
            AllowInCustomizations = Never;
        }
        field(2; Code; Code[20])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the unique code for the tag.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; Name; Text[50])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the display name of the tag.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(4; Color; Enum "GDRG Color")
        {
            Caption = 'Color';
            ToolTip = 'Specifies the color associated with the tag.';
            DataClassification = CustomerContent;
        }
        field(5; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            ToolTip = 'Specifies when the tag was created.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the tag.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "User ID", Code)
        {
            Clustered = true;
        }
        key(Name; "User ID", Name)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Code, Name, Color, Description)
        {
        }
        fieldgroup(DropDown; Code, Name, Color)
        {
        }
    }

    trigger OnInsert()
    begin
        if "User ID" = '' then
            "User ID" := CopyStr(UserId(), 1, 50);
        "Created Date" := CurrentDateTime();

        if Code = '' then
            Code := CopyStr(DelChr(Name, '=', ' '), 1, 20); // Auto-generate code from name
    end;
}
