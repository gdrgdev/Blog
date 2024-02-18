table 50104 GDRGDevAzDevopsRepoCommits
{
    Caption = 'Azure Devops Commits Repository';
    DataClassification = CustomerContent;
    //GET https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}/commits?api-version=7.2-preview.2
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
        field(60; "commitId"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(70; "authorName"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(80; "authorEmail"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(90; "authorDate"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(100; "committerName"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(110; "committerEmail"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(120; "committerDate"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(130; "comment"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(140; "url"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(150; "remoteUrl"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(160; "changeCountsAdd"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(170; "changeCountsEdit"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(180; "changeCountsDelete"; Integer)
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