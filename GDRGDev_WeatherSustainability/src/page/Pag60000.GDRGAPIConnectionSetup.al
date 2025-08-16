page 60000 "GDRG API Connection Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GDRG API Connection Setup";
    Caption = 'API Key Connection Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Base URL"; Rec."Base URL")
                {
                }

                field("Authentication Type"; Rec."Authentication Type")
                {
                }

                field("API Key Name"; Rec."API Key Name")
                {
                }

                field("API Key Value"; Rec."API Key Value")
                {
                }

                field("Test Endpoint"; Rec."Test Endpoint")
                {
                }
            }

            group(Status)
            {
                Caption = 'Connection Status';

                field("Connection Status"; Rec."Connection Status")
                {
                    Editable = false;
                    StyleExpr = StatusStyleText;

                    trigger OnDrillDown()
                    begin
                        if Rec."Last Error Message" <> '' then
                            Message(LastErrorLbl, Rec."Last Error Message");
                    end;
                }

                field("Last Test Date"; Rec."Last Test Date")
                {
                    Editable = false;
                }

                field("Last Error Message"; Rec."Last Error Message")
                {
                    Editable = false;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ConnectionActions)
            {
                Caption = 'Connection';

                action(TestConnection)
                {
                    Caption = 'Test Connection';
                    ToolTip = 'Test the API connection with current settings.';
                    Image = TestDatabase;

                    trigger OnAction()
                    var
                        APIConnectionManager: Codeunit "GDRG API Connection Manager";
                        Response: Text;
                    begin
                        ClearLastError();

                        if Rec."Test Endpoint" = '' then begin
                            Message(TestEndpointRequiredMsg);
                            exit;
                        end;

                        Response := APIConnectionManager.TestAPICall(Rec."Test Endpoint", 'GET');
                        if Response <> '' then
                            Message(ConnectionTestSuccessfulMsg)
                        else
                            Message(ConnectionTestFailedMsg);

                        CurrPage.Update();
                    end;
                }

                action(ViewAPICallLog)
                {
                    Caption = 'View API Call Log';
                    ToolTip = 'View the log of all API calls made by the system.';
                    Image = Log;

                    trigger OnAction()
                    begin
                        Page.Run(Page::"GDRG API Call Log");
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(MyPromotedActionTestConnection; TestConnection)
            {
            }
            actionref(MyPromotedActionViewAPICallLog; ViewAPICallLog)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec."Authentication Type" := Rec."Authentication Type"::"API Key Header";
            Rec."Test Endpoint" := '/geo/1.0/direct?q=Madrid&limit=5';
            Rec.Insert(false);
        end;
        SetStatusStyle();
    end;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;


    local procedure SetStatusStyle()
    begin
        case Rec."Connection Status" of
            Rec."Connection Status"::Connected:
                begin
                    StatusStyle := PageStyle::Favorable;
                    StatusStyleText := Format(StatusStyle);
                end;
            Rec."Connection Status"::Failed:
                begin
                    StatusStyle := PageStyle::Unfavorable;
                    StatusStyleText := Format(StatusStyle);
                end;
            Rec."Connection Status"::Testing:
                begin
                    StatusStyle := PageStyle::Ambiguous;
                    StatusStyleText := Format(StatusStyle);
                end;
            else begin
                StatusStyle := PageStyle::Standard;
                StatusStyleText := Format(StatusStyle);
            end;
        end;
    end;

    var
        LastErrorLbl: Label 'Last Error: %1', Comment = '%1 = Error message';
        ConnectionTestSuccessfulMsg: Label 'Connection test successful!', Comment = 'Success message when API connection test passes';
        ConnectionTestFailedMsg: Label 'Connection test failed. Check the error message for details.', Comment = 'Error message when API connection test fails';
        TestEndpointRequiredMsg: Label 'Please enter a Test Endpoint before running the connection test.', Comment = 'Validation message when test endpoint is required';
        StatusStyle: PageStyle;
        StatusStyleText: Text;
}
