pageextension 77891 "GDRG Customer List Ext" extends "Customer List"
{
    layout
    {
        addafter("No.")
        {
            field(GDRGMarkStatus; Rec.GDRGMarkStatus)
            {
                ApplicationArea = All;
                Editable = false;
                DrillDown = false;
                Width = 1;
            }
        }
    }

    actions
    {
        addfirst(processing)
        {
            action(GDRGMarkRecord)
            {
                ApplicationArea = All;
                Caption = 'Mark/Unmark (Ctrl+F3)';
                ToolTip = 'Specifies to toggle mark on current or selected records.';
                Image = CheckList;
                ShortcutKey = 'Ctrl+F3';

                trigger OnAction()
                begin
                    ToggleMarkRecords();
                end;
            }

            action(GDRGUnmarkAll)
            {
                ApplicationArea = All;
                Caption = 'Unmark All (Ctrl+Shift+F3)';
                ToolTip = 'Specifies to remove marks from all records.';
                Image = ClearFilter;
                ShortcutKey = 'Ctrl+Shift+F3';

                trigger OnAction()
                begin
                    UnmarkAllRecords();
                end;
            }
        }
    }
    views
    {
        addlast
        {
            view(GDRGMarkedRecords)
            {
                Caption = 'Marked Only';
                Filters = where(GDRGMarkStatus = const(Marked));
            }
        }

    }
    local procedure ToggleMarkRecords()
    var
        Customer: Record Customer;
    begin
        CurrPage.SetSelectionFilter(Customer);

        if not Customer.FindFirst() then
            exit;

        if Customer.Count() = 1 then begin
            if Rec.GDRGMarkStatus = Rec.GDRGMarkStatus::Marked then
                Rec.GDRGMarkStatus := Rec.GDRGMarkStatus::" "
            else
                Rec.GDRGMarkStatus := Rec.GDRGMarkStatus::Marked;
            Rec.Modify(true);
        end else
            if Customer.FindSet() then
                repeat
                    if Customer.GDRGMarkStatus = Customer.GDRGMarkStatus::Marked then
                        Customer.GDRGMarkStatus := Customer.GDRGMarkStatus::" "
                    else
                        Customer.GDRGMarkStatus := Customer.GDRGMarkStatus::Marked;
                    Customer.Modify(true);
                until Customer.Next() = 0;

        CurrPage.Update(false);
    end;

    local procedure UnmarkAllRecords()
    var
        Customer: Record Customer;
    begin
        Customer.SetRange(GDRGMarkStatus, Customer.GDRGMarkStatus::Marked);
        Customer.ModifyAll(GDRGMarkStatus, Customer.GDRGMarkStatus::" ", false);
        CurrPage.Update(false);
    end;

}
