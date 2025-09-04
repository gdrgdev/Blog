pageextension 50123 "PTE Sales Order Ext" extends "Sales Order"
{
    layout
    {
        addlast(factboxes)
        {
            part(UserTasksFactBox; "PTE User Tasks FactBox")
            {
                ApplicationArea = All;
                Caption = 'User Tasks';
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        UpdateUserTasksFactBox();
    end;

    local procedure UpdateUserTasksFactBox()
    begin
        CurrPage.UserTasksFactBox.Page.SetRecordContext(Rec.RecordId());
    end;
}
