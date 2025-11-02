enum 90000 "GDRG Mask Pattern"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; LastFourDigits)
    {
        Caption = 'Last Four Digits';
    }
    value(2; FirstAndLastTwo)
    {
        Caption = 'First And Last Two';
    }
    value(3; MiddleVisible)
    {
        Caption = 'Middle Visible';
    }
    value(4; FullMask)
    {
        Caption = 'Full Mask';
    }
}
