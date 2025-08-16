enum 60000 "GDRG API Auth Type"
{
    Caption = 'API Authentication Type';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; "API Key Header")
    {
        Caption = 'API Key Header';
    }
    value(2; "API Key Query")
    {
        Caption = 'API Key Query Parameter';
    }
    value(3; "Bearer Token")
    {
        Caption = 'Bearer Token';
    }
}
