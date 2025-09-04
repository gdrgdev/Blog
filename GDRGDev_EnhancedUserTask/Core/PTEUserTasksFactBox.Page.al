page 50101 "PTE User Tasks FactBox"
{
    PageType = ListPart;
    SourceTable = "User Task";
    Caption = 'User Tasks';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(QuickCreate)
            {
                ShowCaption = false;

                field(CreateTask; '+ Create Task')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Style = StandardAccent;
                    ToolTip = 'Specifies to create a new task for the current record.';

                    trigger OnDrillDown()
                    begin
                        CreateTaskForCurrentRecord();
                    end;
                }
            }

            repeater(ExistingTasks)
            {
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the title of the user task.';
                    Width = 15;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"User Task Card", Rec);
                    end;
                }

                field(Description; Rec.GetDescription())
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the user task.';
                    Width = 12;
                }

                field("Assigned To User Name"; Rec."Assigned To User Name")
                {
                    ApplicationArea = All;
                    Caption = 'Assigned To';
                    ToolTip = 'Specifies who the task is assigned to.';
                    Width = 8;
                }

                field("Due DateTime"; Rec."Due DateTime")
                {
                    ApplicationArea = All;
                    Caption = 'Due';
                    ToolTip = 'Specifies when the task is due.';
                    Width = 6;
                }

                field("Percent Complete"; Rec."Percent Complete")
                {
                    ApplicationArea = All;
                    Caption = '%';
                    ToolTip = 'Specifies the completion percentage of the task.';
                    Width = 3;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewAllTasks)
            {
                ApplicationArea = All;
                Caption = 'View All';
                Image = TaskList;
                ToolTip = 'Specifies to view all tasks for this record.';

                trigger OnAction()
                begin
                    ViewAllTasksForRecord();
                end;
            }
        }
    }

    var
        PTEUserTaskRecordMgt: Codeunit "PTE User Task Record Mgt";
        CurrentRecordId: RecordId;

    procedure SetRecordContext(RecordId: RecordId)
    begin
        CurrentRecordId := RecordId;
        UpdateTasksList();
    end;

    local procedure UpdateTasksList()
    begin
        if Format(CurrentRecordId) <> '' then begin
            PTEUserTaskRecordMgt.FindTasksForRecord(CurrentRecordId, Rec);
            CurrPage.Update(false);
        end;
    end;

    local procedure CreateTaskForCurrentRecord()
    var
        TaskID: Integer;
    begin
        if Format(CurrentRecordId) = '' then
            exit;

        TaskID := PTEUserTaskRecordMgt.CreateTaskForRecord(
            CurrentRecordId,
            '',
            '');

        if TaskID <> 0 then
            UpdateTasksList();
    end;

    local procedure ViewAllTasksForRecord()
    var
        UserTask: Record "User Task";
        UserTaskList: Page "User Task List";
    begin
        if Format(CurrentRecordId) = '' then
            exit;

        PTEUserTaskRecordMgt.FindTasksForRecord(CurrentRecordId, UserTask);
        UserTaskList.SetTableView(UserTask);
        UserTaskList.Run();
    end;
}