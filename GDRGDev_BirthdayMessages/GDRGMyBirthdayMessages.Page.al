page 80102 "GDRG My Birthday Messages"
{
    Caption = 'My Birthday Messages';
    PageType = List;
    SourceTable = "GDRG Birthday Message";
    ApplicationArea = All;
    UsageCategory = Tasks;
    Editable = false;
    SourceTableView = SORTING("Birthday Year") ORDER(Descending);

    layout
    {
        area(Content)
        {
            repeater(Messages)
            {
                field("Birthday Year"; Rec."Birthday Year")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the birthday year.';
                    Style = Strong;
                    StyleExpr = isCurrentYear;
                }

                field("Message Type"; Rec."Message Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the message is from the company or a colleague.';
                    Style = Favorable;
                    StyleExpr = Rec."Message Type" = Rec."Message Type"::Company;
                }

                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee who received the birthday message.';
                }

                field("Employee Name"; employeeName)
                {
                    ApplicationArea = All;
                    Caption = 'Employee Name';
                    ToolTip = 'Specifies the name of the employee who received the birthday message.';
                }

                field("Sent By"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'Sent By';
                    ToolTip = 'Specifies who sent the birthday message.';
                }

                field("Message Date"; Rec."Message Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the message was created.';
                }

                field(MessageText; messageText)
                {
                    ApplicationArea = All;
                    Caption = 'Message';
                    ToolTip = 'Specifies the message text.';
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FilterCurrentYear)
            {
                ApplicationArea = All;
                Caption = 'Current Year Only';
                ToolTip = 'Show only messages from the current year.';
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    birthdayMgmt: Codeunit "GDRG Birthday Management";
                begin
                    Rec.SetRange("Birthday Year", birthdayMgmt.GetCurrentYear());
                    CurrPage.Update(false);
                end;
            }

            action(ShowAll)
            {
                ApplicationArea = All;
                Caption = 'Show All Years';
                ToolTip = 'Show messages from all years.';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.SetRange("Birthday Year");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        employee: Record Employee;
        birthdayMgmt: Codeunit "GDRG Birthday Management";
    begin
        messageText := Rec.GetMessageText();
        isCurrentYear := Rec."Birthday Year" = birthdayMgmt.GetCurrentYear();

        if employee.Get(Rec."Employee No.") then
            employeeName := employee."First Name" + ' ' + employee."Last Name"
        else
            employeeName := '';
    end;

    trigger OnOpenPage()
    var
        employee: Record Employee;
        birthdayMgmt: Codeunit "GDRG Birthday Management";
        notLinkedErr: Label 'Your user is not linked to an employee record. Please contact your administrator to configure User Setup.';
    begin
        if Rec.GetFilters = '' then begin
            if not birthdayMgmt.GetEmployeeFromUserID(UserId, employee) then
                Error(notLinkedErr);

            Rec.SetRange("Employee No.", employee."No.");
        end;
    end;

    procedure SetPageCaption(newCaption: Text)
    begin
        CurrPage.Caption(newCaption);
    end;

    var
        messageText: Text;
        isCurrentYear: Boolean;
        employeeName: Text;
}
