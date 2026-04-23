controladdin "GDRG Field Magnifier"
{
    RequestedHeight = 0;
    MinimumHeight = 0;
    RequestedWidth = 0;
    HorizontalStretch = true;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalShrink = true;

    Scripts = 'src/ControlAddIn/js/Magnifier.js';
    StartupScript = 'src/ControlAddIn/js/Magnifier.js';
    StyleSheets = 'src/ControlAddIn/css/Magnifier.css';

    event OnMagnifierReady();

    procedure EnableMagnifier();
    procedure DisableMagnifier();
    procedure SetZoomLevel(Level: Integer);
}
