pageextension 50122 "Sales Order ICS Export" extends "Sales Order"
{
    layout
    {
        modify("Posting Date")
        {
            Caption = '📅 Posting Date';
            AssistEdit = true;

            trigger OnAssistEdit()
            var
                ICSBusinessHelper: Codeunit "ICS Business Helper";
            begin
                ICSBusinessHelper.BuildSalesPostingEvent(Rec);
            end;
        }

        modify("Shipment Date")
        {
            Caption = '📅 Shipment Date';
            AssistEdit = true;

            trigger OnAssistEdit()
            var
                ICSBusinessHelper: Codeunit "ICS Business Helper";
            begin
                ICSBusinessHelper.BuildSalesShipmentEvent(Rec);
            end;
        }
    }

    actions
    {
        addlast(processing)
        {
            action("CreateCalendarEvent")
            {
                Caption = 'Create Calendar Event';
                Image = CalendarChanged;
                ToolTip = 'Specifies the action to create a calendar event for the sales order.';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ICSBusinessHelper: Codeunit "ICS Business Helper";
                begin
                    ICSBusinessHelper.BuildSalesPostingEvent(Rec);
                end;
            }
        }
    }
}
