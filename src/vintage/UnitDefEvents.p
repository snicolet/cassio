UNIT UnitDefEvents;


INTERFACE


USES AppleEvents, AEDataModel, MacTypes, Events, CarbonEventsCore;

CONST EscapeKey = 27;

      _WaitNextEvent = $A860;

VAR
		theEvent : eventrecord;
		EmplacementDernierClic : Point;
    instantDernierClic : SInt32;


var  gHasAppleEvents : boolean;

     gHandleOAppUPP       : AEEventHandlerUPP;
     gHandleDocUPP        : AEEventHandlerUPP;
     gHandleQuitUPP       : AEEventHandlerUPP;
     gHandleMouseWheelUPP : EventHandlerUPP;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}








END.
