codeunit 60002 "GDRG Zip Code Manager"
{
    Permissions = tabledata "GDRG Zip Code Info" = RIMD;

    procedure GetZipCodeInfo(ZipCode: Code[20]; CountryCode: Code[10]): Boolean
    var
        APIConnectionManager: Codeunit "GDRG API Connection Manager";
        JSONHelper: Codeunit "GDRG JSON Helper";
        JsonObj: JsonObject;
        Endpoint: Text;
        ResponseText: Text;
        ZipParam: Text;
    begin
        if CountryCode <> '' then
            ZipParam := ZipCode + ',' + CountryCode
        else
            ZipParam := ZipCode;

        Endpoint := '/geo/1.0/zip?zip=' + ZipParam + '&limit=5';

        ResponseText := APIConnectionManager.MakeAPICall(Endpoint, 'GET');

        if ResponseText = '' then
            exit(false);

        if not JSONHelper.ParseJsonObject(ResponseText, JsonObj) then
            exit(false);

        exit(ProcessZipCodeResponse(JsonObj));
    end;

    local procedure ProcessZipCodeResponse(JsonObj: JsonObject): Boolean
    var
        ZipCodeInfo: Record "GDRG Zip Code Info";
        JSONHelper: Codeunit "GDRG JSON Helper";
        ZipCode: Code[20];
        CountryCode: Code[10];
        LocationName: Text[100];
        Latitude: Decimal;
        Longitude: Decimal;
    begin
        ZipCode := CopyStr(JSONHelper.GetTextValue(JsonObj, 'zip'), 1, MaxStrLen(ZipCode));
        CountryCode := CopyStr(JSONHelper.GetTextValue(JsonObj, 'country'), 1, MaxStrLen(CountryCode));
        LocationName := CopyStr(JSONHelper.GetTextValue(JsonObj, 'name'), 1, MaxStrLen(LocationName));
        Latitude := JSONHelper.GetDecimalValue(JsonObj, 'lat');
        Longitude := JSONHelper.GetDecimalValue(JsonObj, 'lon');

        if (ZipCode = '') or (CountryCode = '') then
            exit(false);

        if ZipCodeInfo.ZipCodeExists(ZipCode, CountryCode) then begin
            if ZipCodeInfo.GetZipCodeInfo(ZipCode, CountryCode, ZipCodeInfo) then begin
                ZipCodeInfo.Name := LocationName;
                ZipCodeInfo.Latitude := Latitude;
                ZipCodeInfo.Longitude := Longitude;
                ZipCodeInfo.Modify(true);
            end;
        end else begin
            ZipCodeInfo.Init();
            ZipCodeInfo."Zip Code" := ZipCode;
            ZipCodeInfo.Country := CountryCode;
            ZipCodeInfo.Name := LocationName;
            ZipCodeInfo.Latitude := Latitude;
            ZipCodeInfo.Longitude := Longitude;
            ZipCodeInfo.Insert(true);
        end;

        exit(true);
    end;
}
