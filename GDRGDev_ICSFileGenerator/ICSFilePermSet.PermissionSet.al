permissionset 50100 ICSFilePermSet
{
    Caption = 'ICS Export', MaxLength = 30;
    Assignable = true;
    Permissions =
        codeunit ICSFileGenerator = X,
        codeunit "ICS Business Helper" = X,
        codeunit "ICS Assist Edit Manager" = X,
        table "ICS Event Data Buffer" = X,
        page "ICS Event Configuration" = X;
}
