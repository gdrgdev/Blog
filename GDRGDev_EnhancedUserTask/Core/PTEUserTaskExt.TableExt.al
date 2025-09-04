tableextension 50100 "PTE User Task Ext" extends "User Task"
{
    fields
    {
        field(50100; "Related Table No."; Integer)
        {
            Caption = 'Related Table No.';
            ToolTip = 'Specifies the table number of the record this task is related to.';
            DataClassification = CustomerContent;
            AllowInCustomizations = Always;
        }

        field(50101; "Related Record ID"; RecordId)
        {
            Caption = 'Related Record ID';
            ToolTip = 'Specifies the unique identifier of the record this task is related to.';
            DataClassification = CustomerContent;
            AllowInCustomizations = Always;
        }

        field(50102; "Related Record Description"; Text[250])
        {
            Caption = 'Related Record Description';
            ToolTip = 'Specifies the description of the record this task is related to.';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(50103; "Related Table Name"; Text[100])
        {
            Caption = 'Related Table Name';
            ToolTip = 'Specifies the name of the table type this task is related to.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(RelatedRecord; "Related Record ID") { }
        key(RelatedTable; "Related Table No.") { }
    }
}
