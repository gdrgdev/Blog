pageextension 88000 "GDRG Customer List Ext" extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            action(GDRGCopyCustomerContactInfo)
            {
                ApplicationArea = All;
                Caption = 'Copy Contact Info';
                ToolTip = 'Copy customer contact information to clipboard for easy pasting into emails or messages.';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    clipboardMgt: Codeunit "GDRG Clipboard Mgt. Cust.";
                    noCustomerSelectedErr: Label 'Please select a customer first.';
                begin
                    if Rec."No." = '' then
                        Error(noCustomerSelectedErr);

                    clipboardMgt.CopyCustomerInfo(Rec);
                end;
            }
        }
    }
}
