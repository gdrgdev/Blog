table 50102 GDRGDevAzDevopsProject
{
    Caption = 'Azure Devops Project';
    DataClassification = CustomerContent;

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
        field(30; "id_AzureDevopsProject"; text[100])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;

        }
        field(40; "id_AzureDevopsOrganization"; code[50])
        {
            Caption = 'Azure Devops Organization';
            DataClassification = CustomerContent;
        }
        field(50; "name"; text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(60; "description"; text[300])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(70; "url"; text[100])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;
        }
        field(80; "state"; text[100])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(90; "revision"; text[100])
        {
            Caption = 'Revision';
            DataClassification = CustomerContent;
        }
        field(100; "visibility"; text[100])
        {
            Caption = 'Visibility';
            DataClassification = CustomerContent;
        }
        field(110; "lastUpdateTime"; DateTime)
        {
            Caption = 'Last Update Time';
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