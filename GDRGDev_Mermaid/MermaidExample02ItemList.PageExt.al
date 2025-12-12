/// <summary>
/// Page extension for Item List with BOM visualization
/// Demonstrates Class Diagram for product structure
/// </summary>
pageextension 60101 "Mermaid Item List Ext" extends "Item List"
{
    actions
    {
        addlast(processing)
        {
            group(MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                action(MermaidViewBOM)
                {
                    Caption = 'BOM Structure';
                    Image = BOMLevel;
                    ToolTip = 'Specifies the class diagram visualization of the item Bill of Materials structure with components and quantities.';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MermaidHelpers: Codeunit "Mermaid Example Helpers";
                        MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                        MermaidTheme: Enum "Mermaid Theme";
                        DiagramCode: Text;
                    begin
                        DiagramCode := MermaidHelpers.GenerateItemBOMDiagram(Rec."No.", Rec.Description, Rec.Type, Rec."Base Unit of Measure");
                        if DiagramCode <> '' then
                            MermaidMgt.ShowMermaidDiagram(DiagramCode, MermaidTheme::Neutral, 1.0)
                        else
                            Message('No BOM structure found for this item.');
                    end;
                }
            }
        }

        addlast(Promoted)
        {
            group(Category_MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                actionref(MermaidViewBOM_Promoted; MermaidViewBOM) { }
            }
        }
    }
}
