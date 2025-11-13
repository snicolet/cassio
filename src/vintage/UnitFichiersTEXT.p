UNIT basicfile;



INTERFACE







 USES UnitDefCassio , Files , DateTimeUtils, UnitDefHugeString;







function FileExists(nom : String255 ; vRefNum : SInt16; var fic : basicfile) : OSErr;
function FileExists(info : fileInfo; var fic : basicfile) : OSErr;
function CreateFile(nom : String255 ; vRefNum : SInt16; var fic : basicfile) : OSErr;
function CreateFile(info : fileInfo; var fic : basicfile) : OSErr;



function FichierTexteDeCassioExiste(nom : String255; var fic : basicfile) : OSErr;
function CreeFichierTexteDeCassio(nom : String255; var fic : basicfile) : OSErr;


function OpenFile(var fic : basicfile) : OSErr;
function CloseFile(var fic : basicfile) : OSErr;
function DeleteFile(var fic : basicfile) : OSErr;
function FileIsOpen(var fic : basicfile) : boolean;
function GetUniqueID(var fic : basicfile) : SInt32;
function GetFileSize(var fic : basicfile; var taille : SInt32) : OSErr;
function SetFilePosition(var fic : basicfile; position : SInt32) : OSErr;
function SetFilePositionAtEnd(var fic : basicfile) : OSErr;
function GetFilePosition(var fic : basicfile; var position : SInt32) : OSErr;
function EndOfFile(var fic : basicfile; var erreurES : OSErr) : boolean;
function SetEndOfFile(var fic : basicfile; posEOF : SInt32) : OSErr;
function ClearFileContent(var fic : basicfile) : OSErr;


function Write(var fic : basicfile; s : String255) : OSErr;
function Writeln(var fic : basicfile; s : String255) : OSErr;
function Write(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
function Write(var fic : basicfile; ficAbstrait : FichierAbstrait; fromPos : SInt32; var count : SInt32) : OSErr;
function Writeln(var fic : basicfile; value : SInt32) : OSErr;
function Write(var fic : basicfile; const s : HugeString) : OSErr;
function Writeln(var fic : basicfile; const s : HugeString) : OSErr;



function Read(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
function Read(var fic : basicfile; nbOctets : SInt16; var s : String255) : OSErr;
function Readln(var fic : basicfile; var s : String255) : OSErr;
function Readln(var fic : basicfile; var s : LongString) : OSErr;
function Readln(var fic : basicfile; var s : HugeString) : OSErr;
function Readln(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
function Read(var fic : basicfile; var value : SInt32) : OSErr;


procedure ForEachLineInFileDo(whichFile : fileInfo ; DoWhat : LineOfFileProc; var result : SInt32);
function InsertFileInFile(var fic : basicfile; pathFichierAInserer : String255) : OSErr;
function InsertFileInFile(var insere,receptacle : basicfile) : OSErr;


procedure SetFileCreatorFichierTexte(var fic : basicfile; quelType : OSType);
procedure SetFileTypeFichierTexte(var fic : basicfile; quelType : OSType);
function GetFileCreatorFichierTexte(var fic : basicfile) : OSType;
function GetFileTypeFichierTexte(var fic : basicfile) : OSType;


function GetCreationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
function SetCreationDate(var fic : basicfile; const theDate : DateTimeRec) : OSErr;
function GetModificationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
function SetModificationDate(var fic : basicfile; const theDate : DateTimeRec) : OSErr;


function CreerRessourceFork(var fic : basicfile) : OSErr;
function OuvreRessourceFork(var fic : basicfile) : OSErr;
function FermeRessourceFork(var fic : basicfile) : OSErr;
function UseRessourceFork(var fic : basicfile) : OSErr;


procedure SetDebugFiles(flag : boolean);
function  GetDebugFiles : boolean;


function CreateStandardOutputAsFile(var fic : basicfile) : OSErr;
function ExtractFileName(whichFile : fileInfo; var theLongName : String255) : OSErr;
function ExtractFileName(path : String255; var theLongName : String255) : OSErr;


procedure SimpleAlertForFile(nomFichier : String255; erreurES : SInt32);



  (* Installation des procedure pour l'affichage de message :     *)
  (* sur la sortie standard par defaut. On peut installer des     *)
  (* routines personalisees d'impression de messages et d'alerte  *)
  (* juste apres l'appel a InitUnitBasicFile                   *)


procedure InitUnitBasicFile;
procedure InstallMessageDisplayerBasicFile(theProc : MessageDisplayerProc);
procedure InstallMessageAndNumDisplayerBasicFile(theProc : MessageAndNumDisplayerProc);
procedure InstallAlertBasicFile(theProc : MessageAndNumDisplayerProc);

procedure DisplayMessageInConsole(s : String255);
procedure DisplayMessageWithNumInConsole(s : String255; num : SInt32);
procedure DisplayAlerteWithNumInConsole(s : String255; num : SInt32);




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Finder, TextCommon, MacErrors, Script, GestaltEqu, Sound, Resources, Aliases
    , CFBase, CFString
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, MyStrings, MyFileSystemUtils, UnitHashing, UnitTraceLog, UnitServicesRapport, UnitFichierAbstrait
    , UnitRapportImplementation, UnitServicesDialogs, MyMathUtils, UnitRapport, UnitServicesMemoire, UnitHugeString ;
{$ELSEC}
    ;
    {$I prelink/FichiersTEXT.lk}
{$ENDC}


{END_USE_CLAUSE}










const unit_initialized : boolean = false;
      debugBasicFiles : boolean = false;

var useStandardConsole : boolean;
    CustomDisplayMessage : MessageDisplayerProc;
    CustomDisplayMessageWithNum : MessageAndNumDisplayerProc;
    CustomDisplayAlerteWithNum : MessageAndNumDisplayerProc;
    nameOfStandardOutputForRapport : String255;

    gEndOfLineFoundInReadln : boolean;


procedure StandardConsoleDisplayer(s : String255);
begin
  Writeln(s);
end;

procedure StandardConsoleDisplayerWithNum(s : String255; num : SInt32);
begin
  Writeln(s,num);
end;

procedure StandardConsoleAlertWithNum(s : String255; num : SInt32);
begin
  Writeln('### WARNING ### '+s+' ',num);
end;


procedure DisplayMessageInConsole(s : String255);
begin
  if unit_initialized
    then CustomDisplayMessage(s)
    else StandardConsoleDisplayer(s);
end;

procedure DisplayMessageWithNumInConsole(s : String255; num : SInt32);
begin
  if unit_initialized
    then CustomDisplayMessageWithNum(s,num)
    else StandardConsoleDisplayerWithNum(s,num);
end;

procedure DisplayAlerteWithNumInConsole(s : String255; num : SInt32);
begin
  if unit_initialized
    then CustomDisplayAlerteWithNum(s,num)
    else StandardConsoleAlertWithNum(s,num)
end;



function ResolveAliasInFullName(var fullName : String255) : OSErr;
var debut,reste,resolvedDebut : String255;
    myFileInfo : fileInfo;
    err : OSErr;
    posDeuxPoints : SInt16;
begin
  debut := '';
  reste := fullName;
  err := 0;

  while (reste <> '') and (err = 0) do
    begin
      posDeuxPoints := Pos(DirectorySeparator,reste);
      if posDeuxPoints > 0
        then
          begin
            debut := debut + TPCopy(reste,1,posDeuxPoints);
            reste := TPCopy(reste,posDeuxPoints+1,LENGTH_OF_STRING(reste)-posDeuxPoints);
          end
        else
          begin
            debut := debut + reste;
            reste := '';
          end;

      err := MakeFileInfo(debut,myFileInfo);
      ExpandFileName(myFileInfo);
      resolvedDebut := debut;
      err := ExpandFileName(myFileInfo,resolvedDebut);
      if err = 0 then
        begin
          if EndsWithDirectorySeparator(debut) and not(EndsWithDirectorySeparator(resolvedDebut))
            then debut := resolvedDebut + DirectorySeparator 
            else debut := resolvedDebut;
        end;
    end;
  if err = 0 then fullName := debut;

  ResolveAliasInFullName := err;
end;


function FileIsStandardOutput(var fic : basicfile) : boolean;
begin
  FileIsStandardOutput := (fic.vRefNum = 0) and
                              (fic.parID = 0) and
                              (fic.refNum = 0) and
                              (fic.nomFichier = nameOfStandardOutputForRapport);
end;


procedure InitialiseFichierTexte(var nom : String255; var vRefNum : SInt16; var fic : basicfile);
var nomDirectory : String255;
    len : SInt16;
    err : OSErr;
begin

  if (Pos(':',nom) > 0) and (vRefNum <> 0)
    then
      begin
        nomDirectory := GetWDName(vRefNum);
        len := LENGTH_OF_STRING(nomDirectory);
        if (len > 0) and (nomDirectory <> ':') and ((len+LENGTH_OF_STRING(nom)) <= 220) then
          begin
            if (nom[1] = DirectorySeparator ) and EndsWithDirectorySeparator(nomDirectory)
              then nom := TPCopy(nomDirectory,1,len-1)+nom
              else nom := nomDirectory+nom;
            err := ResolveAliasInFullName(nom);
            vRefNum := 0;
          end;
      end;

  fic.nomFichier := nom;
  fic.vRefNum := vRefNum;
  fic.parID := 0;
  fic.refNum := 0;
  fic.uniqueID := 0;  {not yet initialised, we'll do it in CreateFFSpecAndResolveAlias}
  SetNameOfFSSpec(fic.info, '');
  with fic.info do
    begin
      vRefNum := 0;
      parID := 0;
    end;
  fic.ressourceForkRefNum        := -1;
  fic.dataForkCorrectlyOpen := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkCorrectlyOpen := -1; {niveau d'ouverture = 0 veut dire correct}

  with fic.bufferLecture do
    begin
      bufferLecture       := NIL;
      debutDuBuffer       := 0;
      positionDansBuffer  := 0;
      tailleDuFichier     := -1;
      tailleDuBuffer      := -1;
      positionTeteFichier := 0;
      doitUtiliserBuffer  := true;
    end;
end;


procedure InitialiseFichierTexteFSp(info : fileInfo; var fic : basicfile);
begin

  fic.nomFichier := GetName(info);
  fic.vRefNum    := info.vRefNum;
  fic.parID      := info.parID;
  fic.refNum     := 0;
  fic.uniqueID   := 0;  {not yet initialised, we'll do it in CreateFFSpecAndResolveAlias}
  fic.info  := info;
  fic.ressourceForkRefNum        := -1;
  fic.dataForkCorrectlyOpen := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkCorrectlyOpen := -1; {niveau d'ouverture = 0 veut dire correct}

  with fic.bufferLecture do
    begin
      bufferLecture       := NIL;
      debutDuBuffer       := 0;
      positionDansBuffer  := 0;
      tailleDuFichier     := -1;
      tailleDuBuffer      := -1;
      positionTeteFichier := 0;
      doitUtiliserBuffer  := true;
    end;
end;


type FSCopyAliasInfoPtr = function(inAlias : AliasHandle;
                                   targetName :  HFSUniStr255Ptr;
                                   volumeName :  HFSUniStr255Ptr;
                                   pathString : CFStringRefPtr;
                                   whichInfo : Ptr; {should be FSAliasInfoBitmap^ }
                                   info : Ptr       {should be FSAliasInfo^ }
                                   ) : OSStatus;


function ExtractFileName(whichFile : fileInfo; var theLongName : String255) : OSErr;
var err : OSErr;
    MacVersion : SInt32;
    MySFCopyAlias : FSCopyAliasInfoPtr;
    targetName : HFSUniStr255;
    fileRef : FSRef;
    theAlias : aliasHandle;
    str : CFStringRef;
    pascalName : Str255;
label cleanUp;
begin
  err := -1;
  theLongName := GetName(whichFile);

  if (Gestalt(gestaltSystemVersion, MacVersion) = noErr) and
     (MacVersion >= $1020)  (* au moins Mac OS X 10.2 *)
    then
      begin

  			MySFCopyAlias := FSCopyAliasInfoPtr(GetFunctionPointerFromBundle('CoreServices.framework','FSCopyAliasInfo'));

  			if (MySFCopyAlias <> NIL) then
  			  begin
  			    err := FSpMakeFSRef(whichFile,fileRef);

            if (err <> NoErr) then
              goto cleanUp;

            err := FSNewAlias(NIL,fileRef,theAlias);

            if (err <> NoErr) then
              goto cleanUp;

            if (theAlias <> NIL) then
              err := MySFCopyAlias(theAlias,@targetName, NIL, NIL, NIL, NIL);

            if (err <> NoErr) then
              goto cleanUp;

            str := CFStringCreateWithCharacters( NIL {kCFAllocatorDefault}, @targetName.unicode[0], targetName.length );

            if CFStringGetPascalString(str, @pascalName, 256, kTextEncodingMacRoman)
              then theLongName := MyStr255ToString(pascalName)
              else err := -1;

            CFRelease(CFTypeRef(str));

  			  end;
      end;

  cleanUp :
  ExtractFileName := err;
end;


function ExtractFileName(path : String255; var theLongName : String255) : OSErr;
var err : OSErr;
    myFileInfo : fileInfo;
begin
   err := MakeFileInfo(path,myFileInfo);
   if err <> NoErr
     then ExtractFileName := err
     else ExtractFileName := ExtractFileName(myFileInfo,theLongName);
end;


function CreateFFSpecAndResolveAlias(var fic : basicfile) : OSErr;
var err,bidLongint : OSErr;
    fullName : String255;
begin
  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' avant MakeFileInfo dans CreateFFSpecAndResolveAlias :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
    end;

  if FileIsStandardOutput(fic) then
    begin
      CreateFFSpecAndResolveAlias := NoErr;
      exit;
    end;

  with fic do
    begin
      err := MakeFileInfo(vRefNum,parID,nomFichier,info);
      fullName := nomFichier;
      if (err = NoErr) then
        begin
          ExpandFileName(info);

          err := ExpandFileName(info,fullName);

        end else
      if (err = fnfErr) then {-43 : File Not Found, mais le fileInfo est valable}
        bidlongint := ExpandFileName(info,fullName);
      parID      := info.parID;
      nomFichier := fullName;
      uniqueID   := HashString(fullName);

      {DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('LENGTH_OF_STRING(fic.fullName) = ',LENGTH_OF_STRING(fullName));
      DisplayMessageWithNumInConsole('hashing -> uniqueID = ',uniqueID);}
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MakeFileInfo dans CreateFFSpecAndResolveAlias :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;
  CreateFFSpecAndResolveAlias := err;
end;


function FileExists(nom : String255 ; vRefNum : SInt16; var fic : basicfile) : OSErr;
var err1,err2 : OSErr;
    FinderInfos : FInfo;
begin

  if (nom = '') then
    begin
      DisplayMessageInConsole('WARNING ! (nom = '''') dans FileExists');
      FileExists := -1;
      exit;
    end;

  {TraceLog('FileExists : nom =' + nom);}

  InitialiseFichierTexte(nom,vRefNum,fic);

  if FileIsStandardOutput(fic) then
    begin
      FileExists := NoErr;
      exit;
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres InitialiseFichierTexte dans FileExists :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
    end;

  err2 := CreateFFSpecAndResolveAlias(fic);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans FileExists :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageWithNumInConsole('   ==> Err2 = ',err2);
    end;

  if (err2 <> NoErr)
    then
      FileExists := err2
    else
      begin
			  err1 := FSpGetFInfo(fic.info,FinderInfos);

			  if debugBasicFiles then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpGetFInfo dans FileExists :');
			      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
			      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
			      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
			      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
			      DisplayMessageWithNumInConsole('   ==> Err1 = ',err1);
			    end;

			  FileExists := err1;
			end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' a la fin de FileExists :');
      DisplayMessageWithNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
    end;
end;


function FileExists(info : fileInfo; var fic : basicfile) : OSErr;
var err1,err2 : OSErr;
    FinderInfos : FInfo;
begin
  if (GetName(info) = '') then
    begin
      DisplayMessageInConsole('WARNING ! (GetName(info) = '''') dans FileExists');
      FileExists := -1;
      exit;
    end;


  InitialiseFichierTexteFSp(info, fic);

  if FileIsStandardOutput(fic) then
    begin
      FileExists := NoErr;
      exit;
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres InitialiseFichierTexte dans FileExists :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
    end;

  err2 := CreateFFSpecAndResolveAlias(fic);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans FileExists :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageWithNumInConsole('   ==> Err2 = ',err2);
    end;

  if (err2 <> NoErr)
    then
      FileExists := err2
    else
      begin
			  err1 := FSpGetFInfo(fic.info,FinderInfos);

			  if debugBasicFiles then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpGetFInfo dans FileExists :');
			      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
			      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
			      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
			      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
			      DisplayMessageWithNumInConsole('   ==> Err1 = ',err1);
			    end;

			  FileExists := err1;
			end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' a la fin de FileExists :');
      DisplayMessageWithNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
    end;
end;


function CreateFile(nom : String255 ; vRefNum : SInt16; var fic : basicfile) : OSErr;
var err : OSErr;
begin
  InitialiseFichierTexte(nom,vRefNum, fic);
  err := CreateFFSpecAndResolveAlias(fic);

  if FileIsStandardOutput(fic) then
    begin
      CreateFile := NoErr;
      exit;
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans CreateFile :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  err := FSpCreate(fic.info,FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('TEXT'),0);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreate dans CreateFile :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  CreateFile := err;
end;

function CreateFile(info : fileInfo; var fic : basicfile) : OSErr;
var err : OSErr;
begin
  InitialiseFichierTexteFSp(info, fic);
  err := CreateFFSpecAndResolveAlias(fic);

  if FileIsStandardOutput(fic) then
    begin
      CreateFile := NoErr;
      exit;
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans CreateFile :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  err := FSpCreate(fic.info,FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('TEXT'),0);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreate dans CreateFile :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  CreateFile := err;
end;




function OpenFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      OpenFile := NoErr;
      exit;
    end;

  if fic.dataForkCorrectlyOpen <> -1 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le data Fork d''un fichier dont fic.dataForkCorrectlyOpen <> -1 !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('GetName(fic.info) = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
      DisplayMessageInConsole('');
      OpenFile := -1;
      exit;
    end;

  err := -1;

(*
  with fic do  {on essaie l'ouverture avec les anciennes routines}
    err := FSOpen(nomFichier,vRefNum,refNum);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSOpen dans OpenFile :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;
*)

  if err <> NoErr then  {on essaie avec les routines du systeme 7 et le fileInfo}
    with fic do
      begin
        err := FSpOpenDF(info,fsCurPerm,refNum);

        if debugBasicFiles then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpOpenDF dans OpenFile :');
			      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
			      DisplayMessageInConsole('fic.info.name = '+GetName(fic.info));
			      DisplayMessageWithNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
			      DisplayMessageWithNumInConsole('fic.info.parID = ',fic.info.parID);
			      DisplayMessageWithNumInConsole('   ==> Err = ',err);
			    end;
      end;

  if err = NoErr then
    begin
      inc(fic.dataForkCorrectlyOpen);
      if fic.dataForkCorrectlyOpen <> 0 then
        begin
          SysBeep(0);
          DisplayMessageInConsole('');
          DisplayMessageInConsole('## WARNING : après une ouverture réussie, dataForkCorrectlyOpen <> 0 !');
          DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
          DisplayMessageWithNumInConsole('fic.dataForkCorrectlyOpen',fic.dataForkCorrectlyOpen);
          DisplayMessageInConsole('');
        end;
    end;

  OpenFile := err;
end;


function CloseFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      CloseFile := NoErr;
      exit;
    end;

  if fic.dataForkCorrectlyOpen <> 0 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le data Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('GetName(fic.info) = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
      DisplayMessageInConsole('');
      CloseFile := -1;

      (* ForconsLePlantageDeCassio; *)

      exit;
    end;

  err := FSClose(fic.refNum);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSClose dans CloseFile :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  with fic.bufferLecture do
    begin
      if (bufferLecture <> NIL) then DisposeMemoryPtr(Ptr(bufferLecture));
      debutDuBuffer       := 0;
      positionDansBuffer  := 0;
      tailleDuFichier     := -1;
      tailleDuBuffer      := -1;
      positionTeteFichier := 0;
      doitUtiliserBuffer  := false;
    end;

  if err = NoErr then
      begin
        dec(fic.dataForkCorrectlyOpen);
        if (fic.dataForkCorrectlyOpen <> -1) then
          begin
            SysBeep(0);
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une fermeture correcte du data fork d''un fichier, dataForkCorrectlyOpen <> -1 !');
            DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
            DisplayMessageWithNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
            DisplayMessageInConsole('');
          end;
      end;

  CloseFile := err;
end;


function DeleteFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      DeleteFile := NoErr;
      exit;
    end;


  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' entree dans DeleteFile :');
      DisplayMessageInConsole('     appel de OpenFile/CloseFile :');
    end;

  if not(FileIsOpen(fic)) then
    err := OpenFile(fic);

  err := CloseFile(fic);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres OpenFile/CloseFile dans DeleteFile :');
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;


  err := -1;
  (*
  with fic do  {on essaie avec les anciennes routines}
    err := FSDelete(nomFichier,vRefNum);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSDelete dans DeleteFile :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;
  *)

  if err <> NoErr then  {on essaie avec les routines du systeme 7 et le fileInfo}
    with fic do
      begin
        err := FSpDelete(info);

        if debugBasicFiles then
			    begin
			      DisplayMessageInConsole('');
            DisplayMessageInConsole(' apres FSpDelete dans DeleteFile :');
            DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
            DisplayMessageWithNumInConsole('   ==> Err = ',err);
			    end;
      end;

  DeleteFile := err;
end;


function FileIsOpen(var fic : basicfile) : boolean;
begin

  if FileIsStandardOutput(fic) then
    begin
      FileIsOpen := true;
      exit;
    end;

  FileIsOpen := (fic.dataForkCorrectlyOpen = 0);
end;

function GetUniqueID(var fic : basicfile) : SInt32;
begin
  GetUniqueID := fic.uniqueID;
end;

function GetFileSize(var fic : basicfile; var taille : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      taille := GetTailleRapport;
      GetFileSize := NoErr;
      exit;
    end;

  err := GetEOF(fic.refNum,taille);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetEOF dans GetFileSize :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('taille = ',taille);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  GetFileSize := err;
end;


function SetFilePosition(var fic : basicfile; position : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      SetDebutSelectionRapport(position);
      SetFinSelectionRapport(position);
      SetFilePosition := NoErr;
      exit;
    end;

  err := SetFPos(fic.refNum,fsFromStart,position);

  if fic.bufferLecture.doitUtiliserBuffer then
    with fic.bufferLecture do
      begin
        if (position >= debutDuBuffer) and
           (position < debutDuBuffer + tailleDuBuffer)
          then positionDansBuffer := (position - debutDuBuffer);
      end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetFPos dans SetFilePosition :');
      DisplayMessageWithNumInConsole(' pos = ',position);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;


  SetFilePosition := err;
end;

function SetFilePositionAtEnd(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      FinRapport;
      SetFilePositionAtEnd := NoErr;
      exit;
    end;

  err := SetFPos(fic.refNum,fsFromLEOF,0);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetFPos dans SetFilePositionAtEnd :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  SetFilePositionAtEnd := err;
end;


function GetFilePosition(var fic : basicfile; var position : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      position := GetDebutSelectionRapport;
      GetFilePosition := NoErr;
      exit;
    end;

  err := GetFPos(fic.refNum,position);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetFPos dans GetFilePosition :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  GetFilePosition := err;
end;


function EndOfFile(var fic : basicfile; var erreurES : OSErr) : boolean;
var position,logicalEOF : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      position := GetDebutSelectionRapport;
      EndOfFile := (position >= GetTailleRapport);
      exit;
    end;


  EndOfFile := true;

  erreurES := GetFPos(fic.refNum,position);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetFPos dans EndOfFile :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('position = ',position);
      DisplayMessageWithNumInConsole('   ==> Err = ',erreurES);
    end;

  if erreurES <> NoErr then exit;
  erreurES := GetEOF(fic.refNum,logicalEOF);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetEOF dans EndOfFile :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('logicalEOF = ',logicalEOF);
      DisplayMessageWithNumInConsole('   ==> Err = ',erreurES);
    end;

  if erreurES <> NoErr then exit;
  EndOfFile := ( position >= logicalEOF);
end;

function SetEndOfFile(var fic : basicfile; posEOF : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      SetEndOfFile := NoErr;
      exit;
    end;

  err := SetEOF(fic.refNum,posEOF);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetEOF dans SetEndOfFile :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  SetEndOfFile := err;
end;


function ClearFileContent(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      DetruireTexteDansRapport(0,2000000000,true);  {2000000000 was MawLongint}
      ClearFileContent := NoErr;
      exit;
    end;

  err := SetEndOfFile(fic,0);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetEndOfFile dans ClearFileContent :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  ClearFileContent := err;
end;



function Write(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      InsereTexteDansRapport(buffPtr,count);
      Write := NoErr;
      exit;
    end;

  err := FSWrite(fic.refNum,count,buffPtr);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans Write :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Write := err;
end;


function Write(var fic : basicfile; const s : HugeString) : OSErr;
var err : OSErr;
    count : SInt32;
    buffer : CharArrayPtr;
begin

  if FileIsStandardOutput(fic) then
    begin
      WriteHugeStringDansRapport(s);
      Write := NoErr;
      exit;
    end;

  err := -1;

  if HugeStringIsUsable(s) then
    begin
      count   := LengthOfHugeString(s);
      buffer  := GetBufferOfHugeString(s);

      err     := Write(fic, @buffer^[1], count);
    end;

  Write := err;
end;


function Writeln(var fic : basicfile; const s : HugeString) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      WritelnHugeStringDansRapport(s);
      Writeln := NoErr;
      exit;
    end;

  err := Write(fic, s);

  if (err = NoErr) then
    err := Writeln(fic, '');

  Writeln := err;
end;



function Write(var fic : basicfile; s : String255) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      WriteDansRapport(s);
      Write := NoErr;
      exit;
    end;

  err := MyFSWriteString(fic.refNum,s);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans Write :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Write := err;
end;


function Writeln(var fic : basicfile; s : String255) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      WritelnDansRapport(s);
      Writeln := NoErr;
      exit;
    end;

  err := MyFSWriteString(fic.refnum,s + chr(13));

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans Writeln( :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Writeln := err;
end;


function Write(var fic : basicfile; ficAbstrait : FichierAbstrait; fromPos : SInt32; var count : SInt32) : OSErr;
var err : OSErr;
    buffer : Ptr;
begin
  err := -1;

  if (count <= 0) then
    exit;

  buffer := AllocateMemoryPtr(count + 100);
  if (buffer <> NIL) then
    begin
      err := ReadFromFichierAbstrait(ficAbstrait, fromPos , count, buffer);
      if err = NoErr then
        err := Write(fic, buffer, count);
      DisposeMemoryPtr(buffer);
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans Write :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Write := err;
end;



function Writeln(var fic : basicfile; value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      InsereTexteDansRapport(@value,4);
      Writeln := NoErr;
      exit;
    end;

  count := 4;
  err := FSWrite(fic.refNum,count,@value);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans Writeln :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Writeln := err;
end;

function Read(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      Read := -1;
      exit;
    end;

  err := FSRead(fic.refNum,count,buffPtr);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans Read :');
      DisplayMessageWithNumInConsole('count = ',count);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Read := err;
end;


function Read(var fic : basicfile; nbOctets : SInt16; var s : String255) : OSErr;
var len : SInt32;
    err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      Read := -1;
      exit;
    end;

  len := nbOctets;
  if len > 255 then len := 255;
  if len < 0 then len := 0;

  err := FSRead(fic.refnum,len,@s[1]);
  SET_LENGTH_OF_STRING(s,len);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans Read :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Read := err;
end;



function MyFSBufferedReadPourReadln(var fic : basicfile; var length : SInt32; buffer : Ptr) : OSErr;
const SIZE_OF_BUFFER = 1024 * 34;
var luDansLeBuffer : boolean;
    resultBuffer : PackedArrayOfCharPtr;
    k, nbOctetsLusSurLeDisque : SInt32;
    err : OSErr;
    debug : boolean;
label Bail;
begin

 // debug := (Pos('rence',fic.nomFichier) > 0);
  debug := false;

  luDansLeBuffer := false;


  with fic.bufferLecture do
    if doitUtiliserBuffer then
      begin

        if (bufferLecture = NIL) then
          begin
            if debug then WritelnDansRapport('FIX ME : allocation du buffer de lecture');
            bufferLecture := PackedArrayOfCharPtr(AllocateMemoryPtr(SIZE_OF_BUFFER));
            if (bufferLecture = NIL) then
              begin
                doitUtiliserBuffer := false;
                goto Bail;
              end;
          end;

        if (tailleDuFichier < 0) then
          begin
            if (GetFileSize(fic,tailleDuFichier) <> NoErr) then
              begin
                tailleDuFichier := -1;
                doitUtiliserBuffer := false;
                if debug then WritelnNumDansRapport('FIX ME : erreur dans le calcul de la taille du fichier : ',tailleDuFichier);
                goto Bail;
              end;
            if debug then WritelnNumDansRapport('FIX ME : calcul de la taille du fichier : ',tailleDuFichier);
          end;


        if (tailleDuFichier > 0) and
           (length > tailleDuFichier - (debutDuBuffer + positionDansBuffer)) and
           ((positionDansBuffer + length) > tailleDuBuffer)
           then length := tailleDuFichier - (debutDuBuffer + positionDansBuffer);


        if ((positionDansBuffer + length) > tailleDuBuffer) then
          begin
            nbOctetsLusSurLeDisque := SIZE_OF_BUFFER;

            err := GetFilePosition(fic, debutDuBuffer);

            if debug then WritelnNumDansRapport('FIX ME : apres GetFilePosition, err = ',err);

            if (err = NoErr) then
              err := FSRead(fic.refnum, nbOctetsLusSurLeDisque, bufferLecture);

            if (err = NoErr) and (nbOctetsLusSurLeDisque > 0)
              then
                begin
                  tailleDuBuffer     := nbOctetsLusSurLeDisque;
                  positionDansBuffer := 0;
                  if debug then WritelnNumDansRapport('FIX ME : lecture dans le fichier : ',tailleDuBuffer);
                end
              else
                begin
                  if debug then WritelnNumDansRapport('FIX ME : erreur de lecture dans le fichier, err = ',err);
                  if debug then WritelnNumDansRapport('FIX ME : nbOctetsLusSurLeDisque = ',nbOctetsLusSurLeDisque);

                  if (err = eofErr) and (nbOctetsLusSurLeDisque > 0)  {-39 is eofErr, end of file error}
                    then
                      begin
                        tailleDuBuffer     := nbOctetsLusSurLeDisque;
                        positionDansBuffer := 0;
                        err := SetFilePosition(fic, debutDuBuffer);
                      end
                    else
                      begin
                        doitUtiliserBuffer := false;
                        err := SetFilePosition(fic, debutDuBuffer);
                        goto Bail;
                      end;
                end;

          end;

        if ((positionDansBuffer + length) <= tailleDuBuffer) then
          begin
            resultBuffer := PackedArrayOfCharPtr(buffer);

            for k := 0 to length - 1 do
              resultBuffer^[k] := bufferLecture^[positionDansBuffer + k];

            positionDansBuffer := positionDansBuffer + length;

            luDansLeBuffer := true;
            MyFSBufferedReadPourReadln := NoErr;

            // if debug then WritelnNumDansRapport('FIX ME : OK, positionDansBuffer = ',positionDansBuffer);
          end;

      end;

Bail :

  if not(luDansLeBuffer) then
    begin
      if debug then WritelnNumDansRapport('avant, length = ',length);

      err := FSRead(fic.refnum,length,buffer);
      MyFSBufferedReadPourReadln := err;

      if debug then WritelnNumDansRapport('apres, length = ',length);
      if debug then WritelnNumDansRapport('apres, err = ',err);
    end;
end;


function Readln(var fic : basicfile; var s : String255) : OSErr;
var err : OSErr;
    i,len,longueurLigne : SInt32;
    positionTeteDeLecture : SInt32;
    buffer : packed array[0..300] of char;
begin
  s := '';

  if FileIsStandardOutput(fic) then
    begin
      Readln := -1;
      exit;
    end;

  err := GetFilePosition(fic,positionTeteDeLecture);

  {on essaie de lire 258 caracteres du fichier pour les mettre dans notre buffer}
  len := 258;
  err := MyFSBufferedReadPourReadln(fic, len, @buffer[1]);
  //err := FSRead(fic.refnum, len, @buffer[1]);
  for i := len + 1 to 258 do buffer[i] := chr(0);

  {on cherche le premier retour charriot dans le buffer}
  len := Min(256,len);
  longueurLigne := Min(255,len);
  gEndOfLineFoundInReadln := false;
  for i := len downto 1 do
    if (buffer[i] = cr) or (buffer[i] = lf) then
      begin
        longueurLigne := i-1;
        gEndOfLineFoundInReadln := true;
      end;

  {on ajuste en consequence la longueur de s, et on recopie la chaine}
  for i := 1 to longueurLigne do s[i] := buffer[i];
  for i := longueurLigne + 1 to 255 do s[i] := chr(0);
  SET_LENGTH_OF_STRING(s,longueurLigne);

  {on gere les retours charriots DOS, UNIX, Mac, etc}
  if gEndOfLineFoundInReadln then
    begin
      if ((buffer[longueurLigne+1] = cr) and (buffer[longueurLigne+2] = lf)) or
         ((buffer[longueurLigne+1] = lf) and (buffer[longueurLigne+2] = cr))
         then inc(longueurLigne);
    end;

  {on deplace la tete de lecture}
  if gEndOfLineFoundInReadln
    then positionTeteDeLecture := 1 + positionTeteDeLecture + longueurLigne
    else positionTeteDeLecture :=     positionTeteDeLecture + longueurLigne;
  err := SetFilePosition(fic,positionTeteDeLecture);

  {
  WriteStringAndBoolDansRapport(s+' ',gEndOfLineFoundInReadln);
  WritelnNumDansRapport(' ==>  err = ',err);
  }

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans Readln :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Readln := err;
end;



function Readln(var fic : basicfile; var s : LongString) : OSErr;
var longueur : SInt32;
    err : OSErr;
begin
  with s do
    begin
      debutLigne := '';
      finLigne   := '';
      complete   := true;

      err := Readln(fic, debutLigne);

      if (err = NoErr) then
        begin
          longueur := LENGTH_OF_STRING(debutLigne);
          if (longueur < 255) or
             ((longueur = 255) and gEndOfLineFoundInReadln)
            then
              begin
                Readln := err;
                exit;
              end
            else
              begin
                err := Readln(fic, finLigne);
                complete := gEndOfLineFoundInReadln;
              end;
        end;

      Readln := err;
    end;
end;



 (*
 *******************************************************************************
 *                                                                             *
 *   Readln()  : lit un fichier jusqu'au premier     *
 *   retour chariot et met le resultat dans une HugeString. Cette fonction     *
 *   n'alloue pas la HugeString, elle doit avoir ete creee auparavant par un   *
 *   appel a NewHugeString() ou MakeHugeString().                              *
 *                                                                             *
 *******************************************************************************
 *)
function Readln(var fic : basicfile; var s : HugeString) : OSErr;
var buffer : CharArrayPtr;
    err : OSErr;
    count : SInt32;
begin

  err := -1;

  if HugeStringIsUsable(s) then
    begin
      count  := GetMaximumCapacityOfHugeString;
      buffer := GetBufferOfHugeString(s);

      err    := Readln(fic, @buffer^[1], count);

      if (err = NoErr)
        then SetLengthOfHugeString(s, count);

    end;

  Readln := err;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   Readln()  : lit un fichier jusqu'au premier retour  *
 *   chariot et met le resultat dans buffer. Cette fonction n'alloue pas le    *
 *   buffer, il doit avoir ete cree a la bonne taille auparavant.              *
 *      -> En entree, count est la taille du buffer                            *
 *      -> En sortie, count contient le nombre de caracteres jusqu'au premier  *
 *                    retour chariot, si on en a trouve un...                  *
 *                                                                             *
 *******************************************************************************
 *)
function Readln(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
    i,len,longueurLigne : SInt32;
    positionTeteDeLecture : SInt32;
    localBuffer : PackedArrayOfCharPtr;
begin

  if FileIsStandardOutput(fic) then
    begin
      Readln := -1;
      exit;
    end;

  err := GetFilePosition(fic,positionTeteDeLecture);

  {on essaie de lire count caracteres dans buffPtr}
  len := count;
  err := FSRead(fic.refnum,count,buffPtr);
  localBuffer := PackedArrayOfCharPtr(buffPtr);

  {on cherche le premier retour charriot dans buffPtr}
  longueurLigne := Min(len,count);
  gEndOfLineFoundInReadln := false;
  for i := count-1 downto 0 do
    if (localBuffer^[i] = cr) or (localBuffer^[i] = lf) then
      begin
        longueurLigne := i;
        count := i;
        gEndOfLineFoundInReadln := true;
      end;


  {on deplace la tete de lecture}
  if gEndOfLineFoundInReadln
    then positionTeteDeLecture := 1 + positionTeteDeLecture + longueurLigne
    else positionTeteDeLecture :=     positionTeteDeLecture + longueurLigne;
  err := SetFilePosition(fic,positionTeteDeLecture);

  {
  WriteStringAndBoolDansRapport(s+' ',gEndOfLineFoundInReadln);
  WritelnNumDansRapport(' ==>  err = ',err);
  }

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans Readln :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Readln := err;
end;


function Read(var fic : basicfile; var value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      Read := -1;
      exit;
    end;

  count := 4;
  err := FSRead(fic.refNum,count,@value);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans Read :');
      DisplayMessageWithNumInConsole('count = ',count);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Read := err;
end;


procedure ForEachLineInFileDo(whichFile : fileInfo; DoWhat : LineOfFileProc; var result : SInt32);
var theFic : basicfile;
    erreurES : OSErr;
    ligne : LongString;
begin
  erreurES := FileExists(whichFile,theFic);
  if (erreurES <> NoErr) then exit;

  erreurES := OpenFile(theFic);
  if (erreurES <> NoErr) then exit;

  with ligne do
    begin
      debutLigne := '';
      finLigne   := '';
      complete   := true;
    end;

  while not(EndOfFile(theFic,erreurES)) do
    begin

      erreurES := Readln(theFic,ligne);

      DoWhat(ligne,theFic,result);
    end;

  erreurES := CloseFile(theFic);
end;



function InsertFileInFile(var fic : basicfile; pathFichierAInserer : String255) : OSErr;
var insertion : basicfile;
    err,err2 : OSErr;
begin
  err := FileExists(pathFichierAInserer,0,insertion);
  if err = NoErr then
    begin
      err := OpenFile(insertion);
      err := InsertFileInFile(insertion,fic);
      err2 := CloseFile(insertion);
    end;

  InsertFileInFile := err;
end;


function InsertFileInFile(var insere,receptacle : basicfile) : OSErr;
const kTailleBufferCopie = 10000;
var err,err2 : OSErr;
    fichierInsereOuvert : boolean;
    fichierReceptacleOuvert : boolean;
    buffer : packed array[0.. (kTailleBufferCopie-1) ] of char;
    longueurInsertion : SInt32;
    count,nbOctetsCopies : SInt32;
begin

  err := NoErr;
  err2 := NoErr;

  fichierInsereOuvert := FileIsOpen(insere);
  if not(fichierInsereOuvert) then err := OpenFile(insere);
  err := SetFilePosition(insere,0);

  fichierReceptacleOuvert := FileIsOpen(receptacle);
  if not(fichierReceptacleOuvert) then
    begin  {ouvrir le fichier et placer le curseur à la fin}
      err2 := OpenFile(receptacle);
      err2 := SetFilePositionAtEnd(receptacle);
    end;

  if (err = NoErr) and (err2 = NoErr) then
    begin
      err := GetFileSize(insere,longueurInsertion);

      nbOctetsCopies := 0;

      repeat
        count := Min(kTailleBufferCopie, longueurInsertion-nbOctetsCopies);
        err  := Read(insere,@buffer[0],count);
        err2 := Write(receptacle,@buffer[0],count);
        nbOctetsCopies := nbOctetsCopies + count;
      until (err <> NoErr) or (err2 <> NoErr) or (nbOctetsCopies >= longueurInsertion);

    end;

  if not(fichierInsereOuvert)     then err  := CloseFile(insere);
  if not(fichierReceptacleOuvert) then err2 := CloseFile(receptacle);

  if (err <> NoErr)
    then InsertFileInFile := err
    else InsertFileInFile := err2;

end;

function CreerRessourceFork(var fic : basicfile) : OSErr;
var err : OSErr;
    creator,fileType: OSType;
begin

  creator := GetFileCreatorFichierTexte(fic);
  fileType := GetFileTypeFichierTexte(fic);

  FSpCreateResFile(fic.info,creator,fileType,smSystemScript);
  err := ResError;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreateResFile dans CreerRessourceFork :');
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  CreerRessourceFork := err;
end;


function OuvreRessourceFork(var fic : basicfile) : OSErr;
var nroRef : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      OuvreRessourceFork := -1;
      exit;
    end;

  if fic.rsrcForkCorrectlyOpen <> -1 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le ressource Fork d''un fichier dont fic.rsrcForkCorrectlyOpen <> -1 !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('GetName(fic.info) = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
      DisplayMessageInConsole('');
      OuvreRessourceFork := -1;
      exit;
    end;

  nroRef := FSpOpenResFile(fic.info,4);
  if nroRef = -1
    then OuvreRessourceFork := -1  {Error !}
    else
      begin
        fic.ressourceForkRefNum := nroRef;
        OuvreRessourceFork := NoErr;

        inc(fic.rsrcForkCorrectlyOpen);
        if (fic.rsrcForkCorrectlyOpen <> 0) then
          begin
            SysBeep(0);
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une ouverture correcte du ressource fork d''un fichier, rsrcForkCorrectlyOpen <> 0 !');
            DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
            DisplayMessageWithNumInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
            DisplayMessageInConsole('');
          end;
      end;
end;


function UseRessourceFork(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      UseRessourceFork := -1;
      exit;
    end;

  if fic.rsrcForkCorrectlyOpen <> 0 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut utiliser le ressource Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('GetName(fic.info) = '+GetName(fic.info));
      DisplayMessageWithNumInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
      DisplayMessageInConsole('');
      UseRessourceFork := -1;
      exit;
    end;

  UseResFile(fic.ressourceForkRefNum);
  err := ResError;
  {DisplayMessageWithNumInConsole('err = ',err);}

  UseRessourceFork := err;
end;

function FermeRessourceFork(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      FermeRessourceFork := -1;
      exit;
    end;

  if fic.rsrcForkCorrectlyOpen <> 0 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le ressource Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
      DisplayMessageInConsole('');
      FermeRessourceFork := -1;
      exit;
    end;

  if fic.ressourceForkRefNum <> 0
    then
      begin
        CloseResFile(fic.ressourceForkRefNum);
        err := ResError;
        {DisplayMessageWithNumInConsole('err = ',err);}

        FermeRessourceFork := err;

        if err = NoErr then
          begin
            dec(fic.rsrcForkCorrectlyOpen);
            if (fic.rsrcForkCorrectlyOpen <> -1) then
              begin
                SysBeep(0);
                DisplayMessageInConsole('');
                DisplayMessageInConsole('## WARNING : après une fermeture correcte du ressource fork d''un fichier, rsrcForkCorrectlyOpen <> -1 !');
                DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
                DisplayMessageWithNumInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
                DisplayMessageInConsole('');
              end;
          end;
      end
    else
      FermeRessourceFork := -1;  {erreur, on a failli fermer le fichier systeme !}
end;


function FichierTexteDeCassioExiste(nom : String255; var fic : basicfile) : OSErr;
const tailleMaxNom = 31;
var err : OSErr;
    len,posLastDeuxPoints : SInt16;
    erreurEstFicNonTrouve : boolean;
begin

  err := -2;
  erreurEstFicNonTrouve := false;


  if err <> NoErr then
    begin
      err := FileExists(nom,0,fic);
      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
    end;

  posLastDeuxPoints := LastPos(':',nom);
  nom := TPCopy(nom, posLastDeuxPoints+1, 255);

  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
		  if err <> NoErr then
		    begin
		      err := FileExists(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  nom := nom+' ';
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
		  if (err <> NoErr) then
		    begin
		      err := FileExists(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  nom := nom+'(alias)';
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
		  if (err <> NoErr) then
		    begin
		      err := FileExists(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  if (err <> 0) and erreurEstFicNonTrouve
    then FichierTexteDeCassioExiste := fnfErr
    else FichierTexteDeCassioExiste := err;
end;


function CreeFichierTexteDeCassio(nom : String255; var fic : basicfile) : OSErr;
const tailleMaxNom = 31;
var err : OSErr;
    len,posLastDeuxPoints : SInt16;
begin
  err := -1;
  posLastDeuxPoints := LastPos(':',nom);
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      err := CreateFile(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  nom := nom+' (1)';
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      if (err <> NoErr)
        then err := CreateFile(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  nom := nom+'(2)';
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      if (err <> NoErr)
        then err := CreateFile(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  CreeFichierTexteDeCassio := err;
end;

procedure SimpleAlertForFile(nomFichier : String255; erreurES : SInt32);
CONST TextesErreursID       = 10016;
var s,texte,explication,pathFichier : String255;
begin
  s := ReadStringFromRessource(TextesErreursID, 5);  {'erreur I/O sur fichier «^0» ! code erreur =  ^1'}

  pathFichier := nomFichier;
  if (Pos(':',pathFichier) > 0)
    then
      begin
        nomFichier := ExtractFileOrDirectoryName(pathFichier);

        pathFichier := ReplaceStringAll(pathFichier, ':' , '/');

        s := ReplaceParameters(s,nomFichier,IntToStr(erreurES) + chr(13)+'  path = '+pathFichier,'','');
      end
    else
      begin
        s := ReplaceParameters(s,nomFichier,IntToStr(erreurES),'','');
      end;

  Split(s,'!',texte,explication);
  AlerteDouble(texte+'!',explication);
end;



procedure SetFileCreatorFichierTexte(var fic : basicfile; quelType : OSType);
var InfosFinder : FInfo;
    err : OSErr;
begin
  if FileIsStandardOutput(fic)
    then exit;

  err := FSpGetFInfo(fic.info,InfosFinder);
  InfosFinder.fdCreator := QuelType;
  err := FSpSetFInfo(fic.info,InfosFinder);
end;


procedure SetFileTypeFichierTexte(var fic : basicfile; quelType : OSType);
var InfosFinder : FInfo;
    err : OSErr;
begin
  if FileIsStandardOutput(fic)
    then exit;

  err := FSpGetFInfo(fic.info,InfosFinder);
  InfosFinder.fdType := QuelType;
  err := FSpSetFInfo(fic.info,InfosFinder);
end;


function GetFileCreatorFichierTexte(var fic : basicfile) : OSType;
var InfosFinder : FInfo;
    err : OSErr;
begin
  GetFileCreatorFichierTexte := FOUR_CHAR_CODE('????');

  if FileIsStandardOutput(fic) then
    begin
      GetFileCreatorFichierTexte := NoErr;
      exit;
    end;

  err := FSpGetFInfo(fic.info,InfosFinder);
  GetFileCreatorFichierTexte := InfosFinder.fdCreator;
end;


function GetFileTypeFichierTexte(var fic : basicfile) : OSType;
var InfosFinder : FInfo;
    err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      GetFileTypeFichierTexte := NoErr;
      exit;
    end;

  GetFileTypeFichierTexte := FOUR_CHAR_CODE('????');
  err := FSpGetFInfo(fic.info,InfosFinder);
  GetFileTypeFichierTexte := InfosFinder.fdType;
end;

{kFSCatInfoCreateDate = 0x00000020,
   kFSCatInfoContentMod = 0x00000040
   }

function GetCreationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
var err : OSErr;
    fileRef : FSRef;
    catalogInfo : FSCatalogInfo;
begin
  if FileIsStandardOutput(fic) then
    begin
      GetCreationDate := -1;
      exit;
    end;

  err := FSpMakeFSRef(fic.info,fileRef);

  if err = NoErr then
    begin
      err := FSGetCatalogInfo(fileRef,kFSCatInfoCreateDate,@catalogInfo,NIL,NIL,NIL);
      if (err = NoErr) then SecondsToDate(catalogInfo.createDate.lowSeconds,theDate);
    end;

  GetCreationDate := err;
end;


function SetCreationDate(var fic : basicfile; const theDate : DateTimeRec) : OSErr;
var err : OSErr;
    {fileRef : FSRef;
    catalogInfo : FSCatalogInfo;}
begin {$UNUSED theDate}
  if FileIsStandardOutput(fic) then
    begin
      SetCreationDate := -1;
      exit;
    end;

  err := -1;

  SetCreationDate := err;
end;


function GetModificationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
var err : OSErr;
    fileRef : FSRef;
    catalogInfo : FSCatalogInfo;
begin
  if FileIsStandardOutput(fic) then
    begin
      GetModificationDate := -1;
      exit;
    end;

  err := FSpMakeFSRef(fic.info,fileRef);

  if err = NoErr then
    begin
      err := FSGetCatalogInfo(fileRef,kFSCatInfoContentMod,@catalogInfo,NIL,NIL,NIL);
      if (err = NoErr) then SecondsToDate(catalogInfo.contentModDate.lowSeconds,theDate);
    end;

  GetModificationDate := err;
end;


function SetModificationDate(var fic : basicfile; const theDate : DateTimeRec) : OSErr;
var err : OSErr;
begin {$UNUSED theDate}
  if FileIsStandardOutput(fic) then
    begin
      SetModificationDate := -1;
      exit;
    end;

  err := -1;

  SetModificationDate := err;
end;


procedure InstallMessageDisplayerBasicFile(theProc : MessageDisplayerProc);
begin
  CustomDisplayMessage := theProc;
  useStandardConsole := false;
end;

procedure InstallMessageAndNumDisplayerBasicFile(theProc : MessageAndNumDisplayerProc);
begin
  CustomDisplayMessageWithNum := theProc;
  useStandardConsole := false;
end;

procedure InstallAlertBasicFile(theProc : MessageAndNumDisplayerProc);
begin
  CustomDisplayAlerteWithNum := theProc;
  useStandardConsole := false;
end;

procedure InitUnitBasicFile;
begin
  SetDebugFiles(false);

  (* installation des procedure pour l'affichage de message :
     sur la sortie standard par defaut. On peut installer des
     routines personalisees d'impression de messages et d'alerte
     juste apres l'appel a InitUnitBasicFile *)
  InstallMessageDisplayerBasicFile(StandardConsoleDisplayer);
  InstallMessageAndNumDisplayerBasicFile(StandardConsoleDisplayerWithNum);
  InstallAlertBasicFile(StandardConsoleAlertWithNum);
  useStandardConsole := true;

  nameOfStandardOutputForRapport := 'Rapport-stdErr-fake-Cassio';

  unit_initialized := true;
end;


function CreateStandardOutputAsFile(var fic : basicfile) : OSErr;
begin
  if not(unit_initialized) then InitUnitBasicFile;
  CreateStandardOutputAsFile := CreateFile(nameOfStandardOutputForRapport,0,fic);
end;


procedure SetDebugFiles(flag : boolean);
begin
  debugBasicFiles := flag;
end;

function GetDebugFiles : boolean;
begin
  GetDebugFiles := debugBasicFiles;
end;


end.
