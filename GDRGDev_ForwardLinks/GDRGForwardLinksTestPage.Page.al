page 50100 "GDRG Forward Links Test Page"
{
    PageType = Card;
    Caption = 'GDRG - Forward Links Test';
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Help Links Test';

                field(TestInfo; 'Use the buttons to test custom help links')
                {
                    Editable = false;
                    ShowCaption = false;
                    Style = StrongAccent;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(TestLinks)
            {
                Caption = 'Test Links';

                action(TestGeneralValidation)
                {
                    Caption = 'Test General Validation';
                    Image = ErrorLog;
                    ToolTip = 'Simulates a general validation error with help link to BC documentation.';

                    trigger OnAction()
                    var
                        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
                    begin
                        GDRGForwardLinkMgt.ShowCustomHelp(GDRGForwardLinkMgt.GetHelpCodeForCustomValidation());
                    end;
                }

                action(TestWorkflowHelp)
                {
                    Caption = 'Test Workflow Help';
                    Image = Workflow;
                    ToolTip = 'Shows help for custom workflows.';

                    trigger OnAction()
                    var
                        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
                    begin
                        GDRGForwardLinkMgt.ShowCustomHelp(GDRGForwardLinkMgt.GetHelpCodeForCustomWorkflow());
                    end;
                }

                action(TestPowerBIIntegration)
                {
                    Caption = 'Test Power BI Integration';
                    Image = Import;
                    ToolTip = 'Simulates a Power BI integration error with help link.';

                    trigger OnAction()
                    var
                        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
                    begin
                        GDRGForwardLinkMgt.ShowCustomHelp(GDRGForwardLinkMgt.GetHelpCodeForCustomIntegration());
                    end;
                }

                action(LoadAllLinks)
                {
                    Caption = 'Load All Links';
                    Image = Import;
                    ToolTip = 'Loads all custom links.';

                    trigger OnAction()
                    var
                        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
                    begin
                        GDRGForwardLinkMgt.AddMyCustomLinks();
                        Message('Custom links loaded successfully.');
                    end;
                }

                action(OpenForwardLinksPage)
                {
                    Caption = 'View Links List';
                    Image = List;
                    ToolTip = 'Opens the page with all configured links.';

                    trigger OnAction()
                    var
                        ForwardLinksPage: Page "Forward Links";
                    begin
                        ForwardLinksPage.Run();
                    end;
                }
            }

            group(TestErrorScenarios)
            {
                Caption = 'Simulate Real Errors (Microsoft Pattern)';

                action(SimulateCustomExtensionError)
                {
                    Caption = 'Custom Extension Error';
                    Image = ErrorLog;
                    ToolTip = 'Simulates Microsoft real pattern: ErrorMessageMgt.LogMessage with general validation ForwardLink.';

                    trigger OnAction()
                    var
                        Item: Record Item;
                        TempErrorMessage: Record "Error Message" temporary;
                        ErrorMessageMgt: Codeunit "Error Message Management";
                        ErrorMessageHandler: Codeunit "Error Message Handler";
                        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
                        ErrorMessages: Page "Error Messages";
                        MessageType: Option Error,Warning,Information;
                    begin
                        GDRGForwardLinkMgt.AddMyCustomLinks();

                        ErrorMessageMgt.Activate(ErrorMessageHandler);

                        MessageType := MessageType::Warning;

                        Item.Init();
                        Item."No." := 'DEMO001';
                        Item.Description := 'Demo product';

                        ErrorMessageMgt.LogMessage(
                            MessageType,
                            0,
                            'Custom extension validation failed. Please check your extension configuration and setup.',
                            Item,
                            Item.FieldNo("No."),
                            GDRGForwardLinkMgt.GetHelpCodeForCustomValidation());

                        ErrorMessageHandler.AppendTo(TempErrorMessage);
                        if TempErrorMessage.FindFirst() then begin
                            ErrorMessages.SetRecords(TempErrorMessage);
                            ErrorMessages.Run();
                        end else
                            Message('Error registered correctly. If error page does not appear, check VS Code error panel.');
                    end;
                }

                action(SimulateWorkflowError)
                {
                    Caption = 'Workflow Approval Error';
                    Image = ErrorLog;
                    ToolTip = 'Simulates a workflow approval error using Microsoft pattern.';

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        TempErrorMessage: Record "Error Message" temporary;
                        ErrorMessageMgt: Codeunit "Error Message Management";
                        ErrorMessageHandler: Codeunit "Error Message Handler";
                        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
                        ErrorMessages: Page "Error Messages";
                        MessageType: Option Error,Warning,Information;
                    begin
                        GDRGForwardLinkMgt.AddMyCustomLinks();

                        ErrorMessageMgt.Activate(ErrorMessageHandler);

                        MessageType := MessageType::Error;

                        Customer.Init();
                        Customer."No." := 'CUST001';
                        Customer.Name := 'Demo customer';

                        ErrorMessageMgt.LogMessage(
                            MessageType,
                            0,
                            'Custom validation error for customer CUST001. Workflow process requires additional approval.',
                            Customer,
                            Customer.FieldNo("No."),
                            GDRGForwardLinkMgt.GetHelpCodeForCustomWorkflow());

                        ErrorMessageHandler.AppendTo(TempErrorMessage);
                        if TempErrorMessage.FindFirst() then begin
                            ErrorMessages.SetRecords(TempErrorMessage);
                            ErrorMessages.Run();
                        end else
                            Message('Error registered with link to workflow documentation!');
                    end;
                }

                action(SimulatePowerBIError)
                {
                    Caption = 'Power BI Connection Error';
                    Image = Import;
                    ToolTip = 'Simulates a Power BI integration error with help link.';

                    trigger OnAction()
                    var
                        TempErrorMessage: Record "Error Message" temporary;
                        ErrorMessageMgt: Codeunit "Error Message Management";
                        ErrorMessageHandler: Codeunit "Error Message Handler";
                        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
                        ErrorMessages: Page "Error Messages";
                        DummyRecordRef: RecordRef;
                        MessageType: Option Error,Warning,Information;
                    begin
                        GDRGForwardLinkMgt.AddMyCustomLinks();

                        ErrorMessageMgt.Activate(ErrorMessageHandler);

                        MessageType := MessageType::Error;

                        ErrorMessageMgt.LogMessage(
                            MessageType,
                            0,
                            'Power BI connection failed. Check your Power BI workspace configuration and credentials.',
                            DummyRecordRef,
                            0,
                            GDRGForwardLinkMgt.GetHelpCodeForCustomIntegration());

                        ErrorMessageHandler.AppendTo(TempErrorMessage);
                        if TempErrorMessage.FindFirst() then begin
                            ErrorMessages.SetRecords(TempErrorMessage);
                            ErrorMessages.Run();
                        end else
                            Message('Integration error registered with link to solutions documentation!');
                    end;
                }

                action(SimulateMultipleErrors)
                {
                    Caption = 'Simulate Multiple Errors';
                    Image = ErrorLog;
                    ToolTip = 'Simulates multiple errors with different ForwardLinks using Microsoft complete pattern.';

                    trigger OnAction()
                    var
                        Item: Record Item;
                        Customer: Record Customer;
                        TempErrorMessage: Record "Error Message" temporary;
                        ErrorMessageMgt: Codeunit "Error Message Management";
                        ErrorMessageHandler: Codeunit "Error Message Handler";
                        GDRGForwardLinkMgt: Codeunit "GDRG Forward Link Mgt.";
                        ErrorMessages: Page "Error Messages";
                        MessageType: Option Error,Warning,Information;
                    begin
                        GDRGForwardLinkMgt.AddMyCustomLinks();

                        ErrorMessageMgt.Activate(ErrorMessageHandler);

                        Item.Init();
                        Item."No." := 'ITEM001';
                        Item.Description := 'Test product 1';
                        MessageType := MessageType::Warning;
                        ErrorMessageMgt.LogMessage(
                            MessageType,
                            0,
                            'Extension validation error: Custom business rule validation failed.',
                            Item,
                            Item.FieldNo("No."),
                            GDRGForwardLinkMgt.GetHelpCodeForCustomValidation());

                        Customer.Init();
                        Customer."No." := 'CUST001';
                        Customer.Name := 'Test customer';
                        MessageType := MessageType::Error;
                        ErrorMessageMgt.LogMessage(
                            MessageType,
                            0,
                            'Customer CUST001 requires workflow approval before processing.',
                            Customer,
                            Customer.FieldNo("No."),
                            GDRGForwardLinkMgt.GetHelpCodeForCustomWorkflow());

                        MessageType := MessageType::Error;
                        ErrorMessageMgt.LogMessage(
                            MessageType,
                            0,
                            'Power BI data refresh error. Unable to connect to Power BI service.',
                            Item,
                            0,
                            GDRGForwardLinkMgt.GetHelpCodeForCustomIntegration());

                        ErrorMessageHandler.AppendTo(TempErrorMessage);
                        if TempErrorMessage.FindFirst() then begin
                            ErrorMessages.SetRecords(TempErrorMessage);
                            ErrorMessages.Run();
                        end else
                            Message('No errors found to display.');
                    end;
                }
            }
        }
    }
}
