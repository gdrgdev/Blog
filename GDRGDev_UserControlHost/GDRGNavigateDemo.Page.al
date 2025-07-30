page 50109 "GDRG Navigate Demo"
{
    PageType = UserControlHost;
    Caption = 'GDRG Navigate Demo - Full Screen Web Navigation';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            usercontrol(Web; WebPageViewer)
            {
                trigger ControlAddInReady(CallbackUrl: Text)
                begin
                    CurrPage.Web.Navigate('https://gerardorenteria.blog/');
                end;
            }
        }
    }
}
