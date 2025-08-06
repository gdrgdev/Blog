page 50101 "GDRG Gaming Dashboard"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = '🎮 Gaming Dashboard';

    layout
    {
        area(RoleCenter)
        {
            group(Overview)
            {
                Caption = '🏆 Gaming Overview';

            }
        }
    }

    actions
    {
        area(Sections)
        {
            group("My Gaming Experience")
            {
                Caption = '🎮 My Gaming Experience';
                action(MyProfile)
                {
                    Caption = '👤 My Profile';
                    RunObject = page "GDRG My Profile";
                    ToolTip = 'Specifies viewing your personal achievement profile and statistics with visual performance indicators.';
                    Image = User;
                }
                action(AchievementGuide)
                {
                    Caption = '🎯 Achievement Guide';
                    RunObject = page "GDRG Achievement Guide";
                    ToolTip = 'Specifies how to learn achievement earning methods and see all available badges with step-by-step instructions.';
                    Image = TaskList;
                }
                action(Leaderboard)
                {
                    Caption = '🏆 Leaderboard';
                    RunObject = page "GDRG Achievement Leaderboard";
                    ToolTip = 'Specifies viewing the achievement leaderboard with rankings, medals, and user performance indicators.';
                    Image = AnalysisView;
                }
                action(MyAchievementLog)
                {
                    Caption = '📜 My Achievements';
                    RunObject = page "GDRG My Achievement Log";
                    Image = History;
                    ToolTip = 'Specifies viewing your personal achievement history with visual indicators and badges.';
                }
            }
            group("Gaming Administration")
            {
                Caption = '⚙️ Gaming Administration';
                action(AchievementSetup)
                {
                    Caption = '⚙️ Achievement Setup';
                    RunObject = page "GDRG Achievement Definitions";
                    ToolTip = 'Specifies management of achievement definitions and configuration of new achievements with visual elements.';
                    Image = Setup;
                }
                action(AllUserProfiles)
                {
                    Caption = '👥 All User Profiles';
                    RunObject = page "GDRG User Profile List";
                    ToolTip = 'Specifies viewing all user profiles and comparing performance across the organization.';
                    Image = Users;
                }
                action(FullAchievementLog)
                {
                    Caption = '📊 Full Achievement Log';
                    RunObject = page "GDRG Achievement Log";
                    ToolTip = 'Specifies viewing the complete achievement log history for all users with visual indicators and badges.';
                    Image = History;
                }
            }
        }
        area(Creation)
        {
            action(ManageDemoData)
            {
                Caption = '🎲 Manage Demo Data';
                Image = DataEntry;
                ToolTip = 'Specifies creating or clearing demonstration data for testing the gamification system with sample achievements and users.';
                RunObject = codeunit "GDRG Demo Data";
            }
        }
    }
}
