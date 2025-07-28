table 50100 "GDRG Performance Test Result"
{
    Caption = 'GDRG Performance Test Result';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Performance Test Results";
    DrillDownPageId = "GDRG Performance Test Results";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number for the test result.';
        }

        field(2; "Test Date"; DateTime)
        {
            Caption = 'Test Date';
            ToolTip = 'Specifies the date and time when the test was executed.';
        }

        field(3; "Method Type"; Enum "GDRG Performance Method Type")
        {
            Caption = 'Method Type';
            ToolTip = 'Specifies the performance test method used.';
        }

        field(4; "Records Processed"; Integer)
        {
            Caption = 'Records Processed';
            ToolTip = 'Specifies the number of records processed during the test.';
        }

        field(5; "Total Value Calculated"; Decimal)
        {
            Caption = 'Total Value Calculated';
            DecimalPlaces = 2 : 5;
            ToolTip = 'Specifies the total inventory value calculated.';
        }

        field(6; "Execution Time (ms)"; Duration)
        {
            Caption = 'Execution Time (ms)';
            ToolTip = 'Specifies the time taken to execute the test in milliseconds.';
        }

        field(7; "Processing Method"; Text[100])
        {
            Caption = 'Processing Method';
            ToolTip = 'Specifies the description of processing method used.';
        }

        field(8; "Performance Rating"; Text[50])
        {
            Caption = 'Performance Rating';
            ToolTip = 'Specifies the performance rating comparison.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(TestDate; "Test Date", "Method Type")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Method Type", "Records Processed", "Execution Time (ms)", "Performance Rating")
        {
        }

        fieldgroup(DropDown; "Entry No.", "Method Type", "Test Date")
        {
        }
    }
}
