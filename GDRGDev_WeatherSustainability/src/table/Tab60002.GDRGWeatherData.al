table 60002 "GDRG Weather Data"
{
    Caption = 'Weather Data';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Weather Data List";
    DrillDownPageId = "GDRG Weather Data List";
    Permissions = tabledata "GDRG Weather Data" = RIMD;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies the entry number.';
            AllowInCustomizations = Never;
        }
        field(10; Latitude; Decimal)
        {
            Caption = 'Latitude';
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the latitude coordinate.';
        }
        field(20; Longitude; Decimal)
        {
            Caption = 'Longitude';
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the longitude coordinate.';
        }
        field(30; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
            ToolTip = 'Specifies the date and time of the weather data.';
        }
        field(40; "Unix Timestamp"; BigInteger)
        {
            Caption = 'Unix Timestamp';
            ToolTip = 'Specifies the unix timestamp (dt field).';
        }
        field(50; Timezone; Text[50])
        {
            Caption = 'Timezone';
            ToolTip = 'Specifies the timezone.';
        }
        field(60; "Timezone Offset"; Integer)
        {
            Caption = 'Timezone Offset';
            ToolTip = 'Specifies the timezone offset in seconds.';
        }
        field(70; "Sunrise Time"; DateTime)
        {
            Caption = 'Sunrise Time';
            ToolTip = 'Specifies the sunrise time.';
        }
        field(80; "Sunset Time"; DateTime)
        {
            Caption = 'Sunset Time';
            ToolTip = 'Specifies the sunset time.';
        }
        field(90; Temperature; Decimal)
        {
            Caption = 'Temperature';
            ToolTip = 'Specifies the temperature in Celsius.';
        }
        field(100; "Feels Like"; Decimal)
        {
            Caption = 'Feels Like';
            ToolTip = 'Specifies the feels like temperature in Celsius.';
        }
        field(110; Pressure; Integer)
        {
            Caption = 'Pressure';
            ToolTip = 'Specifies the atmospheric pressure in hPa.';
        }
        field(120; Humidity; Integer)
        {
            Caption = 'Humidity';
            ToolTip = 'Specifies the humidity percentage.';
        }
        field(130; "Dew Point"; Decimal)
        {
            Caption = 'Dew Point';
            ToolTip = 'Specifies the dew point in Celsius.';
        }
        field(140; "UV Index"; Decimal)
        {
            Caption = 'UV Index';
            ToolTip = 'Specifies the UV index.';
        }
        field(150; Clouds; Integer)
        {
            Caption = 'Clouds';
            ToolTip = 'Specifies the cloudiness percentage.';
        }
        field(160; Visibility; Integer)
        {
            Caption = 'Visibility';
            ToolTip = 'Specifies the visibility in meters.';
        }
        field(170; "Wind Speed"; Decimal)
        {
            Caption = 'Wind Speed';
            ToolTip = 'Specifies the wind speed in m/s.';
        }
        field(180; "Wind Degree"; Integer)
        {
            Caption = 'Wind Degree';
            ToolTip = 'Specifies the wind direction in degrees.';
        }
        field(190; "Wind Gust"; Decimal)
        {
            Caption = 'Wind Gust';
            ToolTip = 'Specifies the wind gust in m/s.';
        }
        field(200; "Weather ID"; Integer)
        {
            Caption = 'Weather ID';
            ToolTip = 'Specifies the weather condition ID.';
        }
        field(210; "Weather Main"; Text[50])
        {
            Caption = 'Weather Main';
            ToolTip = 'Specifies the main weather condition.';
        }
        field(220; "Weather Description"; Text[100])
        {
            Caption = 'Weather Description';
            ToolTip = 'Specifies the weather description.';
        }
        field(230; "Weather Icon"; Text[10])
        {
            Caption = 'Weather Icon';
            ToolTip = 'Specifies the weather icon code.';
        }
        field(240; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            ToolTip = 'Specifies when the record was created.';
            AllowInCustomizations = Never;
        }
        field(250; "Last Updated"; DateTime)
        {
            Caption = 'Last Updated';
            ToolTip = 'Specifies when the record was last updated.';
            AllowInCustomizations = Never;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(LocationTime; Latitude, Longitude, "Unix Timestamp")
        {
            Unique = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Latitude, Longitude, "Date Time", "Weather Main")
        {
        }
        fieldgroup(Brick; Latitude, Longitude, Temperature, "Weather Description")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Created Date" = 0DT then
            "Created Date" := CurrentDateTime();
        "Last Updated" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Last Updated" := CurrentDateTime();
    end;

    procedure WeatherDataExists(Lat: Decimal; Lon: Decimal; UnixTimestamp: BigInteger): Boolean
    var
        WeatherData: Record "GDRG Weather Data";
    begin
        WeatherData.SetRange(Latitude, Lat);
        WeatherData.SetRange(Longitude, Lon);
        WeatherData.SetRange("Unix Timestamp", UnixTimestamp);
        exit(not WeatherData.IsEmpty());
    end;

    procedure GetWeatherData(Lat: Decimal; Lon: Decimal; UnixTimestamp: BigInteger; var WeatherData: Record "GDRG Weather Data"): Boolean
    begin
        WeatherData.SetRange(Latitude, Lat);
        WeatherData.SetRange(Longitude, Lon);
        WeatherData.SetRange("Unix Timestamp", UnixTimestamp);
        exit(WeatherData.FindFirst());
    end;
}
