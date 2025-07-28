pageextension 50100 "GDRG Item Inventory Demo" extends "Item List"
{
    actions
    {
        addfirst(processing)
        {
            group("Performance Demo")
            {
                Caption = 'RecordRef Performance Demo BC26';

                action("Run Performance Test")
                {
                    Caption = 'Run Performance Test';
                    ToolTip = 'Run both old and new methods and compare performance results.';
                    ApplicationArea = All;
                    Image = TestReport;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        RunPerformanceComparison();
                    end;
                }

                action("View Test Results")
                {
                    Caption = 'View Test Results';
                    ToolTip = 'View all performance test results.';
                    ApplicationArea = All;
                    Image = ShowList;

                    trigger OnAction()
                    var
                        PerformanceTestResults: Page "GDRG Performance Test Results";
                    begin
                        PerformanceTestResults.Run();
                    end;
                }
            }
        }
    }

    var
        QueriesLbl: Label '%1 CalcFields executed', Comment = '%1 = Number of CalcFields calls';

    local procedure RunPerformanceComparison()
    var
        PerformanceTestResult: Record "GDRG Performance Test Result";
        Method1Time: Duration;
        Method2Time: Duration;
        Method3Time: Duration;
        Method1Total: Decimal;
        Method2Total: Decimal;
        Method3Total: Decimal;
        RecordCount: Integer;
    begin
        PerformanceTestResult.Reset();
        PerformanceTestResult.DeleteAll(false);

        ProcessItemsMethod1(Method1Time, Method1Total, RecordCount);

        PerformanceTestResult.Init();
        PerformanceTestResult."Entry No." := 1;
        PerformanceTestResult."Test Date" := CurrentDateTime();
        PerformanceTestResult."Method Type" := PerformanceTestResult."Method Type"::"Record CalcFields in Loop";
        PerformanceTestResult."Records Processed" := RecordCount;
        PerformanceTestResult."Total Value Calculated" := Method1Total;
        PerformanceTestResult."Execution Time (ms)" := Method1Time;
        PerformanceTestResult."Processing Method" := StrSubstNo(QueriesLbl, RecordCount);
        PerformanceTestResult."Performance Rating" := 'SLOW ⚠️';
        PerformanceTestResult.Insert(false);

        ProcessItemsMethod2(Method2Time, Method2Total, RecordCount);

        PerformanceTestResult.Init();
        PerformanceTestResult."Entry No." := 2;
        PerformanceTestResult."Test Date" := CurrentDateTime();
        PerformanceTestResult."Method Type" := PerformanceTestResult."Method Type"::"Record SetAutoCalcFields";
        PerformanceTestResult."Records Processed" := RecordCount;
        PerformanceTestResult."Total Value Calculated" := Method2Total;
        PerformanceTestResult."Execution Time (ms)" := Method2Time;
        PerformanceTestResult."Processing Method" := 'FlowFields pre-calculated';
        PerformanceTestResult."Performance Rating" := 'FAST ⚡';
        PerformanceTestResult.Insert(false);

        ProcessItemsMethod3(Method3Time, Method3Total, RecordCount);

        PerformanceTestResult.Init();
        PerformanceTestResult."Entry No." := 3;
        PerformanceTestResult."Test Date" := CurrentDateTime();
        PerformanceTestResult."Method Type" := PerformanceTestResult."Method Type"::"RecordRef SetAutoCalcFields BC26";
        PerformanceTestResult."Records Processed" := RecordCount;
        PerformanceTestResult."Total Value Calculated" := Method3Total;
        PerformanceTestResult."Execution Time (ms)" := Method3Time;
        PerformanceTestResult."Processing Method" := 'RecordRef FlowFields pre-calculated';
        PerformanceTestResult."Performance Rating" := 'FAST ⚡ (BC26)';
        PerformanceTestResult.Insert(false);

        Page.Run(Page::"GDRG Performance Test Results");
    end;

    // Record with CalcFields in loop - Individual SQL queries (SLOW)
    local procedure ProcessItemsMethod1(var ExecutionTime: Duration; var TotalInventory: Decimal; var RecordCount: Integer)
    var
        ItemRec: Record Item;
        StartTime: DateTime;
        EndTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        TotalInventory := 0;
        RecordCount := 0;

        if ItemRec.FindSet(false) then
            repeat
                ItemRec.CalcFields(Inventory);
                TotalInventory += ItemRec.Inventory;
                RecordCount += 1;
            until ItemRec.Next() = 0;

        EndTime := CurrentDateTime();
        ExecutionTime := EndTime - StartTime;
    end;

    // Record with SetAutoCalcFields before loop - One SQL query (FAST)
    local procedure ProcessItemsMethod2(var ExecutionTime: Duration; var TotalInventory: Decimal; var RecordCount: Integer)
    var
        ItemRec: Record Item;
        StartTime: DateTime;
        EndTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        TotalInventory := 0;
        RecordCount := 0;

        ItemRec.SetAutoCalcFields(Inventory);

        if ItemRec.FindSet(false) then
            repeat
                TotalInventory += ItemRec.Inventory;
                RecordCount += 1;
            until ItemRec.Next() = 0;

        EndTime := CurrentDateTime();
        ExecutionTime := EndTime - StartTime;
    end;

    // RecordRef with SetAutoCalcFields - BC26 new functionality (FAST)
    local procedure ProcessItemsMethod3(var ExecutionTime: Duration; var TotalInventory: Decimal; var RecordCount: Integer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: DateTime;
        EndTime: DateTime;
        CurrentInventory: Decimal;
    begin
        StartTime := CurrentDateTime();
        TotalInventory := 0;
        RecordCount := 0;

        RecRef.Open(Database::Item);
        RecRef.SetAutoCalcFields(68);

        if RecRef.FindSet(false) then
            repeat
                FieldRef := RecRef.Field(68);
                Evaluate(CurrentInventory, Format(FieldRef.Value()));
                TotalInventory += CurrentInventory;
                RecordCount += 1;
            until RecRef.Next() = 0;

        EndTime := CurrentDateTime();
        ExecutionTime := EndTime - StartTime;
    end;
}
