codeunit 80000 GDRStorageTelemetry
{

    #region Subscriber
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Management", 'OnSendDailyTelemetry', '', true, true)]
    local procedure GDRSendNormalStorageTelemetry()
    var
        normalCustomTeleDim: Dictionary of [Text, Text];
        recGDRStorageenvironmentsCount: Record GDRStorageenvironmentsCount;
        recGDRStorageTotalTelemetry: Record GDRStorageTotalTelemetry;
        recGDRStorageTelemetry: Record GDRStorageTelemetry;
    begin

        //Normal Information
        recGDRStorageenvironmentsCount.Reset();
        If recGDRStorageenvironmentsCount.FindLast() THEN begin
            normalCustomTeleDim.Add('EnvProductionCount', format(recGDRStorageenvironmentsCount.production));
            normalCustomTeleDim.Add('EnvSandboxCount', format(recGDRStorageenvironmentsCount.sandbox));
        end;
        recGDRStorageTotalTelemetry.Reset();
        If recGDRStorageTotalTelemetry.FindLast() THEN begin
            normalCustomTeleDim.Add('KBdefault', format(recGDRStorageTotalTelemetry.default));
            normalCustomTeleDim.Add('userLicenses', format(recGDRStorageTotalTelemetry.userLicenses));
            normalCustomTeleDim.Add('KBadditionalCapacity', format(recGDRStorageTotalTelemetry.additionalCapacity));
            normalCustomTeleDim.Add('KBtotal', format(recGDRStorageTotalTelemetry.total));
        end;
        Session.LogMessage('GDRST_001',
            'GDR Storage Telemetry Normal Storage Environments Count',
            Verbosity::Normal, DATACLASSIFICATION::SystemMetadata, TelemetryScope::ExtensionPublisher, normalCustomTeleDim);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Management", 'OnSendDailyTelemetry', '', true, true)]
    local procedure GDRSendWarningStorageTelemetry()
    var
        warningCustomTeleDim: Dictionary of [Text, Text];
        recGDRStorageTotalTelemetry: Record GDRStorageTotalTelemetry;
        recGDRStorageTelemetry: Record GDRStorageTelemetry;
        recCompanyInformation: record "Company Information";
        inttotalcapacity: Integer;
        intcurrentcapacity: Integer;
    begin

        If recCompanyInformation.Get() then;
        inttotalcapacity := 0;
        intcurrentcapacity := 0;

        recGDRStorageTotalTelemetry.Reset();
        If recGDRStorageTotalTelemetry.FindLast() THEN begin
            inttotalcapacity := recGDRStorageTotalTelemetry.total;
        end;

        recGDRStorageTelemetry.Reset();
        if recGDRStorageTelemetry.FindSet() then begin
            repeat
                intcurrentcapacity := intcurrentcapacity + recGDRStorageTelemetry.databaseStorageInKilobytes;
            until recGDRStorageTelemetry.Next() = 0;
        end;

        IF (recCompanyInformation.GDRStorageTotal >= 80) and
        (recCompanyInformation.GDRStorageTotal < 95) then begin
            //Storage Warning 
            warningCustomTeleDim.Add('KBcurrent', format(intcurrentcapacity));
            warningCustomTeleDim.Add('KBtotal', format(inttotalcapacity));
            Session.LogMessage('GDRST_002',
                'GDR Storage Telemetry Warning Storage Environments Count',
                Verbosity::Warning, DATACLASSIFICATION::SystemMetadata, TelemetryScope::ExtensionPublisher, warningCustomTeleDim);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Management", 'OnSendDailyTelemetry', '', true, true)]
    local procedure GDRSendCriticalStorageTelemetry()
    var
        criticalCustomTeleDim: Dictionary of [Text, Text];
        recGDRStorageTotalTelemetry: Record GDRStorageTotalTelemetry;
        recGDRStorageTelemetry: Record GDRStorageTelemetry;
        recCompanyInformation: record "Company Information";
        inttotalcapacity: Integer;
        intcurrentcapacity: Integer;
    begin
        If recCompanyInformation.Get() then;
        inttotalcapacity := 0;
        intcurrentcapacity := 0;

        recGDRStorageTotalTelemetry.Reset();
        If recGDRStorageTotalTelemetry.FindLast() THEN begin
            inttotalcapacity := recGDRStorageTotalTelemetry.total;
        end;

        recGDRStorageTelemetry.Reset();
        if recGDRStorageTelemetry.FindSet() then begin
            repeat
                intcurrentcapacity := intcurrentcapacity + recGDRStorageTelemetry.databaseStorageInKilobytes;
            until recGDRStorageTelemetry.Next() = 0;
        end;

        IF recCompanyInformation.GDRStorageTotal >= 95 then begin
            //Critical Warning 
            criticalCustomTeleDim.Add('KBcurrent', format(intcurrentcapacity));
            criticalCustomTeleDim.Add('KBtotal', format(inttotalcapacity));
            Session.LogMessage('GDRST_003',
                'GDR Storage Telemetry Critical Storage Environments Count',
                Verbosity::Warning, DATACLASSIFICATION::SystemMetadata, TelemetryScope::ExtensionPublisher, criticalCustomTeleDim);
        end;
    end;
    #endregion Subscriber





}