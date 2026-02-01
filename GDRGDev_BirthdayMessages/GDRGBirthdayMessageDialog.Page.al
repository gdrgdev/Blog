page 80108 "GDRG Birthday Message Dialog"
{
    Caption = 'Birthday Message';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            group(MessageGroup)
            {
                Caption = 'Enter your birthday message';

                field(MessageText; messageText)
                {
                    ApplicationArea = All;
                    Caption = 'Message';
                    ToolTip = 'Specifies the birthday message.';
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    procedure GetMessage(): Text
    begin
        exit(messageText);
    end;

    procedure SetEmployeeName(employeeName: Text)
    begin
        CurrPage.Caption := StrSubstNo(dialogCaptionLbl, employeeName);
    end;

    var
        messageText: Text;
        dialogCaptionLbl: Label 'Birthday Message for %1', Comment = '%1 = Employee Name';
}
