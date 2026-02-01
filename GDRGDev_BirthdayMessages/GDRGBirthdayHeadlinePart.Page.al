page 80107 "GDRG Birthday Headline Part"
{
    PageType = HeadlinePart;

    layout
    {
        area(Content)
        {
            field(BirthdayHeadline; headlineText)
            {
                ApplicationArea = All;

                trigger OnDrillDown()
                var
                    employee: Record Employee;
                    birthdayMgmt: Codeunit "GDRG Birthday Management";
                    myMessagesPage: Page "GDRG My Birthday Messages";
                    teamPortalPage: Page "GDRG Team Birthday Portal";
                begin
                    if birthdayMgmt.GetEmployeeFromUserID(UserId, employee) then
                        if birthdayMgmt.IsBirthdayToday(employee."Birth Date") then begin
                            myMessagesPage.Run();
                            exit;
                        end;

                    teamPortalPage.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        birthdayHeadlineCU: Codeunit "GDRG Birthday Headline";
    begin
        headlineText := birthdayHeadlineCU.GetBirthdayHeadline();
    end;

    var
        headlineText: Text;
}
