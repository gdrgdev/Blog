page 50103 "GDRG Achievement Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG User Achievement Log";
    Caption = 'Achievement Log';
    Editable = false;
    Permissions = tabledata "GDRG Achievement Definition" = RIMD;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Importance = Additional;
                }
                field("Achievement Display"; GetAchievementDisplay())
                {
                    Caption = 'Achievement Earned';
                    ToolTip = 'Specifies the achievement that was earned with its badge icon.';
                    Importance = Promoted;
                    Width = 20;
                }
                field("User ID"; Rec."User ID")
                {
                    Importance = Promoted;
                    Style = Strong;
                }
                field("Date Time"; Rec."Date Time")
                {
                    Importance = Promoted;
                }
                field("Points Display"; GetPointsDisplay())
                {
                    Caption = 'Points Earned';
                    ToolTip = 'Specifies the points earned with visual styling.';
                    Importance = Promoted;
                    Width = 10;
                }
                field("Level Progress"; GetLevelProgress())
                {
                    Caption = 'Level Progress';
                    ToolTip = 'Specifies the level progression from this achievement.';
                    Importance = Promoted;
                    Width = 15;
                }
                field("Trigger Details"; Rec."Trigger Details")
                {
                    Importance = Additional;
                }
            }
        }
    }

    var
        UIHelper: Codeunit "GDRG UI Helper";

    local procedure GetAchievementDisplay(): Text
    begin
        exit(UIHelper.GetAchievementDisplayFromLog(Rec));
    end;

    local procedure GetPointsDisplay(): Text
    begin
        exit(UIHelper.GetPointsDisplayFromLog(Rec."Points Earned"));
    end;

    local procedure GetLevelProgress(): Text
    begin
        exit(UIHelper.GetLevelProgressDisplay(Rec."Level Before", Rec."Level After"));
    end;
}
