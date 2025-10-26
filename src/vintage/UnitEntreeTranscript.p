UNIT UnitEntreeTranscript;

INTERFACE









 USES UnitDefCassio;



{ Initialisation et liberation de l'unité }
procedure InitUnitEntreeTranscript;
procedure LibereMemoireUnitEntreeTranscript;

{ Passage en mode d'edition de transcript }
procedure SauvegardeReglagesAvantEditionTranscript;
procedure RestoreReglagesApresEditionTranscript;
procedure PrepareCassioPourEditionTranscript;
procedure DoChangeEnModeEntreeTranscript;

{ Drapeaux globaux de communication avec le reste de Cassio}
function EnModeEntreeTranscript : boolean;
function CassioEstEnTrainDeCorrigerUnTranscript : boolean;
function DoitAfficherLaPlusLonguePartiePossible : boolean;
function TranscriptAccepteLesDonnees : boolean;
function TranscriptDoitChercherDesCorrections : boolean;
procedure SetAffichageDeLaPlusLonguePartiePossible(flag : boolean);
procedure SetTranscriptAccepteLesDonnees(newFlag : boolean; var oldFlag : boolean);
procedure SetTranscriptChercheDesCorrections(newFlag : boolean; var oldFlag : boolean);

{ Gestion des erreurs }
procedure ResetTranscriptErrors(var analyse : AnalyseDeTranscript);
procedure RaiseTranscriptError(whichError : SInt64; square : SInt16; var analyse : AnalyseDeTranscript);
function TranscriptError(const analyse : AnalyseDeTranscript) : SInt64;
function HasTranscriptErrorMask(whichErrors : SInt64; const analyse : AnalyseDeTranscript) : boolean;
function HasTheseErrorsForThisMove(whichErrors : SInt64; const analyse : AnalyseDeTranscript; numeroCoup : SInt64) : boolean;
function CurrentTranscriptHasThisErrors(whichErrors : SInt64) : boolean;

{ Fonctions d'acces au type de donnees "Transcript" }
function NumeroDeCetteCaseDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
function NombreCasesRempliesDansTranscript(const myTranscript : Transcript) : SInt16;
function TranscriptALaPositionDeDepartInversee(const whichTranscript : Transcript) : boolean;
function SameTranscript(const t1,t2 : Transcript) : boolean;
function NombreCasesDifferentesDansTranscripts(const t1,t2 : Transcript) : SInt64;
function DistanceTranscripts(var t1,t2 : Transcript) : SInt64;

{ Les cases vides (sans pions) }
function EstUneCaseVideDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : boolean;
function CaseVidePrecedenteDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
function CaseVideSuivanteDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
function PremiereCaseVideDansTranscript(const myTranscript : Transcript) : SInt16;
function DerniereCaseVideDansTranscript(const myTranscript : Transcript) : SInt16;

{ Les cases vides (sans chiffres ni pions) }
function EstUneCaseSansChiffreDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : boolean;
function CaseSansChiffrePrecedenteDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
function CaseSansChiffreSuivanteDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
function PremiereCaseSansChiffreDansTranscript(const myTranscript : Transcript) : SInt16;
function DerniereCaseSansChiffreDansTranscript(const myTranscript : Transcript) : SInt16;

{ Couleur des pions centraux }
function CouleurDeCetteCaseDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
procedure SetCouleurDeCePionDansTranscript(whichSquare,color : SInt16; var myTranscript : Transcript);
procedure InverserCouleurDesPionsDuTranscript(var myTranscript : Transcript);

{ Gestion du transcript courant }
procedure ViderTranscriptCourant;
function CurrentTranscript : Transcript;
function GetCurrentSquareOfCurseur : SInt16;
function GetCurrentLateralisationOfCurseur : SInt16;
function GetCurrentNumeroOfCurseur : SInt16;
function GetCurrentChiffreSousLeCurseur : SInt16;
function CaseAyantLePlusPetitNumeroAuDela(numeroMinimum : SInt16) : SInt16;
function PositionEtTraitInitiauxDuTranscriptCourant : PositionEtTraitRec;
function PositionEtTraitInitiauxDuTranscript(const whichTranscript : Transcript) : PositionEtTraitRec;

{ Changement d'un ou de plusieurs chiffres dans un transcript }
function IncrementerToutesLesCases(numeroMinimum,increment : SInt16; myTranscript : Transcript) : Transcript;
function IncrementerToutesLesCasesAndSetValueDansSquare(numeroMinimum,increment : SInt16; square,value : SInt16; myTranscript : Transcript) : Transcript;
function DecrementerToutesLesCases(numeroMinimum,increment : SInt16; myTranscript : Transcript; var prochainNumeroActif,square : SInt16) : Transcript;
function IncrementerCetteCase(square,increment : SInt16; myTranscript : Transcript) : Transcript;
function EchangerCasesDansTranscript(square1,square2 : SInt16; myTranscript : Transcript) : Transcript;
procedure DecalerTousLesChiffresDansTranscript(caseDebut,lateralisationDebut,dansQuelSens : SInt16);
procedure TraiteDeleteKeyDansTranscript(var myTranscript : Transcript);
procedure TaperChiffreDansTranscript(ch : char);
procedure SetNumeroDeCetteCaseDansTranscript(whichSquare,numero : SInt16; var myTranscript : Transcript);

{ Deplacements du curseur }
function CurseurEstToutEnHautAGauche(var myTranscript : Transcript) : boolean;
function CurseurEstToutEnBasADroite(var myTranscript : Transcript) : boolean;
function GetLateralisationOfCurseur(const myTranscript : Transcript) : SInt16;
function GetSquareOfCurseur(const myTranscript : Transcript) : SInt16;
function ChiffreSousLeCurseur(const myTranscript : Transcript) : SInt16;
procedure MonterCurseur(var myTranscript : Transcript);
procedure DescendreCurseur(var myTranscript : Transcript);
procedure BougerCurseurAGauche(var myTranscript : Transcript);
procedure BougerCurseurADroite(var myTranscript : Transcript);
procedure BougerCurseurCaseSuivante(var myTranscript : Transcript);
procedure BougerCurseurCasePrecedente(var myTranscript : Transcript);
procedure BougerCurseurDebutDeLigne(var myTranscript : Transcript);
procedure BougerCurseurFinDeLigne(var myTranscript : Transcript);
procedure SetPositionCurseur(square,lateralisation : SInt16; var myTranscript : Transcript);

{ Creation d'un transcript }
function MakeTranscript(positionEtTrait : PositionEtTraitRec) : Transcript;
function TranscriptVide : Transcript;
function MakeTranscriptFromPlateauOthello(coups : platValeur) : Transcript;
procedure EntrerPartieDansTranscript(jusqueQuelCoup : SInt16; var myTranscript : Transcript);
procedure EntrerPartieDansCurrentTranscript(jusqueQuelCoup : SInt16);

{ Gestion des erreurs, des numeros dupliques, etc. }
procedure ChercherLesErreursDansCeTranscript(var myTranscript : Transcript; var analyse : AnalyseDeTranscript);
procedure ChercherLesErreursDansLeTranscriptCourant;
procedure SetDerniereCaseTapeeDansTranscript(whichSquare : SInt16);
function DerniereCaseTapee : SInt16;
function DerniereCaseTapeeEstUnCoupIllegal : boolean;
function ProchaineCaseAvecUneErreurDansTranscript(whichSquare,sens : SInt16) : SInt16;
function CeNumeroDeCoupAUneErreur(numero : SInt16; const analyse : AnalyseDeTranscript) : boolean;
function TypeErreurDeCeNumeroDansTranscript(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt64;
function TypeErreurDeCetteCaseDansTranscript(whichSquare : SInt16; const analyse : AnalyseDeTranscript) : SInt64;
function NombreCasesAvecCeNumero(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
function NombreDoublons(const analyse : AnalyseDeTranscript) : SInt16;
function NombreDoublonsApresCeCoup(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
function NombreDoublonsAvantCeCoup(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
function NombreDoublonsConsecutifsApresCeCoup(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
function NombreErreurs(const analyse : AnalyseDeTranscript) : SInt16;
function NombreCoupsIsoles(const analyse : AnalyseDeTranscript) : SInt16;
function NombreCoupsManquants(const analyse : AnalyseDeTranscript) : SInt16;
function NombreCoupsManquantsConsecutifsApresCeCoup(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
function PremierCoupManquant(const analyse : AnalyseDeTranscript) : SInt16;
function PremierCoupIllegal(const analyse : AnalyseDeTranscript) : SInt16;
function PremierDoublon(const analyse : AnalyseDeTranscript) : SInt16;
function PremierCoupIsole(const analyse : AnalyseDeTranscript) : SInt16;
function DernierCoupPresent(const analyse : AnalyseDeTranscript) : SInt16;
function NombreCoupsCorrectsDansTranscript(const whichTranscript : Transcript; var analyse : AnalyseDeTranscript; var positionEtPartie : String255) : SInt16;
function NombreCasesVidesTranscriptCourant : SInt64;
function EstUnePartieLegaleEtComplete(const analyse : AnalyseDeTranscript) : boolean;
function TranscriptCourantEstUnePartieLegaleEtComplete : boolean;
function PlusLonguePartieLegaleDuTranscriptEstDansOthellierDeGauche : boolean;

{ Gestion de la pile des transcripts, pour pouvoir annuler }
procedure EmpileTranscript(const myTranscript : Transcript);
function DepileTranscriptVersLaGauche : Transcript;
function DepileTranscriptVersLaDroite : Transcript;
procedure InitialisePileTranscripts;

{ Fonctions de dessin }
function GetCouleurDesChiffresDuTranscript : RGBColor;
procedure DessineChiffre2DTranscript(square,lateralisation : SInt64);
procedure DessineCaseTranscript(square : SInt64);
procedure DessineTranscriptCourant;
procedure DessineErreursTranscript(whichErrors : SInt64);
procedure EntourerUneCaseDansTranscript(square : SInt64; color : RGBColor);
procedure EcranStandardTranscript;
procedure AfficherPartieDuTranscriptDansOthellierDeGauche(jusqueQuelCoup : SInt16);
procedure EcritMessageSousTranscript(message : String255);
function DecalageHorizontalOthellierDuTranscript : SInt16;
function DecalageVerticalOthellierDuTranscript : SInt16;
procedure BeginDrawingForTranscript;
procedure EndDrawingForTranscript;
function ErreursAAfficherDansTranscriptCourant : SInt64;
function NombreSuggestionsAffichees : SInt64;
procedure DessineNiemeSuggestionDeCorrection(n : SInt16);
procedure DessineSuggestionsDeCorrection;

{ Gestion des evenements }
function TraiteKeyboardEventDansTranscript(ch : char; var peutRepeter : boolean) : boolean;
function TraiteMouseEventDansTranscript(evt : eventRecord) : boolean;
procedure ImposerUnCoupDansTranscript(whichSquare,numero : SInt16; var myTranscript : Transcript);
procedure ImposerEmpilerCurrentTranscript(const myTranscript : Transcript);

{Creation pour la base}
procedure EssayerEnregistrerLeTranscriptDansLaBase;
procedure PlaquerPositionEtPartieLegaleDansOthellierDeGauche(position : PositionEtTraitRec; partiePlaquee : String255);

{Gestion du type de donnees TranscriptSet }
function MakeEmptyTranscriptSet : TranscriptSet;
function MakeOneElementTranscriptSet(const theTranscript : Transcript; data : SInt64) : TranscriptSet;
procedure DisposeTranscriptSet(var S : TranscriptSet);
function TranscriptSetEstVide(S : TranscriptSet) : boolean;
function CardinalOfTranscriptSet(S : TranscriptSet) : SInt64;
function MemberOfTranscriptSet(const theTranscript : Transcript; var data : SInt64; S : TranscriptSet) : boolean;
procedure AddTranscriptToSet(const theTranscript : Transcript; data : SInt64; var S : TranscriptSet);
procedure RemoveTranscriptFromSet(const theTranscript : Transcript; var S : TranscriptSet);
function HashTranscript(const t : Transcript) : SInt64;

{Actions élémentaires de correction}
function MakeActionDeCorrection(genre : GenreCorrection; square1,square2 : SInt64; arg1,arg2 : SInt64) : ActionDeCorrection;
function ActionDeCorrectionEnString(whichAction : ActionDeCorrection) : String255;
procedure EcrireUneCorrectionDansRapport(profondeur : SInt16; whichAction : ActionDeCorrection);

{Correction automatique de transcripts}
procedure BeginTranscriptSearch;
procedure EndTranscriptSearch;
procedure ViderSuggestionsDeCorrection;
procedure CorrectionAutomatiqueDuTranscript(whichTranscript : Transcript);




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    ToolUtils, OSUtils, QuickDraw, MacWindows, fp, Fonts, QuickdrawText, Sound

{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitGeometrie, UnitScannerUtils, UnitRapport, MyStrings, UnitArbreDeJeuCourant, UnitCarbonisation, UnitNormalisation
    , UnitNotesSurCases, UnitFenetres, UnitUtilitaires, MyUtils, UnitHashing, UnitTroisiemeDimension, UnitPhasesPartie, UnitJeu
    , UnitSetUp, UnitSaisiePartie, UnitBufferedPICT, UnitDialog, UnitGestionDuTemps, UnitVieilOthelliste, UnitIconisation, UnitRetrograde
    , MyMathUtils, MyFonts, SNEvents, UnitScannerOthellistique, UnitPressePapier, UnitBallade, UnitPositionEtTrait, UnitStringSet
    , UnitABR, UnitSquareSet, UnitAffichagePlateau, UnitServicesMemoire, UnitEvenement, UnitActions ;
{$ELSEC}
    ;
    {$I prelink/EntreeTranscript.lk}
{$ENDC}


{END_USE_CLAUSE}






const
      kTextesTranscriptID = 10022;

      kBoutonVoirID = 184;
      kBoutonVoirEnfonceID = 185;

      kChiffreSpecialPionNoir    = -1;
      kChiffreSpecialPionBlanc   = -2;
      kChiffreSpecialCurseur     = -3;
      kChiffreSpecialBordure     = -4;
      kChiffreSpecialChiffreVide = 100;

      kMaxNiveauRecursionContextesGraphiques = 255;

      kMaxNiveauRecursionCorrectionAutomatique = 6;      { 6 corrections elementaires }
      kNombreMaxSuggestionsDeCorrection        = 12;     { 12 suggestions affichees}
      kTailleMaxArbreCorrectionAutomatique     = 10000;  { 10000 noeuds }
      kTailleMaxAppelsCorrectionAutomatique    = 20000;  { 20000 appels recursifs }

type
    PileTranscripts =
      record
        initialisee : boolean;
        tete : SInt16;
        queue : SInt16;
        current : SInt16;
        pile : array[0..kTaillePileTranscripts] of Transcript;
      end;




var gEnModeEntreeTranscript : boolean;
    gTranscriptProtegeEnEcriture : boolean;
    gTranscriptDoitChercherDesCorrections : boolean;
    gAvecAffichagePlusLonguePartie : boolean;
    gReglagesAvantEditionTranscript :
       record
         tailleCase                     : SInt16;
         tailleFenetrePlateau           : SInt64;
         fenetrePlateauRect             : rect;
         aireDeJeuRect                  : rect;
         sauvegardeEn3D                 : boolean;
         sauvegardePaletteAffichee      : boolean;
         sauvegardeEvaluerTousLesCoups  : boolean;
         sauvegardeJeuInstantane        : boolean;
         sauvegardeAfficheCoordonnees   : boolean;
         sauvegardeEnModeSolitaire      : boolean;
         sauvegardeCommentaireSolitaire : String255;
         sauvegardeCadence              : SInt64;
         sauvegardeCadencePersoAffichee : SInt64;
         sauvegardePositionEtTrait      : PositionEtTraitRec;
       end;
    gPileTranscripts : PileTranscripts;
    gAnalyseDuTranscript : AnalyseDeTranscript;
    gTableContextesGraphiques : record
                                  compteurRecursion : SInt64;
                                  table : array[0..kMaxNiveauRecursionContextesGraphiques] of GrafPtr;
                                end;

    gTranscriptSearch   : record
                             searchHistory              : TranscriptSet;
                             solutionSet                : StringSet;
                             compareAnalyse1            : AnalyseDeTranscriptPtr;
                             compareAnalyse2            : AnalyseDeTranscriptPtr;
                             transcriptDepart           : Transcript;
                             analyseDepart              : AnalyseDeTranscriptPtr;
                             analyseStack               : array[0..kMaxNiveauRecursionCorrectionAutomatique] of AnalyseDeTranscriptPtr;
                             correctionsCourantes       : array[0..kMaxNiveauRecursionCorrectionAutomatique] of ActionDeCorrection;
                             nbreNoeudsVisites          : SInt64;
                             nbreEchangesCoupsAutorises : SInt64;
                             nbreSuggestions            : SInt64;
                             suggestions                : array[1..kNombreMaxSuggestionsDeCorrection] of
                                                            record
                                                              nbActions         : SInt64;
                                                              actions           : array[0..kMaxNiveauRecursionCorrectionAutomatique] of ActionDeCorrection;
                                                              transcriptCorrige : Transcript;
                                                              score             : SInt64;
                                                              buttonRect        : rect;
                                                            end;
                             niveauRecursion            : SInt64;
                             magicCookie                : SInt64;
                             lastTickForEvents          : SInt64;
                          end;

procedure InitUnitEntreeTranscript;
var i : SInt64;
begin
  gEnModeEntreeTranscript := false;
  gTranscriptProtegeEnEcriture := false;
  gPileTranscripts.initialisee := false;
  gTranscriptDoitChercherDesCorrections := true;
  with gAnalyseDuTranscript do
    begin
      nombreCoupsPossibles     := 0;
      nombreCasesRemplies      := 0;
      plusLonguePartieLegale   := '';
      partieTerminee           := false;
      tousLesCoupsSontLegaux   := false;
      scorePartieComplete      := 0;
    end;
  with gReglagesAvantEditionTranscript do
    begin
      sauvegardeEn3D                := false;
      sauvegardePaletteAffichee     := false;
      sauvegardeEvaluerTousLesCoups := false;
      tailleCase                    := 0;
      tailleFenetrePlateau          := 0;
      fenetrePlateauRect            := MakeRect(0,0,0,0);
      aireDeJeuRect                 := MakeRect(0,0,0,0);
    end;
  gTableContextesGraphiques.compteurRecursion := 0;
  ResetTranscriptErrors(gAnalyseDuTranscript);
  SetAffichageDeLaPlusLonguePartiePossible(true);
  with gTranscriptSearch do
    begin
      niveauRecursion            := 0;
      compareAnalyse1            := NIL;
      compareAnalyse2            := NIL;
      analyseDepart              := NIL;
      for i := 0 to kMaxNiveauRecursionCorrectionAutomatique do
        analyseStack[i]          := NIL;
      searchHistory              := MakeEmptyTranscriptSet;
      solutionSet                := MakeEmptyStringSet;
      nbreNoeudsVisites          := 0;
      nbreEchangesCoupsAutorises := 0;
      nbreSuggestions            := 0;
      magicCookie                := 0;
    end;
end;


procedure LibereMemoireUnitEntreeTranscript;
begin
end;


procedure DebugEntreeTranscript(fonctionAppelante : String255);
begin
  WritelnNumDansRapport(fonctionAppelante+' : nroDernierCoupAtteint = ',nroDernierCoupAtteint);
  WritelnNumDansRapport(fonctionAppelante+' : AQuiDeJouer = ',AQuiDeJouer);
  WritelnNumDansRapport(fonctionAppelante+' : nbreCoup = ',nbreCoup);
end;


function EnModeEntreeTranscript : boolean;
begin
  EnModeEntreeTranscript := gEnModeEntreeTranscript;
end;

function CassioEstEnTrainDeCorrigerUnTranscript : boolean;
begin
  CassioEstEnTrainDeCorrigerUnTranscript := gTranscriptSearch.niveauRecursion > 0;
end;


function DoitAfficherLaPlusLonguePartiePossible : boolean;
begin
  DoitAfficherLaPlusLonguePartiePossible := gAvecAffichagePlusLonguePartie;
end;


procedure SetAffichageDeLaPlusLonguePartiePossible(flag : boolean);
begin
  gAvecAffichagePlusLonguePartie := flag;
end;


function TranscriptAccepteLesDonnees : boolean;
begin
  TranscriptAccepteLesDonnees := not(gTranscriptProtegeEnEcriture);
end;


procedure SetTranscriptAccepteLesDonnees(newFlag : boolean; var oldFlag : boolean);
begin
  oldFlag := not(gTranscriptProtegeEnEcriture);
  gTranscriptProtegeEnEcriture := not(newFlag);
end;


function TranscriptDoitChercherDesCorrections : boolean;
begin
  TranscriptDoitChercherDesCorrections := gTranscriptDoitChercherDesCorrections;
end;


procedure SetTranscriptChercheDesCorrections(newFlag : boolean; var oldFlag : boolean);
begin
  oldFlag := gTranscriptDoitChercherDesCorrections;
  gTranscriptDoitChercherDesCorrections := newFlag;
end;


procedure SauvegardeReglagesAvantEditionTranscript;
var myPoint : Point;
begin
  with gReglagesAvantEditionTranscript do
    begin

      sauvegardeEn3D := CassioEstEn3D;
      if CassioEstEn3D then DoChangeEn3D(false);
      tailleCase := GetTailleCaseCourante;

      BeginDrawingForTranscript;
      myPoint := GetWindowSize(wPlateauPtr);
      tailleFenetrePlateau := myPoint.h +  65536*myPoint.v ;
      fenetrePlateauRect := GetWindowPortRect(wPlateauPtr);
      LocalToGlobalRect(fenetrePlateauRect);
      aireDeJeuRect := aireDeJeu;
      EndDrawingForTranscript;

      sauvegardePaletteAffichee := windowPaletteOpen;
      (* if not(windowPaletteOpen) then DoChangePalette; *)

      sauvegardePositionEtTrait      := PositionEtTraitCourant;
      sauvegardeCommentaireSolitaire := CommentaireSolitaire^^;
      sauvegardeEnModeSolitaire      := finaleEnModeSolitaire;
    end;
end;


procedure RestoreReglagesApresEditionTranscript;
var tailleCaseChange,positionScoreChange : boolean;
begin
  with gReglagesAvantEditionTranscript do
    begin

      if EstLaPositionCourante(sauvegardePositionEtTrait) then
        begin
          CommentaireSolitaire^^ := sauvegardeCommentaireSolitaire;
          finaleEnModeSolitaire  := sauvegardeEnModeSolitaire;
        end;

      BeginDrawingForTranscript;
      SizeWindow(wPlateauPtr,LoWord(tailleFenetrePlateau),HiWord(tailleFenetrePlateau),true);
      MoveWindow(wPlateauPtr,fenetrePlateauRect.left,fenetrePlateauRect.top,false);
      avecSystemeCoordonnees := sauvegardeAfficheCoordonnees;
      AjusteAffichageFenetrePlat(tailleCase,tailleCaseChange,positionScoreChange);
      EndDrawingForTranscript;
      SetPositionsTextesWindowPlateau;
      MetTitreFenetrePlateau;

      if sauvegardeEn3D then DoChangeEn3D(false);
      if not(sauvegardePaletteAffichee) and windowPaletteOpen then DoChangePalette;

      if (sauvegardeEvaluerTousLesCoups <> avecEvaluationTotale) then DoChangeEvaluationTotale(true);

      if (sauvegardeCadence              <> GetCadence)              or
         (sauvegardeCadencePersoAffichee <> cadencePersoAffichee) or
         (sauvegardeJeuInstantane        <> jeuInstantane) then
        begin
          SetCadence(sauvegardeCadence);
          cadencePersoAffichee := sauvegardeCadencePersoAffichee;
          jeuInstantane        := sauvegardeJeuInstantane;
          AjusteCadenceMin(GetCadence);
          AjusteEtatGeneralDeCassioApresChangementDeCadence;
        end;
    end;
end;


procedure PrepareCassioPourEditionTranscript;
var nouvelleTailleDesCases,largeurNecessaire : SInt16;
    hauteurNecessaire : SInt16;
    tailleCaseChange,positionScoreChange : boolean;
    tailleFenetre : Point;
begin
  if not(analyseRetrograde.enCours) then
    with gReglagesAvantEditionTranscript do
      begin

        BeginDrawingForTranscript;

        CommentaireSolitaire^^         := '';
        finaleEnModeSolitaire          := false;
        sauvegardeAfficheCoordonnees   := avecSystemeCoordonnees;
        sauvegardeCadence              := GetCadence;
        sauvegardeCadencePersoAffichee := cadencePersoAffichee;
        sauvegardeJeuInstantane        := jeuInstantane;
        SetCadence(minutes10000000);
        cadencePersoAffichee := GetCadence;
        jeuInstantane        := false;
        AjusteCadenceMin(GetCadence);

        if not(HumCtreHum) and (AQuiDeJouer <> couleurMacintosh) then
            begin
              if PeutArreterAnalyseRetrograde then
                LanceInterruptionSimple('PrepareCassioPourEditionTranscript');
            end;
        {DoDemandeChangerHumCtreHumEtCouleur;}
        if not(HumCtreHum) then DoDemandeChangerHumCtreHum;

        sauvegardeEvaluerTousLesCoups := avecEvaluationTotale;
        If not(avecEvaluationTotale) then DoChangeEvaluationTotale(true);

        InterruptionCarPhasePartieChange;
        if not(afficheNumeroCoup) then DoChangeAfficheDernierCoup;
        if not(GetAvecAffichageNotesSurCases(kNotesDeCassio)) then DoChangeAfficheNotesSurCases(kNotesDeCassio);

        nouvelleTailleDesCases := RoundToL(0.75 * GetTailleCaseCourante);
        tailleFenetre := GetWindowSize(wPlateauPtr);

        if not(avecSystemeCoordonnees) then DoChangeAvecSystemeCoordonnees;

        if (tailleFenetre.h < (2*GetTailleCaseCourante*8 + RoundToL(3.7*EpaisseurBordureOthellier))) or
           (tailleFenetre.v < (GetTailleCaseCourante*10 + 2*EpaisseurBordureOthellier)) then
          begin
            AjusteAffichageFenetrePlat(nouvelleTailleDesCases,tailleCaseChange,positionScoreChange);
            largeurNecessaire := 2*(nouvelleTailleDesCases*8 + 2*EpaisseurBordureOthellier);
            hauteurNecessaire := nouvelleTailleDesCases*10 + 2*EpaisseurBordureOthellier;
            SizeWindow(wPlateauPtr,largeurNecessaire,Max(hauteurNecessaire,tailleFenetre.v),true);
            EraseRectDansWindowPlateau(GetWindowPortRect(wPlateauPtr));
            DrawContents(wPlateauPtr);
          end;

        SelectWindow(wPlateauPtr);
        EndDrawingForTranscript;
      end;
end;


procedure DoChangeEnModeEntreeTranscript;
begin
  if EnModeEntreeTranscript
    then
      begin
        gEnModeEntreeTranscript := false;
        RestoreReglagesApresEditionTranscript;
      end
    else
      begin
        if not(analyseRetrograde.enCours) then
          begin
            if not(gPileTranscripts.initialisee) then InitialisePileTranscripts;
            SauvegardeReglagesAvantEditionTranscript;
            gEnModeEntreeTranscript := true;
            PrepareCassioPourEditionTranscript;

            if not(gAideTranscriptsDejaPresentee) then
              begin
                gAideCourante := kAideTranscripts;
                if not(windowAideOpen) then OuvreFntrAide;
                DessineAide(gAideCourante);
                gAideTranscriptsDejaPresentee := true;
              end;
          end;
      end;

  InvalidateAllCasesDessinEnTraceDeRayon;
  DrawContents(wPlateauPtr);
end;



procedure ResetTranscriptErrors(var analyse : AnalyseDeTranscript);
begin
  analyse.globalTranscriptError := 0;
end;


procedure RaiseTranscriptError(whichError : SInt64; square : SInt16; var analyse : AnalyseDeTranscript);
begin
  {WritelnNumDansRapport('Raising transcript error for square '+CoupEnString(square,true)+', error : ',whichError);}

  with analyse do
    begin
      globalTranscriptError := BitOr(globalTranscriptError,whichError);

      if (square >= 11) and (square <= 88)
        then
          erreursDansCetteCase[square] := (erreursDansCetteCase[square] or whichError)
        else
          if (whichError <> kTranscriptCoupManquant)
            then WritelnNumDansRapport('ERROR ! square out of range in RaiseTranscriptError : ', square);
    end;
end;


function HasTranscriptErrorMask(whichErrors : SInt64; const analyse : AnalyseDeTranscript) : boolean;
begin
  HasTranscriptErrorMask := BitAnd(analyse.globalTranscriptError,whichErrors) <> 0;
end;


function HasTheseErrorsForThisMove(whichErrors : SInt64; const analyse : AnalyseDeTranscript; numeroCoup : SInt64) : boolean;
begin
  if (numeroCoup < 1) or (numeroCoup > 99)
    then HasTheseErrorsForThisMove := false
    else HasTheseErrorsForThisMove := BitAnd(TypeErreurDeCeNumeroDansTranscript(numeroCoup,analyse),whichErrors) <> 0;
end;


procedure ViderTranscriptCourant;
var myTranscript : Transcript;
begin
  myTranscript := TranscriptVide;
  EmpileTranscript(myTranscript);
end;


function CurrentTranscriptHasThisErrors(whichErrors : SInt64) : boolean;
begin
  CurrentTranscriptHasThisErrors := HasTranscriptErrorMask(whichErrors,gAnalyseDuTranscript);
end;


function TranscriptError(const analyse : AnalyseDeTranscript) : SInt64;
begin
  TranscriptError := analyse.globalTranscriptError;
end;


function SameTranscript(const t1,t2 : Transcript) : boolean;
var k : SInt64;
begin
  for k := 0 to 99 do
    begin
      if (t1.chiffres[k,kGauche] <> t2.chiffres[k,kGauche]) or
         (t1.chiffres[k,kDroite] <> t2.chiffres[k,kDroite]) then
        begin
          SameTranscript := false;
          exit(SameTranscript);
        end;
    end;
  SameTranscript := true;
end;


function NombreCasesDifferentesDansTranscripts(const t1,t2 : Transcript) : SInt64;
var compteur : SInt64;
    k,n1,n2 : SInt16;
begin
  compteur := 0;

  for k := 11 to 88 do
    begin
      n1 := NumeroDeCetteCaseDansTranscript(k,t1);
      n2 := NumeroDeCetteCaseDansTranscript(k,t2);
      if (n1 <> n2) then inc(compteur);
    end;

  NombreCasesDifferentesDansTranscripts := compteur;
end;


function DistanceTranscripts(var t1,t2 : Transcript) : SInt64;
var distance : SInt64;
begin
  with gTranscriptSearch do
    begin

      if SameTranscript(t1,t2) then
        begin
          DistanceTranscripts := 0;
          exit(DistanceTranscripts);
        end;

      distance := 1;

      if (compareAnalyse1 <> NIL) and (compareAnalyse2 <> NIL) then
        begin
          ChercherLesErreursDansCeTranscript(t1,compareAnalyse1^);
          ChercherLesErreursDansCeTranscript(t2,compareAnalyse2^);
        end;

      if not(distance > 0) then WritelnDansRapport('WARNING in DistanceTranscripts : distance should always be > 0 for non equal transcripts…');
      DistanceTranscripts := distance;
    end;
end;


function EstUneCaseVideDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : boolean;
begin
  if (whichSquare < 11) or (whichSquare > 88)
    then EstUneCaseVideDansTranscript := false
    else EstUneCaseVideDansTranscript := (myTranscript.chiffres[whichSquare,kGauche] >= 0);
end;


function CaseVidePrecedenteDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
var trouve : boolean;
    compteur,aux : SInt16;
begin
  compteur := 0;
  aux := whichSquare;

  repeat
    inc(compteur);

    aux := aux - 1;
    if (aux < 11) then aux := 88;
    trouve := EstUneCaseVideDansTranscript(aux,myTranscript);

  until (compteur >= 100) or trouve;

  if trouve
    then CaseVidePrecedenteDansTranscript := aux
    else CaseVidePrecedenteDansTranscript := whichSquare;
end;


function CaseVideSuivanteDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
var trouve : boolean;
    compteur,aux : SInt16;
begin
  compteur := 0;
  aux := whichSquare;
  repeat
    inc(compteur);

    aux := aux + 1;
    if (aux > 88) then aux := 11;
    trouve := EstUneCaseVideDansTranscript(aux,myTranscript);

  until (compteur >= 100) or trouve;

  if trouve
    then CaseVideSuivanteDansTranscript := aux
    else CaseVideSuivanteDansTranscript := whichSquare;
end;


function PremiereCaseVideDansTranscript(const myTranscript : Transcript) : SInt16;
begin
  PremiereCaseVideDansTranscript := CaseVideSuivanteDansTranscript(10,myTranscript);
end;


function DerniereCaseVideDansTranscript(const myTranscript : Transcript) : SInt16;
begin
  DerniereCaseVideDansTranscript := CaseVidePrecedenteDansTranscript(89,myTranscript);
end;


function EstUneCaseSansChiffreDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : boolean;
begin
   if (whichSquare < 11) or (whichSquare > 88)
    then EstUneCaseSansChiffreDansTranscript := false
    else EstUneCaseSansChiffreDansTranscript := (myTranscript.chiffres[whichSquare,kGauche] = kChiffreSpecialChiffreVide) and
                                                (myTranscript.chiffres[whichSquare,kDroite] = kChiffreSpecialChiffreVide);
end;


function CaseSansChiffrePrecedenteDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
var trouve : boolean;
    compteur,aux : SInt16;
begin
  compteur := 0;
  aux := whichSquare;

  repeat
    inc(compteur);

    aux := aux - 1;
    if (aux < 11) then aux := 88;
    trouve := EstUneCaseSansChiffreDansTranscript(aux,myTranscript);

  until (compteur >= 100) or trouve;

  if trouve
    then CaseSansChiffrePrecedenteDansTranscript := aux
    else CaseSansChiffrePrecedenteDansTranscript := whichSquare;
end;


function CaseSansChiffreSuivanteDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
var trouve : boolean;
    compteur,aux : SInt16;
begin
  compteur := 0;
  aux := whichSquare;
  repeat
    inc(compteur);

    aux := aux + 1;
    if (aux > 88) then aux := 11;
    trouve := EstUneCaseSansChiffreDansTranscript(aux,myTranscript);

  until (compteur >= 100) or trouve;

  if trouve
    then CaseSansChiffreSuivanteDansTranscript := aux
    else CaseSansChiffreSuivanteDansTranscript := whichSquare;
end;


function PremiereCaseSansChiffreDansTranscript(const myTranscript : Transcript) : SInt16;
begin
  PremiereCaseSansChiffreDansTranscript := CaseSansChiffreSuivanteDansTranscript(10,myTranscript);
end;


function DerniereCaseSansChiffreDansTranscript(const myTranscript : Transcript) : SInt16;
begin
  DerniereCaseSansChiffreDansTranscript := CaseSansChiffrePrecedenteDansTranscript(89,myTranscript);
end;


function ProchaineCaseAvecUneErreurDansTranscript(whichSquare, sens : SInt16) : SInt16;
var n,square,k,index : SInt16;
    caseAProblemes : record
                       compteur : SInt16;
                       tableau : array[0..64] of SInt16;
                     end;
    trouve : boolean;
    interessantes : SquareSet;


    procedure AjouterCaseInteressante(square : SInt16);
    begin
      if not(square in interessantes) then
        with caseAProblemes do
        begin
          inc(compteur);
          tableau[compteur] := square;
          interessantes := interessantes + [square];

          if (square = whichSquare) then
            begin
              trouve := true;
              index := compteur;
            end;
        end;
    end;

begin {ProchaineCaseAvecUneErreurDansTranscript}
  with gAnalyseDuTranscript do
    begin

      (* premiere phase : faire une liste de toutes les cases à probleme *)
      trouve := false;
      index := 0;
      interessantes := [];
      with caseAProblemes do
        begin
          compteur := 0;
          for n := 1 to 99 do
            if CeNumeroDeCoupAUneErreur(n,gAnalyseDuTranscript) then
              begin
                with cases[n] do
                  begin
                    for k := 1 to cardinal do
                      AjouterCaseInteressante(liste[k]);
                  end;
                (*if false and HasTheseErrorsForThisMove(kTranscriptCoupsDupliques,gAnalyseDuTranscript,n) then
                  begin
                    with cases[n+1] do
                      begin
                        for k := 1 to cardinal do
                          AjouterCaseInteressante(liste[k]);
                      end;
                  end;
                 *)
              end;
        end;

      (* ensuite on rajoute eventuellement des cases sans chiffre du transcript *)

      if (caseAProblemes.compteur > 0)
        then
          begin
            {ajouter la premiere case sans chiffre}
            square := PremiereCaseSansChiffreDansTranscript(CurrentTranscript);
            if not(square in interessantes) and
               EstUneCaseVideDansTranscript(square,CurrentTranscript) and
               EstUneCaseSansChiffreDansTranscript(square,CurrentTranscript)
               and not(EstUneCaseSansChiffreDansTranscript(GetCurrentSquareOfCurseur,CurrentTranscript))
              then AjouterCaseInteressante(square);
          end
        else
          begin
            {ajouter toutes les cases sans chiffre}
            for square := 11 to 88 do
              if EstUneCaseSansChiffreDansTranscript(square,CurrentTranscript)
                then AjouterCaseInteressante(square);
          end;

      (* finalement, deplacer le curseur *)
      if not(trouve)
        then
          begin
            if (caseAProblemes.compteur >= 1)
              then
                if (sens > 0)
                  then ProchaineCaseAvecUneErreurDansTranscript := caseAProblemes.tableau[1]
                  else ProchaineCaseAvecUneErreurDansTranscript := caseAProblemes.tableau[caseAProblemes.compteur]
              else
                if (sens > 0)
                  then ProchaineCaseAvecUneErreurDansTranscript := CaseVideSuivanteDansTranscript(whichSquare,CurrentTranscript)
                  else ProchaineCaseAvecUneErreurDansTranscript := CaseVidePrecedenteDansTranscript(whichSquare,CurrentTranscript);
          end
        else
          begin
            if (sens > 0)
              then index := (index mod caseAProblemes.compteur) + 1
              else
                begin
                  index := index - 1;
                  if index <= 0 then index := index + caseAProblemes.compteur;
                end;
            ProchaineCaseAvecUneErreurDansTranscript := caseAProblemes.tableau[index];
          end;
    end;
end;


function CouleurDeCetteCaseDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
begin
  with myTranscript do
    begin
      if EstUneCaseVideDansTranscript(whichSquare,myTranscript)
        then CouleurDeCetteCaseDansTranscript := pionVide
        else
          begin
            case myTranscript.chiffres[whichSquare,kGauche] of
              kChiffreSpecialPionNoir  : CouleurDeCetteCaseDansTranscript := pionNoir;
              kChiffreSpecialPionBlanc : CouleurDeCetteCaseDansTranscript := pionBlanc;
              otherwise                  CouleurDeCetteCaseDansTranscript := PionInterdit;
            end; {case}
          end;
    end;
end;


function NumeroDeCetteCaseDansTranscript(whichSquare : SInt16; const myTranscript : Transcript) : SInt16;
var a,b : SInt64;
begin
  with myTranscript do
    begin
      if not(EstUneCaseVideDansTranscript(whichSquare,myTranscript))
        then NumeroDeCetteCaseDansTranscript := 0
        else
          begin
            a := chiffres[whichSquare,kGauche];
            b := chiffres[whichSquare,kDroite];

            if a > 9 then a := 0;
            if a < 0 then a := 0;

            if (b = kChiffreSpecialChiffreVide)
              then NumeroDeCetteCaseDansTranscript := a
              else
                begin
                  if b > 9 then b := 0;
                  if b < 0 then b := 0;
                  NumeroDeCetteCaseDansTranscript := 10*a + b;
                end;
          end;
    end;
end;


function NombreCasesRempliesDansTranscript(const myTranscript : Transcript) : SInt16;
var t,somme : SInt16;
begin
  somme := 0;
  for t := 11 to 88 do
    if (NumeroDeCetteCaseDansTranscript(t,myTranscript) > 0) then inc(somme);
  NombreCasesRempliesDansTranscript := somme;
end;


procedure SetCouleurDeCePionDansTranscript(whichSquare,color : SInt16; var myTranscript : Transcript);
begin
  if (whichSquare >= 11) and (whichSquare <= 88) then
    with myTranscript do
     begin
      case color of
        pionNoir  : begin
                      chiffres[whichSquare,kGauche] := kChiffreSpecialPionNoir;
                      chiffres[whichSquare,kDroite] := kChiffreSpecialPionNoir;
                    end;
        pionBlanc : begin
                      chiffres[whichSquare,kGauche] := kChiffreSpecialPionBlanc;
                      chiffres[whichSquare,kDroite] := kChiffreSpecialPionBlanc;
                    end;
        pionVide  : begin
                      chiffres[whichSquare,kGauche] := kChiffreSpecialChiffreVide;
                      chiffres[whichSquare,kDroite] := kChiffreSpecialChiffreVide;
                    end;
      end;
    end;
end;


procedure InverserCouleurDesPionsDuTranscript(var myTranscript : Transcript);
var t,couleur : SInt16;
begin
  for t := 11 to 88 do
    begin
      couleur := CouleurDeCetteCaseDansTranscript(t,myTranscript);
      if (couleur = pionNoir)  then SetCouleurDeCePionDansTranscript(t,pionBlanc,myTranscript) else
      if (couleur = pionBlanc) then SetCouleurDeCePionDansTranscript(t,pionNoir,myTranscript);
    end;
end;


procedure SetNumeroDeCetteCaseDansTranscript(whichSquare,numero : SInt16; var myTranscript : Transcript);
begin
  if (numero > 99) then numero := 99;
  if (numero < 0) then numero := 0;

  if (whichSquare >= 11) and (whichSquare <= 88) and (numero >= 0) and (numero <= 99) then
    with myTranscript do
     begin
      chiffres[whichSquare,kGauche] := numero div 10;
      chiffres[whichSquare,kDroite] := numero mod 10;
    end;
end;


function CurseurEstToutEnHautAGauche(var myTranscript : Transcript) : boolean;
var square : SInt16;
begin
  square := myTranscript.curseur.square;
  CurseurEstToutEnHautAGauche := (myTranscript.curseur.lateralisation = kGauche) and
                                 (CaseVidePrecedenteDansTranscript(square,myTranscript) >= square);
end;


function CurseurEstToutEnBasADroite(var myTranscript : Transcript) : boolean;
var square : SInt16;
begin
  square := myTranscript.curseur.square;
  CurseurEstToutEnBasADroite := (myTranscript.curseur.lateralisation = kDroite) and
                                (CaseVideSuivanteDansTranscript(square,myTranscript) <= square);
end;


procedure MonterCurseur(var myTranscript : Transcript);
var compteur : SInt16;
begin
  with myTranscript.curseur do
    begin
      compteur := 0;
      repeat
        square := square - 10;
        if square < 11 then square := square + 80;
        inc(compteur);
      until (compteur > 10) or EstUneCaseVideDansTranscript(square,myTranscript);
    end;
end;


procedure DescendreCurseur(var myTranscript : Transcript);
var compteur : SInt16;
begin
  with myTranscript.curseur do
    begin
      compteur := 0;
      repeat
        square := square + 10;
        if square > 88 then square := square - 80;
        inc(compteur);
      until (compteur > 10) or EstUneCaseVideDansTranscript(square,myTranscript);
    end;
end;


procedure BougerCurseurADroite(var myTranscript : Transcript);
var compteur : SInt16;
begin
  with myTranscript.curseur do
    begin
      if (lateralisation = kGauche)
        then lateralisation := kDroite
        else
          begin
            lateralisation := kGauche;
            compteur := 0;
            repeat
              square := square + 1;
              if (square mod 10) = 9 then square := square - 8;
              inc(compteur);
            until (compteur > 10) or EstUneCaseVideDansTranscript(square,myTranscript);

            if ((square mod 10) = 1) and (lateralisation = kGauche)
              then DescendreCurseur(myTranscript);
          end;
    end;
end;


procedure BougerCurseurCaseSuivante(var myTranscript : Transcript);
begin
  if GetLateralisationOfCurseur(myTranscript) = kDroite
    then
      BougerCurseurADroite(myTranscript)
    else
      begin
        BougerCurseurADroite(myTranscript);
        BougerCurseurADroite(myTranscript);
      end;
end;

procedure BougerCurseurCasePrecedente(var myTranscript : Transcript);
begin
  if GetLateralisationOfCurseur(myTranscript) = kDroite
    then
      begin
        BougerCurseurAGauche(myTranscript);
        BougerCurseurAGauche(myTranscript);
        BougerCurseurAGauche(myTranscript);
      end
    else
      begin
        BougerCurseurAGauche(myTranscript);
        BougerCurseurAGauche(myTranscript);
      end;
end;


procedure SetPositionCurseur(square,lateralisation : SInt16; var myTranscript : Transcript);
begin
  if EstUneCaseVideDansTranscript(square,myTranscript) then
    begin
      myTranscript.curseur.square := square;
      myTranscript.curseur.lateralisation := lateralisation;
    end;
end;


procedure BougerCurseurAGauche(var myTranscript : Transcript);
var compteur : SInt16;
begin
  with myTranscript.curseur do
    begin
      if lateralisation = kDroite
        then lateralisation := kGauche
        else
          begin
            lateralisation := kDroite;
            compteur := 0;
            repeat
              square := square - 1;
              if (square mod 10) = 0 then square := square + 8;
              inc(compteur);
            until (compteur > 10) or EstUneCaseVideDansTranscript(square,myTranscript);

            if ((square mod 10) = 8) and (lateralisation = kDroite)
              then MonterCurseur(myTranscript);
          end;
    end;
end;


procedure BougerCurseurFinDeLigne(var myTranscript : Transcript);
begin
  with myTranscript.curseur do
    begin
      lateralisation := kDroite;
      square := CaseVidePrecedenteDansTranscript(10*(square div 10) + 9 ,myTranscript);
    end;
end;


procedure BougerCurseurDebutDeLigne(var myTranscript : Transcript);
begin
  with myTranscript.curseur do
    begin
      lateralisation := kGauche;
      square := CaseVideSuivanteDansTranscript(10*(square div 10) ,myTranscript);
    end;
end;


procedure TraiteDeleteKeyDansTranscript(var myTranscript : Transcript);
var square,lateralisation : SInt16;
begin
  with myTranscript do
    begin
      if CurseurEstToutEnHautAGauche(myTranscript)
        then exit(TraiteDeleteKeyDansTranscript)  {on est arrive tout en haut a gauche}
        else
          if CurseurEstToutEnBasADroite(myTranscript) and (GetCurrentChiffreSousLeCurseur <> kChiffreSpecialChiffreVide)
            then
              begin
                square := curseur.square;
                lateralisation := curseur.lateralisation;
                chiffres[square,lateralisation] := kChiffreSpecialChiffreVide;
              end
            else
              begin
                BougerCurseurAGauche(myTranscript);
                square := curseur.square;
                lateralisation := curseur.lateralisation;
                chiffres[square,lateralisation] := kChiffreSpecialChiffreVide;
              end;
    end;
end;


procedure TaperChiffreDansTranscript(ch : char);
var square,lateralisation : SInt16;
    myTranscript : Transcript;
begin
  myTranscript := CurrentTranscript;
  with myTranscript do
    begin

      if (ch = chr(RetourArriereKey))
        then
          TraiteDeleteKeyDansTranscript(myTranscript)
        else
          begin
            square := curseur.square;
            lateralisation := curseur.lateralisation;

            if IsDigit(ch)
              then
                begin
                  chiffres[square,lateralisation] := ord(ch) - ord('0');
                  if (lateralisation = kGauche) and (chiffres[square,lateralisation] >= 7)
                    then RaiseTranscriptError(kTranscriptChiffreTropGrand,square,gAnalyseDuTranscript);
                end
              else chiffres[square,lateralisation] := kChiffreSpecialChiffreVide;

            if (lateralisation = kDroite) then SetDerniereCaseTapeeDansTranscript(square);
            if not(CurseurEstToutEnBasADroite(myTranscript))
              then BougerCurseurADroite(myTranscript);
          end;
      EmpileTranscript(myTranscript);
    end;
end;



procedure DecalerTousLesChiffresDansTranscript(caseDebut,lateralisationDebut,dansQuelSens : SInt16);
var lateralisation : SInt16;
    t,next : SInt16;
    myTranscript : Transcript;
    continuer : boolean;
begin
  myTranscript := CurrentTranscript;
  with myTranscript do
    begin

      if (dansQuelSens = kDroite) then
        begin
          t := DerniereCaseVideDansTranscript(myTranscript);
          lateralisation := kDroite;
          continuer := true;

          while (t > caseDebut) and continuer do
            begin
              if lateralisation = kDroite
                then
                  begin
                    chiffres[t,kDroite] := chiffres[t,kGauche];
                    lateralisation := kGauche;
                  end
                else
                  begin
                    next := CaseVidePrecedenteDansTranscript(t,CurrentTranscript);
                    chiffres[t,kGauche] := chiffres[next,kDroite];
                    lateralisation := kDroite;
                    continuer := (next < t);
                    t := next;
                  end;
            end;
          if lateralisationDebut = kGauche then
            chiffres[caseDebut,kDroite] := chiffres[caseDebut,kGauche];
          chiffres[caseDebut,lateralisationDebut] := kChiffreSpecialChiffreVide;
        end;

      if (dansQuelSens = kGauche) then
        begin
          t := caseDebut;
          lateralisation := lateralisationDebut;
          continuer := true;

          while (t <= 88) and continuer do
            begin
              if lateralisation = kGauche
                then
                  begin
                    chiffres[t,kGauche] := chiffres[t,kDroite];
                    lateralisation := kDroite;
                  end
                else
                  begin
                    next := CaseVideSuivanteDansTranscript(t,CurrentTranscript);
                    continuer := (next > t);

                    if continuer
                      then
                        begin
                          chiffres[t,kDroite] := chiffres[next,kGauche];
                          lateralisation := kGauche;
                          t := next;
                        end
                      else
                        begin
                          chiffres[t,kDroite] := kChiffreSpecialChiffreVide;
                        end;

                  end;
            end;
        end;

      EmpileTranscript(myTranscript);
    end;
end;


function CaseAyantLePlusPetitNumeroAuDela(numeroMinimum : SInt16) : SInt16;
var t,valeur,min,result : SInt16;
    myTranscript : Transcript;
begin
  myTranscript := CurrentTranscript;
  with myTranscript do
    begin
      min := 999;

      result := PremiereCaseVideDansTranscript(myTranscript);

      (* Chercher la case ayant le plus petit numero au dela de numeroMinimum *)
      for t := 11 to 88 do
        if EstUneCaseVideDansTranscript(t,myTranscript) then
          begin
            valeur := NumeroDeCetteCaseDansTranscript(t,myTranscript);
            if (valeur >= numeroMinimum) and (valeur <= min) then
              begin
                min := valeur;
                result := t;
              end;
          end;

      (* not found ? Chercher la case ayant le plus petit numero absolument pour recommencer au coup 1 ... *)
      if (min = 999) then
        for t := 11 to 88 do
          if EstUneCaseVideDansTranscript(t,myTranscript) then
            begin
              valeur := NumeroDeCetteCaseDansTranscript(t,myTranscript);
              if (valeur <= min) then
                begin
                  min := valeur;
                  result := t;
                end;
            end;
    end;
  CaseAyantLePlusPetitNumeroAuDela := result;
end;


function IncrementerToutesLesCases(numeroMinimum,increment : SInt16; myTranscript : Transcript) : Transcript;
var t,valeur : SInt16;
begin
  with myTranscript do
    begin
      for t := 11 to 88 do
        if EstUneCaseVideDansTranscript(t,myTranscript) then
          begin
            valeur := NumeroDeCetteCaseDansTranscript(t,myTranscript);
            if (valeur >= numeroMinimum) then
              SetNumeroDeCetteCaseDansTranscript(t,valeur+increment,myTranscript);
          end;
    end;
  IncrementerToutesLesCases := myTranscript;
end;


function IncrementerToutesLesCasesAndSetValueDansSquare(numeroMinimum,increment : SInt16; square,value : SInt16; myTranscript : Transcript) : Transcript;
var t,valeur : SInt16;
begin
  with myTranscript do
    begin
      for t := 11 to 88 do
        if EstUneCaseVideDansTranscript(t,myTranscript) then
          begin
            valeur := NumeroDeCetteCaseDansTranscript(t,myTranscript);
            if (valeur >= numeroMinimum) then
              SetNumeroDeCetteCaseDansTranscript(t,valeur+increment,myTranscript);
          end;
      if EstUneCaseVideDansTranscript(square,myTranscript) then
        SetNumeroDeCetteCaseDansTranscript(square,value,myTranscript);
    end;
  IncrementerToutesLesCasesAndSetValueDansSquare := myTranscript;
end;


function DecrementerToutesLesCases(numeroMinimum,increment : SInt16; myTranscript : Transcript; var prochainNumeroActif,square : SInt16) : Transcript;
var t,valeur,aux : SInt16;
begin
  with myTranscript do
    begin
      prochainNumeroActif := 99;
      for t := 11 to 88 do
        if EstUneCaseVideDansTranscript(t,myTranscript) and
           not(EstUneCaseSansChiffreDansTranscript(t,myTranscript)) then
          begin
            valeur := NumeroDeCetteCaseDansTranscript(t,myTranscript);
            if (valeur >= numeroMinimum) then
              begin
                SetNumeroDeCetteCaseDansTranscript(t,valeur+increment,myTranscript);

                aux := NumeroDeCetteCaseDansTranscript(t,myTranscript);
                if aux <= prochainNumeroActif then
                  begin
                    prochainNumeroActif := aux;
                    square := t;
                  end;
              end;
          end;
    end;
  DecrementerToutesLesCases := myTranscript;
end;


function IncrementerCetteCase(square,increment : SInt16; myTranscript : Transcript) : Transcript;
var valeur : SInt16;
begin
  with myTranscript do
    begin
      if EstUneCaseVideDansTranscript(square,myTranscript) then
        begin
          valeur := NumeroDeCetteCaseDansTranscript(square,myTranscript);
          SetNumeroDeCetteCaseDansTranscript(square,valeur+increment,myTranscript);
        end;
    end;
  IncrementerCetteCase := myTranscript;
end;


function EchangerCasesDansTranscript(square1,square2 : SInt16; myTranscript : Transcript) : Transcript;
var temp : SInt16;
begin
  with myTranscript do
    begin
      if (square1 >= 11) and (square1 <= 88) and (square2 >= 11) and (square2 <= 88) then
        begin
          temp := chiffres[square1,kGauche];
          chiffres[square1,kGauche] := chiffres[square2,kGauche];
          chiffres[square2,kGauche] := temp;

          temp := chiffres[square1,kDroite];
          chiffres[square1,kDroite] := chiffres[square2,kDroite];
          chiffres[square2,kDroite] := temp;
        end;
    end;
  EchangerCasesDansTranscript := myTranscript;
end;


function MakeTranscript(positionEtTrait : PositionEtTraitRec) : Transcript;
var i,j,t : SInt16;
    result : Transcript;
begin
  with result do
    begin
      for i := 0 to 99 do
        begin
          chiffres[i,kGauche] := kChiffreSpecialBordure;
          chiffres[i,kDroite] := kChiffreSpecialBordure;
        end;

      for i := 1 to 8 do
        for j := 1 to 8 do
          begin
            t := i + j*10;
            case positionEtTrait.position[t] of
              pionNoir  : SetCouleurDeCePionDansTranscript(t,pionNoir,result);
              pionBlanc : SetCouleurDeCePionDansTranscript(t,pionBlanc,result);
              pionVide  : SetCouleurDeCePionDansTranscript(t,pionVide,result);
            end; {case}
          end;

      curseur.square  := 11;
      curseur.lateralisation := kGauche;
    end;

  MakeTranscript := result;
end;



function CurrentTranscript : Transcript;
begin
  CurrentTranscript := gPileTranscripts.pile[gPileTranscripts.current];
end;


function GetLateralisationOfCurseur(const myTranscript : Transcript) : SInt16;
begin
  GetLateralisationOfCurseur := myTranscript.curseur.lateralisation;
end;


function GetSquareOfCurseur(const myTranscript : Transcript) : SInt16;
begin
  GetSquareOfCurseur := myTranscript.curseur.square;
end;


function ChiffreSousLeCurseur(const myTranscript : Transcript) : SInt16;
begin
  with myTranscript do
    ChiffreSousLeCurseur := chiffres[curseur.square,curseur.lateralisation];
end;


function GetCurrentSquareOfCurseur : SInt16;
begin
  GetCurrentSquareOfCurseur := CurrentTranscript.curseur.square;
end;


function GetCurrentLateralisationOfCurseur : SInt16;
begin
  GetCurrentLateralisationOfCurseur := CurrentTranscript.curseur.lateralisation;
end;


function GetCurrentNumeroOfCurseur : SInt16;
begin
  GetCurrentNumeroOfCurseur := NumeroDeCetteCaseDansTranscript(GetCurrentSquareOfCurseur,CurrentTranscript);
end;


function GetCurrentChiffreSousLeCurseur : SInt16;
begin
  GetCurrentChiffreSousLeCurseur := ChiffreSousLeCurseur(CurrentTranscript);
end;


function PileTranscriptEstVide : boolean;
begin
  PileTranscriptEstVide := (gPileTranscripts.tete = gPileTranscripts.queue);
end;


procedure EmpileTranscript(const myTranscript : Transcript);
var next : SInt64;
begin
  with gPileTranscripts do
    begin
      if not(SameTranscript(myTranscript,pile[current])) then
        begin
          next := current + 1;
          if next >= kTaillePileTranscripts then next := next - kTaillePileTranscripts;
          if (current = tete) or not(SameTranscript(myTranscript,pile[next])) then
            begin
              tete := next;
              if (tete = queue) then queue := (queue+1) mod kTaillePileTranscripts;
            end;
          current := next;
        end;
      pile[current] := myTranscript;
    end;
  ChercherLesErreursDansLeTranscriptCourant;
end;


function DepileTranscriptVersLaGauche : Transcript;
begin
  with gPileTranscripts do
    begin
      DepileTranscriptVersLaGauche := pile[current];
      if (current <> queue) then
        begin
          current := current - 1;
          if current < 0 then current := current + kTaillePileTranscripts;
        end;
    end;
  ChercherLesErreursDansLeTranscriptCourant;
end;


function DepileTranscriptVersLaDroite : Transcript;
begin
  with gPileTranscripts do
    begin
      DepileTranscriptVersLaDroite := pile[current];
      if (current <> tete) then
        begin
          current := current + 1;
          if current >= kTaillePileTranscripts then current := current - kTaillePileTranscripts;
        end;
    end;
  ChercherLesErreursDansLeTranscriptCourant;
end;


function TranscriptVide : Transcript;
begin
  TranscriptVide := MakeTranscript(PositionEtTraitInitiauxDuTranscriptCourant);
end;


function MakeTranscriptFromPlateauOthello(coups : platValeur) : Transcript;
var result : Transcript;
    t,square,numero : SInt64;
begin
  result := TranscriptVide;
  for t := 1 to 60 do
    begin
      square := othellier[t];
      numero := coups[square];
      if (numero >= 0) and (numero <= 99) then
        SetNumeroDeCetteCaseDansTranscript(square,numero,result);
    end;
  MakeTranscriptFromPlateauOthello := result;
end;


procedure InitialisePileTranscripts;
begin
  with gPileTranscripts do
    begin
      initialisee := true;
      tete := 0;
      queue := 0;
      current := 0;
      pile[current] := TranscriptVide;
      ChercherLesErreursDansLeTranscriptCourant;
    end;
end;


procedure DessineChiffre2DTranscript(square,lateralisation : SInt64);
var s : String255;
    chiffre : SInt64;
    theRect : rect;
    temp : boolean;
    justification : SInt64;
begin
  theRect := GetBoundingRectOfSquare(square);

  { on ressere un peu les deux chiffres }
  InSetRect(theRect,GetTailleCaseCourante div 11 ,0);
  OffSetRect(theRect,0,-(GetTailleCaseCourante div 12));

  chiffre := CurrentTranscript.chiffres[square,lateralisation];

  if (chiffre >= 0) and (chiffre <= 9) then s := NumEnString(chiffre);
  if (chiffre = kChiffreSpecialChiffreVide) then s := '  ';

  PrepareTexteStatePourTranscript;
  TextSize((2*(theRect.bottom-theRect.top)) div 3);

  temp := doitEffacerSousLesTextesSurOthellier;
  doitEffacerSousLesTextesSurOthellier := false;

  if lateralisation = kGauche
    then justification := kJusticationGauche+kJusticationCentreVert
    else justification := kJusticationDroite+kJusticationCentreVert;

  if (square         = GetCurrentSquareOfCurseur) and
     (lateralisation = GetCurrentLateralisationOfCurseur)
    then justification := justification + kJustificationInverseVideo;

  { coup illegal : en jaune !}
  if BitAnd(TypeErreurDeCetteCaseDansTranscript(square,gAnalyseDuTranscript), kTranscriptCoupIllegal) <> 0
    then DrawJustifiedStringInRectWithRGBColor(theRect,s,justification,square,gPurJaune)
    else DrawJustifiedStringInRectWithRGBColor(theRect,s,justification,square,GetCouleurDesChiffresDuTranscript);
  doitEffacerSousLesTextesSurOthellier := temp;
end;


function DecalageHorizontalOthellierDuTranscript : SInt16;
begin
  DecalageHorizontalOthellierDuTranscript := -2*EpaisseurBordureOthellier-8*GetTailleCaseCourante;
end;


function DecalageVerticalOthellierDuTranscript : SInt16;
begin
  DecalageVerticalOthellierDuTranscript := 0;
end;


function EstUnePartieLegaleEtComplete(const analyse : AnalyseDeTranscript) : boolean;
begin
  EstUnePartieLegaleEtComplete := analyse.tousLesCoupsSontLegaux and analyse.partieTerminee;
end;


function TranscriptCourantEstUnePartieLegaleEtComplete : boolean;
begin
  TranscriptCourantEstUnePartieLegaleEtComplete := EstUnePartieLegaleEtComplete(gAnalyseDuTranscript);
end;


function NombreCasesVidesTranscriptCourant : SInt64;
begin
  NombreCasesVidesTranscriptCourant := 60 - gAnalyseDuTranscript.nombreCasesRemplies;
end;


function PlusLonguePartieLegaleDuTranscriptEstDansOthellierDeGauche : boolean;
var test : boolean;
    p1 : PositionEtTraitRec;
begin
  p1 := PositionEtTraitInitiauxDuTranscriptCourant;

  test := PositionIsTheInitialPositionOfGameTree(p1) and
          (gAnalyseDuTranscript.plusLonguePartieLegale = PartiePourPressePapier(true,false,nbreCoup));

  PlusLonguePartieLegaleDuTranscriptEstDansOthellierDeGauche := test;
end;


function GetCouleurDesChiffresDuTranscript : RGBColor;
begin
  if EstUnePartieLegaleEtComplete(gAnalyseDuTranscript)
    then GetCouleurDesChiffresDuTranscript := gPurBlanc
    else GetCouleurDesChiffresDuTranscript := gPurNoir;
end;


procedure BeginDrawingForTranscript;
begin
  with gTableContextesGraphiques do
    begin
      if (compteurRecursion < kMaxNiveauRecursionContextesGraphiques)
        then inc(compteurRecursion);
      GetPort(table[compteurRecursion]);
    end;
  EssaieSetPortWindowPlateau;
  SetOrigin(DecalageHorizontalOthellierDuTranscript,DecalageVerticalOthellierDuTranscript);
end;


procedure EndDrawingForTranscript;
begin
  EssaieSetPortWindowPlateau;
  SetOrigin(0,0);
  with gTableContextesGraphiques do
    begin
      SetPort(table[compteurRecursion]);
      if (compteurRecursion > 0)
        then dec(compteurRecursion);
    end;
  if gCassioUseQuartzAntialiasing then
    if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
end;


procedure DessineCaseTranscript(square : SInt64);
var valeur : SInt64;
begin

  BeginDrawingForTranscript;

  if (square >= 11) and (square <= 88) then
    begin
      InvalidateDessinEnTraceDeRayon(square);
      if not(EstUneCaseVideDansTranscript(square,CurrentTranscript))
        then
          begin
            DessinePion2D(square,pionEffaceCaseLarge);
            valeur := CouleurDeCetteCaseDansTranscript(square,CurrentTranscript);
            case valeur of
              pionNoir : DessinePion2D(square,pionNoir);
              pionBlanc: DessinePion2D(square,pionBlanc);
            end;
          end
        else
          begin
            DessinePion2D(square,pionVide);

            if GetCurrentLateralisationOfCurseur = kGauche
              then
                begin
                  DessineChiffre2DTranscript(square,kGauche);
                  DessineChiffre2DTranscript(square,kDroite);
                end
              else
                begin
                  DessineChiffre2DTranscript(square,kDroite);
                  DessineChiffre2DTranscript(square,kGauche);
                end;
          end;
       InvalidateDessinEnTraceDeRayon(square);
    end;

  EndDrawingForTranscript;
end;


procedure DessineHaltere(source,dest : rect);
var x,y,theta : double_t;
    rayon_source,rayon_dest : double_t;
    x0,y0,x1,y1 : SInt64;
    centre_dest,centre_source : Point;
begin

  centre_source := MakePoint((source.left + source.right) div 2, (source.top + source.bottom) div 2);
  centre_dest   := MakePoint((dest.left + dest.right) div 2, (dest.top + dest.bottom) div 2);

  x := centre_dest.h - centre_source.h;
  y := centre_dest.v - centre_source.v;

  rayon_source := 0.24*((source.right - source.left) + (source.bottom - source.top));
  rayon_dest   := 0.24*((dest.right - dest.left) + (dest.bottom - dest.top));

  theta := atan2(y,x);

  x0 := RoundToL(-1.0+centre_source.h + cos(theta) * rayon_source);
  y0 := RoundToL(-1.0+centre_source.v + sin(theta) * rayon_source);

  x1 := RoundToL(-1.0+centre_dest.h - cos(theta) * rayon_dest);
  y1 := RoundToL(-1.0+centre_dest.v - sin(theta) * rayon_dest);

  FrameOval(source);
  FrameOval(dest);
  DessineLigne(MakePoint(x0,y0),MakePoint(x1,y1));

end;



procedure EntourerUneCaseDansTranscript(square : SInt64; color : RGBColor);
var theRect : rect;
    epaisseur : SInt16;
begin
  BeginDrawingForTranscript;

  if (square >= 11) and (square <= 88) then
    begin
      theRect := GetBoundingRectOfSquare(square);
      PenMode(patCopy);
      RGBForeColor(color);
      RGBBackColor(color);
      epaisseur := Min(1 + (GetTailleCaseCourante div 12), 5);
      PenSize(epaisseur,epaisseur);
      FrameOval(theRect);
      RGBForeColor(gPurNoir);
      RGBBackColor(gPurBlanc);
      PenSize(1,1);
    end;

  EndDrawingForTranscript;
end;


procedure DessinerHaltereDansTranscript(square1,square2 : SInt64; color : RGBColor);
var theRect1,theRect2 : rect;
    epaisseur : SInt16;
begin
  BeginDrawingForTranscript;

  if (square1 >= 11) and (square1 <= 88) and
     (square2 >= 11) and (square2 <= 88) then
    begin
      theRect1 := GetBoundingRectOfSquare(square1);
      theRect2 := GetBoundingRectOfSquare(square2);

      InSetRect(theRect1,-1,-1);
      InSetRect(theRect2,-1,-1);
      if not(gCouleurOthellier.estUneImage) and not(retirerEffet3DSubtilOthellier2D) then
        begin
          inc(theRect1.right); inc(theRect1.bottom);
          inc(theRect2.right); inc(theRect2.bottom);
        end;

      PenMode(patCopy);
      RGBForeColor(color);
      RGBBackColor(color);
      epaisseur := Min(1 + (GetTailleCaseCourante div 12), 5);
      PenSize(epaisseur,epaisseur);
      DessineHaltere(theRect1,theRect2);
      RGBForeColor(gPurNoir);
      RGBBackColor(gPurBlanc);
      PenSize(1,1);
    end;

  EndDrawingForTranscript;
end;


procedure DessineScoreFinalDuTranscript;
var s : String255;
    theRect : rect;
    temp : boolean;
    retrecissement : SInt16;
begin
  BeginDrawingForTranscript;
  theRect := aireDeJeu;
  retrecissement := RoundToL(3.25*GetTailleCaseCourante);
  InSetRect(theRect,retrecissement,retrecissement);

  s := ScoreFinalEnChaine(gAnalyseDuTranscript.scorePartieComplete);

  PrepareTexteStatePourTranscript;
  TextFace(bold);
  TextFont(HelveticaID);
  TextSize((2*(theRect.bottom-theRect.top)) div 3);

  temp := doitEffacerSousLesTextesSurOthellier;
  doitEffacerSousLesTextesSurOthellier := false;
  DrawJustifiedStringInRectWithRGBColor(theRect,s,kJusticationCentreHori + kJusticationCentreVert,0,gPurRouge);
  doitEffacerSousLesTextesSurOthellier := temp;

  EndDrawingForTranscript;

  MetTitreFenetrePlateau;
end;


procedure DessineTranscriptCourant;
var i,j,t : SInt64;
begin

  BeginDrawingForTranscript;
  DessineSystemeCoordonnees;
  EndDrawingForTranscript;

  InvalidateAllCasesDessinEnTraceDeRayon;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        t := 10*j + i;
        DessineCaseTranscript(t);
        SetOthellierEstSale(t,true);
      end;
  InvalidateAllCasesDessinEnTraceDeRayon;

  if EstUnePartieLegaleEtComplete(gAnalyseDuTranscript) then
    begin
      DessineScoreFinalDuTranscript;
      ViderSuggestionsDeCorrection;
      DessineSuggestionsDeCorrection;
    end;
end;


function ErreursAAfficherDansTranscriptCourant : SInt64;
var mask : SInt64;
begin
  mask := kTranscriptCoupsDupliques+kTranscriptCoupsIsoles;
  mask := mask + kTranscriptCoupManquant;

  ErreursAAfficherDansTranscriptCourant := mask;
end;


function NombreSuggestionsAffichees : SInt64;
begin
  NombreSuggestionsAffichees := gTranscriptSearch.nbreSuggestions;
end;


procedure DessineNiemeSuggestionDeCorrection(n : SInt16);
var s : String255;
    t : SInt16;
    pt : Point;
begin
  if (n >= 1) and (n <= NombreSuggestionsAffichees) then
    with gTranscriptSearch.suggestions[n] do
    begin
      s := ReadStringFromRessource(kTextesTranscriptID,3)+'  '; {'Suggestion:'}

      MoveTo(-7*GetTailleCaseCourante - EpaisseurBordureOthellier,
             aireDeJeu.bottom + EpaisseurBordureOthellier + 10 + n*12);
      TextFace(normal);
      MyDrawString(s);

      TextFace(bold);
      for t := 0 to nbActions - 1 do
        if t > 0
          then s := s + ' ' + ActionDeCorrectionEnString(actions[t])
          else s := ActionDeCorrectionEnString(actions[t]);
      MyDrawString(s);

      TextFace(normal);
      s := '   '+ReadStringFromRessource(kTextesTranscriptID,4)+ScoreFinalEnChaine(score); {'fait '}
      MyDrawString(s);


      (* dessin du petit bouton 'Voir' *)
      GetPen(pt);
      pt.h := pt.h + 15;
      pt.v := pt.v - 9;
      DessineBoutonPicture(wPlateauPtr,kBoutonVoirID,pt,buttonRect);

    end;
end;


procedure DessineSuggestionsDeCorrection;
var n : SInt64;
begin
  EffaceZoneAuDessousDeLOthellier;
  BeginDrawingForTranscript;
  PrepareTexteStatePourCommentaireSolitaire;
  for n := 1 to NombreSuggestionsAffichees do
    DessineNiemeSuggestionDeCorrection(n);
  EndDrawingForTranscript;
end;


procedure EcranStandardTranscript;
begin
  ChercherLesErreursDansLeTranscriptCourant;
  DessineTranscriptCourant;
  DessineErreursTranscript(ErreursAAfficherDansTranscriptCourant);
  DessineSuggestionsDeCorrection;
end;


procedure EcritMessageSousTranscript(message : String255);
var s : String255;
begin

  (* TODO !!  sale hack : on utilise les routines qui
              servent habituellement a écrire le prompt
              du solitaire "Blanc joue et gagne…", etc.
   *)

   BeginDrawingForTranscript;
   s := CommentaireSolitaire^^;
   CommentaireSolitaire^^ := message;
   PrepareTexteStatePourCommentaireSolitaire;
   EcritCommentaireSolitaire;
   CommentaireSolitaire^^ := s;
   EndDrawingForTranscript;
end;


procedure SetDerniereCaseTapeeDansTranscript(whichSquare : SInt16);
begin
  gAnalyseDuTranscript.derniereCaseTapee := whichSquare;
end;


function DerniereCaseTapee : SInt16;
begin
  DerniereCaseTapee := gAnalyseDuTranscript.derniereCaseTapee;
end;


function DerniereCaseTapeeEstUnCoupIllegal : boolean;
begin
  with gAnalyseDuTranscript do
    DerniereCaseTapeeEstUnCoupIllegal := (BitAnd(TypeErreurDeCetteCaseDansTranscript(derniereCaseTapee,gAnalyseDuTranscript),kTranscriptCoupIllegal) <> 0) and
                                         (GetCurrentLateralisationOfCurseur = kGauche);
end;


procedure ChercherLesErreursDansLeTranscriptCourant;
begin
  ChercherLesErreursDansCeTranscript(gPileTranscripts.pile[gPileTranscripts.current],gAnalyseDuTranscript);
end;


function CeNumeroDeCoupAUneErreur(numero : SInt16; const analyse : AnalyseDeTranscript) : boolean;
begin
  if (numero >= 1) and (numero <= 99)
    then CeNumeroDeCoupAUneErreur := (analyse.cases[numero].typeErreur <> 0)
    else CeNumeroDeCoupAUneErreur := false;
end;


function TypeErreurDeCeNumeroDansTranscript(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt64;
begin
  if (numero >= 1) and (numero <= 99)
    then TypeErreurDeCeNumeroDansTranscript := analyse.cases[numero].typeErreur
    else TypeErreurDeCeNumeroDansTranscript := 0;
end;


function TypeErreurDeCetteCaseDansTranscript(whichSquare : SInt16; const analyse : AnalyseDeTranscript) : SInt64;
begin
  if (whichSquare >= 11) and (whichSquare <= 88)
    then TypeErreurDeCetteCaseDansTranscript := analyse.erreursDansCetteCase[whichSquare]
    else TypeErreurDeCetteCaseDansTranscript := 0;
end;

procedure ChercherLesErreursDansCeTranscript(var myTranscript : Transcript; var analyse : AnalyseDeTranscript);
var square,n : SInt64;
begin
  ResetTranscriptErrors(analyse);
  with analyse do
    begin

      nbDoublons                := 0;
      nbCoupsIsoles             := 0;
      nbCoupsManquants          := 0;
      numeroPremierCoupManquant := 0;
      numeroDernierCoupPresent  := 0;
      numeroPremierCoupIllegal  := 0;
      numeroPremierDoublon      := 0;
      numeroPremierCoupIsole    := 0;
      for n := 0 to 200 do
        begin
          cases[n].cardinal   := 0;
          cases[n].typeErreur := 0;
        end;
      for square := 11 to 88 do
        erreursDansCetteCase[square] := 0;

      { on cherche les doublons }
      for square := 11 to 88 do
        if EstUneCaseVideDansTranscript(square,myTranscript) then
          begin
            n := NumeroDeCetteCaseDansTranscript(square,myTranscript);
            if (n >= 0) and (n <= 200) then
              with cases[n] do
                begin

                  if (n >= 1) and (n <= 6) and
                     (GetSquareOfCurseur(myTranscript) = square) and
                     (GetLateralisationOfCurseur(myTranscript) = kDroite) and
                     (myTranscript.chiffres[square,kDroite] = kChiffreSpecialChiffreVide)
                    then
                      begin
                        (* if cardinal = 0 then inc(cardinal); *)
                        {Sinon on aurait un doublon, mais sans doute temporaire}
                      end
                    else
                      begin
                        inc(cardinal);
                        if (n > 0) and (cardinal >= 2) then
                          begin
                            typeErreur := typeErreur or kTranscriptCoupsDupliques;
                            RaiseTranscriptError(kTranscriptCoupsDupliques,square,analyse);
                            if (cardinal = 2) then inc(nbDoublons);
                          end;
                        liste[cardinal] := square;
                      end;
                end;
          end;

      { On leve une erreur si la derniere case tapee vient de creer un doublon }
      if EstUneCaseVideDansTranscript(derniereCaseTapee,myTranscript) then
        begin
          n := NumeroDeCetteCaseDansTranscript(derniereCaseTapee,myTranscript);
          if (n >= 1) and (cases[n].cardinal > 1) then
            RaiseTranscriptError(kTranscriptVientDeCreerUnDoublon,derniereCaseTapee,analyse);
        end;

      {on cherche les coups depassant 60}
      for n := 61 to 99 do
        begin
          if (cases[n].cardinal = 1) then
            begin
              inc(nbCoupsIsoles);
              cases[n].typeErreur := (cases[n].typeErreur or kTranscriptCoupsIsoles);
              RaiseTranscriptError(kTranscriptCoupsIsoles,cases[n].liste[1],analyse);
            end;
        end;

      {on cherche si il faut inverser la position initiale : le dernier coup rentré
       est-il le coup numero 1 ?}

        if EstUneCaseVideDansTranscript(derniereCaseTapee,myTranscript) and
           (NumeroDeCetteCaseDansTranscript(derniereCaseTapee,myTranscript) = 1) then
           begin
             if (TranscriptALaPositionDeDepartInversee(myTranscript) and SquareInSquareSet(derniereCaseTapee,[34,43,56,65])) or
                (not(TranscriptALaPositionDeDepartInversee(myTranscript)) and SquareInSquareSet(derniereCaseTapee,[35,46,53,64]))
               then
                 InverserCouleurDesPionsDuTranscript(myTranscript);
           end;


      {autre facon de verifier s'il faut inverser la position initiale :
       le coup 1 a-t-il deja ete rentre ?}
        if (cases[1].cardinal = 1) then
          begin
            square := cases[1].liste[1];
            if (GetSquareOfCurseur(myTranscript) <> square) then
              if (TranscriptALaPositionDeDepartInversee(myTranscript) and SquareInSquareSet(square,[34,43,56,65])) or
                 (not(TranscriptALaPositionDeDepartInversee(myTranscript)) and SquareInSquareSet(square,[35,46,53,64]))
                then
                  InverserCouleurDesPionsDuTranscript(myTranscript);
          end;

      {on cherche le dernier coup present}
      for n := 99 downto 1 do
        if (cases[n].cardinal > 0) then
          if (numeroDernierCoupPresent <= 0) then numeroDernierCoupPresent := n;

      {le nombre de cases remplies}
      nombreCasesRemplies  := NombreCasesRempliesDansTranscript(myTranscript);

      {on cherche les coups manquants, en particulier le premier}
      for n := 1 to 99 do
        if (cases[n].cardinal = 0) then
          begin
            if (numeroPremierCoupManquant <= 0) then numeroPremierCoupManquant := n;
            if (n < numeroDernierCoupPresent) or ((n <= 60) and (nombreCasesRemplies >= 50)) then
              begin
                inc(nbCoupsManquants);
                cases[n].typeErreur := cases[n].typeErreur or kTranscriptCoupManquant;
                RaiseTranscriptError(kTranscriptCoupManquant,0,analyse);
              end;
          end;

      {on cherche a rejouer la partie la plus longue possible}
      nombreCoupsPossibles := NombreCoupsCorrectsDansTranscript(myTranscript, analyse, plusLonguePartieLegale);
      tousLesCoupsSontLegaux := (nombreCoupsPossibles = nombreCasesRemplies);


      {on cherche le premier coup illegal}
      for n := 1 to 99 do
        if (numeroPremierCoupIllegal <= 0) and HasTheseErrorsForThisMove(kTranscriptCoupIllegal,analyse,n)
          then numeroPremierCoupIllegal := n;

      {on cherche le premier doublon}
      for n := 1 to 99 do
        if (numeroPremierDoublon <= 0) and HasTheseErrorsForThisMove(kTranscriptCoupsDupliques,analyse,n)
          then numeroPremierDoublon := n;

      {on cherche le premier coup isole}
      for n := 1 to 99 do
        if (numeroPremierCoupIsole <= 0) and HasTheseErrorsForThisMove(kTranscriptCoupsIsoles,analyse,n)
          then numeroPremierCoupIsole := n;

    end;
end;


procedure PlaquerPositionEtPartieLegaleDansOthellierDeGauche(position : PositionEtTraitRec; partiePlaquee : String255);
var jusqueQuelCoup : SInt16;
    gameNodeLePlusProfondGenere : GameTree;
    oldValue,foo : boolean;
    partieDeCassioCourante : String255;
    oldCheckDangerousEvents : boolean;
    tempoAfficheProchainsCoup : boolean;
begin

  if (partiePlaquee = PartiePourPressePapier(true,false,nbreCoup)) or
     (analyseRetrograde.enCours and not(PeutArreterAnalyseRetrograde)) then
    exit(PlaquerPositionEtPartieLegaleDansOthellierDeGauche);

  SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);

  jusqueQuelCoup := LENGTH_OF_STRING(partiePlaquee) div 2;
  partieDeCassioCourante := PartiePourPressePapier(true,false,nroDernierCoupAtteint);

  if (jusqueQuelCoup <= 0) or IsPrefix(partieDeCassioCourante,partiePlaquee)
    then
      begin
        {la partie plaquee est un prefixe de la partie courante}

        if (jusqueQuelCoup <> nbreCoup) then ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);
        SetTranscriptAccepteLesDonnees(false,oldValue);

        if (jusqueQuelCoup < nbreCoup) then DoRetourAuCoupNro(jusqueQuelCoup,false,false) else
        if (jusqueQuelCoup > nbreCoup) then DoAvanceAuCoupNro(jusqueQuelCoup,false);

        SetTranscriptAccepteLesDonnees(oldValue,foo);
        EntrerPartieDansCurrentTranscript(jusqueQuelCoup);
      end
    else
      if (nbreCoup > 0) and IsPrefix(partiePlaquee,partieDeCassioCourante)
        then
          begin
            {la partie courante est un prefixe de la partie plaquee}

            ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);
            SetTranscriptAccepteLesDonnees(false,oldValue);

            RejouePartieOthelloFictive(partiePlaquee,jusqueQuelCoup,EstLaPositionInitialeStandard(position),
                                       position.position,GetTraitOfPosition(position),gameNodeLePlusProfondGenere,1{ = kPeutDetruireArbreDeJeu});

            SetTranscriptAccepteLesDonnees(oldValue,foo);
            EntrerPartieDansCurrentTranscript(jusqueQuelCoup);
          end
        else
          begin
            ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);

            tempoAfficheProchainsCoup := afficheProchainsCoups;
            if afficheProchainsCoups then DoChangeAfficheProchainsCoups;

            {la position initiale}
            if EstLaPositionInitialeDeLaPartieEnCours(position)
              then DoDebut(false)
              else PlaquerPosition(position.position,GetTraitOfPosition(position),kRedessineEcran);

            if (partiePlaquee <> '') and (jusqueQuelCoup > 0) then
              begin
                SetTranscriptAccepteLesDonnees(false,oldValue);

                RejouePartieOthelloFictive(partiePlaquee,jusqueQuelCoup,EstLaPositionInitialeStandard(position),
                                           position.position,GetTraitOfPosition(position),gameNodeLePlusProfondGenere,1{ = kPeutDetruireArbreDeJeu});

                SetTranscriptAccepteLesDonnees(oldValue,foo);
                EntrerPartieDansCurrentTranscript(jusqueQuelCoup);
              end;

            if tempoAfficheProchainsCoup <> afficheProchainsCoups then DoChangeAfficheProchainsCoups;
          end;

  DrawContents(wPlateauPtr);

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);

  RefletePositionCouranteDansPictureIconisation;
end;



procedure AfficherPartieDuTranscriptDansOthellierDeGauche(jusqueQuelCoup : SInt16);
var position : PositionEtTraitRec;
    partieDejaLegale,oldValue,foo : boolean;
begin

  with gAnalyseDuTranscript do
    if (nombreCoupsPossibles > 0) then
      begin
        position := PositionEtTraitInitiauxDuTranscriptCourant;

        if DoitAfficherLaPlusLonguePartiePossible then
          begin
            if PositionIsTheInitialPositionOfGameTree(position) and
               (plusLonguePartieLegale = PartiePourPressePapier(true,false,Min(nombreCoupsPossibles,jusqueQuelCoup)))
              then {WritelnDansRapport('La partie est déjà à jour…')}
              else
                begin

                  partieDejaLegale := EstUnePartieLegaleEtComplete(gAnalyseDuTranscript);

                  if partieDejaLegale then SetTranscriptAccepteLesDonnees(false,oldValue);

                  PlaquerPositionEtPartieLegaleDansOthellierDeGauche(position,plusLonguePartieLegale);

                  if partieDejaLegale then SetTranscriptAccepteLesDonnees(oldValue,foo);
                end
          end;

        RefletePositionCouranteDansPictureIconisation;

      end;
end;


function NombreDoublons(const analyse : AnalyseDeTranscript) : SInt16;
begin
  NombreDoublons := analyse.nbDoublons;
end;


function NombreCasesAvecCeNumero(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
begin
  if (numero < 1) or (numero > 99)
    then NombreCasesAvecCeNumero := 0
    else NombreCasesAvecCeNumero := analyse.cases[numero].cardinal;
end;

function NombreDoublonsApresCeCoup(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
var k,compteur : SInt64;
begin
  if numero <= 0 then numero := 1;
  compteur := 0;
  for k := numero to 99 do
    if (analyse.cases[k].cardinal >= 2) then inc(compteur);
  NombreDoublonsApresCeCoup := compteur;
end;


function NombreDoublonsAvantCeCoup(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
var k,compteur : SInt64;
begin
  if (numero > 99) then numero := 99;
  compteur := 0;
  for k := 99 downto 1 do
    if (analyse.cases[k].cardinal >= 2) then inc(compteur);
  NombreDoublonsAvantCeCoup := compteur;
end;


function NombreDoublonsConsecutifsApresCeCoup(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
var compteur : SInt64;
begin
  if (numero > 99) then numero := 99;
  if (numero < 1)  then numero := 1;
  compteur := 0;
  while (numero <= 99) and (analyse.cases[numero].cardinal >= 2) do
    begin
      inc(compteur);
      inc(numero);
    end;
  NombreDoublonsConsecutifsApresCeCoup := compteur;
end;


function NombreCoupsManquantsConsecutifsApresCeCoup(numero : SInt16; const analyse : AnalyseDeTranscript) : SInt16;
var compteur : SInt64;
begin
  if (numero > 99) then numero := 99;
  if (numero < 1)  then numero := 1;
  compteur := 0;
  while (numero <= 99) and (analyse.cases[numero].cardinal <= 0) do
    begin
      inc(compteur);
      inc(numero);
    end;
  NombreCoupsManquantsConsecutifsApresCeCoup := compteur;
end;


function NombreCoupsIsoles(const analyse : AnalyseDeTranscript) : SInt16;
begin
  NombreCoupsIsoles := analyse.nbCoupsIsoles;
end;


function NombreCoupsManquants(const analyse : AnalyseDeTranscript) : SInt16;
begin
  NombreCoupsManquants := analyse.nbCoupsManquants;
end;


function NombreErreurs(const analyse : AnalyseDeTranscript) : SInt16;
var nbErreurs,k : SInt16;
begin
  nbErreurs := NombreDoublons(analyse) + NombreCoupsIsoles(analyse);

  k := PremierCoupIllegal(analyse);
  if (k >= 1) and (k <= 99) and
     not(HasTheseErrorsForThisMove(kTranscriptCoupsDupliques+kTranscriptCoupsIsoles,analyse,k))
    then inc(nbErreurs);

  NombreErreurs := nbErreurs;
end;


function PremierCoupManquant(const analyse : AnalyseDeTranscript) : SInt16;
begin
  PremierCoupManquant := analyse.numeroPremierCoupManquant;
end;


function PremierCoupIllegal(const analyse : AnalyseDeTranscript) : SInt16;
begin
  PremierCoupIllegal := analyse.numeroPremierCoupIllegal;
end;


function PremierDoublon(const analyse : AnalyseDeTranscript) : SInt16;
begin
  PremierDoublon := analyse.numeroPremierDoublon;
end;


function PremierCoupIsole(const analyse : AnalyseDeTranscript) : SInt16;
begin
  PremierCoupIsole := analyse.numeroPremierCoupIsole;
end;


function DernierCoupPresent(const analyse : AnalyseDeTranscript) : SInt16;
begin
  DernierCoupPresent := analyse.numeroDernierCoupPresent;
end;


function TranscriptALaPositionDeDepartInversee(const whichTranscript : Transcript) : boolean;
begin
  TranscriptALaPositionDeDepartInversee := (CouleurDeCetteCaseDansTranscript(44,whichTranscript) = pionNoir) and
                                           (CouleurDeCetteCaseDansTranscript(45,whichTranscript) = pionBlanc) and
                                           (CouleurDeCetteCaseDansTranscript(54,whichTranscript) = pionBlanc) and
                                           (CouleurDeCetteCaseDansTranscript(55,whichTranscript) = pionNoir);
end;


function PositionEtTraitInitiauxDuTranscript(const whichTranscript : Transcript) : PositionEtTraitRec;
begin
  if TranscriptALaPositionDeDepartInversee(whichTranscript)
    then PositionEtTraitInitiauxDuTranscript := InverserCouleurPionsDansPositionEtTrait(PositionEtTraitInitiauxStandard)
    else PositionEtTraitInitiauxDuTranscript := PositionEtTraitInitiauxStandard;
end;


function PositionEtTraitInitiauxDuTranscriptCourant : PositionEtTraitRec;
begin
  if TranscriptALaPositionDeDepartInversee(CurrentTranscript)
    then PositionEtTraitInitiauxDuTranscriptCourant := InverserCouleurPionsDansPositionEtTrait(PositionEtTraitInitiauxStandard)
    else PositionEtTraitInitiauxDuTranscriptCourant := PositionEtTraitInitiauxStandard;
end;





function NombreCoupsCorrectsDansTranscript(const whichTranscript : Transcript; var analyse : AnalyseDeTranscript; var positionEtPartie : String255) : SInt16;
var n,k,square,compteur,nNoirs,nBlancs : SInt16;
    s : String255;
    bloquage : boolean;
    position,positionAux : PositionEtTraitRec;
begin

  with analyse do
    begin

      (* premiere methode : on teste en sautant les trous, pour voir si on arrive a finir la partie *)
      s := '';
      compteur := 0;

      position := PositionEtTraitInitiauxDuTranscript(whichTranscript);

      n := 1;
      bloquage := false;
      while (n <= 100) and not(bloquage) do
        begin
          {doublon ?}
          if (cases[n].cardinal >= 2) then bloquage := true; {zero ou un coup par numero}

          if (GetTraitOfPosition(position) = pionVide) and (cases[n].cardinal >= 1) then
             begin
               { Si la partie est legale mais que l'on n'a pas utilisé
                 tous les coups du transcripts, les coups superflus sont illegaux }
               for k := 1 to cases[n].cardinal do
                 begin
                   cases[n].typeErreur := cases[n].typeErreur or kTranscriptCoupIllegal;
                   RaiseTranscriptError(kTranscriptCoupIllegal,cases[n].liste[k],analyse);
                   if (cases[n].cardinal = 1) then
                     begin
                       cases[n].typeErreur := (cases[n].typeErreur or kTranscriptCoupsIsoles);
                       RaiseTranscriptError(kTranscriptCoupsIsoles,cases[n].liste[1],analyse);
                     end;
                 end;
             end;

          if not(bloquage) and (cases[n].cardinal = 1) then
            begin
              square := cases[n].liste[1];
              if UpdatePositionEtTrait(position,square)
                then
                  begin
                    inc(compteur);
                    s := s + CoupEnStringEnMajuscules(square);
                  end
                else
                  begin
                    bloquage := true;
                    if (numeroPremierCoupManquant > n) then
                      begin
                        cases[n].typeErreur := cases[n].typeErreur or kTranscriptCoupIllegal;
                        RaiseTranscriptError(kTranscriptCoupIllegal,square,analyse);
                      end;
                  end;
            end;
          inc(n);
        end;


      if (GetTraitOfPosition(position) <> pionVide) then
        begin
          { mais si la partie n'est pas terminee, on se calme
            et on ne saute plus les trous... }
          s := '';
          compteur := 0;

          position := PositionEtTraitInitiauxDuTranscript(whichTranscript);
          n := 1;
          bloquage := false;
          while (n <= 100) and not(bloquage) do
            begin
              {doublon ?}

              if not(bloquage) then
                begin
                  for k := 1 to cases[n].cardinal do
                    begin
                      square := cases[n].liste[k];
                      if (cases[n].cardinal = 1) and UpdatePositionEtTrait(position,square)
                        then
                          begin
                            inc(compteur);
                            s := s + CoupEnStringEnMajuscules(square);
                          end
                        else
                          begin
                            bloquage := true;
                            positionAux := position;
                            if not(UpdatePositionEtTrait(positionAux,square)) then
                              begin
                                cases[n].typeErreur := cases[n].typeErreur or kTranscriptCoupIllegal;
                                RaiseTranscriptError(kTranscriptCoupIllegal,square,analyse);
                              end;
                          end;
                    end;
                end;

              if (cases[n].cardinal <> 1) then bloquage := true;  {exactement un coup par numero}

              inc(n);
            end;

        end;
    end;


  nNoirs  := NbPionsDeCetteCouleurDansPosition(pionNoir,position.position);
  nBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,position.position);
  {Les cases vides vont au vainqueur}
  if nNoirs > nBlancs then nNoirs  := (64 - nBlancs) else
  if nNoirs < nBlancs then nBlancs := (64 - nNoirs);


  analyse.scorePartieComplete    := nNoirs - nBlancs;
  analyse.partieTerminee         := (GetTraitOfPosition(position) = pionVide) and not(HasTranscriptErrorMask(kTranscriptCoupIllegal,analyse));
  analyse.nombreCoupsPossibles   := compteur;
  analyse.plusLonguePartieLegale := s;

  positionEtPartie := s;
  NombreCoupsCorrectsDansTranscript := compteur;
end;


function CouleurDeLaNiemeErreur(N : SInt16) : RGBColor;
begin
  case N of
    1 : CouleurDeLaNiemeErreur := gPurRouge;
    2 : CouleurDeLaNiemeErreur := gPurCyan;
    3 : CouleurDeLaNiemeErreur := gPurVert;
    4 : CouleurDeLaNiemeErreur := gPurMagenta;
    5 : CouleurDeLaNiemeErreur := gPurBleu;
    6 : CouleurDeLaNiemeErreur := gPurJaune;
    7 : CouleurDeLaNiemeErreur := gPurNoir;
    8 : CouleurDeLaNiemeErreur := gPurBlanc;
    9 : CouleurDeLaNiemeErreur := gPurBlanc;
    otherwise CouleurDeLaNiemeErreur := gPurBlanc;
  end;
end;


procedure DessineErreursTranscript(whichErrors : SInt64);
var numero,t,nombreErreurs : SInt64;
    nombreErreursColorees : SInt64;
    messageCoupsManquants : String255;
    nbCoupsManquantsTrouves : SInt64;
    nbMaxManquantsAffiches : SInt64;
begin
  nombreErreurs            := 0;
  nombreErreursColorees    := NombreDoublons(gAnalyseDuTranscript);
  nbCoupsManquantsTrouves  := 0;

  if (NombreCoupsManquants(gAnalyseDuTranscript) >= 2)
    then messageCoupsManquants := ReadStringFromRessource(kTextesTranscriptID,2)   {'Coups manquants : '}
    else messageCoupsManquants := ReadStringFromRessource(kTextesTranscriptID,1);  {'Coup manquant : '}
  if (NombreCoupsManquants(gAnalyseDuTranscript) = 4)
    then nbMaxManquantsAffiches := 4
    else nbMaxManquantsAffiches := 3;

  with gAnalyseDuTranscript do
    begin

      {affichons tous les doublons depuis le plus grand numero}
      for numero := 200 downto 1 do
        if CeNumeroDeCoupAUneErreur(numero,gAnalyseDuTranscript) and
           (BitAnd(cases[numero].typeErreur,whichErrors) <> 0) then
          begin

            {doublons ?}

            if (BitAnd(whichErrors,kTranscriptCoupsDupliques) <> 0) and
               (BitAnd(cases[numero].typeErreur,kTranscriptCoupsDupliques) <> 0) then
              begin
                with cases[numero] do
                  for t := 1 to cardinal do
                    DessinerHaltereDansTranscript(liste[t],liste[(t mod cardinal) + 1],CouleurDeLaNiemeErreur(nombreErreursColorees));
                dec(nombreErreursColorees);
              end;
          end;


      for numero := 1 to 200 do
        if CeNumeroDeCoupAUneErreur(numero,gAnalyseDuTranscript) and
           (BitAnd(cases[numero].typeErreur,whichErrors) <> 0) then

          begin
            inc(nombreErreurs);

            {coups isoles ?}

            if (BitAnd(whichErrors,kTranscriptCoupsIsoles) <> 0) and
               (BitAnd(cases[numero].typeErreur,kTranscriptCoupsIsoles) <> 0) then
              begin
                EntourerUneCaseDansTranscript(cases[numero].liste[1],gPurBlanc);
              end;

            {coups manquants ?}

            if (BitAnd(whichErrors,kTranscriptCoupManquant) <> 0) and
               (BitAnd(cases[numero].typeErreur,kTranscriptCoupManquant) <> 0) then
              begin
                inc(nbCoupsManquantsTrouves);

                if (nbCoupsManquantsTrouves = 1)
                  then messageCoupsManquants := messageCoupsManquants + NumEnString(numero) else
                if (nbCoupsManquantsTrouves >= 2) and (nbCoupsManquantsTrouves <= nbMaxManquantsAffiches)
                  then messageCoupsManquants := messageCoupsManquants + ', '+NumEnString(numero) else
                if (nbCoupsManquantsTrouves = succ(nbMaxManquantsAffiches))
                  then messageCoupsManquants := messageCoupsManquants + ', …';
              end;

          end;

      if (BitAnd(whichErrors,kTranscriptCoupManquant) <> 0) and
          CurrentTranscriptHasThisErrors(kTranscriptCoupManquant) and
          not(TranscriptCourantEstUnePartieLegaleEtComplete)
        then EcritMessageSousTranscript(messageCoupsManquants);

    end;
end;


procedure ImposerUnCoupDansTranscript(whichSquare,numero : SInt16; var myTranscript : Transcript);
begin
  if TranscriptAccepteLesDonnees then
    begin
      if (whichSquare >= 11) and (whichSquare <= 88) and
         (numero >= 1) and (numero <= 99) and
         (NumeroDeCetteCaseDansTranscript(whichSquare,myTranscript) <> numero) then
          begin
            SetNumeroDeCetteCaseDansTranscript(whichSquare,numero,myTranscript);
            SetDerniereCaseTapeeDansTranscript(whichSquare);
          end;
    end;
end;


procedure ImposerEmpilerCurrentTranscript(const myTranscript : Transcript);
var temp : boolean;
    mask : SInt64;
begin
  if TranscriptAccepteLesDonnees then
    begin
      temp := DoitAfficherLaPlusLonguePartiePossible;
      SetAffichageDeLaPlusLonguePartiePossible(false);
      EmpileTranscript(myTranscript);

      ChercherLesErreursDansLeTranscriptCourant;
      DessineTranscriptCourant;
      if (TranscriptError(gAnalyseDuTranscript) <> 0) then
        begin
          mask := ErreursAAfficherDansTranscriptCourant;
          if CurrentTranscriptHasThisErrors(mask)
            then DessineErreursTranscript(mask);
        end;
      AfficherPartieDuTranscriptDansOthellierDeGauche(nroDernierCoupAtteint);
      CorrectionAutomatiqueDuTranscript(gPileTranscripts.pile[gPileTranscripts.current]);

      SetAffichageDeLaPlusLonguePartiePossible(temp);
    end;
end;


procedure EssayerEnregistrerLeTranscriptDansLaBase;
var oldValue,bidbool : boolean;
    myTranscript : Transcript;
    compteur,prochainNumeroActif,quelleCase : SInt16;
begin
  ChercherLesErreursDansLeTranscriptCourant;
  DessineTranscriptCourant;
  with gAnalyseDuTranscript do
    begin

      if EstUnePartieLegaleEtComplete(gAnalyseDuTranscript)
        then
          begin

            { On a une partie complete (affichee en blanc),
              on peut donc essayer de la mettre dans la base }

            if (nbreCoup < nombreCoupsPossibles) then
              PlaquerPositionEtPartieLegaleDansOthellierDeGauche(PositionEtTraitInitiauxDuTranscriptCourant,plusLonguePartieLegale);

            if gameOver then
              begin
                if TranscriptALaPositionDeDepartInversee(CurrentTranscript) then
                  begin
                    (* optimisation : on ne rentre pas tous les coups de la
                       symetrie un par un, mais plutot en une seule fois, à la fin *)

                    SetTranscriptAccepteLesDonnees(false,oldValue);
                    DoSymetrie(axeVertical);
                    SetTranscriptAccepteLesDonnees(oldValue,bidbool);

                    EntrerPartieDansCurrentTranscript(nbreCoup);
                  end;

                if not(positionFeerique) then DialogueSaisieNomsJoueursPartie(-1);
              end;
          end
        else
          begin

            { La partie n'est pas complete, on prend alors les coups
             de gauche et on les met sur le transcript de droite }

             myTranscript := IncrementerToutesLesCases(Max(1,nbreCoup-6),10,CurrentTranscript);
             EntrerPartieDansTranscript(nbreCoup,myTranscript);
             compteur := 0;
             repeat
               inc(compteur);
               myTranscript := DecrementerToutesLesCases(nbreCoup+2, -1,myTranscript,prochainNumeroActif,quelleCase);
             until (prochainNumeroActif = nbreCoup+1) or (compteur >= 10);
             EmpileTranscript(myTranscript);

          end
    end;
end;


function MakeTranscriptFromLegalGame(legalGame : String255; const myTranscript : Transcript) : Transcript;
var k,longueur,square : SInt64;
    posDansChaine : SInt16;
    result : Transcript;
begin
  result := myTranscript;

  {on verifie la legalite de la partie, et on normalise la representation}
  if EstUnePartieOthello(legalGame,true) then
    begin
      longueur := LENGTH_OF_STRING(legalGame) div 2;
      k := 1;
      while (k <= longueur) do
        begin
          square := ScannerStringPourTrouverCoup(2*k-1,legalGame,posDansChaine);
          if (square >= 11) and (square <= 88)
            then ImposerUnCoupDansTranscript(square,k,result);
          inc(k);
        end;
    end;

  MakeTranscriptFromLegalGame := result;
end;


procedure EntrerPartieDansTranscript(jusqueQuelCoup : SInt16; var myTranscript : Transcript);
var k,coup : SInt16;
begin
  if EnModeEntreeTranscript and TranscriptAccepteLesDonnees then
    begin
      for k := 1 to jusqueQuelCoup do
        begin
          coup := GetNiemeCoupPartieCourante(k);
          if (coup >= 11) and (coup <= 88)
            then ImposerUnCoupDansTranscript(coup,k,myTranscript);
        end;
    end;
end;


procedure EntrerPartieDansCurrentTranscript(jusqueQuelCoup : SInt16);
var myTranscript : Transcript;
begin
  if EnModeEntreeTranscript and TranscriptAccepteLesDonnees then
    begin
      myTranscript := CurrentTranscript;
      EntrerPartieDansTranscript(jusqueQuelCoup,myTranscript);
      ImposerEmpilerCurrentTranscript(myTranscript);
    end;
end;


function TraiteMouseEventDansTranscript(evt : eventRecord) : boolean;
var mouseLoc : Point;
    caseCliquee,k : SInt16;
    caseRect : rect;
begin
  TraiteMouseEventDansTranscript := false;

  BeginDrawingForTranscript;
  mouseLoc := evt.where;
  GlobalToLocal(mouseLoc);
  if PtInPlateau(mouseLoc,caseCliquee) and EstUneCaseVideDansTranscript(caseCliquee,CurrentTranscript)
    then
      begin
        { S'agit-il plutot d'un clic sur le chiffre gauche ou droit ? }
        caseRect := GetBoundingRectOfSquare(caseCliquee);
        if (mouseLoc.h <= ((caseRect.left + caseRect.right) div 2))
          then SetPositionCurseur(caseCliquee,kGauche,gPileTranscripts.pile[gPileTranscripts.current])
          else SetPositionCurseur(caseCliquee,kDroite,gPileTranscripts.pile[gPileTranscripts.current]);
        EcranStandardTranscript;
        TraiteMouseEventDansTranscript := true;
      end
    else
      begin
        { L'utilisateur a-t-il clique sur un des petits boutons de suggestion ? }
        for k := 1 to NombreSuggestionsAffichees do
          with gTranscriptSearch.suggestions[k] do
            if PtInRect(mouseLoc,buttonRect) then
              begin
                TraiteMouseEventDansTranscript := true;
                if AppuieBoutonPicture(wPlateauPtr,kBoutonVoirID,kBoutonVoirEnfonceID,buttonRect,mouseLoc)
                  then ImposerEmpilerCurrentTranscript(transcriptCorrige);
              end;
      end;
  EndDrawingForTranscript;
end;


function TraiteKeyboardEventDansTranscript(ch : char; var peutRepeter : boolean) : boolean;
var shift,command,option,control : boolean;
    oldCurseurPosition : SInt16;
    myTranscript : Transcript;
    mask : SInt64;
    prochainNumeroActif,quelleCase : SInt16;
    n,decalage : SInt16;
begin
  ResetTranscriptErrors(gAnalyseDuTranscript);
  SetDerniereCaseTapeeDansTranscript(0);

  shift := BAND(theEvent.modifiers,shiftKey) <> 0;
  command := BAND(theEvent.modifiers,cmdKey) <> 0;
  option := BAND(theEvent.modifiers,optionKey) <> 0;
  control := BAND(theEvent.modifiers,controlKey) <> 0;

  peutRepeter := true;
  TraiteKeyboardEventDansTranscript := false;

  ch := LowerCase(ch);
  oldCurseurPosition := GetCurrentSquareOfCurseur;

  if (ch = chr(FlecheHautKey))     or
     (ch = chr(FlecheBasKey))      or
     (ch = chr(FlecheGaucheKey))   or
     (ch = chr(FlecheDroiteKey))   or
     (ch = chr(TabulationKey))     or
     (ch = chr(EntreeKey))         or
     (ch = chr(TopDocumentKey))    or
     (ch = chr(BottomDocumentKey))    then
    begin

      case ord(ch) of
        FlecheHautKey      : if command
                               then SetPositionCurseur(PremiereCaseVideDansTranscript(CurrentTranscript),kGauche,gPileTranscripts.pile[gPileTranscripts.current])
                               else MonterCurseur(gPileTranscripts.pile[gPileTranscripts.current]);
        FlecheBasKey       : if command
                               then SetPositionCurseur(DerniereCaseVideDansTranscript(CurrentTranscript),kDroite,gPileTranscripts.pile[gPileTranscripts.current])
                               else DescendreCurseur(gPileTranscripts.pile[gPileTranscripts.current]);
        FlecheGaucheKey    : if option
                               then DecalerTousLesChiffresDansTranscript(GetCurrentSquareOfCurseur,GetCurrentLateralisationOfCurseur,kGauche) else
                             if command
                               then BougerCurseurDebutDeLigne(gPileTranscripts.pile[gPileTranscripts.current]) else
                             if shift
                               then BougerCurseurCasePrecedente(gPileTranscripts.pile[gPileTranscripts.current])
                               else BougerCurseurAGauche(gPileTranscripts.pile[gPileTranscripts.current]);
        FlecheDroiteKey    : if option
                               then DecalerTousLesChiffresDansTranscript(GetCurrentSquareOfCurseur,GetCurrentLateralisationOfCurseur,kDroite) else
                             if command
                               then BougerCurseurFinDeLigne(gPileTranscripts.pile[gPileTranscripts.current]) else
                             if shift
                               then BougerCurseurCaseSuivante(gPileTranscripts.pile[gPileTranscripts.current])
                               else BougerCurseurADroite(gPileTranscripts.pile[gPileTranscripts.current]);
        TabulationKey      : if option
                               then SetPositionCurseur(CaseAyantLePlusPetitNumeroAuDela(GetCurrentNumeroOfCurseur + 1),kGauche,gPileTranscripts.pile[gPileTranscripts.current]) else
                             if shift
                               then SetPositionCurseur(ProchaineCaseAvecUneErreurDansTranscript(GetCurrentSquareOfCurseur,-1),kGauche,gPileTranscripts.pile[gPileTranscripts.current])
                               else SetPositionCurseur(ProchaineCaseAvecUneErreurDansTranscript(GetCurrentSquareOfCurseur,1),kGauche,gPileTranscripts.pile[gPileTranscripts.current]);
        EntreeKey          : BougerCurseurADroite(gPileTranscripts.pile[gPileTranscripts.current]);
        TopDocumentKey     : SetPositionCurseur(PremiereCaseVideDansTranscript(CurrentTranscript),kGauche,gPileTranscripts.pile[gPileTranscripts.current]);
        BottomDocumentKey  : SetPositionCurseur(DerniereCaseVideDansTranscript(CurrentTranscript),kDroite,gPileTranscripts.pile[gPileTranscripts.current]);
      end; {case}

      DessineTranscriptCourant;
      ChercherLesErreursDansLeTranscriptCourant;

      peutRepeter := false;
      TraiteKeyboardEventDansTranscript := true;
    end;

  if IsDigit(ch) or (ch = ' ')  or (ch = chr(RetourArriereKey)) or
     ((ch = '+') and not(command)) or (ch = '-') or (ch = '=') or (ch = '*') or (ch = 'i') or (ch = 'd') or
     (ch = '>') or (ch = '<') then
    begin
      case ch of
        'i', '>' :
              if not(command) then
                begin
                  myTranscript := IncrementerCetteCase(GetCurrentSquareOfCurseur, +1, CurrentTranscript);
                  EmpileTranscript(myTranscript);
                  peutRepeter := false;
                end;
        'd','<' :
              if not(command) then
                begin
                  myTranscript := IncrementerCetteCase(GetCurrentSquareOfCurseur, -1, CurrentTranscript);
                  EmpileTranscript(myTranscript);
                  peutRepeter := false;
                end;
        '+' : begin
                n := GetCurrentNumeroOfCurseur;
                if (gAnalyseDuTranscript.cases[n+1].cardinal = 0)
                  then myTranscript := IncrementerCetteCase(GetCurrentSquareOfCurseur, +1, CurrentTranscript)
                  else
                  if (gAnalyseDuTranscript.cases[n+2].cardinal = 0)
                    then myTranscript := IncrementerCetteCase(GetCurrentSquareOfCurseur, +2, CurrentTranscript)
                    else
                      begin
                        if (gAnalyseDuTranscript.cases[n].cardinal > 1) and (gAnalyseDuTranscript.cases[n-1].cardinal > 1)
                          then
                            begin
                              myTranscript := IncrementerToutesLesCasesAndSetValueDansSquare(n+1,1,GetCurrentSquareOfCurseur,n+1,CurrentTranscript);
                              myTranscript := IncrementerToutesLesCasesAndSetValueDansSquare(n+2,1,GetCurrentSquareOfCurseur,n+2,myTranscript);
                            end
                          else
                            begin
                              if (gAnalyseDuTranscript.cases[n+1].cardinal > 1)
                                then decalage := 2
                                else decalage := 1;
                              myTranscript := IncrementerToutesLesCasesAndSetValueDansSquare(n+decalage,decalage,GetCurrentSquareOfCurseur,n+decalage,CurrentTranscript);
                            end;
                      end;
                EmpileTranscript(myTranscript);
                peutRepeter := false;
                TraiteKeyboardEventDansTranscript := true;
              end;
        '-' : begin
                myTranscript := DecrementerToutesLesCases(GetCurrentNumeroOfCurseur, -1,CurrentTranscript,prochainNumeroActif,quelleCase);
                EmpileTranscript(myTranscript);
                peutRepeter := false;
                TraiteKeyboardEventDansTranscript := true;
              end;
        '*' : begin
                SetPositionCurseur(CaseAyantLePlusPetitNumeroAuDela(GetCurrentNumeroOfCurseur + 1),kGauche,gPileTranscripts.pile[gPileTranscripts.current]);
                ChercherLesErreursDansLeTranscriptCourant;
                peutRepeter := false;
                TraiteKeyboardEventDansTranscript := true;
              end;
        '=' : if not(command) then
               begin
                  ChercherLesErreursDansLeTranscriptCourant;
                  if EstUnePartieLegaleEtComplete(gAnalyseDuTranscript)
                    then
                      begin
                        if PeutArreterAnalyseRetrograde then
                          begin
                            DoDebut(false);
                            PlaquerPositionEtPartieLegaleDansOthellierDeGauche(PositionEtTraitInitiauxDuTranscriptCourant,gAnalyseDuTranscript.plusLonguePartieLegale);
                          end
                      end
                    else
                      PlaquerPositionEtPartieLegaleDansOthellierDeGauche(PositionEtTraitInitiauxDuTranscriptCourant,gAnalyseDuTranscript.plusLonguePartieLegale);
                  TraiteKeyboardEventDansTranscript := true;
                end;
        otherwise
              begin
                TaperChiffreDansTranscript(ch);
                if (DerniereCaseTapee = 88) then
                  PlaquerPositionEtPartieLegaleDansOthellierDeGauche(PositionEtTraitInitiauxDuTranscriptCourant,gAnalyseDuTranscript.plusLonguePartieLegale);
                peutRepeter := false;
                TraiteKeyboardEventDansTranscript := true;
              end;
      end; {case}

      DessineTranscriptCourant;
    end;

  if (ch = chr(EscapeKey)) then
    begin
      if not(enRetour) then
        begin
          DoChangeEnModeEntreeTranscript;
          TraiteKeyboardEventDansTranscript := true;
        end;
    end;

  if (ch = chr(ReturnKey)) then
    begin
      EssayerEnregistrerLeTranscriptDansLaBase;
      DessineTranscriptCourant;
      TraiteKeyboardEventDansTranscript := true;
    end;

  if (ch = chr(SuppressionKey))  or
     (ch = '\')                  or
     (ch = '/')                  or
     (ch = ' ')                  or {option-espace : espace dur}
     (ch = ' ')                  or {option-maj-espace : espace dur}
     ((ch = ',') and not(command)) or
     ((ch = '.') and not(command))   then
    begin
      if (ch = chr(SuppressionKey)) or (ch = '\') or (ch = ',') or (ch = '.')
        then DecalerTousLesChiffresDansTranscript(GetCurrentSquareOfCurseur,GetCurrentLateralisationOfCurseur,kGauche)
        else DecalerTousLesChiffresDansTranscript(GetCurrentSquareOfCurseur,GetCurrentLateralisationOfCurseur,kDroite);
      DessineTranscriptCourant;

      peutRepeter := false;
      TraiteKeyboardEventDansTranscript := true;
    end;


  {WritelnNumDansRapport('ord(ch) = ',ord(ch));}

  if command then
    begin
      if (ch = '+') then
        begin
          DoChangeEnModeEntreeTranscript;

          peutRepeter := false;
          TraiteKeyboardEventDansTranscript := true;
        end;
      if (ch = 'z') or (ch = 'Z') then
        begin
          if shift
            then myTranscript := DepileTranscriptVersLaDroite
            else myTranscript := DepileTranscriptVersLaGauche;
          DessineTranscriptCourant;
          PlaquerPositionEtPartieLegaleDansOthellierDeGauche(PositionEtTraitInitiauxDuTranscriptCourant,gAnalyseDuTranscript.plusLonguePartieLegale);

          peutRepeter := false;
          TraiteKeyboardEventDansTranscript := true;
        end;
      if (ch = 'Â') or (ch = 'Å') then  {option - z}
        begin
          myTranscript := DepileTranscriptVersLaDroite;
          DessineTranscriptCourant;
          PlaquerPositionEtPartieLegaleDansOthellierDeGauche(PositionEtTraitInitiauxDuTranscriptCourant,gAnalyseDuTranscript.plusLonguePartieLegale);

          peutRepeter := false;
          TraiteKeyboardEventDansTranscript := true;
        end;
      if (ch = 'n') or (ch = 'N') then
        begin
          ViderTranscriptCourant;
          DessineTranscriptCourant;

          peutRepeter := false;
        end;
    end;

  AccelereProchainDoSystemTask(2);

  if (TranscriptError(gAnalyseDuTranscript) <> 0) then
    begin
      if CurrentTranscriptHasThisErrors(kTranscriptChiffreTropGrand) or
         CurrentTranscriptHasThisErrors(kTranscriptVientDeCreerUnDoublon) or
        (CurrentTranscriptHasThisErrors(kTranscriptCoupIllegal) and DerniereCaseTapeeEstUnCoupIllegal)
        then SysBeep(0);

      mask := ErreursAAfficherDansTranscriptCourant;

      if CurrentTranscriptHasThisErrors(mask)
        then DessineErreursTranscript(mask);
    end;

  AccelereProchainDoSystemTask(2);

  CorrectionAutomatiqueDuTranscript(gPileTranscripts.pile[gPileTranscripts.current]);

  AfficherPartieDuTranscriptDansOthellierDeGauche(nroDernierCoupAtteint);

end;


function HashTranscript(const t : Transcript) : SInt64;
begin
  HashTranscript := GenericHash(@t, SizeOf(Transcript));
end;


function MakeActionDeCorrection(genre : GenreCorrection; square1,square2 : SInt64; arg1,arg2 : SInt64) : ActionDeCorrection;
var result : ActionDeCorrection;
begin
  result.genre   := genre;
  result.square1 := square1;
  result.square2 := square2;
  result.arg1    := arg1;
  result.arg2    := arg2;
  MakeActionDeCorrection := result;
end;


function MakeEmptyTranscriptSet : TranscriptSet;
var result : TranscriptSet;
begin
  result.cardinal := 0;
  result.arbre := MakeEmptyABR;
  MakeEmptyTranscriptSet := result;
end;

function MakeOneElementTranscriptSet(const theTranscript : Transcript; data : SInt64) : TranscriptSet;
var hash : SInt64;
    result : TranscriptSet;
begin
  hash := HashTranscript(theTranscript);
  result.cardinal := 1;
  result.arbre := MakeOneElementABR(hash,data);
  MakeOneElementTranscriptSet := result;
end;

procedure DisposeTranscriptSet(var S : TranscriptSet);
begin
  with S do
    begin
      cardinal := 0;
      DisposeABR(arbre);
    end;
end;

function TranscriptSetEstVide(S : TranscriptSet) : boolean;
begin
  TranscriptSetEstVide := (S.cardinal = 0) or ABRIsEmpty(S.arbre);
end;


function CardinalOfTranscriptSet(S : TranscriptSet) : SInt64;
begin
  CardinalOfTranscriptSet := S.cardinal;
end;


function MemberOfTranscriptSet(const theTranscript : Transcript; var data : SInt64; S : TranscriptSet) : boolean;
var hash : SInt64;
    elementTrouve : ABR;
begin
  if TranscriptSetEstVide(S)
    then MemberOfTranscriptSet := false
    else
      begin
        hash := HashTranscript(theTranscript);
        elementTrouve := ABRSearch(S.arbre,hash);
        if elementTrouve <> NIL
          then
            begin
              MemberOfTranscriptSet := true;
              data := elementTrouve^.data;
            end
          else
            begin
              MemberOfTranscriptSet := false;
              data := -1;
            end;
      end;
end;


procedure AddTranscriptToSet(const theTranscript : Transcript; data : SInt64; var S : TranscriptSet);
var element : ABR;
    hash : SInt64;
begin
  if TranscriptSetEstVide(S)
    then S := MakeOneElementTranscriptSet(theTranscript,data)
    else
      begin
        hash := HashTranscript(theTranscript);
        if (ABRSearch(S.arbre,hash) = NIL) then {s'il n'y est pas deja...}
          begin
            element := MakeOneElementABR(hash,data);
            if element <> NIL then
              begin
                S.cardinal := S.cardinal+1;
                ABRInserer(S.arbre,element);
              end;
          end;
    end;
end;


procedure RemoveTranscriptFromSet(const theTranscript : Transcript; var S : TranscriptSet);
var element : ABR;
    hash : SInt64;
begin
  if not(TranscriptSetEstVide(S)) then
    begin
      hash := HashTranscript(theTranscript);
      element := ABRSearch(S.arbre,hash);
      if (element <> NIL) then {s'il y est...}
        begin
          S.cardinal := S.cardinal-1;
          SupprimerDansABR(S.arbre,element);
        end;
    end;
end;


procedure SetNewMagicCookieForTranscriptSearch;
begin
  gTranscriptSearch.magicCookie := NewMagicCookie;
end;


procedure BeginTranscriptSearch;
var i : SInt64;
begin
  with gTranscriptSearch do
    begin

      if (niveauRecursion > 0) then
        begin
          DisposeMemoryPtr(Ptr(compareAnalyse1));
          DisposeMemoryPtr(Ptr(compareAnalyse2));
          DisposeMemoryPtr(Ptr(analyseDepart));
          for i := 0 to kMaxNiveauRecursionCorrectionAutomatique do
            DisposeMemoryPtr(Ptr(analyseStack[i]));
          DisposeTranscriptSet(searchHistory);
          DisposeStringSet(solutionSet);
        end;

      compareAnalyse1            := AnalyseDeTranscriptPtr(AllocateMemoryPtrClear(SizeOf(AnalyseDeTranscript)));
      compareAnalyse2            := AnalyseDeTranscriptPtr(AllocateMemoryPtrClear(SizeOf(AnalyseDeTranscript)));
      analyseDepart              := AnalyseDeTranscriptPtr(AllocateMemoryPtrClear(SizeOf(AnalyseDeTranscript)));
      for i := 0 to kMaxNiveauRecursionCorrectionAutomatique do
        analyseStack[i]          := AnalyseDeTranscriptPtr(AllocateMemoryPtrClear(SizeOf(AnalyseDeTranscript)));
      searchHistory              := MakeEmptyTranscriptSet;
      solutionSet                := MakeEmptyStringSet;

      inc(niveauRecursion);
      nbreNoeudsVisites          := 0;
      nbreEchangesCoupsAutorises := 1;
      nbreSuggestions            := 0;

      SetNewMagicCookieForTranscriptSearch;

      (* WritelnNumDansRapport('BeginTranscriptSearch, niveauRecursion = ', niveauRecursion);  *)
    end;
end;

procedure EndTranscriptSearch;
var i : SInt64;
begin
  with gTranscriptSearch do
    begin
      (* WritelnNumDansRapport('EndTranscriptSearch, niveauRecursion = ', niveauRecursion); *)

      dec(niveauRecursion);

      if (niveauRecursion = 0) then
        begin
          DisposeMemoryPtr(Ptr(compareAnalyse1));
          DisposeMemoryPtr(Ptr(compareAnalyse2));
          DisposeMemoryPtr(Ptr(analyseDepart));
          for i := 0 to kMaxNiveauRecursionCorrectionAutomatique do
            DisposeMemoryPtr(Ptr(analyseStack[i]));
          DisposeTranscriptSet(searchHistory);
          DisposeStringSet(solutionSet);
        end;
      nbreNoeudsVisites := 0;

      SetNewMagicCookieForTranscriptSearch;

    end;
end;


procedure ViderSuggestionsDeCorrection;
begin
  gTranscriptSearch.nbreSuggestions  := 0;
  gTranscriptSearch.transcriptDepart := TranscriptVide;
end;


function ActionDeCorrectionEnString(whichAction : ActionDeCorrection) : String255;
var s : String255;
    i, n1, n2, decalage: SInt64;
begin
  s := '';

  with whichAction do
    case genre of
        EffacementCase   :
          begin
            s := s + 'effacer la case ';
            s := s + NumEnString(arg1)+'.'+CoupEnString(square1,CassioUtiliseDesMajuscules);
          end;
        EchangeCases     :
          begin
            {s := s + 'permuter (';}
            s := s + '(';
            s := s + NumEnString(arg1)+'.'+CoupEnString(square1,CassioUtiliseDesMajuscules);
            s := s + ' <-> ';
            s := s + NumEnString(arg2)+'.'+CoupEnString(square2,CassioUtiliseDesMajuscules);
            s := s + ')';
          end;
        AucuneCorrection :
          begin
            s := 'aucune correction';
          end;
        IncrementAndSet  :
          begin
            decalage := arg2;
            if decalage > 0
              then
                begin
                  n1 := NumeroDeCetteCaseDansTranscript(square1, CurrentTranscript);
                  n2 := NumeroDeCetteCaseDansTranscript(square2, CurrentTranscript);

                  if (decalage = 1) and (n2 = n1 + 1)
                    then
                      begin
                        s := s + NumEnString(n1) + '.' + CoupEnString(square1,CassioUtiliseDesMajuscules) + '+';
                      end
                    else
                      begin
                        s := s + CoupEnString(square2,CassioUtiliseDesMajuscules);
                        for i := 1 to decalage do
                          s := s +  '+';
                        s := s + '; ';
                        s := s + NumEnString(arg1)+'.'+CoupEnString(square1,CassioUtiliseDesMajuscules);
                      end;
                end
              else
                s := s + NumEnString(arg1)+'.'+CoupEnString(square1,CassioUtiliseDesMajuscules);
          end;
        Renumeroter :
          begin
            s := s + NumEnString(arg1)+'.'+CoupEnString(square1,CassioUtiliseDesMajuscules);
          end;
    end; {case}

  ActionDeCorrectionEnString := s;
end;


procedure EcrireUneCorrectionDansRapport(profondeur : SInt16; whichAction : ActionDeCorrection);
begin
  if (profondeur >= 0) and (profondeur <= kMaxNiveauRecursionCorrectionAutomatique) then
  with gTranscriptSearch, whichAction do
    begin
      WriteDansRapport('(');
      WriteDansRapport(ActionDeCorrectionEnString(whichAction));
      WritelnDansRapport(')');
    end;
end;


procedure PublierUneCorrection(profondeur : SInt16; theCorrection : ActionDeCorrection);
begin
  if (profondeur >= 0) and (profondeur <= kMaxNiveauRecursionCorrectionAutomatique) then
    gTranscriptSearch.correctionsCourantes[profondeur] := theCorrection;
end;


procedure PublierUneSolutionDeCorrection(profondeur : SInt16; const theTranscript : Transcript; const analyse : AnalyseDeTranscript);
var k,profStockee : SInt64;
    square : SInt64;
    transcriptCompact : Transcript;
begin
  with gTranscriptSearch do
    begin
      if not(MemberOfStringSet(analyse.plusLonguePartieLegale,profStockee,solutionSet))
        then
          begin
            AddStringToSet(analyse.plusLonguePartieLegale,profondeur,solutionSet);

            if (nbreSuggestions < kNombreMaxSuggestionsDeCorrection) then
              begin
                inc(nbreSuggestions);

                with suggestions[nbreSuggestions] do
                  begin

                    score := analyse.scorePartieComplete;

                    { transcriptCompact est un transcript equivalent à theTranscript,
                      mais où la numerotation ne depasse pas 60 }
                    transcriptCompact := MakeTranscriptFromLegalGame(analyse.plusLonguePartieLegale,theTranscript);
                    if (NombreCasesDifferentesDansTranscripts(transcriptCompact,transcriptDepart) <= NombreCasesDifferentesDansTranscripts(theTranscript,transcriptDepart))
                      then transcriptCorrige := transcriptCompact
                      else transcriptCorrige := theTranscript;

                    if (NombreCasesDifferentesDansTranscripts(transcriptCorrige,transcriptDepart) <= profondeur + 1)
                      then
                        begin

                          {on simplifie la correction affichee en montrant à l'utilisateur les cases à changer, dans l'ordre}
                          nbActions := 0;
                          with analyse do
                          for k := 1 to 99 do
                            if (cases[k].cardinal = 1) then
                              begin
                                square := cases[k].liste[1];
                                if ((analyseDepart^.cases[k].cardinal <> 1) or (square <> analyseDepart^.cases[k].liste[1])) and
                                   (NumeroDeCetteCaseDansTranscript(square,transcriptCorrige) <> NumeroDeCetteCaseDansTranscript(square,transcriptDepart)) then
                                  begin
                                    actions[nbActions] := MakeActionDeCorrection(Renumeroter,square,0,k,0);
                                    inc(nbActions);
                                  end;
                              end;

                        end
                      else
                        begin
                          {la correction affichée sera un peu complexe, tans pis...}
                          for k := 0 to profondeur - 1 do
                            actions[k] := correctionsCourantes[k];
                          nbActions := profondeur;
                        end;
                  end; {with}
              end;
          end;
    end;
end;

procedure RechercheRecursiveDesCorrections(var myTranscript : Transcript; distanceRacine,profondeurArret : SInt64);
var profondeurStockee : SInt64;
    profondeurRestante : SInt64;
    mask : SInt64;
    analyse : AnalyseDeTranscriptPtr;
    doublons,decalage,decalageMax,placeDisponible : SInt64;
    k,n,n1,n2,c1,c2,square1,square2 : SInt64;
    dernierCoupManquantEssaye : SInt64;
    newTranscript : Transcript;
    oldMagicCookie : SInt64;
label sortie;


   procedure TesterEvenementPendantRechercheRecursive;
   begin
     with gTranscriptSearch do
       begin
         if (magicCookie <> oldMagicCookie) then
           goto sortie;

         if (lastTickForEvents <> TickCount) then
           begin
             lastTickForEvents := TickCount;
             if HasGotEvent(everyEvent,theEvent,0,NIL) then
        		    begin
        		      AccelereProchainDoSystemTask(2);
        		      TraiteOneEvenement;
        		      AccelereProchainDoSystemTask(2);
        		    end;
             lastTickForEvents := TickCount;
           end;

         if (magicCookie <> oldMagicCookie) then
           goto sortie;
       end;
   end;


begin {$UNUSED mask}

  with gTranscriptSearch do
    if (distanceRacine         >= 0) and
       (distanceRacine         <= kMaxNiveauRecursionCorrectionAutomatique) and
       (searchHistory.cardinal < kTailleMaxArbreCorrectionAutomatique) and
       (nbreNoeudsVisites      < kTailleMaxAppelsCorrectionAutomatique) then
      begin
        oldMagicCookie := magicCookie;

        inc(nbreNoeudsVisites);

        profondeurRestante := profondeurArret - distanceRacine;

        { on verifie que le transcript n'a pas déjà été testé }
        if MemberOfTranscriptSet(myTranscript,profondeurStockee,searchHistory) then
          if (profondeurStockee >= profondeurRestante)
            then exit(RechercheRecursiveDesCorrections)
            else RemoveTranscriptFromSet(myTranscript,searchHistory);

        { on met le transcript courant dans l'ensemble decrivant l'histoire de la recherche }
        AddTranscriptToSet(myTranscript,profondeurRestante,searchHistory);

        TesterEvenementPendantRechercheRecursive;

        { on est parti : d'abord, chercher si on est arrivé à une solution...}
        analyse := analyseStack[distanceRacine];
        ChercherLesErreursDansCeTranscript(myTranscript,analyse^);

        TesterEvenementPendantRechercheRecursive;

        if EstUnePartieLegaleEtComplete(analyse^)
          then { bingo !}
            PublierUneSolutionDeCorrection(distanceRacine,myTranscript,analyse^)
          else { bon, il va falloir essayer quelque chose... }
            if (distanceRacine < profondeurArret) and
               (NombreErreurs(analyse^) <= profondeurRestante + 2) then
              with analyse^ do
                begin

                  (* cases vides : on essaie de leur affecter un coup manquant *)
                  for square1 := 11 to 88 do
                    if EstUneCaseVideDansTranscript(square1,myTranscript) and
                       EstUneCaseSansChiffreDansTranscript(square1,myTranscript) then
                      begin
                        TesterEvenementPendantRechercheRecursive;
                        n1 := PremierCoupManquant(analyse^);
                        newTranscript := myTranscript;
                        SetNumeroDeCetteCaseDansTranscript(square1,n1,newTranscript);
                        PublierUneCorrection(distanceRacine,MakeActionDeCorrection(Renumeroter,square1,0,n1,0));
                        TesterEvenementPendantRechercheRecursive;
                        RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                        TesterEvenementPendantRechercheRecursive;
                      end;

                  (* coups isoles : on essaie de les affecter a un coup manquant *)
                  if HasTranscriptErrorMask(kTranscriptCoupsIsoles,analyse^) then
                    begin
                      n := PremierCoupIsole(analyse^);
                      square1 := cases[n].liste[1];

                      dernierCoupManquantEssaye := DernierCoupPresent(analyse^) - 1;
                      if dernierCoupManquantEssaye > 68 then dernierCoupManquantEssaye := 68;
                      if (dernierCoupManquantEssaye < 60) and (DernierCoupPresent(analyse^) >= 57) then
                        dernierCoupManquantEssaye := 60;

                      for n2 := 1 to dernierCoupManquantEssaye do
                        if (cases[n2].cardinal <= 0) then
                          begin
                            TesterEvenementPendantRechercheRecursive;
                            newTranscript := myTranscript;
                            SetNumeroDeCetteCaseDansTranscript(square1,n2,newTranscript);
                            PublierUneCorrection(distanceRacine,MakeActionDeCorrection(Renumeroter,square1,0,n2,0));
                            TesterEvenementPendantRechercheRecursive;
                            RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                            TesterEvenementPendantRechercheRecursive;
                          end;
                    end;

                  (* coups manquants : on essaye de leur affecter un doublon plausible *)
                  if HasTranscriptErrorMask(kTranscriptCoupManquant,analyse^) and
                     HasTranscriptErrorMask(kTranscriptCoupsDupliques,analyse^) then
                    begin
                      n := PremierCoupManquant(analyse^);

                      for square1 := 11 to 88 do
                        begin
                          n1 := NumeroDeCetteCaseDansTranscript(square1, myTranscript);

                          if (NombreCasesAvecCeNumero(n1, analyse^) >= 2) and
                             ((n mod 10 = n1 mod 10) or (n div 10 = n1 div 10) or (abs(n - n1) <= 3)) then
                            begin
                              TesterEvenementPendantRechercheRecursive;
                              newTranscript := myTranscript;
                              SetNumeroDeCetteCaseDansTranscript(square1,n,newTranscript);

                              PublierUneCorrection(distanceRacine,MakeActionDeCorrection(Renumeroter,square1,0,n,0));
                              TesterEvenementPendantRechercheRecursive;
                              RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                              TesterEvenementPendantRechercheRecursive;
                            end;
                        end;
                    end;

                  (* coups illegaux : on essaie de transposer quelques coups *)
                  if HasTranscriptErrorMask(kTranscriptCoupIllegal,analyse^) and
                     (nbreEchangesCoupsAutorises >= 1) then
                    begin
                      n := PremierCoupIllegal(analyse^);

                      if (n >= 1) and (n <= 99) then
                        begin
                          if not(HasTheseErrorsForThisMove(kTranscriptCoupsDupliques,analyse^,n)) then
                            begin

                              { transposition de n avec les coups n-1 et n-2 ? }
                              n1 := n;
                              for c1 := 1 to cases[n1].cardinal do
                                for n2 := n1 - 1 downto n1 - 2 do
                                  if (n2 >= 1) and (n2 <= 99) then
                                    for c2 := 1 to cases[n2].cardinal do
                                    begin
                                      TesterEvenementPendantRechercheRecursive;

                                      square1 := cases[n1].liste[c1];
                                      square2 := cases[n2].liste[c2];

                                      PublierUneCorrection(distanceRacine,MakeActionDeCorrection(EchangeCases,square1,square2,n1,n2));
                                      newTranscript := EchangerCasesDansTranscript(square1,square2,myTranscript);
                                      dec(nbreEchangesCoupsAutorises);
                                      TesterEvenementPendantRechercheRecursive;
                                      RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                                      TesterEvenementPendantRechercheRecursive;
                                      inc(nbreEchangesCoupsAutorises);
                                    end;

                              { transposition des coups n-1 et n-2 ? }
                              n1 := n-1;
                              n2 := n-2;
                              if (n1 >= 1) and (n1 <= 99) and (n2 >= 1) and (n2 <= 99) then
                                for c1 := 1 to cases[n1].cardinal do
                                  for c2 := 1 to cases[n2].cardinal do
                                    begin
                                      TesterEvenementPendantRechercheRecursive;
                                      square1 := cases[n1].liste[c1];
                                      square2 := cases[n2].liste[c2];

                                      PublierUneCorrection(distanceRacine,MakeActionDeCorrection(EchangeCases,square1,square2,n1,n2));
                                      newTranscript := EchangerCasesDansTranscript(square1,square2,myTranscript);
                                      dec(nbreEchangesCoupsAutorises);
                                      TesterEvenementPendantRechercheRecursive;
                                      RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                                      TesterEvenementPendantRechercheRecursive;
                                      inc(nbreEchangesCoupsAutorises);
                                    end;

                              { transposition des coups n-1 et n+1 ? }
                              n1 := n-1;
                              n2 := n+1;
                              if (n1 >= 1) and (n1 <= 99) and (n2 >= 1) and (n2 <= 99) then
                                for c1 := 1 to cases[n1].cardinal do
                                  for c2 := 1 to cases[n2].cardinal do
                                    begin
                                      TesterEvenementPendantRechercheRecursive;
                                      square1 := cases[n1].liste[c1];
                                      square2 := cases[n2].liste[c2];

                                      PublierUneCorrection(distanceRacine,MakeActionDeCorrection(EchangeCases,square1,square2,n1,n2));
                                      newTranscript := EchangerCasesDansTranscript(square1,square2,myTranscript);
                                      dec(nbreEchangesCoupsAutorises);
                                      TesterEvenementPendantRechercheRecursive;
                                      RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                                      TesterEvenementPendantRechercheRecursive;
                                      inc(nbreEchangesCoupsAutorises);
                                    end;

                              { transposition de n avec les coups n+1 et n+2 ? }
                              n1 := n;
                              for c1 := 1 to cases[n1].cardinal do
                                for n2 := n1 + 1 to n1 + 2 do
                                  if (n2 >= 1) and (n2 <= 99) then
                                    for c2 := 1 to cases[n2].cardinal do
                                    begin
                                      TesterEvenementPendantRechercheRecursive;
                                      square1 := cases[n1].liste[c1];
                                      square2 := cases[n2].liste[c2];

                                      PublierUneCorrection(distanceRacine,MakeActionDeCorrection(EchangeCases,square1,square2,n1,n2));
                                      newTranscript := EchangerCasesDansTranscript(square1,square2,myTranscript);
                                      dec(nbreEchangesCoupsAutorises);
                                      TesterEvenementPendantRechercheRecursive;
                                      RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                                      TesterEvenementPendantRechercheRecursive;
                                      inc(nbreEchangesCoupsAutorises);
                                    end;

                              { transposition de n avec les coups n+10, n+20, etc. ? }
                              n1 := n;
                              for c1 := 1 to cases[n1].cardinal do
                                for k := 1 to 4 do
                                  begin
                                    n2 := n1 + k*10;
                                    if (n2 >= 1) and (n2 <= 60) then
                                      for c2 := 1 to cases[n2].cardinal do
                                      begin
                                        TesterEvenementPendantRechercheRecursive;
                                        square1 := cases[n1].liste[c1];
                                        square2 := cases[n2].liste[c2];

                                        PublierUneCorrection(distanceRacine,MakeActionDeCorrection(EchangeCases,square1,square2,n1,n2));
                                        newTranscript := EchangerCasesDansTranscript(square1,square2,myTranscript);
                                        dec(nbreEchangesCoupsAutorises);
                                        TesterEvenementPendantRechercheRecursive;
                                        RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                                        TesterEvenementPendantRechercheRecursive;
                                        inc(nbreEchangesCoupsAutorises);
                                      end;
                                 end;
                            end;
                        end;
                    end;

                  (* doublons : on essaie (a) de renvoyer les coups en double vers des coups manquants
                                          (b) ou d'inserer de la place pour les coups en double
                   *)
                  if HasTranscriptErrorMask(kTranscriptCoupsDupliques,analyse^) then
                    begin
                      n := PremierDoublon(analyse^);

                      { on essaie de reaffecter le doublon vers un coup manquant }
                      for c1 := 1 to cases[n].cardinal do
                        begin
                          square1 := cases[n].liste[c1];

                          dernierCoupManquantEssaye := DernierCoupPresent(analyse^) - 1;
                          if dernierCoupManquantEssaye > 68 then dernierCoupManquantEssaye := 68;
                          if (dernierCoupManquantEssaye < 60) and (DernierCoupPresent(analyse^) >= 57) then
                            dernierCoupManquantEssaye := 60;

                          for n2 := 1 to dernierCoupManquantEssaye do
                            if (cases[n2].cardinal <= 0) then {coup manquant ?}
                              begin
                                TesterEvenementPendantRechercheRecursive;
                                newTranscript := myTranscript;
                                SetNumeroDeCetteCaseDansTranscript(square1,n2,newTranscript);

                                PublierUneCorrection(distanceRacine,MakeActionDeCorrection(Renumeroter,square1,0,n2,0));
                                TesterEvenementPendantRechercheRecursive;
                                RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                                TesterEvenementPendantRechercheRecursive;
                              end;
                        end;

                      { on essaie d'inserer de l'espace pour les coups doublons }
                      doublons := NombreDoublonsConsecutifsApresCeCoup(n,analyse^);

                      if doublons <= 1
                        then decalageMax := doublons + 1
                        else decalageMax := doublons;

                      for decalage := 1 to decalageMax do
                        begin
                          placeDisponible := NombreCoupsManquantsConsecutifsApresCeCoup(n+decalage,analyse^);
                          for c1 := 1 to cases[n].cardinal do
                            begin
                              TesterEvenementPendantRechercheRecursive;
                              square1 := cases[n].liste[c1];

                              newTranscript := IncrementerToutesLesCases(n+decalage,Max(decalage - placeDisponible,0),myTranscript); {faire de la place}
                              SetNumeroDeCetteCaseDansTranscript(square1,n+decalage,newTranscript);

                              {on cherche le premier numero au-dela de n+decalage qui a une case non vide}
                              n2 := 0;
                              for k := n+decalage to 99 do
                                if (cases[k].cardinal > 0) and (n2 = 0) then n2 := k;
                              if (n2 = 0) then n2 := n+decalage;

                              PublierUneCorrection(distanceRacine,MakeActionDeCorrection(IncrementAndSet,square1,cases[n2].liste[1],n+decalage,Max(decalage - placeDisponible,0)));
                              TesterEvenementPendantRechercheRecursive;
                              RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1, profondeurArret);
                              TesterEvenementPendantRechercheRecursive;
                            end;
                        end;
                    end;


                  (* desespoir : on essaie d'effacer la premiere erreur...
                                 Attention ! ceci mene à une explosion combinatoire *)
                  (*
                  numeroPremiereErreur := 0;
                  mask := kTranscriptCoupsDupliques + kTranscriptChiffreTropGrand + kTranscriptCoupsIsoles + kTranscriptCoupIllegal + kTranscriptVientDeCreerUnDoublon;
                  for n := 1 to 99 do
                    if HasTheseErrorsForThisMove(mask,analyse^,n) and (numeroPremiereErreur <= 0) then
                      begin
                        numeroPremiereErreur := n;
                        for c1 := 1 to cases[n].cardinal do
                          begin
                            TesterEvenementPendantRechercheRecursive;
                            square1 := cases[n].liste[c1];
                            PublierUneCorrection(distanceRacine,MakeActionDeCorrection(EffacementCase,square1,0,n,0));
                            newTranscript := myTranscript;
                            SetCouleurDeCePionDansTranscript(square1,pionVide,newTranscript);
                            TesterEvenementPendantRechercheRecursive;
                            RechercheRecursiveDesCorrections(newTranscript,distanceRacine + 1,profondeurArret);
                            TesterEvenementPendantRechercheRecursive;
                          end;
                      end;
                  *)

                end;
      end;

   sortie:

end;


procedure CorrectionAutomatiqueDuTranscript(whichTranscript : Transcript);
var profondeurDeRecherche : SInt64;
    ticks, oldMagicCookie : SInt64;
begin
  with gTranscriptSearch do
    begin
      if TranscriptDoitChercherDesCorrections and not(SameTranscript(whichTranscript,transcriptDepart)) then
        begin
          ViderSuggestionsDeCorrection;

          if (NombreCasesRempliesDansTranscript(whichTranscript) >= 60) or
             ((whichTranscript.curseur.square = 88) and (whichTranscript.curseur.lateralisation = kDroite)) then
            begin
              ticks := TickCount;
              BeginTranscriptSearch;

              oldMagicCookie := magicCookie;

              if (analyseDepart <> NIL) then
                begin
                  transcriptDepart := whichTranscript;
                  ChercherLesErreursDansCeTranscript(whichTranscript, analyseDepart^);


                  (* La recherche elle-même : puisque l'on désire
                     avoir d'abord les solutions les plus simples,
                     on fait un approfondissement iteratif pour
                     simuler une recherche en largeur d'abord  *)

                  if   (magicCookie = oldMagicCookie)
                     and (NombreErreurs(analyseDepart^) <= kMaxNiveauRecursionCorrectionAutomatique + 2)
                     and not(EstUnePartieLegaleEtComplete(analyseDepart^)) then
                    begin
                      for profondeurDeRecherche := 1 to kMaxNiveauRecursionCorrectionAutomatique do
                        if (magicCookie = oldMagicCookie)
                          then RechercheRecursiveDesCorrections(whichTranscript,0,profondeurDeRecherche);
                    end;

                end;

              (* WritelnNumDansRapport('searchHistory.cardinal = ',searchHistory.cardinal);
                 WritelnNumDansRapport('gTranscriptSearch.nbreNoeudsVisites = ',gTranscriptSearch.nbreNoeudsVisites);
                 WritelnNumDansRapport('temps = ',TickCount - ticks);
              *)

              EndTranscriptSearch;
            end;

          DessineSuggestionsDeCorrection;
        end;
    end;
end;



END.
