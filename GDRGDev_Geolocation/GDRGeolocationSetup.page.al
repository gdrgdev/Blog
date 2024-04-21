page 80000 GDRGeolocationSetup
{
    ApplicationArea = All;
    Caption = 'GDR Geolocation Setup';
    PageType = Card;
    SourceTable = GDRGeolocationSetup;
    DeleteAllowed = false;
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Api Key Azure Maps"; Rec."Api Key Azure Maps")
                {
                    ToolTip = 'Specifies the value of the Api Key Azure Maps field.';
                }
                field(POI; Rec.POI)
                {
                    ToolTip = 'Specifies the value of the Point of interest field.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
