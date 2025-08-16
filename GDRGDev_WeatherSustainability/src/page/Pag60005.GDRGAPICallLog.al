page 60005 "GDRG API Call Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GDRG API Call Log";
    Caption = 'API Call Log';
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(CallLogList)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }

                field("API Type"; Rec."API Type")
                {
                }

                field("HTTP Method"; Rec."HTTP Method")
                {
                }

                field("Response Status"; Rec."Response Status")
                {
                    StyleExpr = StatusStyleText;
                }

                field("Records Processed"; Rec."Records Processed")
                {
                }

                field("Execution Time (ms)"; Rec."Execution Time (ms)")
                {
                }

                field("Is Manual Call"; Rec."Is Manual Call")
                {
                }

                field("API URL"; Rec."API URL")
                {
                }

                field("Error Message"; Rec."Error Message")
                {
                    Visible = HasErrors;
                }

                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created At';
                    ToolTip = 'Specifies when the API call log entry was created.';
                }

                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'Created By';
                    ToolTip = 'Specifies the user who created the API call log entry.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Maintenance)
            {
                Caption = 'Maintenance';

                action(CleanupOldLogs)
                {
                    Caption = 'Cleanup Old Logs';
                    ToolTip = 'Delete log entries older than specified number of days.';
                    Image = Delete;

                    trigger OnAction()
                    var
                        APICallLog: Record "GDRG API Call Log";
                        DaysToKeep: Integer;
                        CleanupConfirmLbl: Label 'Do you want to delete log entries older than %1 days?', Comment = '%1 = Number of days';
                        CleanupCompletedLbl: Label 'Cleanup completed successfully.', Comment = 'Message when cleanup is completed';
                    begin
                        DaysToKeep := 30;

                        if Confirm(CleanupConfirmLbl, false, DaysToKeep) then begin
                            APICallLog.CleanupOldLogs(DaysToKeep);
                            Message(CleanupCompletedLbl);
                            CurrPage.Update(false);
                        end;
                    end;
                }

                action(RefreshPage)
                {
                    Caption = 'Refresh';
                    ToolTip = 'Refresh the page to show latest log entries.';
                    Image = Refresh;

                    trigger OnAction()
                    begin
                        CurrPage.Update(false);
                    end;
                }

                action(ShowAllEntries)
                {
                    Caption = 'Show All Entries';
                    ToolTip = 'Remove filters to show all log entries.';
                    Image = ShowList;

                    trigger OnAction()
                    begin
                        Rec.Reset();
                        Rec.SetCurrentKey("Entry No.");
                        Rec.SetAscending("Entry No.", false);
                        CurrPage.Update(false);
                    end;
                }

                action(ShowLatest100)
                {
                    Caption = 'Show Latest 100';
                    ToolTip = 'Show only the latest 100 log entries for better performance.';
                    Image = FilterLines;

                    trigger OnAction()
                    var
                        APICallLogRec: Record "GDRG API Call Log";
                        LastEntryNo: Integer;
                        FirstEntryNo: Integer;
                    begin
                        APICallLogRec.SetCurrentKey("Entry No.");
                        if APICallLogRec.FindLast() then begin
                            LastEntryNo := APICallLogRec."Entry No.";
                            FirstEntryNo := LastEntryNo - 99;
                            if FirstEntryNo < 1 then
                                FirstEntryNo := 1;
                            Rec.SetRange("Entry No.", FirstEntryNo, LastEntryNo);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }

        area(Promoted)
        {
            group(Category_Maintenance)
            {
                Caption = 'Maintenance';

                actionref(CleanupOldLogs_Promoted; CleanupOldLogs)
                {
                }
                actionref(RefreshPage_Promoted; RefreshPage)
                {
                }
                actionref(ShowAllEntries_Promoted; ShowAllEntries)
                {
                }
                actionref(ShowLatest100_Promoted; ShowLatest100)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
        CheckForErrors();
    end;

    trigger OnOpenPage()
    var
        APICallLogRec: Record "GDRG API Call Log";
        LastEntryNo: Integer;
        FirstEntryNo: Integer;
    begin
        APICallLogRec.SetCurrentKey("Entry No.");
        if APICallLogRec.FindLast() then begin
            LastEntryNo := APICallLogRec."Entry No.";
            FirstEntryNo := LastEntryNo - 99;
            if FirstEntryNo < 1 then
                FirstEntryNo := 1;
            Rec.SetRange("Entry No.", FirstEntryNo, LastEntryNo);
        end;
    end;

    var
        StatusStyle: PageStyle;
        StatusStyleText: Text;
        HasErrors: Boolean;

    local procedure SetStatusStyle()
    begin
        case Rec."Response Status" of
            200 .. 299:
                begin
                    StatusStyle := PageStyle::Favorable;
                    StatusStyleText := Format(StatusStyle);
                end;
            400 .. 499:
                begin
                    StatusStyle := PageStyle::Unfavorable;
                    StatusStyleText := Format(StatusStyle);
                end;
            500 .. 599:
                begin
                    StatusStyle := PageStyle::Unfavorable;
                    StatusStyleText := Format(StatusStyle);
                end;
            else begin
                StatusStyle := PageStyle::Standard;
                StatusStyleText := Format(StatusStyle);
            end;
        end;
    end;

    local procedure CheckForErrors()
    begin
        HasErrors := Rec."Error Message" <> '';
    end;
}
