/// <summary>
/// Setup page to configure notification cue image
/// </summary>
page 80121 "GDRG Popup Notif Cue Setup"
{
    Caption = 'Popup Notif Cue Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GDRG Popup Notif Cue";

    layout
    {
        area(Content)
        {
            group(Display)
            {
                Caption = 'Notification Image';

                field(Image; Rec.Image)
                {
                    ShowCaption = false;
                    ToolTip = 'Specifies the decorative image displayed in the notification monitor.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportImage)
            {
                Caption = 'Import Image';
                Image = Import;
                ToolTip = 'Specifies the action to import an image file to display in the notification monitor.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileManagement: Codeunit "File Management";
                    InStr: InStream;
                    FileName: Text;
                    FilterTxt: Label 'Image Files (*.png, *.jpg, *.jpeg, *.bmp)|*.png;*.jpg;*.jpeg;*.bmp', Locked = true;
                begin
                    FileName := FileManagement.BLOBImportWithFilter(TempBlob, '', '', FilterTxt, FilterTxt);
                    if FileName = '' then
                        exit;

                    TempBlob.CreateInStream(InStr);
                    Rec.Image.ImportStream(InStr, FileName);
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }
            action(DeleteImage)
            {
                Caption = 'Delete Image';
                Image = Delete;
                ToolTip = 'Specifies the action to remove the current image.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if not Confirm('Delete the current image?', false) then
                        exit;

                    Clear(Rec.Image);
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Ensure the shared record exists
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert(true);
        end;
    end;
}
