codeunit 50100 "GDRG Forward Link Mgt."
{
    Permissions = tabledata "Named Forward Link" = RIMD;

    var
        CustomGeneralValidationTok: Label 'CUSTOM_GENERAL_VALIDATION', Locked = true;
        CustomGeneralValidationMsg: Label 'General validation help - Solution guide';
        CustomWorkflowHelpTok: Label 'CUSTOM_WORKFLOW_HELP', Locked = true;
        CustomWorkflowHelpMsg: Label 'Custom workflow help';
        CustomIntegrationPBITok: Label 'CUSTOM_INTEGRATION_PBI', Locked = true;
        CustomIntegrationPBIMsg: Label 'Power BI integration - Solutions';

    procedure AddMyCustomLinks()
    var
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
    begin
        ForwardLinkMgt.AddLink(
            CustomGeneralValidationTok,
            CustomGeneralValidationMsg,
            'https://docs.microsoft.com/en-us/dynamics365/business-central/ui-work-product'
        );

        ForwardLinkMgt.AddLink(
            CustomWorkflowHelpTok,
            CustomWorkflowHelpMsg,
            'https://docs.microsoft.com/en-us/dynamics365/business-central/across-workflow'
        );

        ForwardLinkMgt.AddLink(
            CustomIntegrationPBITok,
            CustomIntegrationPBIMsg,
            'https://docs.microsoft.com/en-us/dynamics365/business-central/admin-powerbi'
        );
    end;

    procedure GetHelpCodeForCustomValidation(): Code[30]
    begin
        exit(CustomGeneralValidationTok);
    end;

    procedure GetHelpCodeForCustomWorkflow(): Code[30]
    begin
        exit(CustomWorkflowHelpTok);
    end;

    procedure GetHelpCodeForCustomIntegration(): Code[30]
    begin
        exit(CustomIntegrationPBITok);
    end;

    procedure ShowCustomHelp(HelpCode: Code[30])
    var
        NamedForwardLink: Record "Named Forward Link";
    begin
        if NamedForwardLink.Get(HelpCode) then begin
            Message('Help available: %1\Link: %2', NamedForwardLink.Description, NamedForwardLink.Link);
            Hyperlink(NamedForwardLink.Link);
        end else
            Message('No help found for code: %1', HelpCode);
    end;
}
