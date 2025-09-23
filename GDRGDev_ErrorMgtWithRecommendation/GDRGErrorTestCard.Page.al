page 50100 "GDRG Error Test Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'GDRG Error Message Testing';
    Permissions = tabledata "G/L Account" = RIMD;
    layout
    {
        area(Content)
        {
            group(TestData)
            {
                Caption = 'Test Data';
                field(GLAccountNo; GLAccountNo)
                {
                    Caption = 'GL Account No.';
                    TableRelation = "G/L Account";
                    ToolTip = 'Specifies the GL Account to test error handling functionality.';
                    trigger OnValidate()
                    begin
                        if GLAccount.Get(GLAccountNo) then begin
                            GLAccountName := GLAccount.Name;
                            IsBlocked := GLAccount.Blocked;
                            DirectPostingEnabled := GLAccount."Direct Posting";
                            UpdateStatusText();
                        end else
                            ClearValues();
                    end;
                }
                field(GLAccountName; GLAccountName)
                {
                    Caption = 'Account Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the selected GL Account.';
                }
                field(IsBlocked; IsBlocked)
                {
                    Caption = 'Is Blocked';
                    Editable = false;
                    ToolTip = 'Specifies whether the GL Account is blocked for posting.';
                }
                field(DirectPostingEnabled; DirectPostingEnabled)
                {
                    Caption = 'Direct Posting';
                    Editable = false;
                    ToolTip = 'Specifies whether direct posting is allowed for this GL Account.';
                }
                field(StatusText; StatusText)
                {
                    Caption = 'Current Status';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the current validation status of the selected GL Account.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateAccount)
            {
                Caption = 'Validate Account';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CheckRulesSyntax;
                ToolTip = 'Validates the selected GL Account and shows any errors with recommendations for fixing them.';

                trigger OnAction()
                begin
                    ValidateSelectedAccount();
                end;
            }
            action(SetupBlockedAccount)
            {
                Caption = 'Setup Blocked Account Test';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Stop;
                ToolTip = 'Blocks the selected GL Account to simulate a blocked account error for testing.';

                trigger OnAction()
                begin
                    SetupBlockedAccountTest();
                end;
            }
            action(SetupDirectPostingDisabled)
            {
                Caption = 'Setup Direct Posting Test';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Setup;
                ToolTip = 'Disables direct posting for the selected GL Account to simulate this error for testing.';

                trigger OnAction()
                begin
                    SetupDirectPostingDisabledTest();
                end;
            }
            action(ResetAccount)
            {
                Caption = 'Reset Account to Valid State';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Refresh;
                ToolTip = 'Resets the selected GL Account to a valid state by unblocking it and enabling direct posting.';

                trigger OnAction()
                begin
                    ResetAccountToValidState();
                end;
            }
        }
    }

    var
        GLAccount: Record "G/L Account";
        GLAccountErrorGen: Codeunit "GDRG GL Account Error Gen";
        GLAccountNo: Code[20];
        GLAccountName: Text[100];
        IsBlocked: Boolean;
        DirectPostingEnabled: Boolean;
        StatusText: Text;

    local procedure ValidateSelectedAccount()
    begin
        if GLAccountNo = '' then begin
            Message('Please select a GL Account first.');
            exit;
        end;

        if not GLAccount.Get(GLAccountNo) then begin
            Message('GL Account %1 not found.', GLAccountNo);
            exit;
        end;

        GLAccountErrorGen.DemoValidateAndShowErrors(GLAccount);
        RefreshAccountData();
    end;

    local procedure SetupBlockedAccountTest()
    begin
        if GLAccountNo = '' then begin
            Message('Please select a GL Account first.');
            exit;
        end;

        if not GLAccount.Get(GLAccountNo) then begin
            Message('GL Account %1 not found.', GLAccountNo);
            exit;
        end;

        GLAccount.Blocked := true;
        GLAccount.Modify(true);
        RefreshAccountData();
        Message('Account %1 has been blocked for testing. Use "Validate Account" to test error handling.', GLAccountNo);
    end;

    local procedure SetupDirectPostingDisabledTest()
    begin
        if GLAccountNo = '' then begin
            Message('Please select a GL Account first.');
            exit;
        end;

        if not GLAccount.Get(GLAccountNo) then begin
            Message('GL Account %1 not found.', GLAccountNo);
            exit;
        end;

        GLAccount."Direct Posting" := false;
        GLAccount.Modify(true);
        RefreshAccountData();
        Message('Direct Posting disabled for account %1. Use "Validate Account" to test error handling.', GLAccountNo);
    end;

    local procedure ResetAccountToValidState()
    begin
        if GLAccountNo = '' then begin
            Message('Please select a GL Account first.');
            exit;
        end;

        if not GLAccount.Get(GLAccountNo) then begin
            Message('GL Account %1 not found.', GLAccountNo);
            exit;
        end;

        GLAccount.Blocked := false;
        GLAccount."Direct Posting" := true;
        GLAccount.Modify(true);
        RefreshAccountData();
        Message('Account %1 has been reset to a valid state.', GLAccountNo);
    end;

    local procedure RefreshAccountData()
    begin
        if GLAccount.Get(GLAccountNo) then begin
            GLAccountName := GLAccount.Name;
            IsBlocked := GLAccount.Blocked;
            DirectPostingEnabled := GLAccount."Direct Posting";
            UpdateStatusText();
            CurrPage.Update();
        end;
    end;

    local procedure UpdateStatusText()
    var
        Status: Text;
    begin
        Status := '';
        if IsBlocked then
            Status += 'BLOCKED ';
        if not DirectPostingEnabled then
            Status += 'NO_DIRECT_POST ';
        if Status = '' then
            Status := 'VALID_ACCOUNT';

        StatusText := Status;
    end;

    local procedure ClearValues()
    begin
        GLAccountName := '';
        IsBlocked := false;
        DirectPostingEnabled := false;
        StatusText := '';
    end;
}