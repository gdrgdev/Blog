page 88892 "GDRG Anonymize Field List"
{
    ApplicationArea = All;
    Caption = 'Anonymization Fields';
    InsertAllowed = false;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "GDRG Anonymize Field Setup";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Table No."; Rec."Table No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Field No."; Rec."Field No.")
                {
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        SelectField();
                    end;
                }
                field("Field Name"; Rec."Field Name")
                {
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        SelectField();
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
            action(SelectFieldAction)
            {
                ApplicationArea = All;
                Caption = 'Select Field';
                Image = SelectEntries;
                ToolTip = 'Adds one field to the setup.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    SelectField();
                end;
            }
            action(AddSuggestedFieldsAction)
            {
                ApplicationArea = All;
                Caption = 'Suggested Fields';
                Image = SuggestLines;
                ToolTip = 'Adds suggested fields for the current table.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    AddSuggestedFields();
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Enabled := true;
    end;

    local procedure SelectField()
    var
        FieldMetadata: Record Field;
        SetupProposalMgt: Codeunit "GDRG Setup Proposal Mgt";
        FieldLookupPage: Page "GDRG Field Lookup";
        TableNo: Integer;
    begin
        TableNo := GetCurrentTableNo();
        if TableNo = 0 then
            exit;

        FieldMetadata.SetRange(TableNo, TableNo);
        FieldLookupPage.SetTableView(FieldMetadata);
        FieldLookupPage.LookupMode(true);
        if FieldLookupPage.RunModal() <> Action::LookupOK then
            exit;

        FieldLookupPage.GetRecord(FieldMetadata);

        SetupProposalMgt.AddField(TableNo, FieldMetadata."No.");
        CurrPage.Update(false);
    end;

    local procedure AddSuggestedFields()
    var
        SetupProposalMgt: Codeunit "GDRG Setup Proposal Mgt";
        TableNo: Integer;
    begin
        TableNo := GetCurrentTableNo();
        if TableNo = 0 then
            exit;

        SetupProposalMgt.AddSuggestedFields(TableNo);
        CurrPage.Update(false);
    end;

    local procedure GetCurrentTableNo(): Integer
    begin
        if Rec."Table No." <> 0 then
            exit(Rec."Table No.");

        exit(Rec.GetRangeMin("Table No."));
    end;
}