namespace JeremyVyskaClasses.DeliveryWindows.Test;

using JeremyVyskaClasses.DeliveryWindows;
using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
using System.TestLibraries.Utilities;

// [FEATURE] [Delivery Window] Daily capacity and release requirement
codeunit 50151 "JV Delivery Window Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryDeliveryWindow: Codeunit "JV Library - Deliv. Win.";
        LibrarySales: Codeunit "Library - Sales";

    [Test]
    procedure WindowWithCapacityCanBeAssigned()
    var
        SalesHeader: Record "Sales Header";
        WindowCode: Code[10];
    begin
        // [SCENARIO] An order can be booked into a window with capacity left
        // [GIVEN] A window that takes two orders per day
        WindowCode := LibraryDeliveryWindow.CreateDeliveryWindow(2);

        // [WHEN] An order for tomorrow is booked into it
        LibraryDeliveryWindow.BookOrder(SalesHeader, WindowCode, Tomorrow());

        // [THEN] The order keeps the window code
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(WindowCode, SalesHeader."JV Delivery Window Code", 'Window code not stored.');
    end;

    [Test]
    procedure FullWindowRejectsNextOrder()
    var
        BookedOrder: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        WindowCode: Code[10];
    begin
        // [SCENARIO] A full window rejects another order for the same day
        // [GIVEN] A window that takes one order per day, booked for tomorrow
        WindowCode := LibraryDeliveryWindow.CreateDeliveryWindow(1);
        LibraryDeliveryWindow.BookOrder(BookedOrder, WindowCode, Tomorrow());

        // [WHEN] A second order for tomorrow is booked into it
        LibraryDeliveryWindow.CreateSalesOrder(SalesHeader, Tomorrow());
        asserterror SalesHeader.Validate("JV Delivery Window Code", WindowCode);

        // [THEN] The booking fails with the capacity error
        Assert.ExpectedError('is fully booked');
    end;

    [Test]
    procedure MovingOrderOntoFullDateFails()
    var
        BookedOrder: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        WindowCode: Code[10];
    begin
        // [SCENARIO] Changing the date re-checks the window's capacity
        // [GIVEN] A window that takes one order per day, booked for tomorrow
        WindowCode := LibraryDeliveryWindow.CreateDeliveryWindow(1);
        LibraryDeliveryWindow.BookOrder(BookedOrder, WindowCode, Tomorrow());

        // [GIVEN] A second order in the same window, the day after
        LibraryDeliveryWindow.BookOrder(SalesHeader, WindowCode, CalcDate('<+1D>', Tomorrow()));

        // [WHEN] The second order is moved to tomorrow
        asserterror SalesHeader.Validate("Requested Delivery Date", Tomorrow());

        // [THEN] The move fails with the capacity error
        Assert.ExpectedError('is fully booked');
    end;

    [Test]
    procedure ReleaseWithoutWindowFailsWhenRequired()
    var
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] Setup can require a window before release
        // [GIVEN] Setup requires a delivery window
        LibraryDeliveryWindow.SetRequireDeliveryWindow(true);

        // [GIVEN] An order without a window
        LibraryDeliveryWindow.CreateSalesOrder(SalesHeader, Tomorrow());

        // [WHEN] The order is released
        asserterror LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] Release fails because the window is not filled in
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(SalesHeader.FieldCaption("JV Delivery Window Code"));
    end;

    [Test]
    procedure ReleaseWithoutWindowSucceedsWhenNotRequired()
    var
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] Without the setup flag, orders release as before
        // [GIVEN] Setup does not require a delivery window
        LibraryDeliveryWindow.SetRequireDeliveryWindow(false);

        // [GIVEN] An order without a window
        LibraryDeliveryWindow.CreateSalesOrder(SalesHeader, Tomorrow());

        // [WHEN] The order is released
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The order is released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, 'Order not released.');
    end;

    [Test]
    procedure BookingInsideLeadTimeFails()
    var
        SalesHeader: Record "Sales Header";
        WindowCode: Code[10];
    begin
        // [SCENARIO] A window refuses an order that is too close to delivery
        // [GIVEN] A window with three days of lead time
        WindowCode := LibraryDeliveryWindow.CreateDeliveryWindowWithLeadTime(3);

        // [WHEN] An order two days ahead is booked into it
        LibraryDeliveryWindow.CreateSalesOrder(SalesHeader, DaysAhead(2));
        asserterror SalesHeader.Validate("JV Delivery Window Code", WindowCode);

        // [THEN] The booking fails with the lead time error, naming the earliest date
        Assert.ExpectedError('days of lead time');
        Assert.ExpectedError(Format(DaysAhead(3)));
    end;

    [Test]
    procedure BookingOnEarliestDateSucceeds()
    var
        SalesHeader: Record "Sales Header";
        WindowCode: Code[10];
    begin
        // [SCENARIO] The earliest allowed date is exactly the lead time ahead
        // [GIVEN] A window with three days of lead time
        WindowCode := LibraryDeliveryWindow.CreateDeliveryWindowWithLeadTime(3);

        // [WHEN] An order three days ahead is booked into it
        LibraryDeliveryWindow.BookOrder(SalesHeader, WindowCode, DaysAhead(3));

        // [THEN] The order keeps the window code
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(WindowCode, SalesHeader."JV Delivery Window Code", 'Window code not stored.');
    end;

    [Test]
    procedure MovingOrderInsideLeadTimeFails()
    var
        SalesHeader: Record "Sales Header";
        WindowCode: Code[10];
    begin
        // [SCENARIO] Changing the date re-checks the window's lead time
        // [GIVEN] A window with three days of lead time
        WindowCode := LibraryDeliveryWindow.CreateDeliveryWindowWithLeadTime(3);

        // [GIVEN] An order booked into it, three days ahead
        LibraryDeliveryWindow.BookOrder(SalesHeader, WindowCode, DaysAhead(3));

        // [WHEN] The order is moved to tomorrow
        asserterror SalesHeader.Validate("Requested Delivery Date", Tomorrow());

        // [THEN] The move fails with the lead time error
        Assert.ExpectedError('days of lead time');
    end;

    local procedure DaysAhead(Days: Integer): Date
    begin
        exit(WorkDate() + Days);
    end;

    local procedure Tomorrow(): Date
    begin
        exit(CalcDate('<+1D>', WorkDate()));
    end;
}
