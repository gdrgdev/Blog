codeunit 50102 "ICS Business Helper"
{
    Permissions = tabledata "Customer" = R,
    tabledata "User Setup" = R;
    procedure BuildCustomerEvent(Customer: Record Customer): Boolean
    var
        TempEventBuffer: Record "ICS Event Data Buffer" temporary;
        AssistEditManager: Codeunit "ICS Assist Edit Manager";
        MeetingTitleLbl: Label 'Meeting - %1', Comment = '%1 = Customer Name';
        MeetingDescLbl: Label 'Meeting with customer %1 (%2)', Comment = '%1 = Customer Name, %2 = Customer No.';
    begin
        TempEventBuffer.Init();
        TempEventBuffer."Entry No." := 1;
        TempEventBuffer.SetDefaults();

        TempEventBuffer.Summary := CopyStr(StrSubstNo(MeetingTitleLbl, Customer.Name), 1, MaxStrLen(TempEventBuffer.Summary));
        TempEventBuffer.Description := CopyStr(StrSubstNo(MeetingDescLbl, Customer.Name, Customer."No."), 1, MaxStrLen(TempEventBuffer.Description));
        TempEventBuffer.Location := CopyStr(Customer.Address, 1, MaxStrLen(TempEventBuffer.Location));
        TempEventBuffer.Organizer := CopyStr(GetCurrentUserEmail(), 1, MaxStrLen(TempEventBuffer.Organizer));
        TempEventBuffer.Priority := GetDefaultMeetingPriority();

        TempEventBuffer."Start DateTime" := CreateDateTime(Today(), 090000T);
        TempEventBuffer."End DateTime" := CreateDateTime(Today(), 100000T);

        TempEventBuffer.Insert(false);

        if AssistEditManager.OpenEventConfigPage(TempEventBuffer) then begin
            if not AssistEditManager.GenerateAndDownloadICS(TempEventBuffer) then
                exit(false);
            exit(true);
        end;

        exit(false);
    end;

    procedure BuildSalesPostingEvent(SalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
        TempEventBuffer: Record "ICS Event Data Buffer" temporary;
        AssistEditManager: Codeunit "ICS Assist Edit Manager";
        PostingTitleLbl: Label 'Posting - Order %1', Comment = '%1 = Sales Order No.';
        PostingDescLbl: Label 'Process posting for order %1', Comment = '%1 = Order No.';
        CustomerNotFoundErr: Label 'Customer %1 not found.', Comment = '%1 = Customer No.';
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            Error(CustomerNotFoundErr, SalesHeader."Sell-to Customer No.");

        TempEventBuffer.Init();
        TempEventBuffer."Entry No." := 1;
        TempEventBuffer.SetDefaults();

        TempEventBuffer.Summary := CopyStr(StrSubstNo(PostingTitleLbl, SalesHeader."No."), 1, MaxStrLen(TempEventBuffer.Summary));
        TempEventBuffer.Description := CopyStr(StrSubstNo(PostingDescLbl, SalesHeader."No."), 1, MaxStrLen(TempEventBuffer.Description));
        TempEventBuffer.Location := 'Administrative Office';
        TempEventBuffer.Organizer := CopyStr(GetCurrentUserEmail(), 1, MaxStrLen(TempEventBuffer.Organizer));
        TempEventBuffer.Priority := GetDefaultAdministrativePriority();

        if SalesHeader."Posting Date" <> 0D then begin
            TempEventBuffer."Start DateTime" := CreateDateTime(SalesHeader."Posting Date", 090000T);
            TempEventBuffer."End DateTime" := CreateDateTime(SalesHeader."Posting Date", 100000T);
        end else begin
            TempEventBuffer."Start DateTime" := CreateDateTime(Today(), 090000T);
            TempEventBuffer."End DateTime" := CreateDateTime(Today(), 100000T);
        end;

        TempEventBuffer.Insert(false);

        if AssistEditManager.OpenEventConfigPage(TempEventBuffer) then begin
            if not AssistEditManager.GenerateAndDownloadICS(TempEventBuffer) then
                exit(false);
            exit(true);
        end;

        exit(false);
    end;

    procedure BuildSalesShipmentEvent(SalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
        TempEventBuffer: Record "ICS Event Data Buffer" temporary;
        AssistEditManager: Codeunit "ICS Assist Edit Manager";
        ShipmentTitleLbl: Label 'Shipment - Order %1', Comment = '%1 = Sales Order No.';
        ShipmentDescLbl: Label 'Delivery for order %1', Comment = '%1 = Order No.';
        AddressLbl: Label '%1, %2 %3', Comment = '%1 = Address, %2 = Post Code, %3 = City';
        CustomerNotFoundErr: Label 'Customer %1 not found.', Comment = '%1 = Customer No.';
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            Error(CustomerNotFoundErr, SalesHeader."Sell-to Customer No.");

        TempEventBuffer.Init();
        TempEventBuffer."Entry No." := 1;
        TempEventBuffer.SetDefaults();

        TempEventBuffer.Summary := CopyStr(StrSubstNo(ShipmentTitleLbl, SalesHeader."No."), 1, MaxStrLen(TempEventBuffer.Summary));
        TempEventBuffer.Description := CopyStr(StrSubstNo(ShipmentDescLbl, SalesHeader."No."), 1, MaxStrLen(TempEventBuffer.Description));

        if SalesHeader."Ship-to Address" <> '' then
            TempEventBuffer.Location := CopyStr(StrSubstNo(AddressLbl, SalesHeader."Ship-to Address",
                SalesHeader."Ship-to Post Code", SalesHeader."Ship-to City"), 1, MaxStrLen(TempEventBuffer.Location))
        else
            TempEventBuffer.Location := CopyStr(Customer.Address, 1, MaxStrLen(TempEventBuffer.Location));

        TempEventBuffer.Organizer := CopyStr(GetCurrentUserEmail(), 1, MaxStrLen(TempEventBuffer.Organizer));
        TempEventBuffer.Priority := GetDefaultLogisticsPriority();

        if SalesHeader."Shipment Date" <> 0D then begin
            TempEventBuffer."Start DateTime" := CreateDateTime(SalesHeader."Shipment Date", 100000T);
            TempEventBuffer."End DateTime" := CreateDateTime(SalesHeader."Shipment Date", 120000T);
        end else begin
            TempEventBuffer."Start DateTime" := CreateDateTime(Today(), 100000T);
            TempEventBuffer."End DateTime" := CreateDateTime(Today(), 120000T);
        end;

        TempEventBuffer.Insert(false);

        if AssistEditManager.OpenEventConfigPage(TempEventBuffer) then begin
            if not AssistEditManager.GenerateAndDownloadICS(TempEventBuffer) then
                exit(false);
            exit(true);
        end;

        exit(false);
    end;

    local procedure GetCurrentUserEmail(): Text[100]
    var
        UserSetup: Record "User Setup";
        User: Record User;
    begin
        if UserSetup.Get(UserId()) and (UserSetup."E-Mail" <> '') then
            exit(CopyStr(UserSetup."E-Mail", 1, 100));

        if User.Get(UserSecurityId()) and (User."Contact Email" <> '') then
            exit(CopyStr(User."Contact Email", 1, 100));

        exit(CopyStr(UserId() + '@company.com', 1, 100));
    end;

    local procedure GetDefaultMeetingPriority(): Integer
    begin
        exit(5);
    end;

    local procedure GetDefaultAdministrativePriority(): Integer
    begin
        exit(3);
    end;

    local procedure GetDefaultLogisticsPriority(): Integer
    begin
        exit(4);
    end;
}
