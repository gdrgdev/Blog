permissionset 60100 "Mermaid Permissions"
{
    Assignable = true;
    Caption = 'Mermaid Perms', MaxLength = 30;

    Permissions =
        page "Mermaid Code Editor" = X,
        page "Mermaid Visual Viewer" = X,
        table "Mermaid Display Options" = X,
        codeunit "Mermaid Visualization Mgt" = X,
        codeunit "Mermaid Example Helpers" = X;
}
