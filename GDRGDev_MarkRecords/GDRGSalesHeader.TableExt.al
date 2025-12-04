tableextension 77891 "GDRG Sales Header" extends "Sales Header"
{
    fields
    {
        field(77890; GDRGMarkStatus; Enum "GDRG Mark Status")
        {
            Caption = '፞';
            ToolTip = 'Specifies if the record is marked.';
            DataClassification = CustomerContent;
        }
    }
}
