codeunit 50100 "GDRG GL Account Blocked Error" implements ErrorMessageFix
{
    Access = Internal;
    Permissions = tabledata "G/L Account" = RIMD;

    var
        TempGLAccountGbl: Record "G/L Account" temporary;
        GLAccountUnblockedTok: Label 'GL Account %1 unblocked', Comment = '%1 = GL Account No.', Locked = true;
        UnblockAccountActionLbl: Label 'Unblock Account';
        GLAccountBlockedTitleErr: Label 'GL Account %1 is blocked', Comment = '%1 = GL Account No.';

    /// <summary>
    /// Sets error message properties for blocked GL Account errors.
    /// </summary>
    /// <param name="ErrorMessage">The error message record to configure.</param>
    procedure OnSetErrorMessageProps(var ErrorMessage: Record "Error Message" temporary)
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(ErrorMessage."Sub-Context Record ID") then
            exit;

        ErrorMessage.Validate(Title, CopyStr(StrSubstNo(GLAccountBlockedTitleErr, GLAccount."No."), 1, MaxStrLen(ErrorMessage.Title)));
        ErrorMessage.Validate("Recommended Action Caption", CopyStr(UnblockAccountActionLbl, 1, MaxStrLen(ErrorMessage."Recommended Action Caption")));
    end;

    /// <summary>
    /// Fixes the blocked GL Account error by unblocking the account.
    /// </summary>
    /// <param name="ErrorMessage">The error message containing the GL Account context.</param>
    /// <returns>True if the error was fixed successfully.</returns>
    procedure OnFixError(ErrorMessage: Record "Error Message" temporary): Boolean
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(ErrorMessage."Sub-Context Record ID") then
            exit(false);

        GLAccount.Validate(Blocked, false);
        GLAccount.Modify(true);
        TempGLAccountGbl := GLAccount;
        exit(true);
    end;

    /// <summary>
    /// Returns a success message after fixing the blocked account error.
    /// </summary>
    /// <returns>A formatted success message indicating the account was unblocked.</returns>
    procedure OnSuccessMessage(): Text
    begin
        exit(StrSubstNo(GLAccountUnblockedTok, TempGLAccountGbl."No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Error Message Management", OnAddSubContextToLastErrorMessage, '', false, false)]
    local procedure OnAddSubContextToLastErrorMessage(Tag: Text; VariantRec: Variant; var ErrorMessage: Record "Error Message" temporary)
    var
        GLAccount: Record "G/L Account";
        RecRef: RecordRef;
        IErrorMessageFix: Interface ErrorMessageFix;
        ErrorMsgFixImplementation: Enum "Error Msg. Fix Implementation";
    begin
        ErrorMsgFixImplementation := Enum::"Error Msg. Fix Implementation"::GDRGGLAccountBlocked;
        if Tag <> Format(ErrorMsgFixImplementation) then
            exit;

        if VariantRec.IsRecord() then begin
            RecRef.GetTable(VariantRec);
            if RecRef.Number() = Database::"G/L Account" then begin
                RecRef.SetTable(GLAccount);
                ErrorMessage.Validate("Sub-Context Record ID", GLAccount.RecordId());
                ErrorMessage.Validate("Sub-Context Field Number", GLAccount.FieldNo(Blocked));
                ErrorMessage.Validate("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::GDRGGLAccountBlocked);

                IErrorMessageFix := ErrorMessage."Error Msg. Fix Implementation";
                IErrorMessageFix.OnSetErrorMessageProps(ErrorMessage);
                ErrorMessage.Modify(false);
            end;
        end;
    end;
}