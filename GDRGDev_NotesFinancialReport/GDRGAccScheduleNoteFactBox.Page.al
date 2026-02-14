page 50100 "GDRG Acc. Schedule Note"
{
    Caption = 'Line Note';
    PageType = CardPart;
    SourceTable = "Acc. Schedule Line";

    layout
    {
        area(Content)
        {
            field("GDRG Note Text"; Rec."GDRG Note Text")
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;
            }
        }
    }
}
