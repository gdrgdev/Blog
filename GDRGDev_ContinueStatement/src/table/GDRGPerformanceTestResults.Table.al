table 50100 "GDRG Performance Test Results"
{
    Caption = 'GDRG Performance Test Results';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Performance Test";
    DrillDownPageId = "GDRG Performance Test";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            AllowInCustomizations = Never;
        }
        field(2; "Method Type"; Enum "GDRG Method Type")
        {
            Caption = 'Method Type';
            ToolTip = 'Specifies the method type used for testing.';
        }
        field(3; "Customers Processed"; Integer)
        {
            Caption = 'Customers Processed';
            ToolTip = 'Specifies the number of customers processed.';
        }
        field(4; "Execution Time (ms)"; Integer)
        {
            Caption = 'Execution Time (ms)';
            ToolTip = 'Specifies the execution time in milliseconds.';
        }
        field(5; "Execution DateTime"; DateTime)
        {
            Caption = 'Execution DateTime';
            ToolTip = 'Specifies when the test was executed.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Method Type", "Customers Processed", "Execution Time (ms)")
        {
        }
        fieldgroup(Brick; "Method Type", "Customers Processed", "Execution DateTime")
        {
        }
    }
}
