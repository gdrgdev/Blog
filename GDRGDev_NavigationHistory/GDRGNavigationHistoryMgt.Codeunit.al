codeunit 50107 "GDRG Navigation History Mgt."
{

    Permissions =
        tabledata "GDRG Navigation History" = RIMD;

    #region Customer

    [EventSubscriber(ObjectType::Page, Page::"Customer List", OnOpenPageEvent, '', false, false)]
    local procedure TrackCustomerList()
    begin
        LogListVisit(Database::Customer, Page::"Customer List", 'Customers');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", OnAfterGetCurrRecordEvent, '', false, false)]
    local procedure TrackCustomerCard(var Rec: Record Customer)
    begin
        if Rec."No." <> '' then
            LogRecordVisit(Database::Customer, Rec.RecordId(), Page::"Customer Card", Rec."No.", Rec.Name);
    end;

    #endregion

    #region Vendor

    [EventSubscriber(ObjectType::Page, Page::"Vendor List", OnOpenPageEvent, '', false, false)]
    local procedure TrackVendorList()
    begin
        LogListVisit(Database::Vendor, Page::"Vendor List", 'Vendors');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", OnAfterGetCurrRecordEvent, '', false, false)]
    local procedure TrackVendorCard(var Rec: Record Vendor)
    begin
        if Rec."No." <> '' then
            LogRecordVisit(Database::Vendor, Rec.RecordId(), Page::"Vendor Card", Rec."No.", Rec.Name);
    end;

    #endregion

    #region Item

    [EventSubscriber(ObjectType::Page, Page::"Item List", OnOpenPageEvent, '', false, false)]
    local procedure TrackItemList()
    begin
        LogListVisit(Database::Item, Page::"Item List", 'Items');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Card", OnAfterGetCurrRecordEvent, '', false, false)]
    local procedure TrackItemCard(var Rec: Record Item)
    begin
        if Rec."No." <> '' then
            LogRecordVisit(Database::Item, Rec.RecordId(), Page::"Item Card", Rec."No.", Rec.Description);
    end;

    #endregion

    #region G/L Account

    [EventSubscriber(ObjectType::Page, Page::"Chart of Accounts", OnOpenPageEvent, '', false, false)]
    local procedure TrackChartOfAccounts()
    begin
        LogListVisit(Database::"G/L Account", Page::"Chart of Accounts", 'Chart of Accounts');
    end;

    [EventSubscriber(ObjectType::Page, Page::"G/L Account Card", OnAfterGetCurrRecordEvent, '', false, false)]
    local procedure TrackGLAccountCard(var Rec: Record "G/L Account")
    begin
        if Rec."No." <> '' then
            LogRecordVisit(Database::"G/L Account", Rec.RecordId(), Page::"G/L Account Card", Rec."No.", Rec.Name);
    end;

    #endregion

    #region Sales

    [EventSubscriber(ObjectType::Page, Page::"Sales Order List", OnOpenPageEvent, '', false, false)]
    local procedure TrackSalesOrderList()
    begin
        LogListVisit(Database::"Sales Header", Page::"Sales Order List", 'Sales Orders');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", OnAfterGetCurrRecordEvent, '', false, false)]
    local procedure TrackSalesOrder(var Rec: Record "Sales Header")
    begin
        if Rec."No." <> '' then
            LogRecordVisit(Database::"Sales Header", Rec.RecordId(), Page::"Sales Order", Rec."No.", Rec."Sell-to Customer Name");
    end;

    #endregion

    #region Purchase

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", OnOpenPageEvent, '', false, false)]
    local procedure TrackPurchaseOrderList()
    begin
        LogListVisit(Database::"Purchase Header", Page::"Purchase Order List", 'Purchase Orders');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", OnAfterGetCurrRecordEvent, '', false, false)]
    local procedure TrackPurchaseOrder(var Rec: Record "Purchase Header")
    begin
        if Rec."No." <> '' then
            LogRecordVisit(Database::"Purchase Header", Rec.RecordId(), Page::"Purchase Order", Rec."No.", Rec."Buy-from Vendor Name");
    end;

    #endregion

    #region Helper Methods

    #endregion

    #region Helper Methods

    procedure LogListVisit(TableID: Integer; PageID: Integer; Description: Text[100])
    var
        RecentEntry: Record "GDRG Navigation History";
    begin
        CreateEntry(RecentEntry, TableID, PageID, Description);
        RecentEntry."Entry Type" := RecentEntry."Entry Type"::List;
        RecentEntry.Insert(false);
    end;

    procedure LogRecordVisit(TableID: Integer; RecID: RecordId; PageID: Integer; RecNo: Code[20]; RecName: Text[100])
    var
        RecentEntry: Record "GDRG Navigation History";
    begin
        CreateEntry(RecentEntry, TableID, PageID, CopyStr(RecNo + ' - ' + RecName, 1, 100));
        RecentEntry."Entry Type" := RecentEntry."Entry Type"::Card;
        RecentEntry."Record ID" := RecID;
        RecentEntry.Insert(false);
    end;

    local procedure CreateEntry(var RecentEntry: Record "GDRG Navigation History"; TableID: Integer; PageID: Integer; Description: Text[100])
    begin
        RecentEntry.Init();
        RecentEntry."User ID" := CopyStr(UserId(), 1, 50);
        RecentEntry."Table ID" := TableID;
        RecentEntry."Page ID" := PageID;
        RecentEntry.Description := Description;
        RecentEntry."Visited DateTime" := CurrentDateTime();
    end;

    #endregion
}
