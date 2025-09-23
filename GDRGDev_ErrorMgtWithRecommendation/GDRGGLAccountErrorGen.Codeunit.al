codeunit 50102 "GDRG GL Account Error Gen"
{
    Permissions = tabledata "G/L Account" = RIMD;

    var
        LastErrorMessage: Record "Error Message";

    /// <summary>
    /// Validates a GL Account for common business rule violations.
    /// </summary>
    /// <param name="GLAccount">The GL Account to validate.</param>
    /// <returns>True if any errors were found, false if validation passed.</returns>
    procedure ValidateGLAccount(GLAccount: Record "G/L Account"): Boolean
    var
        HasErrors: Boolean;
    begin
        if GLAccount.Blocked then begin
            LogGLAccountBlockedError(GLAccount);
            HasErrors := true;
        end;

        if not GLAccount."Direct Posting" then begin
            LogGLAccountDirectPostingError(GLAccount);
            HasErrors := true;
        end;

        exit(HasErrors);
    end;

    /// <summary>
    /// Demonstrates error validation by showing errors with recommendations in the Error Messages page.
    /// </summary>
    /// <param name="GLAccount">The GL Account to validate and display errors for.</param>
    procedure DemoValidateAndShowErrors(GLAccount: Record "G/L Account")
    var
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageMgt: Codeunit "Error Message Management";
    begin
        ErrorMessageMgt.Activate(ErrorMessageHandler);

        if ValidateGLAccount(GLAccount) then begin
            if ErrorMessageMgt.GetLastErrorID() > 0 then
                ErrorMessageHandler.ShowErrors()
            else
                Message('Error occurred but could not retrieve details.');
        end else
            Message('GL Account %1 validation passed successfully.', GLAccount."No.");
    end;

    /// <summary>
    /// Logs a blocked GL Account error with fix recommendation.
    /// </summary>
    /// <param name="GLAccount">The blocked GL Account.</param>
    /// <returns>True if the error was logged successfully.</returns>
    procedure LogGLAccountBlockedError(GLAccount: Record "G/L Account"): Boolean
    var
        ErrorMessageMgt: Codeunit "Error Message Management";
        BlockedAccountLbl: Label 'Account %1 is blocked', Comment = '%1 = GL Account No.';
        ErrorMsgFixImplementation: Enum "Error Msg. Fix Implementation";
    begin
        if ErrorMessageMgt.IsActive() then begin
            ErrorMessageMgt.LogContextFieldError(0, StrSubstNo(BlockedAccountLbl, GLAccount."No."), GLAccount, GLAccount.FieldNo(Blocked), '');
            ErrorMsgFixImplementation := Enum::"Error Msg. Fix Implementation"::GDRGGLAccountBlocked;
            ErrorMessageMgt.AddSubContextToLastErrorMessage(Format(ErrorMsgFixImplementation), GLAccount);
        end else begin
            LastErrorMessage.Init();
            LastErrorMessage.ID += 1;
            LastErrorMessage."Message" := CopyStr(StrSubstNo(BlockedAccountLbl, GLAccount."No."), 1, MaxStrLen(LastErrorMessage."Message"));
        end;
        exit(true);
    end;

    /// <summary>
    /// Logs a Direct Posting disabled error with fix recommendation.
    /// </summary>
    /// <param name="GLAccount">The GL Account with direct posting disabled.</param>
    /// <returns>True if the error was logged successfully.</returns>
    procedure LogGLAccountDirectPostingError(GLAccount: Record "G/L Account"): Boolean
    var
        ErrorMessageMgt: Codeunit "Error Message Management";
        DirectPostingDisabledLbl: Label 'Direct posting not allowed for account %1', Comment = '%1 = GL Account No.';
        ErrorMsgFixImplementation: Enum "Error Msg. Fix Implementation";
    begin
        if ErrorMessageMgt.IsActive() then begin
            ErrorMessageMgt.LogContextFieldError(0, StrSubstNo(DirectPostingDisabledLbl, GLAccount."No."), GLAccount, GLAccount.FieldNo("Direct Posting"), '');
            ErrorMsgFixImplementation := Enum::"Error Msg. Fix Implementation"::GDRGGLAccountDirectPosting;
            ErrorMessageMgt.AddSubContextToLastErrorMessage(Format(ErrorMsgFixImplementation), GLAccount);
        end else begin
            LastErrorMessage.Init();
            LastErrorMessage.ID += 1;
            LastErrorMessage."Message" := CopyStr(StrSubstNo(DirectPostingDisabledLbl, GLAccount."No."), 1, MaxStrLen(LastErrorMessage."Message"));
        end;
        exit(true);
    end;
}