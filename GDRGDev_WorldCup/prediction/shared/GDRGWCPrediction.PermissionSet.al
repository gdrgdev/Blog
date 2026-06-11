permissionset 88894 "GDRG WC Prediction"
{
    Caption = 'WC Prediction', MaxLength = 30;
    Assignable = true;
    Permissions =
        table "GDRG WC Match" = X,
        tabledata "GDRG WC Match" = RIMD,
        table "GDRG WC Setup" = X,
        tabledata "GDRG WC Setup" = RIMD,
        table "GDRG WC Prediction" = X,
        tabledata "GDRG WC Prediction" = RIMD,
        table "GDRG WC Leaderboard" = X,
        tabledata "GDRG WC Leaderboard" = RIMD,
        page "GDRG WC Match List" = X,
        page "GDRG WC Setup" = X,
        page "GDRG WC Prediction List" = X,
        page "GDRG WC Leaderboard" = X,
        codeunit "GDRG WC Import" = X,
        codeunit "GDRG WC Prediction Mgt" = X;
}