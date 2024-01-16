table 50101 "GDRGDevDevopsOrganization"
{
    Caption = 'Azure Devops Organization';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "AzureDevopsOrganization"; code[50])
        {
            Caption = 'Organization';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "AzureDevopsOrganization")
        {
            Clustered = true;
        }
    }
}