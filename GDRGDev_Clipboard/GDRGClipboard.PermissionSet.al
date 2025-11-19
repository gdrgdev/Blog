permissionset 88000 "GDRG Clipboard"
{
    Assignable = true;
    Caption = 'GDRG Clipboard Extension', MaxLength = 30;
    Permissions =
        codeunit "GDRG Clipboard Mgt. Cust." = X,
        codeunit "GDRG Clipboard Mgt. Vend." = X,
        codeunit "GDRG Clipboard Mgt. CustLedg" = X,
        page "GDRG Clipboard Helper" = X,
        tabledata Customer = R,
        tabledata "Customer Bank Account" = R,
        tabledata Vendor = R,
        tabledata "Vendor Bank Account" = R,
        tabledata "Cust. Ledger Entry" = R;
}
