page 60007 "GDRG Assistant Session Input"
{
    Caption = 'Assistant Session Input';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Parameters)
            {
                Caption = 'Assistant Parameters';
                field(QuestionPrompt; Prompt)
                {
                    Caption = 'Question/Prompt';
                    ToolTip = 'Specifies the question to ask the weather assistant (e.g., Does the current climate in Lleida allow for the use of electric vehicles for deliveries without the risk of running out of battery?).';
                    NotBlank = true;
                    MultiLine = true;
                }
            }
        }
    }

    var
        Prompt: Text[2048];

    procedure SetDefaults(DefaultPrompt: Text)
    begin
        Prompt := CopyStr(DefaultPrompt, 1, 2048);
    end;

    procedure GetPrompt(): Text[2048]
    begin
        exit(Prompt);
    end;
}
