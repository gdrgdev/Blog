page 88895 "GDRG Company Feature Setup"
{
    ApplicationArea = All;
    Caption = 'Company Feature Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "GDRG Company Feature Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Feature Enabled"; Rec."Feature Enabled")
                {
                }
                field("Service Base URL"; Rec."Service Base URL")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        EnsureSetup();
    end;

    local procedure EnsureSetup()
    begin
        if Rec.Get('SETUP') then
            exit;

        Rec.Init();
        Rec."Primary Key" := 'SETUP';
        Rec."Feature Enabled" := true;
        Rec."Service Base URL" := 'https://prod.contoso.local';
        Rec.Insert(true);
    end;
}