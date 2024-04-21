table 80004 GDRGeoPOI
{
    Caption = 'GDRGeoPOI';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "code"; Integer)
        {
            Caption = 'code';
            AutoIncrement = true;
        }
        field(2; poi_name; Text[100])
        {
            Caption = 'poi_name';
        }
        field(3; poi_brands_name; Text[100])
        {
            Caption = 'poi_brands_name';
        }
        field(4; poi_categories; Text[100])
        {
            Caption = 'poi_categories';
        }
        field(5; address_freeformAddress; Text[100])
        {
            Caption = 'address_freeformAddress';
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
