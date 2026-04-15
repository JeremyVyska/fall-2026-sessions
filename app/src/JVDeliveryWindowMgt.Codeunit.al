namespace JeremyVyskaClasses.DeliveryWindows;

using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;

codeunit 50100 "JV Delivery Window Mgt."
{
    var
        WindowFullErr: Label 'Delivery window %1 is fully booked on %2 (%3 orders).', Comment = '%1 = window code, %2 = date, %3 = max. orders';

    internal procedure CheckCapacity(SalesHeader: Record "Sales Header")
    var
        DeliveryWindow: Record "JV Delivery Window";
    begin
        if (SalesHeader."JV Delivery Window Code" = '') or (SalesHeader."Requested Delivery Date" = 0D) then
            exit;

        DeliveryWindow.Get(SalesHeader."JV Delivery Window Code");
        if DeliveryWindow."Max. Orders per Day" = 0 then
            exit;

        if CountBookedOrders(SalesHeader) >= DeliveryWindow."Max. Orders per Day" then
            Error(WindowFullErr, DeliveryWindow."Code", SalesHeader."Requested Delivery Date", DeliveryWindow."Max. Orders per Day");
    end;

    internal procedure CheckBeforeRelease(SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        if SalesHeader."JV Delivery Window Code" <> '' then
            exit;

        if IsDeliveryWindowRequired() then
            SalesHeader.TestField("JV Delivery Window Code");
    end;

    internal procedure IsDeliveryWindowRequired(): Boolean
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.SetLoadFields("JV Require Deliv. Window");
        if SalesSetup.Get() then
            exit(SalesSetup."JV Require Deliv. Window");
    end;

    local procedure CountBookedOrders(SalesHeader: Record "Sales Header"): Integer
    var
        BookedOrder: Record "Sales Header";
    begin
        BookedOrder.SetRange("Document Type", BookedOrder."Document Type"::Order);
        BookedOrder.SetRange("JV Delivery Window Code", SalesHeader."JV Delivery Window Code");
        BookedOrder.SetRange("Requested Delivery Date", SalesHeader."Requested Delivery Date");
        BookedOrder.SetFilter("No.", '<>%1', SalesHeader."No.");
        exit(BookedOrder.Count());
    end;
}
