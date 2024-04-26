pageextension 80001 GDRStorageCompanyInformation extends "Company Information"
{

    layout
    {

        addafter("User Experience")
        {
            group(GDRStorageProgress)
            {
                field(MyProgressGDRStorageEnvironmentsCount; Rec.GDRStorageEnvironmentsCount)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.bar.SetProgress(Rec.GDRStorageEnvironmentsCount);
                    end;
                }
                usercontrol(bar; MyProgressBar)
                {
                    ApplicationArea = All;
                    trigger IAmReady()
                    begin
                        CurrPage.bar.SetProgress(Rec.GDRStorageEnvironmentsCount);
                    end;
                }
                field(MyProgressGDRStorageTotal; Rec.GDRStorageTotal)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.bar.SetProgress(Rec.GDRStorageTotal);
                    end;
                }
                usercontrol(barGDRStorageTotal; MyProgressBar)
                {
                    ApplicationArea = All;
                    trigger IAmReady()
                    begin
                        CurrPage.barGDRStorageTotal.SetProgress(Rec.GDRStorageTotal);
                    end;
                }

            }

        }
        addfirst(FactBoxes)
        {
            part(GDRStorageTelemetry; GDRStorageTelemetry)
            {
                ApplicationArea = all;
                Caption = 'GDR Storage Telemetry';
                //SubPageLink = link = FIELD("Primary Key");
            }
        }

    }

    trigger OnOpenPage()
    var
        GDRStorageWarningNotification: Notification;
        GDRStorageWarningNotificationLbl: label 'Low capacity in your tenant. Check out.';
        GDRGotoBCAdminLbl: label 'Go to Business Central Admin Center.';
    begin
        IF rec.GDRStorageTotal >= 95 THEN begin
            GDRStorageWarningNotification.Message(GDRStorageWarningNotificationLbl);
            GDRStorageWarningNotification.Scope := NotificationScope::LocalScope;
            GDRStorageWarningNotification.AddAction(GDRGotoBCAdminLbl, codeunit::GDRStorageNotification, 'GotoBusinessCentralAdmin');
            GDRStorageWarningNotification.Send();
        end;

    end;
}
