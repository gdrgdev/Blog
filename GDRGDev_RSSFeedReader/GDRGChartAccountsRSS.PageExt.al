pageextension 80100 "GDRG Chart Accounts RSS" extends "Chart of Accounts"
{
    layout
    {
        addfirst(factboxes)
        {
            part(RSSFiscalEntries; "GDRG RSS Feed Entries FactBox")
            {
                ApplicationArea = All;
                SubPageView = where(Category = const(Fiscal));
                Caption = 'Fiscal RSS Feed';
            }
        }
    }
}
