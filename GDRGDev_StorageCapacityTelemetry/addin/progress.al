controladdin MyProgressBar
{
    Scripts = 'script.js';
    StartupScript = 'src/addin/startup.js';
    StyleSheets = 'progress.css';
    MinimumHeight = 50;
    MaximumHeight = 50;
    HorizontalStretch = true;

    event IAmReady();

    procedure SetProgress(Progress: Integer);
}