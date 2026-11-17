    [Test]
    procedure BehaviourInPascalCase()
    var
        BookedOrder: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        WindowCode: Code[10];
    begin
        // [SCENARIO] One sentence describing the behaviour
        // [GIVEN] The starting state, built with library calls
        WindowCode := LibraryDeliveryWindow.CreateDeliveryWindow(1);
        LibraryDeliveryWindow.BookOrder(BookedOrder, WindowCode, Tomorrow());
        LibraryDeliveryWindow.CreateSalesOrder(SalesHeader, Tomorrow());

        // [WHEN] The single action under test
        asserterror SalesHeader.Validate("JV Delivery Window Code", WindowCode);

        // [THEN] The observable result
        Assert.ExpectedError('is fully booked');
    end;
