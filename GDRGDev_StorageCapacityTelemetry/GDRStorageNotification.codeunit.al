codeunit 80002 GDRStorageNotification
{
    procedure GotoBusinessCentralAdmin(GotoBusinessCentralAdmin: Notification)
    var
        recGDRApiMgt: Record GDRApiMgt;
    begin
        if recGDRApiMgt.Get() then;
        recGDRApiMgt.TestField(recGDRApiMgt.apitenant);
        system.Hyperlink('https://businesscentral.dynamics.com/' + recGDRApiMgt.apitenant + '/admin');
    end;
}