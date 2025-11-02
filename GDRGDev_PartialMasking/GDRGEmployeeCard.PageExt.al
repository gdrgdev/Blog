pageextension 90000 "GDRG Employee Card" extends "Employee Card"
{
    layout
    {
        addafter("Social Security No.")
        {
            field(SocialSecurityNoPartial; GetSSNDisplay())
            {
                ApplicationArea = All;
                Caption = '👁️ Social Security No. (Partial)';
                Editable = false;
                AssistEdit = true;
                ToolTip = 'Specifies the social security number. Click the assist button to toggle full/partial view.';

                trigger OnAssistEdit()
                begin
                    ShowFullSSN := not ShowFullSSN;
                    CurrPage.Update(false);
                end;
            }
            field(GDRGCustomSSN; Rec."GDRG Custom SSN")
            {
                ApplicationArea = All;
            }
            field(GDRGCustomSSNPartial; GetCustomSSNDisplay())
            {
                ApplicationArea = All;
                Caption = '👁️ Custom SSN (Partial)';
                Editable = false;
                AssistEdit = true;
                ToolTip = 'Specifies the custom SSN. Click the assist button to toggle full/partial view.';

                trigger OnAssistEdit()
                begin
                    ShowFullCustomSSN := not ShowFullCustomSSN;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        GDRGMaskingMgt: Codeunit "GDRG Masking Management";
        ShowFullSSN: Boolean;
        ShowFullCustomSSN: Boolean;

    local procedure GetSSNDisplay(): Text
    begin
        if ShowFullSSN then
            exit(Rec."Social Security No.")
        else
            exit(GDRGMaskingMgt.GetPartialValue(Database::Employee, SSNFieldNo, Rec."Social Security No."));
    end;

    local procedure GetCustomSSNDisplay(): Text
    begin
        if ShowFullCustomSSN then
            exit(Rec."GDRG Custom SSN")
        else
            exit(GDRGMaskingMgt.GetPartialValue(Database::Employee, CustomSSNFieldNo, Rec."GDRG Custom SSN"));
    end;

    var
        SSNFieldNo: Integer;
        CustomSSNFieldNo: Integer;

    trigger OnOpenPage()
    begin
        SSNFieldNo := 21;
        CustomSSNFieldNo := 50100;
    end;
}
