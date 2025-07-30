page 50111 "GDRG PowerBI Demo"
{
    PageType = UserControlHost;
    Caption = 'GDRG PowerBI Demo - Full Screen Analytics';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    AboutTitle = 'About PowerBI Integration';
    AboutText = 'Demonstrates PowerBI embedded in UserControlHost for immersive full-screen analytics experience without sidebar or ribbon distractions.';

    layout
    {
        area(Content)
        {
            usercontrol(PowerBIViewer; WebPageViewer)
            {
                trigger ControlAddInReady(CallbackUrl: Text)
                begin
                    CurrPage.PowerBIViewer.Navigate('https://app.powerbi.com/view?r=eyJrIjoiY2Y3YTA0ZGMtOGNhMS00MGFjLThmMTQtMjM5MDk4ZDg1N2QxIiwidCI6ImFhMjFiNjQwLWJhYzItNDU2ZC04NTA1LWYyY2MwN2Y1MTc4NCJ9');
                end;

                trigger DocumentReady()
                begin
                    Message('📊 PowerBI dashboard loaded in full screen mode!');
                end;
            }
        }
    }
}
