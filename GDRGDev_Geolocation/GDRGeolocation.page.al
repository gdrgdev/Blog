page 80001 GDRGeolocation
{
    ApplicationArea = All;
    Caption = 'GDRGeolocation';
    Editable = false;
    PageType = List;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {

        }
    }
    actions
    {
        area(processing)
        {
            action(GDRGeoWhereAmI)
            {
                ApplicationArea = All;
                Caption = 'Where Am I?';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Map;
                RunObject = page GDRGeoWhereAmI;
                trigger OnAction()
                var
                    cuGDRGeolocation: Codeunit GDRGeolocation;
                begin
                    cuGDRGeolocation.GDR_GetWhereAmI();
                end;
            }
            action(GDRGeoWhereAmIImage)
            {
                ApplicationArea = All;
                Caption = 'Where Am I? (image)';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Picture;
                RunObject = page GDRGeoWhereAmIImage;
                trigger OnAction()
                var
                    cuGDRGeolocation: Codeunit GDRGeolocation;
                begin
                    cuGDRGeolocation.GDR_GetWhereAmIImage();
                end;
            }
            action(GDRGeoPOI)
            {
                ApplicationArea = All;
                Caption = 'Are there points of interest nearby where I am?';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = NewWarehouse;
                RunObject = page GDRGeoPOI;
                trigger OnAction()
                var
                    cuGDRGeolocation: Codeunit GDRGeolocation;
                begin
                    cuGDRGeolocation.GDR_GetPOI();
                end;
            }
            action(GDRGeoWeather)
            {
                ApplicationArea = All;
                Caption = 'How is the weather where I am?';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Cloud;
                RunObject = page GDRGeoWeather;
                trigger OnAction()
                var
                    cuGDRGeolocation: Codeunit GDRGeolocation;
                begin
                    cuGDRGeolocation.GDR_GetWeather();
                end;
            }

        }
    }

}
