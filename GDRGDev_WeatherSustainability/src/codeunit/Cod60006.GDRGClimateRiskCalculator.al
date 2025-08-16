codeunit 60006 "GDRG Climate Risk Calculator"
{
    Access = Internal;

    procedure CalculateEstimatedCO2Impact(documentType: Enum "Sales Document Type"; location: Text[100]): Decimal
    var
        baseCO2: Decimal;
        distanceMultiplier: Decimal;
    begin
        case documentType of
            documentType::Order:
                baseCO2 := 25.0;
            documentType::"Return Order":
                baseCO2 := 30.0;
            else
                baseCO2 := 20.0;
        end;

        distanceMultiplier := calculateLocationMultiplier(location);

        exit(baseCO2 * distanceMultiplier);
    end;

    procedure CalculateWeatherAdjustedCO2(estimatedCO2: Decimal; riskLevel: Enum "GDRG Climate Risk Level"): Decimal
    var
        riskMultiplier: Decimal;
    begin
        case riskLevel of
            riskLevel::Low:
                riskMultiplier := 1.0;
            riskLevel::Medium:
                riskMultiplier := 1.3;
            riskLevel::High:
                riskMultiplier := 1.8;
            riskLevel::Critical:
                riskMultiplier := 2.5;
            else
                riskMultiplier := 1.0;
        end;

        exit(estimatedCO2 * riskMultiplier);
    end;

    procedure CalculateCO2SavingsPotential(estimatedCO2: Decimal; weatherAdjustedCO2: Decimal): Decimal
    begin
        if weatherAdjustedCO2 > estimatedCO2 then
            exit(weatherAdjustedCO2 - estimatedCO2)
        else
            exit(0);
    end;

    procedure CalculateRiskScore(temperature: Decimal; weatherCondition: Text[100]; hasAlerts: Boolean): Decimal
    var
        tempScore: Decimal;
        conditionScore: Decimal;
        alertScore: Decimal;
    begin
        tempScore := calculateTemperatureRisk(temperature);

        conditionScore := calculateWeatherConditionRisk(weatherCondition);

        if hasAlerts then
            alertScore := 30.0
        else
            alertScore := 0.0;

        exit((tempScore + conditionScore + alertScore) / 3);
    end;

    procedure DetermineRiskLevel(riskScore: Decimal): Enum "GDRG Climate Risk Level"
    begin
        case true of
            riskScore <= 25:
                exit("GDRG Climate Risk Level"::Low);
            riskScore <= 50:
                exit("GDRG Climate Risk Level"::Medium);
            riskScore <= 75:
                exit("GDRG Climate Risk Level"::High);
            else
                exit("GDRG Climate Risk Level"::Critical);
        end;
    end;

    procedure GenerateSustainabilityScore(co2Savings: Decimal; riskLevel: Enum "GDRG Climate Risk Level"): Text[10]
    var
        score: Integer;
    begin
        score := calculateBaseCO2Score(co2Savings);
        score := adjustScoreByRiskLevel(score, riskLevel);
        exit(convertScoreToGrade(score));
    end;

    local procedure calculateBaseCO2Score(co2Savings: Decimal): Integer
    begin
        case true of
            co2Savings >= 15:
                exit(90);
            co2Savings >= 10:
                exit(80);
            co2Savings >= 5:
                exit(70);
            co2Savings >= 1:
                exit(60);
            else
                exit(50);
        end;
    end;

    local procedure adjustScoreByRiskLevel(score: Integer; riskLevel: Enum "GDRG Climate Risk Level"): Integer
    begin
        case riskLevel of
            riskLevel::Low:
                exit(score + 10);
            riskLevel::Medium:
                exit(score - 5);
            riskLevel::High:
                exit(score - 15);
            riskLevel::Critical:
                exit(score - 25);
            else
                exit(score);
        end;
    end;

    local procedure convertScoreToGrade(score: Integer): Text[10]
    begin
        case true of
            score >= 95:
                exit('A+');
            score >= 85:
                exit('A');
            score >= 75:
                exit('B');
            score >= 65:
                exit('C');
            else
                exit('D');
        end;
    end;

    procedure GenerateOptimizationRecommendation(riskLevel: Enum "GDRG Climate Risk Level"; plannedDate: Date; weatherCondition: Text[100]): Text[250]
    begin
        case riskLevel of
            riskLevel::Low:
                exit('Optimal conditions detected. Proceed as planned for maximum efficiency.');
            riskLevel::Medium:
                exit('Moderate risk. Consider consolidating shipments or using eco-friendly transport.');
            riskLevel::High:
                exit('High climate risk. Recommend postponing 2-3 days or using climate-controlled transport.');
            riskLevel::Critical:
                exit('Critical weather alert! Delay shipment until conditions improve to avoid failures.');
            else
                exit('Optimize delivery schedule to avoid adverse conditions. Consider moving ±2 days for CO2 reduction.');
        end;
    end;

    local procedure calculateLocationMultiplier(location: Text[100]): Decimal
    begin
        case true of
            StrPos(LowerCase(location), 'madrid') > 0:
                exit(1.2);
            StrPos(LowerCase(location), 'barcelona') > 0:
                exit(1.1);
            StrPos(LowerCase(location), 'lleida') > 0:
                exit(1.0);
            StrPos(LowerCase(location), 'international') > 0:
                exit(2.5);
            else
                exit(1.5);
        end;
    end;

    local procedure calculateTemperatureRisk(temperature: Decimal): Decimal
    begin
        case true of
            (temperature < -10) or (temperature > 40):
                exit(80.0);
            (temperature < 0) or (temperature > 35):
                exit(60.0);
            (temperature < 5) or (temperature > 30):
                exit(40.0);
            else
                exit(10.0);
        end;
    end;

    local procedure calculateWeatherConditionRisk(weatherCondition: Text[100]): Decimal
    var
        condition: Text;
    begin
        condition := LowerCase(weatherCondition);

        case true of
            StrPos(condition, 'storm') > 0:
                exit(90.0);
            StrPos(condition, 'heavy rain') > 0:
                exit(70.0);
            StrPos(condition, 'snow') > 0:
                exit(60.0);
            StrPos(condition, 'rain') > 0:
                exit(40.0);
            StrPos(condition, 'cloudy') > 0:
                exit(20.0);
            StrPos(condition, 'clear') > 0:
                exit(5.0);
            else
                exit(30.0);
        end;
    end;
}
