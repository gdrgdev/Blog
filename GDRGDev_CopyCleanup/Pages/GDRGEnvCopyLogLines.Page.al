page 88890 "GDRG Env Copy Log Lines"
{
    ApplicationArea = All;
    Caption = 'Cleanup Log Details';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTableView = sorting("Log Entry No.", "Line No.") order(descending);
    SourceTable = "GDRG Env Copy Log Line";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Log Entry No."; Rec."Log Entry No.")
                {
                }
                field("Line No."; Rec."Line No.")
                {
                }
                field("Started At"; StartedAtText)
                {
                    Caption = 'Started At';
                    ToolTip = 'Specifies when the logged step started with millisecond precision.';
                }
                field("Ended At"; EndedAtText)
                {
                    Caption = 'Ended At';
                    ToolTip = 'Specifies when the logged step ended with millisecond precision.';
                }
                field("Duration (ms)"; Rec."Duration (ms)")
                {
                }
                field(Company; Rec.Company)
                {
                }
                field(Step; Rec.Step)
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Table No."; Rec."Table No.")
                {
                }
                field(Message; Rec.Message)
                {
                }
                field("Records Affected"; Rec."Records Affected")
                {
                }
                field("Fields Affected"; Rec."Fields Affected")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StartedAtText := FormatDateTime(Rec."Started At");
        EndedAtText := FormatDateTime(Rec."Ended At");
    end;

    var
        StartedAtText: Text[50];
        EndedAtText: Text[50];

    local procedure FormatDateTime(Value: DateTime): Text[50]
    begin
        if Value = 0DT then
            exit('');

        exit(CopyStr(Format(Value, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2><Second dec>'), 1, 50));
    end;
}