codeunit 60000 "GDRG API Connection Manager"
{
    Permissions = tabledata "GDRG API Connection Setup" = RM;

    var
        InvalidResponseErr: Label 'Invalid response received: Status Code %1, Reason: %2', Comment = '%1 = Status code, %2 = Reason phrase';
        NoSetupErr: Label 'API Connection Setup not found. Please configure the connection first.';
        HttpRequestFailedErr: Label 'Failed to send HTTP request';
        URLOrAPIKeyEmptyErr: Label 'URL or API Key is empty';
        ErrorResponseLbl: Label 'Error Response: %1', Comment = '%1 = Response text';
        InvalidEndpointErr: Label 'Invalid endpoint format: %1', Comment = '%1 = Endpoint';

    local procedure ConfigureAuthentication(var HttpRequestMessage: HttpRequestMessage; APISetup: Record "GDRG API Connection Setup"; var FullUrl: Text)
    begin
        case APISetup."Authentication Type" of
            APISetup."Authentication Type"::"API Key Header":
                ConfigureAPIKeyHeader(HttpRequestMessage, APISetup);
            APISetup."Authentication Type"::"Bearer Token":
                ConfigureBearerToken(HttpRequestMessage, APISetup);
            APISetup."Authentication Type"::"API Key Query":
                ConfigureAPIKeyQuery(HttpRequestMessage, APISetup, FullUrl);
        end;
    end;

    local procedure ConfigureAPIKeyHeader(var HttpRequestMessage: HttpRequestMessage; APISetup: Record "GDRG API Connection Setup")
    var
        Headers: HttpHeaders;
        APIKeyValue: SecretText;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        APIKeyValue := APISetup."API Key Value";
        if APISetup."API Key Name" <> '' then
            Headers.Add(APISetup."API Key Name", APIKeyValue)
        else
            Headers.Add('X-API-Key', APIKeyValue);
    end;

    local procedure ConfigureBearerToken(var HttpRequestMessage: HttpRequestMessage; APISetup: Record "GDRG API Connection Setup")
    var
        Headers: HttpHeaders;
        AuthorizationValue: SecretText;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        AuthorizationValue := SecretText.SecretStrSubstNo('Bearer %1', APISetup."API Key Value");
        Headers.Add('Authorization', AuthorizationValue);
    end;

    local procedure ConfigureAPIKeyQuery(var HttpRequestMessage: HttpRequestMessage; APISetup: Record "GDRG API Connection Setup"; var FullUrl: Text)
    var
        KeyName: Text;
        APIKeyValue: Text;
    begin
        if APISetup."API Key Name" <> '' then
            KeyName := APISetup."API Key Name"
        else
            KeyName := 'api_key';

        APIKeyValue := APISetup."API Key Value";

        if FullUrl.Contains('?') then
            FullUrl := FullUrl + '&' + KeyName + '=' + APIKeyValue
        else
            FullUrl := FullUrl + '?' + KeyName + '=' + APIKeyValue;

        HttpRequestMessage.SetRequestUri(FullUrl);
    end;

    local procedure BuildFullUrl(BaseUrl: Text; Endpoint: Text): Text
    var
        FullUrl: Text;
    begin
        if Endpoint = '' then
            Error(InvalidEndpointErr, Endpoint);

        if Endpoint.StartsWith('http') then
            exit(Endpoint);

        if BaseUrl.EndsWith('/') and Endpoint.StartsWith('/') then
            FullUrl := BaseUrl + CopyStr(Endpoint, 2)
        else
            if not BaseUrl.EndsWith('/') and not Endpoint.StartsWith('/') then
                FullUrl := BaseUrl + '/' + Endpoint
            else
                FullUrl := BaseUrl + Endpoint;

        exit(FullUrl);
    end;

    procedure MakeAPICall(Endpoint: Text; Method: Text): Text
    begin
        exit(MakeAPICall(Endpoint, Method, true));
    end;

    procedure MakeAPICall(Endpoint: Text; Method: Text; IsManualCall: Boolean): Text
    var
        APISetup: Record "GDRG API Connection Setup";
        APICallLog: Record "GDRG API Call Log";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        Headers: HttpHeaders;
        FullUrl: Text;
        IsSuccess: Boolean;
        StartTime: DateTime;
        EndTime: DateTime;
        APIType: Enum "GDRG API Call Type";
    begin
        APISetup := APISetup.GetSetup();

        if (APISetup."Base URL" = '') or (APISetup."API Key Value" = '') then
            Error(NoSetupErr);

        FullUrl := BuildFullUrl(APISetup."Base URL", Endpoint);

        APIType := DetermineAPIType(Endpoint);

        HttpRequestMessage.Method(Method);
        HttpRequestMessage.SetRequestUri(FullUrl);

        ConfigureAuthentication(HttpRequestMessage, APISetup, FullUrl);

        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');

        StartTime := CurrentDateTime();

        IsSuccess := HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        EndTime := CurrentDateTime();

        if IsSuccess then begin
            HttpResponseMessage.Content().ReadAs(ResponseText);

            if HttpResponseMessage.IsSuccessStatusCode() then begin
                APICallLog.LogSuccessfulCall(
                    FullUrl,
                    APIType,
                    Method,
                    HttpResponseMessage.HttpStatusCode(),
                    1,
                    EndTime - StartTime,
                    IsManualCall);

                exit(ResponseText);
            end else begin
                APICallLog.LogFailedCall(
                    FullUrl,
                    APIType,
                    Method,
                    HttpResponseMessage.HttpStatusCode(),
                    StrSubstNo(InvalidResponseErr, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase()),
                    EndTime - StartTime,
                    IsManualCall);

                Error(InvalidResponseErr, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase());
            end;
        end else begin
            APICallLog.LogFailedCall(
                FullUrl,
                APIType,
                Method,
                0,
                HttpRequestFailedErr,
                EndTime - StartTime,
                IsManualCall);

            Error(HttpRequestFailedErr);
        end;
    end;

    procedure MakeAPICallWithDetails(Endpoint: Text; Method: Text; var StatusCode: Integer; var ReasonPhrase: Text): Text
    begin
        exit(MakeAPICallWithDetails(Endpoint, Method, StatusCode, ReasonPhrase, true));
    end;

    procedure MakeAPICallWithDetails(Endpoint: Text; Method: Text; var StatusCode: Integer; var ReasonPhrase: Text; IsManualCall: Boolean): Text
    var
        APISetup: Record "GDRG API Connection Setup";
        APICallLog: Record "GDRG API Call Log";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        Headers: HttpHeaders;
        FullUrl: Text;
        IsSuccess: Boolean;
        StartTime: DateTime;
        EndTime: DateTime;
        APIType: Enum "GDRG API Call Type";
    begin
        APISetup := APISetup.GetSetup();

        if (APISetup."Base URL" = '') or (APISetup."API Key Value" = '') then
            Error(NoSetupErr);

        FullUrl := BuildFullUrl(APISetup."Base URL", Endpoint);

        APIType := DetermineAPIType(Endpoint);

        HttpRequestMessage.Method(Method);
        HttpRequestMessage.SetRequestUri(FullUrl);

        ConfigureAuthentication(HttpRequestMessage, APISetup, FullUrl);

        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');

        StartTime := CurrentDateTime();

        IsSuccess := HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        EndTime := CurrentDateTime();

        if IsSuccess then begin
            HttpResponseMessage.Content().ReadAs(ResponseText);
            StatusCode := HttpResponseMessage.HttpStatusCode();
            ReasonPhrase := HttpResponseMessage.ReasonPhrase();

            if HttpResponseMessage.IsSuccessStatusCode() then begin
                APICallLog.LogSuccessfulCall(
                    FullUrl,
                    APIType,
                    Method,
                    StatusCode,
                    1,
                    EndTime - StartTime,
                    IsManualCall);

                exit(ResponseText);
            end else begin
                APICallLog.LogFailedCall(
                    FullUrl,
                    APIType,
                    Method,
                    StatusCode,
                    StrSubstNo(ErrorResponseLbl, ResponseText),
                    EndTime - StartTime,
                    IsManualCall);

                exit(StrSubstNo(ErrorResponseLbl, ResponseText));
            end;
        end else begin
            StatusCode := 0;
            ReasonPhrase := HttpRequestFailedErr;

            APICallLog.LogFailedCall(
                FullUrl,
                APIType,
                Method,
                0,
                HttpRequestFailedErr,
                EndTime - StartTime,
                IsManualCall);

            exit(HttpRequestFailedErr);
        end;
    end;

    procedure TestAPICall(Endpoint: Text; Method: Text): Text
    var
        APISetup: Record "GDRG API Connection Setup";
        APICallLog: Record "GDRG API Call Log";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        FullUrl: Text;
        IsSuccess: Boolean;
        StartTime: DateTime;
        EndTime: DateTime;
        APIType: Enum "GDRG API Call Type";
    begin
        APISetup := APISetup.GetSetup();

        if (APISetup."Base URL" = '') or (APISetup."API Key Value" = '') then begin
            UpdateConnectionStatus(APISetup, APISetup."Connection Status"::Failed, URLOrAPIKeyEmptyErr);
            Error(NoSetupErr);
        end;

        UpdateConnectionStatus(APISetup, APISetup."Connection Status"::Testing, '');
        Commit();

        FullUrl := BuildFullUrl(APISetup."Base URL", Endpoint);

        APIType := APIType::"Connection Test";

        HttpRequestMessage.Method(Method);
        HttpRequestMessage.SetRequestUri(FullUrl);

        ConfigureAuthentication(HttpRequestMessage, APISetup, FullUrl);

        StartTime := CurrentDateTime();

        IsSuccess := HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        EndTime := CurrentDateTime();

        if IsSuccess then begin
            HttpResponseMessage.Content().ReadAs(ResponseText);

            if HttpResponseMessage.IsSuccessStatusCode() then begin
                APICallLog.LogSuccessfulCall(
                    FullUrl,
                    APIType,
                    Method,
                    HttpResponseMessage.HttpStatusCode(),
                    1,
                    EndTime - StartTime,
                    true);

                UpdateConnectionStatus(APISetup, APISetup."Connection Status"::Connected, '');
                exit(ResponseText);
            end else begin
                APICallLog.LogFailedCall(
                    FullUrl,
                    APIType,
                    Method,
                    HttpResponseMessage.HttpStatusCode(),
                    StrSubstNo(InvalidResponseErr, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase()),
                    EndTime - StartTime,
                    true);

                UpdateConnectionStatus(APISetup, APISetup."Connection Status"::Failed,
                    StrSubstNo(InvalidResponseErr, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase()));
                Error(InvalidResponseErr, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase());
            end;
        end else begin
            APICallLog.LogFailedCall(
                FullUrl,
                APIType,
                Method,
                0,
                HttpRequestFailedErr,
                EndTime - StartTime,
                true);

            UpdateConnectionStatus(APISetup, APISetup."Connection Status"::Failed, HttpRequestFailedErr);
            Error(HttpRequestFailedErr);
        end;
    end;

    local procedure UpdateConnectionStatus(var APISetup: Record "GDRG API Connection Setup"; Status: Enum "GDRG API Connection Status"; ErrorMessage: Text)
    begin
        APISetup."Connection Status" := Status;
        APISetup."Last Test Date" := CurrentDateTime();
        APISetup."Last Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(APISetup."Last Error Message"));
        APISetup.Modify(false);
    end;

    local procedure DetermineAPIType(Endpoint: Text): Enum "GDRG API Call Type"
    var
        APIType: Enum "GDRG API Call Type";
        LowerEndpoint: Text;
    begin
        LowerEndpoint := LowerCase(Endpoint);

        if LowerEndpoint.Contains('/geo/') or LowerEndpoint.Contains('zip?') then
            exit(APIType::Geo);

        if LowerEndpoint.Contains('/data/') or LowerEndpoint.Contains('onecall') or LowerEndpoint.Contains('weather') then
            exit(APIType::Weather);

        exit(APIType::Other);
    end;

    procedure MakeAPICallWithBody(Endpoint: Text; Method: Text; RequestBody: Text): Text
    begin
        exit(MakeAPICallWithBody(Endpoint, Method, RequestBody, true));
    end;

    procedure MakeAPICallWithBody(Endpoint: Text; Method: Text; RequestBody: Text; IsManualCall: Boolean): Text
    var
        APISetup: Record "GDRG API Connection Setup";
        APICallLog: Record "GDRG API Call Log";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        ResponseText: Text;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        FullUrl: Text;
        IsSuccess: Boolean;
        StartTime: DateTime;
        EndTime: DateTime;
        APIType: Enum "GDRG API Call Type";
    begin
        APISetup := APISetup.GetSetup();

        if (APISetup."Base URL" = '') or (APISetup."API Key Value" = '') then
            Error(NoSetupErr);

        FullUrl := BuildFullUrl(APISetup."Base URL", Endpoint);

        APIType := DetermineAPIType(Endpoint);

        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Method(Method);
        HttpRequestMessage.SetRequestUri(FullUrl);
        HttpRequestMessage.Content := HttpContent;

        ConfigureAuthentication(HttpRequestMessage, APISetup, FullUrl);

        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');

        StartTime := CurrentDateTime();

        IsSuccess := HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        EndTime := CurrentDateTime();

        if IsSuccess then begin
            HttpResponseMessage.Content().ReadAs(ResponseText);

            if HttpResponseMessage.IsSuccessStatusCode() then begin
                APICallLog.LogSuccessfulCall(
                    FullUrl,
                    APIType,
                    Method,
                    HttpResponseMessage.HttpStatusCode(),
                    1,
                    EndTime - StartTime,
                    IsManualCall);

                exit(ResponseText);
            end else begin
                APICallLog.LogFailedCall(
                    FullUrl,
                    APIType,
                    Method,
                    HttpResponseMessage.HttpStatusCode(),
                    StrSubstNo(ErrorResponseLbl, ResponseText),
                    EndTime - StartTime,
                    IsManualCall);

                Error(InvalidResponseErr, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase());
            end;
        end else begin
            APICallLog.LogFailedCall(
                FullUrl,
                APIType,
                Method,
                0,
                HttpRequestFailedErr,
                EndTime - StartTime,
                IsManualCall);

            Error(HttpRequestFailedErr);
        end;
    end;
}
