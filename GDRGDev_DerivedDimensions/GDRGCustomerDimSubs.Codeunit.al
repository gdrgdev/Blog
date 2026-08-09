/// <summary>
/// Sample dimension rules for Sales Header.
/// </summary>
codeunit 88888 "GDRG Customer Dim Subs"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Salesperson/Purchaser" = R,
                  tabledata "Sales Invoice Header" = R;

    var
        DerivedDimMgt: Codeunit "GDRG Derived Dim Mgt.";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement,
        OnAfterGetRecDefaultDimIDProcedure, '', false, false)]
    local procedure InjectSalesHeaderDims(
        RecVariant: Variant;
        CurrFieldNo: Integer;
        var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        var SourceCode: Code[20];
        var InheritFromDimSetID: Integer;
        var InheritFromTableNo: Integer;
        var GlobalDim1Code: Code[20];
        var GlobalDim2Code: Code[20];
        var DefaultDimSetID: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if not RecVariant.IsRecord() then
            exit;

        if not TryGetSalesHeader(RecVariant, SalesHeader) then
            exit;

        if SalesHeader."Sell-to Customer No." = '' then
            exit;

        HandlePaymentMethodTrigger(SalesHeader, CurrFieldNo, DefaultDimSetID);
        HandleSalespersonTrigger(SalesHeader, CurrFieldNo, DefaultDimSetID);
        HandleCustomerTrigger(SalesHeader, CurrFieldNo, DefaultDimSetID);
    end;

    [TryFunction]
    local procedure TryGetSalesHeader(RecVariant: Variant; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader := RecVariant;
    end;

    local procedure HandlePaymentMethodTrigger(SalesHeader: Record "Sales Header"; CurrFieldNo: Integer; var DefaultDimSetID: Integer)
    begin
        if CurrFieldNo <> SalesHeader.FieldNo("Payment Method Code") then
            exit;

        DeriveDimensionFromFieldValueFromCurrRecord(SalesHeader, DefaultDimSetID);
        DeriveDimensionFromAnotherDimension(DefaultDimSetID);
        OverrideDerivedDimension(SalesHeader, DefaultDimSetID);
    end;

    local procedure HandleSalespersonTrigger(SalesHeader: Record "Sales Header"; CurrFieldNo: Integer; var DefaultDimSetID: Integer)
    begin
        if CurrFieldNo <> SalesHeader.FieldNo("Salesperson Code") then
            exit;

        DeriveDimensionFromRelatedTable(SalesHeader, DefaultDimSetID);
    end;

    local procedure HandleCustomerTrigger(SalesHeader: Record "Sales Header"; CurrFieldNo: Integer; var DefaultDimSetID: Integer)
    begin
        if CurrFieldNo <> SalesHeader.FieldNo("Sell-to Customer No.") then
            exit;

        DeriveDimensionFromHistoricalData(SalesHeader, DefaultDimSetID);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, "Payment Method Code", false, false)]
    local procedure ForceRecreateDimsAfterValidatePaymentMethodCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."Payment Method Code" = xRec."Payment Method Code" then
            exit;
        ForceRecreateDimensionsFromField(Rec, xRec, Rec.FieldNo("Payment Method Code"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, "Currency Code", false, false)]
    local procedure ForceRecreateDimsAfterValidateCurrencyCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
    end;

    local procedure DeriveDimensionFromFieldValueFromCurrRecord(SalesHeader: Record "Sales Header"; var DefaultDimSetID: Integer)
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if SalesHeader."Payment Method Code" = '' then
            exit;

        case SalesHeader."Payment Method Code" of
            'BANK':
                DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_CHANNEL', 'ONLINE', 'Online');
            'CASH':
                DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_CHANNEL', 'STORE', 'Store');
            else
                DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_CHANNEL', 'OTHER', 'Other');
        end;

        DerivedDimMgt.CommitStagedDims(DefaultDimSetID, TempDimSetEntry);
    end;

    local procedure DeriveDimensionFromAnotherDimension(var DefaultDimSetID: Integer)
    var
        TempCurrentDimSetEntry: Record "Dimension Set Entry" temporary;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.GetDimensionSet(TempCurrentDimSetEntry, DefaultDimSetID);
        if not TempCurrentDimSetEntry.Get(DefaultDimSetID, 'GR_CHANNEL') then
            exit;
        if TempCurrentDimSetEntry."Dimension Value Code" <> 'ONLINE' then
            exit;

        DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_PRIORITY', 'HIGH', 'High Priority');
        DerivedDimMgt.CommitStagedDims(DefaultDimSetID, TempDimSetEntry);
    end;

    local procedure DeriveDimensionFromRelatedTable(SalesHeader: Record "Sales Header"; var DefaultDimSetID: Integer)
    var
        Salesperson: Record "Salesperson/Purchaser";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if SalesHeader."Salesperson Code" = '' then
            exit;
        if not Salesperson.Get(SalesHeader."Salesperson Code") then
            exit;

        if Salesperson."Commission %" >= 10 then
            DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_COMMTIER', 'HIGH', 'High Commission')
        else
            DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_COMMTIER', 'STD', 'Standard Commission');

        DerivedDimMgt.CommitStagedDims(DefaultDimSetID, TempDimSetEntry);
    end;

    local procedure DeriveDimensionFromHistoricalData(SalesHeader: Record "Sales Header"; var DefaultDimSetID: Integer)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        if SalesInvoiceHeader.IsEmpty() then
            DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_DOCTYPE', 'NEW', 'New Customer')
        else
            DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_DOCTYPE', 'REPEAT', 'Repeat Customer');

        DerivedDimMgt.CommitStagedDims(DefaultDimSetID, TempDimSetEntry);
    end;

    local procedure OverrideDerivedDimension(SalesHeader: Record "Sales Header"; var DefaultDimSetID: Integer)
    var
        Salesperson: Record "Salesperson/Purchaser";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if SalesHeader."Salesperson Code" = '' then
            exit;
        if not Salesperson.Get(SalesHeader."Salesperson Code") then
            exit;
        if Salesperson."Commission %" < 10 then
            exit;

        DerivedDimMgt.StageDim(TempDimSetEntry, 'GR_CHANNEL', 'VIP', 'VIP Salesperson');
        DerivedDimMgt.CommitStagedDims(DefaultDimSetID, TempDimSetEntry);
    end;

    local procedure ForceRecreateDimensionsFromField(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; TriggerFieldNo: Integer)
    begin
        if SalesHeader.IsTemporary() then
            exit;
        if SalesHeader."No." = '' then
            exit;
        if SalesHeader."Sell-to Customer No." = '' then
            exit;
        if SalesHeader."Dimension Set ID" <> xSalesHeader."Dimension Set ID" then
            exit;

        SalesHeader.CreateDimFromDefaultDim(TriggerFieldNo);
    end;
}
