page 50101 "GDRG Edit Note Dialog"
{
    Caption = 'Edit Note Text';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            field(NoteText; NoteText)
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;
            }
        }
    }

    var
        NoteText: Text[500];

    procedure SetNoteText(NewText: Text[500])
    begin
        NoteText := NewText;
    end;

    procedure GetNoteText(): Text[500]
    begin
        exit(NoteText);
    end;
}
