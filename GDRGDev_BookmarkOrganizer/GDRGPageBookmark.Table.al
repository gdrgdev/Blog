table 50101 "GDRG Page Bookmark"
{
    Caption = 'Page Bookmark';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Page Bookmark List";
    DrillDownPageId = "GDRG Page Bookmark List";
    Permissions = tabledata "GDRG Folder Bookmark" = RIMD,
            tabledata "GDRG Page Bookmark" = RIMD;
    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user ID who owns this bookmark.';
            AllowInCustomizations = Never;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies the unique entry number for this bookmark.';
            AllowInCustomizations = Never;
        }
        field(10; "Folder Code"; Code[20])
        {
            Caption = 'Folder Code';
            TableRelation = "GDRG Folder Bookmark"."Folder Code" where("User ID" = field("User ID"));
            ToolTip = 'Specifies the folder code where this bookmark is stored.';
        }
        field(11; "Page ID"; Integer)
        {
            Caption = 'Page ID';
            ToolTip = 'Specifies the Business Central page ID to open.';
        }
        field(12; "Page Name"; Text[100])
        {
            Caption = 'Page Name';
            ToolTip = 'Specifies the name of the bookmarked page.';
        }
        field(13; "Custom Label"; Text[100])
        {
            Caption = 'Custom Label';
            ToolTip = 'Specifies an optional custom label for this bookmark.';
        }
        field(20; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            ToolTip = 'Specifies the sort order of this bookmark within its folder.';
        }
        field(30; Indentation; Integer)
        {
            Caption = 'Indentation';
            ToolTip = 'Specifies the indentation level for tree view display.';
            AllowInCustomizations = Never;
        }
    }

    keys
    {
        key(PK; "User ID", "Entry No.")
        {
            Clustered = true;
        }
        key(Folder; "User ID", "Folder Code", "Sort Order")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Page Name", "Page ID")
        {
        }
        fieldgroup(Brick; "Page Name", "Page ID", "Folder Code")
        {
        }
    }

    trigger OnInsert()
    var
        ExistingBookmark: Record "GDRG Page Bookmark";
        ErrorInfo: ErrorInfo;
    begin
        if "User ID" = '' then
            "User ID" := UserId();

        if "Page ID" > 0 then begin
            ExistingBookmark.SetCurrentKey("User ID", "Folder Code", "Sort Order");
            ExistingBookmark.SetRange("User ID", "User ID");
            ExistingBookmark.SetRange("Folder Code", "Folder Code");
            ExistingBookmark.SetRange("Page ID", "Page ID");
            if not ExistingBookmark.IsEmpty() then begin
                ErrorInfo.Message := StrSubstNo('Page "%1" is already bookmarked in folder "%2"', "Page Name", "Folder Code");
                Error(ErrorInfo);
            end;
        end;
    end;
}
