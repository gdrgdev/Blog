page 96000 GDRJsonPage
{
    ApplicationArea = All;
    Caption = 'GDR Testing Json Codeunit';
    PageType = List;
    SourceTable = GDRGJsonTable;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(string; Rec.string)
                {
                    ToolTip = 'Specifies the value of the string field.', Comment = '%';
                }
                field("integer"; Rec."integer")
                {
                    ToolTip = 'Specifies the value of the integer field.', Comment = '%';
                }
                field("decimal"; Rec."decimal")
                {
                    ToolTip = 'Specifies the value of the decimal field.', Comment = '%';
                }
                field("boolean"; Rec."boolean")
                {
                    ToolTip = 'Specifies the value of the boolean field.', Comment = '%';
                }
            }
        }
    }
}
