codeunit 88888 "GDRG Env Cleanup Subscriber"
{
    SingleInstance = true;

    var
        CurrentLogEntryNo: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearDatabaseConfig, '', false, false)]
    local procedure OnClearDatabaseConfig()
    var
        EnvCleanupMgt: Codeunit "GDRG Env Cleanup Mgt";
    begin
        if not IsEnvironmentCopyCleanupEnabled() then
            exit;

        EnvCleanupMgt.EnsureLog(CurrentLogEntryNo, 'Environment Copy', GetEnvironmentNameSafe(), 'OnClearDatabaseConfig');
        EnvCleanupMgt.FinishLog(CurrentLogEntryNo, 'OnClearDatabaseConfig', 'Completed');
        CurrentLogEntryNo := 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text)
    begin
        if not IsEnvironmentCopyCleanupEnabled() then
            exit;

        RunCleanup(CopyStr(CompanyName, 1, 30), 'Environment Copy', 'OnClearCompanyConfig');
    end;

    procedure RunManualCleanup(CompanyName: Text[30])
    begin
        RunCleanup(CompanyName, 'Manual Run', 'Manual Cleanup');
    end;

    local procedure RunCleanup(CompanyName: Text[30]; TriggerType: Text; EventName: Text)
    var
        EnvCleanupMgt: Codeunit "GDRG Env Cleanup Mgt";
        DataAnonymizer: Codeunit "GDRG Data Anonymizer";
        CompanyMarker: Codeunit "GDRG Company Marker";
        CompanyFeatureAdjuster: Codeunit "GDRG Company Feature Adjuster";
        CompanyLineNo: Integer;
    begin
        EnvCleanupMgt.EnsureLog(CurrentLogEntryNo, TriggerType, GetEnvironmentNameSafe(), EventName);
        EnvCleanupMgt.SetLogCompany(CurrentLogEntryNo, CompanyName);
        CompanyLineNo := EnvCleanupMgt.AddLineWithNo(CurrentLogEntryNo, CompanyName, 'Company cleanup (total)', 'Started', 0, EventName + ' received.');
        DataAnonymizer.RunForCompany(CurrentLogEntryNo, CompanyName);
        CompanyMarker.RunForCompany(CurrentLogEntryNo, CompanyName);
        CompanyFeatureAdjuster.RunForCompany(CurrentLogEntryNo, CompanyName);
        EnvCleanupMgt.FinishLine(CurrentLogEntryNo, CompanyLineNo, 'Completed', 'Company cleanup total finished.');
        EnvCleanupMgt.FinishLog(CurrentLogEntryNo, EventName, 'Completed');
        CurrentLogEntryNo := 0;
    end;

    local procedure GetEnvironmentNameSafe(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        exit(EnvironmentInformation.GetEnvironmentName());
    end;

    local procedure IsEnvironmentCopyCleanupEnabled(): Boolean
    var
        CleanupSetup: Record "GDRG Cleanup Setup";
    begin
        if not CleanupSetup.Get('SETUP') then
            exit(false);

        exit(CleanupSetup."Run Env. Cleanup After Copy");
    end;
}