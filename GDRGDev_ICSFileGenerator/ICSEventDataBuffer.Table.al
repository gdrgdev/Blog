table 50110 "ICS Event Data Buffer"
{
    DataClassification = SystemMetadata;
    Caption = 'ICS Event Data Buffer';
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number for the event data buffer.';
            NotBlank = true;
            AllowInCustomizations = Never;
        }
        field(10; Summary; Text[100])
        {
            Caption = 'Summary';
            ToolTip = 'Specifies the summary or title of the calendar event.';
            NotBlank = true;

            trigger OnValidate()
            begin
                if Summary = '' then
                    Error(SummaryEmptyErr);
            end;
        }
        field(20; Description; Text[2048])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the calendar event.';
        }
        field(30; "Start DateTime"; DateTime)
        {
            Caption = 'Start DateTime';
            ToolTip = 'Specifies the start date and time of the calendar event.';
            NotBlank = true;
            AllowInCustomizations = Never;

            trigger OnValidate()
            var
                TypeHelper: Codeunit "Type Helper";
            begin
                if "Start DateTime" = 0DT then
                    Error(StartDateTimeEmptyErr);

                if ("End DateTime" <> 0DT) and (TypeHelper.CompareDateTime("Start DateTime", "End DateTime") >= 0) then
                    Error(StartDateTimeBeforeEndErr);
            end;
        }
        field(40; "End DateTime"; DateTime)
        {
            Caption = 'End DateTime';
            ToolTip = 'Specifies the end date and time of the calendar event.';
            NotBlank = true;
            AllowInCustomizations = Never;

            trigger OnValidate()
            var
                TypeHelper: Codeunit "Type Helper";
            begin
                if "End DateTime" = 0DT then
                    Error(EndDateTimeEmptyErr);

                if ("Start DateTime" <> 0DT) and (TypeHelper.CompareDateTime("End DateTime", "Start DateTime") <= 0) then
                    Error(EndDateTimeAfterStartErr);
            end;
        }
        field(50; Organizer; Text[100])
        {
            Caption = 'Organizer';
            ToolTip = 'Specifies the organizer of the calendar event.';
        }
        field(60; Location; Text[250])
        {
            Caption = 'Location';
            ToolTip = 'Specifies the location where the calendar event will take place.';
        }
        field(70; Method; Text[20])
        {
            Caption = 'Method';
            ToolTip = 'Specifies the method for the calendar event (PUBLISH, REQUEST, REPLY, etc.).';
            InitValue = 'PUBLISH';
            AllowInCustomizations = Never;

            trigger OnValidate()
            begin
                if not (Method in ['PUBLISH', 'REQUEST', 'REPLY', 'CANCEL', 'REFRESH', 'COUNTER', 'DECLINECOUNTER']) then
                    Error(InvalidMethodErr);
            end;
        }
        field(80; Status; Text[20])
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the calendar event (TENTATIVE, CONFIRMED, CANCELLED).';
            InitValue = 'CONFIRMED';
            AllowInCustomizations = Never;

            trigger OnValidate()
            begin
                if not (Status in ['TENTATIVE', 'CONFIRMED', 'CANCELLED']) then
                    Error(InvalidStatusErr);
            end;
        }
        field(90; Sequence; Integer)
        {
            Caption = 'Sequence';
            ToolTip = 'Specifies the sequence number for the calendar event.';
            InitValue = 0;
            AllowInCustomizations = Never;
        }
        field(100; "Prod ID"; Text[100])
        {
            Caption = 'Product ID';
            ToolTip = 'Specifies the product identifier for the calendar event.';
            InitValue = '-//Business Central//ICS Event Export//EN';
            AllowInCustomizations = Never;
        }
        field(110; UID; Text[100])
        {
            Caption = 'Unique ID';
            ToolTip = 'Specifies the unique identifier for the calendar event.';
            AllowInCustomizations = Never;

            trigger OnValidate()
            begin
                if UID = '' then
                    UID := CreateGuid();
            end;
        }
        field(120; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            ToolTip = 'Specifies when the calendar event was created.';
            Editable = false;
            AllowInCustomizations = Never;
        }
        field(130; "All Day Event"; Boolean)
        {
            Caption = 'All Day Event';
            ToolTip = 'Specifies whether the calendar event is an all-day event.';
            InitValue = false;
        }
        field(140; Priority; Integer)
        {
            Caption = 'Priority';
            ToolTip = 'Specifies the priority level of the calendar event (0-9).';
            InitValue = 5;
            MinValue = 0;
            MaxValue = 9;
        }
        field(150; "Time Zone"; Text[50])
        {
            Caption = 'Time Zone';
            ToolTip = 'Specifies the time zone for the calendar event.';
            AllowInCustomizations = Never;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(DateTime; "Start DateTime", "End DateTime")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Summary, "Start DateTime", "End DateTime")
        {
        }
        fieldgroup(Brick; Summary, Description, "Start DateTime", Location)
        {
        }
    }

    trigger OnInsert()
    begin
        if "Created DateTime" = 0DT then
            "Created DateTime" := CurrentDateTime();

        if UID = '' then
            UID := CreateGuid();
    end;

    procedure SetDefaults()
    begin
        if Method = '' then
            Method := 'PUBLISH';

        if Status = '' then
            Status := 'CONFIRMED';

        if "Prod ID" = '' then
            "Prod ID" := '-//Business Central//ICS Event Export//EN';

        if UID = '' then
            UID := CreateGuid();

        if "Created DateTime" = 0DT then
            "Created DateTime" := CurrentDateTime();
    end;

    var
        SummaryEmptyErr: Label 'Summary cannot be empty.';
        StartDateTimeEmptyErr: Label 'Start DateTime cannot be empty.';
        StartDateTimeBeforeEndErr: Label 'Start DateTime must be before End DateTime.';
        EndDateTimeEmptyErr: Label 'End DateTime cannot be empty.';
        EndDateTimeAfterStartErr: Label 'End DateTime must be after Start DateTime.';
        InvalidMethodErr: Label 'Invalid Method. Valid values: PUBLISH, REQUEST, REPLY, CANCEL, REFRESH, COUNTER, DECLINECOUNTER.';
        InvalidStatusErr: Label 'Invalid Status. Valid values: TENTATIVE, CONFIRMED, CANCELLED.';
}
