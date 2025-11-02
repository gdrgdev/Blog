table 90001 "GDRG Field Masking Setup"
{
    Caption = 'GDRG Field Masking Setup';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Field Masking Setup";
    DrillDownPageId = "GDRG Field Masking Setup";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            ToolTip = 'Specifies the table ID.';

            trigger OnValidate()
            begin
                UpdateTableName();
                "Field No." := 0;
                "Field Name" := '';
                "Field Caption" := '';
            end;
        }
        field(2; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            Editable = false;
            ToolTip = 'Specifies the table name.';
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." where(TableNo = field("Table ID"));
            ToolTip = 'Specifies the field number.';

            trigger OnLookup()
            var
                FieldRec: Record Field;
                FieldLookup: Page "GDRG Field Masking Lookup";
            begin
                FieldRec.SetRange(TableNo, "Table ID");
                FieldLookup.SetTableView(FieldRec);
                FieldLookup.LookupMode(true);
                if FieldLookup.RunModal() = Action::LookupOK then begin
                    FieldLookup.GetRecord(FieldRec);
                    Validate("Field No.", FieldRec."No.");
                end;
            end;

            trigger OnValidate()
            begin
                UpdateFieldInfo();
            end;
        }
        field(4; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            Editable = false;
            ToolTip = 'Specifies the field name.';
        }
        field(5; "Field Caption"; Text[80])
        {
            Caption = 'Field Caption';
            Editable = false;
            ToolTip = 'Specifies the field caption.';
        }
        field(10; "Mask Pattern"; Enum "GDRG Mask Pattern")
        {
            Caption = 'Mask Pattern';
            ToolTip = 'Specifies the masking pattern.';
        }
        field(11; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
            ToolTip = 'Specifies whether masking is enabled.';
        }
    }

    keys
    {
        key(PK; "Table ID", "Field No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Table ID", "Table Name", "Field No.", "Field Name") { }
        fieldgroup(Brick; "Table ID", "Table Name", "Field No.", "Field Name") { }
    }

    local procedure UpdateTableName()
    var
        AllObj: Record AllObjWithCaption;
    begin
        if AllObj.Get(AllObj."Object Type"::Table, "Table ID") then
            "Table Name" := AllObj."Object Name";
    end;

    local procedure UpdateFieldInfo()
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if ("Table ID" = 0) or ("Field No." = 0) then
            exit;

        RecRef.Open("Table ID");
        if RecRef.FieldExist("Field No.") then begin
            FldRef := RecRef.Field("Field No.");
            "Field Name" := CopyStr(FldRef.Name(), 1, MaxStrLen("Field Name"));
            "Field Caption" := CopyStr(FldRef.Caption(), 1, MaxStrLen("Field Caption"));
        end;
        RecRef.Close();
    end;
}
