// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!
namespace DefaultPublisher.GDRGDev_CustomTelemetry;
using Microsoft.Sales.Customer;
pageextension 50200 GDGRDDevCustomerListExt extends "Customer List"
{
    actions
    {
        addfirst(General)
        {
            action("CustomTelemetryNormalSystemMetadata")
            {
                Caption = 'Send Custom Telemetry Normal SystemMetadata';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = NumberGroup;
                trigger OnAction()
                var
                    CustomTelemetryDimensions: Dictionary of [Text, Text];
                begin
                    CustomTelemetryDimensions.Add('dimension1', 'dimension value 1');
                    CustomTelemetryDimensions.Add('dimension2', 'dimension value 2');
                    LogMessage('GDRGDev_CustomTelemetry_01',
                        'Custom Telemetry Normal SystemMetadata: Spain hour' + FORMAT(Today()) + FORMAT(Time()),
                        Verbosity::Normal,
                        DATACLASSIFICATION::SystemMetadata,
                        TelemetryScope::ExtensionPublisher,
                        CustomTelemetryDimensions);
                    Message('GDRGDev_CustomTelemetry_01 Signal sent!');
                end;
            }
            action("CustomTelemetryCriticalSystemMetadata")
            {
                Caption = 'Send Custom Telemetry Critical SystemMetadata';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = NumberGroup;
                trigger OnAction()
                begin

                    LogMessage('GDRGDev_CustomTelemetry_02',
                        'Custom Telemetry Critical SystemMetadata: Spain hour' + FORMAT(Today()) + FORMAT(Time()),
                        Verbosity::Critical,
                        DATACLASSIFICATION::SystemMetadata,
                        TelemetryScope::ExtensionPublisher,
                        'dimension3', 'dimension value 3', 'dimension4', 'dimension value 4');
                    Message('GDRGDev_CustomTelemetry_02 Signal sent!');
                end;
            }
            action("CustomTelemetryErrorCustomerContent")
            {
                Caption = 'Send Custom Telemetry Error CustomerContent';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = NumberGroup;
                trigger OnAction()
                begin

                    LogMessage('GDRGDev_CustomTelemetry_03',
                        'Custom Telemetry Error CustomerContent: Spain hour' + FORMAT(Today()) + FORMAT(Time()),
                        Verbosity::Error,
                        DATACLASSIFICATION::CustomerContent, //Not Valid, Not Trace
                        TelemetryScope::ExtensionPublisher,
                        'dimension5', 'dimension value 5', 'dimension6', 'dimension value 6');
                    Message('GDRGDev_CustomTelemetry_03 Signal sent!');
                end;
            }
            action("CustomTelemetryErrorSystemMetadata")
            {
                Caption = 'Send Custom Telemetry Error SystemMetadata';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = NumberGroup;
                trigger OnAction()
                begin

                    LogMessage('GDRGDev_CustomTelemetry_04',
                        'Custom Telemetry Error SystemMetadata: Spain hour' + FORMAT(Today()) + FORMAT(Time()),
                        Verbosity::Error,
                        DATACLASSIFICATION::SystemMetadata,
                        TelemetryScope::ExtensionPublisher,
                        'dimension7', 'dimension value 7', 'dimension8', 'dimension value 8');
                    Message('GDRGDev_CustomTelemetry_04 Signal sent!');
                end;
            }
            action("CustomTelemetryWarningSystemMetadata")
            {
                Caption = 'Send Custom Telemetry Warning SystemMetadata';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = NumberGroup;
                trigger OnAction()
                begin

                    LogMessage('GDRGDev_CustomTelemetry_05',
                        'Custom Telemetry Warning SystemMetadata: Spain hour' + FORMAT(Today()) + FORMAT(Time()),
                        Verbosity::Warning,
                        DATACLASSIFICATION::SystemMetadata,
                        TelemetryScope::ExtensionPublisher,
                        'dimension9', 'dimension value 9', 'dimension10', 'dimension value 10');
                    Message('GDRGDev_CustomTelemetry_05 Signal sent!');
                end;
            }
        }
    }
}

