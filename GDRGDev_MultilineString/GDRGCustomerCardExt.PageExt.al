pageextension 50100 "GDRG Customer Card Ext" extends "Customer Card"
{
    actions
    {
        addlast(processing)
        {
            action(ProcessBatchPayments)
            {
                ApplicationArea = All;
                Caption = 'Process Batch Payments';
                ToolTip = 'Specifies the batch payment processing for multiple customers.';
                Image = Payment;

                trigger OnAction()
                var
                    ConfirmManagement: Codeunit "Confirm Management";
                    ConfirmMsg: Text;
                    InstructionMsg: Text;
                begin
                    // Instruction message
                    InstructionMsg := @'Batch Payment Processing Requirements:

1. All selected invoices must be approved
2. Customer payment methods must be validated
3. Bank account balance will be verified
4. Processing may take 5-10 minutes for large batches

Ensure all prerequisites are met before continuing.';

                    Message(InstructionMsg);

                    // Confirmation message
                    ConfirmMsg := @'Ready to process batch payments?

This operation will:
- Lock selected customer records during processing
- Generate payment files for bank transmission
- Update all related ledger entries automatically
- Send confirmation emails to customers

Continue with batch processing?';

                    if ConfirmManagement.GetResponseOrDefault(ConfirmMsg, false) then
                        Message('Batch processing initiated successfully.');
                end;
            }
            action(DebugCustomerInfo)
            {
                ApplicationArea = All;
                Caption = 'Debug Customer Info';
                ToolTip = 'Specifies debug information showing current vs. calculated values.';
                Image = Info;

                trigger OnAction()
                var
                    DebugMsg: Text;
                    CalculatedCreditLimit: Decimal;
                    ProposedRating: Text;
                begin
                    // Simulate some calculations
                    CalculatedCreditLimit := Rec."Credit Limit (LCY)" * 1.1;
                    ProposedRating := 'MEDIUM';

                    DebugMsg := @'Customer Debug Information:

CURRENT VALUES:
- Credit Limit: %1
- Payment Terms: %2
- Blocked Status: %3
- Balance (LCY): %4

CALCULATED VALUES:
- Proposed Credit Limit: %5
- Suggested Rating: %6
- Risk Score: %7
- Last Payment Delay: %8 days

Analysis: Credit limit adjustment recommended based on payment history.';

                    Message(DebugMsg,
                        Rec."Credit Limit (LCY)",
                        Rec."Payment Terms Code",
                        Rec.Blocked,
                        Rec."Balance (LCY)",
                        CalculatedCreditLimit,
                        ProposedRating,
                        'LOW',
                        '5');
                end;
            }
            action(ErrorInfoExample)
            {
                ApplicationArea = All;
                Caption = 'ErrorInfo Example';
                ToolTip = 'Specifies an example using ErrorInfo with multiline detailed message.';
                Image = ErrorLog;

                trigger OnAction()
                var
                    CustomerErrorInfo: ErrorInfo;
                    DetailedErrorMsg: Text;
                begin
                    // Create detailed error message using multiline string
                    DetailedErrorMsg := @'Customer validation failed due to multiple issues:

VALIDATION ERRORS:
- Credit limit cannot exceed company policy maximum
- Payment terms must be defined before processing orders
- Customer category is required for tax calculations
- Bank account information is incomplete

RECOMMENDED ACTIONS:
1. Contact credit department for limit approval
2. Set appropriate payment terms in customer setup
3. Assign customer to valid business category
4. Complete banking details in payment methods

Please resolve these issues before continuing with customer setup.';

                    CustomerErrorInfo.Title := 'Customer Setup Validation Failed';
                    CustomerErrorInfo.Message := 'Multiple validation errors detected in customer configuration.';
                    CustomerErrorInfo.DetailedMessage := DetailedErrorMsg;
                    CustomerErrorInfo.Verbosity := Verbosity::Error;

                    Error(CustomerErrorInfo);
                end;
            }
            action(JsonExample)
            {
                ApplicationArea = All;
                Caption = 'JSON Creation Example';
                ToolTip = 'Specifies an example of creating JSON using multiline strings.';
                Image = FileContract;

                trigger OnAction()
                var
                    JsonTemplate: Text;
                    JsonText: Text;
                    ResultMsg: Text;
                begin
                    // Create JSON template using multiline string
                    JsonTemplate := @'{
  "customer": {
    "id": "%1",
    "name": "%2",
    "creditInfo": {
      "limit": %3,
      "terms": "%4",
      "riskLevel": "%5"
    },
    "address": {
      "street": "%6",
      "city": "%7",
      "country": "%8"
    },
    "metadata": {
      "lastModified": "%9",
      "modifiedBy": "%10",
      "version": "1.0"
    }
  }
}';

                    // Format with actual values
                    JsonText := StrSubstNo(JsonTemplate,
                        Rec."No.",
                        Rec.Name,
                        Rec."Credit Limit (LCY)",
                        Rec."Payment Terms Code",
                        'MEDIUM',
                        Rec.Address,
                        Rec.City,
                        Rec."Country/Region Code",
                        CurrentDateTime(),
                        UserId());

                    // Show the generated JSON
                    ResultMsg := @'Generated JSON for Customer Export:

FORMATTED JSON OUTPUT:
%1

USAGE SCENARIOS:
- API integrations with external systems
- Data export for reporting tools
- Configuration templates for bulk imports
- Audit trail documentation

The multiline template makes JSON structure clear and maintainable.';

                    Message(ResultMsg, JsonText);
                end;
            }
        }
    }
}
