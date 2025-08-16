codeunit 60005 "GDRG Weather Helper"
{
    Permissions = tabledata "GDRG Zip Code Info" = R,
                  tabledata "GDRG Weather Data" = R;

    procedure FindZipCodeInfo(PostCode: Code[20]; CountryCode: Code[10]; var Latitude: Decimal; var Longitude: Decimal): Boolean
    var
        ZipCodeInfo: Record "GDRG Zip Code Info";
    begin
        ZipCodeInfo.SetRange("Zip Code", PostCode);
        ZipCodeInfo.SetRange(Country, CountryCode);

        if ZipCodeInfo.FindFirst() then begin
            Latitude := ZipCodeInfo.Latitude;
            Longitude := ZipCodeInfo.Longitude;
            exit(true);
        end;

        exit(false);
    end;

    procedure FindWeatherData(Latitude: Decimal; Longitude: Decimal; UnixTimestamp: BigInteger; var WeatherData: Record "GDRG Weather Data"): Boolean
    begin
        WeatherData.SetRange(Latitude, Latitude);
        WeatherData.SetRange(Longitude, Longitude);
        WeatherData.SetRange("Unix Timestamp", UnixTimestamp);

        exit(WeatherData.FindFirst());
    end;
}
