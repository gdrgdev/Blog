codeunit 50111 "GDRG Subscriptions"
{
    Permissions = tabledata "GDRG Audit Entry" = RIMD;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterInsertEvent, '', false, false)]
    local procedure OnCustomerInsert(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        ProcessWithVariantCustomer(Rec);
        ProcessWithImplicitCustomer(Rec);
        ProcessWithRecordCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterInsertEvent, '', false, false)]
    local procedure OnItemInsert(var Rec: Record Item; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        ProcessWithVariantItem(Rec);
        ProcessWithImplicitItem(Rec);
        ProcessWithRecordItem(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, OnAfterInsertEvent, '', false, false)]
    local procedure OnVendorInsert(var Rec: Record Vendor; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        ProcessWithVariantVendor(Rec);
        ProcessWithImplicitVendor(Rec);
        ProcessWithRecordVendor(Rec);
    end;

    local procedure ProcessWithVariantCustomer(Customer: Record Customer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
        CustomerVariant: Variant;
    begin
        CustomerVariant := Customer;
        StartTime := Time();
        RecRef.GetTable(CustomerVariant);
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Variant Method', StartTime);
        RecRef.Close();
    end;

    local procedure ProcessWithVariantItem(Item: Record Item)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
        ItemVariant: Variant;
    begin
        ItemVariant := Item;
        StartTime := Time();
        RecRef.GetTable(ItemVariant);
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Variant Method', StartTime);
        RecRef.Close();
    end;

    local procedure ProcessWithVariantVendor(Vendor: Record Vendor)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
        VendorVariant: Variant;
    begin
        VendorVariant := Vendor;
        StartTime := Time();
        RecRef.GetTable(VendorVariant);
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Variant Method', StartTime);
        RecRef.Close();
    end;

    local procedure ProcessWithImplicitCustomer(Customer: Record Customer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
    begin
        StartTime := Time();
        RecRef := Customer;
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Implicit Method', StartTime);
    end;

    local procedure ProcessWithImplicitItem(Item: Record Item)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
    begin
        StartTime := Time();
        RecRef := Item;
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Implicit Method', StartTime);
    end;

    local procedure ProcessWithImplicitVendor(Vendor: Record Vendor)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
    begin
        StartTime := Time();
        RecRef := Vendor;
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Implicit Method', StartTime);
    end;

    local procedure ProcessWithRecordCustomer(Customer: Record Customer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
    begin
        StartTime := Time();
        RecRef.GetTable(Customer);
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Record Method', StartTime);
        RecRef.Close();
    end;

    local procedure ProcessWithRecordItem(Item: Record Item)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
    begin
        StartTime := Time();
        RecRef.GetTable(Item);
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Record Method', StartTime);
        RecRef.Close();
    end;

    local procedure ProcessWithRecordVendor(Vendor: Record Vendor)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        StartTime: Time;
    begin
        StartTime := Time();
        RecRef.GetTable(Vendor);
        FieldRef := RecRef.FieldIndex(1);
        if FieldRef.Class() = FieldClass::Normal then
            CreateAuditEntry(RecRef, FieldRef, 'Record Method', StartTime);
        RecRef.Close();
    end;

    local procedure CreateAuditEntry(RecRef: RecordRef; FieldRef: FieldRef; Method: Text; StartTime: Time)
    var
        AuditEntry: Record "GDRG Audit Entry";
        EntryNo: Integer;
    begin
        AuditEntry.Reset();
        if AuditEntry.FindLast() then
            EntryNo := AuditEntry."Entry No." + 1
        else
            EntryNo := 1;

        AuditEntry.Init();
        AuditEntry."Entry No." := EntryNo;
        AuditEntry."Table No." := RecRef.Number();
        AuditEntry."Table Name" := CopyStr(RecRef.Caption() + ' (' + Method + ')', 1, 50);
        AuditEntry."Field Name" := CopyStr(FieldRef.Name(), 1, 50);
        AuditEntry."Field Value" := CopyStr(Format(FieldRef.Value()), 1, 250);
        AuditEntry."Processing Time" := Time() - StartTime;
        AuditEntry.Insert(true);
    end;
}
