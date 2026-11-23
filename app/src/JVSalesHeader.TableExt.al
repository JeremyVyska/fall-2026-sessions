namespace JeremyVyskaClasses.DeliveryWindows;

using Microsoft.Sales.Document;

tableextension 50100 "JV Sales Header" extends "Sales Header"
{
    fields
    {
        field(50100; "JV Delivery Window Code"; Code[10])
        {
            Caption = 'Delivery Window Code';
            DataClassification = CustomerContent;
            TableRelation = "JV Delivery Window" where(Blocked = const(false));

            trigger OnValidate()
            var
                DeliveryWindowMgt: Codeunit "JV Delivery Window Mgt.";
            begin
                DeliveryWindowMgt.CheckBooking(Rec);
            end;
        }
        modify("Requested Delivery Date")
        {
            trigger OnAfterValidate()
            var
                DeliveryWindowMgt: Codeunit "JV Delivery Window Mgt.";
            begin
                DeliveryWindowMgt.CheckBooking(Rec);
            end;
        }
    }
}
