table 80001 GDRGeoWeather
{
    Caption = 'GDRGeoWeather';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "code"; Integer)
        {
            Caption = 'code';
            AutoIncrement = true;
        }
        field(2; phrase; Text[50])
        {
            Caption = 'phrase';
        }
        field(3; temperaturevalue; Text[50])
        {
            Caption = 'temperaturevalue';
        }
        field(4; temperatureunit; Text[50])
        {
            Caption = 'temperatureunit';
        }
        field(5; dateTime; Text[50])
        {
            Caption = 'dateTime';
        }

    }
    keys
    {
        key(PK; "code")
        {
            Clustered = true;
        }
    }
}
