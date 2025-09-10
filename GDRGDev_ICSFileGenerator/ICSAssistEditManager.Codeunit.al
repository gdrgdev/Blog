codeunit 50103 "ICS Assist Edit Manager"
{
    Access = Public;

    procedure OpenEventConfigPage(var EventBuffer: Record "ICS Event Data Buffer"): Boolean
    var
        ICSEventConfigPage: Page "ICS Event Configuration";
    begin
        ICSEventConfigPage.LoadEventData(EventBuffer);

        if ICSEventConfigPage.RunModal() = Action::OK then
            if ICSEventConfigPage.WasEventCreated() then begin
                ICSEventConfigPage.GetEventData(EventBuffer);
                exit(true);
            end;

        exit(false);
    end;

    procedure GenerateAndDownloadICS(var EventBuffer: Record "ICS Event Data Buffer"): Boolean
    var
        ICSFileGenerator: Codeunit ICSFileGenerator;
        GenerationFailedErr: Label 'Failed to generate calendar file. Please check your event data and try again.';
    begin
        if not ICSFileGenerator.GenerateICSFile(EventBuffer) then
            Error(GenerationFailedErr);

        exit(true);
    end;
}
