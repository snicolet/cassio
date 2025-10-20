/*
	File:		NavigationServicesSupport.c

	Copyright:	© 1997-1998 by Apple Computer, Inc., all rights reserved.
	This code is originally Apple sample code which has been modified by Ken Beath

*/


#include <Files.h>
#include <Navigation.h>



#define dontSaveChanges	3





pascal OSStatus OpenFileDialog(OSType applicationSignature, short numTypes, OSType typeList[]);
// Displays the NavGet dialog and opens the selected files with AppleEvents.
// To enable multiple document opening through AppleEvents pass NULL as the fileSpec anf fileType.


pascal OSStatus OpenOneFileDialog(OSType applicationSignature, short numTypes, OSType typeList[], FSSpec* fileSpec);
// Displays the NavGet dialog and returns (in "fileSpec") the first selected file.


pascal short ConfirmSaveDialog(StringPtr documentName, Boolean quitting);
// Displays the save confirmation dialog anmd returns {ok, cancel, dontSaveChanges}



pascal OSStatus SaveFileDialog(StringPtr fileName, StringPtr prompt, OSType filetype, OSType fileCreator,  FSSpec* fileSpec, Boolean* stationery, Boolean* replacing, NavReplyRecord* reply);
// Displays the NavPut dialog and returns the selected file location and replacing info.



pascal OSStatus CompleteSave(const FSSpec* fileSpec, NavReplyRecord* reply);

pascal Boolean MyNavServicesAvailable();

// Call this routine after saving a document passing back the fileSpec and reply returned by SaveFileDialog
// This call performs any file tranlation needed and disposes the reply



pascal void MyNavEventProc(const NavEventCallbackMessage callBackSelector,
						NavCBRecPtr callBackParms,
						NavCallBackUserData callBackUD);
// Callback to handle event passing between the navigation dialogs and the application


#include <CodeFragments.h>
#include <Finder.h>
#include <Dialogs.h>
#include <LowMem.h>
#include <string.h>
#include <Processes.h>
#include <AEInteraction.h>


pascal Boolean MyNavServicesAvailable()
{
	return NavServicesAvailable();
}

static Handle NewOpenHandle(OSType applicationSignature, short numTypes, OSType typeList[])
{
	Handle hdl = NULL;
	long   mySize;
	
	if ( numTypes > 0 )
	{
	
	  mySize = (long)sizeof(NavTypeList) + numTypes * (long)sizeof(OSType);
		hdl = NewHandle(mySize);
	
		if ( hdl != NULL )
		{
			NavTypeListHandle open		= (NavTypeListHandle)hdl;
			
			(*open)->componentSignature = applicationSignature;
			(*open)->osTypeCount		= numTypes;
			BlockMoveData(typeList, (*open)->osType, numTypes * (long)sizeof(OSType));
		}
	}
	
	return hdl;
}




static OSStatus NavSendOpenAE(AEDescList list)
{
	OSStatus		err;
	AEAddressDesc	theAddress;
	AppleEvent		dummyReply;
	AppleEvent		theEvent;
	
	theAddress.descriptorType	= typeNull;
	theAddress.dataHandle		= NULL;

	do {
		ProcessSerialNumber psn;

		psn.highLongOfPSN = 0;
		psn.lowLongOfPSN = kCurrentProcess;
		
		err =AECreateDesc(typeProcessSerialNumber, &psn, sizeof(ProcessSerialNumber), &theAddress);
		if ( err != noErr) break;
			
		dummyReply.descriptorType	= typeNull;
		dummyReply.dataHandle		= NULL;

		err = AECreateAppleEvent(kCoreEventClass, kAEOpenDocuments, &theAddress, kAutoGenerateReturnID, kAnyTransactionID, &theEvent);
		if ( err != noErr) break;
		
		err = AEPutParamDesc(&theEvent, keyDirectObject, &list);
		if ( err != noErr) break;
		
		err = AESend(&theEvent, &dummyReply, kAENoReply, kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
		if ( err != noErr) break;
		
			
	} while (false);
	
	return err;
}



pascal OSStatus OpenFileDialog(OSType applicationSignature, short numTypes, OSType typeList[])
{
	NavReplyRecord		theReply;
	NavDialogOptions	dialogOptions;
	OSStatus				theErr		= noErr;
	NavTypeListHandle	openList	= NULL;
	NavEventUPP			eventUPP	= NewNavEventUPP(MyNavEventProc);
	
	NavGetDefaultDialogOptions(&dialogOptions);
	
	dialogOptions.dialogOptionFlags += kNavDontAutoTranslate;
	dialogOptions.dialogOptionFlags += kNavNoTypePopup;
	dialogOptions.dialogOptionFlags -= kNavAllowPreviews;
	
	BlockMoveData(LMGetCurApName(), dialogOptions.clientName, LMGetCurApName()[0] + 1);
	
	openList = (NavTypeListHandle)NewOpenHandle(applicationSignature, numTypes, typeList);
	if ( openList )
	{
		HLock((Handle)openList);
	}
	
	theErr = NavGetFile(NULL, &theReply, &dialogOptions, eventUPP, NULL, NULL, openList, NULL);

	DisposeNavEventUPP(eventUPP);
	
	if ( theErr != noErr && theErr != userCanceledErr )
	{
		// if out of memory then a message will already be shown
		if (theErr == memFullErr)
			theErr = userCanceledErr;
	}
	
	if (theErr == noErr && theReply.validRecord)
	{
		// Multiple files open: use ApleEvents
		theErr = NavSendOpenAE(theReply.selection);

		NavDisposeReply(&theReply);
	}
	
	if (openList != NULL)
	{
		HUnlock((Handle)openList);
		DisposeHandle((Handle)openList);
	}
	
	return theErr;
}



pascal OSStatus OpenOneFileDialog(OSType applicationSignature, short numTypes, OSType typeList[], FSSpec* fileSpec)
{
	NavReplyRecord		theReply;
	NavDialogOptions	dialogOptions;
	OSErr				theErr		= noErr;
	NavTypeListHandle	openList	= NULL;
	NavEventUPP			eventUPP	= NewNavEventUPP(MyNavEventProc);
	
	NavGetDefaultDialogOptions(&dialogOptions);
	dialogOptions.dialogOptionFlags += kNavDontAutoTranslate;
	dialogOptions.dialogOptionFlags += kNavNoTypePopup;
	dialogOptions.dialogOptionFlags -= kNavAllowPreviews;
	
	BlockMoveData(LMGetCurApName(), dialogOptions.clientName, LMGetCurApName()[0] + 1);
	
	openList = (NavTypeListHandle)NewOpenHandle(applicationSignature, numTypes, typeList);
	if ( openList )
	{
		HLock((Handle)openList);
	}
	
	theErr = NavGetFile(NULL, &theReply, &dialogOptions, eventUPP, NULL, NULL, openList, NULL);

	DisposeNavEventUPP(eventUPP);
	
	if ( theErr != noErr && theErr != userCanceledErr )
	{
		// if out of memory then a message will already be shown
		if (theErr == memFullErr)
			theErr = userCanceledErr;
	}
	
	if (theErr == noErr && theReply.validRecord)
	{
	  long   count;
	
	  theErr = AECountItems(&theReply.selection, &count);
	
	  if (count >= 1)
	  {
	    // User selection
		AEDesc 	resultDesc;
		AEKeyword keyword;
			
		// retrieve the returned selection:
		theErr = AEGetNthDesc(&(&theReply)->selection, 1, typeFSS, &keyword, &resultDesc);
		if (theErr == noErr)
#if TARGET_API_MAC_CARBON==0
			BlockMove(*resultDesc.dataHandle, fileSpec, sizeof(FSSpec));
#else
			AEGetDescData(&resultDesc, fileSpec, sizeof(FSSpec));
#endif
      }
	
		NavDisposeReply(&theReply);
	}
	
	if (openList != NULL)
	{
		HUnlock((Handle)openList);
		DisposeHandle((Handle)openList);
	}
	
	return theErr;
}



pascal short ConfirmSaveDialog(StringPtr documentName, Boolean quitting)
{
	OSStatus				theStatusErr 	= noErr;
	OSErr 					theErr 			= noErr;
	NavAskSaveChangesResult	reply 			= 0;
	NavAskSaveChangesAction	action 			= 0;
	NavEventUPP				eventUPP		= NewNavEventUPP(MyNavEventProc);
	NavDialogOptions		dialogOptions;
	short					result;
	
	if (quitting)
		action = kNavSaveChangesQuittingApplication;
	else
		action = kNavSaveChangesClosingDocument;
		
	BlockMoveData(LMGetCurApName(),dialogOptions.clientName,LMGetCurApName()[0]+1);
	BlockMoveData(documentName,dialogOptions.savedFileName,documentName[0]+1);
	
	theErr = NavAskSaveChanges(	&dialogOptions,
								action,
								&reply,
								eventUPP,
								NULL);
	DisposeNavEventUPP(eventUPP);
	
	// Map reply code to ok, cancel, dontSave
	switch (reply)
	{
		case kNavAskSaveChangesSave:
			result = ok;
			break;
			
		case kNavAskSaveChangesCancel:
			result = cancel;
			break;
			
		case kNavAskSaveChangesDontSave:
			result = dontSaveChanges;
			break;
	}
	
	return result;
}



pascal OSStatus SaveFileDialog(StringPtr fileName, StringPtr prompt, OSType filetype, OSType fileCreator,
						 FSSpec* fileSpec,
						Boolean* stationery, Boolean* replacing, NavReplyRecord* reply)
{
	NavDialogOptions	dialogOptions;
	OSErr				theErr		= noErr;
	NavEventUPP			eventUPP	= NewNavEventUPP(MyNavEventProc);

	NavGetDefaultDialogOptions(&dialogOptions);

	dialogOptions.dialogOptionFlags |= (stationery != NULL ? kNavAllowStationery : 0);
	dialogOptions.dialogOptionFlags += kNavNoTypePopup;
	if (prompt) BlockMoveData(prompt, dialogOptions.message, prompt[0] + 1);
	BlockMoveData(fileName, dialogOptions.savedFileName, fileName[0] + 1);
	BlockMoveData(LMGetCurApName(), dialogOptions.clientName, LMGetCurApName()[0] + 1);

	theErr = NavPutFile(NULL, reply, &dialogOptions, eventUPP, filetype, fileCreator, NULL);
	DisposeNavEventUPP(eventUPP);
	
	if (reply->validRecord)
	{
		// User saved
		AEDesc 	resultDesc;
		AEKeyword keyword;
			
		// retrieve the returned selection:
		theErr = AEGetNthDesc(&reply->selection, 1, typeFSS, &keyword, &resultDesc);
		if (theErr == noErr)
#if TARGET_API_MAC_CARBON==0
			BlockMove(*resultDesc.dataHandle, fileSpec, sizeof(FSSpec));
#else
			AEGetDescData(&resultDesc, fileSpec, sizeof(FSSpec));
#endif
		if ( replacing != NULL )
			*replacing = reply->replacing;
		
		if ( stationery != NULL )
		{
			*stationery	= reply->isStationery;
		}
	}
	else
	{
		// User cancelled
		if ( replacing != NULL )
			*replacing = false;
		
		if ( stationery != NULL )
			*stationery	= false;	

		theErr = userCanceledErr;
	}
	
	return theErr;
}



pascal OSStatus CompleteSave(const FSSpec* fileSpec, NavReplyRecord* reply)
{
	OSStatus theErr;
	
	if (reply->validRecord)
	{
		theErr = NavCompleteSave(reply, kNavTranslateInPlace);
	}

	theErr = NavDisposeReply(reply);
	
	return theErr;
}




//
// Callback to handle events that occur while navigation dialogs are up but really should be handled by the application
//

pascal extern void HandleEvent(EventRecord* pEvent);


pascal void MyNavEventProc(const NavEventCallbackMessage callBackSelector,
						NavCBRecPtr callBackParms,
						NavCallBackUserData callBackUD)
// Callback to handle event passing between the navigation dialogs and the application
{
	if ( callBackSelector == kNavCBEvent )
		switch (callBackParms->eventData.eventDataParms.event->what)
		{
			case updateEvt:
				HandleEvent(callBackParms->eventData.eventDataParms.event);
				break;
		}
}

