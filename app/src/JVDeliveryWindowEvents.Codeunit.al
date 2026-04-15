namespace JeremyVyskaClasses.DeliveryWindows;

using Microsoft.Sales.Document;

codeunit 50101 "JV Delivery Window Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure CheckWindowOnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    var
        DeliveryWindowMgt: Codeunit "JV Delivery Window Mgt.";
    begin
        DeliveryWindowMgt.CheckBeforeRelease(SalesHeader);
    end;
}
