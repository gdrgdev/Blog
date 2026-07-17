namespace DefaultPublisher.ChangeLogView;

using Microsoft.Purchases.Vendor;

pageextension 88894 "CL Blame Vendor Card Ext" extends "Vendor Card"
{
    actions
    {
        addlast(navigation)
        {
            action(ViewChangeLogBlame)
            {
                ApplicationArea = All;
                Caption = 'Change Log (Blame View)';
                Image = History;
                ToolTip = 'Opens the change log blame view for this vendor, showing all field changes over time.';

                trigger OnAction()
                var
                    BlamePage: Page "CL Blame";
                begin
                    BlamePage.SetParameters(DATABASE::Vendor, Rec."No.", '', '');
                    BlamePage.RunModal();
                end;
            }
        }
    }
}
