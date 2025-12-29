table 80101 "GDRG RSS Feed Source"
{
    DataClassification = CustomerContent;
    Caption = 'RSS Feed Source';
    LookupPageId = "GDRG RSS Feed Sources";
    DrillDownPageId = "GDRG RSS Feed Sources";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the code for the RSS feed source.';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the RSS feed source.';
        }
        field(3; "Feed URL"; Text[250])
        {
            Caption = 'Feed URL';
            ToolTip = 'Specifies the URL of the RSS feed.';
        }
        field(4; Category; Enum "GDRG RSS Category")
        {
            Caption = 'Category';
            ToolTip = 'Specifies the category of the RSS feed.';
        }
        field(5; "Refresh Interval Minutes"; Integer)
        {
            Caption = 'Refresh Interval Minutes';
            ToolTip = 'Specifies the refresh interval in minutes.';
            InitValue = 60;
            MinValue = 5;
        }
        field(6; "Last Refresh DateTime"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Refresh DateTime';
            ToolTip = 'Specifies when the feed was last refreshed.';
            Editable = false;
            AllowInCustomizations = Never;
        }
        field(7; Active; Boolean)
        {
            Caption = 'Active';
            ToolTip = 'Specifies if the feed source is active.';
            InitValue = true;
        }
        field(10; "Use Custom Interval"; Boolean)
        {
            Caption = 'Use Custom Interval';
            ToolTip = 'Specifies if the feed uses a custom refresh interval.';
        }
        field(20; "Entry Count"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("GDRG RSS Feed Entry" where("Feed Code" = field("Code")));
            Caption = 'Entry Count';
            ToolTip = 'Specifies the number of entries for this feed source.';
            Editable = false;
            AllowInCustomizations = AsReadOnly;
        }
        field(21; "Earliest Entry Date"; DateTime)
        {
            FieldClass = FlowField;
            CalcFormula = min("GDRG RSS Feed Entry"."Published Date" where("Feed Code" = field("Code")));
            Caption = 'Earliest Entry Date';
            ToolTip = 'Specifies the oldest entry date for this feed source.';
            Editable = false;
            AllowInCustomizations = AsReadOnly;
        }
        field(22; "Latest Entry Date"; DateTime)
        {
            FieldClass = FlowField;
            CalcFormula = max("GDRG RSS Feed Entry"."Published Date" where("Feed Code" = field("Code")));
            Caption = 'Latest Entry Date';
            ToolTip = 'Specifies the most recent entry date for this feed source.';
            Editable = false;
            AllowInCustomizations = AsReadOnly;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, Category)
        {
        }
        fieldgroup(Brick; "Code", Description, "Feed URL", Active)
        {
        }
    }
}
