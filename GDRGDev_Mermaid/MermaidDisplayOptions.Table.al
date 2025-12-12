/// <summary>
/// Table for Mermaid display options and configuration
/// Used to pass rendering parameters to the visualization engine
/// </summary>
table 60100 "Mermaid Display Options"
{
    Caption = 'Mermaid Display Options';
    TableType = Temporary;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies the unique identifier for the display options record.';
            NotBlank = true;
        }
        field(10; "Theme"; Enum "Mermaid Theme")
        {
            Caption = 'Theme';
            ToolTip = 'Specifies the color theme for the Mermaid diagram (Default, Dark, Forest, or Neutral).';
            InitValue = Default;
        }
        field(20; "Scale Factor"; Decimal)
        {
            Caption = 'Scale Factor';
            ToolTip = 'Specifies the zoom scale for the diagram display, ranging from 0.1 (10%) to 2.0 (200%).';
            InitValue = 1.0;
            MinValue = 0.1;
            MaxValue = 2.0;
        }
        field(70; "Enable Validation"; Boolean)
        {
            Caption = 'Enable Validation';
            ToolTip = 'Specifies whether to validate Mermaid code before rendering the diagram.';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Initialize with default values for standard diagram display
    /// </summary>
    procedure InitializeDefaults()
    begin
        "Primary Key" := 'DEFAULT';
        "Theme" := "Theme"::Default;
        "Scale Factor" := 1.0;
        "Enable Validation" := true;
    end;

    /// <summary>
    /// Create preset for compact display (reduced size)
    /// </summary>
    procedure InitializeCompact()
    begin
        InitializeDefaults();
        "Scale Factor" := 0.7;
    end;

    /// <summary>
    /// Create preset for full-screen display
    /// </summary>
    procedure InitializeFullScreen()
    begin
        InitializeDefaults();
        "Scale Factor" := 1.2;
    end;
}
