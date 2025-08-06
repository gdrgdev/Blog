page 50102 "GDRG User Profile List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG User Achievement Profile";
    Caption = 'User Achievement Profiles';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("User Display"; GetUserDisplay())
                {
                    Caption = 'User';
                    ToolTip = 'Specifies the user with status indicator.';
                    Importance = Promoted;
                    Width = 15;
                }
                field("Level Display"; GetLevelDisplay())
                {
                    Caption = 'Level & Points';
                    ToolTip = 'Specifies the current level with visual badge and total points.';
                    Importance = Promoted;
                    Width = 20;
                }
                field("Department Breakdown"; GetDepartmentBreakdown())
                {
                    Caption = 'Department Points';
                    ToolTip = 'Specifies points breakdown by department with icons.';
                    Importance = Additional;
                    Width = 30;
                }
                field("Badges Display"; GetBadgesDisplay())
                {
                    Caption = 'Badges';
                    ToolTip = 'Specifies total badges earned with visual representation.';
                    Importance = Additional;
                    Width = 20;
                }
            }
        }
    }

    var
        UIHelper: Codeunit "GDRG UI Helper";

    local procedure GetUserDisplay(): Text
    begin
        if Rec."User ID" = '' then
            exit('❓ Unknown User');

        exit('👤 ' + Rec."User ID");
    end;

    local procedure GetLevelDisplay(): Text
    var
        LevelText: Text;
    begin
        LevelText := UIHelper.GetLevelText(Rec."Current Level");
        exit(LevelText + ' (' + UIHelper.GetTotalPointsDisplay(Rec."Total Points") + ')');
    end;

    local procedure GetDepartmentBreakdown(): Text
    begin
        exit(UIHelper.GetDepartmentBreakdown(Rec."Sales Points", Rec."Finance Points", Rec."Manufacturing Points", Rec."Service Points", Rec."HR Points"));
    end;

    local procedure GetBadgesDisplay(): Text
    begin
        exit('🏆 ' + Format(Rec."Badges Earned") + ' badges');
    end;

}
