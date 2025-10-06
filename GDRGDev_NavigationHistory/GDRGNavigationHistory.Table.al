table 50105 "GDRG Navigation History"
{
    Caption = 'Navigation History';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Navigation History";
    DrillDownPageId = "GDRG Navigation History";
    Permissions = tabledata "GDRG Navigation History" = RIMD;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            AllowInCustomizations = Never;
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            AllowInCustomizations = Never;
        }
        field(3; "Entry Type"; Enum "GDRG Nav. History Type")
        {
            Caption = 'Entry Type';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether this is a list page or a specific record visit.';
        }
        field(4; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;
            AllowInCustomizations = Never;
        }
        field(5; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
            DataClassification = SystemMetadata;
            AllowInCustomizations = Never;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the visited page or record.';
        }
        field(7; "Page ID"; Integer)
        {
            Caption = 'Page ID';
            DataClassification = SystemMetadata;
            AllowInCustomizations = Never;
        }
        field(8; "Visited DateTime"; DateTime)
        {
            Caption = 'Visited Date/Time';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies when the page or record was last visited.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(UserTime; "User ID", "Visited DateTime")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Description, "Visited DateTime")
        {
        }
        fieldgroup(Brick; Description, "Entry Type", "Visited DateTime")
        {
        }
    }
}
