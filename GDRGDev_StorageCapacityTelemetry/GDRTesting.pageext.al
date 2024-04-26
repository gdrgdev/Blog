pageextension 80000 GDRTesting extends "Customer List"
{

    actions
    {
        addafter("&Customer")
        {
            action(APIToken)
            {
                Caption = 'ApiToken';
                Image = Web;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    cuGDRApiMgt: Codeunit GDRApiMgt;
                begin
                    Message(cuGDRApiMgt.GDRgetToken());
                end;
            }
            action(APIQuotas)
            {
                Caption = 'Api Storage Quotas';
                Image = Web;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    cuGDRStorageTables: Codeunit GDRStorageTables;
                begin
                    cuGDRStorageTables.GDRgetstoragequotas();
                end;
            }
        }
    }
}
