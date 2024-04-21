page 80004 GDRGeoWhereAmIImage
{
    ApplicationArea = All;
    Caption = 'GDRGeoWhereAmIImage';
    PageType = List;
    SourceTable = GDRGeoWhereAmIImage;
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

            }
        }

    }
}
