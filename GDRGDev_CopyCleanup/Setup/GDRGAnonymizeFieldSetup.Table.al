table 88891 "GDRG Anonymize Field Setup"
{
    Caption = 'GDRG Anonymize Field Setup';
    DataPerCompany = false;
    DrillDownPageId = "GDRG Anonymize Field List";
    LookupPageId = "GDRG Anonymize Field List";

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = "GDRG Anonymize Setup";
            ToolTip = 'Specifies the selected table number.';
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            ToolTip = 'Specifies the selected field number.';

            trigger OnValidate()
            var
                FieldMetadata: Record Field;
            begin
                if FieldMetadata.Get("Table No.", "Field No.") then
                    "Field Name" := CopyStr(FieldMetadata.FieldName, 1, MaxStrLen("Field Name"))
                else
                    "Field Name" := '';
            end;
        }
        field(3; "Field Name"; Text[100])
        {
            Caption = 'Field Name';
            ToolTip = 'Specifies the selected field name.';
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
            ToolTip = 'Specifies whether anonymization is enabled for this field.';
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Field No.", "Field Name")
        {
        }
        fieldgroup(Brick; "Field No.", "Field Name", Enabled)
        {
        }
    }
}