pageextension 50105 "PTE User Task List Ext" extends "User Task List"
{
    layout
    {
        addafter(Title)
        {
            field("Related Record Description"; Rec."Related Record Description")
            {
                ApplicationArea = All;
                Caption = 'Related To';
                Editable = false;
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(NavigateToRelatedRecord)
            {
                ApplicationArea = All;
                Caption = 'Go to Related Record';
                Image = Navigate;
                ToolTip = 'Specifies to navigate to the record this task is related to.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PTEUserTaskRecordMgt: Codeunit "PTE User Task Record Mgt";
                begin
                    if Rec."Related Table No." <> 0 then
                        PTEUserTaskRecordMgt.NavigateToRecord(Rec."Related Record ID");
                end;
            }
        }
    }
}
