page 50111 "GDRG Page Bookmark List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "GDRG Page Bookmark";
    Caption = 'Bookmark Pages';
    Editable = true;
    DelayedInsert = true;
    UsageCategory = None;
    Permissions = tabledata "GDRG Folder Bookmark" = RIMD,
            tabledata "GDRG Page Bookmark" = RIMD;
    layout
    {
        area(Content)
        {
            repeater(Bookmarks)
            {
                field("Folder Code"; Rec."Folder Code")
                {
                    Visible = false;
                }
                field("Page Name"; Rec."Page Name")
                {
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PageMetadata: Record "Page Metadata";
                    begin
                        PageMetadata.SetFilter(PageType, '%1|%2|%3',
                            PageMetadata.PageType::List,
                            PageMetadata.PageType::Worksheet,
                            PageMetadata.PageType::ListPlus);
                        if Page.RunModal(Page::"GDRG System Page Browser", PageMetadata) = Action::LookupOK then begin
                            Rec.Validate("Page ID", PageMetadata.ID);
                            Rec.Validate("Page Name", CopyStr(PageMetadata.Caption, 1, 100));
                        end;
                    end;

                    trigger OnDrillDown()
                    begin
                        if Rec."Page ID" > 0 then
                            Page.Run(Rec."Page ID");
                    end;
                }
                field("Page ID"; Rec."Page ID")
                {
                    Editable = false;
                }
                field("Custom Label"; Rec."Custom Label")
                {
                }
                field("Sort Order"; Rec."Sort Order")
                {
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
                    OpenSelectedPage();
                end;
            }

            action(DeleteAll)
            {
                Caption = 'Delete All Bookmarks';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PageBookmark: Record "GDRG Page Bookmark";
                    FolderFilter: Text;
                    ConfirmMsg: Text;
                begin
                    PageBookmark.SetRange("User ID", UserId());

                    FolderFilter := Rec.GetFilter("Folder Code");
                    if FolderFilter <> '' then begin
                        PageBookmark.SetRange("Folder Code", Rec.GetRangeMin("Folder Code"));
                        ConfirmMsg := StrSubstNo('Delete all bookmarks in folder "%1"?', Rec.GetRangeMin("Folder Code"));
                    end else begin
                        ConfirmMsg := 'Delete ALL your bookmarks in ALL folders?';
                    end;

                    if not Confirm(ConfirmMsg, false) then
                        exit;

                    PageBookmark.DeleteAll(false);

                    Message('Bookmarks deleted');
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("User ID", UserId());
        Rec.FilterGroup(0);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec.GetFilter("Folder Code") <> '' then
            Rec."Folder Code" := Rec.GetRangeMin("Folder Code");
    end;

    local procedure OpenSelectedPage()
    var
        ErrorInfo: ErrorInfo;
    begin
        if Rec."Page ID" = 0 then begin
            ErrorInfo.Message := 'No page selected';
            Error(ErrorInfo);
        end;

        Page.Run(Rec."Page ID");
    end;
}
