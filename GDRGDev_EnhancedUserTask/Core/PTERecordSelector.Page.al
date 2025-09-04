page 50102 "PTE Record Selector"
{
    PageType = List;
    Caption = 'Select Record';
    SourceTable = "Integer";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(RecordText; RecordDisplayText)
                {
                    ApplicationArea = All;
                    Caption = 'Record';
                    ToolTip = 'Specifies the record description.';
                    Editable = false;
                }

                field(KeyText; KeyDisplayText)
                {
                    ApplicationArea = All;
                    Caption = 'Key';
                    ToolTip = 'Specifies the primary key of the record.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SelectRecord)
            {
                ApplicationArea = All;
                Caption = 'Select';
                ToolTip = 'Specifies to select this record.';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    SelectCurrentRecord();
                end;
            }
        }
    }

    var
        SelectedRecordId: RecordId;
        TableNumber: Integer;
        RecordDisplayText: Text[250];
        KeyDisplayText: Text[100];
        RecordIdList: List of [RecordId];

    procedure SetTableNumber(TableNo: Integer)
    begin
        TableNumber := TableNo;
        LoadRecords();
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Number <= RecordIdList.Count() then begin
            SelectedRecordId := RecordIdList.Get(Rec.Number);
            SetDisplayTexts();
        end;
    end;

    local procedure SetDisplayTexts()
    var
        PTEUserTaskRecordMgt: Codeunit "PTE User Task Record Mgt";
        RecRef: RecordRef;
    begin
        if SelectedRecordId.TableNo() > 0 then begin
            RecRef.Get(SelectedRecordId);
            RecordDisplayText := PTEUserTaskRecordMgt.GetRecordDescription(SelectedRecordId);
            KeyDisplayText := CopyStr(PTEUserTaskRecordMgt.GetPrimaryKeyFieldsText(RecRef), 1, 100);
            RecRef.Close();
        end;
    end;

    local procedure LoadRecords()
    var
        RecRef: RecordRef;
        Counter: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll(false);
        Clear(RecordIdList);

        RecRef.Open(TableNumber);

        Counter := 0;
        if RecRef.FindSet() then
            repeat
                Counter += 1;
                RecordIdList.Add(RecRef.RecordId());

                Rec.Init();
                Rec.Number := Counter;
                Rec.Insert(false);
            until (RecRef.Next() = 0) or (Counter >= 50);

        RecRef.Close();
        if Rec.FindFirst() then; // Position cursor on first record for UI display
    end;


    local procedure SelectCurrentRecord()
    begin
        if Rec.Number <= RecordIdList.Count() then
            SelectedRecordId := RecordIdList.Get(Rec.Number);
        CurrPage.Close();
    end;

    procedure GetSelectedRecordId(): RecordId
    begin
        exit(SelectedRecordId);
    end;
}
