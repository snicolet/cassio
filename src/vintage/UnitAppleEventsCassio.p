UNIT UnitAppleEventsCassio;


INTERFACE







 USES GestaltEqu , AppleEvents , AEDataModel , UnitDefCassio;




procedure InitUnitAppleEventsCassio;
procedure CheckAppleEvents;
function GotRequiredParameters(var theAppleEvent : AppleEvent) : OSErr;
function HandleOpenApplicationAppleEvent(var theAppleEvent, reply : AppleEvent; refCon: SInt32) : OSErr;
function HandleDocumentAppleEvent(var theAppleEvent,reply : AppleEvent; refCon : SInt32) : OSErr;
function HandleQuitApplicationAppleEvent (var theAppleEvent, reply : AppleEvent; refCon: SInt32) : OSErr;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, Files, CarbonEventsCore, CarbonEvents, ControlDefinitions, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitFenetres
    , UnitRapportImplementation, UnitBallade, UnitActions, UnitLongintScroller, UnitServicesRapport, UnitTraceLog, UnitRapport, UnitEvenement
    , UnitPrint ;
{$ELSEC}
    ;
    {$I prelink/AppleEventsCassio.lk}
{$ENDC}


{END_USE_CLAUSE}















procedure CheckAppleEvents;
var gestaltResponse : SInt32;
begin
	gHasAppleEvents := false;
	if GestaltImplemented then
	  if (Gestalt(gestaltAppleEventsAttr, gestaltResponse) = noErr) then
			gHasAppleEvents := BTST(gestaltResponse, gestaltAppleEventsPresent);
end;




function GotRequiredParameters(var theAppleEvent : AppleEvent) : OSErr;
var
	 myError,result : OSErr;
	 returnedType : DescType;
	 actualSize : Size;
begin
	myError := AEGetAttributePtr(theAppleEvent, keyMissedKeywordAttr, typeWildCard, @returnedType, NIL, 0, @actualSize);
	if (myError = errAEDescNotFound)
	  then result := NoErr
		else
		  if (myError = noErr)
		    then result := errAEParamMissed
		    else result := myError;
  GotRequiredParameters := result;

  {WritelnNumDansRapport('GotRequiredParameters : result = ',result);}
end;


function HandleOpenApplicationAppleEvent (var theAppleEvent, reply : AppleEvent; refCon: SInt32) : OSErr;
var err : OSErr;
begin
  {$UNUSED reply , refCon}

  err := GotRequiredParameters(theAppleEvent);
  {What am I supposed to do here?}
  HandleOpenApplicationAppleEvent := err;

  {WritelnNumDansRapport('HandleOpenApplicationAppleEvent : err = ',err);}
end;


function HandleDocumentAppleEvent(var theAppleEvent,reply : AppleEvent; refCon : SInt32) : OSErr;
var theError : OSErr;
    docList:AEDescList;
    itemsInList : SInt32;
    index : SInt32;
    Keyword : AEKeyword;
    returnedType : DescType;
    theFileSpec : fileInfo;
    actualSize : Size;
    bidErr : OSErr;
begin
	{$UNUSED reply}
	theError := AEGetParamDesc(theAppleEvent, keyDirectObject, typeAEList,  docList);
	if (theError = noErr) then
	  begin
		  theError := GotRequiredParameters(theAppleEvent);
		  if (theError = noErr) then
		    begin
			    theError := AECountItems(docList, itemsInList);
			    if (theError = noErr) then
			      begin
				     for index := 1 to itemsInList do
				       begin
					       theError := AEGetNthPtr(docList, index, typeFSS, @keyword, @returnedType, @theFileSpec, sizeof(theFileSpec), @actualSize);
					       if (theError = noErr) then
					         begin
						        if (refCon = SInt32(MY_FOUR_CHAR_CODE('odoc')))   {kAEOpenDocuments}
						          then
							          begin
							            bidErr := OuvrirFichierPartieFSp(theFileSpec, AllKnownFormats, true);
							            Leave;  {Cassio est monodocument !}
							          end
						          else
						        if (refCon = SInt32(MY_FOUR_CHAR_CODE('pdoc')))   {kAEPrintDocuments}
							        then
							          begin
							            if OuvrirFichierPartieFSp(theFileSpec, AllKnownFormats, true) = NoErr then
							              DoDialogueApercuAvantImpression;
							            Leave;  {Cassio est monodocument !}
							          end
					         end;
				       end;
			     end;
		   end;
		bidErr := AEDisposeDesc(docList);
	end;
	HandleDocumentAppleEvent := theError;
end;



function HandleQuitApplicationAppleEvent (var theAppleEvent, reply: AppleEvent; refCon: SInt32) : OSErr;
var theError : OSErr;
begin
  {$UNUSED reply,refCon}

  theError := GotRequiredParameters(theAppleEvent);
  if (theError = NoErr) then
    begin
      {WritelnNumDansRapport('HandleQuitApplicationAppleEvent ',0);}
      DoQuit;
      if not(Quitter) then theError := userCanceledErr;
    end;

  HandleQuitApplicationAppleEvent := theError;
end;


function InstallRequiredAppleEvents : OSErr;
var result : OSErr;
begin

	gHandleOAppUPP := NewAEEventHandlerUPP(AEEventHandlerProcPtr(@HandleOpenApplicationAppleEvent));
	gHandleDocUPP := NewAEEventHandlerUPP(AEEventHandlerProcPtr(@HandleDocumentAppleEvent));
	gHandleQuitUPP := NewAEEventHandlerUPP(AEEventHandlerProcPtr(@HandleQuitApplicationAppleEvent));

  {TraceLog('InstallRequiredAppleEvents');}

	result := AEInstallEventHandler(MY_FOUR_CHAR_CODE('aevt'),MY_FOUR_CHAR_CODE('oapp'),gHandleOAppUPP, 0, false);
	result := AEInstallEventHandler(kCoreEventClass, kAEQuitApplication,gHandleQuitUPP, 0, false);
	result := AEInstallEventHandler(MY_FOUR_CHAR_CODE('aevt'),MY_FOUR_CHAR_CODE('odoc'),gHandleDocUPP,SInt32(MY_FOUR_CHAR_CODE('odoc')), false);
	result := AEInstallEventHandler(MY_FOUR_CHAR_CODE('aevt'),MY_FOUR_CHAR_CODE('pdoc'),gHandleDocUPP,SInt32(MY_FOUR_CHAR_CODE('pdoc')), false);


	{WritelnNumDansRapport('InstallRequiredAppleEvents : result = ',result);}

	InstallRequiredAppleEvents := result;
end;


var
  gDernierTickDeplacementHorizontalParRoulette : SInt32;
  gDernierDeplacementHorizontal : SInt32;
  gNbCoupsDeRouletteTresRapides : SInt32;

const
  kEventMouseScroll = 11;
  kDelaiPourDeplacementHorizontalParRoulette = 1;   { en ticks }

function MouseWeelHandler (nextHandler: EventHandlerCallRef; whichEvent: EventRef; userData: UnivPtr): OSStatus;
var {$unused nextHandler, userData}
	eventClass : UInt32;
	eventKind : UInt32;
	axis : EventMouseWheelAxis;
	deltaLignes, signe : SInt32;
	deplacementHorizontal : SInt32;
	err : OSStatus;
	mightyMouseDeltaX : SInt32;
	mightyMouseDeltaY : SInt32;
	kEventParamMouseWheelSmoothVerticalDelta : SInt32;
	kEventParamMouseWheelSmoothHorizontalDelta : SInt32;
	deltaLignesToScroll : SInt32;
	ancPosPouce, deltaTemps : SInt32;
	i, aux : SInt32;
	vitesse : SInt32;
begin

  MouseWeelHandler := eventNotHandledErr;


  eventClass := GetEventClass(whichEvent);
	eventKind  := GetEventKind(whichEvent);

	deltaLignesToScroll := 0;
	deplacementHorizontal := 0;

	if (eventClass = kEventClassMouse) then
	  begin

      MouseWeelHandler := NoErr;

	    case eventKind of

	      kEventMouseWheelMoved :
	        begin
	          err := GetEventParameter( whichEvent, kEventParamMouseWheelAxis, typeMouseWheelAxis, NIL, sizeof(axis), NIL, @axis );
	          if (err = NoErr) then err := GetEventParameter( whichEvent, kEventParamMouseWheelDelta, typeLongInteger, NIL, sizeof(deltaLignes), NIL, @deltaLignes );

	          if (err = NoErr) and (axis = kEventMouseWheelAxisY) then
	            deltaLignesToScroll := deltaLignes;

	          (*if (err = NoErr) and (axis = kEventMouseWheelAxisY) then
	            WritelnNumDansRapport('deltaLignesToScroll {1} = ',deltaLignesToScroll); *)

	          if false then
	          if (err = NoErr) and (axis = kEventMouseWheelAxisX) then
	            begin



	              deplacementHorizontal := -deltaLignes;

	              if (deplacementHorizontal >= 0)
	                then
	                  signe := +1
	                else
	                  begin
	                    signe := -1;
	                    deplacementHorizontal := -deplacementHorizontal;
	                  end;

	              deltaTemps := Abs(TickCount - gDernierTickDeplacementHorizontalParRoulette);

	              vitesse := 20;

	              if (deltaTemps > 15)
	                then
	                  begin
	                    // premiere utilisation de la roulette horizontale depuis un certain temps => on neglige
	                    gDernierTickDeplacementHorizontalParRoulette := TickCount;
	                    deplacementHorizontal := 0;
	                    gDernierDeplacementHorizontal := 0;
	                    gNbCoupsDeRouletteTresRapides := 0;
	                    {WritelnDansRapport('');}
	                  end
	                else
    	              if (deltaTemps < kDelaiPourDeplacementHorizontalParRoulette)
    	                then
    	                  begin
    	                    // coups de roulette horizontal trop rapproches => on neglige


    	                    if ((1.0*deplacementHorizontal/(deltaTemps+1)) >= vitesse) and
    	                       (deplacementHorizontal >= 40)
  	                        then
  	                          begin
  	                            aux := deplacementHorizontal div vitesse;

  	                            gNbCoupsDeRouletteTresRapides := gNbCoupsDeRouletteTresRapides + 1;


  	                            if (deplacementHorizontal div (deltaTemps + 1)) >= 40 then inc(gNbCoupsDeRouletteTresRapides);
  	                            if (deplacementHorizontal) >= 75 then inc(gNbCoupsDeRouletteTresRapides);
  	                            if (deplacementHorizontal) >= 100 then inc(gNbCoupsDeRouletteTresRapides);

  	                            {WritelnNumDansRapport('u = ',deplacementHorizontal div (deltaTemps+1));}



  	                            if gNbCoupsDeRouletteTresRapides >= 3
  	                              then deplacementHorizontal := 60 * aux
  	                              else deplacementHorizontal := 0;
  	                          end
    	                      else deplacementHorizontal := 0;

    	                    inc(gDernierDeplacementHorizontal);
    	                  end
    	                else
    	                  begin

  	                      if (deltaTemps <> 0) and
  	                         ((1.0*deplacementHorizontal/deltaTemps) >= vitesse) and
  	                         (deltaTemps <= 10) and
  	                         (deplacementHorizontal >= 40)
  	                        then
  	                          begin

  	                            aux := deplacementHorizontal div vitesse;

  	                            gNbCoupsDeRouletteTresRapides := gNbCoupsDeRouletteTresRapides + 1;

  	                            if (deplacementHorizontal div deltaTemps) >= 40 then inc(gNbCoupsDeRouletteTresRapides);
  	                            if (deplacementHorizontal) >= 75 then inc(gNbCoupsDeRouletteTresRapides);
  	                            if (deplacementHorizontal) >= 100 then inc(gNbCoupsDeRouletteTresRapides);

  	                            {WritelnNumDansRapport('v = ',(deplacementHorizontal div deltaTemps));}


  	                            if gNbCoupsDeRouletteTresRapides >= 3
  	                              then deplacementHorizontal := 60 * aux
  	                              else deplacementHorizontal := 1;
  	                          end
  	                        else
  	                          if deplacementHorizontal > 0 then deplacementHorizontal := 1;

  	                      {
  	                      if deplacementHorizontal > gDernierDeplacementHorizontal then
  	                        begin
  	                          deplacementHorizontal := gDernierDeplacementHorizontal + 1;
  	                          inc(deplacementHorizontal);
  	                        end;
  	                      }

  	                      if deplacementHorizontal <> 0 then gDernierTickDeplacementHorizontalParRoulette := TickCount;

  	                    end;

  	            if signe < 0
  	              then deplacementHorizontal := -deplacementHorizontal;

  	            {
  	            WriteNumDansRapport('(r,Æ,dep,t,r) = (',gNbCoupsDeRouletteTresRapides);
  	            WriteNumDansRapport(',',-deltaLignes);
  	            WriteNumDansRapport(',',deplacementHorizontal);
  	            WriteNumDansRapport(',',deltaTemps);

  	            WritelnDansRapport(')');
  	            }



	            end;


	        end;

	      kEventMouseScroll :
	        begin
	          kEventParamMouseWheelSmoothVerticalDelta   := EventParamName(MY_FOUR_CHAR_CODE('saxy'));
	          kEventParamMouseWheelSmoothHorizontalDelta := EventParamName(MY_FOUR_CHAR_CODE('saxx'));


            err := GetEventParameter( whichEvent, kEventParamMouseWheelSmoothHorizontalDelta, typeLongInteger, NIL, sizeof(mightyMouseDeltaX), NIL, @mightyMouseDeltaX );
            err := GetEventParameter( whichEvent, kEventParamMouseWheelSmoothVerticalDelta, typeLongInteger, NIL, sizeof(mightyMouseDeltaY), NIL, @mightyMouseDeltaY );


            if (err = NoErr) then
              deltaLignesToScroll := (mightyMouseDeltaY div GetHauteurChaqueLigneDansListe);

            if (err = NoErr) then
              WritelnNumDansRapport('deltaLignesToScroll {2} = ',mightyMouseDeltaY);


            {WritelnNumDansRapport('dep hor = ',mightyMouseDeltaX);}
	        end;
	    end; {case}
	  end;


  if (deltaLignesToScroll <> 0) then
    begin
      if windowListeOpen and (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow)) then
         with infosListeParties do
           begin
             ancPosPouce := positionPouceAscenseurListe;
             positionPouceAscenseurListe := positionPouceAscenseurListe - deltaLignesToScroll;
             SetValeurAscenseurListe(positionPouceAscenseurListe);
             if ancPosPouce <> positionPouceAscenseurListe then
               EcritListeParties(false,'MouseWeelHandler');
           end else
       if FenetreRapportEstOuverte and (OrdreFenetre(GetRapportWindow) < OrdreFenetre(wListePtr)) then
         begin
           if (deltaLignesToScroll < 0) then
             for i := 1 to Abs(deltaLignesToScroll) do
               TrackScrollingRapport(GetVerticalScrollerOfRapport,kControlDownButtonPart);

           if (deltaLignesToScroll > 0) then
             for i := 1 to Abs(deltaLignesToScroll) do
               TrackScrollingRapport(GetVerticalScrollerOfRapport,kControlUpButtonPart);
         end;

       MouseWeelHandler := NoErr;
   end;


   if deplacementHorizontal <> 0 then
     begin
       SeDeplacerDansLaPartieDeTantDeCoups(deplacementHorizontal,false);
       MouseWeelHandler := NoErr;
     end;



end;



function InstallApplicationEventHandler : OSErr;
var
  commandEventType: EventTypeSpec;
	err: OSErr;
begin

  gHandleMouseWheelUPP := NewEventHandlerUPP(EventHandlerProcPtr(@MouseWeelHandler));

  commandEventType.eventClass  := kEventClassMouse;
  commandEventType.eventKind   := kEventMouseWheelMoved;

	err := InstallEventHandler(GetApplicationEventTarget(), gHandleMouseWheelUPP, 1, @commandEventType, nil, nil);

	commandEventType.eventClass  := kEventClassMouse;
  commandEventType.eventKind   := kEventMouseScroll;

	err := InstallEventHandler(GetApplicationEventTarget(), gHandleMouseWheelUPP, 1, @commandEventType, nil, nil);


	InstallApplicationEventHandler := err;
end;


procedure InitUnitAppleEventsCassio;
var err : OSErr;
begin

  {TraceLog('InitUnitAppleEventsCassio');}

  err := -1;
  CheckAppleEvents;
	if gHasAppleEvents then
	  begin
	    err := InstallRequiredAppleEvents;
	    err := InstallApplicationEventHandler;
	  end;


	{WritelnNumDansRapport('InitUnitAppleEventsCassio : err = ',err);}
end;



END.
