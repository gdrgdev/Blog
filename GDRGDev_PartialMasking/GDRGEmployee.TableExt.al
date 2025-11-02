tableextension 90000 "GDRG Employee" extends Employee
{
    fields
    {
        field(50100; "GDRG Custom SSN"; Text[30])
        {
            Caption = 'Custom SSN';
            DataClassification = CustomerContent;
            MaskType = Concealed;
            ToolTip = 'Specifies the custom SSN with MaskType Concealed.';
        }
    }
}
