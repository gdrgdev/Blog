// Startup script for GDRG Popup Notification Control Add-in
// This script runs when the control initializes

console.log('*** GDRG STARTUP.JS LOADED ***');

// Notify that the control is ready
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnReady', []);
console.log('*** OnReady invoked ***');

// Timer: every 30 seconds check for new notifications
setInterval(function() {
    console.log('*** Timer tick - OnTimerElapsed invoked ***');
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnTimerElapsed', []);
}, 30000);
