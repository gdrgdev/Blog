table 60003 "GDRG Assistant Session"
{
    Caption = 'Assistant Session Data';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Assistant Session List";
    DrillDownPageId = "GDRG Assistant Session List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies the entry number.';
            AllowInCustomizations = Never;
        }
        field(10; Answer; Text[2048])
        {
            Caption = 'Answer';
            ToolTip = 'Specifies the assistant response answer.';
        }
        field(20; "Current UTC Time"; DateTime)
        {
            Caption = 'Current UTC Time';
            ToolTip = 'Specifies the current UTC time when the session was created.';
        }
        field(30; "Current Temperature"; Decimal)
        {
            Caption = 'Current Temperature';
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the current temperature in Celsius.';
        }
        field(40; "Current Feels Like"; Decimal)
        {
            Caption = 'Current Feels Like';
            DecimalPlaces = 0 : 2;
            ToolTip = 'Specifies the current feels like temperature in Celsius.';
        }
        field(50; "Current Humidity"; Integer)
        {
            Caption = 'Current Humidity';
            ToolTip = 'Specifies the current humidity percentage.';
        }
        field(60; "Current Weather"; Text[100])
        {
            Caption = 'Current Weather';
            ToolTip = 'Specifies the current weather description.';
        }
        field(70; "Alert Event"; Text[100])
        {
            Caption = 'Alert Event';
            ToolTip = 'Specifies the weather alert event type.';
        }
        field(80; "Alert Start"; DateTime)
        {
            Caption = 'Alert Start';
            ToolTip = 'Specifies the weather alert start time.';
        }
        field(90; "Alert End"; DateTime)
        {
            Caption = 'Alert End';
            ToolTip = 'Specifies the weather alert end time.';
        }
        field(100; "Alert Description"; Text[500])
        {
            Caption = 'Alert Description';
            ToolTip = 'Specifies the weather alert description.';
        }
        field(110; "Alert Sender Name"; Text[100])
        {
            Caption = 'Alert Sender Name';
            ToolTip = 'Specifies the weather alert sender name.';
        }
        field(120; "Alert Tags"; Text[250])
        {
            Caption = 'Alert Tags';
            ToolTip = 'Specifies the weather alert tags.';
        }
        field(130; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            ToolTip = 'Specifies when the record was created.';
            AllowInCustomizations = Never;
        }
        field(140; "Last Updated"; DateTime)
        {
            Caption = 'Last Updated';
            ToolTip = 'Specifies when the record was last updated.';
            AllowInCustomizations = Never;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TimeIndex; "Current UTC Time")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Current UTC Time", "Current Weather", Answer)
        {
        }
        fieldgroup(Brick; "Current Temperature", "Current Feels Like", "Current Weather", "Alert Event")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Created Date" = 0DT then
            "Created Date" := CurrentDateTime();
        "Last Updated" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Last Updated" := CurrentDateTime();
    end;
}
