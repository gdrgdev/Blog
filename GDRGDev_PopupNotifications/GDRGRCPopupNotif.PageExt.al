/// <summary>
/// Role Center extension to include the notification monitor
/// </summary>
pageextension 80116 "GDRG RC Popup Notif" extends "Business Manager Role Center"
{
    layout
    {
        //addbefore("Job Queue Tasks Activities")
        addafter(Control139)
        {
            part(NotificationMonitor; "GDRG Popup Notif Monitor")
            {
                ApplicationArea = All;
                ShowFilter = false;
            }
        }
    }
}
