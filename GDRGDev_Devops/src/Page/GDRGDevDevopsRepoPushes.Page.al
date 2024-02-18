page 50106 GDRGDevAzDevopsRepoPushes
{
    ApplicationArea = All;
    Caption = 'Azure Devops Pushes Repository';
    PageType = List;
    SourceTable = GDRGDevAzDevopsRepoPush;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(RepeaterGDRGDevAzDevopsRepoPushes)
            {
                field(Pk; Rec.Pk)
                {
                    Visible = false;
                }
                field(id_AzureDevopsOrganization; Rec.id_AzureDevopsOrganization)
                {
                    Visible = false;
                }
                field(id_AzureDevopsProject; Rec.id_AzureDevopsProject)
                {
                    Visible = false;
                }
                field(id_AzureDevopsRepository; Rec.id_AzureDevopsRepository)
                {
                    Visible = false;
                }
                field(pushedBydisplayName; Rec.pushedBydisplayName)
                {
                }
                field(pushId; Rec.pushId)
                {
                }
                field(date; Rec.date)
                {
                }
                field(url; Rec.url)
                {
                    ToolTip = 'Go to Azure Devops Push Information - Repository';
                    Style = Favorable;
                    ExtendedDatatype = URL;
                }
            }
        }
    }
    procedure GDRGDev_SetGDRGDevAzDevopsSetup(var parGDRGDevAzDevopsSetup: Record GDRGDevAzDevopsSetup)
    begin
        GDRGDevAzDevopsSetup := parGDRGDevAzDevopsSetup;
    end;

    var
        GDRGDevAzDevopsSetup: Record GDRGDevAzDevopsSetup;
}
