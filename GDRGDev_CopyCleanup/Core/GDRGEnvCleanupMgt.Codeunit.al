codeunit 88892 "GDRG Env Cleanup Mgt"
{
    Permissions = tabledata "GDRG Env Copy Log" = rim,
                  tabledata "GDRG Env Copy Log Line" = rim;

    procedure StartLog(TriggerType: Text; EnvironmentName: Text; EventName: Text): Integer
    var
        EnvCopyLog: Record "GDRG Env Copy Log";
    begin
        EnvCopyLog.Init();
        EnvCopyLog."Started At" := CurrentDateTime();
        EnvCopyLog."Trigger Type" := CopyStr(TriggerType, 1, MaxStrLen(EnvCopyLog."Trigger Type"));
        EnvCopyLog."First Event" := CopyStr(EventName, 1, MaxStrLen(EnvCopyLog."First Event"));
        EnvCopyLog."Environment Name" := CopyStr(EnvironmentName, 1, MaxStrLen(EnvCopyLog."Environment Name"));
        EnvCopyLog.Status := 'In Progress';
        EnvCopyLog."User Security Id" := UserSecurityId();
        EnvCopyLog.Insert(true, true);
        AddLine(EnvCopyLog."Entry No.", '', 'Event Start - ' + EventName, 'Started', 0, '');
        exit(EnvCopyLog."Entry No.");
    end;

    procedure EnsureLog(var LogEntryNo: Integer; TriggerType: Text; EnvironmentName: Text; EventName: Text)
    begin
        if LogEntryNo <> 0 then
            exit;

        LogEntryNo := StartLog(TriggerType, EnvironmentName, EventName);
    end;

    procedure SetLogCompany(LogEntryNo: Integer; CompanyName: Text[30])
    var
        EnvCopyLog: Record "GDRG Env Copy Log";
    begin
        if (LogEntryNo = 0) or (CompanyName = '') then
            exit;

        if not EnvCopyLog.Get(LogEntryNo) then
            exit;

        if EnvCopyLog.Company = CompanyName then
            exit;

        EnvCopyLog.Company := CopyStr(CompanyName, 1, MaxStrLen(EnvCopyLog.Company));
        EnvCopyLog.Modify(true);
    end;

    procedure FinishLog(LogEntryNo: Integer; EventName: Text; NewStatus: Text)
    var
        EnvCopyLog: Record "GDRG Env Copy Log";
    begin
        if LogEntryNo = 0 then
            exit;

        AddLine(LogEntryNo, '', 'Event End - ' + EventName, NewStatus, 0, '');

        if not EnvCopyLog.Get(LogEntryNo) then
            exit;

        EnvCopyLog."Ended At" := CurrentDateTime();
        EnvCopyLog.Status := CopyStr(NewStatus, 1, MaxStrLen(EnvCopyLog.Status));
        EnvCopyLog.Modify(true);
    end;

    procedure AddLine(LogEntryNo: Integer; CompanyName: Text[30]; Step: Text; Status: Text; TableNo: Integer; Message: Text)
    var
        EnvCopyLogLine: Record "GDRG Env Copy Log Line";
        CurrentMoment: DateTime;
    begin
        if LogEntryNo = 0 then
            exit;

        CurrentMoment := CurrentDateTime();
        EnvCopyLogLine.Init();
        EnvCopyLogLine."Log Entry No." := LogEntryNo;
        EnvCopyLogLine."Line No." := GetNextLineNo(LogEntryNo);
        EnvCopyLogLine."Created At" := CurrentMoment;
        EnvCopyLogLine."Started At" := CurrentMoment;
        EnvCopyLogLine."Ended At" := CurrentMoment;
        EnvCopyLogLine."Duration (ms)" := 0;
        EnvCopyLogLine.Company := CopyStr(CompanyName, 1, MaxStrLen(EnvCopyLogLine.Company));
        EnvCopyLogLine.Step := CopyStr(Step, 1, MaxStrLen(EnvCopyLogLine.Step));
        EnvCopyLogLine.Status := CopyStr(Status, 1, MaxStrLen(EnvCopyLogLine.Status));
        EnvCopyLogLine."Table No." := TableNo;
        EnvCopyLogLine.Message := CopyStr(Message, 1, MaxStrLen(EnvCopyLogLine.Message));
        EnvCopyLogLine.Insert(true);
    end;

    procedure AddLineWithNo(LogEntryNo: Integer; CompanyName: Text[30]; Step: Text; Status: Text; TableNo: Integer; Message: Text): Integer
    var
        EnvCopyLogLine: Record "GDRG Env Copy Log Line";
        CurrentMoment: DateTime;
    begin
        if LogEntryNo = 0 then
            exit(0);

        CurrentMoment := CurrentDateTime();
        EnvCopyLogLine.Init();
        EnvCopyLogLine."Log Entry No." := LogEntryNo;
        EnvCopyLogLine."Line No." := GetNextLineNo(LogEntryNo);
        EnvCopyLogLine."Created At" := CurrentMoment;
        EnvCopyLogLine."Started At" := CurrentMoment;
        EnvCopyLogLine.Company := CopyStr(CompanyName, 1, MaxStrLen(EnvCopyLogLine.Company));
        EnvCopyLogLine.Step := CopyStr(Step, 1, MaxStrLen(EnvCopyLogLine.Step));
        EnvCopyLogLine.Status := CopyStr(Status, 1, MaxStrLen(EnvCopyLogLine.Status));
        EnvCopyLogLine."Table No." := TableNo;
        EnvCopyLogLine.Message := CopyStr(Message, 1, MaxStrLen(EnvCopyLogLine.Message));
        EnvCopyLogLine.Insert(true);
        exit(EnvCopyLogLine."Line No.");
    end;

    procedure UpdateLineCounters(LogEntryNo: Integer; LineNo: Integer; UpdatedRecords: Integer; UpdatedFields: Integer)
    var
        EnvCopyLogLine: Record "GDRG Env Copy Log Line";
    begin
        if (LogEntryNo = 0) or (LineNo = 0) then
            exit;

        if not EnvCopyLogLine.Get(LogEntryNo, LineNo) then
            exit;

        EnvCopyLogLine."Records Affected" := UpdatedRecords;
        EnvCopyLogLine."Fields Affected" := UpdatedFields;
        EnvCopyLogLine.Modify(true);
    end;

    procedure FinishLine(LogEntryNo: Integer; LineNo: Integer; NewStatus: Text; Message: Text)
    var
        EnvCopyLogLine: Record "GDRG Env Copy Log Line";
        EndedAt: DateTime;
    begin
        if (LogEntryNo = 0) or (LineNo = 0) then
            exit;

        if not EnvCopyLogLine.Get(LogEntryNo, LineNo) then
            exit;

        EndedAt := CurrentDateTime();
        EnvCopyLogLine."Ended At" := EndedAt;
        EnvCopyLogLine."Duration (ms)" := EndedAt - EnvCopyLogLine."Started At";
        EnvCopyLogLine.Status := CopyStr(NewStatus, 1, MaxStrLen(EnvCopyLogLine.Status));
        if Message <> '' then
            EnvCopyLogLine.Message := CopyStr(Message, 1, MaxStrLen(EnvCopyLogLine.Message));
        EnvCopyLogLine.Modify(true);
    end;

    local procedure GetNextLineNo(LogEntryNo: Integer): Integer
    var
        EnvCopyLogLine: Record "GDRG Env Copy Log Line";
    begin
        EnvCopyLogLine.SetRange("Log Entry No.", LogEntryNo);
        if EnvCopyLogLine.FindLast() then
            exit(EnvCopyLogLine."Line No." + 10000);

        exit(10000);
    end;
}