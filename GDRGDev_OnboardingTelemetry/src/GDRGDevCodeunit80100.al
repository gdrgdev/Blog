codeunit 80100 "GL Entry Signal" implements "Onboarding Signal"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = r;

    procedure IsOnboarded(): Boolean
    var
        GLEntry: Record "G/L Entry";
        OnboardingThreshold: Integer;
    begin
        OnboardingThreshold := 1000;

        exit(GLEntry.Count() >= OnboardingThreshold);
    end;
}