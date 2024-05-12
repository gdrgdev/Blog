codeunit 80001 GDRApiMgt
{
    var
        ApiSetupRead: Boolean;
        GDRApiMgt: Record GDRApiMgt;


    procedure GDRgetToken() resultToken: Text[2048];
    var
        cuOAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
        txtRedirectURL: text;
        txtURLToken: text;
        txtBodyContent: text;

        lblURLToken: Label 'https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token';
        lblScopes: label 'https://graph.microsoft.com/.default';

        HttpContent: HttpContent;
        HttpHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;

        JsonObject: JsonObject;
    begin

        GetApiSetup();
        If (GDRApiMgt.apitenant = '') or (GDRApiMgt.apiclienteid = '') or (GDRApiMgt.apisecreto = '') then
            error('You must complete the setup.');

        Scopes.Add(lblScopes);
        cuOAuth2.GetDefaultRedirectURL(txtRedirectURL);

        txtURLToken := lblURLToken;
        txtURLToken := txtURLToken.Replace('{tenantId}', GDRApiMgt.apitenant);

        txtBodyContent := 'grant_type=client_credentials';
        txtBodyContent := txtBodyContent + '&client_id=' + GDRApiMgt.apiclienteid;
        txtBodyContent := txtBodyContent + '&client_secret=' + GDRApiMgt.apisecreto;
        txtBodyContent := txtBodyContent + '&scope=' + lblScopes;

        HttpContent.WriteFrom(txtBodyContent);
        HttpContent.GetHeaders(HttpHeader);
        HttpHeader.Remove('Content-Type');
        HttpHeader.Add('Content-Type', 'application/x-www-form-urlencoded');


        if not HttpClient.Post(txtURLToken, HttpContent, HttpResponseMessage) then
            if HttpResponseMessage.IsBlockedByEnvironment then
                Error('Request was blocked by environment')
            else
                Error('Request to Azure Graph failed\ %1', GetLastErrorText());


        txtBodyContent := '';
        HttpResponseMessage.Content.ReadAs(txtBodyContent);

        if JsonObject.ReadFrom(txtBodyContent) then begin
            exit(GDRGetJsonToken(JsonObject, 'access_token', 0).AsValue().AsText());
        end;
    end;

    procedure GDRGetJsonToken(parJsonObject: JsonObject; parTokenKey: Text; parType: Integer) resultJsonToken: JsonToken;
    var
        txtjsonEmpty: Text;
        JsonObjectEmpty: JsonObject;
    begin
        txtjsonEmpty := '{"Empty":"","EmptyBool":false,"EmptyInt":0,"EmptyDate":"0D"}';
        if not parJsonObject.Get(parTokenKey, resultJsonToken) then begin
            case parType of
                0:
                    begin
                        JsonObjectEmpty.ReadFrom(txtjsonEmpty);
                        JsonObjectEmpty.Get('Empty', resultJsonToken);
                    end;
                1:
                    begin
                        JsonObjectEmpty.ReadFrom(txtjsonEmpty);
                        JsonObjectEmpty.Get('EmptyBool', resultJsonToken);
                    end;
                2:
                    begin
                        JsonObjectEmpty.ReadFrom(txtjsonEmpty);
                        JsonObjectEmpty.Get('EmptyInt', resultJsonToken);
                    end;
                3:
                    begin
                        JsonObjectEmpty.ReadFrom(txtjsonEmpty);
                        JsonObjectEmpty.Get('EmptyDate', resultJsonToken);
                    end;
            end;
        end;
    end;

    local procedure GetApiSetup()
    begin
        if not ApiSetupRead then
            GDRApiMgt.Get();

        ApiSetupRead := true;

    end;
}