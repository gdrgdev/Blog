page 50100 "GDRG Performance Test Results"
{
    Caption = 'GDRG Performance Test Results';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Performance Test Result";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Results)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }

                field("Test Date"; Rec."Test Date")
                {
                }

                field("Method Type"; Rec."Method Type")
                {
                }

                field("Records Processed"; Rec."Records Processed")
                {
                }

                field("Total Value Calculated"; Rec."Total Value Calculated")
                {
                }

                field("Execution Time (ms)"; Rec."Execution Time (ms)")
                {
                }

                field("Processing Method"; Rec."Processing Method")
                {
                }

                field("Performance Rating"; Rec."Performance Rating")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Clear All Results")
            {
                Caption = 'Clear All Results';
                ToolTip = 'Specifies the action to clear all performance test results.';
                Image = ClearLog;

                trigger OnAction()
                begin
                    if Confirm('Clear all performance test results?') then begin
                        Rec.DeleteAll(false);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
}
