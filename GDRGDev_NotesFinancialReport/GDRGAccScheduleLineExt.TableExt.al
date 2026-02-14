tableextension 50103 "GDRG Acc. Schedule Line" extends "Acc. Schedule Line"
{
    fields
    {
        field(50100; "GDRG Has Notes"; Boolean)
        {
            Caption = 'Has Notes';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50101; "GDRG Note Text"; Text[500])
        {
            Caption = 'Note Text';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "GDRG Has Notes" := "GDRG Note Text" <> '';
            end;
        }
    }
}
