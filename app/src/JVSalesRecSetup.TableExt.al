namespace JeremyVyskaClasses.DeliveryWindows;

using Microsoft.Sales.Setup;

tableextension 50101 "JV Sales & Rec. Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50100; "JV Require Deliv. Window"; Boolean)
        {
            Caption = 'Require Delivery Window';
            DataClassification = CustomerContent;
        }
    }
}
