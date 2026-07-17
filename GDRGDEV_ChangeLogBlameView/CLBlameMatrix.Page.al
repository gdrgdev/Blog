namespace DefaultPublisher.ChangeLogView;

page 88891 "CL Blame Matrix"
{
    Caption = 'Change Log Blame Matrix';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "CL Blame Row Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(BlameRows)
            {
                ShowCaption = false;
                field(RowCaption; Rec."Row Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Field';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the field name or event metadata label.';
                }
                field(Col1; this.CellData[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[1];
                    Editable = false;
                    Visible = this.Col1Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 1.';
                }
                field(Col2; this.CellData[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[2];
                    Editable = false;
                    Visible = this.Col2Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 2.';
                }
                field(Col3; this.CellData[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[3];
                    Editable = false;
                    Visible = this.Col3Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 3.';
                }
                field(Col4; this.CellData[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[4];
                    Editable = false;
                    Visible = this.Col4Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 4.';
                }
                field(Col5; this.CellData[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[5];
                    Editable = false;
                    Visible = this.Col5Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 5.';
                }
                field(Col6; this.CellData[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[6];
                    Editable = false;
                    Visible = this.Col6Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 6.';
                }
                field(Col7; this.CellData[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[7];
                    Editable = false;
                    Visible = this.Col7Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 7.';
                }
                field(Col8; this.CellData[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[8];
                    Editable = false;
                    Visible = this.Col8Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 8.';
                }
                field(Col9; this.CellData[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[9];
                    Editable = false;
                    Visible = this.Col9Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 9.';
                }
                field(Col10; this.CellData[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[10];
                    Editable = false;
                    Visible = this.Col10Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 10.';
                }
                field(Col11; this.CellData[11])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[11];
                    Editable = false;
                    Visible = this.Col11Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 11.';
                }
                field(Col12; this.CellData[12])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + this.ColCaptions[12];
                    Editable = false;
                    Visible = this.Col12Visible;
                    Style = Strong;
                    StyleExpr = Rec."Is Header";
                    ToolTip = 'Specifies the value for event 12.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        i: Integer;
    begin
        for i := 1 to 12 do
            if this.TempCellBuf.Get(Rec."Row No.", i) then
                this.CellData[i] := this.TempCellBuf."Cell Value"
            else
                this.CellData[i] := '';
    end;

    internal procedure LoadData(TableNo: Integer; PK1: Text[50]; PK2: Text[50]; PK3: Text[50]; StartAt: Integer)
    var
        BlameMgmt: Codeunit "CL Blame Mgmt";
    begin
        Rec.Reset();
        Rec.DeleteAll(false);
        this.TempCellBuf.Reset();
        this.TempCellBuf.DeleteAll(false);
        Clear(this.ColCaptions);
        this.NoOfCols := 0;
        this.TotalEvents := 0;
        this.HasBaseline := false;

        BlameMgmt.LoadBlameData(Rec, this.TempCellBuf, this.ColCaptions, this.NoOfCols, this.TotalEvents, this.HasBaseline, TableNo, PK1, PK2, PK3, StartAt);

        this.ApplyColVisibility();
        CurrPage.Update(false);
    end;

    internal procedure GetTotalEvents(): Integer
    begin
        exit(this.TotalEvents);
    end;

    internal procedure GetHasBaseline(): Boolean
    begin
        exit(this.HasBaseline);
    end;

    local procedure ApplyColVisibility()
    begin
        this.Col1Visible := this.NoOfCols >= 1;
        this.Col2Visible := this.NoOfCols >= 2;
        this.Col3Visible := this.NoOfCols >= 3;
        this.Col4Visible := this.NoOfCols >= 4;
        this.Col5Visible := this.NoOfCols >= 5;
        this.Col6Visible := this.NoOfCols >= 6;
        this.Col7Visible := this.NoOfCols >= 7;
        this.Col8Visible := this.NoOfCols >= 8;
        this.Col9Visible := this.NoOfCols >= 9;
        this.Col10Visible := this.NoOfCols >= 10;
        this.Col11Visible := this.NoOfCols >= 11;
        this.Col12Visible := this.NoOfCols >= 12;
    end;

    var
        TempCellBuf: Record "CL Blame Cell Buffer" temporary;
        ColCaptions: array[12] of Text[80];
        CellData: array[12] of Text[2048];
        TotalEvents: Integer;
        NoOfCols: Integer;
        HasBaseline: Boolean;
        Col1Visible: Boolean;
        Col2Visible: Boolean;
        Col3Visible: Boolean;
        Col4Visible: Boolean;
        Col5Visible: Boolean;
        Col6Visible: Boolean;
        Col7Visible: Boolean;
        Col8Visible: Boolean;
        Col9Visible: Boolean;
        Col10Visible: Boolean;
        Col11Visible: Boolean;
        Col12Visible: Boolean;
}
