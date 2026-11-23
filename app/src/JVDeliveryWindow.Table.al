namespace JeremyVyskaClasses.DeliveryWindows;

table 50100 "JV Delivery Window"
{
    Caption = 'Delivery Window';
    DataClassification = CustomerContent;
    DrillDownPageId = "JV Delivery Windows";
    LookupPageId = "JV Delivery Windows";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Start Time"; Time)
        {
            Caption = 'Start Time';

            trigger OnValidate()
            begin
                CheckTimes();
            end;
        }
        field(4; "End Time"; Time)
        {
            Caption = 'End Time';

            trigger OnValidate()
            begin
                CheckTimes();
            end;
        }
        field(5; "Max. Orders per Day"; Integer)
        {
            Caption = 'Max. Orders per Day';
            MinValue = 0;
        }
        field(6; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(7; "Min. Lead Time (Days)"; Integer)
        {
            Caption = 'Min. Lead Time (Days)';
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        EndBeforeStartErr: Label 'End Time must be later than Start Time.';

    local procedure CheckTimes()
    begin
        if ("Start Time" = 0T) or ("End Time" = 0T) then
            exit;
        if "End Time" <= "Start Time" then
            Error(EndBeforeStartErr);
    end;
}
