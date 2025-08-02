page 50104 "GDRG Tag Selection"
{
    Caption = 'Select Tags';
    PageType = List;
    SourceTable = "GDRG Personal Tag Master";
    UsageCategory = Tasks;
    ApplicationArea = All;
    Permissions = tabledata "GDRG Personal Tag Assignment" = RIMD;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Selected; TempSelection)
                {
                    Caption = 'Select';
                    ToolTip = 'Specifies whether the tag is selected.';

                    trigger OnValidate()
                    begin
                        UpdateSelection();
                    end;
                }
                field(Code; Rec.Code)
                {
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    Editable = false;
                    Style = Strong;
                }
                field(Color; Rec.Color)
                {
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                }
                field("Created Date"; Rec."Created Date")
                {
                    Visible = false;
                }
                field("User ID"; Rec."User ID")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApplySelectedTags)
            {
                Caption = 'Apply Selected Tags';
                ToolTip = 'Specifies to apply selected tags.';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PersonalTagMgr: Codeunit "GDRG Personal Tag Manager";
                    RecRef: RecordRef;
                    TagCode: Code[20];
                    AppliedCount: Integer;
                begin
                    if not RecRef.Get(TargetRecordId) then
                        Error(RecordNotFoundErr);

                    AppliedCount := 0;
                    foreach TagCode in TempSelectionList do begin
                        PersonalTagMgr.AddTag(RecRef, TagCode);
                        AppliedCount += 1;
                    end;

                    if AppliedCount > 0 then
                        CurrPage.Close()
                    else
                        Message(NoTagsSelectedMsg);
                end;
            }
            action(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Specifies to cancel.';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("User ID", CopyStr(UserId(), 1, 50));
        Clear(TempSelectionList);
        LoadExistingSelections();
    end;

    trigger OnAfterGetRecord()
    begin
        TempSelection := IsTagSelected(Rec.Code);
    end;

    var
        TargetRecordId: RecordId;
        TempSelection: Boolean;
        TempSelectionList: List of [Code[20]];
        RecordNotFoundErr: Label 'Record not found.';
        NoTagsSelectedMsg: Label 'No tags were selected.';

    procedure SetRecord(RecordId: RecordId)
    begin
        TargetRecordId := RecordId;
    end;

    local procedure UpdateSelection()
    begin
        if TempSelection then begin
            if not TempSelectionList.Contains(Rec.Code) then
                TempSelectionList.Add(Rec.Code);
        end else
            if TempSelectionList.Contains(Rec.Code) then
                TempSelectionList.Remove(Rec.Code);
    end;

    local procedure IsTagSelected(TagCode: Code[20]): Boolean
    begin
        exit(TempSelectionList.Contains(TagCode));
    end;

    local procedure LoadExistingSelections()
    var
        PersonalTagAssignment: Record "GDRG Personal Tag Assignment";
        RecRef: RecordRef;
    begin
        if not RecRef.Get(TargetRecordId) then
            exit;

        PersonalTagAssignment.SetRange("User ID", CopyStr(UserId(), 1, 50));
        PersonalTagAssignment.SetRange("Record ID", TargetRecordId);
        if PersonalTagAssignment.FindSet() then
            repeat
                TempSelectionList.Add(PersonalTagAssignment."Tag Code");
            until PersonalTagAssignment.Next() = 0;
    end;
}
