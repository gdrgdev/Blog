codeunit 80103 "Customer Signal" implements "Onboarding Signal"
{
    Access = Internal;
    Permissions = tabledata "Customer" = r;

    procedure IsOnboarded(): Boolean
    var
        recCustomer: Record "Customer";
        OnboardingThreshold: Integer;
    begin
        OnboardingThreshold := 1000;

        exit(recCustomer.Count() >= OnboardingThreshold);
    end;
}