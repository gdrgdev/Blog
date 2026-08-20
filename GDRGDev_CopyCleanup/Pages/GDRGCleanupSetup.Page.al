page 88894 "GDRG Cleanup Setup"
{
    ApplicationArea = All;
    Caption = 'Cleanup Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "GDRG Cleanup Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Run Env. Cleanup After Copy"; Rec."Run Env. Cleanup After Copy")
                {
                }
                field("Run Company Cleanup After Copy"; Rec."Run Company Cleanup After Copy")
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
        Rec.Insert(true);
    end;
}