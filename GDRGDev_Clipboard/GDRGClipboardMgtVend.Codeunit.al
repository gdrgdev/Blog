codeunit 88001 "GDRG Clipboard Mgt. Vend."
{
    Permissions = tabledata Vendor = R,
                  tabledata "Vendor Bank Account" = R;

    procedure CopyVendorInfo(Vendor: Record Vendor)
    var
        contactInfo: Text;
        paymentInfo: Text;
    begin
        contactInfo := FormatVendorContactInfo(Vendor);
        paymentInfo := FormatVendorPaymentInfo(Vendor);
        ShowClipboardDialog(contactInfo, paymentInfo);
    end;

    local procedure FormatVendorContactInfo(Vendor: Record Vendor): Text
    var
        formattedText: TextBuilder;
        vendorLbl: Label 'Vendor';
    begin
        formattedText.AppendLine('---------------------------------------------');
        formattedText.AppendLine('CONTACT INFORMATION');
        formattedText.AppendLine('---------------------------------------------');
        formattedText.AppendLine(vendorLbl + ': ' + Vendor."No." + ' - ' + Vendor.Name);
        AppendContactDetails(Vendor, formattedText);
        AppendVendorBalance(Vendor, formattedText);
        formattedText.Append('---------------------------------------------');
        exit(formattedText.ToText());
    end;

    local procedure AppendContactDetails(Vendor: Record Vendor; var formattedText: TextBuilder)
    var
        contactLbl: Label 'Contact';
        phoneLbl: Label 'Phone';
        emailLbl: Label 'Email';
        vatRegNoLbl: Label 'VAT Registration No.';
    begin
        if Vendor.Contact <> '' then
            formattedText.AppendLine(contactLbl + ': ' + Vendor.Contact);

        if Vendor."Phone No." <> '' then
            formattedText.AppendLine(phoneLbl + ': ' + Vendor."Phone No.");

        if Vendor."E-Mail" <> '' then
            formattedText.AppendLine(emailLbl + ': ' + Vendor."E-Mail");

        AppendAddress(Vendor, formattedText);
        AppendCity(Vendor, formattedText);

        if Vendor."VAT Registration No." <> '' then
            formattedText.AppendLine(vatRegNoLbl + ': ' + Vendor."VAT Registration No.");
    end;

    local procedure AppendAddress(Vendor: Record Vendor; var formattedText: TextBuilder)
    var
        addressLbl: Label 'Address';
    begin
        if Vendor.Address = '' then
            exit;

        formattedText.AppendLine(addressLbl + ': ' + Vendor.Address);
        if Vendor."Address 2" <> '' then
            formattedText.AppendLine('         ' + Vendor."Address 2");
    end;

    local procedure AppendCity(Vendor: Record Vendor; var formattedText: TextBuilder)
    var
        cityLbl: Label 'City';
    begin
        if (Vendor.City <> '') or (Vendor."Post Code" <> '') then
            formattedText.AppendLine(cityLbl + ': ' + Vendor."Post Code" + ' ' + Vendor.City);
    end;

    local procedure AppendVendorBalance(var Vendor: Record Vendor; var formattedText: TextBuilder)
    var
        balanceLbl: Label 'Balance ($)';
        overdueBalanceLbl: Label 'Overdue Balance ($)';
    begin
        Vendor.SetRange("Date Filter", 0D, Today());
        Vendor.CalcFields("Balance (LCY)", "Balance Due (LCY)");
        formattedText.AppendLine(balanceLbl + ': ' + Format(Vendor."Balance (LCY)", 0, '<Precision,2:2><Standard Format,0>'));
        formattedText.AppendLine(overdueBalanceLbl + ': ' + Format(Vendor."Balance Due (LCY)", 0, '<Precision,2:2><Standard Format,0>'));
    end;

    local procedure FormatVendorPaymentInfo(Vendor: Record Vendor): Text
    var
        vendorBankAccount: Record "Vendor Bank Account";
        formattedText: TextBuilder;
    begin
        formattedText.AppendLine('---------------------------------------------');
        formattedText.AppendLine('BANK INFORMATION');
        formattedText.AppendLine('---------------------------------------------');
        AppendPaymentTerms(Vendor, formattedText);
        formattedText.AppendLine('');
        AppendBankAccountDetails(Vendor, vendorBankAccount, formattedText);
        formattedText.Append('---------------------------------------------');
        exit(formattedText.ToText());
    end;

    local procedure AppendPaymentTerms(Vendor: Record Vendor; var formattedText: TextBuilder)
    var
        paymentTermsLbl: Label 'Payment Terms Code';
        paymentMethodLbl: Label 'Payment Method Code';
    begin
        if Vendor."Payment Terms Code" <> '' then
            formattedText.AppendLine(paymentTermsLbl + ': ' + Vendor."Payment Terms Code");

        if Vendor."Payment Method Code" <> '' then
            formattedText.AppendLine(paymentMethodLbl + ': ' + Vendor."Payment Method Code");
    end;

    local procedure AppendBankAccountDetails(Vendor: Record Vendor; var vendorBankAccount: Record "Vendor Bank Account"; var formattedText: TextBuilder)
    begin
        if Vendor."Preferred Bank Account Code" = '' then begin
            formattedText.AppendLine('No bank account configured');
            exit;
        end;

        if not vendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code") then
            exit;

        AppendBankFields(vendorBankAccount, formattedText);
    end;

    local procedure AppendBankFields(vendorBankAccount: Record "Vendor Bank Account"; var formattedText: TextBuilder)
    var
        bankNameLbl: Label 'Bank Name';
        bankAccountLbl: Label 'Bank Account No.';
        bankBranchLbl: Label 'Bank Branch No.';
        ibanLbl: Label 'IBAN';
        swiftLbl: Label 'SWIFT Code';
    begin
        if vendorBankAccount.Name <> '' then
            formattedText.AppendLine(bankNameLbl + ': ' + vendorBankAccount.Name);

        if vendorBankAccount."Bank Account No." <> '' then
            formattedText.AppendLine(bankAccountLbl + ': ' + vendorBankAccount."Bank Account No.");

        if vendorBankAccount."Bank Branch No." <> '' then
            formattedText.AppendLine(bankBranchLbl + ': ' + vendorBankAccount."Bank Branch No.");

        if vendorBankAccount.IBAN <> '' then
            formattedText.AppendLine(ibanLbl + ': ' + vendorBankAccount.IBAN);

        if vendorBankAccount."SWIFT Code" <> '' then
            formattedText.AppendLine(swiftLbl + ': ' + vendorBankAccount."SWIFT Code");
    end;

    local procedure ShowClipboardDialog(contactInfo: Text; paymentInfo: Text)
    var
        clipboardPage: Page "GDRG Clipboard Helper";
    begin
        clipboardPage.SetCaption('Vendor Information');
        clipboardPage.SetCustomerData(contactInfo, paymentInfo);
        clipboardPage.RunModal();
    end;
}
