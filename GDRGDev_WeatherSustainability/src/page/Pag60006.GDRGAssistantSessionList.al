page 60006 "GDRG Assistant Session List"
{
    Caption = 'Assistant Session Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Assistant Session";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field(Answer; Rec.Answer)
                {
                }
                field("Current UTC Time"; Rec."Current UTC Time")
                {
                }
                field("Current Temperature"; Rec."Current Temperature")
                {
                }
                field("Current Feels Like"; Rec."Current Feels Like")
                {
                }
                field("Current Humidity"; Rec."Current Humidity")
                {
                }
                field("Current Weather"; Rec."Current Weather")
                {
                }
                field("Alert Event"; Rec."Alert Event")
                {
                }
                field("Alert Start"; Rec."Alert Start")
                {
                }
                field("Alert End"; Rec."Alert End")
                {
                }
                field("Alert Description"; Rec."Alert Description")
                {
                }
                field("Alert Sender Name"; Rec."Alert Sender Name")
                {
                }
                field("Alert Tags"; Rec."Alert Tags")
                {
                }
                field("Created Date"; Rec."Created Date")
                {
                }
                field("Last Updated"; Rec."Last Updated")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get Assistant Session Data")
            {
                Caption = 'Get Assistant Session Data';
                Image = GetLines;
                ToolTip = 'Retrieve assistant session data from API.';

                trigger OnAction()
                begin
                    GetAssistantSessionFromAPI();
                end;
            }
            action("Refresh")
            {
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Refresh the assistant session data list.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }


    local procedure GetAssistantSessionFromAPI()
    var
        AssistantSessionManager: Codeunit "GDRG Assistant Session Manager";
        AssistantSessionInputPage: Page "GDRG Assistant Session Input";
        PromptText: Text[2048];
        ProcessedLbl: Label 'Assistant session data retrieved successfully.';
        ErrorLbl: Label 'Failed to retrieve assistant session data. Please check the API configuration and try again.';
        DefaultPromptLbl: Label 'Does the current climate in Lleida allow for the use of electric vehicles for deliveries without the risk of running out of battery?';
    begin
        AssistantSessionInputPage.SetDefaults(DefaultPromptLbl);

        if AssistantSessionInputPage.RunModal() = Action::OK then begin
            PromptText := AssistantSessionInputPage.GetPrompt();

            if PromptText = '' then
                exit;

            if AssistantSessionManager.GetAssistantSessionData(PromptText) then begin
                Message(ProcessedLbl);
                CurrPage.Update(false);
            end else
                Message(ErrorLbl);
        end;
    end;
}
