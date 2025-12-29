page 80102 "GDRG RSS Feed Source Card"
{
    Permissions = tabledata "GDRG RSS Feed Source" = RIMD,
                  tabledata "GDRG RSS Feed Entry" = RIMD;

    PageType = Card;
    ApplicationArea = All;
    SourceTable = "GDRG RSS Feed Source";
    Caption = 'RSS Feed Source Card';
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                field(Active; Rec.Active)
                {
                }
            }
            group(RefreshSettings)
            {
                Caption = 'Refresh Settings';

                field("Use Custom Interval"; Rec."Use Custom Interval")
                {
                }
                field("Refresh Interval Minutes"; Rec."Refresh Interval Minutes")
                {
                    Editable = Rec."Use Custom Interval";
                }
                field("Last Refresh DateTime"; Rec."Last Refresh DateTime")
                {
                    Editable = false;
                }
                field("Entry Count"; Rec."Entry Count")
                {
                    Visible = false;
                }
                field("Earliest Entry Date"; Rec."Earliest Entry Date")
                {
                    Visible = false;
                }
                field("Latest Entry Date"; Rec."Latest Entry Date")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshFeed)
            {
                Caption = 'Refresh Feed';
                ToolTip = 'Manually refresh this RSS feed.';
                Image = Refresh;

                trigger OnAction()
                var
                    RSSManager: Codeunit "GDRG RSS Feed Manager";
                begin
                    RSSManager.FetchAndParseFeed(Rec."Code");
                    Message('Feed refreshed successfully.');
                end;
            }
            action(DeleteFeedEntries)
            {
                Caption = 'Delete Feed Entries';
                ToolTip = 'Delete all cached entries for this RSS feed source.';
                Image = Delete;

                trigger OnAction()
                var
                    RSSEntry: Record "GDRG RSS Feed Entry";
                begin
                    if not Confirm('Delete all entries for feed %1?', false, Rec."Code") then
                        exit;

                    RSSEntry.SetRange("Feed Code", Rec."Code");
                    RSSEntry.DeleteAll(true);

                    Rec."Last Refresh DateTime" := 0DT;
                    Rec.Modify(true);

                    Message('Feed entries deleted.');
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(RefreshFeed_Promoted; RefreshFeed)
                {
                }
                actionref(DeleteFeedEntries_Promoted; DeleteFeedEntries)
                {
                }
            }
        }
    }
}
