/// <summary>
/// Control Add-in for visualizing Mermaid diagrams directly in Business Central
/// Mermaid.js documentation: https://mermaid.js.org/
/// </summary>
controladdin "MermaidVisualizerAddin"
{
    RequestedHeight = 600;
    RequestedWidth = 800;
    MinimumHeight = 400;
    MinimumWidth = 600;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js',
              'ControlAddins/MermaidVisualizer/js/MermaidVisualizer.js';

    event ControlReady();
    event DiagramRendered(Success: Boolean; ErrorMessage: Text);

    procedure LoadMermaidCode(MermaidCode: Text);
    procedure SetTheme(Theme: Text);
    procedure SetScale(ScalePercentage: Decimal);
    procedure ExportDiagram();
}
