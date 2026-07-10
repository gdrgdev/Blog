pageextension 97825 "GDRGPE Vend Card Ext" extends "Vendor Card"
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
                    PageExplorerPage.SetParameters(Page::"Vendor Card", Rec.SystemId);
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
