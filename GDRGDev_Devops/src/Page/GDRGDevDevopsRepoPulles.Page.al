page 50107 GDRGDevAzDevopsRepoPullRe
{
    ApplicationArea = All;
    Caption = 'Azure Devops Pull Requests Repository';
    PageType = List;
    SourceTable = GDRGDevAzDevopsRepoPull;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(RepeaterGDRGDevAzDevopsRepoPullR)
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
                field(createdBydisplayName; Rec.createdBydisplayName)
                {
                }
                field(pullRequestId; Rec.pullRequestId)
                {
                }
                field(codeReviewId; Rec.codeReviewId)
                {
                }
                field(status; Rec.status)
                {
                }
                field(title; Rec.title)
                {
                }
                field(description; Rec.description)
                {
                }
                field(creationDate; Rec.creationDate)
                {
                }
                field(sourceRefName; Rec.sourceRefName)
                {
                }
                field(targetRefName; Rec.targetRefName)
                {
                }
                field(mergeStatus; Rec.mergeStatus)
                {
                }
                field(url; Rec.url)
                {
                    ToolTip = 'Go to Azure Devops Pull Request Information - Repository';
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
