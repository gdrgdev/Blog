page 50108 "GDRG Visual Demo"
{
    PageType = UserControlHost;
    Caption = 'GDRG Visual Demo - Custom HTML/CSS/JavaScript';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            usercontrol(WebContent; WebPageViewer)
            {
                trigger ControlAddInReady(CallbackUrl: Text)
                begin
                    ShowDemoWithCallback();
                end;

                trigger DocumentReady()
                begin
                    Message('✅ Web content loaded successfully!');
                end;

                trigger Callback(Data: Text)
                begin
                    Message('🎉 SUCCESS! JavaScript→AL Callback worked!' + '\n' + 'Data received: ' + Data);
                end;
            }
        }
    }

    local procedure ShowDemoWithCallback()
    var
        Html: Text;
    begin
        Html := '<html><head></head>' +
               '<body style="margin:0;padding:40px;font-family:Segoe UI;background:#0078d4;color:white;text-align:center">' +
               '<h1 style="font-size:4em">🚀 UserControlHost</h1>' +
               '<p style="font-size:2em">FULL SCREEN - No sidebar, no ribbon!</p>' +
               '<div style="margin:30px 0">' +
               '<button onclick="alert(''✅ JavaScript works perfectly!'')" style="padding:20px;font-size:1.2em;background:#00ff88;border:none;border-radius:10px;cursor:pointer;margin:10px">Interactive JavaScript</button>' +
               '<button onclick="window.open(''https://gerardorenteria.blog'', ''_blank'')" style="padding:20px;font-size:1.2em;background:#ff6b6b;border:none;border-radius:10px;cursor:pointer;margin:10px">Open External Site</button>' +
               '<button onclick="document.body.style.background=''linear-gradient(45deg, #ff6b6b, #4ecdc4)''; alert(''🎨 Design changed!'')" style="padding:20px;font-size:1.2em;background:#4ecdc4;border:none;border-radius:10px;cursor:pointer;margin:10px">Change Design</button>' +
               '</div>' +
               '<p style="font-size:1.2em">✨ Custom HTML + CSS + JavaScript in Business Central!</p>' +
               '<p style="font-size:1em">🎯 Perfect for dashboards, reports, and modern UIs</p>' +
               '</body></html>';

        CurrPage.WebContent.SetContent(Html);
    end;
}
