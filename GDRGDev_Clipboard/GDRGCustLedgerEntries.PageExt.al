pageextension 88002 "GDRG Cust. Ledger Entries" extends "Customer Ledger Entries"
{
    actions
    {
        addlast(processing)
        {
            action(GDRGCopyCustLedgerEntryInfo)
            {
                ApplicationArea = All;
                Caption = 'Copy Entry Info';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Copy customer ledger entry information to clipboard.';

                trigger OnAction()
                var
                    clipboardMgt: Codeunit "GDRG Clipboard Mgt. CustLedg";
                    noEntrySelectedErr: Label 'Please select a customer ledger entry.';
                begin
                    if Rec."Entry No." = 0 then
                        Error(noEntrySelectedErr);

                    clipboardMgt.CopyCustLedgerEntryInfo(Rec);
                end;
            }
        }
    }
}
