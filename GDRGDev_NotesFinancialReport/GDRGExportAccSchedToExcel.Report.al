report 50105 "GDRG Export Acc. Sched. Excel"
{
    Caption = 'Export Acc. Sched. to Excel with Notes';
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            trigger OnAfterGetRecord()
            var
                Company: Record Company;
                Window: Dialog;
                RecNo: Integer;
                TotalRecNo: Integer;
                RowNo: Integer;
                ColumnNo: Integer;
                CompanyDisplayName: Text;
                IntroductionParagraph: Text;
                ClosingParagraph: Text;
            begin
                Window.Open(Text000 + '@1@@@@@@@@@@@@@@@@@@@@@\');
                Window.Update(1, 0);
                AccSchedLine.SetFilter(Show, '<>%1', AccSchedLine.Show::No);
                TotalRecNo := AccSchedLine.Count();
                RecNo := 0;

                TempExcelBuffer.DeleteAll();
                Clear(TempExcelBuffer);

                AccSchedName.Get(AccSchedLine.GetRangeMin("Schedule Name"));
                AccSchedManagement.CheckAnalysisView(AccSchedName.Name, ColumnLayout.GetRangeMin("Column Layout Name"), true);
                if AccSchedName."Analysis View Name" <> '' then
                    AnalysisView.Get(AccSchedName."Analysis View Name");
                GLSetup.Get();

                RowNo := 1;
                EnterCell(RowNo, 1, Text001, false, false, true, false, '', TempExcelBuffer."Cell Type"::Text);
                EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Date Filter"), AccSchedLine.FieldCaption("Date Filter"), '', TempExcelBuffer."Cell Type"::Text);
                EnterFilterInCell(RowNo, AccSchedLine.GetFilter("G/L Budget Filter"), AccSchedLine.FieldCaption("G/L Budget Filter"), '', TempExcelBuffer."Cell Type"::Text);
                EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Cost Budget Filter"), AccSchedLine.FieldCaption("Cost Budget Filter"), '', TempExcelBuffer."Cell Type"::Text);
                EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Cost Center Filter"), AccSchedLine.FieldCaption("Cost Center Filter"), '', TempExcelBuffer."Cell Type"::Text);
                EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Cost Object Filter"), AccSchedLine.FieldCaption("Cost Object Filter"), '', TempExcelBuffer."Cell Type"::Text);
                EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Cash Flow Forecast Filter"), AccSchedLine.FieldCaption("Cash Flow Forecast Filter"), '', TempExcelBuffer."Cell Type"::Text);

                IntroductionParagraph := FinancialReport.GetIntroductoryParagraph();
                if IntroductionParagraph <> '' then begin
                    RowNo += 1;
                    EnterCellBlobValue(RowNo, 1, IntroductionParagraph, TempExcelBuffer."Cell Type"::Text);
                end;

                EnterDimensionFilters(RowNo);

                RowNo := RowNo + 1;
                if UseAmtsInAddCurr then
                    EnterFilterInCell(RowNo, GLSetup."Additional Reporting Currency", Currency.TableCaption(), '', TempExcelBuffer."Cell Type"::Text)
                else
                    EnterFilterInCell(RowNo, GLSetup."LCY Code", Currency.TableCaption(), '', TempExcelBuffer."Cell Type"::Text);

                RowNo := RowNo + 1;
                if AccSchedLine.FindSet() then begin
                    if ColumnLayout.FindSet() then begin
                        RowNo := RowNo + 1;
                        ColumnNo := 2;
                        repeat
                            ColumnNo := ColumnNo + 1;
                            EnterCell(RowNo, ColumnNo, AccSchedManagement.CalcColumnHeader(AccSchedLine, ColumnLayout), false, false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        until ColumnLayout.Next() = 0;
                        ColumnNo := ColumnNo + 1;
                        EnterCell(RowNo, ColumnNo, 'Notes', true, false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    end;
                    repeat
                        RecNo := RecNo + 1;
                        Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                        if ShouldIncludeRow() then begin
                            RowNo := RowNo + 1;
                            ColumnNo := 1;
                            EnterCell(RowNo, ColumnNo, AccSchedLine."Row No.", AccSchedLine.Bold, AccSchedLine.Italic, AccSchedLine.Underline, AccSchedLine."Double Underline", '0', TempExcelBuffer."Cell Type"::Text);
                            ColumnNo := 2;
                            if IncludeRow(AccSchedLine) then
                                EnterCell(RowNo, ColumnNo, AccSchedLine.Description, AccSchedLine.Bold, AccSchedLine.Italic, AccSchedLine.Underline, AccSchedLine."Double Underline", '', TempExcelBuffer."Cell Type"::Text);
                            if ColumnLayout.FindSet() then
                                repeat
                                    CalcColumnValue();
                                    ColumnNo := ColumnNo + 1;
                                    if IncludeRow(AccSchedLine) then
                                        EnterCell(RowNo, ColumnNo, MatrixMgt.FormatAmount(ColumnValue, ColumnLayout."Rounding Factor", UseAmtsInAddCurr), AccSchedLine.Bold, AccSchedLine.Italic, AccSchedLine.Underline, AccSchedLine."Double Underline", '', TempExcelBuffer."Cell Type"::Number)
                                until ColumnLayout.Next() = 0;
                            ColumnNo := ColumnNo + 1;
                            if AccSchedLine."GDRG Has Notes" then
                                EnterCell(RowNo, ColumnNo, AccSchedLine."GDRG Note Text", false, false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        end;
                    until AccSchedLine.Next() = 0;
                end;

                ClosingParagraph := FinancialReport.GetClosingParagraph();
                if ClosingParagraph <> '' then begin
                    RowNo += 1;
                    EnterCellBlobValue(RowNo, 1, ClosingParagraph, TempExcelBuffer."Cell Type"::Text);
                end;

                Window.Close();

                Company.Get(CompanyName());
                CompanyDisplayName := Company."Display Name";
                if CompanyDisplayName = '' then
                    CompanyDisplayName := Company.Name;

                TempExcelBuffer.CreateNewBook(AccSchedName.Name);
                TempExcelBuffer.WriteSheet(AccSchedName.Description, CompanyDisplayName, UserId);
                TempExcelBuffer.CloseBook();
                TempExcelBuffer.SetFriendlyFilename(AccSchedName.Name);
                TempExcelBuffer.OpenExcel();
            end;
        }
    }

    var
        AccSchedName: Record "Acc. Schedule Name";
        AccSchedLine: Record "Acc. Schedule Line";
        ColumnLayout: Record "Column Layout";
        TempExcelBuffer: Record "Excel Buffer" temporary;
        GLSetup: Record "General Ledger Setup";
        AnalysisView: Record "Analysis View";
        Currency: Record Currency;
        FinancialReport: Record "Financial Report";
        AccSchedManagement: Codeunit AccSchedManagement;
        MatrixMgt: Codeunit "Matrix Management";
        UseAmtsInAddCurr: Boolean;
        ColumnValue: Decimal;
        Text000: Label 'Analyzing Data...\\';
        Text001: Label 'Filters';

    procedure SetOptions(var AccSchedLine2: Record "Acc. Schedule Line"; ColumnLayoutName2: Code[10]; UseAmtsInAddCurr2: Boolean; FinancialReportName: Code[10])
    begin
        AccSchedLine.CopyFilters(AccSchedLine2);
        ColumnLayout.SetRange("Column Layout Name", ColumnLayoutName2);
        UseAmtsInAddCurr := UseAmtsInAddCurr2;
        if FinancialReportName <> '' then
            FinancialReport.Get(FinancialReportName);
    end;

    local procedure CalcColumnValue()
    begin
        if (AccSchedLine.Totaling = '') or (AccSchedLine."Totaling Type" in [AccSchedLine."Totaling Type"::Underline, AccSchedLine."Totaling Type"::"Double Underline"]) then
            ColumnValue := 0
        else begin
            ColumnValue := AccSchedManagement.CalcCell(AccSchedLine, ColumnLayout, UseAmtsInAddCurr);
            if AccSchedManagement.GetDivisionError() then
                ColumnValue := 0
        end;
    end;

    local procedure EnterFilterInCell(var RowNo: Integer; Filter: Text[250]; FieldName: Text[100]; Format: Text[30]; CellType: Option)
    begin
        if Filter <> '' then begin
            RowNo := RowNo + 1;
            EnterCell(RowNo, 1, FieldName, false, false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            EnterCell(RowNo, 2, Filter, false, false, false, false, Format, CellType);
        end;
    end;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; Italic: Boolean; UnderLine: Boolean; DoubleUnderLine: Boolean; Format: Text[30]; CellType: Option)
    begin
        TempExcelBuffer.Init();
        TempExcelBuffer.Validate("Row No.", RowNo);
        TempExcelBuffer.Validate("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Text" := CopyStr(CellValue, 1, MaxStrLen(TempExcelBuffer."Cell Value as Text"));
        TempExcelBuffer.Formula := '';
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        if DoubleUnderLine = true then begin
            TempExcelBuffer."Double Underline" := true;
            TempExcelBuffer.Underline := false;
        end else begin
            TempExcelBuffer."Double Underline" := false;
            TempExcelBuffer.Underline := UnderLine;
        end;
        TempExcelBuffer.NumberFormat := Format;
        TempExcelBuffer."Cell Type" := CellType;
        TempExcelBuffer.Insert();
    end;

    local procedure IncludeRow(AccSchedLine: Record "Acc. Schedule Line"): Boolean
    begin
        exit(not (AccSchedLine."Totaling Type" in [AccSchedLine."Totaling Type"::Underline, AccSchedLine."Totaling Type"::"Double Underline", AccSchedLine."Totaling Type"::"Set Base For Percent"]));
    end;

    local procedure EnterCellBlobValue(RowNo: Integer; ColumnNo: Integer; CellValue: Text; CellType: Option)
    var
        OutStream: OutStream;
    begin
        TempExcelBuffer.Init();
        TempExcelBuffer.Validate("Row No.", RowNo);
        TempExcelBuffer.Validate("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Blob".CreateOutStream(OutStream);
        OutStream.WriteText(CellValue);
        TempExcelBuffer."Cell Type" := CellType;
        TempExcelBuffer.Insert();
    end;

    local procedure GetDimFilterCaption(DimFilterNo: Integer): Text[80]
    var
        Dimension: Record Dimension;
    begin
        if AccSchedName."Analysis View Name" = '' then
            case DimFilterNo of
                1:
                    Dimension.Get(GLSetup."Global Dimension 1 Code");
                2:
                    Dimension.Get(GLSetup."Global Dimension 2 Code");
            end
        else
            case DimFilterNo of
                1:
                    Dimension.Get(AnalysisView."Dimension 1 Code");
                2:
                    Dimension.Get(AnalysisView."Dimension 2 Code");
                3:
                    Dimension.Get(AnalysisView."Dimension 3 Code");
                4:
                    Dimension.Get(AnalysisView."Dimension 4 Code");
            end;
        exit(CopyStr(Dimension.GetMLFilterCaption(GlobalLanguage), 1, 80));
    end;

    local procedure EnterDimensionFilters(var RowNo: Integer)
    begin
        if ((AccSchedName."Analysis View Name" = '') and (GLSetup."Global Dimension 1 Code" <> '')) or ((AccSchedName."Analysis View Name" <> '') and (AnalysisView."Dimension 1 Code" <> '')) then
            EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Dimension 1 Filter"), GetDimFilterCaption(1), '', TempExcelBuffer."Cell Type"::Text);
        if ((AccSchedName."Analysis View Name" = '') and (GLSetup."Global Dimension 2 Code" <> '')) or ((AccSchedName."Analysis View Name" <> '') and (AnalysisView."Dimension 2 Code" <> '')) then
            EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Dimension 2 Filter"), GetDimFilterCaption(2), '', TempExcelBuffer."Cell Type"::Text);
        if (AccSchedName."Analysis View Name" = '') or ((AccSchedName."Analysis View Name" <> '') and (AnalysisView."Dimension 3 Code" <> '')) then
            EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Dimension 3 Filter"), GetDimFilterCaption(3), '', TempExcelBuffer."Cell Type"::Text);
        if (AccSchedName."Analysis View Name" = '') or ((AccSchedName."Analysis View Name" <> '') and (AnalysisView."Dimension 4 Code" <> '')) then
            EnterFilterInCell(RowNo, AccSchedLine.GetFilter("Dimension 4 Filter"), GetDimFilterCaption(4), '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure ShouldIncludeRow(): Boolean
    begin
        if AccSchedLine.Show = AccSchedLine.Show::"If Any Column Not Zero" then begin
            if ColumnLayout.FindSet() then
                repeat
                    CalcColumnValue();
                    if ColumnValue <> 0 then
                        exit(true);
                until ColumnLayout.Next() = 0;
            exit(false);
        end;
        exit(true);
    end;
}
