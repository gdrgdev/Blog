codeunit 60003 "GDRG Weather Data Manager"
{
    Permissions = tabledata "GDRG Weather Data" = RIMD;

    procedure GetWeatherData(Lat: Decimal; Lon: Decimal; UnixTimestamp: BigInteger): Boolean
    var
        APIConnectionManager: Codeunit "GDRG API Connection Manager";
        JSONHelper: Codeunit "GDRG JSON Helper";
        JsonObj: JsonObject;
        Endpoint: Text;
        ResponseText: Text;
        EndpointLbl: Label '/data/3.0/onecall/timemachine?lat=%1&lon=%2&dt=%3&units=metric', Locked = true;
    begin
        Endpoint := StrSubstNo(EndpointLbl, Lat, Lon, UnixTimestamp);

        ResponseText := APIConnectionManager.MakeAPICall(Endpoint, 'GET');

        if ResponseText = '' then
            exit(false);

        if not JSONHelper.ParseJsonObject(ResponseText, JsonObj) then
            exit(false);

        exit(ProcessWeatherResponse(JsonObj, Lat, Lon, UnixTimestamp));
    end;

    local procedure ProcessWeatherResponse(JsonObj: JsonObject; Lat: Decimal; Lon: Decimal; UnixTimestamp: BigInteger): Boolean
    var
        WeatherData: Record "GDRG Weather Data";
        JSONHelper: Codeunit "GDRG JSON Helper";
        DataArray: JsonArray;
        DataToken: JsonToken;
        DataObject: JsonObject;
    begin
        if not JSONHelper.GetJsonArray(JsonObj, 'data', DataArray) then
            exit(false);

        if not DataArray.Get(0, DataToken) then
            exit(false);

        DataObject := DataToken.AsObject();

        if WeatherData.WeatherDataExists(Lat, Lon, UnixTimestamp) then begin
            if WeatherData.GetWeatherData(Lat, Lon, UnixTimestamp, WeatherData) then begin
                UpdateWeatherRecord(WeatherData, JsonObj, DataObject);
                WeatherData.Modify(true);
            end;
        end else begin
            WeatherData.Init();
            WeatherData.Latitude := Lat;
            WeatherData.Longitude := Lon;
            WeatherData."Unix Timestamp" := UnixTimestamp;

            WeatherData."Date Time" := CreateDateTime(DMY2Date(1, 1, 1970), 0T) + (UnixTimestamp * 1000);

            UpdateWeatherRecord(WeatherData, JsonObj, DataObject);
            WeatherData.Insert(true);
        end;

        exit(true);
    end;

    local procedure UpdateWeatherRecord(var WeatherData: Record "GDRG Weather Data"; RootObject: JsonObject; DataObject: JsonObject)
    var
        JSONHelper: Codeunit "GDRG JSON Helper";
        WeatherArray: JsonArray;
        WeatherToken: JsonToken;
        WeatherObject: JsonObject;
        SunriseUnix: BigInteger;
        SunsetUnix: BigInteger;
    begin
        WeatherData.Timezone := CopyStr(JSONHelper.GetTextValue(RootObject, 'timezone'), 1, MaxStrLen(WeatherData.Timezone));
        WeatherData."Timezone Offset" := JSONHelper.GetIntegerValue(RootObject, 'timezone_offset');

        WeatherData.Temperature := JSONHelper.GetDecimalValue(DataObject, 'temp');
        WeatherData."Feels Like" := JSONHelper.GetDecimalValue(DataObject, 'feels_like');
        WeatherData.Pressure := JSONHelper.GetIntegerValue(DataObject, 'pressure');
        WeatherData.Humidity := JSONHelper.GetIntegerValue(DataObject, 'humidity');
        WeatherData."Dew Point" := JSONHelper.GetDecimalValue(DataObject, 'dew_point');
        WeatherData."UV Index" := JSONHelper.GetDecimalValue(DataObject, 'uvi');
        WeatherData.Clouds := JSONHelper.GetIntegerValue(DataObject, 'clouds');
        WeatherData.Visibility := JSONHelper.GetIntegerValue(DataObject, 'visibility');
        WeatherData."Wind Speed" := JSONHelper.GetDecimalValue(DataObject, 'wind_speed');
        WeatherData."Wind Degree" := JSONHelper.GetIntegerValue(DataObject, 'wind_deg');
        WeatherData."Wind Gust" := JSONHelper.GetDecimalValue(DataObject, 'wind_gust');

        SunriseUnix := JSONHelper.GetBigIntegerValue(DataObject, 'sunrise');
        SunsetUnix := JSONHelper.GetBigIntegerValue(DataObject, 'sunset');

        if SunriseUnix > 0 then
            WeatherData."Sunrise Time" := CreateDateTime(DMY2Date(1, 1, 1970), 0T) + (SunriseUnix * 1000);
        if SunsetUnix > 0 then
            WeatherData."Sunset Time" := CreateDateTime(DMY2Date(1, 1, 1970), 0T) + (SunsetUnix * 1000);

        if JSONHelper.GetJsonArray(DataObject, 'weather', WeatherArray) then
            if WeatherArray.Get(0, WeatherToken) then begin
                WeatherObject := WeatherToken.AsObject();
                WeatherData."Weather ID" := JSONHelper.GetIntegerValue(WeatherObject, 'id');
                WeatherData."Weather Main" := CopyStr(JSONHelper.GetTextValue(WeatherObject, 'main'), 1, MaxStrLen(WeatherData."Weather Main"));
                WeatherData."Weather Description" := CopyStr(JSONHelper.GetTextValue(WeatherObject, 'description'), 1, MaxStrLen(WeatherData."Weather Description"));
                WeatherData."Weather Icon" := CopyStr(JSONHelper.GetTextValue(WeatherObject, 'icon'), 1, MaxStrLen(WeatherData."Weather Icon"));
            end;
    end;
}
