/// <summary>
/// Helper codeunit for Mermaid example diagram generation
/// Centralizes data access and diagram generation logic
/// </summary>
codeunit 60105 "Mermaid Example Helpers"
{
    Permissions = tabledata "Sales Header" = R,
                  tabledata "Sales Line" = R,
                  tabledata "Sales Invoice Header" = R,
                  tabledata "Sales Shipment Header" = R,
                  tabledata "BOM Component" = R,
                  tabledata Item = R,
                  tabledata Job = R,
                  tabledata "Job Task" = R;
    procedure GenerateCustomerFlowDiagram(CustomerNo: Code[20]; CustomerName: Text[100]; Balance: Decimal): Text
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        TypeHelper: Codeunit "Type Helper";
        Diagram: Text;
        OrderCount: Integer;
        InvoiceCount: Integer;
        ShipmentCount: Integer;
    begin
        if CustomerNo = '' then
            exit('');

        // Count related records
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        OrderCount := SalesHeader.Count();

        SalesInvoiceHeader.SetRange("Sell-to Customer No.", CustomerNo);
        InvoiceCount := SalesInvoiceHeader.Count();

        SalesShipmentHeader.SetRange("Sell-to Customer No.", CustomerNo);
        ShipmentCount := SalesShipmentHeader.Count();

        // Build flowchart
        Diagram := 'flowchart LR' + TypeHelper.LFSeparator();
        Diagram += '    Customer["🧑 Customer<br/>' + CustomerName + '<br/>(' + CustomerNo + ')"]' + TypeHelper.LFSeparator();
        Diagram += '    Customer --> Orders["📋 Sales Orders<br/>(' + Format(OrderCount) + ')"]' + TypeHelper.LFSeparator();
        Diagram += '    Orders --> Process[Process Orders]' + TypeHelper.LFSeparator();
        Diagram += '    Process --> Ship["📦 Shipments<br/>(' + Format(ShipmentCount) + ')"]' + TypeHelper.LFSeparator();
        Diagram += '    Ship --> Invoices["🧾 Posted Invoices<br/>(' + Format(InvoiceCount) + ')"]' + TypeHelper.LFSeparator();

        if Balance <> 0 then
            Diagram += '    Invoices --> Payment["💰 Outstanding<br/>' + Format(Balance) + '"]' + TypeHelper.LFSeparator();

        exit(Diagram);
    end;

    procedure GenerateJobTimelineDiagram(JobNo: Code[20]; JobDescription: Text[100]): Text
    var
        TypeHelper: Codeunit "Type Helper";
        Diagram: Text;
    begin
        if JobNo = '' then
            exit('');

        Diagram := 'gantt' + TypeHelper.LFSeparator();
        Diagram += '    title Project Timeline: ' + JobDescription + ' (' + JobNo + ')' + TypeHelper.LFSeparator();
        Diagram += '    dateFormat YYYY-MM-DD' + TypeHelper.LFSeparator();
        Diagram += '    section Tasks' + TypeHelper.LFSeparator();
        Diagram += AddJobTasksToTimeline(JobNo, TypeHelper);

        exit(Diagram);
    end;

    procedure GenerateItemBOMDiagram(ItemNo: Code[20]; ItemDescription: Text[100]; ItemType: Enum "Item Type"; BaseUnitOfMeasure: Code[10]): Text
    var
        TypeHelper: Codeunit "Type Helper";
        Diagram: Text;
        ItemTypeText: Text;
    begin
        if ItemNo = '' then
            exit('');

        ItemTypeText := GetItemTypeText(ItemType);

        Diagram := 'classDiagram' + TypeHelper.LFSeparator();
        Diagram += BuildParentItemClass(ItemNo, ItemDescription, ItemTypeText, BaseUnitOfMeasure, TypeHelper);
        Diagram += AddBOMComponents(ItemNo, TypeHelper);

        exit(Diagram);
    end;

    procedure GeneratePurchaseStatusDiagram(DocumentNo: Code[20]; Status: Enum "Purchase Document Status"; VendorName: Text[100]): Text
    var
        TypeHelper: Codeunit "Type Helper";
        Diagram: Text;
        SafeVendorName: Text;
    begin
        if DocumentNo = '' then
            exit('');

        SafeVendorName := VendorName.Replace(',', '');
        SafeVendorName := SafeVendorName.Replace(':', '');

        // Build state diagram
        Diagram := 'stateDiagram-v2' + TypeHelper.LFSeparator();
        Diagram += '    [*] --> Open: Create PO ' + DocumentNo + TypeHelper.LFSeparator();
        Diagram += '    Open --> Released: Release' + TypeHelper.LFSeparator();
        Diagram += '    Released --> PendingApproval: Request Approval' + TypeHelper.LFSeparator();
        Diagram += '    PendingApproval --> Released: Approve' + TypeHelper.LFSeparator();
        Diagram += '    PendingApproval --> Open: Reject' + TypeHelper.LFSeparator();
        Diagram += '    Released --> PartialReceive: Partial Receipt' + TypeHelper.LFSeparator();
        Diagram += '    PartialReceive --> Completed: Final Receipt' + TypeHelper.LFSeparator();
        Diagram += '    Released --> Completed: Full Receipt' + TypeHelper.LFSeparator();
        Diagram += '    Completed --> [*]: Close' + TypeHelper.LFSeparator();
        Diagram += '    ' + TypeHelper.LFSeparator();

        // Highlight current status
        case Status of
            Status::Open:
                Diagram += '    Open: Current Status' + TypeHelper.LFSeparator();
            Status::Released:
                Diagram += '    Released: Current Status' + TypeHelper.LFSeparator();
            Status::"Pending Approval":
                Diagram += '    PendingApproval: Current Status' + TypeHelper.LFSeparator();
        end;

        Diagram += '    note right of Open : Vendor ' + SafeVendorName + TypeHelper.LFSeparator();

        exit(Diagram);
    end;

    procedure GenerateOrderLinesDiagram(DocumentNo: Code[20]): Text
    var
        SalesLine: Record "Sales Line";
        TypeHelper: Codeunit "Type Helper";
        Diagram: Text;
        LineCount: Integer;
    begin
        if DocumentNo = '' then
            exit('');

        Diagram := 'flowchart TD' + TypeHelper.LFSeparator();
        Diagram += '    Order["📋 Sales Order<br/>' + DocumentNo + '"]' + TypeHelper.LFSeparator();

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then begin
            repeat
                LineCount += 1;
                if LineCount <= 10 then
                    Diagram += BuildSalesLineNode(LineCount, SalesLine, TypeHelper);
            until (SalesLine.Next() = 0) or (LineCount >= 10);

            if LineCount > 10 then
                Diagram += '    Order --> More["... and ' + Format(LineCount - 10) + ' more lines"]' + TypeHelper.LFSeparator();
        end;

        exit(Diagram);
    end;

    procedure GenerateOrderSequenceDiagram(DocumentNo: Code[20]; Status: Enum "Sales Document Status"): Text
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TypeHelper: Codeunit "Type Helper";
        Diagram: Text;
        HasShipment: Boolean;
        HasInvoice: Boolean;
    begin
        if DocumentNo = '' then
            exit('');

        // Check if order has been shipped/invoiced
        SalesShipmentHeader.SetRange("Order No.", DocumentNo);
        HasShipment := not SalesShipmentHeader.IsEmpty();

        SalesInvoiceHeader.SetRange("Order No.", DocumentNo);
        HasInvoice := not SalesInvoiceHeader.IsEmpty();

        // Build sequence diagram
        Diagram := 'sequenceDiagram' + TypeHelper.LFSeparator();
        Diagram += '    participant C as Customer' + TypeHelper.LFSeparator();
        Diagram += '    participant S as Sales' + TypeHelper.LFSeparator();
        Diagram += '    participant I as Inventory' + TypeHelper.LFSeparator();
        Diagram += '    participant W as Warehouse' + TypeHelper.LFSeparator();
        Diagram += '    participant A as Accounting' + TypeHelper.LFSeparator();
        Diagram += '    ' + TypeHelper.LFSeparator();
        Diagram += '    C->>S: Place Order ' + DocumentNo + TypeHelper.LFSeparator();
        Diagram += '    S->>I: Check Availability' + TypeHelper.LFSeparator();

        if Status = Status::Released then begin
            Diagram += '    I-->>S: Available' + TypeHelper.LFSeparator();
            Diagram += '    S->>W: Release to Warehouse' + TypeHelper.LFSeparator();
        end else
            Diagram += '    Note over S: Order Status: ' + Format(Status) + TypeHelper.LFSeparator();

        if HasShipment then begin
            Diagram += '    W->>C: Ship Items' + TypeHelper.LFSeparator();
            Diagram += '    W->>S: Confirm Shipment' + TypeHelper.LFSeparator();
        end;

        if HasInvoice then begin
            Diagram += '    S->>A: Create Invoice' + TypeHelper.LFSeparator();
            Diagram += '    A->>C: Send Invoice' + TypeHelper.LFSeparator();
            Diagram += '    C->>A: Payment' + TypeHelper.LFSeparator();
        end;

        exit(Diagram);
    end;

    local procedure AddJobTasksToTimeline(JobNo: Code[20]; TypeHelper: Codeunit "Type Helper"): Text
    var
        JobTask: Record "Job Task";
        Result: Text;
    begin
        JobTask.SetRange("Job No.", JobNo);
        JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);
        JobTask.SetCurrentKey("Job No.", "Job Task No.");
        if JobTask.FindSet() then
            repeat
                Result += BuildJobTaskLine(JobTask, TypeHelper);
            until JobTask.Next() = 0
        else
            Result := '    No tasks defined :done, ' + Format(Today(), 0, '<Year4>-<Month,2>-<Day,2>') + ', 1d' + TypeHelper.LFSeparator();
        exit(Result);
    end;

    local procedure BuildJobTaskLine(JobTask: Record "Job Task"; TypeHelper: Codeunit "Type Helper"): Text
    var
        TaskName: Text;
        StartDate: Date;
        EndDate: Date;
    begin
        // Use task description
        TaskName := CopyStr(JobTask.Description, 1, 40);
        if TaskName = '' then
            TaskName := JobTask."Job Task No.";

        // Calculate FlowFields first
        JobTask.CalcFields("Start Date", "End Date");
        StartDate := JobTask."Start Date";
        EndDate := JobTask."End Date";

        // Fallback if no dates defined
        if StartDate = 0D then
            StartDate := Today();
        if EndDate = 0D then
            EndDate := CalcDate('<+7D>', StartDate);

        exit('    ' + TaskName + ' :active, ' +
             Format(StartDate, 0, '<Year4>-<Month,2>-<Day,2>') + ', ' +
             Format(EndDate, 0, '<Year4>-<Month,2>-<Day,2>') + TypeHelper.LFSeparator());
    end;

    local procedure GetItemTypeText(ItemType: Enum "Item Type"): Text
    begin
        case ItemType of
            ItemType::Inventory:
                exit('Inventory');
            ItemType::"Non-Inventory":
                exit('Non-Inventory');
            ItemType::Service:
                exit('Service');
        end;
    end;

    local procedure BuildParentItemClass(ItemNo: Code[20]; ItemDescription: Text[100]; ItemTypeText: Text; BaseUnitOfMeasure: Code[10]; TypeHelper: Codeunit "Type Helper"): Text
    var
        Result: Text;
    begin
        Result := '    class ' + SanitizeForMermaid(ItemNo) + ' {' + TypeHelper.LFSeparator();
        Result += '        <<Parent Item>>' + TypeHelper.LFSeparator();
        Result += '        +No: ' + ItemNo + TypeHelper.LFSeparator();
        Result += '        +Description: ' + CopyStr(ItemDescription, 1, 30) + TypeHelper.LFSeparator();
        Result += '        +Type: ' + ItemTypeText + TypeHelper.LFSeparator();
        Result += '        +Base Unit: ' + BaseUnitOfMeasure + TypeHelper.LFSeparator();
        Result += '    }' + TypeHelper.LFSeparator();
        exit(Result);
    end;

    local procedure AddBOMComponents(ItemNo: Code[20]; TypeHelper: Codeunit "Type Helper"): Text
    var
        BOMComponent: Record "BOM Component";
        Result: Text;
        ComponentCount: Integer;
    begin
        BOMComponent.SetRange("Parent Item No.", ItemNo);
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        if BOMComponent.FindSet() then begin
            Result := ProcessBOMComponentsList(ItemNo, BOMComponent, TypeHelper, ComponentCount);
            if ComponentCount > 10 then
                Result += BuildMoreComponentsNote(ItemNo, ComponentCount - 10, TypeHelper);
        end else
            Result := BuildNoBOMNote(ItemNo, TypeHelper);

        exit(Result);
    end;

    local procedure ProcessBOMComponentsList(ItemNo: Code[20]; var BOMComponent: Record "BOM Component"; TypeHelper: Codeunit "Type Helper"; var ComponentCount: Integer): Text
    var
        Item: Record Item;
        Result: Text;
    begin
        repeat
            ComponentCount += 1;
            if ComponentCount <= 10 then
                if Item.Get(BOMComponent."No.") then
                    Result += BuildComponentClass(ItemNo, BOMComponent, Item, TypeHelper);
        until (BOMComponent.Next() = 0) or (ComponentCount >= 10);
        exit(Result);
    end;

    local procedure BuildMoreComponentsNote(ItemNo: Code[20]; AdditionalCount: Integer; TypeHelper: Codeunit "Type Helper"): Text
    begin
        exit('    note for ' + SanitizeForMermaid(ItemNo) + ' "... and ' +
             Format(AdditionalCount) + ' more components"' + TypeHelper.LFSeparator());
    end;

    local procedure BuildNoBOMNote(ItemNo: Code[20]; TypeHelper: Codeunit "Type Helper"): Text
    begin
        exit('    note for ' + SanitizeForMermaid(ItemNo) + ' "No BOM components defined"' + TypeHelper.LFSeparator());
    end;

    local procedure BuildComponentClass(ParentItemNo: Code[20]; BOMComponent: Record "BOM Component"; Item: Record Item; TypeHelper: Codeunit "Type Helper"): Text
    var
        Result: Text;
    begin
        Result := '    class ' + SanitizeForMermaid(BOMComponent."No.") + ' {' + TypeHelper.LFSeparator();
        Result += '        +No: ' + BOMComponent."No." + TypeHelper.LFSeparator();
        Result += '        +Description: ' + CopyStr(Item.Description, 1, 30) + TypeHelper.LFSeparator();
        Result += '        +Qty per: ' + Format(BOMComponent."Quantity per") + TypeHelper.LFSeparator();
        Result += '    }' + TypeHelper.LFSeparator();
        Result += '    ' + SanitizeForMermaid(ParentItemNo) + ' "1" --> "' +
                  Format(BOMComponent."Quantity per") + '" ' +
                  SanitizeForMermaid(BOMComponent."No.") + ' : contains' + TypeHelper.LFSeparator();
        exit(Result);
    end;

    local procedure BuildSalesLineNode(LineCount: Integer; SalesLine: Record "Sales Line"; TypeHelper: Codeunit "Type Helper"): Text
    var
        Result: Text;
        ColorStyle: Text;
    begin
        Result := '    Order --> Line' + Format(LineCount) + '["' +
                  CopyStr(SalesLine.Description, 1, 30) + '<br/>Qty: ' +
                  Format(SalesLine.Quantity) + '"]' + TypeHelper.LFSeparator();

        ColorStyle := GetLineColorStyle(SalesLine.Quantity);
        if ColorStyle <> '' then
            Result += '    style Line' + Format(LineCount) + ' ' + ColorStyle + TypeHelper.LFSeparator();

        exit(Result);
    end;

    local procedure GetLineColorStyle(Quantity: Decimal): Text
    begin
        if Quantity >= 10 then
            exit('fill:#90EE90');
        if Quantity >= 5 then
            exit('fill:#FFD700');
        exit('fill:#FFB6C1');
    end;

    local procedure SanitizeForMermaid(InputText: Text): Text
    begin
        InputText := InputText.Replace('-', '_');
        InputText := InputText.Replace(' ', '_');
        InputText := InputText.Replace('.', '_');
        InputText := InputText.Replace('/', '_');
        exit(InputText);
    end;
}
