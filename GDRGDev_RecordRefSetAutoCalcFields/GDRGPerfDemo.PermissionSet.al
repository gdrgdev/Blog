permissionset 50100 "GDRG Perf Demo"
{
    Assignable = true;
    Caption = 'GDRG Performance Demo', MaxLength = 30;

    Permissions =
        table "GDRG Performance Test Result" = X,
        tabledata "GDRG Performance Test Result" = RIMd,
        page "GDRG Performance Test Results" = X;
}
