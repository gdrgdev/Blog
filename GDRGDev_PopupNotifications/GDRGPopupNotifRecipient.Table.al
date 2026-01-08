/// <summary>
/// Tracking table: which users have seen which notifications
/// Allows each user to see the notification once, independently of others
/// </summary>
table 80118 "GDRG Popup Notif Recipient"
{
    Caption = 'GDRG Popup Notif Recipient';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Popup Notif Recipients";
    DrillDownPageId = "GDRG Popup Notif Recipients";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Notification Entry No.';
            TableRelation = "GDRG Popup Notif Queue"."Entry No.";
            ToolTip = 'Specifies the notification entry number that this recipient record is associated with.';
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user who received the notification.';
        }
        field(10; "Read DateTime"; DateTime)
        {
            Caption = 'Read DateTime';
            ToolTip = 'Specifies when the notification was read by the user.';
        }
        field(20; "Scheduled DateTime"; DateTime)
        {
            Caption = 'Scheduled DateTime';
            ToolTip = 'Specifies when the notification should start being displayed to the user.';
            AllowInCustomizations = Never;
        }
    }

    keys
    {
        key(PK; "Entry No.", "User ID")
        {
            Clustered = true;
        }
        key(UserUnread; "User ID", "Read DateTime", "Scheduled DateTime")
        {
            // Optimized key for finding unread notifications for a user that are ready to display
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "User ID", "Read DateTime")
        {
        }
        fieldgroup(Brick; "User ID", "Entry No.", "Read DateTime")
        {
        }
    }
}
