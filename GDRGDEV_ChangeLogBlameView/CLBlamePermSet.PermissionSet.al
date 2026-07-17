namespace DefaultPublisher.ChangeLogView;

permissionset 88896 "CL Blame Perm Set"
{
    Assignable = true;
    Caption = 'Change Log Blame View', Locked = true;

    Permissions =
        table "CL Blame Row Buffer" = X,
        table "CL Blame Cell Buffer" = X,
        codeunit "CL Blame Mgmt" = X,
        page "CL Blame Matrix" = X,
        page "CL Blame" = X;
}
