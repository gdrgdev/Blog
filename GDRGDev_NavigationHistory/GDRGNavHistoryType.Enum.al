enum 50100 "GDRG Nav. History Type"
{
    Caption = 'Navigation History Type';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; List)
    {
        Caption = 'List Page';
    }
    value(2; Card)
    {
        Caption = 'Specific Record';
    }
}
