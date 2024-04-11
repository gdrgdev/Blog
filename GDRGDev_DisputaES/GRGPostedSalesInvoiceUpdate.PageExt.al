pageextension 80000 GRGPostedSalesInvoiceUpdate extends "Posted Sales Invoice - Update"
{
    layout
    {
        addafter("SII Last Summary Doc. No.")
        {
            field("Dispute Status"; Rec."Dispute Status")
            {
                ApplicationArea = All;
                Editable = true;
            }
        }
    }
}
