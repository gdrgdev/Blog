permissionset 50100 "GDRG Personal Tags"
{
    Access = Public;
    Assignable = true;
    Caption = 'GDRG Personal Tags', MaxLength = 30;

    Permissions =
        table "GDRG Personal Tag Master" = X,
        tabledata "GDRG Personal Tag Master" = RIMD,
        table "GDRG Personal Tag Assignment" = X,
        tabledata "GDRG Personal Tag Assignment" = RIMD,
        codeunit "GDRG Personal Tag Manager" = X,
        codeunit "GDRG Demo Data Setup" = X,
        page "GDRG Personal Tags FactBox" = X,
        page "GDRG Tag Search" = X,
        page "GDRG Personal Tag Master" = X,
        page "GDRG Personal Tag Assignments" = X,
        page "GDRG Tag Selection" = X;
}
