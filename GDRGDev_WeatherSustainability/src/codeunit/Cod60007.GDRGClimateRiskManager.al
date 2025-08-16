codeunit 60007 "GDRG Climate Risk Manager"
{
    Access = Internal;
    Permissions = tabledata "Sales Header" = r,
                  tabledata "Purchase Header" = r,
                  tabledata Customer = r,
                  tabledata Vendor = r,
                  tabledata "GDRG Weather Data" = r,
                  tabledata "GDRG Assistant Session" = r,
                  tabledata "GDRG Order Climate Risk" = rimd;

    procedure AnalyzeOrderClimateRisk(var orderClimateRisk: Record "GDRG Order Climate Risk")
    var
        salesHeader: Record "Sales Header";
        purchaseHeader: Record "Purchase Header";
        weatherData: Record "GDRG Weather Data";
        calculator: Codeunit "GDRG Climate Risk Calculator";
        estimatedCO2: Decimal;
        weatherAdjustedCO2: Decimal;
        riskScore: Decimal;
        riskLevel: Enum "GDRG Climate Risk Level";
        hasWeatherAlerts: Boolean;
    begin
        if orderClimateRisk."Is Sales Order" then
            getOrderDataFromSales(orderClimateRisk, salesHeader)
        else
            getOrderDataFromPurchase(orderClimateRisk, purchaseHeader);

        getWeatherDataForOrder(orderClimateRisk, weatherData, hasWeatherAlerts);

        estimatedCO2 := calculator.CalculateEstimatedCO2Impact(orderClimateRisk."Document Type", 'Default Location');
        riskScore := calculator.CalculateRiskScore(weatherData.Temperature, weatherData."Weather Description", hasWeatherAlerts);
        riskLevel := calculator.DetermineRiskLevel(riskScore);
        weatherAdjustedCO2 := calculator.CalculateWeatherAdjustedCO2(estimatedCO2, riskLevel);

        updateOrderClimateRiskRecord(orderClimateRisk, calculator, estimatedCO2, weatherAdjustedCO2, riskScore, riskLevel);
    end;

    procedure AnalyzeOrdersInDateRange(startDate: Date; endDate: Date): Integer
    var
        salesHeader: Record "Sales Header";
        purchaseHeader: Record "Purchase Header";
        orderClimateRisk: Record "GDRG Order Climate Risk";
        ordersAnalyzed: Integer;
    begin
        ordersAnalyzed := 0;

        salesHeader.SetRange("Document Type", salesHeader."Document Type"::Order);
        salesHeader.SetRange("Shipment Date", startDate, endDate);

        if salesHeader.FindSet() then
            repeat
                if createOrUpdateClimateRiskRecord(salesHeader, orderClimateRisk) then begin
                    AnalyzeOrderClimateRisk(orderClimateRisk);
                    ordersAnalyzed += 1;
                end;
            until salesHeader.Next() = 0;

        purchaseHeader.SetRange("Document Type", purchaseHeader."Document Type"::Order);
        purchaseHeader.SetRange("Expected Receipt Date", startDate, endDate);

        if purchaseHeader.FindSet() then
            repeat
                if createOrUpdateClimateRiskRecord(purchaseHeader, orderClimateRisk) then begin
                    AnalyzeOrderClimateRisk(orderClimateRisk);
                    ordersAnalyzed += 1;
                end;
            until purchaseHeader.Next() = 0;

        if ordersAnalyzed = 0 then begin
            salesHeader.Reset();
            salesHeader.SetRange("Document Type", salesHeader."Document Type"::Order);
            if salesHeader.FindSet() then
                repeat
                    if createOrUpdateClimateRiskRecord(salesHeader, orderClimateRisk) then begin
                        AnalyzeOrderClimateRisk(orderClimateRisk);
                        ordersAnalyzed += 1;
                    end;
                until (salesHeader.Next() = 0) or (ordersAnalyzed >= 5);

            purchaseHeader.Reset();
            purchaseHeader.SetRange("Document Type", purchaseHeader."Document Type"::Order);
            if purchaseHeader.FindSet() then
                repeat
                    if createOrUpdateClimateRiskRecord(purchaseHeader, orderClimateRisk) then begin
                        AnalyzeOrderClimateRisk(orderClimateRisk);
                        ordersAnalyzed += 1;
                    end;
                until (purchaseHeader.Next() = 0) or (ordersAnalyzed >= 10);
        end;

        exit(ordersAnalyzed);
    end;

    procedure GenerateDemoData(): Integer
    var
        demoRecords: Integer;
        recordExistsBeforeInsert: Boolean;
    begin
        demoRecords := 0;

        recordExistsBeforeInsert := checkDemoRecordExists('SO001');
        createDemoRecordWithWeather('SO001', 'Customer A', 'Madrid, Spain', 40.4168, -3.7038, Today() + 3, "GDRG Climate Risk Level"::Medium, 'Clear sky', 22.5);
        if not recordExistsBeforeInsert then
            demoRecords += 1;

        recordExistsBeforeInsert := checkDemoRecordExists('SO002');
        createDemoRecordWithWeather('SO002', 'Customer B', 'Barcelona, Spain', 41.3851, 2.1734, Today() + 5, "GDRG Climate Risk Level"::Low, 'Partly cloudy', 18.0);
        if not recordExistsBeforeInsert then
            demoRecords += 1;

        recordExistsBeforeInsert := checkDemoRecordExists('PO001');
        createDemoRecordWithWeather('PO001', 'Vendor X', 'Lleida, Spain', 41.6143, 0.6392, Today() + 7, "GDRG Climate Risk Level"::High, 'Heavy rain', 15.5);
        if not recordExistsBeforeInsert then
            demoRecords += 1;

        recordExistsBeforeInsert := checkDemoRecordExists('SO003');
        createDemoRecordWithWeather('SO003', 'Customer C', 'Sevilla, Spain', 37.3886, -5.9823, Today() + 10, "GDRG Climate Risk Level"::Critical, 'Thunderstorm', 8.0);
        if not recordExistsBeforeInsert then
            demoRecords += 1;

        exit(demoRecords);
    end;

    procedure GetSustainabilityMetrics(var totalOrders: Integer; var ordersAtRisk: Integer; var avgRiskScore: Decimal; var totalCO2Savings: Decimal)
    var
        orderClimateRisk: Record "GDRG Order Climate Risk";
    begin
        totalOrders := 0;
        ordersAtRisk := 0;
        avgRiskScore := 0;
        totalCO2Savings := 0;

        if orderClimateRisk.FindSet() then
            repeat
                totalOrders += 1;

                if orderClimateRisk."Climate Risk Level" in [orderClimateRisk."Climate Risk Level"::Medium, orderClimateRisk."Climate Risk Level"::High, orderClimateRisk."Climate Risk Level"::Critical] then
                    ordersAtRisk += 1;

                avgRiskScore += orderClimateRisk."Risk Score";
                totalCO2Savings += orderClimateRisk."CO2 Savings Potential";
            until orderClimateRisk.Next() = 0;

        if totalOrders > 0 then
            avgRiskScore := avgRiskScore / totalOrders;
    end;

    local procedure getOrderDataFromSales(var orderClimateRisk: Record "GDRG Order Climate Risk"; var salesHeader: Record "Sales Header")
    var
        customer: Record Customer;
    begin
        if salesHeader.Get(orderClimateRisk."Document Type", orderClimateRisk."Document No.") then begin
            orderClimateRisk."Customer/Vendor No." := salesHeader."Sell-to Customer No.";
            orderClimateRisk."Planned Date" := salesHeader."Shipment Date";
            orderClimateRisk."Is Sales Order" := true;

            orderClimateRisk.Latitude := salesHeader."GDRG Latitude";
            orderClimateRisk.Longitude := salesHeader."GDRG Longitude";

            if customer.Get(salesHeader."Sell-to Customer No.") then
                orderClimateRisk."Customer/Vendor Name" := customer.Name;
        end;
    end;

    local procedure getOrderDataFromPurchase(var orderClimateRisk: Record "GDRG Order Climate Risk"; var purchaseHeader: Record "Purchase Header")
    var
        vendor: Record Vendor;
    begin
        if purchaseHeader.Get(purchaseHeader."Document Type"::Order, orderClimateRisk."Document No.") then begin
            orderClimateRisk."Customer/Vendor No." := purchaseHeader."Buy-from Vendor No.";
            orderClimateRisk."Planned Date" := purchaseHeader."Expected Receipt Date";
            orderClimateRisk."Is Sales Order" := false;

            orderClimateRisk.Latitude := purchaseHeader."GDRG Latitude";
            orderClimateRisk.Longitude := purchaseHeader."GDRG Longitude";

            if vendor.Get(purchaseHeader."Buy-from Vendor No.") then
                orderClimateRisk."Customer/Vendor Name" := vendor.Name;
        end;
    end;

    local procedure getWeatherDataForOrder(var orderClimateRisk: Record "GDRG Order Climate Risk"; var weatherData: Record "GDRG Weather Data"; var hasAlerts: Boolean)
    var
        salesHeader: Record "Sales Header";
        purchaseHeader: Record "Purchase Header";
    begin
        if orderClimateRisk."Is Sales Order" then begin
            if salesHeader.Get(orderClimateRisk."Document Type", orderClimateRisk."Document No.") then begin
                orderClimateRisk."Weather Condition" := salesHeader."GDRG Weather Description";
                orderClimateRisk."Temperature" := salesHeader."GDRG Temperature";

                weatherData.Temperature := salesHeader."GDRG Temperature";
                weatherData."Weather Description" := salesHeader."GDRG Weather Description";
                weatherData.Humidity := salesHeader."GDRG Humidity";
            end else
                getWeatherDataFromCoordinates(orderClimateRisk);
        end else
            if purchaseHeader.Get(purchaseHeader."Document Type"::Order, orderClimateRisk."Document No.") then begin
                orderClimateRisk."Weather Condition" := purchaseHeader."GDRG Weather Description";
                orderClimateRisk."Temperature" := purchaseHeader."GDRG Temperature";

                weatherData.Temperature := purchaseHeader."GDRG Temperature";
                weatherData."Weather Description" := purchaseHeader."GDRG Weather Description";
                weatherData.Humidity := purchaseHeader."GDRG Humidity";
            end else
                getWeatherDataFromCoordinates(orderClimateRisk);

        hasAlerts := false;
    end;

    local procedure updateOrderClimateRiskRecord(var orderClimateRisk: Record "GDRG Order Climate Risk"; calculator: Codeunit "GDRG Climate Risk Calculator"; estimatedCO2: Decimal; weatherAdjustedCO2: Decimal; riskScore: Decimal; riskLevel: Enum "GDRG Climate Risk Level")
    var
        aiRecommendation: Text[250];
    begin
        orderClimateRisk."Climate Risk Level" := riskLevel;
        orderClimateRisk."Risk Score" := riskScore;
        orderClimateRisk."Estimated CO2 Impact" := estimatedCO2;
        orderClimateRisk."Weather Adjusted CO2" := weatherAdjustedCO2;
        orderClimateRisk."CO2 Savings Potential" := calculator.CalculateCO2SavingsPotential(estimatedCO2, weatherAdjustedCO2);
        orderClimateRisk."Sustainability Score" := calculator.GenerateSustainabilityScore(orderClimateRisk."CO2 Savings Potential", riskLevel);

        aiRecommendation := getAIClimateRecommendation(orderClimateRisk);
        if aiRecommendation <> '' then
            orderClimateRisk."Optimization Recommendation" := aiRecommendation
        else
            orderClimateRisk."Optimization Recommendation" := calculator.GenerateOptimizationRecommendation(riskLevel, orderClimateRisk."Planned Date", orderClimateRisk."Weather Condition");

        orderClimateRisk."Analysis Date" := CurrentDateTime();
        orderClimateRisk."Last Updated" := CurrentDateTime();

        orderClimateRisk.Modify(true);
    end;

    local procedure createOrUpdateClimateRiskRecord(salesHeader: Record "Sales Header"; var orderClimateRisk: Record "GDRG Order Climate Risk"): Boolean
    begin
        orderClimateRisk.Reset();
        orderClimateRisk.SetRange("Document Type", salesHeader."Document Type");
        orderClimateRisk.SetRange("Document No.", salesHeader."No.");

        if orderClimateRisk.FindFirst() then
            exit(true);

        Clear(orderClimateRisk);
        orderClimateRisk.Init();
        orderClimateRisk."Document Type" := salesHeader."Document Type";
        orderClimateRisk."Document No." := salesHeader."No.";
        orderClimateRisk."Is Sales Order" := true;

        exit(TryInsertClimateRiskRecord(orderClimateRisk));
    end;

    [TryFunction]
    local procedure TryInsertClimateRiskRecord(var orderClimateRisk: Record "GDRG Order Climate Risk")
    begin
        orderClimateRisk.Insert(true);
    end;

    local procedure createOrUpdateClimateRiskRecord(purchaseHeader: Record "Purchase Header"; var orderClimateRisk: Record "GDRG Order Climate Risk"): Boolean
    begin
        orderClimateRisk.Reset();
        orderClimateRisk.SetRange("Document Type", "Sales Document Type"::Order);
        orderClimateRisk.SetRange("Document No.", purchaseHeader."No.");

        if orderClimateRisk.FindFirst() then
            exit(true)
        else begin
            orderClimateRisk.Reset();
            orderClimateRisk.Init();
            orderClimateRisk."Document Type" := "Sales Document Type"::Order;
            orderClimateRisk."Document No." := purchaseHeader."No.";
            if orderClimateRisk.Insert(true) then
                exit(true)
            else
                exit(false);
        end;
    end;

    local procedure createDemoRecordWithWeather(documentNo: Code[20]; customerVendorName: Text[100]; location: Text[100]; latitude: Decimal; longitude: Decimal; plannedDate: Date; riskLevel: Enum "GDRG Climate Risk Level"; weatherCondition: Text[100]; temperature: Decimal)
    var
        orderClimateRisk: Record "GDRG Order Climate Risk";
        calculator: Codeunit "GDRG Climate Risk Calculator";
    begin
        orderClimateRisk.Reset();
        orderClimateRisk.SetRange("Document Type", "Sales Document Type"::Order);
        orderClimateRisk.SetRange("Document No.", documentNo);

        if orderClimateRisk.FindFirst() then
            exit;

        orderClimateRisk.Init();
        orderClimateRisk."Document Type" := "Sales Document Type"::Order;
        orderClimateRisk."Document No." := documentNo;
        orderClimateRisk."Customer/Vendor Name" := customerVendorName;
        orderClimateRisk."Planned Date" := plannedDate;
        orderClimateRisk."Climate Risk Level" := riskLevel;
        orderClimateRisk.Latitude := latitude;
        orderClimateRisk.Longitude := longitude;

        orderClimateRisk."Weather Condition" := weatherCondition;
        orderClimateRisk."Temperature" := temperature;

        orderClimateRisk."Estimated CO2 Impact" := calculator.CalculateEstimatedCO2Impact("Sales Document Type"::Order, location);
        orderClimateRisk."Weather Adjusted CO2" := calculator.CalculateWeatherAdjustedCO2(orderClimateRisk."Estimated CO2 Impact", riskLevel);
        orderClimateRisk."CO2 Savings Potential" := calculator.CalculateCO2SavingsPotential(orderClimateRisk."Estimated CO2 Impact", orderClimateRisk."Weather Adjusted CO2");
        orderClimateRisk."Risk Score" := Random(100);
        orderClimateRisk."Sustainability Score" := calculator.GenerateSustainabilityScore(orderClimateRisk."CO2 Savings Potential", riskLevel);
        orderClimateRisk."Optimization Recommendation" := calculator.GenerateOptimizationRecommendation(riskLevel, plannedDate, orderClimateRisk."Weather Condition");
        orderClimateRisk."Analysis Date" := CurrentDateTime();
        orderClimateRisk."Last Updated" := CurrentDateTime();

        orderClimateRisk.Insert(true);
    end;

    local procedure checkDemoRecordExists(documentNo: Code[20]): Boolean
    var
        orderClimateRisk: Record "GDRG Order Climate Risk";
    begin
        orderClimateRisk.Reset();
        orderClimateRisk.SetRange("Document Type", "Sales Document Type"::Order);
        orderClimateRisk.SetRange("Document No.", documentNo);
        exit(not orderClimateRisk.IsEmpty());
    end;

    local procedure getWeatherDataFromCoordinates(var orderClimateRisk: Record "GDRG Order Climate Risk")
    var
        weatherData: Record "GDRG Weather Data";
        weatherDataManager: Codeunit "GDRG Weather Data Manager";
        unixTimestamp: BigInteger;
        targetDate: Date;
        coordinatesTolerance: Decimal;
    begin
        if (orderClimateRisk.Latitude = 0) or (orderClimateRisk.Longitude = 0) then
            exit;

        targetDate := orderClimateRisk."Planned Date";
        if targetDate = 0D then
            targetDate := WorkDate();

        unixTimestamp := (targetDate - DMY2Date(1, 1, 1970)) * 86400;

        coordinatesTolerance := 0.01;
        weatherData.Reset();
        weatherData.SetRange(Latitude, orderClimateRisk.Latitude - coordinatesTolerance, orderClimateRisk.Latitude + coordinatesTolerance);
        weatherData.SetRange(Longitude, orderClimateRisk.Longitude - coordinatesTolerance, orderClimateRisk.Longitude + coordinatesTolerance);

        if weatherData.FindLast() then begin
            orderClimateRisk."Weather Condition" := weatherData."Weather Description";
            orderClimateRisk."Temperature" := weatherData.Temperature;
        end else
            if weatherDataManager.GetWeatherData(orderClimateRisk.Latitude, orderClimateRisk.Longitude, unixTimestamp) then
                if weatherData.GetWeatherData(orderClimateRisk.Latitude, orderClimateRisk.Longitude, unixTimestamp, weatherData) then begin
                    orderClimateRisk."Weather Condition" := weatherData."Weather Description";
                    orderClimateRisk."Temperature" := weatherData.Temperature;
                end;
    end;

    local procedure getAIClimateRecommendation(var orderClimateRisk: Record "GDRG Order Climate Risk"): Text[250]
    var
        assistantSession: Record "GDRG Assistant Session";
        assistantSessionManager: Codeunit "GDRG Assistant Session Manager";
        promptText: Text[2048];
        cityCountry: Text[150];
        aiPromptTemplateLbl: Label 'Do you think we will have good weather on %1 in %2? This information will help me for logistics activities.', Comment = '%1 = Date, %2 = City-Country';
    begin
        if (orderClimateRisk.Latitude = 0) or (orderClimateRisk.Longitude = 0) then
            exit('');

        cityCountry := getCityCountryFromCoordinates(orderClimateRisk.Latitude, orderClimateRisk.Longitude);
        if cityCountry = '' then
            exit('');

        promptText := StrSubstNo(aiPromptTemplateLbl,
            orderClimateRisk."Planned Date",
            cityCountry);

        if not TryGetAIResponse(assistantSessionManager, promptText) then
            exit('');

        assistantSession.Reset();
        assistantSession.SetCurrentKey("Current UTC Time");
        assistantSession.Ascending(false);

        if assistantSession.FindFirst() then
            exit(CopyStr(assistantSession.Answer, 1, 250))
        else
            exit('');
    end;

    [TryFunction]
    local procedure TryGetAIResponse(assistantSessionManager: Codeunit "GDRG Assistant Session Manager"; promptText: Text)
    begin
        assistantSessionManager.GetAssistantSessionData(promptText);
    end;

    local procedure getCityCountryFromCoordinates(latitude: Decimal; longitude: Decimal): Text[150]
    var
        zipCodeInfo: Record "GDRG Zip Code Info";
        coordinatesTolerance: Decimal;
    begin
        coordinatesTolerance := 0.01;

        zipCodeInfo.Reset();
        zipCodeInfo.SetRange(Latitude, latitude - coordinatesTolerance, latitude + coordinatesTolerance);
        zipCodeInfo.SetRange(Longitude, longitude - coordinatesTolerance, longitude + coordinatesTolerance);

        if zipCodeInfo.FindFirst() then
            exit(zipCodeInfo.Name + ', ' + zipCodeInfo.Country)
        else
            exit('');
    end;
}
