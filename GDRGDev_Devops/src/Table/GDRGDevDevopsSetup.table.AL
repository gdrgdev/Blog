table 50100 GDRGDevAzDevopsSetup
{
    Caption = 'Azure Devops Personal Access Tokens Setup';
    DataClassification = CustomerContent;

    fields
    {

        field(10; AzureDevopsOrganization; text[100])
        {
            Caption = 'Organization';
            DataClassification = CustomerContent;
        }
        field(20; AccessTokenAzureDevops; text[100])
        {
            Caption = 'Access Token';
            DataClassification = CustomerContent;
        }


    }
    keys
    {
        key(Key1; AzureDevopsOrganization)
        {
            Clustered = true;
        }

    }
}
