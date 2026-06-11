table 88895 "GDRG WC Setup"
{
    Caption = 'WC Setup';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG WC Setup";
    DrillDownPageId = "GDRG WC Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            NotBlank = true;
            ToolTip = 'Specifies the primary key for the setup record.';
            AllowInCustomizations = AsReadOnly;
        }
        field(2; "Source URL"; Text[250])
        {
            Caption = 'Source URL';
            ToolTip = 'Specifies the JSON source URL used to refresh matches.';
            AllowInCustomizations = AsReadOnly;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}