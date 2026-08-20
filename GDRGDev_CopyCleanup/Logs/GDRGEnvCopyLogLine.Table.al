table 88889 "GDRG Env Copy Log Line"
{
    Caption = 'GDRG Env Copy Log Line';
    DataPerCompany = false;
    DrillDownPageId = "GDRG Env Copy Log Lines";
    LookupPageId = "GDRG Env Copy Log Lines";

    fields
    {
        field(1; "Log Entry No."; Integer)
        {
            Caption = 'Log Entry No.';
            TableRelation = "GDRG Env Copy Log";
            ToolTip = 'Specifies the parent log entry number.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the log line number.';
        }
        field(3; "Created At"; DateTime)
        {
            Caption = 'Created At';
            ToolTip = 'Specifies when the log line was created.';
        }
        field(4; "Started At"; DateTime)
        {
            Caption = 'Started At';
            ToolTip = 'Specifies when the logged step started.';
        }
        field(5; "Ended At"; DateTime)
        {
            Caption = 'Ended At';
            ToolTip = 'Specifies when the logged step ended.';
        }
        field(6; "Duration (ms)"; Integer)
        {
            Caption = 'Duration (ms)';
            ToolTip = 'Specifies the duration of the logged step in milliseconds.';
        }
        field(7; Company; Text[30])
        {
            Caption = 'Company';
            ToolTip = 'Specifies the company related to the log line.';
        }
        field(8; Step; Text[100])
        {
            Caption = 'Step';
            ToolTip = 'Specifies the executed step.';
        }
        field(9; Status; Text[30])
        {
            Caption = 'Status';
            ToolTip = 'Specifies the step status.';
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            ToolTip = 'Specifies the related table number.';
        }
        field(11; Message; Text[250])
        {
            Caption = 'Message';
            ToolTip = 'Specifies additional details for the log line.';
        }
        field(12; "Records Affected"; Integer)
        {
            Caption = 'Records Affected';
            ToolTip = 'Specifies how many records were affected.';
        }
        field(13; "Fields Affected"; Integer)
        {
            Caption = 'Fields Affected';
            ToolTip = 'Specifies how many fields were affected.';
        }
    }

    keys
    {
        key(PK; "Log Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Log Entry No.", "Line No.", Step)
        {
        }
        fieldgroup(Brick; "Log Entry No.", "Line No.", Step)
        {
        }
    }
}