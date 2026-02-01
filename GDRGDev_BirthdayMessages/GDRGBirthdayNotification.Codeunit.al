codeunit 80101 "GDRG Birthday Notification"
{
    trigger OnRun()
    begin
        ProcessDailyBirthdays();
    end;

    procedure ProcessDailyBirthdays()
    var
        birthdayMgmt: Codeunit "GDRG Birthday Management";
    begin
        birthdayMgmt.UpdateAllEmployeeBirthdays();
        CreateCompanyMessages();
    end;

    local procedure CreateCompanyMessages()
    var
        employee: Record Employee;
        birthdayMessage: Record "GDRG Birthday Message";
        birthdayMgmt: Codeunit "GDRG Birthday Management";
        currentYear: Integer;
        companyMessageTxt: Label 'Happy Birthday %1!\\The %2 team wishes you a wonderful day full of joy and new achievements. May you have many more!', Comment = '%1 = Employee Name, %2 = Company Name';
    begin
        currentYear := birthdayMgmt.GetCurrentYear();

        birthdayMgmt.GetUpcomingBirthdays(0, employee);
        if employee.FindSet() then
            repeat
                if not CompanyMessageExists(employee."No.", currentYear) then begin
                    Clear(birthdayMessage);
                    birthdayMessage.Init();
                    birthdayMessage."Employee No." := employee."No.";
                    birthdayMessage."Birthday Year" := currentYear;
                    birthdayMessage."User ID" := 'SYSTEM';
                    birthdayMessage."Message Type" := birthdayMessage."Message Type"::Company;
                    birthdayMessage.Insert(true);

                    birthdayMessage.SetMessageText(
            StrSubstNo(companyMessageTxt, employee."First Name" + ' ' + employee."Last Name", CompanyName));
                    birthdayMessage.Modify(false);
                end;
            until employee.Next() = 0;
    end;

    local procedure CompanyMessageExists(employeeNo: Code[20]; year: Integer): Boolean
    var
        birthdayMessage: Record "GDRG Birthday Message";
    begin
        birthdayMessage.SetRange("Employee No.", employeeNo);
        birthdayMessage.SetRange("Birthday Year", year);
        birthdayMessage.SetRange("Message Type", birthdayMessage."Message Type"::Company);
        exit(not birthdayMessage.IsEmpty);
    end;
}
