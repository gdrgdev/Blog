page 50100 "GDRG Personal Tags FactBox"
{
    Caption = 'Personal Tags';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "GDRG Personal Tag Assignment";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Tags)
            {
                field("Tag Color"; Rec."Tag Color")
                {
                    Caption = 'Color';
                }
                field("Tag Code"; Rec."Tag Code")
                {
                    Caption = 'Code';
                }
                field("Tag Name"; Rec."Tag Name")
                {
                    Caption = 'Name';
                    Style = Strong;

                    trigger OnDrillDown()
                    var
                        PersonalTags: Page "GDRG Personal Tag Assignments";
                    begin
                        PersonalTags.SetTableView(Rec);
                        PersonalTags.Run();
                    end;
                }
                field("User ID"; Rec."User ID")
                {
                    Caption = 'User';
                    Visible = false;
                }
                field("Created Date"; Rec."Created Date")
                {
                    Caption = 'Created';
                }
                field("Table No."; Rec."Table No.")
                {
                    Visible = false;
                }
                field("Record ID"; Rec."Record ID")
                {
                    Visible = false;
                }
                field("Table Name"; Rec."Table Name")
                {
                    Visible = false;
                }
                field("Record Description"; Rec."Record Description")
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
            action(AddTag)
            {
                Caption = 'Add Tag';
                Image = Add;
                ToolTip = 'Specifies to add a tag.';

                trigger OnAction()
                var
                    TagSelection: Page "GDRG Tag Selection";
                begin
                    TagSelection.SetRecord(CurrentRecordId);
                    if TagSelection.RunModal() = Action::OK then
                        CurrPage.Update(false);
                end;
            }
            action(RemoveTag)
            {
                Caption = 'Remove Tag';
                Image = Delete;
                ToolTip = 'Specifies to remove a tag.';

                trigger OnAction()
                var
                    PersonalTagMgr: Codeunit "GDRG Personal Tag Manager";
                    RecRef: RecordRef;
                begin
                    Rec.CalcFields("Tag Name");
                    if not Confirm('Remove tag "%1"?', false, Rec."Tag Name") then
                        exit;

                    if not RecRef.Get(CurrentRecordId) then
                        exit;

                    PersonalTagMgr.RemoveTag(RecRef, Rec."Tag Code");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateTags();
    end;

    var
        CurrentRecordId: RecordId;
        CurrentTableNo: Integer;

    procedure SetContext(RecordId: RecordId; TableNo: Integer)
    begin
        if RecordId.TableNo() = 0 then
            exit;

        CurrentRecordId := RecordId;
        CurrentTableNo := TableNo;
        UpdateTags();
    end;

    local procedure UpdateTags()
    begin
        Rec.Reset();
        Rec.SetRange("User ID", CopyStr(UserId(), 1, 50));
        Rec.SetRange("Table No.", CurrentTableNo);
        Rec.SetRange("Record ID", CurrentRecordId);
        CurrPage.Update(false);
    end;
}
