pageextension 97828 "GDRGPE Sales Order Sub Ext" extends "Sales Order Subform"
{
    actions
    {
        addlast(processing)
        {
            action(GDRGPEPageExplorer)
            {
                ApplicationArea = All;
                Caption = 'Page Explorer';
                Image = Info;
                ToolTip = 'Shows all fields and available actions on the Sales Line with their descriptions.';

                trigger OnAction()
                var
                    PageExplorerPage: Page "GDRGPE Main";
                begin
                    PageExplorerPage.SetParameters(Page::"Sales Order Subform", Rec.SystemId);
                    PageExplorerPage.RunModal();
                end;
            }
        }
    }
}
