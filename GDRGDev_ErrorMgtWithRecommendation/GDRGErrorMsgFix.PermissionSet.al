permissionset 50100 "GDRG Error Msg Fix"
{
    Access = Public;
    Assignable = true;
    Caption = 'GDRG Error Message Fix', MaxLength = 30;

    Permissions =
        codeunit "GDRG GL Account Blocked Error" = X,
        codeunit "GDRG GL Acc Direct Post Error" = X,
        codeunit "GDRG GL Account Error Gen" = X,
        page "GDRG Error Test Card" = X,
        tabledata "G/L Account" = RIMD,
        tabledata "Error Message" = RIMD,
        tabledata "General Ledger Setup" = RIMD;
}