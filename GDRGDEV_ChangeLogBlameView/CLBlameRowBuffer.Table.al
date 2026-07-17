namespace DefaultPublisher.ChangeLogView;

table 88888 "CL Blame Row Buffer"
{
    Caption = 'CL Blame Row Buffer';
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; "Row No."; Integer)
        {
            AllowInCustomizations = Never;
            Caption = 'Row No.';
            ToolTip = 'Specifies the internal row number used to order the blame matrix.';
        }
        field(2; "Row Caption"; Text[80])
        {
            AllowInCustomizations = AsReadOnly;
            Caption = 'Row Caption';
            ToolTip = 'Specifies the field name or event metadata label shown in the blame matrix.';
        }
        field(3; "Is Header"; Boolean)
        {
            AllowInCustomizations = Never;
            Caption = 'Is Header';
            ToolTip = 'Specifies whether the row is a header row in the blame matrix.';
        }
        field(4; "Field No."; Integer)
        {
            AllowInCustomizations = Never;
            Caption = 'Field No.';
            ToolTip = 'Specifies the source field number represented by the row.';
        }
    }

    keys
    {
        key(PK; "Row No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Row No.", "Row Caption")
        {
        }
        fieldgroup(Brick; "Row No.", "Row Caption")
        {
        }
    }
}
