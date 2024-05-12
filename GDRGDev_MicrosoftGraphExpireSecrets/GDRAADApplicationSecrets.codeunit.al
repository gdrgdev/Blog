codeunit 80002 GDRAADApplicationSecrets
{
    var
        cuGDRApiMgt: codeunit GDRApiMgt;

    #region suscriber
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    procedure GDROnAfterLoginGetAADApplicationSecrets();
    var
    begin

    end;

    [EventSubscriber(ObjectType::Page, Page::"AAD Application Card", 'OnOpenPageEvent', '', false, false)]
    procedure GDROnOpenPageEventAADCard(var Rec: Record "AAD Application")
    begin
        CheckExpiredSecrets(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"AAD Application List", 'OnOpenPageEvent', '', false, false)]
    procedure GDROnOpenPageEventAADList(var Rec: Record "AAD Application")
    var
        recAADApplication: record "AAD Application";
        recGDRAADApplicationSecrets: record GDRAADApplicationSecrets;
    begin
        recAADApplication.Reset();
        recAADApplication.SetRange(recAADApplication.CheckSecrets, true);
        IF recAADApplication.FindSet() then begin
            repeat
                CheckExpiredSecrets(recAADApplication);
            until recAADApplication.next = 0;
        end;
    end;

    local procedure CheckExpiredSecrets(var Rec: Record "AAD Application")
    var
        newNotification: Notification;
        newNotificationLbl: label 'You have secrets close to expire. Check out.';
        GotoAzurePortalLbl: label 'Go to Azure Portal.';
        recGDRAADApplicationSecrets: record GDRAADApplicationSecrets;
    begin
        recGDRAADApplicationSecrets.RESET;
        recGDRAADApplicationSecrets.SetRange(recGDRAADApplicationSecrets."Client Id", rec."Client Id");
        recGDRAADApplicationSecrets.SETRANGE(recGDRAADApplicationSecrets.monthtoexpire, true);
        IF recGDRAADApplicationSecrets.FindSet() then begin
            newNotification.Id := CreateGuid();
            newNotification.Message(newNotificationLbl);
            newNotification.Scope := NotificationScope::LocalScope;
            newNotification.AddAction(GotoAzurePortalLbl, codeunit::GDRAADAplicationSecretsNotif, 'GotoAzurePortal');
            newNotification.Send();
        end;
    end;
    #endregion suscriber 



    #region GetAADApplicationSecrets
    procedure GDRGetAADApplicationSecrets(parGUIDApp: Guid)
    var
        txtToken: text;
        HttpClient: HttpClient;
        lblURL: Label 'https://graph.microsoft.com/v1.0/applications';
        txtURL: Text;
        HttpResponseMessage: HttpResponseMessage;
        txtResult: text;
    begin
        txtToken := cuGDRApiMgt.GDRgetToken();
        if txtToken <> '' then begin

            txtURL := lblURL + '(appId=''' + parGUIDApp + ''')';
            txtURL := DelChr(txtURL, '=', '{');
            txtURL := DelChr(txtURL, '=', '}');

            HttpClient.DefaultRequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', txtToken));
            HttpClient.DefaultRequestHeaders.Add('Accept', 'application/json');
            if not HttpClient.Get(txtURL, HttpResponseMessage) then
                if HttpResponseMessage.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Microsoft Graph failed\ %1', GetLastErrorText());

            if not HttpResponseMessage.IsSuccessStatusCode then
                Error('Request to Microsoft Graph failed\%1 %2', HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase);

            HttpResponseMessage.Content.ReadAs(txtResult);
            GDRGetAADApplicationSecretsJson(txtResult, parGUIDApp);
        end;
    end;

    local procedure GDRGetAADApplicationSecretsJson(txtJsonString: text; parGUIDApp: Guid)
    var
        recGDRAADApplicationSecrets: Record GDRAADApplicationSecrets;
        JsonResponse: JsonObject;
        JsonTokenValue: JsonToken;
        JsonArraypasswordCredentials: JsonArray;
        JsonTokenpasswordCredentials: JsonToken;
        JsonObjectpasswordCredentials: JsonObject;
        datmonthtoexpire: Date;
        blnmonthtoexpire: Boolean;
        intFila: Integer;
        datToCompare: date;

    begin
        datToCompare := Today();
        //datToCompare := 20240707D;
        intFila := 0;

        recGDRAADApplicationSecrets.RESET;
        recGDRAADApplicationSecrets.SetRange(recGDRAADApplicationSecrets."Client Id", parGUIDApp);
        If recGDRAADApplicationSecrets.FindSet() then
            recGDRAADApplicationSecrets.DeleteAll();

        If JsonResponse.ReadFrom(txtJsonString) then begin
            if JsonResponse.Get('passwordCredentials', JsonTokenValue) then begin
                JsonArraypasswordCredentials := JsonTokenValue.AsArray();

                foreach JsonTokenpasswordCredentials in JsonArraypasswordCredentials do begin
                    blnmonthtoexpire := false;
                    JsonObjectpasswordCredentials := JsonTokenpasswordCredentials.AsObject();
                    intFila := intFila + 10;
                    recGDRAADApplicationSecrets.Init();
                    recGDRAADApplicationSecrets."Client Id" := parGUIDApp;
                    recGDRAADApplicationSecrets."Line No." := intFila;
                    recGDRAADApplicationSecrets.displayName := cuGDRApiMgt.GDRGetJsonToken(JsonObjectpasswordCredentials, 'displayName', 0).AsValue().AsText();
                    recGDRAADApplicationSecrets.startDateTime := cuGDRApiMgt.GDRGetJsonToken(JsonObjectpasswordCredentials, 'startDateTime', 0).AsValue().AsDateTime();
                    recGDRAADApplicationSecrets.endDateTime := cuGDRApiMgt.GDRGetJsonToken(JsonObjectpasswordCredentials, 'endDateTime', 0).AsValue().AsDateTime();
                    recGDRAADApplicationSecrets.startDate := System.DT2Date(recGDRAADApplicationSecrets.startDateTime);
                    recGDRAADApplicationSecrets.endDate := System.DT2Date(recGDRAADApplicationSecrets.endDateTime);

                    datmonthtoexpire := CalcDate('<-1M>', recGDRAADApplicationSecrets.endDate);
                    if datToCompare >= datmonthtoexpire then
                        blnmonthtoexpire := true;

                    recGDRAADApplicationSecrets.monthtoexpire := blnmonthtoexpire;
                    recGDRAADApplicationSecrets.monthtoexpiredate := datmonthtoexpire;
                    recGDRAADApplicationSecrets.Insert();
                end;


            end;

        end;
    end;
    #endregion GetAADApplicationSecrets
}
