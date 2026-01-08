table 80120 "GDRG Popup Notif Cue"
{
    Caption = 'GDRG Popup Notif Cue';
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[50])
        {
            Caption = 'Notification';
            Editable = false;
            NotBlank = false;
            ToolTip = 'Specifies the primary key for the notification.';
        }
        field(2; Image; MediaSet)
        {
            Caption = 'Notification';
            ToolTip = 'Specifies the notification image.';
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
