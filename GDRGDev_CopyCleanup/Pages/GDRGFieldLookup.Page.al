page 88893 "GDRG Field Lookup"
{
    ApplicationArea = All;
    Caption = 'Select Field';
    Editable = false;
    PageType = List;
    SourceTable = Field;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(TableNo; Rec.TableNo)
                {
                    ToolTip = 'Specifies the table number.';
                    Visible = false;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the field number.';
                }
                field(FieldName; Rec.FieldName)
                {
                    ToolTip = 'Specifies the field name.';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the field data type.';
                }
            }
        }
    }
}