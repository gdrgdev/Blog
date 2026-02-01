pageextension 80105 "GDRG User Setup Page" extends "User Setup"
{
    layout
    {
        addafter("User ID")
        {
            field("GDRG Employee No."; Rec."GDRG Employee No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the employee number linked to this user for birthday messages.';
            }
        }
    }
}
