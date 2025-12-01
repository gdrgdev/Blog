codeunit 78452 "GDRG Key Manager"
{
    /// <summary>
    /// Retrieves all keys defined in a table using RecordRef
    /// </summary>
    /// <param name="TableNo">The table number to retrieve keys from.</param>
    /// <param name="TempTableKey">Temporary table to store the retrieved keys.</param>
    procedure GetTableKeys(TableNo: Integer; var TempTableKey: Record "GDRG Table Key" temporary)
    var
        RecRef: RecordRef;
        KeyRef: KeyRef;
        EntryNo: Integer;
        i: Integer;
        KeyCount: Integer;
    begin
        TempTableKey.Reset();
        TempTableKey.DeleteAll(false);

        if TableNo = 0 then
            exit;

        RecRef.Open(TableNo);
        KeyCount := RecRef.KeyCount();
        EntryNo := 0;

        // Iterate through all table keys
        for i := 1 to KeyCount do begin
            KeyRef := RecRef.KeyIndex(i);
            EntryNo += 1;

            TempTableKey.Init();
            TempTableKey."Entry No." := EntryNo;
            TempTableKey."Table No." := TableNo;
            TempTableKey."Key No." := i;
            TempTableKey."Key Name" := GetKeyDisplayName(KeyRef, i);
            TempTableKey."Key Fields" := GetKeyFieldNames(KeyRef);
            TempTableKey."Is Primary" := (i = 1); // First key is always the primary key
            TempTableKey."Field Count" := KeyRef.FieldCount();
            TempTableKey.Insert(false);
        end;

        RecRef.Close();
    end;

    /// <summary>
    /// Builds the user-friendly key name for display
    /// </summary>
    /// <param name="KeyRef">Key reference from RecordRef.</param>
    /// <param name="KeyNo">Key number (index).</param>
    /// <returns>The display name for the key.</returns>
    local procedure GetKeyDisplayName(KeyRef: KeyRef; KeyNo: Integer): Text[250]
    var
        PrimaryPrefix: Text;
        KeyName: Text[250];
    begin
        KeyName := GetKeyFieldNames(KeyRef);

        // If it's the primary key, add indicator
        if KeyNo = 1 then begin
            PrimaryPrefix := '🔑 Primary: ';
            KeyName := CopyStr(PrimaryPrefix + KeyName, 1, 250);
        end;

        exit(KeyName);
    end;

    /// <summary>
    /// Retrieves the field names that compose the key
    /// </summary>
    /// <param name="KeyRef">Key reference from RecordRef.</param>
    /// <returns>Comma-separated list of field names in the key.</returns>
    local procedure GetKeyFieldNames(KeyRef: KeyRef): Text[250]
    var
        FieldRef: FieldRef;
        i: Integer;
        KeyFields: Text[250];
    begin
        KeyFields := '';

        for i := 1 to KeyRef.FieldCount() do begin
            FieldRef := KeyRef.FieldIndex(i);

            if KeyFields <> '' then
                KeyFields += ', ';

            KeyFields += FieldRef.Caption(); // Use Caption for user-friendly field name
        end;

        exit(KeyFields);
    end;

    /// <summary>
    /// Builds the TableView string to apply sorting
    /// This string is used with SetTableView() on the page
    /// </summary>
    /// <param name="TableNo">The table number.</param>
    /// <param name="KeyNo">The key number (index).</param>
    /// <returns>SORTING string for use with SetTableView.</returns>
    procedure BuildTableViewFromKey(TableNo: Integer; KeyNo: Integer): Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        i: Integer;
        SortingText: Text;
    begin
        if (TableNo = 0) or (KeyNo = 0) then
            exit('');

        RecRef.Open(TableNo);

        if KeyNo > RecRef.KeyCount() then begin
            RecRef.Close();
            exit('');
        end;

        KeyRef := RecRef.KeyIndex(KeyNo);
        SortingText := 'SORTING(';

        // Build field list for SORTING clause
        for i := 1 to KeyRef.FieldCount() do begin
            FieldRef := KeyRef.FieldIndex(i);

            if i > 1 then
                SortingText += ',';

            SortingText += FieldRef.Name(); // Use Name (technical field name) for SORTING
        end;

        SortingText += ')';
        RecRef.Close();

        exit(SortingText);
    end;

    /// <summary>
    /// Retrieves the descriptive key name for display in caption
    /// </summary>
    /// <param name="TableNo">The table number.</param>
    /// <param name="KeyNo">The key number (index).</param>
    /// <returns>User-friendly description of the key for display in captions.</returns>
    procedure GetKeyDescriptionForCaption(TableNo: Integer; KeyNo: Integer): Text
    var
        RecRef: RecordRef;
        KeyRef: KeyRef;
    begin
        if (TableNo = 0) or (KeyNo = 0) then
            exit('');

        RecRef.Open(TableNo);

        if KeyNo > RecRef.KeyCount() then begin
            RecRef.Close();
            exit('');
        end;

        KeyRef := RecRef.KeyIndex(KeyNo);
        RecRef.Close();

        exit(GetKeyFieldNames(KeyRef));
    end;
}
