page 50112 "GDRG System Page Browser"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Page Metadata";
    SourceTableView = where(PageType = filter(List | Worksheet | ListPlus));
    Caption = 'Browse BC Pages';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Pages)
            {
                field(Caption; Rec.Caption)
                {
                    Caption = 'Page Name';
                    ToolTip = 'Specifies the name of the page.';
                }
                field(Name; Rec.Name)
                {
                    Caption = 'Object Name (English)';
                    ToolTip = 'Specifies the object name in English.';
                }
                field(ID; Rec.ID)
                {
                    Caption = 'Page ID';
                    ToolTip = 'Specifies the page ID number.';
                }
                field(PageType; Rec.PageType)
                {
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of page.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenPage)
            {
                Caption = 'Open Page';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Page.Run(Rec.ID);
                end;
            }
        }
    }
}
