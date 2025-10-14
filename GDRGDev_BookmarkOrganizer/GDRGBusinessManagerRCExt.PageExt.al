pageextension 50100 "GDRG Business Manager RC Ext" extends "Business Manager Role Center"
{
    layout
    {
        // Add bookmark navigator as a sidebar part
        addfirst(rolecenter)
        {
            part(BookmarkNavigator; "GDRG Bookmark Tree Part")
            {
                ApplicationArea = All;
                Caption = 'Quick Bookmarks';
            }
        }
    }
}
