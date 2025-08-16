table 60004 "GDRG API Call Log"
{
    Caption = 'API Call Log';
    LookupPageId = "GDRG API Call Log";
    DrillDownPageId = "GDRG API Call Log";
    DataClassification = ToBeClassified;
    Permissions = tabledata "GDRG API Call Log" = RD;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the sequential entry number for the API call log.';
            AllowInCustomizations = Never;
        }
        field(10; "API URL"; Text[2048])
        {
            Caption = 'API URL';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the complete URL called to the API, including parameters.';
        }
        field(20; "API Type"; Enum "GDRG API Call Type")
        {
            Caption = 'API Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of API call (Projects, Time Entries, etc.).';
        }
        field(30; "HTTP Method"; Text[10])
        {
            Caption = 'HTTP Method';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the HTTP method used (GET, POST, etc.).';
        }
        field(40; "Response Status"; Integer)
        {
            Caption = 'Response Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the HTTP response status code.';
        }
        field(50; "Records Processed"; Integer)
        {
            Caption = 'Records Processed';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of records processed from this API call.';
        }
        field(60; "Execution Time (ms)"; Integer)
        {
            Caption = 'Execution Time (ms)';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the execution time in milliseconds.';
        }
        field(70; "Error Message"; Text[500])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies any error message if the API call failed.';
        }
        field(80; "Is Manual Call"; Boolean)
        {
            Caption = 'Is Manual Call';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if this was a manual call (true) or automated job queue call (false).';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(CreatedDateKey; SystemCreatedAt)
        {
        }
        key(APITypeKey; "API Type", SystemCreatedAt)
        {
        }
        key(ManualCallKey; "Is Manual Call", SystemCreatedAt)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "API Type", "HTTP Method", "Response Status", SystemCreatedAt)
        {
        }
        fieldgroup(Brick; "Entry No.", "API Type", "Records Processed", SystemCreatedAt)
        {
        }
    }

    procedure LogSuccessfulCall(APIURL: Text; APIType: Enum "GDRG API Call Type"; HTTPMethod: Text; ResponseStatus: Integer; RecordsProcessed: Integer; ExecutionTimeMs: Integer; IsManualCall: Boolean)
    begin
        Init();
        "Entry No." := GetNextEntryNo();
        "API URL" := CopyStr(APIURL, 1, MaxStrLen("API URL"));
        "API Type" := APIType;
        "HTTP Method" := CopyStr(HTTPMethod, 1, MaxStrLen("HTTP Method"));
        "Response Status" := ResponseStatus;
        "Records Processed" := RecordsProcessed;
        "Execution Time (ms)" := ExecutionTimeMs;
        "Is Manual Call" := IsManualCall;
        "Error Message" := '';
        Insert(true);
    end;

    procedure LogFailedCall(APIURL: Text; APIType: Enum "GDRG API Call Type"; HTTPMethod: Text; ResponseStatus: Integer; ErrorMessage: Text; ExecutionTimeMs: Integer; IsManualCall: Boolean)
    begin
        Init();
        "Entry No." := GetNextEntryNo();
        "API URL" := CopyStr(APIURL, 1, MaxStrLen("API URL"));
        "API Type" := APIType;
        "HTTP Method" := CopyStr(HTTPMethod, 1, MaxStrLen("HTTP Method"));
        "Response Status" := ResponseStatus;
        "Records Processed" := 0;
        "Execution Time (ms)" := ExecutionTimeMs;
        "Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen("Error Message"));
        "Is Manual Call" := IsManualCall;
        Insert(true);
    end;

    procedure CleanupOldLogs(DaysToKeep: Integer)
    var
        APICallLogRec: Record "GDRG API Call Log";
        DateFormula: DateFormula;
        CleanupDate: DateTime;
        DaysFormulaTxt: Label '-%1D', Comment = '%1 = Number of days', Locked = true;
    begin
        Evaluate(DateFormula, StrSubstNo(DaysFormulaTxt, DaysToKeep));
        CleanupDate := CreateDateTime(CalcDate(DateFormula, Today()), Time());
        APICallLogRec.Reset();
        APICallLogRec.SetFilter(SystemCreatedAt, '<%1', CleanupDate);
        APICallLogRec.DeleteAll(true);
    end;

    local procedure GetNextEntryNo(): Integer
    var
        APICallLogRec: Record "GDRG API Call Log";
    begin
        APICallLogRec.Reset();
        APICallLogRec.SetCurrentKey("Entry No.");
        if APICallLogRec.FindLast() then
            exit(APICallLogRec."Entry No." + 1)
        else
            exit(1);
    end;
}
