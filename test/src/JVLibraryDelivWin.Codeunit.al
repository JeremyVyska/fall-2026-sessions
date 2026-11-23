namespace JeremyVyskaClasses.DeliveryWindows.Test;

using JeremyVyskaClasses.DeliveryWindows;
using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;

codeunit 50150 "JV Library - Deliv. Win."
{
    var
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateDeliveryWindow(MaxOrdersPerDay: Integer): Code[10]
    var
        DeliveryWindow: Record "JV Delivery Window";
    begin
        DeliveryWindow."Code" := CopyStr(
            LibraryUtility.GenerateRandomCode(DeliveryWindow.FieldNo("Code"), Database::"JV Delivery Window"),
            1, MaxStrLen(DeliveryWindow."Code"));
        DeliveryWindow.Validate("Start Time", 080000T);
        DeliveryWindow.Validate("End Time", 120000T);
        DeliveryWindow.Validate("Max. Orders per Day", MaxOrdersPerDay);
        DeliveryWindow.Insert(true);
        exit(DeliveryWindow."Code");
    end;

    procedure CreateDeliveryWindowWithLeadTime(MinLeadTimeDays: Integer): Code[10]
    var
        DeliveryWindow: Record "JV Delivery Window";
    begin
        DeliveryWindow.Get(CreateDeliveryWindow(0));
        DeliveryWindow.Validate("Min. Lead Time (Days)", MinLeadTimeDays);
        DeliveryWindow.Modify(true);
        exit(DeliveryWindow."Code");
    end;

    procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; DeliveryDate: Date)
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        SalesHeader.Validate("Requested Delivery Date", DeliveryDate);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), 1);
    end;

    procedure BookOrder(var SalesHeader: Record "Sales Header"; WindowCode: Code[10]; DeliveryDate: Date)
    begin
        CreateSalesOrder(SalesHeader, DeliveryDate);
        SalesHeader.Validate("JV Delivery Window Code", WindowCode);
        SalesHeader.Modify(true);
    end;

    procedure SetRequireDeliveryWindow(Required: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        SalesSetup.Validate("JV Require Deliv. Window", Required);
        SalesSetup.Modify(true);
    end;
}
