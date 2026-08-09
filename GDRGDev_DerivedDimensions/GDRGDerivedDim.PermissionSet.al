permissionset 88888 "GDRG Derived Dim"
{
    Caption = 'Derived Dim.', MaxLength = 30;
    Assignable = true;

    Permissions =
        codeunit "GDRG Derived Dim Mgt." = X,
        codeunit "GDRG Customer Dim Subs" = X;
}
