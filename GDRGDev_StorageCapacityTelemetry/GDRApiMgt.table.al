table 80000 GDRApiMgt
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
        }
        field(2; apitenant; Text[50])
        {
            Caption = 'Api Tenant';
        }
        field(3; apiclienteid; Text[50])
        {
            Caption = 'Api Cliente ID';
        }
        field(4; apisecreto; Text[50])
        {
            Caption = 'Api Secreto';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        Fetched: Boolean;

    procedure Fetch()
    begin
        if Fetched then
            exit;
        Fetched := true;
        if not Get() then
            Init();
    end;
}