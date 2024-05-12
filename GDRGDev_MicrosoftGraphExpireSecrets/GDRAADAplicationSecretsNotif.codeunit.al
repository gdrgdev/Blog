codeunit 80003 GDRAADAplicationSecretsNotif
{
    procedure GotoAzurePortal(GotoAzurePortal: Notification)
    begin
        system.Hyperlink('https://portal.azure.com/#home');
    end;

}
