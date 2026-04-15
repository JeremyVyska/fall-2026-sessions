namespace JeremyVyskaClasses.DeliveryWindows;

using Microsoft.Sales.Document;

pageextension 50100 "JV Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Requested Delivery Date")
        {
            field("JV Delivery Window Code"; Rec."JV Delivery Window Code")
            {
                ApplicationArea = All;
                ShowMandatory = DeliveryWindowRequired;
                ToolTip = 'Specifies the delivery window the order is booked into.';
            }
        }
    }

    trigger OnOpenPage()
    var
        DeliveryWindowMgt: Codeunit "JV Delivery Window Mgt.";
    begin
        DeliveryWindowRequired := DeliveryWindowMgt.IsDeliveryWindowRequired();
    end;

    var
        DeliveryWindowRequired: Boolean;
}
