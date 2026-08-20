page 88888 "GDRG Env Copy Log List"
{
    ApplicationArea = All;
    Caption = 'Cleanup Log';
    DeleteAllowed = true;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTableView = sorting("Entry No.") order(descending);
    SourceTable = "GDRG Env Copy Log";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        EnvCopyLogLine: Record "GDRG Env Copy Log Line";
                    begin
                        EnvCopyLogLine.SetRange("Log Entry No.", Rec."Entry No.");
                        Page.Run(Page::"GDRG Env Copy Log Lines", EnvCopyLogLine);
                    end;
                }
                field("Started At"; StartedAtText)
                {
                    Caption = 'Started At';
                    ToolTip = 'Specifies when the cleanup started with millisecond precision.';
                }
                field("Ended At"; EndedAtText)
                {
                    Caption = 'Ended At';
                    ToolTip = 'Specifies when the cleanup ended with millisecond precision.';
                }
                field(Duration; DurationMs)
                {
                    Caption = 'Duration (ms)';
                    ToolTip = 'Specifies the total duration of the cleanup log entry in milliseconds.';
                }
                field("Trigger Type"; Rec."Trigger Type")
                {
                }
                field(Company; Rec.Company)
                {
                }
                field("First Event"; Rec."First Event")
                {
                }
                field("Environment Name"; Rec."Environment Name")
                {
                }
                field(Status; Rec.Status)
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenLines)
            {
                ApplicationArea = All;
                Caption = 'Details';
                Image = ViewDetails;
                ToolTip = 'Opens the detailed log lines for the selected entry.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    EnvCopyLogLine: Record "GDRG Env Copy Log Line";
                begin
                    EnvCopyLogLine.SetRange("Log Entry No.", Rec."Entry No.");
                    Page.Run(Page::"GDRG Env Copy Log Lines", EnvCopyLogLine);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DurationMs := GetDurationMs();
        StartedAtText := FormatDateTime(Rec."Started At");
        EndedAtText := FormatDateTime(Rec."Ended At");
    end;

    var
        DurationMs: Duration;
        StartedAtText: Text[50];
        EndedAtText: Text[50];

    local procedure GetDurationMs(): Duration
    begin
        if (Rec."Started At" = 0DT) or (Rec."Ended At" = 0DT) then
            exit(0);

        exit(Rec."Ended At" - Rec."Started At");
    end;

    local procedure FormatDateTime(Value: DateTime): Text[50]
    begin
        if Value = 0DT then
            exit('');

        exit(CopyStr(Format(Value, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2><Second dec>'), 1, 50));
    end;

}