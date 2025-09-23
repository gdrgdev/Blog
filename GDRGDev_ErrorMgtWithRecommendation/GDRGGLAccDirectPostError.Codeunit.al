codeunit 50101 "GDRG GL Acc Direct Post Error" implements ErrorMessageFix
{
    Access = Internal;
    Permissions = tabledata "G/L Account" = RIMD;

    var
        TempGLAccountGbl: Record "G/L Account" temporary;
        GLAccountDirectPostEnabledTok: Label 'Direct Posting enabled for %1', Comment = '%1 = GL Account No.', Locked = true;
        EnableDirectPostingActionLbl: Label 'Enable posting';
        GLAccountDirectPostDisabledErr: Label 'GL Account %1 does not allow Direct Posting', Comment = '%1 = GL Account No.';

    /// <summary>
    /// Sets error message properties for Direct Posting disabled errors.
    /// </summary>
    /// <param name="ErrorMessage">The error message record to configure.</param>
    procedure OnSetErrorMessageProps(var ErrorMessage: Record "Error Message" temporary)
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(ErrorMessage."Sub-Context Record ID") then
            exit;

        ErrorMessage.Validate(Title, CopyStr(StrSubstNo(GLAccountDirectPostDisabledErr, GLAccount."No."), 1, MaxStrLen(ErrorMessage.Title)));
        ErrorMessage.Validate("Recommended Action Caption", CopyStr(EnableDirectPostingActionLbl, 1, MaxStrLen(ErrorMessage."Recommended Action Caption")));
    end;

    /// <summary>
    /// Fixes the Direct Posting disabled error by enabling direct posting.
    /// </summary>
    /// <param name="ErrorMessage">The error message containing the GL Account context.</param>
    /// <returns>True if the error was fixed successfully.</returns>
    procedure OnFixError(ErrorMessage: Record "Error Message" temporary): Boolean
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(ErrorMessage."Sub-Context Record ID") then
            exit(false);

        GLAccount.Validate("Direct Posting", true);
        GLAccount.Modify(true);
        TempGLAccountGbl := GLAccount;
        exit(true);
    end;

    /// <summary>
    /// Returns a success message after fixing the Direct Posting error.
    /// </summary>
    /// <returns>A formatted success message indicating Direct Posting was enabled.</returns>
    procedure OnSuccessMessage(): Text
    begin
        exit(StrSubstNo(GLAccountDirectPostEnabledTok, TempGLAccountGbl."No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Error Message Management", OnAddSubContextToLastErrorMessage, '', false, false)]
    local procedure OnAddSubContextToLastErrorMessage(Tag: Text; VariantRec: Variant; var ErrorMessage: Record "Error Message" temporary)
    var
        GLAccount: Record "G/L Account";
        RecRef: RecordRef;
        IErrorMessageFix: Interface ErrorMessageFix;
        ErrorMsgFixImplementation: Enum "Error Msg. Fix Implementation";
    begin
        ErrorMsgFixImplementation := Enum::"Error Msg. Fix Implementation"::GDRGGLAccountDirectPosting;
        if Tag <> Format(ErrorMsgFixImplementation) then
            exit;

        if VariantRec.IsRecord() then begin
            RecRef.GetTable(VariantRec);
            if RecRef.Number() = Database::"G/L Account" then begin
                RecRef.SetTable(GLAccount);
                ErrorMessage.Validate("Sub-Context Record ID", GLAccount.RecordId());
                ErrorMessage.Validate("Sub-Context Field Number", GLAccount.FieldNo("Direct Posting"));
                ErrorMessage.Validate("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::GDRGGLAccountDirectPosting);

                IErrorMessageFix := ErrorMessage."Error Msg. Fix Implementation";
                IErrorMessageFix.OnSetErrorMessageProps(ErrorMessage);
                ErrorMessage.Modify(false);
            end;
        end;
    end;
}