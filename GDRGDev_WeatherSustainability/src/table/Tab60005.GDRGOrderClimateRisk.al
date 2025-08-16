table 60005 "GDRG Order Climate Risk"
{
    Caption = 'Order Climate Risk Analysis';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Order Climate Analysis";
    DrillDownPageId = "GDRG Order Climate Analysis";
    Permissions = tabledata "GDRG Order Climate Risk" = RM;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AllowInCustomizations = Never;
        }

        field(10; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            ToolTip = 'Specifies the type of document (Sales Order, Purchase Order).';
        }

        field(20; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            ToolTip = 'Specifies the document number being analyzed.';
        }

        field(30; "Customer/Vendor No."; Code[20])
        {
            Caption = 'Customer/Vendor No.';
            ToolTip = 'Specifies the customer or vendor number.';
            AllowInCustomizations = Never;
        }

        field(40; "Customer/Vendor Name"; Text[100])
        {
            Caption = 'Customer/Vendor Name';
            ToolTip = 'Specifies the customer or vendor name.';
        }

        field(56; Latitude; Decimal)
        {
            Caption = 'Latitude';
            DecimalPlaces = 0 : 6;
            ToolTip = 'Specifies the latitude coordinate for the shipping/buying location.';

        }

        field(57; Longitude; Decimal)
        {
            Caption = 'Longitude';
            DecimalPlaces = 0 : 6;
            ToolTip = 'Specifies the longitude coordinate for the shipping/buying location.';

        }

        field(60; "Planned Date"; Date)
        {
            Caption = 'Planned Shipment/Receipt Date';
            ToolTip = 'Specifies the planned shipment or receipt date.';
        }

        field(70; "Climate Risk Level"; Enum "GDRG Climate Risk Level")
        {
            Caption = 'Climate Risk Level';
            ToolTip = 'Specifies the calculated climate risk level for this order.';
        }

        field(80; "Risk Score"; Decimal)
        {
            Caption = 'Risk Score';
            DecimalPlaces = 1 : 2;
            ToolTip = 'Specifies the numerical risk score (0-100).';
        }

        field(90; "Estimated CO2 Impact"; Decimal)
        {
            Caption = 'Estimated CO2 Impact (kg)';
            DecimalPlaces = 1 : 2;
            ToolTip = 'Specifies the estimated CO2 impact in kilograms.';
        }

        field(100; "Weather Adjusted CO2"; Decimal)
        {
            Caption = 'Weather Adjusted CO2 (kg)';
            DecimalPlaces = 1 : 2;
            ToolTip = 'Specifies the weather-adjusted CO2 impact considering climate risk.';
        }

        field(110; "CO2 Savings Potential"; Decimal)
        {
            Caption = 'CO2 Savings Potential (kg)';
            DecimalPlaces = 1 : 2;
            ToolTip = 'Specifies the potential CO2 savings through optimization.';
        }

        field(120; "Sustainability Score"; Text[10])
        {
            Caption = 'Sustainability Score';
            ToolTip = 'Specifies the sustainability grade (A+, A, B, C, D).';
        }

        field(130; "Weather Condition"; Text[100])
        {
            Caption = 'Weather Condition';
            ToolTip = 'Specifies the weather condition affecting this order.';
        }

        field(140; "Temperature"; Decimal)
        {
            Caption = 'Temperature (°C)';
            DecimalPlaces = 1 : 1;
            ToolTip = 'Specifies the temperature at the planned date.';
        }

        field(150; "Optimization Recommendation"; Text[250])
        {
            Caption = 'Optimization Recommendation';
            ToolTip = 'Specifies AI-generated recommendations for optimization.';
        }

        field(160; "Analysis Date"; DateTime)
        {
            Caption = 'Analysis Date';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies when this analysis was performed.';
            AllowInCustomizations = Never;
        }

        field(170; "Last Updated"; DateTime)
        {
            Caption = 'Last Updated';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies when this record was last updated.';
            AllowInCustomizations = Never;
        }

        field(180; "Is Sales Order"; Boolean)
        {
            Caption = 'Is Sales Order';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies if this is a sales order (true) or purchase order (false).';
            AllowInCustomizations = Never;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Document; "Document Type", "Document No.")
        {
        }
        key(Risk; "Climate Risk Level", "Risk Score")
        {
        }
        key(Date; "Planned Date")
        {
        }
        key(CO2Savings; "CO2 Savings Potential")
        {
        }
        key(Location; Latitude, Longitude, "Planned Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Document No.", "Customer/Vendor Name", "Climate Risk Level", "Risk Score")
        {
        }
        fieldgroup(Brick; "Document No.", "Customer/Vendor Name", "Climate Risk Level", "Sustainability Score", Latitude, Longitude)
        {
        }
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();
    end;


    procedure UpdateClimateAnalysis()
    var
        ClimateRiskManager: Codeunit "GDRG Climate Risk Manager";
    begin
        RefreshOrderData();

        ClimateRiskManager.AnalyzeOrderClimateRisk(Rec);
        Rec."Last Updated" := CurrentDateTime();
        Rec.Modify(true);
    end;

    procedure GetRiskColor(): Text
    begin
        case Rec."Climate Risk Level" of
            Rec."Climate Risk Level"::Low:
                exit(Format(PageStyle::Favorable));
            Rec."Climate Risk Level"::Medium:
                exit(Format(PageStyle::Ambiguous));
            Rec."Climate Risk Level"::High:
                exit(Format(PageStyle::Unfavorable));
            Rec."Climate Risk Level"::Critical:
                exit(Format(PageStyle::Attention));
            else
                exit(Format(PageStyle::Standard));
        end;
    end;

    local procedure GetNextEntryNo(): Integer
    var
        OrderClimateRiskRec: Record "GDRG Order Climate Risk";
    begin
        OrderClimateRiskRec.Reset();
        OrderClimateRiskRec.SetCurrentKey("Entry No.");
        if OrderClimateRiskRec.FindLast() then
            exit(OrderClimateRiskRec."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure RefreshOrderData()
    var
        salesHeader: Record "Sales Header";
        purchaseHeader: Record "Purchase Header";
        customer: Record Customer;
        vendor: Record Vendor;
    begin
        if Rec."Is Sales Order" then begin
            if salesHeader.Get(Rec."Document Type", Rec."Document No.") then begin
                Rec."Planned Date" := salesHeader."Shipment Date";
                Rec.Latitude := salesHeader."GDRG Latitude";
                Rec.Longitude := salesHeader."GDRG Longitude";
                Rec."Customer/Vendor No." := salesHeader."Sell-to Customer No.";

                if customer.Get(salesHeader."Sell-to Customer No.") then
                    Rec."Customer/Vendor Name" := customer.Name;
            end;
        end else
            if purchaseHeader.Get(purchaseHeader."Document Type"::Order, Rec."Document No.") then begin
                Rec."Planned Date" := purchaseHeader."Expected Receipt Date";
                Rec.Latitude := purchaseHeader."GDRG Latitude";
                Rec.Longitude := purchaseHeader."GDRG Longitude";
                Rec."Customer/Vendor No." := purchaseHeader."Buy-from Vendor No.";

                if vendor.Get(purchaseHeader."Buy-from Vendor No.") then
                    Rec."Customer/Vendor Name" := vendor.Name;
            end;
    end;
}
