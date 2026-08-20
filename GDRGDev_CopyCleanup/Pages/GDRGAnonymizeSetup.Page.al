page 88891 "GDRG Anonymize Setup"
{
    ApplicationArea = All;
    Caption = 'Anonymization Setup';
    InsertAllowed = false;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "GDRG Anonymize Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Table No."; Rec."Table No.")
                {
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        AnonymizeFieldSetup: Record "GDRG Anonymize Field Setup";
                    begin
                        AnonymizeFieldSetup.SetRange("Table No.", Rec."Table No.");
                        Page.Run(Page::"GDRG Anonymize Field List", AnonymizeFieldSetup);
                    end;
                }
                field("Table Name"; Rec."Table Name")
                {
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        AnonymizeFieldSetup: Record "GDRG Anonymize Field Setup";
                    begin
                        AnonymizeFieldSetup.SetRange("Table No.", Rec."Table No.");
                        Page.Run(Page::"GDRG Anonymize Field List", AnonymizeFieldSetup);
                    end;
                }
                field(Enabled; Rec.Enabled)
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SelectTable)
            {
                ApplicationArea = All;
                Caption = 'Select Table';
                Image = SelectEntries;
                ToolTip = 'Adds one table to the setup.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    RunSelectTable();
                end;
            }
            action(AddSuggestedTables)
            {
                ApplicationArea = All;
                Caption = 'Suggested Tables';
                Image = SuggestLines;
                ToolTip = 'Adds a short list of suggested tables and their suggested fields.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    RunAddSuggestedTables();
                end;
            }
            action(RunManualCleanup)
            {
                ApplicationArea = All;
                Caption = 'Run Cleanup';
                Image = Start;
                ToolTip = 'Runs the same cleanup flow manually and writes the full log.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    RunManualCleanupForCurrentCompany();
                end;
            }
            action(Fields)
            {
                ApplicationArea = All;
                Caption = 'Fields';
                Image = EditLines;
                ToolTip = 'Opens the field setup for the selected table.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    AnonymizeFieldSetup: Record "GDRG Anonymize Field Setup";
                begin
                    if Rec."Table No." = 0 then
                        exit;

                    AnonymizeFieldSetup.SetRange("Table No.", Rec."Table No.");
                    Page.Run(Page::"GDRG Anonymize Field List", AnonymizeFieldSetup);
                end;
            }
        }
    }

    local procedure RunSelectTable()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        SetupProposalMgt: Codeunit "GDRG Setup Proposal Mgt";
        AllObjectsWithCaptionPage: Page "All Objects with Caption";
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjectsWithCaptionPage.SetTableView(AllObjWithCaption);
        AllObjectsWithCaptionPage.LookupMode(true);
        if AllObjectsWithCaptionPage.RunModal() <> Action::LookupOK then
            exit;

        AllObjectsWithCaptionPage.GetRecord(AllObjWithCaption);

        SetupProposalMgt.AddTable(AllObjWithCaption."Object ID");
        CurrPage.Update(false);
    end;

    local procedure RunAddSuggestedTables()
    var
        SetupProposalMgt: Codeunit "GDRG Setup Proposal Mgt";
    begin
        SetupProposalMgt.AddSuggestedTables();
        CurrPage.Update(false);
    end;

    local procedure RunManualCleanupForCurrentCompany()
    var
        Company: Record Company;
        EnvCleanupSubscriber: Codeunit "GDRG Env Cleanup Subscriber";
    begin
        if not Company.Get(CompanyName()) then
            exit;

        EnvCleanupSubscriber.RunManualCleanup(CopyStr(Company.Name, 1, 30));
    end;
}