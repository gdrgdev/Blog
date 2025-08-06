codeunit 50101 "GDRG Demo Data"
{
    Permissions = tabledata "GDRG Achievement Definition" = RIMD,
        tabledata "GDRG User Achievement Profile" = RIMD,
        tabledata "GDRG User Achievement Log" = RIMD;

    trigger OnRun()
    var
        SelectionMsg: Label 'What would you like to do?';
        CreateOptionLbl: Label 'Create Demo Data';
        ClearOptionLbl: Label 'Clear All Data';
    begin
        case StrMenu(CreateOptionLbl + ',' + ClearOptionLbl, 1, SelectionMsg) of
            1:
                CreateAllDemoData();
            2:
                ClearAllData();
        end;
    end;

    var
        DemoAchievementsCreatedMsg: Label 'Demo achievements created successfully!', Comment = 'Message shown when demo achievements are created';
        DemoUserProfilesCreatedMsg: Label 'Demo user profiles created successfully!', Comment = 'Message shown when demo user profiles are created';
        DemoLogsCreatedMsg: Label 'Demo achievement logs created successfully!', Comment = 'Message shown when demo achievement logs are created';
        AllDemoDataCreatedMsg: Label 'All demo data created successfully!', Comment = 'Message shown when all demo data is created';
        AllDataClearedMsg: Label 'All gamification data cleared successfully!', Comment = 'Message shown when all data is cleared';
        ConfirmClearDataQst: Label 'Are you sure you want to clear all gamification data?', Comment = 'Confirmation question when clearing all data';

    procedure CreateDemoAchievements()
    var
        AchievementDef: Record "GDRG Achievement Definition";
    begin
        AchievementDef.DeleteAll(false);

        CreateAchievement('FIRST_SALE', 'First Sale Order', 100, "GDRG Achievement Trigger Type"::"Sales Order Posted", 1, '🎯', "GDRG Department Filter"::Sales, true);
        CreateAchievement('BIG_DEAL', 'Big Deal (>10K)', 500, "GDRG Achievement Trigger Type"::"Big Deal", 10000, '💎', "GDRG Department Filter"::Sales, false);
        CreateAchievement('CUSTOMER_CREATOR', 'Customer Creator', 50, "GDRG Achievement Trigger Type"::"Customer Created", 1, '👥', "GDRG Department Filter"::Sales, false);
        CreateAchievement('ITEM_MASTER', 'Item Master', 75, "GDRG Achievement Trigger Type"::"Item Created", 1, '📦', "GDRG Department Filter"::All, false);
        CreateAchievement('QUOTE_MACHINE', 'Quote Machine', 25, "GDRG Achievement Trigger Type"::"Quote Created", 1, '📋', "GDRG Department Filter"::Sales, false);
        CreateAchievement('VENDOR_MANAGER', 'Vendor Manager', 60, "GDRG Achievement Trigger Type"::"Vendor Created", 1, '🏢', "GDRG Department Filter"::Finance, false);
        CreateAchievement('CONTACT_BUILDER', 'Contact Builder', 40, "GDRG Achievement Trigger Type"::"Contact Created", 1, '📞', "GDRG Department Filter"::Sales, false);
        CreateAchievement('PURCHASE_PRO', 'Purchase Pro', 80, "GDRG Achievement Trigger Type"::"Purchase Order Posted", 1, '🛒', "GDRG Department Filter"::Finance, false);

        Message(DemoAchievementsCreatedMsg);
    end;

    local procedure CreateAchievement(Code: Code[20]; Description: Text[100]; Points: Integer; TriggerType: Enum "GDRG Achievement Trigger Type"; Threshold: Decimal; Icon: Text[50]; Department: Enum "GDRG Department Filter"; OneTime: Boolean)
    var
        AchievementDef: Record "GDRG Achievement Definition";
    begin
        AchievementDef.Init();
        AchievementDef."Achievement Code" := Code;
        AchievementDef.Description := Description;
        AchievementDef."Points Value" := Points;
        AchievementDef."Trigger Type" := TriggerType;
        AchievementDef."Min. Threshold" := Threshold;
        AchievementDef."Badge Icon" := Icon;
        AchievementDef."Department Filter" := Department;
        AchievementDef."One Time Only" := OneTime;
        AchievementDef."Is Active" := true;

        SetAchievementInstructions(AchievementDef, TriggerType);

        AchievementDef.Insert(false);
    end;

    local procedure SetAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition"; TriggerType: Enum "GDRG Achievement Trigger Type")
    begin
        if IsEasyAchievement(TriggerType) then
            SetEasyAchievementInstructions(AchievementDef, TriggerType);
        if IsMediumAchievement(TriggerType) then
            SetMediumAchievementInstructions(AchievementDef, TriggerType);
        if IsHardAchievement(TriggerType) then
            SetHardAchievementInstructions(AchievementDef);
        if not (IsEasyAchievement(TriggerType) or IsMediumAchievement(TriggerType) or IsHardAchievement(TriggerType)) then
            SetDefaultAchievementInstructions(AchievementDef);
    end;

    local procedure IsEasyAchievement(TriggerType: Enum "GDRG Achievement Trigger Type"): Boolean
    begin
        exit(TriggerType in [TriggerType::"Customer Created", TriggerType::"Quote Created",
                            TriggerType::"Item Created", TriggerType::"Vendor Created",
                            TriggerType::"Contact Created"]);
    end;

    local procedure IsMediumAchievement(TriggerType: Enum "GDRG Achievement Trigger Type"): Boolean
    begin
        exit(TriggerType in [TriggerType::"Sales Order Posted", TriggerType::"Purchase Order Posted"]);
    end;

    local procedure IsHardAchievement(TriggerType: Enum "GDRG Achievement Trigger Type"): Boolean
    begin
        exit(TriggerType = TriggerType::"Big Deal");
    end;

    local procedure SetEasyAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition"; TriggerType: Enum "GDRG Achievement Trigger Type")
    begin
        AchievementDef."Difficulty Level" := AchievementDef."Difficulty Level"::Easy;
        case TriggerType of
            TriggerType::"Customer Created":
                SetCustomerAchievementInstructions(AchievementDef);
            TriggerType::"Quote Created":
                SetQuoteAchievementInstructions(AchievementDef);
            TriggerType::"Item Created":
                SetItemAchievementInstructions(AchievementDef);
            TriggerType::"Vendor Created":
                SetVendorAchievementInstructions(AchievementDef);
            TriggerType::"Contact Created":
                SetContactAchievementInstructions(AchievementDef);
        end;
    end;

    local procedure SetMediumAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition"; TriggerType: Enum "GDRG Achievement Trigger Type")
    begin
        AchievementDef."Difficulty Level" := AchievementDef."Difficulty Level"::Medium;
        case TriggerType of
            TriggerType::"Sales Order Posted":
                SetSalesOrderAchievementInstructions(AchievementDef);
            TriggerType::"Purchase Order Posted":
                SetPurchaseOrderAchievementInstructions(AchievementDef);
        end;
    end;

    local procedure SetHardAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."Difficulty Level" := AchievementDef."Difficulty Level"::Hard;
        SetBigDealAchievementInstructions(AchievementDef);
    end;

    local procedure SetCustomerAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Create a new customer record in the system';
        AchievementDef."Example Action" := 'Go to Customers → New → Fill details → Save';
    end;

    local procedure SetSalesOrderAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Complete and post a sales order';
        AchievementDef."Example Action" := 'Sales Orders → Select order → Post → Ship and Invoice';
    end;

    local procedure SetBigDealAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Post a sales order with amount ≥ 10,000';
        AchievementDef."Example Action" := 'Create high-value sales order (>€10,000) and post it';
    end;

    local procedure SetQuoteAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Create a sales quote for a customer';
        AchievementDef."Example Action" := 'Sales Quotes → New → Select customer → Add items → Save';
    end;

    local procedure SetItemAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Add a new item to the inventory system';
        AchievementDef."Example Action" := 'Items → New → Enter item details → Save';
    end;

    local procedure SetPurchaseOrderAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Complete and post a purchase order';
        AchievementDef."Example Action" := 'Purchase Orders → Select order → Post → Receive';
    end;

    local procedure SetVendorAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Register a new vendor in the system';
        AchievementDef."Example Action" := 'Vendors → New → Fill vendor information → Save';
    end;

    local procedure SetContactAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Add a new contact to the contact list';
        AchievementDef."Example Action" := 'Contacts → New → Enter contact details → Save';
    end;

    local procedure SetDefaultAchievementInstructions(var AchievementDef: Record "GDRG Achievement Definition")
    begin
        AchievementDef."How to Achieve" := 'Complete the associated business activity';
        AchievementDef."Example Action" := 'Perform the required action in Business Central';
        AchievementDef."Difficulty Level" := AchievementDef."Difficulty Level"::Medium;
    end;

    procedure CreateDemoProfiles()
    var
        UserProfile: Record "GDRG User Achievement Profile";
        UserLog: Record "GDRG User Achievement Log";
        i: Integer;
        Users: array[5] of Code[50];
    begin
        UserProfile.DeleteAll(false);
        UserLog.DeleteAll(false);

        Users[1] := 'DEMO.USER1';
        Users[2] := 'DEMO.USER2';
        Users[3] := 'DEMO.USER3';
        Users[4] := 'DEMO.USER4';
        Users[5] := 'DEMO.USER5';

        for i := 1 to 5 do
            CreateDemoUserProfile(Users[i], i * 250, i, (i - 1) * 100, i * 50);

        Message(DemoUserProfilesCreatedMsg);
    end;

    local procedure CreateDemoUserProfile(UserID: Code[50]; TotalPoints: Integer; Level: Integer; SalesPoints: Integer; FinancePoints: Integer)
    var
        UserProfile: Record "GDRG User Achievement Profile";
    begin
        UserProfile.Init();
        UserProfile."User ID" := UserID;
        UserProfile."Total Points" := TotalPoints;
        UserProfile."Current Level" := Level;
        UserProfile."Sales Points" := SalesPoints;
        UserProfile."Finance Points" := FinancePoints;
        UserProfile."Badges Earned" := Level * 2;
        UserProfile.Insert(false);
    end;

    procedure CreateDemoAchievementLogs()
    var
        UserLog: Record "GDRG User Achievement Log";
        i: Integer;
        j: Integer;
        Users: array[5] of Code[50];
        Achievements: array[3] of Code[20];
        EntryNo: Integer;
    begin
        UserLog.DeleteAll(false);

        Users[1] := 'DEMO.USER1';
        Users[2] := 'DEMO.USER2';
        Users[3] := 'DEMO.USER3';
        Users[4] := 'DEMO.USER4';
        Users[5] := 'DEMO.USER5';

        Achievements[1] := 'FIRST_SALE';
        Achievements[2] := 'CUSTOMER_CREATOR';

        EntryNo := 1;

        for i := 1 to 5 do
            for j := 1 to 2 do begin
                CreateDemoLogEntry(EntryNo, Users[i], Achievements[j], i * j * 25, i, i + 1);
                EntryNo += 1;
            end;

        Message(DemoLogsCreatedMsg);
    end;

    local procedure CreateDemoLogEntry(EntryNo: Integer; UserID: Code[50]; AchievementCode: Code[20]; Points: Integer; LevelBefore: Integer; LevelAfter: Integer)
    var
        UserLog: Record "GDRG User Achievement Log";
        DemoMsg: Label 'Demo achievement: %1', Comment = '%1 = Achievement Code';
    begin
        UserLog.Init();
        UserLog."Entry No." := EntryNo;
        UserLog."User ID" := UserID;
        UserLog."Achievement Code" := AchievementCode;
        UserLog."Date Time" := CurrentDateTime() - (EntryNo * 60000);
        UserLog."Points Earned" := Points;
        UserLog."Trigger Details" := StrSubstNo(DemoMsg, AchievementCode);
        UserLog."Level Before" := LevelBefore;
        UserLog."Level After" := LevelAfter;
        UserLog.Insert(false);
    end;

    procedure CreateAllDemoData()
    begin
        CreateDemoAchievements();
        CreateDemoProfiles();
        CreateDemoAchievementLogs();
        Message(AllDemoDataCreatedMsg);
    end;

    procedure ClearAllData()
    var
        AchievementDef: Record "GDRG Achievement Definition";
        UserProfile: Record "GDRG User Achievement Profile";
        UserLog: Record "GDRG User Achievement Log";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponseOrDefault(ConfirmClearDataQst, false) then
            exit;

        UserLog.DeleteAll(false);
        UserProfile.DeleteAll(false);
        AchievementDef.DeleteAll(false);

        Message(AllDataClearedMsg);
    end;
}
