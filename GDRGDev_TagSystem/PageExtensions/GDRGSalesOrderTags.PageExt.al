pageextension 50102 "GDRG Sales Order Tags" extends "Sales Order"
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
        CurrPage."Personal Tags".Page.SetContext(Rec.RecordId(), Database::"Sales Header");
    end;
}
