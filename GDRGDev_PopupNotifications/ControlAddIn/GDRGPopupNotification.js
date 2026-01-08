// GDRG Popup Notification - JavaScript Implementation
// Control to display modal notifications at company level

(function() {
    'use strict';

    // Popup state
    let currentNotificationId = null;
    let modalOverlay = null;

    /**
     * Displays the modal popup centered over the entire interface
     */
    window.ShowNotification = function(title, message, notificationId) {
        console.log('*** ShowNotification CALLED FROM AL ***', title, message, notificationId);
        
        // Check if already shown IN THIS SESSION (sessionStorage per tab)
        const shownKey = 'gdrg_notif_shown_' + notificationId;
        if (sessionStorage.getItem(shownKey)) {
            console.log('Notification already shown in this session:', notificationId);
            return;
        }
        
        console.log('*** CREATING POPUP NOW ***');
        
        // Mark as shown in this session
        sessionStorage.setItem(shownKey, Date.now().toString());

        currentNotificationId = notificationId;

        // If there's already a popup, remove it
        if (modalOverlay) {
            window.HideNotification();
        }

        // Create overlay with inline styles to ensure positioning
        modalOverlay = document.createElement('div');
        modalOverlay.className = 'gdrg-notification-overlay';
        modalOverlay.style.cssText = 'position: fixed !important; top: 0 !important; left: 0 !important; width: 100vw !important; height: 100vh !important; z-index: 2147483647 !important; display: flex !important; justify-content: center !important; align-items: center !important; background: rgba(0,0,0,0.6) !important;';

        // Create modal with Microsoft dialog-like styles
        const modal = document.createElement('div');
        modal.className = 'gdrg-notification-modal';
        modal.style.cssText = 'background: white; border-radius: 8px; box-shadow: 0 6.4px 14.4px 0 rgba(0,0,0,0.132), 0 1.2px 3.6px 0 rgba(0,0,0,0.108); max-width: 600px; width: 90%; padding: 0; position: relative; font-family: "Segoe UI", "Segoe UI Web (West European)", -apple-system, BlinkMacSystemFont, Roboto, "Helvetica Neue", sans-serif;';

        // Header with Microsoft-style blue title
        const header = document.createElement('div');
        header.className = 'gdrg-notification-header';
        header.style.cssText = 'padding: 20px 24px 16px 24px; border-bottom: 1px solid #edebe9;';
        const h2 = document.createElement('h2');
        h2.textContent = title;
        h2.style.cssText = 'margin: 0; font-size: 18px; font-weight: 600; color: #0078d4; font-family: "Segoe UI", "Segoe UI Web (West European)", -apple-system, BlinkMacSystemFont, Roboto, "Helvetica Neue", sans-serif;';
        header.appendChild(h2);

        // Body
        const body = document.createElement('div');
        body.className = 'gdrg-notification-body';
        body.style.cssText = 'padding: 20px 24px; font-size: 14px; color: #323130; line-height: 20px;';
        const p = document.createElement('p');
        p.textContent = message;
        p.style.cssText = 'margin: 0; white-space: pre-wrap; word-wrap: break-word;';
        body.appendChild(p);

        // Footer with button
        const footer = document.createElement('div');
        footer.className = 'gdrg-notification-footer';
        footer.style.cssText = 'padding: 16px 24px 20px 24px; border-top: none; text-align: right; display: flex; justify-content: flex-end; gap: 8px;';
        const btnAccept = document.createElement('button');
        btnAccept.className = 'gdrg-btn-accept';
        btnAccept.textContent = 'OK';
        btnAccept.style.cssText = 'background: #0078d4; color: white; border: none; border-radius: 2px; padding: 8px 32px; font-size: 14px; font-weight: 600; cursor: pointer; font-family: "Segoe UI", "Segoe UI Web (West European)", -apple-system, BlinkMacSystemFont, Roboto, "Helvetica Neue", sans-serif; transition: background 0.1s ease; min-width: 80px;';
        btnAccept.onmouseover = function() { this.style.background = '#106ebe'; };
        btnAccept.onmouseout = function() { this.style.background = '#0078d4'; };
        btnAccept.onclick = handleAccept;
        footer.appendChild(btnAccept);

        // Assemble modal
        modal.appendChild(header);
        modal.appendChild(body);
        modal.appendChild(footer);
        modalOverlay.appendChild(modal);

        // FORCE append to parent.document.body (BC main page, not iframe)
        const targetBody = window.parent.document.body;
        targetBody.appendChild(modalOverlay);
        console.log('*** POPUP APPENDED TO PARENT BODY ***');

        // Activate animation
        setTimeout(() => modalOverlay.classList.add('show'), 10);

        // ESC key handler
        document.addEventListener('keydown', handleEscapeKey);
    };

    /**
     * Hides the current popup
     */
    window.HideNotification = function() {
        if (modalOverlay) {
            modalOverlay.classList.remove('show');
            
            setTimeout(() => {
                if (modalOverlay && modalOverlay.parentNode) {
                    modalOverlay.parentNode.removeChild(modalOverlay);
                }
                modalOverlay = null;
            }, 300);
        }
    };

    /**
     * Handles the Accept button click
     */
    function handleAccept() {
        // Notify AL that the notification was accepted
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnAccepted', [currentNotificationId]);
        
        // Hide the modal
        window.HideNotification();
    }

    /**
     * Handles ESC key to close
     */
    function handleEscapeKey(event) {
        if (event.key === 'Escape' && modalOverlay) {
            handleAccept();
        }
    }

})();
