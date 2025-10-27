UNIT UnitFichiersTEXT;



INTERFACE







 USES UnitDefCassio , Files , DateTimeUtils, UnitDefHugeString;







function FichierTexteExiste(nom : String255 ; vRefNum : SInt16; var fic : FichierTEXT) : OSErr;
function FichierTexteExisteFSp(mySpec : FSSpec; var fic : FichierTEXT) : OSErr;
function CreeFichierTexte(nom : String255 ; vRefNum : SInt16; var fic : FichierTEXT) : OSErr;
function CreeFichierTexteFSp(mySpec : FSSpec; var fic : FichierTEXT) : OSErr;



function FichierTexteDeCassioExiste(nom : String255; var fic : FichierTEXT) : OSErr;
function CreeFichierTexteDeCassio(nom : String255; var fic : FichierTEXT) : OSErr;


function OuvreFichierTexte(var fic : FichierTEXT) : OSErr;
function FermeFichierTexte(var fic : FichierTEXT) : OSErr;
function DetruitFichierTexte(var fic : FichierTEXT) : OSErr;
function FichierTexteEstOuvert(var fic : FichierTEXT) : boolean;
function GetUniqueIDFichierTexte(var fic : FichierTEXT) : SInt32;
function GetTailleFichierTexte(var fic : FichierTEXT; var taille : SInt32) : OSErr;
function SetPositionTeteLectureFichierTexte(var fic : FichierTEXT; position : SInt32) : OSErr;
function SetPositionTeteLectureFinFichierTexte(var fic : FichierTEXT) : OSErr;
function GetPositionTeteLectureFichierTexte(var fic : FichierTEXT; var position : SInt32) : OSErr;
function EOFFichierTexte(var fic : FichierTEXT; var erreurES : OSErr) : boolean;
function SetEOFFichierTexte(var fic : FichierTEXT; posEOF : SInt32) : OSErr;
function VideFichierTexte(var fic : FichierTEXT) : OSErr;


function WriteDansFichierTexte(var fic : FichierTEXT; s : String255) : OSErr;
function WritelnDansFichierTexte(var fic : FichierTEXT; s : String255) : OSErr;
function WriteBufferDansFichierTexte(var fic : FichierTEXT; buffPtr : Ptr; var count : SInt32) : OSErr;
function WriteFichierAbstraitDansFichierTexte(var fic : FichierTEXT; ficAbstrait : FichierAbstrait; fromPos : SInt32; var count : SInt32) : OSErr;
function WriteLongintDansFichierTexte(var fic : FichierTEXT; value : SInt32) : OSErr;
function WriteHugeStringDansFichierTexte(var fic : FichierTEXT; const s : HugeString) : OSErr;
function WritelnHugeStringDansFichierTexte(var fic : FichierTEXT; const s : HugeString) : OSErr;



function ReadBufferDansFichierTexte(var fic : FichierTEXT; buffPtr : Ptr; var count : SInt32) : OSErr;
function ReadDansFichierTexte(var fic : FichierTEXT; nbOctets : SInt16; var s : String255) : OSErr;
function ReadlnDansFichierTexte(var fic : FichierTEXT; var s : String255) : OSErr;
function ReadlnLongStringDansFichierTexte(var fic : FichierTEXT; var s : LongString) : OSErr;
function ReadlnHugeStringDansFichierTexte(var fic : FichierTEXT; var s : HugeString) : OSErr;
function ReadlnBufferDansFichierTexte(var fic : FichierTEXT; buffPtr : Ptr; var count : SInt32) : OSErr;
function ReadLongintDansFichierTexte(var fic : FichierTEXT; var value : SInt32) : OSErr;


procedure ForEachLineInFileDo(whichFile : FSSpec ; DoWhat : LineOfFileProc; var result : SInt32);
function InsererFichierDansFichierTexte(var fic : FichierTEXT; pathFichierAInserer : String255) : OSErr;
function InsererFichierTexteDansFichierTexte(var insere,receptacle : FichierTEXT) : OSErr;


procedure SetFileCreatorFichierTexte(var fic : FichierTEXT; quelType : OSType);
procedure SetFileTypeFichierTexte(var fic : FichierTEXT; quelType : OSType);
function GetFileCreatorFichierTexte(var fic : FichierTEXT) : OSType;
function GetFileTypeFichierTexte(var fic : FichierTEXT) : OSType;


function GetCreationDateFichierTexte(var fic : FichierTEXT; var theDate : DateTimeRec) : OSErr;
function SetCreationDateFichierTexte(var fic : FichierTEXT; const theDate : DateTimeRec) : OSErr;
function GetModificationDateFichierTexte(var fic : FichierTEXT; var theDate : DateTimeRec) : OSErr;
function SetModificationDateFichierTexte(var fic : FichierTEXT; const theDate : DateTimeRec) : OSErr;


function CreerRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
function OuvreRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
function FermeRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
function UseRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;


procedure SetDebuggageUnitFichiersTexte(flag : boolean);
function  GetDebuggageUnitFichiersTexte : boolean;


function CreeSortieStandardEnFichierTexte(var fic : FichierTEXT) : OSErr;
function FSSpecToLongName(whichFile : FSSpec; var theLongName : String255) : OSErr;
function PathCompletToLongName(path : String255; var theLongName : String255) : OSErr;


procedure AlerteSimpleFichierTexte(nomFichier : String255; erreurES : SInt32);



  (* Installation des procedure pour l'affichage de message :     *)
  (* sur la sortie standard par defaut. On peut installer des     *)
  (* routines personalisees d'impression de messages et d'alerte  *)
  (* juste apres l'appel a InitUnitFichierTexte                   *)


procedure InitUnitFichierTexte;
procedure InstalleMessageDisplayerFichierTexte(theProc : MessageDisplayerProc);
procedure InstalleMessageAndNumDisplayerFichierTexte(theProc : MessageAndNumDisplayerProc);
procedure InstalleAlerteFichierTexte(theProc : MessageAndNumDisplayerProc);

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










const unit_initialisee : boolean = false;
      avecDebuggageUnitFichiersTexte : boolean = false;

var useStandardConsole : boolean;
    CustomDisplayMessage : MessageDisplayerProc;
    CustomDisplayMessageWithNum : MessageAndNumDisplayerProc;
    CustomDisplayAlerteWithNum : MessageAndNumDisplayerProc;
    nomSortieStandardDansRapport : String255;

    gRetourCharriotTrouveDansReadlnFichierTEXT : boolean;


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
  if unit_initialisee
    then CustomDisplayMessage(s)
    else StandardConsoleDisplayer(s);
end;

procedure DisplayMessageWithNumInConsole(s : String255; num : SInt32);
begin
  if unit_initialisee
    then CustomDisplayMessageWithNum(s,num)
    else StandardConsoleDisplayerWithNum(s,num);
end;

procedure DisplayAlerteWithNumInConsole(s : String255; num : SInt32);
begin
  if unit_initialisee
    then CustomDisplayAlerteWithNum(s,num)
    else StandardConsoleAlertWithNum(s,num)
end;



function ResolveAliasInFullName(var fullName : String255) : OSErr;
var debut,reste,resolvedDebut : String255;
    myFSSpec : FSSpec;
    err : OSErr;
    posDeuxPoints : SInt16;
begin
  debut := '';
  reste := fullName;
  err := 0;

  while (reste <> '') and (err = 0) do
    begin
      posDeuxPoints := Pos(':',reste);
      if posDeuxPoints > 0
        then
          begin
            debut := debut+TPCopy(reste,1,posDeuxPoints);
            reste := TPCopy(reste,posDeuxPoints+1,LENGTH_OF_STRING(reste)-posDeuxPoints);
          end
        else
          begin
            debut := debut+reste;
            reste := '';
          end;

      err := MyFSMakeFSSpec(0,0,debut,myFSSpec);
      MyResolveAliasFile(myFSSpec);
      resolvedDebut := debut;
      err := FSSpecToFullPath(myFSSpec,resolvedDebut);
      if err = 0 then
        begin
          if EndsWithDeuxPoints(debut) and not(EndsWithDeuxPoints(resolvedDebut))
            then debut := resolvedDebut+':'
            else debut := resolvedDebut;
        end;
    end;
  if err = 0 then fullName := debut;

  ResolveAliasInFullName := err;
end;


function FichierTexteEstLeRapport(var fic : FichierTEXT) : boolean;
begin
  FichierTexteEstLeRapport := (fic.vRefNum = 0) and
                              (fic.parID = 0) and
                              (fic.refNum = 0) and
                              (fic.nomFichier = nomSortieStandardDansRapport);
end;


procedure InitialiseFichierTexte(var nom : String255; var vRefNum : SInt16; var fic : FichierTEXT);
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
            if (nom[1] = ':') and EndsWithDeuxPoints(nomDirectory)
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
  SetNameOfFSSpec(fic.theFSSpec, '');
  with fic.theFSSpec do
    begin
      vRefNum := 0;
      parID := 0;
    end;
  fic.ressourceForkRefNum        := -1;
  fic.dataForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}

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


procedure InitialiseFichierTexteFSp(mySpec : FSSpec; var fic : FichierTEXT);
begin

  fic.nomFichier := GetNameOfFSSpec(mySpec);
  fic.vRefNum    := mySpec.vRefNum;
  fic.parID      := mySpec.parID;
  fic.refNum     := 0;
  fic.uniqueID   := 0;  {not yet initialised, we'll do it in CreateFFSpecAndResolveAlias}
  fic.theFSSpec  := mySpec;
  fic.ressourceForkRefNum        := -1;
  fic.dataForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}

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


function FSSpecToLongName(whichFile : FSSpec; var theLongName : String255) : OSErr;
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
  theLongName := GetNameOfFSSpec(whichFile);

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
  FSSpecToLongName := err;
end;


function PathCompletToLongName(path : String255; var theLongName : String255) : OSErr;
var err : OSErr;
    myFSSpec : FSSpec;
begin
   err := MyFSMakeFSSpec(0,0,path,myFSSpec);
   if err <> NoErr
     then PathCompletToLongName := err
     else PathCompletToLongName := FSSpecToLongName(myFSSpec,theLongName);
end;


function CreateFFSpecAndResolveAlias(var fic : FichierTEXT) : OSErr;
var err,bidLongint : OSErr;
    fullName : String255;
begin
  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' avant MyFSMakeFSSpec dans CreateFFSpecAndResolveAlias :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
    end;

  if FichierTexteEstLeRapport(fic) then
    begin
      CreateFFSpecAndResolveAlias := NoErr;
      exit(CreateFFSpecAndResolveAlias);
    end;

  with fic do
    begin
      err := MyFSMakeFSSpec(vRefNum,parID,nomFichier,theFSSpec);
      fullName := nomFichier;
      if (err = NoErr) then
        begin
          MyResolveAliasFile(theFSSpec);

          err := FSSpecToFullPath(theFSSpec,fullName);

        end else
      if (err = fnfErr) then {-43 : File Not Found, mais le FSSpec est valable}
        bidlongint := FSSpecToFullPath(theFSSpec,fullName);
      parID      := theFSSpec.parID;
      nomFichier := fullName;
      uniqueID   := HashString(fullName);

      {DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('LENGTH_OF_STRING(fic.fullName) = ',LENGTH_OF_STRING(fullName));
      DisplayMessageWithNumInConsole('hashing -> uniqueID = ',uniqueID);}
    end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSMakeFSSpec dans CreateFFSpecAndResolveAlias :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;
  CreateFFSpecAndResolveAlias := err;
end;


function FichierTexteExiste(nom : String255 ; vRefNum : SInt16; var fic : FichierTEXT) : OSErr;
var err1,err2 : OSErr;
    FinderInfos : FInfo;
begin

  if (nom = '') then
    begin
      DisplayMessageInConsole('WARNING ! (nom = '''') dans FichierTexteExiste');
      FichierTexteExiste := -1;
      exit(FichierTexteExiste);
    end;

  {TraceLog('FichierTexteExiste : nom =' + nom);}

  InitialiseFichierTexte(nom,vRefNum,fic);

  if FichierTexteEstLeRapport(fic) then
    begin
      FichierTexteExiste := NoErr;
      exit(FichierTexteExiste);
    end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres InitialiseFichierTexte dans FichierTexteExiste :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
    end;

  err2 := CreateFFSpecAndResolveAlias(fic);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans FichierTexteExiste :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err2 = ',err2);
    end;

  if (err2 <> NoErr)
    then
      FichierTexteExiste := err2
    else
      begin
			  err1 := FSpGetFInfo(fic.theFSSpec,FinderInfos);

			  if avecDebuggageUnitFichiersTexte then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpGetFInfo dans FichierTexteExiste :');
			      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
			      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
			      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
			      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
			      DisplayMessageWithNumInConsole('   ==> Err1 = ',err1);
			    end;

			  FichierTexteExiste := err1;
			end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' a la fin de FichierTexteExiste :');
      DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
    end;
end;


function FichierTexteExisteFSp(mySpec : FSSpec; var fic : FichierTEXT) : OSErr;
var err1,err2 : OSErr;
    FinderInfos : FInfo;
begin
  if (GetNameOfFSSpec(mySpec) = '') then
    begin
      DisplayMessageInConsole('WARNING ! (GetNameOfFSSpec(mySpec) = '''') dans FichierTexteExisteFSp');
      FichierTexteExisteFSp := -1;
      exit(FichierTexteExisteFSp);
    end;


  InitialiseFichierTexteFSp(mySpec, fic);

  if FichierTexteEstLeRapport(fic) then
    begin
      FichierTexteExisteFSp := NoErr;
      exit(FichierTexteExisteFSp);
    end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres InitialiseFichierTexte dans FichierTexteExisteFSp :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
    end;

  err2 := CreateFFSpecAndResolveAlias(fic);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans FichierTexteExisteFSp :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err2 = ',err2);
    end;

  if (err2 <> NoErr)
    then
      FichierTexteExisteFSp := err2
    else
      begin
			  err1 := FSpGetFInfo(fic.theFSSpec,FinderInfos);

			  if avecDebuggageUnitFichiersTexte then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpGetFInfo dans FichierTexteExiste :');
			      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
			      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
			      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
			      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
			      DisplayMessageWithNumInConsole('   ==> Err1 = ',err1);
			    end;

			  FichierTexteExisteFSp := err1;
			end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' a la fin de FichierTexteExiste :');
      DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
    end;
end;


function CreeFichierTexte(nom : String255 ; vRefNum : SInt16; var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin
  InitialiseFichierTexte(nom,vRefNum, fic);
  err := CreateFFSpecAndResolveAlias(fic);

  if FichierTexteEstLeRapport(fic) then
    begin
      CreeFichierTexte := NoErr;
      exit(CreeFichierTexte);
    end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans CreeFichierTexte :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  err := FSpCreate(fic.TheFSSpec,MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('TEXT'),0);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreate dans CreeFichierTexte :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  CreeFichierTexte := err;
end;

function CreeFichierTexteFSp(mySpec : FSSpec; var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin
  InitialiseFichierTexteFSp(mySpec, fic);
  err := CreateFFSpecAndResolveAlias(fic);

  if FichierTexteEstLeRapport(fic) then
    begin
      CreeFichierTexteFSp := NoErr;
      exit(CreeFichierTexteFSp);
    end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres CreateFFSpecAndResolveAlias dans CreeFichierTexteFSp :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  err := FSpCreate(fic.TheFSSpec,MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('TEXT'),0);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreate dans CreeFichierTexteFSp :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  CreeFichierTexteFSp := err;
end;




function OuvreFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      OuvreFichierTexte := NoErr;
      exit(OuvreFichierTexte);
    end;

  if fic.dataForkOuvertCorrectement <> -1 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le data Fork d''un fichier dont fic.dataForkOuvertCorrectement <> -1 !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('GetNameOfFSSpec(fic.theFSSpec) = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
      DisplayMessageInConsole('');
      OuvreFichierTexte := -1;
      exit(OuvreFichierTexte);
    end;

  err := -1;

(*
  with fic do  {on essaie l'ouverture avec les anciennes routines}
    err := FSOpen(nomFichier,vRefNum,refNum);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSOpen dans OuvreFichierTexte :');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;
*)

  if err <> NoErr then  {on essaie avec les routines du systeme 7 et le FSSpec}
    with fic do
      begin
        err := FSpOpenDF(theFSSpec,fsCurPerm,refNum);

        if avecDebuggageUnitFichiersTexte then
			    begin
			      DisplayMessageInConsole('');
			      DisplayMessageInConsole(' apres FSpOpenDF dans OuvreFichierTexte :');
			      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
			      DisplayMessageWithNumInConsole('fic.vRefNum = ',fic.vRefNum);
			      DisplayMessageWithNumInConsole('fic.parID = ',fic.parID);
			      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
			      DisplayMessageInConsole('FSSpec.name = '+GetNameOfFSSpec(fic.theFSSpec));
			      DisplayMessageWithNumInConsole('FSSpec.vRefNum = ',fic.theFSSpec.vRefNum);
			      DisplayMessageWithNumInConsole('FSSpec.parID = ',fic.theFSSpec.parID);
			      DisplayMessageWithNumInConsole('   ==> Err = ',err);
			    end;
      end;

  if err = NoErr then
    begin
      inc(fic.dataForkOuvertCorrectement);
      if fic.dataForkOuvertCorrectement <> 0 then
        begin
          SysBeep(0);
          DisplayMessageInConsole('');
          DisplayMessageInConsole('## WARNING : après une ouverture réussie, dataForkOuvertCorrectement <> 0 !');
          DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
          DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement',fic.dataForkOuvertCorrectement);
          DisplayMessageInConsole('');
        end;
    end;

  OuvreFichierTexte := err;
end;


function FermeFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      FermeFichierTexte := NoErr;
      exit(FermeFichierTexte);
    end;

  if fic.dataForkOuvertCorrectement <> 0 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le data Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('GetNameOfFSSpec(fic.theFSSpec) = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
      DisplayMessageInConsole('');
      FermeFichierTexte := -1;

      (* ForconsLePlantageDeCassio; *)

      exit(FermeFichierTexte);
    end;

  err := FSClose(fic.refNum);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSClose dans FermeFichierTexte :');
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
        dec(fic.dataForkOuvertCorrectement);
        if (fic.dataForkOuvertCorrectement <> -1) then
          begin
            SysBeep(0);
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une fermeture correcte du data fork d''un fichier, dataForkOuvertCorrectement <> -1 !');
            DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
            DisplayMessageWithNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
            DisplayMessageInConsole('');
          end;
      end;

  FermeFichierTexte := err;
end;


function DetruitFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      DetruitFichierTexte := NoErr;
      exit(DetruitFichierTexte);
    end;


  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' entree dans DetruitFichierTexte :');
      DisplayMessageInConsole('     appel de OuvreFichierTexte/FermeFichierTexte :');
    end;

  if not(FichierTexteEstOuvert(fic)) then
    err := OuvreFichierTexte(fic);

  err := FermeFichierTexte(fic);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres OuvreFichierTexte/FermeFichierTexte dans DetruitFichierTexte :');
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;


  err := -1;
  (*
  with fic do  {on essaie avec les anciennes routines}
    err := FSDelete(nomFichier,vRefNum);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSDelete dans DetruitFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;
  *)

  if err <> NoErr then  {on essaie avec les routines du systeme 7 et le FSSpec}
    with fic do
      begin
        err := FSpDelete(theFSSpec);

        if avecDebuggageUnitFichiersTexte then
			    begin
			      DisplayMessageInConsole('');
            DisplayMessageInConsole(' apres FSpDelete dans DetruitFichierTexte :');
            DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
            DisplayMessageWithNumInConsole('   ==> Err = ',err);
			    end;
      end;

  DetruitFichierTexte := err;
end;


function FichierTexteEstOuvert(var fic : FichierTEXT) : boolean;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      FichierTexteEstOuvert := true;
      exit(FichierTexteEstOuvert);
    end;

  FichierTexteEstOuvert := (fic.dataForkOuvertCorrectement = 0);
end;

function GetUniqueIDFichierTexte(var fic : FichierTEXT) : SInt32;
begin
  GetUniqueIDFichierTexte := fic.uniqueID;
end;

function GetTailleFichierTexte(var fic : FichierTEXT; var taille : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      taille := GetTailleRapport;
      GetTailleFichierTexte := NoErr;
      exit(GetTailleFichierTexte);
    end;

  err := GetEOF(fic.refNum,taille);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetEOF dans GetTailleFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('taille = ',taille);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  GetTailleFichierTexte := err;
end;


function SetPositionTeteLectureFichierTexte(var fic : FichierTEXT; position : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      SetDebutSelectionRapport(position);
      SetFinSelectionRapport(position);
      SetPositionTeteLectureFichierTexte := NoErr;
      exit(SetPositionTeteLectureFichierTexte);
    end;

  err := SetFPos(fic.refNum,fsFromStart,position);

  if fic.bufferLecture.doitUtiliserBuffer then
    with fic.bufferLecture do
      begin
        if (position >= debutDuBuffer) and
           (position < debutDuBuffer + tailleDuBuffer)
          then positionDansBuffer := (position - debutDuBuffer);
      end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetFPos dans SetPositionTeteLectureFichierTexte :');
      DisplayMessageWithNumInConsole(' pos = ',position);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;


  SetPositionTeteLectureFichierTexte := err;
end;

function SetPositionTeteLectureFinFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      FinRapport;
      SetPositionTeteLectureFinFichierTexte := NoErr;
      exit(SetPositionTeteLectureFinFichierTexte);
    end;

  err := SetFPos(fic.refNum,fsFromLEOF,0);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetFPos dans SetPositionTeteLectureFinFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  SetPositionTeteLectureFinFichierTexte := err;
end;


function GetPositionTeteLectureFichierTexte(var fic : FichierTEXT; var position : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      position := GetDebutSelectionRapport;
      GetPositionTeteLectureFichierTexte := NoErr;
      exit(GetPositionTeteLectureFichierTexte);
    end;

  err := GetFPos(fic.refNum,position);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetFPos dans GetPositionTeteLectureFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  GetPositionTeteLectureFichierTexte := err;
end;


function EOFFichierTexte(var fic : FichierTEXT; var erreurES : OSErr) : boolean;
var position,logicalEOF : SInt32;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      position := GetDebutSelectionRapport;
      EOFFichierTexte := (position >= GetTailleRapport);
      exit(EOFFichierTexte);
    end;


  EOFFichierTexte := true;

  erreurES := GetFPos(fic.refNum,position);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetFPos dans EOFFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('position = ',position);
      DisplayMessageWithNumInConsole('   ==> Err = ',erreurES);
    end;

  if erreurES <> NoErr then exit(EOFFichierTexte);
  erreurES := GetEOF(fic.refNum,logicalEOF);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetEOF dans EOFFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('logicalEOF = ',logicalEOF);
      DisplayMessageWithNumInConsole('   ==> Err = ',erreurES);
    end;

  if erreurES <> NoErr then exit(EOFFichierTexte);
  EOFFichierTexte := ( position >= logicalEOF);
end;

function SetEOFFichierTexte(var fic : FichierTEXT; posEOF : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      SetEOFFichierTexte := NoErr;
      exit(SetEOFFichierTexte);
    end;

  err := SetEOF(fic.refNum,posEOF);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetEOF dans SetEOFFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  SetEOFFichierTexte := err;
end;


function VideFichierTexte(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      DetruireTexteDansRapport(0,2000000000,true);  {2000000000 was MawLongint}
      VideFichierTexte := NoErr;
      exit(VideFichierTexte);
    end;

  err := SetEOFFichierTexte(fic,0);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetEOFFichierTexte dans VideFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  VideFichierTexte := err;
end;



function WriteBufferDansFichierTexte(var fic : FichierTEXT; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      InsereTexteDansRapport(buffPtr,count);
      WriteBufferDansFichierTexte := NoErr;
      exit(WriteBufferDansFichierTexte);
    end;

  err := FSWrite(fic.refNum,count,buffPtr);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans WriteBufferDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  WriteBufferDansFichierTexte := err;
end;


function WriteHugeStringDansFichierTexte(var fic : FichierTEXT; const s : HugeString) : OSErr;
var err : OSErr;
    count : SInt32;
    buffer : CharArrayPtr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      WriteHugeStringDansRapport(s);
      WriteHugeStringDansFichierTexte := NoErr;
      exit(WriteHugeStringDansFichierTexte);
    end;

  err := -1;

  if HugeStringIsUsable(s) then
    begin
      count   := LengthOfHugeString(s);
      buffer  := GetBufferOfHugeString(s);

      err     := MyFSWrite(fic.refNum, count, @buffer^[1]);
    end;

  WriteHugeStringDansFichierTexte := err;
end;


function WritelnHugeStringDansFichierTexte(var fic : FichierTEXT; const s : HugeString) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      WritelnHugeStringDansRapport(s);
      WritelnHugeStringDansFichierTexte := NoErr;
      exit(WritelnHugeStringDansFichierTexte);
    end;

  err := WriteHugeStringDansFichierTexte(fic, s);

  if (err = NoErr) then
    err := WritelnDansFichierTexte(fic, '');

  WritelnHugeStringDansFichierTexte := err;
end;



function WriteDansFichierTexte(var fic : FichierTEXT; s : String255) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      WriteDansRapport(s);
      WriteDansFichierTexte := NoErr;
      exit(WriteDansFichierTexte);
    end;

  err := MyFSWriteString(fic.refNum,s);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans WriteDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  WriteDansFichierTexte := err;
end;


function WritelnDansFichierTexte(var fic : FichierTEXT; s : String255) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      WritelnDansRapport(s);
      WritelnDansFichierTexte := NoErr;
      exit(WritelnDansFichierTexte);
    end;

  err := MyFSWriteString(fic.refnum,s + chr(13));

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans WritelnDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  WritelnDansFichierTexte := err;
end;


function WriteFichierAbstraitDansFichierTexte(var fic : FichierTEXT; ficAbstrait : FichierAbstrait; fromPos : SInt32; var count : SInt32) : OSErr;
var err : OSErr;
    buffer : Ptr;
begin
  err := -1;

  if (count <= 0) then
    exit(WriteFichierAbstraitDansFichierTexte);

  buffer := AllocateMemoryPtr(count + 100);
  if (buffer <> NIL) then
    begin
      err := ReadFromFichierAbstrait(ficAbstrait, fromPos , count, buffer);
      if err = NoErr then
        err := WriteBufferDansFichierTexte(fic, buffer, count);
      DisposeMemoryPtr(buffer);
    end;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans WriteBufferDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  WriteFichierAbstraitDansFichierTexte := err;
end;



function WriteLongintDansFichierTexte(var fic : FichierTEXT; value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      InsereTexteDansRapport(@value,4);
      WriteLongintDansFichierTexte := NoErr;
      exit(WriteLongintDansFichierTexte);
    end;

  count := 4;
  err := FSWrite(fic.refNum,count,@value);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans WriteLongintDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  WriteLongintDansFichierTexte := err;
end;

function ReadBufferDansFichierTexte(var fic : FichierTEXT; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      ReadBufferDansFichierTexte := -1;
      exit(ReadBufferDansFichierTexte);
    end;

  err := FSRead(fic.refNum,count,buffPtr);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadBufferDansFichierTexte :');
      DisplayMessageWithNumInConsole('count = ',count);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  ReadBufferDansFichierTexte := err;
end;


function ReadDansFichierTexte(var fic : FichierTEXT; nbOctets : SInt16; var s : String255) : OSErr;
var len : SInt32;
    err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      ReadDansFichierTexte := -1;
      exit(ReadDansFichierTexte);
    end;

  len := nbOctets;
  if len > 255 then len := 255;
  if len < 0 then len := 0;

  err := FSRead(fic.refnum,len,@s[1]);
  SET_LENGTH_OF_STRING(s,len);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  ReadDansFichierTexte := err;
end;



function MyFSBufferedReadPourReadln(var fic : FichierTEXT; var length : SInt32; buffer : Ptr) : OSErr;
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
            if debug then WritelnDansRapport('FIXEME : allocation du buffer de lecture');
            bufferLecture := PackedArrayOfCharPtr(AllocateMemoryPtr(SIZE_OF_BUFFER));
            if (bufferLecture = NIL) then
              begin
                doitUtiliserBuffer := false;
                goto Bail;
              end;
          end;

        if (tailleDuFichier < 0) then
          begin
            if (GetTailleFichierTexte(fic,tailleDuFichier) <> NoErr) then
              begin
                tailleDuFichier := -1;
                doitUtiliserBuffer := false;
                if debug then WritelnNumDansRapport('FIXEME : erreur dans le calcul de la taille du fichier : ',tailleDuFichier);
                goto Bail;
              end;
            if debug then WritelnNumDansRapport('FIXEME : calcul de la taille du fichier : ',tailleDuFichier);
          end;


        if (tailleDuFichier > 0) and
           (length > tailleDuFichier - (debutDuBuffer + positionDansBuffer)) and
           ((positionDansBuffer + length) > tailleDuBuffer)
           then length := tailleDuFichier - (debutDuBuffer + positionDansBuffer);


        if ((positionDansBuffer + length) > tailleDuBuffer) then
          begin
            nbOctetsLusSurLeDisque := SIZE_OF_BUFFER;

            err := GetPositionTeteLectureFichierTexte(fic, debutDuBuffer);

            if debug then WritelnNumDansRapport('FIXEME : apres GetPositionTeteLectureFichierTexte, err = ',err);

            if (err = NoErr) then
              err := FSRead(fic.refnum, nbOctetsLusSurLeDisque, bufferLecture);

            if (err = NoErr) and (nbOctetsLusSurLeDisque > 0)
              then
                begin
                  tailleDuBuffer     := nbOctetsLusSurLeDisque;
                  positionDansBuffer := 0;
                  if debug then WritelnNumDansRapport('FIXEME : lecture dans le fichier : ',tailleDuBuffer);
                end
              else
                begin
                  if debug then WritelnNumDansRapport('FIXEME : erreur de lecture dans le fichier, err = ',err);
                  if debug then WritelnNumDansRapport('FIXEME : nbOctetsLusSurLeDisque = ',nbOctetsLusSurLeDisque);

                  if (err = -39) and (nbOctetsLusSurLeDisque > 0)
                    then
                      begin
                        tailleDuBuffer     := nbOctetsLusSurLeDisque;
                        positionDansBuffer := 0;
                        err := SetPositionTeteLectureFichierTexte(fic, debutDuBuffer);
                      end
                    else
                      begin
                        doitUtiliserBuffer := false;
                        err := SetPositionTeteLectureFichierTexte(fic, debutDuBuffer);
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

            // if debug then WritelnNumDansRapport('FIXEME : OK, positionDansBuffer = ',positionDansBuffer);
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


function ReadlnDansFichierTexte(var fic : FichierTEXT; var s : String255) : OSErr;
var err : OSErr;
    i,len,longueurLigne : SInt32;
    positionTeteDeLecture : SInt32;
    buffer : packed array[0..300] of char;
begin
  s := '';

  if FichierTexteEstLeRapport(fic) then
    begin
      ReadlnDansFichierTexte := -1;
      exit(ReadlnDansFichierTexte);
    end;

  err := GetPositionTeteLectureFichierTexte(fic,positionTeteDeLecture);

  {on essaie de lire 258 caracteres du fichier pour les mettre dans notre buffer}
  len := 258;
  err := MyFSBufferedReadPourReadln(fic, len, @buffer[1]);
  //err := FSRead(fic.refnum, len, @buffer[1]);
  for i := len + 1 to 258 do buffer[i] := chr(0);

  {on cherche le premier retour charriot dans le buffer}
  len := Min(256,len);
  longueurLigne := Min(255,len);
  gRetourCharriotTrouveDansReadlnFichierTEXT := false;
  for i := len downto 1 do
    if (buffer[i] = cr) or (buffer[i] = lf) then
      begin
        longueurLigne := i-1;
        gRetourCharriotTrouveDansReadlnFichierTEXT := true;
      end;

  {on ajuste en consequence la longueur de s, et on recopie la chaine}
  for i := 1 to longueurLigne do s[i] := buffer[i];
  for i := longueurLigne + 1 to 255 do s[i] := chr(0);
  SET_LENGTH_OF_STRING(s,longueurLigne);

  {on gere les retours charriots DOS, UNIX, Mac, etc}
  if gRetourCharriotTrouveDansReadlnFichierTEXT then
    begin
      if ((buffer[longueurLigne+1] = cr) and (buffer[longueurLigne+2] = lf)) or
         ((buffer[longueurLigne+1] = lf) and (buffer[longueurLigne+2] = cr))
         then inc(longueurLigne);
    end;

  {on deplace la tete de lecture}
  if gRetourCharriotTrouveDansReadlnFichierTEXT
    then positionTeteDeLecture := 1 + positionTeteDeLecture + longueurLigne
    else positionTeteDeLecture :=     positionTeteDeLecture + longueurLigne;
  err := SetPositionTeteLectureFichierTexte(fic,positionTeteDeLecture);

  {
  WriteStringAndBoolDansRapport(s+' ',gRetourCharriotTrouveDansReadlnFichierTEXT);
  WritelnNumDansRapport(' ==>  err = ',err);
  }

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadlnDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  ReadlnDansFichierTexte := err;
end;



function ReadlnLongStringDansFichierTexte(var fic : FichierTEXT; var s : LongString) : OSErr;
var longueur : SInt32;
    err : OSErr;
begin
  with s do
    begin
      debutLigne := '';
      finLigne   := '';
      complete   := true;

      err := ReadlnDansFichierTexte(fic, debutLigne);

      if (err = NoErr) then
        begin
          longueur := LENGTH_OF_STRING(debutLigne);
          if (longueur < 255) or
             ((longueur = 255) and gRetourCharriotTrouveDansReadlnFichierTEXT)
            then
              begin
                ReadlnLongStringDansFichierTexte := err;
                exit(ReadlnLongStringDansFichierTexte);
              end
            else
              begin
                err := ReadlnDansFichierTexte(fic, finLigne);
                complete := gRetourCharriotTrouveDansReadlnFichierTEXT;
              end;
        end;

      ReadlnLongStringDansFichierTexte := err;
    end;
end;



 (*
 *******************************************************************************
 *                                                                             *
 *   ReadlnHugeStringDansFichierTexte()  : lit un fichier jusqu'au premier     *
 *   retour chariot et met le resultat dans une HugeString. Cette fonction     *
 *   n'alloue pas la HugeString, elle doit avoir ete creee auparavant par un   *
 *   appel a NewHugeString() ou MakeHugeString().                              *
 *                                                                             *
 *******************************************************************************
 *)
function ReadlnHugeStringDansFichierTexte(var fic : FichierTEXT; var s : HugeString) : OSErr;
var buffer : CharArrayPtr;
    err : OSErr;
    count : SInt32;
begin

  err := -1;

  if HugeStringIsUsable(s) then
    begin
      count  := GetMaximumCapacityOfHugeString;
      buffer := GetBufferOfHugeString(s);

      err    := ReadlnBufferDansFichierTexte(fic, @buffer^[1], count);

      if (err = NoErr)
        then SetLengthOfHugeString(s, count);

    end;

  ReadlnHugeStringDansFichierTexte := err;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   ReadlnBufferDansFichierTexte()  : lit un fichier jusqu'au premier retour  *
 *   chariot et met le resultat dans buffer. Cette fonction n'alloue pas le    *
 *   buffer, il doit avoir ete cree a la bonne taille auparavant.              *
 *      -> En entree, count est la taille du buffer                            *
 *      -> En sortie, count contient le nombre de caracteres jusqu'au premier  *
 *                    retour chariot, si on en a trouve un...                  *
 *                                                                             *
 *******************************************************************************
 *)
function ReadlnBufferDansFichierTexte(var fic : FichierTEXT; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
    i,len,longueurLigne : SInt32;
    positionTeteDeLecture : SInt32;
    localBuffer : PackedArrayOfCharPtr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      ReadlnBufferDansFichierTexte := -1;
      exit(ReadlnBufferDansFichierTexte);
    end;

  err := GetPositionTeteLectureFichierTexte(fic,positionTeteDeLecture);

  {on essaie de lire count caracteres dans buffPtr}
  len := count;
  err := FSRead(fic.refnum,count,buffPtr);
  localBuffer := PackedArrayOfCharPtr(buffPtr);

  {on cherche le premier retour charriot dans buffPtr}
  longueurLigne := Min(len,count);
  gRetourCharriotTrouveDansReadlnFichierTEXT := false;
  for i := count-1 downto 0 do
    if (localBuffer^[i] = cr) or (localBuffer^[i] = lf) then
      begin
        longueurLigne := i;
        count := i;
        gRetourCharriotTrouveDansReadlnFichierTEXT := true;
      end;


  {on deplace la tete de lecture}
  if gRetourCharriotTrouveDansReadlnFichierTEXT
    then positionTeteDeLecture := 1 + positionTeteDeLecture + longueurLigne
    else positionTeteDeLecture :=     positionTeteDeLecture + longueurLigne;
  err := SetPositionTeteLectureFichierTexte(fic,positionTeteDeLecture);

  {
  WriteStringAndBoolDansRapport(s+' ',gRetourCharriotTrouveDansReadlnFichierTEXT);
  WritelnNumDansRapport(' ==>  err = ',err);
  }

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadlnBufferDansFichierTexte :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  ReadlnBufferDansFichierTexte := err;
end;


function ReadLongintDansFichierTexte(var fic : FichierTEXT; var value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      ReadLongintDansFichierTexte := -1;
      exit(ReadLongintDansFichierTexte);
    end;

  count := 4;
  err := FSRead(fic.refNum,count,@value);

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans ReadLongintDansFichierTexte :');
      DisplayMessageWithNumInConsole('count = ',count);
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  ReadLongintDansFichierTexte := err;
end;


procedure ForEachLineInFileDo(whichFile : FSSpec; DoWhat : LineOfFileProc; var result : SInt32);
var theFic : FichierTEXT;
    erreurES : OSErr;
    ligne : LongString;
begin
  erreurES := FichierTexteExisteFSp(whichFile,theFic);
  if (erreurES <> NoErr) then exit(ForEachLineInFileDo);

  erreurES := OuvreFichierTexte(theFic);
  if (erreurES <> NoErr) then exit(ForEachLineInFileDo);

  with ligne do
    begin
      debutLigne := '';
      finLigne   := '';
      complete   := true;
    end;

  while not(EOFFichierTexte(theFic,erreurES)) do
    begin

      erreurES := ReadlnLongStringDansFichierTexte(theFic,ligne);

      DoWhat(ligne,theFic,result);
    end;

  erreurES := FermeFichierTexte(theFic);
end;



function InsererFichierDansFichierTexte(var fic : FichierTEXT; pathFichierAInserer : String255) : OSErr;
var insertion : FichierTEXT;
    err,err2 : OSErr;
begin
  err := FichierTexteExiste(pathFichierAInserer,0,insertion);
  if err = NoErr then
    begin
      err := OuvreFichierTexte(insertion);
      err := InsererFichierTexteDansFichierTexte(insertion,fic);
      err2 := FermeFichierTexte(insertion);
    end;

  InsererFichierDansFichierTexte := err;
end;


function InsererFichierTexteDansFichierTexte(var insere,receptacle : FichierTEXT) : OSErr;
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

  fichierInsereOuvert := FichierTexteEstOuvert(insere);
  if not(fichierInsereOuvert) then err := OuvreFichierTexte(insere);
  err := SetPositionTeteLectureFichierTexte(insere,0);

  fichierReceptacleOuvert := FichierTexteEstOuvert(receptacle);
  if not(fichierReceptacleOuvert) then
    begin  {ouvrir le fichier et placer le curseur à la fin}
      err2 := OuvreFichierTexte(receptacle);
      err2 := SetPositionTeteLectureFinFichierTexte(receptacle);
    end;

  if (err = NoErr) and (err2 = NoErr) then
    begin
      err := GetTailleFichierTexte(insere,longueurInsertion);

      nbOctetsCopies := 0;

      repeat
        count := Min(kTailleBufferCopie, longueurInsertion-nbOctetsCopies);
        err  := ReadBufferDansFichierTexte(insere,@buffer[0],count);
        err2 := WriteBufferDansFichierTexte(receptacle,@buffer[0],count);
        nbOctetsCopies := nbOctetsCopies + count;
      until (err <> NoErr) or (err2 <> NoErr) or (nbOctetsCopies >= longueurInsertion);

    end;

  if not(fichierInsereOuvert)     then err  := FermeFichierTexte(insere);
  if not(fichierReceptacleOuvert) then err2 := FermeFichierTexte(receptacle);

  if (err <> NoErr)
    then InsererFichierTexteDansFichierTexte := err
    else InsererFichierTexteDansFichierTexte := err2;

end;

function CreerRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
var err : OSErr;
    creator,fileType: OSType;
begin

  creator := GetFileCreatorFichierTexte(fic);
  fileType := GetFileTypeFichierTexte(fic);

  FSpCreateResFile(fic.TheFSSpec,creator,fileType,smSystemScript);
  err := ResError;

  if avecDebuggageUnitFichiersTexte then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreateResFile dans CreerRessourceForkFichierTEXT :');
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  CreerRessourceForkFichierTEXT := err;
end;


function OuvreRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
var nroRef : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      OuvreRessourceForkFichierTEXT := -1;
      exit(OuvreRessourceForkFichierTEXT);
    end;

  if fic.rsrcForkOuvertCorrectement <> -1 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le ressource Fork d''un fichier dont fic.rsrcForkOuvertCorrectement <> -1 !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('GetNameOfFSSpec(fic.theFSSpec) = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement = ',fic.rsrcForkOuvertCorrectement);
      DisplayMessageInConsole('');
      OuvreRessourceForkFichierTEXT := -1;
      exit(OuvreRessourceForkFichierTEXT);
    end;

  nroRef := FSpOpenResFile(fic.TheFSSpec,4);
  if nroRef = -1
    then OuvreRessourceForkFichierTEXT := -1  {Error !}
    else
      begin
        fic.ressourceForkRefNum := nroRef;
        OuvreRessourceForkFichierTEXT := NoErr;

        inc(fic.rsrcForkOuvertCorrectement);
        if (fic.rsrcForkOuvertCorrectement <> 0) then
          begin
            SysBeep(0);
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une ouverture correcte du ressource fork d''un fichier, rsrcForkOuvertCorrectement <> 0 !');
            DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
            DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement = ',fic.rsrcForkOuvertCorrectement);
            DisplayMessageInConsole('');
          end;
      end;
end;


function UseRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      UseRessourceForkFichierTEXT := -1;
      exit(UseRessourceForkFichierTEXT);
    end;

  if fic.rsrcForkOuvertCorrectement <> 0 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut utiliser le ressource Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageInConsole('GetNameOfFSSpec(fic.theFSSpec) = '+GetNameOfFSSpec(fic.theFSSpec));
      DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement = ',fic.rsrcForkOuvertCorrectement);
      DisplayMessageInConsole('');
      UseRessourceForkFichierTEXT := -1;
      exit(UseRessourceForkFichierTEXT);
    end;

  UseResFile(fic.ressourceForkRefNum);
  err := ResError;
  {DisplayMessageWithNumInConsole('err = ',err);}

  UseRessourceForkFichierTEXT := err;
end;

function FermeRessourceForkFichierTEXT(var fic : FichierTEXT) : OSErr;
var err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      FermeRessourceForkFichierTEXT := -1;
      exit(FermeRessourceForkFichierTEXT);
    end;

  if fic.rsrcForkOuvertCorrectement <> 0 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le ressource Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
      DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement = ',fic.rsrcForkOuvertCorrectement);
      DisplayMessageInConsole('');
      FermeRessourceForkFichierTEXT := -1;
      exit(FermeRessourceForkFichierTEXT);
    end;

  if fic.ressourceForkRefNum <> 0
    then
      begin
        CloseResFile(fic.ressourceForkRefNum);
        err := ResError;
        {DisplayMessageWithNumInConsole('err = ',err);}

        FermeRessourceForkFichierTEXT := err;

        if err = NoErr then
          begin
            dec(fic.rsrcForkOuvertCorrectement);
            if (fic.rsrcForkOuvertCorrectement <> -1) then
              begin
                SysBeep(0);
                DisplayMessageInConsole('');
                DisplayMessageInConsole('## WARNING : après une fermeture correcte du ressource fork d''un fichier, rsrcForkOuvertCorrectement <> -1 !');
                DisplayMessageInConsole('fic.nomFichier = '+fic.nomFichier);
                DisplayMessageWithNumInConsole('fic.rsrcForkOuvertCorrectement = ',fic.rsrcForkOuvertCorrectement);
                DisplayMessageInConsole('');
              end;
          end;
      end
    else
      FermeRessourceForkFichierTEXT := -1;  {erreur, on a failli fermer le fichier systeme !}
end;


function FichierTexteDeCassioExiste(nom : String255; var fic : FichierTEXT) : OSErr;
const tailleMaxNom = 31;
var err : OSErr;
    len,posLastDeuxPoints : SInt16;
    erreurEstFicNonTrouve : boolean;
begin

  err := -2;
  erreurEstFicNonTrouve := false;


  if err <> NoErr then
    begin
      err := FichierTexteExiste(nom,0,fic);
      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
    end;

  posLastDeuxPoints := LastPos(':',nom);
  nom := TPCopy(nom, posLastDeuxPoints+1, 255);

  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
		  if err <> NoErr then
		    begin
		      err := FichierTexteExiste(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  nom := nom+' ';
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
		  if (err <> NoErr) then
		    begin
		      err := FichierTexteExiste(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  nom := nom+'(alias)';
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
		  if (err <> NoErr) then
		    begin
		      err := FichierTexteExiste(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  if (err <> 0) and erreurEstFicNonTrouve
    then FichierTexteDeCassioExiste := fnfErr
    else FichierTexteDeCassioExiste := err;
end;


function CreeFichierTexteDeCassio(nom : String255; var fic : FichierTEXT) : OSErr;
const tailleMaxNom = 31;
var err : OSErr;
    len,posLastDeuxPoints : SInt16;
begin
  err := -1;
  posLastDeuxPoints := LastPos(':',nom);
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      err := CreeFichierTexte(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  nom := nom+' (1)';
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      if (err <> NoErr)
        then err := CreeFichierTexte(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  nom := nom+'(2)';
  len := LENGTH_OF_STRING(nom)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      if (err <> NoErr)
        then err := CreeFichierTexte(pathDossierFichiersAuxiliaires+':'+nom,0,fic);
    end;
  CreeFichierTexteDeCassio := err;
end;

procedure AlerteSimpleFichierTexte(nomFichier : String255; erreurES : SInt32);
CONST TextesErreursID       = 10016;
var s,texte,explication,pathFichier : String255;
begin
  s := ReadStringFromRessource(TextesErreursID, 5);  {'erreur I/O sur fichier «^0» ! code erreur =  ^1'}

  pathFichier := nomFichier;
  if (Pos(':',pathFichier) > 0)
    then
      begin
        nomFichier := ExtraitNomDirectoryOuFichier(pathFichier);

        ReplaceCharByCharInString(pathFichier,':','/');

        s := ParamStr(s,nomFichier,IntToStr(erreurES) + chr(13)+'  path = '+pathFichier,'','');
      end
    else
      begin
        s := ParamStr(s,nomFichier,IntToStr(erreurES),'','');
      end;

  SplitBy(s,'!',texte,explication);
  AlerteDouble(texte+'!',explication);
end;



procedure SetFileCreatorFichierTexte(var fic : FichierTEXT; quelType : OSType);
var InfosFinder : FInfo;
    err : OSErr;
begin
  if FichierTexteEstLeRapport(fic)
    then exit(SetFileCreatorFichierTexte);

  err := FSpGetFInfo(fic.theFSSpec,InfosFinder);
  InfosFinder.fdCreator := QuelType;
  err := FSpSetFInfo(fic.theFSSpec,InfosFinder);
end;


procedure SetFileTypeFichierTexte(var fic : FichierTEXT; quelType : OSType);
var InfosFinder : FInfo;
    err : OSErr;
begin
  if FichierTexteEstLeRapport(fic)
    then exit(SetFileTypeFichierTexte);

  err := FSpGetFInfo(fic.theFSSpec,InfosFinder);
  InfosFinder.fdType := QuelType;
  err := FSpSetFInfo(fic.theFSSpec,InfosFinder);
end;


function GetFileCreatorFichierTexte(var fic : FichierTEXT) : OSType;
var InfosFinder : FInfo;
    err : OSErr;
begin
  GetFileCreatorFichierTexte := MY_FOUR_CHAR_CODE('????');

  if FichierTexteEstLeRapport(fic) then
    begin
      GetFileCreatorFichierTexte := NoErr;
      exit(GetFileCreatorFichierTexte);
    end;

  err := FSpGetFInfo(fic.theFSSpec,InfosFinder);
  GetFileCreatorFichierTexte := InfosFinder.fdCreator;
end;


function GetFileTypeFichierTexte(var fic : FichierTEXT) : OSType;
var InfosFinder : FInfo;
    err : OSErr;
begin

  if FichierTexteEstLeRapport(fic) then
    begin
      GetFileTypeFichierTexte := NoErr;
      exit(GetFileTypeFichierTexte);
    end;

  GetFileTypeFichierTexte := MY_FOUR_CHAR_CODE('????');
  err := FSpGetFInfo(fic.theFSSpec,InfosFinder);
  GetFileTypeFichierTexte := InfosFinder.fdType;
end;

{kFSCatInfoCreateDate = 0x00000020,
   kFSCatInfoContentMod = 0x00000040
   }

function GetCreationDateFichierTexte(var fic : FichierTEXT; var theDate : DateTimeRec) : OSErr;
var err : OSErr;
    fileRef : FSRef;
    catalogInfo : FSCatalogInfo;
begin
  if FichierTexteEstLeRapport(fic) then
    begin
      GetCreationDateFichierTexte := -1;
      exit(GetCreationDateFichierTexte);
    end;

  err := FSpMakeFSRef(fic.theFSSpec,fileRef);

  if err = NoErr then
    begin
      err := FSGetCatalogInfo(fileRef,kFSCatInfoCreateDate,@catalogInfo,NIL,NIL,NIL);
      if (err = NoErr) then SecondsToDate(catalogInfo.createDate.lowSeconds,theDate);
    end;

  GetCreationDateFichierTexte := err;
end;


function SetCreationDateFichierTexte(var fic : FichierTEXT; const theDate : DateTimeRec) : OSErr;
var err : OSErr;
    {fileRef : FSRef;
    catalogInfo : FSCatalogInfo;}
begin {$UNUSED theDate}
  if FichierTexteEstLeRapport(fic) then
    begin
      SetCreationDateFichierTexte := -1;
      exit(SetCreationDateFichierTexte);
    end;

  err := -1;

  SetCreationDateFichierTexte := err;
end;


function GetModificationDateFichierTexte(var fic : FichierTEXT; var theDate : DateTimeRec) : OSErr;
var err : OSErr;
    fileRef : FSRef;
    catalogInfo : FSCatalogInfo;
begin
  if FichierTexteEstLeRapport(fic) then
    begin
      GetModificationDateFichierTexte := -1;
      exit(GetModificationDateFichierTexte);
    end;

  err := FSpMakeFSRef(fic.theFSSpec,fileRef);

  if err = NoErr then
    begin
      err := FSGetCatalogInfo(fileRef,kFSCatInfoContentMod,@catalogInfo,NIL,NIL,NIL);
      if (err = NoErr) then SecondsToDate(catalogInfo.contentModDate.lowSeconds,theDate);
    end;

  GetModificationDateFichierTexte := err;
end;


function SetModificationDateFichierTexte(var fic : FichierTEXT; const theDate : DateTimeRec) : OSErr;
var err : OSErr;
begin {$UNUSED theDate}
  if FichierTexteEstLeRapport(fic) then
    begin
      SetModificationDateFichierTexte := -1;
      exit(SetModificationDateFichierTexte);
    end;

  err := -1;

  SetModificationDateFichierTexte := err;
end;


procedure InstalleMessageDisplayerFichierTexte(theProc : MessageDisplayerProc);
begin
  CustomDisplayMessage := theProc;
  useStandardConsole := false;
end;

procedure InstalleMessageAndNumDisplayerFichierTexte(theProc : MessageAndNumDisplayerProc);
begin
  CustomDisplayMessageWithNum := theProc;
  useStandardConsole := false;
end;

procedure InstalleAlerteFichierTexte(theProc : MessageAndNumDisplayerProc);
begin
  CustomDisplayAlerteWithNum := theProc;
  useStandardConsole := false;
end;

procedure InitUnitFichierTexte;
begin
  SetDebuggageUnitFichiersTexte(false);

  (* installation des procedure pour l'affichage de message :
     sur la sortie standard par defaut. On peut installer des
     routines personalisees d'impression de messages et d'alerte
     juste apres l'appel a InitUnitFichierTexte *)
  InstalleMessageDisplayerFichierTexte(StandardConsoleDisplayer);
  InstalleMessageAndNumDisplayerFichierTexte(StandardConsoleDisplayerWithNum);
  InstalleAlerteFichierTexte(StandardConsoleAlertWithNum);
  useStandardConsole := true;

  nomSortieStandardDansRapport := 'Rapport-stdErr-fake-Cassio';

  unit_initialisee := true;
end;


function CreeSortieStandardEnFichierTexte(var fic : FichierTEXT) : OSErr;
begin
  if not(unit_initialisee) then InitUnitFichierTexte;
  CreeSortieStandardEnFichierTexte := CreeFichierTexte(nomSortieStandardDansRapport,0,fic);
end;


procedure SetDebuggageUnitFichiersTexte(flag : boolean);
begin
  avecDebuggageUnitFichiersTexte := flag;
end;

function GetDebuggageUnitFichiersTexte : boolean;
begin
  GetDebuggageUnitFichiersTexte := avecDebuggageUnitFichiersTexte;
end;


end.
