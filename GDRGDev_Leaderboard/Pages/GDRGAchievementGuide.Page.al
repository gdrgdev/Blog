page 50105 "GDRG Achievement Guide"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Achievement Definition";
    Caption = '🎯 Achievement Guide - How to Earn Badges';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Achievement Display"; GetAchievementDisplay())
                {
                    Caption = 'Achievement';
                    ToolTip = 'Specifies the achievement with its badge icon.';
                    Importance = Promoted;
                    Width = 20;
                }
                field("Points Display"; GetPointsDisplay())
                {
                    Caption = 'Reward';
                    ToolTip = 'Specifies points you will earn for this achievement.';
                    Importance = Promoted;
                    Style = Favorable;
                    Width = 10;
                }
                field("How to Achieve"; Rec."How to Achieve")
                {
                    Caption = '🎯 How to Earn This';
                    ToolTip = 'Specifies step-by-step instructions to earn this achievement.';
                    Importance = Promoted;
                    Style = Strong;
                    Width = 40;
                }
                field("Example Action"; Rec."Example Action")
                {
                    Caption = '💡 Example';
                    ToolTip = 'Specifies a specific example of how to complete this achievement.';
                    Importance = Promoted;
                    Style = StandardAccent;
                    Width = 35;
                }
                field("Difficulty Display"; GetDifficultyDisplay())
                {
                    Caption = 'Difficulty';
                    ToolTip = 'Specifies how challenging this achievement is to complete.';
                    Importance = Additional;
                    Width = 12;
                }
                field("Department Display"; GetDepartmentDisplay())
                {
                    Caption = 'Department';
                    ToolTip = 'Specifies which department benefits from this achievement.';
                    Importance = Additional;
                    Width = 15;
                }
                field("Frequency Info"; GetFrequencyInfo())
                {
                    Caption = 'Frequency';
                    ToolTip = 'Specifies how often you can earn this achievement.';
                    Importance = Additional;
                    Width = 12;
                }
            }
        }
    }


    var
        UIHelper: Codeunit "GDRG UI Helper";

    trigger OnOpenPage()
    begin
        Rec.SetRange("Is Active", true);

        Rec.SetCurrentKey("Difficulty Level", "Points Value");
    end;

    local procedure GetAchievementDisplay(): Text
    begin
        exit(UIHelper.GetAchievementDisplayFromDefinition(Rec));
    end;

    local procedure GetPointsDisplay(): Text
    begin
        exit(UIHelper.GetPointsDisplayFromValue(Rec."Points Value"));
    end;

    local procedure GetDifficultyDisplay(): Text
    begin
        exit(UIHelper.GetDifficultyDisplay(Rec."Difficulty Level"));
    end;

    local procedure GetDepartmentDisplay(): Text
    begin
        exit(UIHelper.GetDepartmentDisplay(Rec."Department Filter"));
    end;

    local procedure GetFrequencyInfo(): Text
    begin
        exit(UIHelper.GetFrequencyInfo(Rec."One Time Only"));
    end;
}
