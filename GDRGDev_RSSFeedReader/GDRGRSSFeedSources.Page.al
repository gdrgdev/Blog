page 80101 "GDRG RSS Feed Sources"
{
    Permissions = tabledata "GDRG RSS Feed Source" = RIMD,
                  tabledata "GDRG RSS Feed Entry" = RIMD;

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG RSS Feed Source";
    Caption = 'RSS Feed Sources';
    CardPageId = "GDRG RSS Feed Source Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Feed URL"; Rec."Feed URL")
                {
                }
                field(Category; Rec.Category)
                {
                }
                field("Entry Count"; Rec."Entry Count")
                {
                }
                field("Earliest Entry Date"; Rec."Earliest Entry Date")
                {
                }
                field("Latest Entry Date"; Rec."Latest Entry Date")
                {
                }
                field(Active; Rec.Active)
                {
                }
                field("Last Refresh DateTime"; Rec."Last Refresh DateTime")
                {
                }
                field("Use Custom Interval"; Rec."Use Custom Interval")
                {
                }
                field("Refresh Interval Minutes"; Rec."Refresh Interval Minutes")
                {
                }
            }
            part(RSSFeedEntriesList; "GDRG RSS Feed Entries List")
            {
                SubPageLink = "Feed Code" = field("Code");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshRSS)
            {
                Caption = 'Refresh RSS';
                ToolTip = 'Force refresh all filtered RSS feed sources.';
                Image = Refresh;

                trigger OnAction()
                var
                    FeedSource: Record "GDRG RSS Feed Source";
                    RSSManager: Codeunit "GDRG RSS Feed Manager";
                    RefreshCount: Integer;
                begin
                    CurrPage.SetSelectionFilter(FeedSource);

                    if FeedSource.IsEmpty() then begin
                        Message('No feed sources selected.');
                        exit;
                    end;

                    if not Confirm('Refresh %1 selected feed source(s)?', false, FeedSource.Count()) then
                        exit;

                    if FeedSource.FindSet() then
                        repeat
                            RSSManager.FetchAndParseFeed(FeedSource."Code");
                            RefreshCount += 1;
                        until FeedSource.Next() = 0;

                    CurrPage.Update(false);
                    Message('%1 feed sources refreshed.', RefreshCount);
                end;
            }
            action(DeleteFeedEntries)
            {
                Caption = 'Delete Feed Entries';
                ToolTip = 'Delete all cached entries for filtered RSS feed sources.';
                Image = Delete;

                trigger OnAction()
                var
                    FeedSource: Record "GDRG RSS Feed Source";
                    RSSEntry: Record "GDRG RSS Feed Entry";
                    DeleteCount: Integer;
                begin
                    CurrPage.SetSelectionFilter(FeedSource);

                    if FeedSource.IsEmpty() then begin
                        Message('No feed sources selected.');
                        exit;
                    end;

                    if not Confirm('Delete all entries for %1 selected feed source(s)?', false, FeedSource.Count()) then
                        exit;

                    if FeedSource.FindSet() then
                        repeat
                            RSSEntry.SetRange("Feed Code", FeedSource."Code");
                            DeleteCount += RSSEntry.Count();
                            RSSEntry.DeleteAll(true);

                            FeedSource."Last Refresh DateTime" := 0DT;
                            FeedSource.Modify(true);
                        until FeedSource.Next() = 0;

                    CurrPage.Update(false);
                    Message('%1 feed entries deleted.', DeleteCount);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(RefreshRSS_Promoted; RefreshRSS)
                {
                }
                actionref(DeleteFeedEntries_Promoted; DeleteFeedEntries)
                {
                }
            }
        }
    }
}
