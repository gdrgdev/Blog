table 80002 GDRStorageTotalTelemetry
{
    Caption = 'GDRStorageTotalTelemetry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "code"; Integer)
        {
            Caption = 'code';
            AutoIncrement = true;
        }
        field(2; default; Integer)
        {
            Caption = 'default';
        }
        field(3; userLicenses; Integer)
        {
            Caption = 'userLicenses';
        }
        field(4; additionalCapacity; Integer)
        {
            Caption = 'additionalCapacity';
        }
        field(5; total; integer)
        {
            Caption = 'total';
        }
        field(6; datetime; DateTime)
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
