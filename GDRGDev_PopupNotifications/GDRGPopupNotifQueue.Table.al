/// <summary>
/// Queue table for broadcast notifications
/// Stores notifications that should be displayed to all connected users
/// </summary>
table 80113 "GDRG Popup Notif Queue"
{
    Caption = 'GDRG Popup Notif Queue';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Popup Notif Queue";
    DrillDownPageId = "GDRG Popup Notif Queue";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies the unique entry number for the notification.';
        }
        field(10; Title; Text[100])
        {
            Caption = 'Title';
            ToolTip = 'Specifies the title of the notification message.';
        }
        field(20; Message; Text[2048])
        {
            Caption = 'Message';
            ToolTip = 'Specifies the content of the notification message.';
        }
        field(30; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            ToolTip = 'Specifies when the notification was created.';
        }
        field(40; "Scheduled DateTime"; DateTime)
        {
            Caption = 'Scheduled DateTime';
            ToolTip = 'Specifies when the notification should start being displayed to users.';
            AllowInCustomizations = Never;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Created; "Created DateTime")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", Title, "Created DateTime")
        {
        }
        fieldgroup(Brick; Title, Message, "Created DateTime")
        {
        }
    }
}
