pageextension 78453 "GDRG Customer List Ext" extends "Customer List"
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
                    Customer: Record Customer;
                    KeyManager: Codeunit "GDRG Key Manager";
                    KeySelectionPage: Page "GDRG Key Selection";
                    CustomerList: Page "Customer List";
                    KeyDescription: Text;
                    TableViewText: Text;
                    SelectedKeyNo: Integer;
                    CouldNotBuildSortingErr: Label 'Could not build sorting view for the selected key.';
                begin
                    // Load available keys from Customer table
                    KeySelectionPage.LoadKeys(Database::Customer);

                    // Show selection page to user
                    KeySelectionPage.RunModal();
                    SelectedKeyNo := KeySelectionPage.GetSelectedKeyNo();

                    if SelectedKeyNo > 0 then begin
                        // Build TableView with selected key
                        TableViewText := KeyManager.BuildTableViewFromKey(Database::Customer, SelectedKeyNo);
                        KeyDescription := KeyManager.GetKeyDescriptionForCaption(Database::Customer, SelectedKeyNo);

                        if TableViewText <> '' then begin
                            // Apply view to record
                            Customer.SetView(TableViewText);

                            // Open new window with sorting applied
                            CustomerList.SetTableView(Customer);
                            CustomerList.Caption := 'Customers - Sorted by: ' + KeyDescription;
                            CustomerList.Run();
                        end else
                            Error(CouldNotBuildSortingErr);
                    end;
                end;
            }
        }
    }
}
