pageextension 50100 "GDRG Customer Tags" extends "Customer Card"
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
        CurrPage."Personal Tags".Page.SetContext(Rec.RecordId(), Database::Customer);
    end;
}
