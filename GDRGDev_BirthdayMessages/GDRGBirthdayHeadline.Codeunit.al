codeunit 80102 "GDRG Birthday Headline"
{
    procedure GetBirthdayHeadline(): Text
    var
        employee: Record Employee;
        birthdayMgmt: Codeunit "GDRG Birthday Management";
        messageCount: Integer;
        currentYear: Integer;
    begin
        if not birthdayMgmt.GetEmployeeFromUserID(UserId, employee) then
            exit(GetUpcomingBirthdaysHeadline());

        if birthdayMgmt.IsBirthdayToday(employee."Birth Date") then begin
            currentYear := birthdayMgmt.GetCurrentYear();
            messageCount := birthdayMgmt.CountMessagesForYear(employee."No.", currentYear);
            exit(GetMyBirthdayHeadline(employee."First Name", messageCount));
        end;

        exit(GetUpcomingBirthdaysHeadline());
    end;

    local procedure GetMyBirthdayHeadline(firstName: Text[30]; messageCount: Integer): Text
    var
        myBirthdayTxt: Label '🎉 HAPPY BIRTHDAY %1! You have %2 messages waiting for you', Comment = '%1 = First Name, %2 = Message Count';
        myBirthdayNoMsgTxt: Label '🎉 HAPPY BIRTHDAY %1! Enjoy your special day', Comment = '%1 = First Name';
    begin
        if messageCount > 0 then
            exit(StrSubstNo(myBirthdayTxt, firstName, messageCount));

        exit(StrSubstNo(myBirthdayNoMsgTxt, firstName));
    end;

    local procedure GetUpcomingBirthdaysHeadline(): Text
    var
        employee: Record Employee;
        birthdayMgmt: Codeunit "GDRG Birthday Management";
        upcomingBirthdaysTxt: Label '🎂 Upcoming birthdays: %1', Comment = '%1 = List of names';
        noBirthdaysTxt: Label '🎂 No upcoming birthdays in the next 7 days';
        daysLbl: Label ' (%1d)', Comment = '%1 = Days to birthday';
        namesText: Text;
        count: Integer;
    begin
        birthdayMgmt.GetUpcomingBirthdays(7, employee);
        if employee.FindSet() then begin
            count := 0;
            repeat
                if count > 0 then
                    namesText += ', ';

                namesText += employee."First Name";

                if employee."GDRG Days to Birthday" = 0 then
                    namesText += ' (today)'
                else
                    namesText += StrSubstNo(daysLbl, employee."GDRG Days to Birthday");

                count += 1;
            until (employee.Next() = 0) or (count >= 3);

            if count > 3 then
                namesText += '...';

            exit(StrSubstNo(upcomingBirthdaysTxt, namesText));
        end;

        exit(noBirthdaysTxt);
    end;
}
