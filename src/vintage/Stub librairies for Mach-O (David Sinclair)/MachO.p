
{ MW/GPC Pascal unit, written by Adriaan van Os, www.microbizz.nl, not copyrighted.   					}
{_______________________________________________________________________________________________}

UNIT MachO;
{_______________________________________________________________________________________________}
{
 	This unit contains routines to load and call Mach-O routines in Mac OS X bundles and
	frameworks dynamically. They can be used to call Mach-O routines from CFM/PEF code.
	This unit also shows how to call back into CFM/PEF from Mach-O code loaded from CFM/PEF.
	
	Please note that the MetroWerks CodeWarrior Pascal compiler produces CFM/PEF, while the
	Microbizz GNU Pascal plugins for CodeWarrior create Mach-O.
	
	The routines are based on sample code, provided "AS IS" by Apple Computer Inc., see		
	<http://developer.apple.com/samplecode/CFM_MachO_CFM/CFM_MachO_CFM.html>.											}
{_______________________________________________________________________________________________}

INTERFACE
{_______________________________________________________________________________________________}

	USES
	{$ifc defined __GPC__}
	
//		GPCMacOSAll;
    MacTypes, Files, CFBase, CFString, CFBundle;  // SN change

	{$elsec}
	
//		MWMacOSAll;
    MacTypes, Files, CFBase, CFString, CFBundle;  // DJS change
    
    
	{$endc}
{_______________________________________________________________________________________________}

{$ifc defined __GPC__}
{$definec univ}
{$endc}
{_______________________________________________________________________________________________}

	Type
		Int16															= SInt16;
		Int16Ptr													= SInt16Ptr;
		Int32															= SInt32;
		Int32Ptr													= SInt32Ptr;
		Word16														= UInt16;
		Word32														= UInt32;
		Word16Ptr													= UInt16Ptr;
		Word32Ptr													= UInt32Ptr;
{_______________________________________________________________________________________________}

 function MachOLoadBundle
				(			theBundleVolumeRef			: Int16;
							theBundleDirID					: Int32;
        const theBundleFileName				: Str255;
					var theBundlePtr						: CFBundleRef): OSStatus;

 function MachOLoadFrameworkBundle
				(			theFrameworkCFStrRef		: CFStringRef;
							theOptionalFolderRefPtr	: FSRefPtr;
					var theBundlePtr						: CFBundleRef): OSStatus;

 function MachOGetBundleFunctionRef
				(			theBundleVolumeRef			: Int16;
							theBundleDirID					: Int32;
        const theBundleFileName				: Str255;
				const theFunctionStr					: Str255;
					var theVarBundleRef					: CFBundleRef;
					var theFunctionPtr					: univ UnivPtr): OSStatus;

 function MachOGetBundleDataRef
				(			theBundleVolumeRef			: Int16;
							theBundleDirID					: Int32;
        const theBundleFileName				: Str255;
				const theDataStr							: Str255;
					var theVarBundleRef					: CFBundleRef;
					var theDataPtr							: univ UnivPtr): OSStatus;

 function MachOGetFrameworkFunctionRef
			( const theFrameworkStr					: Str255;
							theOptionalFolderRefPtr	: FSRefPtr;
				const theFunctionStr					: Str255;
					var theVarBundleRef					: CFBundleRef;
					var theFunctionPtr					: univ UnivPtr): OSStatus;

 function MachOGetFrameworkDataRef
			( const theFrameworkStr					: Str255;
							theOptionalFolderRefPtr	: FSRefPtr;
				const theDataStr							: Str255;
					var theVarBundleRef					: CFBundleRef;
					var theDataPtr							: univ UnivPtr): OSStatus;
{_______________________________________________________________________________________________}

{$ifc not defined __GPC__}
 function NewMachOFunctionPointerForCFMFunctionPointer
				(			theCFMProcPtr						: ProcPtr;
					var theMachOProcPtr					: ProcPtr): OSErr;

procedure DisposeMachOFunctionPointerForCFMFunctionPointer
				(	var theMachOProcPtr					: ProcPtr);
{$endc}
{_______________________________________________________________________________________________}

IMPLEMENTATION

	{$ifc not defined __GPC__}
uses
  MacErrors, MacMemory, OSUtils, Folders, CFURL;  // DJS change
{$endc}
  
{_______________________________________________________________________________________________}

 function MachOLoadBundle
				(			theBundleVolumeRef			: Int16;
							theBundleDirID					: Int32;
        const theBundleFileName				: Str255;
					var theBundlePtr						: CFBundleRef): OSStatus;
		const
				kCFAllocator									= nil; {kCFAllocatorSystemDefault}
			var
				theErr												: OSStatus;
				theFSRef											: FSRef;
				theBundleURL									: CFURLRef;
				theFSSpec											: FSSpec;
		begin
			theBundlePtr										:= nil;
			theBundleURL										:= nil;
			theErr													:= FSMakeFSSpec
 				( theBundleVolumeRef, theBundleDirID, theBundleFileName, theFSSpec);
			if theErr = noErr
				then theErr										:= FSpMakeFSRef
 					 (  theFSSpec, theFSRef);
			if theErr = noErr
				then begin
					theBundleURL								:= CFURLCreateFromFSRef
						( kCFAllocator, theFSRef);
					if theBundleURL = nil
						then theErr								:= coreFoundationUnknownErr
				end;
			if theErr = noErr
				then begin
					theBundlePtr								:= CFBundleCreate
						( kCFAllocator, theBundleURL);
					if theBundlePtr = nil
						then theErr								:= coreFoundationUnknownErr
				end;
			if theErr = noErr
				then if not CFBundleLoadExecutable
					 ( theBundlePtr)
					 then theErr								:= coreFoundationUnknownErr;
			if ( theErr				<> noErr	) and
				 ( theBundlePtr	<> nil		)
				then begin
					CFRelease
						( CFTypeRef( theBundlePtr));
					theBundlePtr								:= nil
				end;
			if theBundleURL <> nil
				then CFRelease
					 ( CFTypeRef( theBundleURL));
			MachOLoadBundle									:= theErr
		end;
{_______________________________________________________________________________________________}

 function MachOLoadFrameworkBundle
				(			theFrameworkCFStrRef		: CFStringRef;
							theOptionalFolderRefPtr	: FSRefPtr;
					var theBundlePtr						: CFBundleRef): OSStatus;
		const
				kCFAllocator									= nil; {kCFAllocatorSystemDefault}
			var
				theErr												: OSStatus;
				theFrameworksFolderRef				: FSRef;
				theBaseURL										: CFURLRef;
				theBundleURL									: CFURLRef;
		begin
			theBundlePtr										:= nil;
			theBaseURL											:= nil;
			theBundleURL										:= nil;
			theErr													:= noErr;
			if theOptionalFolderRefPtr <> nil
				then theFrameworksFolderRef		:= theOptionalFolderRefPtr^
				else theErr										:= FSFindFolder
					 ( kOnAppropriateDisk, kFrameworksFolderType, true, theFrameworksFolderRef);
			if theErr = noErr
				then begin
					theBaseURL									:= CFURLCreateFromFSRef
						( kCFAllocator, theFrameworksFolderRef);
					if theBaseURL = nil
						then theErr								:= coreFoundationUnknownErr
				end;
			if theErr = noErr
				then begin
					theBundleURL								:= CFURLCreateCopyAppendingPathComponent
						( kCFAllocator, theBaseURL, theFrameworkCFStrRef, False);
					if theBundleURL = nil
						then theErr								:= coreFoundationUnknownErr
				end;
			if theErr = noErr
				then begin
					theBundlePtr								:= CFBundleCreate
						( kCFAllocator, theBundleURL);
					if theBundlePtr = nil
						then theErr								:= coreFoundationUnknownErr
				end;
			if theErr = noErr
				then if not CFBundleLoadExecutable
					 ( theBundlePtr)
					 then theErr								:= coreFoundationUnknownErr;
			if ( theErr				<> noErr	) and
				 ( theBundlePtr	<> nil		)
				then begin
					CFRelease
						( CFTypeRef( theBundlePtr));
					theBundlePtr								:= nil
				end;
			if theBundleURL <> nil
				then CFRelease
					 ( CFTypeRef( theBundleURL));
			if theBaseURL <> nil
				then CFRelease
					 ( CFTypeRef( theBaseURL));
			MachOLoadFrameworkBundle				:= theErr
		end;
{_______________________________________________________________________________________________}

 function MachOGetBundleFunctionRef
				(			theBundleVolumeRef			: Int16;
							theBundleDirID					: Int32;
        const theBundleFileName				: Str255;
				const theFunctionStr					: Str255;
					var theVarBundleRef					: CFBundleRef;
					var theFunctionPtr					: univ UnivPtr): OSStatus;
		const
				kAllocator										= nil;
			var
				theErr												: OSStatus;
				theFunctionStrRef							: CFStringRef;
		begin
			theErr													:= noErr;
			theFunctionPtr									:= nil;
			theFunctionStrRef								:= nil;
			if theVarBundleRef = nil
				then theErr										:= MachOLoadBundle
					 ( theBundleVolumeRef, theBundleDirID, theBundleFileName, theVarBundleRef);
			if theErr = noErr
				then begin
					theFunctionStrRef						:= CFStringCreateWithPascalString
						( kAllocator, theFunctionStr, kCFStringEncodingMacRoman);
					theFunctionPtr							:= CFBundleGetFunctionPointerForName
					 	( theVarBundleRef, theFunctionStrRef);
					if theFunctionPtr = nil
						then theErr								:= cfragNoSymbolErr
				end;
			if theFunctionStrRef <> nil
				then CFRelease
					 ( CFTypeRef( theFunctionStrRef));
			MachOGetBundleFunctionRef				:= theErr
		end;
{_______________________________________________________________________________________________}

 function MachOGetBundleDataRef
				(			theBundleVolumeRef			: Int16;
							theBundleDirID					: Int32;
        const theBundleFileName				: Str255;
				const theDataStr							: Str255;
					var theVarBundleRef					: CFBundleRef;
					var theDataPtr							: univ UnivPtr): OSStatus;
		const
				kAllocator										= nil;
			var
				theErr												: OSStatus;
				theDataStrRef									: CFStringRef;
		begin
			theErr													:= noErr;
			theDataPtr											:= nil;
			theDataStrRef										:= nil;
			if theVarBundleRef = nil
				then theErr										:= MachOLoadBundle
					 ( theBundleVolumeRef, theBundleDirID, theBundleFileName, theVarBundleRef);
			if theErr = noErr
				then begin
					theDataStrRef								:= CFStringCreateWithPascalString
						( kAllocator, theDataStr, kCFStringEncodingMacRoman);
					theDataPtr									:= CFBundleGetDataPointerForName
					 	( theVarBundleRef, theDataStrRef);
					if theDataPtr = nil
						then theErr								:= cfragNoSymbolErr
				end;
			if theDataStrRef <> nil
				then CFRelease
					 ( CFTypeRef( theDataStrRef));
			MachOGetBundleDataRef						:= theErr
		end;
{_______________________________________________________________________________________________}

 function MachOGetFrameworkFunctionRef
			( const theFrameworkStr					: Str255;
							theOptionalFolderRefPtr	: FSRefPtr;
				const theFunctionStr					: Str255;
					var theVarBundleRef					: CFBundleRef;
					var theFunctionPtr					: univ UnivPtr): OSStatus;
		const
				kAllocator										= nil;
			var
				theErr												: OSStatus;
				theFrameworkStrRef						: CFStringRef;
				theFunctionStrRef							: CFStringRef;
		begin
			theErr													:= noErr;
			theFunctionPtr									:= nil;
			theFunctionStrRef								:= nil;
			theFrameworkStrRef							:= CFStringCreateWithPascalString
				( kAllocator, theFrameworkStr, kCFStringEncodingMacRoman);
			if theVarBundleRef = nil
				then theErr										:= MachOLoadFrameworkBundle
					 ( theFrameworkStrRef, theOptionalFolderRefPtr, theVarBundleRef);
			if theErr = noErr
				then begin
					theFunctionStrRef						:= CFStringCreateWithPascalString
						( kAllocator, theFunctionStr, kCFStringEncodingMacRoman);
					theFunctionPtr							:= CFBundleGetFunctionPointerForName
					 	( theVarBundleRef, theFunctionStrRef);
					if theFunctionPtr = nil
						then theErr								:= cfragNoSymbolErr
				end;
			if theFrameworkStrRef <> nil
				then CFRelease
					 ( CFTypeRef( theFrameworkStrRef));
			if theFunctionStrRef <> nil
				then CFRelease
					 ( CFTypeRef( theFunctionStrRef));
			MachOGetFrameworkFunctionRef		:= theErr
		end;
{_______________________________________________________________________________________________}

 function MachOGetFrameworkDataRef
			( const theFrameworkStr					: Str255;
							theOptionalFolderRefPtr	: FSRefPtr;
				const theDataStr							: Str255;
					var theVarBundleRef					: CFBundleRef;
					var theDataPtr							: univ UnivPtr): OSStatus;
		const
				kAllocator										= nil;
			var
				theErr												: OSStatus;
				theFrameworkStrRef						: CFStringRef;
				theDataStrRef									: CFStringRef;
		begin
			theErr													:= noErr;
			theDataPtr											:= nil;
			theDataStrRef										:= nil;
			theFrameworkStrRef							:= CFStringCreateWithPascalString
				( kAllocator, theFrameworkStr, kCFStringEncodingMacRoman);
			if theVarBundleRef = nil
				then theErr										:= MachOLoadFrameworkBundle
					 ( theFrameworkStrRef, theOptionalFolderRefPtr, theVarBundleRef);
			if theErr = noErr
				then begin
					theDataStrRef								:= CFStringCreateWithPascalString
						( kAllocator, theDataStr, kCFStringEncodingMacRoman);
					theDataPtr									:= CFBundleGetDataPointerForName
					 	( theVarBundleRef, theDataStrRef);
					if theDataPtr = nil
						then theErr								:= cfragNoSymbolErr
				end;
			if theFrameworkStrRef <> nil
				then CFRelease
					 ( CFTypeRef( theFrameworkStrRef));
			if theDataStrRef <> nil
				then CFRelease
					 ( CFTypeRef( theDataStrRef));
			MachOGetFrameworkDataRef				:= theErr
		end;
{_______________________________________________________________________________________________}

{$ifc not defined __GPC__}
{_______________________________________________________________________________________________}

	Type
		CFMCallBackGluePtr								= ^CFMCallBackGlue;
		CFMCallBackGlue										= array[ 0..5] of Word32;
{_______________________________________________________________________________________________}

	Const
		kCFMCallBackGlue									:
			CFMCallBackGlue									= ( $3D800000, $618C0000, $800C0000,
																					$804C0004, $7C0903A6, $4E800420);
{_______________________________________________________________________________________________}

 function NewMachOFunctionPointerForCFMFunctionPointer
				(			theCFMProcPtr						: ProcPtr;
					var theMachOProcPtr					: ProcPtr): OSErr;
		const
				kGlueSize											= SizeOf( kCFMCallBackGlue);
			var
				theOSErr											: OSErr;
				theLo													: Word32;
				theHi													: Word32;
				theGluePtr										: CFMCallBackGluePtr;
		begin
			theMachOProcPtr									:= NewPtr
				( kGlueSize);
			if theMachOProcPtr = nil
				then theOSErr									:= MemError
				else begin
					theOSErr										:= noErr;
					theGluePtr									:= CFMCallBackGluePtr( theMachOProcPtr);
					theHi												:= Word32( theCFMProcPtr) shr 16;
					theLo												:= Word32( theCFMProcPtr) and $0000FFFF;
			    theGluePtr^[ 0]							:= kCFMCallBackGlue[ 0] or theHi;
			    theGluePtr^[ 1]							:= kCFMCallBackGlue[ 1] or theLo;
			    theGluePtr^[ 2]							:= kCFMCallBackGlue[ 2];
			    theGluePtr^[ 3]							:= kCFMCallBackGlue[ 3];
			    theGluePtr^[ 4]							:= kCFMCallBackGlue[ 4];
			    theGluePtr^[ 5]							:= kCFMCallBackGlue[ 5];
    			MakeDataExecutable
    				( UnivPtr( theGluePtr), kGlueSize)
    		end;
    	NewMachOFunctionPointerForCFMFunctionPointer:= theOSErr
    end;
{_______________________________________________________________________________________________}

procedure DisposeMachOFunctionPointerForCFMFunctionPointer
				(	var theMachOProcPtr					: ProcPtr);
		begin
			if theMachOProcPtr <> nil
				then begin
					DisposePtr
						( theMachOProcPtr);
					theMachOProcPtr							:= nil
				end
		end;
{_______________________________________________________________________________________________}

{$endc}
{_______________________________________________________________________________________________}

END.
{_______________________________________________________________________________________________}
	Pascal:MW/GPC/CWPro7		Author:A.van Os   File:MachO.p   	Version:1.0   	Date:20 July 2004.
