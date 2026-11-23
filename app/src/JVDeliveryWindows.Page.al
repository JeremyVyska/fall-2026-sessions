namespace JeremyVyskaClasses.DeliveryWindows;

page 50100 "JV Delivery Windows"
{
    ApplicationArea = All;
    Caption = 'Delivery Windows';
    PageType = List;
    SourceTable = "JV Delivery Window";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Windows)
            {
                field("Code"; Rec."Code")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code of the delivery window.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the delivery window.';
                }
                field("Start Time"; Rec."Start Time")
                {
                    ToolTip = 'Specifies when the delivery window opens.';
                }
                field("End Time"; Rec."End Time")
                {
                    ToolTip = 'Specifies when the delivery window closes.';
                }
                field("Max. Orders per Day"; Rec."Max. Orders per Day")
                {
                    ToolTip = 'Specifies how many orders can be booked into the window per day. Zero means no limit.';
                }
                field("Min. Lead Time (Days)"; Rec."Min. Lead Time (Days)")
                {
                    ToolTip = 'Specifies how many days ahead of the requested delivery date an order must be booked into the window. Zero means no minimum.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies that the window cannot be assigned to orders.';
                }
            }
        }
    }
}
