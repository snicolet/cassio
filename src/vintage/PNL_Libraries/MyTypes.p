UNIT MyTypes;

{ From Peter's PNL Libraries }
{ Copyright 1992 Peter N Lewis }
{ This source may be used for any non-commercial purposes as long as I get a mention }
{ in the About box and Docs of any derivative program.  It may not be used in any commercial }
{ application without my permission }

INTERFACE







	uses
		Quickdraw, Events, MacTypes, Controls, Menus, Files, fp
		{$ifc defined __GPC__} ,GPCStrings {$endc}
		;

	const
		inProgress = 1;							{ I/O in progress }
		sysWDProcID = $4552494B;		{ 'ERIK' }
		myErr = -5;
		myErr2 = -6;
		cancelErr = myErr2;
		myErr3 = -7;
		noType = 0;							{ should be OSType(0) !!! }
		fsNoCache = $20;
		fsNewLine = $80; { put the newline character in the high Byte of ioPosMode }
		bad_rn = 0;
		bad_date = 1;    { was $80000000; }
		bad_refnum = -32768;
		bad_vRefNum = -4567;
		bad_dirID = -4567;
		window_at_front = WindowPtr(-1);
	
	const
		ticks_in_ms = 17;
		second_in_ms = 1000;
		minute_in_ms = SInt32(60) * second_in_ms;
		hour_in_ms = SInt32(60) * minute_in_ms;
		day_in_ms = SInt32(24) * hour_in_ms;
		second_in_ticks = SInt32(60);
		minute_in_ticks = SInt32(60) * second_in_ticks;
		hour_in_ticks = SInt32(60) * minute_in_ticks;
		day_in_ticks = SInt32(24) * hour_in_ticks;
		minute_in_seconds = SInt32(60);
		hour_in_seconds = SInt32(60) * minute_in_seconds;
		day_in_seconds = SInt32(24) * hour_in_seconds;
		hour_in_minutes = SInt32(60);
		day_in_minutes = SInt32(24) * hour_in_minutes;
		day_in_hours = SInt32(24);

	const
		M_Apple = 128;
		M_File = 129;
		M_Edit = 130;
		M_Windows = 150;

	const
		Cabout = 'abou';
		Cnew = 'new ';
		Copen = 'open';
		Csave = 'save';
		Csaveas = 'svas';
		Cclose = 'clos';
		Cpreferences = 'pref';
		Cpagesetup = 'pgsu';
		Cprint = 'prnt';
		Chelp = 'help';
		Cquit = 'quit';
		Cundo = 'undo';
		Ccut = 'cut ';
		Ccopy = 'copy';
		Cpaste = 'past';
		Cclear = 'clea';
		Cselectall = 'sela';

	const
		keyOdocOption = 'auto'; { optional parameter to open }
		keyOdocControl = 'autC'; { optional parameter to open }

	const									{ Low Memory Globals }
		curApNameA = $910;
		ticksA = $16A;
		SFSaveDiskA = $214;
		CurDirStoreA = $398;

	const									{ Other OS constants, probably declared somewhere now }
		kSysEnvironsVersion = 1;
		kOSEvent = osEvt;				{event used by MultiFinder}
		kSuspendResumeMessage = 1;	{high Byte of suspend/resume event message}
		kResumeMask = 1;					{bit of message field for resume vs. suspend}
		kMouseMovedMessage = $00FA;	{high Byte of mouse-moved event message}
		kNoEvents = 0;						{no events mask}

	const									{ Constants that aren't normally defined }
		drawCntlMsg = 0;
		testCntlMsg = 1;
		calcCRgnsMsg = 2;
		initCntlMsg = 3;
		dispCntlMsg = 4;
		posCntlMsg = 5;
		thumbCntlMsg = 6;
		dragCntlMsg = 7;
		autoTrackMsg = 8;

	const
		EMundo = 1;
		EMcut = 3;
		EMcopy = 4;
		EMpaste = 5;
		EMclear = 6;
		EMselectall = 7;

	const
		nulChar = 0;
		homeChar = $01;
		enterChar = $03;
		endChar = $04;
		helpChar = $05;
		backSpaceChar = $08;
		tabChar = $09;
		lfChar = $0A;
		pageUpChar = $0b;
		pageDownChar = $0c;
		crChar = $0D;
		escChar = $1b;
		escKey = $35;
		clearChar = $1b;
		clearKey = $47;
		leftArrowChar = $1c;
		rightArrowChar = $1d;
		upArrowChar = $1e;
		downArrowChar = $1f;
		spaceChar = $20;
		delChar = $7f;
		bulletChar = $a5;
		undoKey = $7a;
		cutKey = $78;
		copyKey = $63;
		pasteKey = $76;

	const
		nul = chr(nulChar);
		enter = chr(enterChar);
		bs = chr(backSpaceChar);
		tab = chr(tabChar);
		lf = chr(lfChar);
		cr = chr(crChar);
		leftArrow = chr(leftArrowChar);
		rightArrow = chr(rightArrowChar);
		upArrow = chr(upArrowChar);
		downArrow = chr(downArrowChar);
		esc = chr(escChar);
		spc = chr(spaceChar);
		del = chr(delChar);

	type
	  charP = ^char;
		integerP = ^SInt16;
		integerH = ^integerP;
		unsignedwordP = ^unsignedword;
		unsignedwordH = ^unsignedwordP;
		longintP = ^SInt32;
		longintH = ^longintP;
		unsignedlongP = ^UInt32;
		unsignedlongH = ^unsignedlongP;
		ptrint = SInt32; { integer type to cast pointers to do pointer arithmatic }
		forkType = (no_fork, data_fork, rsrc_fork, both_fork);
		buf255 = packed array[0..255] of char;
		CRLFTypes = (CL_CRLF, CL_CR, CL_LF);
		CharSet = set of char;
		short = SInt16;
		long = SInt32;
    ProcedureType = procedure;

    bytePtr =  ^UInt8;



    LongintArray = array[0..0] of SInt32;
    LongintArrayPtr = ^LongintArray;
    LongintArrayHdl = ^LongintArrayPtr;


    IntegerArray = array[0..0] of SInt16;
    IntegerArrayPtr = ^IntegerArray;
    IntegerArrayHdl = ^IntegerArrayPtr;


    PackedArrayOfChar = packed array[0..0] of char;
		PackedArrayOfCharPtr = ^PackedArrayOfChar;



    CharArray = PACKED ARRAY [0..32001] OF CHAR;
    CharArrayPtr = ^CharArray;
    CharArrayHandle = ^CharArrayPtr;


    {TypeReel = float_t;}  {single precision (4 bytes) on PPC}
     TypeReel = double;  {double precision (8 bytes) on PPC}


    TypeReelArray = array[0..40] of TypeReel;
    TypeReelArrayPtr =  ^TypeReelArray;


    {
    str255 = string[255];

    Byte = 0..255;
    SInt8 = -128..127;
    UInt8 = Byte;
    SInt8 = SInt8;
    UInt16 = integer;
    SInt16 = integer;
    UInt32 = longint;
    SInt32 = longint;
    UniChar = UInt16;

    Ptr = ^SInt8;
    Handle = ^Ptr;
    }

  (* on rajoute ces definitions, qui ne sont pas dans Carbon *)


  type  SFReplyPtr = ^SFReply;
        SFReply = RECORD
		                good:				  	BOOLEAN;
		                copy:				  	BOOLEAN;
		                fType:					OSType;
		                vRefNum:				SInt16;
		                version:				SInt16;
		                fName:					StrFileName;							{  a Str63 on MacOS  }
	                END;
	      DlgHookUPP              = UniversalProcPtr;
        FileFilterUPP           = UniversalProcPtr;
        SFTypeList							 =  ARRAY [0..3] OF OSType;
        ConstSFTypeListPtr			 =  ^OSType;
	{	
	    The GetFile "typeList" parameter type has changed from "SFTypeList" to "ConstSFTypeListPtr".
	    For C, this will add "const" and make it an in-only parameter.
	    For Pascal, this will require client code to use the @ operator, but make it easier to specify long lists.
	
	    ConstSFTypeListPtr is a pointer to an array of OSTypes.
		}

  const
    maxmenucmds = 127;

	type
		menuCmdSet = set of 1..maxmenucmds;
		myKeyMap = packed array[0..15] of UInt8;
		TwoBytesArray = packed array[0..1] of UInt8;
		FourBytesArray = packed array[0..3] of UInt8;

		MenuFlottantRec = record
				theID : SInt32;
				theMenu : MenuRef;
				theControl : ControlHandle;
				theWindow : WindowPtr;
				theRect : rect;
				theMenuWidth : SInt32;
				theMenuFontID : SInt16;
				theMenuFontSize : UInt16;
				theItem : SInt16;
				checkedItems : menuCmdSet;
				provientDUneResource : boolean;
				installe : boolean;
			end;

		ProcedureTypeWithLongint = procedure(var param : SInt32);


{$ifc defined __GPC__}
    UnivPtr = Pointer;
    UnivHandle = ^Pointer;
{$elsec}
    UnivPtr = Ptr;
    UnivHandle = Handle;
{$endc}



  var

		GenevaID : SInt16;
		CourierID : SInt16;
		MonacoID : SInt16;
		TimesID : SInt16;
		NewYorkID : SInt16;
		PalatinoID : SInt16;
		SymbolID : SInt16;
		TimesNewRomanID : SInt16;
		TrebuchetMSID : SInt16;
		EpsiSansID : SInt16;
		HelveticaID : SInt16;

const
		my_font_strh_id = 1900;
	
	type
		SavedWindowInfo = record
				oldport: GrafPtr;
				thisport: GrafPtr;
				font: SInt16;
				size: SInt16;
				face: Style;
			end;

	type
		MyFontType = (
				MFT_Geneva0, MFT_Geneva9, MFT_Geneva12,
				MFT_Courier0, MFT_Courier9, MFT_Courier12,
				MFT_Chicago0, MFT_Chicago9, MFT_Chicago12,
				MFT_System0, MFT_System9, MFT_System12,
				MFT_Monaco0, MFT_Monaco9, MFT_Monaco12
				);
				
	type
		ScanProc = function(var fs : FSSpec; folder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
{ for folders, return true to scan contents }
{ for files return true if you Delete the file - other changes to the file system would be bad... }
				
				
				

IMPLEMENTATION









end.
