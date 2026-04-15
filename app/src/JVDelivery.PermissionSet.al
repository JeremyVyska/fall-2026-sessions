namespace JeremyVyskaClasses.DeliveryWindows;

permissionset 50100 "JV Delivery"
{
    Assignable = true;
    Caption = 'Delivery Windows';

    Permissions =
        tabledata "JV Delivery Window" = RIMD,
        table "JV Delivery Window" = X,
        page "JV Delivery Windows" = X,
        codeunit "JV Delivery Window Mgt." = X,
        codeunit "JV Delivery Window Events" = X;
}
