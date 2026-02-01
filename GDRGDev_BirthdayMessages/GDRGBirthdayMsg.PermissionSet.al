permissionset 80100 "GDRG Birthday Msg"
{
    Assignable = true;
    Caption = 'Birthday Messages';

    Permissions =
    table "GDRG Birthday Message" = X,
    tabledata "GDRG Birthday Message" = RMID,
    tabledata "User Setup" = R,
    page "GDRG Birthday Management HR" = X,
    page "GDRG Team Birthday Portal" = X,
    page "GDRG My Birthday Messages" = X,
    page "GDRG Birthday Message Dialog" = X,
    page "GDRG Birthday Headline Part" = X,
    codeunit "GDRG Birthday Management" = X,
    codeunit "GDRG Birthday Notification" = X,
    codeunit "GDRG Birthday Headline" = X;
}
