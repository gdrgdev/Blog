pageextension 50106 "PTE User Task Card Ext" extends "User Task Card"
{
    layout
    {
        addlast(content)
        {
            group("Related Record")
            {
                Caption = 'Related Record';

                field("Related Table Name"; Rec."Related Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Table';
                    Editable = false;
                }

                field("Related Record Description"; Rec."Related Record Description")
                {
                    ApplicationArea = All;
                    Caption = 'Record';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(SelectRelatedRecord)
            {
                ApplicationArea = All;
                Caption = 'Select Related Record';
                Image = SelectLineToApply;
                ToolTip = 'Specifies to select a record to relate this task to.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PTEUserTaskRecordMgt: Codeunit "PTE User Task Record Mgt";
                    TableSelector: Page "PTE Table Selector for Task";
                    SelectedRecordId: RecordId;
                begin
                    if TableSelector.RunModal() = Action::OK then begin
                        SelectedRecordId := TableSelector.GetSelectedRecordId();
                        if Format(SelectedRecordId) <> '' then begin
                            Rec."Related Record ID" := SelectedRecordId;
                            Rec."Related Table No." := SelectedRecordId.TableNo();
                            Rec."Related Record Description" := PTEUserTaskRecordMgt.GetRecordDescription(SelectedRecordId);
                            Rec."Related Table Name" := PTEUserTaskRecordMgt.GetTableName(SelectedRecordId.TableNo());
                            Rec.Modify(true);
                            CurrPage.Update();
                        end;
                    end;
                end;
            }

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

            action(RemoveRelatedRecord)
            {
                ApplicationArea = All;
                Caption = 'Remove Related Record';
                Image = RemoveLine;
                ToolTip = 'Specifies to remove the relationship to the selected record.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ConfirmManagement: Codeunit "Confirm Management";
                    BlankRecordId: RecordId;
                begin
                    if Rec."Related Table No." <> 0 then
                        if ConfirmManagement.GetResponseOrDefault('Do you want to remove the relationship to the selected record?', false) then begin
                            Rec."Related Record ID" := BlankRecordId;
                            Rec."Related Table No." := 0;
                            Rec."Related Record Description" := '';
                            Rec."Related Table Name" := '';
                            Rec.Modify(true);
                            CurrPage.Update();
                        end;
                end;
            }
        }
    }
}