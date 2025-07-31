table 50100 "GDRG Audit Entry"
{
    Caption = 'Audit Entry - Demo';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Audit List";
    DrillDownPageId = "GDRG Audit List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            ToolTip = 'Specifies the table number.';
        }
        field(3; "Table Name"; Text[50])
        {
            Caption = 'Table Name';
            ToolTip = 'Specifies the table name.';
        }
        field(4; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
            ToolTip = 'Specifies the field name.';
        }
        field(5; "Field Value"; Text[250])
        {
            Caption = 'Field Value';
            ToolTip = 'Specifies the field value.';
        }
        field(6; "Processing Time"; Duration)
        {
            Caption = 'Processing Time (ms)';
            ToolTip = 'Specifies the processing time.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Time; "Processing Time")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Table Name", "Field Name", "Processing Time")
        {
        }
        fieldgroup(DropDown; "Entry No.", "Table Name", "Field Name")
        {
        }
    }
}
