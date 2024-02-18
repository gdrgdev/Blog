table 50105 GDRGDevAzDevopsRepoBranch
{
    Caption = 'Azure Devops Branch Repository';
    DataClassification = CustomerContent;
    //https://learn.microsoft.com/en-us/rest/api/azure/devops/git/refs?view=azure-devops-rest-7.2
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
        field(60; "name"; text[200])
        {
            DataClassification = CustomerContent;
        }
        field(70; "creatordisplayName"; text[200])
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