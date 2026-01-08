/// <summary>
/// Broadcast notification management
/// </summary>
codeunit 80115 "GDRG Popup Notif Mgt"
{
    Permissions =
        tabledata "GDRG Popup Notif Queue" = RI,
        tabledata "GDRG Popup Notif Recipient" = RIM,
        tabledata User = R;

    /// <summary>
    /// Creates a new notification in the queue for broadcast
    /// </summary>
    /// <param name="NotificationTitle">The title of the notification.</param>
    /// <param name="NotificationMessage">The message content of the notification.</param>
    /// <param name="ScheduledDateTime">The date and time when the notification should start being displayed.</param>
    procedure BroadcastNotification(NotificationTitle: Text[100]; NotificationMessage: Text[2048]; ScheduledDateTime: DateTime)
    var
        NotificationQueue: Record "GDRG Popup Notif Queue";
        NotificationRecipient: Record "GDRG Popup Notif Recipient";
        User: Record User;
        EntryNo: Integer;
        CurrentDT: DateTime;
        ActualScheduledDT: DateTime;
    begin
        CurrentDT := CurrentDateTime();

        // Ensure Scheduled DateTime is never before Created DateTime
        if ScheduledDateTime < CurrentDT then
            ActualScheduledDT := CurrentDT
        else
            ActualScheduledDT := ScheduledDateTime;

        // Insert notification in queue
        NotificationQueue.Init();
        NotificationQueue.Title := NotificationTitle;
        NotificationQueue.Message := NotificationMessage;
        NotificationQueue."Created DateTime" := CurrentDT;
        NotificationQueue."Scheduled DateTime" := ActualScheduledDT;
        NotificationQueue.Insert(true);
        EntryNo := NotificationQueue."Entry No.";

        // Create recipients for real system users (exclude applications/services)
        User.SetRange(State, User.State::Enabled); // Only enabled users
        User.SetRange("License Type", User."License Type"::"Full User"); // Only users with full license
        User.SetFilter("Authentication Email", '<>%1', ''); // Must have authentication email
        if User.FindSet() then
            repeat
                // Exclude application/service users that don't have Windows Security ID
                if not IsNullGuid(User."User Security ID") then begin
                    NotificationRecipient.Init();
                    NotificationRecipient."Entry No." := EntryNo;
                    NotificationRecipient."User ID" := CopyStr(User."User Name", 1, 50);
                    NotificationRecipient."Read DateTime" := 0DT; // Blank = unread
                    NotificationRecipient."Scheduled DateTime" := ActualScheduledDT;
                    NotificationRecipient.Insert(true);
                end;
            until User.Next() = 0;
    end;

    /// <summary>
    /// Gets notifications that the current user has NOT read (personal inbox)
    /// </summary>
    /// <param name="NotificationQueue">The record variable to store the filtered notifications.</param>
    procedure GetActiveNotifications(var NotificationQueue: Record "GDRG Popup Notif Queue")
    var
        NotificationRecipient: Record "GDRG Popup Notif Recipient";
        CurrentUserID: Code[50];
    begin
        CurrentUserID := CopyStr(UserId(), 1, 50);

        // Filter recipients for current user where Read DateTime is blank (unread) and scheduled time has arrived
        NotificationRecipient.SetCurrentKey("User ID", "Read DateTime", "Scheduled DateTime");
        NotificationRecipient.SetRange("User ID", CurrentUserID);
        NotificationRecipient.SetRange("Read DateTime", 0DT); // Blank = unread
        NotificationRecipient.SetFilter("Scheduled DateTime", '<=%1', CurrentDateTime()); // Scheduled time has arrived

        if NotificationRecipient.FindSet() then
            repeat
                // Get the corresponding notification
                if NotificationQueue.Get(NotificationRecipient."Entry No.") then
                    NotificationQueue.Mark(true);
            until NotificationRecipient.Next() = 0;

        NotificationQueue.MarkedOnly(true);
    end;

    /// <summary>
    /// Marks a notification as read (UPDATE Read DateTime)
    /// </summary>
    /// <param name="EntryNo">The notification entry number to mark as read.</param>
    procedure MarkAsShownToUser(EntryNo: Integer)
    var
        NotificationRecipient: Record "GDRG Popup Notif Recipient";
        CurrentUserID: Code[50];
    begin
        CurrentUserID := CopyStr(UserId(), 1, 50);

        // Find the existing record and update read date
        NotificationRecipient.SetRange("Entry No.", EntryNo);
        NotificationRecipient.SetRange("User ID", CurrentUserID);
        if NotificationRecipient.FindFirst() then begin
            NotificationRecipient."Read DateTime" := CurrentDateTime();
            NotificationRecipient.Modify(true);
        end;
    end;
}
