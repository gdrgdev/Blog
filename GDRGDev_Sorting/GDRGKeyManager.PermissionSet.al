permissionset 78452 "GDRG Key Manager"
{
    Assignable = true;
    Caption = 'GDRG Key Manager', MaxLength = 30;

    Permissions =
        tabledata "GDRG Table Key" = RIMD,
        table "GDRG Table Key" = X,
        codeunit "GDRG Key Manager" = X,
        page "GDRG Key Selection" = X;
}
