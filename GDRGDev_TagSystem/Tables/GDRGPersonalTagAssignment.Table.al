table 50100 "GDRG Personal Tag Assignment"
{
    Caption = 'Personal Tag Assignment';
    LookupPageId = "GDRG Personal Tag Assignments";
    DrillDownPageId = "GDRG Personal Tag Assignments";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the user who created the tag assignment.';
            TableRelation = User."User Name";
            DataClassification = EndUserIdentifiableInformation;
            AllowInCustomizations = Never;
        }
        field(2; "Tag Code"; Code[20])
        {
            Caption = 'Tag Code';
            ToolTip = 'Specifies the code of the assigned tag.';
            TableRelation = "GDRG Personal Tag Master".Code where("User ID" = field("User ID"));
            DataClassification = CustomerContent;
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            ToolTip = 'Specifies the table number of the tagged record.';
            DataClassification = SystemMetadata;
            AllowInCustomizations = Never;
        }
        field(4; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
            ToolTip = 'Specifies the unique identifier of the tagged record.';
            DataClassification = CustomerContent;
            AllowInCustomizations = Never;
        }
        field(5; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            ToolTip = 'Specifies when the tag assignment was created.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Tag Name"; Text[50])
        {
            Caption = 'Tag Name';
            ToolTip = 'Specifies the name of the assigned tag.';
            FieldClass = FlowField;
            CalcFormula = lookup("GDRG Personal Tag Master".Name where(Code = field("Tag Code"), "User ID" = field("User ID")));
            Editable = false;
        }
        field(7; "Tag Color"; Enum "GDRG Color")
        {
            Caption = 'Tag Color';
            ToolTip = 'Specifies the color of the assigned tag.';
            FieldClass = FlowField;
            CalcFormula = lookup("GDRG Personal Tag Master".Color where(Code = field("Tag Code"), "User ID" = field("User ID")));
            Editable = false;
        }
        field(8; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            ToolTip = 'Specifies the name of the table containing the tagged record.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "Record Description"; Text[250])
        {
            Caption = 'Record Description';
            ToolTip = 'Specifies the description of the tagged record.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User ID", "Tag Code", "Table No.", "Record ID")
        {
            Clustered = true;
        }
        key(Search; "User ID", "Tag Code")
        {
        }
        key(Record; "User ID", "Table No.", "Record ID")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Tag Code", "Tag Name", "Tag Color", "Table Name", "Record Description")
        {
        }
        fieldgroup(DropDown; "Tag Code", "Tag Name", "Tag Color")
        {
        }
    }

    trigger OnInsert()
    begin
        if "User ID" = '' then
            "User ID" := CopyStr(UserId(), 1, 50);
        "Created Date" := CurrentDateTime();
        UpdateTableInfo();
    end;

    trigger OnModify()
    begin
        UpdateTableInfo();
    end;

    local procedure UpdateTableInfo()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        i: Integer;
    begin
        // Get table name
        AllObjWithCaption.Reset();
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", "Table No.");
        if AllObjWithCaption.FindFirst() then
            "Table Name" := AllObjWithCaption."Object Caption";

        // Try to get record description
        if not RecRef.Get("Record ID") then
            exit;

        KeyRef := RecRef.KeyIndex(1);
        "Record Description" := '';

        // Build description from primary key fields
        for i := 1 to KeyRef.FieldCount() do begin
            FieldRef := KeyRef.FieldIndex(i);
            if "Record Description" <> '' then
                "Record Description" += ' - ';
            "Record Description" += Format(FieldRef.Value());
            if StrLen("Record Description") > 200 then begin
                "Record Description" := CopyStr("Record Description", 1, 200) + '...';
                break;
            end;
        end;
    end;
}
