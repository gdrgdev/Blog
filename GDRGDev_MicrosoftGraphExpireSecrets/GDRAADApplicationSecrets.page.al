page 80001 GDRAADApplicationSecrets
{
    ApplicationArea = All;
    Caption = 'GDR AAD Application Secrets';
    PageType = List;
    SourceTable = GDRAADApplicationSecrets;
    Editable = false;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("Client Id"; Rec."Client Id")
                {
                    ToolTip = 'Specifies the value of the Client Id field.';
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    Visible = false;
                }
                field(displayName; Rec.displayName)
                {
                    StyleExpr = StyleText;
                    ToolTip = 'Specifies the value of the displayName field.';
                }
                field(startDateTime; Rec.startDateTime)
                {
                    ToolTip = 'Specifies the value of the startDateTime field.';
                }
                field(startDate; Rec.startDate)
                {
                    ToolTip = 'Specifies the value of the startDate field.';
                }
                field(endDateTime; Rec.endDateTime)
                {
                    ToolTip = 'Specifies the value of the endDateTime field.';
                }
                field(endDate; Rec.endDate)
                {
                    StyleExpr = StyleText;
                    ToolTip = 'Specifies the value of the endDate field.';
                }
                field(monthtoexpire; Rec.monthtoexpire)
                {
                    ToolTip = 'Specifies the value of the monthtoexpire field.';
                    Visible = false;
                }
                field(monthtoexpiredate; Rec.monthtoexpiredate)
                {
                    ToolTip = 'Specifies the value of the monthtoexpiredate field.';
                    Visible = false;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        StyleText := 'standard';
        if Rec.monthtoexpire then
            StyleText := 'Unfavorable';
    end;

    var
        StyleText: Text;
}
