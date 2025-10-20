UNIT UnitEnvirons;



INTERFACE


 USES UnitDefCassio;




{ Version de Cassio, par exemple "7.5" }
function VersionDeCassioEnString : String255;

{ Paths complets vers les dossiers de Cassio }
function DetermineVolumeApplication : String255;
function DeterminePathDossierFichiersAuxiliaires(whichVolumeRefCassio : String255) : String255;
function DeterminePathDossierOthelliersCassio(whichVolumeRefCassio : String255) : String255;

{ Noms de l'utilisateur et de l'executable }
function GetUserName : String255;
function GetApplicationName(default : String255) : String255;
function GetApplicationBundleName : String255;

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
    , MyStrings, UnitServicesMemoire, MyFileSystemUtils, MyFonts, MyAntialiasing, UnitFichiersTEXT, MyMathUtils, UnitCarbonisation
    , UnitRapport, UnitEngine, UnitGestionDuTemps, UnitTournoi ;
{$ELSEC}
    ;
    {$I prelink/Environs.lk}
{$ENDC}


{END_USE_CLAUSE}

const gCassioSansDouteLanceDepuisUneImageDisque : boolean = false;


function VersionDeCassioEnString : String255;
begin
  VersionDeCassioEnString := '8.4';
end;



function DetermineVolumeApplication : String255;
var myStringPtr : StringPtr;
    refvol : SInt16;
    codeErreur : OSErr;
    dirID : UInt32;
    myPath : String255;
    myFSSpec : FSSpec;
    left,right : String255;
begin
   myStringPtr := StringPtr(AllocateMemoryPtr(sizeof(str255)));
   codeErreur := HGetVol(myStringPtr,refvol,dirID);
   DisposeMemoryPtr(Ptr(myStringPtr));

   myPath := GetWDName(refvol);

   // On gere le cas ou Cassio est une application sous forme de bundle

   SplitRightByStr (myPath , ':Contents:' , left , right );
   if (left <> '') & (right <> '') then
     begin
       myPath := left;
       SplitRightByStr (myPath , ':' , left , right );
       if (left <> '') & (right <> '') then
         begin
           left := left + ':';
           codeErreur := MyFSMakeFSSpec(0,0,left,myFSSpec);
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

   SplitRightByStr (myPath , ':Contents:' , left , right );

   CassioEstUnBundleApplicatif := (left <> '') & (right <> '');
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

   SplitRightByStr (myPath , ':Contents:' , left , right );
   if (left <> '') & (right <> '')
     then
       begin
         myPath := left;
         SplitRightByStr(myPath, ':' , left , right);
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
		myFSSpec : FSSpec;
		myString : Str255;
begin
	GetApplicationName := default;  {nom par défaut si le reste ne marche pas, e.g. sur un PC}

	if not(HasGestaltAttr(gestaltOSAttr, gestaltLaunchControl)) then
		exit(GetApplicationName);

	CurrentPSN.highLongOfPSN := 0;
	CurrentPSN.lowLongOfPSN := kCurrentProcess;

	err := GetCurrentProcess(CurrentPSN);
	if err <> 0 then
		exit(GetApplicationName);

	ProcessInfo.processInfoLength := sizeof(ProcessInfoRec);
	ProcessInfo.processName := @myString;
	ProcessInfo.processAppSpec := @myFSSpec;

	err := GetProcessInformation(CurrentPSN, ProcessInfo);
	if err <> 0 then
		exit(GetApplicationName)
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

function DeterminePathDossierFichiersAuxiliaires(whichVolumeRefCassio : String255) : String255;
var myFSSpec : FSSpec;
    err : OSErr;
    fullPath : String255;
    iterateurCassioFolderPaths : String255;
begin

  iterateurCassioFolderPaths := BeginIterationOnCassioFolderPaths(whichVolumeRefCassio);

  repeat
    err := -1;

    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Fichiers auxiliaires',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Fichiers-auxiliaires',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Fichiers auxiliaires Cassio',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Fichiers-auxiliaires-Cassio',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Auxilary files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Auxilary-files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Auxiliary files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Auxiliary-files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Cassio files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Cassio-files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Cassio auxilary files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Cassio-auxilary-files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Cassio auxiliary files',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Cassio-auxiliary-files',myFSSpec);

    if err = NoErr
      then
        begin
          MyResolveAliasFile(myFSSpec);
          err := FSSpecToFullPath(myFSSpec,fullPath);

          if err = NoErr then AddValidCassioFolderPath(iterateurCassioFolderPaths);

          DeterminePathDossierFichiersAuxiliaires := fullPath;
          {WritelnDansRapport('Branche de reussite dans DeterminePathDossierFichiersAuxiliaires : '+fullPath);}
        end
      else
        iterateurCassioFolderPaths := TryNextCassioFolderPath;

  until (err = NoErr) | (iterateurCassioFolderPaths = '');

  if err <> NoErr then  { desespoir !! }
      begin
        err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths,myFSSpec);
        MyResolveAliasFile(myFSSpec);
        err := FSSpecToFullPath(myFSSpec,fullPath);

        DeterminePathDossierFichiersAuxiliaires := fullPath;
        {WritelnDansRapport('Branche d''echec dans DeterminePathDossierFichiersAuxiliaires : '+fullPath);}
      end
end;


function DeterminePathDossierOthelliersCassio(whichVolumeRefCassio : String255) : String255;
var myFSSpec : FSSpec;
    err : OSErr;
    fullPath : String255;
    iterateurCassioFolderPaths : String255;
begin
  iterateurCassioFolderPaths := BeginIterationOnCassioFolderPaths(whichVolumeRefCassio);

  repeat

    err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Othelliers Cassio',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Othelliers Cassio (alias)',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Othelliers',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Boards',myFSSpec);
    if err <> 0 then err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths+'Boards Cassio',myFSSpec);

    if err = 0
      then
        begin
          MyResolveAliasFile(myFSSpec);
          err := FSSpecToFullPath(myFSSpec,fullPath);

          if err = NoErr then AddValidCassioFolderPath(iterateurCassioFolderPaths);

          DeterminePathDossierOthelliersCassio := fullPath;
          {WritelnDansRapport('Branche de reussite dans DeterminePathDossierOthelliersCassio : '+fullPath);}
        end
      else
        iterateurCassioFolderPaths := TryNextCassioFolderPath;

  until (err = NoErr) | (iterateurCassioFolderPaths = '');


  if (err <> 0) then
    begin  { desespoir !! }
      err := MyFSMakeFSSpec(0,0,iterateurCassioFolderPaths,myFSSpec);
      MyResolveAliasFile(myFSSpec);
      err := FSSpecToFullPath(myFSSpec,fullPath);
      DeterminePathDossierOthelliersCassio := fullPath;
      {WritelnDansRapport('Branche d''echec dans DeterminePathDossierOthelliersCassio : '+fullPath);}
    end

end;




procedure SelectCassioFonts(theme : SInt32);
var aux : SInt32;
    err : OSErr;
begin



    if gVersionJaponaiseDeCassio & gHasJapaneseScript
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




function LoadPolicePriveeDeCassio(var fs : FSSpec; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
var nomFichier : String255;
    fontFile : FichierTEXT;
    err : OSErr;
    source, dest : String255;
    command, arguments : String255;
begin
 {$UNUSED pb,path}

 LoadPolicePriveeDeCassio := false;

 if not(isFolder) then
   begin
     nomFichier := GetNameOfFSSpec(fs);

     if (nomFichier = '') | (nomFichier[1] = '.') then
       exit(LoadPolicePriveeDeCassio);

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
           err := LoadFont(fontFile.theFSSpec);

         end;

     // WritelnNumDansRapport('err = ',err);

   end;

  LoadPolicePriveeDeCassio := false; {ne pas chercher recursivement, sinon mettre := isFolder}
end;


procedure ChargerLesPolicesPriveesDeCassio;
var fontDirectory : FSSpec;
    fic : FichierTEXT;
    path : String255;
    err : OSErr;
begin

  if (gNbLecturesDossierPolicesDeCassio > 0)
    then exit(ChargerLesPolicesPriveesDeCassio);

  // WritelnDansRapport('Entree dans ChargerLesPolicesPriveesDeCassio');

  if FichierTexteDeCassioExiste(pathDossierFichiersAuxiliaires+':Fonts:GenBasI.ttf', fic) = NoErr then
    begin
      path := pathDossierFichiersAuxiliaires+':Fonts:';

      // WritelnDansRapport('dans ChargerLesPolicesPriveesDeCassio, path = ' + path);

      err := MyFSMakeFSSpec(0,0,path,fontDirectory);
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
      exit(GetCassioFontNum);
    end;

  policeID := MyGetFontNum(nomPolice);

  if (policeID = 0) & (nomPolice = 'Fontin')                 then policeID := GetCassioFontNum('Fontin Regular');
  if (policeID = 0) & (nomPolice = 'New Century Schoolbook') then policeID := GetCassioFontNum('New Century Schoolbook Roman');
  if (policeID = 0) & (nomPolice = 'Gentium')                then policeID := GetCassioFontNum('Gentium Basic');

  // WritelnNumDansRapport(nomPolice + '  =>  policeID = ',policeID);

  if (policeID = 0) & (gNbLecturesDossierPolicesDeCassio <= 0) then
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

  if Abs(Random) < -20
    then y := 10
    else y := 0;

  if (x div y) > 10 then WritelnDansRapport('Oula !');

  IndexInfoDejaCalculeesCoupNro := IndexInfoDejaCalculeesCoupNroHdl(-23);
  i := -Abs(RandomLongint);
  IndexInfoDejaCalculeesCoupNro^^[i] := 1000;
  MemoryFillChar(IndexInfoDejaCalculeesCoupNro^,sizeof(t_IndexInfoDejaCalculeesCoupNro),chr(0));

end;


function HasGestaltAttr(itsAttr : OStype; itsBit : SInt16) : boolean;
	var
		response : SInt32;
begin
	HasGestaltAttr := (Gestalt(itsAttr, response) = noErr) & (BTST(response, itsBit));
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
  EstLaVersionAnglaiseDeCassio := not(EstLaVersionFrancaiseDeCassio | EstLaVersionJaponaiseDeCassio);
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
    fic : FichierTEXT;
    s : String255;
    i : SInt32;
begin

  if (GetPathOfApplicationSupportFolder(appSupportPath) = NoErr) then
    begin

      // WritelnDansRapport('Entree dans SauvegarderListeOfCassioFolderPaths');

      filename := appSupportPath + ':Cassio:CassioFolderPathsList.txt';

      erreurES := CreateDirectoryWithThisPath(ExtraitCheminDAcces(filename));

      erreurES := FichierTexteExiste(filename,0,fic);
      if (erreurES = -43)   {fnfErr => File not found }
        then erreurES := CreeFichierTexte(fileName,0,fic);
      if erreurES = NoErr {le fichier de la liste des dossier Cassio existe : on l'ouvre et on le vide}
        then
          begin
            erreurES := OuvreFichierTexte(fic);
            erreurES := VideFichierTexte(fic);
          end;
      if erreurES <> 0 then exit(SauvegarderListeOfCassioFolderPaths);

      for i := 1 to kMaxCassioFolderPaths do
        if (gListeOfValidCassioFolders.paths[i] <> '') then
          begin
            s := gListeOfValidCassioFolders.paths[i];
            erreurES := WritelnDansFichierTexte(fic,s);
          end;

      erreurES := FermeFichierTexte(fic);

    end;
end;


procedure LireListeOfCassioFolderPaths;
var filename : String255;
    applicationSupportPath : String255;
    erreurES : OSErr;
    fic : FichierTEXT;
    s : String255;
    i,nbPathsCassioFolder : SInt32;
begin

  if gListOfValidCassioFoldersInitialised
    then exit(LireListeOfCassioFolderPaths);

  if (GetPathOfApplicationSupportFolder(applicationSupportPath) = NoErr) then
    begin

      InitListeOfValidCassioFolders;

      (* vider la liste *)
      for i := 1 to kMaxCassioFolderPaths do
        gListeOfValidCassioFolders.paths[i] := '';

      // WritelnDansRapport('Entree dans LireListeOfCassioFolderPaths');

      filename := applicationSupportPath + ':Cassio:CassioFolderPathsList.txt';
      erreurES := FichierTexteExiste(filename,0,fic);
      if erreurES = NoErr
        then erreurES := OuvreFichierTexte(fic);
      if erreurES <> 0 then exit(LireListeOfCassioFolderPaths);


      nbPathsCassioFolder := 0;
      repeat
        erreurES := ReadlnDansFichierTexte(fic,s);
        if (s <> '') & (erreurES = NoErr) then
          begin
            inc(nbPathsCassioFolder);
            gListeOfValidCassioFolders.paths[nbPathsCassioFolder] := s;
          end;
      until (nbPathsCassioFolder >= kMaxCassioFolderPaths) | (erreurES <> NoErr) | EOFFichierTexte(fic,erreurES);

      erreurES := FermeFichierTexte(fic);

    end;
end;


procedure AddValidCassioFolderPath(whichPath : String255);
var k : SInt32;
    applicationSupportPath : String255;
    trouve : boolean;
begin
  if (whichPath <> '') & (GetPathOfApplicationSupportFolder(applicationSupportPath) = NoErr) then
    begin

      (* ne pas ajouter le path du dossier si on a l'impression que Cassio
         a été lancé depuis une image disque (.dmg) : c'est sans doute
         un volume temporaire... *)
      if (ExtraitNomDeVolume(whichPath) <> ExtraitNomDeVolume(applicationSupportPath)) then
        begin
          gCassioSansDouteLanceDepuisUneImageDisque := true;
          exit(AddValidCassioFolderPath);
        end;

      (* Lire la liste si necessaire *)
      LireListeOfCassioFolderPaths;

      (* si le path donne est dejà dans la liste, il n'y a rien a faire *)
      for k := 1 to kMaxCassioFolderPaths do
        if (whichPath = gListeOfValidCassioFolders.paths[k]) then
          exit(AddValidCassioFolderPath);

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
      if (compteur >= 1) & (compteur <= kMaxCassioFolderPaths)
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

















