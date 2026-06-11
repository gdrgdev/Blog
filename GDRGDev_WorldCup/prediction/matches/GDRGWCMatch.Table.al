table 88891 "GDRG WC Match"
{
    Caption = 'WC Match';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG WC Match List";
    DrillDownPageId = "GDRG WC Match List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
            AllowInCustomizations = AsReadOnly;
        }
        field(2; Round; Text[50])
        {
            Caption = 'Round';
            ToolTip = 'Specifies the tournament round.';
            AllowInCustomizations = AsReadOnly;
        }
        field(3; "Match Date"; Date)
        {
            Caption = 'Match Date';
            ToolTip = 'Specifies the match date.';
            AllowInCustomizations = AsReadOnly;
        }
        field(4; "Match Time"; Text[30])
        {
            Caption = 'Match Time';
            ToolTip = 'Specifies the match time from the source data.';
            AllowInCustomizations = AsReadOnly;
        }
        field(5; "Team 1"; Text[100])
        {
            Caption = 'Team 1';
            ToolTip = 'Specifies team 1.';
            AllowInCustomizations = AsReadOnly;
        }
        field(6; "Team 2"; Text[100])
        {
            Caption = 'Team 2';
            ToolTip = 'Specifies team 2.';
            AllowInCustomizations = AsReadOnly;
        }
        field(7; Group; Text[30])
        {
            Caption = 'Group';
            ToolTip = 'Specifies the group when available.';
            AllowInCustomizations = AsReadOnly;
        }
        field(8; Ground; Text[100])
        {
            Caption = 'Ground';
            ToolTip = 'Specifies the ground.';
            AllowInCustomizations = AsReadOnly;
        }
        field(9; "Team 1 Score"; Integer)
        {
            Caption = 'Team 1 Score';
            ToolTip = 'Specifies the final score for team 1.';
            AllowInCustomizations = AsReadOnly;
        }
        field(10; "Team 2 Score"; Integer)
        {
            Caption = 'Team 2 Score';
            ToolTip = 'Specifies the final score for team 2.';
            AllowInCustomizations = AsReadOnly;
        }
        field(11; "Has Result"; Boolean)
        {
            Caption = 'Has Result';
            ToolTip = 'Specifies whether the match already has a final score.';
            AllowInCustomizations = AsReadOnly;
        }
        field(12; "Match DateTime"; DateTime)
        {
            Caption = 'Local Match';
            ToolTip = 'Specifies the imported match date and time.';
            AllowInCustomizations = AsReadOnly;
        }
        field(13; "Last Updated At"; DateTime)
        {
            Caption = 'Last Updated At';
            ToolTip = 'Specifies when this match record was last refreshed.';
            AllowInCustomizations = AsReadOnly;
        }
        field(14; "Result Type"; Code[2])
        {
            Caption = 'Result Type';
            ToolTip = 'Specifies whether the final result comes from FT, ET, or P.';
            AllowInCustomizations = AsReadOnly;
        }
        field(15; "Source Round"; Integer)
        {
            Caption = 'Source Round';
            ToolTip = 'Specifies the source round.';
            AllowInCustomizations = AsReadOnly;
        }
        field(16; "Source Match"; Integer)
        {
            Caption = 'Source Match';
            ToolTip = 'Specifies the source match number.';
            AllowInCustomizations = AsReadOnly;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(DateTimeKey; "Match Date", "Match Time")
        {
        }
        key(SourceKey; "Source Round", "Source Match")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Entry No.", "Match Date", "Match Time", "Team 1", "Team 2", "Match DateTime")
        {
        }
        fieldgroup(DropDown; "Entry No.", "Match Date", "Match Time", "Team 1", "Team 2", "Match DateTime")
        {
        }
    }
}