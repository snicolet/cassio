UNIT UnitPrefs;






INTERFACE







USES UnitDefCassio , QuickDraw, UnitDefParallelisme;





procedure NumEnStringFormatee(num : SInt32; formatage : SInt16; var s : String255);
function StringFormateeEnNumFromPos(formatage : SInt16; s : String255; index : SInt16) : SInt32;
function StringFormateeEnNum(formatage : SInt16; var s : String255) : SInt32;
function FenetreEnChaine(ouverte : boolean; theWindow : WindowPtr;unRect : rect) : String255;
procedure ChaineEnFenetre(s : String255; var ouverte : boolean; var RectangleFenetre : rect);
procedure ChaineEnRect(s : String255; var UnBool : boolean; var Rectangle : rect);


procedure CreeFichierPreferences;
procedure LitFichierPreferences;
procedure GetPartiesAReouvrirFromPrefsFile;
procedure GereSauvegardePreferences;


function NameOfPrefsFile : String255;
procedure SauvegarderListeOfPrefsFiles;
procedure LireListeOfPrefsFiles;
procedure AjouterNomDansListOfPrefsFiles(whichName : String255);


procedure DoDialoguePreferences;
procedure DoDialoguePreferencesAffichage;
procedure DoDialoguePreferencesSpeciales;

procedure CreeFichierGroupes;
procedure LitFichierGroupes;


procedure InstallerFichierCronjob(nomFichierCronjob : String255);


function OpenPrefsFileForSequentialReading : OSErr;
function GetNextLineInPrefsFile(var s : String255) : OSErr;
function EOFInPrefsFile : boolean;
function ClosePrefsFile : OSErr;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, UnitDebuggage, fp, MacWindows, OSUtils, UnitDefEngine
{$IFC NOT(USE_PRELINK)}
    , Zebra_to_Cassio, UnitUtilitaires
    , UnitRapport, UnitTroisiemeDimension, UnitZoo, UnitCurseur, UnitServicesDialogs, UnitNotesSurCases, UnitRapportImplementation, UnitBufferedPICT
    , UnitFenetres, UnitScannerUtils, UnitAffichageArbreDeJeu, UnitArbreDeJeuCourant, UnitNewGeneral, UnitGameTree, UnitJaponais, UnitGestionDuTemps
    , UnitMenus, UnitEvaluation, UnitServicesDialogs, UnitFichierPhotos, UnitSaisiePartie, MyStrings, UnitEntreeTranscript, UnitDialog
    , UnitNouveauFormat, UnitCarbonisation, UnitVieilOthelliste, UnitNormalisation, UnitCouleur, UnitListe, UnitJeu, UnitProblemeDePriseDeCoin
    , UnitParallelisme, MyMathUtils, SNMenus, MyUtils, SNEvents, UnitEngine, UnitEnvirons, UnitOth2
    , UnitFichiersTEXT, UnitServicesRapport, UnitAffichagePlateau, UnitActions, UnitEnvirons, UnitImportDesNoms ;
{$ELSEC}
    ;
    {$I prelink/Prefs.lk}
{$ENDC}


{END_USE_CLAUSE}








const kMaxPrefFiles = 10;
const kNomParDefauFichierPreferences = 'Préférences Cassio';

var gPrefsFileInfos : record
                       filePtr : FichierTEXT;
                       nbOfLastLineRead : SInt16;
                       lastLineRead : String255;
                      end;

    gListeOfPrefFiles : array[1..kMaxPrefFiles] of
                          record
                            date,name : String255;
                          end;

procedure NumEnStringFormatee(num : SInt32; formatage : SInt16; var s : String255);
var s1 : String255;
    longueur,i : SInt16;
    aux : SInt32;
begin
  s1 := '';
  aux := num;
  s1 := IntToStr(aux);
  longueur := LENGTH_OF_STRING(s1);
  if longueur > formatage then {erreur de formatage ! On n'a pas prevu assez de place pour cette valeur…}
    begin
      s1 := '';
      longueur := 0;
    end;
  for i := 1 to formatage-longueur do s1 := CharToString('0')+s1;
  s := Concat(s,s1);
end;


function StringFormateeEnNumFromPos(formatage : SInt16; s : String255; index : SInt16) : SInt32;
var s1 : String255;
    i : SInt16;
    aux : SInt32;
begin
  s1 := '';
  for i := index to index + formatage - 1 do s1 := s1 + s[i];
  for i := 1 to LENGTH_OF_STRING(s1) - 1 do
    if s1[1] = '0' then s1 := TPCopy(s1,2,LENGTH_OF_STRING(s1)-1);
  ChaineToLongint(s1,aux);
  StringFormateeEnNumFromPos := aux;
end;


function StringFormateeEnNum(formatage : SInt16; var s : String255) : SInt32;
begin
  StringFormateeEnNum := StringFormateeEnNumFromPos(formatage,s,1);
  s := TPCopy(s,formatage+1,LENGTH_OF_STRING(s)-formatage);
end;



function FenetreEnChaine(ouverte : boolean; theWindow : WindowPtr;unRect : rect) : String255;
var s1 : String255;
    oldPort : grafPtr;
begin
  s1 := '';
  if ouverte then s1 := s1 + CharToString('Y') else s1 := s1 + CharToString('N');
  if ouverte and (theWindow <> NIL) then   {si la fenetre est ouverte,mettre à jour son rectangle }
    begin
      GetPort(oldPort);
      SetPortByWindow(theWindow);
      unRect := GetWindowPortRect(theWindow);
      LocalToGlobal(unRect.topleft);
      LocalToGlobal(unRect.botright);
      SetPort(oldPort);
    end;
  NumEnStringFormatee(unRect.left,4,s1);
  NumEnStringFormatee(unRect.top,4,s1);
  NumEnStringFormatee(unRect.right,4,s1);
  NumEnStringFormatee(unRect.bottom,4,s1);
  FenetreEnChaine := s1;
end;


procedure ChaineEnFenetre(s : String255; var ouverte : boolean; var RectangleFenetre : rect);
var unRect : rect;
    rectangleOK : boolean;
begin
  ouverte := s[1] = 'Y';
  unRect.left := StringFormateeEnNumFromPos(4,s,2);
  unRect.top := StringFormateeEnNumFromPos(4,s,6);
  unRect.right := StringFormateeEnNumFromPos(4,s,10);
  unRect.bottom := StringFormateeEnNumFromPos(4,s,14);

  if unRect.bottom > GetScreenBounds.bottom - 2 then unRect.bottom := GetScreenBounds.bottom - 2;
  if unRect.right  > GetScreenBounds.right  - 2 then unRect.right  := GetScreenBounds.right  - 2;

  if unRect.right < unRect.left then unRect.right := unRect.left + 40;
  if unRect.bottom < unRect.top then unRect.bottom := unRect.top + 40;

  {if debuggage.general then
   with unRect do
    begin
      Writestringandbooleanat('ouverte : ', (s[1] = 'Y'),10,10);
      WriteNumAt('top = ',top,10,30);
      WriteNumAt('left = ',left,10,20);
      WriteNumAt('bottom = ',bottom,10,50);
      WriteNumAt('right = ',right,10,40);
      WriteNumAt('marge haut = ',top-GetScreenBounds.top,10,100);
      WriteNumAt('marge gauche = ',left-GetScreenBounds.left,10,90);
      WriteNumAt('marge bas = ',GetScreenBounds.bottom-top,10,120);
      WriteNumAt('marge droite = ',GetScreenBounds.right-left,10,110);
      SysBeep(0);
      AttendFrappeClavier;
    end;
  }
  rectangleOK := unRect.top > 21;
  rectangleOK := rectangleOK and (unRect.right-unRect.left >= 20) and (unRect.bottom-unRect.top >= 20);
  with GetScreenBounds do
    begin
      rectangleOK := rectangleOK and (unRect.left <= right-15) and (unRect.top <= bottom-15);
      rectangleOK := rectangleOK and (unRect.right > 0) and (unRect.bottom > 20);
    end;
  if rectangleOK then RectangleFenetre := unRect;
end;


procedure ChaineEnRect(s : String255; var UnBool : boolean; var Rectangle : rect);
var unRect : rect;
begin
  UnBool := s[1] = 'Y';
  unRect.left := StringFormateeEnNumFromPos(4,s,2);
  unRect.top := StringFormateeEnNumFromPos(4,s,6);
  unRect.right := StringFormateeEnNumFromPos(4,s,10);
  unRect.bottom := StringFormateeEnNumFromPos(4,s,14);
  if unRect.right < unRect.left then unRect.right := unRect.left+40;
  if unRect.bottom < unRect.top then unRect.bottom := unRect.top+40;
  {if debuggage.general then
   with unRect do
    begin
      Writestringandbooleanat('ouverte : ', (s[1] = 'Y'),10,10);
      WriteNumAt('top = ',top,10,30);
      WriteNumAt('left = ',left,10,20);
      WriteNumAt('bottom = ',bottom,10,50);
      WriteNumAt('right = ',right,10,40);
      WriteNumAt('marge haut = ',top-GetScreenBounds.top,10,100);
      WriteNumAt('marge gauche = ',left-GetScreenBounds.left,10,90);
      WriteNumAt('marge bas = ',GetScreenBounds.bottom-top,10,120);
      WriteNumAt('marge droite = ',GetScreenBounds.right-left,10,110);
      SysBeep(0);
      AttendFrappeClavier;
    end;
  }
  Rectangle := unRect;
end;


procedure ParamDiagRecEnChaine(paramDiag : ParamDiagRec; var s : String255);
var aux : SInt16;
begin
  s := '';
  with paramDiag do
    begin
      if CoordonneesFFORUM          then s := Concat(s,'Y') else s := Concat(s,'N');
      if PionsEnDedansFFORUM        then s := Concat(s,'Y') else s := Concat(s,'N');
      if DessineCoinsDuCarreFFORUM  then s := Concat(s,'Y') else s := Concat(s,'N');
      if TraitsFinsFFORUM           then s := Concat(s,'Y') else s := Concat(s,'N');
      if EcritApres37c7FFORUM       then s := Concat(s,'Y') else s := Concat(s,'N');
      if EcritNomsJoueursFFORUM     then s := Concat(s,'Y') else s := Concat(s,'N');
      if EcritNomTournoiFFORUM      then s := Concat(s,'Y') else s := Concat(s,'N');
      if NumerosSeulementFFORUM     then s := Concat(s,'Y') else s := Concat(s,'N');
      s := Concat(s,'&');   {ou n'importe quoi, unused }
      NumEnStringFormatee(DecalageHorFFORUM,5,s);
      NumEnStringFormatee(DecalageVertFFORUM,5,s);
      NumEnStringFormatee(tailleCaseFFORUM,5,s);
      NumEnStringFormatee(RoundToL(epaisseurCadreFFORUM*100),5,s);
      NumEnStringFormatee(distanceCadreFFORUM,5,s);
      NumEnStringFormatee(nbPixelDedansFFORUM,5,s);
      NumEnStringFormatee(PoliceFFORUMID,8,s);
      NumEnStringFormatee(TypeDiagrammeFFORUM,5,s);
      NumEnStringFormatee(FondOthellierPatternFFORUM,5,s);
      NumEnStringFormatee(CouleurOthellierFFORUM,5,s);
      if DessinePierresDeltaFFORUM then s := Concat(s,'Y') else s := Concat(s,'N');
      for aux := 1 to 8 do
        if (aux <= LENGTH_OF_STRING(GainTheoriqueFFORUM))
          then s := Concat(s,GainTheoriqueFFORUM[aux])
          else s := Concat(s,'&');
    end;
end;


procedure ChaineEnParamDiagRec(s : String255; var paramDiag : ParamDiagRec);
var aux : SInt32;
begin
  with paramDiag do
    begin
      CoordonneesFFORUM          := s[1] = 'Y';
      PionsEnDedansFFORUM        := s[2] = 'Y';
      DessineCoinsDuCarreFFORUM  := s[3] = 'Y';
      TraitsFinsFFORUM           := s[4] = 'Y';
      EcritApres37c7FFORUM       := s[5] = 'Y';
      EcritNomsJoueursFFORUM     := s[6] = 'Y';
      EcritNomTournoiFFORUM      := s[7] = 'Y';
      NumerosSeulementFFORUM     := s[8] = 'Y';
      {GainTheoriqueFFORUM       := s[9];}    {deprecated, see below}
      DecalageHorFFORUM          := StringFormateeEnNumFromPos(5,s,10);
      DecalageVertFFORUM         := StringFormateeEnNumFromPos(5,s,15);
      tailleCaseFFORUM           := StringFormateeEnNumFromPos(5,s,20);
      aux := StringFormateeEnNumFromPos(5,s,25);
      if aux <= 5
        then epaisseurCadreFFORUM := (aux*1.0)  {ca vient sans doute d'un ancien format des préférences}
        else epaisseurCadreFFORUM := (aux/100.0);
      distanceCadreFFORUM        := StringFormateeEnNumFromPos(5,s,30);
      nbPixelDedansFFORUM        := StringFormateeEnNumFromPos(5,s,35);
      PoliceFFORUMID             := StringFormateeEnNumFromPos(8,s,40);
      TypeDiagrammeFFORUM        := StringFormateeEnNumFromPos(5,s,48);
      FondOthellierPatternFFORUM := StringFormateeEnNumFromPos(5,s,53);
      CouleurOthellierFFORUM     := StringFormateeEnNumFromPos(5,s,58);
      DessinePierresDeltaFFORUM  := s[63] = 'Y';
      GainTheoriqueFFORUM := '';
      for aux := 0 to 7 do
        if s[64+aux] <> '&'
          then GainTheoriqueFFORUM := GainTheoriqueFFORUM + s[64+aux];
    end;
end;


procedure DecodeChaineSolitairesDemandes(s1 : String255);
var i,len : SInt32;
begin
  len := LENGTH_OF_STRING(s1);
  for i := 1 to 64 do
    if len >= i then SolitairesDemandes[i] :=   (s1[i] = 'Y');
end;

function CodeChaineSolitairesDemandes : String255;
var s : String255;
    i : SInt32;
begin
  s := '';
  for i := 1 to 64 do
    if SolitairesDemandes[i]
      then s := s + 'Y'
      else s := s + 'N';
  CodeChaineSolitairesDemandes := s;
end;




procedure CodeChainePref(var s1,s2 : String255);
var bidbool : boolean;
begin
    begin
      s1 := '';
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if EnVieille3D                                    then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool(*OthelloTorique*)                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecSon                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecProgrammation                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if gEcranCouleur                                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if OrdreDuTriRenverse                             then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheBibl                                    then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.general                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheNumeroCoup                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheSuggestionDeCassio                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheMeilleureSuite                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecEvaluationTotale                           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool(*avecDessinCoupEnTete*)                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if referencesCompletes                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if PionClignotant                                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if LectureAntichronologique                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if decrementetemps                                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if SupprimerLesEffetsDeZoom                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if OptimisePourKaleidoscope                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if affichageReflexion.doitAfficher                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheGestionTemps                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if jeuInstantane                                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecSauvegardePref                             then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecAlerteNouvInterversion                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecSystemeCoordonnees                         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if ToujoursIndexerBase                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecSelectivite                                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecNomOuvertures                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if neJamaisTomber                                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if doitConfirmerQuitter                           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecTestBibliotheque                           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if InfosTechniquesDansRapport                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheInfosApprentissage                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if UtiliseGrapheApprentissage                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if LaDemoApprend                                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      with gEntrainementOuvertures do begin
      if CassioVarieSesCoups                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if CassioSeContenteDeLaNulle                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      end; {with gEntrainementOuvertures}
      if analyseRetrograde.doitConfirmerArret           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if AuMoinsUneFelicitation                         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecRefutationsDansRapport                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if enModeIOS                                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if sousEmulatorSousPC                             then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if affichePierresDelta                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecEvaluationTablesDeCoins                    then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetDebuggageUnitFichiersTexte                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      with debuggage do begin
      if entreesSortiesUnitFichiersTEXT                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if pendantLectureBase                             then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheSuiteInitialisations                    then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if evenementsDansRapport                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if elementsStrategiques                           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if gestionDuTemps                                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if calculFinaleOptimaleParOptimalite              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if arbreDeJeu                                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if lectureSmartGameBoard                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      end; {with debuggage do}
      if afficheProchainsCoups                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheSignesDiacritiques                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if NePasUtiliserLeGrasFenetreOthellier            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if prefVersion40b11Enregistrees                   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.apprentissage                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if PostscriptCompatibleXPress                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if HumCtreHum                                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if bidbool                                        then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetReveillerRegulierementLeMac                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if affichageReflexion.afficherToutesLesPasses     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.algoDeFinale                         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetEcritToutDansRapportLog                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecBibl                                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if CassioUtiliseDesMajuscules                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if differencierLesFreres                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecInterversions                              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetAvecAffichageNotesSurCases(kNotesDeCassio)  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if utilisateurVeutDiscretiserEvaluation           then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if sansReflexionSurTempsAdverse                   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if seMefierDesScoresDeLArbre                      then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if retirerEffet3DSubtilOthellier2D                then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.MacOSX                               then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecGagnantEnGrasDansListe                     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if gInfosSaisiePartie.enregistrementAutomatique   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecLisereNoirSurPionsBlancs                   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecAjustementAutomatiqueDuNiveau              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if eviterSolitairesOrdinateursSVP                 then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if listeEtroiteEtNomsCourts                       then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if avecOmbrageDesPions                            then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if GetAvecAffichageNotesSurCases(kNotesDeZebra)   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if garderPartieNoireADroiteOthellier              then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if gAideTranscriptsDejaPresentee                  then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if InclurePartiesAvecOrdinateursDansListe         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if cassio_must_get_zebra_nodes_from_disk <> 0     then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if afficheNuage                                   then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.engineInput                          then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if debuggage.engineoutput                         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');
      if CassioIsUsingMetaphone                         then s1 := Concat(s1,'Y') else s1 := Concat(s1,'N');


      s2 := '';
      NumEnStringFormatee(gCouleurOthellier.couleurFront,4,s2);
      NumEnStringFormatee(gCouleurOthellier.couleurBack,4,s2);
      NumEnStringFormatee(GetCadence,12,s2);
      NumEnStringFormatee(traductionMoisTournoi,2,s2);
      NumEnStringFormatee(FntrFelicitationTopLeft.h,5,s2);
      NumEnStringFormatee(FntrFelicitationTopLeft.v,5,s2);
      NumEnStringFormatee(cadencePersoAffichee,15,s2);
      NumEnStringFormatee(NiveauJeuInstantane,4,s2);
      NumEnStringFormatee(gCouleurOthellier.menuCmd,3,s2);
      NumEnStringFormatee(genreAffichageTextesDansFenetrePlateau,4,s2);
      NumEnStringFormatee(TypeEvalEnCoursEnInteger,3,s2);
      NumEnStringFormatee(numProcessors,4,s2);
      NumEnStringFormatee(GetCadenceAutreQueAnalyse,12,s2);
    end;
end;


procedure DecodeChainePrefBooleens(s1 : String255);
var len : SInt16;
    bidbool : boolean;
begin
  len := LENGTH_OF_STRING(s1);
 {if len >= 1  then bidbool                                         := s1[1] = 'Y';}
  if len >= 2  then SetEnVieille3D                                    (s1[2] = 'Y');
 {if len >= 3  then OthelloTorique                                  := s1[3] = 'Y';}
  if len >= 4  then avecSon                                         := s1[4] = 'Y';
  if len >= 5  then avecProgrammation                               := s1[5] = 'Y';
 {if len >= 6  then gEcranCouleur                                   := s1[6] = 'Y';}
 {if len >= 7  then bidbool                                         := s1[7] = 'Y';}
  if len >= 8  then OrdreDuTriRenverse                              := s1[8] = 'Y';
  if len >= 9  then afficheBibl                                     := s1[9] = 'Y';
  if len >= 10 then debuggage.general                               := s1[10] = 'Y';
  if len >= 11 then afficheNumeroCoup                               := s1[11] = 'Y';
  if len >= 12 then afficheSuggestionDeCassio                       := s1[12] = 'Y';
  if len >= 13 then afficheMeilleureSuite                           := s1[13] = 'Y';
  if len >= 14 then avecEvaluationTotale                            := s1[14] = 'Y';
 {if len >= 15 then avecDessinCoupEnTete                            := s1[15] = 'Y';}
  if len >= 16 then referencesCompletes                             := s1[16] = 'Y';
 {if len >= 17 then PionClignotant                                  := s1[17] = 'Y';}
  if len >= 18 then LectureAntichronologique                        := s1[18] = 'Y';
  if len >= 19 then decrementetemps                                 := s1[19] = 'Y';
 {if len >= 20 then SupprimerLesEffetsDeZoom                        := s1[20] = 'Y';}
 {if len >= 21 then OptimisePourKaleidoscope                        := s1[21] = 'Y';}
  if len >= 22 then bidbool                                         := s1[22] = 'Y';
  if len >= 23 then bidbool                                         := s1[23] = 'Y';
  if len >= 24 then bidbool                                         := s1[24] = 'Y';
  if len >= 25 then bidbool                                         := s1[25] = 'Y';
  if len >= 26 then bidbool                                         := s1[26] = 'Y';
  if len >= 27 then affichageReflexion.doitAfficher                 := s1[27] = 'Y';
  if len >= 28 then afficheGestionTemps                             := s1[28] = 'Y';
  if len >= 29 then jeuInstantane                                   := s1[29] = 'Y';
  if len >= 30 then avecSauvegardePref                              := s1[30] = 'Y';
 {if len >= 31 then avecAlerteNouvInterversion                      := s1[31] = 'Y';}
 {if len >= 32 then avecSystemeCoordonnees                          := s1[32] = 'Y';}
 {if len >= 33 then toujoursIndexerBase                             := s1[33] = 'Y';}
 {if len >= 34 then avecSelectivite                                 := s1[34] = 'Y';}
 {if len >= 35 then avecNomOuvertures                               := s1[35] = 'Y';}
  if len >= 36 then neJamaisTomber                                  := s1[36] = 'Y';
  if len >= 37 then doitConfirmerQuitter                            := s1[37] = 'Y';
 {if len >= 38 then bidbool                                         := s1[38] = 'Y';}
 {if len >= 39 then avecTestBibliotheque                            := s1[39] = 'Y';}
 {if len >= 40 then BeeperAuxCoupsillegaux                          := s1[40] = 'Y';}
  if len >= 41 then InfosTechniquesDansRapport                      := s1[41] = 'Y';
  if len >= 42 then afficheInfosApprentissage                       := s1[42] = 'Y';
  if len >= 43 then UtiliseGrapheApprentissage                      := s1[43] = 'Y';
  if len >= 44 then LaDemoApprend                                   := s1[44] = 'Y';
  with gEntrainementOuvertures do begin
  if len >= 45 then CassioVarieSesCoups                             := s1[45] = 'Y';
  if len >= 46 then CassioSeContenteDeLaNulle                       := s1[46] = 'Y';
  end; {with gEntrainementOuvertures}
  if len >= 47 then analyseRetrograde.doitConfirmerArret            := s1[47] = 'Y';
  if len >= 48 then AuMoinsUneFelicitation                          := s1[48] = 'Y';
 {if len >= 49 then bidbool                                         := s1[49] = 'Y';}
 {if len >= 50 then bidbool                                         := s1[50] = 'Y';}
  if len >= 51 then avecRefutationsDansRapport                      := s1[51] = 'Y';
  if len >= 52 then enModeIOS                                       := s1[52] = 'Y';
 {if len >= 53 then sousEmulatorSousPC                              := s1[53] = 'Y';}
  if len >= 54 then affichePierresDelta                             := s1[54] = 'Y';
  if len >= 55 then avecEvaluationTablesDeCoins                     := s1[55] = 'Y';
  if len >= 56 then SetDebuggageUnitFichiersTexte                     (s1[56] = 'Y');
  with debuggage do begin
  if len >= 57 then entreesSortiesUnitFichiersTEXT                  := s1[57] = 'Y';
  if len >= 58 then pendantLectureBase                              := s1[58] = 'Y';
  {if len >= 59 then afficheSuiteInitialisations                     := s1[59] = 'Y';}
  if len >= 60 then evenementsDansRapport                           := s1[60] = 'Y';
  if len >= 61 then elementsStrategiques                            := s1[61] = 'Y';
  if len >= 62 then gestionDuTemps                                  := s1[62] = 'Y';
  if len >= 63 then calculFinaleOptimaleParOptimalite               := s1[63] = 'Y';
  if len >= 64 then arbreDeJeu                                      := s1[64] = 'Y';
  if len >= 65 then lectureSmartGameBoard                           := s1[65] = 'Y';
  end; {with debuggage do}
  if len >= 66 then afficheProchainsCoups                           := s1[66] = 'Y';
  if len >= 67 then afficheSignesDiacritiques                       := s1[67] = 'Y';
  if len >= 68 then NePasUtiliserLeGrasFenetreOthellier             := s1[68] = 'Y';
  if len >= 69 then prefVersion40b11Enregistrees                    := s1[69] = 'Y';
  if len >= 70 then debuggage.apprentissage                         := s1[70] = 'Y';
  {if len >= 71 then PostscriptCompatibleXPress                     := s1[71] = 'Y';}
  if len >= 72 then HumCtreHum                                      := s1[72] = 'Y';
 {if len >= 73 then bidbool                                         := s1[73] = 'Y';}
  if len >= 74 then SetReveillerRegulierementLeMac                    (s1[74] = 'Y');
  if len >= 75 then affichageReflexion.afficherToutesLesPasses      := s1[75] = 'Y';
  if len >= 76 then debuggage.algoDeFinale                          := s1[76] = 'Y';
 {if len >= 77 then ecrireDansRapportLog                            := s1[77] = 'Y';}
  if len >= 78 then avecBibl                                        := s1[78] = 'Y';
  if len >= 79 then CassioUtiliseDesMajuscules                      := s1[79] = 'Y';
  if len >= 80 then differencierLesFreres                           := s1[80] = 'Y';
  if len >= 81 then avecInterversions                               := s1[81] = 'Y';
  if len >= 82 then SetAvecAffichageNotesSurCases      (kNotesDeCassio,s1[82] = 'Y');
 {if len >= 83 then utilisateurVeutDiscretiserEvaluation            := s1[83] = 'Y';}
  if len >= 84 then sansReflexionSurTempsAdverse                    := s1[84] = 'Y';
  if len >= 85 then seMefierDesScoresDeLArbre                       := s1[85] = 'Y';
 {if len >= 86 then retirerEffet3DSubtilOthellier2D                 := s1[86] = 'Y';}
  if len >= 87 then debuggage.MacOSX                                := s1[87] = 'Y';
  if len >= 88 then avecGagnantEnGrasDansListe                      := s1[88] = 'Y';
  if len >= 89 then gInfosSaisiePartie.enregistrementAutomatique    := s1[89] = 'Y';
  {if len >= 90 then avecLisereNoirSurPionsBlancs                   := s1[90] = 'Y';}
  if len >= 91 then avecAjustementAutomatiqueDuNiveau               := s1[91] = 'Y';
  if len >= 92 then eviterSolitairesOrdinateursSVP                  := s1[92] = 'Y';
  if len >= 93 then listeEtroiteEtNomsCourts                        := s1[93] = 'Y';
  {if len >= 94 then avecOmbrageDesPions                             := s1[94] = 'Y';}
  {if len >= 95 then SetAvecAffichageNotesSurCases       (kNotesDeZebra,s1[95] = 'Y');}
  if len >= 96 then garderPartieNoireADroiteOthellier               := s1[96] = 'Y';
  if len >= 97 then gAideTranscriptsDejaPresentee                   := s1[97] = 'Y';
  if len >= 98 then SetInclurePartiesAvecOrdinateursDansListe        (s1[98] = 'Y');
  {if len >= 99 then SetCassioMustGetZebraNodesFromDisk              (s1[99] = 'Y');}
  if len >= 100 then afficheNuage                                   := s1[100] = 'Y';
  if len >= 101 then debuggage.engineInput                          := s1[101] = 'Y';
  if len >= 102 then debuggage.engineoutput                         := s1[102] = 'Y';
  if len >= 103 then SetCassioIsUsingMetaphone                       (s1[103] = 'Y');



end;


procedure DecodeChainePrefNumeriques(s2 : String255);
begin
    gCouleurOthellier.couleurFront         := StringFormateeEnNum(4,s2);
    gCouleurOthellier.couleurBack          := StringFormateeEnNum(4,s2);
    SetCadence                               (StringFormateeEnNum(12,s2));
    traductionMoisTournoi                  := StringFormateeEnNum(2,s2);
    FntrFelicitationTopLeft.h              := StringFormateeEnNum(5,s2);
    FntrFelicitationTopLeft.v              := StringFormateeEnNum(5,s2);
    cadencePersoAffichee                   := StringFormateeEnNum(15,s2);
    NiveauJeuInstantane                    := StringFormateeEnNum(4,s2);
    gCouleurOthellier.menuCmd              := StringFormateeEnNum(3,s2);
    genreAffichageTextesDansFenetrePlateau := StringFormateeEnNum(4,s2);
    SetTypeEvaluationEnCours                 (StringFormateeEnNum(3,s2));
    numProcessors                          := StringFormateeEnNum(4,s2);
    SetCadenceAutreQueAnalyse                (StringFormateeEnNum(12,s2),GetJeuInstantaneAutreQueAnalyse);

    if (GetCadence <= 0)
      then SetCadence(minutes5);
    if cadencePersoAffichee <= 0
      then cadencePersoAffichee := GetCadence;

    if (NiveauJeuInstantane < NiveauDebutants) or
       (NiveauJeuInstantane > NiveauChampions)
      then  NiveauJeuInstantane := NiveauDebutants;

    if (gCouleurOthellier.menuCmd <= 0) or
       (gCouleurOthellier.menuCmd > AutreCouleurCmd)
      then gCouleurOthellier.menuCmd := VertPaleCmd;

    SetNombreDeProcesseursActifs(numProcessors);
end;

procedure DecodeChainePasseAnalyseRetrograde(s : String255);
var s1,s2,s3,s4,reste : String255;
    nroPasse,nroStage : SInt16;
begin
  Parser2(s,s1,s2,reste);  { '\nroPasse'  '->' }
  nroPasse := ChaineEnLongint(s1);
  if (nroPasse >= 1) and (nroPasse <= nbMaxDePassesAnalyseRetrograde) then
    begin
      nroStage := 0;
      while (reste <> '') and (nroStage < nbMaxDeStagesAnalyseRetrograde) do
        begin
          inc(nroStage);
          Parser4(reste,s1,s2,s3,s4,reste);
          analyseRetrograde.menuItems[nroPasse,nroStage,kMenuGenre] := ChaineEnLongint(s1);
          analyseRetrograde.menuItems[nroPasse,nroStage,kMenuProf]  := ChaineEnLongint(s2);
          analyseRetrograde.menuItems[nroPasse,nroStage,kMenuDuree] := ChaineEnLongint(s3);
          analyseRetrograde.menuItems[nroPasse,nroStage,kMenuNotes] := ChaineEnLongint(s4);
        end;
    end;
end;

procedure LitPrefDerniersJoueursSaisie(chainePref : String255; serie : SInt32);
var N,numero : SInt32;
    s : String255;
begin
  for N := 1 to 35 do
    begin
      s := TPCopy(chainePref, 1 + (N-1)*6 , 6);
      {WritelnDansRapport('LitPrefDerniersJoueursSaisie : '+ s);}
      if s = ''
        then numero := -1
        else numero := ChaineEnLongint(s);
      {WritelnNumDansRapport('numero = ',numero);}
      SetNiemeJoueurTableSaisiePartie( (serie - 1) * 35 + N, numero);
    end;
end;

procedure LitPrefDerniersTournoisSaisie(chainePref : String255; serie : SInt32);
var N,numero : SInt32;
    s : String255;
begin
  for N := 1 to 35 do
    begin
      s := TPCopy(chainePref, 1 + (N-1)*6 , 6);
      {WritelnDansRapport('LitPrefDerniersTournoisSaisie : '+ s);}
      if s = ''
        then numero := -1
        else numero := ChaineEnLongint(s);
      {WritelnNumDansRapport('numero = ',numero);}
      SetNiemeTournoiTableSaisiePartie( (serie - 1) * 35 + N, numero);
    end;
end;

function FabriquePrefDerniersJoueursSaisie(serie : SInt32) : String255;
var N,k,numero : SInt32;
    s,s1 : String255;
begin
  s := '';
  for N := 1 to 35 do
    begin
      numero := GetNiemeJoueurTableSaisiePartie( (serie - 1) * 35 + N);
      if (numero >= 0)
        then s1 := IntToStr(numero)
        else s1 := '';
      for k := 1 to 6 - LENGTH_OF_STRING(s1) do
        s1 := s1 + ' ';
      {WritelnNumDansRapport('numero = ',numero);
      WritelnDansRapport('FabriquePrefDerniersJoueursSaisie : '+ s1);}
      s := s + s1;
    end;
  FabriquePrefDerniersJoueursSaisie := s;
  {WritelnDansRapport('FabriquePrefDerniersJoueursSaisie (totale) : '+ s);}
end;

function FabriquePrefDerniersTournoisSaisie(serie : SInt32) : String255;
var N,k,numero : SInt32;
    s,s1 : String255;
begin
  s := '';
  for N := 1 to 35 do
    begin
      numero := GetNiemeTournoiTableSaisiePartie( (serie - 1) * 35 + N);
      if (numero >= 0)
        then s1 := IntToStr(numero)
        else s1 := '';
      for k := 1 to 6 - LENGTH_OF_STRING(s1) do
        s1 := s1 + ' ';
      {WritelnNumDansRapport('numero = ',numero);
      WritelnDansRapport('FabriquePrefDerniersTournoisSaisie : '+ s1);}
      s := s + s1;
    end;
  FabriquePrefDerniersTournoisSaisie := s;
  {WritelnDansRapport('FabriquePrefDerniersTournoisSaisie (totale) : '+ s);}
end;


function FichierPreferencesDeCassioExiste(nom : String255; var fic : FichierTEXT) : OSErr;
var s : String255;
    erreurES : OSErr;
begin

  erreurES := -1;

  s := nom;
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  s := ReplaceStringOnce('Préférences','Preferences',nom);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  s := ReplaceStringOnce('Préférences','PreÃÅfeÃÅrences',nom);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  s := ReplaceStringOnce('Preferences','Préférences',nom);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  s := ReplaceStringOnce('Preferences','PreÃÅfeÃÅrences',nom);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  FichierPreferencesDeCassioExiste := erreurES;

end;



procedure CreeFichierPreferences;
var fichierPref : FichierTEXT;
    filename : String255;
    version : String255;
    chainePref : String255;
    chainePrefBooleens : String255;
    chainePrefNumeriques : String255;
    erreurES,k,j : SInt32;
begin
  filename := NameOfPrefsFile;

  {SetDebuggageUnitFichiersTexte(false);}

  erreurES := FichierPreferencesDeCassioExiste(fileName,fichierPref);
  if (erreurES = fnfErr) {-43 = file not found  ==> on crée le fichier}
    then erreurES := CreeFichierTexteDeCassio(fileName,fichierPref);

  if (erreurES = NoErr)
    then {le fichier préférences existe : on l'ouvre et on le vide}
      begin
        erreurES := OuvreFichierTexte(fichierPref);
        erreurES := VideFichierTexte(fichierPref);
      end;

  if (erreurES <> NoErr) then
    begin
      { Si il y a une erreur à ce niveau, c'est probablement que l'on n'a
        pas les droits d'ecriture sur le repertoire (archive web, CD, etc).
        L'utilisateur ne peut sans doute rien faire, et ça ne sert à rien
        de l'embeter avec une alerte }

      {AlerteSimpleFichierTexte(fileName,erreurES);}

      erreurES := FermeFichierTexte(fichierPref);
      exit;
    end;

  prefVersion40b11Enregistrees := true;

  RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);

  (* New in Cassio 7.6 : les valeurs et les couleurs de zebra dans l'arbre vont toujours de pair *)
  if ZebraBookACetteOption(kAfficherNotesZebraDansArbre) or
     ZebraBookACetteOption(kAfficherCouleursZebraDansArbre) then
    begin
      RetirerZebraBookOption(kAfficherNotesZebraDansArbre);
      RetirerZebraBookOption(kAfficherCouleursZebraDansArbre);
      AjouterZebraBookOption(kAfficherNotesZebraDansArbre);
      AjouterZebraBookOption(kAfficherCouleursZebraDansArbre);
    end;


  version := '%versionOfPrefsFile = 11';
  erreurES := WritelnDansFichierTexte(fichierPref,version);
  CodeChainePref(chainePrefBooleens,chainePrefNumeriques);
  erreurES := WritelnDansFichierTexte(fichierPref,'%booleens = '+chainePrefBooleens);
  erreurES := WritelnDansFichierTexte(fichierPref,'%numeriques = '+chainePrefNumeriques);
  erreurES := WritelnDansFichierTexte(fichierPref,'%SolitairesDemandes = '+CodeChaineSolitairesDemandes);

  ParamDiagRecEnChaine(ParamDiagPositionFFORUM,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%paramDiagPositionFFORUM-version-1 = '+chainePref);
  ParamDiagRecEnChaine(ParamDiagPartieFFORUM,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%paramDiagPartieFFORUM-version-1 = '+chainePref);
  ParamDiagRecEnChaine(ParamDiagCourant,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%paramDiagCourant-version-1 = '+chainePref);
  ParamDiagRecEnChaine(ParamDiagImpr,chainePref);
  erreurES := WritelnDansFichierTexte(fichierPref,'%paramDiagImpr-version-1 = '+chainePref);

  chainePref := FenetreEnChaine(windowPlateauOpen,wPlateauPtr,FntrPlatRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowPlateau = '+chainePref);
  chainePref := FenetreEnChaine(windowCourbeOpen,wCourbePtr,FntrCourbeRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowCourbe = '+chainePref);
  chainePref := FenetreEnChaine(windowAideOpen,wAidePtr,FntrAideRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowAide = '+chainePref);
  chainePref := FenetreEnChaine(windowGestionOpen,wGestionPtr,FntrGestionRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowGestion = '+chainePref);
  chainePref := FenetreEnChaine(windowNuageOpen,wNuagePtr,FntrNuageRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowNuage = '+chainePref);
  chainePref := FenetreEnChaine(windowReflexOpen,wReflexPtr,FntrReflexRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowReflexion = '+chainePref);
  chainePref := FenetreEnChaine(windowListeOpen,wListePtr,FntrListeRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowListe = '+chainePref);
  chainePref := FenetreEnChaine(windowStatOpen,wStatPtr,FntrStatRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowStat = '+chainePref);
  chainePref := FenetreEnChaine(windowPaletteOpen,wPalettePtr,FntrPaletteRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowPalette = '+chainePref);
  chainePref := FenetreEnChaine(windowRapportOpen,GetRapportWindow,FntrRapportRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowRapport = '+chainePref);
  chainePref := FenetreEnChaine(iconisationDeCassio.encours,iconisationDeCassio.theWindow,iconisationDeCassio.IconisationRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowIconisation = '+chainePref);
  chainePref := FenetreEnChaine(arbreDeJeu.windowOpen,GetArbreDeJeuWindow,FntrCommentairesRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowCommentaires = '+chainePref);
  chainePref := FenetreEnChaine(false,NIL,FntrCadenceRect);
  erreurES := WritelnDansFichierTexte(fichierPref,'%windowCadence = '+chainePref);
  chainePref := FenetreEnChaine(false,NIL,aireDeJeu);
  erreurES := WritelnDansFichierTexte(fichierPref,'%aireDeJeu = '+chainePref);

  chainePref := CheminAccesThorDBA^^;
  erreurES := WritelnDansFichierTexte(fichierPref,'%accesThorDBA = '+chainePref);
  chainePref := CheminAccesThorDBASolitaire^^;
  erreurES := WritelnDansFichierTexte(fichierPref,'%accesSolitaires = '+chainePref);
  chainePref := IntToStr(VolumeRefThorDBA);
  erreurES := WritelnDansFichierTexte(fichierPref,'%volumeRefThorDBA = '+chainePref);
  chainePref := IntToStr(VolumeRefThorDBASolitaire);
  erreurES := WritelnDansFichierTexte(fichierPref,'%volumeRefSolitaires = '+chainePref);
  chainePref := IntToStr(nbExplicationsPasses);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbExplicationsPasses = '+chainePref);
  {chainePref := IntToStr(gGenreDeTriListe);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gGenreDeTriListe = '+chainePref);}
  chainePref := IntToStr(analyseRetrograde.nbMinPourConfirmationArret);
  erreurES := WritelnDansFichierTexte(fichierPref,'%confirmationArretRetro = '+chainePref);
  chainePref := IntToStr(arbreDeJeu.positionLigneSeparation);
  erreurES := WritelnDansFichierTexte(fichierPref,'%LigneSeparationCommentaires = '+chainePref);

  chainePref := IntToStr(Trunc(Coeffinfluence*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffInfluence = '+chainePref);
  chainePref := IntToStr(Trunc(Coefffrontiere*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffFrontiere = '+chainePref);
  chainePref := IntToStr(Trunc(CoeffEquivalence*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffEquivalence = '+chainePref);
  chainePref := IntToStr(Trunc(Coeffcentre*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffCentre = '+chainePref);
  chainePref := IntToStr(Trunc(Coeffgrandcentre*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffGrandCentre = '+chainePref);
  chainePref := IntToStr(Trunc(Coeffbetonnage*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffBetonnage = '+chainePref);
  chainePref := IntToStr(Trunc(Coeffminimisation*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffMinimisation = '+chainePref);
  chainePref := IntToStr(Trunc(CoeffpriseCoin*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffPriseCoin = '+chainePref);
  chainePref := IntToStr(Trunc(CoeffdefenseCoin*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffDefenseCoin = '+chainePref);
  chainePref := IntToStr(Trunc(CoeffValeurCoin*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffValeurCoin = '+chainePref);
  chainePref := IntToStr(Trunc(CoeffValeurCaseX*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffValeurCaseX = '+chainePref);
  chainePref := IntToStr(Trunc(CoeffPenalite*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffPenalite = '+chainePref);
  chainePref := IntToStr(Trunc(CoeffMobiliteUnidirectionnelle*100+0.5));
  erreurES := WritelnDansFichierTexte(fichierPref,'%CoeffMobiliteUnidirectionnelle = '+chainePref);
  chainePref := IntToStr(gPourcentageTailleDesPions);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gPourcentageTailleDesPions = '+chainePref);
  chainePref := IntToStr(gCouleurSupplementaire.red);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurSupplementaire.red = '+chainePref);
  chainePref := IntToStr(gCouleurSupplementaire.green);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurSupplementaire.green = '+chainePref);
  chainePref := IntToStr(gCouleurSupplementaire.blue);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurSupplementaire.blue = '+chainePref);
  chainePref := IntToStr(gCouleurOthellier.menuID);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurOthellier.menuID = '+chainePref);
  chainePref := gCouleurOthellier.nomFichierTexture;
  erreurES := WritelnDansFichierTexte(fichierPref,'%gCouleurOthellier.nomFichierTexture = '+chainePref);
  chainePref := IntToStr(gLastTexture3D.theMenu);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gLastTexture3D.theMenu = '+chainePref);
  chainePref := IntToStr(gLastTexture3D.theCmd);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gLastTexture3D.theCmd = '+chainePref);
  chainePref := IntToStr(gLastTexture2D.theMenu);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gLastTexture2D.theMenu = '+chainePref);
  chainePref := IntToStr(gLastTexture2D.theCmd);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gLastTexture2D.theCmd = '+chainePref);
  chainePref := CoupEnStringEnMinuscules(GetPremierCoupParDefaut);
  erreurES := WritelnDansFichierTexte(fichierPref,'%PremierCoupParDefaut = '+chainePref);
  chainePref := IntToStr(nbCasesVidesMinSolitaire);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbCasesVidesMinSolitaire = '+chainePref);
  chainePref := IntToStr(nbCasesVidesMaxSolitaire);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbCasesVidesMaxSolitaire = '+chainePref);
  chainePref := Concat('"',GetPoliceNameNotesSurCases(kNotesDeCassio), '" ', IntToStr(GetTailleNotesSurCases(kNotesDeCassio)));
  erreurES := WritelnDansFichierTexte(fichierPref,'%PoliceNotesSurLesCases = '+chainePref);
  chainePref := Concat('"',GetPoliceNameNotesSurCases(kNotesDeZebra), '" ', IntToStr(GetTailleNotesSurCases(kNotesDeZebra)));
  erreurES := WritelnDansFichierTexte(fichierPref,'%PoliceBiblioZebraSurLesCases = '+chainePref);
  chainePref := IntToStr(GetZebraBookContemptWindowWidth);
  erreurES := WritelnDansFichierTexte(fichierPref,'%ZebraBookContemptValue = '+chainePref);
  chainePref := IntToStr(GetZebraBookOptions);
  erreurES := WritelnDansFichierTexte(fichierPref,'%ZebraBookOptions = '+chainePref);
  if CassioDoitRentrerEnContactAvecLeZoo
    then chainePref := 'YES'
    else chainePref := 'NO';
  erreurES := WritelnDansFichierTexte(fichierPref,'%CassioDoitRentrerDansOthelloZoo = '+chainePref);
  chainePref := IntToStr(ord(gAideCourante));
  erreurES := WritelnDansFichierTexte(fichierPref,'%gAideCourante = '+chainePref);
  chainePref := IntToStr(humanWinningStreak);
  erreurES := WritelnDansFichierTexte(fichierPref,'%humanWinningStreak = '+chainePref);
  chainePref := IntToStr(humanScoreLastLevel);
  erreurES := WritelnDansFichierTexte(fichierPref,'%humanScoreLastLevel = '+chainePref);
  chainePref := IntToStr(themeCourantDeCassio);
  erreurES := WritelnDansFichierTexte(fichierPref,'%themeCourantDeCassio = '+chainePref);
  chainePref := IntToStr(gNbreMegaoctetsPourLaBase);
  erreurES := WritelnDansFichierTexte(fichierPref,'%gNbreMegaoctetsPourLaBase = '+chainePref);

  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueursSaisie = ' +FabriquePrefDerniersJoueursSaisie(1));
  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueursSaisie2 = '+FabriquePrefDerniersJoueursSaisie(2));
  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueursSaisie3 = '+FabriquePrefDerniersJoueursSaisie(3));
  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueursSaisie4 = '+FabriquePrefDerniersJoueursSaisie(4));
  erreurES := WritelnDansFichierTexte(fichierPref,'%TournoisSaisie = ' +FabriquePrefDerniersTournoisSaisie(1));
  erreurES := WritelnDansFichierTexte(fichierPref,'%TournoisSaisie2 = '+FabriquePrefDerniersTournoisSaisie(2));
  erreurES := WritelnDansFichierTexte(fichierPref,'%TournoisSaisie3 = '+FabriquePrefDerniersTournoisSaisie(3));
  erreurES := WritelnDansFichierTexte(fichierPref,'%TournoisSaisie4 = '+FabriquePrefDerniersTournoisSaisie(4));
  erreurES := WritelnDansFichierTexte(fichierPref,'%AnneeSaisie = '+IntToStr(gInfosSaisiePartie.derniereAnnee));
  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueurNoirSaisie = '+IntToStr(gInfosSaisiePartie.dernierJoueurNoir));
  erreurES := WritelnDansFichierTexte(fichierPref,'%JoueurBlancSaisie = '+IntToStr(gInfosSaisiePartie.dernierJoueurBlanc));
  erreurES := WritelnDansFichierTexte(fichierPref,'%TournoiSaisie = '+IntToStr(gInfosSaisiePartie.dernierTournoi));
  erreurES := WritelnDansFichierTexte(fichierPref,'%DistributionSaisie = '+IntToStr(Max(1,gInfosSaisiePartie.derniereDistribution)));
  erreurES := WritelnDansFichierTexte(fichierPref,'%DerniereRechercheArbre = '+GetLastStringSearchedInGameTree);
  erreurES := WritelnDansFichierTexte(fichierPref,'%tailleFenetrePlateauAvantPassageEn3D = '+IntToStr(tailleFenetrePlateauAvantPassageEn3D));
  erreurES := WritelnDansFichierTexte(fichierPref,'%tailleCaseAvantPassageEn3D = '+IntToStr(tailleCaseAvantPassageEn3D));
  erreurES := WritelnDansFichierTexte(fichierPref,'%empilementFenetres = '+VisibiliteInitiale.ordreOuvertureDesFenetres);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbColonnesFenetreListe = '+IntToStr(nbColonnesFenetreListe));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionDistribution = '+IntToStr(positionDistribution));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionTournoi = '+IntToStr(positionTournoi));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionNoir = '+IntToStr(positionNoir));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionBlanc = '+IntToStr(positionBlanc));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionCoup = '+IntToStr(positionCoup));
  erreurES := WritelnDansFichierTexte(fichierPref,'%positionScoreReel = '+IntToStr(positionScoreReel));
  erreurES := WritelnDansFichierTexte(fichierPref,'%DernierTempsDeChargementDeLaBase = '+IntToStr(gDernierTempsDeChargementDeLaBase));
  erreurES := WritelnDansFichierTexte(fichierPref,'%nomEngineEnCours = '+GetEngineName(numeroEngineEnCours));
  erreurES := WritelnDansFichierTexte(fichierPref,'%verbosityZoo = '+IntToStr(VerbosityOfZoo));


  GetIntervalleDeDifficultePourProblemeDePriseDeCoin(j,k);
  erreurES := WritelnDansFichierTexte(fichierPref,'%IntervalleProblemesDeCoinDansListe = '+IntToStr(j*10 + k));

  chainePref := IntToStr(nbCoupsEnTete);
  erreurES := WritelnDansFichierTexte(fichierPref,'%nbMeilleursCoupsAffiches = '+chainePref);
  for k := 1 to nbMaxDePassesAnalyseRetrograde do
    begin
      chainePref := '%PasseAnalyseRetrograde = '+IntToStr(k)+' ->';
      for j := 1 to nbMaxDeStagesAnalyseRetrograde do
        begin
          chainePref := chainePref+' '+IntToStr(analyseRetrograde.menuItems[k,j,kMenuGenre])+
                                   ' '+IntToStr(analyseRetrograde.menuItems[k,j,kMenuProf])+
                                   ' '+IntToStr(analyseRetrograde.menuItems[k,j,kMenuDuree])+
                                   ' '+IntToStr(analyseRetrograde.menuItems[k,j,kMenuNotes]);
        end;
      erreurES := WritelnDansFichierTexte(fichierPref,chainePref);
    end;

  for k := NbMaxItemsReouvrirMenu downto 1 do
    if (nomDuFichierAReouvrir[k] <> NIL) and (nomDuFichierAReouvrir[k]^^ <> '') then
      begin
        chainePref := nomDuFichierAReouvrir[k]^^;
        erreurES := WritelnDansFichierTexte(fichierPref,'%partieAReouvrir = '+chainePref);
      end;

  with DistributionsNouveauFormat do
    begin
      case ChoixDistributions.genre of
        kToutesLesDistributions : chainePref := '%quellesBasesLire = ToutesLesDistributions';
        kQuelquesDistributions  : chainePref := '%quellesBasesLire = QuelquesDistributions';
        kAucuneDistribution     : chainePref := '%quellesBasesLire = AucuneDistribution';
      end;
      erreurES := WritelnDansFichierTexte(fichierPref,chainePref);
      for k := 1 to nbDistributions do
        begin

         {
          TraceLog('k = '+IntToStr(k));
          if (Distribution[k].path <> NIL) and (Distribution[k].name <> NIL)
            then TraceLog('   '+Distribution[k].path^ + Distribution[k].name^)
            else TraceLog('   NIL ou NIL !');
          if (k in ChoixDistributions.distributionsALire)
            then TraceLog('   k in ChoixDistributions.distributionsALire => TRUE')
            else TraceLog('   k in ChoixDistributions.distributionsALire => false');
         }

          if (k in ChoixDistributions.distributionsALire) and
           (Distribution[k].path <> NIL) and (Distribution[k].name <> NIL) then
          begin
            chainePref := Distribution[k].path^ + Distribution[k].name^;
            chainePref := ReplaceStringOnce(pathCassioFolder,'$CASSIO_FOLDER:',chainePref);
            erreurES := WritelnDansFichierTexte(fichierPref,'%baseActive = '+chainePref);
          end;
        end;
    end;

  erreurES := FermeFichierTexte(fichierPref);
  SetFileCreatorFichierTexte(fichierPref,MY_FOUR_CHAR_CODE('SNX4'));
  SetFileTypeFichierTexte(fichierPref,MY_FOUR_CHAR_CODE('PREF'));

  AjouterNomDansListOfPrefsFiles(filename);

end;




procedure LitFichierPreferences;
var fichierPref : FichierTEXT;
    filename : String255;
    LigneFichierPref : String255;
    motClef : String255;
    auxStr : String255;
    chainePref : String255;
    erreurES : SInt16;
    bidon : boolean;
    i : SInt32;
    autreFichierPreferencesSuggere : String255;
begin

 if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : avant NameOfPrefsFile');

 filename := NameOfPrefsFile;

 {SetDebuggageUnitFichiersTexte(false);}

 erreurES := FichierPreferencesDeCassioExiste(fileName,fichierPref);

 if erreurES = fnfErr then
   begin
     {fichier préférences non trouvé =  >  on essaie de lire les vieux fichiers de preferences}

     LireListeOfPrefsFiles;
     for i := 1 to kMaxPrefFiles do
       begin
         autreFichierPreferencesSuggere := gListeOfPrefFiles[i].name;
         if (erreurES = fnfErr) and (autreFichierPreferencesSuggere <> '') then
           begin
             erreurES := FichierPreferencesDeCassioExiste(autreFichierPreferencesSuggere,fichierPref);
             if erreurES = NoErr then
               begin
                 filename := autreFichierPreferencesSuggere;
                 if (i > 1) then AjouterNomDansListOfPrefsFiles(filename);
               end;
           end;
       end;

     { desespoir, on n'a trouve aucun vieux fichier de preferences :
       on quitte et on prendra les prefs par défauts}
     if erreurES = fnfErr then exit;
   end;

 if erreurES <> NoErr then
   begin
     AlerteSimpleFichierTexte(fileName,erreurES);
     exit;
   end;

 erreurES := OuvreFichierTexte(fichierPref);
 if erreurES <> NoErr then
   begin
     AlerteSimpleFichierTexte(fileName,erreurES);
     exit;
   end;

 erreurES := ReadlnDansFichierTexte(fichierPref,chainePref);
 if erreurES <> NoErr then
   begin
     AlerteSimpleFichierTexte(fileName,erreurES);
     erreurES := FermeFichierTexte(fichierPref);
     exit;
   end;

 if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : avant if (chainePref <> ''%versionOfPrefsFile = 11'')');

 if (chainePref <> '%versionOfPrefsFile = 11')           {mauvaise version du fichier preference}
  then
   begin

    if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : avant GetIndString');
    chainePref := ReadStringFromRessource(TextesErreursID,1);

    AlerteSimple(chainepref);

   end
  else
   begin
    while (erreurES = NoErr) and not(EOFFichierTexte(fichierPref,erreurES)) do
     begin


      erreurES := ReadlnDansFichierTexte(fichierPref,LigneFichierPref);

      if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : LigneFichierPref = '+LigneFichierPref);

      Parser2(LigneFichierPref,motClef,auxStr,chainePref);


      if chainePref <> '' then
       begin
        if motClef = '%booleens'                            then DecodeChainePrefBooleens(chainePref) else
        if motClef = '%numeriques'                          then DecodeChainePrefNumeriques(chainePref) else
        if motClef = '%SolitairesDemandes'                  then DecodeChaineSolitairesDemandes(chainePref) else
        if motClef = '%paramDiagPositionFFORUM-version-1'   then ChaineEnParamDiagRec(chainePref,ParamDiagPositionFFORUM) else
        if motClef = '%paramDiagPartieFFORUM-version-1'     then ChaineEnParamDiagRec(chainePref,ParamDiagPartieFFORUM) else
        if motClef = '%paramDiagCourant-version-1'          then ChaineEnParamDiagRec(chainePref,ParamDiagCourant) else
        if motClef = '%paramDiagImpr-version-1'             then ChaineEnParamDiagRec(chainePref,ParamDiagImpr) else
        if motClef = '%windowPlateau'                       then ChaineEnFenetre(chainePref,windowPlateauOpen,FntrPlatRect) else
        if motClef = '%windowCourbe'                        then ChaineEnFenetre(chainePref,windowCourbeOpen,FntrCourbeRect) else
        if motClef = '%windowAide'                          then ChaineEnFenetre(chainePref,windowAideOpen,FntrAideRect) else
        if motClef = '%windowGestion'                       then ChaineEnFenetre(chainePref,windowGestionOpen,FntrGestionRect) else
        if motClef = '%windowNuage'                         then ChaineEnFenetre(chainePref,windowNuageOpen,FntrNuageRect) else
        if motClef = '%windowReflexion'                     then ChaineEnFenetre(chainePref,windowReflexOpen,FntrReflexRect) else
        if motClef = '%windowListe'                         then ChaineEnFenetre(chainePref,windowListeOpen,FntrListeRect) else
        if motClef = '%windowStat'                          then ChaineEnFenetre(chainePref,windowStatOpen,FntrStatRect) else
        if motClef = '%windowPalette'                       then ChaineEnFenetre(chainePref,windowPaletteOpen,FntrPaletteRect) else
        if motClef = '%windowRapport'                       then ChaineEnFenetre(chainePref,windowRapportOpen,FntrRapportRect) else
        if motClef = '%windowCommentaires'                  then ChaineEnFenetre(chainePref,arbreDeJeu.windowOpen,FntrCommentairesRect) else
        if motClef = '%windowCadence'                       then ChaineEnFenetre(chainePref,bidon,FntrCadenceRect) else
        if motClef = '%aireDeJeu'                           then ChaineEnRect(chainePref,bidon,aireDeJeu) else
        if motClef = '%accesThorDBA'                        then CheminAccesThorDBA^^ := chainePref else
        if motClef = '%accesSolitaires'                     then CheminAccesThorDBASolitaire^^ := chainePref else
        if motClef = '%volumeRefThorDBA'                    then ChaineToInteger(chainePref,VolumeRefThorDBA) else
        if motClef = '%volumeRefSolitaires'                 then ChaineToInteger(chainePref,VolumeRefThorDBASolitaire) else
        if motClef = '%nbExplicationsPasses'                then ChaineToInteger(chainePref,nbExplicationsPasses) else
       {if motClef = '%gGenreDeTriListe'                    then ChaineToInteger(chainePref,gGenreDeTriListe) else}
        if motClef = '%confirmationArretRetro'              then ChaineToLongint(chainePref,analyseRetrograde.nbMinPourConfirmationArret) else
        if motClef = '%CoeffInfluence'                      then Coeffinfluence := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffFrontiere'                      then Coefffrontiere := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffEquivalence'                    then CoeffEquivalence := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffCentre'                         then Coeffcentre := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffGrandCentre'                    then Coeffgrandcentre := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffBetonnage'                      then Coeffbetonnage := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffMinimisation'                   then Coeffminimisation := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffPriseCoin'                      then CoeffpriseCoin := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffDefenseCoin'                    then CoeffdefenseCoin := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffValeurCoin'                     then CoeffValeurCoin := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffValeurCaseX'                    then CoeffValeurCaseX := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffPenalite'                       then CoeffPenalite := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%CoeffMobiliteUnidirectionnelle'      then CoeffMobiliteUnidirectionnelle := ChaineEnLongint(chainePref)/100.0 else
        if motClef = '%LigneSeparationCommentaires'         then arbreDeJeu.positionLigneSeparation := ChaineEnLongint(chainePref) else
        {if motClef = '%gPourcentageTailleDesPions'          then gPourcentageTailleDesPions := ChaineEnLongint(chainePref) else}
        if motClef = '%gCouleurSupplementaire.red'          then SetRGBColor(gCouleurSupplementaire,ChaineEnLongint(chainePref),gCouleurSupplementaire.green,gCouleurSupplementaire.blue) else
        if motClef = '%gCouleurSupplementaire.green'        then SetRGBColor(gCouleurSupplementaire,gCouleurSupplementaire.red,ChaineEnLongint(chainePref),gCouleurSupplementaire.blue) else
        if motClef = '%gCouleurSupplementaire.blue'         then SetRGBColor(gCouleurSupplementaire,gCouleurSupplementaire.red,gCouleurSupplementaire.green,ChaineEnLongint(chainePref)) else
        if motClef = '%gCouleurOthellier.menuID'            then gCouleurOthellier.menuID := ChaineEnLongint(chainePref) else
        if motClef = '%gCouleurOthellier.nomFichierTexture' then gCouleurOthellier.nomFichierTexture := chainePref else
        if motClef = '%gLastTexture3D.theMenu'              then gLastTexture3D.theMenu := ChaineEnLongint(chainePref) else
        if motClef = '%gLastTexture3D.theCmd'               then gLastTexture3D.theCmd := ChaineEnLongint(chainePref) else
        if motClef = '%gLastTexture2D.theMenu'              then gLastTexture2D.theMenu := ChaineEnLongint(chainePref) else
        if motClef = '%gLastTexture2D.theCmd'               then gLastTexture2D.theCmd := ChaineEnLongint(chainePref) else
        if motClef = '%nbMeilleursCoupsAffiches'            then ChaineToInteger(chainePref,nbCoupsEnTete) else
        if motClef = '%PasseAnalyseRetrograde'              then DecodeChainePasseAnalyseRetrograde(chainePref) else
        if motClef = '%PremierCoupParDefaut'                then SetPremierCoupParDefaut(StringEnCoup(chainePref)) else
        if motClef = '%nbCasesVidesMinSolitaire'            then nbCasesVidesMinSolitaire := ChaineEnLongint(chainePref) else
        if motClef = '%nbCasesVidesMaxSolitaire'            then nbCasesVidesMaxSolitaire := ChaineEnLongint(chainePref) else
        if motClef = '%JoueursSaisie'                       then LitPrefDerniersJoueursSaisie(chainePref, 1) else
        if motClef = '%JoueursSaisie2'                      then LitPrefDerniersJoueursSaisie(chainePref, 2) else
        if motClef = '%JoueursSaisie3'                      then LitPrefDerniersJoueursSaisie(chainePref, 3) else
        if motClef = '%JoueursSaisie4'                      then LitPrefDerniersJoueursSaisie(chainePref, 4) else
        if motClef = '%TournoisSaisie'                      then LitPrefDerniersTournoisSaisie(chainePref, 1) else
        if motClef = '%TournoisSaisie2'                     then LitPrefDerniersTournoisSaisie(chainePref, 2) else
        if motClef = '%TournoisSaisie3'                     then LitPrefDerniersTournoisSaisie(chainePref, 3) else
        if motClef = '%TournoisSaisie4'                     then LitPrefDerniersTournoisSaisie(chainePref, 4) else
        if motClef = '%AnneeSaisie'                         then gInfosSaisiePartie.derniereAnnee := ChaineEnLongint(chainePref) else
        if motClef = '%JoueurNoirSaisie'                    then gInfosSaisiePartie.dernierJoueurNoir := ChaineEnLongint(chainePref) else
        if motClef = '%JoueurBlancSaisie'                   then gInfosSaisiePartie.dernierJoueurBlanc := ChaineEnLongint(chainePref) else
        if motClef = '%TournoiSaisie'                       then gInfosSaisiePartie.dernierTournoi := ChaineEnLongint(chainePref) else
        if motClef = '%DistributionSaisie'                  then gInfosSaisiePartie.derniereDistribution := Max(1,ChaineEnLongint(chainePref)) else
        if motClef = '%nbColonnesFenetreListe'              then nbColonnesFenetreListe := ChaineEnLongint(chainePref) else
        if motClef = '%positionDistribution'                then positionDistribution := ChaineEnLongint(chainePref) else
        if motClef = '%positionTournoi'                     then positionTournoi := ChaineEnLongint(chainePref) else
        if motClef = '%positionNoir'                        then positionNoir := ChaineEnLongint(chainePref) else
        if motClef = '%positionBlanc'                       then positionBlanc := ChaineEnLongint(chainePref) else
        if motClef = '%positionCoup'                        then positionCoup := ChaineEnLongint(chainePref) else
        if motClef = '%positionScoreReel'                   then positionScoreReel := ChaineEnLongint(chainePref) else
        if motClef = '%humanWinningStreak'                  then humanWinningStreak := ChaineEnLongint(chainePref) else
        if motClef = '%humanScoreLastLevel'                 then humanScoreLastLevel := ChaineEnLongint(chainePref) else
        if motClef = '%themeCourantDeCassio'                then themeCourantDeCassio := ChaineEnLongint(chainePref) else
        if motClef = '%gNbreMegaoctetsPourLaBase'           then gNbreMegaoctetsPourLaBase := ChaineEnLongint(chainePref) else
        if motClef = '%tailleFenetrePlateauAvantPassageEn3D'then tailleFenetrePlateauAvantPassageEn3D := ChaineEnLongint(chainePref) else
        if motClef = '%tailleCaseAvantPassageEn3D'          then tailleCaseAvantPassageEn3D := ChaineEnLongint(chainePref) else
        if motClef = '%empilementFenetres'                  then VisibiliteInitiale.ordreOuvertureDesFenetres := chainePref else
        {if motClef = '%ZebraBookContemptValue'              then SetZebraBookContemptWindowWidth(ChaineEnLongint(chainePref)) else}
        if motClef = '%ZebraBookOptions'                    then SetZebraBookOptions(ChaineEnLongint(chainePref)) else
        if motClef = '%CassioDoitRentrerDansOthelloZoo'     then SetCassioDoitRentrerEnContactAvecLeZoo('YES') else // SetCassioDoitRentrerEnContactAvecLeZoo(chainePref) else
        if motClef = '%gAideCourante'                       then gAideCourante := PagesAide(ChaineEnLongint(chainePref)) else
        if motClef = '%DerniereRechercheArbre'              then SetLastStringSearchedInGameTree(chainePref) else
        if motClef = '%IntervalleProblemesDeCoinDansListe'  then SetIntervalleDeDifficultePourProblemeDePriseDeCoin(ChaineEnLongint(chainePref) div 10,ChaineEnLongint(chainePref) mod 10) else
        if motClef = '%DernierTempsDeChargementDeLaBase'    then gDernierTempsDeChargementDeLaBase := ChaineEnLongint(chainePref) else
        if motClef = '%nomEngineEnCours'                    then numeroEngineEnCours := GetNumeroOfEngine(chainePref) else
        if motClef = '%verbosityZoo'                        then SetVerbosityOfZoo(ChaineEnLongint(chainePref)) else
        if motClef = '%PoliceNotesSurLesCases'              then
           begin
             ParserWithQuoteProtection(chainePref,chainePref,auxStr);
             SetPoliceNameNotesSurCases(kNotesDeCassio,chainePref);
             SetTailleNotesSurCases(kNotesDeCassio,ChaineEnLongint(auxStr));
           end else
        if motClef = '%GrandePoliceNotesSurLesCases' then
           begin
             ParserWithQuoteProtection(chainePref,chainePref,auxStr);
             SetAlternativePoliceNameNotesSurCases(kNotesDeCassio,chainePref);
             SetAlternativeTailleNotesSurCases(kNotesDeCassio,ChaineEnLongint(auxStr));
           end else
        if motClef = '%PoliceBiblioZebraSurLesCases'              then
           begin
             ParserWithQuoteProtection(chainePref,chainePref,auxStr);
             SetPoliceNameNotesSurCases(kNotesDeZebra,chainePref);
             SetTailleNotesSurCases(kNotesDeZebra,ChaineEnLongint(auxStr));
           end else
        if motClef = '%GrandePoliceZebraSurLesCases' then
           begin
             ParserWithQuoteProtection(chainePref,chainePref,auxStr);
             SetAlternativePoliceNameNotesSurCases(kNotesDeZebra,chainePref);
             SetAlternativeTailleNotesSurCases(kNotesDeZebra,ChaineEnLongint(auxStr));
           end else
        if motClef = '%windowIconisation'                   then
           begin
             ChaineEnFenetre(chainePref,bidon,iconisationDeCassio.IconisationRect);
             with iconisationDeCassio.IconisationRect , iconisationDeCassio  do
               begin
                 if (right-left) <> LargeurFenetreIconisation then right := left+LargeurFenetreIconisation;
                 if (bottom-top) <> LargeurFenetreIconisation then bottom := top+LargeurFenetreIconisation;
               end;
           end else
	      if motClef = '%quellesBasesLire' then
	        with ChoixDistributions do
	         begin
             if chainePref = 'ToutesLesDistributions' then genre := kToutesLesDistributions else
             if chainePref = 'QuelquesDistributions'  then genre := kQuelquesDistributions else
             if chainePref = 'AucuneDistribution'     then genre := kAucuneDistribution;
           end;
       end;
     end;
    if not(prefVersion40b11Enregistrees) then
      gCouleurOthellier.menuCmd := VertPaleCmd;
    FntrListeRect.right := FntrListeRect.left + LargeurNormaleFenetreListe(nbColonnesFenetreListe) + 1;

    RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);

    (* New in Cassio 7.6 : les valeurs et les couleurs de zebra dans l'arbre vont toujours de pair *)
    if ZebraBookACetteOption(kAfficherNotesZebraDansArbre) or
       ZebraBookACetteOption(kAfficherCouleursZebraDansArbre) then
      begin
        RetirerZebraBookOption(kAfficherNotesZebraDansArbre);
        RetirerZebraBookOption(kAfficherCouleursZebraDansArbre);
        AjouterZebraBookOption(kAfficherNotesZebraDansArbre);
        AjouterZebraBookOption(kAfficherCouleursZebraDansArbre);
      end;

    if GetZebraBookOptions <> 0 then SetUsingZebraBook(true);

   end;
 erreurES := FermeFichierTexte(fichierPref);

 if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  LitFichierPreferences : sortie');
end;


procedure GetPartiesAReouvrirFromPrefsFile;
var err : OSErr;
    s,motClef,bidStr,chainePref : String255;
begin
  if OpenPrefsFileForSequentialReading = NoErr then
	  begin
      while not(EOFInPrefsFile) do
        begin
          err := GetNextLineInPrefsFile(s);
          if err = NoErr then
            begin
              Parser2(s,motClef,bidStr,chainePref);
              if motClef = '%partieAReouvrir'then AjoutePartieDansMenuReouvrir(chainePref);
            end;
        end;
      err := ClosePrefsFile;
    end;

  if gPartieOuvertePendantLesInitialisationsDeCassio <> ''
    then AjoutePartieDansMenuReouvrir(gPartieOuvertePendantLesInitialisationsDeCassio);

  if SousMenuReouvrirEstVide
     then MyDisableItem(GetFileMenu,reouvrirCmd)
     else MyEnableItem(GetFileMenu,reouvrirCmd);
end;

procedure DoDialoguePreferences;
  const
    PreferencesDialogueID = 130;
    OK = 1;
    Annuler = 2;
    BoutonToujours = 7;
    BoutonParfois = 8;
    BoutonJamais = 9;
    TextNbExplications = 10;
    StaticPremiereFois = 11;
    {VerifierBiblBox = 12;}
    EnregistrerPrefsBox = 12;
    ConfirmationQuitterBox = 13;
    ConfirmationArretRetroBox = 14;
    TextNbMin = 15;
    StaticMin = 16;
    NbreMegasBaseText = 17;
    NbrePartiesStaticText = 19;
    {KaleidoscopeBox = 18;
    ZoomRapideBox = 19;
    EmulationPCBox = 20;}
    {SubtilsEffets3DBox = 21;
    TaillePionsText = 23;
    LisereBox = 25;}
    PoliceRapportStatic = 20;
    PoliceRapportUserItemPopUp = 21;
    {OmbrageBox = 23;}
    ChoixEvalStatic = 22;
    ChoixEvalUserItemPopUp = 23;
    ParallelismeStatic = 24;
    ParallelismeUserItemPopUp = 25;
    MenuFlottantPoliceRapportID = 3011;
    MenuFlottantChoixEvalID = 3012;
    MenuFlottantParallelismeID = 3013;

  var dp : DialogPtr;
      itemHit : SInt16;
      PrefsRadios : RadioRec;
      FiltreDialoguePrefsUPP : ModalFilterUPP;
      err : OSErr;
      doitRedessinerOthellier : boolean;
      retirerEffet3DSubtilOthellier2DArrivee : boolean;
      avecLisereNoirSurPionsBlancsArrivee : boolean;
      avecOmbrageDesPionsArrivee : boolean;
      gPourcentageTailleDesPionsArrivee : SInt32;
      gNbreMegaoctetsPourLaBaseArrivee : SInt32;
      themeCourantDeCassioArrivee : SInt32;

      menuPoliceRapportRect : rect;
      itemMenuPoliceRapport : SInt16;
      MenuFlottantPoliceRapport : MenuRef;

      menuChoixEvalRect : rect;
      itemMenuChoixEval : SInt16;
      MenuFlottantChoixEval : MenuRef;

      menuParallelismeRect : rect;
      itemMenuParallelisme : SInt16;
      MenuFlottantParallelisme : MenuRef;

      itemMenuChoixEvalArrivee    : SInt16;
			itemMenuParallelismeArrivee : SInt16;

      nombrePartiesStr,s : String255;

  procedure InstalleMenuFlottantPoliceRapport;
  begin
    MenuFlottantPoliceRapport := MyGetMenu(MenuFlottantPoliceRapportID);
	  InsertMenu(MenuFlottantPoliceRapport, -1);
  end;

  procedure DesinstalleMenuFlottantPoliceRapport;
	begin
	  DeleteMenu(MenuFlottantPoliceRapportID);
	  TerminateMenu(MenuFlottantPoliceRapport,true);
	end;

	procedure InstalleMenuFlottantChoixEval;
	var name : String255;
	    k : SInt32;
  begin
    MenuFlottantChoixEval := MyGetMenu(MenuFlottantChoixEvalID);
    if CassioEstUnBundleApplicatif and (GetEngineBundleName <> '') then
      for k := 1 to NumberOfEngines do
        begin
          name := GetEngineName(k);
          if (name <> '') then
            begin
              name[1] := UpperCase(name[1]);
              MyAppendMenu(MenuFlottantChoixEval, name);
            end;
        end;
	  InsertMenu(MenuFlottantChoixEval, -1);
  end;

  procedure DesinstalleMenuFlottantChoixEval;
	begin
	  DeleteMenu(MenuFlottantChoixEvalID);
	  TerminateMenu(MenuFlottantChoixEval,true);
	end;

	procedure InstalleMenuFlottantParallelisme;
  begin
    MenuFlottantParallelisme := MyGetMenu(MenuFlottantParallelismeID);
	  InsertMenu(MenuFlottantParallelisme, -1);
  end;

  procedure DesinstalleMenuFlottantParallelisme;
	begin
	  DeleteMenu(MenuFlottantParallelismeID);
	  TerminateMenu(MenuFlottantParallelisme,true);
	end;

  procedure InitDialoguePref(Radios : RadioRec);
    var  numeroEngine : SInt32;
    begin
      LecturePreparatoireDossierEngines(pathCassioFolder);

      SetIntegerEditableText(dp,TextNbMin,analyseRetrograde.nbMinPourConfirmationArret);
      {SetBoolCheckBox(dp,VerifierBiblBox,avecTestBibliotheque);}
      SetBoolCheckBox(dp,EnregistrerPrefsBox,avecSauvegardePref);
      SetBoolCheckBox(dp,ConfirmationQuitterBox,doitConfirmerQuitter);
      SetBoolCheckBox(dp,ConfirmationArretRetroBox,analyseRetrograde.doitConfirmerArret);
      {SetBoolCheckBox(dp,ZoomRapideBox,SupprimerLesEffetsDeZoom);
      SetBoolCheckBox(dp,KaleidoscopeBox,OptimisePourKaleidoscope);
      SetBoolCheckBox(dp,EmulationPCBox,sousEmulatorSousPC);}
      {SetBoolCheckBox(dp,SubtilsEffets3DBox,retirerEffet3DSubtilOthellier2D);
      SetBoolCheckBox(dp,LisereBox,avecLisereNoirSurPionsBlancs);
      SetBoolCheckBox(dp,OmbrageBox,avecOmbrageDesPions);
      SetIntegerEditableText(dp,TaillePionsText,gPourcentageTailleDesPions);}
      SetIntegerEditableText(dp,NbreMegasBaseText,gNbreMegaoctetsPourLaBase);

      if (Radios.selection = BoutonJamais) or (Radios.selection = BoutonToujours)
        then SetIntegerEditableText(dp,TextNbExplications,2)
        else SetIntegerEditableText(dp,TextNbExplications,nbExplicationsPasses);

      retirerEffet3DSubtilOthellier2DArrivee := retirerEffet3DSubtilOthellier2D;
      gPourcentageTailleDesPionsArrivee := gPourcentageTailleDesPions;
      avecLisereNoirSurPionsBlancsArrivee := avecLisereNoirSurPionsBlancs;
      avecOmbrageDesPionsArrivee := avecOmbrageDesPions;
      gNbreMegaoctetsPourLaBaseArrivee := gNbreMegaoctetsPourLaBase;
      themeCourantDeCassioArrivee := themeCourantDeCassio;

      GetDialogItemRect(dp, PoliceRapportUserItemPopUp, menuPoliceRapportRect);
      GetDialogItemRect(dp, ChoixEvalUserItemPopUp, menuChoixEvalRect);
      GetDialogItemRect(dp, ParallelismeUserItemPopUp, menuParallelismeRect);

			itemMenuPoliceRapport := themeCourantDeCassio;
			if CassioIsUsingAnEngine(numeroEngine)
			  then itemMenuChoixEval := numeroEngine + 2
			  else itemMenuChoixEval := TypeEvalEnCoursEnInteger;
			itemMenuParallelisme := numProcessors;

			itemMenuChoixEvalArrivee    := itemMenuChoixEval;
			itemMenuParallelismeArrivee := itemMenuParallelisme;


    end;

  procedure ChangeChoixMoteurEvaluation(numeroMoteurDansMenu : SInt32);
  var oldEngine : SInt32;
      CassioAttendaitUnResultat : boolean;
  begin
    oldEngine := numeroEngineEnCours;
    if (numeroMoteurDansMenu <= 2)
      then
        begin
          {Cassio, Edmond}
          SetTypeEvaluationEnCours(numeroMoteurDansMenu);
          numeroEngineEnCours := 0;
        end
      else
        begin
          { Autre moteur }
          SetTypeEvaluationEnCours(SInt32(EVAL_EDMOND));
          numeroEngineEnCours := numeroMoteurDansMenu - 2;
        end;

    if (numeroEngineEnCours <> oldEngine) then
      begin
        CassioAttendaitUnResultat := CassioIsWaitingAnEngineResult;

        // kill the old engine, if necessary
        if (oldEngine <> 0) then
          begin
            KillCurrentEngine;
            Wait(0.25);
          end;

        // start the new engine
        if (numeroEngineEnCours <> 0) then
          begin
            if not(CanStartEngine(GetEnginePath(numeroEngineEnCours,''), IntToStr(numProcessors)))
              then numeroEngineEnCours := 0;
            if CassioAttendaitUnResultat and (numeroEngineEnCours <> 0) then
              begin
                Wait(1.0);   // wait a one second
                RelancerDerniereRechercheEngine;
              end;
          end;
      end;
  end;


  procedure ChangeNombreDeProcesseurs(nombreProcesseursVoulus : SInt32);
  var oldNombreDeProcesseurs : SInt32;
      numeroEngine : SInt32;
      CassioAttendaitUnResultat : boolean;
  begin

    oldNombreDeProcesseurs := numProcessors;

    SetNombreDeProcesseursActifs(nombreProcesseursVoulus);

    if (numProcessors <> oldNombreDeProcesseurs) and CassioIsUsingAnEngine(numeroEngine) then
      begin
        CassioAttendaitUnResultat := CassioIsWaitingAnEngineResult;

        KillCurrentEngine;
        Wait(0.25);

        // restart the engine with the new number of processors
        if (numeroEngine <> 0) then
          begin
            if not(CanStartEngine(GetEnginePath(numeroEngine,''), IntToStr(numProcessors)))
              then numeroEngineEnCours := 0;
            if CassioAttendaitUnResultat and (numeroEngineEnCours <> 0) then
              begin
                Wait(1.0);   // wait a one second
                RelancerDerniereRechercheEngine;
              end;
          end;
      end;

  end;


  procedure ChangeMoteurEtNombreDeProcesseurs(numeroMoteurDansMenu, nombreProcesseursVoulus : SInt32);
  var oldEngine : SInt32;
      oldNombreDeProcesseurs : SInt32;
      CassioAttendaitUnResultat : boolean;
  begin

    // essayer de changer le moteur
    oldEngine := numeroEngineEnCours;
    if (numeroMoteurDansMenu <= 2)
      then
        begin
          {Cassio, Edmond}
          SetTypeEvaluationEnCours(numeroMoteurDansMenu);
          numeroEngineEnCours := 0;
        end
      else
        begin
          { Autre moteur }
          SetTypeEvaluationEnCours(SInt32(EVAL_EDMOND));
          numeroEngineEnCours := numeroMoteurDansMenu - 2;
        end;

    // essayer de changer le nombre de processeurs
    oldNombreDeProcesseurs := numProcessors;
    SetNombreDeProcesseursActifs(nombreProcesseursVoulus);


    if (numeroEngineEnCours <> oldEngine) or (numProcessors <> oldNombreDeProcesseurs) then
      begin
        CassioAttendaitUnResultat := CassioIsWaitingAnEngineResult;

        // kill the old engine, if necessary
        if (oldEngine <> 0) then
          begin
            KillCurrentEngine;
            Wait(0.25);
          end;

        // start the new engine with the new number of processors
        if (numeroEngineEnCours <> 0) then
          begin
            if not(CanStartEngine(GetEnginePath(numeroEngineEnCours,''), IntToStr(numProcessors)))
              then numeroEngineEnCours := 0;
            if CassioAttendaitUnResultat and (numeroEngineEnCours <> 0) then
              begin
                Wait(1.0);   // wait a one second
                RelancerDerniereRechercheEngine;
              end;
          end;
      end;
  end;

  procedure ChangePreferences(Radios : RadioRec);
    begin
      GetLongintEditableText(dp,TextNbMin,analyseRetrograde.nbMinPourConfirmationArret);
      {GetBoolCheckBox(dp,VerifierBiblBox,avecTestBibliotheque);}
      GetBoolCheckBox(dp,EnregistrerPrefsBox,avecSauvegardePref);
      GetBoolCheckBox(dp,ConfirmationQuitterBox,doitConfirmerQuitter);
      GetBoolCheckBox(dp,ConfirmationArretRetroBox,analyseRetrograde.doitConfirmerArret);
      {GetBoolCheckBox(dp,ZoomRapideBox,SupprimerLesEffetsDeZoom);
      GetBoolCheckBox(dp,KaleidoscopeBox,OptimisePourKaleidoscope);
      GetBoolCheckBox(dp,EmulationPCBox,sousEmulatorSousPC);}
      {GetBoolCheckBox(dp,SubtilsEffets3DBox,retirerEffet3DSubtilOthellier2D);
      GetBoolCheckBox(dp,LisereBox,avecLisereNoirSurPionsBlancs);
      GetBoolCheckBox(dp,OmbrageBox,avecOmbrageDesPions);


      GetLongintEditableText(dp,TaillePionsText,gPourcentageTailleDesPions);}

      GetLongintEditableText(dp,NbreMegasBaseText,gNbreMegaoctetsPourLaBase);

      case Radios.selection of
         BoutonJamais    : nbExplicationsPasses := 0;
         BoutonToujours  : nbExplicationsPasses := 10000;
         BoutonParfois   : GetIntegerEditableText(dp,TextNbExplications,nbExplicationsPasses);
      end;

      if gNbreMegaoctetsPourLaBase <= 0 then gNbreMegaoctetsPourLaBase := 1;

      if gIsRunningUnderMacOSX and (gNbreMegaoctetsPourLaBase <> gNbreMegaoctetsPourLaBaseArrivee)
		    then ChangeNbPartiesChargeablesPourBase(CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024));

      themeCourantDeCassio := itemMenuPoliceRapport;
      ChangeChoixMoteurEvaluation(itemMenuChoixEval);
      typeEvalDemandeeDansLesPreferences := typeEvalEnCours;
      ChangeNombreDeProcesseurs(itemMenuParallelisme);
    end;



  begin
    with PrefsRadios do
      begin
        firstButton := BoutonToujours;
        lastButton := BoutonJamais;
        case nbExplicationsPasses of
              0         : selection := BoutonJamais;
              10000     : selection := BoutonToujours;
              otherWise   selection := BoutonParfois;
            end;
      end;
    BeginDialog;
    FiltreDialoguePrefsUPP := NewModalFilterUPP(MyFiltreClassiqueRapide);
    dp := MyGetNewDialog(PreferencesDialogueID);
    if dp <> NIL then
    begin
      doitRedessinerOthellier := false;

      GetItemTextInDialog(dp,NbrePartiesStaticText,nombrePartiesStr);
      s := IntToStr(CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024));
      s := SeparerLesChiffresParTrois(s);
      s := ParamStr(nombrePartiesStr,s,'','','');
      SetItemTextInDialog(dp,NbrePartiesStaticText,s);


      MyDrawDialog(dp);

      InitRadios(dp,PrefsRadios);
      InitDialoguePref(PrefsRadios);
      InstalleMenuFlottantPoliceRapport;
      InstalleMenuFlottantChoixEval;
      InstalleMenuFlottantParallelisme;

      DrawPUItem(MenuFlottantPoliceRapport, itemMenuPoliceRapport, menuPoliceRapportRect, true);
      DrawPUItem(MenuFlottantChoixEval, itemMenuChoixEval, menuChoixEvalRect, true);
      DrawPUItem(MenuFlottantParallelisme, itemMenuParallelisme, menuParallelismeRect, true);

      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreDialoguePrefsUPP,itemHit);
        if (itemHit <> OK) and (itemHit <> Annuler) then
          begin
            case itemHit of
              VirtualUpdateItemInDialog : begin
																						BeginUpdate(GetDialogWindow(dp));
																						SetPortByDialog(dp);
																						MyDrawDialog(dp);
																						DrawPUItem(MenuFlottantPoliceRapport, itemMenuPoliceRapport, menuPoliceRapportRect, true);
																						DrawPUItem(MenuFlottantChoixEval, itemMenuChoixEval, menuChoixEvalRect, true);
																						DrawPUItem(MenuFlottantParallelisme, itemMenuParallelisme, menuParallelismeRect, true);
																						OutlineOK(dp);
																						EndUpdate(GetDialogWindow(dp));
																					end;
              BoutonToujours            : PushRadio(dp,PrefsRadios,BoutonToujours);
              BoutonParfois             : PushRadio(dp,PrefsRadios,BoutonParfois);
              BoutonJamais              : PushRadio(dp,PrefsRadios,BoutonJamais);
              TextNbExplications        : begin
                                            PushRadio(dp,PrefsRadios,BoutonParfois);
                                            FiltrerChiffreInEditText(dp,TextNbExplications);
                                          end;
              NbreMegasBaseText         : begin
                                            FiltrerChiffreInEditText(dp,NbreMegasBaseText);
                                            GetLongintEditableText(dp,NbreMegasBaseText,gNbreMegaoctetsPourLaBase);

                                            s := IntToStr(CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024));
                                            s := SeparerLesChiffresParTrois(s);
                                            s := ParamStr(nombrePartiesStr,s,'','','');
                                            SetItemTextInDialog(dp,NbrePartiesStaticText,s);
                                          end;
              StaticPremiereFois        : PushRadio(dp,PrefsRadios,BoutonParfois);
              {VerifierBiblBox           : ToggleCheckBox(dp,VerifierBiblBox);}
              EnregistrerPrefsBox       : ToggleCheckBox(dp,EnregistrerPrefsBox);
              ConfirmationQuitterBox    : ToggleCheckBox(dp,ConfirmationQuitterBox);
              ConfirmationArretRetroBox : ToggleCheckBox(dp,ConfirmationArretRetroBox);
              TextNbMin                 : begin
                                            if not(IsCheckBoxOn(dp,ConfirmationArretRetroBox)) then
                                              ToggleCheckBox(dp,ConfirmationArretRetroBox);
                                            FiltrerChiffreInEditText(dp,TextNbMin);
                                          end;
              StaticMin                 : ToggleCheckBox(dp,ConfirmationArretRetroBox);
              {ZoomRapideBox             : ToggleCheckBox(dp,ZoomRapideBox);
              KaleidoscopeBox           : ToggleCheckBox(dp,KaleidoscopeBox);
              EmulationPCBox            : ToggleCheckBox(dp,EmulationPCBox);}
              {SubtilsEffets3DBox        : begin
                                            ToggleCheckBox(dp,SubtilsEffets3DBox);
                                            if not(gCouleurOthellier.estUneImage) then
                                              begin
                                                doitRedessinerOthellier := true;
                                                retirerEffet3DSubtilOthellier2D := not(retirerEffet3DSubtilOthellier2D);
                                                InvalidateAllCasesDessinEnTraceDeRayon;
                                                InvalidateAllOffScreenPICTs;
                                                EcranStandard(NIL,true);
                                              end;
                                          end;
              TaillePionsText           : begin
                                            FiltrerChiffreInEditText(dp,TaillePionsText);
                                            GetLongintEditableText(dp,TaillePionsText,aux);
                                            if (aux > 10) and not(gCouleurOthellier.estUneImage) then
                                              begin
                                                doitRedessinerOthellier := true;
                                                gPourcentageTailleDesPions := aux;
                                                InvalidateAllOffScreenPICTs;
                                                InvalidateAllCasesDessinEnTraceDeRayon;
                                                EcranStandard(NIL,true);
                                              end;
                                          end;
              LisereBox                 : begin
                                            ToggleCheckBox(dp,LisereBox);
                                            if not(gCouleurOthellier.estUneImage) then
                                              begin
                                                doitRedessinerOthellier := true;
                                                avecLisereNoirSurPionsBlancs := not(avecLisereNoirSurPionsBlancs);
                                                InvalidateAllOffScreenPICTs;
                                                InvalidateAllCasesDessinEnTraceDeRayon;
                                                EcranStandard(NIL,true);
                                              end;
                                          end;
              OmbrageBox                 : begin
                                            ToggleCheckBox(dp,OmbrageBox);
                                            if not(gCouleurOthellier.estUneImage) then
                                              begin
                                                doitRedessinerOthellier := true;
                                                avecOmbrageDesPions := not(avecOmbrageDesPions);
                                                InvalidateAllOffScreenPICTs;
                                                InvalidateAllCasesDessinEnTraceDeRayon;
                                                EcranStandard(NIL,true);
                                              end;
                                          end;}
              PoliceRapportUserItemPopUp : begin
                                            if EventPopUpItemInDialog(dp, PoliceRapportStatic, MenuFlottantPoliceRapport, itemMenuPoliceRapport, menuPoliceRapportRect, true, true)
										                          then SelectCassioFonts(itemMenuPoliceRapport);
										                        InvalidateAllWindows;
                                          end;
              ChoixEvalUserItemPopUp    : begin
                                            if EventPopUpItemInDialog(dp, ChoixEvalStatic, MenuFlottantChoixEval, itemMenuChoixEval, menuChoixEvalRect, true, true)
										                          then ChangeChoixMoteurEvaluation(itemMenuChoixEval);
										                        InvalidateAllWindows;
                                          end;
              ParallelismeUserItemPopUp : begin
                                            if EventPopUpItemInDialog(dp, ParallelismeStatic, MenuFlottantParallelisme, itemMenuParallelisme, menuParallelismeRect, true, true)
										                          then
										                            begin
										                              itemMenuParallelisme := Min(MPProcessorsScheduled,itemMenuParallelisme);
										                              ChangeNombreDeProcesseurs(itemMenuParallelisme);
										                              DrawPUItem(MenuFlottantParallelisme, numProcessors, menuParallelismeRect, true);
										                            end;
										                        InvalidateAllWindows;
                                          end;

            end;
          end;
      until (itemHit = OK) or (itemHit = Annuler);

      {on se prepare pour Annuler, au cas ou}
      retirerEffet3DSubtilOthellier2D := retirerEffet3DSubtilOthellier2DArrivee;
      gPourcentageTailleDesPions      := gPourcentageTailleDesPionsArrivee;
      avecLisereNoirSurPionsBlancs    := avecLisereNoirSurPionsBlancsArrivee;
      avecOmbrageDesPions             := avecOmbrageDesPionsArrivee;
      gNbreMegaoctetsPourLaBase       := gNbreMegaoctetsPourLaBaseArrivee;
      themeCourantDeCassio            := themeCourantDeCassioArrivee;

      {mais si on a clique sur OK, il faut vraiment changer}
      if (itemHit = OK) then ChangePreferences(PrefsRadios);

      SelectCassioFonts(themeCourantDeCassio);
      if themeCourantDeCassio <> themeCourantDeCassioArrivee
        then InvalidateAllWindows;

      if doitRedessinerOthellier then
        begin
          InvalidateAllOffScreenPICTs;
          InvalidateAllCasesDessinEnTraceDeRayon;
          EcranStandard(NIL,true);
        end;

      {si on a clique sur Annuler, alors il faut annuler les nouveaux moteurs}
      if (itemHit = Annuler) and
         ((itemMenuChoixEvalArrivee <> itemMenuChoixEval) or (itemMenuParallelismeArrivee <> itemMenuParallelisme))
         then ChangeMoteurEtNombreDeProcesseurs(itemMenuChoixEvalArrivee,itemMenuParallelismeArrivee);

      DesinstalleMenuFlottantPoliceRapport;
      DesinstalleMenuFlottantChoixEval;
      DesinstalleMenuFlottantParallelisme;
      MyDisposeDialog(dp);
    end;
    MyDisposeModalFilterUPP(FiltreDialoguePrefsUPP);
    EndDialog;
 end;


procedure DoDialoguePreferencesAffichage;
  const
    PreferencesAffichageID = 161;
    OK = 1;
    Annuler = 2;


    AfficherFondBoisADroiteBox = 10;
    AfficheMeilleureSuiteBox = 11;
    AfficheNumeroDernierCoupBox = 12;
    AfficheProchainsCoupsBox = 13;

    AfficheSuggestionBox = 14;
    AfficheSignesDiacritiquesBox = 15;
    AffichePierresDeltaBox = 16;

    AfficheBibliothequeBox = 17;
    AfficheNotesCassioSurCasesBox = 18;

    AfficheNotesZebraSurOthellierBox = 19;
    AfficheCouleursZebraSurOthellierBox = 20;

    AfficheCouleursZebraDansArbreBox = 21;

    {attention, penser à changer DerniereCheckBox ci-dessous si
     on rajoute des boite a cliquer dans le dialogue !! }

    PremiereCheckBox = 10;
    DerniereCheckBox = 21;


  var dp : DialogPtr;
      itemHit : SInt16;
      err : OSErr;
      FiltreDialogueUPP : ModalFilterUPP;

  procedure SetPreferencesAffichageInDialogue;
  begin
    SetBoolCheckBox(dp,AfficherFondBoisADroiteBox, not(garderPartieNoireADroiteOthellier));
    SetBoolCheckBox(dp,AfficheMeilleureSuiteBox, afficheMeilleureSuite);
    SetBoolCheckBox(dp,AfficheNumeroDernierCoupBox, afficheNumeroCoup);
    SetBoolCheckBox(dp,AfficheProchainsCoupsBox, afficheProchainsCoups);

    SetBoolCheckBox(dp,AfficheSuggestionBox, afficheSuggestionDeCassio);
    SetBoolCheckBox(dp,AffichePierresDeltaBox, affichePierresDelta);
    SetBoolCheckBox(dp,AfficheSignesDiacritiquesBox, afficheSignesDiacritiques);

    SetBoolCheckBox(dp,AfficheBibliothequeBox, afficheBibl);
    SetBoolCheckBox(dp,AfficheNotesCassioSurCasesBox, GetAvecAffichageNotesSurCases(kNotesDeCassio));


    SetBoolCheckBox(dp,AfficheNotesZebraSurOthellierBox,     ZebraBookACetteOption(kAfficherNotesZebraSurOthellier));
    SetBoolCheckBox(dp,AfficheCouleursZebraSurOthellierBox,  ZebraBookACetteOption(kAfficherCouleursZebraSurOthellier));

    SetBoolCheckBox(dp,AfficheCouleursZebraDansArbreBox, ZebraBookACetteOption(kAfficherNotesZebraDansArbre + kAfficherCouleursZebraDansArbre));

  end;

  procedure GetPreferencesAffichageFromDialogue;
  var tempoZebraOptions : SInt32;
      G : GameTree;
  begin

    if (GetCheckBoxValue(dp,AfficherFondBoisADroiteBox) <> not(garderPartieNoireADroiteOthellier)) then DoChangeGarderPartieNoireADroiteOthellier;

    if GetCheckBoxValue(dp,AfficheMeilleureSuiteBox) <> afficheMeilleureSuite then DoChangeAfficheMeilleureSuite;
    if GetCheckBoxValue(dp,AfficheNumeroDernierCoupBox) <> afficheNumeroCoup then DoChangeAfficheDernierCoup;
    if GetCheckBoxValue(dp,AfficheProchainsCoupsBox) <> afficheProchainsCoups then DoChangeAfficheProchainsCoups;

    if GetCheckBoxValue(dp,AfficheSuggestionBox) <> afficheSuggestionDeCassio then DoChangeAfficheSuggestionDeCassio;
    if GetCheckBoxValue(dp,AffichePierresDeltaBox) <> affichePierresDelta then DoChangeAffichePierresDelta;
    if GetCheckBoxValue(dp,AfficheSignesDiacritiquesBox) <> afficheSignesDiacritiques then DoChangeAfficheSignesDiacritiques;

    if GetCheckBoxValue(dp,AfficheBibliothequeBox) <> afficheBibl then DoChangeAfficheBibliotheque;
    if GetCheckBoxValue(dp,AfficheNotesCassioSurCasesBox) <> GetAvecAffichageNotesSurCases(kNotesDeCassio) then DoChangeAfficheNotesSurCases(kNotesDeCassio);


    tempoZebraOptions := GetZebraBookOptions;

    if GetCheckBoxValue(dp,AfficheNotesZebraSurOthellierBox) <> ZebraBookACetteOption(kAfficherNotesZebraSurOthellier)
      then
        begin
          if GetCheckBoxValue(dp,AfficheNotesZebraSurOthellierBox) then SetUsingZebraBook(true);
          ToggleZebraOption(kAfficherNotesZebraSurOthellier);
        end;

    if GetCheckBoxValue(dp,AfficheCouleursZebraSurOthellierBox) <> ZebraBookACetteOption(kAfficherCouleursZebraSurOthellier)
      then
        begin
          if GetCheckBoxValue(dp,AfficheCouleursZebraSurOthellierBox) then SetUsingZebraBook(true);
          ToggleZebraOption(kAfficherCouleursZebraSurOthellier);
        end;

    if GetCheckBoxValue(dp,AfficheCouleursZebraDansArbreBox) <> ZebraBookACetteOption(kAfficherCouleursZebraDansArbre)
      then
        begin
          if GetCheckBoxValue(dp,AfficheCouleursZebraDansArbreBox) then SetUsingZebraBook(true);
          ToggleZebraOption(kAfficherNotesZebraDansArbre);
          ToggleZebraOption(kAfficherCouleursZebraDansArbre);
        end;


    if (tempoZebraOptions <> GetZebraBookOptions) then
      begin
        LoadZebraBook(false);

        G := GetCurrentNode;
        DetruitLesFilsZebraBookInutilesDeCeNoeud(G);
        LireBibliothequeDeZebraPourCurrentNode('GetPreferencesAffichageFromDialogue');

        EffaceNoteSurCases(kNotesDeCassio,othellierToutEntier);
        EffaceNoteSurCases(kNotesDeZebra,othellierToutEntier);

        if GetAvecAffichageNotesSurCases(kNotesDeCassio) and (BAND(GetAffichageProprietesOfCurrentNode,kNotesCassioSurLesCases) <> 0)
		      then DessineNoteSurCases(kNotesDeCassio,othellierToutEntier);

		    if GetAvecAffichageNotesSurCases(kNotesDeZebra) and (BAND(GetAffichageProprietesOfCurrentNode,kNotesZebraSurLesCases) <> 0)
		      then DessineNoteSurCases(kNotesDeZebra,othellierToutEntier);

		    AfficheProprietesOfCurrentNode(true,othellierToutEntier,'GetPreferencesAffichageFromDialogue');

		    if EstVisibleDansFenetreArbreDeJeu(GetCurrentNode) then
          begin
            EffaceNoeudDansFenetreArbreDeJeu;
            LireBibliothequeDeZebraPourCurrentNode('GetPreferencesAffichageFromDialogue');
            EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
          end;

      end;

  end;

begin
  BeginDialog;
  FiltreDialogueUPP := NewModalFilterUPP(MyFiltreClassiqueRapide);
  dp := MyGetNewDialog(PreferencesAffichageID);
  if (dp <> NIL) then
    begin
      SetPreferencesAffichageInDialogue;
      MyDrawDialog(dp);
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreDialogueUPP,itemHit);
        if (itemHit <> OK) and (itemHit <> Annuler) and
           (itemHit >= PremiereCheckBox) and (itemHit <= DerniereCheckBox)
          then
            begin
              ToggleCheckBox(dp,itemHit);
              GetPreferencesAffichageFromDialogue;
            end;
      until (itemHit = OK) or (itemHit = Annuler);
      if (itemHit = OK) then
        GetPreferencesAffichageFromDialogue;
      MyDisposeDialog(dp);
    end;
  MyDisposeModalFilterUPP(FiltreDialogueUPP);
  EndDialog;
  AjusteCurseur;
end;


procedure DoDialoguePreferencesSpeciales;
const DialogueDebugageID = 153;
      OK = 1;
      Annuler = 2;
      PremiereCheckBox = 5;
      DerniereCheckBox = 40;
var dp : DialogPtr;
    itemHit : SInt16;
    FiltreDialogueDebuggageUPP : ModalFilterUPP;
    differencierLesFreresArrivee : boolean;
    err : OSErr;
    algoMetaphoneArrivee : boolean;

  procedure SetVariablesSpecialesInDialogue;
  begin
    SetBoolCheckBox(dp,5,debuggage.general);
    {SetBoolCheckBox(dp,6,debuggage.entreesSortiesUnitFichiersTEXT);}
    SetBoolCheckBox(dp,6,GetDebuggageUnitFichiersTexte);
    SetBoolCheckBox(dp,7,debuggage.pendantLectureBase);
    SetBoolCheckBox(dp,8,debuggage.afficheSuiteInitialisations);
    SetBoolCheckBox(dp,9,debuggage.evenementsDansRapport);
    SetBoolCheckBox(dp,10,debuggage.elementsStrategiques);
    SetBoolCheckBox(dp,11,debuggage.gestionDuTemps);
    SetBoolCheckBox(dp,12,debuggage.calculFinaleOptimaleParOptimalite);
    SetBoolCheckBox(dp,13,debuggage.arbreDeJeu);
    SetBoolCheckBox(dp,14,debuggage.lectureSmartGameBoard);
    SetBoolCheckBox(dp,15,debuggage.apprentissage);
    SetBoolCheckBox(dp,16,debuggage.algoDeFinale);
    SetBoolCheckBox(dp,17,debuggage.MacOSX);
    SetBoolCheckBox(dp,18,debuggage.engineInput);
    SetBoolCheckBox(dp,19,debuggage.engineOutput);
    SetBoolCheckBox(dp,20,(VerbosityOfZoo > 0));
    SetBoolCheckBox(dp,27,CassioIsUsingMetaphone);
    SetBoolCheckBox(dp,28,listeEtroiteEtNomsCourts);
    SetBoolCheckBox(dp,29,InfosTechniquesDansRapport);
    SetBoolCheckBox(dp,30,avecNomOuvertures);
    SetBoolCheckBox(dp,31,enModeIOS);
    SetBoolCheckBox(dp,32,LaDemoApprend);
    SetBoolCheckBox(dp,33,not(CassioDoitRentrerEnContactAvecLeZoo));
    SetBoolCheckBox(dp,34,afficheInfosApprentissage);
    SetBoolCheckBox(dp,35,avecRefutationsDansRapport);
    SetBoolCheckBox(dp,36,NePasUtiliserLeGrasFenetreOthellier);
    SetBoolCheckBox(dp,37,GetReveillerRegulierementLeMac);
    SetBoolCheckBox(dp,38,affichageReflexion.afficherToutesLesPasses);
    SetBoolCheckBox(dp,39,CassioUtiliseDesMajuscules);
    SetBoolCheckBox(dp,40,differencierLesFreres);

    differencierLesFreresArrivee := differencierLesFreres;
    algoMetaphoneArrivee := CassioIsUsingMetaphone;
  end;

  procedure GetVariablesSpecialesFromDialogue;
  var aux : boolean;
  begin
    GetBoolCheckBox(dp,5,debuggage.general);
    GetBoolCheckBox(dp,6,debuggage.entreesSortiesUnitFichiersTEXT);
    SetDebuggageUnitFichiersTexte(debuggage.entreesSortiesUnitFichiersTEXT);
    GetBoolCheckBox(dp,7,debuggage.pendantLectureBase);
    GetBoolCheckBox(dp,8,debuggage.afficheSuiteInitialisations);
    GetBoolCheckBox(dp,9,debuggage.evenementsDansRapport);
    GetBoolCheckBox(dp,10,debuggage.elementsStrategiques);
    GetBoolCheckBox(dp,11,debuggage.gestionDuTemps);
    GetBoolCheckBox(dp,12,debuggage.calculFinaleOptimaleParOptimalite);
    GetBoolCheckBox(dp,13,debuggage.arbreDeJeu);
    GetBoolCheckBox(dp,14,debuggage.lectureSmartGameBoard);
    GetBoolCheckBox(dp,15,debuggage.apprentissage);
    GetBoolCheckBox(dp,16,debuggage.algoDeFinale);
    GetBoolCheckBox(dp,17,debuggage.MacOSX);
    GetBoolCheckBox(dp,18,debuggage.engineInput);
    GetBoolCheckBox(dp,19,debuggage.engineOutput);
    GetBoolCheckBox(dp,20,aux);  {"debug zoo"}
    if aux
      then SetVerbosityOfZoo(2)
      else SetVerbosityOfZoo(0);
    GetBoolCheckBox(dp,27,aux);  {"Noms algo Metaphone"}
    SetCassioIsUsingMetaphone(aux);
    GetBoolCheckBox(dp,28,listeEtroiteEtNomsCourts);
    GetBoolCheckBox(dp,29,InfosTechniquesDansRapport);
    GetBoolCheckBox(dp,30,avecNomOuvertures);
    GetBoolCheckBox(dp,31,enModeIOS);
    GetBoolCheckBox(dp,32,LaDemoApprend);
    GetBoolCheckBox(dp,33,UtiliseGrapheApprentissage);
    GetBoolCheckBox(dp,33,aux);  {"Deconnecter du réseau"}
    if aux
      then SetCassioDoitRentrerEnContactAvecLeZoo('NO')
      else SetCassioDoitRentrerEnContactAvecLeZoo('YES');
    GetBoolCheckBox(dp,34,afficheInfosApprentissage);
    GetBoolCheckBox(dp,35,avecRefutationsDansRapport);
    GetBoolCheckBox(dp,36,NePasUtiliserLeGrasFenetreOthellier);
    GetBoolCheckBox(dp,37,aux);
    SetReveillerRegulierementLeMac(aux);
    GetBoolCheckBox(dp,38,affichageReflexion.afficherToutesLesPasses);
    GetBoolCheckBox(dp,39,CassioUtiliseDesMajuscules);
    GetBoolCheckBox(dp,40,differencierLesFreres);

    if (differencierLesFreres <> differencierLesFreresArrivee) then EffaceTousLesNomsCourtsDesJoueurs;
    if (CassioIsUsingMetaphone <> algoMetaphoneArrivee) then RegenererLesNomsMetaphoneDeLaBase;
  end;

begin
  BeginDialog;
  FiltreDialogueDebuggageUPP := NewModalFilterUPP(MyFiltreClassiqueRapide);
  dp := MyGetNewDialog(DialogueDebugageID);
  if dp <> NIL then
    begin
      SetVariablesSpecialesInDialogue;
      MyDrawDialog(dp);
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreDialogueDebuggageUPP,itemHit);
        if (itemHit <> OK) and (itemHit <> Annuler) and
           (itemHit >= PremiereCheckBox) and (itemHit <= DerniereCheckBox)
          then ToggleCheckBox(dp,itemHit);
      until (itemHit = OK) or (itemHit = Annuler);
      if (itemHit = OK) then
        GetVariablesSpecialesFromDialogue;
      MyDisposeDialog(dp);
    end;
  MyDisposeModalFilterUPP(FiltreDialogueDebuggageUPP);
  EndDialog;
end;


procedure LitFichierGroupes;
var fichierGroupes : FichierTEXT;
    filename : String255;
    s : String255;
    erreurES : SInt16;
    nbGroupes,longueur : SInt16;
begin
  filename := 'groupes Cassio';
  erreurES := FichierTexteDeCassioExiste(filename,fichierGroupes);
  if erreurES <> NoErr then exit;
  erreurES := OuvreFichierTexte(fichierGroupes);
  if erreurES <> NoErr then exit;

  nbGroupes := 0;
  repeat
    erreurES := ReadlnDansFichierTexte(fichierGroupes,s);
    if (s <> '') and (erreurES = NoErr) then
      if s[1] = '∑' then
        begin
          longueur := LENGTH_OF_STRING(s);
          if s[longueur] <> '}' then
            if longueur = 255
              then s[longueur] := '}'
              else s := s + CharToString('}');
          nbGroupes := nbGroupes+1;
          if nbGroupes <= nbMaxGroupes then
            groupes^^[nbGroupes] := s;
        end;
  until (nbGroupes >= nbMaxGroupes) or (erreurES <> NoErr) or EOFFichierTexte(fichiergroupes,erreurES);
  erreurES := FermeFichierTexte(fichierGroupes);
end;


procedure CreeFichierGroupes;
var fichierGroupes : FichierTEXT;
    filename,s : String255;
    erreurES : SInt16;
    i : SInt16;

 function ListeDesGroupesEstVide : boolean;
   var i : SInt16;
   begin
     ListeDesGroupesEstVide := true;
     for i := 1 to nbMaxGroupes do
       if groupes^^[i] <> '' then
         begin
           ListeDesGroupesEstVide := false;
           exit;
         end;
   end;

begin
  if not(ListeDesGroupesEstVide) then
    begin
      filename := 'groupes Cassio';
      erreurES := FichierTexteDeCassioExiste(filename,fichierGroupes);
      if erreurES = fnfErr  {-43 => File not found}
        then erreurES := CreeFichierTexteDeCassio(fileName,fichierGroupes);
      if erreurES = NoErr {le fichier groupes existe : on l'ouvre et on le vide}
		    then
		      begin
		        erreurES := OuvreFichierTexte(fichierGroupes);
		        erreurES := VideFichierTexte(fichierGroupes);
		      end;
      if erreurES <> 0 then exit;

      for i := 1 to nbMaxGroupes do
        begin
          s := groupes^^[i];
          if s <> '' then
            erreurES := WritelnDansFichierTexte(fichierGroupes,s);
        end;

      erreurES := FermeFichierTexte(fichierGroupes);
      SetFileCreatorFichierTexte(fichierGroupes,MY_FOUR_CHAR_CODE('SNX4'));
      SetFileTypeFichierTexte(fichierGroupes,MY_FOUR_CHAR_CODE('sgma'));
    end;
end;

procedure InstallerFichierCronjob(nomFichierCronjob : String255);
var source,dest : FichierTEXT;
    nomSource,nomDest : String255;
    err : OSErr;
begin
  if CassioEstUnBundleApplicatif then
    begin
      WritelnDansRapport('Updating file ' + nomFichierCronjob + ' ...');


      nomSource := pathCassioFolder + 'Cassio.app:Contents:Cronjobs:' + nomFichierCronjob;
      nomDest   := pathCassioFolder + nomFichierCronjob;

      (*
      WritelnDansRapport('nomSource = ' + nomSource);
      WritelnDansRapport('nomDest = ' + nomDest);
      *)

      if (FichierTexteExiste(nomSource,0,source) = NoErr) and
         (FichierTexteExiste(nomDest,0,dest) = NoErr) then
         begin
           err := OuvreFichierTexte(source);

           WritelnNumDansRapport('[1]  err = ',err);

           if (err = NoErr) then
             begin
               err := OuvreFichierTexte(dest);
               err := VideFichierTexte(dest);
               err := FermeFichierTexte(dest);

               WritelnNumDansRapport('[2]  err = ',err);

               err := InsererFichierTexteDansFichierTexte(source, dest);

               WritelnNumDansRapport('[3]  err = ',err);

             end;


           err := FermeFichierTexte(source);

           WritelnNumDansRapport('[4]  err = ',err);
         end;


    end;
end;


procedure GereSauvegardePreferences;
var cheminThorDBA,cheminThorDBASol : String255;
    volRefThorDBA,volRefThorDBASol : SInt16;
begin
  if avecSauvegardePref
    then CreeFichierPreferences
    else
      begin
        cheminThorDBA := CheminAccesThorDBA^^;
	      cheminThorDBASol := CheminAccesThorDBASolitaire^^;
	      volRefThorDBA := VolumeRefThorDBA;
	      volRefThorDBASol := VolumeRefThorDBASolitaire;
			  LitFichierPreferences;

	      CheminAccesThorDBA^^ := cheminThorDBA;
	      CheminAccesThorDBASolitaire^^ := cheminThorDBASol;
	      VolumeRefThorDBA := volRefThorDBA;
	      VolumeRefThorDBASolitaire := volRefThorDBASol;
	      avecSauvegardePref := false;
			  CreeFichierPreferences;
      end;
end;


procedure SauvegarderListeOfPrefsFiles;
var filename : String255;
    erreurES : OSErr;
    fic : FichierTEXT;
    s : String255;
    i : SInt32;
begin
  filename := 'PrefCassioFileList.txt';
  erreurES := FichierTexteDeCassioExiste(filename,fic);
  if erreurES = fnfErr  {-43 => File not found}
    then erreurES := CreeFichierTexteDeCassio(fileName,fic);
  if erreurES = NoErr {le fichier de la liste des fichiers preference existe : on l'ouvre et on le vide}
    then
      begin
        erreurES := OuvreFichierTexte(fic);
        erreurES := VideFichierTexte(fic);
      end;

  if erreurES <> 0 then exit;

  for i := 1 to kMaxPrefFiles do
    if (gListeOfPrefFiles[i].date <> '') and
       (gListeOfPrefFiles[i].name <> '') then
      begin
        s := gListeOfPrefFiles[i].date + ' ' + gListeOfPrefFiles[i].name;
        erreurES := WritelnDansFichierTexte(fic,s);
      end;

  erreurES := FermeFichierTexte(fic);
end;


procedure LireListeOfPrefsFiles;
var filename : String255;
    erreurES : OSErr;
    fic : FichierTEXT;
    s : String255;
    i,nbPrefFiles : SInt32;
begin

  for i := 1 to kMaxPrefFiles do
    begin
      gListeOfPrefFiles[i].date := '';
      gListeOfPrefFiles[i].name := '';
    end;

  filename := 'PrefCassioFileList.txt';
  erreurES := FichierTexteDeCassioExiste(filename,fic);
  if erreurES = NoErr
    then erreurES := OuvreFichierTexte(fic);
  if erreurES <> 0 then exit;


  nbPrefFiles := 0;
  repeat
    erreurES := ReadlnDansFichierTexte(fic,s);
    if (s <> '') and (erreurES = NoErr) then
      begin
        inc(nbPrefFiles);
        Parser(s,gListeOfPrefFiles[nbPrefFiles].date,gListeOfPrefFiles[nbPrefFiles].name);
      end;
  until (nbPrefFiles >= kMaxPrefFiles) or (erreurES <> NoErr) or EOFFichierTexte(fic,erreurES);

  erreurES := FermeFichierTexte(fic);
end;


procedure AjouterNomDansListOfPrefsFiles(whichName : String255);
var i,indexCourant : SInt32;
begin

  if (whichName <> kNomParDefauFichierPreferences) then
    begin

      LireListeOfPrefsFiles;

      {chercher quel enregistrement ecraser}
      indexCourant := kMaxPrefFiles;
      for i := kMaxPrefFiles downto 1 do
        if gListeOfPrefFiles[i].name = whichName then
          indexCourant := i;

      {placer le nom courant en tete}
      for i := indexCourant downto 2 do
        begin
          gListeOfPrefFiles[i].date := gListeOfPrefFiles[i-1].date;
          gListeOfPrefFiles[i].name := gListeOfPrefFiles[i-1].name;
        end;
      gListeOfPrefFiles[1].date := DateCouranteEnString;
      gListeOfPrefFiles[1].name := whichName;

      SauvegarderListeOfPrefsFiles;
    end;
end;


function NameOfPrefsFile : String255;
var s,s1 : String255;
    nomDeLApplication : String255;
    nomDuBundle : String255;
begin
  s := ReadStringFromRessource(TextesDiversID,3);  {Préférences ^0}

  nomDeLApplication := GetApplicationName('Cassio');

  nomDuBundle := GetApplicationBundleName;

  if (nomDuBundle <> '')
    then nomDeLApplication := nomDuBundle;


  nomDeLApplication := ReplaceStringOnce('.app','-app',nomDeLApplication);

  {
  WritelnDansRapport('nomDeLApplication = '+nomDeLApplication);
  WritelnDansRapport('nomDuBundle = '+nomDuBundle);
  }

  if (nomDeLApplication = 'Cassio') or
     (nomDeLApplication = 'Cassio.app') or
     (nomDeLApplication = '')
    then nomDeLApplication := 'Cassio ' + VersionDeCassioEnString;

  if Pos("^0",s) > 0
    then s1 := ParamStr(s,nomDeLApplication,"","","")
    else s1 := s;

 if LENGTH_OF_STRING(s1) <= 31
   then NameOfPrefsFile := s1
   else NameOfPrefsFile := kNomParDefauFichierPreferences;
end;



function OpenPrefsFileForSequentialReading : OSErr;
var filename : String255;
    autreFichierPreferencesSuggere : String255;
    erreurES : SInt16;
    i : SInt32;
begin
  filename := NameOfPrefsFile;

  erreurES := FichierPreferencesDeCassioExiste(fileName,gPrefsFileInfos.filePtr);


  if erreurES = fnfErr then
   begin
     {fichier préférences non trouvé =  >  on essaie de lire les vieux fichiers de preferences}

     LireListeOfPrefsFiles;
     for i := 1 to kMaxPrefFiles do
       begin
         autreFichierPreferencesSuggere := gListeOfPrefFiles[i].name;
         if (erreurES = fnfErr) and (autreFichierPreferencesSuggere <> '') then
           begin
             erreurES := FichierPreferencesDeCassioExiste(autreFichierPreferencesSuggere,gPrefsFileInfos.filePtr);
             if erreurES = NoErr then
               begin
                 filename := autreFichierPreferencesSuggere;
                 if (i > 1) then AjouterNomDansListOfPrefsFiles(filename);
               end;
           end;
       end;
   end;

  if (erreurES <> NoErr) then
    begin
      OpenPrefsFileForSequentialReading := erreurES;
      exit;
    end;

   erreurES := OuvreFichierTexte(gPrefsFileInfos.filePtr);
   if erreurES <> 0 then
     begin
       OpenPrefsFileForSequentialReading := erreurES;
       exit;
     end;

  gPrefsFileInfos.nbOfLastLineRead := 0;
  gPrefsFileInfos.lastLineRead := '';
  OpenPrefsFileForSequentialReading := erreurES;
end;



function GetNextLineInPrefsFile(var s : String255) : OSErr;
var erreurES : OSErr;
begin
  erreurES := ReadlnDansFichierTexte(gPrefsFileInfos.filePtr,s);
  if erreurES <> 0 then
     begin
       GetNextLineInPrefsFile := erreurES;
       exit;
     end;

  gPrefsFileInfos.nbOfLastLineRead := gPrefsFileInfos.nbOfLastLineRead+1;
  gPrefsFileInfos.lastLineRead := s;
  GetNextLineInPrefsFile := erreurES;
end;



function EOFInPrefsFile : boolean;
var erreurES : OSErr;
begin
  EOFInPrefsFile := EOFFichierTexte(gPrefsFileInfos.filePtr,erreurES)
end;



function ClosePrefsFile : OSErr;
begin
  ClosePrefsFile := FermeFichierTexte(gPrefsFileInfos.filePtr);
end;


end.
