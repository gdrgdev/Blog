page 50106 "GDRG My Profile"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "GDRG User Achievement Profile";
    Caption = '👤 My Gaming Profile';
    Editable = false;

    layout
    {
        area(Content)
        {
            group("Personal Overview")
            {
                Caption = '🏆 My Achievement Overview';
                field("User Display"; GetUserDisplay())
                {
                    Caption = 'User';
                    ToolTip = 'Specifies your user identification.';
                    Importance = Promoted;
                    Style = Strong;
                }
                field("Level Display"; GetLevelDisplay())
                {
                    Caption = 'Current Level';
                    ToolTip = 'Specifies your current achievement level with badge.';
                    Importance = Promoted;
                    Style = Favorable;
                }
                field("Total Points Display"; GetTotalPointsDisplay())
                {
                    Caption = 'Total Points';
                    ToolTip = 'Specifies your total achievement points earned.';
                    Importance = Promoted;
                    Style = Strong;
                }
                field("Badges Display"; GetBadgesDisplay())
                {
                    Caption = 'Badges Earned';
                    ToolTip = 'Specifies the total number of achievement badges you have earned.';
                    Importance = Promoted;
                    Style = Favorable;
                }
            }
            group("Department Breakdown")
            {
                Caption = '🏢 My Department Points';
                field("Sales Points Display"; GetSalesPointsDisplay())
                {
                    Caption = 'Sales Points';
                    ToolTip = 'Specifies points earned from sales-related activities.';
                    Importance = Additional;
                }
                field("Finance Points Display"; GetFinancePointsDisplay())
                {
                    Caption = 'Finance Points';
                    ToolTip = 'Specifies points earned from finance-related activities.';
                    Importance = Additional;
                }
                field("Manufacturing Points Display"; GetManufacturingPointsDisplay())
                {
                    Caption = 'Manufacturing Points';
                    ToolTip = 'Specifies points earned from manufacturing-related activities.';
                    Importance = Additional;
                }
                field("Service Points Display"; GetServicePointsDisplay())
                {
                    Caption = 'Service Points';
                    ToolTip = 'Specifies points earned from service-related activities.';
                    Importance = Additional;
                }
                field("HR Points Display"; GetHRPointsDisplay())
                {
                    Caption = 'HR Points';
                    ToolTip = 'Specifies points earned from HR-related activities.';
                    Importance = Additional;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ViewMyAchievements)
            {
                Caption = '🏆 My Achievements';
                ToolTip = 'Specifies your personal achievement history.';
                Image = History;

                trigger OnAction()
                var
                    AchievementLog: Record "GDRG User Achievement Log";
                    MyAchievementsPage: Page "GDRG Achievement Log";
                begin
                    AchievementLog.SetRange("User ID", CopyStr(UserId(), 1, 50));
                    MyAchievementsPage.SetTableView(AchievementLog);
                    MyAchievementsPage.Run();
                end;
            }
            action(ViewLeaderboard)
            {
                Caption = '🥇 View Leaderboard';
                ToolTip = 'Specifies how you rank against other users.';
                Image = AnalysisView;

                trigger OnAction()
                var
                    LeaderboardPage: Page "GDRG Achievement Leaderboard";
                begin
                    LeaderboardPage.Run();
                end;
            }
            action(AchievementGuide)
            {
                Caption = '🎯 Achievement Guide';
                ToolTip = 'Specifies how to earn more achievements.';
                Image = TaskList;

                trigger OnAction()
                var
                    AchievementGuidePage: Page "GDRG Achievement Guide";
                begin
                    AchievementGuidePage.Run();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Quick Actions';
                actionref(ViewMyAchievements_Promoted; ViewMyAchievements)
                {
                }
                actionref(ViewLeaderboard_Promoted; ViewLeaderboard)
                {
                }
                actionref(AchievementGuide_Promoted; AchievementGuide)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        UserProfile: Record "GDRG User Achievement Profile";
        CurrentUserID: Code[50];
        ErrorInfo: ErrorInfo;
    begin
        CurrentUserID := CopyStr(UserId(), 1, 50);

        if not UserProfile.Get(CurrentUserID) then begin
            CreateUserProfile(CurrentUserID);
            if not UserProfile.Get(CurrentUserID) then begin
                ErrorInfo.Message := 'Unable to create user profile. Please contact your administrator.';
                ErrorInfo.DetailedMessage := 'Failed to create user achievement profile for user: ' + CurrentUserID;
                ErrorInfo.Verbosity := Verbosity::Error;
                Error(ErrorInfo);
            end;
        end;

        Rec.SetRange("User ID", CurrentUserID);

        if not Rec.FindFirst() then begin
            ErrorInfo.Message := 'Unable to load your profile. Please contact your administrator.';
            ErrorInfo.DetailedMessage := 'User profile exists but could not be loaded for user: ' + CurrentUserID;
            ErrorInfo.Verbosity := Verbosity::Error;
            Error(ErrorInfo);
        end;
    end;

    local procedure CreateUserProfile(UserID: Code[50])
    var
        UserProfile: Record "GDRG User Achievement Profile";
    begin
        UserProfile.Init();
        UserProfile."User ID" := UserID;
        UserProfile."Current Level" := 1;
        UserProfile.Insert(false);
    end;

    var
        UIHelper: Codeunit "GDRG UI Helper";

    local procedure GetUserDisplay(): Text
    begin
        exit('👤 ' + Rec."User ID");
    end;

    local procedure GetLevelDisplay(): Text
    var
        LevelText: Text;
    begin
        LevelText := UIHelper.GetLevelText(Rec."Current Level");
        exit(LevelText);
    end;

    local procedure GetTotalPointsDisplay(): Text
    begin
        exit(UIHelper.GetTotalPointsDisplay(Rec."Total Points"));
    end;

    local procedure GetBadgesDisplay(): Text
    begin
        exit('🏆 ' + Format(Rec."Badges Earned") + ' badges');
    end;

    local procedure GetSalesPointsDisplay(): Text
    var
        DeptFilter: Enum "GDRG Department Filter";
    begin
        exit(UIHelper.GetDepartmentPointsDisplay(DeptFilter::Sales, Rec."Sales Points"));
    end;

    local procedure GetFinancePointsDisplay(): Text
    var
        DeptFilter: Enum "GDRG Department Filter";
    begin
        exit(UIHelper.GetDepartmentPointsDisplay(DeptFilter::Finance, Rec."Finance Points"));
    end;

    local procedure GetManufacturingPointsDisplay(): Text
    var
        DeptFilter: Enum "GDRG Department Filter";
    begin
        exit(UIHelper.GetDepartmentPointsDisplay(DeptFilter::Manufacturing, Rec."Manufacturing Points"));
    end;

    local procedure GetServicePointsDisplay(): Text
    var
        DeptFilter: Enum "GDRG Department Filter";
    begin
        exit(UIHelper.GetDepartmentPointsDisplay(DeptFilter::Service, Rec."Service Points"));
    end;

    local procedure GetHRPointsDisplay(): Text
    var
        DeptFilter: Enum "GDRG Department Filter";
    begin
        exit(UIHelper.GetDepartmentPointsDisplay(DeptFilter::HR, Rec."HR Points"));
    end;
}
