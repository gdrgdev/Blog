codeunit 50100 ICSFileGenerator
{
    SingleInstance = true;
    Subtype = Normal;

    /// <summary>
    /// Generate ICS file from event data and download - Primary function of this extension
    /// </summary>
    /// <param name="EventData">Structured event data</param>
    /// <returns>True if successful, false otherwise</returns>
    procedure GenerateICSFile(EventData: Record "ICS Event Data Buffer"): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
    begin
        if not GenerateICSBlob(EventData, TempBlob, FileName) then
            exit(false);

        exit(DownloadICSFile(TempBlob, FileName));
    end;

    /// <summary>
    /// Generate ICS content and create blob (no download) - For flexible output handling
    /// </summary>
    /// <param name="EventData">Structured event data</param>
    /// <param name="TempBlob">Output: Generated ICS file as blob</param>
    /// <param name="FileName">Output: Suggested filename</param>
    /// <returns>True if successful, false otherwise</returns>
    procedure GenerateICSBlob(EventData: Record "ICS Event Data Buffer"; var TempBlob: Codeunit "Temp Blob"; var FileName: Text): Boolean
    var
        ICSContent: Text;
    begin
        ICSContent := BuildICSContent(EventData);

        if ICSContent = '' then begin
            Message('Failed to generate ICS content.');
            exit(false);
        end;

        FileName := GenerateFileName(EventData.Summary, EventData."Created DateTime");
        WriteToStream(ICSContent, TempBlob);

        exit(true);
    end;

    /// <summary>
    /// Download ICS blob as file to user - Separated download responsibility
    /// </summary>
    /// <param name="TempBlob">ICS file blob to download</param>
    /// <param name="FileName">Filename for download</param>
    /// <returns>True if successful</returns>
    procedure DownloadICSFile(var TempBlob: Codeunit "Temp Blob"; FileName: Text): Boolean
    var
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, '', '', '', FileName);
        Message('Calendar event exported successfully as "%1"!', FileName);

        exit(true);
    end;

    procedure BuildICSContent(EventData: Record "ICS Event Data Buffer"): Text
    var
        StringBuilder: TextBuilder;
    begin
        StringBuilder.Append(BuildCalendarHeader(EventData));

        StringBuilder.Append(BuildEventSection(EventData));

        StringBuilder.AppendLine('END:VCALENDAR');

        exit(StringBuilder.ToText());
    end;

    local procedure BuildCalendarHeader(EventData: Record "ICS Event Data Buffer"): Text
    var
        StringBuilder: TextBuilder;
    begin
        StringBuilder.AppendLine('BEGIN:VCALENDAR');
        StringBuilder.AppendLine('VERSION:2.0');
        StringBuilder.AppendLine('PRODID:' + EventData."Prod ID");
        StringBuilder.AppendLine('METHOD:' + EventData.Method);
        exit(StringBuilder.ToText());
    end;

    local procedure BuildEventSection(EventData: Record "ICS Event Data Buffer"): Text
    var
        StringBuilder: TextBuilder;
    begin
        StringBuilder.AppendLine('BEGIN:VEVENT');
        StringBuilder.AppendLine('UID:' + DelChr(EventData.UID, '<>', '{}'));

        if EventData.Organizer <> '' then
            StringBuilder.AppendLine('ORGANIZER:' + EventData.Organizer);

        if EventData.Location <> '' then
            StringBuilder.AppendLine('LOCATION:' + EventData.Location);

        if EventData."All Day Event" then begin
            StringBuilder.AppendLine('DTSTART;VALUE=DATE:' + GetICSDateString(EventData."Start DateTime"));
            StringBuilder.AppendLine('DTEND;VALUE=DATE:' + GetICSDateString(EventData."End DateTime"));
        end else begin
            StringBuilder.AppendLine('DTSTART:' + GetICSDateTimeString(EventData."Start DateTime"));
            StringBuilder.AppendLine('DTEND:' + GetICSDateTimeString(EventData."End DateTime"));
        end;

        StringBuilder.AppendLine('SUMMARY:' + EventData.Summary);

        if EventData.Description <> '' then begin
            StringBuilder.AppendLine('DESCRIPTION:' + EventData.Description);
            StringBuilder.AppendLine('X-ALT-DESC;FMTTYPE=text/html:' + GetHtmlDescription(EventData.Description));
        end;

        if EventData.Priority <> 5 then
            StringBuilder.AppendLine('PRIORITY:' + Format(EventData.Priority));

        StringBuilder.AppendLine('SEQUENCE:' + Format(EventData.Sequence));
        StringBuilder.AppendLine('STATUS:' + EventData.Status);
        StringBuilder.AppendLine('END:VEVENT');

        exit(StringBuilder.ToText());
    end;

    procedure GenerateFileName(Summary: Text; CreatedDateTime: DateTime): Text
    var
        CleanSummary: Text;
    begin
        CleanSummary := SanitizeFileName(Summary);

        exit(CleanSummary + '-' + Format(CreatedDateTime, 0, '<Year4><Month,2><Day,2>T<Hours24><Minutes,2><Seconds,2>') + '.ics');
    end;

    local procedure SanitizeFileName(Input: Text): Text
    var
        CleanText: Text;
        MaxFilenameLength: Integer;
    begin
        MaxFilenameLength := GetMaxFilenamePrefixLength();

        CleanText := DelChr(Input, '=', '/\:*?"<>|[](){}$%^&+=`~');

        while StrPos(CleanText, '  ') > 0 do
            CleanText := DelChr(CleanText, '=', ' ');
        CleanText := DelChr(CleanText, '<>', ' ');

        CleanText := ConvertStr(CleanText, ' ', '-');

        if StrLen(CleanText) > MaxFilenameLength then
            CleanText := CopyStr(CleanText, 1, MaxFilenameLength);

        if CleanText = '' then
            CleanText := GetDefaultEventPrefix();

        exit(CleanText);
    end;

    local procedure GetMaxFilenamePrefixLength(): Integer
    begin
        exit(50);
    end;

    local procedure GetDefaultEventPrefix(): Text
    begin
        exit('calendar-event');
    end;

    procedure WriteToStream(ICSContent: Text; var TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(ICSContent);
    end;

    procedure GetHtmlDescription(Description: Text): Text
    var
        Regex: Codeunit Regex;
        HtmlAppointDescription: Text;
    begin
        HtmlAppointDescription := Regex.Replace(Description, '\r', '');
        HtmlAppointDescription := Regex.Replace(HtmlAppointDescription, '\n', '<br>');
        exit('<html><body>' + HtmlAppointDescription + '</body></html>');
    end;

    procedure GetICSDateTimeString(DateTimeValue: DateTime): Text
    var
        TimeZone: Codeunit "Time Zone";
        TimeZoneOffset: Duration;
        UTCDateTime: DateTime;
    begin
        TimeZoneOffset := TimeZone.GetTimezoneOffset(DateTimeValue);
        UTCDateTime := DateTimeValue - TimeZoneOffset;

        exit(Format(UTCDateTime, 0, '<Year4><Month,2><Day,2>T<Hours24><Minutes,2><Seconds,2>Z'));
    end;

    procedure GetICSDateString(DateTimeValue: DateTime): Text
    begin
        exit(Format(DateTimeValue, 0, '<Year4><Month,2><Day,2>'));
    end;
}
