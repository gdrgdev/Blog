codeunit 97816 "GDRGPE Builder"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        NextLineNo: Integer;
        OrderedCaptions: List of [Text];
        MainActionsSectionLbl: Label 'Main Actions';
        OtherActionsSectionLbl: Label 'Other Actions';

    internal procedure BuildGuide(PageId: Integer; SystemId: Guid; var TempGuideLine: Record "GDRGPE Line")
    var
        ValueByCaption: Dictionary of [Text, Text];
        TooltipByCaption: Dictionary of [Text, Text];
    begin
        NextLineNo := 0;
        Clear(OrderedCaptions);
        TempGuideLine.Reset();
        if not TempGuideLine.IsEmpty() then
            TempGuideLine.DeleteAll(false);

        ParsePageSummary(PageId, SystemId, ValueByCaption, TooltipByCaption);
        AddFieldSection(TempGuideLine, ValueByCaption, TooltipByCaption);
        AddActionSection(PageId, TempGuideLine);
    end;

    local procedure ParsePageSummary(PageId: Integer; SystemId: Guid; var ValueByCaption: Dictionary of [Text, Text]; var TooltipByCaption: Dictionary of [Text, Text])
    var
        PageSummaryProvider: Codeunit "Page Summary Provider";
        JObject: JsonObject;
        JsonResponse: Text;
    begin
        if IsNullGuid(SystemId) then
            exit;

        JsonResponse := PageSummaryProvider.GetPageSummaryBySystemID(PageId, SystemId);
        if not JObject.ReadFrom(JsonResponse) then
            exit;
        if JObject.Contains('error') then
            exit;

        ParseFieldArray(JObject, 'recordFields', ValueByCaption, TooltipByCaption);
        ParseFieldArray(JObject, 'fields', ValueByCaption, TooltipByCaption);
    end;

    local procedure ParseFieldArray(var JObject: JsonObject; ArrayKey: Text; var ValueByCaption: Dictionary of [Text, Text]; var TooltipByCaption: Dictionary of [Text, Text])
    var
        JToken: JsonToken;
        JFieldToken: JsonToken;
        JArray: JsonArray;
    begin
        if not JObject.Get(ArrayKey, JToken) then
            exit;

        JArray := JToken.AsArray();
        foreach JFieldToken in JArray do
            TryAddField(JFieldToken, ValueByCaption, TooltipByCaption);
    end;

    local procedure TryAddField(JFieldToken: JsonToken; var ValueByCaption: Dictionary of [Text, Text]; var TooltipByCaption: Dictionary of [Text, Text])
    var
        JToken: JsonToken;
        JFieldObject: JsonObject;
        FieldCaption: Text;
        FieldValue: Text;
        FieldTooltip: Text;
    begin
        JFieldObject := JFieldToken.AsObject();
        if JFieldObject.Get('caption', JToken) then
            FieldCaption := JToken.AsValue().AsText();
        if JFieldObject.Get('fieldValue', JToken) then
            FieldValue := JToken.AsValue().AsText();
        if JFieldObject.Get('tooltip', JToken) then
            FieldTooltip := JToken.AsValue().AsText();

        if FieldCaption = '' then
            exit;
        if not ValueByCaption.ContainsKey(FieldCaption) then begin
            ValueByCaption.Add(FieldCaption, FieldValue);
            TooltipByCaption.Add(FieldCaption, FieldTooltip);
            OrderedCaptions.Add(FieldCaption);
            exit;
        end;
        UpdateTooltipIfBetter(FieldCaption, FieldTooltip, TooltipByCaption);
    end;

    local procedure UpdateTooltipIfBetter(FieldCaption: Text; FieldTooltip: Text; var TooltipByCaption: Dictionary of [Text, Text])
    begin
        if (FieldTooltip <> '') and (TooltipByCaption.Get(FieldCaption) = '') then
            TooltipByCaption.Set(FieldCaption, FieldTooltip);
    end;

    local procedure AddFieldSection(var TempGuideLine: Record "GDRGPE Line"; var ValueByCaption: Dictionary of [Text, Text]; var TooltipByCaption: Dictionary of [Text, Text])
    var
        FieldCaption: Text;
    begin
        if OrderedCaptions.Count() = 0 then
            exit;
        foreach FieldCaption in OrderedCaptions do
            AddFieldRow(
                TempGuideLine,
                FieldCaption,
                ValueByCaption.Get(FieldCaption),
                TooltipByCaption.Get(FieldCaption));
    end;

    local procedure AddActionSection(PageId: Integer; var TempGuideLine: Record "GDRGPE Line")
    var
        PageAction: Record "Page Action";
    begin
        PageAction.SetLoadFields("Page ID", "Action Type", Caption, "Action Subtype", Promoted, ToolTip1, ToolTip2, ToolTip3, ToolTip4, RunObjectType, RunObjectID);
        PageAction.SetRange("Page ID", PageId);
        PageAction.SetRange("Action Type", PageAction."Action Type"::Action);
        PageAction.SetFilter(Caption, '<>%1', '');
        PageAction.SetFilter("Action Subtype", '<>%1&<>%2&<>%3',
            PageAction."Action Subtype"::SystemActions,
            PageAction."Action Subtype"::Prompting,
            PageAction."Action Subtype"::PromptGuide);

        PageAction.SetRange(Promoted, true);
        if PageAction.FindSet() then begin
            AddSectionHeader(TempGuideLine, MainActionsSectionLbl);
            AddActionRows(TempGuideLine, PageAction, true);
        end;

        PageAction.SetRange(Promoted, false);
        if PageAction.FindSet() then begin
            AddSectionHeader(TempGuideLine, OtherActionsSectionLbl);
            AddActionRows(TempGuideLine, PageAction, false);
        end;
    end;

    local procedure AddActionRows(var TempGuideLine: Record "GDRGPE Line"; var PageAction: Record "Page Action"; IsPromoted: Boolean)
    var
        FullTooltip: Text;
        ActionCaption: Text;
    begin
        repeat
            FullTooltip := PageAction.ToolTip1 + PageAction.ToolTip2 + PageAction.ToolTip3 + PageAction.ToolTip4;
            ActionCaption := PageAction.Caption;
            if PageAction.RunObjectID <> 0 then
                ActionCaption += ' → ' + Format(PageAction.RunObjectType);
            AddActionRow(TempGuideLine, ActionCaption, FullTooltip, IsPromoted);
        until PageAction.Next() = 0;
    end;

    local procedure AddSectionHeader(var TempGuideLine: Record "GDRGPE Line"; HeaderText: Text)
    begin
        NextLineNo += 10000;
        TempGuideLine.Init();
        TempGuideLine."Line No." := NextLineNo;
        TempGuideLine."Line Type" := TempGuideLine."Line Type"::Header;
        TempGuideLine.Caption := CopyStr(HeaderText, 1, MaxStrLen(TempGuideLine.Caption));
        TempGuideLine."Style Expr" := 'Strong';
        TempGuideLine.Insert(false);
    end;

    local procedure AddFieldRow(var TempGuideLine: Record "GDRGPE Line"; CaptionText: Text; ValueText: Text; TooltipText: Text)
    begin
        NextLineNo += 10000;
        TempGuideLine.Init();
        TempGuideLine."Line No." := NextLineNo;
        TempGuideLine."Line Type" := TempGuideLine."Line Type"::Field;
        TempGuideLine.Caption := CopyStr(CaptionText, 1, MaxStrLen(TempGuideLine.Caption));
        TempGuideLine.Value := CopyStr(ValueText, 1, MaxStrLen(TempGuideLine.Value));
        if TooltipText = '' then begin
            TempGuideLine.Tooltip := CopyStr('(no description available)', 1, MaxStrLen(TempGuideLine.Tooltip));
            TempGuideLine."Style Expr" := 'Subordinate';
        end else begin
            TempGuideLine.Tooltip := CopyStr(TooltipText, 1, MaxStrLen(TempGuideLine.Tooltip));
            TempGuideLine."Style Expr" := 'Standard';
        end;
        TempGuideLine.Insert(false);
    end;

    local procedure AddActionRow(var TempGuideLine: Record "GDRGPE Line"; CaptionText: Text; TooltipText: Text; IsPromoted: Boolean)
    begin
        NextLineNo += 10000;
        TempGuideLine.Init();
        TempGuideLine."Line No." := NextLineNo;
        TempGuideLine."Line Type" := TempGuideLine."Line Type"::Action;
        TempGuideLine.Caption := CopyStr(CaptionText, 1, MaxStrLen(TempGuideLine.Caption));
        TempGuideLine.Tooltip := CopyStr(TooltipText, 1, MaxStrLen(TempGuideLine.Tooltip));
        if IsPromoted then
            TempGuideLine."Style Expr" := 'Attention'
        else
            TempGuideLine."Style Expr" := 'Standard';
        TempGuideLine.Insert(false);
    end;
}
