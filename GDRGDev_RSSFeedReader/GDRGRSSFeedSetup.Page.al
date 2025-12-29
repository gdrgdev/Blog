page 80100 "GDRG RSS Feed Setup"
{
    Permissions = tabledata "GDRG RSS Feed Setup" = RIMD;

    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GDRG RSS Feed Setup";
    Caption = 'RSS Feed Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Default Refresh Minutes"; Rec."Default Refresh Minutes")
                {
                }
                field("Keep Entries Days"; Rec."Keep Entries Days")
                {
                }
                field("Last Cleanup DateTime"; Rec."Last Cleanup DateTime")
                {
                    Editable = false;
                }
                field("Primary Key"; Rec."Primary Key")
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
            action(CleanupOldEntries)
            {
                Caption = 'Cleanup Old Entries';
                ToolTip = 'Delete old RSS entries based on Keep Entries Days setting.';
                Image = Delete;

                trigger OnAction()
                var
                    RSSManager: Codeunit "GDRG RSS Feed Manager";
                begin
                    RSSManager.CleanupOldEntries(Rec."Keep Entries Days");
                    Rec."Last Cleanup DateTime" := CurrentDateTime();
                    Rec.Modify(true);
                    Message('Old entries have been cleaned up.');
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                ShowAs = SplitButton;

                actionref(CleanupOldEntries_Promoted; CleanupOldEntries)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetInstance();
    end;
}
