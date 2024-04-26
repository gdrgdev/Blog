page 80000 GDRApiMgt
{
    ApplicationArea = All;
    Caption = 'GDR Api Setup';
    PageType = Card;
    SourceTable = GDRApiMgt;
    DeleteAllowed = false;
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(apitenant; Rec.apitenant)
                {
                    ToolTip = 'Specifies the value of the Api Tenant Id field.';
                }
                field(apiclienteid; Rec.apiclienteid)
                {
                    ToolTip = 'Specifies the value of the Api Tenant Id field.';
                }
                field(apisecreto; Rec.apisecreto)
                {
                    ToolTip = 'Specifies the value of the Api Tenant Id field.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}