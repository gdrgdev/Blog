codeunit 50101 "GDRG Forward Link Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Named Forward Link", OnLoad, '', false, false)]
    local procedure OnLoadCustomLinks()
    var
        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
    begin
        GDRGForwardLinkMgt.AddMyCustomLinks();
    end;
}
