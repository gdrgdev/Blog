tableextension 60003 "GDRG Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(60100; "GDRG Latitude"; Decimal)
        {
            Caption = 'Latitude';
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the latitude coordinate for weather data.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60101; "GDRG Longitude"; Decimal)
        {
            Caption = 'Longitude';
            DecimalPlaces = 0 : 4;
            ToolTip = 'Specifies the longitude coordinate for weather data.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60102; "GDRG Date Time"; DateTime)
        {
            Caption = 'Date Time';
            ToolTip = 'Specifies the date and time for weather data.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60103; "GDRG Temperature"; Decimal)
        {
            Caption = 'Temperature';
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the temperature in Celsius.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60104; "GDRG Feels Like"; Decimal)
        {
            Caption = 'Feels Like';
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the feels like temperature in Celsius.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60105; "GDRG Weather Main"; Text[50])
        {
            Caption = 'Weather Main';
            ToolTip = 'Specifies the main weather condition.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60106; "GDRG Weather Description"; Text[100])
        {
            Caption = 'Weather Description';
            ToolTip = 'Specifies the detailed weather description.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60107; "GDRG Humidity"; Integer)
        {
            Caption = 'Humidity';
            ToolTip = 'Specifies the humidity percentage.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60108; "GDRG Pressure"; Integer)
        {
            Caption = 'Pressure';
            ToolTip = 'Specifies the atmospheric pressure in hPa.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60109; "GDRG Wind Speed"; Decimal)
        {
            Caption = 'Wind Speed';
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the wind speed in meters per second.';
            DataClassification = CustomerContent;
            Editable = false;
        }

        modify("Ship-to Post Code")
        {
            trigger OnAfterValidate()
            begin
                UpdateWeatherData();
            end;
        }

        modify("Ship-to Country/Region Code")
        {
            trigger OnAfterValidate()
            begin
                UpdateWeatherData();
            end;
        }
    }

    procedure UpdateWeatherData()
    var
        ZipCodeManager: Codeunit "GDRG Zip Code Manager";
        WeatherHelper: Codeunit "GDRG Weather Helper";
        Latitude: Decimal;
        Longitude: Decimal;
        HasLocationData: Boolean;
    begin
        if (Rec."Ship-to Post Code" = '') or (Rec."Ship-to Country/Region Code" = '') then begin
            ClearWeatherData();
            exit;
        end;

        if WeatherHelper.FindZipCodeInfo(Rec."Ship-to Post Code", Rec."Ship-to Country/Region Code", Latitude, Longitude) then
            HasLocationData := true
        else
            if ZipCodeManager.GetZipCodeInfo(Rec."Ship-to Post Code", Rec."Ship-to Country/Region Code") then
                if WeatherHelper.FindZipCodeInfo(Rec."Ship-to Post Code", Rec."Ship-to Country/Region Code", Latitude, Longitude) then
                    HasLocationData := true;

        if HasLocationData then begin
            Rec."GDRG Latitude" := Latitude;
            Rec."GDRG Longitude" := Longitude;
            Rec."GDRG Date Time" := CurrentDateTime();

            GetWeatherDataFromCoordinates(Latitude, Longitude);
        end else begin
            ClearWeatherData();
            Rec.Modify(true);
        end;
    end;

    local procedure GetWeatherDataFromCoordinates(Latitude: Decimal; Longitude: Decimal)
    var
        WeatherDataManager: Codeunit "GDRG Weather Data Manager";
        UnixTimestamp: BigInteger;
    begin
        UnixTimestamp := GetCurrentUnixTimestamp();

        if WeatherDataManager.GetWeatherData(Latitude, Longitude, UnixTimestamp) then
            LoadWeatherDataFromTable(Latitude, Longitude, UnixTimestamp)
        else
            ClearWeatherData();
    end;

    local procedure GetCurrentUnixTimestamp(): BigInteger
    var
        BaseDateTime: DateTime;
        CurrentDT: DateTime;
        DiffInMilliseconds: BigInteger;
    begin
        BaseDateTime := CreateDateTime(DMY2Date(1, 1, 1970), 0T);
        CurrentDT := CurrentDateTime();

        DiffInMilliseconds := CurrentDT - BaseDateTime;
        exit(DiffInMilliseconds div 1000);
    end;

    local procedure LoadWeatherDataFromTable(Latitude: Decimal; Longitude: Decimal; UnixTimestamp: BigInteger)
    var
        WeatherData: Record "GDRG Weather Data";
        WeatherHelper: Codeunit "GDRG Weather Helper";
    begin
        if WeatherHelper.FindWeatherData(Latitude, Longitude, UnixTimestamp, WeatherData) then begin
            Rec."GDRG Temperature" := WeatherData.Temperature;
            Rec."GDRG Feels Like" := WeatherData."Feels Like";
            Rec."GDRG Weather Main" := WeatherData."Weather Main";
            Rec."GDRG Weather Description" := WeatherData."Weather Description";
            Rec."GDRG Humidity" := WeatherData.Humidity;
            Rec."GDRG Pressure" := WeatherData.Pressure;
            Rec."GDRG Wind Speed" := WeatherData."Wind Speed";

            Rec.Modify(true);
        end else
            ClearWeatherData();
    end;

    local procedure ClearWeatherData()
    begin
        Rec."GDRG Latitude" := 0;
        Rec."GDRG Longitude" := 0;
        Rec."GDRG Date Time" := 0DT;
        Rec."GDRG Temperature" := 0;
        Rec."GDRG Feels Like" := 0;
        Rec."GDRG Weather Main" := '';
        Rec."GDRG Weather Description" := '';
        Rec."GDRG Humidity" := 0;
        Rec."GDRG Pressure" := 0;
        Rec."GDRG Wind Speed" := 0;

        Rec.Modify(true);
    end;
}
