permissionset 50100 "GDRG Gaming"
{
    Assignable = true;
    Caption = 'GDRG Gaming', MaxLength = 30;

    Permissions =
        tabledata "GDRG Achievement Definition" = RIMD,
        tabledata "GDRG User Achievement Profile" = RIMD,
        tabledata "GDRG User Achievement Log" = RI,
        table "GDRG Achievement Definition" = X,
        table "GDRG User Achievement Profile" = X,
        table "GDRG User Achievement Log" = X,
        page "GDRG Achievement Definitions" = X,
        page "GDRG Achievement Guide" = X,
        page "GDRG Gaming Dashboard" = X,
        page "GDRG My Profile" = X,
        page "GDRG User Profile List" = X,
        page "GDRG Achievement Log" = X,
        page "GDRG Achievement Leaderboard" = X,
        page "GDRG My Achievement Log" = X,
        codeunit "GDRG Achievement Processor" = X,
        codeunit "GDRG Demo Data" = X,
        codeunit "GDRG Achievement Events" = X,
        codeunit "GDRG UI Helper" = X;
}
