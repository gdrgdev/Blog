codeunit 96000 GDRJsonMgt
{
    procedure CheckJsonArray()
    var
        JsonCU: Codeunit Json;
        jsonArrayText: Text;

        JsonObjectText: text;
        JsonObjectTextReplace: text;
        JsonObjectTextNew: text;
        JsonObjectTextTable: text;

        JsonvalueText: Text;
        JsonvalueInt: integer;
        Jsonvaluedecimal: Decimal;
        JsonValuebool: Boolean;
        Jsonvaluevariant: Variant;

        GDRJsonTable: Record GDRGJsonTable;
        RecRef: RecordRef;

        i: Integer;
    begin
        //Json Collection Example
        jsonArrayText := '[' +
            '{"string":"string 1", "integer":30, "decimal":30.30,"boolean":true},' +
            '{"string":"string 2", "integer":40, "decimal":40.40,"boolean":false}' +
            ']';

        //Initial reading of the json
        JsonCU.InitializeCollection(jsonArrayText);
        Message('Collection as Text (Original): ' + JsonCU.GetCollectionAsText());
        for i := 0 to JsonCU.GetCollectionCount() - 1 do begin
            JsonCU.GetObjectFromCollectionByIndex(i, JsonObjectText);
            JsonCU.InitializeObject(JsonObjectText);

            Message('Object as Text (Original): ' + JsonCU.GetObjectAsText());

            //Getting values ​​from json
            JsonCU.GetStringPropertyValueByName('string', JsonvalueText);
            JsonCU.GetIntegerPropertyValueFromJObjectByName('integer', JsonvalueInt);
            JsonCU.GetDecimalPropertyValueFromJObjectByName('decimal', Jsonvaluedecimal);
            JsonCU.GetBoolPropertyValueFromJObjectByName('boolean', JsonValuebool);

            Message('GetStringPropertyValueByName: ' + JsonvalueText);
            Message('GetIntegerPropertyValueFromJObjectByName: ' + format(JsonvalueInt));
            Message('GetDecimalPropertyValueFromJObjectByName: ' + format(Jsonvaluedecimal));
            Message('GetBoolPropertyValueFromJObjectByName: ' + format(JsonValuebool));

            JsonCU.GetPropertyValueByName('string', Jsonvaluevariant);
            If Jsonvaluevariant.IsText then begin
                Message('GetStringPropertyValueByName (Variant): ' + JsonvalueText);
            end;

            //Replacing values ​​of the "string" property
            JsonCU.ReplaceOrAddJPropertyInJObject('string', JsonvalueText + ' replace');
            JsonObjectTextReplace := JsonCU.GetObjectAsText();
            JsonCU.ReplaceJObjectInCollection(i, JsonObjectTextReplace);
            Message('Object as Text (After replacement): ' + JsonCU.GetObjectAsText());
            Message('Collection as Text (After replacement): ' + JsonCU.GetCollectionAsText());
        end;

        //Removing object
        JsonCU.RemoveJObjectFromCollection(1);
        Message('Collection as Text (After deletion): ' + JsonCU.GetCollectionAsText());

        //Adding object
        JsonCU.InitializeObject(JsonObjectTextNew);
        JsonCU.ReplaceOrAddJPropertyInJObject('string', 'New String');
        JsonCU.ReplaceOrAddJPropertyInJObject('integer', 50);
        JsonCU.ReplaceOrAddJPropertyInJObject('decimal', 50.50);
        JsonCU.ReplaceOrAddJPropertyInJObject('boolean', false);
        JsonObjectTextNew := JsonCU.GetObjectAsText();
        JsonCU.AddJObjectToCollection(JsonObjectTextNew);
        Message('Collection as Text (After the addition): ' + JsonCU.GetCollectionAsText());

        //Adding in the table     
        GDRJsonTable.DeleteAll();
        for i := 0 to JsonCU.GetCollectionCount() - 1 do begin
            JsonCU.GetObjectFromCollectionByIndex(i, JsonObjectTextTable);
            JsonCU.InitializeObject(JsonObjectTextTable);
            RecRef.GetTable(GDRJsonTable);
            RecRef.Init();
            JsonCU.GetValueAndSetToRecFieldNo(RecRef, 'string', GDRJsonTable.FieldNo(string));
            JsonCU.GetValueAndSetToRecFieldNo(RecRef, 'integer', GDRJsonTable.FieldNo(integer));
            JsonCU.GetValueAndSetToRecFieldNo(RecRef, 'decimal', GDRJsonTable.FieldNo(decimal));
            JsonCU.GetValueAndSetToRecFieldNo(RecRef, 'boolean', GDRJsonTable.FieldNo(boolean));
            RecRef.Insert(true);
        end;
        Message('Filled table');
    end;

}