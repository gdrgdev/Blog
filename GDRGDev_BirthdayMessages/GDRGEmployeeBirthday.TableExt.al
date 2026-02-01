tableextension 80101 "GDRG Employee Birthday" extends Employee
{
    fields
    {
        field(80100; "GDRG Birthday Messages Total"; Integer)
        {
            Caption = 'Birthday Messages (Total)';
            FieldClass = FlowField;
            CalcFormula = Count("GDRG Birthday Message" WHERE("Employee No." = FIELD("No.")));
            Editable = false;
        }

        field(80101; "GDRG Next Birthday Date"; Date)
        {
            Caption = 'Next Birthday Date';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(80102; "GDRG Days to Birthday"; Integer)
        {
            Caption = 'Days to Birthday';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(BirthdayDays; "GDRG Days to Birthday")
        {
        }
    }
}
