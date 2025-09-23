enumextension 50100 "GDRG Error Msg Fix Impl" extends "Error Msg. Fix Implementation"
{
    value(50100; GDRGGLAccountBlocked)
    {
        Caption = 'GDRG GL Account Blocked';
        Implementation = ErrorMessageFix = "GDRG GL Account Blocked Error";
    }
    value(50101; GDRGGLAccountDirectPosting)
    {
        Caption = 'GDRG GL Account Direct Posting';
        Implementation = ErrorMessageFix = "GDRG GL Acc Direct Post Error";
    }
}