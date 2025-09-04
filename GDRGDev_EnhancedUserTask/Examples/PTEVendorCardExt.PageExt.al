pageextension 50121 "PTE Vendor Card Ext" extends "Vendor Card"
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
