page 50104 "GDRG Customer Test Data"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Valid Customers";
    Caption = 'GDRG Customer Test Data - Valid Customers';

    layout
    {
        area(Content)
        {
            repeater(ValidCustomers)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ToolTip = 'Specifies the value of the E-Mail field.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field.';
                }
                field("Method Used"; Rec."Method Used")
                {
                    ToolTip = 'Specifies the value of the Method Used field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Generate Test Data")
            {
                Caption = 'Generate Test Data';
                Image = Create;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Generate 20 test customers with random data.';

                trigger OnAction()
                var
                    TestDataGenerator: Codeunit "GDRG Test Data Generator";
                begin
                    TestDataGenerator.GenerateTestCustomers();
                    CurrPage.Update(false);
                end;
            }
            action("Refresh Valid List")
            {
                Caption = 'Refresh Valid List';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Refresh the list of valid customers.';

                trigger OnAction()
                var
                    TestDataGenerator: Codeunit "GDRG Test Data Generator";
                begin
                    TestDataGenerator.RefreshValidCustomers();
                    CurrPage.Update(false);
                end;
            }
            action("Clear Test Data")
            {
                Caption = 'Clear Test Data';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Clear all test data.';

                trigger OnAction()
                var
                    TestDataGenerator: Codeunit "GDRG Test Data Generator";
                begin
                    if Confirm('Clear all test data?') then begin
                        TestDataGenerator.ClearTestData();
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
}
