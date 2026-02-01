tableextension 80104 "GDRG User Setup" extends "User Setup"
{
    fields
    {
        field(80100; "GDRG Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;
            DataClassification = CustomerContent;
        }
    }
}
