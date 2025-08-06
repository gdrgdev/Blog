codeunit 50102 "GDRG Achievement Events"
{
    Permissions = tabledata "GDRG User Achievement Profile" = RIMD;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterCustomerInsert(var Rec: Record Customer; RunTrigger: Boolean)
    var
        Processor: Codeunit "GDRG Achievement Processor";
        TriggerDetailsMsg: Label 'Customer %1 created', Comment = '%1 = Customer Number';
    begin
        if not RunTrigger then exit;

        Processor.ProcessUserAction(
            CopyStr(UserId(), 1, 50),
            "GDRG Achievement Trigger Type"::"Customer Created",
            1,
            StrSubstNo(TriggerDetailsMsg, Rec."No.")
        );
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        Processor: Codeunit "GDRG Achievement Processor";
        SalesOrderMsg: Label 'Sales Order %1 posted', Comment = '%1 = Sales Order Number';
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then exit;

        Processor.ProcessUserAction(
            CopyStr(UserId(), 1, 50),
            "GDRG Achievement Trigger Type"::"Sales Order Posted",
            1,
            StrSubstNo(SalesOrderMsg, SalesHeader."No.")
        );

        Processor.ProcessBigDealAchievement(SalesHeader."No.", SalesInvHdrNo, CopyStr(UserId(), 1, 50));
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterItemInsert(var Rec: Record Item; RunTrigger: Boolean)
    var
        Processor: Codeunit "GDRG Achievement Processor";
        ItemCreatedMsg: Label 'Item %1 created', Comment = '%1 = Item Number';
    begin
        if not RunTrigger then exit;

        Processor.ProcessUserAction(
            CopyStr(UserId(), 1, 50),
            "GDRG Achievement Trigger Type"::"Item Created",
            1,
            StrSubstNo(ItemCreatedMsg, Rec."No.")
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterVendorInsert(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        Processor: Codeunit "GDRG Achievement Processor";
        VendorCreatedMsg: Label 'Vendor %1 created', Comment = '%1 = Vendor Number';
    begin
        if not RunTrigger then exit;

        Processor.ProcessUserAction(
            CopyStr(UserId(), 1, 50),
            "GDRG Achievement Trigger Type"::"Vendor Created",
            1,
            StrSubstNo(VendorCreatedMsg, Rec."No.")
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterContactInsert(var Rec: Record Contact; RunTrigger: Boolean)
    var
        Processor: Codeunit "GDRG Achievement Processor";
        ContactCreatedMsg: Label 'Contact %1 created', Comment = '%1 = Contact Number';
    begin
        if not RunTrigger then exit;

        Processor.ProcessUserAction(
            CopyStr(UserId(), 1, 50),
            "GDRG Achievement Trigger Type"::"Contact Created",
            1,
            StrSubstNo(ContactCreatedMsg, Rec."No.")
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterSalesQuoteInsert(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        Processor: Codeunit "GDRG Achievement Processor";
        QuoteCreatedMsg: Label 'Quote %1 created', Comment = '%1 = Quote Number';
    begin
        if not RunTrigger then exit;
        if Rec."Document Type" <> Rec."Document Type"::Quote then exit;

        Processor.ProcessUserAction(
            CopyStr(UserId(), 1, 50),
            "GDRG Achievement Trigger Type"::"Quote Created",
            1,
            StrSubstNo(QuoteCreatedMsg, Rec."No.")
        );
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPostPurchaseDoc, '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        Processor: Codeunit "GDRG Achievement Processor";
        PurchOrderMsg: Label 'Purchase Order %1 posted', Comment = '%1 = Purchase Order Number';
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then exit;

        Processor.ProcessUserAction(
            CopyStr(UserId(), 1, 50),
            "GDRG Achievement Trigger Type"::"Purchase Order Posted",
            1,
            StrSubstNo(PurchOrderMsg, PurchaseHeader."No.")
        );
    end;

    [EventSubscriber(ObjectType::Page, Page::"GDRG Gaming Dashboard", OnOpenPageEvent, '', false, false)]
    local procedure OnGamingDashboardOpen()
    var
        UserProfile: Record "GDRG User Achievement Profile";
        CurrentUserID: Code[50];
    begin
        CurrentUserID := CopyStr(UserId(), 1, 50);

        if not UserProfile.Get(CurrentUserID) then
            CreateUserProfile(CurrentUserID);
    end;

    local procedure CreateUserProfile(UserID: Code[50])
    var
        UserProfile: Record "GDRG User Achievement Profile";
    begin
        UserProfile.Init();
        UserProfile."User ID" := UserID;
        UserProfile."Current Level" := 1;
        UserProfile.Insert(false);
    end;
}