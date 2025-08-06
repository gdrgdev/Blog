page 50100 "GDRG Achievement Definitions"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Achievement Definition";
    Caption = 'Achievement Setup';
    Editable = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Achievement Code"; Rec."Achievement Code")
                {
                    Caption = 'Achievement Code';
                    ToolTip = 'Specifies the unique code for this achievement.';
                    Importance = Promoted;
                    Style = Strong;
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies a clear description of the achievement.';
                    Importance = Promoted;
                    Style = Strong;
                }
                field("Points Value"; Rec."Points Value")
                {
                    Caption = 'Points';
                    ToolTip = 'Specifies the point value for this achievement.';
                    Importance = Promoted;
                }
                field("Trigger Type"; Rec."Trigger Type")
                {
                    Caption = 'Trigger Type';
                    ToolTip = 'Specifies what action triggers this achievement.';
                    Importance = Promoted;
                }
                field("Department Filter"; Rec."Department Filter")
                {
                    Caption = 'Department';
                    ToolTip = 'Specifies which department this achievement belongs to.';
                    Importance = Promoted;
                }
                field("Is Active"; Rec."Is Active")
                {
                    Caption = 'Active';
                    ToolTip = 'Specifies whether this achievement is enabled or disabled.';
                    Importance = Promoted;
                }
                field("Difficulty Level"; Rec."Difficulty Level")
                {
                    Caption = 'Difficulty';
                    ToolTip = 'Specifies the difficulty level of this achievement.';
                    Importance = Promoted;
                }
                field("How to Achieve"; Rec."How to Achieve")
                {
                    Caption = 'How to Achieve';
                    Importance = Additional;
                }
                field("Example Action"; Rec."Example Action")
                {
                    Caption = 'Example Action';
                    Importance = Additional;
                }
                field("Threshold Value"; Rec."Min. Threshold")
                {
                    Caption = 'Min. Threshold';
                    ToolTip = 'Specifies the minimum threshold value if needed (e.g., amount for Big Deal).';
                    Importance = Additional;
                }
                field("One Time Only"; Rec."One Time Only")
                {
                    Caption = 'One Time Only';
                    ToolTip = 'Specifies whether this achievement can only be earned once per user.';
                    Importance = Additional;
                }
                field("Badge Icon"; Rec."Badge Icon")
                {
                    Caption = 'Badge Icon';
                    ToolTip = 'Specifies an emoji or icon for this achievement.';
                    Importance = Additional;
                }
            }
        }
    }

    actions
    {
    }
}
