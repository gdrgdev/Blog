page 50107 "GDRG My Achievement Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG User Achievement Log";
    Caption = '👤 My Achievement History';
    Editable = false;
    Permissions = tabledata "GDRG Achievement Definition" = RIMD;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Achievement Display"; GetAchievementDisplay())
                {
                    Caption = 'Achievement Earned';
                    ToolTip = 'Specifies the achievement that you earned with its badge icon.';
                    Importance = Promoted;
                    Width = 25;
                }
                field("Date Time"; Rec."Date Time")
                {
                    Caption = 'Date & Time';
                    ToolTip = 'Specifies when you earned this achievement.';
                    Importance = Promoted;
                }
                field("Points Display"; GetPointsDisplay())
                {
                    Caption = 'Points Earned';
                    ToolTip = 'Specifies the points you earned with visual styling.';
                    Importance = Promoted;
                    Width = 12;
                }
                field("Level Progress"; GetLevelProgress())
                {
                    Caption = 'Level Progress';
                    ToolTip = 'Specifies your level progression from this achievement.';
                    Importance = Promoted;
                    Width = 18;
                }
                field("Trigger Details"; Rec."Trigger Details")
                {
                    Caption = 'Details';
                    ToolTip = 'Specifies what triggered this achievement.';
                    Importance = Additional;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    Importance = Additional;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CurrentUserID: Code[50];
    begin
        CurrentUserID := CopyStr(UserId(), 1, 50);

        Rec.SetRange("User ID", CurrentUserID);

        Rec.SetCurrentKey("Date Time");
        Rec.Ascending(false);

        if Rec.IsEmpty() then
            Message('🎯 You haven''t earned any achievements yet! Check the Achievement Guide to see how to start earning badges.');
    end;

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
