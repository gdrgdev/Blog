page 90001 "GDRG Field Masking Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GDRG Field Masking Setup";
    Caption = 'Field Masking Setup';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID") { }
                field("Table Name"; Rec."Table Name") { }
                field("Field No."; Rec."Field No.") { }
                field("Field Name"; Rec."Field Name") { }
                field("Field Caption"; Rec."Field Caption") { }
                field("Mask Pattern"; Rec."Mask Pattern") { }
                field(Enabled; Rec.Enabled) { }
            }
        }
    }
}
