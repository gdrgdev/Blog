table 97815 "GDRGPE Line"
{
    Caption = 'Page Guide Line';
    DataClassification = SystemMetadata;
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; "Line No."; Integer)
        {
            AllowInCustomizations = Never;
            Caption = 'Line No.';
        }
        field(2; "Line Type"; Enum "GDRGPE Line Type")
        {
            AllowInCustomizations = Never;
            Caption = 'Line Type';
        }
        field(3; Caption; Text[250])
        {
            AllowInCustomizations = Never;
            Caption = 'Name';
            ToolTip = 'Specifies the name of the field or action.';
        }
        field(4; Value; Text[250])
        {
            AllowInCustomizations = Never;
            Caption = 'Value';
            ToolTip = 'Specifies the current value of the field.';
        }
        field(5; Tooltip; Text[1000])
        {
            AllowInCustomizations = Never;
            Caption = 'Description';
            ToolTip = 'Specifies the description of the field or action.';
        }
        field(7; "Style Expr"; Text[30])
        {
            AllowInCustomizations = Never;
            Caption = 'Style';
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Caption, Value, Tooltip) { }
        fieldgroup(DropDown; Caption, "Line Type") { }
    }
}
