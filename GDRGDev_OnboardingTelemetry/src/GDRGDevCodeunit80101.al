codeunit 80101 "Register Onboarding Signals"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        RegisterOnboardingSignals();
    end;

    internal procedure RegisterOnboardingSignals()
    var
        Company: Record Company;
        OnboardingSignal: Codeunit "Onboarding Signal";
        EnvironmentInfo: Codeunit "Environment Information";
        OnboardingSignalType: Enum "Onboarding Signal Type";
    begin
        if not Company.Get(CompanyName()) then
            exit;

        if Company."Evaluation Company" then
            exit;

        if EnvironmentInfo.IsSandbox() then
            exit;

        OnboardingSignal.RegisterNewOnboardingSignal(Company.Name, OnboardingSignalType::"GL Entry Signal");
        OnboardingSignal.RegisterNewOnboardingSignal(Company.Name, OnboardingSignalType::"Value Entry Signal");
        OnboardingSignal.RegisterNewOnboardingSignal(Company.Name, OnboardingSignalType::"Customer Signal");
    end;
}