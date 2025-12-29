table 80102 "GDRG RSS Feed Entry"
{
    DataClassification = CustomerContent;
    Caption = 'RSS Feed Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
            AutoIncrement = true;
            AllowInCustomizations = Never;
        }
        field(2; "Feed Code"; Code[20])
        {
            Caption = 'Feed Code';
            ToolTip = 'Specifies the feed source code.';
            TableRelation = "GDRG RSS Feed Source";
        }
        field(3; Title; Text[250])
        {
            Caption = 'Title';
            ToolTip = 'Specifies the title of the RSS entry.';
        }
        field(4; Description; Text[2048])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the RSS entry.';
        }
        field(5; Link; Text[250])
        {
            Caption = 'Link';
            ToolTip = 'Specifies the link to the RSS entry.';
            ExtendedDatatype = URL;
            AllowInCustomizations = AsReadOnly;
        }
        field(6; "Published Date"; DateTime)
        {
            Caption = 'Published Date';
            ToolTip = 'Specifies when the entry was published.';
        }
        field(7; "Fetched DateTime"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Fetched DateTime';
            ToolTip = 'Specifies when the entry was fetched.';
            Editable = false;
            AllowInCustomizations = Never;
        }
        field(8; Category; Enum "GDRG RSS Category")
        {
            Caption = 'Category';
            ToolTip = 'Specifies the category of the RSS feed.';
            Editable = false;
            AllowInCustomizations = AsReadOnly;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(FeedDate; "Feed Code", "Published Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Title, "Published Date", "Feed Code")
        {
        }
        fieldgroup(Brick; Title, Description, "Published Date")
        {
        }
    }
}
