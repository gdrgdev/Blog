permissionset 50100 "GDRG Bookmarks"
{
    Assignable = true;
    Caption = 'GDRG Bookmarks', Locked = true;

    Permissions =
        table "GDRG Folder Bookmark" = X,
        tabledata "GDRG Folder Bookmark" = RIMD,
        table "GDRG Page Bookmark" = X,
        tabledata "GDRG Page Bookmark" = RIMD,
        page "GDRG Bookmark Tree View" = X,
        page "GDRG Bookmark Tree Part" = X,
        page "GDRG Folder Bookmark List" = X,
        page "GDRG Page Bookmark List" = X,
        page "GDRG System Page Browser" = X,
        codeunit "GDRG Bookmark Manager" = X,
        codeunit "GDRG Bookmark Tree Builder" = X;
}
