codeunit 88002 "GDRG Clipboard Mgt. CustLedg"
{
    Permissions = tabledata "Cust. Ledger Entry" = R,
                  tabledata Customer = R,
                  tabledata "Customer Bank Account" = R;

    procedure CopyCustLedgerEntryInfo(CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        customer: Record Customer;
        transactionInfo: Text;
        customerInfo: Text;
    begin
        transactionInfo := FormatTransactionInfo(CustLedgerEntry);

        if customer.Get(CustLedgerEntry."Customer No.") then
            customerInfo := FormatCustomerContactInfo(customer)
        else
            customerInfo := 'Customer information not available';

        ShowClipboardDialog(transactionInfo, customerInfo);
    end;

    local procedure FormatTransactionInfo(CustLedgerEntry: Record "Cust. Ledger Entry"): Text
    var
        customer: Record Customer;
        formattedText: TextBuilder;
        customerLbl: Label 'Customer';
        cifLbl: Label 'CIF';
        documentTypeLbl: Label 'Document Type';
        documentNoLbl: Label 'Document No.';
        postingDateLbl: Label 'Posting Date';
        dueDateLbl: Label 'Due Date';
        externalDocNoLbl: Label 'External Document No.';
        descriptionLbl: Label 'Description';
        originalAmountLbl: Label 'Original Amount (LCY)';
        remainingAmountLbl: Label 'Remaining Amount (LCY)';
    begin
        formattedText.AppendLine('---------------------------------------------');
        formattedText.AppendLine('TRANSACTION INFORMATION');
        formattedText.AppendLine('---------------------------------------------');

        if customer.Get(CustLedgerEntry."Customer No.") then begin
            formattedText.AppendLine(customerLbl + ': ' + CustLedgerEntry."Customer No." + ' - ' + customer.Name);
            if customer."VAT Registration No." <> '' then
                formattedText.AppendLine(cifLbl + ': ' + customer."VAT Registration No.");
        end else
            formattedText.AppendLine(customerLbl + ': ' + CustLedgerEntry."Customer No.");

        formattedText.AppendLine('');
        formattedText.AppendLine(documentTypeLbl + ': ' + Format(CustLedgerEntry."Document Type"));
        formattedText.AppendLine(documentNoLbl + ': ' + CustLedgerEntry."Document No.");
        formattedText.AppendLine(postingDateLbl + ': ' + Format(CustLedgerEntry."Posting Date"));
        formattedText.AppendLine(dueDateLbl + ': ' + Format(CustLedgerEntry."Due Date"));

        if CustLedgerEntry."External Document No." <> '' then
            formattedText.AppendLine(externalDocNoLbl + ': ' + CustLedgerEntry."External Document No.");

        if CustLedgerEntry.Description <> '' then
            formattedText.AppendLine(descriptionLbl + ': ' + CustLedgerEntry.Description);

        formattedText.AppendLine('');
        CustLedgerEntry.CalcFields("Original Amt. (LCY)", "Remaining Amt. (LCY)");
        formattedText.AppendLine(originalAmountLbl + ': ' + Format(CustLedgerEntry."Original Amt. (LCY)", 0, '<Precision,2:2><Standard Format,0>'));
        formattedText.AppendLine(remainingAmountLbl + ': ' + Format(CustLedgerEntry."Remaining Amt. (LCY)", 0, '<Precision,2:2><Standard Format,0>'));

        formattedText.Append('---------------------------------------------');
        exit(formattedText.ToText());
    end;

    local procedure FormatCustomerContactInfo(customer: Record Customer): Text
    var
        formattedText: TextBuilder;
    begin
        formattedText.AppendLine('---------------------------------------------');
        formattedText.AppendLine('CUSTOMER INFORMATION');
        formattedText.AppendLine('---------------------------------------------');

        AppendCustomerContactDetails(customer, formattedText);
        AppendCustomerAddressInfo(customer, formattedText);
        AppendCustomerBalanceInfo(customer, formattedText);

        formattedText.Append('---------------------------------------------');
        exit(formattedText.ToText());
    end;

    local procedure AppendCustomerContactDetails(customer: Record Customer; var formattedText: TextBuilder)
    var
        contactLbl: Label 'Contact';
        phoneLbl: Label 'Phone';
        emailLbl: Label 'Email';
        vatRegNoLbl: Label 'VAT Registration No.';
    begin
        if customer.Contact <> '' then
            formattedText.AppendLine(contactLbl + ': ' + customer.Contact);

        if customer."Phone No." <> '' then
            formattedText.AppendLine(phoneLbl + ': ' + customer."Phone No.");

        if customer."E-Mail" <> '' then
            formattedText.AppendLine(emailLbl + ': ' + customer."E-Mail");

        if customer."VAT Registration No." <> '' then
            formattedText.AppendLine(vatRegNoLbl + ': ' + customer."VAT Registration No.");
    end;

    local procedure AppendCustomerAddressInfo(customer: Record Customer; var formattedText: TextBuilder)
    var
        addressLbl: Label 'Address';
        cityLbl: Label 'City';
    begin
        if customer.Address <> '' then begin
            formattedText.AppendLine(addressLbl + ': ' + customer.Address);
            if customer."Address 2" <> '' then
                formattedText.AppendLine('         ' + customer."Address 2");
        end;

        if (customer.City <> '') or (customer."Post Code" <> '') then
            formattedText.AppendLine(cityLbl + ': ' + customer."Post Code" + ' ' + customer.City);
    end;

    local procedure AppendCustomerBalanceInfo(var customer: Record Customer; var formattedText: TextBuilder)
    var
        balanceLbl: Label 'Balance ($)';
        overdueBalanceLbl: Label 'Overdue Balance ($)';
    begin
        formattedText.AppendLine('');
        customer.SetRange("Date Filter", 0D, Today());
        customer.CalcFields("Balance (LCY)", "Balance Due (LCY)");
        formattedText.AppendLine(balanceLbl + ': ' + Format(customer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,0>'));
        formattedText.AppendLine(overdueBalanceLbl + ': ' + Format(customer."Balance Due (LCY)", 0, '<Precision,2:2><Standard Format,0>'));
    end;

    local procedure ShowClipboardDialog(transactionInfo: Text; customerInfo: Text)
    var
        clipboardPage: Page "GDRG Clipboard Helper";
    begin
        clipboardPage.SetCaption('Customer Ledger Entry');
        clipboardPage.SetCustomerData(transactionInfo, customerInfo);
        clipboardPage.RunModal();
    end;
}
