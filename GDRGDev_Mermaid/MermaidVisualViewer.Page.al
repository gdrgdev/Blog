/// <summary>
/// Mermaid diagram visualization page for Business Central
/// Provides real-time rendering of Mermaid diagrams with theme and scaling controls
/// </summary>
page 60100 "Mermaid Visual Viewer"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Mermaid Visual Viewer';

    layout
    {
        area(Content)
        {
            group(Visualization)
            {
                Caption = 'Diagram Visualization';

                usercontrol(MermaidVisualizer; "MermaidVisualizerAddin")
                {
                    trigger ControlReady()
                    begin
                        ControlIsReady := true;
                        GenerateAndShowDiagram();
                    end;

                    trigger DiagramRendered(Success: Boolean; ErrorMessage: Text)
                    begin
                        if not Success then
                            Message('Rendering failed: %1', ErrorMessage);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetLightTheme)
            {
                Caption = 'Light Theme';
                Image = SetupLines;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Apply light theme to diagram.';

                trigger OnAction()
                begin
                    if ControlIsReady then
                        CurrPage.MermaidVisualizer.SetTheme('default');
                end;
            }

            action(SetDarkTheme)
            {
                Caption = 'Dark Theme';
                Image = SetupColumns;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Apply dark theme to diagram.';

                trigger OnAction()
                begin
                    if ControlIsReady then
                        CurrPage.MermaidVisualizer.SetTheme('dark');
                end;
            }

            action(SetForestTheme)
            {
                Caption = 'Forest Theme';
                Image = SetupPayment;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Apply forest theme to diagram.';

                trigger OnAction()
                begin
                    if ControlIsReady then
                        CurrPage.MermaidVisualizer.SetTheme('forest');
                end;
            }

            action(SetNeutralTheme)
            {
                Caption = 'Neutral Theme';
                Image = Report;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Apply neutral theme to diagram.';

                trigger OnAction()
                begin
                    if ControlIsReady then
                        CurrPage.MermaidVisualizer.SetTheme('neutral');
                end;
            }

            action(SetSmallSize)
            {
                Caption = 'Small (60%)';
                Image = Compress;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Scale diagram to 60%.';

                trigger OnAction()
                begin
                    if ControlIsReady then
                        CurrPage.MermaidVisualizer.SetScale(60);
                end;
            }

            action(SetMediumSize)
            {
                Caption = 'Medium (80%)';
                Image = Default;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Scale diagram to 80% (recommended).';

                trigger OnAction()
                begin
                    if ControlIsReady then
                        CurrPage.MermaidVisualizer.SetScale(80);
                end;
            }

            action(SetLargeSize)
            {
                Caption = 'Large (100%)';
                Image = View;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Scale diagram to 100%.';

                trigger OnAction()
                begin
                    if ControlIsReady then
                        CurrPage.MermaidVisualizer.SetScale(100);
                end;
            }

            action(ExportDiagram)
            {
                Caption = 'Export Diagram';
                Image = Export;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Export diagram as SVG file.';

                trigger OnAction()
                begin
                    if ControlIsReady then
                        CurrPage.MermaidVisualizer.ExportDiagram();
                end;
            }
        }

    }

    var
        ControlIsReady: Boolean;
        ExternalMermaidCode: Text;
        PendingTheme: Enum "Mermaid Theme";
        PendingScaleFactor: Decimal;
        HasPendingTheme: Boolean;
        HasPendingScale: Boolean;


    local procedure GenerateAndShowDiagram()
    var
        MermaidCode: Text;
    begin
        if not ControlIsReady then
            exit;

        // Apply pending theme FIRST if set
        if HasPendingTheme then begin
            ApplyTheme(PendingTheme);
            HasPendingTheme := false;
        end;

        // Apply pending scale SECOND if set
        if HasPendingScale then begin
            ApplyScale(PendingScaleFactor);
            HasPendingScale := false;
        end;

        // Load diagram LAST so it uses the correct theme
        MermaidCode := ExternalMermaidCode;
        if MermaidCode <> '' then
            CurrPage.MermaidVisualizer.LoadMermaidCode(MermaidCode)
        else
            Message('No diagram code available to display.');
    end;

    /// <summary>
    /// Sets Mermaid code from external pages for rendering
    /// </summary>
    /// <param name="Code">The Mermaid diagram code to be rendered</param>
    procedure SetMermaidCode(Code: Text)
    begin
        ExternalMermaidCode := Code;
    end;

    /// <summary>
    /// Clears external Mermaid code
    /// </summary>
    procedure ClearExternalCode()
    begin
        Clear(ExternalMermaidCode);
    end;

    /// <summary>
    /// Sets theme from external code (codeunit)
    /// </summary>
    /// <param name="Theme">The theme to apply to the diagram</param>
    procedure SetThemeFromCode(Theme: Enum "Mermaid Theme")
    begin
        if ControlIsReady then
            ApplyTheme(Theme)
        else begin
            PendingTheme := Theme;
            HasPendingTheme := true;
        end;
    end;

    /// <summary>
    /// Sets scale from external code (codeunit)
    /// </summary>
    /// <param name="ScaleFactor">The scale factor (decimal, e.g., 0.8 for 80%)</param>
    procedure SetScaleFromCode(ScaleFactor: Decimal)
    begin
        if ControlIsReady then
            ApplyScale(ScaleFactor)
        else begin
            PendingScaleFactor := ScaleFactor;
            HasPendingScale := true;
        end;
    end;

    local procedure ApplyTheme(Theme: Enum "Mermaid Theme")
    begin
        case Theme of
            Theme::Default:
                CurrPage.MermaidVisualizer.SetTheme('default');
            Theme::Dark:
                CurrPage.MermaidVisualizer.SetTheme('dark');
            Theme::Forest:
                CurrPage.MermaidVisualizer.SetTheme('forest');
            Theme::Neutral:
                CurrPage.MermaidVisualizer.SetTheme('neutral');
        end;
    end;

    local procedure ApplyScale(ScaleFactor: Decimal)
    var
        ScalePercentage: Integer;
    begin
        // Convert decimal scale factor to percentage
        ScalePercentage := Round(ScaleFactor * 100, 1);

        // Ensure scale is within valid range
        if ScalePercentage < 10 then
            ScalePercentage := 10;
        if ScalePercentage > 200 then
            ScalePercentage := 200;

        CurrPage.MermaidVisualizer.SetScale(ScalePercentage);
    end;


}
