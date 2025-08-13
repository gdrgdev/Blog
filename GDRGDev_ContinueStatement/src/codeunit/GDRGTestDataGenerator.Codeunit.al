codeunit 50102 "GDRG Test Data Generator"
{
    Permissions = tabledata "GDRG Valid Customers" = RIMD,
        tabledata "Customer" = RIMD;
    procedure GenerateTestCustomers()
    var
        Customer: Record Customer;
        TestCustomer: Record Customer;
        Counter: Integer;
        RandomNo: Integer;
    begin
        // Limpiar clientes de prueba existentes
        Customer.SetRange("No.", 'TEST001', 'TEST020');
        Customer.DeleteAll(false);

        // Crear 20 clientes de prueba
        for Counter := 1 to 20 do begin
            TestCustomer.Init();
            TestCustomer."No." := 'TEST' + Format(Counter, 3, '<Integer,3><Filler Character,0>');
            TestCustomer.Name := 'Test Customer ' + Format(Counter);

            // Blocked aleatoriamente (30% bloqueados)
            RandomNo := Random(10);
            if RandomNo <= 3 then
                TestCustomer.Blocked := TestCustomer.Blocked::All
            else
                TestCustomer.Blocked := TestCustomer.Blocked::" ";

            // Email aleatoriamente (70% tienen email)
            RandomNo := Random(10);
            if RandomNo <= 7 then
                TestCustomer."E-Mail" := 'test' + Format(Counter) + '@testcompany.com'
            else
                TestCustomer."E-Mail" := '';

            // Phone aleatoriamente (80% tienen teléfono)
            RandomNo := Random(10);
            if RandomNo <= 8 then
                TestCustomer."Phone No." := '+34 ' + Format(Random(999), 3, '<Integer,3><Filler Character,0>') + ' ' + Format(Random(999), 3, '<Integer,3><Filler Character,0>') + ' ' + Format(Random(999), 3, '<Integer,3><Filler Character,0>')
            else
                TestCustomer."Phone No." := '';

            TestCustomer.Insert(false);
        end;

        Message('%1 test customers created successfully!', 20);
    end;

    procedure RefreshValidCustomers()
    var
        Customer: Record Customer;
        ValidCustomer: Record "GDRG Valid Customers";
        ValidCount: Integer;
        EntryNo: Integer;
    begin
        // Limpiar tabla de válidos
        ValidCustomer.DeleteAll(false);

        // Buscar clientes válidos
        Customer.SetRange("No.", 'TEST001', 'TEST020');
        if Customer.FindSet() then
            repeat
                if (Customer.Blocked = Customer.Blocked::" ") and
                   (Customer."E-Mail" <> '') and
                   (Customer."Phone No." <> '') then begin

                    // Obtener siguiente Entry No.
                    EntryNo += 1;

                    ValidCustomer.Init();
                    ValidCustomer."Entry No." := EntryNo;
                    ValidCustomer."Customer No." := Customer."No.";
                    ValidCustomer.Name := Customer.Name;
                    ValidCustomer.Blocked := Customer.Blocked;
                    ValidCustomer."E-Mail" := Customer."E-Mail";
                    ValidCustomer."Phone No." := Customer."Phone No.";
                    ValidCustomer."Method Used" := 'Manual Refresh';
                    ValidCustomer.Insert(false);
                    ValidCount += 1;
                end;
            until Customer.Next() = 0;

        Message('%1 valid customers found and loaded!', ValidCount);
    end;

    procedure ClearTestData()
    var
        Customer: Record Customer;
        ValidCustomer: Record "GDRG Valid Customers";
    begin
        // Limpiar clientes de prueba
        Customer.SetRange("No.", 'TEST001', 'TEST020');
        Customer.DeleteAll(false);

        // Limpiar tabla de válidos
        ValidCustomer.DeleteAll(false);

        Message('All test data cleared!');
    end;
}
