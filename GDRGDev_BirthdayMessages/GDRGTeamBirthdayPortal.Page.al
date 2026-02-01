page 80101 "GDRG Team Birthday Portal"
{
    Caption = 'Team Birthdays';
    PageType = List;
    SourceTable = Employee;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Birthdays)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee number.';
                    Visible = false;
                }

                field(FullName; Rec."First Name" + ' ' + Rec."Last Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the employee full name.';
                    Style = Strong;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }

                field("Birth Date"; Rec."Birth Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee birth date.';
                }

                field("Next Birthday Date"; Rec."GDRG Next Birthday Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the next birthday date.';
                }

                field("Days to Birthday"; Rec."GDRG Days to Birthday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of days until the next birthday.';
                    Style = Attention;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }

                field("Already Greeted"; alreadyGreeted)
                {
                    ApplicationArea = All;
                    Caption = 'Already Greeted';
                    ToolTip = 'Specifies if you have already greeted this employee.';
                    Style = Favorable;
                    StyleExpr = alreadyGreeted;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LeaveMessage)
            {
                ApplicationArea = All;
                Caption = 'Leave Message';
                ToolTip = 'Write a birthday message for this employee.';
                Image = Comment;
                Enabled = (Rec."No." <> '') and (not alreadyGreeted);
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    currentEmployee: Record Employee;
                    birthdayMgmt: Codeunit "GDRG Birthday Management";
                    messageDialog: Page "GDRG Birthday Message Dialog";
                    messageText: Text;
                    messageSentMsg: Label 'Your birthday message has been saved.';
                    alreadyGreetedErr: Label 'You have already sent a birthday message to this employee this year.';
                    cannotGreetSelfErr: Label 'You cannot send a birthday message to yourself.';
                begin
                    if birthdayMgmt.GetEmployeeFromUserID(UserId, currentEmployee) then
                        if currentEmployee."No." = Rec."No." then
                            Error(cannotGreetSelfErr);

                    if birthdayMgmt.HasAlreadyGreeted(Rec."No.", birthdayMgmt.GetCurrentYear(), UserId) then
                        Error(alreadyGreetedErr);

                    messageDialog.SetEmployeeName(Rec."First Name" + ' ' + Rec."Last Name");
                    if messageDialog.RunModal() = Action::OK then begin
                        messageText := messageDialog.GetMessage();
                        if messageText <> '' then begin
                            birthdayMgmt.CreateColleagueMessage(Rec."No.", messageText);
                            alreadyGreeted := true;
                            Message(messageSentMsg);
                            CurrPage.Update(false);
                        end;
                    end;
                end;
            }

            action(ViewMyMessages)
            {
                ApplicationArea = All;
                Caption = 'My Message Sent To';
                ToolTip = 'View the birthday messages you sent to this employee.';
                Image = ViewComments;
                Enabled = Rec."No." <> '';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    birthdayMessage: Record "GDRG Birthday Message";
                    myMessagesPage: Page "GDRG My Birthday Messages";
                    pageCaption: Text;
                    sentToCaptionLbl: Label 'Messages Sent to %1', Comment = '%1 = Employee Name';
                begin
                    birthdayMessage.SetRange("Employee No.", Rec."No.");
                    birthdayMessage.SetRange("User ID", CopyStr(UserId, 1, 50));
                    myMessagesPage.SetTableView(birthdayMessage);

                    pageCaption := StrSubstNo(sentToCaptionLbl, Rec."First Name" + ' ' + Rec."Last Name");
                    myMessagesPage.SetPageCaption(pageCaption);

                    myMessagesPage.Run();
                end;
            }

            action(AllMySentMessages)
            {
                ApplicationArea = All;
                Caption = 'All My Sent Messages';
                ToolTip = 'View all birthday messages you have sent to all employees.';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    birthdayMessage: Record "GDRG Birthday Message";
                    myMessagesPage: Page "GDRG My Birthday Messages";
                    pageCaption: Text;
                    allSentCaptionLbl: Label 'All Messages Sent By Me';
                begin
                    birthdayMessage.SetRange("User ID", CopyStr(UserId, 1, 50));
                    birthdayMessage.SetRange("Message Type", birthdayMessage."Message Type"::Colleague);
                    myMessagesPage.SetTableView(birthdayMessage);

                    pageCaption := allSentCaptionLbl;
                    myMessagesPage.SetPageCaption(pageCaption);

                    myMessagesPage.Run();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        birthdayMgmt: Codeunit "GDRG Birthday Management";
    begin
        alreadyGreeted := birthdayMgmt.HasAlreadyGreeted(Rec."No.", birthdayMgmt.GetCurrentYear(), UserId);
    end;

    trigger OnOpenPage()
    var
        employee: Record Employee;
        birthdayMgmt: Codeunit "GDRG Birthday Management";
        notLinkedWarningMsg: Label 'Your user is not linked to an employee record in User Setup. You will not be able to send birthday messages.';
    begin
        if not birthdayMgmt.GetEmployeeFromUserID(UserId, employee) then
            Message(notLinkedWarningMsg);

        Rec.SetFilter("Birth Date", '<>%1', 0D);
        Rec.SetFilter("GDRG Days to Birthday", '0..7');
        Rec.SetCurrentKey("GDRG Days to Birthday");
    end;

    var
        alreadyGreeted: Boolean;
}
