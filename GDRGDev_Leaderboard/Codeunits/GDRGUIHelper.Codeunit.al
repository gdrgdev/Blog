codeunit 50103 "GDRG UI Helper"
{
    Permissions = tabledata "GDRG Achievement Definition" = RIMD,
                  tabledata "GDRG User Achievement Profile" = RIMD,
                  tabledata "GDRG User Achievement Log" = RIMD;


    procedure GetLevelText(Level: Integer): Text
    var
        LevelNames: array[10] of Text;
    begin
        LevelNames[1] := NoviceLevelTxt;
        LevelNames[2] := ApprenticeLevelTxt;
        LevelNames[3] := ExpertLevelTxt;
        LevelNames[4] := MasterLevelTxt;
        LevelNames[5] := ChampionLevelTxt;
        LevelNames[6] := LegendLevelTxt;
        LevelNames[7] := GrandMasterLevelTxt;
        LevelNames[8] := EliteLevelTxt;
        LevelNames[9] := LegendaryLevelTxt;
        LevelNames[10] := MythicalLevelTxt;

        if Level <= 10 then
            exit(LevelNames[Level])
        else
            exit(StrSubstNo(UltimateLevelTxt, Level));
    end;

    procedure GetBadgeIcon(AchievementCode: Code[20]): Text
    begin
        case AchievementCode of
            'FIRST_SALE':
                exit(FirstSaleIconTxt);
            'BIG_DEAL':
                exit(BigDealIconTxt);
            'CUSTOMER_CREATOR':
                exit(CustomerCreatorIconTxt);
            'ITEM_MASTER':
                exit(ItemMasterIconTxt);
            'QUOTE_MACHINE':
                exit(QuoteMachineIconTxt);
            else
                exit(DefaultBadgeIconTxt);
        end;
    end;

    procedure GetAchievementDisplayFromDefinition(AchievementDef: Record "GDRG Achievement Definition"): Text
    var
        BadgeIcon: Text;
    begin
        BadgeIcon := GetBadgeIcon(AchievementDef."Achievement Code");
        if BadgeIcon = '' then
            BadgeIcon := AchievementDef."Badge Icon";
        if BadgeIcon = '' then
            BadgeIcon := DefaultBadgeIconTxt;

        exit(BadgeIcon + ' ' + AchievementDef.Description);
    end;

    procedure GetAchievementDisplayFromLog(AchievementLog: Record "GDRG User Achievement Log"): Text
    var
        AchievementDef: Record "GDRG Achievement Definition";
        BadgeIcon: Text;
        DisplayText: Text;
    begin
        if AchievementDef.Get(AchievementLog."Achievement Code") then begin
            BadgeIcon := GetBadgeIcon(AchievementLog."Achievement Code");
            if BadgeIcon = '' then
                BadgeIcon := AchievementDef."Badge Icon";
            if BadgeIcon = '' then
                BadgeIcon := DefaultBadgeIconTxt;

            DisplayText := BadgeIcon + ' ' + AchievementDef.Description;
        end else
            DisplayText := DefaultBadgeIconTxt + ' ' + AchievementLog."Achievement Code";

        exit(DisplayText);
    end;

    procedure GetPointsDisplayFromValue(PointsValue: Integer): Text
    var
        PointsIcon: Text;
    begin
        case true of
            (PointsValue >= 500):
                PointsIcon := '💎';
            (PointsValue >= 200):
                PointsIcon := '🥇';
            (PointsValue >= 100):
                PointsIcon := '🥈';
            (PointsValue >= 50):
                PointsIcon := '🥉';
            else
                PointsIcon := '⭐';
        end;

        exit(PointsIcon + ' ' + Format(PointsValue) + ' points');
    end;

    procedure GetPointsDisplayFromLog(PointsEarned: Integer): Text
    var
        PointsIcon: Text;
    begin
        case true of
            (PointsEarned >= 500):
                PointsIcon := '💎';
            (PointsEarned >= 200):
                PointsIcon := '🥇';
            (PointsEarned >= 100):
                PointsIcon := '🥈';
            (PointsEarned >= 50):
                PointsIcon := '🥉';
            else
                PointsIcon := '⭐';
        end;

        exit(PointsIcon + ' +' + Format(PointsEarned) + ' pts');
    end;

    procedure GetLevelProgressDisplay(LevelBefore: Integer; LevelAfter: Integer): Text
    var
        ProgressIcon: Text;
        ProgressText: Text;
    begin
        if LevelAfter > LevelBefore then begin
            ProgressIcon := '📈';
            ProgressText := Format(LevelBefore) + ' → ' + Format(LevelAfter) + ' LEVEL UP!';
        end else begin
            ProgressIcon := '📊';
            ProgressText := 'Level ' + Format(LevelBefore);
        end;

        exit(ProgressIcon + ' ' + ProgressText);
    end;

    procedure GetDifficultyDisplay(DifficultyLevel: Enum "GDRG Difficulty Level"): Text
    var
        DifficultyIcon: Text;
    begin
        case DifficultyLevel of
            DifficultyLevel::Easy:
                DifficultyIcon := '🟢 Easy';
            DifficultyLevel::Medium:
                DifficultyIcon := '🟡 Medium';
            DifficultyLevel::Hard:
                DifficultyIcon := '🟠 Hard';
            DifficultyLevel::Expert:
                DifficultyIcon := '🔴 Expert';
            else
                DifficultyIcon := '⭐ Basic';
        end;

        exit(DifficultyIcon);
    end;

    procedure GetDepartmentDisplay(DepartmentFilter: Enum "GDRG Department Filter"): Text
    var
        DeptIcon: Text;
        DeptText: Text;
    begin
        DeptText := Format(DepartmentFilter);

        case DepartmentFilter of
            DepartmentFilter::Sales:
                DeptIcon := '💰';
            DepartmentFilter::Finance:
                DeptIcon := '📊';
            DepartmentFilter::Manufacturing:
                DeptIcon := '🏭';
            DepartmentFilter::Service:
                DeptIcon := '🛠️';
            DepartmentFilter::HR:
                DeptIcon := '👥';
            else
                DeptIcon := '🌐';
        end;

        exit(DeptIcon + ' ' + DeptText);
    end;

    procedure GetFrequencyInfo(OneTimeOnly: Boolean): Text
    begin
        if OneTimeOnly then
            exit('🔒 One-time only')
        else
            exit('🔄 Repeatable');
    end;

    procedure GetTotalPointsDisplay(TotalPoints: Integer): Text
    begin
        case true of
            (TotalPoints >= 1000):
                exit('💎 ' + Format(TotalPoints) + ' points');
            (TotalPoints >= 500):
                exit('🥇 ' + Format(TotalPoints) + ' points');
            (TotalPoints >= 200):
                exit('🥈 ' + Format(TotalPoints) + ' points');
            (TotalPoints >= 100):
                exit('🥉 ' + Format(TotalPoints) + ' points');
            else
                exit('⭐ ' + Format(TotalPoints) + ' points');
        end;
    end;

    procedure GetDepartmentBreakdown(SalesPoints: Integer; FinancePoints: Integer; ManufacturingPoints: Integer; ServicePoints: Integer; HRPoints: Integer): Text
    var
        Breakdown: Text;
        TotalDeptPoints: Integer;
    begin
        TotalDeptPoints := SalesPoints + FinancePoints + ManufacturingPoints + ServicePoints + HRPoints;

        if TotalDeptPoints = 0 then
            exit('📊 No department activity');

        Breakdown := '💰' + Format(SalesPoints) + ' 📊' + Format(FinancePoints) +
                    ' 🏭' + Format(ManufacturingPoints) + ' 🛠️' + Format(ServicePoints) +
                    ' 👥' + Format(HRPoints);

        exit(Breakdown);
    end;

    procedure GetDepartmentPointsDisplay(DepartmentFilter: Enum "GDRG Department Filter"; Points: Integer): Text
    var
        DeptIcon: Text;
    begin
        case DepartmentFilter of
            DepartmentFilter::Sales:
                DeptIcon := '💰';
            DepartmentFilter::Finance:
                DeptIcon := '📊';
            DepartmentFilter::Manufacturing:
                DeptIcon := '🏭';
            DepartmentFilter::Service:
                DeptIcon := '🛠️';
            DepartmentFilter::HR:
                DeptIcon := '👥';
            else
                DeptIcon := '🌐';
        end;

        exit(DeptIcon + ' ' + Format(Points) + ' pts');
    end;

    var
        NoviceLevelTxt: Label '🌱 Novice';
        ApprenticeLevelTxt: Label '🎓 Apprentice';
        ExpertLevelTxt: Label '⭐ Expert';
        MasterLevelTxt: Label '🏆 Master';
        ChampionLevelTxt: Label '👑 Champion';
        LegendLevelTxt: Label '🌟 Legend';
        GrandMasterLevelTxt: Label '💫 Grand Master';
        EliteLevelTxt: Label '⚡ Elite';
        LegendaryLevelTxt: Label '🔥 Legendary';
        MythicalLevelTxt: Label '🚀 Mythical';
        UltimateLevelTxt: Label 'Ultimate Level %1', Comment = '%1 = Level number for levels above 10';
        FirstSaleIconTxt: Label '🎯', Locked = true;
        BigDealIconTxt: Label '💎', Locked = true;
        CustomerCreatorIconTxt: Label '👥', Locked = true;
        ItemMasterIconTxt: Label '📦', Locked = true;
        QuoteMachineIconTxt: Label '📋', Locked = true;
        DefaultBadgeIconTxt: Label '🏆', Locked = true;
}