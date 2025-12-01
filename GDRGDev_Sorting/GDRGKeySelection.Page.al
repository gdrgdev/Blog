page 78452 "GDRG Key Selection"
{
    PageType = List;
    SourceTable = "GDRG Table Key";
    SourceTableTemporary = true;
    Caption = 'Select Sort Order';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Keys)
            {
                field("Key Name"; Rec."Key Name")
                {
                    ApplicationArea = All;
                    Caption = 'Sort By';
                    Style = Strong;
                    StyleExpr = Rec."Is Primary";

                    trigger OnDrillDown()
                    begin
                        SelectedKeyNo := Rec."Key No.";
                        CurrPage.Close();
                    end;
                }
                field("Key Fields"; Rec."Key Fields")
                {
                    ApplicationArea = All;
                    Caption = 'Fields in this Sort Order';
                }
                field("Field Count"; Rec."Field Count")
                {
                    ApplicationArea = All;
                    Caption = 'Number of Fields';
                }
            }
        }
    }

    var
        SelectedKeyNo: Integer;

    /// <summary>
    /// Loads the available keys for a table
    /// </summary>
    /// <param name="TableNo">The table number to retrieve keys from.</param>
    procedure LoadKeys(TableNo: Integer)
    var
        KeyManager: Codeunit "GDRG Key Manager";
    begin
        KeyManager.GetTableKeys(TableNo, Rec);

        if Rec.FindFirst() then; // Position cursor on first record in the list
    end;

    /// <summary>
    /// Retrieves the key number selected by the user
    /// </summary>
    /// <returns>The selected key number.</returns>
    procedure GetSelectedKeyNo(): Integer
    begin
        exit(SelectedKeyNo);
    end;

    trigger OnOpenPage()
    begin
        SelectedKeyNo := 0;
    end;
}
