pageextension 50122 "PTE Item Card Ext" extends "Item Card"
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
