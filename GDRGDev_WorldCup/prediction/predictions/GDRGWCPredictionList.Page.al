page 88899 "GDRG WC Prediction List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG WC Prediction";
    SourceTableView = sorting(Username, "Match Date", "Match Time");
    Caption = 'World Cup Predictions';
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Username; Rec.Username)
                {
                    Editable = false;
                }
                field("Match DateTime"; Rec."Match DateTime")
                {
                    Editable = false;
                }
                field("Team 1"; Rec."Team 1")
                {
                    Editable = false;
                }
                field("Team 2"; Rec."Team 2")
                {
                    Editable = false;
                }
                field("Team 1 Score"; Rec."Team 1 Score")
                {
                    Editable = false;
                }
                field("Team 2 Score"; Rec."Team 2 Score")
                {
                    Editable = false;
                }
                field("Result Type"; Rec."Result Type")
                {
                    Editable = false;
                }
                field("Match Last Updated At"; Rec."Match Last Updated At")
                {
                    Editable = false;
                }
                field("Predicted Team 1 Score"; Rec."Predicted Team 1 Score")
                {
                    trigger OnValidate()
                    begin
                        Rec."Has Prediction" := true;
                        Rec."Last Updated At" := CurrentDateTime();
                    end;
                }
                field("Predicted Team 2 Score"; Rec."Predicted Team 2 Score")
                {
                    trigger OnValidate()
                    begin
                        Rec."Has Prediction" := true;
                        Rec."Last Updated At" := CurrentDateTime();
                    end;
                }
                field(Points; Rec.Points)
                {
                    Editable = false;
                }
                field("Last Updated At"; Rec."Last Updated At")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowUpcomingPredictions)
            {
                Caption = 'Upcoming Matches';
                Image = Filter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Shows upcoming matches only.';

                trigger OnAction()
                begin
                    ApplyUpcomingMatchesFilter();
                    CurrPage.Update(false);
                end;
            }
            action(ShowAllPredictions)
            {
                Caption = 'Show All Matches';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Clears the date filter and shows all matches.';

                trigger OnAction()
                begin
                    Rec.SetRange("Match Date");
                    CurrPage.Update(false);
                end;
            }
            action(RefreshPredictions)
            {
                Caption = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copies the latest match data into your prediction list.';

                trigger OnAction()
                var
                    PredictionMgt: Codeunit "GDRG WC Prediction Mgt";
                    CurrentUserName: Text[100];
                begin
                    CurrentUserName := CopyStr(UserId(), 1, MaxStrLen(CurrentUserName));
                    PredictionMgt.RefreshPredictionsForUser(CurrentUserName);
                    ApplyCurrentUserFilter();
                    ApplyUpcomingMatchesFilter();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ApplyCurrentUserFilter();
        ApplyUpcomingMatchesFilter();
    end;

    local procedure ApplyCurrentUserFilter()
    var
        CurrentUserName: Text[100];
    begin
        CurrentUserName := CopyStr(UserId(), 1, MaxStrLen(CurrentUserName));
        Rec.SetRange(Username, CurrentUserName);
    end;

    local procedure ApplyUpcomingMatchesFilter()
    begin
        Rec.SetFilter("Match Date", '>=%1', Today());
    end;
}
