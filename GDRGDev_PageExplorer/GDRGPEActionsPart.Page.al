page 97823 "GDRGPE Actions Part"
{
    ApplicationArea = All;
    Caption = 'Actions';
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
            repeater(Lines)
            {
                field(ItemCaption; Rec.Caption)
                {
                    Caption = 'Action';
                    StyleExpr = StyleExprVar;
                    ToolTip = 'Specifies the action name.';
                }
                field(ItemTooltip; Rec.Tooltip)
                {
                    Caption = 'Description';
                    MultiLine = true;
                    StyleExpr = TooltipStyleVar;
                    ToolTip = 'Specifies the description of the action.';
                }
            }
        }
    }

    var
        StyleExprVar: Text[30];
        TooltipStyleVar: Text[30];

    trigger OnAfterGetRecord()
    begin
        StyleExprVar := Rec."Style Expr";
        if Rec."Line Type" = Rec."Line Type"::Header then
            TooltipStyleVar := Format(PageStyle::Subordinate)
        else
            if Rec.Tooltip = '' then
                TooltipStyleVar := Format(PageStyle::Unfavorable)
            else
                TooltipStyleVar := Format(PageStyle::Standard);
    end;

    internal procedure LoadLines(var SourceLines: Record "GDRGPE Line")
    begin
        Rec.Reset();
        if not Rec.IsTemporary() then
            exit;
        Rec.DeleteAll(false);
        SourceLines.SetFilter("Line Type", '%1|%2',
            SourceLines."Line Type"::Header,
            SourceLines."Line Type"::Action);
        if SourceLines.FindSet() then
            repeat
                Rec := SourceLines;
                Rec.Insert(false);
            until SourceLines.Next() = 0;
        SourceLines.SetRange("Line Type");
        CurrPage.Update(false);
    end;
}
