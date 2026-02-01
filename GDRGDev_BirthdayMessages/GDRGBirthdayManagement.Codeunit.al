codeunit 80100 "GDRG Birthday Management"
{
    procedure GetCurrentYear(): Integer
    begin
        exit(Date2DMY(Today, 3));
    end;

    procedure CalculateNextBirthday(birthDate: Date): Date
    var
        nextBirthday: Date;
        currentYear: Integer;
    begin
        if birthDate = 0D then
            exit(0D);

        currentYear := GetCurrentYear();
        nextBirthday := DMY2Date(Date2DMY(birthDate, 1), Date2DMY(birthDate, 2), currentYear);

        if nextBirthday < Today then
            nextBirthday := DMY2Date(Date2DMY(birthDate, 1), Date2DMY(birthDate, 2), currentYear + 1);

        exit(nextBirthday);
    end;

    procedure CalculateDaysToBirthday(birthDate: Date): Integer
    var
        nextBirthday: Date;
    begin
        nextBirthday := CalculateNextBirthday(birthDate);
        if nextBirthday = 0D then
            exit(999);

        exit(nextBirthday - Today);
    end;

    procedure UpdateAllEmployeeBirthdays()
    var
        employee: Record Employee;
    begin
        if employee.FindSet() then
            repeat
                employee."GDRG Next Birthday Date" := CalculateNextBirthday(employee."Birth Date");
                employee."GDRG Days to Birthday" := CalculateDaysToBirthday(employee."Birth Date");
                employee.Modify(false);
            until employee.Next() = 0;
    end;

    procedure IsBirthdayToday(birthDate: Date): Boolean
    begin
        if birthDate = 0D then
            exit(false);

        exit((Date2DMY(birthDate, 1) = Date2DMY(Today, 1)) and
             (Date2DMY(birthDate, 2) = Date2DMY(Today, 2)));
    end;

    procedure GetEmployeeFromUserID(userID: Text; var employee: Record Employee): Boolean
    var
        userSetup: Record "User Setup";
    begin
        if userID = '' then
            exit(false);

        if not userSetup.Get(CopyStr(userID, 1, 50)) then
            exit(false);

        if userSetup."GDRG Employee No." = '' then
            exit(false);

        exit(employee.Get(userSetup."GDRG Employee No."));
    end;

    procedure HasAlreadyGreeted(employeeNo: Code[20]; birthdayYear: Integer; userID: Text): Boolean
    var
        birthdayMessage: Record "GDRG Birthday Message";
    begin
        birthdayMessage.SetRange("Employee No.", employeeNo);
        birthdayMessage.SetRange("Birthday Year", birthdayYear);
        birthdayMessage.SetRange("User ID", CopyStr(userID, 1, 50));
        exit(not birthdayMessage.IsEmpty);
    end;

    procedure CountMessagesForYear(employeeNo: Code[20]; year: Integer): Integer
    var
        birthdayMessage: Record "GDRG Birthday Message";
    begin
        birthdayMessage.SetRange("Employee No.", employeeNo);
        birthdayMessage.SetRange("Birthday Year", year);
        exit(birthdayMessage.Count);
    end;

    procedure CreateColleagueMessage(employeeNo: Code[20]; messageText: Text)
    var
        birthdayMessage: Record "GDRG Birthday Message";
        employee: Record Employee;
        currentYear: Integer;
        cannotCreateMessageErr: Label 'Cannot create birthday message. User is not linked to an employee.';
    begin
        if not GetEmployeeFromUserID(UserId, employee) then
            Error(cannotCreateMessageErr);

        currentYear := GetCurrentYear();

        Clear(birthdayMessage);
        birthdayMessage.Init();
        birthdayMessage."Employee No." := employeeNo;
        birthdayMessage."Birthday Year" := currentYear;
        birthdayMessage."User ID" := CopyStr(UserId, 1, 50);
        birthdayMessage."Message Type" := birthdayMessage."Message Type"::Colleague;
        birthdayMessage.Insert(true);

        birthdayMessage.SetMessageText(messageText);
        birthdayMessage.Modify(false);
    end;

    procedure GetUpcomingBirthdays(daysAhead: Integer; var employee: Record Employee)
    begin
        employee.SetFilter("Birth Date", '<>%1', 0D);
        employee.SetRange("GDRG Days to Birthday", 0, daysAhead);
        if employee.FindSet() then;
    end;
}
