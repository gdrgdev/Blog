permissionset 88888 "GDRG Env Cleanup"
{
    Assignable = true;
    Caption = 'Env Cleanup';

    Permissions =
        tabledata "GDRG Env Copy Log" = RIMD,
        tabledata "GDRG Env Copy Log Line" = RIMD,
        tabledata "GDRG Anonymize Setup" = RIMD,
        tabledata "GDRG Anonymize Field Setup" = RIMD,
        tabledata "GDRG Cleanup Setup" = RIMD,
        tabledata "GDRG Company Feature Setup" = RIMD,
        table "GDRG Env Copy Log" = X,
        table "GDRG Env Copy Log Line" = X,
        table "GDRG Anonymize Setup" = X,
        table "GDRG Anonymize Field Setup" = X,
        table "GDRG Cleanup Setup" = X,
        table "GDRG Company Feature Setup" = X,
        codeunit "GDRG Copy Company Subscriber" = X,
        codeunit "GDRG Company Feature Adjuster" = X,
        codeunit "GDRG Env Cleanup Subscriber" = X,
        codeunit "GDRG Data Anonymizer" = X,
        codeunit "GDRG Company Marker" = X,
        codeunit "GDRG Pseudonymizer" = X,
        codeunit "GDRG Env Cleanup Mgt" = X,
        codeunit "GDRG Setup Proposal Mgt" = X,
        page "GDRG Cleanup Setup" = X,
        page "GDRG Company Feature Setup" = X,
        page "GDRG Env Copy Log List" = X,
        page "GDRG Env Copy Log Lines" = X,
        page "GDRG Anonymize Setup" = X,
        page "GDRG Anonymize Field List" = X,
        page "GDRG Field Lookup" = X;
}