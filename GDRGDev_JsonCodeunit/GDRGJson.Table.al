table 96000 GDRGJsonTable
{
    Caption = 'GDRGJsonTable';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; string; Text[100])
        {
            Caption = 'string';
        }
        field(2; "integer"; Integer)
        {
            Caption = 'integer';
        }
        field(3; "decimal"; Decimal)
        {
            Caption = 'decimal';
        }
        field(4; "boolean"; Boolean)
        {
            Caption = 'boolean';
        }
    }
    keys
    {
        key(PK; string)
        {
            Clustered = true;
        }
    }
}
