namespace JeremyVyskaClasses.DeliveryWindows;

using Microsoft.Sales.Setup;

pageextension 50101 "JV Sales & Rec. Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(General)
        {
            field("JV Require Deliv. Window"; Rec."JV Require Deliv. Window")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that sales orders need a delivery window before they can be released.';
            }
        }
    }
}
