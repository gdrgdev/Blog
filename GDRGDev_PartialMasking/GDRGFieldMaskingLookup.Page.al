page 90002 "GDRG Field Masking Lookup"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = Field;
    Caption = 'Select Field';
    Editable = false;
    UsageCategory = None;
    SourceTableView = where(Type = filter(Code | Text | BigInteger | Integer | Decimal | GUID));

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the field number.';
                }
                field(FieldName; Rec.FieldName)
                {
                    ToolTip = 'Specifies the field name.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ToolTip = 'Specifies the field caption.';
                }
                field("Type Name"; Rec."Type Name")
                {
                    ToolTip = 'Specifies the field type.';
                }
            }
        }
    }
}
