/// <summary>
/// Page extension for Sales Order with line items visualization
/// Demonstrates Flowchart for order composition
/// </summary>
pageextension 60103 "Mermaid Sales Order Ext" extends "Sales Order"
{
    actions
    {
        addlast(processing)
        {
            group(MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                action(MermaidViewLines)
                {
                    Caption = 'Order Line Items';
                    Image = ItemLines;
                    ToolTip = 'Specifies the flowchart breakdown of sales order line items with quantities and amounts by type.';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MermaidHelpers: Codeunit "Mermaid Example Helpers";
                        MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                        MermaidTheme: Enum "Mermaid Theme";
                        DiagramCode: Text;
                    begin
                        DiagramCode := MermaidHelpers.GenerateOrderLinesDiagram(Rec."No.");
                        if DiagramCode <> '' then
                            MermaidMgt.ShowMermaidDiagram(DiagramCode, MermaidTheme::Forest, 1.0)
                        else
                            Message('No lines found for this order.');
                    end;
                }

                action(MermaidViewSequence)
                {
                    Caption = 'Order Process Flow';
                    Image = Process;
                    ToolTip = 'Specifies the sequence diagram showing the order fulfillment process workflow from placement to payment.';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MermaidHelpers: Codeunit "Mermaid Example Helpers";
                        MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                        DiagramCode: Text;
                    begin
                        DiagramCode := MermaidHelpers.GenerateOrderSequenceDiagram(Rec."No.", Rec.Status);
                        if DiagramCode <> '' then
                            MermaidMgt.ShowMermaidDiagram(DiagramCode)
                        else
                            Message('Unable to generate sequence diagram.');
                    end;
                }
            }
        }

        addlast(Promoted)
        {
            group(Category_MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                actionref(MermaidViewLines_Promoted; MermaidViewLines) { }
                actionref(MermaidViewSequence_Promoted; MermaidViewSequence) { }
            }
        }
    }
}
