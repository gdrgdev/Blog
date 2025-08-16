pageextension 60001 "GDRG Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast(content)
        {
            group("PTE Weather")
            {
                Caption = 'Weather';

                field("PTE Latitude"; Rec."GDRG Latitude")
                {
                    ApplicationArea = All;
                }
                field("PTE Longitude"; Rec."GDRG Longitude")
                {
                    ApplicationArea = All;
                }
                field("PTE Date Time"; Rec."GDRG Date Time")
                {
                    ApplicationArea = All;
                }
                field("PTE Temperature"; Rec."GDRG Temperature")
                {
                    ApplicationArea = All;
                }
                field("PTE Feels Like"; Rec."GDRG Feels Like")
                {
                    ApplicationArea = All;
                }
                field("PTE Weather Main"; Rec."GDRG Weather Main")
                {
                    ApplicationArea = All;
                }
                field("PTE Weather Description"; Rec."GDRG Weather Description")
                {
                    ApplicationArea = All;
                }
                field("PTE Humidity"; Rec."GDRG Humidity")
                {
                    ApplicationArea = All;
                }
                field("PTE Pressure"; Rec."GDRG Pressure")
                {
                    ApplicationArea = All;
                }
                field("PTE Wind Speed"; Rec."GDRG Wind Speed")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action("PTE Update Weather Data")
            {
                Caption = 'Update Weather Data';
                Image = Refresh;
                ApplicationArea = All;
                ToolTip = 'Update weather data based on Post Code and Country/Region Code.';

                trigger OnAction()
                var
                    UpdatedLbl: Label 'Weather data update process completed. Check the weather fields for results.';
                    NoPostCodeLbl: Label 'Please enter Post Code and Country/Region Code first.';
                begin
                    if (Rec."Post Code" <> '') and (Rec."Country/Region Code" <> '') then begin
                        Rec.UpdateWeatherData();
                        Message(UpdatedLbl);
                        CurrPage.Update(false);
                    end else
                        Message(NoPostCodeLbl);
                end;
            }
        }
    }
}
