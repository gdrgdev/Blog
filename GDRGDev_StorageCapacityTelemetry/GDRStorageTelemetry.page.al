page 80001 GDRStorageTelemetry
{
    ApplicationArea = All;
    Caption = 'GDRStorageTelemetry';
    Editable = false;
    PageType = ListPart;
    SourceTable = GDRStorageTelemetry;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(environmentType; Rec.environmentType)
                {
                    ToolTip = 'Specifies the value of the environmentType field.';
                }
                field(environmentName; Rec.environmentName)
                {
                    ToolTip = 'Specifies the value of the environmentName field.';
                }
                field(databaseStorageInKilobytes; Rec.databaseStorageInKilobytes)
                {
                    ToolTip = 'Specifies the value of the databaseStorageInKilobytes field.';
                }
            }
        }
    }
}
