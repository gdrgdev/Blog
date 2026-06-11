codeunit 88893 "GDRG WC Import"
{
    Permissions = tabledata "GDRG WC Match" = rimd,
                   tabledata "GDRG WC Setup" = rimd;

    var
        UnableToDownloadWorldCupDataErr: Label 'Unable to download World Cup data. Status code: %1', Comment = 'Shown when the World Cup JSON download fails; %1 is the HTTP status code.';
        InvalidJsonContentErr: Label 'Invalid JSON content.';
        JsonDoesNotContainMatchesErr: Label 'The JSON does not contain matches.';

    internal procedure RefreshMatches()
    var
        WCSetup: Record "GDRG WC Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: Text;
    begin
        Client.Get(GetSourceUrl(WCSetup), Response);
        if not Response.IsSuccessStatusCode() then
            Error(UnableToDownloadWorldCupDataErr, Response.HttpStatusCode());

        Response.Content().ReadAs(Content);
        ImportMatches(Content);
    end;

    local procedure ImportMatches(JsonText: Text)
    var
        RootToken: JsonToken;
        MatchesToken: JsonToken;
        MatchToken: JsonToken;
        Matches: JsonArray;
        MatchObject: JsonObject;
        Index: Integer;
    begin
        if not RootToken.ReadFrom(JsonText) then
            Error(InvalidJsonContentErr);

        if not RootToken.AsObject().Get('matches', MatchesToken) then
            Error(JsonDoesNotContainMatchesErr);

        Matches := MatchesToken.AsArray();
        for Index := 0 to Matches.Count() - 1 do begin
            Matches.Get(Index, MatchToken);
            MatchObject := MatchToken.AsObject();
            UpsertMatch(MatchObject, Index + 1);
        end;
    end;

    local procedure UpsertMatch(MatchObject: JsonObject; MatchNo: Integer)
    var
        MatchRec: Record "GDRG WC Match";
        ScoreToken: JsonToken;
        FinalScoreToken: JsonToken;
        FinalScoreArray: JsonArray;
        Score1Token: JsonToken;
        Score2Token: JsonToken;
    begin
        MatchRec.SetRange("Source Round", 1);
        MatchRec.SetRange("Source Match", MatchNo);
        if not MatchRec.FindFirst() then begin
            MatchRec.Init();
            MatchRec."Source Round" := 1;
            MatchRec."Source Match" := MatchNo;
            MatchRec."Entry No." := GetNextEntryNo();
            MatchRec.Insert(false);
        end;

        MatchRec.Round := CopyStr(GetText(MatchObject, 'round'), 1, MaxStrLen(MatchRec.Round));
        MatchRec."Match Date" := GetDate(MatchObject, 'date');
        MatchRec."Match Time" := CopyStr(GetText(MatchObject, 'time'), 1, MaxStrLen(MatchRec."Match Time"));
        MatchRec."Match DateTime" := GetMatchDateTime(MatchRec."Match Date", MatchRec."Match Time");
        MatchRec."Team 1" := CopyStr(GetText(MatchObject, 'team1'), 1, MaxStrLen(MatchRec."Team 1"));
        MatchRec."Team 2" := CopyStr(GetText(MatchObject, 'team2'), 1, MaxStrLen(MatchRec."Team 2"));
        MatchRec.Group := CopyStr(GetText(MatchObject, 'group'), 1, MaxStrLen(MatchRec.Group));
        MatchRec.Ground := CopyStr(GetText(MatchObject, 'ground'), 1, MaxStrLen(MatchRec.Ground));
        MatchRec."Has Result" := false;
        MatchRec."Result Type" := '';
        MatchRec."Team 1 Score" := 0;
        MatchRec."Team 2 Score" := 0;
        MatchRec."Last Updated At" := CurrentDateTime();

        if MatchObject.Get('score', ScoreToken) then
            if GetFinalScoreToken(ScoreToken.AsObject(), FinalScoreToken, MatchRec."Result Type") then begin
                FinalScoreArray := FinalScoreToken.AsArray();
                if FinalScoreArray.Count() >= 2 then begin
                    FinalScoreArray.Get(0, Score1Token);
                    FinalScoreArray.Get(1, Score2Token);
                    MatchRec."Team 1 Score" := Score1Token.AsValue().AsInteger();
                    MatchRec."Team 2 Score" := Score2Token.AsValue().AsInteger();
                    MatchRec."Has Result" := true;
                end;
            end;

        MatchRec.Modify(false);
    end;

    local procedure GetNextEntryNo(): Integer
    var
        MatchRec: Record "GDRG WC Match";
    begin
        if MatchRec.FindLast() then
            exit(MatchRec."Entry No." + 1);

        exit(1);
    end;

    local procedure GetText(MatchObject: JsonObject; PropertyName: Text): Text
    var
        ValueToken: JsonToken;
        ValueText: Text;
    begin
        if not MatchObject.Get(PropertyName, ValueToken) then
            exit('');

        ValueText := ValueToken.AsValue().AsText();
        exit(ValueText);
    end;

    local procedure GetFinalScoreToken(ScoreObject: JsonObject; var FinalScoreToken: JsonToken; var ResultType: Code[2]): Boolean
    begin
        if ScoreObject.Get('p', FinalScoreToken) then begin
            ResultType := 'P';
            exit(true);
        end;

        if ScoreObject.Get('et', FinalScoreToken) then begin
            ResultType := 'ET';
            exit(true);
        end;

        if ScoreObject.Get('ft', FinalScoreToken) then begin
            ResultType := 'FT';
            exit(true);
        end;

        ResultType := '';
        exit(false);
    end;

    local procedure GetDate(MatchObject: JsonObject; PropertyName: Text): Date
    var
        ValueToken: JsonToken;
    begin
        if not MatchObject.Get(PropertyName, ValueToken) then
            exit(0D);

        exit(EvaluateIsoDate(ValueToken.AsValue().AsText()));
    end;

    local procedure EvaluateIsoDate(ValueText: Text): Date
    var
        ParsedDate: Date;
    begin
        Evaluate(ParsedDate, ValueText, 9);
        exit(ParsedDate);
    end;

    local procedure GetSourceUrl(var WCSetup: Record "GDRG WC Setup"): Text
    begin
        if not WCSetup.Get('SETUP') then begin
            WCSetup.Init();
            WCSetup."Primary Key" := 'SETUP';
            WCSetup."Source URL" := 'https://raw.githubusercontent.com/openfootball/worldcup.json/master/2026/worldcup.json';
            WCSetup.Insert(false);
        end;

        exit(WCSetup."Source URL");
    end;

    local procedure GetMatchDateTime(MatchDate: Date; MatchTimeText: Text[30]): DateTime
    var
        TimeZone: Codeunit "Time Zone";
        TimeText: Text;
        OffsetText: Text;
        SpacePosition: Integer;
        LocalTime: Time;
        OffsetHours: Integer;
        MatchDateTime: DateTime;
        UserTimeZoneOffset: Duration;
    begin
        if MatchDate = 0D then
            exit(0DT);

        SpacePosition := StrPos(MatchTimeText, ' ');
        if SpacePosition > 0 then begin
            TimeText := CopyStr(MatchTimeText, 1, SpacePosition - 1);
            OffsetText := CopyStr(MatchTimeText, SpacePosition + 1);
        end else begin
            TimeText := MatchTimeText;
            OffsetText := '';
        end;

        if not Evaluate(LocalTime, TimeText) then
            exit(0DT);

        MatchDateTime := CreateDateTime(MatchDate, LocalTime);

        UserTimeZoneOffset := TimeZone.GetTimezoneOffset(MatchDateTime);

        if OffsetText = '' then
            exit(MatchDateTime);

        OffsetHours := GetUtcOffsetHours(OffsetText);
        MatchDateTime := MatchDateTime + UserTimeZoneOffset - (OffsetHours * 3600000);

        exit(MatchDateTime);
    end;

    local procedure GetUtcOffsetHours(OffsetText: Text): Integer
    var
        UtcPosition: Integer;
        HoursText: Text;
        OffsetHours: Integer;
    begin
        UtcPosition := StrPos(OffsetText, 'UTC');
        if UtcPosition = 0 then
            exit(0);

        HoursText := DelStr(OffsetText, 1, UtcPosition + 2);
        if not Evaluate(OffsetHours, HoursText) then
            exit(0);

        exit(OffsetHours);
    end;
}