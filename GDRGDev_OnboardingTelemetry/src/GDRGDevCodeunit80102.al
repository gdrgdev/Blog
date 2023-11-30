codeunit 80102 "Value Entry Signal" implements "Onboarding Signal"
{
    Access = Internal;
    Permissions = tabledata "Value Entry" = r;

    procedure IsOnboarded(): Boolean
    var
        VlEntry: Record "Value Entry";
        OnboardingThreshold: Integer;
    begin
        OnboardingThreshold := 1000;

        exit(VlEntry.Count() >= OnboardingThreshold);
    end;
}