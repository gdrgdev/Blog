codeunit 97824 "GDRGPE JSON Renderer"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure RenderToHtml(JsonText: Text): Text
    var
        JToken: JsonToken;
        RenderedJson: Text;
    begin
        if JToken.ReadFrom(JsonText) then
            RenderedJson := RenderToken(JToken, 0)
        else
            RenderedJson := HtmlEsc(JsonText);
        exit(
            '<!DOCTYPE html><html><head><style>' +
            'body{margin:12px;font-family:Consolas,"Courier New",monospace;font-size:13px;background:#fff;color:#000;line-height:1.6;}' +
            'pre{white-space:pre-wrap;word-break:break-all;margin:0;}' +
            '.type-key{color:#000;font-weight:bold;}' +
            '.type-string{color:#0B7500;}' +
            '.type-number{color:#1A01CC;}' +
            '.type-boolean{color:#1A01CC;font-weight:bold;}' +
            '.type-null{color:#909;}' +
            '</style></head><body><pre>' + RenderedJson + '</pre></body></html>'
        );
    end;

    local procedure RenderToken(JToken: JsonToken; Indent: Integer): Text
    begin
        if JToken.IsObject() then
            exit(RenderObject(JToken.AsObject(), Indent));
        if JToken.IsArray() then
            exit(RenderArray(JToken.AsArray(), Indent));
        exit(RenderValue(JToken.AsValue()));
    end;

    local procedure RenderObject(JObject: JsonObject; Indent: Integer): Text
    var
        Keys: List of [Text];
        ChildToken: JsonToken;
        JKey: Text;
        Result: Text;
        IsFirst: Boolean;
    begin
        Keys := JObject.Keys();
        if Keys.Count() = 0 then
            exit('{}');
        Result := '{';
        IsFirst := true;
        foreach JKey in Keys do begin
            if not IsFirst then
                Result += ',';
            JObject.Get(JKey, ChildToken);
            Result +=
                '<br>' + PadStr('', (Indent + 1) * 2) +
                '<span class="type-key">"' + HtmlEsc(JKey) + '"</span>: ' +
                RenderToken(ChildToken, Indent + 1);
            IsFirst := false;
        end;
        Result += '<br>' + PadStr('', Indent * 2) + '}';
        exit(Result);
    end;

    local procedure RenderArray(JArray: JsonArray; Indent: Integer): Text
    var
        ChildToken: JsonToken;
        Result: Text;
        IsFirst: Boolean;
        I: Integer;
    begin
        if JArray.Count() = 0 then
            exit('[]');
        Result := '[';
        IsFirst := true;
        for I := 0 to JArray.Count() - 1 do begin
            if not IsFirst then
                Result += ',';
            JArray.Get(I, ChildToken);
            Result += '<br>' + PadStr('', (Indent + 1) * 2) + RenderToken(ChildToken, Indent + 1);
            IsFirst := false;
        end;
        Result += '<br>' + PadStr('', Indent * 2) + ']';
        exit(Result);
    end;

    local procedure RenderValue(JValue: JsonValue): Text
    var
        ValueStr: Text;
    begin
        if JValue.IsNull() then
            exit('<span class="type-null">null</span>');
        JValue.WriteTo(ValueStr);
        if (ValueStr = 'true') or (ValueStr = 'false') then
            exit('<span class="type-boolean">' + ValueStr + '</span>');
        if ValueStr.StartsWith('"') then
            exit('<span class="type-string">' + HtmlEsc(ValueStr) + '</span>');
        exit('<span class="type-number">' + ValueStr + '</span>');
    end;

    local procedure HtmlEsc(s: Text): Text
    begin
        s := s.Replace('&', '&amp;');
        s := s.Replace('<', '&lt;');
        s := s.Replace('>', '&gt;');
        exit(s);
    end;
}
