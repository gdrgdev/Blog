pageextension 50101 "GDRG Account Schedule" extends "Account Schedule"
{
    layout
    {
        addafter(Show)
        {
            field("GDRG Has Notes"; Rec."GDRG Has Notes")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("GDRG Note Text"; Rec."GDRG Note Text")
            {
                ApplicationArea = All;
                Width = 30;
                Editable = false;

                trigger OnDrillDown()
                var
                    EditNoteDialog: Page "GDRG Edit Note Dialog";
                begin
                    EditNoteDialog.SetNoteText(Rec."GDRG Note Text");
                    EditNoteDialog.LookupMode(true);
                    if EditNoteDialog.RunModal() = Action::LookupOK then begin
                        Rec.Validate("GDRG Note Text", EditNoteDialog.GetNoteText());
                        Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(GDRGEditNote)
            {
                ApplicationArea = All;
                Caption = 'Edit Note';
                Image = EditLines;
                Scope = Repeater;

                trigger OnAction()
                var
                    EditNoteDialog: Page "GDRG Edit Note Dialog";
                begin
                    EditNoteDialog.SetNoteText(Rec."GDRG Note Text");
                    EditNoteDialog.LookupMode(true);
                    if EditNoteDialog.RunModal() = Action::LookupOK then begin
                        Rec.Validate("GDRG Note Text", EditNoteDialog.GetNoteText());
                        Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        addfirst(Promoted)
        {
            actionref(GDRGEditNote_Promoted; GDRGEditNote) { }
        }
    }
}
