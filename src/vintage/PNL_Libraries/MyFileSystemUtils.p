UNIT MyFileSystemUtils;

INTERFACE







 uses
     UnitDefCassio , Files , CFURL , CFString , CFBase , CFBundle;


	procedure ExpandFileName (var fs : fileInfo);
	function MyGetCatInfo (vrn : SInt16; dirID : SInt32; nameAdr : StringPtr; index: SInt16; var pb : CInfoPBRec) : OSErr;
	function FSpGetCatInfo (const fs : fileInfo; var pb : CInfoPBRec) : OSErr;
	function FSpGetIndCatInfo (var fs : fileInfo; index: SInt16; var pb : CInfoPBRec) : OSErr;
	function FSpSetCatInfo (const spec : fileInfo; var pb : CInfoPBRec) : OSErr;
	function FSpGetParID( const spec : fileInfo; var dirID : SInt32 ) : OSErr;
	function FSpGetDirID( const spec : fileInfo; var dirID : SInt32 ) : OSErr;
	function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255; var fs : fileInfo) : OSErr;
	function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255) : fileInfo;
	procedure MyGetModDate (const spec : fileInfo; var moddate : SInt32);
	function DuplicateFile ({const} org, new : fileInfo) : OSErr;
	function CopyData (src, dst: SInt16; len : SInt32) : OSErr;
	function TouchDir (fs : fileInfo) : OSErr;
	function TouchFolder (vrn : SInt16; dirID : SInt32) : OSErr;
	function CreateUniqueFile (var fs : fileInfo; creator, ftype : OSType) : OSErr;
	function CreateUniqueFolder (var fs : fileInfo; var dirID : UInt32 ) : OSErr;
	function CreateSubDirectoryNearThisFile(const whichFile : fileInfo; var directoryName : String255) : OSErr;
  function CreateDirectoryWithThisPath(directoryPath : String255) : OSErr;
  function FolderExists (var folder : fileInfo; var err : OSErr) : boolean;

	function MyFSReadLineEOL (refnum : SInt16; ch : char; var s : String255) : OSErr;
	function MyFSReadLine (refnum : SInt16; var s : String255) : OSErr;
	function MyFSReadLineAt (refnum : SInt16; pos : SInt32; var s : String255) : OSErr;
	function MyFSRead(refnum : SInt16; len : SInt32; p : Ptr) : OSErr;
	function MyFSWriteString( refnum : SInt16; const s : String255 ) : OSErr;
	function MyFSWrite (refnum : SInt16; len : SInt32; p : Ptr) : OSErr;
	function MyFSWriteAt (refnum : SInt16; mode : SInt16; pos, len : SInt32; p : Ptr) : OSErr;
	function MyFSReadAt (refnum : SInt16; pos, len : SInt32; p : Ptr) : OSErr;
	function MyFSReadFile( {const} spec : fileInfo; var data: Handle ) : OSErr;


	procedure SetNameOfFSSpec(var fs : fileInfo; const name : String255);
	function GetName(fs : fileInfo) : String255;


	function GetNameOfSFReply(const reply : SFReply) : String255;
  procedure SetNameOfSFReply(var reply : SFReply; const name : String255);


	function ExpandFileName (fs : fileInfo; var path : String255) : OSErr;
	function ExpandFileName(fs : fileInfo) : String255;
	{function DiskFreeSpace (vrn : SInt16) : SInt32;} { result in k }
	function DiskSize (vrn : SInt16) : SInt32; { result in k }
	function BlessSystemFolder (vrn : SInt16; dirID : SInt32) : OSErr;
	function SameFSSpec (const fs1, fs2: fileInfo) : boolean;
	{procedure GetSFLocation (var vrn : SInt16; var dirID : SInt32);}
	{procedure SetSFLocation (vrn : SInt16; dirID : SInt32);}
	procedure SafeFindFolder (vRefNum : SInt16; folderType : OSType; var foundvRefNum : SInt16; var foundDirID : UInt32);
	function CreateTemporaryFile (var fs : fileInfo) : OSErr;
  function GetPathOfApplicationSupportFolder(var applicationFolderPath : String255) : OSErr;



	function FSpGetFolderDirID( const spec : fileInfo; var dirID : SInt32 ) : OSErr;
(*	function GetVolInfo (var name : Str63; var vrn : SInt16; index: SInt16; var CrDate : SInt32) : OSErr; *)
(*  function GetVolumeAddrBlock(vrn : SInt16; index: SInt16; var addr : AddrBlock) : OSErr;  *)
	function ScanDirectory (fs : fileInfo; doit : ScanProc) : OSErr;
	function SetPathOfScannedDirectory(var folder : fileInfo) : OSErr;
	function GetPathOfScannedDirectory : String255;
	function RemoveResourceFork( {const} spec : fileInfo ) : OSErr;
  function MacPathToUNIXPath( oldMacPath : String255 ) : String255;
  function EscapeSpacesInUnixPath( oldPath : String255 ) : String255;


 { some string manipulations }
	function MakeCFSTR(s : String255) : CFStringRef;
  function ConvertEncodingOfString(s : String255; oldEncoding, newEncoding : CFStringEncoding) : String255;


 { mise en memoire des frameworks du systeme ou prives (internes a l'application) }
  function MyLoadFrameworkBundle(inFrameworkName : CFStringRef; var outBundleRef : CFBundleRef) : OSStatus;
  function MyLoadPrivateFrameworkBundle(inFrameworkName : CFStringRef; var outBundleRef : CFBundleRef) : OSStatus;


 { chargement des pointeurs de fonctions dans les framework du systeme ou prives }
  function GetFunctionPointerFromBundle(const whichBundle,functionName : String255) : Ptr;
  function GetFunctionPointerFromPrivateBundle(const whichBundle,functionName : String255) : Ptr;




  procedure MySFPutFile(where : Point; prompt : ConstStringPtr; origName : String255; dlgHook : DlgHookUPP; VAR reply : SFReply);
  procedure MySFGetFile(where : Point; prompt : String255; fileFilter : FileFilterUPP; numTypes : SInt16; typeList : ConstSFTypeListPtr; dlgHook : DlgHookUPP; var reply : SFReply);


	procedure SetFileCreator(fichier : fileInfo; QuelType : OSType);
	procedure SetFileType(fichier : fileInfo; QuelType : OSType);


	function GetWDName(WDRefNum : SInt16) : String255;
	function ChangeDir(pathName : String255) : OSErr;


  { Dialogue de sauvegarde dans un fichier texte}
  function GetFichierTexte(prompt : String255; fileKind1,fileKind2,fileKind3,fileKind4 : OSType; var fic : basicfile) : OSErr;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}





{$DEFINEC USE_PRELINK true}

USES
    MacMemory, Finder, MacErrors, TextUtils, ToolUtils, OSUtils, GestaltEqu, Folders
    , Aliases, LowMem, Devices, DateTimeUtils, NumberFormatting, CodeFragments
{$IFC NOT(USE_PRELINK)}
    , MyStrings
    , MyMemory, UnitDialog, basicfile, UnitRapport ;
{$ELSEC}
    ;
    {$I prelink/MyFileSystemUtils.lk}
{$ENDC}


{END_USE_CLAUSE}





  var nomDirectoryDepartRecursion : String255;





function GetWDName(WDRefNum : SInt16) : String255;
	var
		parmBlock : CInfoPBRec;
		OSError : OSErr;
		myName255 : str255;
		fileName : String255;
		pathName : String255;
		done : boolean;
begin
	pathName := '';
	done := false;
	with parmBlock do
		begin
			ioCompletion := NIL;
			ioNamePtr := @myName255;
			iovRefNum := WDRefNum;
			ioFDirIndex := -1;
			ioDirID := 0;
		end;
	OSError := PBGetCatInfoSync(@parmBlock);
	fileName := MyStr255ToString(myName255);

	if OSError = noErr then
		begin
			fileName := Concat(fileName, DirectorySeparator );
			Insert(fileName, pathName, 1);
		end;

	repeat
		with parmBlock do
			begin
				ioCompletion := NIL;
				ioNamePtr := @myName255;
				iovRefNum := WDRefNum;
				ioFDirIndex := -1;
				ioDirID := ioDrParId;
			end;
		OSError := PBGetCatInfoSync(@parmBlock);
		fileName := MyStr255ToString(myName255);

		if OSError = noErr then
			begin
				filename := Concat(filename, DirectorySeparator );
				Insert(filename, pathname, 1);
			end;
	until OSError <> 0;
	GetWDName := pathName;
end;

function ChangeDir(pathName : String255) : OSErr;
	var
		parmBlock : WDPBRec;
		myName255 : str255;
begin
  myName255 := StringToStr255(pathName);
	with parmBlock do
		begin
			ioCompletion := NIL;
			ioNamePtr := @myName255;
			iovRefNum := 0;
			ioWDDirID := 0;
		end;
	changeDir := PBHSetVolSync(@parmBlock);
end;



procedure SetFileCreator(fichier : fileInfo; QuelType : OSType);
	var
		InfosFinder : FInfo;
		err : OSErr;
begin
	err := FSpGetFInfo(fichier, InfosFinder);
	InfosFinder.fdCreator := QuelType;
	err := FSpSetFInfo(fichier, InfosFinder);
end;

procedure SetFileType(fichier : fileInfo; QuelType : OSType);
	var
		InfosFinder : FInfo;
		err : OSErr;
begin
	err := FSpGetFInfo(fichier, InfosFinder);
	InfosFinder.fdType := QuelType;
	err := FSpSetFInfo(fichier, InfosFinder);
end;



	procedure SafeFindFolder (vRefNum : SInt16; folderType : OSType; var foundvRefNum : SInt16; var foundDirID : UInt32);
		var
			theWorld: SysEnvRec;
			gv: SInt32;
	begin
		foundvRefNum := -1;
		foundDirID := 2;
		if (Gestalt(gestaltFindFolderAttr, gv) <> noErr) or
		   (not BTST(gv, gestaltFindFolderPresent)) or
		   (FindFolder(vRefNum, folderType, true, foundvRefNum, foundDirID) <> noErr) then
		   begin
    			if true {or (SysEnvirons(1, theWorld) = noErr)} then begin
    				foundvRefNum := theWorld.sysvRefNum;
    				foundDirID := 0;
    			end else begin
    				foundvRefNum := -1;
    				foundDirID := 2;
    			end;
		   end;
	end;

	function CreateTemporaryFile (var fs : fileInfo) : OSErr;
	begin
		SafeFindFolder( kOnSystemDisk, kTemporaryFolderType, fs.vRefNum, fs.parID );
		CreateTemporaryFile := CreateUniqueFile( fs, FOUR_CHAR_CODE('trsh'), FOUR_CHAR_CODE('trsh') );
	end;

{
	procedure GetSFLocation (var vrn : SInt16; var dirID : SInt32);
	begin
		vrn := -LMGetSFSaveDisk;
		dirID := LMGetCurDirStore;
	end;

	procedure SetSFLocation (vrn : SInt16; dirID : SInt32);
	begin
		LMSetSFSaveDisk(-vrn);
		LMSetCurDirStore(dirID);
	end;
}

	function ExpandFileName (fs : fileInfo; var path : String255) : OSErr;
		var
			err : OSErr;
			pb : CInfoPBRec;
			s : String255;
	begin
	  s := GetName(fs);
		err := MakeFileInfo(fs.vRefNum, fs.parID, s, fs);
		if err = fnfErr then begin
			err := noErr;
		end;
		if err = noErr then begin
			if fs.parID = 1 then begin
				path := Concat(GetName(fs), DirectorySeparator );
			end else begin
				path := GetName(fs);
				while (err = noErr) and (fs.parID <> 1) do begin
					err := FSpGetIndCatInfo(fs, -1, pb);
					path := Concat(GetName(fs), DirectorySeparator , path);
					fs.parID := pb.ioFlParID;
				end;
			end;
		end;
		ExpandFileName := err;
	end;


	{$ifc defined __GPC__}

	function GetName(fs : fileInfo) : String255;
	var aux63 : Str63;
	    aux255 : Str255;
	begin
	  aux63 := Str63(fs.name);
	  aux255 := Str63ToStr255(aux63);
	  GetName := MyStr255ToString(aux255);
	end;

	{$elsec}

	function GetName(fs : fileInfo) : String255;
	begin
	  GetName := fs.name;
	end;

	{$endc}



  procedure SetNameOfFSSpec(var fs : fileInfo; const name : String255);
	begin
	  {$ifc defined __GPC__}
	     StringIntoStr63(name, Str63(fs.name));
	  {$elsec}
	     fs.name := name;
	  {$endc}
	end;





	{$ifc defined __GPC__}

	function GetNameOfSFReply(const reply : SFReply) : String255;
  var aux63 : Str63;
	    aux255 : Str255;
	begin
	  aux63 := Str63(reply.fName);
	  aux255 := Str63ToStr255(aux63);
	  GetNameOfSFReply := MyStr255ToString(aux255);
	end;

  {$elsec}

  function GetNameOfSFReply(const reply : SFReply) : String255;
  begin
    GetNameOfSFReply := reply.fName;
  end;

  {$endc}

  procedure SetNameOfSFReply(var reply : SFReply; const name : String255);
	begin
	  {$ifc defined __GPC__}
	     StringIntoStr63(name, Str63(reply.fName));
	  {$elsec}
	     reply.fName := name;
	  {$endc}
	end;



	function ExpandFileName(fs : fileInfo) : String255;
	var result : String255;
	    error : OSErr;
	begin
	  error := ExpandFileName(fs,result);
	  ExpandFileName := result;
	end;


	function TouchDir (fs : fileInfo) : OSErr;
		var
			pb : CInfoPBRec;
			err : OSErr;
	begin
		if GetName(fs) = '' then begin
			TouchDir := TouchFolder(fs.vRefNum, fs.parID);
		end else begin
			pb.iovRefNum := fs.vRefNum;
			pb.ioDirID := fs.parID;
			pb.ioNamePtr := @fs.name;
			pb.ioFDirIndex := 0;
			err := PBGetCatInfoSync(@pb);
			if err = noErr then begin
				pb.ioNamePtr := NIL;
				GetDateTime(pb.ioDrMdDat);
				err := PBSetCatInfoSync(@pb);
			end;
			TouchDir := err;
		end;
	end;

	function TouchFolder (vrn : SInt16; dirID : SInt32) : OSErr;
		var
			pb : CInfoPBRec;
			err : OSErr;
	begin
		pb.iovRefNum := vrn;
		pb.ioDirID := dirID;
		pb.ioNamePtr := NIL;
		pb.ioFDirIndex := -1;
		err := PBGetCatInfoSync(@pb);
		if err = noErr then begin
			pb.iovRefNum := vrn;
			pb.ioDirID := dirID;
			pb.ioNamePtr := NIL;
			GetDateTime(pb.ioDrMdDat);
			err := PBSetCatInfoSync(@pb);
		end;
		TouchFolder := err;
	end;

	function CreateUniqueFile (var fs : fileInfo; creator, ftype : OSType) : OSErr;
		var
			oname : String255;
			name : Str255;
			n : String255;
			i : SInt16;
			oe : OSErr;
	begin
		oname := GetName(fs);
		LimitStringLength(oname, 27, '…');

		name := StringToStr255(GetName(fs));

		oe := HCreate(fs.vRefNum, fs.parID, name , creator, ftype);
		i := 1;
		while oe = dupFNErr do begin
			n := IntToStr(i);

			SetNameOfFSSpec(fs, Concat(oname, '#', n));

			name := StringToStr255(GetName(fs));

			oe := HCreate(fs.vRefNum, fs.parID, name, creator, ftype);
			i := i + 1;
		end;
		CreateUniqueFile := oe;
	end;

	function CreateUniqueFolder (var fs : fileInfo; var dirID : UInt32 ) : OSErr;
		var
			oname : String255;
			n : String255;
			i : SInt16;
			oe : OSErr;
	begin
		oname := GetName(fs);

		LimitStringLength( oname, 27, '…' );
		oe := FSpDirCreate( fs, 0, dirID );
		i := 1;
		while oe = dupFNErr do begin
			n := IntToStr( i );

			SetNameOfFSSpec(fs, Concat(oname, '#', n));

			oe := FSpDirCreate( fs, 0, dirID );
			i := i + 1;
		end;
		CreateUniqueFolder := oe;
	end;


	function FolderExists (var folder : fileInfo; var err : OSErr) : boolean;
	  var targetIsFolder : boolean;
	      wasAliased : boolean;
	      path : String255;
	begin
		err := ResolveAliasFile(folder, TRUE, targetIsFolder, wasAliased);
		
    if err = NoErr then err := ExpandFileName(folder,path);

		FolderExists := (err = NoErr);
	end;



	function MyFSReadAt (refnum : SInt16; pos, len : SInt32; p : Ptr) : OSErr;
		var
			pb : ParamBlockRec;
			oe : OSErr;
	begin
		pb.ioRefNum := refnum;
		pb.ioBuffer := p;
		pb.ioReqCount := len;
		pb.ioPosMode := fsFromStart;
		pb.ioPosOffset := pos;
		oe := PBReadSync(@pb);
		if (oe = noErr) and (pb.ioActCount <> len) then begin
			oe := -1;
		end;
		MyFSReadAt := oe;
	end;

	function MyFSReadLineEOL (refnum : SInt16; ch : char; var s : String255) : OSErr;
		var
			pb : ParamBlockRec;
			err : OSErr;
	begin
		pb.ioRefNum := refnum;
{$PUSH}
{$R-}
		pb.ioBuffer := @s[1];
		pb.ioReqCount := 255;
		pb.ioPosMode := fsFromMark + fsNewLine + BSL(ord(ch), 8);
		pb.ioPosOffset := 0;
		err := PBReadSync(@pb);
		if (err = eofErr) and (pb.ioActCount > 0) then begin
			err := noErr;
		end;
		if err = noErr then begin
			if (pb.ioActCount > 0) and (s[pb.ioActCount] = ch) then begin
				pb.ioActCount := pb.ioActCount - 1;
			end;
			SET_LENGTH_OF_STRING(s, (pb.ioActCount));
		end;
{$POP}
		MyFSReadLineEOL := err;
	end;

	function MyFSReadLine (refnum : SInt16; var s : String255) : OSErr;
	begin
		MyFSReadLine := MyFSReadLineEOL(refnum, cr, s);
	end;

	function MyFSReadLineAt (refnum : SInt16; pos : SInt32; var s : String255) : OSErr;
		var
			pb : ParamBlockRec;
			err : OSErr;
	begin
		pb.ioRefNum := refnum;
{$PUSH}
{$R-}
		pb.ioBuffer := @s[1];
		pb.ioReqCount := 255;
		pb.ioPosMode := fsFromStart + fsNewLine + BSL(ord(cr), 8);
		pb.ioPosOffset := pos;
		err := PBReadSync(@pb);
		if (err = eofErr) and (pb.ioActCount > 0) then begin
			err := noErr;
		end;
		if err = noErr then begin
		  if (pb.ioActCount > 0)
		    then SET_LENGTH_OF_STRING(s, (pb.ioActCount - 1))
		    else SET_LENGTH_OF_STRING(s, 0);
		end;
{$POP}
		MyFSReadLineAt := err;
	end;

	function MyFSRead(refnum : SInt16; len : SInt32; p : Ptr) : OSErr;
		var
			err : OSErr;
			count: SInt32;
	begin
		err := noErr;
		if len > 0 then begin
			count := len;
			err := FSRead(refnum, count, p);
			if (err = noErr) and (count <> len) then begin
				err := -1;
			end;
		end;
		MyFSRead := err;
	end;

	function MyFSWriteString( refnum : SInt16; const s : String255 ) : OSErr;
	begin
		MyFSWriteString := MyFSWrite( refnum, LENGTH_OF_STRING(s), @s[1] );
	end;

	function MyFSWrite (refnum : SInt16; len : SInt32; p : Ptr) : OSErr;
		var
			oe : OSErr;
			count: SInt32;
	begin

		oe := noErr;

		if len > 0 then begin
			count := len;
			oe := FSWrite(refnum, count, p);
			if (oe = noErr) and (count <> len) then begin
				oe := -1;
			end;
		end;

		MyFSWrite := oe;
	end;

	function MyFSReadFile( {const} spec : fileInfo; var data : Handle ) : OSErr;
		var
			err, junk: OSErr;
			rn : SInt16;
			filelen : SInt32;
	begin
		data := NIL;
		err := FSpOpenDF( spec, fsRdPerm, rn );
		if err = noErr then begin
			err := GetEOF( rn,  filelen );
			if err = noErr then begin
				err := MNewHandle( UnivHandle(data), filelen );
				if err = noErr then begin
					HLock( data );
					err := MyFSRead( rn, filelen, data^ );
					HUnlock( data );
				end;
			end;
			junk := FSClose( rn );
		end;
		if err <> noErr then begin
			MDisposeHandle( UnivHandle(data) );
		end;
		MyFSReadFile := err;
	end;

	procedure ExpandFileName (var fs : fileInfo);
		var
			isFolder, wasalias: boolean;
			temp : fileInfo;
			gv: SInt32;
			oe : OSErr;
	begin
		if (Gestalt(gestaltAliasMgrAttr, gv) = noErr) and (BTST(gv, gestaltAliasMgrPresent)) then begin
			temp := fs;
			oe := ResolveAliasFile(fs, true, isFolder, wasalias);
			if oe <> noErr then begin
				fs := temp;
			end;
		end;
	end;

	function MyGetCatInfo (vrn : SInt16; dirID : SInt32; nameAdr : StringPtr; index: SInt16; var pb : CInfoPBRec) : OSErr;
	begin
		pb.iovRefNum := vrn;
		pb.ioDirID := dirID;
		pb.ioNamePtr := nameAdr;
		pb.ioFDirIndex := index;

		MyGetCatInfo := PBGetCatInfoSync(@pb);
	end;

	function FSpGetParID( const spec : fileInfo; var dirID : SInt32 ) : OSErr;
		var
			err : OSErr;
			pb : CInfoPBRec;
	begin
		err := FSpGetCatInfo( spec, pb );
		if err = noErr then begin
			dirID := pb.ioDrParID;
		end;
		FSpGetParID := err;
	end;

	function FSpGetDirID( const spec : fileInfo; var dirID : SInt32 ) : OSErr;
		var
			err : OSErr;
			pb : CInfoPBRec;
	begin
		err := FSpGetCatInfo( spec, pb );
		if err = noErr then begin
			if BitAnd(pb.ioFlAttrib,ioDirMask) <> 0 then begin
				dirID := pb.ioDrDirID;
			end else begin
				err := fnfErr;
			end;
		end;
		FSpGetDirID := err;
	end;

	function FSpGetCatInfo (const fs : fileInfo; var pb : CInfoPBRec) : OSErr;
	begin
		pb.iovRefNum := fs.vRefNum;
		pb.ioDirID := fs.parID;
		pb.ioNamePtr := @fs.name;
		pb.ioFDirIndex := 0;
		FSpGetCatInfo := PBGetCatInfoSync(@pb);
	end;

	function FSpGetIndCatInfo (var fs : fileInfo; index: SInt16; var pb : CInfoPBRec) : OSErr;
	begin
		pb.iovRefNum := fs.vRefNum;
		pb.ioDirID := fs.parID;
		pb.ioNamePtr := @fs.name;
		pb.ioFDirIndex := index;
		FSpGetIndCatInfo := PBGetCatInfoSync(@pb);
	end;

	function FSpSetCatInfo (const spec : fileInfo; var pb : CInfoPBRec) : OSErr;
	begin
		pb.iovRefNum := spec.vRefNum;
		pb.ioDirID := spec.parID;
		pb.ioNamePtr := @spec.name;
		FSpSetCatInfo := PBSetCatInfoSync(@pb);
	end;

	function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255; var fs : fileInfo) : OSErr;
		var
			pb : CInfoPBRec;
			oe : OSErr;
			gv : SInt32;
			name255 : Str255;
	begin
	    DoDirSeparators(name);
		if (Gestalt(gestaltFSAttr, gv) = noErr) and (BTST(gv, gestaltHasFSSpecCalls))
		  then
		    begin
		      StringIntoStr255(name, name255);
			    oe := FSMakeFSSpec(vrn, dirID, name255, fs);
		    end
		  else
		    begin
    			oe := MyGetCatInfo(vrn, dirID, @fs.name, 0, pb);
    			if (oe = noErr) then
      			begin
      				fs.vRefNum := pb.iovRefNum;
      				fs.parID := pb.ioFlParID;

      				SetNameOfFSSpec(fs, name);

      			end;
    		end;
		MakeFileInfo := oe;
	end;

	function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255) : fileInfo;
	var result : fileInfo;
	    err : OSErr;
	begin
	  err := MakeFileInfo(vrn, dirID, name, result);
	  MyMakeFSSpec := result;
	end;

	procedure MyGetModDate (const spec : fileInfo; var moddate : SInt32);
		var
			err : OSErr;
			pb : CInfoPBRec;
	begin
	  {$R-}
		err := FSpGetCatInfo( spec, pb );
		if err = noErr then begin
			moddate := pb.ioFlMdDat
		end else begin
			moddate := $40000000;
		end;
	end;

	function CopyData (src, dst: SInt16; len : SInt32) : OSErr;
		const
			buffer_len = 4096;
		var
			buffer : packed array[1..buffer_len] of SInt8;
			l : SInt32;
			oe : OSErr;
	begin
		oe := noErr;
		while (len > 0) and (oe = noErr) do begin
			if len > SizeOf(buffer) then begin
				l := SizeOf(buffer);
			end else begin
				l := len;
			end;
			oe := FSRead(src, l, @buffer);
			if (l = 0) and (oe = noErr) then begin
				oe := -1;
			end;
			if oe = noErr then begin
				oe := MyFSWrite(dst, l, @buffer);
			end;
			len := len - l;
		end;
		CopyData := oe;
	end;

	function DuplicateFile ({const} org, new : fileInfo) : OSErr;
		const
			fdInited = $0100;
		var
			oe, ooe : OSErr;
			fi: FInfo;
			pb : CInfoPBRec;
			orn, nrn : SInt16;
			rlen, dlen : SInt32;
	begin
		oe := FSpGetFInfo(org, fi);
		if oe = noErr then begin
			oe := FSpCreate(new, fi.fdCreator, fi.fdType, 0);
			fi.fdFlags := BAND(fi.fdFlags, BNOT(fdInited));
			oe := FSpSetFInfo(new, fi);
		end;
		if oe = noErr then begin
			oe := FSpGetCatInfo(org, pb);
			if oe = noErr then begin
				dlen := pb.ioFlLgLen;
				rlen := pb.ioFlRLgLen;
				oe := FSpSetCatInfo( new, pb);
			end;

			if oe = noErr then begin
				oe := FSpOpenDF(org, fsRdPerm, orn);
				if oe = noErr then begin
					oe := FSpOpenDF(new, fsWrPerm, nrn);
					if oe = noErr then begin
						oe := CopyData(orn, nrn, dlen);
						ooe := FSClose(nrn);
						if oe = noErr then begin
							ooe := oe;
						end;
					end;
					ooe := FSClose(orn);
				end;
			end;

			if oe = noErr then begin
				oe := FSpOpenRF(org, fsRdPerm, orn);
				if oe = noErr then begin
					oe := FSpOpenRF(new, fsWrPerm, nrn);
					if oe = noErr then begin
						oe := CopyData(orn, nrn, rlen);
						ooe := FSClose(nrn);
						if oe = noErr then begin
							ooe := oe;
						end;
					end;
					ooe := FSClose(orn);
				end;
			end;

			if oe <> noErr then begin
				ooe := FSpDelete(new);
			end;
		end;
		DuplicateFile := oe;
	end;


	function MyFSWriteAt (refnum : SInt16; mode : SInt16; pos, len : SInt32; p : Ptr) : OSErr;
		var
			pb : ParamBlockRec;
			oe : OSErr;
	begin
		pb.ioRefNum := refnum;
		pb.ioBuffer := p;
		pb.ioReqCount := len;
		pb.ioPosMode := mode;
		pb.ioPosOffset := pos;
		oe := PBWriteSync(@pb);
		if (oe = noErr) and (pb.ioActCount <> len) then begin
			oe := -1;
		end;
		MyFSWriteAt := oe;
	end;


(*
// Alternative version, maybe slower
function MyFSWriteAt (refnum : SInt16; mode : SInt16; pos, len : SInt32; p : Ptr) : OSErr;
	var err : OSErr;
	    count : SInt32;
	begin

	  err := -1;

	  err := SetFPos(refnum, mode, pos);

	  if (err = noErr) then
	    begin
	      count := len;
	      err := FSWrite(refnum, count, p);
	      if (err = noErr) and (count <> len)
	        then err := -1;
	    end;


		MyFSWriteAt := err;
	end;
*)

	const
		maxk = $70000000 div 1024;

	function MultiplyAllocation (blocks, blocksize : SInt32) : SInt32; { result in k }
		var
			size : SInt32;
	begin
		blocks := BAND(BSR(blocks, 1), $00007FFF); { div 2 }
		blocksize := BAND(BSR(blocksize, 9), $007FFFFF); { div 512 }
		if (blocksize > 256) and (blocks > 256) then begin
			size := (blocksize div 16) * (blocks div 16);
			if size > maxk div 256 then begin
				size := maxk div 256;
			end;
			size := size * 256;
		end else begin
			size := blocksize * blocks; { in k }
			if size > maxk then begin
				size := maxk;
			end;
		end;
		MultiplyAllocation := size;
	end;

	function OldDiskFreeSpace (vrn : SInt16) : SInt32; { result in k }
		var
			err : OSErr;
			pb : HParamBlockRec;
			free : SInt32;
	begin
		free := maxk;
		pb.ioNamePtr := NIL;
		pb.iovRefNum := vrn;
		pb.ioVolIndex := 0;
		err := PBHGetVInfoSync(@pb);
		if err = noErr then begin
			free := MultiplyAllocation(pb.ioVFrBlk, pb.ioVAlBlkSiz);
		end;
		OldDiskFreeSpace := free;
	end;

	(*
	function DiskFreeSpace (vrn : SInt16) : SInt32; { result in k }
		var
			err : OSErr;
			free : SInt32;
	begin
		err := GetVInfo(vrn, NIL, vrn, free);
		if err <> noErr then begin
			free := maxk;
		end else begin
			if free < 0 then begin
				free := maxk;
			end else begin
				free := free div 1024;
				if free > maxk then begin
					free := maxk;
				end;
			end;
		end;
		DiskFreeSpace := free;
	end;
	*)

	function DiskSize (vrn : SInt16) : SInt32; { result in k }
		var
			err : OSErr;
			pb : HParamBlockRec;
			size : SInt32;
	begin
		size := 0;
		pb.ioNamePtr := NIL;
		pb.iovRefNum := vrn;
		pb.ioVolIndex := 0;
		err := PBHGetVInfoSync(@pb);
		if err = noErr then begin
			size := MultiplyAllocation(pb.ioVNmAlBlks, pb.ioVAlBlkSiz);
		end;
		DiskSize := size;
	end;

	function BlessSystemFolder (vrn : SInt16; dirID : SInt32) : OSErr;
		var
			err : OSErr;
			pb : HParamBlockRec;
	begin
		pb.ioNamePtr := NIL;
		pb.iovRefNum := vrn;
		pb.ioVolIndex := 0;
		err := PBHGetVInfoSync(@pb);
		if err = noErr then begin
			pb.ioVFndrInfo[1] := dirID;  { ARGHHHHHHH! }
			err := PBSetVInfoSync(@pb);
		end;
		BlessSystemFolder := err;
	end;


	function SameFSSpec (const fs1, fs2 : fileInfo) : boolean;
	begin
		SameFSSpec := (fs1.vRefNum = fs2.vRefNum) and
		              (fs1.parID = fs2.parID) and   {(IUEqualString(fs1.name, fs2.name) = 0);}
		              (GetName(fs1) = GetName(fs2));      {attention, on devrait plutot utiliser IUEqualString !!!!!!!}
	end;



	function FSpGetFolderDirID( const spec : fileInfo; var dirID : SInt32 ) : OSErr;
		var
			err : OSErr;
			pb : CInfoPBRec;
	begin
		dirID := -10;
		err := FSpGetCatInfo( spec, pb );
		if err = noErr then begin
			if BitAnd(pb.ioFlAttrib,ioDirMask) = 0 then begin
				err := fnfErr;
			end else begin
				dirID := pb.ioDrDirID;
			end;
		end;
		FSpGetFolderDirID := err;
	end;

	(*
	function GetVolInfo (var name : Str63; var vrn : SInt16; index: SInt16; var CrDate : SInt32) : OSErr;
		var
			pb : ParamBlockRec;
			oe : OSErr;
	begin
		if (name <> '') and (name[LENGTH_OF_STRING(name)] <> DirectorySeparator ) then begin
			name := Concat(name, DirectorySeparator );
		end;
		pb.ioNamePtr := @name;
		pb.iovRefNum := vrn;
		pb.ioVolIndex := index;
		oe := PBGetVInfoSync(@pb);
		if oe = noErr then begin
			vrn := pb.iovRefNum;
			CrDate := pb.ioVCrDate;
		end;
		GetVolInfo := oe;
	end;
	*)

(*

{$PUSH}
{$ALIGN MAC68K}
	type
		VolParamsRecord = packed record
					version : SInt16;
					attrib: SInt32;
					localhand: Handle;
					address: AddrBlock;
				end;
{$ALIGN RESET}
{$POP}


	function GetVolumeAddrBlock(vrn : SInt16; index: SInt16; var addr : AddrBlock) : OSErr;
		var
			err : OSErr;
			pb : HParamBlockRec;
			volparams: VolParamsRecord;
	begin
		SInt32(addr) := 0;
		pb.ioNamePtr := NIL;
		pb.iovRefNum := vrn;
		pb.ioVolIndex := index;
		err := PBHGetVInfoSync(@pb);
		if err = noErr then begin
			pb.ioNamePtr := NIL;
			pb.ioBuffer := @volparams;
			pb.ioReqCount := SizeOf(volparams);
			err := PBHGetVolParmsSync(@pb);
		end;
		if err = noErr then begin
			addr := volparams.address;
		end;
		GetVolumeAddrBlock := err;
	end;
*)



function ScanDirectory (fs : fileInfo; doit : ScanProc) : OSErr;
var
	pb : CInfoPBRec;
	ret, folder : boolean;
	path : String255;
  err : OSErr;
  dummy : boolean;


	procedure Scan (dirID : SInt32);
		var
			index, len : SInt16;
			oe : OSErr;
	begin
		index := 1;
		repeat
			with pb do
			  begin
					oe := MyGetCatInfo(fs.vRefNum, dirID, @fs.name, index, pb);

					index := index + 1;
					if oe = noErr then
					  begin
							fs.parID := dirID;
							folder := BAND(pb.ioFlAttrib, ioDirMask) <> 0;
							ret := doit(fs, folder, path, pb);
							if folder and ret
							  then
							    begin
										len := LENGTH_OF_STRING(path);
										path := Concat(path, GetName(fs), DirectorySeparator );
										Scan(pb.ioDirID);
										SET_LENGTH_OF_STRING(path,len);
								  end
							  else
							    begin
							      if not(folder) and ret then
							        begin
								       index := index - 1;
							       end;
							    end;
					  end;
			  end;
		until (oe <> noErr) {or EscapeDansQueue;}
	end;

begin
	path := DirectorySeparator ;
	if GetName(fs) <> ''
	  then
	    begin
	      err := MyGetCatInfo(fs.vRefNum, fs.parID, @fs.name, 0, pb);

	      if err = noErr then
	        begin
		  	    if BAND(pb.ioFlAttrib, ioDirMask) <> 0
	  		      then Scan(pb.ioDirID)
			        else dummy := doit(fs, false, path, pb);
			    end;
	    end
	  else
	    begin
		    Scan(fs.parID);
		    err := noErr;
	    end;
	ScanDirectory := err;
end;


function SetPathOfScannedDirectory(var folder : fileInfo) : OSErr;
var err : OSErr;
    path : String255;
    targetIsFolder,wasAliased : boolean;
begin

  err := ResolveAliasFile(folder,TRUE,targetIsFolder,wasAliased);
  err := ExpandFileName(folder,path);

  nomDirectoryDepartRecursion := path;
  if RightStr(nomDirectoryDepartRecursion,1) = DirectorySeparator then
    nomDirectoryDepartRecursion := LeftStr(nomDirectoryDepartRecursion,LENGTH_OF_STRING(nomDirectoryDepartRecursion)-1);

  SetPathOfScannedDirectory := err;
end;


function GetPathOfScannedDirectory : String255;
begin
  GetPathOfScannedDirectory := nomDirectoryDepartRecursion;
end;


function MacPathToUNIXPath( oldMacPath : String255 ) : String255;
var pathUnix, foo : String255;
begin

  if (Pos(':' , oldMacPath) <= 0) then
    begin
      // probably already a UNIX path...
      MacPathToUNIXPath := oldMacPath;
      exit;
    end;


  oldMacPath := ReplaceStringAll(oldMacPath,'/',':');  // separateurs a la mode Mac
  if (oldMacPath[1] = ':')
    then pathUnix := oldMacPath
    else
      begin
        Split(oldMacPath, ':', foo, pathUnix);       // enlever le nom du disque dur
        pathUnix := '/' + pathUnix;
      end;

  pathUnix := ReplaceStringAll(pathUnix,':','/');      // remettre les separateurs a la mode UNIX
  MacPathToUNIXPath := pathUnix;
end;




function EscapeSpacesInUnixPath( oldPath : String255 ) : String255;
var result : String255;
begin

  result := oldPath;

  result := ReplaceStringAll(result, ' ','•' );

  while (Pos('•', result) > 0) do
    result := ReplaceStringOnce(result, '•' , '\ ');

  EscapeSpacesInUnixPath := result;

end;



function RemoveResourceFork( {const} spec : fileInfo ) : OSErr;
	var
		err, err2 : OSErr;
		refnum : SInt16;
	begin
		err := FSpOpenRF( spec, fsRdWrPerm, refnum );
		if err = noErr then begin
			err := SetEOF( refnum, 0 );
			err2 := FSClose( refnum );
			if err = noErr then begin
				err := err2;
			end;
		end;
		RemoveResourceFork := err;
	end;


type SFPutFileProcPtr = procedure(where : Point; prompt : ConstStringPtr; origName : Str255; dlgHook : DlgHookUPP; VAR reply : SFReply);


procedure MySFPutFile(where : Point; prompt : ConstStringPtr; origName : String255; dlgHook : DlgHookUPP; VAR reply : SFReply);
var err : OSErr;
    connID : CFragConnectionID;
    MySFPutFileProc : SFPutFileProcPtr;
    mainAddr : Ptr;
    errMessage : Str255;
    symClass : CFragSymbolClassPtr;
    symAddr : symAddrPtr;
begin
  connID := NIL;  {kInvalidID}
  MySFPutFileProc := NIL;
  mainAddr := NIL;

  err := GetSharedLibrary( StringToStr63("InterfaceLib"), kCompiledCFragArch, kReferenceCFrag, connID, mainAddr, errMessage );

  {WritelnNumDansRapport('MySFPutFile : après GetSharedLibrary, err = ',err);}

  if (err = noErr) then
    begin
      err := FindSymbol( connID, StringToStr255("SFPutFile"), symAddr, symClass);
    end;

  {WritelnNumDansRapport('MySFPutFile : après FindSymbol, err = ',err);}

  if (err = NoErr) then
    begin
      MySFPutFileProc := SFPutFileProcPtr(symAddr);

      {WritelnNumDansRapport('MySFPutFile : avant l''appel de MySFPutFileProc, err = ',err);}

      MySFPutFileProc(where, prompt, StringToStr255(origName), dlgHook, reply);

      {WritelnNumDansRapport('MySFPutFile : après l''appel de MySFPutFileProc, err = ',err);}
    end;
end;



type SFGetFileProcPtr = procedure(where : Point; prompt : Str255; fileFilter : FileFilterUPP; numTypes : SInt16; typeList : ConstSFTypeListPtr; dlgHook : DlgHookUPP; var reply : SFReply);

procedure MySFGetFile(where : Point; prompt : String255; fileFilter : FileFilterUPP; numTypes : SInt16; typeList : ConstSFTypeListPtr; dlgHook : DlgHookUPP; var reply : SFReply);
var err : OSErr;
    connID : CFragConnectionID;
    MySFGetFileProc : SFGetFileProcPtr;
    mainAddr : Ptr;
    errMessage : Str255;
    symClass : CFragSymbolClassPtr;
    symAddr : symAddrPtr;
begin
  connID := NIL;  {kInvalidID}
  MySFGetFileProc := NIL;
  mainAddr := NIL;

  err := GetSharedLibrary(StringToStr63("InterfaceLib") , kCompiledCFragArch, kReferenceCFrag, connID, mainAddr, errMessage );

  (* WritelnNumDansRapport('MySFGetFile : après GetSharedLibrary, err = ',err); *)

  if (err = noErr) then
    begin
      err := FindSymbol( connID, StringToStr255("SFGetFile"), symAddr, symClass);
    end;

  (* WritelnNumDansRapport('MySFGetFile : après FindSymbol, err = ',err); *)

  if (err = NoErr) then
    begin
      MySFGetFileProc := SFGetFileProcPtr(symAddr);

      (* WritelnNumDansRapport('MySFGetFile : avant l''appel de MySFGetFileProc, err = ',err); *)

      MySFGetFileProc(where, StringToStr255(prompt), fileFilter, numTypes, typeList, dlgHook, reply);

      (* WritelnNumDansRapport('MySFGetFile : après l''appel de MySFGetFileProc, err = ',err); *)
    end;
end;


function MakeCFSTR(s : String255) : CFStringRef;
begin
  MakeCFSTR := CFStringCreateWithPascalString(NIL, StringToStr255(s), kCFStringEncodingMacRoman);
end;


function CFStringToString255(theCFString : CFStringRef) : String255;
var s : str255;
    result : String255;
begin

  if (theCFString = NIL) then
    begin
      CFStringToString255 := '';
      exit;
    end;

  if CFStringGetPascalString(theCFString, @s, 256, kCFStringEncodingMacRoman)
    then result := Str255ToString(s)
    else result := '';

  CFStringToString255 := result;
end;


function ConvertEncodingOfString(s : String255; oldEncoding, newEncoding : CFStringEncoding) : String255;
var theCFString : CFStringRef;
    buffer : str255;
begin

  if (oldEncoding = newEncoding) then
    begin
      ConvertEncodingOfString := s;
      exit;
    end;

  theCFString := CFStringCreateWithPascalString(NIL, StringToStr255(s), oldEncoding);

  if (theCFString = NIL) then
    begin
      CFRelease(CFTypeRef(theCFString));
      ConvertEncodingOfString := s;
      exit;
    end;

  if CFStringGetPascalString(theCFString, @buffer, 256, newEncoding)
    then ConvertEncodingOfString := Str255ToString(buffer)
    else ConvertEncodingOfString := s;

  CFRelease(CFTypeRef(theCFString));
end;


function MyLoadFrameworkBundle(inFrameworkName : CFStringRef; var outBundleRef : CFBundleRef) : OSStatus;
var
	frameworksFolderRef : FSRef	;
	baseURL : CFURLRef ;
	bundleURL : CFURLRef ;
	err : OSStatus ;
label cleanup;
begin

  baseURL := NIL;
  bundleURL := NIL;

	outBundleRef := NIL ;

	(*	find the Frameworks folder *)
	err := FSFindFolder(kOnAppropriateDisk, kFrameworksFolderType, kDontCreateFolder, frameworksFolderRef);
	if (err <> NoErr) then
	begin
	  {Writeln('MyLoadFrameworkBundle : FSFindFolder = ',err);}
		goto cleanup ;
	end;

	(*	convert the FSRef into a URL *)
	err := coreFoundationUnknownErr ;
	{ baseURL := CFURLCreateFromFSRef(kCFAllocatorSystemDefault, frameworksFolderRef)); }
	baseURL := CFURLCreateFromFSRef(NIL, frameworksFolderRef);
	if (baseURL = NIL) then
	begin
	  {Writeln('MyLoadFrameworkBundle : baseURL = NIL');}
		goto cleanup ;
	end;

	(*	append the name of the framework to the base URL *)
	{bundleURL := CFURLCreateCopyAppendingPathComponent(kCFAllocatorSystemDefault, baseURL, inFrameworkName, false);}
	bundleURL := CFURLCreateCopyAppendingPathComponent(NIL, baseURL, inFrameworkName, false);
	if (bundleURL = NIL) then
	begin
	  {Writeln('MyLoadFrameworkBundle : bundleURL = NIL');}
		goto cleanup ;
	end;

	(*	create a bundle based on that URL *)
	{outBundleRef := CFBundleCreate(kCFAllocatorSystemDefault, bundleURL);}
	outBundleRef := CFBundleCreate(NIL, bundleURL);
	if (outBundleRef = NIL) then
	begin
	  {Writeln('MyLoadFrameworkBundle : outBundleRef = NIL');}
		goto cleanup ;
	end;

	(*	load the bundle *)
	if NOT(CFBundleLoadExecutable(outBundleRef)) then
	begin
	  {Writeln('MyLoadFrameworkBundle : NOT(CFBundleLoadExecutable(outBundleRef))');}
		goto cleanup ;
	end;

	(*	clear result code *)
	err := noErr ;

cleanup :
	(*	clean up *)
	if (err <> noErr) then
	begin
		if (outBundleRef <> NIL) then
		begin
			CFRelease(CFTypeRef(outBundleRef)) ;
			outBundleRef := NIL ;
		end;
	end;

	if (bundleURL <> NIL) then
	begin
		CFRelease(CFTypeRef(bundleURL)) ;
		bundleURL := NIL ;
	end;

	if (baseURL <> NIL) then
	begin
		CFRelease(CFTypeRef(baseURL)) ;
		baseURL := NIL ;
	end;

	(*	return result code *)
	MyLoadFrameworkBundle := err ;
end;






//	Utility routine to load a bundle from the applications Frameworks folder.
//	par exemple : "Cassio.app/Contents/Frameworks/SplashScreenBundle.bundle"
function MyLoadPrivateFrameworkBundle(inFrameworkName : CFStringRef; var outBundleRef : CFBundleRef) : OSStatus;
var
	baseURL : CFURLRef ;
	bundleURL : CFURLRef ;
	myAppsBundle : CFBundleRef;
	err : OSStatus ;
	frameworkName : String255;
	myCFRef : CFStringRef;

label cleanup;
begin

  baseURL := NIL;
  bundleURL := NIL;
  myAppsBundle := NIL;

	outBundleRef := NIL ;

	err := coreFoundationUnknownErr ;

	frameworkName := CFStringToString255(inFrameworkName);

	// WritelnDansRapport('frameworkPath = '+frameworkPath);


	if (Pos('/',frameworkName) = 0)
	  then
	    begin

      	(* Get our application's main bundle from Core Foundation *)
      	myAppsBundle :=  CFBundleGetMainBundle;
      	if ( myAppsBundle = NIL )	then
      	begin
      	  Writeln('MyLoadPrivateFrameworkBundle : CFBundleGetMainBundle = ',err);
      	  goto cleanup;
      	end;

      	(*	get the framework URL *)
      	baseURL :=  CFBundleCopyPrivateFrameworksURL( myAppsBundle );
      	if (baseURL = NIL) then
      	begin
      	  Writeln('MyLoadPrivateFrameworkBundle : baseURL = NIL');
      		goto cleanup ;
      	end;

      	(*	append the name of the framework to the base URL *)
      	bundleURL := CFURLCreateCopyAppendingPathComponent(NIL, baseURL, inFrameworkName, false);
      	if (bundleURL = NIL) then
      	begin
      	  Writeln('MyLoadPrivateFrameworkBundle : bundleURL = NIL');
      		goto cleanup ;
      	end;

      end
    else
      begin


        //myCFRef := MakeCFSTR('/Library/MyBundle.bundle');

        myCFRef := MakeCFSTR(frameworkName);
        bundleURL := CFURLCreateWithFileSystemPath(kCFAllocatorDefault,myCFRef,kCFURLPOSIXPathStyle,true);
        CFRelease(CFTypeRef(myCFRef));

        if (bundleURL = NIL) then
      	begin
      	  Writeln('MyLoadPrivateFrameworkBundle : bundleURL = NIL');
      		goto cleanup ;
      	end;

      end;



	(*	create a bundle based on that URL *)
	outBundleRef := CFBundleCreate(NIL, bundleURL);
	if (outBundleRef = NIL) then
	begin
	  Writeln('MyLoadPrivateFrameworkBundle : outBundleRef = NIL');
		goto cleanup ;
	end;

	(*	load the bundle *)
	if NOT(CFBundleLoadExecutable(outBundleRef)) then
	begin
	  Writeln('MyLoadPrivateFrameworkBundle : NOT(CFBundleLoadExecutable(outBundleRef))');
		goto cleanup ;
	end;

	(*	clear result code *)
	err := noErr ;

cleanup :
	(*	clean up *)
	if (err <> noErr) then
	begin
		if (outBundleRef <> NIL) then
		begin
			CFRelease(CFTypeRef(outBundleRef)) ;
			outBundleRef := NIL ;
		end;
	end;

	if (bundleURL <> NIL) then
	begin
		CFRelease(CFTypeRef(bundleURL)) ;
		bundleURL := NIL ;
	end;

	if (baseURL <> NIL) then
	begin
		CFRelease(CFTypeRef(baseURL)) ;
		baseURL := NIL ;
	end;

	(*	return result code *)
	MyLoadPrivateFrameworkBundle := err ;
end;



function GetFunctionPointerFromBundle(const whichBundle,functionName : String255) : Ptr;
var err : OSStatus;
    bundleRef : CFBundleRef;
    myCFRef : CFStringRef;
    result : Ptr;
begin
  (*	load the framework *)

  myCFRef := MakeCFSTR(whichBundle);
  err :=  MyLoadFrameworkBundle(myCFRef, bundleRef);
  CFRelease(CFTypeRef(myCFRef));

  if (err <> NoErr) then
    begin
      GetFunctionPointerFromBundle := NIL;
      WritelnNumDansRapport(whichBundle + ' : bundle not found,   err = ',err);
      {Writeln(whichBundle + ' : bundle not found,  err = ',err);}
      exit;
    end;

  (*  get the function pointer in the framework *)

  myCFRef := MakeCFSTR(functionName);
  result := CFBundleGetFunctionPointerForName(bundleRef,myCFRef);
	CFRelease(CFTypeRef(myCFRef));

	if (result = NIL) then
    begin
      GetFunctionPointerFromBundle := NIL;
      WritelnDansRapport(functionName + ' : function not found in bundle '+ whichBundle);
      {Writeln(functionName + ' : function not found in bundle '+ whichBundle);}
      exit;
    end;

	GetFunctionPointerFromBundle := result;
end;


function GetFunctionPointerFromPrivateBundle(const whichBundle,functionName : String255) : Ptr;
var err : OSStatus;
    bundleRef : CFBundleRef;
    myCFRef : CFStringRef;
    result : Ptr;
begin
  (*	load the framework *)

  myCFRef := MakeCFSTR(whichBundle);
  err :=  MyLoadPrivateFrameworkBundle(myCFRef, bundleRef);
  CFRelease(CFTypeRef(myCFRef));

  if (err <> NoErr) then
    begin
      GetFunctionPointerFromPrivateBundle := NIL;
      WritelnNumDansRapport(whichBundle + ' : bundle not found,   err = ',err);
      {Writeln(whichBundle + ' : bundle not found,  err = ',err);}
      exit;
    end;

  (*  get the function pointer in the framework *)

  myCFRef := MakeCFSTR(functionName);
  result := CFBundleGetFunctionPointerForName(bundleRef,myCFRef);
	CFRelease(CFTypeRef(myCFRef));

	if (result = NIL) then
    begin
      GetFunctionPointerFromPrivateBundle := NIL;
      WritelnDansRapport(functionName + ' : function not found in bundle '+ whichBundle);
      {Writeln(functionName + ' : function not found in bundle '+ whichBundle);}
      exit;
    end;

	GetFunctionPointerFromPrivateBundle := result;
end;


function GetFichierTexte(prompt : String255; fileKind1,fileKind2,fileKind3,fileKind4 : OSType; var fic : basicfile) : OSErr;
var reply : SFReply;
    err : OSErr;
    info : fileInfo;
begin
  err := -1;

  if GetFileName(prompt,reply,fileKind1,fileKind2,fileKind3,fileKind4,info) then
    err := FileExists(info,fic);

  GetFichierTexte := err;
end;


function CreateDirectoryWithThisPath(directoryPath : String255) : OSErr;
const separateur = DirectorySeparator ;
var erreurES : OSErr;
    directoryDepot : fileInfo;
    dirID : UInt32;
begin

  if RightStr(directoryPath,1) <> CharToString(separateur) then
     directoryPath := directoryPath + separateur;

  erreurES := MakeFileInfo(directoryPath,directoryDepot);

  if not(FolderExists(directoryDepot, erreurES))
    then
      begin
        {WritelnNumDansRapport('Le dossier '+directoryPath+' n''existe pas, erreurES = ',erreurES); }
        erreurES := CreateUniqueFolder(directoryDepot,dirID);
      end
    else
      begin
        {WritelnNumDansRapport('Le dossier '+directoryPath+' existe, erreurES = ',erreurES) }
      end;

   CreateDirectoryWithThisPath := erreurES;
end;


function CreateSubDirectoryNearThisFile(const whichFile : fileInfo; var directoryName : String255) : OSErr;
const separateur = DirectorySeparator ;
var erreurES : OSErr;
    path, pathSubDirectory : String255;

begin

  if RightStr(directoryName,1) <> CharToString(separateur) then
    directoryName := directoryName + separateur;

  erreurES := ExpandFileName(whichFile,path);
  pathSubDirectory := ExtraitCheminDAcces(path) + directoryName;

  erreurES := CreateDirectoryWithThisPath(pathSubDirectory);

  CreateSubDirectoryNearThisFile := erreurES;
end;



var gApplicationSupportCached :
      record
        thePath : String255;
        theErr :  OSErr;
      end;
const gApplicationSupportPathCalculated : boolean = false;


function GetPathOfApplicationSupportFolder(var applicationFolderPath : String255) : OSErr;
var
	applicationSupportFolderRef : FSRef	;
	err : OSStatus ;
	CPath : packed array[0..255] of char;
	c : char;
	i : SInt32;
	fsTemp : fileInfo;
	pathTemp : String255;
	volumeName : String255;
	fsAppSuppFolder : fileInfo;
	err2 : OSErr;
label cleanup;
begin

  if gApplicationSupportPathCalculated then
    begin
      applicationFolderPath             := gApplicationSupportCached.thePath;
      GetPathOfApplicationSupportFolder := gApplicationSupportCached.theErr;
      exit;
    end;

  applicationFolderPath := '';

	(*	find the Application Support folder *)
	err := FSFindFolder(kUserDomain, kApplicationSupportFolderType, kDontCreateFolder, applicationSupportFolderRef);
	if (err <> NoErr) then
	begin
	  WritelnNumDansRapport('GetPathOfApplicationSupportFolder : FSFindFolder = ',err);
		goto cleanup ;
	end;

	(* convert the FSRef to a C path *)
	err := FSRefMakePath(applicationSupportFolderRef, @CPath, 255);
	if (err <> NoErr) then
	begin
	  WritelnNumDansRapport('GetPathOfApplicationSupportFolder : FSRefMakePath = ',err);
		goto cleanup ;
	end;

	(* convert the C path to a Pascal String *)
	i := 0;
	while (i < 255) and (ord(CPath[i]) > 0) do
	  begin
	    c := CPath[i];
	    if c = '/' then c := DirectorySeparator ;
	    applicationFolderPath := applicationFolderPath + c;
	    i := i + 1;
	  end;

	(* try to create a temporary file to guess the user volume name *)
	SetNameOfFSSpec(fsTemp,'foobarbar');
	err := CreateTemporaryFile(fsTemp);
	if (err <> NoErr) then
	begin
	  WritelnNumDansRapport('GetPathOfApplicationSupportFolder : CreateTemporaryFile = ',err);
		goto cleanup ;
	end;

	(* get the complete path of that temporary file *)
	err := ExpandFileName(fsTemp, pathTemp);
	if (err <> NoErr) then
	begin
	  WritelnNumDansRapport('GetPathOfApplicationSupportFolder : ExpandFileName = ',err);
		goto cleanup ;
	end;

	(* the volume name should be the left part of this temporary path *)
	volumeName := ExtraitNomDeVolume(pathTemp);


	applicationFolderPath := volumeName + applicationFolderPath;

	(* Check the result : is the application support folder path a correct path ? *)
	err := MakeFileInfo(applicationFolderPath,fsAppSuppFolder);
	if (err <> NoErr) then
	begin
	  WritelnNumDansRapport('GetPathOfApplicationSupportFolder : MakeFileInfo = ',err);
		goto cleanup ;
	end;

	(* Check the existence of the application support folder *)
  if not(FolderExists(fsAppSuppFolder, err2)) then
    begin
      WritelnNumDansRapport('GetPathOfApplicationSupportFolder : FolderExists = ',err2);
      err := err2;
		  goto cleanup ;
    end;

	cleanup :

	gApplicationSupportPathCalculated := true;

	gApplicationSupportCached.thePath := applicationFolderPath;
	gApplicationSupportCached.theErr  := err;

  GetPathOfApplicationSupportFolder := err;
end;



end.
