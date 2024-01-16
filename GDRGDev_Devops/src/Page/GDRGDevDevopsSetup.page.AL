
page 50100 "GDRGDevAzDevopsSetup"
{
    Caption = 'Azure Devops Personal Access Tokens Setup';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = GDRGDevAzDevopsSetup;


    layout
    {
        area(Content)
        {
            repeater(RepeatAzureDevopsOrganizationSetup)
            {

                field(AzureDevopsOrganization; rec.AzureDevopsOrganization)
                {
                    ApplicationArea = all;
                }
                field(AccessTokenAzureDevops; rec.AccessTokenAzureDevops)
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
            }
        }

    }


}

