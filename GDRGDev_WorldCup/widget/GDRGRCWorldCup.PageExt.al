pageextension 88890 "GDRG RC World Cup" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control16)
        {
            part(WorldCup; "GDRG World Cup Scores Part")
            {
                ApplicationArea = All;
            }
        }
    }
}