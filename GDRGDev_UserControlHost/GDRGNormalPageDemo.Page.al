page 50110 "GDRG Normal Page Demo"
{
    PageType = Card;
    Caption = 'GDRG Normal Page Demo - Traditional BC Page with WebPageViewer';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            group(Header)
            {
                Caption = 'Traditional Business Central Page';
                field(InfoText; 'This is a NORMAL BC page with sidebar, ribbon, and navigation')
                {
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(WebContent)
            {
                Caption = 'WebPageViewer Control (Same as UserControlHost)';
                usercontrol(WebViewer; WebPageViewer)
                {
                    trigger ControlAddInReady(CallbackUrl: Text)
                    begin
                        CurrPage.WebViewer.Navigate('https://gerardorenteria.blog/');
                    end;
                }
            }
        }
    }
}
