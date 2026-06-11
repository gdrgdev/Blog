page 88892 "GDRG WC Match List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG WC Match";
    SourceTableView = sorting("Match Date", "Match Time");
    Caption = 'World Cup Matches';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Match Date"; Rec."Match Date")
                {
                }
                field("Match Time"; Rec."Match Time")
                {
                }
                field("Match DateTime UTC"; Rec."Match DateTime")
                {
                }
                field("Last Updated At"; Rec."Last Updated At")
                {
                }
                field(Round; Rec.Round)
                {
                }
                field(Group; Rec.Group)
                {
                }
                field("Team 1"; Rec."Team 1")
                {
                }
                field("Team 1 Score"; Rec."Team 1 Score")
                {
                }
                field("Result Type"; Rec."Result Type")
                {
                }
                field("Team 2 Score"; Rec."Team 2 Score")
                {
                }
                field("Team 2"; Rec."Team 2")
                {
                }
                field(Ground; Rec.Ground)
                {
                }
                field("Has Result"; Rec."Has Result")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowUpcomingMatches)
            {
                Caption = 'Upcoming Matches';
                Image = Filter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Shows matches from today onward.';

                trigger OnAction()
                begin
                    ApplyUpcomingMatchesFilter();
                    CurrPage.Update(false);
                end;
            }
            action(ShowAllMatches)
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
            action(RefreshMatches)
            {
                Caption = 'Refresh Matches';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Downloads the latest World Cup matches and results.';

                trigger OnAction()
                var
                    WCImport: Codeunit "GDRG WC Import";
                begin
                    WCImport.RefreshMatches();
                    CurrPage.Update(false);
                end;
            }
            action(OpenSetup)
            {
                Caption = 'Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Opens the World Cup setup.';

                trigger OnAction()
                begin
                    Page.Run(Page::"GDRG WC Setup");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ApplyUpcomingMatchesFilter();
    end;

    local procedure ApplyUpcomingMatchesFilter()
    begin
        Rec.SetFilter("Match Date", '>=%1', Today());
    end;

}