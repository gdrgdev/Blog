table 78452 "GDRG Table Key"
{
    TableType = Temporary;
    Caption = 'Table Key Selection';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
            AllowInCustomizations = Never;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            ToolTip = 'Specifies the table number.';
            AllowInCustomizations = Never;
        }
        field(3; "Key No."; Integer)
        {
            Caption = 'Key No.';
            ToolTip = 'Specifies the key number.';
            AllowInCustomizations = Never;
        }
        field(4; "Key Name"; Text[250])
        {
            Caption = 'Sort By';
            ToolTip = 'Specifies the key name for sorting.';
        }
        field(5; "Key Fields"; Text[500])
        {
            Caption = 'Fields';
            ToolTip = 'Specifies the fields that compose the key.';
        }
        field(6; "Is Primary"; Boolean)
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies whether this is the primary key.';
            AllowInCustomizations = Never;
        }
        field(7; "Field Count"; Integer)
        {
            Caption = 'Field Count';
            ToolTip = 'Specifies the number of fields in the key.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Key No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Key Name")
        {
        }
        fieldgroup(Brick; "Key Name", "Key Fields")
        {
        }
    }
}
