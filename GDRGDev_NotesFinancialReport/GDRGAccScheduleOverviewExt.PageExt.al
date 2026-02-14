pageextension 50102 "GDRG Acc. Schedule Overview" extends "Acc. Schedule Overview"
{
    layout
    {
        addfirst(factboxes)
        {
            part(GDRGNoteFactBox; "GDRG Acc. Schedule Note")
            {
                ApplicationArea = All;
                SubPageLink = "Schedule Name" = field("Schedule Name"), "Line No." = field("Line No.");
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(GDRGEditNote)
            {
                ApplicationArea = All;
                Caption = 'Edit Note';
                Image = EditLines;
                Scope = Repeater;

                trigger OnAction()
                var
                    AccScheduleLine: Record "Acc. Schedule Line";
                    EditNoteDialog: Page "GDRG Edit Note Dialog";
                begin
                    AccScheduleLine.Get(Rec."Schedule Name", Rec."Line No.");
                    EditNoteDialog.SetNoteText(AccScheduleLine."GDRG Note Text");
                    EditNoteDialog.LookupMode(true);
                    if EditNoteDialog.RunModal() = Action::LookupOK then begin
                        AccScheduleLine.Validate("GDRG Note Text", EditNoteDialog.GetNoteText());
                        AccScheduleLine.Modify(true);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        addlast("Export to Excel")
        {
            action(GDRGExportToExcel)
            {
                ApplicationArea = All;
                Caption = 'Export to Excel (with Notes)';
                Image = ExportToExcel;
                ToolTip = 'Export the account schedule data to Excel with line notes included.';

                trigger OnAction()
                var
                    AccSchedLine: Record "Acc. Schedule Line";
                    ExportReport: Report "GDRG Export Acc. Sched. Excel";
                begin
                    AccSchedLine.SetRange("Schedule Name", Rec."Schedule Name");
                    AccSchedLine.CopyFilters(Rec);
                    ExportReport.SetOptions(AccSchedLine, CurrentColumnName, UseAmtsInAddCurr, '');
                    ExportReport.Run();
                end;
            }
        }
        addlast("F&unctions")
        {
            action(GDRGAddSampleNotes)
            {
                ApplicationArea = All;
                Caption = 'Add Sample Notes (TEST)';
                Image = TestDatabase;

                trigger OnAction()
                var
                    AccSchedLine: Record "Acc. Schedule Line";
                    NoteText: Text;
                    CRLF: Text[2];
                    NotesAdded: Integer;
                begin
                    CRLF[1] := 13;
                    CRLF[2] := 10;
                    AccSchedLine.SetRange("Schedule Name", Rec."Schedule Name");
                    if AccSchedLine.FindSet(true) then begin
                        NotesAdded := 0;
                        repeat
                            NoteText := '';
                            case AccSchedLine."Row No." of
                                '1000':
                                    begin
                                        NoteText := 'BASIS OF PRESENTATION' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'The accompanying financial statements have been prepared in accordance with generally accepted accounting principles (GAAP).' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'The company follows the accrual basis of accounting, whereby revenues are recognized when earned and expenses when incurred, regardless of cash flow timing.';
                                    end;
                                '2000':
                                    begin
                                        NoteText := 'FIXED ASSETS COMPOSITION' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Total assets include:' + CRLF;
                                        NoteText += '- Property, plant and equipment: $28,450,000' + CRLF;
                                        NoteText += '- Accumulated depreciation: ($12,980,740)' + CRLF;
                                        NoteText += '- Net fixed assets: $15,469,260' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Depreciation is calculated using the straight-line method over the estimated useful lives of the assets, ranging from 3 to 25 years.';
                                    end;
                                '3000':
                                    begin
                                        NoteText := 'LONG-TERM DEBT' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Current liabilities include a term loan with ABC Bank with the following terms:' + CRLF;
                                        NoteText += '- Principal amount: $45,000,000' + CRLF;
                                        NoteText += '- Interest rate: 4.75% fixed' + CRLF;
                                        NoteText += '- Maturity date: December 31, 2028' + CRLF;
                                        NoteText += '- Current portion due: $5,625,000';
                                    end;
                                '4010':
                                    begin
                                        NoteText := 'REVENUE RECOGNITION POLICY' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Revenue from product sales is recognized when control of the goods transfers to the customer, typically upon shipment or delivery based on contractual terms.' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Service revenue is recognized over time as services are performed. The company applies the percentage-of-completion method for long-term service contracts.';
                                    end;
                                '7000':
                                    begin
                                        NoteText := 'OPERATING INCOME BREAKDOWN' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Operating income for the current period includes:' + CRLF;
                                        NoteText += '- Product sales: $82,340,500 (63%)' + CRLF;
                                        NoteText += '- Service revenue: $38,720,100 (30%)' + CRLF;
                                        NoteText += '- Licensing fees: $9,473,900 (7%)' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Geographic distribution: North America 52%, Europe 31%, Asia-Pacific 17%.';
                                    end;
                                '8000':
                                    begin
                                        NoteText := 'COST OF GOODS SOLD COMPONENTS' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'COGS includes direct materials ($28.5M), direct labor ($15.2M), and manufacturing overhead ($14.8M).' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'The increase of 12.3% compared to prior period is primarily due to higher raw material costs and increased production volume to meet demand.';
                                    end;
                                '9000':
                                    begin
                                        NoteText := 'OPERATING EXPENSES' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Operating expenses consist of:' + CRLF;
                                        NoteText += '- Selling and marketing: $7,840,000' + CRLF;
                                        NoteText += '- General and administrative: $4,320,000' + CRLF;
                                        NoteText += '- Research and development: $900,000' + CRLF;
                                        NoteText += CRLF;
                                        NoteText += 'Notable items: includes $1.2M one-time consulting fees related to ERP system implementation.';
                                    end;
                            end;

                            if NoteText <> '' then begin
                                AccSchedLine.Validate("GDRG Note Text", NoteText);
                                AccSchedLine.Modify(true);
                                NotesAdded += 1;
                            end;
                        until AccSchedLine.Next() = 0;
                        Message('Added %1 realistic financial notes to specific lines.', NotesAdded);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(GDRGAddSampleNotes_Promoted; GDRGAddSampleNotes) { }
        }
        addlast("Category_Export to Excel")
        {
            actionref(GDRGExportToExcel_Promoted; GDRGExportToExcel) { }
        }
    }
}
