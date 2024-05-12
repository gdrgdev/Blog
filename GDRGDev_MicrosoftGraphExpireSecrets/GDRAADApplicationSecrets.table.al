table 80001 GDRAADApplicationSecrets
{
    Caption = 'GDR AAD Application Secrets';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Client Id"; Guid)
        {
            Caption = 'Client Id';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; displayName; Text[100])
        {
            Caption = 'displayName';
        }
        field(4; startDateTime; DateTime)
        {
            Caption = 'startDateTime';
        }
        field(5; endDateTime; DateTime)
        {
            Caption = 'endDateTime';
        }
        field(6; startDate; Date)
        {
            Caption = 'startDate';
        }
        field(7; endDate; Date)
        {
            Caption = 'endDate';
        }
        field(8; monthtoexpire; Boolean)
        {
            Caption = '1 month to expire';
        }
        field(9; monthtoexpiredate; date)
        {
            Caption = '1 month to expire (date)';
        }
    }
    keys
    {
        key(PK; "Client Id", "Line No.")
        {
            Clustered = true;
        }
    }
}
