permissionset 50105 "GDRG Nav. History"
{
    Caption = 'GDRG Nav. History', Locked = false;
    Assignable = true;

    Permissions =
        tabledata "GDRG Navigation History" = RIMD,
        table "GDRG Navigation History" = X,
        page "GDRG Navigation History" = X,
        codeunit "GDRG Navigation History Mgt." = X;
}
