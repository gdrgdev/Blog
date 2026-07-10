pageextension 97827 "GDRGPE Sales Order Ext" extends "Sales Order"
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
                ToolTip = 'Shows all fields and available actions on this page with their descriptions.';

                trigger OnAction()
                var
                    PageExplorerPage: Page "GDRGPE Main";
                begin
                    PageExplorerPage.SetParameters(Page::"Sales Order", Rec.SystemId);
                    PageExplorerPage.RunModal();
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(GDRGPEPageExplorer_Promoted; GDRGPEPageExplorer) { }
        }
    }
}
