/// <summary>
/// Invisible PagePart that monitors notifications
/// Included in Role Center so all users have it active
/// </summary>
page 80114 "GDRG Popup Notif Monitor"
{
    Caption = 'GDRG Popup Notif Monitor';
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = None;
    ShowFilter = false;
    Editable = false;
    SourceTable = "GDRG Popup Notif Cue";
    Permissions =
        tabledata "GDRG Popup Notif Queue" = R;

    layout
    {
        area(Content)
        {

            grid(Grid1)
            {
                ShowCaption = false;

                group(Group1)
                {
                    ShowCaption = false;
                }
                field(Image; Rec.Image)
                {

                }
            }
            cuegroup(Cues)
            {
                ShowCaption = false;

                field("Primary Key"; Rec."Primary Key")
                {
                    Visible = false;
                }
            }
            usercontrol(NotificationPopup; "GDRG Popup Notification")
            {
                trigger OnReady()
                begin
                    IsControlReady := true;
                    // Force immediate verification
                    CurrPage.Update(false);
                    CheckForNewNotifications();
                end;

                trigger OnTimerElapsed()
                begin
                    CheckForNewNotifications();
                end;

                trigger OnAccepted(NotificationId: Integer)
                begin
                    // User clicked OK - NOW mark as read
                    NotificationMgt.MarkAsShownToUser(NotificationId);
                end;
            }
        }
    }

    var
        NotificationMgt: Codeunit "GDRG Popup Notif Mgt";
        IsControlReady: Boolean;

    trigger OnOpenPage()
    begin
        IsControlReady := false;

        // Ensure Cue record exists (single shared record for image)
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert(true);
        end;
    end;

    /// <summary>
    /// Checks if there are unread notifications for the current user
    /// </summary>
    local procedure CheckForNewNotifications()
    var
        NotificationQueue: Record "GDRG Popup Notif Queue";
    begin
        if not IsControlReady then
            exit;

        // Get unread notifications from user's personal inbox
        NotificationMgt.GetActiveNotifications(NotificationQueue);

        if NotificationQueue.FindSet() then
            repeat
                // Show popup - will be marked as read when user clicks OK (OnAccepted)
                CurrPage.NotificationPopup.ShowNotification(
                    NotificationQueue.Title,
                    NotificationQueue.Message,
                    NotificationQueue."Entry No."
                );
            until NotificationQueue.Next() = 0;
    end;
}
