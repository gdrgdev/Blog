codeunit 50101 "GDRG Bookmark Tree Builder"
{
    Permissions = tabledata "GDRG Folder Bookmark" = RIMD,
            tabledata "GDRG Page Bookmark" = RIMD;
    procedure BuildTree(var TempPageBookmark: Record "GDRG Page Bookmark" temporary; var ExpandedFolders: List of [Code[20]])
    var
        FolderBookmark: Record "GDRG Folder Bookmark";
        OrderNumber: Integer;
    begin
        TempPageBookmark.DeleteAll(false);
        OrderNumber := 10;

        FolderBookmark.SetRange("User ID", UserId());
        FolderBookmark.SetCurrentKey("User ID", "Sort Order");
        if FolderBookmark.FindSet() then
            repeat
                OrderNumber := AddFolderWithBookmarks(TempPageBookmark, FolderBookmark, OrderNumber, ExpandedFolders);
            until FolderBookmark.Next() = 0;

        TempPageBookmark.SetCurrentKey("Sort Order");
        if TempPageBookmark.FindFirst() then; // Position at first record
    end;

    local procedure AddFolderWithBookmarks(var TempPageBookmark: Record "GDRG Page Bookmark" temporary; FolderBookmark: Record "GDRG Folder Bookmark"; var OrderNumber: Integer; var ExpandedFolders: List of [Code[20]]): Integer
    var
        PageBookmark: Record "GDRG Page Bookmark";
    begin
        TempPageBookmark.Init();
        TempPageBookmark."Entry No." := OrderNumber;
        TempPageBookmark."User ID" := UserId();
        TempPageBookmark."Folder Code" := FolderBookmark."Folder Code";
        TempPageBookmark."Page ID" := -1;
        TempPageBookmark."Page Name" := FolderBookmark."Folder Name";
        TempPageBookmark."Sort Order" := OrderNumber;
        TempPageBookmark.Indentation := 0;
        TempPageBookmark.Insert(false);

        OrderNumber += 10;

        if ExpandedFolders.Contains(FolderBookmark."Folder Code") then begin
            PageBookmark.SetRange("User ID", UserId());
            PageBookmark.SetRange("Folder Code", FolderBookmark."Folder Code");
            PageBookmark.SetCurrentKey("User ID", "Folder Code", "Sort Order");
            if PageBookmark.FindSet() then
                repeat
                    TempPageBookmark.Init();
                    TempPageBookmark."Entry No." := OrderNumber;
                    TempPageBookmark."User ID" := PageBookmark."User ID";
                    TempPageBookmark."Folder Code" := PageBookmark."Folder Code";
                    TempPageBookmark."Page ID" := PageBookmark."Page ID";
                    TempPageBookmark."Page Name" := PageBookmark."Page Name";
                    TempPageBookmark."Custom Label" := PageBookmark."Custom Label";
                    TempPageBookmark."Sort Order" := OrderNumber;
                    TempPageBookmark.Indentation := 1;
                    TempPageBookmark.Insert(false);
                    OrderNumber += 10;
                until PageBookmark.Next() = 0;
        end;

        exit(OrderNumber);
    end;

    procedure CalculateDisplayName(PageBookmarkRec: Record "GDRG Page Bookmark"; var ExpandedFolders: List of [Code[20]]): Text[250]
    var
        BookmarkManager: Codeunit "GDRG Bookmark Manager";
        TreeSymbol: Text[10];
        Icon: Text[10];
        Count: Integer;
    begin
        if PageBookmarkRec."Page ID" = -1 then begin
            Count := BookmarkManager.CountBookmarksInFolder(PageBookmarkRec."Folder Code");
            if ExpandedFolders.Contains(PageBookmarkRec."Folder Code") then begin
                TreeSymbol := '▼ ';
                Icon := '📂 ';
            end else begin
                TreeSymbol := '▶ ';
                Icon := '📁 ';
            end;
            exit(TreeSymbol + Icon + PageBookmarkRec."Page Name" + ' (' + Format(Count) + ')');
        end else begin
            if PageBookmarkRec."Custom Label" <> '' then
                exit('📄 ' + PageBookmarkRec."Custom Label")
            else
                exit('📄 ' + PageBookmarkRec."Page Name");
        end;
    end;

    procedure IsFolder(PageBookmarkRec: Record "GDRG Page Bookmark"): Boolean
    begin
        exit(PageBookmarkRec."Page ID" = -1);
    end;

    procedure ToggleFolder(var TempPageBookmark: Record "GDRG Page Bookmark" temporary; FolderCode: Code[20]; var ExpandedFolders: List of [Code[20]])
    begin
        if ExpandedFolders.Contains(FolderCode) then
            ExpandedFolders.Remove(FolderCode)
        else
            ExpandedFolders.Add(FolderCode);

        BuildTree(TempPageBookmark, ExpandedFolders);

        TempPageBookmark.SetCurrentKey("Sort Order");
        if TempPageBookmark.FindSet() then
            repeat
                if (TempPageBookmark."Folder Code" = FolderCode) and (TempPageBookmark."Page ID" = -1) then
                    exit;
            until TempPageBookmark.Next() = 0;

        if TempPageBookmark.FindFirst() then; // Reposition to first record
    end;

    procedure ExpandAllFolders(var TempPageBookmark: Record "GDRG Page Bookmark" temporary; var ExpandedFolders: List of [Code[20]])
    var
        FolderBookmark: Record "GDRG Folder Bookmark";
    begin
        ExpandedFolders.RemoveRange(1, ExpandedFolders.Count());
        FolderBookmark.SetRange("User ID", UserId());
        if FolderBookmark.FindSet() then
            repeat
                ExpandedFolders.Add(FolderBookmark."Folder Code");
            until FolderBookmark.Next() = 0;
        BuildTree(TempPageBookmark, ExpandedFolders);
    end;

    procedure CollapseAllFolders(var TempPageBookmark: Record "GDRG Page Bookmark" temporary; var ExpandedFolders: List of [Code[20]])
    begin
        ExpandedFolders.RemoveRange(1, ExpandedFolders.Count());
        BuildTree(TempPageBookmark, ExpandedFolders);
    end;

    procedure OpenPage(PageID: Integer)
    var
        ErrorInfo: ErrorInfo;
    begin
        if PageID <= 0 then
            exit;

        if not TryOpenPage(PageID) then begin
            ErrorInfo.Title := 'Cannot open page';
            ErrorInfo.Message := StrSubstNo('You do not have permission to access page %1, or the page does not exist in this environment.', PageID);
            ErrorInfo.DetailedMessage := 'This bookmark may have been created by another user with different permissions, or the page may not be available in your current license/environment.';
            ErrorInfo.AddNavigationAction('Learn about BC permissions');
            ErrorInfo.Verbosity := Verbosity::Warning;
            Error(ErrorInfo);
        end;
    end;

    [TryFunction]
    local procedure TryOpenPage(PageID: Integer)
    begin
        Page.Run(PageID);
    end;
}
