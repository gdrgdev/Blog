table 60000 "GDRG API Connection Setup"
{
    Caption = 'API Connection Setup';
    DataClassification = ToBeClassified;
    Permissions = tabledata "GDRG API Connection Setup" = RI;
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            AllowInCustomizations = Never;
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Base URL"; Text[250])
        {
            Caption = 'Base URL';
            DataClassification = CustomerContent;
            ToolTip = 'Enter the base URL for the API (e.g., https://api.example.com).';

            trigger OnValidate()
            begin
                if "Base URL" <> '' then
                    if not "Base URL".StartsWith('https://') then
                        Error(URLMustStartWithHttpsErr);
            end;
        }
        field(20; "API Key Name"; Text[50])
        {
            Caption = 'API Key Name';
            DataClassification = CustomerContent;
            ToolTip = 'Enter the name of the API key parameter (leave empty for default values).';
        }
        field(30; "API Key Value"; Text[250])
        {
            Caption = 'API Key Value';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
            ToolTip = 'Enter the API key value.';
        }
        field(40; "Authentication Type"; Enum "GDRG API Auth Type")
        {
            Caption = 'Authentication Type';
            DataClassification = CustomerContent;
            ToolTip = 'Select how the API key should be sent.';
        }
        field(50; "Connection Status"; Enum "GDRG API Connection Status")
        {
            Caption = 'Connection Status';
            DataClassification = CustomerContent;
            ToolTip = 'Shows the current connection status.';
        }
        field(60; "Last Test Date"; DateTime)
        {
            Caption = 'Last Test Date';
            DataClassification = CustomerContent;
            ToolTip = 'Shows when the connection was last tested.';
        }
        field(70; "Last Error Message"; Text[500])
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
            ToolTip = 'Shows the last error message if the connection failed.';
        }
        field(80; "Test Endpoint"; Text[250])
        {
            Caption = 'Test Endpoint';
            DataClassification = CustomerContent;
            ToolTip = 'Enter the endpoint to use for testing the connection (e.g., /projects.json, /api/health).';

            trigger OnValidate()
            begin
                if "Test Endpoint" <> '' then
                    if not ("Test Endpoint".StartsWith('/') or "Test Endpoint".StartsWith('http')) then
                        Error(InvalidEndpointFormatErr);
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Base URL", "Authentication Type", "Connection Status")
        {
        }
        fieldgroup(Brick; "Base URL", "Connection Status", "Last Test Date")
        {
        }
    }

    procedure GetSetup(): Record "GDRG API Connection Setup"
    var
        APISetup: Record "GDRG API Connection Setup";
    begin
        if not APISetup.Get() then begin
            APISetup.Init();
            APISetup."Primary Key" := '';
            APISetup."Authentication Type" := APISetup."Authentication Type"::"API Key Header";
            APISetup."Test Endpoint" := '/projects.json';
            APISetup.Insert(false);
        end;
        exit(APISetup);
    end;

    var
        URLMustStartWithHttpsErr: Label 'The URL must start with https://';
        InvalidEndpointFormatErr: Label 'The endpoint must start with "/" or "http"';
}
