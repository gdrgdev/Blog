table 88890 "GDRG Anonymize Setup"
{
    Caption = 'GDRG Anonymize Setup';
    DataPerCompany = false;
    DrillDownPageId = "GDRG Anonymize Setup";
    LookupPageId = "GDRG Anonymize Setup";
    Permissions = tabledata "GDRG Anonymize Field Setup" = rd;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            ToolTip = 'Specifies the selected table number.';

            trigger OnValidate()
            var
                AllObjWithCaption: Record AllObjWithCaption;
            begin
                if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, "Table No.") then
                    "Table Name" := CopyStr(AllObjWithCaption."Object Caption", 1, MaxStrLen("Table Name"))
                else
                    "Table Name" := '';
            end;
        }
        field(2; "Table Name"; Text[100])
        {
            Caption = 'Table Name';
            ToolTip = 'Specifies the selected table name.';
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
            ToolTip = 'Specifies whether anonymization is enabled for this table.';
        }
    }

    keys
    {
        key(PK; "Table No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Table No.", "Table Name")
        {
        }
        fieldgroup(Brick; "Table No.", "Table Name", Enabled)
        {
        }
    }

    trigger OnDelete()
    var
        AnonymizeFieldSetup: Record "GDRG Anonymize Field Setup";
    begin
        AnonymizeFieldSetup.SetRange("Table No.", "Table No.");
        if not AnonymizeFieldSetup.IsEmpty() then
            AnonymizeFieldSetup.DeleteAll(true);
    end;
}