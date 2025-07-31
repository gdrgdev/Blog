page 50101 "GDRG Audit List"
{
    Caption = 'Audit History';
    PageType = List;
    SourceTable = "GDRG Audit Entry";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Table No."; Rec."Table No.")
                {
                }
                field("Table Name"; Rec."Table Name")
                {
                }
                field("Field Name"; Rec."Field Name")
                {
                }
                field("Field Value"; Rec."Field Value")
                {
                }
                field("Processing Time"; Rec."Processing Time")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearHistory)
            {
                Caption = 'Clear History';
                Image = Delete;
                ToolTip = 'Clears all audit history entries.';

                trigger OnAction()
                var
                    AuditEntry: Record "GDRG Audit Entry";
                begin
                    if Confirm('Are you sure you want to delete all audit history?') then begin
                        AuditEntry.DeleteAll(false);
                        Message('Audit history cleared successfully.');
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
}
