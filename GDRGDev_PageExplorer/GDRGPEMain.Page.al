page 97817 "GDRGPE Main"
{
    ApplicationArea = All;
    Caption = 'Page Explorer';
    Editable = false;
    Extensible = false;
    PageType = ListPlus;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                part(FieldsPart; "GDRGPE Fields Part")
                {
                    Caption = 'Fields';
                }
                part(ActionsPart; "GDRGPE Actions Part")
                {
                    Caption = 'Actions';
                }
            }
            group(PageInfo)
            {
                Caption = 'Summary';
                field(PageNameField; PageNameVar)
                {
                    Caption = 'Page';
                    Style = Strong;
                    ToolTip = 'Specifies the name of the explored page.';
                }
                field(FieldCountField; FieldCountVar)
                {
                    Caption = 'Fields';
                    ToolTip = 'Specifies the number of fields found on the page.';
                }
                field(ActionCountField; ActionCountVar)
                {
                    Caption = 'Actions';
                    ToolTip = 'Specifies the number of actions found on the page.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewRawJson)
            {
                Caption = 'View Page Summary JSON';
                Image = ViewDetails;
                ToolTip = 'Shows the raw JSON returned by the Page Summary Provider for this record.';

                trigger OnAction()
                var
                    PageSummaryProvider: Codeunit "Page Summary Provider";
                    RawJsonPage: Page "GDRGPE Raw JSON";
                begin
                    RawJsonPage.SetJson(PageSummaryProvider.GetPageSummaryBySystemID(PageId, SystemId));
                    RawJsonPage.RunModal();
                end;
            }
            action(FilterByValue)
            {
                Caption = 'With Value Only';
                Image = Filter;
                ToolTip = 'Shows only fields that have a value.';
                Visible = not ShowOnlyWithValue;

                trigger OnAction()
                begin
                    ShowOnlyWithValue := true;
                    CurrPage.FieldsPart.Page.SetValueFilter(true);
                end;
            }
            action(ShowAll)
            {
                Caption = 'Show All Fields';
                Image = RemoveFilterLines;
                ToolTip = 'Removes the filter and shows all fields, including those without a value.';
                Visible = ShowOnlyWithValue;

                trigger OnAction()
                begin
                    ShowOnlyWithValue := false;
                    CurrPage.FieldsPart.Page.SetValueFilter(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(ViewRawJson_Promoted; ViewRawJson) { }
            actionref(FilterByValue_Promoted; FilterByValue) { }
            actionref(ShowAll_Promoted; ShowAll) { }
        }
    }

    var
        PageId: Integer;
        SystemId: Guid;
        PageNameVar: Text[250];
        FieldCountVar: Integer;
        ActionCountVar: Integer;
        ShowOnlyWithValue: Boolean;

    trigger OnOpenPage()
    var
        TempGuideLine: Record "GDRGPE Line" temporary;
        AllObjWithCaption: Record AllObjWithCaption;
        GuideBuilder: Codeunit "GDRGPE Builder";
    begin
        if PageId = 0 then
            exit;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Page);
        AllObjWithCaption.SetRange("Object ID", PageId);
        if AllObjWithCaption.FindFirst() then
            PageNameVar := AllObjWithCaption."Object Caption";
        GuideBuilder.BuildGuide(PageId, SystemId, TempGuideLine);
        TempGuideLine.SetRange("Line Type", TempGuideLine."Line Type"::Field);
        FieldCountVar := TempGuideLine.Count();
        TempGuideLine.SetRange("Line Type", TempGuideLine."Line Type"::Action);
        ActionCountVar := TempGuideLine.Count();
        TempGuideLine.SetRange("Line Type");
        CurrPage.FieldsPart.Page.LoadLines(TempGuideLine);
        CurrPage.ActionsPart.Page.LoadLines(TempGuideLine);
    end;

    internal procedure SetParameters(NewPageId: Integer; NewSystemId: Guid)
    begin
        PageId := NewPageId;
        SystemId := NewSystemId;
    end;
}
