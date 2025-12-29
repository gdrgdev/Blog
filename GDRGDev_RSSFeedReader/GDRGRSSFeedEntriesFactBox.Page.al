page 80103 "GDRG RSS Feed Entries FactBox"
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
                    Width = 20;

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec.Link);
                    end;
                }
                field(Description; Rec.Description)
                {
                    Width = 30;
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

    actions
    {
        area(Processing)
        {
            action(OpenFeedSources)
            {
                Caption = 'Open Feed Sources';
                ToolTip = 'Open the RSS Feed Sources page filtered by the current category.';
                Image = List;

                trigger OnAction()
                var
                    FeedSource: Record "GDRG RSS Feed Source";
                    CategoryFilter: Text;
                begin
                    Rec.FilterGroup(4);
                    CategoryFilter := Rec.GetFilter(Category);
                    Rec.FilterGroup(0);

                    if CategoryFilter <> '' then
                        FeedSource.SetFilter(Category, CategoryFilter);

                    Page.Run(Page::"GDRG RSS Feed Sources", FeedSource);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeedSource: Record "GDRG RSS Feed Source";
        RSSManager: Codeunit "GDRG RSS Feed Manager";
        CategoryFilter: Text;
        FeedCodeFilter: Text;
    begin
        Rec.FilterGroup(4);
        FeedCodeFilter := Rec.GetFilter("Feed Code");
        CategoryFilter := Rec.GetFilter(Category);
        Rec.FilterGroup(0);

        if FeedCodeFilter <> '' then begin
            FeedSource.SetRange("Code", Rec.GetRangeMin("Feed Code"));
            if FeedSource.FindFirst() then
                RSSManager.GetFeedEntries(FeedSource."Code");
        end else
            if CategoryFilter <> '' then begin
                FeedSource.SetFilter(Category, CategoryFilter);
                FeedSource.SetRange(Active, true);
                if FeedSource.FindSet() then
                    repeat
                        RSSManager.GetFeedEntries(FeedSource."Code");
                    until FeedSource.Next() = 0;
            end;

        CurrPage.Update(false);
    end;
}
