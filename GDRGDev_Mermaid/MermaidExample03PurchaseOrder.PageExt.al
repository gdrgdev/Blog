/// <summary>
/// Page extension for Purchase Order with status workflow visualization
/// Demonstrates State Diagram for order lifecycle
/// </summary>
pageextension 60102 "Mermaid Purchase Order Ext" extends "Purchase Order"
{
    actions
    {
        addlast(processing)
        {
            group(MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                action(MermaidViewStatus)
                {
                    Caption = 'Order Status Flow';
                    Image = Workflow;
                    ToolTip = 'Specifies the state diagram showing the complete purchase order lifecycle and status transitions.';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MermaidHelpers: Codeunit "Mermaid Example Helpers";
                        MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                        MermaidTheme: Enum "Mermaid Theme";
                        DiagramCode: Text;
                    begin
                        DiagramCode := MermaidHelpers.GeneratePurchaseStatusDiagram(Rec."No.", Rec.Status, Rec."Buy-from Vendor Name");
                        if DiagramCode <> '' then
                            MermaidMgt.ShowMermaidDiagram(DiagramCode, MermaidTheme::Dark, 1.0)
                        else
                            Message('Unable to generate status diagram.');
                    end;
                }
            }
        }

        addlast(Promoted)
        {
            group(Category_MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                actionref(MermaidViewStatus_Promoted; MermaidViewStatus) { }
            }
        }
    }
}
