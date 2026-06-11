table 88900 "GDRG WC Leaderboard"
{
    Caption = 'WC Leaderboard';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the leaderboard row entry number.';
            AllowInCustomizations = AsReadOnly;
        }
        field(2; Username; Text[100])
        {
            Caption = 'Username';
            ToolTip = 'Specifies the user shown in the leaderboard.';
            AllowInCustomizations = AsReadOnly;
        }
        field(3; "Total Points"; Integer)
        {
            Caption = 'Total Points';
            ToolTip = 'Specifies the total points earned by the user.';
            AllowInCustomizations = AsReadOnly;
        }
        field(4; Predictions; Integer)
        {
            Caption = 'Predictions';
            ToolTip = 'Specifies how many predictions the user has entered.';
            AllowInCustomizations = AsReadOnly;
        }
        field(5; Exacts; Integer)
        {
            Caption = 'Exacts';
            ToolTip = 'Specifies how many exact score predictions the user has.';
            AllowInCustomizations = AsReadOnly;
        }
        field(6; Outcomes; Integer)
        {
            Caption = 'Correct Outcomes';
            ToolTip = 'Specifies how many predictions matched the correct result type, even if the score was not exact.';
            AllowInCustomizations = AsReadOnly;
        }
        field(7; Position; Integer)
        {
            Caption = 'Position';
            ToolTip = 'Specifies the ranking position in the leaderboard.';
            AllowInCustomizations = AsReadOnly;
        }
        field(8; Medal; Text[10])
        {
            Caption = 'Medal';
            ToolTip = 'Specifies the medal or trophy icon for the top positions.';
            AllowInCustomizations = AsReadOnly;
        }
        field(9; "Last Updated At"; DateTime)
        {
            Caption = 'Last Updated At';
            ToolTip = 'Specifies the last time any prediction for the user was updated.';
            AllowInCustomizations = AsReadOnly;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(RankingKey; "Total Points", Username)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Position, Medal, Username, "Total Points")
        {
        }
        fieldgroup(DropDown; Position, Medal, Username, "Total Points")
        {
        }
    }
}