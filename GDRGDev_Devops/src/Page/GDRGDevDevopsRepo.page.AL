page 50103 GDRGDevAzDevopsRepositories
{
    Caption = 'Azure Devops Repositories';
    PageType = List;
    SourceTable = GDRGDevAzDevopsRepository;
    PromotedActionCategories = 'New,Process,Report,Commits,Ranges,Dependencies,Tag';
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(RepeaterGDRGDevAzDevopsRepositories)
            {
                field(id; rec.id)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(name; rec.name)
                {
                    ApplicationArea = All;
                }


                field(defaultBranch; rec.defaultBranch)
                {
                    ApplicationArea = All;
                }
                field(size; rec.size)
                {
                    ApplicationArea = All;
                }
                field(isDisabled; rec.isDisabled)
                {
                    ApplicationArea = All;
                }


                field(webUrlLink; rec.webUrlLink)
                {
                    ApplicationArea = All;
                    ToolTip = 'Go to Azure Devops Repository';
                    Style = Favorable;
                    ExtendedDatatype = URL;
                }
            }
        }
    }

    procedure GDRGDev_SetGDRGDevAzDevopsSetup(var parGDRGDevAzDevopsSetup: Record GDRGDevAzDevopsSetup)
    begin
        GDRGDevAzDevopsSetup := parGDRGDevAzDevopsSetup;
    end;

    var
        GDRGDevAzDevopsSetup: Record GDRGDevAzDevopsSetup;
}