permissionset 50100 "GDRG Forward Links"
{
    Caption = 'GDRG Forward Links', MaxLength = 30;
    Assignable = true;

    Permissions =
        codeunit "GDRG Forward Link Mgt." = X,
        codeunit "GDRG Forward Link Subscriber" = X,
        page "GDRG Forward Links Test Page" = X,
        tabledata "Named Forward Link" = RIMD,
        tabledata "Error Message" = RIMD;
}
