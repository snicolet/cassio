UNIT UnitUtilitaires;





INTERFACE







 USES UnitDefCassio , Dialogs;








procedure InitUnitUtilitaires;
procedure LibereMemoireUnitUtilitaires;


function MyFiltreClassique(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;

function ComplementeJoueur(prefixe : String255; typeVoulu : SInt64; useMenuHistory : boolean; var found : boolean) : String255;
function ComplementeTournoi(prefixe : String255; typeVoulu : SInt64; useMenuHistory : boolean; var found : boolean) : String255;
function Complemente(typeVoulu : SInt64; useMenuHistory : boolean; var prefixe : String255; var longueurPrefixe : SInt16; var found : boolean) : String255;
procedure CoupJoueDansRapport(numeroCoup,coup : SInt64);
procedure DoListerLesGroupes;
procedure DoAjouterGroupe;


function StringMayHaveUTF8Accents(const s : String255) : boolean;
function UTF8ToAscii(const s : String255) : String255;
procedure ReadUnicodeAccentsFromDisc;
procedure ReadLineWithUnicodeAccents(var ligne : LongString; var theFic : FichierTEXT; var compteur : SInt64);
procedure InspectUnicodeAccent(const accent, remplacement : String255);
procedure AddUnicodeRemplacement(const accent, remplacement : String255);
procedure InitUnicodeTable;
procedure DisposeUnicodeTable;


function ScoreFinalEnChaine(scorePourNoir : SInt16) : String255;
procedure ConstruitTitrePartie(const nomNoir,nomBlanc : String255; enleverLesPrenoms : boolean; scoreNoir : SInt64; var titre : String255);
function EnleveAnneeADroiteDansChaine(var s : String255; var firstYear,lastYear : SInt16) : boolean;
procedure EchangeSurnoms(var nom : String255);
procedure EpureNomJoueur(var unNomDeJoueur : String255);
procedure TraiteJoueurEnMinuscules(nomBrut : String255; var nomJoueur : String255);
procedure TraiteTournoiEnMinuscules(nom : String255; var nomTournoi : String255);
procedure TournoiEnMinuscules(var nomBrut : String255);


function FiltreCoeffDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
function ClicSurCurseurCoeff(mouseLoc : Point; var hauteurExacte,nroCoeff : SInt16) : boolean;
procedure CalculEtAfficheCoeff(dp : DialogPtr; mouseX,item,hauteurExacte : SInt16);
procedure DessineEchellesCoeffs(dp : DialogPtr);
procedure DessineBord(xdeb,y : SInt64; indexBord : SInt64);
procedure DessineEchelleEtCurseur(dp : DialogPtr; xmin,xmax,y : SInt64; coeff : double);
procedure EcritParametre(dp : DialogPtr; s : String255; parametre : SInt64; y : SInt64);
procedure EcritParametres(dp : DialogPtr; quelParametre : SInt16);
procedure EcritEtDessineBords;
procedure EcritValeursTablesPositionnelles(dp : DialogPtr);
procedure EffaceValeursTablesPositionnelles(dp : DialogPtr);


procedure DoInsererMarque;


function PeutCompleterPartieAvecSelectionRapport(var partieAlpha : String255) : boolean;


procedure SetCoupDansSuite(var suite : meilleureSuiteInfosRec; index, coup : SInt64);
function GetCoupDansSuite(var suite : meilleureSuiteInfosRec; index : SInt64) : SInt64;
procedure SetCoupDansMeilleureSuite(index, coup : SInt64);
function GetCoupDansMeilleureSuite(index : SInt64) : SInt64;
procedure FabriqueMeilleureSuiteInfos(premierCoup : SInt16; suiteJouee : t_suiteJouee; meilleureSuite : meilleureSuitePtr; coul : SInt16; plat : plateauOthello; nBla,nNoi : SInt64; message : SInt64);


procedure SauvegardeLigneOptimale(coul : SInt64);
procedure MetCoupEnTeteDansKiller(coup,KillerProf : SInt64);
procedure MeilleureSuiteDansKiller(profKiller : SInt64);
function SquareSetToPlatBool(theSet : SquareSet) : plBool;
procedure SetNbrePionsPerduParVariation(numeroDuCoup,deltaScore : SInt64);
function PrefixeFichierProfiler : String255;
procedure SetEffetSpecial(flag : boolean);
function  GetEffetSpecial : boolean;
function SetClefHashageGlobale(whichValue : SInt64) : SInt64;
procedure TesterClefHashage(valeurCorrecte : SInt64; nomFonction : String255);


procedure Planetes;



(* procedure apprendCoeffsPartiesDeLaListeAlaBill;*)
(* procedure apprendCoeffsLignesPartiesDeLaListe; *)
(* procedure apprendBlocsDeCoinPartiesDeLaListe; *)





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, fp, Fonts, QuickdrawText, Sound, ControlDefinitions
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitListe
    , UnitSaisiePartie, UnitFichiersTEXT, UnitServicesMemoire, UnitJeu, UnitStrategie, UnitBibl, UnitPrefs, UnitGrapheInterversions
    , UnitPalette, UnitAffichageReflexion, UnitServicesRapport, UnitRapportImplementation, UnitAccesNouveauFormat, UnitArbreDeJeuCourant, UnitServicesDialogs, UnitMilieuDePartie
    , UnitHTML, UnitFichierAbstrait, UnitJaponais, UnitSuperviseur, UnitRapport, MyStrings, UnitDialog, UnitGestionDuTemps
    , UnitScannerUtils, UnitLiveUndo, UnitFenetres, UnitBlocsDeCoin, UnitSolve, UnitNormalisation, UnitPackedThorGame, UnitCarbonisation
    , MyMathUtils, UnitGeometrie, SNEvents, UnitScannerOthellistique, UnitRapportWindow, UnitAffichageArbreDeJeu, UnitPressePapier, UnitImportDesNoms
    , UnitStringSet, UnitPositionEtTrait, UnitGameTree, UnitPropertyList, UnitProperties ;
{$ELSEC}
    ;
    {$I prelink/Utilitaires.lk}
{$ENDC}


{END_USE_CLAUSE}





var gJoueursComplementes  : StringSet;
    gTournoisComplementes : StringSet;



const kTailleUnicodeTable = 160;
var gUnicode : record
                 cardinal : SInt64;
                 table : array[0..kTailleUnicodeTable] of
                           record
                             theAccent : String255Ptr;
                             theRemplacement : String255Ptr;
                           end;
               end;
var caracterIsUsedForUTF8 : array[0..255] of boolean;



function MyFiltreClassique(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
begin
  MyFiltreClassique := FiltreClassique(dlog,evt,item);
end;





(*
procedure apprendCoeffsPartiesDeLaListeAlaBill;
var i,j,n,nroReference : SInt64;
    s60 : PackedThorGame;
    trait : SInt64;
    GainTheorique,GainReel : String255;
    ScoreReel : SInt16;
    ok : boolean;
    platBill : plateauOthello;
    jouableBill : plBool;
    nbBlancBill,nbNoirBill : SInt64;
    frontBill : InfoFront;
    traitDansPartie : Tableau60Longint;
    uneMatrice : MatriceCovariance;
    det,constanteGain,constantePerte : double;
    v1,v2,v3 : VecteurCoefficients;



begin

  metTableCoeffAZero(tableCoeffBords);
  metTableCoeffAZero(tableCoeffFrontiere);
  metTableCoeffAZero(tableCoeffEquivFrontiere);
  metTableCoeffAZero(tableCoeffCentre);
  metTableCoeffAZero(tableCoeffGrandCentre);
  metTableCoeffAZero(tableCoeffMinimisation);
  metTableCoeffAZero(tableCoeffCentralite);
  metTableCoeffAZero(tableCoeffBlocsDeCoin);
  MemoryFillChar(@Ng_et_Np,sizeof(Ng_et_Np),chr(0));
  for i := 0 to 50 do annuleMatriceCovariance(SigmaGagnantBill^[i]);
  for i := 0 to 50 do annuleMatriceCovariance(SigmaPerdantBill^[i]);



  WritelnDansRapport('Apprentissage des coeffs de la liste � la Bill�');
  n := 1;
  while (n <= nbPartiesActives) and not(Quitter) do
    begin
      nroReference := tableNumeroReference^^[n];
      GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
      scoreReel := GetScoreReelParNroRefPartie(nroReference);
      if scoreReel > 32 then GainReel := CaracterePourNoir else
      if scoreReel = 32 then GainReel := CaracterePourEgalite else
      if scoreReel < 32 then GainReel := CaracterePourBlanc;

      {WritelnDansRapport('apprentissage de la partie #'+IntToStr(nroReference));}
      ExtraitPartieTableStockageParties(nroreference,s60);
      CalculeLesTraitsDeCettePartie(s60,traitDansPartie);

      OthellierEtPionsDeDepart(platBill,nbNoirBill,nbBlancBill);
      MemoryFillChar(@JouableBill,sizeof(JouableBill),chr(0));
      InitialiseDirectionsJouables;
      CarteJouable(platBill,JouableBill);
      CarteFrontiere(platBill,frontBill);

      ok := true;
      for i := 1 to Min(LENGTH_OF_STRING(s60),45) do
        if ok then
        begin
          trait := traitDansPartie[i];
          ok := ModifPlat(ord(s60[i]),trait,platBill,jouableBill,nbBlancBill,nbNoirBill,frontBill);
          trait := traitDansPartie[i+1];
          if ok then
            if ((GainTheorique = CaracterePourNoir) and (trait = pionNoir)) or
               ((GainTheorique = CaracterePourBlanc) and (trait = pionBlanc))
               then apprendCoeffsMoyensPositionBill(i,ClasseGagnantBill,platBill,trait,
                                                  nbBlancBill,nbNoirBill,jouableBill,frontBill);
          if ok then
            if ((GainTheorique = CaracterePourNoir) and (trait = pionBlanc)) or
               ((GainTheorique = CaracterePourBlanc) and (trait = pionNoir))
               then apprendCoeffsMoyensPositionBill(i,ClassePerdantBill,platBill,trait,
                                                  nbBlancBill,nbNoirBill,jouableBill,frontBill);
        end;

      if (n mod 40) = 0 then WritelnDansRapport(IntToStr(n)+CharToString('�'));

      {
      if (n mod 100) = 0 then EcritCoeffsMoyensBillDansRapport(35);
      }

      if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
      n := n+1;
    end;


  CalculeDifferenceEtDemiSomme(tableCoeffBords);
  CalculeDifferenceEtDemiSomme(tableCoeffFrontiere);
  CalculeDifferenceEtDemiSomme(tableCoeffEquivFrontiere);
  CalculeDifferenceEtDemiSomme(tableCoeffCentre);
  CalculeDifferenceEtDemiSomme(tableCoeffGrandCentre);
  CalculeDifferenceEtDemiSomme(tableCoeffMinimisation);
  CalculeDifferenceEtDemiSomme(tableCoeffCentralite);
  CalculeDifferenceEtDemiSomme(tableCoeffBlocsDeCoin);

  WritelnDansRapport('apprentissage des covariances�');
  n := 1;
  while (n <= nbPartiesActives) and not(Quitter) do
    begin
      nroReference := tableNumeroReference^^[n];
      GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
      scoreReel := GetScoreReelParNroRefPartie(nroReference);
      if scoreReel > 32 then GainReel := CaracterePourNoir else
      if scoreReel = 32 then GainReel := CaracterePourEgalite else
      if scoreReel < 32 then GainReel := CaracterePourBlanc;


      {WritelnDansRapport('apprentissage de la partie #'+IntToStr(nroReference));}
      ExtraitPartieTableStockageParties(nroreference,s60);
      CalculeLesTraitsDeCettePartie(s60,traitDansPartie);

      OthellierEtPionsDeDepart(platBill,nbNoirBill,nbBlancBill);
      MemoryFillChar(@JouableBill,sizeof(JouableBill),chr(0));
      InitialiseDirectionsJouables;
      CarteJouable(platBill,JouableBill);
      CarteFrontiere(platBill,frontBill);

      ok := true;
      for i := 1 to Min(LENGTH_OF_STRING(s60),45) do
        if ok then
        begin
          trait := traitDansPartie[i];
          ok := ModifPlat(ord(s60[i]),trait,platBill,jouableBill,nbBlancBill,nbNoirBill,frontBill);
          trait := traitDansPartie[i+1];
          if ok then
            if ((GainTheorique = CaracterePourNoir) and (trait = pionNoir)) or
               ((GainTheorique = CaracterePourBlanc) and (trait = pionBlanc))
               then apprendVariancesCoeffPositionBill(i,ClasseGagnantBill,platBill,trait,
                                                      nbBlancBill,nbNoirBill,jouableBill,frontBill);
          if ok then
            if ((GainTheorique = CaracterePourNoir) and (trait = pionBlanc)) or
               ((GainTheorique = CaracterePourBlanc) and (trait = pionNoir))
               then apprendVariancesCoeffPositionBill(i,ClassePerdantBill,platBill,trait,
                                                      nbBlancBill,nbNoirBill,jouableBill,frontBill);
        end;

      if (n mod 40) = 0 then WritelnDansRapport(IntToStr(n)+CharToString('�'));

      {
      if (n mod 100) = 0 then
        begin
          WritelnDansRapport('Sigma Gagnant = ');
          EcritMatriceCovariancesBillDansRapport(35,SigmaGagnantBill^[35]);
          WritelnDansRapport('Sigma Perdant = ');
          EcritMatriceCovariancesBillDansRapport(35,SigmaPerdantBill^[35]);
        end;
      }

      if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
      n := n+1;
    end;

 {
  WritelnDansRapport('avant lissage : ');
  for i := 27 to 32 do
    begin
      WriteDansRapport('Sigma Gagnant = ');
      EcritMatriceCovariancesBillDansRapport(i,SigmaGagnantBill^[i]);
      WriteDansRapport('Sigma Perdant = ');
      EcritMatriceCovariancesBillDansRapport(i,SigmaPerdantBill^[i]);
    end;
 }


  WritelnDansRapport('lissage des moyennes�');
  LisserMoyennesCoefficients(tableCoeffBords);
  LisserMoyennesCoefficients(tableCoeffFrontiere);
  LisserMoyennesCoefficients(tableCoeffEquivFrontiere);
  LisserMoyennesCoefficients(tableCoeffCentre);
  LisserMoyennesCoefficients(tableCoeffGrandCentre);
  LisserMoyennesCoefficients(tableCoeffMinimisation);
  LisserMoyennesCoefficients(tableCoeffCentralite);
  LisserMoyennesCoefficients(tableCoeffBlocsDeCoin);

  WritelnDansRapport('lissage des matrices de covariance�');
  lisserMatricesCovariance(SigmaGagnantBill);
  lisserMatricesCovariance(SigmaPerdantBill);

 {
  WritelnDansRapport('apr�s lissage :');
  for i := 27 to 32 do
   begin
     WriteDansRapport('Sigma Gagnant = ');
     EcritMatriceCovariancesBillDansRapport(i,SigmaGagnantBill^[i]);
     WriteDansRapport('Sigma Perdant = ');
     EcritMatriceCovariancesBillDansRapport(i,SigmaPerdantBill^[i]);
   end;
 }

  WritelnDansRapport('calcul des matrices moyennes�');
  for i := 1 to 45 do
    begin
      SommeMatricesCovariance(SigmaGagnantBill^[i],SigmaPerdantBill^[i],uneMatrice);
      multMatriceCovarianceParReel(uneMatrice,0.5,uneMatrice);
      SigmaPerdantBill^[i] := uneMatrice;
      {
      if (i mod 10) = 1 then EcritMatriceCovariancesBillDansRapport(i,uneMatrice);
      }
    end;


  WritelnDansRapport('calcul des matrices inverses�');
  for i := 1 to 45 do
    begin
      InverseMatriceCovariance(SigmaPerdantBill^[i],uneMatrice,det);
      SigmaGagnantBill^[i] := uneMatrice;
    end;



 {
  WritelnDansRapport('v�rification des inversions : ');
  for i := 1 to 45 do
    begin
      if (i mod 10) = 1 then
        begin
          produitMatricesCovariance(SigmaGagnantBill^[i],SigmaPerdantBill^[i],uneMatrice);
          WritelnDansRapport('matrice unit� pour i = '+IntToStr(i)+' : ');
          EcritMatriceCovariancesBillDansRapport(i,uneMatrice);
        end;
    end;
  }


  WritelnDansRapport('calcul des termes constants� ');
  for i := 1 to 45 do
    begin
      ConstruitVecteur(i,ClasseGagnantBill,v1);
      AppliqueMatriceCovariance(SigmaGagnantBill^[i],v1,v2);
      constanteGain := ProduitScalaireVecteursCoefficients(v1,v2);

      ConstruitVecteur(i,ClassePerdantBill,v1);
      AppliqueMatriceCovariance(SigmaGagnantBill^[i],v1,v2);
      constantePerte := ProduitScalaireVecteursCoefficients(v1,v2);

      CoefficientsDeFisher[i,0] := -0.5*(constanteGain-constantePerte);


    end;


  for i := 1 to 45 do
    begin
      ConstruitVecteur(i,DifferenceGagnantPerdant,v1);
      appliqueMatriceCovariance(SigmaGagnantBill^[i],v1,v2);
      for j := 1 to nbCoeffs do
        CoefficientsDeFisher[i,j] := v2[j];

      if (i mod 3) = 1 then
        EcritCoeffsFisherDansRapport(i);

    end;
end;
*)

(*
procedure apprendCoeffsLignesPartiesDeLaListe;
var i,n,nroReference,Nbmin,Nbmax,longueur : SInt64;
    s60 : PackedThorGame;
    plat : plateauOthello;
    trait : SInt64;
    GainTheorique,GainReel : String255;
    scoreReel : SInt16;
    ok : boolean;
    code : t_codage;
    s : String255;
    fmin,fmax,fnote : double;
    nbVides,nbAmis,nbEnnemis : SInt64;
    traitDansPartie : Tableau60Longint;

begin
  if valeurCentralite8 <> NIL then MemoryFillChar(valeurCentralite8,sizeof(valeurCentralite8^),chr(0));
  if valeurCentralite7 <> NIL then MemoryFillChar(valeurCentralite7,sizeof(valeurCentralite7^),chr(0));
  if valeurCentralite6 <> NIL then MemoryFillChar(valeurCentralite6,sizeof(valeurCentralite6^),chr(0));
  if valeurCentralite5 <> NIL then MemoryFillChar(valeurCentralite5,sizeof(valeurCentralite5^),chr(0));
  if valeurCentralite4 <> NIL then MemoryFillChar(valeurCentralite4,sizeof(valeurCentralite4^),chr(0));

  if nbOccurencesLigne8 <> NIL then MemoryFillChar(nbOccurencesLigne8,sizeof(nbOccurencesLigne8^),chr(0));
  if nbOccurencesLigne7 <> NIL then MemoryFillChar(nbOccurencesLigne7,sizeof(nbOccurencesLigne7^),chr(0));
  if nbOccurencesLigne6 <> NIL then MemoryFillChar(nbOccurencesLigne6,sizeof(nbOccurencesLigne6^),chr(0));
  if nbOccurencesLigne5 <> NIL then MemoryFillChar(nbOccurencesLigne5,sizeof(nbOccurencesLigne5^),chr(0));
  if nbOccurencesLigne4 <> NIL then MemoryFillChar(nbOccurencesLigne4,sizeof(nbOccurencesLigne4^),chr(0));

  WritelnDansRapport('Apprentissage des lignes de la liste�');

  n := 1;
  while (n <= nbPartiesActives) and not(Quitter) do
    begin
      nroReference := tableNumeroReference^^[n];
      GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
      scoreReel := GetScoreReelParNroRefPartie(nroReference);
      if scoreReel > 32 then GainReel := CaracterePourNoir else
      if scoreReel = 32 then GainReel := CaracterePourEgalite else
      if scoreReel < 32 then GainReel := CaracterePourBlanc;


      {WritelnDansRapport('apprentissage de la partie #'+IntToStr(nroReference));}
      ExtraitPartieTableStockageParties(nroreference,s60);
      CalculeLesTraitsDeCettePartie(s60,traitDansPartie);

      OthellierDeDepart(plat);
      ok := true;
      for i := 1 to Min(LENGTH_OF_STRING(s60),40) do
        if ok then
        begin
          trait := traitDansPartie[i];
          ok := ModifPlatSeulement(ord(s60[i]),plat,trait);
          trait := traitDansPartie[i+1];
          if ok then apprendLignesPosition(plat,GainTheorique);
        end;

      if (n mod 40) = 0 then WritelnDansRapport(IntToStr(n)+CharToString('�'));
      if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
      n := n+1;
    end;

  longueur := 8;
  fmin := 10000.0;
  fmax := -10000.0;
  Nbmin := 32000;
  Nbmax := -32000;
  for i := -3280 to 3280 do
    begin
      if nbOccurencesLigne8^[i] > 30
        then fnote := 1.0*valeurCentralite8^[i]/nbOccurencesLigne8^[i]
        else
          begin
            CoderBord(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;

      valeurCentralite8^[i] := Trunc(fnote*100);

      if fnote > fmax then
        begin
          fmax := fnote;
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  fmax = '+ReelEnString(fnote));
          WriteDansRapport('  occ = '+IntToStr(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurCentralite8^[i]));
        end;
      if fnote < fmin then
        begin
          fmin := fnote;
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  fmin = '+ReelEnString(fnote));
          WriteDansRapport('  occ = '+IntToStr(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurCentralite8^[i]));
        end;

      if nbOccurencesLigne8^[i] > Nbmax then
        begin
          Nbmax := nbOccurencesLigne8^[i];
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  Nbmax = '+IntToStr(Nbmax));
          WriteDansRapport('  fnote = '+ReelEnString(fnote));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurCentralite8^[i]));
        end;
      if nbOccurencesLigne8^[i] < Nbmin then
        begin
          Nbmin := nbOccurencesLigne8^[i];
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  Nbmin = '+IntToStr(Nbmin));
          WriteDansRapport('  fnote = '+ReelEnString(fnote));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurCentralite8^[i]));
        end;

      if ((i+14) mod 50)  = 0 then
        begin
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WriteDansRapport(code);
          WriteDansRapport('  i = '+IntToStr(i)+CharToString(' '));
          WriteDansRapport('  fnote = '+ReelEnString(fnote));
          WriteDansRapport('  Occ = '+IntToStr(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurCentralite8^[i]));
        end;
    end;

    longueur := 7;
    for i := -1093 to 1093 do
    begin
      if nbOccurencesLigne7^[i] > 30
        then fnote := 1.0*valeurCentralite7^[i]/nbOccurencesLigne7^[i]
        else
          begin
            CoderBord(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
      valeurCentralite7^[i] := Trunc(fnote*100);
    end;

    longueur := 6;
    for i := -364 to 364 do
    begin
      if nbOccurencesLigne6^[i] > 30
        then fnote := 1.0*valeurCentralite6^[i]/nbOccurencesLigne6^[i]
        else
          begin
            CoderBord(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
      valeurCentralite6^[i] := Trunc(fnote*100);
    end;

    longueur := 5;
    for i := -121 to 121 do
    begin
      if nbOccurencesLigne5^[i] > 30
        then fnote := 1.0*valeurCentralite5^[i]/nbOccurencesLigne5^[i]
        else
          begin
            CoderBord(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
      valeurCentralite5^[i] := Trunc(fnote*100);
    end;

    longueur := 4;
    for i := -40 to 40 do
    begin
      if nbOccurencesLigne4^[i] > 30
        then fnote := 1.0*valeurCentralite4^[i]/nbOccurencesLigne4^[i]
        else
          begin
            CoderBord(i,longueur,code,nbVides,nbAmis,nbEnnemis);
            fnote := 0.01*notationCentralite(code,longueur,nbVides,nbAmis,nbEnnemis);
          end;
      valeurCentralite4^[i] := Trunc(fnote*100);
    end;
end;
*)

(*
procedure apprendBlocsDeCoinPartiesDeLaListe;
var i,n,nroReference,Nbmin,Nbmax : SInt64;
    s60 : PackedThorGame;
    plat : plateauOthello;
    trait : SInt64;
    GainTheorique,GainReel : String255;
    scoreReel : SInt16;
    ok : boolean;
    code : t_codage;
    s : String255;
    fmin,fmax,fnote : double;
    nbVides,nbAmis,nbEnnemis : SInt64;
    traitDansPartie : Tableau60Longint;

begin
  if valeurBlocsDeCoin <> NIL then MemoryFillChar(valeurBlocsDeCoin,sizeof(valeurBlocsDeCoin^),chr(0));
  if nbOccurencesLigne8 <> NIL then MemoryFillChar(nbOccurencesLigne8,sizeof(nbOccurencesLigne8^),chr(0));

  WritelnDansRapport('Apprentissage des blocs de coin de la liste�');
  n := 1;
  while (n <= nbPartiesActives) and not(Quitter) do
    begin
      nroReference := tableNumeroReference^^[n];
      GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
      scoreReel := GetScoreReelParNroRefPartie(nroReference);
      if scoreReel > 32 then GainReel := CaracterePourNoir else
      if scoreReel = 32 then GainReel := CaracterePourEgalite else
      if scoreReel < 32 then GainReel := CaracterePourBlanc;


      {WritelnDansRapport('apprentissage de la partie #'+IntToStr(nroReference));}
      ExtraitPartieTableStockageParties(nroreference,s60);
      CalculeLesTraitsDeCettePartie(s60,traitDansPartie);

      OthellierDeDepart(plat);
      ok := true;
      for i := 1 to Min(LENGTH_OF_STRING(s60),47) do
        if ok then
        begin
          trait := traitDansPartie[i];
          ok := ModifPlatSeulement(ord(s60[i]),plat,trait);
          trait := traitDansPartie[i+1];
          if ok then apprendBlocsDeCoinPosition(plat,GainTheorique);
        end;

      if (n mod 40) = 0 then WritelnDansRapport(IntToStr(n)+CharToString('�'));
      if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
      n := n+1;
    end;


  fmin := 10000.0;
  fmax := -10000.0;
  Nbmin := 32000;
  Nbmax := -32000;
  for i := -3280 to 3280 do
    begin
      if nbOccurencesLigne8^[i] > 0
        then
          begin
            fnote := 1.0*valeurBlocsDeCoin^[i]/nbOccurencesLigne8^[i];
            CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
            if (nbVides >= 1) and ((i mod 30) = 6) then
              begin
                WritelnDansRapport('');
                WritelnDansRapport(TPCopy(code,1,4));
                WriteDansRapport(TPCopy(code,5,4));
                WriteDansRapport('  i = '+IntToStr(i)+CharToString(' '));
                WriteDansRapport('  fnote = '+ReelEnString(fnote));
                WritelnDansRapport('  Occ = '+IntToStr(nbOccurencesLigne8^[i]));
              end;
            if nbOccurencesLigne8^[i] <= 10 then fnote := 0.5*fnote;
            if nbOccurencesLigne8^[i] <= 6 then fnote := 0.5*fnote;
          end
        else
          begin
            fnote := 0.0;
          end;

      valeurBlocsDeCoin^[i] := Trunc(fnote*100);

      if fnote > fmax then
        begin
          fmax := fnote;
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  fmax = '+ReelEnString(fnote));
          WriteDansRapport('  occ = '+IntToStr(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurBlocsDeCoin^[i]));
        end;
      if fnote < fmin then
        begin
          fmin := fnote;
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  fmin = '+ReelEnString(fnote));
          WriteDansRapport('  occ = '+IntToStr(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurBlocsDeCoin^[i]));
        end;

      if nbOccurencesLigne8^[i] > Nbmax then
        begin
          Nbmax := nbOccurencesLigne8^[i];
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  Nbmax = '+IntToStr(Nbmax));
          WriteDansRapport('  fnote = '+ReelEnString(fnote));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurBlocsDeCoin^[i]));
        end;
      if nbOccurencesLigne8^[i] < Nbmin then
        begin
          Nbmin := nbOccurencesLigne8^[i];
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  Nbmin = '+IntToStr(Nbmin));
          WriteDansRapport('  fnote = '+ReelEnString(fnote));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurBlocsDeCoin^[i]));
        end;

      if (((i+14) mod 50)  = 0) and (fnote <> 0.0) then
        begin
          CoderBord(i,8,code,nbVides,nbAmis,nbEnnemis);
          WritelnDansRapport('');
          WritelnDansRapport(TPCopy(code,1,4));
          WriteDansRapport(TPCopy(code,5,4));
          WriteDansRapport('  i = '+IntToStr(i)+CharToString(' '));
          WriteDansRapport('  fnote = '+ReelEnString(fnote));
          WriteDansRapport('  Occ = '+IntToStr(nbOccurencesLigne8^[i]));
          WritelnDansRapport('  note pour 1 = '+IntToStr(valeurBlocsDeCoin^[i]));
        end;
    end;

end;
*)


function ComplementeJoueur(prefixe : String255; typeVoulu : SInt64; useMenuHistory : boolean; var found : boolean) : String255;
var i,n,idepart,numeroDansSet : SInt64;
    joueurBase,prefixeMajus,derniereChaineMajus : String255;
begin

  ComplementeJoueur := prefixe;
  found := false;

  prefixeMajus := prefixe;
  prefixeMajus := MyUpperString(prefixeMajus,false);
  derniereChaineMajus := derniereChaineComplementation^^;
  derniereChaineMajus := MyUpperString(derniereChaineMajus,false);


  if (prefixe <> '') and (JoueursNouveauFormat.nbJoueursNouveauFormat > 0) then
    begin
      if (prefixeMajus <> derniereChaineMajus) or
         (TypeDerniereComplementation <> typeVoulu)
        then
          begin  {complementation avec un nouveau prefixe}
            DisposeStringSet(gJoueursComplementes);
            iDepart := 0;
            if useMenuHistory then
              for n := 1 to kNbJoueursMenuSaisie do
                begin
                  i := GetNiemeJoueurTableSaisiePartie(n);
                  joueurBase := GetNomJoueur(i);
                  joueurBase := MyUpperString(joueurBase,false);
                  if (Pos(prefixeMajus,joueurBase) = 1) then
                    begin
                      iDepart := i;
                      leave;
                    end;
                end;
          end
        else
          begin  {on continue avec le meme prefixe }
            iDepart := numeroDerniereComplementationDansTable + 1;
          end;


      if iDepart < 0 then iDepart := 0;
      if iDepart >= JoueursNouveauFormat.nbJoueursNouveauFormat then iDepart := 0;

      i := iDepart;
      repeat


        {on essaie de voir si le prefixe est le debut du joueur numero "i" dans la liste des joueurs}
        joueurBase := GetNomJoueur(i);
        joueurBase := MyUpperString(joueurBase,false);
        if (Pos(prefixeMajus,joueurBase) = 1) then
          begin
            joueurBase := GetNomJoueur(i);
            joueurBase := EnleveEspacesDeDroite(joueurBase);

            { a-t-on deja renvoy� ce joueur dans cette serie de complementations ? }
            if MemberOfStringSet(joueurBase,numeroDansSet,gJoueursComplementes)
              then
                begin
                  if (numeroDansSet = i) then  {on ne garde que la premiere occurence en cas de joueurs dupliqu�s}
                    begin
                      ComplementeJoueur := joueurBase;
                      numeroDerniereComplementationDansTable := i;
                      found := true;
                    end;
                end
              else
                begin  {c'est la premiere occurence de ce joueur avec le bon prefixe}
                  AddStringToSet(joueurBase,i,gJoueursComplementes);
                  ComplementeJoueur := joueurBase;
                  numeroDerniereComplementationDansTable := i;
                  found := true;
                end;
          end;

        {on fait la meme chose avec les noms japonais}
        if gVersionJaponaiseDeCassio and gHasJapaneseScript and not(found) and JoueurAUnNomJaponais(i) then
          begin
            joueurBase := GetNomJaponaisDuJoueur(i);
            joueurBase := MyUpperString(joueurBase,false);
            if (Pos(prefixeMajus,joueurBase) = 1) then
		          begin
		            joueurBase := GetNomJaponaisDuJoueur(i);
		            joueurBase := EnleveEspacesDeDroite(joueurBase);

		            { a-t-on deja renvoy� ce joueur dans cette serie de complementations ? }
		            if MemberOfStringSet(joueurBase,numeroDansSet,gJoueursComplementes)
                  then
                    begin
                      if (numeroDansSet = i) then  {on ne garde que la premiere occurence en cas de joueurs dupliqu�s}
                        begin
                          ComplementeJoueur := joueurBase;
                          numeroDerniereComplementationDansTable := i;
                          found := true;
                        end;
                    end
                  else
                    begin {c'est la premiere occurence de ce joueur avec le bon prefixe}
                      AddStringToSet(joueurBase,i,gJoueursComplementes);
                      ComplementeJoueur := joueurBase;
                      numeroDerniereComplementationDansTable := i;
                      found := true;
                    end;
    		          end;
          end;

        i := i+1;
        if (i >= JoueursNouveauFormat.nbJoueursNouveauFormat) then i := 0;
      until found or (i = iDepart);
    end;

  TypeDerniereComplementation := typeVoulu;
  if found
    then derniereChaineComplementation^^ := TPCopy(joueurBase,1,LENGTH_OF_STRING(prefixe))
    else derniereChaineComplementation^^ := prefixe;

end;



function ComplementeTournoi(prefixe : String255; typeVoulu : SInt64; useMenuHistory : boolean; var found : boolean) : String255;
var i,n,idepart,numeroDansSet : SInt64;
    tournoi,prefixeMaj,derniereChaineMaj : String255;
begin
  ComplementeTournoi := prefixe;
  found := false;

  prefixeMaj := prefixe;
  derniereChaineMaj := derniereChaineComplementation^^;
  prefixeMaj := MyUpperString(prefixeMaj,false);
  derniereChaineMaj := MyUpperString(derniereChaineMaj,false);

  if (prefixeMaj <> derniereChaineMaj) or (TypeDerniereComplementation <> typeVoulu)
    then
      begin {complementation avec un nouveau prefixe}
        DisposeStringSet(gTournoisComplementes);
        iDepart := TournoisNouveauFormat.nbTournoisNouveauFormat - 1;
        if useMenuHistory then
          for n := 1 to kNbTournoisMenuSaisie do
            begin
              i := GetNiemeTournoiTableSaisiePartie(n);
              tournoi := GetNomTournoi(i);
              tournoi := MyUpperString(tournoi,false);
              if (Pos(prefixeMaj,tournoi) = 1) then
                begin
                  iDepart := i;
                  leave;
                end;
            end;
      end
    else
      begin {on continue avec le meme prefixe}
        iDepart := numeroDerniereComplementationDansTable-1;
      end;

  if iDepart < 0 then iDepart := TournoisNouveauFormat.nbTournoisNouveauFormat-1;
  if iDepart >= TournoisNouveauFormat.nbTournoisNouveauFormat then iDepart := TournoisNouveauFormat.nbTournoisNouveauFormat-1;

  i := iDepart;
  found := false;
  if (TournoisNouveauFormat.nbTournoisNouveauFormat > 0) then
  repeat

    {on essaie de voir si le prefixe est le debut du tournoi numero "i" dans la liste des tournois}
    tournoi := GetNomTournoi(i);
    tournoi := MyUpperString(tournoi,false);
    if (Pos(prefixeMaj,tournoi) = 1) then
      begin
        tournoi := GetNomTournoi(i);
        tournoi := EnleveEspacesDeDroite(tournoi);

        { a-t-on deja renvoy� ce tournoi dans cette serie de complementations ? }
        if MemberOfStringSet(tournoi,numeroDansSet,gTournoisComplementes)
          then
            begin
              if (numeroDansSet = i) then  {on ne garde que la premiere occurence en cas de tournois dupliqu�s}
                begin
                  ComplementeTournoi := tournoi;
                  numeroDerniereComplementationDansTable := i;
                  found := true;
                end;
            end
          else
            begin  {c'est la premiere occurence de ce tournoi avec le bon prefixe}
              AddStringToSet(tournoi,i,gTournoisComplementes);
              ComplementeTournoi := tournoi;
              numeroDerniereComplementationDansTable := i;
              found := true;
            end;
      end;

    i := i-1;
    if (i < 0) then i := TournoisNouveauFormat.nbTournoisNouveauFormat-1;
  until found or (i = iDepart);

  TypeDerniereComplementation := typeVoulu;
  if found
    then derniereChaineComplementation^^ := TPCopy(tournoi,1,LENGTH_OF_STRING(prefixe))
    else derniereChaineComplementation^^ := prefixe;
end;


function Complemente(typeVoulu : SInt64; useMenuHistory : boolean; var prefixe : String255; var longueurPrefixe : SInt16; var found : boolean) : String255;
begin
  Complemente := prefixe;
  found := false;

  if joueursEtTournoisEnMemoire then
    case typeVoulu of
      complementationJoueurNoir  : Complemente := ComplementeJoueur(prefixe , typeVoulu, useMenuHistory, found);
      complementationJoueurBlanc : Complemente := ComplementeJoueur(prefixe , typeVoulu, useMenuHistory, found);
      complementationTournoi     : Complemente := ComplementeTournoi(prefixe, typeVoulu, useMenuHistory, found);
    end;

  longueurPrefixe := LENGTH_OF_STRING(prefixe);
end;


procedure CoupJoueDansRapport(numeroCoup,coup : SInt64);
var s{,s1} : String255;
    nomOuverture : String255;
    {oldScript : SInt64;}
    nomOuvertureProp : Property;
    s60 : PackedThorGame;
    autreCoupQuatreDiagDansPartie : boolean;
    ouvertureDiagonale : boolean;
begin {$UNUSED numeroCoup,coup,s,s1,oldScript}

  if avecNomOuvertures then
    begin
		  if (SelectFirstPropertyOfTypesInGameTree([OpeningNameProp],GetCurrentNode) = NIL) and
		      NomOuvertureChange(nomOuverture) then
		    begin
		      EnleveEspacesDeDroiteSurPlace(nomOuverture);
		      {
		      GetCurrentScript(oldScript);
		      IntToStr(numeroCoup,s1);
		      s := '� '+s1+CharToString('.')+CoupEnString(coup,CassioUtiliseDesMajuscules)+' �';
		      s := s + '   �'+nomOuverture+CharToString('�');
		      DisableKeyboardScriptSwitch;
		      FinRapport;
		      TextNormalDansRapport;
		      WritelnDansRapport(s);
		      EnableKeyboardScriptSwitch;
		      SetCurrentScript(oldScript);
		      SwitchToRomanScript;
		      }
		      nomOuvertureProp := MakeStringProperty(OpeningNameProp,nomOuverture);
		      InsertPropInListAfter(nomOuvertureProp,GetCurrentNode^.properties,SelectMovePropertyOfNode(GetCurrentNode));
		      DisposePropertyStuff(nomOuvertureProp);
		    end;
		end;

  if avecInterversions then
    begin
		  s := PartieNormalisee(autreCoupQuatreDiagDansPartie,false);
		  {WritelnDansRapport('dans CoupJoueDansRapport, s = '+s);}
		  tableLignes^.cardinal := 0;
		  if InterversionDansLeGrapheApprentissage(s,false,tableLignes) then
		    begin
		      s60 := tableLignes^.table[2];
		      ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		      TransposePartiePourOrientation(s60,autreCoupQuatreDiagDansPartie,1,60);
		      TraductionThorEnAlphanumerique(s60,s);
		      {WritelnDansRapport('dans CoupJoueDansRapport, interversion = '+s);}
		      AddTranspositionPropertyToCurrentNode(s);
		    end;
		end;

end;


procedure DoListerLesGroupes;
var i : SInt64;
    s : String255;
    oldScript : SInt64;
begin
  GetCurrentScript(oldScript);
  if not(FenetreRapportEstOuverte)
    then
      OuvreFntrRapport(false,true)
    else
      if not(FenetreRapportEstAuPremierPlan) then SelectWindowSousPalette(GetRapportWindow);
  WritelnDansRapport('');
  s := ReadStringFromRessource(TextesGroupesID,1);
  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
  ChangeFontDansRapport(gCassioRapportBoldFont);
  ChangeFontFaceDansRapport(bold);
  WritelnDansRapport(s);

  TextNormalDansRapport;
  for i := 1 to nbMaxGroupes do
    begin
      s := Groupes^^[i];
      if s <> '' then WritelnDansRapport(s);
    end;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
end;

procedure DoAjouterGroupe;
const OuiBouton = 1;
      DialogueSyntaxeGroupesID = 1134;
var i : SInt64;
    ok,groupeUtilise : boolean;
    newGroupe,groupeExistant,nomDuGroupe,s : String255;
    caracteres : CharArrayHandle;
    posSigma,posEgal,posAcoladeOuvrante,posAcoladeFermante : SInt64;
    syntaxeCorrecte,groupeVide : boolean;


  function ConfirmationRemplacerGroupe : boolean;
  const DialogueRemplacerGroupeID = 1133;
        annulerBouton = 1;
        remplacerBouton = 2;
	var itemHit : SInt16;
	begin
	  ConfirmationRemplacerGroupe := true;

	  itemHit := CautionAlertTwoButtonsFromRessource(DialogueRemplacerGroupeID,4,0,annulerBouton,remplacerBouton);

	  ConfirmationRemplacerGroupe := (itemHit = remplacerBouton);

	end;



begin
  ok := false;
  if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan and SelectionRapportNonVide then
    ok := true;
  if not(ok)
    then
      begin
        DialogueSimple(DialogueSyntaxeGroupesID);
      end
    else
      begin
        if (LongueurSelectionRapport > 255)
          then
            begin
              s := ReadStringFromRessource(TextesGroupesID,2);
              AlerteSimple(s);
            end
          else
            begin
              caracteres := GetRapportTextHandle;
              newGroupe := '';
              for i := GetDebutSelectionRapport to GetFinSelectionRapport - 1 do
                if caracteres^^[i] <> chr(13) then    {retour chariot}
                  newGroupe := newGroupe+caracteres^^[i];
              EnleveEspacesDeDroiteSurPlace(newGroupe);
              EnleveEspacesDeGaucheSurPlace(newGroupe);

              posSigma := Pos('�',newGroupe);
              posEgal := Pos('=',newgroupe);
              posAcoladeOuvrante := Pos('{',newgroupe);
              posAcoladeFermante := Pos('}',newgroupe);

              { On verifie que le nom du groupe est non vide, qu'il commence par �
                et que les acolades sont bien placees }
              syntaxeCorrecte := (posSigma = 1) and
                                 (posEgal > 2) and
                                 (posAcoladeOuvrante > posEgal) and
                                 (posAcoladeFermante > posAcoladeOuvrante);

              { Et il ne doit y avoir que des espaces (eventuellement aucune)
                entre le signe egal et l'acolade ouvrante}
              for i := posEgal+1 to posAcoladeOuvrante-1 do
                if newgroupe[i] <> ' ' then syntaxeCorrecte := false;

              { L'utilisateur peut avoir d�fini un groupe vide pour supprimer
                un groupe existant. Est-ce la cas ? }
              groupeVide := true;
              for i := posAcoladeOuvrante+1 to posAcoladeFermante-1 do
                if newgroupe[i] <> ' ' then groupeVide := false;


              if not(syntaxeCorrecte)
                then
                  begin
                    s := ReadStringFromRessource(TextesGroupesID,3);
                    AlerteSimple(s);
                  end
                else
                  begin
                    groupeUtilise := false;
                    nomDuGroupe := TPCopy(newGroupe,1,posEgal-1);
                    EnleveEspacesDeDroiteSurPlace(nomDuGroupe);
                    for i := 1 to nbMaxGroupes do
                      if groupes^^[i] <> '' then
                        begin
                          groupeExistant := groupes^^[i];
                          posEgal := Pos('=',groupeExistant);
                          groupeExistant := TPCopy(groupeExistant,1,posEgal-1);
                          EnleveEspacesDeDroiteSurPlace(groupeExistant);

                          if (groupeExistant = nomDuGroupe) and not(groupeUtilise) then
                            begin
                              groupeUtilise := true;
                              if groupeVide
                                then
                                  begin
                                    s := ReadStringFromRessource(TextesGroupesID,4);  {"supprimer groupe ?"}
                                    s := ParamStr(s,nomDuGroupe,'','','');


                                    if (AlerteDoubleOuiNon(s,'') = OuiBouton) then // OUI ?
                                      begin
                                        groupes^^[i] := '';
                                        ListeDesGroupesModifiee := true;
                                        DoListerLesGroupes;
                                      end;
                                  end
                                else
                                  begin
                                    if ConfirmationRemplacerGroupe then
                                      begin
                                        groupes^^[i] := newgroupe;
                                        ListeDesGroupesModifiee := true;
                                        DoListerLesGroupes;
                                      end;
                                  end;
                            end;
                        end;
                    if not(groupeUtilise) then
                      for i := 1 to nbMaxGroupes do
                        if (groupes^^[i] = '') and not(groupeUtilise) then
                          begin
                            groupes^^[i] := newGroupe;
                            ListeDesGroupesModifiee := true;
                            DoListerLesGroupes;
                            groupeUtilise := true;
                          end;
                     if not(groupeUtilise) then
                       begin
                         s := ReadStringFromRessource(TextesGroupesID,6);
                         AlerteSimple(s);
                       end
                  end;
            end;
      end;
 if ListeDesGroupesModifiee then
   begin
     CreeFichierGroupes;
     ListeDesGroupesModifiee := false;
   end;
end;











function ScoreFinalEnChaine(scorePourNoir : SInt16) : String255;
var s1,s2 : String255;
   aux : SInt16;
begin
  aux := scorePourNoir;
  if odd(aux) then
    if aux > 0 then inc(aux) else
    if aux < 0 then dec(aux);
  s1 := IntToStr(32+(aux div 2));
  s2 := IntToStr(32-(aux div 2));
  ScoreFinalEnChaine := s1+CharToString('-')+s2;
end;


procedure ConstruitTitrePartie(const nomNoir,nomBlanc : String255; enleverLesPrenoms : boolean; scoreNoir : SInt64; var titre : String255);
var s,s2 : String255;
    nom : String255;
begin
  if enleverLesPrenoms and (nomNoir[LENGTH_OF_STRING(nomNoir)] <> '.')
    then EnlevePrenom(nomNoir,nom)
    else nom := nomNoir;

  if (Pos('Tastet M.',nom) = 1) then nom := 'Tastet';
  if (Pos('TASTET M.',nom) = 1) then nom := 'TASTET';
  if (Pos('tastet m.',nom) = 1) then nom := 'tastet';
  if (Pos('tastet M.',nom) = 1) then nom := 'tastet';

  s := nom;

  s2 := IntToStr(scoreNoir);
  if nom[LENGTH_OF_STRING(nom)] = ' '
    then s := s + s2+CharToString('-')
    else s := s + CharToString(' ')+s2+CharToString('-');
  s2 := IntToStr(64-scoreNoir);
  s := s + s2+CharToString(' ');

  if enleverLesPrenoms and (nomBlanc[LENGTH_OF_STRING(nomBlanc)] <> '.')
    then EnlevePrenom(nomBlanc,nom)
    else nom := nomBlanc;
  if nom[LENGTH_OF_STRING(nom)] = ' ' then nom := TPCopy(nom,1,pred(LENGTH_OF_STRING(nom)));

  if (Pos('Tastet M.',nom) = 1) then nom := 'Tastet';
  if (Pos('TASTET M.',nom) = 1) then nom := 'TASTET';
  if (Pos('tastet m.',nom) = 1) then nom := 'tastet';
  if (Pos('tastet M.',nom) = 1) then nom := 'tastet';

  s := s + nom;
  titre := s;

end;


function EnleveAnneeADroiteDansChaine(var s : String255; var firstYear,lastYear : SInt16) : boolean;
var k,annee : SInt16;
    s1 : String255;
    aux : SInt64;
    trouve,diminish : boolean;
begin
	trouve := false;
	annee := 0;
	firstYear := 10000;
	lastYear := -10000;

	repeat
	  diminish := false;
		k := LENGTH_OF_STRING(s);
		if (k >= 5) and
		   IsDigit(s[k]) and
			 IsDigit(s[k-1]) and
			 IsDigit(s[k-2]) and
			 IsDigit(s[k-3]) and
			 ((s[k-4] = ' ') or (s[k-4] = '-')) then
			    begin
			      trouve := true;
			      diminish := true;
			      ChaineToLongint(TPCopy(s,k-3,4),aux);
			      annee := aux;
			      if annee < firstYear then firstYear := annee;
			      if annee > lastYear then lastYear := annee;
			      s1 := TPCopy(s,1,k-5);
			      s1 := EnleveEspacesDeDroite(s1);
			      s := s1;
			    end;
		k := LENGTH_OF_STRING(s);
		if (k >= 3) and
		   IsDigit(s[k]) and
			 IsDigit(s[k-1]) and
			 ((s[k-2] = ' ') or (s[k-2] = '-')) then
			    begin
			      trouve := true;
			      diminish := true;
			      if s[k-1] >= '5'     {1950}
			        then ChaineToLongint('19'+s[k-1]+s[k],aux)
			        else ChaineToLongint('20'+s[k-1]+s[k],aux);
			      annee := aux;
			      if annee < firstYear then firstYear := annee;
			      if annee > lastYear then lastYear := annee;
			      s1 := TPCopy(s,1,k-3);
			      s1 := EnleveEspacesDeDroite(s1);
			      s := s1;
			    end;
		 k := LENGTH_OF_STRING(s);
		 if (k = 4) and
		   IsDigit(s[k]) and
			 IsDigit(s[k-1]) and
			 IsDigit(s[k-2]) and
			 IsDigit(s[k-3]) then
			    begin
			      trouve := true;
			      diminish := true;
			      ChaineToLongint(s,aux);
			      annee := aux;
			      if annee < firstYear then firstYear := annee;
			      if annee > lastYear then lastYear := annee;
			      s := '';
			    end;
	  k := LENGTH_OF_STRING(s);
		if (k = 2) and
		   IsDigit(s[k]) and
			 IsDigit(s[k-1]) then
			    begin
			      trouve := true;
			      diminish := true;
			      if s[k-1] >= '5'     {1950}
			        then ChaineToLongint('19'+s[k-1]+s[k],aux)
			        else ChaineToLongint('20'+s[k-1]+s[k],aux);
			      annee := aux;
			      if annee < firstYear then firstYear := annee;
			      if annee > lastYear then lastYear := annee;
			      s := '';
			    end;
	until not(diminish);
  if trouve and (firstYear < 1950) then firstYear := 1950;
  if trouve and (firstYear > 2049) then firstYear := 2049;
  if trouve and (lastYear < 1950) then lastYear := 1950;
  if trouve and (lastYear > 2049) then lastYear := 2049;
	EnleveAnneeADroiteDansChaine := trouve;
end;

procedure EchangeSurnoms(var nom : String255);
var s : String255;
begin
  s := nom;
  s := MyUpperString(s,false);
  if s = 'PROF' then nom := 'tastet marc' else
  if s = 'TATA' then nom := 'tamenori hideshi' else
  if s = 'BDLB' then nom := 'de la boisserie bru' else
  if s = 'VDLB' then nom := 'de la boisserie vin' else
  if s = 'DIP' then nom := 'piau didier' else
  if s = 'DOP' then nom := 'penloup dominique' else
  if s = 'OO7' then nom := '007 (buro)' else  {on met des vrais z�ros}
  if s = 'O07' then nom := '007 (buro)' else
  if s = '0O7' then nom := '007 (buro)' else
  if s = 'oo7' then nom := '007 (buro)' else
  if s = 'Oo7' then nom := '007 (buro)';
end;

procedure EpureNomJoueur(var unNomDeJoueur : String255);
var c : char;
    longueur,i : SInt16;
    nomAux : String255;
begin
  longueur := LENGTH_OF_STRING(unNomDeJoueur);
  if longueur > 19 then longueur := 19;
  nomAux := '';
  for i := 1 to longueur do
    begin
      c := unNomDeJoueur[i];
      if (c = '�') or (c = '�') then c := 'e';
      if (c >= 'A') and (c <= 'Z') then c := chr(ord(c)+32);
      nomAux := nomAux+c;
    end;
  EchangeSurnoms(nomAux);
  unNomDeJoueur := nomAux;
end;

procedure TraiteJoueurEnMinuscules(nomBrut : String255; var nomJoueur : String255);
var c : char;
    longueur,i : SInt64;
begin
  longueur := LENGTH_OF_STRING(nomBrut);
  if longueur > 19 then longueur := 19;
  nomJoueur := '';
  for i := 1 to longueur do
    begin
      c := nomBrut[i];
      if (c = '�') or (c = '�') then c := 'e';
      if (c >= 'A') and (c <= 'Z') then c := chr(ord(c)+32);
      nomJoueur := Concat(nomJoueur,c);
    end;
  EchangeSurnoms(nomJoueur);
end;




function StringMayHaveUTF8Accents(const s : String255) : boolean;
var k : SInt64;
begin
  for k := 1 to LENGTH_OF_STRING(s) do
    if caracterIsUsedForUTF8[ord(s[k])] then
      begin
        StringMayHaveUTF8Accents := true;
        exit;
      end;
  StringMayHaveUTF8Accents := false;
end;


function UTF8ToAscii(const s : String255) : String255;
var k, compteur, len : SInt64;
    aux : String255;
begin
  if not(StringMayHaveUTF8Accents(s))
    then
      UTF8ToAscii := s
    else
      with gUnicode do
        begin
          aux := s;
          for k := 1 to cardinal do
            begin
              compteur := 0;
              repeat
                len := LENGTH_OF_STRING(aux);
                aux := ReplaceStringOnce(table[k].theAccent^ , table[k].theRemplacement^, aux);
                inc(compteur);
              until ((LENGTH_OF_STRING(aux) = len) or (compteur >= 10));
            end;

          UTF8ToAscii := aux;
        end;
end;


procedure InspectUnicodeAccent(const accent, remplacement : String255);
var k : SInt64;
begin
  Discard(remplacement);
  for k := 1 to LENGTH_OF_STRING(accent) do
    begin
      caracterIsUsedForUTF8[ord(accent[k])] := true;
    end;
end;



procedure ReadLineWithUnicodeAccents(var ligne : LongString; var theFic : FichierTEXT; var compteur : SInt64);
var s, remplacement : String255;
begin
  Discard(theFic);

  if (ligne.debutLigne <> '') then
    begin
      Parser(ligne.debutLigne, s, remplacement);
      InspectUnicodeAccent(s, remplacement);

      // WritelnDansRapport('  AddUnicodeRemplacement( ''' + s + ''' , ''' + remplacement + ''' );');
      // WritelnDansRapport( UTF8ToAscii(s) + '  -->  ' + remplacement);

      inc(compteur);
    end;
end;




procedure ReadUnicodeAccentsFromDisc;
const kUnicodeAccentsFileName = 'accents-utf8.txt';
var fic : FichierTEXT;
    err : OSErr;
    k, compteur : SInt64;
begin
  for k := 0 to 255 do
    caracterIsUsedForUTF8[k] := false;
  compteur := 0;

  err := FichierTexteDeCassioExiste(kUnicodeAccentsFileName,fic);
  if err = NoErr then
    ForEachLineInFileDo(fic.theFSSpec, ReadLineWithUnicodeAccents, compteur);

  // WritelnNumDansRapport('nombre de caract�res Unicode = ',compteur);
end;



procedure AddUnicodeRemplacement(const accent, remplacement : String255);
begin
  with gUnicode do
    begin
      if (cardinal < kTailleUnicodeTable) then
        begin
          InspectUnicodeAccent(accent, remplacement);

          inc(cardinal);

          with table[cardinal] do
            begin
              theAccent  := String255Ptr(AllocateMemoryPtr(sizeof(String255)));
              theRemplacement := String255Ptr(AllocateMemoryPtr(sizeof(String255)));

              if theAccent <> NIL       then theAccent^       := accent;
              if theRemplacement <> NIL then theRemplacement^ := remplacement;

              if (theAccent = NIL) or (theRemplacement = NIL)
                 then dec(cardinal);
            end;

        end;
    end;
end;

procedure DisposeUnicodeTable;
var k : SInt64;
begin
  with gUnicode do
    begin
      cardinal := 0;
      for k := 0 to kTailleUnicodeTable do
        begin
          if table[k].theAccent <> NIL then
	          begin
	            DisposeMemoryPtr(Ptr(table[k].theAccent));
	            table[k].theAccent := NIL;
	          end;
	        if table[k].theRemplacement <> NIL then
	          begin
	            DisposeMemoryPtr(Ptr(table[k].theRemplacement));
	            table[k].theRemplacement := NIL;
	          end;
        end;
    end;
end;




procedure InitUnicodeTable;
var k : SInt64;
begin
  for k := 0 to 255 do
    caracterIsUsedForUTF8[k] := false;

  with gUnicode do
    begin
      cardinal := 0;
      for k := 0 to kTailleUnicodeTable do
        begin
          table[k].theAccent       := NIL;
          table[k].theRemplacement := NIL;
        end;
    end;

  // note : pour reg�n�rer cette table, utiliser la
  // proc�dure "ReadUnicodeAccentsFromDisc" ci-dessus.

  AddUnicodeRemplacement( '﻿á' , 'a' );
  AddUnicodeRemplacement( 'Á' , 'A' );
  AddUnicodeRemplacement( 'à' , 'a' );
  AddUnicodeRemplacement( 'À' , 'A' );
  AddUnicodeRemplacement( 'ă' , 'a' );
  AddUnicodeRemplacement( 'Ă' , 'A' );
  AddUnicodeRemplacement( 'â' , 'a' );
  AddUnicodeRemplacement( 'Â' , 'A' );
  AddUnicodeRemplacement( 'ä' , 'a' );
  AddUnicodeRemplacement( 'ä' , 'a' );
  AddUnicodeRemplacement( 'Ä' , 'A' );
  AddUnicodeRemplacement( 'Ä' , 'A' );
  AddUnicodeRemplacement( 'ã' , 'a' );
  AddUnicodeRemplacement( 'Ã' , 'A' );
  AddUnicodeRemplacement( 'ą' , 'a' );
  AddUnicodeRemplacement( 'Ą' , 'A' );
  AddUnicodeRemplacement( 'ā' , 'a' );
  AddUnicodeRemplacement( 'Ā' , 'A' );
  AddUnicodeRemplacement( 'å' , 'a' );
  AddUnicodeRemplacement( 'Å' , 'A' );
  AddUnicodeRemplacement( 'æ' , 'ae' );
  AddUnicodeRemplacement( 'Æ' , 'AE' );
  AddUnicodeRemplacement( 'Ǣ' , 'AE' );
  AddUnicodeRemplacement( 'ǣ' , 'oe' );
  AddUnicodeRemplacement( 'ḃ' , 'b' );
  AddUnicodeRemplacement( 'ć' , 'c' );
  AddUnicodeRemplacement( 'Ć' , 'C' );
  AddUnicodeRemplacement( 'č' , 'c' );
  AddUnicodeRemplacement( 'Č' , 'C' );
  AddUnicodeRemplacement( 'ċ' , 'c' );
  AddUnicodeRemplacement( 'Ċ' , 'C' );
  AddUnicodeRemplacement( 'ç' , 'c' );
  AddUnicodeRemplacement( 'Ç' , 'C' );
  AddUnicodeRemplacement( 'ď' , 'd' );
  AddUnicodeRemplacement( 'Ď' , 'D' );
  AddUnicodeRemplacement( 'ḋ' , 'd' );
  AddUnicodeRemplacement( 'ð' , 'th' );
  AddUnicodeRemplacement( 'Ð' , 'TH' );
  AddUnicodeRemplacement( 'é' , 'e' );
  AddUnicodeRemplacement( 'É' , 'E' );
  AddUnicodeRemplacement( 'è' , 'e' );
  AddUnicodeRemplacement( 'È' , 'E' );
  AddUnicodeRemplacement( 'ĕ' , 'e' );
  AddUnicodeRemplacement( 'Ĕ' , 'E' );
  AddUnicodeRemplacement( 'ê' , 'e' );
  AddUnicodeRemplacement( 'Ê' , 'E' );
  AddUnicodeRemplacement( 'ě' , 'e' );
  AddUnicodeRemplacement( 'Ě' , 'E' );
  AddUnicodeRemplacement( 'ë' , 'e' );
  AddUnicodeRemplacement( 'Ë' , 'E' );
  AddUnicodeRemplacement( 'ę' , 'e' );
  AddUnicodeRemplacement( 'Ę' , 'E' );
  AddUnicodeRemplacement( 'ē' , 'e' );
  AddUnicodeRemplacement( 'Ē' , 'E' );
  AddUnicodeRemplacement( 'ḟ' , 'f' );
  AddUnicodeRemplacement( 'ğ' , 'g' );
  AddUnicodeRemplacement( 'Ğ' , 'G' );
  AddUnicodeRemplacement( 'ġ' , 'g' );
  AddUnicodeRemplacement( 'Ġ' , 'G' );
  AddUnicodeRemplacement( 'í' , 'i' );
  AddUnicodeRemplacement( 'Í' , 'I' );
  AddUnicodeRemplacement( 'ì' , 'i' );
  AddUnicodeRemplacement( 'Ì' , 'I' );
  AddUnicodeRemplacement( 'ĭ' , 'i' );
  AddUnicodeRemplacement( 'Ĭ' , 'I' );
  AddUnicodeRemplacement( 'î' , 'i' );
  AddUnicodeRemplacement( 'Î' , 'I' );
  AddUnicodeRemplacement( 'ï' , 'i' );
  AddUnicodeRemplacement( 'Ï' , 'I' );
  AddUnicodeRemplacement( 'İ' , 'I' );
  AddUnicodeRemplacement( 'ī' , 'i' );
  AddUnicodeRemplacement( 'Ī' , 'I' );
  AddUnicodeRemplacement( 'ı' , 'i' );
  AddUnicodeRemplacement( 'ĺ' , 'l' );
  AddUnicodeRemplacement( 'Ĺ' , 'L' );
  AddUnicodeRemplacement( 'ľ' , 'l' );
  AddUnicodeRemplacement( 'Ľ' , 'L' );
  AddUnicodeRemplacement( 'ł' , 'l' );
  AddUnicodeRemplacement( 'Ł' , 'L' );
  AddUnicodeRemplacement( 'ṁ' , 'm' );
  AddUnicodeRemplacement( 'ń' , 'n' );
  AddUnicodeRemplacement( 'Ń' , 'N' );
  AddUnicodeRemplacement( 'ň' , 'n' );
  AddUnicodeRemplacement( 'Ň' , 'N' );
  AddUnicodeRemplacement( 'ñ' , 'n' );
  AddUnicodeRemplacement( 'Ñ' , 'N' );
  AddUnicodeRemplacement( 'ṅ' , 'n' );
  AddUnicodeRemplacement( 'ó' , 'o' );
  AddUnicodeRemplacement( 'Ó' , 'O' );
  AddUnicodeRemplacement( 'ò' , 'o' );
  AddUnicodeRemplacement( 'Ò' , 'O' );
  AddUnicodeRemplacement( 'ŏ' , 'o' );
  AddUnicodeRemplacement( 'Ŏ' , 'O' );
  AddUnicodeRemplacement( 'ô' , 'o' );
  AddUnicodeRemplacement( 'Ô' , 'O' );
  AddUnicodeRemplacement( 'ö' , 'o' );
  AddUnicodeRemplacement( 'Ö' , 'O' );
  AddUnicodeRemplacement( 'õ' , 'o' );
  AddUnicodeRemplacement( 'Õ' , 'O' );
  AddUnicodeRemplacement( 'ø' , 'o' );
  AddUnicodeRemplacement( 'Ø' , 'O' );
  AddUnicodeRemplacement( 'ō' , 'o' );
  AddUnicodeRemplacement( 'Ō' , 'O' );
  AddUnicodeRemplacement( 'œ' , 'oe' );
  AddUnicodeRemplacement( 'Œ' , 'OE' );
  AddUnicodeRemplacement( 'ṗ' , 'p' );
  AddUnicodeRemplacement( 'ŕ' , 'r' );
  AddUnicodeRemplacement( 'Ŕ' , 'R' );
  AddUnicodeRemplacement( 'ř' , 'r' );
  AddUnicodeRemplacement( 'Ř' , 'R' );
  AddUnicodeRemplacement( 'ṙ' , 'r' );
  AddUnicodeRemplacement( 'ś' , 's' );
  AddUnicodeRemplacement( 'Ś' , 'S' );
  AddUnicodeRemplacement( 'š' , 's' );
  AddUnicodeRemplacement( 'š' , 's' );
  AddUnicodeRemplacement( 'Š' , 'S' );
  AddUnicodeRemplacement( 'Š' , 'S' );
  AddUnicodeRemplacement( 'ṡ' , 's' );
  AddUnicodeRemplacement( 'ş' , 's' );
  AddUnicodeRemplacement( 'Ş' , 'S' );
  AddUnicodeRemplacement( 'ß' , 'ss' );
  AddUnicodeRemplacement( 'ť' , 't' );
  AddUnicodeRemplacement( 'Ť' , 'T' );
  AddUnicodeRemplacement( 'ṫ' , 't' );
  AddUnicodeRemplacement( 'ú' , 'u' );
  AddUnicodeRemplacement( 'Ú' , 'U' );
  AddUnicodeRemplacement( 'ù' , 'u' );
  AddUnicodeRemplacement( 'Ù' , 'U' );
  AddUnicodeRemplacement( 'ŭ' , 'u' );
  AddUnicodeRemplacement( 'Ŭ' , 'U' );
  AddUnicodeRemplacement( 'û' , 'u' );
  AddUnicodeRemplacement( 'Û' , 'U' );
  AddUnicodeRemplacement( 'ů' , 'u' );
  AddUnicodeRemplacement( 'Ů' , 'U' );
  AddUnicodeRemplacement( 'ü' , 'u' );
  AddUnicodeRemplacement( 'Ü' , 'U' );
  AddUnicodeRemplacement( 'ū' , 'u' );
  AddUnicodeRemplacement( 'Ū' , 'U' );
  AddUnicodeRemplacement( 'ý' , 'y' );
  AddUnicodeRemplacement( 'Ý' , 'Y' );
  AddUnicodeRemplacement( 'ÿ' , 'y' );
  AddUnicodeRemplacement( 'Ÿ' , 'Y' );
  AddUnicodeRemplacement( 'ȳ' , 'y' );
  AddUnicodeRemplacement( 'Ȳ' , 'Y' );
  AddUnicodeRemplacement( 'ź' , 'z' );
  AddUnicodeRemplacement( 'Ź' , 'Z' );
  AddUnicodeRemplacement( 'ž' , 'z' );
  AddUnicodeRemplacement( 'Ž' , 'Z' );
  AddUnicodeRemplacement( 'ż' , 'z' );
  AddUnicodeRemplacement( 'Ż' , 'Z' );
  AddUnicodeRemplacement( 'þ' , 'th' );
  AddUnicodeRemplacement( 'Þ' , 'Th' );

end;



procedure TraiteTournoiEnMinuscules(nom : String255; var nomTournoi : String255);
var i,longueur : SInt64;
    c : char;
begin
  longueur := LENGTH_OF_STRING(nom);
  if longueur > 29 then longueur := 29;
  nomTournoi := '';
  for i := 1 to longueur do
    begin
      c := nom[i];
      if (c >= 'A') and (c <= 'Z') then c := chr(ord(c)+32);
      nomTournoi := Concat(nomTournoi,c);
    end;

  nomTournoi := MyLowerString(nomTournoi,false);
end;

procedure TournoiEnMinuscules(var nomBrut : String255);
begin
  nomBrut := MyLowerString(nomBrut,false);
end;







const yCurseurPremierParametre   = 90;
      xminSlider                 = 200;
      xmaxSlider                 = 400;
      kInterligneEntreDeuxCoeffs = 22;
      kNombreDeCoefficients      = 4;



procedure CalculEtAfficheCoeff(dp : DialogPtr; mouseX,item,hauteurExacte : SInt16);
const ln4 = 1.386294;
var c : double;
begin
  c := exp(ln4*(2*(mouseX-xmaxSlider)/(xmaxSlider-xminSlider)+1));
  if c < 0.25 then c := 0.25;
  if c > 4.0 then c := 4.0;
  DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,hauteurExacte,c);
  case item of
      1: Coefffrontiere := c;
      2: Coeffminimisation := c;
      3: CoeffMobiliteUnidirectionnelle := c;
      4: CoeffPenalite := c;

      {2: CoeffEquivalence := c;
      3: Coeffcentre := c;
      4: Coeffgrandcentre := c;
      5: Coeffbetonnage := c;}
      {7: CoeffpriseCoin := c;
      8: CoeffdefenseCoin := c;
      9: CoeffValeurCoin := c;
      10: CoeffValeurCaseX := c;}

    end;
end;

function ClicSurCurseurCoeff(mouseLoc : Point; var hauteurExacte,nroCoeff : SInt16) : boolean;
const ln4 = 1.386294;
var aux,haut : SInt16;
    c : double;
    test : boolean;
begin
   nroCoeff := 1 + (mouseLoc.v - yCurseurPremierParametre + (kInterligneEntreDeuxCoeffs div 2)) div kInterligneEntreDeuxCoeffs;
   hauteurExacte := yCurseurPremierParametre+(nroCoeff-1)*kInterligneEntreDeuxCoeffs;
   case nroCoeff of
      1: c := Coefffrontiere;
      2: c := Coeffminimisation;
      3: c := CoeffMobiliteUnidirectionnelle;
      4: c := CoeffPenalite;

      {
      2: c := CoeffEquivalence;
      3: c := Coeffcentre;
      4: c := Coeffgrandcentre;
      5: c := Coeffbetonnage;
      7: c := CoeffpriseCoin;
      8: c := CoeffdefenseCoin;
      9: c := CoeffValeurCoin;
      10: c := CoeffValeurCaseX;
      }

    end;
    aux := (xminSlider+xmaxSlider) div 2 +Trunc((xmaxSlider-xminSlider)*ln(c)/2/ln4);

    haut := (kInterligneEntreDeuxCoeffs div 2) - 2;
    test := (aux- haut <= mouseLoc.h) and (mouseLoc.h <= aux + haut);
    ClicSurCurseurCoeff := test;
    if not(test) then nroCoeff := 0;
end;



function FiltreCoeffDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
var mouseLoc : Point;
    hauteurExacte,MouseX : SInt16;
    Ecriturerect,Dessinerect,sourisrect : rect;
    tirecurseur,bouge : boolean;
    oldPort : grafPtr;
begin
  FiltreCoeffDialog := false;
  if not(EvenementDuDialogue(dlog,evt))
    then FiltreCoeffDialog := MyFiltreClassique(dlog,evt,item)
    else
      case evt.what of
        mouseDown:
          begin
            IncrementeCompteurDeMouseEvents;
            GetPort(oldPort);
            SetPortByDialog(dlog);

            mouseLoc := evt.where;
            GlobalToLocal(mouseLoc);
            if PtInRect(mouseLoc,EchelleCoeffsRect) then
              begin
                if ClicSurCurseurCoeff(mouseLoc,hauteurExacte,item) then
                begin
                  SetRect(sourisrect,EchelleCoeffsRect.left-850,hauteurExacte-857,EchelleCoeffsRect.right+850,hauteurExacte+857);
                  SetRect(Dessinerect,EchelleCoeffsRect.left-5,hauteurExacte-(kInterligneEntreDeuxCoeffs div 2),EchelleCoeffsRect.right+60,hauteurExacte+(kInterligneEntreDeuxCoeffs div 2));
                  SetRect(Ecriturerect,0,hauteurExacte-7,EchelleCoeffsRect.left-5,hauteurExacte+7);
                  tirecurseur := true;
                  mouseX := 0;
                  while Button and tirecurseur do
                    begin
                      GetMouse(mouseLoc);
                      tirecurseur := PtInRect(mouseLoc,sourisrect);
                      bouge := (mouseLoc.h <> mouseX) and
                             (((mouseLoc.h >= EchelleCoeffsRect.left ) and (mouseLoc.h <= EchelleCoeffsRect.right)) or
                              ((mouseLoc.h <= EchelleCoeffsRect.left ) and (mouseX >= EchelleCoeffsRect.left)) or
                              ((mouseLoc.h >= EchelleCoeffsRect.right) and (mouseX <= EchelleCoeffsRect.right)));
                      if bouge and tirecurseur then
                        begin
                          MyEraseRect(Dessinerect);
                          MyEraseRectWithColor(DessineRect,OrangeCmd,blackPattern,'');
                          CalculEtAfficheCoeff(dlog,mouseLoc.h,item,hauteurExacte);
                          Superviseur(nbreCoup);
                          MyEraseRect(Ecriturerect);
                          MyEraseRectWithColor(Ecriturerect,OrangeCmd,blackPattern,'');
                          EcritParametres(dlog,item);
                          ShareTimeWithOtherProcesses(2);
                        end;
                      MouseX := mouseLoc.h;
                    end;
                  FiltreCoeffDialog := true;
                  item := 0;
                end;
              end
             else
              FiltreCoeffDialog := MyFiltreClassique(dlog,evt,item);

            SetPort(oldPort);
          end;
       updateEvt :
         begin
           item := VirtualUpdateItemInDialog;
           FiltreCoeffDialog := true;
         end;
       otherwise FiltreCoeffDialog := MyFiltreClassique(dlog,evt,item)
     end;  {case}
end;


procedure DessineEchellesCoeffs(dp : DialogPtr);
var y : SInt64;
begin
    y := yCurseurPremierParametre;
    DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,y,Coefffrontiere);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,y,Coeffminimisation);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,y,CoeffMobiliteUnidirectionnelle);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(dp,xminSlider,xmaxSlider,y,CoeffPenalite);

    {
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffEquivalence);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,Coeffcentre);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,Coeffgrandcentre);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,Coeffbetonnage);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffpriseCoin);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffdefenseCoin);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffValeurCoin);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,CoeffValeurCaseX);
    y := y+kInterligneEntreDeuxCoeffs;
    DessineEchelleEtCurseur(xminSlider,xmaxSlider,y,Coeffinfluence);
    }
    SetRect(EchelleCoeffsRect,xminSlider-8,yCurseurPremierParametre - (kInterligneEntreDeuxCoeffs div 2),xmaxSlider+8,y+kInterligneEntreDeuxCoeffs);
end;



procedure DessineBord(xdeb,y : SInt64; indexBord : SInt64);
  const taille = 12;
  var i,x,dx : SInt64;
      unRect : rect;
  begin
    PenSize(1,1);
    dx := dir[indexBord];
    x := casebord[indexBord]-dx;
    if (indexBord = 4) or (indexBord = 2) then
      begin
        x := x+7*dx;
        dx := -dx;
      end;
    for i := 1 to 8 do
     BEGIN
       SetRect(unRect,xdeb+(i-1)*taille,y-taille-1,xdeb+i*taille+1,y);
       FrameRect(unRect);
       if GetCouleurOfSquareDansJeuCourant(x) = pionBlanc then
         begin
           InsetRect(unRect,2,2);
           FrameOval(unRect);
         end;
       if GetCouleurOfSquareDansJeuCourant(x) = pionNoir then
         begin
           InsetRect(unRect,2,2);
           FillOval(unRect,blackPattern);
         end;
       x := x+dx;
      END;
  end;

procedure DessineEchelleEtCurseur(dp : DialogPtr; xmin,xmax,y : SInt64; coeff : double);
const ln4 = 1.386294;
var s : String255;
    aux : SInt64;
    mil : SInt64;
    err : OSStatus;
    sliderRect : rect;
    theSlider : ControlHandle;
begin
  mil := (xmin+xmax) div 2;
  aux := mil + Trunc((xmax-xmin)*ln(coeff)/2/ln4);


  if true
    then
      begin
        if not(gIsRunningUnderMacOSX)
          then sliderRect := MakeRect(xmin,y-8,xmax,y+9)
          else sliderRect := MakeRect(xmin,y-5,xmax,y+5);

        err := CreateSliderControl(GetDialogWindow(dp),sliderRect,aux,xmin,xmax,
                                   kControlSliderDoesNotPoint, 0, false, NIL, theSlider);

        if (err = NoErr) and (theSlider <> NIL) then
          begin
            Draw1Control(theSlider);
            ShowControl(theSlider);
            if SetControlVisibility(theSlider,false,false) = NoErr then DoNothing;
            SizeControl(theSlider,0,0);
            DisposeControl(theSlider);
          end;

      end
    else
      begin
        PenSize(1,1);
			  Moveto(xmin,y);
			  Lineto(xmax,y);
			  Moveto(xmin,y-2);
			  Lineto(xmin,y+2);
			  Moveto(xmax,y-2);
			  Lineto(xmax,y+2);
			  Moveto(mil,y-2);
			  Lineto(mil,y+2);
			  Moveto((xmin+mil) div 2,y-2);
			  Lineto((xmin+mil) div 2,y+2);
			  Moveto((xmax+mil) div 2,y-2);
			  Lineto((xmax+mil) div 2,y+2);

			  PenSize(2,2);
			  Moveto(aux,y-4);
			  Lineto(aux,y+4);
			end;


  s := PourcentageReelEnString(coeff);
  if s = '199%' then s := '200%';
  Moveto(xmax+10,y+3);
  TextFont(gCassioApplicationFont);
  TextSize(gCassioSmallFontSize);
  MyDrawString(s);
end;

procedure EcritParametre(dp : DialogPtr; s : String255; parametre : SInt64; y : SInt64);
var oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByDialog(dp);

  TextFont(systemFont);
  TextSize(0);
  Moveto(10,y);
  MyDrawString(s);

  if not(utilisationNouvelleEval) then
    begin
      s := IntToStr(parametre);
      Moveto(160,y);
      MyDrawString(s);
    end;

  SetPort(oldPort);
end;

procedure EcritParametres(dp : DialogPtr; quelParametre : SInt16);
var y : SInt64;
    s : String255;
    oldPort : grafPtr;
begin
   GetPort(oldPort);
   SetPortByDialog(dp);

   TextFont(systemFont);
   TextSize(0);

   s := ReadStringFromRessource(TextesCoeffsID,1);
   with QDGetPortBound do
     Moveto((left+right-MyStringWidth(s)) div 2,35);
   if (quelParametre <= 0) then MyDrawString(s);

   y := yCurseurPremierParametre + 4;
   s := ReadStringFromRessource(TextesCoeffsID,2);
   if (quelParametre = 1) or (quelParametre <= 0) then
     EcritParametre(dp,s,-valFrontiere,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,7);
   if (quelParametre = 2) or (quelParametre <= 0) then
     EcritParametre(dp,s,-valMinimisationAvantCoins,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,19);
   if (quelParametre = 3) or (quelParametre <= 0) then
     EcritParametre(dp,s,4*valMobiliteUnidirectionnelle,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,12);
   if (quelParametre = 4) or (quelParametre <= 0) then
     EcritParametre(dp,s,-penalitePourTraitAff,y);

   {
   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,3);
   if (quelParametre = 2) or (quelParametre <= 0) then
     EcritParametre(dp,s,-valEquivalentFrontiere,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,4);
   if (quelParametre = 3) or (quelParametre <= 0) then
     EcritParametre(dp,s,valPionCentre,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,5);
   if (quelParametre = 4) or (quelParametre <= 0) then
     EcritParametre(dp,s,valPionPetitCentre,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,6);
   if (quelParametre = 5) or (quelParametre <= 0) then
     EcritParametre(dp,s,valBetonnage,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,8);
   if (quelParametre = 7) or (quelParametre <= 0) then
     EcritParametre(dp,s,valPriseCoin,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,9);
   if (quelParametre = 8) or (quelParametre <= 0) then
     EcritParametre(dp,s,-valDefenseCoin,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,10);
   if (quelParametre = 9) or (quelParametre <= 0) then
     EcritParametre(dp,s,valCoin,y);

   y := y+kInterligneEntreDeuxCoeffs;
   s := ReadStringFromRessource(TextesCoeffsID,11);
   if (quelParametre = 10) or (quelParametre <= 0) then
     EcritParametre(dp,s,-valCaseX,y);

  }

  SetPort(oldPort);

end;

procedure EcritEtDessineBords;
var y : SInt64;
    s : String255;
begin

   TextFont(systemFont);
   TextSize(0);

   y := yCurseurPremierParametre + kInterligneEntreDeuxCoeffs*kNombreDeCoefficients + 25;
   Moveto(10,y);
   s := ReadStringFromRessource(TextesCoeffsID,13);
   MyDrawString(s);
   WriteNumAt(ReadStringFromRessource(TextesCoeffsID,17)+' : ',valeurBord^[-frontiereCourante.AdressePattern[kAdresseBordNord]],260,y);
   WriteNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',valeurBord^[frontiereCourante.AdressePattern[kAdresseBordNord]],375,y);
   DessineBord(155,y+2,3);
   y := y+15;
   Moveto(10,y);
   s := ReadStringFromRessource(TextesCoeffsID,14);
   MyDrawString(s);
   WriteNumAt(ReadStringFromRessource(TextesCoeffsID,17)+' : ',valeurBord^[-frontiereCourante.AdressePattern[kAdresseBordOuest]],260,y);
   WriteNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',valeurBord^[frontiereCourante.AdressePattern[kAdresseBordOuest]],375,y);
   DessineBord(155,y+2,1);
   y := y+15;
   Moveto(10,y);
   s := ReadStringFromRessource(TextesCoeffsID,15);
   MyDrawString(s);
   WriteNumAt(ReadStringFromRessource(TextesCoeffsID,17)+' : ',valeurBord^[-frontiereCourante.AdressePattern[kAdresseBordEst]],260,y);
   WriteNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',valeurBord^[frontiereCourante.AdressePattern[kAdresseBordEst]],375,y);
   DessineBord(155,y+2,2);
   y := y+15;
   Moveto(10,y);
   s := ReadStringFromRessource(TextesCoeffsID,16);
   MyDrawString(s);
   WriteNumAt(ReadStringFromRessource(TextesCoeffsID,17)+' : ',valeurBord^[-frontiereCourante.AdressePattern[kAdresseBordSud]],260,y);
   WriteNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',valeurBord^[frontiereCourante.AdressePattern[kAdresseBordSud]],375,y);
   DessineBord(155,y+2,4);

end;

const TablesPositionnellesBox = 4;

procedure EcritValeursTablesPositionnelles(dp : DialogPtr);
var y : SInt64;
    unRect : rect;
    jeu : plateauOthello;
begin

  GetDialogItemRect(dp,TablesPositionnellesBox,unRect);
  y := unRect.bottom-4;

  TextFont(systemFont);
  TextSize(0);

  jeu := JeuCourant;

  WriteNumAt(ReadStringFromRessource(TextesCoeffsID,20)+' : ',(4+((nbreDePions[pionBlanc]+nbreDePions[pionNoir]) div 4))*ValeurBlocsDeCoinPourNoir(jeu),220,y);
  WriteNumAt(ReadStringFromRessource(TextesCoeffsID,18)+' : ',(4+((nbreDePions[pionBlanc]+nbreDePions[pionNoir]) div 4))*ValeurBlocsDeCoinPourBlanc(jeu),375,y);
end;

procedure EffaceValeursTablesPositionnelles(dp : DialogPtr);
var unRect : rect;
    y : SInt64;
begin
  GetDialogItemRect(dp,TablesPositionnellesBox,unRect);
  y := unRect.bottom-4;
  SetRect(unRect,220,y-15,1000,y+5);
  MyEraseRect(unRect);
  MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
end;



procedure DoInsererMarque;
var i : SInt64;
    peutMettreNouvelleMarque : boolean;
begin
  if (nbreCoup > 0) and not(gameOver) then
   if (marques[0] < 10) then
    begin
      peutMettreNouvelleMarque := true;
      for i := 1 to marques[0] do
        if marques[i] = nbreCoup then peutMettreNouvelleMarque := false;
      if peutMettreNouvelleMarque then
         begin
           marques[0] := marques[0]+1;
           marques[marques[0]] := nbreCoup;
         end;
    end;
end;


function PeutCompleterPartieAvecSelectionRapport(var partieAlpha : String255) : boolean;
var s,s1 : String255;
    longueur : SInt64;
    loc : SInt16;
begin
  PeutCompleterPartieAvecSelectionRapport := false;
  partieAlpha := '';

  if SelectionRapportNonVide then
    begin
      longueur := LongueurSelectionRapport;

      if (longueur < 2) or (longueur > 250)
        then exit;

      s := SelectionRapportEnString(longueur);
      EnleveEspacesDeDroiteSurPlace(s);
      EnleveEspacesDeGaucheSurPlace(s);

      if ScannerStringPourTrouverCoup(1,s,loc) > 0 then
        begin
          s1 := PartiePourPressePapier(true,false,nbreCoup);
		      if (LENGTH_OF_STRING(s1) + LENGTH_OF_STRING(s)) <= 255 then
		        begin
		          s := s1 + s;
		          if EstUnePartieOthello(s,true) then
		            begin
		              partieAlpha := s;
		              PeutCompleterPartieAvecSelectionRapport := true;
		            end;
		        end;
		    end;
    end;
end;




procedure FabriqueMeilleureSuiteInfos(premierCoup : SInt16;
                                   suiteJouee : t_suiteJouee;
                                   meilleureSuite : meilleureSuitePtr;
                                   coul : SInt16; plat : plateauOthello; nBla,nNoi : SInt64;
                                   message : SInt64);
var i,j,coup : SInt64;
    p : SInt64;
    eval : SInt64;
    aQui : SInt64;
    coupPossible : boolean;
    positionEtTrait : PositionEtTraitRec;
begin
  VideMeilleureSuiteInfos;
  with meilleureSuiteInfos do
    begin
       numeroCoup := nNoi+nBla-4;
       statut := NeSaitPas;
       couleur := -coul;

       SetCoupDansMeilleureSuite(-1, 44);
       if RefleSurTempsJoueur then
       begin
         coup := meilleurCoupHum;
         if (coup < 11) or (coup > 88) then coup := 44;
         if PossibleMove[coup] and (coup <> premierCoup) then
           SetCoupDansMeilleureSuite(-1, coup);
       end;

       SetCoupDansMeilleureSuite(0, premierCoup);

       i := kNbMaxNiveaux+1;
       repeat
         i := i-1;
       until (i < 0) or (suiteJouee[i] <> 0);
       for j := i downto 1 do
        begin
         coup := meilleureSuite^[i,j];
         if coup <> 0 then
           begin
             p := 1+(i-j);
             if (p >= 1) and (p <= kNbMaxNiveaux) then
               SetCoupDansMeilleureSuite(p, coup);
           end;
       end;

    if phaseDeLaPartie < phaseFinale
     then
       begin
         positionEtTrait := MakePositionEtTrait(plat,coul);
         if (GetTraitOfPosition(positionEtTrait) <> coul) and not(DoitPasserPlatSeulement(coul,plat)) then
           begin
             SysBeep(0);
             WritelnDansRapport('erreur 1 dans FabriqueMeilleureSuiteInfos (milieu de partie) : GetTraitOfPosition(positionEtTrait) <> coul !!');
           end;
         i := 0;
         repeat
           inc(i);
           coup := GetCoupDansMeilleureSuite(i);
           coupPossible := (coup <> 0) and UpdatePositionEtTrait(positionEtTrait,coup);
         until not(coupPossible) or (i >= kNbMaxNiveaux);
         for j := i to kNbMaxNiveaux do SetCoupDansMeilleureSuite(j, 0);
       end
     else
      if message = pasDeMessage
        then
          begin
            aQui := coul;
            i := kNbMaxNiveaux + 1;
            repeat
              i := i - 1;
            until (i < 0) or (suiteJouee[i] <> 0);
            for j := i downto 1 do
              begin
                coup := meilleureSuite^[i,j];
                if (coup <> 0) then
                  begin
                    coupPossible := ModifPlatFin(Coup,aQui,plat,nBla,nNoi);
                    if coupPossible
                      then
                        begin
                          aQui := -aQui;
                        end
                      else
                        coupPossible := ModifPlatFin(Coup,-aQui,plat,nBla,nNoi);
                  end;
              end;
            score.noir := nNoi;
            score.blanc := nBla;
            if InRange(numeroCoup,finDePartie,finDePartieOptimale) then
              begin
                eval := score.noir-score.blanc;
                if eval = 0 then statut := nulle;
                if eval > 0 then statut := victoireNoire;
                if eval < 0 then statut := victoireBlanche;
                if message = messageToutEstPerdant then statut := toutEstPerdant;
                if message = messageToutEstProbablementPerdant then statut := toutEstProbablementPerdant;
              end;
          end
        else
          begin
            if message = messageToutEstPerdant then statut := toutEstPerdant;
            if message = messageToutEstProbablementPerdant then statut := toutEstProbablementPerdant;
            if message = messageFaitNulle then statut := nulle;
            if message = messageEstGagnant then
              if couleur = pionNoir
                then statut := victoireNoire
                else statut := victoireBlanche;
            if message = messageEstPerdant then
              if couleur = pionNoir
                then statut := victoireBlanche
                else statut := victoireNoire;
          end;
   end;
end;



procedure SauvegardeLigneOptimale(coul : SInt64);
var i,coup : SInt64;
    ok : boolean;
    debugMeilleureSuite : boolean;
begin

  if debuggage.calculFinaleOptimaleParOptimalite then
    begin
      WritelnDansRapport('');
      WritelnNumDansRapport('Entr�e de SauvegardeLigneOptimale pour coul = ',coul);
    end;

  with meilleureSuiteInfos do
    if (phaseDeLaPartie >= phaseFinaleParfaite) then
      if (coul = couleurMacintosh) or not(finaleEnModeSolitaire) then
         begin
           for i := 0 to nbreCoup do
             begin
               coup := GetNiemeCoupPartieCourante(i);
               if coup <> partie^^[i].coupParfait then
                 begin
                   partie^^[i].coupParfait := coup;
                   partie^^[i].optimal := false;
                 end;
             end;
           for i := nbreCoup + 1 to numeroCoup - 1 do
             begin
               coup := GetNiemeCoupPartieCourante(i);
               if (coup <> coupInconnu) and not(partie^^[i].optimal) then
                 partie^^[i].coupParfait := coup;
             end;


           ok := (statut <> ReflAnnonceGagnant) and (statut <> ReflAnnonceParfait);

           if ok then
             begin

               coup := GetCoupDansMeilleureSuite(-1);
               if (coup <> 44) and (coup >= 11) and (coup <= 88) then
                 if partie^^[numeroCoup - 1].optimal and (partie^^[numeroCoup - 1].coupParfait <> coup)
                   then ok := false
                   else partie^^[numeroCoup-1].coupParfait := coup;

               if ok then
               for i := numeroCoup to 60 do
                 begin
                   coup := GetCoupDansMeilleureSuite(i-numeroCoup);
                   partie^^[i].coupParfait := coup;
                   if (i > nbreCoup) and ((i-numeroCoup) >= 0) then
                     partie^^[i].optimal := true;
                 end;



               // debugMeilleureSuite := (partie^^[50].coupParfait = 27) or (partie^^[51].coupParfait = 27) ;
               debugMeilleureSuite := false;

               if debugMeilleureSuite then
                 begin

                     WritelnDansRapport('debugMeilleureSuite dans SauvegardeLigneOptimale : ');
                     WritelnNumDansRapport('statut = ',statut);
                     WritelnNumDansRapport('couleur = ',couleur);
                     WritelnNumDansRapport('numeroCoup = ',numeroCoup);
                     WritelnNumDansRapport('score.noir = ',score.noir);
                     WritelnNumDansRapport('score.blanc = ',score.blanc);
                     for i := -1 to 20 do
                       begin
                         coup := GetCoupDansMeilleureSuite(i);
                         WriteNumDansRapport('i = ',i);
                         WritelnStringAndCoupDansRapport(', coup = ',coup);
                       end;
                 end;

             end;
         end;
end;

procedure SetCoupDansSuite(var suite : meilleureSuiteInfosRec; index, coup : SInt64);
begin
  if (index < profondeurMax) or (index > kNbMaxNiveaux) then
    begin
      WritelnNumDansRapport('WARNING, index out of bound dans SetCoupDansSuite :  index = ',index);
      exit;
    end;

  suite.coupsDanslLigne[index] := coup;
end;

function GetCoupDansSuite(var suite : meilleureSuiteInfosRec; index : SInt64) : SInt64;
begin
  if (index < profondeurMax) or (index > kNbMaxNiveaux) then
    begin
      WritelnNumDansRapport('WARNING, index out of bound dans GetCoupDansSuite :  index = ',index);
      GetCoupDansSuite := -1;
      exit;
    end;

  GetCoupDansSuite := suite.coupsDanslLigne[index];
end;

procedure SetCoupDansMeilleureSuite(index, coup : SInt64);
begin
  SetCoupDansSuite(meilleureSuiteInfos, index, coup);
end;

function GetCoupDansMeilleureSuite(index : SInt64) : SInt64;
begin
  GetCoupDansMeilleureSuite := GetCoupDansSuite(meilleureSuiteInfos, index);
end;

procedure MetCoupEnTeteDansKiller(coup,KillerProf : SInt64);
  var k,kcoup : SInt64;
  begin
    if (killerProf >= profondeurMax) and (killerProf <= kNbMaxNiveaux) then
      if (coup >= 11) and (coup <= 88) then
          if not(interdit[coup]) then
            if not(estUnCoin[coup]) then
              begin
                  if nbKillerGlb^[killerProf] = 0
                    then
                      begin
                        nbKillerGlb^[killerProf] := 1;
                        KillerGlb^[killerProf,1] := coup;
                      end
                    else
                      begin
                        kcoup := nbKillerGlb^[killerProf];
                        for k := 1 to nbKillerGlb^[killerProf] do
                          if KillerGlb^[killerProf,k] = coup then kCoup := k;
                        if (KillerGlb^[killerProf,kcoup] <> coup) and (kcoup < nbCoupsMeurtriers)
                          then kcoup := kcoup+1;
                        for k := kcoup downto 2 do
                          KillerGlb^[killerProf,k] := KillerGlb^[killerProf,k-1];
                        KillerGlb^[killerProf,1] := coup;
                      end;
              end;
  end;


procedure MeilleureSuiteDansKiller(profKiller : SInt64);
  var p,i,coup : SInt64;
  begin
    for i := 1 to kNbMaxNiveaux do
      begin
        coup := GetCoupDansMeilleureSuite(i);
        p := profKiller + 1 - i;
        MetCoupEnTeteDansKiller(coup,p);
      end;
  end;

function SquareSetToPlatBool(theSet : SquareSet) : plBool;
var result : plBool;
    i,j,aux : SInt16;
begin
  for i := 0 to 99 do result[i] := false;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        aux := i*10 + j;
        if aux in theSet then result[aux] := true;
      end;
  SquareSetToPlatBool := result;
end;



procedure SetNbrePionsPerduParVariation(numeroDuCoup,deltaScore : SInt64);
var i,somme : SInt16;
begin
  if (numeroDuCoup >= 0) and (numeroDuCoup <= 64) then
  with gEntrainementOuvertures do
    begin

      {WritelnDansRapport('appel de SetNbrePionsPerduParVariation('+IntToStr(numeroDuCoup)+','+IntToStr(deltaScore)+')');}

      deltaNotePerduCeCoup[numeroDuCoup] := deltaScore;

      for i := numeroDuCoup+1 to 64 do
        deltaNotePerduCeCoup[i] := 0;

      somme := 0;
      for i := 0 to 64 do
        somme := somme + deltaNotePerduCeCoup[i];
      deltaNotePerduAuTotal := somme;
    end;
end;

function PrefixeFichierProfiler : String255;
begin
  if GetEffetSpecial
    then PrefixeFichierProfiler := 'eff_'
    else PrefixeFichierProfiler := 'not(eff)_';
end;

procedure SetEffetSpecial(flag : boolean);
begin
  effetspecial := flag;
end;

function  GetEffetSpecial : boolean;
begin
  GetEffetSpecial := effetspecial;
end;

function SetClefHashageGlobale(whichValue : SInt64) : SInt64;
begin
  gClefHashage := whichValue;
  SetClefHashageGlobale := whichValue;
end;

procedure TesterClefHashage(valeurCorrecte : SInt64; nomFonction : String255);
begin
  if (gClefHashage <> valeurCorrecte) then
    begin
      WritelnNumDansRapport('gClefHashage = ',gClefHashage);
      AlerteSimple('Erreur dans mon algorithme, gClefHashage = '+IntToStr(gClefHashage)+ ' dans '+nomFonction+'!! Pr�venez St�phane');
    end;
end;


procedure InitUnitUtilitaires;
begin
  MyFiltreClassiqueUPP := NewModalFilterUPP(MyFiltreClassique);
  SetReveillerRegulierementLeMac(false);

  gJoueursComplementes := MakeEmptyStringSet;
  gTournoisComplementes := MakeEmptyStringSet;

  InitUnicodeTable;
end;


procedure LibereMemoireUnitUtilitaires;
begin
  MyDisposeModalFilterUPP(MyFiltreClassiqueUPP);

  DisposeStringSet(gJoueursComplementes);
  DisposeStringSet(gTournoisComplementes);

  DisposeUnicodeTable;
end;


(* Etant donne un nombre k compris entre 1 et (length !) ,
   cette procedure genere la k-ieme permutation de longueur
   length et la place dans perm *)
procedure GeneratePermutation(length : SInt64; k : SInt64; var perm : LongintArrayPtr);
var i,j,a,b : SInt64;
begin

  for j := 1 to length do
    perm^[j] := j;

  for j := 2 to length do
    begin

      i := 1 + (k mod j);  // perm est indice a partir de 1

      a := perm^[j];
      b := perm^[i];

      perm^[j] := b;
      perm^[i] := a;

      k := k div j;
    end;

end;


procedure Planetes;
const k_TAILLE_Grille = 8;
      k_NBRE_PLANETES = 8;
var planete : array[1..k_NBRE_PLANETES] of String255;
    lettres : array['A'..'Z'] of SInt64;
    mot : String255;
    Grille : array[0..k_TAILLE_Grille] of char;
    voisin : array[1..k_TAILLE_Grille,1..6] of SInt64;
    permutationBuffer : array[0..k_TAILLE_Grille] of SInt64;
    permutation : LongintArrayPtr;
    a,b,i,j,k : SInt64;
    top_solution : SInt64;
    factorielle : SInt64;


  procedure WritelnGrillePlanetesDansRapport;
  begin
    WritelnDansRapport('     '         +Grille[1] + '  '+ Grille[2] + '  ');
    WritelnDansRapport(Grille[3] + '  '+Grille[4] + '  '+ Grille[5] + '  ' + Grille[6]);
    WritelnDansRapport('     '         +Grille[7] + '  '+ Grille[8] + '  ');
  end;


  function CeMotEstDansLeGrille(s : String255) : boolean;
  var c : char;
      z,x,y,n : SInt64;
  begin

    CeMotEstDansLeGrille := false;  // jusqu'a preuve du contraire

    n := 1;
    c := s[n];


    x := 0;
    for z := 1 to k_TAILLE_Grille do
      if (Grille[z] = c) then x := z;
    if (x = 0) then exit;

    repeat
      inc(n);

      if (n > LENGTH_OF_STRING(s)) then
        begin
          CeMotEstDansLeGrille := true;
          exit;
        end;
      c := s[n];

      y := x;
      x := 0;
      for z := 1 to 6 do
        if (Grille[voisin[y,z]] = c) then x := voisin[y,z];

    until (x = 0);

  end;


  procedure EssayerCetteGrille(i, j, k : SInt64; const permutation : LongintArrayPtr);
  var t, longueur : SInt64;
  begin

    (*
    Grille[1] := mot[t1];
    Grille[2] := mot[t2];
    Grille[3] := mot[t3];
    Grille[4] := mot[t4];
    Grille[5] := mot[t5];
    Grille[6] := mot[t6];
    Grille[7] := mot[t7];
    Grille[8] := mot[t8];
    *)

    for t := 1 to k_TAILLE_Grille do
      Grille[t] := mot[permutation^[t]];



    if CeMotEstDansLeGrille(planete[i]) and
       CeMotEstDansLeGrille(planete[j]) and
       CeMotEstDansLeGrille(planete[k])
      then
        begin

          longueur := LENGTH_OF_STRING(planete[i]) + LENGTH_OF_STRING(planete[j]) + LENGTH_OF_STRING(planete[k]);

          if (longueur > top_solution) then
            begin
              WritelnNumDansRapport('solution !  =  >  ', longueur);
              WritelnGrillePlanetesDansRapport;

              top_solution := longueur;
            end;
        end;


  end;


  procedure EssayerCesPlanetes(i,j,k : SInt64);
  var t,s : SInt64;
      c : char;
  begin

    for c := 'A' to 'Z' do
      lettres[c] := 0;


    for t := 1 to LENGTH_OF_STRING(planete[i]) do
      begin
        c := planete[i][t];
        if (t >= 2) and (c = planete[i][t - 1]) then inc(lettres[c]); // TERRE redouble le R
        if (lettres[c] = 0) then inc(lettres[c]);
      end;

    for t := 1 to LENGTH_OF_STRING(planete[j]) do
      begin
        c := planete[j][t];
        if (t >= 2) and (c = planete[j][t - 1]) then inc(lettres[c]); // TERRE redouble le R
        if (lettres[c] = 0) then inc(lettres[c]);
      end;

    for t := 1 to LENGTH_OF_STRING(planete[k]) do
      begin
        c := planete[k][t];
        if (t >= 2) and (c = planete[k][t - 1]) then inc(lettres[c]); // TERRE redouble le R
        if (lettres[c] = 0) then inc(lettres[c]);
      end;


    s := 0;
    for c := 'A' to 'Z' do
      s := s + lettres[c];


    if (s <= k_TAILLE_Grille) then
      begin
        WritelnDansRapport(planete[i]+' , '+planete[j] + ' , '+ planete[k] + '  ');

        s := 0;
        mot := '';
        for c := 'A' to 'Z' do
          begin

            if lettres[c] > 0 then
              begin
                dec(lettres[c]);
                inc(s);
                mot := mot + c;
              end;

            if lettres[c] > 0 then
              begin
                dec(lettres[c]);
                inc(s);
                mot := mot + c;
              end;

          end;

        for t := 0 to k_TAILLE_Grille do Grille[t] := ' ';


        permutation := LongintArrayPtr(@permutationBuffer);

        factorielle := 1;
        for t := 2 to k_TAILLE_Grille do
          factorielle := t * factorielle;


        for t := 1 to factorielle do
          begin
            GeneratePermutation(k_TAILLE_Grille, t, permutation);
            EssayerCetteGrille(i, j, k, permutation);
          end;

    end;

  end;


begin

  planete[1] := 'NEPTUNE';
  planete[2] := 'TERRE';
  planete[3] := 'VENUS';
  planete[4] := 'MARS';
  planete[5] := 'JUPITER';
  planete[6] := 'SATURNE';
  planete[7] := 'URANUS';
  planete[8] := 'MERCURE';




  for a := 1 to k_TAILLE_Grille do
    for b := 1 to 6 do
      voisin[a,b] := 0;

  //    1 2
  //  3 4 5 6
  //    7 8

  voisin[1,1] := 2;
  voisin[1,2] := 3;
  voisin[1,3] := 4;
  voisin[1,4] := 5;

  voisin[2,1] := 1;
  voisin[2,2] := 4;
  voisin[2,3] := 5;
  voisin[2,4] := 6;

  voisin[3,1] := 1;
  voisin[3,2] := 4;
  voisin[3,3] := 7;

  voisin[4,1] := 1;
  voisin[4,2] := 2;
  voisin[4,3] := 3;
  voisin[4,4] := 5;
  voisin[4,5] := 7;
  voisin[4,6] := 8;

  voisin[5,1] := 1;
  voisin[5,2] := 2;
  voisin[5,3] := 4;
  voisin[5,4] := 6;
  voisin[5,5] := 7;
  voisin[5,6] := 8;

  voisin[6,1] := 2;
  voisin[6,2] := 5;
  voisin[6,3] := 8;

  voisin[7,1] := 3;
  voisin[7,2] := 4;
  voisin[7,3] := 5;
  voisin[7,4] := 8;

  voisin[8,1] := 4;
  voisin[8,2] := 5;
  voisin[8,3] := 6;
  voisin[8,4] := 7;


  top_solution := 0;

  for i := 1 to k_NBRE_PLANETES do
    for j := i + 1 to k_NBRE_PLANETES do
      for k := j + 1 to k_NBRE_PLANETES do
        if (i <> j) and (i <> k) and (j <> k) then
          begin
            EssayerCesPlanetes(i,j,k);
          end;



end;



end.
