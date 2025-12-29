pageextension 80102 "GDRG Item List RSS" extends "Item List"
{
    layout
    {
        addfirst(factboxes)
        {
            part(RSSPharmaAlerts; "GDRG RSS Feed Entries FactBox")
            {
                ApplicationArea = All;
                SubPageView = where(Category = const(Pharma));
                Caption = 'Pharma Alerts';
            }
        }
    }
}
