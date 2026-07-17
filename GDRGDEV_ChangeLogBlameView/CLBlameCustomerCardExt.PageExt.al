namespace DefaultPublisher.ChangeLogView;

using Microsoft.Sales.Customer;

pageextension 88893 "CL Blame Customer Card Ext" extends "Customer Card"
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
                ToolTip = 'Opens the change log blame view for this customer, showing all field changes over time.';

                trigger OnAction()
                var
                    BlamePage: Page "CL Blame";
                begin
                    BlamePage.SetParameters(DATABASE::Customer, Rec."No.", '', '');
                    BlamePage.RunModal();
                end;
            }
        }
    }
}
