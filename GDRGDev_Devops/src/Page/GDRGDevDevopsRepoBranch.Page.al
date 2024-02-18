page 50105 GDRGDevAzDevopsRepoBranches
{
    ApplicationArea = All;
    Caption = 'Azure Devops Branches Repository';
    PageType = List;
    SourceTable = GDRGDevAzDevopsRepoBranch;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(RepeaterGDRGDevAzDevopsRepoBranches)
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
                field(name; Rec.name)
                {
                }
                field(creatordisplayName; Rec.creatordisplayName)
                {
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
