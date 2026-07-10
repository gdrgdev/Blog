pageextension 97826 "GDRGPE Item Card Ext" extends "Item Card"
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
                    PageExplorerPage.SetParameters(Page::"Item Card", Rec.SystemId);
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
