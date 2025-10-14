page 50104 "GDRG Bookmark Tree View"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Page Bookmark";
    SourceTableTemporary = true;
    Caption = 'Bookmark Tree';
    Editable = false;

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
                    Style = Strong;
                    StyleExpr = IsFolder;

                    trigger OnDrillDown()
                    begin
                        if IsFolder then
                            ToggleFolder()
                        else
                            OpenPage();
                    end;
                }

                field("Folder Code"; Rec."Folder Code")
                {
                    Caption = 'Folder';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenSelectedPage)
            {
                Caption = 'Open Page';
                ToolTip = 'Open the selected page.';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Enabled = not IsFolder;

                trigger OnAction()
                begin
                    OpenPage();
                end;
            }

            action(ExpandAll)
            {
                Caption = 'Expand All';
                ToolTip = 'Expand all folders.';
                Image = ExpandAll;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

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
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

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
    end;

    var
        TreeBuilder: Codeunit "GDRG Bookmark Tree Builder";
        ExpandedFolders: List of [Code[20]];
        DisplayName: Text[250];
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
