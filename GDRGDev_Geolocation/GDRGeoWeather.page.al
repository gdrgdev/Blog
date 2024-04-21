page 80002 GDRGeoWeather
{
    ApplicationArea = All;
    Caption = 'GDRGeoWeather';
    Editable = false;
    PageType = List;
    SourceTable = GDRGeoWeather;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(dateTime; rec.dateTime)
                {
                    ToolTip = 'Specifies the value of the dateTime field.';
                }
                field("code"; Rec."code")
                {
                    ToolTip = 'Specifies the value of the code field.';
                }
                field(phrase; Rec.phrase)
                {
                    ToolTip = 'Specifies the value of the phrase field.';
                }
                field(temperaturevalue; Rec.temperaturevalue)
                {
                    ToolTip = 'Specifies the value of the temperaturevalue field.';
                }
                field(temperatureunit; Rec.temperatureunit)
                {
                    ToolTip = 'Specifies the value of the temperatureunit field.';
                }

            }
        }
    }
}
