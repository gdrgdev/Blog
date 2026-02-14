reportextension 50104 "GDRG Account Schedule" extends "Account Schedule"
{
    dataset
    {
        add("Acc. Schedule Line")
        {
            column(GDRGHasNotes; "GDRG Has Notes") { }
            column(GDRGNoteText; "GDRG Note Text") { }
            column(GDRGNotesSectionCaptionLbl; GDRGNotesSectionCaptionLbl) { }
        }
    }

    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(GDRGIncludeNotes; GDRGIncludeNotes)
                {
                    ApplicationArea = All;
                    Caption = 'Include Notes';
                }
            }
        }
    }

    rendering
    {
        layout(GDRGLandscapeLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/GDRGLandscapeLayout.rdl';
            Caption = 'Financial Report Landscape with Notes';
        }
    }

    var
        GDRGIncludeNotes: Boolean;
        GDRGNotesSectionCaptionLbl: Label 'NOTES TO FINANCIAL STATEMENTS:';
}
