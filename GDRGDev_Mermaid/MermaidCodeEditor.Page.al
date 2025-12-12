/// <summary>
/// Mermaid code editor with diagram preview functionality
/// Allows writing Mermaid code and visualizing it in the viewer component
/// </summary>
page 60101 "Mermaid Code Editor"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Mermaid Code Editor';

    layout
    {
        area(Content)
        {
            group(CodeEditor)
            {
                Caption = 'Code Editor';

                field(MermaidCodeField; MermaidCode)
                {
                    Caption = 'Mermaid Code';
                    ToolTip = 'Specifies the Mermaid code to generate the diagram.';
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        if MermaidCode <> '' then
                            HasContent := true
                        else
                            HasContent := false;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewDiagram)
            {
                Caption = 'View Diagram';
                Image = View;
                Enabled = HasContent;
                ToolTip = 'Open viewer with current Mermaid code.';

                trigger OnAction()
                var
                    MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                begin
                    if MermaidCode = '' then begin
                        Message('Please enter Mermaid code before viewing the diagram.');
                        exit;
                    end;

                    // Use the new robust API - simple method
                    if not MermaidMgt.ShowMermaidDiagram(MermaidCode) then
                        Message('Failed to display the diagram. Please check the code.');
                end;
            }

            action(ViewCompact)
            {
                Caption = 'View Forest Compact';
                Image = Compress;
                Enabled = HasContent;
                ToolTip = 'Open forest theme compact viewer (green theme, 60% scale).';

                trigger OnAction()
                var
                    MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                    MermaidTheme: Enum "Mermaid Theme";
                begin
                    if MermaidCode = '' then begin
                        Message('Please enter Mermaid code before viewing the diagram.');
                        exit;
                    end;

                    // Use forest theme with compact scale (60%)
                    if not MermaidMgt.ShowMermaidDiagram(MermaidCode, MermaidTheme::Forest, 0.6) then
                        Message('Failed to display the compact forest diagram.');
                end;
            }

            action(ViewDarkTheme)
            {
                Caption = 'View Dark Large';
                Image = SetupColumns;
                Enabled = HasContent;
                ToolTip = 'Open viewer with dark theme and large scale (120%).';

                trigger OnAction()
                var
                    MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                    MermaidTheme: Enum "Mermaid Theme";
                begin
                    if MermaidCode = '' then begin
                        Message('Please enter Mermaid code before viewing the diagram.');
                        exit;
                    end;

                    // Use dark theme with large scale (120%)
                    if not MermaidMgt.ShowMermaidDiagram(MermaidCode, MermaidTheme::Dark, 1.2) then
                        Message('Failed to display the large dark diagram.');
                end;
            }

            action(ViewNeutralMedium)
            {
                Caption = 'View Neutral Medium';
                Image = TestFile;
                Enabled = HasContent;
                ToolTip = 'Open viewer with neutral theme and medium scale (90%).';

                trigger OnAction()
                var
                    MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                    MermaidTheme: Enum "Mermaid Theme";
                begin
                    if MermaidCode = '' then begin
                        Message('Please enter Mermaid code before viewing the diagram.');
                        exit;
                    end;

                    // Use neutral theme with medium scale (90%)
                    if not MermaidMgt.ShowMermaidDiagram(MermaidCode, MermaidTheme::Neutral, 0.9) then
                        Message('Failed to display the neutral medium diagram.');
                end;
            }

            action(ClearCode)
            {
                Caption = 'Clear';
                Image = ClearLog;
                ToolTip = 'Clear current Mermaid code.';

                trigger OnAction()
                begin
                    if Confirm('Do you want to clear the current code?') then begin
                        Clear(MermaidCode);
                        HasContent := false;
                        CurrPage.Update();
                    end;
                end;
            }

            group(Examples)
            {
                Caption = 'Examples';

                action(ExampleFlowchart)
                {
                    Caption = 'Flowchart';
                    Image = Flow;
                    ToolTip = 'Load a flowchart example showing a simple process flow.';
                    trigger OnAction()
                    begin
                        MermaidCode := GetFlowchartExample();
                        HasContent := true;
                        CurrPage.Update();
                    end;
                }

                action(ExampleSequence)
                {
                    Caption = 'Sequence Diagram';
                    Image = Interaction;
                    ToolTip = 'Load a sequence diagram example showing message flow between participants.';

                    trigger OnAction()
                    begin
                        MermaidCode := GetSequenceExample();
                        HasContent := true;
                        CurrPage.Update();
                    end;
                }

                action(ExampleClass)
                {
                    Caption = 'Class Diagram';
                    Image = Hierarchy;
                    ToolTip = 'Load a class diagram example showing object-oriented design.';

                    trigger OnAction()
                    begin
                        MermaidCode := GetClassExample();
                        HasContent := true;
                        CurrPage.Update();
                    end;
                }

                action(ExampleER)
                {
                    Caption = 'ER Diagram';
                    Image = DataEntry;
                    ToolTip = 'Load an entity-relationship diagram example.';

                    trigger OnAction()
                    begin
                        MermaidCode := GetERExample();
                        HasContent := true;
                        CurrPage.Update();
                    end;
                }

                action(ExampleGantt)
                {
                    Caption = 'Gantt Chart';
                    Image = Timeline;
                    ToolTip = 'Load a Gantt chart example showing project timeline.';

                    trigger OnAction()
                    begin
                        MermaidCode := GetGanttExample();
                        HasContent := true;
                        CurrPage.Update();
                    end;
                }

                action(ExampleState)
                {
                    Caption = 'State Diagram';
                    Image = Status;
                    ToolTip = 'Load a state diagram example showing state transitions.';

                    trigger OnAction()
                    begin
                        MermaidCode := GetStateExample();
                        HasContent := true;
                        CurrPage.Update();
                    end;
                }
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ViewDiagram_Promoted; ViewDiagram) { }
                actionref(ClearCode_Promoted; ClearCode) { }
            }

            group(Category_Examples)
            {
                Caption = 'Examples';

                actionref(ExampleFlowchart_Promoted; ExampleFlowchart) { }
                actionref(ExampleSequence_Promoted; ExampleSequence) { }
                actionref(ExampleClass_Promoted; ExampleClass) { }
                actionref(ExampleER_Promoted; ExampleER) { }
                actionref(ExampleGantt_Promoted; ExampleGantt) { }
                actionref(ExampleState_Promoted; ExampleState) { }
            }
        }
    }

    var
        MermaidCode: Text;
        HasContent: Boolean;

    trigger OnOpenPage()
    begin
        HasContent := false;
    end;

    local procedure GetFlowchartExample(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit('flowchart TD' + TypeHelper.LFSeparator() +
             '    Start([Start Process]) --> Input[/Enter Data/]' + TypeHelper.LFSeparator() +
             '    Input --> Validate{Is Valid?}' + TypeHelper.LFSeparator() +
             '    Validate -->|Yes| Process[Process Data]' + TypeHelper.LFSeparator() +
             '    Validate -->|No| Error[Show Error]' + TypeHelper.LFSeparator() +
             '    Error --> Input' + TypeHelper.LFSeparator() +
             '    Process --> Save[(Save to Database)]' + TypeHelper.LFSeparator() +
             '    Save --> End([End])');
    end;

    local procedure GetSequenceExample(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit('sequenceDiagram' + TypeHelper.LFSeparator() +
             '    participant User' + TypeHelper.LFSeparator() +
             '    participant System' + TypeHelper.LFSeparator() +
             '    participant Database' + TypeHelper.LFSeparator() +
             '    User->>System: Request Data' + TypeHelper.LFSeparator() +
             '    activate System' + TypeHelper.LFSeparator() +
             '    System->>Database: Query Records' + TypeHelper.LFSeparator() +
             '    activate Database' + TypeHelper.LFSeparator() +
             '    Database-->>System: Return Results' + TypeHelper.LFSeparator() +
             '    deactivate Database' + TypeHelper.LFSeparator() +
             '    System-->>User: Display Data' + TypeHelper.LFSeparator() +
             '    deactivate System');
    end;

    local procedure GetClassExample(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit('classDiagram' + TypeHelper.LFSeparator() +
             '    class Customer {' + TypeHelper.LFSeparator() +
             '        +String No' + TypeHelper.LFSeparator() +
             '        +String Name' + TypeHelper.LFSeparator() +
             '        +String Email' + TypeHelper.LFSeparator() +
             '        +PlaceOrder()' + TypeHelper.LFSeparator() +
             '        +GetBalance() Decimal' + TypeHelper.LFSeparator() +
             '    }' + TypeHelper.LFSeparator() +
             '    class SalesOrder {' + TypeHelper.LFSeparator() +
             '        +String OrderNo' + TypeHelper.LFSeparator() +
             '        +Date OrderDate' + TypeHelper.LFSeparator() +
             '        +Decimal Amount' + TypeHelper.LFSeparator() +
             '        +Post()' + TypeHelper.LFSeparator() +
             '    }' + TypeHelper.LFSeparator() +
             '    class Item {' + TypeHelper.LFSeparator() +
             '        +String No' + TypeHelper.LFSeparator() +
             '        +String Description' + TypeHelper.LFSeparator() +
             '        +Decimal Price' + TypeHelper.LFSeparator() +
             '    }' + TypeHelper.LFSeparator() +
             '    Customer "1" --> "*" SalesOrder : places' + TypeHelper.LFSeparator() +
             '    SalesOrder "1" --> "*" Item : contains');
    end;

    local procedure GetERExample(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit('erDiagram' + TypeHelper.LFSeparator() +
             '    CUSTOMER ||--o{ SALES-ORDER : places' + TypeHelper.LFSeparator() +
             '    SALES-ORDER ||--|{ ORDER-LINE : contains' + TypeHelper.LFSeparator() +
             '    ORDER-LINE }o--|| ITEM : references' + TypeHelper.LFSeparator() +
             '    CUSTOMER {' + TypeHelper.LFSeparator() +
             '        string CustomerNo PK' + TypeHelper.LFSeparator() +
             '        string Name' + TypeHelper.LFSeparator() +
             '        string Email' + TypeHelper.LFSeparator() +
             '        decimal Balance' + TypeHelper.LFSeparator() +
             '    }' + TypeHelper.LFSeparator() +
             '    SALES-ORDER {' + TypeHelper.LFSeparator() +
             '        string OrderNo PK' + TypeHelper.LFSeparator() +
             '        string CustomerNo FK' + TypeHelper.LFSeparator() +
             '        date OrderDate' + TypeHelper.LFSeparator() +
             '        decimal TotalAmount' + TypeHelper.LFSeparator() +
             '    }' + TypeHelper.LFSeparator() +
             '    ORDER-LINE {' + TypeHelper.LFSeparator() +
             '        int LineNo PK' + TypeHelper.LFSeparator() +
             '        string OrderNo FK' + TypeHelper.LFSeparator() +
             '        string ItemNo FK' + TypeHelper.LFSeparator() +
             '        decimal Quantity' + TypeHelper.LFSeparator() +
             '    }' + TypeHelper.LFSeparator() +
             '    ITEM {' + TypeHelper.LFSeparator() +
             '        string ItemNo PK' + TypeHelper.LFSeparator() +
             '        string Description' + TypeHelper.LFSeparator() +
             '        decimal UnitPrice' + TypeHelper.LFSeparator() +
             '    }');
    end;

    local procedure GetGanttExample(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit('gantt' + TypeHelper.LFSeparator() +
             '    title Project Implementation Timeline' + TypeHelper.LFSeparator() +
             '    dateFormat YYYY-MM-DD' + TypeHelper.LFSeparator() +
             '    section Planning' + TypeHelper.LFSeparator() +
             '        Requirements Analysis    :a1, 2024-01-01, 14d' + TypeHelper.LFSeparator() +
             '        Design Phase            :a2, after a1, 21d' + TypeHelper.LFSeparator() +
             '    section Development' + TypeHelper.LFSeparator() +
             '        Backend Development     :b1, after a2, 30d' + TypeHelper.LFSeparator() +
             '        Frontend Development    :b2, after a2, 28d' + TypeHelper.LFSeparator() +
             '        Integration            :b3, after b1, 7d' + TypeHelper.LFSeparator() +
             '    section Testing' + TypeHelper.LFSeparator() +
             '        Unit Testing           :c1, after b3, 10d' + TypeHelper.LFSeparator() +
             '        UAT                    :c2, after c1, 14d' + TypeHelper.LFSeparator() +
             '    section Deployment' + TypeHelper.LFSeparator() +
             '        Production Deploy      :milestone, after c2, 1d');
    end;

    local procedure GetStateExample(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit('stateDiagram-v2' + TypeHelper.LFSeparator() +
             '    [*] --> Draft' + TypeHelper.LFSeparator() +
             '    Draft --> PendingApproval: Submit' + TypeHelper.LFSeparator() +
             '    PendingApproval --> Approved: Approve' + TypeHelper.LFSeparator() +
             '    PendingApproval --> Rejected: Reject' + TypeHelper.LFSeparator() +
             '    Rejected --> Draft: Revise' + TypeHelper.LFSeparator() +
             '    Approved --> Posted: Post' + TypeHelper.LFSeparator() +
             '    Posted --> [*]' + TypeHelper.LFSeparator() +
             '    ' + TypeHelper.LFSeparator() +
             '    Draft: Document in Draft' + TypeHelper.LFSeparator() +
             '    PendingApproval: Waiting for Approval' + TypeHelper.LFSeparator() +
             '    Approved: Approved by Manager' + TypeHelper.LFSeparator() +
             '    Posted: Posted to GL');
    end;
}
