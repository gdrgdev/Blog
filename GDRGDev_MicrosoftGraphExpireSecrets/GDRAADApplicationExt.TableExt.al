tableextension 80000 GDRAADApplicationExt extends "AAD Application"
{
    fields
    {
        field(80000; CheckSecrets; Boolean)
        {
            Caption = 'Check Secrets Expiration';
            DataClassification = ToBeClassified;
        }
    }
}
