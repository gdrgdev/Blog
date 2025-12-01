pageextension 78455 "GDRG Sales Order List Ext" extends "Sales Order List"
{
    actions
    {
        addlast(processing)
        {
            action(ChangeSortOrder)
            {
                ApplicationArea = All;
                Caption = 'Change Sort Order';
                ToolTip = 'Select a different sort order from the available keys to view the list sorted by different fields.';
                Image = SortAscending;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    KeyManager: Codeunit "GDRG Key Manager";
                    KeySelectionPage: Page "GDRG Key Selection";
                    SalesOrderList: Page "Sales Order List";
                    KeyDescription: Text;
                    TableViewText: Text;
                    SelectedKeyNo: Integer;
                    CouldNotBuildSortingErr: Label 'Could not build sorting view for the selected key.';
                begin
                    // Load available keys from Sales Header table
                    KeySelectionPage.LoadKeys(Database::"Sales Header");

                    // Show selection page to user
                    KeySelectionPage.RunModal();
                    SelectedKeyNo := KeySelectionPage.GetSelectedKeyNo();

                    if SelectedKeyNo > 0 then begin
                        // Build TableView with selected key
                        TableViewText := KeyManager.BuildTableViewFromKey(Database::"Sales Header", SelectedKeyNo);
                        KeyDescription := KeyManager.GetKeyDescriptionForCaption(Database::"Sales Header", SelectedKeyNo);

                        if TableViewText <> '' then begin
                            // Apply document type filter and view to record
                            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                            SalesHeader.SetView(TableViewText);

                            // Open new window with sorting applied
                            SalesOrderList.SetTableView(SalesHeader);
                            SalesOrderList.Caption := 'Sales Orders - Sorted by: ' + KeyDescription;
                            SalesOrderList.Run();
                        end else
                            Error(CouldNotBuildSortingErr);
                    end;
                end;
            }
        }
    }
}
