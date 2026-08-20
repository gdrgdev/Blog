codeunit 88894 "GDRG Copy Company Subscriber"
{
    Permissions = tabledata "GDRG Cleanup Setup" = r;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", OnAfterCreatedNewCompanyByCopyCompany, '', false, false)]
    local procedure OnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        CleanupSetup: Record "GDRG Cleanup Setup";
        EnvCleanupSubscriber: Codeunit "GDRG Env Cleanup Subscriber";
    begin
        if not CleanupSetup.Get('SETUP') then
            exit;

        if not CleanupSetup."Run Company Cleanup After Copy" then
            exit;

        EnvCleanupSubscriber.RunManualCleanup(NewCompanyName);
    end;
}