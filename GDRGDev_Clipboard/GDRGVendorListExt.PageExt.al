pageextension 88001 "GDRG Vendor List Ext" extends "Vendor List"
{
    actions
    {
        addlast(processing)
        {
            action(GDRGCopyVendorContactInfo)
            {
                ApplicationArea = All;
                Caption = 'Copy Vendor Info';
                ToolTip = 'Copy vendor contact and payment information to clipboard for easy pasting into emails or messages.';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    clipboardMgt: Codeunit "GDRG Clipboard Mgt. Vend.";
                    noVendorSelectedErr: Label 'Please select a vendor first.';
                begin
                    if Rec."No." = '' then
                        Error(noVendorSelectedErr);

                    clipboardMgt.CopyVendorInfo(Rec);
                end;
            }
        }
    }
}
