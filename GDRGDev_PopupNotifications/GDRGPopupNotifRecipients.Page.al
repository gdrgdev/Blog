/// <summary>
/// List to view notification history per user and manually add recipients
/// </summary>
page 80119 "GDRG Popup Notif Recipients"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG Popup Notif Recipient";
    Caption = 'Popup Notif Recipients History';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                }
                field("User ID"; Rec."User ID")
                {
                    TableRelation = User."User Name";
                }
                field("Scheduled DateTime"; Rec."Scheduled DateTime")
                {
                    Editable = false;
                }
                field("Shown DateTime"; Rec."Read DateTime")
                {
                    Editable = false;
                }
            }
        }
    }

    var
        GlobalEntryNo: Integer;
        GlobalScheduledDateTime: DateTime;

    procedure SetEntryNoAndScheduledDateTime(EntryNo: Integer; ScheduledDateTime: DateTime)
    begin
        GlobalEntryNo := EntryNo;
        GlobalScheduledDateTime := ScheduledDateTime;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if GlobalEntryNo <> 0 then
            Rec."Entry No." := GlobalEntryNo;
        if GlobalScheduledDateTime <> 0DT then
            Rec."Scheduled DateTime" := GlobalScheduledDateTime;
    end;
}
