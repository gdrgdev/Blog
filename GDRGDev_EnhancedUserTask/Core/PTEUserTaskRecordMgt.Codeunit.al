codeunit 50110 "PTE User Task Record Mgt"
{
    Permissions = tabledata "User Task" = RIMD;

    var
        FieldNotFoundErr: Label 'Field %1 not found in table %2', Comment = '%1 = Field Name, %2 = Table Caption';
        FieldNotFoundDetailedErr: Label 'The field "%1" was not found in table "%2" (Table No. %3)', Comment = '%1 = Field Name, %2 = Table Caption, %3 = Table Number';

    procedure CreateTaskForRecord(RecordId: RecordId; SuggestedTitle: Text; SuggestedDescription: Text): Integer
    var
        UserTask: Record "User Task";
        UserTaskCard: Page "User Task Card";
    begin
        if Format(RecordId) = '' then
            exit(0);

        UserTask.Init();
        UserTask."Related Record ID" := RecordId;
        UserTask."Related Table No." := RecordId.TableNo();
        UserTask."Related Record Description" := GetRecordDescription(RecordId);
        UserTask."Related Table Name" := GetTableName(RecordId.TableNo());

        if SuggestedTitle <> '' then
            UserTask.Title := CopyStr(SuggestedTitle, 1, MaxStrLen(UserTask.Title))
        else
            UserTask.Title := CopyStr('Task for ' + UserTask."Related Record Description", 1, MaxStrLen(UserTask.Title));

        if SuggestedDescription <> '' then
            UserTask.SetDescription(SuggestedDescription);

        UserTask."Assigned To" := UserSecurityId();
        UserTask.Insert(true);

        Commit(); // Required before opening modal page

        UserTaskCard.SetRecord(UserTask);
        if UserTaskCard.RunModal() = Action::OK then
            exit(UserTask.ID)
        else begin
            if UserTask.Get(UserTask.ID) then
                UserTask.Delete(true);
            exit(0);
        end;
    end;

    procedure FindTasksForRecord(RecordId: RecordId; var UserTask: Record "User Task")
    begin
        UserTask.Reset();
        UserTask.SetRange("Related Record ID", RecordId);
    end;

    procedure GetRecordDescription(RecordId: RecordId): Text[250]
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        DisplayText: Text;
        KeyFieldsText: Text;
    begin
        if Format(RecordId) = '' then
            exit('');

        if not RecRef.Get(RecordId) then
            exit(Format(RecordId));

        KeyFieldsText := GetPrimaryKeyFieldsText(RecRef);
        if KeyFieldsText <> '' then
            DisplayText := KeyFieldsText;

        if TryGetFieldRef(RecRef, 'Name', FieldRef) then
            DisplayText += ' - ' + Format(FieldRef.Value())
        else
            if TryGetFieldRef(RecRef, 'Description', FieldRef) then
                DisplayText += ' - ' + Format(FieldRef.Value());

        if DisplayText = '' then
            DisplayText := Format(RecordId);

        exit(CopyStr(DisplayText, 1, 250));
    end;

    procedure GetTableName(TableNo: Integer): Text[100]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableNo);
        if AllObjWithCaption.FindFirst() then
            exit(CopyStr(AllObjWithCaption."Object Caption", 1, 100))
        else
            exit('Table ' + Format(TableNo));
    end;

    procedure NavigateToRecord(RecordId: RecordId)
    var
        PageManagement: Codeunit "Page Management";
    begin
        if Format(RecordId) = '' then
            exit;

        PageManagement.PageRun(RecordId);
    end;

    [TryFunction]
    local procedure TryGetFieldRef(RecRef: RecordRef; FieldName: Text; var FieldRef: FieldRef)
    var
        Field: Record Field;
        ErrorInfo: ErrorInfo;
    begin
        Field.SetRange(TableNo, RecRef.Number());
        Field.SetRange(FieldName, FieldName);
        if Field.FindFirst() then
            FieldRef := RecRef.Field(Field."No.")
        else begin
            ErrorInfo.Message := StrSubstNo(FieldNotFoundErr, FieldName, RecRef.Caption());
            ErrorInfo.DetailedMessage := StrSubstNo(FieldNotFoundDetailedErr, FieldName, RecRef.Caption(), RecRef.Number());
            ErrorInfo.Verbosity := Verbosity::Error;
            Error(ErrorInfo);
        end;
    end;

    procedure GetPrimaryKeyFieldsText(RecRef: RecordRef): Text
    var
        FieldRef: FieldRef;
        i: Integer;
        KeyRef: KeyRef;
        ResultText: Text;
    begin
        if RecRef.KeyCount() = 0 then
            exit('');

        KeyRef := RecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount() do begin
            FieldRef := KeyRef.FieldIndex(i);
            if ResultText <> '' then
                ResultText += ', ';
            ResultText += Format(FieldRef.Value());
        end;
        exit(ResultText);
    end;
}
