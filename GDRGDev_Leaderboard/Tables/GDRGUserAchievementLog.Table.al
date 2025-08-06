table 50102 "GDRG User Achievement Log"
{
    Caption = 'GDRG User Achievement Log';
    LookupPageId = "GDRG Achievement Log";
    DrillDownPageId = "GDRG Achievement Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the unique sequential number for this achievement log entry.';
            AutoIncrement = true;
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the user who earned this achievement.';
            NotBlank = true;
            TableRelation = "GDRG User Achievement Profile"."User ID";
        }
        field(3; "Achievement Code"; Code[20])
        {
            Caption = 'Achievement Code';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the code of the achievement that was earned.';
            TableRelation = "GDRG Achievement Definition"."Achievement Code";
        }
        field(4; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
            ToolTip = 'Specifies the exact date and time when this achievement was earned.';
        }
        field(5; "Points Earned"; Integer)
        {
            Caption = 'Points Earned';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the number of points earned from this achievement.';
            MinValue = 0;
        }
        field(6; "Trigger Details"; Text[250])
        {
            Caption = 'Trigger Details';
            ToolTip = 'Specifies additional details about what triggered this achievement.';
        }
        field(7; "Level Before"; Integer)
        {
            Caption = 'Level Before';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the user level before earning this achievement.';
            MinValue = 1;
        }
        field(8; "Level After"; Integer)
        {
            Caption = 'Level After';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the user level after earning this achievement.';
            MinValue = 1;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(UserAchievement; "User ID", "Achievement Code")
        {
        }
        key(DateTime; "Date Time")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "User ID", "Achievement Code", "Date Time")
        {
        }
        fieldgroup(Brick; "Entry No.", "User ID", "Achievement Code", "Points Earned", "Date Time")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Date Time" = 0DT then
            "Date Time" := CurrentDateTime();
    end;
}
