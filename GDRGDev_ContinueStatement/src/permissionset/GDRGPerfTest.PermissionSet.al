permissionset 50100 "GDRG Perf Test"
{
    Assignable = true;
    Caption = 'GDRG Performance Test', MaxLength = 30;

    Permissions =
        table "GDRG Performance Test Results" = X,
        tabledata "GDRG Performance Test Results" = RIMD,
        page "GDRG Performance Test" = X,
        table "GDRG Valid Customers" = X,
        tabledata "GDRG Valid Customers" = RIMD,
        page "GDRG Customer Test Data" = X,
        codeunit "GDRG Test Data Generator" = X;
}
