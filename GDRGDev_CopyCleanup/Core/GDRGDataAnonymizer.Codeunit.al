codeunit 88889 "GDRG Data Anonymizer"
{
    Permissions = tabledata "GDRG Anonymize Setup" = r,
                  tabledata "GDRG Anonymize Field Setup" = r;

    procedure RunForCompany(LogEntryNo: Integer; CompanyName: Text[30])
    var
        AnonymizeSetup: Record "GDRG Anonymize Setup";
    begin
        AnonymizeSetup.SetRange(Enabled, true);
        if AnonymizeSetup.FindSet() then
            repeat
                RunTable(LogEntryNo, CompanyName, AnonymizeSetup);
            until AnonymizeSetup.Next() = 0;
    end;

    local procedure RunTable(LogEntryNo: Integer; CompanyName: Text[30]; AnonymizeSetup: Record "GDRG Anonymize Setup")
    var
        AnonymizeFieldSetup: Record "GDRG Anonymize Field Setup";
        EnvCleanupMgt: Codeunit "GDRG Env Cleanup Mgt";
        StartLineNo: Integer;
        Success: Boolean;
    begin
        AnonymizeFieldSetup.SetRange("Table No.", AnonymizeSetup."Table No.");
        AnonymizeFieldSetup.SetRange(Enabled, true);
        if AnonymizeFieldSetup.IsEmpty() then begin
            EnvCleanupMgt.AddLine(LogEntryNo, CompanyName, 'Table anonymization skipped', 'Skipped', AnonymizeSetup."Table No.", 'No enabled fields configured.');
            exit;
        end;

        StartLineNo := EnvCleanupMgt.AddLineWithNo(LogEntryNo, CompanyName, 'Table anonymization', 'Started', AnonymizeSetup."Table No.", AnonymizeSetup."Table Name");
        Success := TryRunTable(LogEntryNo, CompanyName, AnonymizeSetup."Table No.", StartLineNo);
        if Success then
            EnvCleanupMgt.FinishLine(LogEntryNo, StartLineNo, 'Completed', AnonymizeSetup."Table Name")
        else
            EnvCleanupMgt.FinishLine(LogEntryNo, StartLineNo, 'Failed', GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryRunTable(LogEntryNo: Integer; CompanyName: Text[30]; TableNo: Integer; StartLineNo: Integer)
    var
        AnonymizeFieldSetup: Record "GDRG Anonymize Field Setup";
        FieldMetadata: Record Field;
        EnvCleanupMgt: Codeunit "GDRG Env Cleanup Mgt";
        Pseudonymizer: Codeunit "GDRG Pseudonymizer";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        UpdatedRecords: Integer;
        UpdatedFields: Integer;
    begin
        RecordRef.Open(TableNo, false, CompanyName);
        if RecordRef.FindSet() then
            repeat
                AnonymizeFieldSetup.SetRange("Table No.", TableNo);
                AnonymizeFieldSetup.SetRange(Enabled, true);
                if AnonymizeFieldSetup.FindSet() then
                    repeat
                        if FieldMetadata.Get(TableNo, AnonymizeFieldSetup."Field No.") then begin
                            FieldRef := RecordRef.Field(AnonymizeFieldSetup."Field No.");
                            if Format(FieldRef.Value()) <> '' then begin
                                FieldRef.Value := Pseudonymizer.GetValue(Format(FieldRef.Value()), FieldMetadata.Len);
                                UpdatedFields += 1;
                            end;
                        end;
                    until AnonymizeFieldSetup.Next() = 0;

                RecordRef.Modify(false);
                UpdatedRecords += 1;
            until RecordRef.Next() = 0;

        EnvCleanupMgt.UpdateLineCounters(LogEntryNo, StartLineNo, UpdatedRecords, UpdatedFields);
        RecordRef.Close();
    end;
}