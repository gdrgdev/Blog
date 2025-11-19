page 88000 "GDRG Clipboard Helper"
{
    PageType = StandardDialog;
    UsageCategory = None;
    Caption = 'Information';

    layout
    {
        area(Content)
        {
            usercontrol(WebPageViewer; System.Integration.WebPageViewer)
            {
                ApplicationArea = All;

                trigger ControlAddInReady(CallbackUrl: Text)
                begin
                    SetContent();
                end;

                trigger Callback(data: Text)
                begin
                    if data = 'copied' then
                        CurrPage.Close();
                end;
            }
        }
    }

    var
        contactInfo: Text;
        bankInfo: Text;

    procedure SetCustomerData(newContactInfo: Text; newBankInfo: Text)
    begin
        contactInfo := newContactInfo;
        bankInfo := newBankInfo;
    end;

    procedure SetCaption(newCaption: Text)
    begin
        CurrPage.Caption := newCaption;
    end;

    local procedure SetContent()
    var
        html: Text;
        js: Text;
    begin
        html := '<div style="font-family:Segoe UI,sans-serif;padding:6px 8px;background:white;overflow:hidden;">';
        html += '<div style="display:flex;gap:10px;">';
        html += '<div style="flex:1;">';
        html += '<div style="font-size:15px;font-weight:600;margin-bottom:3px;color:#000000;">Contact Info</div>';
        html += '<textarea id="contactText" readonly style="width:100%;height:190px;font-family:Segoe UI,sans-serif;font-size:13px;padding:6px;border:1px solid #d2d0ce;background:white;resize:none;color:#323130;line-height:1.3;">';
        html += EscapeForHtml(contactInfo);
        html += '</textarea>';
        html += '<button id="copyContactBtn" style="margin-top:3px;padding:5px 16px;font-size:14px;font-family:Segoe UI,sans-serif;font-weight:400;background:#008489;color:white;border:1px solid #008489;border-radius:2px;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:5px;transition:background 0.15s;min-height:32px;">';
        html += '<svg width="12" height="12" viewBox="0 0 16 16" fill="white"><path d="M4 2h8a2 2 0 0 1 2 2v8h-2V4H4V2z"/><path d="M2 6a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6zm2 0v6h6V6H4z"/></svg>';
        html += '<span>Copy</span></button>';
        html += '</div>';
        html += '<div style="flex:1;">';
        html += '<div style="font-size:15px;font-weight:600;margin-bottom:3px;color:#000000;">Bank Info</div>';
        html += '<textarea id="bankText" readonly style="width:100%;height:190px;font-family:Segoe UI,sans-serif;font-size:13px;padding:6px;border:1px solid #d2d0ce;background:white;resize:none;color:#323130;line-height:1.3;">';
        html += EscapeForHtml(bankInfo);
        html += '</textarea>';
        html += '<button id="copyBankBtn" style="margin-top:3px;padding:5px 16px;font-size:14px;font-family:Segoe UI,sans-serif;font-weight:400;background:#008489;color:white;border:1px solid #008489;border-radius:2px;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:5px;transition:background 0.15s;min-height:32px;">';
        html += '<svg width="12" height="12" viewBox="0 0 16 16" fill="white"><path d="M4 2h8a2 2 0 0 1 2 2v8h-2V4H4V2z"/><path d="M2 6a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6zm2 0v6h6V6H4z"/></svg>';
        html += '<span>Copy</span></button>';
        html += '</div>';
        html += '</div>';
        html += '</div>';

        js := 'function copyText(textareaId, btnId) {';
        js += '  var textarea = document.getElementById(textareaId);';
        js += '  var btn = document.getElementById(btnId);';
        js += '  var btnText = btn.querySelector("span");';
        js += '  textarea.select();';
        js += '  document.execCommand("copy");';
        js += '  btn.style.background = "#107c10";';
        js += '  btn.style.borderColor = "#107c10";';
        js += '  btnText.textContent = "Copied!";';
        js += '  setTimeout(function() {';
        js += '    btn.style.background = "#008489";';
        js += '    btn.style.borderColor = "#008489";';
        js += '    btnText.textContent = "Copy";';
        js += '  }, 1500);';
        js += '}';
        js += 'document.getElementById("copyContactBtn").onclick = function() { copyText("contactText", "copyContactBtn"); };';
        js += 'document.getElementById("copyBankBtn").onclick = function() { copyText("bankText", "copyBankBtn"); };';
        js += 'document.getElementById("copyContactBtn").onmouseenter = function() { if(this.style.background !== "rgb(16, 124, 16)") this.style.background = "#00757a"; };';
        js += 'document.getElementById("copyContactBtn").onmouseleave = function() { if(this.style.background !== "rgb(16, 124, 16)") this.style.background = "#008489"; };';
        js += 'document.getElementById("copyBankBtn").onmouseenter = function() { if(this.style.background !== "rgb(16, 124, 16)") this.style.background = "#00757a"; };';
        js += 'document.getElementById("copyBankBtn").onmouseleave = function() { if(this.style.background !== "rgb(16, 124, 16)") this.style.background = "#008489"; };';

        CurrPage.WebPageViewer.SetContent(html, js);
    end;

    local procedure EscapeForHtml(inputText: Text): Text
    var
        outputText: Text;
    begin
        outputText := inputText;
        outputText := outputText.Replace('&', '&amp;');
        outputText := outputText.Replace('<', '&lt;');
        outputText := outputText.Replace('>', '&gt;');
        outputText := outputText.Replace('"', '&quot;');
        outputText := outputText.Replace('''', '&#39;');
        exit(outputText);
    end;
}
