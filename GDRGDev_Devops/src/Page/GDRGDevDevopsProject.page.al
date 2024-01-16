page 50102 GDRGDevAzDevopsProjects
{
    Caption = 'Azure Devops Projects';
    PageType = List;
    SourceTable = GDRGDevAzDevopsProject;
    PromotedActionCategories = 'New,Process,Report,Repositories,Works,Teams,Comentario';
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(RepeatGDRGDevAzDevopsProjects)
            {
                field(id_AzureDevopsProject; rec.id_AzureDevopsProject)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(name; rec.name)
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Get List of Azure Devops Repositories';

                    trigger OnDrillDown()
                    var
                        GDRGDevAzDevopsMgtCU: Codeunit GDRGDevAzDevopsMgt;
                        GDRGDevAzDevopsRepositoriesPage: page GDRGDevAzDevopsRepositories;
                        GDRGDevAzDevopsRepositoryRecord: Record GDRGDevAzDevopsRepository;
                    begin
                        GDRGDevAzDevopsMgtCU.GDRGDev_getAzureDevopsRepositories(
                                GDRGDevAzDevopsSetup, GDRGDevAzDevopsRepositoryRecord,
                                rec.id_AzureDevopsOrganization, rec.id_AzureDevopsProject);
                        GDRGDevAzDevopsRepositoriesPage.SetRecord(GDRGDevAzDevopsRepositoryRecord);
                        GDRGDevAzDevopsRepositoriesPage.GDRGDev_SetGDRGDevAzDevopsSetup(GDRGDevAzDevopsSetup);
                        GDRGDevAzDevopsRepositoriesPage.Run();
                    end;
                }
                field(description; rec.description)
                {
                    ApplicationArea = All;
                }

                field(visibility; rec.visibility)
                {
                    ApplicationArea = All;
                }
                field(revision; rec.revision)
                {
                    ApplicationArea = All;
                }
                field(url; rec.url)
                {
                    ApplicationArea = All;
                    ToolTip = 'Go to Azure Devops Project';
                    Style = Favorable;
                    ExtendedDatatype = URL;
                }
                field(lastUpdateTime; rec.lastUpdateTime)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GDRGDev_getURLRepositories
    end;

    procedure GDRGDev_SetGDRGDevAzDevopsSetup(var parGDRGDevAzDevopsSetup: Record GDRGDevAzDevopsSetup)
    begin
        GDRGDevAzDevopsSetup := parGDRGDevAzDevopsSetup;
    end;

    procedure GDRGDev_getURLRepositories()
    var
        urlGDRGDevAzDevopsProjects: text;
    begin
        if rec.url.IndexOf('_') <> 0 then begin
            urlGDRGDevAzDevopsProjects := rec.url.Substring(1, rec.url.IndexOf('_') - 1);
            urlGDRGDevAzDevopsProjects := urlGDRGDevAzDevopsProjects + rec.name;
            rec.url := urlGDRGDevAzDevopsProjects;
        end;
    end;

    var
        GDRGDevAzDevopsSetup: Record GDRGDevAzDevopsSetup;

}