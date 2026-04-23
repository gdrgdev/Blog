pageextension 78453 "GDRG Customer Card Magnifier" extends "Customer Card"
{
    layout
    {
        addlast(content)
        {
            usercontrol(MagnifierAddin; "GDRG Field Magnifier")
            {
                ApplicationArea = All;

                trigger OnMagnifierReady()
                begin
                    MagnifierActive := true;
                end;
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(ToggleMagnifier)
            {
                ApplicationArea = All;
                Caption = 'Toggle Field Magnifier';
                ToolTip = 'Enable or disable field magnification on hover';

                trigger OnAction()
                begin
                    MagnifierActive := not MagnifierActive;
                    if MagnifierActive then begin
                        CurrPage.MagnifierAddin.EnableMagnifier();
                        Message('Field Magnifier enabled');
                    end else begin
                        CurrPage.MagnifierAddin.DisableMagnifier();
                        Message('Field Magnifier disabled');
                    end;
                end;
            }
            action(SetZoom3x)
            {
                ApplicationArea = All;
                Caption = 'Zoom 3x';
                ToolTip = 'Set magnification to 3x';

                trigger OnAction()
                begin
                    CurrPage.MagnifierAddin.SetZoomLevel(3);
                end;
            }
            action(SetZoom4x)
            {
                ApplicationArea = All;
                Caption = 'Zoom 4x';
                ToolTip = 'Set magnification to 4x';

                trigger OnAction()
                begin
                    CurrPage.MagnifierAddin.SetZoomLevel(4);
                end;
            }
            action(SetZoom5x)
            {
                ApplicationArea = All;
                Caption = 'Zoom 5x';
                ToolTip = 'Set magnification to 5x';

                trigger OnAction()
                begin
                    CurrPage.MagnifierAddin.SetZoomLevel(5);
                end;
            }
        }
        addlast(Promoted)
        {
            group(Category_Magnifier)
            {
                Caption = 'Magnifier';

                actionref(ToggleMagnifier_Promoted; ToggleMagnifier)
                {
                }
                actionref(SetZoom3x_Promoted; SetZoom3x)
                {
                }
                actionref(SetZoom4x_Promoted; SetZoom4x)
                {
                }
                actionref(SetZoom5x_Promoted; SetZoom5x)
                {
                }
            }
        }
    }

    var
        MagnifierActive: Boolean;
}
