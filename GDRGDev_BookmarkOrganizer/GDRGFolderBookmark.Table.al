table 50100 "GDRG Folder Bookmark"
{
    Caption = 'Folder Bookmark';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Folder Bookmark List";
    DrillDownPageId = "GDRG Folder Bookmark List";
    Permissions = tabledata "GDRG Folder Bookmark" = RIMD,
            tabledata "GDRG Page Bookmark" = RIMD;
    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user ID who owns this folder.';
            AllowInCustomizations = Never;
        }
        field(2; "Folder Code"; Code[20])
        {
            Caption = 'Folder Code';
            ToolTip = 'Specifies the unique code for this folder.';
        }
        field(10; "Folder Name"; Text[100])
        {
            Caption = 'Folder Name';
            ToolTip = 'Specifies the display name of the folder.';
        }
        field(20; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            ToolTip = 'Specifies the sort order of this folder.';
        }
        field(30; "Bookmark Count"; Integer)
        {
            Caption = 'Bookmark Count';
            FieldClass = FlowField;
            CalcFormula = count("GDRG Page Bookmark" where("User ID" = field("User ID"), "Folder Code" = field("Folder Code")));
            Editable = false;
            ToolTip = 'Specifies the number of bookmarks in this folder.';
        }
    }

    keys
    {
        key(PK; "User ID", "Folder Code")
        {
            Clustered = true;
        }
        key(Sort; "User ID", "Sort Order")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Folder Code", "Folder Name")
        {
        }
        fieldgroup(Brick; "Folder Code", "Folder Name", "Bookmark Count")
        {
        }
    }

    trigger OnInsert()
    begin
        if "User ID" = '' then
            "User ID" := UserId();
    end;

    trigger OnDelete()
    var
        PageBookmark: Record "GDRG Page Bookmark";
    begin
        PageBookmark.SetRange("User ID", "User ID");
        PageBookmark.SetRange("Folder Code", "Folder Code");
        PageBookmark.DeleteAll(false);
    end;
}
