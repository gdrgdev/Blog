table 80001 GDRStorageTelemetry
{
    Caption = 'GDRStorageTelemetry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "code"; Integer)
        {
            Caption = 'code';
            AutoIncrement = true;
        }
        field(2; environmentName; Text[100])
        {
            Caption = 'environmentName';
        }
        field(3; environmentType; Text[100])
        {
            Caption = 'environmentType';
        }
        field(4; databaseStorageInKilobytes; Integer)
        {
            Caption = 'databaseStorageInKilobytes';
        }
        field(5; datetime; DateTime)
        {
            Caption = 'datetime';
        }
        field(6; link; text[10])
        {
            Caption = 'link';
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
