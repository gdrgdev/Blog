codeunit 88895 "GDRG Company Feature Adjuster"
{
    Permissions = tabledata "GDRG Company Feature Setup" = rim;

    procedure RunForCompany(LogEntryNo: Integer; CompanyName: Text[30])
    var
        EnvCleanupMgt: Codeunit "GDRG Env Cleanup Mgt";
        StartLineNo: Integer;
        Success: Boolean;
    begin
        StartLineNo := EnvCleanupMgt.AddLineWithNo(LogEntryNo, CompanyName, 'Company feature adjustment', 'Started', 0, 'Apply company feature defaults.');
        Success := TryRunForCompany(CompanyName);
        if Success then
            EnvCleanupMgt.FinishLine(LogEntryNo, StartLineNo, 'Completed', 'Company feature setup adjusted.')
        else
            EnvCleanupMgt.FinishLine(LogEntryNo, StartLineNo, 'Failed', GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryRunForCompany(CompanyName: Text[30])
    var
        CompanyFeatureSetup: Record "GDRG Company Feature Setup";
    begin
        CompanyFeatureSetup.ChangeCompany(CompanyName);
        if not CompanyFeatureSetup.Get('SETUP') then begin
            CompanyFeatureSetup.Init();
            CompanyFeatureSetup."Primary Key" := 'SETUP';
            CompanyFeatureSetup.Insert(true);
        end;

        CompanyFeatureSetup."Feature Enabled" := false;
        CompanyFeatureSetup."Service Base URL" := GetAdjustedServiceBaseUrl(CompanyFeatureSetup."Service Base URL");
        CompanyFeatureSetup.Modify(true);
    end;

    local procedure GetAdjustedServiceBaseUrl(CurrentServiceBaseUrl: Text[250]): Text[250]
    var
        AdjustedServiceBaseUrl: Text;
    begin
        if CurrentServiceBaseUrl = '' then
            CurrentServiceBaseUrl := 'https://prod.contoso.local';

        AdjustedServiceBaseUrl := CurrentServiceBaseUrl;
        AdjustedServiceBaseUrl := AdjustedServiceBaseUrl.Replace('prod', 'test');
        AdjustedServiceBaseUrl := AdjustedServiceBaseUrl.Replace('Prod', 'Test');
        AdjustedServiceBaseUrl := AdjustedServiceBaseUrl.Replace('PROD', 'TEST');

        exit(CopyStr(AdjustedServiceBaseUrl, 1, 250));
    end;
}