table 88888 "GDRG Env Copy Log"
{
    Caption = 'GDRG Env Copy Log';
    DataPerCompany = false;
    DrillDownPageId = "GDRG Env Copy Log List";
    LookupPageId = "GDRG Env Copy Log List";
    Permissions = tabledata "GDRG Env Copy Log Line" = rd;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies the log entry number.';
        }
        field(2; "Started At"; DateTime)
        {
            Caption = 'Started At';
            ToolTip = 'Specifies when the cleanup started.';
        }
        field(3; "Ended At"; DateTime)
        {
            Caption = 'Ended At';
            ToolTip = 'Specifies when the cleanup ended.';
        }
        field(4; "Trigger Type"; Text[30])
        {
            Caption = 'Trigger Type';
            ToolTip = 'Specifies how the cleanup was triggered.';
        }
        field(5; "First Event"; Text[50])
        {
            Caption = 'First Event';
            ToolTip = 'Specifies which event created the log entry first.';
        }
        field(6; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            ToolTip = 'Specifies the current environment name.';
        }
        field(7; Status; Text[30])
        {
            Caption = 'Status';
            ToolTip = 'Specifies the current cleanup status.';
            AllowInCustomizations = Never;
        }
        field(8; "User Security Id"; Guid)
        {
            Caption = 'User Security Id';
            ToolTip = 'Specifies the user security identifier that started the log entry.';
            AllowInCustomizations = Never;
        }
        field(9; Company; Text[30])
        {
            Caption = 'Company';
            ToolTip = 'Specifies the company related to the log entry when the cleanup is company-scoped.';
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
        fieldgroup(DropDown; "Entry No.", "Started At", Status)
        {
        }
        fieldgroup(Brick; "Entry No.", "Started At", Status)
        {
        }
    }

    trigger OnDelete()
    var
        EnvCopyLogLine: Record "GDRG Env Copy Log Line";
    begin
        EnvCopyLogLine.SetRange("Log Entry No.", "Entry No.");
        if not EnvCopyLogLine.IsEmpty() then
            EnvCopyLogLine.DeleteAll(true);
    end;
}