table 88894 "GDRG Cleanup Setup"
{
    Caption = 'GDRG Cleanup Setup';
    DataPerCompany = false;
    DrillDownPageId = "GDRG Cleanup Setup";
    LookupPageId = "GDRG Cleanup Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            NotBlank = true;
            ToolTip = 'Specifies the primary key of the setup record.';
            AllowInCustomizations = Never;
        }
        field(2; "Run Env. Cleanup After Copy"; Boolean)
        {
            Caption = 'Run Cleanup After Environment Copy';
            ToolTip = 'Specifies whether the cleanup process runs automatically after an environment copy.';
        }
        field(3; "Run Company Cleanup After Copy"; Boolean)
        {
            Caption = 'Run Cleanup After Company Copy';
            ToolTip = 'Specifies whether the cleanup process runs automatically after a company copy finishes.';
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
        fieldgroup(DropDown; "Primary Key", "Run Env. Cleanup After Copy", "Run Company Cleanup After Copy")
        {
        }
        fieldgroup(Brick; "Primary Key", "Run Env. Cleanup After Copy", "Run Company Cleanup After Copy")
        {
        }
    }
}