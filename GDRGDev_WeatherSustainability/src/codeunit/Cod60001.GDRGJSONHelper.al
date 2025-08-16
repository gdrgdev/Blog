codeunit 60001 "GDRG JSON Helper"
{
    procedure GetTextValue(JsonObj: JsonObject; JsonKey: Text): Text
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(JsonKey, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsText());
        exit('');
    end;

    procedure GetIntegerValue(JsonObj: JsonObject; JsonKey: Text): Integer
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(JsonKey, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsInteger());
        exit(0);
    end;

    procedure GetDateTimeValue(JsonObj: JsonObject; JsonKey: Text): DateTime
    var
        Token: JsonToken;
        DateTimeText: Text;
        ResultDateTime: DateTime;
    begin
        if JsonObj.Get(JsonKey, Token) then
            if not Token.AsValue().IsNull() then begin
                DateTimeText := Token.AsValue().AsText();
                if DateTimeText <> '' then
                    if Evaluate(ResultDateTime, DateTimeText) then
                        exit(ResultDateTime);
            end;
        exit(0DT);
    end;

    procedure GetJsonArray(JsonObj: JsonObject; JsonKey: Text; var JsonArray: JsonArray): Boolean
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(JsonKey, Token) then begin
            JsonArray := Token.AsArray();
            exit(true);
        end;
        exit(false);
    end;

    procedure GetJsonObject(Token: JsonToken; var JsonObj: JsonObject): Boolean
    begin
        JsonObj := Token.AsObject();
        exit(true);
    end;

    procedure ParseJsonObject(JsonText: Text; var JsonObj: JsonObject): Boolean
    begin
        if JsonText = '' then
            exit(false);

        exit(JsonObj.ReadFrom(JsonText));
    end;

    procedure GetArrayItemValueByID(JsonObj: JsonObject; ArrayKey: Text; SearchID: Integer; ValueKey: Text): Text
    var
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObject: JsonObject;
        ItemID: Integer;
    begin
        if not GetJsonArray(JsonObj, ArrayKey, ItemsArray) then
            exit('');

        foreach ItemToken in ItemsArray do
            if GetJsonObject(ItemToken, ItemObject) then begin
                ItemID := GetIntegerValue(ItemObject, 'id');
                if ItemID = SearchID then
                    exit(GetTextValue(ItemObject, ValueKey));
            end;

        exit('');
    end;

    procedure GetNestedJsonObject(JsonObj: JsonObject; JsonKey: Text; var NestedJsonObj: JsonObject): Boolean
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(JsonKey, Token) then begin
            NestedJsonObj := Token.AsObject();
            exit(true);
        end;
        exit(false);
    end;

    procedure KeyExists(JsonObj: JsonObject; JsonKey: Text): Boolean
    var
        Token: JsonToken;
    begin
        exit(JsonObj.Get(JsonKey, Token));
    end;

    procedure GetArrayCount(JsonArray: JsonArray): Integer
    begin
        exit(JsonArray.Count());
    end;

    procedure GetBooleanValue(JsonObj: JsonObject; JsonKey: Text): Boolean
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(JsonKey, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsBoolean());
        exit(false);
    end;

    procedure GetDecimalValue(JsonObj: JsonObject; JsonKey: Text): Decimal
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(JsonKey, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsDecimal());
        exit(0);
    end;

    procedure GetBigIntegerValue(JsonObj: JsonObject; JsonKey: Text): BigInteger
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(JsonKey, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsBigInteger());
        exit(0);
    end;
}
