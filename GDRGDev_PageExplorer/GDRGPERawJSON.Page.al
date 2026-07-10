#pragma warning disable LC0034
page 97821 "GDRGPE Raw JSON"
{
    ApplicationArea = All;
    Caption = 'Page Summary JSON';
    PageType = UserControlHost;

    layout
    {
        area(Content)
        {
            usercontrol(Viewer; WebPageViewer)
            {

                trigger ControlAddInReady(callbackUrl: Text)
                var
                    JsonRenderer: Codeunit "GDRGPE JSON Renderer";
                begin
                    CurrPage.Viewer.SetContent(JsonRenderer.RenderToHtml(RawJsonVar));
                end;
            }
        }
    }

    var
        RawJsonVar: Text;

    internal procedure SetJson(JsonText: Text)
    begin
        RawJsonVar := JsonText;
    end;
}
