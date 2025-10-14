page 50113 "GDRG Bookmark Tree Part"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "GDRG Page Bookmark";
    SourceTableTemporary = true;
    Caption = 'Quick Bookmarks';
    Editable = false;
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            repeater(BookmarksTree)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = DisplayName;

                field(DisplayName; DisplayName)
                {
                    Caption = 'Bookmark';
                    StyleExpr = DisplayStyle;

                    trigger OnDrillDown()
                    begin
                        if IsFolder then
                            ToggleFolder()
                        else
                            OpenPage();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ExpandAll)
            {
                Caption = 'Expand All';
                ToolTip = 'Expand all folders.';
                Image = ExpandAll;

                trigger OnAction()
                begin
                    TreeBuilder.ExpandAllFolders(Rec, ExpandedFolders);
                    CurrPage.Update(false);
                end;
            }
            action(CollapseAll)
            {
                Caption = 'Collapse All';
                ToolTip = 'Collapse all folders.';
                Image = CollapseAll;

                trigger OnAction()
                begin
                    TreeBuilder.CollapseAllFolders(Rec, ExpandedFolders);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        TreeBuilder.BuildTree(Rec, ExpandedFolders);
    end;

    trigger OnAfterGetRecord()
    begin
        DisplayName := TreeBuilder.CalculateDisplayName(Rec, ExpandedFolders);
        IsFolder := TreeBuilder.IsFolder(Rec);
        if IsFolder then
            DisplayStyle := Format(PageStyle::Strong)
        else
            DisplayStyle := Format(PageStyle::Standard);
    end;

    var
        TreeBuilder: Codeunit "GDRG Bookmark Tree Builder";
        ExpandedFolders: List of [Code[20]];
        DisplayName: Text[250];
        DisplayStyle: Text;
        IsFolder: Boolean;

    local procedure ToggleFolder()
    begin
        TreeBuilder.ToggleFolder(Rec, Rec."Folder Code", ExpandedFolders);
        CurrPage.Update(false);
    end;

    local procedure OpenPage()
    begin
        TreeBuilder.OpenPage(Rec."Page ID");
    end;
}
