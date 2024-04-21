page 80003 GDRGeoWhereAmI
{
    ApplicationArea = All;
    Caption = 'GDRGeoWhereAmI';
    PageType = List;
    SourceTable = GDRGeoWhereAmI;
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
                field(buildingNumber; Rec.buildingNumber)
                {
                    ToolTip = 'Specifies the value of the buildingNumber field.';
                }
                field(streetNameAndNumber; Rec.streetNameAndNumber)
                {
                    ToolTip = 'Specifies the value of the streetNameAndNumber field.';
                }

                field(countrySecondarySubdivision; Rec.countrySecondarySubdivision)
                {
                    ToolTip = 'Specifies the value of the countrySecondarySubdivision field.';
                }
                field(countrySubdivision; Rec.countrySubdivision)
                {
                    ToolTip = 'Specifies the value of the countrySubdivision field.';
                }
                field(neighbourhood; Rec.neighbourhood)
                {
                    ToolTip = 'Specifies the value of the neighbourhood field.';
                }
                field(postalCode; Rec.postalCode)
                {
                    ToolTip = 'Specifies the value of the postalCode field.';
                }
                field(countryCode; Rec.countryCode)
                {
                    ToolTip = 'Specifies the value of the countryCode field.';
                }
            }
        }
    }
}
