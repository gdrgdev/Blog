page 50101 "GDRG Performance Test"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Performance Test Results";
    Caption = 'GDRG Performance Test - Continue Statement Demo';
    Permissions = tabledata "GDRG Performance Test Results" = RIMD,
        tabledata "GDRG Valid Customers" = RIMD,
        tabledata "Customer" = RIMD;
    layout
    {
        area(Content)
        {
            repeater(Results)
            {
                field("Method Type"; Rec."Method Type")
                {
                    ToolTip = 'Specifies the value of the Method Type field.';
                }
                field("Customers Processed"; Rec."Customers Processed")
                {
                    ToolTip = 'Specifies the value of the Customers Processed field.';
                }
                field("Execution Time (ms)"; Rec."Execution Time (ms)")
                {
                    ToolTip = 'Specifies the value of the Execution Time (ms) field.';
                }
                field("Execution DateTime"; Rec."Execution DateTime")
                {
                    ToolTip = 'Specifies the value of the Execution DateTime field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Run IF Statement")
            {
                Caption = 'Run IF Statement Method';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Run performance test using nested IF statements method.';

                trigger OnAction()
                begin
                    RunIfStatement();
                    CurrPage.Update(false);
                end;
            }
            action("Run Continue Statement")
            {
                Caption = 'Run Continue Statement Method';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Run performance test using continue statement method.';

                trigger OnAction()
                begin
                    RunContinueStatement();
                    CurrPage.Update(false);
                end;
            }
            action("Clear Results")
            {
                Caption = 'Clear All Results';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Delete all test results from the list.';

                trigger OnAction()
                begin
                    if Confirm('Delete all test results?') then begin
                        Rec.DeleteAll(false);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    local procedure RunIfStatement()
    var
        Customer: Record Customer;
        ProcessedCount: Integer;
        TotalCount: Integer;
        StartTime: DateTime;
        EndTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        ProcessedCount := 0;
        TotalCount := 0;

        if Customer.FindSet() then
            repeat
                TotalCount += 1;

                if Customer.Blocked = Customer.Blocked::" " then
                    if Customer."E-Mail" <> '' then
                        if Customer."Phone No." <> '' then begin
                            ProcessedCount += 1;
                            CreateValidCustomerEntry(Customer, 'IF Statement');
                        end;
            until Customer.Next() = 0;

        EndTime := CurrentDateTime();
        CreatePerformanceResult('IF Statement', ProcessedCount, StartTime, EndTime);
        ShowResults('IF Statement', ProcessedCount, TotalCount, EndTime - StartTime);
    end;

    local procedure RunContinueStatement()
    var
        Customer: Record Customer;
        ProcessedCount: Integer;
        TotalCount: Integer;
        StartTime: DateTime;
        EndTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        ProcessedCount := 0;
        TotalCount := 0;

        if Customer.FindSet() then
            repeat
                TotalCount += 1;

                if Customer.Blocked <> Customer.Blocked::" " then continue;
                if Customer."E-Mail" = '' then continue;
                if Customer."Phone No." = '' then continue;

                ProcessedCount += 1;
                CreateValidCustomerEntry(Customer, 'Continue Statement');
            until Customer.Next() = 0;

        EndTime := CurrentDateTime();
        CreatePerformanceResult('Continue Statement', ProcessedCount, StartTime, EndTime);
        ShowResults('Continue Statement', ProcessedCount, TotalCount, EndTime - StartTime);
    end;

    local procedure CreateValidCustomerEntry(Customer: Record Customer; MethodUsed: Text[50])
    var
        ValidCustomer: Record "GDRG Valid Customers";
        NextEntryNo: Integer;
    begin
        ValidCustomer.Reset();
        if ValidCustomer.FindLast() then
            NextEntryNo := ValidCustomer."Entry No." + 1
        else
            NextEntryNo := 1;

        ValidCustomer.Init();
        ValidCustomer."Entry No." := NextEntryNo;
        ValidCustomer."Customer No." := Customer."No.";
        ValidCustomer.Name := Customer.Name;
        ValidCustomer.Blocked := Customer.Blocked;
        ValidCustomer."E-Mail" := Customer."E-Mail";
        ValidCustomer."Phone No." := Customer."Phone No.";
        ValidCustomer."Method Used" := MethodUsed;
        ValidCustomer.Insert(false);
    end;

    local procedure CreatePerformanceResult(MethodType: Text[50]; ProcessedCount: Integer; StartTime: DateTime; EndTime: DateTime)
    var
        TestResult: Record "GDRG Performance Test Results";
    begin
        TestResult.Init();
        case MethodType of
            'IF Statement':
                TestResult."Method Type" := TestResult."Method Type"::"IF Statement";
            'Continue Statement':
                TestResult."Method Type" := TestResult."Method Type"::"Continue Statement";
        end;
        TestResult."Customers Processed" := ProcessedCount;
        TestResult."Execution Time (ms)" := EndTime - StartTime;
        TestResult."Execution DateTime" := StartTime;
        TestResult.Insert(false);
    end;

    local procedure ShowResults(MethodType: Text[50]; ProcessedCount: Integer; TotalCount: Integer; ExecutionTime: Integer)
    begin
        Message('%1: %2 valid customers from %3 total in %4ms', MethodType, ProcessedCount, TotalCount, ExecutionTime);
    end;
}
