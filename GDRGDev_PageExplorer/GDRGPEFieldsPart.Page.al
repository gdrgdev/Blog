page 97822 "GDRGPE Fields Part"
{
    ApplicationArea = All;
    Caption = 'Fields';
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "GDRGPE Line";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Fields)
            {
                field(ItemCaption; Rec.Caption)
                {
                    Caption = 'Field';
                    ToolTip = 'Specifies the field name.';
                }
                field(Value; Rec.Value)
                {
                    Caption = 'Value';
                    StyleExpr = ValueStyleExprVar;
                }
                field(ItemTooltip; Rec.Tooltip)
                {
                    Caption = 'Description';
                    MultiLine = true;
                    StyleExpr = StyleExprVar;
                    ToolTip = 'Specifies the description of the field.';
                }
            }
        }
    }

    var
        StyleExprVar: Text[30];
        ValueStyleExprVar: Text[30];

    trigger OnAfterGetRecord()
    begin
        if Rec."Style Expr" = Format(PageStyle::Standard) then
            StyleExprVar := Rec."Style Expr"
        else
            StyleExprVar := Format(PageStyle::Unfavorable);
        if Rec.Value <> '' then
            ValueStyleExprVar := Format(PageStyle::Strong)
        else
            ValueStyleExprVar := Format(PageStyle::Standard);
    end;

    internal procedure SetValueFilter(OnlyNonEmpty: Boolean)
    begin
        if OnlyNonEmpty then
            Rec.SetFilter(Value, '<>%1', '')
        else
            Rec.SetRange(Value);
        CurrPage.Update(false);
    end;

    internal procedure LoadLines(var SourceLines: Record "GDRGPE Line")
    begin
        Rec.Reset();
        if not Rec.IsTemporary() then
            exit;
        Rec.DeleteAll(false);
        SourceLines.SetRange("Line Type", SourceLines."Line Type"::Field);
        if SourceLines.FindSet() then
            repeat
                Rec := SourceLines;
                Rec.Insert(false);
            until SourceLines.Next() = 0;
        SourceLines.SetRange("Line Type");
        CurrPage.Update(false);
    end;
}
