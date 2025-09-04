page 50103 "PTE Table Selector for Task"
{
    PageType = List;
    Caption = 'Select Table Type';
    SourceTable = "Integer";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            repeater(Tables)
            {
                field("Table Name"; TableName)
                {
                    ApplicationArea = All;
                    Caption = 'Table Type';
                    ToolTip = 'Specifies the table type to select records from.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SelectRecords)
            {
                ApplicationArea = All;
                Caption = 'Select Records';
                ToolTip = 'Specifies to open record selector for this table.';
                Image = SelectLineToApply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    OpenRecordSelector();
                end;
            }
        }
    }

    var
        SelectedRecordId: RecordId;
        SelectedTableNo: Integer;
        TableName: Text[100];

    trigger OnOpenPage()
    begin
        LoadTables();
    end;

    trigger OnAfterGetRecord()
    begin
        SelectedTableNo := Rec.Number;
        case SelectedTableNo of
            Database::Customer:
                TableName := 'Customer';
            Database::Vendor:
                TableName := 'Vendor';
            Database::Item:
                TableName := 'Item';
            Database::"Sales Header":
                TableName := 'Sales Order';
            else
                TableName := 'Unknown';
        end;
    end;

    local procedure LoadTables()
    begin
        Rec.Reset();
        Rec.DeleteAll(false);

        Rec.Init();
        Rec.Number := Database::Customer;
        Rec.Insert(false);

        Rec.Init();
        Rec.Number := Database::Vendor;
        Rec.Insert(false);

        Rec.Init();
        Rec.Number := Database::Item;
        Rec.Insert(false);

        Rec.Init();
        Rec.Number := Database::"Sales Header";
        Rec.Insert(false);

        if not Rec.FindFirst() then
            Clear(Rec); // Ensure clean state if no records found
    end;

    local procedure OpenRecordSelector()
    var
        RecordSelector: Page "PTE Record Selector";
    begin
        RecordSelector.SetTableNumber(SelectedTableNo);
        if RecordSelector.RunModal() = Action::OK then begin
            SelectedRecordId := RecordSelector.GetSelectedRecordId();
            CurrPage.Close();
        end;
    end;

    procedure GetSelectedRecordId(): RecordId
    begin
        exit(SelectedRecordId);
    end;
}