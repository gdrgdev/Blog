table 80002 GDRGeoWhereAmI
{
    Caption = 'GDRGeoWhereAmI';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "code"; Integer)
        {
            Caption = 'code';
            AutoIncrement = true;
        }
        field(1; buildingNumber; Text[50])
        {
            Caption = 'buildingNumber';
        }
        field(2; streetNameAndNumber; Text[100])
        {
            Caption = 'streetNameAndNumber';
        }
        field(3; countryCode; Text[80])
        {
            Caption = 'countryCode';
        }
        field(4; countrySubdivision; Text[80])
        {
            Caption = 'countrySubdivision';
        }
        field(5; countrySecondarySubdivision; Text[80])
        {
            Caption = 'countrySecondarySubdivision';
        }
        field(6; postalCode; Text[80])
        {
            Caption = 'postalCode';
        }
        field(7; neighbourhood; Text[80])
        {
            Caption = 'neighbourhood';
        }
    }
    keys
    {
        key(PK; "code")
        {
            Clustered = true;
        }
    }
}
