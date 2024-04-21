codeunit 80000 "GDRGeolocation"
{
    var
        decLatitude: Decimal;
        decLongitude: Decimal;
        txtLatitude: Text;
        txtLongitude: Text;
        GeolocationSetupRead: Boolean;
        GDRGeoSetup: Record GDRGeolocationSetup;
        Geolocation: Codeunit Geolocation;

    #region Setup
    procedure GetGeolocationSetup()
    begin
        if not GeolocationSetupRead then
            GDRGeoSetup.Get();

        GeolocationSetupRead := true;

    end;
    /// <summary>
    /// https://github.com/microsoft/BCApps/tree/main/src/System%20Application/App/Geolocation
    /// </summary>
    procedure GDRGetLocation()
    begin
        Geolocation.SetHighAccuracy(true);
        if Geolocation.RequestGeolocation() then
            Geolocation.GetGeolocation(decLatitude, decLongitude);

        txtLatitude := format(decLatitude);
        txtLongitude := format(decLongitude);

        txtLatitude := txtLatitude.replace(',', '.');
        txtLongitude := txtLongitude.replace(',', '.');
    end;

    procedure GDR_GetJsonToken(xJsonObject: JsonObject; TokenKey: Text; posHead: Integer) xJsonToken: JsonToken;
    var
        jsonEmpty: Text;
        xNewJsonObject: JsonObject;
    begin
        jsonEmpty := '{"Empty":"","EmptyBool":false,"EmptyInt":0,"EmptyDate":"0D"}';
        if not xJsonObject.Get(TokenKey, xJsonToken) then begin
            case poshead of
                0:
                    begin
                        xNewJsonObject.ReadFrom(jsonEmpty);
                        xNewJsonObject.Get('Empty', xJsonToken);
                    end;
                1:
                    begin
                        xNewJsonObject.ReadFrom(jsonEmpty);
                        xNewJsonObject.Get('EmptyBool', xJsonToken);
                    end;
                2:
                    begin
                        xNewJsonObject.ReadFrom(jsonEmpty);
                        xNewJsonObject.Get('EmptyInt', xJsonToken);
                    end;
                3:
                    begin
                        xNewJsonObject.ReadFrom(jsonEmpty);
                        xNewJsonObject.Get('EmptyDate', xJsonToken);
                    end;
            end;
        end;
    end;

    #endregion Setup

    #region whereami
    /// <summary>
    /// https://learn.microsoft.com/en-us/rest/api/maps/search/get-search-address-reverse?view=rest-maps-1.0&tabs=HTTP
    /// </summary>
    procedure GDR_GetWhereAmI()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
        Result: text;
    begin
        GetGeolocationSetup();
        GDRGetLocation();
        if GDRGeoSetup."Api Key Azure Maps" <> '' then begin
            Client.DefaultRequestHeaders.Add('subscription-key', GDRGeoSetup."Api Key Azure Maps");
            url := 'https://atlas.microsoft.com/search/address/reverse/json?api-version=1.0&query=' + txtLatitude + ',' + txtLongitude + '';

            if not Client.Get(Url, Response) then
                if Response.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Azure Maps failed\ %1', GetLastErrorText());

            if not Response.IsSuccessStatusCode then
                Error('Request to Azure Maps failed\%1 %2', Response.HttpStatusCode, Response.ReasonPhrase);

            Response.Content.ReadAs(Result);
            GDR_JSONGetWhereAmI(Result);
        end;
    end;

    procedure GDR_JSONGetWhereAmI(result: text)
    var
        xJsonObject: JsonObject;
        xJsonToken: JsonToken;

        xJsonArray: JsonArray;

        xJsonTokenLines: JsonToken;
        xJsonObjectLines: JsonObject;

        xJsonTokenaddress: JsonToken;
        xJsonObjectaddress: JsonObject;

        recGDRGeoWhereAmI: Record GDRGeoWhereAmI;
        i: Integer;
    begin
        recGDRGeoWhereAmI.DeleteAll();
        if not xJsonObject.ReadFrom(result) then
            Error('');

        if xJsonObject.Get('addresses', xJsonToken) then begin
            xJsonArray := xJsonToken.AsArray();

            for i := 0 to xJsonArray.Count - 1 do begin
                xJsonArray.Get(i, xJsonTokenLines);
                xJsonObjectLines := xJsonTokenLines.AsObject;

                recGDRGeoWhereAmI.Init();
                recGDRGeoWhereAmI.code := i + 1;
                if xJsonObjectLines.Get('address', xJsonTokenaddress) then begin
                    xJsonObjectaddress := xJsonTokenaddress.AsObject;
                    recGDRGeoWhereAmI.buildingNumber := GDR_GetJsonToken(xJsonObjectaddress, 'buildingNumber', 0).AsValue().AsText();
                    recGDRGeoWhereAmI.streetNameAndNumber := GDR_GetJsonToken(xJsonObjectaddress, 'streetNameAndNumber', 0).AsValue().AsText();
                    recGDRGeoWhereAmI.countryCode := GDR_GetJsonToken(xJsonObjectaddress, 'countryCode', 0).AsValue().AsText();
                    recGDRGeoWhereAmI.countrySubdivision := GDR_GetJsonToken(xJsonObjectaddress, 'countrySubdivision', 0).AsValue().AsText();
                    recGDRGeoWhereAmI.countrySecondarySubdivision := GDR_GetJsonToken(xJsonObjectaddress, 'countrySecondarySubdivision', 0).AsValue().AsText();
                    recGDRGeoWhereAmI.postalCode := GDR_GetJsonToken(xJsonObjectaddress, 'postalCode', 0).AsValue().AsText();
                    recGDRGeoWhereAmI.neighbourhood := GDR_GetJsonToken(xJsonObjectaddress, 'neighbourhood', 0).AsValue().AsText();
                    recGDRGeoWhereAmI.Insert();
                end;
            end;
        end;
    end;

    #endregion whereami

    #region whereamiimage
    /// <summary>
    /// https://learn.microsoft.com/en-us/rest/api/maps/render/get-map-image?view=rest-maps-1.0&tabs=HTTP
    /// </summary>
    procedure GDR_GetWhereAmIImage()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
        Result: InStream;
    begin
        GetGeolocationSetup();
        GDRGetLocation();
        if GDRGeoSetup."Api Key Azure Maps" <> '' then begin
            Client.DefaultRequestHeaders.Add('subscription-key', GDRGeoSetup."Api Key Azure Maps");
            url := 'https://atlas.microsoft.com/map/static/png?api-version=1.0&layer=basic&zoom=14&style=main&view=Auto&height=700&Width=700&center=' + txtLongitude + ',' + txtLatitude + '';

            if not Client.Get(Url, Response) then
                if Response.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Azure Maps failed\ %1', GetLastErrorText());

            if not Response.IsSuccessStatusCode then
                Error('Request to Azure Maps failed\%1 %2', Response.HttpStatusCode, Response.ReasonPhrase);

            Response.Content.ReadAs(Result);
            GDR_GetWhereAmIImage(Result);
        end;
    end;

    procedure GDR_GetWhereAmIImage(result: InStream)
    var
        recGDRGeoWhereAmIImage: Record GDRGeoWhereAmIImage;
        i: Integer;
    begin
        recGDRGeoWhereAmIImage.DeleteAll();

        recGDRGeoWhereAmIImage.Init();
        recGDRGeoWhereAmIImage.code := i + 1;
        Clear(recGDRGeoWhereAmIImage.image);
        recGDRGeoWhereAmIImage.image.ImportStream(result, 'Mapa.png');
        recGDRGeoWhereAmIImage.Insert();

    end;

    #endregion whereamiimage

    #region poi
    /// <summary>
    /// https://learn.microsoft.com/en-us/rest/api/maps/search/get-search-poi?view=rest-maps-1.0&tabs=HTTP
    /// </summary>
    procedure GDR_GetPOI()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
        Result: text;
    begin
        GetGeolocationSetup();
        GDRGetLocation();
        if ((GDRGeoSetup."Api Key Azure Maps" <> '') AND
        (GDRGeoSetup.POI <> '')) then begin
            Client.DefaultRequestHeaders.Add('subscription-key', GDRGeoSetup."Api Key Azure Maps");
            url := 'https://atlas.microsoft.com/search/poi/json?api-version=1.0&query=' + GDRGeoSetup.POI + '&limit=5&lat=' + txtLatitude + '&lon=' + txtLongitude + '&radius=8046';



            if not Client.Get(Url, Response) then
                if Response.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Azure Maps failed\ %1', GetLastErrorText());

            if not Response.IsSuccessStatusCode then
                Error('Request to Azure Maps failed\%1 %2', Response.HttpStatusCode, Response.ReasonPhrase);

            Response.Content.ReadAs(Result);
            GDR_JSONGetPOI(Result);
        end;
    end;

    procedure GDR_JSONGetPOI(result: text)
    var
        xJsonObject: JsonObject;
        xJsonToken: JsonToken;
        xJsonArray: JsonArray;

        xJsonTokenLines: JsonToken;
        xJsonObjectLines: JsonObject;

        xJsonTokenpoi: JsonToken;
        xJsonArraypoi: JsonArray;
        xJsonObjectpoi: JsonObject;
        xJsonTokenLinespoi: JsonToken;

        xJsonTokenbrand: JsonToken;
        xJsonObjectbrand: JsonObject;

        xJsonTokencla: JsonToken;
        xJsonObjectcla: JsonObject;

        xJsonTokenaddress: JsonToken;
        xJsonObjectaddress: JsonObject;

        recGDRGeoPOI: Record GDRGeoPOI;
        i: Integer;
        ipoi: Integer;
    begin
        recGDRGeoPOI.DeleteAll();
        if not xJsonObject.ReadFrom(result) then
            Error('');

        if xJsonObject.Get('results', xJsonToken) then begin
            xJsonArray := xJsonToken.AsArray();

            for i := 0 to xJsonArray.Count - 1 do begin
                xJsonArray.Get(i, xJsonTokenLines);
                xJsonObjectLines := xJsonTokenLines.AsObject;

                recGDRGeoPOI.Init();
                recGDRGeoPOI.code := i + 1;
                if xJsonObjectLines.Get('poi', xJsonTokenpoi) then begin
                    xJsonObjectpoi := xJsonTokenpoi.AsObject;
                    recGDRGeoPOI.poi_name := GDR_GetJsonToken(xJsonObjectpoi, 'name', 0).AsValue().AsText();

                    if xJsonObjectpoi.Get('brands', xJsonTokenbrand) then begin
                        xJsonArraypoi := xJsonTokenbrand.AsArray();

                        for ipoi := 0 to xJsonArraypoi.Count - 1 do begin
                            xJsonArraypoi.Get(ipoi, xJsonTokenLinespoi);
                            xJsonObjectbrand := xJsonTokenLinespoi.AsObject;

                            recGDRGeoPOI.poi_brands_name := GDR_GetJsonToken(xJsonObjectbrand, 'name', 0).AsValue().AsText();
                        end;

                    end;

                    if xJsonObjectpoi.Get('classifications', xJsonTokencla) then begin
                        xJsonArraypoi := xJsonTokencla.AsArray();

                        for ipoi := 0 to xJsonArraypoi.Count - 1 do begin
                            xJsonArraypoi.Get(ipoi, xJsonTokenLinespoi);
                            xJsonObjectcla := xJsonTokenLinespoi.AsObject;

                            recGDRGeoPOI.poi_categories := GDR_GetJsonToken(xJsonObjectcla, 'code', 0).AsValue().AsText();
                        end;
                    end;
                end;
                if xJsonObjectLines.Get('address', xJsonTokenaddress) then begin
                    xJsonObjectaddress := xJsonTokenaddress.AsObject;
                    recGDRGeoPOI.address_freeformAddress := GDR_GetJsonToken(xJsonObjectaddress, 'freeformAddress', 0).AsValue().AsText();
                end;

                recGDRGeoPOI.Insert();
            end;
        end;
    end;

    #endregion poi

    #region Weather
    /// <summary>
    /// https://learn.microsoft.com/en-us/azure/azure-maps/how-to-request-weather-data
    /// </summary>
    procedure GDR_GetWeather()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
        Result: text;
    begin
        GetGeolocationSetup();
        GDRGetLocation();
        if GDRGeoSetup."Api Key Azure Maps" <> '' then begin
            Client.DefaultRequestHeaders.Add('subscription-key', GDRGeoSetup."Api Key Azure Maps");
            url := 'https://atlas.microsoft.com/weather/currentConditions/json?api-version=1.0&query=' + txtLatitude + ',' + txtLongitude + '';

            if not Client.Get(Url, Response) then
                if Response.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Azure Maps failed\ %1', GetLastErrorText());

            if not Response.IsSuccessStatusCode then
                Error('Request to Azure Maps failed\%1 %2', Response.HttpStatusCode, Response.ReasonPhrase);

            Response.Content.ReadAs(Result);
            GDR_JSONGetWeather(Result);
        end;
    end;

    procedure GDR_JSONGetWeather(result: text)
    var
        xJsonObject: JsonObject;
        xJsonToken: JsonToken;

        xJsonArray: JsonArray;

        xJsonTokenLines: JsonToken;
        xJsonObjectLines: JsonObject;

        xJsonTokentemperature: JsonToken;
        xJsonObjecttemperature: JsonObject;

        recGDRGeoWeather: Record GDRGeoWeather;
        i: Integer;
    begin
        recGDRGeoWeather.DeleteAll();
        if not xJsonObject.ReadFrom(result) then
            Error('');

        if xJsonObject.Get('results', xJsonToken) then begin
            xJsonArray := xJsonToken.AsArray();

            for i := 0 to xJsonArray.Count - 1 do begin
                xJsonArray.Get(i, xJsonTokenLines);
                xJsonObjectLines := xJsonTokenLines.AsObject;

                recGDRGeoWeather.Init();
                recGDRGeoWeather.code := i + 1;
                recGDRGeoWeather.dateTime := GDR_GetJsonToken(xJsonObjectLines, 'dateTime', 0).AsValue().AsText();
                recGDRGeoWeather.phrase := GDR_GetJsonToken(xJsonObjectLines, 'phrase', 0).AsValue().AsText();
                if xJsonObjectLines.Get('temperature', xJsonTokentemperature) then begin
                    xJsonObjecttemperature := xJsonTokentemperature.AsObject;
                    recGDRGeoWeather.temperaturevalue := GDR_GetJsonToken(xJsonObjecttemperature, 'value', 0).AsValue().AsText();
                    recGDRGeoWeather.temperatureunit := GDR_GetJsonToken(xJsonObjecttemperature, 'unit', 0).AsValue().AsText();
                    recGDRGeoWeather.Insert();
                end;
            end;
        end;
    end;

    #endregion Weather
}
