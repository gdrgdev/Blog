page 50104 "ICS Event Configuration"
{
    PageType = Card;
    Caption = 'Configure Calendar Event';
    SourceTable = "ICS Event Data Buffer";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(EventDetails)
            {
                Caption = 'Event Details';

                field(Summary; Rec.Summary)
                {
                    ApplicationArea = All;
                    Caption = 'Event Title';
                    ShowMandatory = true;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    MultiLine = true;
                }

                field(Location; Rec.Location)
                {
                    ApplicationArea = All;
                    Caption = 'Location';
                }

                field(Organizer; Rec.Organizer)
                {
                    ApplicationArea = All;
                    Caption = 'Organizer';
                }

                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    Caption = 'Priority';
                }
            }

            group(DateTimeSettings)
            {
                Caption = 'Date & Time Settings';

                field(StartDate; StartDateVar)
                {
                    ApplicationArea = All;
                    Caption = 'Start Date';
                    ToolTip = 'Specifies the start date for the calendar event.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        UpdateStartDateTime();
                        if EndDateVar < StartDateVar then
                            EndDateVar := StartDateVar;
                        UpdateEndDateTime();
                    end;
                }

                field(StartTime; StartTimeVar)
                {
                    ApplicationArea = All;
                    Caption = 'Start Time';
                    ToolTip = 'Specifies the start time for the calendar event.';

                    trigger OnValidate()
                    begin
                        UpdateStartDateTime();
                    end;
                }

                field(EndDate; EndDateVar)
                {
                    ApplicationArea = All;
                    Caption = 'End Date';
                    ToolTip = 'Specifies the end date for the calendar event.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        UpdateEndDateTime();
                    end;
                }

                field(EndTime; EndTimeVar)
                {
                    ApplicationArea = All;
                    Caption = 'End Time';
                    ToolTip = 'Specifies the end time for the calendar event.';

                    trigger OnValidate()
                    begin
                        UpdateEndDateTime();
                    end;
                }

                field(AllDayEvent; Rec."All Day Event")
                {
                    ApplicationArea = All;
                    Caption = 'All Day Event';

                    trigger OnValidate()
                    begin
                        if Rec."All Day Event" then begin
                            StartTimeVar := 0T;
                            EndTimeVar := 0T;
                            UpdateStartDateTime();
                            UpdateEndDateTime();
                        end else begin
                            if StartTimeVar = 0T then
                                StartTimeVar := 090000T;
                            if EndTimeVar = 0T then
                                EndTimeVar := 100000T;
                            UpdateStartDateTime();
                            UpdateEndDateTime();
                        end;
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateEvent)
            {
                ApplicationArea = All;
                Caption = 'Create Calendar Event';
                ToolTip = 'Specifies the action to create and configure a calendar event.';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ValidateRequiredFields();
                    EventCreated := true;
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SplitDateTime();
    end;

    var
        StartDateVar: Date;
        StartTimeVar: Time;
        EndDateVar: Date;
        EndTimeVar: Time;
        EventCreated: Boolean;
        StartDateEmptyErr: Label 'Start date cannot be empty.';
        EndDateEmptyErr: Label 'End date cannot be empty.';
        PastDateErr: Label 'Cannot create events in the past. Please select a future date.';
        EndDateBeforeStartErr: Label 'End date cannot be before start date.';
        PastTimeErr: Label 'Cannot create events in the past. Please select a future time.';
        EndTimeBeforeStartErr: Label 'End time must be after start time for same-day events.';

    local procedure SplitDateTime()
    begin
        if Rec."Start DateTime" <> 0DT then begin
            StartDateVar := Rec."Start DateTime".Date();
            StartTimeVar := Rec."Start DateTime".Time();
        end;

        if Rec."End DateTime" <> 0DT then begin
            EndDateVar := Rec."End DateTime".Date();
            EndTimeVar := Rec."End DateTime".Time();
        end;
    end;

    local procedure UpdateStartDateTime()
    begin
        if StartDateVar <> 0D then
            if Rec."All Day Event" then
                Rec."Start DateTime" := CreateDateTime(StartDateVar, 0T)
            else
                Rec."Start DateTime" := CreateDateTime(StartDateVar, StartTimeVar);
    end;

    local procedure UpdateEndDateTime()
    begin
        if EndDateVar <> 0D then
            if Rec."All Day Event" then
                Rec."End DateTime" := CreateDateTime(EndDateVar, 0T)
            else
                Rec."End DateTime" := CreateDateTime(EndDateVar, EndTimeVar);
    end;

    local procedure ValidateRequiredFields()
    begin
        Rec.TestField(Summary);
        ValidateDates();
        ValidateTimes();
    end;

    local procedure ValidateDates()
    begin
        if StartDateVar = 0D then
            Error(StartDateEmptyErr);

        if EndDateVar = 0D then
            Error(EndDateEmptyErr);

        if StartDateVar < Today() then
            Error(PastDateErr);

        if EndDateVar < StartDateVar then
            Error(EndDateBeforeStartErr);
    end;

    local procedure ValidateTimes()
    begin
        if Rec."All Day Event" then
            exit;

        if (StartDateVar = Today()) and (StartTimeVar < Time()) then
            Error(PastTimeErr);

        if (StartDateVar = EndDateVar) and (EndTimeVar <= StartTimeVar) then
            Error(EndTimeBeforeStartErr);
    end;

    procedure LoadEventData(var SourceEventBuffer: Record "ICS Event Data Buffer")
    begin
        Rec.Reset();
        Rec.DeleteAll(false);
        Rec.Init();
        Rec.TransferFields(SourceEventBuffer, false);
        Rec."Entry No." := 1;
        Rec.Insert(false);
        SplitDateTime();
    end;

    procedure GetEventData(var TargetEventBuffer: Record "ICS Event Data Buffer")
    begin
        UpdateStartDateTime();
        UpdateEndDateTime();
        TargetEventBuffer.TransferFields(Rec, false);
    end;

    procedure WasEventCreated(): Boolean
    begin
        exit(EventCreated);
    end;
}
