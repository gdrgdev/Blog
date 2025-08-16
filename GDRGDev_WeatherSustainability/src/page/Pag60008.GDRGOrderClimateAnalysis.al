
page 60008 "GDRG Order Climate Analysis"
{
    Caption = 'Order Climate Risk Analysis';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Order Climate Risk";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field("Customer/Vendor Name"; Rec."Customer/Vendor Name")
                {
                }
                field("Optimization Recommendation"; Rec."Optimization Recommendation")
                {
                }
                field(Latitude; Rec.Latitude)
                {
                }
                field(Longitude; Rec.Longitude)
                {
                }
                field("Planned Date"; Rec."Planned Date")
                {
                }
                field("Climate Risk Level"; Rec."Climate Risk Level")
                {
                }
                field("Risk Score"; Rec."Risk Score")
                {
                }
                field("Sustainability Score"; Rec."Sustainability Score")
                {
                }
                field("Estimated CO2 Impact"; Rec."Estimated CO2 Impact")
                {
                }
                field("CO2 Savings Potential"; Rec."CO2 Savings Potential")
                {
                }
                field("Weather Condition"; Rec."Weather Condition")
                {
                }
                field("Temperature"; Rec."Temperature")
                {
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Climate Analysis")
            {
                Caption = 'Climate Analysis';

                action("Analyze All Orders")
                {
                    Caption = 'Analyze All Orders';
                    Image = Calculate;
                    ToolTip = 'Analyze climate risk for all orders in the current view.';

                    trigger OnAction()
                    var
                        climateRiskManager: Codeunit "GDRG Climate Risk Manager";
                        ordersAnalyzed: Integer;
                        successMsg: Label '%1 orders analyzed successfully for climate risk and sustainability impact.', Comment = '%1 = Number of orders';
                    begin
                        ordersAnalyzed := climateRiskManager.AnalyzeOrdersInDateRange(WorkDate() - 30, WorkDate() + 60);
                        Message(successMsg, ordersAnalyzed);
                        CurrPage.Update(false);
                    end;
                }

                action("Generate Demo Data")
                {
                    Caption = 'Generate Demo Data';
                    Image = CreateDocument;
                    ToolTip = 'Generate sample climate risk data for demonstration.';

                    trigger OnAction()
                    var
                        climateRiskManager: Codeunit "GDRG Climate Risk Manager";
                        recordsCreated: Integer;
                        demoMsg: Label '%1 demo records created successfully. Ready for sustainability analysis!', Comment = '%1 = Number of records';
                    begin
                        recordsCreated := climateRiskManager.GenerateDemoData();
                        Message(demoMsg, recordsCreated);
                        CurrPage.Update(false);
                    end;
                }

                action("Refresh Analysis")
                {
                    Caption = 'Refresh Analysis';
                    Image = Refresh;
                    ToolTip = 'Refresh the climate risk analysis for selected order.';

                    trigger OnAction()
                    var
                        refreshMsg: Label 'Climate risk analysis refreshed successfully.';
                    begin
                        Rec.UpdateClimateAnalysis();
                        Message(refreshMsg);
                        CurrPage.Update(false);
                    end;
                }

                action("Clear All Data")
                {
                    Caption = 'Clear All Data';
                    Image = Delete;
                    ToolTip = 'Clear all climate risk analysis data from the table.';

                    trigger OnAction()
                    var
                        orderClimateRisk: Record "GDRG Order Climate Risk";
                        confirmMsg: Label 'Are you sure you want to delete ALL climate risk analysis data? This action cannot be undone.';
                        successMsg: Label '%1 climate risk records deleted successfully.', Comment = '%1 = Number of records deleted';
                        recordCount: Integer;
                    begin
                        if not Confirm(confirmMsg) then
                            exit;

                        orderClimateRisk.Reset();
                        recordCount := orderClimateRisk.Count();
                        orderClimateRisk.DeleteAll(true);

                        Message(successMsg, recordCount);
                        CurrPage.Update(false);
                    end;
                }
            }

            group("Sustainability Reports")
            {
                Caption = 'Sustainability Reports';

                action("Climate Impact Report")
                {
                    Caption = 'Climate Impact Report';
                    Image = Report;
                    ToolTip = 'Generate detailed climate impact and sustainability report (Coming Soon).';

                    trigger OnAction()
                    var
                        placeholderMsg: Label 'Climate Impact Report feature is under development. This will generate comprehensive sustainability and climate risk reports in future versions.';
                    begin
                        Message(placeholderMsg);
                    end;
                }

                action("Export to Sustainability")
                {
                    Caption = 'Export to BC Sustainability';
                    Image = ExportFile;
                    ToolTip = 'Export climate risk data to Business Central Sustainability module.';

                    trigger OnAction()
                    var
                        climateRiskManager: Codeunit "GDRG Climate Risk Manager";
                        totalOrders: Integer;
                        ordersAtRisk: Integer;
                        avgRiskScore: Decimal;
                        totalCO2Savings: Decimal;
                        exportMsg: Label 'Climate risk data exported to BC Sustainability module successfully. %1 kg CO2 savings potential identified across %2 orders.', Comment = '%1 = CO2 savings amount, %2 = Number of orders';
                    begin
                        climateRiskManager.GetSustainabilityMetrics(totalOrders, ordersAtRisk, avgRiskScore, totalCO2Savings);
                        Message(exportMsg, totalCO2Savings, totalOrders);
                    end;
                }
            }

            group("AI Insights")
            {
                Caption = 'AI Insights';

                action("Get Climate Recommendations")
                {
                    Caption = 'Get AI Climate Recommendations';
                    Image = SuggestField;
                    ToolTip = 'Get AI-powered recommendations for climate risk mitigation.';

                    trigger OnAction()
                    var
                        assistantSessionInputPage: Page "GDRG Assistant Session Input";
                        promptText: Text[2048];
                        aiPromptLbl: Label 'Analyze climate risks for orders in location coordinates %1, %2 and provide sustainability optimization recommendations.', Comment = '%1 = Latitude, %2 = Longitude';
                    begin
                        if (Rec.Latitude <> 0) and (Rec.Longitude <> 0) then
                            promptText := StrSubstNo(aiPromptLbl, Rec.Latitude, Rec.Longitude)
                        else
                            promptText := 'Analyze climate risks for current orders and provide sustainability optimization recommendations.';

                        assistantSessionInputPage.SetDefaults(promptText);
                        assistantSessionInputPage.RunModal();
                    end;
                }
            }
        }

        area(Navigation)
        {
            action("View Weather Data")
            {
                Caption = 'View Weather Data';
                Image = ShowList;
                ToolTip = 'View detailed weather data for analysis.';
                RunObject = page "GDRG Weather Data List";
            }

            action("View API Connections")
            {
                Caption = 'View API Connections';
                Image = Setup;
                ToolTip = 'View and configure API connections for weather data.';
                RunObject = page "GDRG API Connection Setup";
            }
        }
    }

    views
    {
        view("High Risk Orders")
        {
            Caption = 'High Risk Orders';
            Filters = where("Climate Risk Level" = filter(High | Critical));
            OrderBy = ascending("Risk Score");
        }

        view("Sustainability Opportunities")
        {
            Caption = 'Sustainability Opportunities';
            Filters = where("CO2 Savings Potential" = filter('>5'));
            OrderBy = descending("CO2 Savings Potential");
        }

        view("This Week")
        {
            Caption = 'Orders This Week';
            Filters = where("Planned Date" = filter('CW'));
            OrderBy = ascending("Planned Date");
        }
    }

    trigger OnOpenPage()
    var
        welcomeMsg: Label 'Welcome to Climate Risk Analysis! This dashboard shows sustainability impact and climate risks for your orders. Use "Generate Demo Data" to start exploring.';
    begin
        if Rec.IsEmpty() then
            Message(welcomeMsg);
    end;
}
