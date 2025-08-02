page 50101 "GDRG Tag Search"
{
    Caption = 'My Tags Overview';
    PageType = List;
    SourceTable = "GDRG Personal Tag Assignment";
    ApplicationArea = All;
    UsageCategory = Tasks;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Tags)
            {
                field("Tag Color"; Rec."Tag Color")
                {
                }
                field("Tag Code"; Rec."Tag Code")
                {
                }
                field("Tag Name"; Rec."Tag Name")
                {
                    Style = Strong;
                }
                field("Table Name"; Rec."Table Name")
                {
                }
                field("Record Description"; Rec."Record Description")
                {
                }
                field("Created Date"; Rec."Created Date")
                {
                }
                field("User ID"; Rec."User ID")
                {
                    Visible = false;
                }
                field("Table No."; Rec."Table No.")
                {
                    Visible = false;
                }
                field("Record ID"; Rec."Record ID")
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
            action(GoToRecord)
            {
                Caption = 'Go to Record';
                ToolTip = 'Specifies to navigate to the record.';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PageManagement: codeunit "Page Management";
                    RecRef: RecordRef;
                    RecordNotAccessibleMsg: Label 'The record no longer exists or cannot be accessed.';
                begin
                    if not RecRef.Get(Rec."Record ID") then begin
                        Message(RecordNotAccessibleMsg);
                        exit;
                    end;

                    PageManagement.PageRun(RecRef);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("User ID", CopyStr(UserId(), 1, 50));
    end;
}
