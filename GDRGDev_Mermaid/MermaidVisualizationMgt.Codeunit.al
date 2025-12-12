/// <summary>
/// Mermaid Visualization Management Codeunit
/// Provides a robust API for rendering Mermaid diagrams in Business Central
/// This is the main entry point for consuming extensions
/// </summary>
codeunit 60100 "Mermaid Visualization Mgt"
{
    /// <summary>
    /// Simple method to show a Mermaid diagram with default settings
    /// </summary>
    /// <param name="MermaidCode">The Mermaid diagram code to render</param>
    /// <returns>True if diagram was displayed successfully</returns>
    procedure ShowMermaidDiagram(MermaidCode: Text): Boolean
    var
        TempDefaultOptions: Record "Mermaid Display Options" temporary;
    begin
        if MermaidCode = '' then
            exit(false);

        TempDefaultOptions.InitializeDefaults();
        exit(ShowMermaidDiagramWithOptions(MermaidCode, TempDefaultOptions));
    end;

    /// <summary>
    /// Show Mermaid diagram with specific theme and scale
    /// </summary>
    /// <param name="MermaidCode">The Mermaid diagram code to render</param>
    /// <param name="Theme">Theme to apply (Default, Dark, Forest, Neutral)</param>
    /// <param name="ScaleFactor">Scale factor (0.1 to 2.0)</param>
    /// <returns>True if diagram was displayed successfully</returns>
    procedure ShowMermaidDiagram(MermaidCode: Text; Theme: Enum "Mermaid Theme"; ScaleFactor: Decimal): Boolean
    var
        TempOptions: Record "Mermaid Display Options" temporary;
    begin
        if MermaidCode = '' then
            exit(false);

        TempOptions.InitializeDefaults();
        TempOptions."Theme" := Theme;
        TempOptions."Scale Factor" := ScaleFactor;

        exit(ShowMermaidDiagramWithOptions(MermaidCode, TempOptions));
    end;

    /// <summary>
    /// Show Mermaid diagram with complete configuration options
    /// </summary>
    /// <param name="MermaidCode">The Mermaid diagram code to render</param>
    /// <param name="TempOptions">Complete display options configuration</param>
    /// <returns>True if diagram was displayed successfully</returns>
    procedure ShowMermaidDiagramWithOptions(MermaidCode: Text; var TempOptions: Record "Mermaid Display Options" temporary): Boolean
    var
        MermaidViewer: Page "Mermaid Visual Viewer";
        ValidationResult: Text;
    begin
        if MermaidCode = '' then begin
            Message('Mermaid code cannot be empty.');
            exit(false);
        end;

        // Validate code if validation is enabled
        if TempOptions."Enable Validation" then
            if not ValidateMermaidCode(MermaidCode, ValidationResult) then begin
                Message('Mermaid code validation failed: %1', ValidationResult);
                exit(false);
            end;

        // Configure the viewer page
        MermaidViewer.SetMermaidCode(MermaidCode);

        // Apply theme if specified
        if TempOptions."Theme" <> TempOptions."Theme"::Default then
            MermaidViewer.SetThemeFromCode(TempOptions."Theme");

        // Apply scale if different from default
        if TempOptions."Scale Factor" <> 1.0 then
            MermaidViewer.SetScaleFromCode(TempOptions."Scale Factor");

        // Run the viewer
        MermaidViewer.Run();
        exit(true);
    end;

    /// <summary>
    /// Validate Mermaid code syntax and structure
    /// </summary>
    /// <param name="MermaidCode">The code to validate</param>
    /// <returns>True if code is valid</returns>
    procedure ValidateMermaidCode(MermaidCode: Text): Boolean
    var
        ValidationMessage: Text;
    begin
        exit(ValidateMermaidCode(MermaidCode, ValidationMessage));
    end;

    /// <summary>
    /// Validate Mermaid code with detailed error information
    /// </summary>
    /// <param name="MermaidCode">The code to validate</param>
    /// <param name="ValidationMessage">Detailed validation result message</param>
    /// <returns>True if code is valid</returns>
    procedure ValidateMermaidCode(MermaidCode: Text; var ValidationMessage: Text): Boolean
    begin
        ValidationMessage := '';

        // Basic validation checks
        if MermaidCode = '' then begin
            ValidationMessage := 'Code cannot be empty';
            exit(false);
        end;

        if StrLen(MermaidCode) > 10000 then begin
            ValidationMessage := 'Code exceeds maximum length of 10,000 characters';
            exit(false);
        end;

        // Check for basic Mermaid diagram types
        if not ContainsValidDiagramType(MermaidCode) then begin
            ValidationMessage := 'Code does not contain a recognized Mermaid diagram type';
            exit(false);
        end;

        ValidationMessage := 'Code validation passed';
        exit(true);
    end;

    local procedure ContainsValidDiagramType(MermaidCode: Text): Boolean
    var
        DiagramTypes: List of [Text];
        DiagramType: Text;
        CodeLowerCase: Text;
    begin
        // Initialize list of valid Mermaid diagram types
        DiagramTypes.Add('flowchart');
        DiagramTypes.Add('graph');
        DiagramTypes.Add('sequencediagram');
        DiagramTypes.Add('classDiagram');
        DiagramTypes.Add('stateDiagram');
        DiagramTypes.Add('erDiagram');
        DiagramTypes.Add('journey');
        DiagramTypes.Add('gantt');
        DiagramTypes.Add('pie');
        DiagramTypes.Add('gitgraph');

        CodeLowerCase := LowerCase(MermaidCode);

        foreach DiagramType in DiagramTypes do
            if StrPos(CodeLowerCase, LowerCase(DiagramType)) > 0 then
                exit(true);

        exit(false);
    end;
}
