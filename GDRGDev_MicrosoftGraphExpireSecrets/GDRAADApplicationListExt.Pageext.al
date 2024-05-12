pageextension 80000 GDRAADApplicationListExt extends "AAD Application List"
{
    layout
    {
        addafter(State)
        {
            field(CheckSecrets; Rec.CheckSecrets)
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        addfirst(Processing)
        {
            action(AADAplicationSecrets)
            {
                Caption = 'AAD Aplication Secrets';
                Image = EncryptionKeys;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page GDRAADApplicationSecrets;
                RunPageLink = "Client Id" = field("Client Id");
                ToolTip = 'Open the list of secrets that are registered for the AAD Application.';
            }
            action(AADAplicationSecretsTest)
            {
                Caption = 'AAD Aplication Secrets Test';
                Image = TestReport;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Testing AAD Application Secrets';
                trigger OnAction()
                var
                    gdrcuGDRAADApplicationSecrets: Codeunit GDRAADApplicationSecrets;
                begin
                    gdrcuGDRAADApplicationSecrets.GDRGetAADApplicationSecrets(rec."Client Id");
                end;
            }
        }
    }
}
