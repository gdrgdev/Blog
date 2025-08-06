page 50104 "GDRG Achievement Leaderboard"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG User Achievement Profile";
    Caption = 'GDRG Achievement Leaderboard';

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Ranking Icon"; GetRankingIcon())
                {
                    Caption = '🏆';
                    ToolTip = 'Specifies the ranking position with appropriate icon.';
                    Importance = Promoted;
                    Width = 3;
                }
                field("Ranking Position"; GetRankingPosition())
                {
                    Caption = 'Rank';
                    ToolTip = 'Specifies the ranking position of the user in the leaderboard based on total points.';
                    Importance = Promoted;
                    Style = Favorable;
                }
                field("User ID"; Rec."User ID")
                {
                    Importance = Promoted;
                    Style = Strong;
                }
                field("Level Badge"; GetLevelBadge())
                {
                    Caption = 'Level';
                    ToolTip = 'Specifies the user level with visual badge.';
                    Importance = Promoted;
                    Width = 8;
                }
                field("Total Points"; Rec."Total Points")
                {
                    Importance = Promoted;
                    Style = Favorable;
                }
                field("Badges Display"; GetBadgesDisplay())
                {
                    Caption = 'Badges';
                    ToolTip = 'Specifies the number of badges earned with visual representation.';
                    Importance = Promoted;
                    Width = 10;
                }
                field("Sales Points"; Rec."Sales Points")
                {
                    Caption = 'Sales Points';
                    ToolTip = 'Specifies points earned from sales-related activities.';
                    Importance = Promoted;
                    Style = Favorable;
                }
                field("Finance Points"; Rec."Finance Points")
                {
                    Caption = 'Finance Points';
                    ToolTip = 'Specifies points earned from finance-related activities.';
                    Importance = Promoted;
                    Style = Favorable;
                }
                field("Service Points"; Rec."Service Points")
                {
                    Caption = 'Service Points';
                    ToolTip = 'Specifies points earned from service-related activities.';
                    Importance = Promoted;
                    Style = Favorable;
                }
                field("Current Level"; Rec."Current Level")
                {
                    Importance = Additional;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshLeaderboard)
            {
                Caption = 'Refresh Leaderboard';
                Image = Refresh;
                ToolTip = 'Specifies to refresh the leaderboard to show the most current ranking and points.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(ViewAchievementLog)
            {
                Caption = 'View Achievement Log';
                Image = History;
                ToolTip = 'Specifies to open the achievement log for the selected user to view their earned achievements.';

                trigger OnAction()
                var
                    AchievementLog: Record "GDRG User Achievement Log";
                    AchievementLogPage: Page "GDRG Achievement Log";
                begin
                    AchievementLog.SetRange("User ID", Rec."User ID");
                    AchievementLogPage.SetTableView(AchievementLog);
                    AchievementLogPage.Run();
                end;
            }
            action(ViewUserDetails)
            {
                Caption = 'View User Details';
                Image = User;
                ToolTip = 'Specifies to view detailed information for the selected user profile.';

                trigger OnAction()
                var
                    UserProfile: Record "GDRG User Achievement Profile";
                begin
                    if UserProfile.Get(Rec."User ID") then
                        Page.Run(Page::"GDRG My Profile", UserProfile);
                end;
            }
            action(ShowAchievementCard)
            {
                Caption = 'Show Achievement Card';
                Image = Card;
                ToolTip = 'Specifies to show the achievement card for the selected user.';

                trigger OnAction()
                var
                    AchievementLog: Record "GDRG User Achievement Log";
                    AchievementLogPage: Page "GDRG Achievement Log";
                begin
                    AchievementLog.SetRange("User ID", Rec."User ID");
                    AchievementLogPage.SetTableView(AchievementLog);
                    AchievementLogPage.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Total Points");
        Rec.Ascending(false);
    end;

    local procedure GetRankingIcon(): Text
    var
        Position: Integer;
    begin
        Position := GetRankingPosition();
        case Position of
            1:
                exit('🥇');
            2:
                exit('🥈');
            3:
                exit('🥉');
            else
                exit('🏅');
        end;
    end;

    local procedure GetRankingPosition(): Integer
    var
        UserProfile: Record "GDRG User Achievement Profile";
        Position: Integer;
    begin
        Position := 1;
        UserProfile.SetCurrentKey("Total Points");
        UserProfile.Ascending(false);
        if UserProfile.FindSet() then
            repeat
                if UserProfile."User ID" = Rec."User ID" then
                    exit(Position);
                Position += 1;
            until UserProfile.Next() = 0;
        exit(Position);
    end;

    local procedure GetLevelBadge(): Text
    var
        LevelText: Text;
    begin
        LevelText := UIHelper.GetLevelText(Rec."Current Level");
        exit(LevelText);
    end;

    local procedure GetBadgesDisplay(): Text
    begin
        exit('🏆 ' + Format(Rec."Badges Earned") + ' badges');
    end;

    var
        UIHelper: Codeunit "GDRG UI Helper";
}
