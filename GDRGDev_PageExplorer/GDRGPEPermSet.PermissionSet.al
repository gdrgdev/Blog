permissionset 97819 "GDRGPE Perm Set"
{
    Assignable = true;
    Caption = 'GDRGPE Page Explorer', Locked = true;

    Permissions =
        table "GDRGPE Line" = X,
        tabledata "GDRGPE Line" = R,
        codeunit "GDRGPE Builder" = X,
        codeunit "GDRGPE JSON Renderer" = X,
        page "GDRGPE Main" = X,
        page "GDRGPE Raw JSON" = X,
        page "GDRGPE Fields Part" = X,
        page "GDRGPE Actions Part" = X;
}
