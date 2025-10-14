page 50110 "GDRG Folder Bookmark List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Folder Bookmark";
    Caption = 'Bookmark Folders';
    Editable = true;
    Permissions = tabledata "GDRG Folder Bookmark" = RIMD,
            tabledata "GDRG Page Bookmark" = RIMD;
    layout
    {
        area(Content)
        {
            repeater(Folders)
            {
                field("Folder Code"; Rec."Folder Code")
                {
                }
                field("Folder Name"; Rec."Folder Name")
                {
                    Style = Strong;
                    StyleExpr = true;

                    trigger OnDrillDown()
                    var
                        PageBookmark: Record "GDRG Page Bookmark";
                    begin
                        PageBookmark.SetRange("User ID", UserId());
                        PageBookmark.SetRange("Folder Code", Rec."Folder Code");
                        Page.Run(Page::"GDRG Page Bookmark List", PageBookmark);
                    end;
                }
                field("Bookmark Count"; Rec."Bookmark Count")
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
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
            action(ViewBookmarks)
            {
                Caption = 'View Bookmarks';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PageBookmark: Record "GDRG Page Bookmark";
                begin
                    PageBookmark.SetRange("User ID", UserId());
                    PageBookmark.SetRange("Folder Code", Rec."Folder Code");
                    Page.Run(Page::"GDRG Page Bookmark List", PageBookmark);
                end;
            }

            action(DeleteAll)
            {
                Caption = 'Delete All';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    FolderBookmark: Record "GDRG Folder Bookmark";
                    PageBookmark: Record "GDRG Page Bookmark";
                begin
                    if not Confirm('This will delete ALL your folders and bookmarks. Are you sure?', false) then
                        exit;

                    PageBookmark.SetRange("User ID", UserId());
                    PageBookmark.DeleteAll(false);

                    FolderBookmark.SetRange("User ID", UserId());
                    FolderBookmark.DeleteAll(false);

                    Message('All folders and bookmarks have been deleted');
                    CurrPage.Update(false);
                end;
            }

            action(ImportTemplate)
            {
                Caption = 'Import Template';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    BookmarkManager: Codeunit "GDRG Bookmark Manager";
                    InStr: InStream;
                    JsonText: Text;
                    FileName: Text;
                begin
                    if UploadIntoStream('Select JSON file', '', 'JSON Files (*.json)|*.json', FileName, InStr) then begin
                        InStr.ReadText(JsonText);
                        BookmarkManager.ImportFromJson(JsonText);
                        CurrPage.Update(false);
                    end;
                end;
            }

            action(ExportTemplate)
            {
                Caption = 'Export Template';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    BookmarkManager: Codeunit "GDRG Bookmark Manager";
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    OutStr: OutStream;
                    JsonText: Text;
                    FileName: Text;
                begin
                    JsonText := BookmarkManager.ExportToJson();
                    TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                    OutStr.WriteText(JsonText);
                    TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
                    FileName := 'MyBookmarks_' + Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hours24><Minutes,2><Seconds,2>') + '.json';
                    DownloadFromStream(InStr, 'Export Bookmarks', '', 'JSON Files (*.json)|*.json', FileName);
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

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Bookmark Count");
    end;
}
