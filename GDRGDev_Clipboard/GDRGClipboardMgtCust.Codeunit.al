codeunit 88000 "GDRG Clipboard Mgt. Cust."
{
    Permissions = tabledata Customer = R,
                  tabledata "Customer Bank Account" = R;

    procedure CopyCustomerInfo(Customer: Record Customer)
    var
        contactInfo: Text;
        bankInfo: Text;
    begin
        contactInfo := FormatCustomerContactInfo(Customer);
        bankInfo := FormatCustomerBankInfo(Customer);
        ShowClipboardDialog(contactInfo, bankInfo);
    end;

    local procedure FormatCustomerContactInfo(Customer: Record Customer): Text
    var
        formattedText: TextBuilder;
        customerLbl: Label 'Customer';
    begin
        formattedText.AppendLine('---------------------------------------------');
        formattedText.AppendLine('CONTACT INFORMATION');
        formattedText.AppendLine('---------------------------------------------');
        formattedText.AppendLine(customerLbl + ': ' + Customer."No." + ' - ' + Customer.Name);
        AppendContactDetails(Customer, formattedText);
        AppendCustomerBalance(Customer, formattedText);
        formattedText.Append('---------------------------------------------');
        exit(formattedText.ToText());
    end;

    local procedure AppendContactDetails(Customer: Record Customer; var formattedText: TextBuilder)
    var
        contactLbl: Label 'Contact';
        phoneLbl: Label 'Phone';
        emailLbl: Label 'Email';
        vatRegNoLbl: Label 'VAT Registration No.';
    begin
        if Customer.Contact <> '' then
            formattedText.AppendLine(contactLbl + ': ' + Customer.Contact);

        if Customer."Phone No." <> '' then
            formattedText.AppendLine(phoneLbl + ': ' + Customer."Phone No.");

        if Customer."E-Mail" <> '' then
            formattedText.AppendLine(emailLbl + ': ' + Customer."E-Mail");

        AppendAddress(Customer, formattedText);
        AppendCity(Customer, formattedText);

        if Customer."VAT Registration No." <> '' then
            formattedText.AppendLine(vatRegNoLbl + ': ' + Customer."VAT Registration No.");
    end;

    local procedure AppendAddress(Customer: Record Customer; var formattedText: TextBuilder)
    var
        addressLbl: Label 'Address';
    begin
        if Customer.Address = '' then
            exit;

        formattedText.AppendLine(addressLbl + ': ' + Customer.Address);
        if Customer."Address 2" <> '' then
            formattedText.AppendLine('         ' + Customer."Address 2");
    end;

    local procedure AppendCity(Customer: Record Customer; var formattedText: TextBuilder)
    var
        cityLbl: Label 'City';
    begin
        if (Customer.City <> '') or (Customer."Post Code" <> '') then
            formattedText.AppendLine(cityLbl + ': ' + Customer."Post Code" + ' ' + Customer.City);
    end;

    local procedure AppendCustomerBalance(var Customer: Record Customer; var formattedText: TextBuilder)
    var
        balanceLbl: Label 'Balance ($)';
        overdueBalanceLbl: Label 'Overdue Balance ($)';
    begin
        Customer.SetRange("Date Filter", 0D, Today());
        Customer.CalcFields("Balance (LCY)", "Balance Due (LCY)");
        formattedText.AppendLine(balanceLbl + ': ' + Format(Customer."Balance (LCY)", 0, '<Precision,2:2><Standard Format,0>'));
        formattedText.AppendLine(overdueBalanceLbl + ': ' + Format(Customer."Balance Due (LCY)", 0, '<Precision,2:2><Standard Format,0>'));
    end;

    local procedure FormatCustomerBankInfo(Customer: Record Customer): Text
    var
        custBankAccount: Record "Customer Bank Account";
        formattedText: TextBuilder;
    begin
        formattedText.AppendLine('---------------------------------------------');
        formattedText.AppendLine('BANK INFORMATION');
        formattedText.AppendLine('---------------------------------------------');
        AppendPaymentTerms(Customer, formattedText);
        formattedText.AppendLine('');
        AppendBankAccountDetails(Customer, custBankAccount, formattedText);
        formattedText.Append('---------------------------------------------');
        exit(formattedText.ToText());
    end;

    local procedure AppendPaymentTerms(Customer: Record Customer; var formattedText: TextBuilder)
    var
        paymentTermsLbl: Label 'Payment Terms Code';
        paymentMethodLbl: Label 'Payment Method Code';
    begin
        if Customer."Payment Terms Code" <> '' then
            formattedText.AppendLine(paymentTermsLbl + ': ' + Customer."Payment Terms Code");

        if Customer."Payment Method Code" <> '' then
            formattedText.AppendLine(paymentMethodLbl + ': ' + Customer."Payment Method Code");
    end;

    local procedure AppendBankAccountDetails(Customer: Record Customer; var custBankAccount: Record "Customer Bank Account"; var formattedText: TextBuilder)
    begin
        if Customer."Preferred Bank Account Code" = '' then begin
            formattedText.AppendLine('No bank account configured');
            exit;
        end;

        if not custBankAccount.Get(Customer."No.", Customer."Preferred Bank Account Code") then
            exit;

        AppendBankFields(custBankAccount, formattedText);
    end;

    local procedure AppendBankFields(custBankAccount: Record "Customer Bank Account"; var formattedText: TextBuilder)
    var
        bankNameLbl: Label 'Bank Name';
        bankAccountLbl: Label 'Bank Account No.';
        bankBranchLbl: Label 'Bank Branch No.';
        ibanLbl: Label 'IBAN';
        swiftLbl: Label 'SWIFT Code';
    begin
        if custBankAccount.Name <> '' then
            formattedText.AppendLine(bankNameLbl + ': ' + custBankAccount.Name);

        if custBankAccount."Bank Account No." <> '' then
            formattedText.AppendLine(bankAccountLbl + ': ' + custBankAccount."Bank Account No.");

        if custBankAccount."Bank Branch No." <> '' then
            formattedText.AppendLine(bankBranchLbl + ': ' + custBankAccount."Bank Branch No.");

        if custBankAccount.IBAN <> '' then
            formattedText.AppendLine(ibanLbl + ': ' + custBankAccount.IBAN);

        if custBankAccount."SWIFT Code" <> '' then
            formattedText.AppendLine(swiftLbl + ': ' + custBankAccount."SWIFT Code");
    end;

    local procedure ShowClipboardDialog(contactInfo: Text; bankInfo: Text)
    var
        clipboardPage: Page "GDRG Clipboard Helper";
    begin
        clipboardPage.SetCaption('Customer Information');
        clipboardPage.SetCustomerData(contactInfo, bankInfo);
        clipboardPage.RunModal();
    end;
}
