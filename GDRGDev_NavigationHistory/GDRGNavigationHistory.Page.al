page 50106 "GDRG Navigation History"
{
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "GDRG Navigation History";
    Caption = 'Navigation History';
    ApplicationArea = All;
    Editable = false;
    SourceTableView = sorting("User ID", "Visited DateTime") order(descending);
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    StyleExpr = TypeStyleExpr;
                }
                field(Description; Rec.Description)
                {
                    StyleExpr = DescriptionStyleExpr;

                    trigger OnDrillDown()
                    begin
                        OpenEntry();
                    end;
                }
                field("Visited DateTime"; Rec."Visited DateTime")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Open)
            {
                ApplicationArea = All;
                Caption = 'Open';
                Image = View;

                trigger OnAction()
                begin
                    OpenEntry();
                end;
            }
            action(ClearHistory)
            {
                ApplicationArea = All;
                Caption = 'Clear All History';
                Image = Delete;

                trigger OnAction()
                var
                    RecentEntry: Record "GDRG Navigation History";
                begin
                    if Confirm('Do you want to clear all your recent records history?', false) then begin
                        RecentEntry.SetRange("User ID", UserId());
                        RecentEntry.DeleteAll(false);
                        Message('All history cleared successfully.');
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(CleanupOldEntries)
            {
                ApplicationArea = All;
                Caption = 'Delete Entries Older Than 30 Days';
                Image = ClearLog;

                trigger OnAction()
                var
                    RecentEntry: Record "GDRG Navigation History";
                    CutoffDate: Date;
                    DeletedCount: Integer;
                begin
                    if Confirm('Do you want to delete all entries older than 30 days?', false) then begin
                        CutoffDate := Today() - 30;
                        RecentEntry.SetRange("User ID", UserId());
                        RecentEntry.SetFilter("Visited DateTime", '<%1', CreateDateTime(CutoffDate, 0T));
                        DeletedCount := RecentEntry.Count();
                        RecentEntry.DeleteAll(false);
                        Message('%1 old entries deleted successfully.', DeletedCount);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Open_Promoted; Open)
                {
                }
                actionref(ClearHistory_Promoted; ClearHistory)
                {
                }
                actionref(CleanupOldEntries_Promoted; CleanupOldEntries)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("User ID", UserId());
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyles();
    end;

    local procedure OpenEntry()
    var
        PageManagement: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        if Rec."Entry Type" = Rec."Entry Type"::List then begin
            RecRef.Open(Rec."Table ID");
            PageManagement.PageRun(RecRef);
            RecRef.Close();
        end else begin
            if not RecRef.Get(Rec."Record ID") then begin
                if Confirm('This record no longer exists. Delete this history entry?', false) then begin
                    Rec.Delete(false);
                    CurrPage.Update(false);
                end;
                exit;
            end;
            PageManagement.PageRun(RecRef);
            RecRef.Close();
        end;
    end;

    local procedure SetStyles()
    begin
        case Rec."Entry Type" of
            Rec."Entry Type"::List:
                begin
                    TypeStyleExpr := Format(PageStyle::Favorable);
                    DescriptionStyleExpr := Format(PageStyle::Strong);
                end;
            Rec."Entry Type"::Card:
                begin
                    TypeStyleExpr := Format(PageStyle::Attention);
                    DescriptionStyleExpr := '';
                end;
        end;
    end;

    var
        TypeStyleExpr: Text;
        DescriptionStyleExpr: Text;
}
