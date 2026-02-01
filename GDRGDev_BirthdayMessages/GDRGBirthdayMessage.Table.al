table 80100 "GDRG Birthday Message"
{
    Caption = 'Birthday Message';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }

        field(2; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;
            DataClassification = CustomerContent;
            NotBlank = true;
        }

        field(3; "Birthday Year"; Integer)
        {
            Caption = 'Birthday Year';
            DataClassification = CustomerContent;
            NotBlank = true;
        }

        field(4; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
        }

        field(5; Message; Blob)
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }

        field(6; "Message Date"; Date)
        {
            Caption = 'Message Date';
            DataClassification = CustomerContent;
        }

        field(7; "Message Type"; Enum "GDRG Birthday Message Type")
        {
            Caption = 'Message Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(Unique; "Employee No.", "Birthday Year", "User ID")
        {
            Unique = true;
        }
    }

    trigger OnInsert()
    begin
        if "Message Date" = 0D then
            "Message Date" := Today;
    end;

    procedure SetMessageText(NewMessage: Text)
    var
        outStream: OutStream;
    begin
        Clear(Message);
        Message.CreateOutStream(outStream, TextEncoding::UTF8);
        outStream.WriteText(NewMessage);
    end;

    procedure GetMessageText(): Text
    var
        inStream: InStream;
        messageText: Text;
    begin
        CalcFields(Message);
        if not Message.HasValue then
            exit('');

        Message.CreateInStream(inStream, TextEncoding::UTF8);
        inStream.ReadText(messageText);
        exit(messageText);
    end;
}
