permissionset 80110 "GDRG Popup Notif"
{
    Assignable = true;
    Caption = 'GDRG Popup Notifications', Locked = true;

    Permissions =
        page "GDRG Popup Notif Card" = X,
        page "GDRG Popup Notif Monitor" = X,
        page "GDRG Popup Notif Queue" = X,
        page "GDRG Popup Notif Recipients" = X,
        page "GDRG Popup Notif Cue Setup" = X,
        table "GDRG Popup Notif Queue" = X,
        table "GDRG Popup Notif Recipient" = X,
        table "GDRG Popup Notif Cue" = X,
        tabledata "GDRG Popup Notif Queue" = RIMD,
        tabledata "GDRG Popup Notif Recipient" = RIMD,
        tabledata "GDRG Popup Notif Cue" = RIMD,
        codeunit "GDRG Popup Notif Mgt" = X;
}
