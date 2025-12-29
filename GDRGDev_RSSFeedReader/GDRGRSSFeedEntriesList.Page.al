page 80104 "GDRG RSS Feed Entries List"
{
    Permissions = tabledata "GDRG RSS Feed Source" = R;

    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "GDRG RSS Feed Entry";
    Caption = 'RSS Feed Entries';
    Editable = false;
    SourceTableView = sorting("Published Date") order(descending);
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Title; Rec.Title)
                {
                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec.Link);
                    end;
                }
                field(Description; Rec.Description)
                {
                }
                field("Published Date"; Rec."Published Date")
                {
                }
                field("Feed Code"; Rec."Feed Code")
                {
                }
                field("Entry No."; Rec."Entry No.")
                {
                    Visible = false;
                }
                field(Link; Rec.Link)
                {
                    Visible = false;
                }
                field("Fetched DateTime"; Rec."Fetched DateTime")
                {
                    Visible = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeedSource: Record "GDRG RSS Feed Source";
        RSSManager: Codeunit "GDRG RSS Feed Manager";
    begin
        if Rec.GetFilter("Feed Code") <> '' then begin
            FeedSource.SetRange("Code", Rec.GetRangeMin("Feed Code"));
            if FeedSource.FindFirst() then
                RSSManager.GetFeedEntries(FeedSource."Code");
        end;
    end;
}
