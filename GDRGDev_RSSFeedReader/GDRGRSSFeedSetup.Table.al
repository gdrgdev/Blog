table 80100 "GDRG RSS Feed Setup"
{
    DataClassification = CustomerContent;
    Caption = 'RSS Feed Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
            ToolTip = 'Specifies the primary key.';
            NotBlank = true;
            AllowInCustomizations = Never;
        }
        field(10; "Default Refresh Minutes"; Integer)
        {
            Caption = 'Default Refresh Minutes';
            ToolTip = 'Specifies the default refresh interval in minutes for RSS feeds.';
            InitValue = 60;
            MinValue = 5;
        }
        field(11; "Keep Entries Days"; Integer)
        {
            Caption = 'Keep Entries Days';
            ToolTip = 'Specifies the number of days to keep RSS entries before cleanup.';
            InitValue = 30;
            MinValue = 1;
        }
        field(12; "Last Cleanup DateTime"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Cleanup DateTime';
            ToolTip = 'Specifies when the last cleanup was executed.';
            Editable = false;
            AllowInCustomizations = Never;
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
        fieldgroup(DropDown; "Default Refresh Minutes", "Keep Entries Days")
        {
        }
        fieldgroup(Brick; "Default Refresh Minutes", "Keep Entries Days", "Last Cleanup DateTime")
        {
        }
    }

    procedure GetInstance(): Record "GDRG RSS Feed Setup"
    begin
        if not Get() then begin
            Init();
            "Primary Key" := '';
            Insert();
        end;
        exit(Rec);
    end;
}
