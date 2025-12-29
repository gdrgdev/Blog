permissionset 80100 "GDRG RSS Reader"
{
    Assignable = true;
    Caption = 'RSS Reader', MaxLength = 30;

    Permissions =
        table "GDRG RSS Feed Setup" = X,
        tabledata "GDRG RSS Feed Setup" = RMID,
        table "GDRG RSS Feed Source" = X,
        tabledata "GDRG RSS Feed Source" = RMID,
        table "GDRG RSS Feed Entry" = X,
        tabledata "GDRG RSS Feed Entry" = RMID,
        codeunit "GDRG RSS Feed Manager" = X,
        page "GDRG RSS Feed Setup" = X,
        page "GDRG RSS Feed Sources" = X,
        page "GDRG RSS Feed Source Card" = X,
        page "GDRG RSS Feed Entries FactBox" = X,
        page "GDRG RSS Feed Entries List" = X,
        page "GDRG RSS Feed Entries Part" = X;
}
