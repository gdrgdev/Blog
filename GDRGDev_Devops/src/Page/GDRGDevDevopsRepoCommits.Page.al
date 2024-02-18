page 50104 GDRGDevAzDevopsRepoCommits
{
    ApplicationArea = All;
    Caption = 'Azure Devops Commits Repository';
    PageType = List;
    SourceTable = GDRGDevAzDevopsRepoCommits;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(RepeaterGDRGDevAzDevopsRepoCommits)
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
                }
                field(remoteUrl; Rec.remoteUrl)
                {
                    ToolTip = 'Go to Azure Devops Commit';
                    Style = Favorable;
                    ExtendedDatatype = URL;
                }
                field(authorDate; Rec.authorDate)
                {
                }
                field(authorEmail; Rec.authorEmail)
                {
                }
                field(authorName; Rec.authorName)
                {
                }

                field(comment; Rec.comment)
                {
                }
                field(commitId; Rec.commitId)
                {
                }
                field(committerDate; Rec.committerDate)
                {
                }
                field(committerEmail; Rec.committerEmail)
                {
                }
                field(committerName; Rec.committerName)
                {
                }
                field(changeCountsAdd; Rec.changeCountsAdd)
                {
                }
                field(changeCountsDelete; Rec.changeCountsDelete)
                {
                }
                field(changeCountsEdit; Rec.changeCountsEdit)
                {
                }

                field(url; Rec.url)
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
