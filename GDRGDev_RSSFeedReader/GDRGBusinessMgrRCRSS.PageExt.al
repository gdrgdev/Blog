pageextension 80101 "GDRG Business Mgr RC RSS" extends "Business Manager Role Center"
{
    layout
    {
        addlast(rolecenter)
        {
            part(RSSLatestNews; "GDRG RSS Feed Entries Part")
            {
                ApplicationArea = All;
                SubPageView = where(Category = const(News));
                Caption = 'Latest BC News';
            }
        }
    }
}
