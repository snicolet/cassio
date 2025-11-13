UNIT UnitEnvirons;



INTERFACE


 USES UnitDefCassio;




{ Version de Cassio, par exemple "7.5" }
function VersionDeCassioEnString : String255;

{ Paths complets vers les dossiers de Cassio }
function DetermineVolumeApplication : String255;
function DeterminePathDossierFichiersAuxiliaires(whichVolumeRefCassio : String255) : String255;
function DeterminePathDossierOthelliersCassio(whichVolumeRefCassio : String255) : String255;

{ Fichiers textes dans les dossiers auxiliaires de Cassio }
function FichierTexteDeCassioExiste(name : String255; var fic : basicfile) : OSErr;
function CreeFichierTexteDeCassio(name : String255; var fic : basicfile) : OSErr;

{ Noms de l'utilisateur et de l'executable }
function GetUserName : String255;
function GetApplicationName(default : String255) : String255;
function GetApplicationBundleName : String255;

{ Createur et type de fichier (MacOS seulement) }
procedure SetFileCreatorFichierTexte(var fic : basicfile; quelType : OSType);
procedure SetFileTypeFichierTexte(var fic : basicfile; quelType : OSType);
function GetFileCreatorFichierTexte(var fic : basicfile) : OSType;
function GetFileTypeFichierTexte(var fic : basicfile) : OSType;

{ Creation et utilisation des ressources fork (MacOS seulement) }
function CreerRessourceFork(var fic : basicfile) : OSErr;
function OuvreRessourceFork(var fic : basicfile) : OSErr;
function FermeRessourceFork(var fic : basicfile) : OSErr;
function UseRessourceFork(var fic : basicfile) : OSErr;

{ Polices de caracteres }
procedure SelectCassioFonts(theme : SInt32);
function GetCassioFontNum(nomPolice : String255) : SInt32;
procedure ChargerLesPolicesPriveesDeCassio;

{ Divers }
procedure ForconsLePlantageDeCassio;
function HasGestaltAttr(itsAttr : OStype; itsBit : SInt16) : boolean;
function CassioEstUnBundleApplicatif : boolean;
function CassioSansDouteLanceDepuisUneImageDisque : boolean;

{ Test pour les langues des localisations de Cassio }
function EstLaVersionFrancaiseDeCassio : boolean;
function EstLaVersionJaponaiseDeCassio : boolean;
function EstLaVersionAnglaiseDeCassio : boolean;

{ Gestion de la memorisation du path du dossier de Cassio }
procedure InitListeOfValidCassioFolders;
procedure SauvegarderListeOfCassioFolderPaths;
procedure LireListeOfCassioFolderPaths;
procedure AddValidCassioFolderPath(whichPath : String255);
function BeginIterationOnCassioFolderPaths(firstPathToTry : String255) : String255;
function TryNextCassioFolderPath : String255;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Script, Fonts, MacWindows, GestaltEqu, Processes, CFBase, CFString, OSUtils

{$IFC NOT(USE_PRELINK)}
    , MyStrings, UnitServicesMemoire, MyFileSystemUtils, MyFonts, MyAntialiasing, basicfile, MyMathUtils, UnitCarbonisation
    , UnitRapport, UnitEngine, UnitGestionDuTemps, UnitTournoi ;
{$ELSEC}
    ;
    {$I prelink/Environs.lk}
{$ENDC}


{END_USE_CLAUSE}

const gCassioSansDouteLanceDepuisUneImageDisque : boolean = false;


function VersionDeCassioEnString : String255;
begin
  VersionDeCassioEnString := '9.0b1';
end;



function DetermineVolumeApplication : String255;
var myStringPtr : StringPtr;
    refvol : SInt16;
    codeErreur : OSErr;
    dirID : UInt32;
    myPath : String255;
    myFileInfo : fileInfo;
    left,right : String255;
begin
   myStringPtr := StringPtr(AllocateMemoryPtr(sizeof(str255)));
   codeErreur := HGetVol(myStringPtr,refvol,dirID);
   DisposeMemoryPtr(Ptr(myStringPtr));

   myPath := GetWDName(refvol);

   // On gere le cas ou Cassio est une application sous forme de bundle

   SplitRight(myPath , DirectorySeparator + 'Contents' + DirectorySeparator , left , right );
   if (left <> '') and (right <> '') then
     begin
       myPath := left;
       SplitRight(myPath , DirectorySeparator , left , right );
       if (left <> '') and (right <> '') then
         begin
           left := left + DirectorySeparator;
           codeErreur := MakeFileInfo(left,myFileInfo);
           if codeErreur = NoErr then myPath := left;
         end;
     end;

   DetermineVolumeApplication := myPath;
end;


function CassioEstUnBundleApplicatif : boolean;
var myStringPtr : StringPtr;
    refvol : SInt16;
    codeErreur : OSErr;
    dirID : UInt32;
    myPath : String255;
    left,right : String255;
begin
   myStringPtr := StringPtr(AllocateMemoryPtr(sizeof(str255)));
   codeErreur := HGetVol(myStringPtr,refvol,dirID);
   DisposeMemoryPtr(Ptr(myStringPtr));

   myPath := GetWDName(refvol);

   SplitRight(myPath , ':Contents:' , left , right );

   CassioEstUnBundleApplicatif := (left <> '') and (right <> '');
end;


function CassioSansDouteLanceDepuisUneImageDisque : boolean;
begin
  CassioSansDouteLanceDepuisUneImageDisque := gCassioSansDouteLanceDepuisUneImageDisque;
end;


function GetApplicationBundleName : String255;
var myStringPtr : StringPtr;
    refvol : SInt16;
    codeErreur : OSErr;
    dirID : UInt32;
    myPath : String255;
    left,right : String255;
begin
   GetApplicationBundleName := '';

   myStringPtr := StringPtr(AllocateMemoryPtr(sizeof(str255)));
   codeErreur := HGetVol(myStringPtr,refvol,dirID);
   DisposeMemoryPtr(Ptr(myStringPtr));

   myPath := GetWDName(refvol);

   // On trouve si Cassio est une application sous forme de bundle

   SplitRight(myPath , DirectorySeparator + 'Contents' + DirectorySeparator , left , right );
   if (left <> '') and (right <> '')
     then
       begin
         myPath := left;
         SplitRightByStr(myPath, DirectorySeparator , left , right);
         GetApplicationBundleName := right;
       end
     else
       begin
         GetApplicationBundleName := '';
       end;
end;



function GetApplicationName(default : String255) : String255;
	var
		CurrentPSN : ProcessSerialNumber;
		ProcessInfo : ProcessInfoRec;
		err : OSErr;
		myFileInfo : fileInfo;
		myString : Str255;
begin
	GetApplicationName := default;  {nom par défaut si le reste ne marche pas, e.g. sur un PC}

	if not(HasGestaltAttr(gestaltOSAttr, gestaltLaunchControl)) then
		exit;

	CurrentPSN.highLongOfPSN := 0;
	CurrentPSN.lowLongOfPSN := kCurrentProcess;

	err := GetCurrentProcess(CurrentPSN);
	if err <> 0 then
		exit;

	ProcessInfo.processInfoLength := sizeof(ProcessInfoRec);
	ProcessInfo.processName := @myString;
	ProcessInfo.processAppSpec := @myFileInfo;

	err := GetProcessInformation(CurrentPSN, ProcessInfo);
	if err <> 0 then
		exit
	else
		GetApplicationName := MyStr255ToString(ProcessInfo.processname^);
end;


function GetUserName : String255;
var result : Str255;
    textStringRef : CFStringRef;
    useShortName : boolean;
begin
  result := StringToStr255('');

  useShortName := true;
  textStringRef := CSCopyUserName(useShortName);
  if (textStringRef <> NIL) then
    begin
      if CFStringGetPascalString(textStringRef,@result,256,CFStringGetSystemEncoding) then DoNothing;

      if (textStringRef <> NIL) then CFRelease(CFTypeRef(textStringRef));
    end;

  GetUserName := MyStr255ToString(result);
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
      DisplayMessageInConsole('   ==> Err = ',err);
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
      Beep();
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le ressource Fork d''un fichier dont fic.rsrcForkCorrectlyOpen <> -1 !');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
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
            Beep();
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une ouverture correcte du ressource fork d''un fichier, rsrcForkCorrectlyOpen <> 0 !');
            DisplayMessageInConsole('fic.fileName = '+fic.fileName);
            DisplayMessageInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
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
      Beep();
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut utiliser le ressource Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
      DisplayMessageInConsole('');
      UseRessourceFork := -1;
      exit;
    end;

  UseResFile(fic.ressourceForkRefNum);
  err := ResError;
  {DisplayMessageInConsole('err = ',err);}

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
      Beep();
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le ressource Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
      DisplayMessageInConsole('');
      FermeRessourceFork := -1;
      exit;
    end;

  if fic.ressourceForkRefNum <> 0
    then
      begin
        CloseResFile(fic.ressourceForkRefNum);
        err := ResError;
        {DisplayMessageInConsole('err = ',err);}

        FermeRessourceFork := err;

        if err = NoErr then
          begin
            dec(fic.rsrcForkCorrectlyOpen);
            if (fic.rsrcForkCorrectlyOpen <> -1) then
              begin
                Beep();
                DisplayMessageInConsole('');
                DisplayMessageInConsole('## WARNING : après une fermeture correcte du ressource fork d''un fichier, rsrcForkCorrectlyOpen <> -1 !');
                DisplayMessageInConsole('fic.fileName = '+fic.fileName);
                DisplayMessageInConsole('fic.rsrcForkCorrectlyOpen = ',fic.rsrcForkCorrectlyOpen);
                DisplayMessageInConsole('');
              end;
          end;
      end
    else
      FermeRessourceFork := -1;  {erreur, on a failli fermer le fichier systeme !}
end;


function DeterminePathDossierFichiersAuxiliaires(whichVolumeRefCassio : String255) : String255;
var myFileInfo : fileInfo;
    err : OSErr;
    fullPath : String255;
    iterateurCassioFolderPaths : String255;
begin

  iterateurCassioFolderPaths := BeginIterationOnCassioFolderPaths(whichVolumeRefCassio);

  repeat
    err := -1;

    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Fichiers auxiliaires',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Fichiers-auxiliaires',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Fichiers auxiliaires Cassio',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Fichiers-auxiliaires-Cassio',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Auxilary files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Auxilary-files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Auxiliary files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Auxiliary-files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Cassio files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Cassio-files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Cassio auxilary files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Cassio-auxilary-files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Cassio auxiliary files',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Cassio-auxiliary-files',myFileInfo);

    if err = NoErr
      then
        begin
          ExpandFileName(myFileInfo);
          err := ExpandFileName(myFileInfo,fullPath);

          if err = NoErr then AddValidCassioFolderPath(iterateurCassioFolderPaths);

          DeterminePathDossierFichiersAuxiliaires := fullPath;
          {WritelnDansRapport('Branche de reussite dans DeterminePathDossierFichiersAuxiliaires : '+fullPath);}
        end
      else
        iterateurCassioFolderPaths := TryNextCassioFolderPath;

  until (err = NoErr) or (iterateurCassioFolderPaths = '');

  if err <> NoErr then  { desespoir !! }
      begin
        err := MakeFileInfo(iterateurCassioFolderPaths,myFileInfo);
        ExpandFileName(myFileInfo);
        err := ExpandFileName(myFileInfo,fullPath);

        DeterminePathDossierFichiersAuxiliaires := fullPath;
        {WritelnDansRapport('Branche d''echec dans DeterminePathDossierFichiersAuxiliaires : '+fullPath);}
      end
end;


function DeterminePathDossierOthelliersCassio(whichVolumeRefCassio : String255) : String255;
var myFileInfo : fileInfo;
    err : OSErr;
    fullPath : String255;
    iterateurCassioFolderPaths : String255;
begin
  iterateurCassioFolderPaths := BeginIterationOnCassioFolderPaths(whichVolumeRefCassio);

  repeat

    err := MakeFileInfo(iterateurCassioFolderPaths+'Othelliers Cassio',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Othelliers Cassio (alias)',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Othelliers',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Boards',myFileInfo);
    if err <> 0 then err := MakeFileInfo(iterateurCassioFolderPaths+'Boards Cassio',myFileInfo);

    if err = 0
      then
        begin
          ExpandFileName(myFileInfo);
          err := ExpandFileName(myFileInfo,fullPath);

          if err = NoErr then AddValidCassioFolderPath(iterateurCassioFolderPaths);

          DeterminePathDossierOthelliersCassio := fullPath;
          {WritelnDansRapport('Branche de reussite dans DeterminePathDossierOthelliersCassio : '+fullPath);}
        end
      else
        iterateurCassioFolderPaths := TryNextCassioFolderPath;

  until (err = NoErr) or (iterateurCassioFolderPaths = '');


  if (err <> 0) then
    begin  { desespoir !! }
      err := MakeFileInfo(iterateurCassioFolderPaths,myFileInfo);
      ExpandFileName(myFileInfo);
      err := ExpandFileName(myFileInfo,fullPath);
      DeterminePathDossierOthelliersCassio := fullPath;
      {WritelnDansRapport('Branche d''echec dans DeterminePathDossierOthelliersCassio : '+fullPath);}
    end

end;



function FichierTexteDeCassioExiste(name : String255; var fic : basicfile) : OSErr;
const tailleMaxNom = 31;
var err : OSErr;
    len,posLastDeuxPoints : SInt16;
    erreurEstFicNonTrouve : boolean;
begin

  err := -2;
  erreurEstFicNonTrouve := false;


  if err <> NoErr then
    begin
      err := FileExists(name,0,fic);
      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
    end;

  posLastDeuxPoints := LastPos( DirectorySeparator ,name);
  name := TPCopy(name, posLastDeuxPoints+1, 255);

  len := LENGTH_OF_STRING(name);
  if len <= tailleMaxNom then
    begin
		  if err <> NoErr then
		    begin
		      err := FileExists(pathDossierFichiersAuxiliaires+ DirectorySeparator +name,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  name := name+' ';
  len := LENGTH_OF_STRING(name);
  if len <= tailleMaxNom then
    begin
		  if (err <> NoErr) then
		    begin
		      err := FileExists(pathDossierFichiersAuxiliaires+ DirectorySeparator +name,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  name := name+'(alias)';
  len := LENGTH_OF_STRING(name);
  if len <= tailleMaxNom then
    begin
		  if (err <> NoErr) then
		    begin
		      err := FileExists(pathDossierFichiersAuxiliaires+ DirectorySeparator +name,0,fic);
		      erreurEstFicNonTrouve := erreurEstFicNonTrouve or (err = fnfErr);
		    end;
		end;

  if (err <> 0) and erreurEstFicNonTrouve
    then FichierTexteDeCassioExiste := fnfErr
    else FichierTexteDeCassioExiste := err;
end;


function CreeFichierTexteDeCassio(name : String255; var fic : basicfile) : OSErr;
const tailleMaxNom = 31;
var err : OSErr;
    len,posLastDeuxPoints : SInt16;
begin
  err := -1;
  posLastDeuxPoints := LastPos( DirectorySeparator ,name);
  len := LENGTH_OF_STRING(name)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      err := CreateFile(pathDossierFichiersAuxiliaires+ DirectorySeparator +name,0,fic);
    end;
  name := name+' (1)';
  len := LENGTH_OF_STRING(name)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      if (err <> NoErr)
        then err := CreateFile(pathDossierFichiersAuxiliaires+ DirectorySeparator +name,0,fic);
    end;
  name := name+'(2)';
  len := LENGTH_OF_STRING(name)-posLastDeuxPoints;
  if len <= tailleMaxNom then
    begin
      if (err <> NoErr)
        then err := CreateFile(pathDossierFichiersAuxiliaires+ DirectorySeparator +name,0,fic);
    end;
  CreeFichierTexteDeCassio := err;
end;



procedure SelectCassioFonts(theme : SInt32);
var aux : SInt32;
    err : OSErr;
begin



    if gVersionJaponaiseDeCassio and gHasJapaneseScript
      then
        begin
          gCassioSmallFontSize   := 9;
	        gCassioNormalFontSize  := 12;
	        gCassioBigFontSize     := 24;
	        gCassioApplicationFont := GetAppFont;

	        if FontToScript(gCassioApplicationFont) <> smJapanese then
	          begin
	            aux := GetScriptVariable(smJapanese,smScriptPrefFondSize);
	            gCassioApplicationFont := HiWord(aux);
	            gCassioNormalFontSize := LoWord(aux);
	          end;
	
	        gCassioApplicationFont := MyGetFontNum('Osaka');

          gCassioRapportNormalFont := gCassioApplicationFont;
          gCassioRapportBoldFont   := gCassioApplicationFont;
          gCassioRapportBoldSize   := gCassioNormalFontSize;
          gCassioRapportNormalSize := gCassioNormalFontSize;
          gCassioRapportSmallSize  := 9;

          gCassioUseQuartzAntialiasing := false;

        end
      else
        begin
          case theme of
            kThemeBaskerville :
              begin
                gCassioUseQuartzAntialiasing := gIsRunningUnderMacOSX;

                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;

                if MyGetFontNum('Baskerville') > 0
                  then
		                begin
		                  gCassioRapportBoldSize   := 13;
		                  gCassioRapportNormalSize := 13;
		                  gCassioRapportSmallSize  := 13;

		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := MyGetFontNum('Baskerville');
		                  gCassioRapportBoldFont   := MyGetFontNum('Baskerville');
		                end
		              else
		                begin
		                  gCassioRapportBoldSize   := 12;
		                  gCassioRapportNormalSize := 12;
		                  gCassioRapportSmallSize  := 12;

		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := NewYorkID;
		                  gCassioRapportBoldFont   := NewYorkID;
		                end;
              end;
            kThemeTimesNewRoman :
              begin
                gCassioUseQuartzAntialiasing := gIsRunningUnderMacOSX;

                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;

                if MyGetFontNum('Times New Roman') > 0
                  then
		                begin
		                  gCassioRapportBoldSize   := 12;
		                  gCassioRapportNormalSize := 12;
		                  gCassioRapportSmallSize  := 12;

		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := MyGetFontNum('Times New Roman');
		                  gCassioRapportBoldFont   := MyGetFontNum('Times New Roman');
		                end
		              else
		                begin
		                  gCassioRapportBoldSize   := 12;
		                  gCassioRapportNormalSize := 12;
		                  gCassioRapportSmallSize  := 12;

		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := NewYorkID;
		                  gCassioRapportBoldFont   := NewYorkID;
		                end;
              end;
            kThemeModerne :
              begin
                gCassioUseQuartzAntialiasing := gIsRunningUnderMacOSX;

                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;

                gCassioRapportBoldSize   := 11;
                gCassioRapportNormalSize := 10;
                gCassioRapportSmallSize  := 10;

                gCassioApplicationFont   := GenevaID;
                gCassioRapportNormalFont := GenevaID;
                gCassioRapportBoldFont   := HelveticaID;

              end;
            kThemeGillSans :
              begin
                gCassioUseQuartzAntialiasing := gIsRunningUnderMacOSX;

                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;

                if MyGetFontNum('Gill Sans') > 0
                  then
		                begin
		                  gCassioRapportBoldSize   := 11;
		                  gCassioRapportNormalSize := 11;
		                  gCassioRapportSmallSize  := 11;

		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := MyGetFontNum('Gill Sans');
		                  gCassioRapportBoldFont   := MyGetFontNum('Gill Sans');
		                end
		              else
		                begin
		                  gCassioRapportBoldSize   := 9;
		                  gCassioRapportNormalSize := 9;
		                  gCassioRapportSmallSize  := 9;

		                  gCassioApplicationFont   := GenevaID;
		                  gCassioRapportNormalFont := GenevaID;
		                  gCassioRapportBoldFont   := HelveticaID;
		                end;
              end;
            kThemeMacOS9 :
              begin
                gCassioUseQuartzAntialiasing := false;

                gCassioSmallFontSize     := 9;
                gCassioNormalFontSize    := 12;
                gCassioBigFontSize       := 24;
                gCassioRapportBoldSize   := 9;
                gCassioRapportNormalSize := 9;
                gCassioRapportSmallSize  := 9;

                gCassioApplicationFont   := GenevaID;
                gCassioRapportNormalFont := GenevaID;
                gCassioRapportBoldFont   := GenevaID;
              end;
          end; {case}
        end;


  gCassioSmallFontSize := 9;

  if gCassioUseQuartzAntialiasing
    then
      begin
        err := SetAntiAliasedTextEnabled(true,9);
        EnableQuartzAntiAliasing(true);
        if windowListeOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false);
        if windowStatOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),true);
        if windowCourbeOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr),true);
        if windowAideOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wAidePtr),true);
        if windowGestionOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wGestionPtr),true);
        if windowNuageOpen then EnableQuartzAntiAliasingThisPort(GetWindowPort(wNuagePtr),true);
      end
    else
      begin
        {err := SetAntiAliasedTextEnabled(gIsRunningUnderMacOSX,9);}
        err := SetAntiAliasedTextEnabled(false,9);
        DisableQuartzAntiAliasing;
        if windowListeOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr));
        if windowStatOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr));
        if windowCourbeOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr));
        if windowAideOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wAidePtr));
        if windowGestionOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wGestionPtr));
        if windowNuageOpen then DisableQuartzAntiAliasingThisPort(GetWindowPort(wNuagePtr));
      end;

end;


const gNbLecturesDossierPolicesDeCassio : SInt32 = 0;




function LoadPolicePriveeDeCassio(var fs : fileInfo; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
var nomFichier : String255;
    fontFile : basicfile;
    err : OSErr;
    source, dest : String255;
    command, arguments : String255;
begin
 {$UNUSED pb,path}

 LoadPolicePriveeDeCassio := false;

 if not(isFolder) then
   begin
     nomFichier := GetName(fs);

     if (nomFichier = '') or (nomFichier[1] = '.') then
       exit;

     // WritelnDansRapport('Searching font ' + nomFichier + ' ...');

     err := FichierTexteDeCassioExiste(pathDossierFichiersAuxiliaires+':Fonts:' + nomFichier, fontFile);

     if err = NoErr
       then
         begin

           source := EscapeSpacesInUnixPath(MacPathToUNIXPath(pathDossierFichiersAuxiliaires+':Fonts:' + nomFichier)) ;
           dest := EscapeSpacesInUnixPath('~/Library/Fonts/' + nomFichier )  ;

           command := '/bin/cp';
           arguments :=  ' -n ' + source + '    ' + dest;

           // WritelnDansRapport(command + arguments);

           if CanStartUnixTask(command, arguments) then DoNothing;

           // WritelnDansRapport('Loading font ' + nomFichier + ' ...');
           err := LoadFont(fontFile.info);

         end;

     // WritelnNumDansRapport('err = ',err);

   end;

  LoadPolicePriveeDeCassio := false; {ne pas chercher recursivement, sinon mettre := isFolder}
end;


procedure ChargerLesPolicesPriveesDeCassio;
var fontDirectory : fileInfo;
    fic : basicfile;
    path : String255;
    err : OSErr;
begin

  if (gNbLecturesDossierPolicesDeCassio > 0)
    then exit;

  // WritelnDansRapport('Entree dans ChargerLesPolicesPriveesDeCassio');

  if FichierTexteDeCassioExiste(pathDossierFichiersAuxiliaires+':Fonts:GenBasI.ttf', fic) = NoErr then
    begin
      path := pathDossierFichiersAuxiliaires+':Fonts:';

      // WritelnDansRapport('dans ChargerLesPolicesPriveesDeCassio, path = ' + path);

      err := MakeFileInfo(path,fontDirectory);
      if (err = 0) then err := SetPathOfScannedDirectory(fontDirectory);
      if (err = 0) then err := ScanDirectory(fontDirectory,LoadPolicePriveeDeCassio);

    end;

  inc(gNbLecturesDossierPolicesDeCassio);
  if (gNbLecturesDossierPolicesDeCassio < 0) then gNbLecturesDossierPolicesDeCassio := 1;

  // WritelnNumDansRapport('dans ChargerLesPolicesPriveesDeCassio,  gNbLecturesDossierPolicesDeCassio = ',gNbLecturesDossierPolicesDeCassio);
end;


function GetCassioFontNum(nomPolice : String255) : SInt32;
var policeID : SInt32;
begin

  if (nomPolice = '') then
    begin
      GetCassioFontNum := 0;
      exit;
    end;

  policeID := MyGetFontNum(nomPolice);

  if (policeID = 0) and (nomPolice = 'Fontin')                 then policeID := GetCassioFontNum('Fontin Regular');
  if (policeID = 0) and (nomPolice = 'New Century Schoolbook') then policeID := GetCassioFontNum('New Century Schoolbook Roman');
  if (policeID = 0) and (nomPolice = 'Gentium')                then policeID := GetCassioFontNum('Gentium Basic');

  // WritelnNumDansRapport(nomPolice + '  =>  policeID = ',policeID);

  if (policeID = 0) and (gNbLecturesDossierPolicesDeCassio <= 0) then
    begin
       ChargerLesPolicesPriveesDeCassio;
       policeID := GetCassioFontNum(nomPolice);
    end;


  GetCassioFontNum := policeID;
end;



procedure ForconsLePlantageDeCassio;
var i,x,y : SInt32;
begin

  x := 5;

  if Abs(Random16()) < -20
    then y := 10
    else y := 0;

  if (x div y) > 10 then WritelnDansRapport('Oula !');

  IndexInfoDejaCalculeesCoupNro := IndexInfoDejaCalculeesCoupNroHdl(-23);
  i := -Abs(Random32());
  IndexInfoDejaCalculeesCoupNro^^[i] := 1000;
  MemoryFillChar(IndexInfoDejaCalculeesCoupNro^,sizeof(t_IndexInfoDejaCalculeesCoupNro),chr(0));

end;


function HasGestaltAttr(itsAttr : OStype; itsBit : SInt16) : boolean;
	var
		response : SInt32;
begin
	HasGestaltAttr := (Gestalt(itsAttr, response) = noErr) and (BTST(response, itsBit));
end;


const gTestDeLaVersionFrancaiseInitialised : boolean = false;
var gVersionFrancaiseDeCassio : boolean;


function EstLaVersionFrancaiseDeCassio : boolean;
var s : String255;
begin

  if not(gTestDeLaVersionFrancaiseInitialised) then
    begin
      s := ReadStringFromRessource(TextesDiversID,2);  {sans titre}
      gVersionFrancaiseDeCassio := (s = 'sans titre');
      gTestDeLaVersionFrancaiseInitialised := true;
    end;

  EstLaVersionFrancaiseDeCassio := gVersionFrancaiseDeCassio;
end;


function EstLaVersionJaponaiseDeCassio : boolean;
begin
  EstLaVersionJaponaiseDeCassio := gVersionJaponaiseDeCassio;
end;


function EstLaVersionAnglaiseDeCassio : boolean;
begin
  EstLaVersionAnglaiseDeCassio := not(EstLaVersionFrancaiseDeCassio or EstLaVersionJaponaiseDeCassio);
end;


const gListOfValidCassioFoldersInitialised : boolean = false;
const kMaxCassioFolderPaths = 10;

var gListeOfValidCassioFolders :
      record
        compteur : SInt32;
        paths : array[1..kMaxCassioFolderPaths] of String255;
      end;

procedure InitListeOfValidCassioFolders;
var k : SInt32;
begin
  if not(gListOfValidCassioFoldersInitialised) then
    begin
      for k := 1 to kMaxCassioFolderPaths do
        gListeOfValidCassioFolders.paths[k] := '';

      gListOfValidCassioFoldersInitialised := true;
    end;
end;

procedure SauvegarderListeOfCassioFolderPaths;
var filename : String255;
    appSupportPath : String255;
    erreurES : OSErr;
    fic : basicfile;
    s : String255;
    i : SInt32;
begin

  if (GetPathOfApplicationSupportFolder(appSupportPath) = NoErr) then
    begin

      // WritelnDansRapport('Entree dans SauvegarderListeOfCassioFolderPaths');

      filename := appSupportPath + ':Cassio:CassioFolderPathsList.txt';

      erreurES := CreateDirectoryWithThisPath(ExtraitCheminDAcces(filename));

      erreurES := FileExists(filename,0,fic);
      if (erreurES = fnfErr)   {fnfErr => File not found }
        then erreurES := CreateFile(fileName,0,fic);
      if erreurES = NoErr {le fichier de la liste des dossier Cassio existe : on l'ouvre et on le vide}
        then
          begin
            erreurES := OpenFile(fic);
            erreurES := ClearFileContent(fic);
          end;
      if erreurES <> 0 then exit;

      for i := 1 to kMaxCassioFolderPaths do
        if (gListeOfValidCassioFolders.paths[i] <> '') then
          begin
            s := gListeOfValidCassioFolders.paths[i];
            erreurES := Writeln(fic,s);
          end;

      erreurES := CloseFile(fic);

    end;
end;


procedure LireListeOfCassioFolderPaths;
var filename : String255;
    applicationSupportPath : String255;
    erreurES : OSErr;
    fic : basicfile;
    s : String255;
    i,nbPathsCassioFolder : SInt32;
begin

  if gListOfValidCassioFoldersInitialised
    then exit;

  if (GetPathOfApplicationSupportFolder(applicationSupportPath) = NoErr) then
    begin

      InitListeOfValidCassioFolders;

      (* vider la liste *)
      for i := 1 to kMaxCassioFolderPaths do
        gListeOfValidCassioFolders.paths[i] := '';

      // WritelnDansRapport('Entree dans LireListeOfCassioFolderPaths');

      filename := applicationSupportPath + ':Cassio:CassioFolderPathsList.txt';
      erreurES := FileExists(filename,0,fic);
      if erreurES = NoErr
        then erreurES := OpenFile(fic);
      if erreurES <> 0 then exit;


      nbPathsCassioFolder := 0;
      repeat
        erreurES := Readln(fic,s);
        if (s <> '') and (erreurES = NoErr) then
          begin
            inc(nbPathsCassioFolder);
            gListeOfValidCassioFolders.paths[nbPathsCassioFolder] := s;
          end;
      until (nbPathsCassioFolder >= kMaxCassioFolderPaths) or (erreurES <> NoErr) or EndOfFile(fic,erreurES);

      erreurES := CloseFile(fic);

    end;
end;


procedure AddValidCassioFolderPath(whichPath : String255);
var k : SInt32;
    applicationSupportPath : String255;
    trouve : boolean;
begin
  if (whichPath <> '') and (GetPathOfApplicationSupportFolder(applicationSupportPath) = NoErr) then
    begin

      (* ne pas ajouter le path du dossier si on a l'impression que Cassio
         a été lancé depuis une image disque (.dmg) : c'est sans doute
         un volume temporaire... *)
      if (ExtraitNomDeVolume(whichPath) <> ExtraitNomDeVolume(applicationSupportPath)) then
        begin
          gCassioSansDouteLanceDepuisUneImageDisque := true;
          exit;
        end;

      (* Lire la liste si necessaire *)
      LireListeOfCassioFolderPaths;

      (* si le path donne est dejà dans la liste, il n'y a rien a faire *)
      for k := 1 to kMaxCassioFolderPaths do
        if (whichPath = gListeOfValidCassioFolders.paths[k]) then
          exit;

      trouve := false;
      for k := 1 to kMaxCassioFolderPaths do
        if (gListeOfValidCassioFolders.paths[k] = '') then
          begin
            trouve := true;   // on a trouve une place libre
            gListeOfValidCassioFolders.paths[k] := whichPath;
            leave;
          end;
      if not(trouve) then gListeOfValidCassioFolders.paths[1] := whichPath; // sinon on le met en tete

      SauvegarderListeOfCassioFolderPaths;

    end;
end;

function BeginIterationOnCassioFolderPaths(firstPathToTry : String255) : String255;
begin
  gListeOfValidCassioFolders.compteur := 0;
  BeginIterationOnCassioFolderPaths := firstPathToTry;
end;


function TryNextCassioFolderPath : String255;
begin
  with gListeOfValidCassioFolders do
    begin
      if (compteur = 0)
        then LireListeOfCassioFolderPaths;


      inc(compteur);
      if (compteur >= 1) and (compteur <= kMaxCassioFolderPaths)
        then TryNextCassioFolderPath := gListeOfValidCassioFolders.paths[compteur]
        else TryNextCassioFolderPath := '';
    end;

end;


function GetFunctionPointerFromCassioPrivateFramework(const whichFramework,functionName : String255) : Ptr;
var result : Ptr;
begin
  result := GetFunctionPointerFromPrivateBundle(whichFramework, functionName);

  GetFunctionPointerFromCassioPrivateFramework := result;
end;





END.

















