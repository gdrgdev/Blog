page 80005 GDRGeoPOI
{
    ApplicationArea = All;
    Caption = 'GDRGeoPOI';
    PageType = List;
    SourceTable = GDRGeoPOI;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("code"; Rec."code")
                {
                    ToolTip = 'Specifies the value of the code field.';
                }
                field(poi_name; Rec.poi_name)
                {
                    ToolTip = 'Specifies the value of the poi_name field.';
                }
                field(poi_brands_name; Rec.poi_brands_name)
                {
                    ToolTip = 'Specifies the value of the poi_brands_name field.';
                }
                field(poi_categories; Rec.poi_categories)
                {
                    ToolTip = 'Specifies the value of the poi_categories field.';
                }
                field(address_freeformAddress; Rec.address_freeformAddress)
                {
                    ToolTip = 'Specifies the value of the address_freeformAddress field.';
                }
            }
        }
    }
}
