namespace DefaultPublisher.ChangeLogView;

using System.Diagnostics;
using System.Reflection;

codeunit 88890 "CL Blame Mgmt"
{
    Permissions = tabledata "Change Log Entry" = r;

    internal procedure LoadBlameData(
        var RowBuf: Record "CL Blame Row Buffer";
        var CellBuf: Record "CL Blame Cell Buffer";
        var ColCaptions: array[12] of Text[80];
        var NoOfCols: Integer;
        var TotalEvents: Integer;
        var HasBaseline: Boolean;
        TableNo: Integer;
        PKVal1: Text[50];
        PKVal2: Text[50];
        PKVal3: Text[50];
        StartAt: Integer)
    var
        RowMap: Dictionary of [Integer, Integer];
        ColOffset: Integer;
    begin
        RowBuf.Reset();
        RowBuf.DeleteAll(false);
        CellBuf.Reset();
        CellBuf.DeleteAll(false);
        Clear(ColCaptions);
        NoOfCols := 0;
        TotalEvents := 0;
        HasBaseline := false;

        this.PopulateRows(RowBuf, TableNo, RowMap);
        HasBaseline := not this.HasInsertEvent(TableNo, PKVal1, PKVal2, PKVal3);
        if HasBaseline then begin
            this.AddBaselineColumn(CellBuf, ColCaptions, NoOfCols, TableNo, PKVal1, PKVal2, PKVal3, RowMap);
            ColOffset := 1;
        end;
        this.ProcessEntries(CellBuf, ColCaptions, NoOfCols, TotalEvents, TableNo, PKVal1, PKVal2, PKVal3, StartAt, RowMap, ColOffset);
    end;

    local procedure PopulateRows(var RowBuf: Record "CL Blame Row Buffer"; TableNo: Integer; var RowMap: Dictionary of [Integer, Integer])
    var
        FieldRec: Record Field;
        RowNo: Integer;
    begin
        this.InsertRow(RowBuf, 1, 'Type of Change', true, 0);
        this.InsertRow(RowBuf, 2, 'Date & Time', true, 0);
        this.InsertRow(RowBuf, 3, 'User', true, 0);

        RowNo := 4;
        FieldRec.SetRange(TableNo, TableNo);
        FieldRec.SetRange(Class, FieldRec.Class::Normal);
        if FieldRec.FindSet() then
            repeat
                if not this.IsAuditStampField(FieldRec."Field Caption") then begin
                    this.InsertRow(RowBuf, RowNo, Format(FieldRec."No.") + ' – ' + FieldRec."Field Caption", false, FieldRec."No.");
                    RowMap.Add(FieldRec."No.", RowNo);
                    RowNo += 1;
                end;
            until FieldRec.Next() = 0;
    end;

    local procedure ProcessEntries(
        var CellBuf: Record "CL Blame Cell Buffer";
        var ColCaptions: array[12] of Text[80];
        var NoOfCols: Integer;
        var TotalEvents: Integer;
        TableNo: Integer;
        PKVal1: Text[50]; PKVal2: Text[50]; PKVal3: Text[50];
        StartAt: Integer;
        var RowMap: Dictionary of [Integer, Integer];
        ColOffset: Integer)
    var
        ChangeLogEntry: Record "Change Log Entry";
        EventOrdinals: Dictionary of [Text[150], Integer];
        ModifyCount: Integer;
    begin
        this.SetChangeLogFilters(ChangeLogEntry, TableNo, PKVal1, PKVal2, PKVal3);
        if not ChangeLogEntry.FindSet() then
            exit;

        TotalEvents := 0;
        ModifyCount := 0;
        NoOfCols := ColOffset;
        repeat
            if not this.IsAuditStampField(ChangeLogEntry."Field Caption") and RowMap.ContainsKey(ChangeLogEntry."Field No.") then begin
                this.RegisterEvent(EventOrdinals, TotalEvents, ModifyCount, CellBuf, ColCaptions, NoOfCols, ChangeLogEntry, StartAt, ColOffset);
                this.FillCell(CellBuf, EventOrdinals, ChangeLogEntry, StartAt, RowMap, ColOffset);
            end;
        until ChangeLogEntry.Next() = 0;
    end;

    local procedure RegisterEvent(
        var EventOrdinals: Dictionary of [Text[150], Integer];
        var TotalEvents: Integer;
        var ModifyCount: Integer;
        var CellBuf: Record "CL Blame Cell Buffer";
        var ColCaptions: array[12] of Text[80];
        var NoOfCols: Integer;
        ChangeLogEntry: Record "Change Log Entry";
        StartAt: Integer;
        ColOffset: Integer)
    var
        GroupKey: Text[150];
        ColIdx: Integer;
    begin
        GroupKey := this.BuildGroupKey(ChangeLogEntry);
        if EventOrdinals.ContainsKey(GroupKey) then
            exit;

        TotalEvents += 1;
        EventOrdinals.Add(GroupKey, TotalEvents);
        if ChangeLogEntry."Type of Change" = ChangeLogEntry."Type of Change"::Modification then
            ModifyCount += 1;
        ColIdx := TotalEvents - StartAt + 1 + ColOffset;
        if not this.IsInWindow(ColIdx) then
            exit;

        ColCaptions[ColIdx] := this.BuildColCaption(ChangeLogEntry."Type of Change", ModifyCount);
        this.UpsertCell(CellBuf, 1, ColIdx, Format(ChangeLogEntry."Type of Change"));
        this.UpsertCell(CellBuf, 2, ColIdx, this.FormatDT(ChangeLogEntry."Date and Time"));
        this.UpsertCell(CellBuf, 3, ColIdx, ChangeLogEntry."User ID");
        if ColIdx > NoOfCols then
            NoOfCols := ColIdx;
    end;

    local procedure FillCell(
        var CellBuf: Record "CL Blame Cell Buffer";
        var EventOrdinals: Dictionary of [Text[150], Integer];
        ChangeLogEntry: Record "Change Log Entry";
        StartAt: Integer;
        var RowMap: Dictionary of [Integer, Integer];
        ColOffset: Integer)
    var
        GroupKey: Text[150];
        ColIdx: Integer;
    begin
        GroupKey := this.BuildGroupKey(ChangeLogEntry);
        if not EventOrdinals.ContainsKey(GroupKey) then
            exit;
        ColIdx := EventOrdinals.Get(GroupKey) - StartAt + 1 + ColOffset;
        if not this.IsInWindow(ColIdx) then
            exit;
        if not RowMap.ContainsKey(ChangeLogEntry."Field No.") then
            exit;
        this.UpsertCell(CellBuf, RowMap.Get(ChangeLogEntry."Field No."), ColIdx, this.FormatCellValue(ChangeLogEntry."New Value"));
    end;

    local procedure SetChangeLogFilters(var ChangeLogEntry: Record "Change Log Entry"; TableNo: Integer; PKVal1: Text[50]; PKVal2: Text[50]; PKVal3: Text[50])
    begin
        ChangeLogEntry.SetCurrentKey("Table No.", "Date and Time");
        ChangeLogEntry.SetRange("Table No.", TableNo);
        ChangeLogEntry.SetRange("Primary Key Field 1 Value", PKVal1);
        ChangeLogEntry.SetRange("Primary Key Field 2 Value", PKVal2);
        ChangeLogEntry.SetRange("Primary Key Field 3 Value", PKVal3);
        ChangeLogEntry.Ascending(true);
    end;

    local procedure IsInWindow(ColIdx: Integer): Boolean
    begin
        exit((ColIdx >= 1) and (ColIdx <= 12));
    end;

    local procedure BuildGroupKey(ChangeLogEntry: Record "Change Log Entry"): Text[150]
    begin
        exit(
            Format(ChangeLogEntry."Type of Change") + '|' +
            this.FormatDT(ChangeLogEntry."Date and Time") + '|' +
            ChangeLogEntry."User ID");
    end;

    local procedure BuildColCaption(TypeOfChange: Enum "Change Log Entry Type"; ModifySeq: Integer): Text[80]
    begin
        case TypeOfChange of
            TypeOfChange::Insertion:
                exit('Insert');
            TypeOfChange::Modification:
                exit('Mod. ' + Format(ModifySeq));
            TypeOfChange::Deletion:
                exit('Delete');
            else
                exit('Event');
        end;
    end;

    local procedure FormatDT(DateAndTime: DateTime): Text[30]
    begin
        if DateAndTime = 0DT then
            exit('');
        exit(
            Format(DateAndTime.Date(), 0, '<Day,2>/<Month,2>/<Year4>') +
            ' ' +
            Format(DateAndTime.Time(), 0, '<Hours24,2>:<Minutes,2>'));
    end;

    local procedure IsAuditStampField(FieldCaption: Text[80]): Boolean
    begin
        exit(
            (FieldCaption = 'Last Modified Date Time') or
            (FieldCaption = 'Last Date Modified') or
            (FieldCaption = 'Last Time Modified') or
            (FieldCaption = 'Last DateTime Modified'));
    end;

    local procedure HasInsertEvent(TableNo: Integer; PKVal1: Text[50]; PKVal2: Text[50]; PKVal3: Text[50]): Boolean
    var
        ChangeLogEntry: Record "Change Log Entry";
    begin
        this.SetChangeLogFilters(ChangeLogEntry, TableNo, PKVal1, PKVal2, PKVal3);
        ChangeLogEntry.SetRange("Type of Change", ChangeLogEntry."Type of Change"::Insertion);
        exit(not ChangeLogEntry.IsEmpty());
    end;

    local procedure AddBaselineColumn(
        var CellBuf: Record "CL Blame Cell Buffer";
        var ColCaptions: array[12] of Text[80];
        var NoOfCols: Integer;
        TableNo: Integer;
        PKVal1: Text[50]; PKVal2: Text[50]; PKVal3: Text[50];
        var RowMap: Dictionary of [Integer, Integer])
    var
        OldValues: Dictionary of [Integer, Text];
        FieldNos: List of [Integer];
        FieldNo: Integer;
    begin
        OldValues := this.CollectFirstOldValues(TableNo, PKVal1, PKVal2, PKVal3);
        this.FillMissingFromRecord(OldValues, TableNo, PKVal1, PKVal2, PKVal3, RowMap);

        ColCaptions[1] := 'Prior';
        this.UpsertCell(CellBuf, 1, 1, 'Prior');
        this.UpsertCell(CellBuf, 2, 1, '');
        this.UpsertCell(CellBuf, 3, 1, '');
        FieldNos := RowMap.Keys();
        foreach FieldNo in FieldNos do
            if OldValues.ContainsKey(FieldNo) then
                this.UpsertCell(CellBuf, RowMap.Get(FieldNo), 1, this.FormatCellValue(OldValues.Get(FieldNo)));
        NoOfCols := 1;
    end;

    local procedure CollectFirstOldValues(TableNo: Integer; PKVal1: Text[50]; PKVal2: Text[50]; PKVal3: Text[50]): Dictionary of [Integer, Text]
    var
        ChangeLogEntry: Record "Change Log Entry";
        OldValues: Dictionary of [Integer, Text];
    begin
        this.SetChangeLogFilters(ChangeLogEntry, TableNo, PKVal1, PKVal2, PKVal3);
        if ChangeLogEntry.FindSet() then
            repeat
                if not OldValues.ContainsKey(ChangeLogEntry."Field No.") then
                    OldValues.Add(ChangeLogEntry."Field No.", ChangeLogEntry."Old Value");
            until ChangeLogEntry.Next() = 0;
        exit(OldValues);
    end;

    local procedure FillMissingFromRecord(var OldValues: Dictionary of [Integer, Text]; TableNo: Integer; PKVal1: Text[50]; PKVal2: Text[50]; PKVal3: Text[50]; var RowMap: Dictionary of [Integer, Integer])
    var
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldNos: List of [Integer];
        FieldNo: Integer;
        FieldVal: Text;
    begin
        RecRef.Open(TableNo);
        KeyRef := RecRef.KeyIndex(1);
        this.FilterRecRefByKey(RecRef, KeyRef, PKVal1, PKVal2, PKVal3);
        if RecRef.FindFirst() then begin
            FieldNos := RowMap.Keys();
            foreach FieldNo in FieldNos do
                if not OldValues.ContainsKey(FieldNo) then
                    if this.TryGetFieldValue(RecRef, FieldNo, FieldVal) then
                        OldValues.Add(FieldNo, FieldVal);
        end;
        RecRef.Close();
    end;

    local procedure FilterRecRefByKey(var RecRef: RecordRef; var KeyRef: KeyRef; PKVal1: Text[50]; PKVal2: Text[50]; PKVal3: Text[50])
    var
        FldRef: FieldRef;
    begin
        if KeyRef.FieldCount() >= 1 then begin
            FldRef := KeyRef.FieldIndex(1);
            RecRef.Field(FldRef.Number()).SetFilter(PKVal1);
        end;
        if KeyRef.FieldCount() >= 2 then begin
            FldRef := KeyRef.FieldIndex(2);
            RecRef.Field(FldRef.Number()).SetFilter(PKVal2);
        end;
        if KeyRef.FieldCount() >= 3 then begin
            FldRef := KeyRef.FieldIndex(3);
            RecRef.Field(FldRef.Number()).SetFilter(PKVal3);
        end;
    end;

    local procedure FormatCellValue(Value: Text): Text
    begin
        if Value = '' then
            exit('<blank>');
        exit(Value);
    end;

    [TryFunction]
    local procedure TryGetFieldValue(var RecRef: RecordRef; FieldNo: Integer; var Value: Text)
    var
        FldRef: FieldRef;
    begin
        FldRef := RecRef.Field(FieldNo);
        Value := Format(FldRef.Value());
    end;

    local procedure InsertRow(var RowBuf: Record "CL Blame Row Buffer"; RowNo: Integer; Caption: Text; IsHeader: Boolean; FieldNo: Integer)
    begin
        RowBuf.Init();
        RowBuf."Row No." := RowNo;
        RowBuf."Row Caption" := CopyStr(Caption, 1, MaxStrLen(RowBuf."Row Caption"));
        RowBuf."Is Header" := IsHeader;
        RowBuf."Field No." := FieldNo;
        RowBuf.Insert(false);
    end;

    local procedure UpsertCell(var CellBuf: Record "CL Blame Cell Buffer"; RowNo: Integer; ColNo: Integer; Value: Text)
    begin
        CellBuf.Init();
        CellBuf."Row No." := RowNo;
        CellBuf."Col No." := ColNo;
        CellBuf."Cell Value" := CopyStr(Value, 1, MaxStrLen(CellBuf."Cell Value"));
        if not CellBuf.Insert(false) then begin
            CellBuf."Cell Value" := CopyStr(Value, 1, MaxStrLen(CellBuf."Cell Value"));
            CellBuf.Modify(false);
        end;
    end;
}
