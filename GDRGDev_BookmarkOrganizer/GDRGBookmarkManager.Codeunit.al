codeunit 50100 "GDRG Bookmark Manager"
{
    Permissions = tabledata "GDRG Folder Bookmark" = RIMD,
            tabledata "GDRG Page Bookmark" = RIMD;

    procedure CountBookmarksInFolder(FolderCode: Code[20]): Integer
    var
        PageBookmark: Record "GDRG Page Bookmark";
    begin
        PageBookmark.SetRange("User ID", UserId());
        PageBookmark.SetRange("Folder Code", FolderCode);
        exit(PageBookmark.Count());
    end;

    procedure ExportToJson(): Text
    var
        FolderBookmark: Record "GDRG Folder Bookmark";
        PageBookmark: Record "GDRG Page Bookmark";
        JsonObject: JsonObject;
        FoldersArray: JsonArray;
        BookmarksArray: JsonArray;
        FolderObj: JsonObject;
        BookmarkObj: JsonObject;
    begin
        JsonObject.Add('user', UserId());
        JsonObject.Add('exportDate', CurrentDateTime());

        FolderBookmark.SetRange("User ID", UserId());
        if FolderBookmark.FindSet() then
            repeat
                Clear(FolderObj);
                FolderObj.Add('code', FolderBookmark."Folder Code");
                FolderObj.Add('name', FolderBookmark."Folder Name");
                FolderObj.Add('sortOrder', FolderBookmark."Sort Order");
                FoldersArray.Add(FolderObj);
            until FolderBookmark.Next() = 0;

        PageBookmark.SetRange("User ID", UserId());
        if PageBookmark.FindSet() then
            repeat
                Clear(BookmarkObj);
                BookmarkObj.Add('folderCode', PageBookmark."Folder Code");
                BookmarkObj.Add('pageId', PageBookmark."Page ID");
                BookmarkObj.Add('pageName', PageBookmark."Page Name");
                BookmarkObj.Add('customLabel', PageBookmark."Custom Label");
                BookmarkObj.Add('sortOrder', PageBookmark."Sort Order");
                BookmarksArray.Add(BookmarkObj);
            until PageBookmark.Next() = 0;

        JsonObject.Add('folders', FoldersArray);
        JsonObject.Add('bookmarks', BookmarksArray);

        exit(Format(JsonObject));
    end;

    procedure ImportFromJson(JsonText: Text)
    var
        JsonObject: JsonObject;
        FoldersArray: JsonArray;
        BookmarksArray: JsonArray;
        FolderToken: JsonToken;
        BookmarkToken: JsonToken;
        CleanJson: Text;
        ErrorInfo: ErrorInfo;
    begin
        CleanJson := JsonText.Trim();

        if CleanJson = '' then begin
            ErrorInfo.Message := 'JSON content is empty';
            Error(ErrorInfo);
        end;

        if not JsonObject.ReadFrom(CleanJson) then begin
            ErrorInfo.Message := 'Invalid JSON format. Please verify the file contains valid JSON data.';
            Error(ErrorInfo);
        end;

        if JsonObject.Get('folders', FolderToken) then begin
            FoldersArray := FolderToken.AsArray();
            ImportFolders(FoldersArray);
        end;

        if JsonObject.Get('bookmarks', BookmarkToken) then begin
            BookmarksArray := BookmarkToken.AsArray();
            ImportBookmarks(BookmarksArray);
        end;

        Message('Import completed successfully');
    end;

    local procedure ImportFolders(FoldersArray: JsonArray)
    var
        FolderBookmark: Record "GDRG Folder Bookmark";
        FolderToken: JsonToken;
        FolderObj: JsonObject;
        i: Integer;
    begin
        for i := 0 to FoldersArray.Count() - 1 do begin
            FoldersArray.Get(i, FolderToken);
            FolderObj := FolderToken.AsObject();

            FolderBookmark.Init();
            FolderBookmark."User ID" := UserId();
            FolderBookmark."Folder Code" := GetJsonValue(FolderObj, 'code');
            FolderBookmark."Folder Name" := GetJsonValue(FolderObj, 'name');
            FolderBookmark."Sort Order" := GetJsonValueAsInteger(FolderObj, 'sortOrder');
            if not FolderBookmark.Insert(false) then
                FolderBookmark.Modify(false);
        end;
    end;

    local procedure ImportBookmarks(BookmarksArray: JsonArray)
    var
        PageBookmark: Record "GDRG Page Bookmark";
        ExistingBookmark: Record "GDRG Page Bookmark";
        BookmarkToken: JsonToken;
        BookmarkObj: JsonObject;
        i: Integer;
        PageId: Integer;
        FolderCode: Code[20];
    begin
        for i := 0 to BookmarksArray.Count() - 1 do begin
            BookmarksArray.Get(i, BookmarkToken);
            BookmarkObj := BookmarkToken.AsObject();

            PageId := GetJsonValueAsInteger(BookmarkObj, 'pageId');
            FolderCode := CopyStr(GetJsonValue(BookmarkObj, 'folderCode'), 1, 20);

            ExistingBookmark.SetRange("User ID", UserId());
            ExistingBookmark.SetRange("Page ID", PageId);
            ExistingBookmark.SetRange("Folder Code", FolderCode);

            if ExistingBookmark.FindFirst() then begin
                ExistingBookmark."Page Name" := CopyStr(GetJsonValue(BookmarkObj, 'pageName'), 1, 100);
                ExistingBookmark."Custom Label" := CopyStr(GetJsonValue(BookmarkObj, 'customLabel'), 1, 100);
                ExistingBookmark."Sort Order" := GetJsonValueAsInteger(BookmarkObj, 'sortOrder');
                ExistingBookmark.Modify(false);
            end else begin
                PageBookmark.Init();
                PageBookmark."User ID" := UserId();
                PageBookmark."Folder Code" := FolderCode;
                PageBookmark."Page ID" := PageId;
                PageBookmark."Page Name" := CopyStr(GetJsonValue(BookmarkObj, 'pageName'), 1, 100);
                PageBookmark."Custom Label" := CopyStr(GetJsonValue(BookmarkObj, 'customLabel'), 1, 100);
                PageBookmark."Sort Order" := GetJsonValueAsInteger(BookmarkObj, 'sortOrder');
                if PageBookmark.Insert(true) then; // Suppress return value check
            end;
        end;
    end;

    local procedure GetJsonValue(JsonObj: JsonObject; KeyName: Text): Text
    var
        JsonToken: JsonToken;
    begin
        if JsonObj.Get(KeyName, JsonToken) then
            exit(JsonToken.AsValue().AsText());
    end;

    local procedure GetJsonValueAsInteger(JsonObj: JsonObject; KeyName: Text): Integer
    var
        JsonToken: JsonToken;
    begin
        if JsonObj.Get(KeyName, JsonToken) then
            exit(JsonToken.AsValue().AsInteger());
    end;
}
