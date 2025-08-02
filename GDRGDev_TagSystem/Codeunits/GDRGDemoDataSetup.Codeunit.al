codeunit 50101 "GDRG Demo Data Setup"
{
    Permissions = tabledata "GDRG Personal Tag Assignment" = RIMD,
                 tabledata "GDRG Personal Tag Master" = RIMD,
                 tabledata Customer = R,
                 tabledata Vendor = R,
                 tabledata "Sales Header" = R;

    procedure InitializeDemoData()
    begin
        ClearExistingData();
        CreateMasterTags();
        AssignRandomTags();
    end;

    procedure ClearExistingData()
    var
        PersonalTagAssignment: Record "GDRG Personal Tag Assignment";
        PersonalTagMaster: Record "GDRG Personal Tag Master";
        CurrentUser: Code[50];
    begin
        CurrentUser := CopyStr(UserId(), 1, 50);

        // Clear existing assignments for current user
        PersonalTagAssignment.SetRange("User ID", CurrentUser);
        PersonalTagAssignment.DeleteAll(true);

        // Clear existing master tags for current user
        PersonalTagMaster.SetRange("User ID", CurrentUser);
        PersonalTagMaster.DeleteAll(true);
    end;

    procedure CreateMasterTags()
    begin
        // Create demo tags
        CreateTag('PRIORITY', 'High Priority', "GDRG Color"::Red, 'Records that require immediate attention and high priority handling.');
        CreateTag('VIP', 'VIP Client', "GDRG Color"::Yellow, 'Very important clients that receive premium service and special treatment.');
        CreateTag('PROSPECT', 'Potential Client', "GDRG Color"::Green, 'Prospective customers with high potential for business conversion.');
        CreateTag('FOLLOW', 'Follow Up Required', "GDRG Color"::Orange, 'Records that need follow-up actions or pending responses.');
        CreateTag('STRATEGIC', 'Strategic Partner', "GDRG Color"::Blue, 'Key strategic partners critical for business growth and development.');
        CreateTag('REVIEW', 'Under Review', "GDRG Color"::Purple, 'Records currently under review or pending approval processes.');
    end;

    local procedure CreateTag(TagCode: Code[20]; TagName: Text[50]; TagColor: Enum "GDRG Color"; Description: Text[100])
    var
        PersonalTagMaster: Record "GDRG Personal Tag Master";
        CurrentUser: Code[50];
    begin
        CurrentUser := CopyStr(UserId(), 1, 50);

        PersonalTagMaster.Init();
        PersonalTagMaster."User ID" := CurrentUser;
        PersonalTagMaster.Code := TagCode;
        PersonalTagMaster.Name := TagName;
        PersonalTagMaster.Color := TagColor;
        PersonalTagMaster.Description := Description;
        PersonalTagMaster.Insert(true);
    end;

    procedure AssignRandomTags()
    begin
        // Initialize random seed
        Randomize();

        AssignTagsToCustomers();
        AssignTagsToVendors();
        AssignTagsToSalesOrders();
    end;

    local procedure AssignTagsToCustomers()
    var
        Customer: Record Customer;
        PersonalTagMgr: Codeunit "GDRG Personal Tag Manager";
        TagCodes: List of [Code[20]];
        i: Integer;
        TagCount: Integer;
    begin
        // Get available tags from master table
        GetAvailableTagCodes(TagCodes);

        if TagCodes.Count() = 0 then
            exit; // No tags available

        // Get first 15 customers
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        if Customer.FindSet() then begin
            i := 0;
            repeat
                i += 1;
                // Assign 1-3 random tags per customer
                TagCount := 1 + Random(3); // Random between 1-3
                AssignRandomTagsToRecord(Customer, TagCodes, TagCount, PersonalTagMgr);
            until (Customer.Next() = 0) or (i >= 15);
        end;
    end;

    local procedure AssignTagsToVendors()
    var
        Vendor: Record Vendor;
        PersonalTagMgr: Codeunit "GDRG Personal Tag Manager";
        TagCodes: List of [Code[20]];
        i: Integer;
        TagCount: Integer;
    begin
        // Get available tags from master table
        GetAvailableTagCodes(TagCodes);

        if TagCodes.Count() = 0 then
            exit; // No tags available

        // Get first 15 vendors
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        if Vendor.FindSet() then begin
            i := 0;
            repeat
                i += 1;
                // Assign 1-3 random tags per vendor
                TagCount := 1 + Random(3); // Random between 1-3
                AssignRandomTagsToRecord(Vendor, TagCodes, TagCount, PersonalTagMgr);
            until (Vendor.Next() = 0) or (i >= 15);
        end;
    end;

    local procedure AssignTagsToSalesOrders()
    var
        SalesHeader: Record "Sales Header";
        PersonalTagMgr: Codeunit "GDRG Personal Tag Manager";
        TagCodes: List of [Code[20]];
        i: Integer;
        TagCount: Integer;
    begin
        // Get available tags from master table
        GetAvailableTagCodes(TagCodes);

        if TagCodes.Count() = 0 then
            exit; // No tags available

        // Get first 10 sales orders
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindSet() then begin
            i := 0;
            repeat
                i += 1;
                // Assign 1-3 random tags per sales order
                TagCount := 1 + Random(3); // Random between 1-3
                AssignRandomTagsToRecord(SalesHeader, TagCodes, TagCount, PersonalTagMgr);
            until (SalesHeader.Next() = 0) or (i >= 10);
        end;
    end;

    local procedure AssignRandomTagsToRecord(RecordVariant: Variant; var TagCodes: List of [Code[20]]; TagCount: Integer; var PersonalTagMgr: Codeunit "GDRG Personal Tag Manager")
    var
        UsedTags: List of [Code[20]];
        SelectedTag: Code[20];
        i: Integer;
    begin
        // Validate input - ensure we have tags to work with
        if (TagCodes.Count() = 0) or (TagCount <= 0) then
            exit;

        for i := 1 to TagCount do begin
            SelectedTag := GetRandomUnusedTag(TagCodes, UsedTags);
            if SelectedTag <> '' then begin
                PersonalTagMgr.AddTag(RecordVariant, SelectedTag);
                UsedTags.Add(SelectedTag);
            end;
        end;
    end;

    local procedure GetRandomUnusedTag(var TagCodes: List of [Code[20]]; var UsedTags: List of [Code[20]]): Code[20]
    var
        RandomIndex: Integer;
        SelectedTag: Code[20];
        AttemptCount: Integer;
        MaxAttempts: Integer;
    begin
        MaxAttempts := 50;
        AttemptCount := 0;

        if TagCodes.Count() = 0 then
            exit('');

        repeat
            AttemptCount += 1;
            if TagCodes.Count() > 0 then begin
                RandomIndex := Random(TagCodes.Count());
                SelectedTag := TagCodes.Get(RandomIndex);
            end else
                exit('');
        until (not UsedTags.Contains(SelectedTag)) or (AttemptCount >= MaxAttempts);

        if AttemptCount >= MaxAttempts then
            exit('');

        exit(SelectedTag);
    end;

    local procedure GetAvailableTagCodes(var TagCodes: List of [Code[20]])
    var
        PersonalTagMaster: Record "GDRG Personal Tag Master";
        CurrentUser: Code[50];
    begin
        // Clear existing list safely
        if TagCodes.Count() > 0 then
            TagCodes.RemoveRange(1, TagCodes.Count());

        CurrentUser := CopyStr(UserId(), 1, 50);

        PersonalTagMaster.SetRange("User ID", CurrentUser);
        if PersonalTagMaster.FindSet() then
            repeat
                TagCodes.Add(PersonalTagMaster.Code);
            until PersonalTagMaster.Next() = 0;
    end;
}
