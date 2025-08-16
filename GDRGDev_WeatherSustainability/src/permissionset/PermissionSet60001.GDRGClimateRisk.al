permissionset 60001 "GDRG Climate Risk"
{
    Access = Public;
    Assignable = true;
    Caption = 'Climate Risk Analysis', MaxLength = 30;

    Permissions =
    tabledata "GDRG Order Climate Risk" = RIMD,
    table "GDRG Order Climate Risk" = X,

    page "GDRG Order Climate Analysis" = X,

    codeunit "GDRG Climate Risk Calculator" = X,
    codeunit "GDRG Climate Risk Manager" = X,

    tabledata "GDRG Weather Data" = R,
    tabledata "GDRG Zip Code Info" = R,
    tabledata "GDRG Assistant Session" = R,

    tabledata "Sales Header" = R,
    tabledata "Purchase Header" = R,
    tabledata Customer = R,
    tabledata Vendor = R,
    tabledata "Company Information" = R,
    table "Sales Header" = X,
    table "Purchase Header" = X,
    table Customer = X,
    table Vendor = X,
    table "Company Information" = X;
}
