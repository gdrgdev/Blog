table 50103 GDRGDevAzDevopsRepository
{
    Caption = 'Azure Devops Repository';
    DataClassification = CustomerContent;

    fields
    {
        field(10; Pk; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(20; id_UserID; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "id_AzureDevopsRepository"; text[100])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(40; "id_AzureDevopsOrganization"; code[50])
        {
            Caption = 'Organization';
            DataClassification = CustomerContent;
        }
        field(50; "id"; text[100])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(60; "name"; text[300])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(70; "url"; text[300])
        {

        }
        field(80; "defaultBranch"; text[300])
        {
            Caption = 'Default Branch';
            DataClassification = CustomerContent;
        }
        field(90; "size"; Decimal)
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
        }
        field(100; "remoteUrl"; text[300])
        {
            Caption = 'Remote URL';
            DataClassification = CustomerContent;
        }
        field(110; "sshUrl"; text[300])
        {
            Caption = 'SSH Url';
            DataClassification = CustomerContent;
        }
        field(120; "webUrlLink"; text[300])
        {
            Caption = 'Web URL';
            DataClassification = CustomerContent;
        }
        field(130; "isDisabled"; Boolean)
        {
            Caption = 'Is Disabled';
            DataClassification = CustomerContent;
        }
        field(140; "id_AzDevopsProject"; text[300])
        {

        }
        field(150; "name_AzDevopsProject"; text[300])
        {

        }
        field(160; "description_AzDevopsProject"; text[300])
        {

        }
        field(170; "url_AzDevopsProject"; text[300])
        {

        }

        field(180; "state_AzDevopsProject"; text[300])
        {

        }
        field(190; "revision_AzDevopsProject"; text[300])
        {

        }
        field(200; "visibility_AzDevopsProject"; text[300])
        {

        }
        field(210; "lastUpdateTime_AzDevopsProject"; DateTime)
        {

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