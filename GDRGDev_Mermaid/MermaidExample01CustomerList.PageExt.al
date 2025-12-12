/// <summary>
/// Page extension to demonstrate Mermaid Framework integration
/// Adds a "View Customer Diagram" action to the standard Customer List
/// This is a practical example of how to use the Mermaid Visualization Framework
/// </summary>
pageextension 60100 "Mermaid Customer List Ext" extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            group(MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                action(MermaidViewFlowchart)
                {
                    Caption = 'Sales Flow Diagram';
                    Image = Relationship;
                    ToolTip = 'Visualize customer sales process flow with metrics.';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MermaidHelpers: Codeunit "Mermaid Example Helpers";
                        MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                        MermaidTheme: Enum "Mermaid Theme";
                        DiagramCode: Text;
                    begin
                        DiagramCode := MermaidHelpers.GenerateCustomerFlowDiagram(Rec."No.", Rec.Name, Rec.Balance);
                        if DiagramCode <> '' then
                            MermaidMgt.ShowMermaidDiagram(DiagramCode, MermaidTheme::Forest, 1.0)
                        else
                            Message('Unable to generate diagram for this customer.');
                    end;
                }

            }
        }

        addlast(Promoted)
        {
            group(Category_MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                actionref(MermaidViewFlowchart_Promoted; MermaidViewFlowchart) { }
            }
        }
    }
}
