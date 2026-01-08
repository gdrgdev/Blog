/// <summary>
/// List to monitor notification queue
/// </summary>
page 80117 "GDRG Popup Notif Queue"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Popup Notif Queue";
    Caption = 'Popup Notification Queue';
    Editable = false;
    Permissions =
        tabledata "GDRG Popup Notif Queue" = RD,
        tabledata "GDRG Popup Notif Recipient" = RD;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field(Title; Rec.Title)
                {
                }
                field(Message; Rec.Message)
                {
                }
                field("Created DateTime"; Rec."Created DateTime")
                {
                }
                field("Scheduled DateTime"; Rec."Scheduled DateTime")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewRecipients)
            {
                Caption = 'View Recipients';
                Image = Users;
                ToolTip = 'View which users have accepted this notification.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NotificationRecipient: Record "GDRG Popup Notif Recipient";
                    RecipientsPage: Page "GDRG Popup Notif Recipients";
                begin
                    NotificationRecipient.SetRange("Entry No.", Rec."Entry No.");
                    RecipientsPage.SetTableView(NotificationRecipient);
                    RecipientsPage.RunModal();
                end;
            }
            action(DeleteSelected)
            {
                Caption = 'Delete Selected';
                Image = Delete;
                ToolTip = 'Delete selected notifications and their recipients.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    NotificationQueue: Record "GDRG Popup Notif Queue";
                    NotificationRecipient: Record "GDRG Popup Notif Recipient";
                begin
                    CurrPage.SetSelectionFilter(NotificationQueue);
                    if NotificationQueue.IsEmpty() then
                        Error(NoNotificationsSelectedErr);

                    if Confirm(DeleteConfirmQst, false, NotificationQueue.Count()) then begin
                        if NotificationQueue.FindSet() then
                            repeat
                                // First delete related recipients
                                NotificationRecipient.SetRange("Entry No.", NotificationQueue."Entry No.");
                                NotificationRecipient.DeleteAll(true);
                                // Then delete the notification
                                NotificationQueue.Delete(true);
                            until NotificationQueue.Next() = 0;
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    var
        NoNotificationsSelectedErr: Label 'No notifications selected.';
        DeleteConfirmQst: Label 'Delete %1 selected notification(s) and their recipients?', Comment = '%1 = Number of selected notifications';
}
