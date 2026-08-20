table 88895 "GDRG Company Feature Setup"
{
    Caption = 'GDRG Company Feature Setup';
    DataPerCompany = true;
    DrillDownPageId = "GDRG Company Feature Setup";
    LookupPageId = "GDRG Company Feature Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            NotBlank = true;
            ToolTip = 'Specifies the primary key of the company feature setup record.';
            AllowInCustomizations = Never;
        }
        field(2; "Feature Enabled"; Boolean)
        {
            Caption = 'Feature Enabled';
            ToolTip = 'Specifies whether the company feature is enabled.';
        }
        field(3; "Service Base URL"; Text[250])
        {
            Caption = 'Service Base URL';
            ToolTip = 'Specifies the base URL used by the company feature.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Primary Key", "Feature Enabled", "Service Base URL")
        {
        }
        fieldgroup(Brick; "Primary Key", "Feature Enabled", "Service Base URL")
        {
        }
    }
}