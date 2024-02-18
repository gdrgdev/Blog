page 50103 GDRGDevAzDevopsRepositories
{
    Caption = 'Azure Devops Repositories';
    PageType = List;
    SourceTable = GDRGDevAzDevopsRepository;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(RepeaterGDRGDevAzDevopsRepositories)
            {
                field(id; rec.id)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(name; rec.name)
                {
                    ApplicationArea = All;
                }


                field(defaultBranch; rec.defaultBranch)
                {
                    ApplicationArea = All;
                }
                field(size; rec.size)
                {
                    ApplicationArea = All;
                }
                field(isDisabled; rec.isDisabled)
                {
                    ApplicationArea = All;
                }


                field(webUrlLink; rec.webUrlLink)
                {
                    ApplicationArea = All;
                    ToolTip = 'Go to Azure Devops Repository';
                    Style = Favorable;
                    ExtendedDatatype = URL;
                }
            }
        }

    }
    actions
    {
        area(Creation)
        {
            group("Actions")
            {
                action("Commits")
                {
                    Caption = 'Commits';
                    Image = List;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        GDRGDevAzDevopsMgtCU: Codeunit GDRGDevAzDevopsMgt;
                        GDRGDevAzDevopsRepositoryCommitsPage: page GDRGDevAzDevopsRepoCommits;
                        GDRGDevAzDevopsRepositoryCommitsRecord: Record GDRGDevAzDevopsRepoCommits;
                    begin
                        GDRGDevAzDevopsMgtCU.GDRGDev_getAzureDevopsRepoCommits(
                                GDRGDevAzDevopsSetup, GDRGDevAzDevopsRepositoryCommitsRecord,
                                rec.id_AzureDevopsOrganization,
                                rec.name_AzDevopsProject,
                                rec.name);
                        GDRGDevAzDevopsRepositoryCommitsPage.SetRecord(GDRGDevAzDevopsRepositoryCommitsRecord);
                        GDRGDevAzDevopsRepositoryCommitsPage.GDRGDev_SetGDRGDevAzDevopsSetup(GDRGDevAzDevopsSetup);
                        GDRGDevAzDevopsRepositoryCommitsPage.Run();
                    end;
                }
                action("Branches")
                {
                    Caption = 'Branches';
                    Image = ShowList;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        GDRGDevAzDevopsMgtCU: Codeunit GDRGDevAzDevopsMgt;
                        GDRGDevAzDevopsRepositoryBranchesPage: page GDRGDevAzDevopsRepoBranches;
                        GDRGDevAzDevopsRepositoryBranchesRecord: Record GDRGDevAzDevopsRepoBranch;
                    begin
                        GDRGDevAzDevopsMgtCU.GDRGDev_getAzureDevopsRepoBranches(
                                GDRGDevAzDevopsSetup, GDRGDevAzDevopsRepositoryBranchesRecord,
                                rec.id_AzureDevopsOrganization,
                                rec.name_AzDevopsProject,
                                rec.id);
                        GDRGDevAzDevopsRepositoryBranchesPage.SetRecord(GDRGDevAzDevopsRepositoryBranchesRecord);
                        GDRGDevAzDevopsRepositoryBranchesPage.GDRGDev_SetGDRGDevAzDevopsSetup(GDRGDevAzDevopsSetup);
                        GDRGDevAzDevopsRepositoryBranchesPage.Run();
                    end;
                }
                action("Pushes")
                {
                    Caption = 'Pushes';
                    Image = LinesFromTimesheet;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        GDRGDevAzDevopsMgtCU: Codeunit GDRGDevAzDevopsMgt;
                        GDRGDevAzDevopsRepositoryPushesPage: page GDRGDevAzDevopsRepoPushes;
                        GDRGDevAzDevopsRepositoryPushesRecord: Record GDRGDevAzDevopsRepoPush;
                    begin
                        GDRGDevAzDevopsMgtCU.GDRGDev_getAzureDevopsRepoPushes(
                                GDRGDevAzDevopsSetup, GDRGDevAzDevopsRepositoryPushesRecord,
                                rec.id_AzureDevopsOrganization,
                                rec.name_AzDevopsProject,
                                rec.id);
                        GDRGDevAzDevopsRepositoryPushesPage.SetRecord(GDRGDevAzDevopsRepositoryPushesRecord);
                        GDRGDevAzDevopsRepositoryPushesPage.GDRGDev_SetGDRGDevAzDevopsSetup(GDRGDevAzDevopsSetup);
                        GDRGDevAzDevopsRepositoryPushesPage.Run();
                    end;
                }
                action("Pull Requests")
                {
                    Caption = 'Pull Requests';
                    Image = GetLines;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        GDRGDevAzDevopsMgtCU: Codeunit GDRGDevAzDevopsMgt;
                        GDRGDevAzDevopsRepositoryPullRPage: page GDRGDevAzDevopsRepoPullRe;
                        GDRGDevAzDevopsRepositoryPullRRecord: Record GDRGDevAzDevopsRepoPull;
                    begin
                        GDRGDevAzDevopsMgtCU.GDRGDev_getAzureDevopsRepoPullRequests(
                                GDRGDevAzDevopsSetup, GDRGDevAzDevopsRepositoryPullRRecord,
                                rec.id_AzureDevopsOrganization,
                                rec.name_AzDevopsProject,
                                rec.id);
                        GDRGDevAzDevopsRepositoryPullRPage.SetRecord(GDRGDevAzDevopsRepositoryPullRRecord);
                        GDRGDevAzDevopsRepositoryPullRPage.GDRGDev_SetGDRGDevAzDevopsSetup(GDRGDevAzDevopsSetup);
                        GDRGDevAzDevopsRepositoryPullRPage.Run();
                    end;
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