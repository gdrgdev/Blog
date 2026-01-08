// GDRG Popup Notification Control Add-in
// Control to display centered modal notifications that appear over the entire interface
controladdin "GDRG Popup Notification"
{
    RequestedHeight = 1;
    RequestedWidth = 1;
    MinimumHeight = 1;
    MinimumWidth = 1;
    VerticalStretch = false;
    VerticalShrink = false;
    HorizontalStretch = false;
    HorizontalShrink = false;

    Scripts = 'src/ControlAddIn/Startup.js',
              'src/ControlAddIn/GDRGPopupNotification.js';
    StyleSheets = 'src/ControlAddIn/GDRGPopupNotification.css';

    /// <summary>
    /// Shows the modal popup with the specified message
    /// </summary>
    /// <param name="Title">The title of the notification.</param>
    /// <param name="Message">The message content of the notification.</param>
    /// <param name="NotificationId">The unique identifier of the notification.</param>
    procedure ShowNotification(Title: Text; Message: Text; NotificationId: Integer);

    /// <summary>
    /// Hides the current popup
    /// </summary>
    procedure HideNotification();

    /// <summary>
    /// Event that fires when the control is ready
    /// </summary>
    event OnReady();

    /// <summary>
    /// Event that fires every 30 seconds (timer)
    /// </summary>
    event OnTimerElapsed();

    /// <summary>
    /// Event that fires when the user clicks Accept
    /// </summary>
    /// <param name="NotificationId">The unique identifier of the notification that was accepted.</param>
    event OnAccepted(NotificationId: Integer);
}
