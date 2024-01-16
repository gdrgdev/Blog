page 50101 "GDRGDevAzDevopsOrganizations"
{
    Caption = 'Azure Devops Organizations';
    PageType = List;
    SourceTable = GDRGDevAzDevopsSetup;
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(RepeatAzureDevopsOrganizations)
            {
                field(AzureDevopsOrganization; rec.AzureDevopsOrganization)
                {
                    ApplicationArea = All;
                    ToolTip = 'Get List of Azure Devops Projects';
                    Style = StrongAccent;
                    trigger OnDrillDown()
                    begin
                        GDRGDev_getAzureDevopsProjects();
                    end;
                }
            }
        }
    }

    procedure GDRGDev_getAzureDevopsProjects()
    var
        GDRGDevDevopsProjectRecord: Record GDRGDevAzDevopsProject;
        GDRGDevAzDevopsProjectsPage: page GDRGDevAzDevopsProjects;
        GDRGDevDevopsMgtCU: Codeunit GDRGDevAzDevopsMgt;
    begin

        rec.TestField(AccessTokenAzureDevops);

        GDRGDevDevopsMgtCU.GDRGDev_getAzureDevopsProjects(rec, GDRGDevDevopsProjectRecord, rec.AzureDevopsOrganization);
        GDRGDevAzDevopsProjectsPage.SetRecord(GDRGDevDevopsProjectRecord);
        GDRGDevAzDevopsProjectsPage.GDRGDev_SetGDRGDevAzDevopsSetup(rec);
        GDRGDevAzDevopsProjectsPage.Run()

    end;

}