table 88897 "GDRG WC Prediction"
{
    Caption = 'WC Prediction';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG WC Prediction List";
    DrillDownPageId = "GDRG WC Prediction List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
            AllowInCustomizations = AsReadOnly;
        }
        field(2; Username; Text[100])
        {
            Caption = 'Username';
            ToolTip = 'Specifies the user who owns the prediction.';
            AllowInCustomizations = AsReadOnly;
            TableRelation = User."User Name";
        }
        field(3; "Match Entry No."; Integer)
        {
            Caption = 'Match Entry No.';
            ToolTip = 'Specifies the related match entry number.';
            AllowInCustomizations = AsReadOnly;
            TableRelation = "GDRG WC Match"."Entry No.";
        }
        field(4; "Match Date"; Date)
        {
            Caption = 'Match Date';
            ToolTip = 'Specifies the match date.';
            AllowInCustomizations = AsReadOnly;
        }
        field(5; "Match Time"; Text[30])
        {
            Caption = 'Match Time';
            ToolTip = 'Specifies the match time.';
            AllowInCustomizations = AsReadOnly;
        }
        field(6; "Match DateTime"; DateTime)
        {
            Caption = 'Match DateTime';
            ToolTip = 'Specifies the local match date and time.';
            AllowInCustomizations = AsReadOnly;
        }
        field(7; "Team 1"; Text[100])
        {
            Caption = 'Team 1';
            ToolTip = 'Specifies team 1.';
            AllowInCustomizations = AsReadOnly;
        }
        field(8; "Team 2"; Text[100])
        {
            Caption = 'Team 2';
            ToolTip = 'Specifies team 2.';
            AllowInCustomizations = AsReadOnly;
        }
        field(9; "Team 1 Score"; Integer)
        {
            Caption = 'Team 1 Score';
            ToolTip = 'Specifies the real score for team 1.';
            AllowInCustomizations = AsReadOnly;
        }
        field(10; "Team 2 Score"; Integer)
        {
            Caption = 'Team 2 Score';
            ToolTip = 'Specifies the real score for team 2.';
            AllowInCustomizations = AsReadOnly;
        }
        field(11; "Has Result"; Boolean)
        {
            Caption = 'Has Result';
            ToolTip = 'Specifies whether the match already has a final score.';
            AllowInCustomizations = AsReadOnly;
        }
        field(12; "Result Type"; Code[2])
        {
            Caption = 'Result Type';
            ToolTip = 'Specifies whether the final result comes from FT, ET, or P.';
            AllowInCustomizations = AsReadOnly;
        }
        field(13; "Match Last Updated At"; DateTime)
        {
            Caption = 'Match Last Updated At';
            ToolTip = 'Specifies the last time the match data was refreshed.';
            AllowInCustomizations = AsReadOnly;
        }
        field(14; "Has Prediction"; Boolean)
        {
            Caption = 'Has Prediction';
            ToolTip = 'Specifies whether the user has already entered a prediction.';
            AllowInCustomizations = AsReadOnly;
        }
        field(15; "Predicted Team 1 Score"; Integer)
        {
            Caption = 'Predicted Team 1 Score';
            ToolTip = 'Specifies the predicted score for team 1.';
            AllowInCustomizations = AsReadWrite;
        }
        field(16; "Predicted Team 2 Score"; Integer)
        {
            Caption = 'Predicted Team 2 Score';
            ToolTip = 'Specifies the predicted score for team 2.';
            AllowInCustomizations = AsReadWrite;
        }
        field(17; Points; Integer)
        {
            Caption = 'Points';
            ToolTip = 'Specifies the points earned for this prediction.';
            AllowInCustomizations = AsReadOnly;
        }
        field(18; "Last Updated At"; DateTime)
        {
            Caption = 'Last Updated At';
            ToolTip = 'Specifies when this prediction was last refreshed.';
            AllowInCustomizations = AsReadOnly;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(UserMatchKey; Username, "Match Entry No.")
        {
        }
        key(UserDateTimeKey; Username, "Match Date", "Match Time")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Username, "Match DateTime", "Team 1", "Team 2", "Predicted Team 1 Score", "Predicted Team 2 Score", Points)
        {
        }
        fieldgroup(DropDown; Username, "Match DateTime", "Team 1", "Team 2", "Predicted Team 1 Score", "Predicted Team 2 Score", Points)
        {
        }
    }
}
