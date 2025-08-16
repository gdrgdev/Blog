page 60003 "GDRG Weather Data Input"
{
    PageType = StandardDialog;
    Caption = 'Enter Weather Data Parameters';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Weather Data Parameters';

                field(Latitude; Latitude)
                {
                    Caption = 'Latitude';
                    DecimalPlaces = 0 : 4;
                    ToolTip = 'Specifies the latitude coordinate (e.g., 31.7798).';
                    NotBlank = true;
                }
                field(Longitude; Longitude)
                {
                    Caption = 'Longitude';
                    DecimalPlaces = 0 : 4;
                    ToolTip = 'Specifies the longitude coordinate (e.g., -83.9706).';
                    NotBlank = true;
                }
                field(UnixTimestamp; UnixTimestamp)
                {
                    Caption = 'Unix Timestamp';
                    ToolTip = 'Specifies the unix timestamp for historical weather data (e.g., 1752603633).';
                    NotBlank = true;
                }
            }
        }
    }

    var
        Latitude: Decimal;
        Longitude: Decimal;
        UnixTimestamp: BigInteger;


    procedure GetLatitude(): Decimal
    begin
        exit(Latitude);
    end;

    procedure GetLongitude(): Decimal
    begin
        exit(Longitude);
    end;


    procedure GetUnixTimestamp(): BigInteger
    begin
        exit(UnixTimestamp);
    end;

    procedure SetDefaults(DefaultLat: Decimal; DefaultLon: Decimal; DefaultTimestamp: BigInteger)
    begin
        Latitude := DefaultLat;
        Longitude := DefaultLon;
        UnixTimestamp := DefaultTimestamp;
    end;
}
