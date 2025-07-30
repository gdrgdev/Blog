page 50112 "GDRG PowerBI Normal Page"
{
    PageType = Card;
    Caption = 'GDRG PowerBI Normal Page - Traditional BC with Analytics';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            group(Header)
            {
                Caption = 'Traditional Business Central Page Layout';
                field(InfoText; 'This is a NORMAL BC page with sidebar, ribbon, and reduced space for PowerBI')
                {
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Analytics)
            {
                Caption = 'PowerBI Dashboard (Constrained by BC Layout)';
                usercontrol(PowerBIViewer; WebPageViewer)
                {
                    trigger ControlAddInReady(CallbackUrl: Text)
                    begin
                        CurrPage.PowerBIViewer.Navigate('https://app.powerbi.com/view?r=eyJrIjoiY2Y3YTA0ZGMtOGNhMS00MGFjLThmMTQtMjM5MDk4ZDg1N2QxIiwidCI6ImFhMjFiNjQwLWJhYzItNDU2ZC04NTA1LWYyY2MwN2Y1MTc4NCJ9');
                    end;

                    trigger DocumentReady()
                    begin
                        Message('📊 PowerBI loaded in constrained normal page layout');
                    end;
                }
            }
        }
    }
}
