table 80003 GDRGeoWhereAmIImage
{
    Caption = 'GDRGeoWhereAmIImage';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "code"; Integer)
        {
            Caption = 'code';
        }
        field(2; "image"; MediaSet)
        {
            Caption = 'image';
        }
        field(3; "file"; text[2048])
        {
            Caption = 'image';
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
