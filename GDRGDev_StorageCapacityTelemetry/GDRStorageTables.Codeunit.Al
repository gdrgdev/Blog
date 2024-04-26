codeunit 80003 GDRStorageTables
{
    //https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/administration-center-api_authorizedaadapps
    var
        cuGDRApiMgt: codeunit GDRApiMgt;

    trigger OnRun()
    begin
        GDRgetstoragequotas();
        GDRgetusedstorage();
    end;

    #region StorageQuotas
    procedure GDRgetstoragequotas()
    var
        txtToken: text;
        HttpClient: HttpClient;
        lblURL: Label 'https://api.businesscentral.dynamics.com/admin/v2.20/environments/quotas';
        HttpResponseMessage: HttpResponseMessage;
        txtResult: text;
    begin
        txtToken := cuGDRApiMgt.GDRgetToken();
        if txtToken <> '' then begin
            HttpClient.DefaultRequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', txtToken));
            HttpClient.DefaultRequestHeaders.Add('Accept', 'application/json');
            if not HttpClient.Get(lblURL, HttpResponseMessage) then
                if HttpResponseMessage.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Business Central failed\ %1', GetLastErrorText());

            if not HttpResponseMessage.IsSuccessStatusCode then
                Error('Request to Business Central failed\%1 %2', HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase);

            HttpResponseMessage.Content.ReadAs(txtResult);
            GDRgetstoragequotasJson(txtResult);
        end;
    end;

    local procedure GDRgetstoragequotasJson(txtJsonString: text)
    var
        recGDRStorageenvironmentsCount: Record GDRStorageenvironmentsCount;
        recGDRStorageTotalTelemetry: Record GDRStorageTotalTelemetry;
        recCompanyInformation: Record "Company Information";

        JsonResponse: JsonObject;
        JsonTokenValue: JsonToken;

        JsonResponsestorageInKilobytes: JsonObject;
        JsonResponseenvironmentsCount: JsonObject;

        intEnvironmentTotal: Integer;
        intStorageEnvironmentsCount: integer;
    begin
        intEnvironmentTotal := 4;

        If recCompanyInformation.Get() then;

        recGDRStorageenvironmentsCount.DeleteAll();
        recGDRStorageTotalTelemetry.DeleteAll();

        If JsonResponse.ReadFrom(txtJsonString) then begin
            if JsonResponse.Get('environmentsCount', JsonTokenValue) then begin
                JsonResponsestorageInKilobytes := JsonTokenValue.AsObject();
                recGDRStorageenvironmentsCount.Init();
                recGDRStorageenvironmentsCount.code += 1;
                recGDRStorageenvironmentsCount.production := cuGDRApiMgt.GDRGetJsonToken(JsonResponsestorageInKilobytes, 'production', 0).AsValue().AsInteger();
                recGDRStorageenvironmentsCount.sandbox := cuGDRApiMgt.GDRGetJsonToken(JsonResponsestorageInKilobytes, 'sandbox', 0).AsValue().AsInteger();
                recGDRStorageenvironmentsCount.datetime := CurrentDateTime;
                recGDRStorageenvironmentsCount.Insert();
            end;


            if JsonResponse.Get('storageInKilobytes', JsonTokenValue) then begin
                JsonResponseenvironmentsCount := JsonTokenValue.AsObject();
                recGDRStorageTotalTelemetry.Init();
                recGDRStorageTotalTelemetry.code += 1;
                recGDRStorageTotalTelemetry.default := cuGDRApiMgt.GDRGetJsonToken(JsonResponseenvironmentsCount, 'default', 0).AsValue().AsInteger();
                recGDRStorageTotalTelemetry.userLicenses := cuGDRApiMgt.GDRGetJsonToken(JsonResponseenvironmentsCount, 'userLicenses', 0).AsValue().AsInteger();
                recGDRStorageTotalTelemetry.additionalCapacity := cuGDRApiMgt.GDRGetJsonToken(JsonResponseenvironmentsCount, 'additionalCapacity', 0).AsValue().AsInteger();
                recGDRStorageTotalTelemetry.total := cuGDRApiMgt.GDRGetJsonToken(JsonResponseenvironmentsCount, 'total', 0).AsValue().AsInteger();
                recGDRStorageTotalTelemetry.datetime := CurrentDateTime;
                recGDRStorageTotalTelemetry.Insert();
            end;

            recCompanyInformation.GDRStorageEnvironmentsCount :=
                round((intEnvironmentTotal / (recGDRStorageenvironmentsCount.production + recGDRStorageenvironmentsCount.sandbox)) * 100, 1, '=');
            recCompanyInformation.Modify();
        end;
    end;
    #endregion StorageQuotas

    #region usedstorage
    procedure GDRgetusedstorage()
    var
        txtToken: text;
        HttpClient: HttpClient;
        lblURL: Label 'https://api.businesscentral.dynamics.com/admin/v2.20/environments/usedstorage';
        HttpResponseMessage: HttpResponseMessage;
        txtResult: text;
    begin
        txtToken := cuGDRApiMgt.GDRgetToken();
        if txtToken <> '' then begin
            HttpClient.DefaultRequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', txtToken));
            HttpClient.DefaultRequestHeaders.Add('Accept', 'application/json');
            if not HttpClient.Get(lblURL, HttpResponseMessage) then
                if HttpResponseMessage.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Business Central failed\ %1', GetLastErrorText());

            if not HttpResponseMessage.IsSuccessStatusCode then
                Error('Request to Business Central failed\%1 %2', HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase);

            HttpResponseMessage.Content.ReadAs(txtResult);
            GDRgetusedstorageJson(txtResult);
        end;
    end;

    local procedure GDRgetusedstorageJson(txtJsonString: text)
    var
        recGDRStorageTelemetry: Record GDRStorageTelemetry;
        recCompanyInformation: Record "Company Information";
        recGDRStorageTotalTelemetry: Record GDRStorageTotalTelemetry;

        JsonResponse: JsonObject;
        JsonTokenValue: JsonToken;

        JsonValuesArray: JsonArray;
        JsonTokenValueArray: JsonToken;

        JsonObejctDetalle: JsonObject;

        inttotalcapacity: Integer;
        inttotalcurrentcapacity: Integer;
    begin
        inttotalcapacity := 0;
        inttotalcurrentcapacity := 0;

        If recCompanyInformation.Get() then;

        recGDRStorageTelemetry.DeleteAll();

        If JsonResponse.ReadFrom(txtJsonString) then begin
            if JsonResponse.Get('value', JsonTokenValue) then begin
                JsonValuesArray := JsonTokenValue.AsArray();

                foreach JsonTokenValueArray in JsonValuesArray do begin
                    JsonObejctDetalle := JsonTokenValueArray.AsObject();
                    recGDRStorageTelemetry.Init();
                    recGDRStorageTelemetry.code += 1;
                    recGDRStorageTelemetry.environmentName := cuGDRApiMgt.GDRGetJsonToken(JsonObejctDetalle, 'environmentName', 0).AsValue().AsText();
                    recGDRStorageTelemetry.environmentType := cuGDRApiMgt.GDRGetJsonToken(JsonObejctDetalle, 'environmentType', 0).AsValue().AsText();
                    recGDRStorageTelemetry.databaseStorageInKilobytes := cuGDRApiMgt.GDRGetJsonToken(JsonObejctDetalle, 'databaseStorageInKilobytes', 0).AsValue().AsInteger();
                    inttotalcurrentcapacity := inttotalcurrentcapacity + recGDRStorageTelemetry.databaseStorageInKilobytes;
                    recGDRStorageTelemetry.datetime := CurrentDateTime;
                    recGDRStorageTelemetry.link := '';
                    recGDRStorageTelemetry.Insert();

                end;
            end;
        end;

        recGDRStorageTotalTelemetry.Reset();
        If recGDRStorageTotalTelemetry.FindLast() THEN begin
            inttotalcapacity := recGDRStorageTotalTelemetry.total;
        end;

        recCompanyInformation.GDRStorageTotal := round((inttotalcurrentcapacity / inttotalcapacity) * 100, 1, '=');
        recCompanyInformation.GDRStorageTotal := 82;
        recCompanyInformation.Modify();
    end;
    #endregion usedstorage


}