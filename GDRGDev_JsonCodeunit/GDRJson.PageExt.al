pageextension 96000 GDRJsonMgtTest extends "Customer List"
{
    actions
    {
        addfirst(General)
        {
            action("TestingJsonCodeunit")
            {
                Caption = 'Testing Json Codeunit';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = TestFile;
                trigger OnAction()
                var
                    GDRJson: codeunit GDRJsonMgt;
                begin
                    GDRJson.CheckJsonArray();
                end;
            }
        }
    }
}
