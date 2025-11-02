permissionset 90000 "GDRG Masking"
{
    Assignable = true;
    Caption = 'GDRG Masking', Locked = true;

    Permissions =
        table "GDRG Field Masking Setup" = X,
        tabledata "GDRG Field Masking Setup" = RIMD,
        page "GDRG Field Masking Setup" = X,
        page "GDRG Field Masking Lookup" = X,
        codeunit "GDRG Masking Management" = X,
        tabledata Employee = R;
}
