table 50101 "GDRG User Achievement Profile"
{
    Caption = 'GDRG User Achievement Profile';
    LookupPageId = "GDRG User Profile List";
    DrillDownPageId = "GDRG User Profile List";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the unique identifier for the user in the achievement system.';
            NotBlank = true;
            TableRelation = User."User Name";
        }
        field(2; "Total Points"; Integer)
        {
            Caption = 'Total Points';
            ToolTip = 'Specifies the total number of achievement points earned by the user across all departments.';
            MinValue = 0;
            Editable = false;
        }
        field(3; "Current Level"; Integer)
        {
            Caption = 'Current Level';
            ToolTip = 'Specifies the current achievement level of the user based on total points earned.';
            MinValue = 1;
            Editable = false;
        }
        field(4; "Sales Points"; Integer)
        {
            Caption = 'Sales Points';
            ToolTip = 'Specifies the achievement points earned specifically from sales-related activities.';
            MinValue = 0;
            Editable = false;
        }
        field(5; "Finance Points"; Integer)
        {
            Caption = 'Finance Points';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the achievement points earned specifically from finance-related activities.';
            MinValue = 0;
            Editable = false;
        }
        field(6; "Badges Earned"; Integer)
        {
            Caption = 'Badges Earned';
            ToolTip = 'Specifies the total number of achievement badges earned by the user.';
            MinValue = 0;
            Editable = false;
        }

        field(10; "Manufacturing Points"; Integer)
        {
            Caption = 'Manufacturing Points';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the achievement points earned specifically from manufacturing-related activities.';
            MinValue = 0;
            Editable = false;
        }
        field(11; "Service Points"; Integer)
        {
            Caption = 'Service Points';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the achievement points earned specifically from service-related activities.';
            MinValue = 0;
            Editable = false;
        }
        field(12; "HR Points"; Integer)
        {
            Caption = 'HR Points';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the achievement points earned specifically from human resources-related activities.';
            MinValue = 0;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
        key(TotalPoints; "Total Points")
        {
        }
        key(Level; "Current Level")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "User ID", "Total Points", "Current Level")
        {
        }
        fieldgroup(Brick; "User ID", "Total Points", "Current Level", "Badges Earned")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Current Level" = 0 then
            "Current Level" := 1;
    end;
}
