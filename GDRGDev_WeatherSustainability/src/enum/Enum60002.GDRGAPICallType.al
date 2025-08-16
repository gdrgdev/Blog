enum 60002 "GDRG API Call Type"
{
    Caption = 'API Call Type';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(10; "Weather")
    {
        Caption = 'Weather';
    }
    value(20; "Geo")
    {
        Caption = 'Geo';
    }
    value(30; "Connection Test")
    {
        Caption = 'Connection Test';
    }
    value(40; "Other")
    {
        Caption = 'Other';
    }
}
