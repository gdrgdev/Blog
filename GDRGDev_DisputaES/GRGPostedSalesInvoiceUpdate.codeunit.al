
codeunit 80000 GRGPostedSalesInvoiceUpdate
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Invoice Header - Edit", OnRunOnBeforeSalesInvoiceHeaderModify, '', false, false)]
    local procedure "Sales Invoice Header - Edit_OnRunOnBeforeSalesInvoiceHeaderModify"
        (var SalesInvoiceHeader: Record "Sales Invoice Header"; FromSalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader."Dispute Status" := FromSalesInvoiceHeader."Dispute Status";
        UpdateCustLedgerEntry(SalesInvoiceHeader)
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Invoice - Update", OnAfterRecordIsChanged, '', false, false)]
    local procedure "Posted Sales Invoice - Update_OnAfterRecordIsChanged"(var SalesInvoiceHeader: Record "Sales Invoice Header"; xSalesInvoiceHeader: Record "Sales Invoice Header"; var RecordIsChanged: Boolean)
    begin
        If SalesInvoiceHeader."Dispute Status" <> xSalesInvoiceHeader."Dispute Status" then
            RecordIsChanged := true;
    end;

    local procedure UpdateCustLedgerEntry(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DisputeStatus: Record "Dispute Status";
        CustEntryEdit: Codeunit "Cust. Entry-Edit";
        MarkedAsOnHoldLbl: label 'X', Locked = true;
    begin
        if not GetCustLedgerEntry(CustLedgerEntry, SalesInvoiceHeader) then
            exit;

        if CustLedgerEntry."Dispute Status" <> '' then begin
            if DisputeStatus.get(CustLedgerEntry."Dispute Status") then
                if (DisputeStatus."Overwrite on hold") and ClearOnHold(SalesInvoiceHeader) then
                    CustLedgerEntry."On Hold" := ''
        end else
            if SalesInvoiceHeader."Dispute Status" <> '' then
                if DisputeStatus.get(SalesInvoiceHeader."Dispute Status") then
                    if DisputeStatus."Overwrite on hold" then
                        CustLedgerEntry."On Hold" := Copystr(MarkedAsOnHoldLbl, 1, MaxStrLen(CustLedgerEntry."On Hold"));
        CustLedgerEntry."Dispute Status" := SalesInvoiceHeader."Dispute Status";

        CustEntryEdit.SetCalledFromSalesInvoice(true);
        CustEntryEdit.Run(CustLedgerEntry);
    end;

    local procedure GetCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    begin
        if SalesInvoiceHeader."Cust. Ledger Entry No." = 0 then
            exit(false);
        CustLedgerEntry.ReadIsolation(IsolationLevel::UpdLock);
        exit(CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No."));
    end;

    local procedure ClearOnHold(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        DisputeStatus: Record "Dispute Status";
    begin
        if SalesInvoiceHeader."Dispute Status" = '' then
            exit(true);
        if DisputeStatus.get(SalesInvoiceHeader."Dispute Status") then
            exit(not DisputeStatus."Overwrite on hold");
    end;
}