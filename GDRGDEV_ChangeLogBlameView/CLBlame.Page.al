namespace DefaultPublisher.ChangeLogView;

using System.Reflection;

page 88892 "CL Blame"
{
    Caption = 'Change Log Blame View';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(RecordSelection)
            {
                Caption = 'Record Selection';
                field(TableNoField; this.TableNoFilter)
                {
                    Caption = 'Table No.';
                    Importance = Standard;
                    ToolTip = 'Specifies the BC table number to view change history for.';

                    trigger OnValidate()
                    begin
                        this.UpdateTableCaption();
                        this.PK1Filter := '';
                        this.PK2Filter := '';
                        this.PK3Filter := '';
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObjWithCaption: Record AllObjWithCaption;
                    begin
                        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
                        if Page.RunModal(0, AllObjWithCaption) = Action::LookupOK then begin
                            this.TableNoFilter := AllObjWithCaption."Object ID";
                            this.UpdateTableCaption();
                            this.PK1Filter := '';
                            this.PK2Filter := '';
                            this.PK3Filter := '';
                        end;
                        exit(true);
                    end;
                }
                field(TableCaptionField; this.TableCaptionFilter)
                {
                    Caption = 'Table';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the name of the selected table.';
                }
                field(PK1Field; this.PK1Filter)
                {
                    Caption = 'Primary Key 1';
                    Importance = Standard;
                    ToolTip = 'Specifies the first primary key value of the record (e.g. Customer No., Vendor No., Item No.).';
                }
                field(PK2Field; this.PK2Filter)
                {
                    Caption = 'Primary Key 2';
                    Importance = Additional;
                    ToolTip = 'Specifies the second primary key value, if the record has a composite key (e.g. Ship-to Code).';
                }
                field(PK3Field; this.PK3Filter)
                {
                    Caption = 'Primary Key 3';
                    Importance = Additional;
                    ToolTip = 'Specifies the third primary key value for records with a three-part key.';
                }
                field(EventRangeField; this.EventRangeText)
                {
                    Caption = 'Showing Events';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the range of change events currently visible in the matrix.';
                }
            }
            part(BlamePart; "CL Blame Matrix")
            {
                Caption = 'Change History';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadChangeLog)
            {
                Caption = 'Load Change Log';
                Image = ShowMatrix;
                ToolTip = 'Specifies that the blame matrix is loaded for the selected table and record.';

                trigger OnAction()
                begin
                    this.CurrentEventStart := 1;
                    this.RunLoad();
                end;
            }
            action(PrevSet)
            {
                Caption = '← Previous';
                Image = PreviousSet;
                Enabled = this.PrevSetEnabled;
                ToolTip = 'Specifies that the previous 12 change events are shown.';

                trigger OnAction()
                begin
                    this.CurrentEventStart -= this.EventsPerPage;
                    if this.CurrentEventStart < 1 then
                        this.CurrentEventStart := 1;
                    this.RunLoad();
                end;
            }
            action(NextSet)
            {
                Caption = 'Next →';
                Image = NextSet;
                Enabled = this.NextSetEnabled;
                ToolTip = 'Specifies that the next 12 change events are shown.';

                trigger OnAction()
                begin
                    this.CurrentEventStart += this.EventsPerPage;
                    this.RunLoad();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(LoadChangeLog_Promoted; LoadChangeLog) { }
                actionref(PrevSet_Promoted; PrevSet) { }
                actionref(NextSet_Promoted; NextSet) { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if (this.TableNoFilter <> 0) and (this.PK1Filter <> '') then
            this.RunLoad();
    end;

    internal procedure SetParameters(NewTableNo: Integer; NewPK1: Text[50]; NewPK2: Text[50]; NewPK3: Text[50])
    begin
        this.TableNoFilter := NewTableNo;
        this.PK1Filter := NewPK1;
        this.PK2Filter := NewPK2;
        this.PK3Filter := NewPK3;
        this.CurrentEventStart := 1;
        this.EventsPerPage := 12;
        this.UpdateTableCaption();
    end;

    local procedure RunLoad()
    var
        EndAt: Integer;
    begin
        if this.TableNoFilter = 0 then
            Error(this.SelectTableNumberErr);
        if this.PK1Filter = '' then
            Error(this.EnterPrimaryKeyErr);
        if this.CurrentEventStart < 1 then
            this.CurrentEventStart := 1;
        CurrPage.BlamePart.Page.LoadData(this.TableNoFilter, this.PK1Filter, this.PK2Filter, this.PK3Filter, this.CurrentEventStart);
        this.TotalEvents := CurrPage.BlamePart.Page.GetTotalEvents();
        if CurrPage.BlamePart.Page.GetHasBaseline() then
            this.EventsPerPage := 11
        else
            this.EventsPerPage := 12;
        this.PrevSetEnabled := this.CurrentEventStart > 1;
        this.NextSetEnabled := this.CurrentEventStart + this.EventsPerPage <= this.TotalEvents;
        EndAt := this.CurrentEventStart + this.EventsPerPage - 1;
        if EndAt > this.TotalEvents then
            EndAt := this.TotalEvents;
        if this.TotalEvents > 0 then
            this.EventRangeText := Format(this.CurrentEventStart) + ' – ' + Format(EndAt) + ' of ' + Format(this.TotalEvents)
        else
            this.EventRangeText := '';
    end;

    local procedure UpdateTableCaption()
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        this.TableCaptionFilter := '';
        if this.TableNoFilter <> 0 then
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, this.TableNoFilter) then
                this.TableCaptionFilter := AllObjWithCaption."Object Caption";
    end;

    var
        TableNoFilter: Integer;
        TableCaptionFilter: Text[250];
        PK1Filter: Text[50];
        PK2Filter: Text[50];
        PK3Filter: Text[50];
        CurrentEventStart: Integer;
        TotalEvents: Integer;
        EventsPerPage: Integer;
        EventRangeText: Text[50];
        PrevSetEnabled: Boolean;
        NextSetEnabled: Boolean;
        SelectTableNumberErr: Label 'Select a table number first.';
        EnterPrimaryKeyErr: Label 'Enter at least the first primary key value.';
}
