pageextension 50121 "Customer Card ICS Export" extends "Customer Card"
{
    actions
    {
        addlast(creation)
        {
            action("CreateCalendarEvent")
            {
                Caption = 'Create Calendar Event';
                Image = CalendarChanged;
                ToolTip = 'Specifies the action to create a calendar event for the customer.';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ICSBusinessHelper: Codeunit "ICS Business Helper";
                begin
                    ICSBusinessHelper.BuildCustomerEvent(Rec);
                end;
            }
        }
    }
}
