page 60004 "GDRG Weather Data List"
{
    Caption = 'Weather Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Weather Data";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field(Latitude; Rec.Latitude)
                {
                }
                field(Longitude; Rec.Longitude)
                {
                }
                field("Date Time"; Rec."Date Time")
                {
                }
                field("Unix Timestamp"; Rec."Unix Timestamp")
                {
                }
                field(Temperature; Rec.Temperature)
                {
                }
                field("Feels Like"; Rec."Feels Like")
                {
                }
                field("Dew Point"; Rec."Dew Point")
                {
                }
                field("Weather ID"; Rec."Weather ID")
                {
                }
                field("Weather Main"; Rec."Weather Main")
                {
                }
                field("Weather Description"; Rec."Weather Description")
                {
                }
                field("Weather Icon"; Rec."Weather Icon")
                {
                }
                field(Humidity; Rec.Humidity)
                {
                }
                field(Pressure; Rec.Pressure)
                {
                }
                field("Wind Speed"; Rec."Wind Speed")
                {
                }
                field("Wind Degree"; Rec."Wind Degree")
                {
                }
                field("Wind Gust"; Rec."Wind Gust")
                {
                }
                field("UV Index"; Rec."UV Index")
                {
                }
                field(Clouds; Rec.Clouds)
                {
                }
                field(Visibility; Rec.Visibility)
                {
                }
                field(Timezone; Rec.Timezone)
                {
                }
                field("Timezone Offset"; Rec."Timezone Offset")
                {
                }
                field("Sunrise Time"; Rec."Sunrise Time")
                {
                }
                field("Sunset Time"; Rec."Sunset Time")
                {
                }
                field("Created Date"; Rec."Created Date")
                {
                }
                field("Last Updated"; Rec."Last Updated")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get Weather Data")
            {
                Caption = 'Get Weather Data';
                Image = GetLines;
                ToolTip = 'Retrieve weather data from API.';

                trigger OnAction()
                begin
                    GetWeatherDataFromAPI();
                end;
            }
            action("Refresh")
            {
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Refresh the weather data list.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }


    local procedure GetWeatherDataFromAPI()
    var
        WeatherDataManager: Codeunit "GDRG Weather Data Manager";
        WeatherDataInputPage: Page "GDRG Weather Data Input";
        LatValue: Decimal;
        LonValue: Decimal;
        UnixTimestamp: BigInteger;
        ProcessedLbl: Label 'Weather data retrieved successfully.';
        ErrorLbl: Label 'Failed to retrieve weather data. Please check the API configuration and try again.';
    begin
        WeatherDataInputPage.SetDefaults(31.7798, -83.9706, 1752603633);

        if WeatherDataInputPage.RunModal() = Action::OK then begin
            LatValue := WeatherDataInputPage.GetLatitude();
            LonValue := WeatherDataInputPage.GetLongitude();
            UnixTimestamp := WeatherDataInputPage.GetUnixTimestamp();

            if (LatValue = 0) or (LonValue = 0) or (UnixTimestamp = 0) then
                exit;

            if WeatherDataManager.GetWeatherData(LatValue, LonValue, UnixTimestamp) then begin
                Message(ProcessedLbl);
                CurrPage.Update(false);
            end else
                Message(ErrorLbl);
        end;
    end;
}
