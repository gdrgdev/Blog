table 50103 "GDRG Valid Customers"
{
    Caption = 'GDRG Valid Customers';
    DataClassification = CustomerContent;
    LookupPageId = "GDRG Customer Test Data";
    DrillDownPageId = "GDRG Customer Test Data";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer number.';
        }
        field(3; "Name"; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the customer name.';
        }
        field(4; "Blocked"; Enum "Customer Blocked")
        {
            Caption = 'Blocked';
            ToolTip = 'Specifies if the customer is blocked.';
        }
        field(5; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            ToolTip = 'Specifies the customer email.';
        }
        field(6; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ToolTip = 'Specifies the customer phone number.';
        }
        field(7; "Method Used"; Text[50])
        {
            Caption = 'Method Used';
            ToolTip = 'Specifies which method found this valid customer.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Customer No.", Name, "Method Used")
        {
        }
        fieldgroup(Brick; "Customer No.", Name, "E-Mail")
        {
        }
    }
}
