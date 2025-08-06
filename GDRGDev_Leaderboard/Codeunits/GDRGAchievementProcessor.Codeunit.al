codeunit 50100 "GDRG Achievement Processor"
{
    Permissions = tabledata "GDRG Achievement Definition" = RIMD,
        tabledata "GDRG User Achievement Profile" = RIMD,
        tabledata "GDRG User Achievement Log" = RIMD,
        tabledata "Sales Invoice Header" = RIMD,
        tabledata "Sales Header" = RIMD;

    var
        BigDealMsg: Label 'Big Deal: %1 with amount %2', Comment = '%1 = Order Number, %2 = Amount';

    procedure ProcessUserAction(UserID: Code[50]; TriggerType: Enum "GDRG Achievement Trigger Type"; TriggerValue: Decimal; TriggerText: Text[250])
    var
        AchievementDef: Record "GDRG Achievement Definition";
    begin
        if UserID = '' then exit;
        if TriggerValue < 0 then exit;

        AchievementDef.SetRange("Trigger Type", TriggerType);
        AchievementDef.SetRange("Is Active", true);

        if AchievementDef.IsEmpty() then exit;

        if AchievementDef.FindSet() then
            repeat
                if ShouldGrantAchievement(UserID, AchievementDef, TriggerValue) then
                    GrantAchievement(UserID, AchievementDef, TriggerText);
            until AchievementDef.Next() = 0;
    end;

    local procedure ShouldGrantAchievement(UserID: Code[50]; AchievementDef: Record "GDRG Achievement Definition"; TriggerValue: Decimal): Boolean
    var
        UserLog: Record "GDRG User Achievement Log";
    begin
        if AchievementDef."One Time Only" then begin
            UserLog.SetRange("User ID", UserID);
            UserLog.SetRange("Achievement Code", AchievementDef."Achievement Code");
            if not UserLog.IsEmpty() then
                exit(false);
        end;

        if TriggerValue < AchievementDef."Min. Threshold" then
            exit(false);

        exit(true);
    end;

    local procedure GrantAchievement(UserID: Code[50]; AchievementDef: Record "GDRG Achievement Definition"; TriggerDetails: Text[250])
    var
        UserProfile: Record "GDRG User Achievement Profile";
        UserLog: Record "GDRG User Achievement Log";
        LevelBefore: Integer;
        LevelAfter: Integer;
    begin
        if not UserProfile.Get(UserID) then
            CreateNewUserProfile(UserProfile, UserID);

        LevelBefore := UserProfile."Current Level";

        CreateAchievementLogEntry(UserLog, UserID, AchievementDef, TriggerDetails, LevelBefore);

        UpdateUserProfileWithAchievement(UserProfile, AchievementDef);

        LevelAfter := CalculateUserLevel(UserProfile."Total Points");
        UserProfile."Current Level" := LevelAfter;

        UserProfile.Modify(false);
        UserLog."Level After" := LevelAfter;
        UserLog.Insert(false);
    end;

    local procedure CreateNewUserProfile(var UserProfile: Record "GDRG User Achievement Profile"; UserID: Code[50])
    begin
        UserProfile.Init();
        UserProfile."User ID" := UserID;
        UserProfile."Current Level" := 1;
        UserProfile.Insert(false);
    end;

    local procedure CreateAchievementLogEntry(var UserLog: Record "GDRG User Achievement Log"; UserID: Code[50]; AchievementDef: Record "GDRG Achievement Definition"; TriggerDetails: Text[250]; LevelBefore: Integer)
    begin
        UserLog.Init();
        UserLog."User ID" := UserID;
        UserLog."Achievement Code" := AchievementDef."Achievement Code";
        UserLog."Date Time" := CurrentDateTime();
        UserLog."Points Earned" := AchievementDef."Points Value";
        UserLog."Trigger Details" := TriggerDetails;
        UserLog."Level Before" := LevelBefore;
    end;

    local procedure UpdateUserProfileWithAchievement(var UserProfile: Record "GDRG User Achievement Profile"; AchievementDef: Record "GDRG Achievement Definition")
    begin
        UserProfile."Total Points" += AchievementDef."Points Value";
        UserProfile."Badges Earned" += 1;

        case AchievementDef."Department Filter" of
            "GDRG Department Filter"::Sales:
                UserProfile."Sales Points" += AchievementDef."Points Value";
            "GDRG Department Filter"::Finance:
                UserProfile."Finance Points" += AchievementDef."Points Value";
            "GDRG Department Filter"::Manufacturing:
                UserProfile."Manufacturing Points" += AchievementDef."Points Value";
            "GDRG Department Filter"::Service:
                UserProfile."Service Points" += AchievementDef."Points Value";
            "GDRG Department Filter"::HR:
                UserProfile."HR Points" += AchievementDef."Points Value";
        end;
    end;

    local procedure CalculateUserLevel(TotalPoints: Integer): Integer
    begin
        if TotalPoints < 500 then
            exit(1);

        exit((TotalPoints div 500) + 1);
    end;

    procedure ProcessBigDealAchievement(SalesOrderNo: Code[20]; SalesInvoiceNo: Code[20]; UserID: Code[50])
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        if SalesInvoiceNo <> '' then begin
            if SalesInvHeader.Get(SalesInvoiceNo) then begin
                SalesInvHeader.CalcFields("Amount Including VAT");
                TotalAmount := SalesInvHeader."Amount Including VAT";
            end;
        end
        else
            if SalesOrderNo <> '' then
                if SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo) then begin
                    SalesHeader.CalcFields("Amount Including VAT");
                    TotalAmount := SalesHeader."Amount Including VAT";
                end;

        if TotalAmount >= 10000 then
            ProcessUserAction(
                UserID,
                "GDRG Achievement Trigger Type"::"Big Deal",
                TotalAmount,
                StrSubstNo(BigDealMsg, SalesOrderNo, TotalAmount)
            );
    end;
}
