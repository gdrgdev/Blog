/// <summary>
/// Page extension to demonstrate Mermaid Framework integration with Jobs
/// Adds a "View Project Timeline" action to the standard Job List
/// Shows project tasks in a Gantt chart format
/// </summary>
pageextension 60105 "Mermaid Job List Ext" extends "Job List"
{
    actions
    {
        addlast(processing)
        {
            group(MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                action(MermaidViewTimeline)
                {
                    Caption = 'Project Timeline';
                    Image = Timeline;
                    ToolTip = 'Visualize project tasks in a Gantt chart timeline showing planning and execution phases.';
                    ApplicationArea = Jobs;

                    trigger OnAction()
                    var
                        MermaidHelpers: Codeunit "Mermaid Example Helpers";
                        MermaidMgt: Codeunit "Mermaid Visualization Mgt";
                        MermaidTheme: Enum "Mermaid Theme";
                        DiagramCode: Text;
                    begin
                        DiagramCode := MermaidHelpers.GenerateJobTimelineDiagram(Rec."No.", Rec.Description);
                        if DiagramCode <> '' then
                            MermaidMgt.ShowMermaidDiagram(DiagramCode, MermaidTheme::Default, 1.0)
                        else
                            Message('Unable to generate timeline for this project.');
                    end;
                }
            }
        }

        addlast(Promoted)
        {
            group(Category_MermaidDiagrams)
            {
                Caption = 'Mermaid Diagrams';

                actionref(MermaidViewTimeline_Promoted; MermaidViewTimeline) { }
            }
        }
    }
}
