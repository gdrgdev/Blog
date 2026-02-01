page 80100 "GDRG Birthday Management HR"
{
    Caption = 'Birthday Management';
    PageType = List;
    SourceTable = Employee;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Employees)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee number.';
                    Style = Attention;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }

                field(FullName; Rec."First Name" + ' ' + Rec."Last Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the employee full name.';
                    Style = Attention;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }

                field("Birth Date"; Rec."Birth Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee birth date.';
                    Style = Attention;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }

                field("Next Birthday Date"; Rec."GDRG Next Birthday Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the next birthday date.';
                    Style = Attention;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }

                field("Days to Birthday"; Rec."GDRG Days to Birthday")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of days until the next birthday.';
                    Style = Attention;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }

                field("Current Year Messages"; currentYearMessages)
                {
                    ApplicationArea = All;
                    Caption = 'Messages (Current Year)';
                    ToolTip = 'Specifies the number of messages received this year.';
                    Style = Attention;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }

                field("Total Messages"; Rec."GDRG Birthday Messages Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total number of messages received.';
                    Style = Attention;
                    StyleExpr = Rec."GDRG Days to Birthday" = 0;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewAllMessages)
            {
                ApplicationArea = All;
                Caption = 'View All Messages';
                ToolTip = 'View all birthday messages received by this employee from everyone.';
                Image = ViewComments;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    birthdayMessage: Record "GDRG Birthday Message";
                    myMessagesPage: Page "GDRG My Birthday Messages";
                begin
                    birthdayMessage.SetRange("Employee No.", Rec."No.");
                    myMessagesPage.SetTableView(birthdayMessage);
                    myMessagesPage.Run();
                end;
            }

            action(RefreshBirthdays)
            {
                ApplicationArea = All;
                Caption = 'Refresh Birthday Dates';
                ToolTip = 'Recalculate all birthday dates and days to birthday.';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    birthdayMgmt: Codeunit "GDRG Birthday Management";
                    refreshedMsg: Label 'Birthday dates have been refreshed.';
                begin
                    birthdayMgmt.UpdateAllEmployeeBirthdays();
                    CurrPage.Update(false);
                    Message(refreshedMsg);
                end;
            }

            action(ClearCalculatedFields)
            {
                ApplicationArea = All;
                Caption = 'Clear Calculated Fields';
                ToolTip = 'Clear next birthday date and days to birthday for testing purposes.';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    employee: Record Employee;
                    clearedMsg: Label '%1 employee(s) cleared.', Comment = '%1 = Number of employees';
                    count: Integer;
                begin
                    if employee.FindSet(true) then
                        repeat
                            employee."GDRG Next Birthday Date" := 0D;
                            employee."GDRG Days to Birthday" := 0;
                            employee.Modify(false);
                            count += 1;
                        until employee.Next() = 0;

                    Message(clearedMsg, count);
                    CurrPage.Update(false);
                end;
            }
        }

        area(Navigation)
        {
            action(EmployeeCard)
            {
                ApplicationArea = All;
                Caption = 'Employee Card';
                ToolTip = 'View or edit detailed information about the employee.';
                Image = Employee;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Employee Card";
                RunPageLink = "No." = FIELD("No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        birthdayMgmt: Codeunit "GDRG Birthday Management";
    begin
        currentYearMessages := birthdayMgmt.CountMessagesForYear(Rec."No.", birthdayMgmt.GetCurrentYear());
    end;

    trigger OnOpenPage()
    var
        employee: Record Employee;
        birthdayMgmt: Codeunit "GDRG Birthday Management";
    begin
        employee.SetRange("GDRG Days to Birthday", 0);
        employee.SetFilter("Birth Date", '<>%1', 0D);
        if not employee.IsEmpty then
            birthdayMgmt.UpdateAllEmployeeBirthdays();

        Rec.SetFilter("Birth Date", '<>%1', 0D);
        Rec.SetCurrentKey("GDRG Days to Birthday");
    end;

    var
        currentYearMessages: Integer;
}
