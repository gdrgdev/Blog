table 50107 GDRGDevAzDevopsRepoPull
{
    Caption = 'Azure Devops Pull Request Repository';
    DataClassification = CustomerContent;
    //https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-requests?view=azure-devops-rest-7.2

    fields
    {
        field(10; Pk; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(20; id_UserID; code[50])
        {
            DataClassification = CustomerContent;
        }
        field(30; "id_AzureDevopsRepository"; code[50])
        {
            DataClassification = CustomerContent;

        }
        field(40; "id_AzureDevopsProject"; code[50])
        {
            DataClassification = CustomerContent;
        }
        field(50; "id_AzureDevopsOrganization"; code[50])
        {
            DataClassification = CustomerContent;
        }
        field(70; "pullRequestId"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(80; "codeReviewId"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(90; "status"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(100; "createdBydisplayName"; Code[200])
        {
            DataClassification = CustomerContent;
        }
        field(110; "creationDate"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(120; "title"; Code[200])
        {
            DataClassification = CustomerContent;
        }
        field(130; "description"; Code[200])
        {
            DataClassification = CustomerContent;
        }
        field(140; "sourceRefName"; Code[200])
        {
            DataClassification = CustomerContent;
        }
        field(150; "targetRefName"; Code[200])
        {
            DataClassification = CustomerContent;
        }
        field(160; "mergeStatus"; Code[200])
        {
            DataClassification = CustomerContent;
        }

        field(170; "url"; text[200])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; pk, id_UserID)
        {
            Clustered = true;
        }
    }
}