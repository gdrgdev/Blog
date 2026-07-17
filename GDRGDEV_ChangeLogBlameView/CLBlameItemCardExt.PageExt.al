namespace DefaultPublisher.ChangeLogView;

using Microsoft.Inventory.Item;

pageextension 88895 "CL Blame Item Card Ext" extends "Item Card"
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
                ToolTip = 'Opens the change log blame view for this item, showing all field changes over time.';

                trigger OnAction()
                var
                    BlamePage: Page "CL Blame";
                begin
                    BlamePage.SetParameters(DATABASE::Item, Rec."No.", '', '');
                    BlamePage.RunModal();
                end;
            }
        }
    }
}
