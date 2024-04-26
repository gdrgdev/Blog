table 80003 GDRStorageenvironmentsCount
{
    Caption = 'GDRStorageenvironmentsCount';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "code"; Integer)
        {
            Caption = 'code';
            AutoIncrement = true;
        }
        field(2; production; Integer)
        {
            Caption = 'production';
        }
        field(3; sandbox; integer)
        {
            Caption = 'sandbox';
        }
        field(4; datetime; DateTime)
        {
            Caption = 'datetime';
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
