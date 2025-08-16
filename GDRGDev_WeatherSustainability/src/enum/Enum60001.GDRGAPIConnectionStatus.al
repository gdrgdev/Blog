enum 60001 "GDRG API Connection Status"
{
    Caption = 'API Connection Status';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; "Not Tested")
    {
        Caption = 'Not Tested';
    }
    value(2; "Connected")
    {
        Caption = 'Connected';
    }
    value(3; "Failed")
    {
        Caption = 'Failed';
    }
    value(4; "Testing")
    {
        Caption = 'Testing';
    }
}
