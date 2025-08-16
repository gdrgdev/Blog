page 60002 "GDRG Zip Code Input"
{
    PageType = StandardDialog;
    Caption = 'Enter Zip Code Information';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Zip Code Information';

                field(ZipCode; ZipCode)
                {
                    Caption = 'Zip Code';
                    ToolTip = 'Specifies the zip code to search for.';
                    NotBlank = true;
                }
                field(CountryCode; CountryCode)
                {
                    Caption = 'Country Code';
                    ToolTip = 'Specifies the country code (e.g., US, CA, GB).';
                }
            }
        }
    }

    var
        ZipCode: Code[20];
        CountryCode: Code[10];

    procedure GetZipCode(): Code[20]
    begin
        exit(ZipCode);
    end;

    procedure GetCountryCode(): Code[10]
    begin
        exit(CountryCode);
    end;

    procedure SetDefaults(DefaultZipCode: Code[20]; DefaultCountryCode: Code[10])
    begin
        ZipCode := DefaultZipCode;
        CountryCode := DefaultCountryCode;
    end;
}
