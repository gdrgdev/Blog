// Simple page to send popup notifications
page 80112 "GDRG Popup Notif Card"
{
    Caption = 'Send Popup Notification';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Permissions =
        tabledata "GDRG Popup Notif Queue" = RI,
        tabledata "GDRG Popup Notif Recipient" = RI;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Notification';

                field(Title; NotificationTitle)
                {
                    Caption = 'Title';
                    ToolTip = 'Specifies the title of the notification.';
                    ShowMandatory = true;
                }
                field(Message; NotificationMessage)
                {
                    Caption = 'Message';
                    MultiLine = true;
                    ToolTip = 'Specifies the message that will be displayed to all users.';
                    ShowMandatory = true;
                }
                field(ScheduledDateTime; ScheduledDateTime)
                {
                    Caption = 'Scheduled Date/Time';
                    ToolTip = 'Specifies when the notification should start being displayed. Leave as current time to send immediately.';

                    trigger OnValidate()
                    var
                        TypeHelper: Codeunit "Type Helper";
                    begin
                        if TypeHelper.CompareDateTime(ScheduledDateTime, CurrentDateTime()) < 0 then
                            Error(ScheduledDateTimePastErr);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Send)
            {
                Caption = 'Send to All Users';
                Image = SendMail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Send this notification to all users. It will appear as a popup.';

                trigger OnAction()
                var
                    NotificationMgt: Codeunit "GDRG Popup Notif Mgt";
                begin
                    if NotificationTitle = '' then
                        Error(TitleRequiredErr);
                    if NotificationMessage = '' then
                        Error(MessageRequiredErr);

                    if Confirm(SendConfirmQst, false) then begin
                        // Broadcast to all users (insert in queue)
                        NotificationMgt.BroadcastNotification(NotificationTitle, NotificationMessage, ScheduledDateTime);

                        Message(NotificationSentMsg);

                        // Clear fields
                        NotificationTitle := '';
                        NotificationMessage := '';
                        ScheduledDateTime := CurrentDateTime();
                    end;
                end;
            }
            action(SelectRecipients)
            {
                Caption = 'Select Recipients';
                Image = Users;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Save notification and manually select which users should receive it.';

                trigger OnAction()
                var
                    NotificationRecipient: Record "GDRG Popup Notif Recipient";
                    RecipientsPage: Page "GDRG Popup Notif Recipients";
                    NotificationMgt: Codeunit "GDRG Popup Notif Mgt";
                    EntryNo: Integer;
                begin
                    if NotificationTitle = '' then
                        Error(TitleRequiredErr);
                    if NotificationMessage = '' then
                        Error(MessageRequiredErr);

                    // Save notification to queue first
                    EntryNo := SaveNotificationToQueue();

                    // Commit the transaction before opening modal page
                    Commit();

                    // Open recipients page in editable mode for manual selection
                    NotificationRecipient.SetRange("Entry No.", EntryNo);
                    RecipientsPage.SetTableView(NotificationRecipient);
                    RecipientsPage.SetEntryNoAndScheduledDateTime(EntryNo, ScheduledDateTime);
                    RecipientsPage.RunModal();

                    Message(RecipientSelectionCompleteMsg);

                    // Clear fields
                    NotificationTitle := '';
                    NotificationMessage := '';
                    ScheduledDateTime := CurrentDateTime();
                end;
            }
            action(ViewQueue)
            {
                Caption = 'View Queue';
                Image = List;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Open the notification queue to view all notifications.';

                trigger OnAction()
                var
                    QueuePage: Page "GDRG Popup Notif Queue";
                begin
                    QueuePage.Run();
                end;
            }
        }
    }

    var
        NotificationTitle: Text[100];
        NotificationMessage: Text[2048];
        ScheduledDateTime: DateTime;
        TitleRequiredErr: Label 'Title is required.';
        MessageRequiredErr: Label 'Message is required.';
        SendConfirmQst: Label 'Send this notification to all users?';
        NotificationSentMsg: Label 'Notification sent to all connected users.';
        RecipientSelectionCompleteMsg: Label 'Notification saved. You can now add more recipients from the Recipients page.';
        ScheduledDateTimePastErr: Label 'Scheduled date/time cannot be in the past.';

    local procedure SaveNotificationToQueue(): Integer
    var
        NotificationQueue: Record "GDRG Popup Notif Queue";
        CurrentDT: DateTime;
    begin
        CurrentDT := CurrentDateTime();

        // Insert notification in queue without creating recipients
        NotificationQueue.Init();
        NotificationQueue.Title := NotificationTitle;
        NotificationQueue.Message := NotificationMessage;
        NotificationQueue."Created DateTime" := CurrentDT;

        // Ensure Scheduled DateTime is never before Created DateTime
        if ScheduledDateTime < CurrentDT then
            NotificationQueue."Scheduled DateTime" := CurrentDT
        else
            NotificationQueue."Scheduled DateTime" := ScheduledDateTime;

        NotificationQueue.Insert(true);
        exit(NotificationQueue."Entry No.");
    end;

    trigger OnOpenPage()
    begin
        if ScheduledDateTime = 0DT then
            ScheduledDateTime := CurrentDateTime();
    end;
}
