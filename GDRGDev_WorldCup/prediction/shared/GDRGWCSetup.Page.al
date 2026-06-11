page 88896 "GDRG WC Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GDRG WC Setup";
    Caption = 'World Cup Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Source URL"; Rec."Source URL")
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
        Rec."Source URL" := 'https://raw.githubusercontent.com/openfootball/worldcup.json/master/2026/worldcup.json';
        Rec.Insert(false);
    end;
}