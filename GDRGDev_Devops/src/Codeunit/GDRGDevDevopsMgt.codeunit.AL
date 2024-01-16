codeunit 50100 GDRGDevAzDevopsMgt
{
    var
        GDRGDevAccessToken: text;

    #region Utilities    
    local procedure GDRGDev_GetAuthorizationHeaderValue(parGDRGDevAccessToken: Text) Value: Text;
    begin
        Value := StrSubstNo('Basic %1', parGDRGDevAccessToken);
    end;

    procedure GDRGDev_GetJsonToken(xJsonObject: JsonObject; TokenKey: Text; posHead: Integer) xJsonToken: JsonToken;
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

    procedure GDRGDev_getAccessTokenAzureDevops(parGDRGDevDevopsSetup: Record GDRGDevAzDevopsSetup): text
    var
        GDRGDevBase64Convert: Codeunit "Base64 Convert";
    begin
        GDRGDevAccessToken := parGDRGDevDevopsSetup.AccessTokenAzureDevops;
        if GDRGDevAccessToken <> '' then begin
            GDRGDevAccessToken := GDRGDevBase64Convert.ToBase64(':' + GDRGDevAccessToken);
            exit(GDRGDevAccessToken);
        end;
        exit('');
    end;
    #endregion

    #region AzureDevopsProjects

    procedure GDRGDev_getAzureDevopsProjects
        (parGDRGDevAzDevopsSetup: Record GDRGDevAzDevopsSetup;
        var parGDRGDevAzDevopsProject: Record GDRGDevAzDevopsProject;
        parGDRGDevAzDevopsOrganization: code[50])
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
        Result: text;
    begin

        GDRGDev_getAccessTokenAzureDevops(parGDRGDevAzDevopsSetup);
        if GDRGDevAccessToken <> '' then begin
            Client.DefaultRequestHeaders.Add('Authorization', GDRGDev_GetAuthorizationHeaderValue(GDRGDevAccessToken));
            Client.DefaultRequestHeaders.Add('Connection', 'keep-alive');
            Client.DefaultRequestHeaders.Add('Accept', '*/*');
            url := 'https://dev.azure.com/' + parGDRGDevAzDevopsOrganization + '/_apis/projects??api-version=6.1-preview.4';

            if not Client.Get(Url, Response) then
                if Response.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Business Central failed\ %1', GetLastErrorText());

            if not Response.IsSuccessStatusCode then
                Error('Request to Business Central failed\%1 %2', Response.HttpStatusCode, Response.ReasonPhrase);

            Response.Content.ReadAs(Result);
            GDRGDev_JSONGetProjectAzureDevops(Result, parGDRGDevAzDevopsProject, parGDRGDevAzDevopsOrganization);
        end;
    end;

    procedure GDRGDev_JSONGetProjectAzureDevops
        (result: text;
        var parGDRGDevAzDevopsProject: Record GDRGDevAzDevopsProject;
        parGDRGDevAzDevopsOrganization: code[50])
    var
        xJsonObject: JsonObject;
        xJsonToken: JsonToken;
        xJsonArray: JsonArray;
        xJsonTokenLines: JsonToken;
        xJsonObjectLines: JsonObject;
        i: Integer;
        dateToText: text;
        textToDate: DateTime;
    begin
        parGDRGDevAzDevopsProject.SetFilter(id_UserID, UserId());
        if parGDRGDevAzDevopsProject.FindSet() then begin
            parGDRGDevAzDevopsProject.DeleteAll();
        end;

        if not xJsonObject.ReadFrom(result) then
            Error('');

        if xJsonObject.Get('value', xJsonToken) then begin
            xJsonArray := xJsonToken.AsArray();

            for i := 0 to xJsonArray.Count - 1 do begin
                xJsonArray.Get(i, xJsonTokenLines);
                xJsonObjectLines := xJsonTokenLines.AsObject;

                parGDRGDevAzDevopsProject.Init();
                parGDRGDevAzDevopsProject.Pk := i + 1;
                parGDRGDevAzDevopsProject.id_AzureDevopsOrganization := parGDRGDevAzDevopsOrganization;
                parGDRGDevAzDevopsProject.id_UserID := UserId();
                parGDRGDevAzDevopsProject.Validate(parGDRGDevAzDevopsProject.id_AzureDevopsProject, GDRGDev_GetJsonToken(xJsonObjectLines, 'id', 0).AsValue().AsText());
                parGDRGDevAzDevopsProject.Validate(parGDRGDevAzDevopsProject.name, GDRGDev_GetJsonToken(xJsonObjectLines, 'name', 0).AsValue().AsText());
                parGDRGDevAzDevopsProject.Validate(parGDRGDevAzDevopsProject.description, GDRGDev_GetJsonToken(xJsonObjectLines, 'description', 0).AsValue().AsText());
                parGDRGDevAzDevopsProject.Validate(parGDRGDevAzDevopsProject.url, GDRGDev_GetJsonToken(xJsonObjectLines, 'url', 0).AsValue().AsText());
                parGDRGDevAzDevopsProject.Validate(parGDRGDevAzDevopsProject.state, GDRGDev_GetJsonToken(xJsonObjectLines, 'state', 0).AsValue().AsText());
                parGDRGDevAzDevopsProject.Validate(parGDRGDevAzDevopsProject.revision, GDRGDev_GetJsonToken(xJsonObjectLines, 'revision', 0).AsValue().AsText());
                parGDRGDevAzDevopsProject.Validate(parGDRGDevAzDevopsProject.visibility, GDRGDev_GetJsonToken(xJsonObjectLines, 'visibility', 0).AsValue().AsText());
                dateToText := GDRGDev_GetJsonToken(xJsonObjectLines, 'lastUpdateTime', 0).AsValue().AsText();
                dateToText := dateToText.Substring(1, 19);
                dateToText := dateToText.Replace('T', ' ');
                Evaluate(textToDate, dateToText);
                parGDRGDevAzDevopsProject.Validate(parGDRGDevAzDevopsProject.lastUpdateTime, textToDate);
                parGDRGDevAzDevopsProject.Insert();
            end;
        end;
    end;

    #EndRegion

    #region AzureDevopsRepositories
    procedure GDRGDev_getAzureDevopsRepositories(
           parGDRGDevAzDevopsSetup: Record GDRGDevAzDevopsSetup;
           var parGDRGDevAzDevopsRepository: Record GDRGDevAzDevopsRepository;
           parGDRGDevAzDevopsOrganization: code[50];
           parid_AzDevopsProject: text)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
        Result: text;
    begin

        GDRGDev_getAccessTokenAzureDevops(parGDRGDevAzDevopsSetup);
        if GDRGDevAccessToken <> '' then begin
            Client.DefaultRequestHeaders.Add('Authorization', GDRGDev_GetAuthorizationHeaderValue(GDRGDevAccessToken));
            Client.DefaultRequestHeaders.Add('Accept', 'application/json');
            url := ' https://dev.azure.com/' + parGDRGDevAzDevopsOrganization + '/' + parid_AzDevopsProject + '/_apis/git/repositories?api-version=7.1-preview.1';

            if not Client.Get(Url, Response) then
                if Response.IsBlockedByEnvironment then
                    Error('Request was blocked by environment')
                else
                    Error('Request to Business Central failed\ %1', GetLastErrorText());

            if not Response.IsSuccessStatusCode then
                Error('Request to Business Central failed\%1 %2', Response.HttpStatusCode, Response.ReasonPhrase);

            Response.Content.ReadAs(Result);
            GDRGDev_JSONGetReposAzureDevops(Result, parGDRGDevAzDevopsRepository, parGDRGDevAzDevopsOrganization, parid_AzDevopsProject);
        end;
    end;

    procedure GDRGDev_JSONGetReposAzureDevops(
        result: text;
        var parGDRGDevAzDevopsRepository: Record GDRGDevAzDevopsRepository;
        parGDRGDevAzDevopsOrganization: code[50];
        parid_AzDevopsProject: text)
    var
        xJsonObject: JsonObject;
        xJsonToken: JsonToken;
        xJsonArray: JsonArray;
        xJsonArrayProject: JsonArray;
        xJsonTokenLines: JsonToken;
        xJsonTokenProject: JsonToken;
        xJsonObjectLines: JsonObject;
        xJsonObjectPro: JsonObject;
        i: Integer;
        j: Integer;
        dateToText: text;
        textToDate: DateTime;
    begin
        parGDRGDevAzDevopsRepository.SetFilter(id_UserID, UserId());
        if parGDRGDevAzDevopsRepository.FindSet() then begin
            parGDRGDevAzDevopsRepository.DeleteAll();
        end;

        if not xJsonObject.ReadFrom(result) then
            Error('');

        if xJsonObject.Get('value', xJsonToken) then begin
            xJsonArray := xJsonToken.AsArray();

            for i := 0 to xJsonArray.Count - 1 do begin
                xJsonArray.Get(i, xJsonTokenLines);
                xJsonObjectLines := xJsonTokenLines.AsObject;

                parGDRGDevAzDevopsRepository.Init();
                parGDRGDevAzDevopsRepository.Pk := i + 1;
                parGDRGDevAzDevopsRepository.id_AzureDevopsOrganization := parGDRGDevAzDevopsOrganization;
                parGDRGDevAzDevopsRepository.id := parid_AzDevopsProject;
                parGDRGDevAzDevopsRepository.id_UserID := UserId();
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.id, GDRGDev_GetJsonToken(xJsonObjectLines, 'id', 0).AsValue().AsText());
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.name, GDRGDev_GetJsonToken(xJsonObjectLines, 'name', 0).AsValue().AsText());
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.url, GDRGDev_GetJsonToken(xJsonObjectLines, 'url', 0).AsValue().AsText());
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.defaultBranch, GDRGDev_GetJsonToken(xJsonObjectLines, 'defaultBranch', 0).AsValue().AsText());
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.size, GDRGDev_GetJsonToken(xJsonObjectLines, 'size', 0).AsValue().AsDecimal());
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.remoteUrl, GDRGDev_GetJsonToken(xJsonObjectLines, 'remoteUrl', 0).AsValue().AsText());
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.sshUrl, GDRGDev_GetJsonToken(xJsonObjectLines, 'sshUrl', 0).AsValue().AsText());
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.webUrlLink, GDRGDev_GetJsonToken(xJsonObjectLines, 'webUrl', 0).AsValue().AsText());
                parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.isDisabled, GDRGDev_GetJsonToken(xJsonObjectLines, 'isDisabled', 0).AsValue().AsBoolean());
                if xJsonObjectLines.Get('project', xJsonTokenProject) then begin
                    xJsonObjectPro := xJsonTokenProject.AsObject;
                    parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.id_AzDevopsProject, GDRGDev_GetJsonToken(xJsonObjectPro, 'id', 0).AsValue().AsText());
                    parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.name_AzDevopsProject, GDRGDev_GetJsonToken(xJsonObjectPro, 'name', 0).AsValue().AsText());
                    parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.description_AzDevopsProject, GDRGDev_GetJsonToken(xJsonObjectPro, 'description', 0).AsValue().AsText());
                    parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.url_AzDevopsProject, GDRGDev_GetJsonToken(xJsonObjectPro, 'url', 0).AsValue().AsText());
                    parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.state_AzDevopsProject, GDRGDev_GetJsonToken(xJsonObjectPro, 'state', 0).AsValue().AsText());
                    parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.revision_AzDevopsProject, GDRGDev_GetJsonToken(xJsonObjectPro, 'sshUrl', 0).AsValue().AsText());
                    parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.visibility_AzDevopsProject, GDRGDev_GetJsonToken(xJsonObjectPro, 'sshUrl', 0).AsValue().AsText());
                    dateToText := GDRGDev_GetJsonToken(xJsonObjectPro, 'lastUpdateTime', 0).AsValue().AsText();
                    dateToText := dateToText.Substring(1, 19);
                    dateToText := dateToText.Replace('T', ' ');
                    Evaluate(textToDate, dateToText);
                    parGDRGDevAzDevopsRepository.Validate(parGDRGDevAzDevopsRepository.lastUpdateTime_AzDevopsProject, textToDate);
                    parGDRGDevAzDevopsRepository.Insert();
                end;
            end;
        end;
    end;


    #endregion

}
