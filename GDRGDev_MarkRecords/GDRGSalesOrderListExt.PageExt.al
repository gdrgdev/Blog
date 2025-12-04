pageextension 77892 "GDRG Sales Order List Ext" extends "Sales Order List"
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
        addbefore(ShippedNotInvoiced)
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
        SalesHeader: Record "Sales Header";
    begin
        CurrPage.SetSelectionFilter(SalesHeader);

        if not SalesHeader.FindFirst() then
            exit;

        if SalesHeader.Count() = 1 then begin
            if Rec.GDRGMarkStatus = Rec.GDRGMarkStatus::Marked then
                Rec.GDRGMarkStatus := Rec.GDRGMarkStatus::" "
            else
                Rec.GDRGMarkStatus := Rec.GDRGMarkStatus::Marked;
            Rec.Modify(true);
        end else
            if SalesHeader.FindSet() then
                repeat
                    if SalesHeader.GDRGMarkStatus = SalesHeader.GDRGMarkStatus::Marked then
                        SalesHeader.GDRGMarkStatus := SalesHeader.GDRGMarkStatus::" "
                    else
                        SalesHeader.GDRGMarkStatus := SalesHeader.GDRGMarkStatus::Marked;
                    SalesHeader.Modify(true);
                until SalesHeader.Next() = 0;

        CurrPage.Update(false);
    end;

    local procedure UnmarkAllRecords()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange(GDRGMarkStatus, SalesHeader.GDRGMarkStatus::Marked);
        SalesHeader.ModifyAll(GDRGMarkStatus, SalesHeader.GDRGMarkStatus::" ", false);
        CurrPage.Update(false);
    end;
}
