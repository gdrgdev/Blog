pageextension 50101 "GDRG Vendor Tags" extends "Vendor Card"
{
    layout
    {
        addlast(factboxes)
        {
            part("Personal Tags"; "GDRG Personal Tags FactBox")
            {
                ApplicationArea = All;
                Caption = 'My Tags';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage."Personal Tags".Page.SetContext(Rec.RecordId(), Database::Vendor);
    end;
}
