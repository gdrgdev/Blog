page 50103 "GDRG Personal Tag Master"
{
    PageType = List;
    SourceTable = "GDRG Personal Tag Master";
    Caption = 'Personal Tag Master';
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                }
                field(Name; Rec.Name)
                {
                    Style = Strong;
                }
                field(Color; Rec.Color)
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Created Date"; Rec."Created Date")
                {
                    Editable = false;
                }
                field("User ID"; Rec."User ID")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewAssignments)
            {
                Caption = 'View Assignments';
                ToolTip = 'Specifies to view tag assignments.';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "GDRG Personal Tag Assignments";
                RunPageLink = "User ID" = field("User ID"), "Tag Code" = field(Code);
            }
            action(SetupDemoData)
            {
                Caption = 'Setup Demo Data';
                ToolTip = 'Specifies to initialize demo data for personal tags.';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    DemoDataSetup: Codeunit "GDRG Demo Data Setup";
                    ConfirmInitMsg: Label 'This will delete all existing personal tags and create demo data. Do you want to continue?';
                    CompletedMsg: Label 'Demo data has been successfully created with 6 master tags and random assignments to customers, vendors, and sales orders.';
                begin
                    if Confirm(ConfirmInitMsg) then begin
                        DemoDataSetup.InitializeDemoData();
                        Message(CompletedMsg);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("User ID", CopyStr(UserId(), 1, 50));
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."User ID" := CopyStr(UserId(), 1, 50);
    end;
}
