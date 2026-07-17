namespace DefaultPublisher.ChangeLogView;

table 88889 "CL Blame Cell Buffer"
{
    Caption = 'CL Blame Cell Buffer';
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; "Row No."; Integer)
        {
            AllowInCustomizations = Never;
            Caption = 'Row No.';
        }
        field(2; "Col No."; Integer)
        {
            AllowInCustomizations = Never;
            Caption = 'Col No.';
        }
        field(3; "Cell Value"; Text[2048])
        {
            AllowInCustomizations = Never;
            Caption = 'Cell Value';
        }
    }

    keys
    {
        key(PK; "Row No.", "Col No.")
        {
            Clustered = true;
        }
    }
}
