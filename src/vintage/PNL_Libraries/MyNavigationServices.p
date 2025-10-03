

unit MyNavigationServices;

interface

 uses UnitDefCassio , Navigation , Files;



// Displays the NavGet dialog and opens the selected files with AppleEvents.
// To enable multiple document opening through AppleEvents pass NULL as the fileSpec anf fileType.
function OpenFileDialog(applicationSignature : OSType; numTypes : SInt16; typeList : ConstSFTypeListPtr) : OSStatus;                                                                ATTRIBUTE_NAME('OpenFileDialog')


// Displays the NavGet dialog and returns (in "fileSpec") the first selected file.
function OpenOneFileDialog(prompt : String255; applicationSignature : OSType; numTypes : SInt16; typeList : ConstSFTypeListPtr; var fileSpec : FSSpec) : OSStatus;                  ATTRIBUTE_NAME('OpenOneFileDialog')


// Displays the NavPut dialog and returns the selected file location and replacing info.
function SaveFileDialog(fileName,prompt : stringPtr; filetype,fileCreator : OSType; var fileSpec : FSSpec; var stationery : boolean; var replacing : boolean; var reply : NavReplyRecord) : OSStatus;                                                                         ATTRIBUTE_NAME('SaveFileDialog')


// Displays the save confirmation dialog anmd returns {ok, cancel, dontSaveChanges}
function ConfirmSaveDialog(documentName : stringPtr; quitting : boolean) : SInt16;                                                                                                  ATTRIBUTE_NAME('ConfirmSaveDialog')


function MyNavServicesAvailable : boolean;                                                                                                                                          ATTRIBUTE_NAME('MyNavServicesAvailable')

// Callback to handle event passing between the navigation dialogs and the application
procedure MyNavEventProc(callBackSelector : NavEventCallbackMessage; callBackParms : NavCBRecPtr ; callBackUD: UnivPtr);                                                            ATTRIBUTE_NAME('MyNavEventProc')



implementation


USES CodeFragments,Finder,Dialogs,LowMem,Processes,AEInteraction,MacMemory,MacErrors,AEDataModel,AppleEvents;



procedure WritelnNumDansRapport(s : String255; num : SInt32);  EXTERNAL_NAME('WritelnNumDansRapport');



function MyNavServicesAvailable() : boolean;
begin
	return true;
end;


//
// Callback to handle events that occur while navigation dialogs are up but really should be handled by the application
//

procedure HandleEvent(var whichEvent : eventRecord); EXTERNAL_NAME('HandleEvent');


procedure MyNavEventProc(callBackSelector : NavEventCallbackMessage;
						             callBackParms : NavCBRecPtr ;
						             callBackUD : UnivPtr);
// Callback to handle event passing between the navigation dialogs and the application
begin  {$unused callBackUD}
	if ( callBackSelector = kNavCBEvent ) then
	  if (callBackParms <> NIL) &
	     (callBackParms^.eventData.eventDataParms.event <> NIL)
	    then
    		if (callBackParms^.eventData.eventDataParms.event^.what = updateEvt) then
    		begin
    			HandleEvent(callBackParms^.eventData.eventDataParms.event^);
    		end;
end;


function NewOpenHandle(applicationSignature : OSType ; numTypes : SInt16; typeList : ConstSFTypeListPtr) : Handle;
var hdl : Handle;
    mySize : SInt32;
    open : NavTypeListHandle;
begin
	hdl := NIL;

	if ( numTypes > 0 ) then
	begin

	  mySize := sizeof(NavTypeList) + numTypes * sizeof(OSType);
		hdl := NewHandle(mySize);

		if ( hdl <> NIL ) then
		begin
			open	 := NavTypeListHandle(hdl);

      if (open <> NIL) & (open^ <> NIL) then
        begin
    			open^^.componentSignature := applicationSignature;
    			open^^.osTypeCount	 := numTypes;

    			BlockMoveData(typeList, @open^^.osType, numTypes * sizeof(OSType));
    	 end;
		end;
	end;

	return hdl;
end;




function  NavSendOpenAE(list : AEDescList ) : OSStatus;
var err : OSStatus		;
	theAddress : AEAddressDesc	;
	dummyReply : AppleEvent		;
	myEvent : AppleEvent		;
	psn : ProcessSerialNumber;
begin


	theAddress.descriptorType := typeNull;
	theAddress.dataHandle	 := NIL;

	while true do
	begin

		psn.highLongOfPSN := 0;
		psn.lowLongOfPSN := kCurrentProcess;

		err := AECreateDesc(typeProcessSerialNumber, @psn, sizeof(ProcessSerialNumber), theAddress);
		if ( err <> noErr) then leave;

		dummyReply.descriptorType := typeNull;
		dummyReply.dataHandle	 := NIL;

		err := AECreateAppleEvent(kCoreEventClass, kAEOpenDocuments, theAddress, kAutoGenerateReturnID, kAnyTransactionID, myEvent);
		if ( err <> noErr) then leave;

		err := AEPutParamDesc(myEvent, keyDirectObject, list);
		if ( err <> noErr) then leave;

		err := AESend(myEvent, dummyReply, kAENoReply, kAENormalPriority, kAEDefaultTimeout, NIL, NIL);
		if ( err <> noErr) then leave;


	end;

	return err;
end;



function OpenFileDialog(applicationSignature : OSType; numTypes : SInt16; typeList : ConstSFTypeListPtr) : OSStatus;
var
  theReply : NavReplyRecord;
	dialogOptions : NavDialogOptions;
	theErr : OSStatus	;
	openList : NavTypeListHandle;
	eventUPP : NavEventUPP			;
begin

  theErr := -1;

  openList := NIL;

  eventUPP := NewNavEventUPP(MyNavEventProc);

  if eventUPP <> NIL then
    begin

    	theErr := NavGetDefaultDialogOptions(dialogOptions);

    	if (theErr = NoErr) then
    	  begin

        	dialogOptions.dialogOptionFlags := dialogOptions.dialogOptionFlags + kNavDontAutoTranslate;
        	dialogOptions.dialogOptionFlags := dialogOptions.dialogOptionFlags + kNavNoTypePopup;
        	dialogOptions.dialogOptionFlags := dialogOptions.dialogOptionFlags - kNavAllowPreviews;

        	// dialogOptions.clientName := LMGetCurApName()^;

        	openList := NavTypeListHandle(NewOpenHandle(applicationSignature, numTypes, typeList));

        	if ( openList <> NIL ) then
        	  HLock(Handle(openList));

        	theErr := NavGetFile(NIL, theReply, @dialogOptions, eventUPP, NIL, NIL, openList, NIL);

       end;

    end;

	if ( theErr <> noErr ) & ( theErr <> userCanceledErr ) then
	begin
		// if out of memory then a message will already be shown
		if (theErr = memFullErr) then
			theErr := userCanceledErr;
	end;

	if (theErr = noErr ) & ( theReply.validRecord) then
	begin
		// Multiple files open : use ApleEvents
		theErr := NavSendOpenAE(theReply.selection);

		theErr := NavDisposeReply(theReply);
	end;

	if (eventUPP <> NIL) then
    begin
	    DisposeNavEventUPP(eventUPP);
	    eventUPP := NIL;
	  end;

	if (openList <> NIL) then
  	begin
  		HUnlock(Handle(openList));
  		DisposeHandle(Handle(openList));
  		openList := NIL;
  	end;

	return theErr;
end;



function OpenOneFileDialog(prompt : String255; applicationSignature : OSType; numTypes : SInt16; typeList : ConstSFTypeListPtr; var fileSpec : FSSpec) : OSStatus;
var
	theReply : NavReplyRecord		;
	dialogOptions : NavDialogOptions	;
  theErr : OSErr;
  openList : NavTypeListHandle;
  eventUPP : NavEventUPP;
  count : SInt32;
  // User selection
  resultDesc : AEDesc;
  keyword : AEKeyword;
begin

	theErr	 := -1;

  openList := NIL;

	eventUPP := NewNavEventUPP(MyNavEventProc);

	//WritelnNumDansRapport('OpenOneFileDialog  : ',1);

	if (eventUPP <> NIL) then
	  begin

	    //WritelnNumDansRapport('OpenOneFileDialog  : ',2);

    	theErr := NavGetDefaultDialogOptions(dialogOptions);

    	//WritelnNumDansRapport('OpenOneFileDialog  : 3 , theErr = ',theErr);

    	if theErr = NoErr then
    	  begin

        	dialogOptions.dialogOptionFlags := dialogOptions.dialogOptionFlags + kNavDontAutoTranslate;
        	dialogOptions.dialogOptionFlags := dialogOptions.dialogOptionFlags + kNavNoTypePopup;
        	dialogOptions.dialogOptionFlags := dialogOptions.dialogOptionFlags - kNavAllowPreviews;

        	//dialogOptions.clientName := LMGetCurApName()^;

        	dialogOptions.clientName := StringToStr255('Cassio');
        	dialogOptions.message    := StringToStr255(prompt);

        	//WritelnNumDansRapport('OpenOneFileDialog  : 4 , numTypes = ',numTypes);

        	openList := NavTypeListHandle(NewOpenHandle(applicationSignature, numTypes, typeList));

        	//WritelnNumDansRapport('OpenOneFileDialog  : 5 , openList = ',SInt32(openList));

        	if ( openList <> NIL ) then
          	HLock(Handle(openList));

          theErr := NavGetFile(NIL, theReply, @dialogOptions, eventUPP, NIL, NIL, openList, NIL);

        	//WritelnNumDansRapport('OpenOneFileDialog  : 6 , theErr = ',theErr);



        	if ( theErr <> noErr ) & ( theErr <> userCanceledErr ) then
          	begin
          		// if out of memory then a message will already be shown
          		if (theErr = memFullErr) then
          			theErr := userCanceledErr;
          	end;

        	if (theErr = noErr ) & ( theReply.validRecord) then
          	begin

          	  theErr := AECountItems(theReply.selection, count);

          	  if (count >= 1) & (theErr = NoErr) then
          	    begin


              		// retrieve the returned selection:
              		theErr := AEGetNthDesc(theReply.selection, 1, typeFSS, @keyword, resultDesc);

              		if (theErr = noErr) then
                     theErr := AEGetDescData(resultDesc, @fileSpec, sizeof(FSSpec));


                end;

          		theErr := NavDisposeReply(theReply);
          	end;
       end;

    	if (openList <> NIL) then
    	begin
    		HUnlock(Handle(openList));
    		DisposeHandle(Handle(openList));
    		openList := NIL;
    	end;

   end;

  if (eventUPP <> NIL) then
	  begin
	    DisposeNavEventUPP(eventUPP);
	    eventUPP := NIL;
	  end;

	return theErr;
end;



function ConfirmSaveDialog(documentName : stringPtr; quitting : boolean) : SInt16;
var
  theStatusErr : OSStatus ;
  theErr : OSErr;
  reply : NavAskSaveChangesResult ;
  action : NavAskSaveChangesAction ;
  eventUPP : NavEventUPP ;
  dialogOptions : NavDialogOptions ;
  result : SInt16;
begin

	theStatusErr  := -1;
	theErr 		 := noErr;
	reply 		 := 0;
	action 		 := 0;
	result     := 2;  {cancel, par defaut }

	eventUPP	 := NewNavEventUPP(MyNavEventProc);

	if (eventUPP <> NIL) then
	  begin

    	if (quitting) then
    		action := kNavSaveChangesQuittingApplication
    	else
    		action := kNavSaveChangesClosingDocument;

      //dialogOptions.clientName := LMGetCurApName()^;
      dialogOptions.clientName := StringToStr255('Cassio');

      if (documentName <> NIL) then
    	  dialogOptions.savedFileName := documentName^;


    	theErr := NavAskSaveChanges(	dialogOptions,
    								action,
    								reply,
    								eventUPP,
    								NIL);

      if (eventUPP <> NIL) then
    	  begin
    	    DisposeNavEventUPP(eventUPP);
    	    eventUPP := NIL;
    	  end;
   end;

  if (theErr = NoErr) then
    begin

    	// Map reply code to ok, cancel, dontSave
    	case (reply) of
    	  kNavAskSaveChangesSave:
    			begin
    			  result := 1;  {ok}
    			end;

    		kNavAskSaveChangesCancel :
    			begin
    			  result := 2;  {cancel}
    			end;

    		kNavAskSaveChangesDontSave:
    			begin
    			  result := 3;  {dontSaveChanges}
    			end;
    	end;  {case}

   end;

	return result;
end;



function SaveFileDialog(fileName,prompt : stringPtr; filetype,fileCreator : OSType; var fileSpec : FSSpec;
						var stationery : boolean; var replacing : boolean; var reply : NavReplyRecord) : OSStatus;
var
  dialogOptions : NavDialogOptions	;
  theErr : OSErr;
  eventUPP : NavEventUPP;
  // User saved
	resultDesc : 	AEDesc 	;
	keyword :	AEKeyword ;

begin

	theErr	 := -1;

	eventUPP := NewNavEventUPP(MyNavEventProc);

	if eventUPP <> NIL then
	  begin

    	theErr := NavGetDefaultDialogOptions(dialogOptions);

      if (theErr = NoErr) then
        begin
          dialogOptions.dialogOptionFlags := dialogOptions.dialogOptionFlags or kNavAllowStationery;

        	dialogOptions.dialogOptionFlags := dialogOptions.dialogOptionFlags + kNavNoTypePopup;

        	if (prompt <> NIL) & (prompt^ <> '') then
        	  dialogOptions.message := prompt^;

          if fileName <> NIL then
        	  dialogOptions.savedFileName := fileName^;

        	//dialogOptions.clientName := LMGetCurApName()^;
        	dialogOptions.clientName := StringToStr255('Cassio');

        	theErr := NavPutFile(NIL, reply, @dialogOptions, eventUPP, filetype, fileCreator, NIL);
        end;

    	if (theErr = NoErr) & (reply.validRecord) then
      	begin

      		// retrieve the returned selection:
      		theErr := AEGetNthDesc(reply.selection, 1, typeFSS, @keyword, resultDesc);

      		if (theErr = noErr) then
      			theErr := AEGetDescData(resultDesc, @fileSpec, sizeof(FSSpec));

      		replacing := reply.replacing;

      		stationery := reply.isStationery;

      	end
    	else
      	begin
      		// User cancelled
      		replacing := false;

      		stationery := false;

      		theErr := userCanceledErr;
      	end;
   end;


 if (eventUPP <> NIL) then
	  begin
	    DisposeNavEventUPP(eventUPP);
	    eventUPP := NIL;
	  end;

	return theErr;
end;







end.
