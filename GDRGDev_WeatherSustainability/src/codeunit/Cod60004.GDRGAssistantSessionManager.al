codeunit 60004 "GDRG Assistant Session Manager"
{
    Permissions = tabledata "GDRG Assistant Session" = RIMD;

    procedure GetAssistantSessionData(PromptText: Text): Boolean
    var
        APIConnectionManager: Codeunit "GDRG API Connection Manager";
        JSONHelper: Codeunit "GDRG JSON Helper";
        JsonObj: JsonObject;
        Endpoint: Text;
        ResponseText: Text;
        RequestBody: Text;
        EndpointLbl: Label '/assistant/session', Locked = true;
    begin
        Endpoint := EndpointLbl;

        RequestBody := CreateRequestBody(PromptText);

        ResponseText := APIConnectionManager.MakeAPICallWithBody(Endpoint, 'POST', RequestBody);

        if ResponseText = '' then
            exit(false);

        if not JSONHelper.ParseJsonObject(ResponseText, JsonObj) then
            exit(false);

        exit(ProcessAssistantResponse(JsonObj));
    end;

    local procedure CreateRequestBody(PromptText: Text): Text
    var
        JsonObj: JsonObject;
        JsonText: Text;
    begin
        JsonObj.Add('prompt', PromptText);
        JsonObj.WriteTo(JsonText);
        exit(JsonText);
    end;

    local procedure ProcessAssistantResponse(JsonObj: JsonObject): Boolean
    var
        AssistantSession: Record "GDRG Assistant Session";
    begin
        AssistantSession.Init();
        AssistantSession."Entry No." := 0;

        ProcessBasicFields(JsonObj, AssistantSession);

        ProcessCurrentWeatherData(JsonObj, AssistantSession);

        ProcessWeatherAlerts(JsonObj, AssistantSession);

        exit(AssistantSession.Insert(true));
    end;

    local procedure ProcessBasicFields(JsonObj: JsonObject; var AssistantSession: Record "GDRG Assistant Session")
    var
        JSONHelper: Codeunit "GDRG JSON Helper";
    begin
        AssistantSession.Answer := CopyStr(JSONHelper.GetTextValue(JsonObj, 'answer'), 1, 2048);
        AssistantSession."Current UTC Time" := CurrentDateTime();
    end;

    local procedure ProcessCurrentWeatherData(JsonObj: JsonObject; var AssistantSession: Record "GDRG Assistant Session")
    var
        JSONHelper: Codeunit "GDRG JSON Helper";
        CurrentObj: JsonObject;
        CurrentToken: JsonToken;
    begin
        if not JsonObj.Get('current', CurrentToken) then
            exit;

        if not JSONHelper.GetJsonObject(CurrentToken, CurrentObj) then
            exit;

        AssistantSession."Current Temperature" := JSONHelper.GetDecimalValue(CurrentObj, 'temp');
        AssistantSession."Current Feels Like" := JSONHelper.GetDecimalValue(CurrentObj, 'feels_like');
        AssistantSession."Current Humidity" := JSONHelper.GetIntegerValue(CurrentObj, 'humidity');

        ProcessWeatherDescription(CurrentObj, AssistantSession);
    end;

    local procedure ProcessWeatherDescription(CurrentObj: JsonObject; var AssistantSession: Record "GDRG Assistant Session")
    var
        JSONHelper: Codeunit "GDRG JSON Helper";
        WeatherToken: JsonToken;
        WeatherObj: JsonObject;
        WeatherArrayToken: JsonToken;
    begin
        if not CurrentObj.Get('weather', WeatherArrayToken) then
            exit;

        if not WeatherArrayToken.IsArray() then
            exit;

        if not WeatherArrayToken.AsArray().Get(0, WeatherToken) then
            exit;

        if JSONHelper.GetJsonObject(WeatherToken, WeatherObj) then
            AssistantSession."Current Weather" := CopyStr(JSONHelper.GetTextValue(WeatherObj, 'description'), 1, 100);
    end;

    local procedure ProcessWeatherAlerts(JsonObj: JsonObject; var AssistantSession: Record "GDRG Assistant Session")
    var
        JSONHelper: Codeunit "GDRG JSON Helper";
        AlertToken: JsonToken;
        AlertObj: JsonObject;
        AlertsToken: JsonToken;
    begin
        if not JsonObj.Get('alerts', AlertsToken) then
            exit;

        if not AlertsToken.IsArray() then
            exit;

        if AlertsToken.AsArray().Count() = 0 then
            exit;

        if not AlertsToken.AsArray().Get(0, AlertToken) then
            exit;

        if not JSONHelper.GetJsonObject(AlertToken, AlertObj) then
            exit;

        ProcessAlertData(AlertObj, AssistantSession);
    end;

    local procedure ProcessAlertData(AlertObj: JsonObject; var AssistantSession: Record "GDRG Assistant Session")
    var
        JSONHelper: Codeunit "GDRG JSON Helper";
    begin
        AssistantSession."Alert Event" := CopyStr(JSONHelper.GetTextValue(AlertObj, 'event'), 1, 100);
        AssistantSession."Alert Start" := UnixTimestampToDateTime(JSONHelper.GetBigIntegerValue(AlertObj, 'start'));
        AssistantSession."Alert End" := UnixTimestampToDateTime(JSONHelper.GetBigIntegerValue(AlertObj, 'end'));
        AssistantSession."Alert Description" := CopyStr(JSONHelper.GetTextValue(AlertObj, 'description'), 1, 500);
        AssistantSession."Alert Sender Name" := CopyStr(JSONHelper.GetTextValue(AlertObj, 'sender_name'), 1, 100);
        AssistantSession."Alert Tags" := CopyStr(JSONHelper.GetTextValue(AlertObj, 'tags'), 1, 250);
    end;

    local procedure UnixTimestampToDateTime(UnixTimestamp: BigInteger): DateTime
    var
        BaseDateTime: DateTime;
    begin
        if UnixTimestamp = 0 then
            exit(0DT);

        BaseDateTime := CreateDateTime(DMY2Date(1, 1, 1970), 0T);
        exit(BaseDateTime + (UnixTimestamp * 1000));
    end;
}
