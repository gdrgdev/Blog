table 80000 GDRGeolocationSetup
{
    Caption = 'GDR Geolocation Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
        }

        field(2; "Api Key Azure Maps"; Text[50])
        {
            Caption = 'Api Key Azure Maps';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "POI"; Text[50])
        {
            Caption = 'Point of Interest';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
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