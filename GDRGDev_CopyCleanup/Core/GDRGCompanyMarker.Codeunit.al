codeunit 88890 "GDRG Company Marker"
{
    Permissions = tabledata "Company Information" = rm;

    procedure RunForCompany(LogEntryNo: Integer; CompanyName: Text[30])
    var
        EnvCleanupMgt: Codeunit "GDRG Env Cleanup Mgt";
        StartLineNo: Integer;
        Success: Boolean;
    begin
        StartLineNo := EnvCleanupMgt.AddLineWithNo(LogEntryNo, CompanyName, 'Company marking', 'Started', 0, 'Apply company copy markers.');
        Success := TryRunForCompany(CompanyName);
        if Success then
            EnvCleanupMgt.FinishLine(LogEntryNo, StartLineNo, 'Completed', 'Company copy markers applied.')
        else
            EnvCleanupMgt.FinishLine(LogEntryNo, StartLineNo, 'Failed', GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryRunForCompany(CompanyName: Text[30])
    var
        Company: Record Company;
        CompanyInformation: Record "Company Information";
        MarkerText: Text;
    begin
        MarkerText := '[COPY]';

        Company.ChangeCompany(CompanyName);
        if Company.Get(CompanyName) then
            if StrPos(Company."Display Name", MarkerText) = 0 then begin
                Company."Display Name" := CopyStr(Company."Display Name" + ' ' + MarkerText, 1, MaxStrLen(Company."Display Name"));
                Company.Modify(true);
            end;

        CompanyInformation.ChangeCompany(CompanyName);
        if CompanyInformation.Get() then begin
            if StrPos(CompanyInformation.Name, MarkerText) = 0 then
                CompanyInformation.Name := CopyStr(CompanyInformation.Name + ' ' + MarkerText, 1, MaxStrLen(CompanyInformation.Name));
            CompanyInformation."System Indicator" := CompanyInformation."System Indicator"::Custom;
            CompanyInformation."System Indicator Style" := CompanyInformation."System Indicator Style"::Accent6;
            CompanyInformation."Custom System Indicator Text" := CopyStr('SANDBOX COPY', 1, MaxStrLen(CompanyInformation."Custom System Indicator Text"));
            CompanyInformation.Modify(false);
        end;
    end;
}