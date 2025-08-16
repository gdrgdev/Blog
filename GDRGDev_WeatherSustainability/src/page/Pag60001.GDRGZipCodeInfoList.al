page 60001 "GDRG Zip Code Info List"
{
    Caption = 'Zip Code Information';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Zip Code Info";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Zip Code"; Rec."Zip Code")
                {
                }
                field(Country; Rec.Country)
                {
                }
                field(Name; Rec.Name)
                {
                }
                field(Latitude; Rec.Latitude)
                {
                }
                field(Longitude; Rec.Longitude)
                {
                }
                field("Created Date"; Rec."Created Date")
                {
                }
                field("Last Updated"; Rec."Last Updated")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get Zip Code Info")
            {
                Caption = 'Get Zip Code Info';
                Image = GetLines;
                ToolTip = 'Retrieve zip code information from API.';

                trigger OnAction()
                begin
                    GetZipCodeFromAPI();
                end;
            }
            action("Refresh")
            {
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Refresh the zip code information list.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }


    local procedure GetZipCodeFromAPI()
    var
        ZipCodeManager: Codeunit "GDRG Zip Code Manager";
        ZipCodeInputPage: Page "GDRG Zip Code Input";
        ZipCode: Code[20];
        CountryCode: Code[10];
        ProcessedLbl: Label 'Zip code information retrieved successfully.';
        ErrorLbl: Label 'Failed to retrieve zip code information. Please check the API configuration and try again.';
    begin
        ZipCodeInputPage.SetDefaults('', 'US');

        if ZipCodeInputPage.RunModal() = Action::OK then begin
            ZipCode := ZipCodeInputPage.GetZipCode();
            CountryCode := ZipCodeInputPage.GetCountryCode();

            if ZipCode = '' then
                exit;

            if ZipCodeManager.GetZipCodeInfo(ZipCode, CountryCode) then begin
                Message(ProcessedLbl);
                CurrPage.Update(false);
            end else
                Message(ErrorLbl);
        end;
    end;
}
