UNIT  MyAntialiasing;



INTERFACE


 USES UnitDefCassio , QuickDraw;



  procedure EnableQuartzAntiAliasing(useQuartzMetrics : boolean);                                                                                                                   ATTRIBUTE_NAME('EnableQuartzAntiAliasing')
  procedure EnableQuartzAntiAliasingThisPort(port : CGrafPtr; useQuartzMetrics : boolean);                                                                                          ATTRIBUTE_NAME('EnableQuartzAntiAliasingThisPort')
  procedure DisableQuartzAntiAliasing;                                                                                                                                              ATTRIBUTE_NAME('DisableQuartzAntiAliasing')
  procedure DisableQuartzAntiAliasingThisPort(port : CGrafPtr);                                                                                                                     ATTRIBUTE_NAME('DisableQuartzAntiAliasingThisPort')
  function InitialiseQuartzAntiAliasing : OSErr;                                                                                                                                    ATTRIBUTE_NAME('InitialiseQuartzAntiAliasing')



IMPLEMENTATION


USES MyFileSystemUtils,MacErrors;







type SwapQDTextFlagsProcPtr = function(newFlags : UInt32) : UInt32;
type QDSwapPortTextFlagsPtr = function(port : CGrafPtr; newFlags : UInt32) : UInt32;

const SwapQDTextFlagsProcInitialise : boolean = false;
const QDSwapPortTextFlagsInitialise : boolean = false;


var MySwapQDTextFlagsProc : SwapQDTextFlagsProcPtr;
var MyQDSwapPortTextFlagsProc : QDSwapPortTextFlagsPtr;

{
const kQDUseTrueTypeScalerGlyphs = 1;
      kQDUseCGTextRendering = 2;
      kQDUseCGTextMetrics = 4;
      }


procedure EnableQuartzAntiAliasing(useQuartzMetrics : boolean);
var savedFlags : UInt32;
    newFlags : UInt32;
begin
	(*	enable Quartz text rendering globaly, for the whole application *)

	if useQuartzMetrics
	  then newFlags := kQDUseTrueTypeScalerGlyphs + kQDUseCGTextRendering + kQDUseCGTextMetrics
	  else newFlags := kQDUseTrueTypeScalerGlyphs + kQDUseCGTextRendering ;

	if SwapQDTextFlagsProcInitialise then
    savedFlags := MySwapQDTextFlagsProc(newFlags);
end;

procedure DisableQuartzAntiAliasing;
var savedFlags : UInt32;
begin
	(*	disable Quartz text rendering globaly, for the whole application *)

	if SwapQDTextFlagsProcInitialise then
    savedFlags := MySwapQDTextFlagsProc(0);
end;

procedure EnableQuartzAntiAliasingThisPort(port : CGrafPtr; useQuartzMetrics : boolean);
var savedFlags : UInt32;
    newFlags : UInt32;
begin
	(*	enable Quartz text rendering for this port *)

	if useQuartzMetrics
	  then newFlags := kQDUseTrueTypeScalerGlyphs + kQDUseCGTextRendering + kQDUseCGTextMetrics
	  else newFlags := kQDUseTrueTypeScalerGlyphs + kQDUseCGTextRendering;

	if QDSwapPortTextFlagsInitialise then
    savedFlags := MyQDSwapPortTextFlagsProc(port,newFlags);
end;

procedure DisableQuartzAntiAliasingThisPort(port : CGrafPtr);
var savedFlags : UInt32;
begin
	(*	disable Quartz text rendering for this port *)

	if QDSwapPortTextFlagsInitialise then
    savedFlags := MyQDSwapPortTextFlagsProc(port,0);
end;


function InitialiseQuartzAntiAliasing : OSErr;
var bundleRef : CFBundleRef;
    err : OSStatus;
    myCFRef : CFStringRef;
label cleanUp;
begin
  bundleRef := NIL;
  err := -1;

  {if gIsRunningUnderMacOSX then}
    begin

		  (*	load the ApplicationServices framework *)

		  myCFRef := MakeCFSTR('ApplicationServices.framework');
		  err :=  MyLoadFrameworkBundle(myCFRef, bundleRef);
		  CFRelease(CFTypeRef(myCFRef));

			if (err <> NoErr) then
			  goto cleanUp;


			(*	get a pointer to the SwapQDTextFlags function *)
			err := coreFoundationUnknownErr ;

			myCFRef := MakeCFSTR('SwapQDTextFlags');
			MySwapQDTextFlagsProc := SwapQDTextFlagsProcPtr(CFBundleGetFunctionPointerForName(bundleRef,myCFRef));
			CFRelease(CFTypeRef(myCFRef));

			if (MySwapQDTextFlagsProc = NIL)
			  then goto cleanUp
			  else SwapQDTextFlagsProcInitialise := true;


			(*	get a pointer to the SwapQDTextFlags function *)
			err := coreFoundationUnknownErr ;

			myCFRef := MakeCFSTR('QDSwapPortTextFlags');
			MyQDSwapPortTextFlagsProc := QDSwapPortTextFlagsPtr(CFBundleGetFunctionPointerForName(bundleRef,myCFRef));
			CFRelease(CFTypeRef(myCFRef));

			if (MyQDSwapPortTextFlagsProc = NIL)
			  then goto cleanUp
			  else QDSwapPortTextFlagsInitialise := true;



			(*	clear result code *)
			err := noErr ;

    end;


  cleanUp :
  InitialiseQuartzAntiAliasing := err;

end;

END.


































