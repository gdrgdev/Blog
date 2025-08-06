table 50100 "GDRG Achievement Definition"
{
    Caption = 'GDRG Achievement Definition';
    LookupPageId = "GDRG Achievement Definitions";
    DrillDownPageId = "GDRG Achievement Definitions";

    fields
    {
        field(1; "Achievement Code"; Code[20])
        {
            Caption = 'Achievement Code';
            ToolTip = 'Specifies the unique code that identifies this achievement definition.';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of what this achievement represents or what action triggers it.';
        }
        field(3; "Points Value"; Integer)
        {
            Caption = 'Points Value';
            ToolTip = 'Specifies the number of points awarded when this achievement is earned.';
            MinValue = 0;
        }
        field(4; "Trigger Type"; Enum "GDRG Achievement Trigger Type")
        {
            Caption = 'Trigger Type';
            ToolTip = 'Specifies the type of action or event that triggers this achievement.';
        }
        field(5; "Min. Threshold"; Decimal)
        {
            Caption = 'Min. Threshold';
            ToolTip = 'Specifies the minimum threshold value required to trigger this achievement.';
            MinValue = 0;
        }
        field(6; "Badge Icon"; Text[50])
        {
            Caption = 'Badge Icon';
            ToolTip = 'Specifies the icon or symbol that represents this achievement badge.';
        }
        field(7; "Department Filter"; Enum "GDRG Department Filter")
        {
            Caption = 'Department Filter';
            ToolTip = 'Specifies which department this achievement applies to or if it applies to all departments.';
        }
        field(8; "One Time Only"; Boolean)
        {
            Caption = 'One Time Only';
            ToolTip = 'Specifies whether this achievement can only be earned once per user or multiple times.';
        }
        field(9; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            ToolTip = 'Specifies whether this achievement definition is currently active and can be earned by users.';
            InitValue = true;
        }
        field(10; "How to Achieve"; Text[250])
        {
            Caption = 'How to Achieve';
            ToolTip = 'Specifies clear instructions for users on how to earn this achievement.';
        }
        field(11; "Example Action"; Text[250])
        {
            Caption = 'Example Action';
            ToolTip = 'Specifies a specific example of an action that would earn this achievement.';
        }
        field(12; "Difficulty Level"; Enum "GDRG Difficulty Level")
        {
            Caption = 'Difficulty Level';
            ToolTip = 'Specifies how difficult this achievement is to obtain.';
        }
    }

    keys
    {
        key(PK; "Achievement Code")
        {
            Clustered = true;
        }
        key(TriggerType; "Trigger Type", "Is Active")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Achievement Code", Description, "Points Value")
        {
        }
        fieldgroup(Brick; "Achievement Code", Description, "Points Value", "Trigger Type", "Is Active")
        {
        }
    }
}
