UNIT UnitInterversions;

INTERFACE







 USES UnitDefCassio;


{Initialisation de l'unite}
procedure InitUnitInterversions;                                                                                                                                                    ATTRIBUTE_NAME('InitUnitInterversions')
procedure LibereMemoireUnitInterversion;                                                                                                                                            ATTRIBUTE_NAME('LibereMemoireUnitInterversion')
procedure TestUnitInterversions;                                                                                                                                                    ATTRIBUTE_NAME('TestUnitInterversions')

procedure EcritInterversionsSurDisque;                                                                                                                                              ATTRIBUTE_NAME('EcritInterversionsSurDisque')
procedure Initialise_interversions;                                                                                                                                                 ATTRIBUTE_NAME('Initialise_interversions')
procedure AjouteInterversions_5_14;                                                                                                                                                 ATTRIBUTE_NAME('AjouteInterversions_5_14')
procedure AjouteInterversions_15_33;                                                                                                                                                ATTRIBUTE_NAME('AjouteInterversions_15_33')


{ajout des interversions a la volee}
procedure AjouterInterversionAlaVolee(InterVarianteAlaVolee,InterCanonAlaVolee : PackedThorGame; longueur : SInt16; whichNode : GameTree);                                          ATTRIBUTE_NAME('AjouterInterversionAlaVolee')
procedure RaccourcirInterversion(var variante60,canonique60 : PackedThorGame; var longueurUtile : SInt16; var estInterversion : boolean);                                           ATTRIBUTE_NAME('RaccourcirInterversion')
procedure EssaieAjouterInterversionPotentielle(alpha1,alpha2 : String255; whichNode : GameTree);                                                                                    ATTRIBUTE_NAME('EssaieAjouterInterversionPotentielle')


{trouver tous les chemins}
function ChercheToutesInterversionsPositionEtTrait(var goal : PositionEtTraitRec; coupUn,refGoal : SInt32; whichGame : String255Ptr; metDansGraphe,dansRapport,sousIntervertions : boolean) : SInt32;                                                                         ATTRIBUTE_NAME('ChercheToutesInterversionsPositionEtTrait')
procedure ChercheToutesInterversionsPartie(var partieAlpha : String255; coupUn,refPartie : SInt32; metDansGraphe,sousIntervertions : boolean; var nbInter : SInt32);                ATTRIBUTE_NAME('ChercheToutesInterversionsPartie')


{memoisation}
procedure VideMemoisationInterversions;                                                                                                                                             ATTRIBUTE_NAME('VideMemoisationInterversions')
function NbPositionsMemoizees : SInt32;                                                                                                                                             ATTRIBUTE_NAME('NbPositionsMemoizees')


{fonctions de gestion des interversions}
procedure GererInterversionDeCeNoeud(G : GameTree; var position : PositionEtTraitRec);                                                                                              ATTRIBUTE_NAME('GererInterversionDeCeNoeud')
procedure AjouterInterversionsOfGameTreeDansTable(G : GameTree; var table : TableParties60Ptr);                                                                                     ATTRIBUTE_NAME('AjouterInterversionsOfGameTreeDansTable')


{Reponse aux clics souris dans la fenetre d'arbre de jeu}
procedure CyclerDansOrbiteInterversionDuGraphe(whichNode : GameTree; avancerDansOrbite : boolean);                                                                                  ATTRIBUTE_NAME('CyclerDansOrbiteInterversionDuGraphe')
procedure EcrireInterversionsDuGrapheCeNoeudDansRapport(whichNode : GameTree);                                                                                                      ATTRIBUTE_NAME('EcrireInterversionsDuGrapheCeNoeudDansRapport')
procedure SetEnTrainDeRejouerUneInterversion(flag : boolean);                                                                                                                       ATTRIBUTE_NAME('SetEnTrainDeRejouerUneInterversion')
function EstEnTrainDeRejouerUneInterversion : boolean;                                                                                                                              ATTRIBUTE_NAME('EstEnTrainDeRejouerUneInterversion')
procedure SetLongueurInterversionEnTrainDEtreRejouee(longueur : SInt32);                                                                                                            ATTRIBUTE_NAME('SetLongueurInterversionEnTrainDEtreRejouee')
function LongueurInterversionEnTrainDEtreRejouee : SInt32;                                                                                                                          ATTRIBUTE_NAME('LongueurInterversionEnTrainDEtreRejouee')


{Drapeau pour gerer l'ecriture des interversions trouvees dans leur graphe}
function ToujoursAjouterInterversionDansGrapheInterversions : boolean;                                                                                                              ATTRIBUTE_NAME('ToujoursAjouterInterversionDansGrapheInterversions')
procedure SetToujoursAjouterInterversionDansGrapheInterversions(flag : boolean);                                                                                                    ATTRIBUTE_NAME('SetToujoursAjouterInterversionDansGrapheInterversions')


{Diverses}
procedure TraiteInterversionFormatThorCompile(var whichGame : PackedThorGame);                                                                                                      ATTRIBUTE_NAME('TraiteInterversionFormatThorCompile')
procedure TraiteInterversionFormatThor(var whichGame : PackedThorGame; longueur : SInt16);                                                                                          ATTRIBUTE_NAME('TraiteInterversionFormatThor')
procedure PrecompileInterversions(var whichGame : PackedThorGame; longueur : SInt16);                                                                                               ATTRIBUTE_NAME('PrecompileInterversions')
procedure TraiteIntervertionsCoups(var s : String255);                                                                                                                              ATTRIBUTE_NAME('TraiteIntervertionsCoups')
procedure InterversionPuisNormalisation(var partie120 : String255; var autreCoupQuatreDiag : boolean);                                                                              ATTRIBUTE_NAME('InterversionPuisNormalisation')
procedure AjouterInterversion(variante,canonique : String255);                                                                                                                      ATTRIBUTE_NAME('AjouterInterversion')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, OSUtils, Sound
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitRapport, UnitRapportImplementation, UnitJaponais, UnitPositionEtTraitSet
    , UnitEvenement, Zebra_to_Cassio, UnitPileEtFile, UnitGameTree, UnitStrategie, UnitGrapheInterversions, UnitArbreDeJeuCourant, UnitAffichageArbreDeJeu
    , UnitJeu, UnitGeneralSort, UnitDialog, MyFileSystemUtils, UnitServicesDialogs, UnitMiniProfiler, UnitHashing, MyStrings
    , UnitScannerUtils, UnitNormalisation, UnitEntreeTranscript, UnitPackedThorGame, SNEvents, UnitScannerOthellistique, UnitFichiersTEXT, UnitPositionEtTrait
    , UnitABR, UnitProperties, UnitServicesRapport, UnitServicesMemoire ;
{$ELSEC}
    ;
    {$I prelink/Interversions.lk}
{$ENDC}


{END_USE_CLAUSE}








var memoisationInterversionsEnArriere : PositionEtTraitSet;
    impasses : PositionEtTraitSet;
    longueurInterversionPrincipale : SInt32;
    nbAffichageSousLignesDansRapport : SInt32;
    nbAppelsJouerCoup : SInt32;
    impassesLocales : Pile;
    trace : boolean;
    gToujoursAjouterInterversionDansGrapheInterversions : boolean;
    gEnTrainDeRejouerUneInterversion : boolean;
    gLongueurInterversionEnTrainDEtreRejouee : SInt32;

var PositionsDontOnAEcritLOrbite : PositionEtTraitSet;


procedure InitUnitInterversions;
begin
  SetToujoursAjouterInterversionDansGrapheInterversions(true);
  memoisationInterversionsEnArriere := MakeEmptyPositionEtTraitSet;
  impasses := MakeEmptyPositionEtTraitSet;
  longueurInterversionPrincipale := 5;
  trace := false;
  gEnTrainDeRejouerUneInterversion := false;
  gLongueurInterversionEnTrainDEtreRejouee := 0;

  PositionsDontOnAEcritLOrbite := MakeEmptyPositionEtTraitSet;
end;


procedure LibereMemoireUnitInterversion;
begin
  DisposePositionEtTraitSet(memoisationInterversionsEnArriere);

  DisposePositionEtTraitSet(PositionsDontOnAEcritLOrbite);
end;


procedure VideMemoisationInterversions;
begin
  DisposePositionEtTraitSet(memoisationInterversionsEnArriere);
end;


function NbPositionsMemoizees : SInt32;
begin
  NbPositionsMemoizees := CardinalOfPositionEtTraitSet(memoisationInterversionsEnArriere);
end;


procedure EcritInterversionsSurDisque;
var fichierInterversions : FichierTEXT;
    reply : SFReply;
    mySpec : FSSpec;
    nomfichier,s : String255;
    faut60,princ60 : PackedThorGame;
    faut255,princ255 : String255;
    i : SInt16;
    erreurES : OSErr;
begin
  s := ReadStringFromRessource(TextesDiversID,2);   {'sans titre'}
  SetNameOfSFReply(reply, s);
  if MakeFileName(reply,'Nom du fichier d''interversions ?',mySpec) then
      begin

        nomfichier := GetNameOfSFReply(reply)+CharToString('1');
        erreurES := FichierTexteExisteFSp(MyMakeFSSpec(mySpec.vRefNum,mySpec.parID,nomfichier),fichierInterversions);
        if erreurES = fnfErr then erreurES := CreeFichierTexteFSp(MyMakeFSSpec(mySpec.vRefNum,mySpec.parID,nomfichier),fichierInterversions);
        if erreurES = 0 then
          begin
            erreurES := OuvreFichierTexte(fichierInterversions);
            erreurES := VideFichierTexte(fichierInterversions);
          end;
        if erreurES <> 0 then
          begin
            AlerteSimpleFichierTexte(nomFichier,erreurES);
            erreurES := FermeFichierTexte(fichierInterversions);
            exit(EcritInterversionsSurDisque);
          end;
        for i := 1 to numeroInterversion[14] do
          begin
            COPY_STR60_TO_PACKED_GAME(interversionFautive^^[i], faut60);
            COPY_STR60_TO_PACKED_GAME(interversionCanonique^^[i], princ60);
            SET_NTH_MOVE_OF_PACKED_GAME(faut60, 1, 56);      (** a cause de la sentinelle **)
            TraductionThorEnAlphanumerique(faut60,faut255);
            TraductionThorEnAlphanumerique(princ60,princ255);

            erreurES := WriteDansFichierTexte(fichierInterversions,'ajouterInterversion(''');
            erreurES := WriteDansFichierTexte(fichierInterversions,faut255);
            erreurES := WriteDansFichierTexte(fichierInterversions,''',''');
            erreurES := WriteDansFichierTexte(fichierInterversions,princ255);
            erreurES := WritelnDansFichierTexte(fichierInterversions,''');');
          end;
        erreurES := FermeFichierTexte(fichierInterversions);
        SetFileCreatorFichierTexte(fichierInterversions,MY_FOUR_CHAR_CODE('CWIE'));
        SetFileTypeFichierTexte(fichierInterversions,MY_FOUR_CHAR_CODE('TEXT'));


        nomfichier := GetNameOfSFReply(reply)+CharToString('2');
        erreurES := FichierTexteExisteFSp(MyMakeFSSpec(mySpec.vRefNum,mySpec.parID,nomfichier),fichierInterversions);
        if erreurES = fnfErr then erreurES := CreeFichierTexteFSp(MyMakeFSSpec(mySpec.vRefNum,mySpec.parID,nomfichier),fichierInterversions);
        if erreurES = 0 then
          begin
            erreurES := OuvreFichierTexte(fichierInterversions);
            erreurES := VideFichierTexte(fichierInterversions);
          end;
        if erreurES <> 0 then
          begin
            AlerteSimpleFichierTexte(nomFichier,erreurES);
            erreurES := FermeFichierTexte(fichierInterversions);
            exit(EcritInterversionsSurDisque);
          end;
        for i := numeroInterversion[14]+1 to numeroInterversion[33] do
          begin
            COPY_STR60_TO_PACKED_GAME(interversionFautive^^[i], faut60);
            COPY_STR60_TO_PACKED_GAME(interversionCanonique^^[i], princ60);
            SET_NTH_MOVE_OF_PACKED_GAME(faut60, 1, 56);      (** a cause de la sentinelle **)
            TraductionThorEnAlphanumerique(faut60,faut255);
            TraductionThorEnAlphanumerique(princ60,princ255);

            if GET_LENGTH_OF_PACKED_GAME(faut60) < 28
              then
                begin
                  erreurES := WriteDansFichierTexte(fichierInterversions,'ajouterInterversion(''');
                  erreurES := WriteDansFichierTexte(fichierInterversions,faut255);
                  erreurES := WriteDansFichierTexte(fichierInterversions,''',''');
                  erreurES := WriteDansFichierTexte(fichierInterversions,princ255);
                  erreurES := WritelnDansFichierTexte(fichierInterversions,''');');
                end
              else
                begin
                  erreurES := WriteDansFichierTexte(fichierInterversions,'ajouterInterversion(''');
                  erreurES := WriteDansFichierTexte(fichierInterversions,faut255);
                  erreurES := WritelnDansFichierTexte(fichierInterversions,''',');
                  erreurES := WriteDansFichierTexte(fichierInterversions,'        ''');
                  erreurES := WriteDansFichierTexte(fichierInterversions,princ255);
                  erreurES := WritelnDansFichierTexte(fichierInterversions,''');');
                end;
          end;
        erreurES := FermeFichierTexte(fichierInterversions);
        SetFileCreatorFichierTexte(fichierInterversions,MY_FOUR_CHAR_CODE('CWIE'));
        SetFileTypeFichierTexte(fichierInterversions,MY_FOUR_CHAR_CODE('TEXT'));
      end;
end;


procedure Initialise_interversions;
var i : SInt16;
    {s : String255;}
    chrono : SInt32;
begin
  for i := 0 to 33 do numeroInterversion[i] := 0;

  chrono := TickCount;
  AjouteInterversions_5_14;
  AjouteInterversions_15_33;

  {
  WriteNumAt('temps en ticks : ',(TickCount-chrono),100,150);
  AttendFrappeClavier;
  for i := 0 to 20 do
    begin
      NumEnString(i,s);
      WriteNumAt('inter longueur '+s+' : ',numeroInterversion[i],10,10+11*i);
    end;
  AttendFrappeClavier;
  for i := 21 to 33 do
    begin
      NumEnString(i,s);
      WriteNumAt('inter longueur '+s+' : ',numeroInterversion[i],10,10+11*(i-21));
    end;
  AttendFrappeClavier;
  WriteNumAt('nb interversions : ',numeroInterversion[33],100,100);
  AttendFrappeClavier;
  }

end;


procedure AjouteInterversions_5_14;
var i : SInt16;
begin
 {$I  ProcInitInter1.p}
  for i := 1 to numeroInterversion[33] do
    interversionFautive^^[i][1] := chr(230);   {•• sentinelle ••}
end;


procedure AjouteInterversions_15_33;
var i : SInt16;
begin
 {$I  ProcInitInter2.p}
  for i := 1 to numeroInterversion[33] do
    interversionFautive^^[i][1] := chr(230);   {•• sentinelle ••}
end;



procedure RaccourcirInterversion(var variante60,canonique60 : PackedThorGame; var longueurUtile : SInt16; var estInterversion : boolean);
var positionVariante,positionCanonique : PositionEtTraitRec;
    i,longueur,coup1,coup2 : SInt16;
    memesPositionsCoupPrecedent : boolean;
    memesPositionsCeCoup : boolean;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(variante60);
  longueurUtile := 1;
  if (longueur > 1) & (longueur = GET_LENGTH_OF_PACKED_GAME(canonique60)) then
    begin
      positionVariante := PositionEtTraitInitiauxStandard;
      positionCanonique := PositionEtTraitInitiauxStandard;
      memesPositionsCoupPrecedent := true;
      for i := 1 to longueur do
        begin
          coup1 := GET_NTH_MOVE_OF_PACKED_GAME(variante60, i,'RaccourcirInterversion(1)');
          coup2 := GET_NTH_MOVE_OF_PACKED_GAME(canonique60, i,'RaccourcirInterversion(2)');
          if UpdatePositionEtTrait(positionVariante,coup1) &
             UpdatePositionEtTrait(positionCanonique,coup2)
             then
               begin
                 memesPositionsCeCoup := SamePositionEtTrait(positionVariante,positionCanonique);
                 if not(memesPositionsCoupPrecedent) & memesPositionsCeCoup then longueurUtile := i;
                 memesPositionsCoupPrecedent := memesPositionsCeCoup;
                 estInterversion := memesPositionsCeCoup;
               end
             else
               begin
                 SysBeep(0);
                 WritelnDansRapport('## ERREUR : suite ou variante illégale dans RaccourcirInterversions !! Prévenez Stéphane ');
                 longueurUtile := 0;
                 estInterversion := false;
                 exit(RaccourcirInterversion);
               end;
        end;
    end;
  if (longueurUtile > 0) & (longueurUtile <> longueur) then
    begin
      SHORTEN_PACKED_GAME(variante60, longueurUtile);
      SHORTEN_PACKED_GAME(canonique60, longueurUtile);
    end;
end;


procedure AjouterInterversionAlaVolee(InterVarianteAlaVolee,InterCanonAlaVolee : PackedThorGame; longueur : SInt16; whichNode : GameTree);
var variante120,canonique120 : String255;
    canonique255,variante255 : String255;
    canoniqueAff,varianteAff : String255;
    IndexInsertion,nbInterversion : SInt16;
    t : SInt16;
    platCanon,platVariante : plateauOthello;
    canoniqueEstLegale,varianteEstLegale,estUneInterversion : boolean;
    autreCoupQuatre : boolean;
    nbCoupsLegauxCanon,nbCoupsLegauxVariante : SInt32;
    oldScript : SInt32;
const InterversionDialogID = 1128;
begin
  if (longueur <= 33) & (longueur >= 5) then
    begin
      SHORTEN_PACKED_GAME(InterVarianteAlaVolee,longueur);
      SHORTEN_PACKED_GAME(InterCanonAlaVolee,longueur);
      SET_NTH_MOVE_OF_PACKED_GAME(InterVarianteAlaVolee, 1, 56);  (** on remet F5 **)
      SET_NTH_MOVE_OF_PACKED_GAME(InterCanonAlaVolee, 1, 56);     (** on remet F5 **)

      RaccourcirInterversion(InterVarianteAlaVolee,InterCanonAlaVolee,longueur,estUneInterversion);
      
      if not(estUneInterversion) | (longueur < 5) then
        begin
          WritelnDansRapport('## BIZARRE : not(estUneInterversion) | (longueur < 5) dans AjouterInterversionAlaVolee');
          exit(AjouterInterversionAlaVolee);
        end;

      TraductionThorEnAlphanumerique(InterVarianteAlaVolee,variante255);
      TraductionThorEnAlphanumerique(InterCanonAlaVolee,canonique255);

      variante120 := variante255;
      canonique120 := canonique255;

      Normalisation(variante120,autreCoupQuatre,true);
		  Normalisation(canonique120,autreCoupQuatre,true);

		  if (variante120 = canonique120) then
		    begin
		      WritelnDansRapport('## BIZARRE : les variantes normalisées sont les mêmes dans AjouterInterversionAlaVolee');
          exit(AjouterInterversionAlaVolee);
		    end;

      CalculePositionFinale(variante120,platVariante,varianteEstLegale,nbCoupsLegauxVariante);
      CalculePositionFinale(canonique120,platCanon,canoniqueEstLegale,nbCoupsLegauxCanon);

      if not(varianteEstLegale) | not(canoniqueEstLegale) |
        not(PositionsEgales(platVariante,platCanon)) then exit(AjouterInterversionAlaVolee);

      ApprendInterversionAlaVoleeDansGraphe(canonique120,variante120,not(PendantLectureFormatSmartGameBoard));

      if whichNode = GetCurrentNode
        then AddTranspositionPropertyToCurrentNode(variante255)
        else AddTranspositionPropertyToGameTree(variante255,whichNode);

      nbInterversion := numeroInterversion[33];
      if nbInterversion < nbMaxInterversions then
        begin
          IndexInsertion := numeroInterversion[longueur]+1;
          for t := numeroInterversion[33]+1 downto numeroInterversion[longueur]+1 do
            begin
              interversionFautive^^[t]  := interversionFautive^^[t-1];
              interversionCanonique^^[t] := interversionCanonique^^[t-1];
            end;
          COPY_PACKED_GAME_TO_STR60(InterVarianteAlaVolee, interversionFautive^^[IndexInsertion]);
          COPY_PACKED_GAME_TO_STR60(InterCanonAlaVolee,    interversionCanonique^^[IndexInsertion]);
          interversionFautive^^[IndexInsertion][1] := chr(230);   {•• sentinelle ••}
          for t := 33 downto longueur do
            numeroInterversion[t] := numeroInterversion[t]+1;
          if avecAlerteNouvInterversion then
            begin
              t := 1;
              repeat
                inc(t);
              until (t >= longueur) | (canonique120[2*t-1] <> variante120[2*t-1]) | (canonique120[2*t] <> variante120[2*t]);
              canoniqueAff := TPCopy(canonique120,1,2*t-2)+CharToString('-')+TPCopy(canonique120,2*t-1,2*longueur-2*t+2);
              varianteAff := TPCopy(variante120,1,2*t-2)+CharToString('-')+TPCopy(variante120,2*t-1,2*longueur-2*t+2);

		          if not(PendantLectureFormatSmartGameBoard) & not(EnModeEntreeTranscript) then
		            begin
		              MyParamText(canoniqueAff,varianteAff,'','');
		              DialogueSimple(InterversionDialogID);

		              GetCurrentScript(oldScript);
                  DisableKeyboardScriptSwitch;
                  FinRapport;
                  TextNormalDansRapport;
                  if not(PendantLectureFormatSmartGameBoard) then WritelnDansRapport('');
                  WritelnDansRapport(canoniqueAff+' = '+varianteAff);
                  if not(PendantLectureFormatSmartGameBoard) then WritelnDansRapport('');
                  EnableKeyboardScriptSwitch;
                  SetCurrentScript(oldScript);
                  SwitchToRomanScript;
		            end;
            end;
        end;
    end;
end;

{alpha1 et alpha2 doivent etre des parties d'othello legales, pas forcement normalisees}
procedure EssaieAjouterInterversionPotentielle(alpha1,alpha2 : String255; whichNode : GameTree);
var partie1_120,partie2_120 : String255;
    s1,s2 : PackedThorGame;
    autreCoupQuatre : boolean;
begin
  if LENGTH_OF_STRING(alpha1) = LENGTH_OF_STRING(alpha2) then
    begin

      {
      SetEcritToutDansRapportLog(true);
		  WritelnDansRapport('');
		  WritelnDansRapport('dans EssaieAjouterInterversionPotentielle');
		  WritelnDansRapport('avant normalisation : '+alpha1 + ' = ' + alpha2);
		  }

		  partie1_120 := alpha1;
		  partie2_120 := alpha2;
		  Normalisation(partie1_120,autreCoupQuatre,true);
		  Normalisation(partie2_120,autreCoupQuatre,true);

		  alpha1 := partie1_120;
		  alpha2 := partie2_120;

      {
		  WritelnDansRapport('apres normalisation : '+alpha1 + ' = ' + alpha2);
		  WritelnStringAndBoolDansRapport('meme lignes = ', (alpha1 = alpha2));
		  }


		  if (alpha1 <> alpha2) then
		    begin
		      TraductionAlphanumeriqueEnThor(alpha1,s1);
		      TraductionAlphanumeriqueEnThor(alpha2,s2);
		      AjouterInterversionAlaVolee(s1,s2,GET_LENGTH_OF_PACKED_GAME(s1),whichNode);
		    end;
		end;
end;


procedure ViderImpasses;
begin
  DisposePositionEtTraitSet(impasses);
end;


procedure AjouterDansImpasses(var whichPos,whichGoal : PositionEtTraitRec; var pileIndexImpasses : Pile; var nbImpassesLocales : SInt32);
var posHash , goalHash : SInt32;
    ok : boolean;
    trait : SInt32;
begin
  if not(PileEstPleine(pileIndexImpasses)) then
    begin
      trait := GetTraitOfPosition(whichPos);
      posHash := GenericHash(@whichPos,sizeof(whichPos));
      if ABRSearch(impasses.arbre,posHash) <> NIL
		    then
		      begin
		        if trace then
		          WritelnNumDansRapport('Deja dans impasses : ',GenericHash(@whichPos,sizeof(whichPos)));
		      end
		    else
			    begin
			      trait := GetTraitOfPosition(whichGoal);
			      goalHash := GenericHash(@whichGoal,sizeof(whichGoal));
			      AddPositionEtTraitToSet(whichPos,goalHash,impasses);
			      Empiler(pileIndexImpasses,posHash,ok);
			      inc(nbImpassesLocales);

			      {WritelnNumDansRapport('NbElementsDansPile = ',NbElementsDansPile(pileIndexImpasses));}

			      if trace then
			        WritelnNumDansRapport('Empiler '+NumEnString(posHash)+' / ',goalHash);

			    end;
		end;
end;


procedure ReactiverPositions(var pileIndexImpasses : Pile; var whichGoal : PositionEtTraitRec; nbImpassesLocales : SInt32);
var posHash,goalHash : SInt32;
    ok : boolean;
    elementTrouve : ABR;
    nbDepilements : SInt32;
    trait : SInt32;
begin
  if (nbImpassesLocales > 0) & not(PileEstVide(pileIndexImpasses) | PositionEtTraitSetEstVide(impasses)) then
    begin
      trait := GetTraitOfPosition(whichGoal);
      goalHash := GenericHash(@whichGoal,sizeof(whichGoal));
      nbDepilements := 0;
      repeat
        inc(nbDepilements);
        posHash := Depiler(pileIndexImpasses,ok);
        elementTrouve := ABRSearch(impasses.arbre,posHash);
        if (elementTrouve <> NIL) & (elementTrouve^.data = goalHash) then
          begin
            impasses.cardinal := impasses.cardinal-1;
            SupprimerDansABR(impasses.arbre,elementTrouve);

            if trace then
              WritelnNumDansRapport('Depiler '+NumEnString(posHash)+' / ',goalHash);

          end;
      until (nbDepilements >= nbImpassesLocales) | PileEstVide(pileIndexImpasses);
    end;
end;


function ChercheToutesInterversionsPositionEtTrait(var goal : PositionEtTraitRec; coupUn,refGoal : SInt32; whichGame : String255Ptr; metDansGraphe,dansRapport,sousIntervertions : boolean) : SInt32;
const kCaseRemplieCouleurIndeterminee = 35;
var couleurPionsForces : platValeur;
    i,j,t,nbCoupMax,intervalleExtreme : SInt32;
    caseNordOuest,caseSudEst : SInt32;
    pionExterieur,estTriviale : boolean;
    ligne,goalLigne : array[1..60] of SInt32;
    compteurReussites,nbPositionsVisitees : SInt32;
    {nbSousInter,}sommeSousInterGoal{,infoTableGlobale} : SInt32;
    partieReussie : String255;
    memoisationEnAvant : PositionEtTraitSet;
    {positionForcee : PositionEtTraitRec;}
    nbImpasses : SInt32;
    chercheSolutionsLocales : boolean;
    positionLancementRecursion : PositionEtTraitRec;

  procedure JouerCoup(var posCourante : PositionEtTraitRec; coup,numeroCoup : SInt32);
  var posAux : PositionEtTraitRec;
      x,i,t,couleurCase,dist : SInt32;
      compteurReussitesArrivee : SInt32;
      nbFaconAtteindrePosCherchee : SInt32;
      nbSousInterversionsCetteInter : SInt32;
      goalHash,nbLigneAffichee : SInt32;
  begin {$UNUSED t,nbSousInterversionsCetteInter,goalHash}
  
    posAux := posCourante;
    
    if UpdatePositionEtTrait(posAux,coup) then
      begin
        inc(nbAppelsJouerCoup);
        inc(nbPositionsVisitees);
        ligne[numeroCoup] := coup;

        if trace then
          begin
		        WriteDansRapport('  goal = '+whichGame^+' ');
		        WriteDansRapport('appel de JouerCoup : ');
		        for i := 1 to numeroCoup do
		          WriteDansRapport(CoupEnStringEnMajuscules(ligne[i]));
		        WritelnDansRapport('');
          end;

        if (numeroCoup >= nbCoupMax) | (GetTraitOfPosition(posAux) = pionVide)
          then
	          begin
	            if SamePositionEtTrait(goal,posAux) then
	              begin
	                inc(compteurReussites);
	                partieReussie := '';
	                for i := 1 to numeroCoup do
	                  partieReussie := partieReussie+CoupEnStringEnMajuscules(ligne[i]);

	                estTriviale := (whichGame <> NIL) & (partieReussie = whichGame^);

	                if trace then
	                  begin
			                if estTriviale
			                  then WritelnDansRapport('triviale : '+whichGame^+' = '+partieReussie)
			                  else WritelnDansRapport('non triviale : '+whichGame^+' = '+partieReussie);
	                  end;

	                nbLigneAffichee := 0;
	                if dansRapport & not(estTriviale) {& (longueurInterversionPrincipale = numeroCoup)} then
	                  begin
	                    inc(nbAffichageSousLignesDansRapport);
	                    nbLigneAffichee := nbAffichageSousLignesDansRapport;
	                  end;


	                (*
	                nbSousInter := 0;
	                nbSousInterversionsCetteInter := 0;
	                if FALSE & sousIntervertions {& not(estTriviale)} then
	                  begin
	                    for i := 1 to numeroCoup-1 do
                        begin
                          {if (i = numeroCoup-1) then}
                            ChercheToutesInterversionsPartie(TPCopy(partieReussie,1,2*i),coupUn,nbLigneAffichee,metDansGraphe,true,nbSousInter);
                          nbSousInterversionsCetteInter := nbSousInterversionsCetteInter+nbSousInter;
                          if (i = numeroCoup-1) then
                            sommeSousInterGoal := sommeSousInterGoal+nbSousInter;
                        end;
                    end;
                  *)

                  if dansRapport {& not(estTriviale)} {& (longueurInterversionPrincipale = numeroCoup)} then
	                  begin
	                    WriteNumDansRapport('#',nbLigneAffichee);
	                    WriteStringDansRapport(' ');
	                    WriteDansRapport(partieReussie);

	                    (*
	                    for i := numeroCoup+1 to longueurInterversionPrincipale do
	                      WriteDansRapport('  ');
	                    WriteDansRapport(' = '+whichGame^);
	                    for i := numeroCoup+1 to longueurInterversionPrincipale do
	                      WriteDansRapport('  ');
	                    WriteNumDansRapport('    ( ',nbSousInter);
	                    WriteNumDansRapport(' , #',nbLigneAffichee);
	                    WriteNumDansRapport(' , ->#',refGoal);
	                    if (longueurInterversionPrincipale = numeroCoup)
	                      then WriteDansRapport(' )    bingo !')
	                      else WriteDansRapport(' )');
	                    *)
	                    WritelnDansRapport('');
	                  end;


	                (*
	                if metDansGraphe & not(estTriviale) then
	                  ApprendInterversionAlaVoleeDansGraphe(whichGame^,partieReussie,false);
	                *)

	              end;
	          end
          else
            begin
              (*
              if MemberOfPositionEtTraitSet(posAux,goalHash,impasses)
                then
                  begin
                    {if trace then
                      WritelnNumDansRapport('Impasse utilisee : goalHash ='+NumEnString(goalHash)+'  vraieHash = ',GenericHash(@goal,Sizeof(goal)));
                    }
                    nbFaconAtteindrePosCherchee := 0;
                    {AddPositionEtTraitToSet(posAux,nbFaconAtteindrePosCherchee,memoisationEnAvant);}
                  end
                else *)
                  begin
                    (*
			              if FALSE & MemberOfPositionEtTraitSet(posAux,nbFaconAtteindrePosCherchee,memoisationEnAvant)
			                then
			                  begin
			                    if trace then
			                      begin
			                        WriteDansRapport('  goal = '+whichGame^+' ');
			                        WriteDansRapport('JouerCoup ');
			                        for i := 1 to numeroCoup do
			                          WriteDansRapport(CoupEnStringEnMajuscules(ligne[i]));
			                        WritelnDansRapport(' direct ');
			                      end;

			                    compteurReussites := compteurReussites+nbFaconAtteindrePosCherchee
			                  end
			                else
			                *)

			                  begin
			                    if trace then
			                      begin
			                        WriteDansRapport('  goal = '+whichGame^+' ');
			                        WriteDansRapport('JouerCoup ');
			                        for i := 1 to numeroCoup do
			                           WriteDansRapport(CoupEnStringEnMajuscules(ligne[i]));
			                        WritelnDansRapport(' recursif ');
			                      end;

						              compteurReussitesArrivee := compteurReussites;
									        if chercheSolutionsLocales
									          then
									            begin

									              for dist := intervalleExtreme downto 1 do
									                begin
									                  x := goalLigne[numeroCoup+1]+dist;
									                  {WritelnNumDansRapport(' dist = ',dist);
									                  WritelnNumDansRapport(' test de x = ',x);}
													          if (x >= caseNordOuest) & (x <= caseSudEst) & (posAux.position[x] = pionVide) then
													            begin
													              couleurCase := couleurPionsForces[x];
													              if (couleurCase <> pionVide) & ((couleurCase = kCaseRemplieCouleurIndeterminee) | (couleurCase = GetTraitOfPosition(posAux)))
													                then JouerCoup(posAux,x,numeroCoup+1);
													            end;
													          x := goalLigne[numeroCoup+1]-dist;
													          {WritelnNumDansRapport(' dist = ',-dist);
									                  WritelnNumDansRapport(' test de x = ',x);}
													          if (x >= caseNordOuest) & (x <= caseSudEst) & (posAux.position[x] = pionVide) then
													            begin
													              couleurCase := couleurPionsForces[x];
													              if (couleurCase <> pionVide) & ((couleurCase = kCaseRemplieCouleurIndeterminee) | (couleurCase = GetTraitOfPosition(posAux)))
													                then JouerCoup(posAux,x,numeroCoup+1);
													            end;
												          end;

												        x := goalLigne[numeroCoup+1];
			                          {WritelnNumDansRapport(' dist = ',0);
			                          WritelnNumDansRapport(' test de x = ',x);}
											          if (x >= caseNordOuest) & (x <= caseSudEst) & (posAux.position[x] = pionVide) then
											            begin
											              couleurCase := couleurPionsForces[x];
											              if (couleurCase <> pionVide) & ((couleurCase = kCaseRemplieCouleurIndeterminee) | (couleurCase = GetTraitOfPosition(posAux)))
											                then JouerCoup(posAux,x,numeroCoup+1);
											            end;

												      end
												    else
												      begin
												        for x := caseSudEst downto caseNordOuest do
											          if (posAux.position[x] = pionVide) then
											            begin
											              couleurCase := couleurPionsForces[x];
											              if (couleurCase <> pionVide) & ((couleurCase = kCaseRemplieCouleurIndeterminee) | (couleurCase = GetTraitOfPosition(posAux)))
											                then JouerCoup(posAux,x,numeroCoup+1);
											            end;
												      end;
									        nbFaconAtteindrePosCherchee := compteurReussites-compteurReussitesArrivee;

									        (*
									        if trace then
			                      begin
			                        WriteDansRapport('  goal = '+whichGame^+' ');
									            WriteDansRapport(' : dans la table locale -> ');
									            for t := 1 to numeroCoup do
			                          WriteDansRapport(CoupEnStringEnMajuscules(ligne[t]));
									            WritelnNumDansRapport('  , ',nbFaconAtteindrePosCherchee);
									          end;
									        *)

									        (*
									        AddPositionEtTraitToSet(posAux,nbFaconAtteindrePosCherchee,memoisationEnAvant);
									        *)

									        (*
									        if (nbFaconAtteindrePosCherchee = 0) then
									           begin
									             AjouterDansImpasses(posAux,goal,impassesLocales,nbImpasses);
									           end;
									        *)

									      end;
								  end;
			        {WritelnNumDansRapport('nbFaconAtteindrePosCherchee = ',nbFaconAtteindrePosCherchee);}
			        {WritelnNumDansRapport('',nbFaconAtteindrePosCherchee);}
			      end;

      end;
  end;



begin  {$UNUSED refGoal, metDansGraphe, sousIntervertions}
  if trace then
		begin
		  if whichGame <> NIL
		    then WritelnDansRapport('appel de ChercheInter('+whichGame^+')');
		end;

  (*
  if MemberOfPositionEtTraitSet(goal,compteurReussites,memoisationInterversionsEnArriere) {memoisation ?}
    then  {oui, cool}
      begin
        if trace then
		      begin
		        if whichGame <> NIL
              then WritelnNumDansRapport('cool '+ whichGame^+' direct : ',compteurReussites)
              else WritelnNumDansRapport('cool direct : ',compteurReussites);
          end;
        ChercheToutesInterversionsPositionEtTrait := compteurReussites;
      end
    else  {non, il faut calculer}
    *)

      begin



        MemoryFillChar(@couleurPionsForces,sizeof(couleurPionsForces),chr(0));
			  for i := 0 to 99 do
			    if interdit[i] then couleurPionsForces[i] := PionInterdit;

			  nbCoupMax := NbPionsDeCetteCouleurDansPosition(pionNoir,goal.position) +
			               NbPionsDeCetteCouleurDansPosition(pionBlanc,goal.position) - 4;



			  caseNordOuest := 1000;
				caseSudEst  := -1000;
			  with goal do
				  for i := 1 to 64 do
				    begin
				      t := othellier[i];
				      if position[t] = pionVide
				        then couleurPionsForces[t] := pionVide
				        else
				          begin
				            if t < caseNordOuest then caseNordOuest := t;
				            if t > caseSudEst    then caseSudEst := t;

					          pionExterieur := false;
					          for j := 1 to 13 do
					            if ((position[t+dirPrise[j]]   = pionVide) | (position[t+dirPrise[j]]  = PionInterdit)) &
					               ((position[t+dirPrise[j+1]] = pionVide) | (position[t+dirPrise[j+1]] = PionInterdit)) &
					               ((position[t+dirPrise[j+2]] = pionVide) | (position[t+dirPrise[j+2]] = PionInterdit)) &
					               ((position[t+dirPrise[j+3]] = pionVide) | (position[t+dirPrise[j+3]] = PionInterdit))
					                 then pionExterieur := true;

					          if pionExterieur
					            then couleurPionsForces[t] := position[t]
					            else couleurPionsForces[t] := kCaseRemplieCouleurIndeterminee;
					        end;
					  end;

			  chercheSolutionsLocales := false;
			  intervalleExtreme := 0;
			  if whichGame <> NIL then
			    begin
			      chercheSolutionsLocales := true;
			      for i := 1 to nbCoupMax do
			        begin
			          t := PositionDansStringAlphaEnCoup(whichGame^,2*i-1);
			          if (t >= 11) & (t <= 88)
			            then goalLigne[i] := t
			            else chercheSolutionsLocales := false;
			        end;
			      if chercheSolutionsLocales
			        then intervalleExtreme := (caseSudEst-caseNordOuest);
			    end;
			  {WritelnNumDansRapport('intervalleExtreme = ',intervalleExtreme);
			  WritelnStringAndBoolDansRapport('chercheSolutionsLocales = ',chercheSolutionsLocales);
			  }

				if trace then
		      begin
				    if whichGame <> NIL
              then WritelnDansRapport('ChercheToutesInterversionsPositionEtTrait '+whichGame^+' recursif')
              else WritelnDansRapport('ChercheToutesInterversionsPositionEtTrait recursif');
          end;


				compteurReussites := 0;
				nbPositionsVisitees := 0;
				sommeSousInterGoal := 0;


				nbImpasses := 0;

				memoisationEnAvant := MakeEmptyPositionEtTraitSet;

				{on cherche recursivement}
				positionLancementRecursion := PositionEtTraitInitiauxStandard;
				JouerCoup(positionLancementRecursion,coupUn,1);

			  {
			  WritelnNumDansRapport('compteurReussites = ',compteurReussites);
				WritelnNumDansRapport('nbPositionsVisitees = ',nbPositionsVisitees);
				WritelnNumDansRapport('memoisationEnAvant.cardinal = ',memoisationEnAvant.cardinal);
				WritelnNumDansRapport('hauteur de  memoisationEnAvant =  ',ABRHauteur(memoisationEnAvant.arbre));
        }

				DisposePositionEtTraitSet(memoisationEnAvant);

				(*
				ReactiverPositions(impassesLocales,goal,nbImpasses);
				*)

				{et on memoize… }

				(*
				if (compteurReussites <= 1) & (whichGame <> NIL) then
				  begin
				    positionForcee := PositionEtTraitInitiauxStandard;
				    for i := 1 to nbCoupMax-1 do
				      begin
				        t := PositionDansStringAlphaEnCoup(whichGame^,2*i-1);
				        if UpdatePositionEtTrait(positionForcee,t) then
				          begin
				            if trace then
						          if MemberOfPositionEtTraitSet(positionForcee,infoTableGlobale,memoisationInterversionsEnArriere)
											  then
											    begin
											      WriteDansRapport('  goal = '+whichGame^+' : ');
														WritelnDansRapport(TPCopy(whichGame^,1,2*i)+' est deja dans la table globale !! ');
											    end
											  else
											    begin
								            WriteDansRapport('  goal = '+whichGame^+' ');
														WriteStringDansRapport(' : dans la table globale -> ');
														WriteDansRapport(TPCopy(whichGame^,1,2*i));
														WriteNumDansRapport('  , ',compteurReussites);
														WritelnStringDansRapport('  (car compteurReussites <= 1)');
												  end;

						        AddPositionEtTraitToSet(positionForcee,compteurReussites,memoisationInterversionsEnArriere);
						      end;
				      end;
				  end;
				  *)

				(*
				if trace then
				  if MemberOfPositionEtTraitSet(goal,infoTableGlobale,memoisationInterversionsEnArriere)
				    then
				      begin
				        WriteDansRapport('  goal = '+whichGame^+' : ');
							  WritelnDansRapport(whichGame^+' est deja dans la table globale !! ');
				      end
				    else
				      begin
		            WriteDansRapport('  goal = '+whichGame^+' ');
							  WriteStringDansRapport(' : dans la table globale -> ');
							  WriteDansRapport(whichGame^);
							  WritelnNumDansRapport('  , ',compteurReussites);
							end;
				*)

				(*
				AddPositionEtTraitToSet(goal,compteurReussites,memoisationInterversionsEnArriere);
				*)

				ChercheToutesInterversionsPositionEtTrait := compteurReussites;
	  end;
end;


procedure ChercheToutesInterversionsPartie(var partieAlpha : String255; coupUn,refPartie : SInt32; metDansGraphe,sousIntervertions : boolean; var nbInter : SInt32);
var s60 : PackedThorGame;
    longueur,i,erreur : SInt32;
    sousPosition : PositionEtTraitRec;
    sousPartie : String255;
begin
  if (LENGTH_OF_STRING(partieAlpha) > 0) & EstUnePartieOthello(partieAlpha,true) then
    begin
      if trace then
		    WritelnDansRapport('appel de ChercheToutesInterversionsPartie('+partieAlpha+')');


      TraductionAlphanumeriqueEnThor(partieAlpha,s60);
      longueur := GET_LENGTH_OF_PACKED_GAME(s60);

      for i := 1 to longueur do
        if sousIntervertions | (longueur = i) then
        begin
          sousPosition := PositionEtTraitAfterMoveNumber(s60,i,erreur);
          sousPartie := TPCopy(partieAlpha,1,2*i);
          nbInter := ChercheToutesInterversionsPositionEtTrait(sousPosition,coupUn,refPartie,@sousPartie,metDansGraphe,true,sousIntervertions);
        end;
      {WritelnNumDansRapport('nb interversions de '+partieAlpha+' = ',nbInter);}
    end;
end;


procedure EcritSystemeMinimalInterversionsDansRapport(partieAlpha : String255; coupUn : SInt32; metDansGraphe : boolean; var nbInter : SInt32);
begin
  VideMemoisationInterversions;
  ViderImpasses;
  longueurInterversionPrincipale := LENGTH_OF_STRING(partieAlpha) div 2;

  WritelnDansRapport('Recherche du systeme minimal d''interversion pour la partie :');
  WritelnDansRapport(partieAlpha+'   ( #0 )');
  WritelnDansRapport('');

  ChercheToutesInterversionsPartie(partieAlpha,coupUn,0,metDansGraphe,true,nbInter);

  WritelnDansRapport('');
  WritelnNumDansRapport('Nombre interversions = ',nbInter);
  WritelnNumDansRapport('Taille du systeme minimum d''interversions = ',nbAffichageSousLignesDansRapport);
  WritelnNumDansRapport('Nombre de coups joues = ',nbAppelsJouerCoup);
 {WritelnNumDansRapport('impassesLocales.tete = ',impassesLocales.tete);
  WritelnNumDansRapport('impassesLocales.queue = ',impassesLocales.queue);}
  WritelnNumDansRapport('Nombre positions memorisees = ',NbPositionsMemoizees);
  WritelnNumDansRapport('Hauteur de l''arbre binaire de recherche =  ',ABRHauteur(memoisationInterversionsEnArriere.arbre));
  WritelnDansRapport('');

end;


procedure TestUnitInterversions;
var s,s1,s2 : String255;
    sh1,sh2 : PackedThorGame;
    longueurUtile : SInt16;
    interversion,autoVidage,ecritLog : boolean;
    nbInter,tick : SInt32;
    ok : boolean;
begin
  if FALSE then
    begin
		  s1 := 'F5D6C3D3C4B3';
		  s2 := 'F5D6C4D3C3B3';
		  WritelnDansRapport(s1);
		  WritelnDansRapport(s2);
		  TraductionAlphanumeriqueEnThor(s1,sh1);
		  TraductionAlphanumeriqueEnThor(s2,sh2);
		  RaccourcirInterversion(sh1,sh2,longueurUtile,interversion);
		  TraductionThorEnAlphanumerique(sh1,s1);
		  TraductionThorEnAlphanumerique(sh2,s2);
		  WritelnStringAndBoolDansRapport('result1 = '+s1+'  longueurUtile = '+NumEnString(longueurUtile)+' inter = ',interversion);
		  WritelnStringAndBoolDansRapport('result2 = '+s2+'  longueurUtile = '+NumEnString(longueurUtile)+' inter = ',interversion);
		  WritelnDansRapport('');

		  s1 := 'F5D6C3D3C4B3';
		  s2 := 'F5D6C4D3C3B1';
		  WritelnDansRapport(s1);
		  WritelnDansRapport(s2);
		  TraductionAlphanumeriqueEnThor(s1,sh1);
		  TraductionAlphanumeriqueEnThor(s2,sh2);
		  RaccourcirInterversion(sh1,sh2,longueurUtile,interversion);
		  TraductionThorEnAlphanumerique(sh1,s1);
		  TraductionThorEnAlphanumerique(sh2,s2);
		  WritelnStringAndBoolDansRapport('result1 = '+s1+'  longueurUtile = '+NumEnString(longueurUtile)+' inter = ',interversion);
		  WritelnStringAndBoolDansRapport('result2 = '+s2+'  longueurUtile = '+NumEnString(longueurUtile)+' inter = ',interversion);
		  WritelnDansRapport('');

		  s1 := 'F5D6C3D3C4B3';
		  s2 := 'F5D6C4D3C3F4';
		  WritelnDansRapport(s1);
		  WritelnDansRapport(s2);
		  TraductionAlphanumeriqueEnThor(s1,sh1);
		  TraductionAlphanumeriqueEnThor(s2,sh2);
		  RaccourcirInterversion(sh1,sh2,longueurUtile,interversion);
		  TraductionThorEnAlphanumerique(sh1,s1);
		  TraductionThorEnAlphanumerique(sh2,s2);
		  WritelnStringAndBoolDansRapport('result1 = '+s1+'  longueurUtile = '+NumEnString(longueurUtile)+' inter = ',interversion);
		  WritelnStringAndBoolDansRapport('result2 = '+s2+'  longueurUtile = '+NumEnString(longueurUtile)+' inter = ',interversion);
		  WritelnDansRapport('');

		  s1 := 'F5D6C3D3C4F4F6F3G4G5E3';
		  s2 := 'F5D6C4D3C3F4F6G5E3F3G4';
		  WritelnDansRapport(s1);
		  WritelnDansRapport(s2);
		  TraductionAlphanumeriqueEnThor(s1,sh1);
		  TraductionAlphanumeriqueEnThor(s2,sh2);
		  RaccourcirInterversion(sh1,sh2,longueurUtile,interversion);
		  TraductionThorEnAlphanumerique(sh1,s1);
		  TraductionThorEnAlphanumerique(sh2,s2);
		  WritelnStringAndBoolDansRapport('result1 = '+s1+'  longueurUtile = '+NumEnString(longueurUtile)+' inter = ',interversion);
		  WritelnStringAndBoolDansRapport('result2 = '+s2+'  longueurUtile = '+NumEnString(longueurUtile)+' inter = ',interversion);
		  WritelnDansRapport('');

    end;  {if FALSE then}

  autoVidage := GetAutoVidageDuRapport;
  ecritLog := GetEcritToutDansRapportLog;
  SetAutoVidageDuRapport(false);
  SetEcritToutDansRapportLog(false);


  trace := false;
  impassesLocales := AllocatePile(20000,ok);

  tick := TickCount;

  s := '';
  s := 'F5D6C3D3C4F4E3F3E6B4C6B3E2F2';
  {s := 'F5D6C3D3C4F4E3F3E6B4C6B3E2F2D2C5';}
  {s := 'F5D6C3F3D3D2E1F6F7G7H7';}
  {s := 'F5D6C3D3C4F4F6';}
  {s := 'F5D6C3D3C4F4F6F3E3G5G4';}
  {s := 'F5D6C5F4E3C6D3F6E6D7G3C4G5C3B4B3B5A5A4A3';}
  {s := 'F5D6C5F4E3C6D3F6E6D7G3C4G5C3';}
  {s := 'F5D6C3D3C4F4E6B4F3B3C6';}
  {s := 'E6F6F5F4C3D7F3D6G4C5C6C4';}
  {s := 'F5D6C4D3C3F4C5F6E3D2E6';}

  ChercheToutesInterversionsPartie(s,StringEnCoup('F5'),0,false,false,nbInter);

  {EcritSystemeMinimalInterversionsDansRapport(s,StringEnCoup('F5'),false,nbInter);}



{  tick := TickCount-tick;
  WritelnNumDansRapport('temps utilise = ',tick);}




  VideMemoisationInterversions;
  ViderImpasses;
  ChercheToutesInterversionsPartie(s,StringEnCoup('E6'),0,false,false,nbInter);
  VideMemoisationInterversions;
  ViderImpasses;
  ChercheToutesInterversionsPartie(s,StringEnCoup('C4'),0,false,false,nbInter);
  VideMemoisationInterversions;
  ViderImpasses;
  ChercheToutesInterversionsPartie(s,StringEnCoup('D3'),0,false,false,nbInter);


  DisposePile(impassesLocales);

  SetAutoVidageDuRapport(autoVidage);
  SetEcritToutDansRapportLog(ecritLog);
end;


procedure GererInterversionDeCeNoeud(G : GameTree; var position : PositionEtTraitRec);
var noeudDansTable : GameTree;
    hashIndex : InterversionHashIndexRec;
    positionVerification : PositionEtTraitRec;
    s,s1 : String255;
begin
  if GameTreeHasStandardInitialPosition then
    begin
		  if not(ExisteDansHashTableInterversions(position,noeudDansTable,hashIndex))
		    then
		      begin
		        MetDansHashTableInterversions(G,position,hashIndex);   {insertion dans la table de hashage}
		      end
		    else
		      begin
  		      if (noeudDansTable = G) then exit(GererInterversionDeCeNoeud);

  		      if ToujoursAjouterInterversionDansGrapheInterversions
  		        then
  		          begin
        		      if CreatePartieEnAlphaJusqua(noeudDansTable,s,positionVerification)
        			      then
        			        begin
        			          if SamePositionEtTrait(positionVerification,position)
          			          then
          		              begin
          		                FusionOrbitesInterversions(noeudDansTable,G);
          		                s1 := CoupsDuCheminJusquauNoeudEnString(G);
          		                EssaieAjouterInterversionPotentielle(s1,s,G);
          		              end
          		            else
          		              begin
          		                SetNbCollisionsInterversions(GetNbCollisionsInterversions+1);
          		                hashIndex.clef  := 0;
          		                hashIndex.stamp := 0;
          		                MetDansHashTableInterversions(G,position,hashIndex);
          		                MetDansHashTableInterversions(noeudDansTable,positionVerification,hashIndex);
          		                {WritelnNumDansRapport('nb Collisions Interversions = ',GetNbCollisionsInterversions);}
          		              end
          		        end
        			      else
        			        begin
        			          WritelnDansRapport('WARNING : not(GetPositionEtTraitACeNoeud(noeudDansTable,positionVerification)) dans GererInterversionDeCeNoeud');
        			        end;
        			  end
      			  else
      			    begin
      			      FusionOrbitesInterversions(noeudDansTable,G);
      			    end;
  			  end;
	  end;
end;


function TrouvePartieDansTableParties60(const s60 : PackedThorGame; table : TableParties60Ptr; var index : SInt16) : boolean;
var i : SInt16;
begin
  TrouvePartieDansTableParties60 := false;
  index := -1;

	for i := 1 to table^.cardinal do
		begin
		  if SAME_PACKED_GAMES(table^.table[i], s60) then
  		  begin
  		    TrouvePartieDansTableParties60 := true;
  		    index := i;
  		    exit(TrouvePartieDansTableParties60);
  		  end;
  end;
end;


procedure AjouterInterversionsOfGameTreeDansTable(G : GameTree; var table : TableParties60Ptr);
var aux : GameTree;
    autreCoupQuatre,trouve : boolean;
    s : String255;
    s60 : PackedThorGame;
    premierCoup,i,compteur : SInt16;
begin
  if (G <> NIL) & (G^.transpositionOrbite <> NIL) & (table <> NIL) &
     GameTreeHasStandardInitialPosition then
    begin
      ExtraitPremierCoup(premierCoup,autreCoupQuatre);
      aux := G; compteur := 0;
		  repeat
		    s := CoupsDuCheminJusquauNoeudEnString(aux);
	      TraductionAlphanumeriqueEnThor(s,s60);
	      if (table^.cardinal < 100) then
	        begin
			      trouve := TrouvePartieDansTableParties60(s60,table,i);
			      if not(trouve) then
	            begin
	              inc(table^.cardinal);
	              table^.table[table^.cardinal] := s60;
	            end;
	        end;
	      if (compteur >= 500) then
          begin
            AlerteSimple('boucle infinie (1) dans AjouterInterversionsOfGameTreeDansTable !! Prévenez Stéphane');
            exit(AjouterInterversionsOfGameTreeDansTable);
          end;
	      aux := aux^.transpositionOrbite;
	      compteur := compteur + 1;
		  until (aux = NIL) | (aux = G);
    end;
end;


var tablePartiesPourTri : TableParties60Ptr;

function LectureTriParties60(i : SInt32) : SInt32;
begin
  LectureTriParties60 := tablePartiesPourTri^.ref[i];
end;

procedure AffectationTriParties60(i,el : SInt32);
begin
  tablePartiesPourTri^.ref[i] := el;
end;

function CompareTriParties60(n1,n2 : SInt32) : boolean;
begin
  CompareTriParties60 := (COMPARE_PACKED_GAMES(tablePartiesPourTri^.table[n1],tablePartiesPourTri^.table[n2]) <= 0) ;
end;

procedure TrierTableParties60(table : TableParties60Ptr);
begin
  if (table <> NIL) & (table^.cardinal > 1) then
    begin
		  tablePartiesPourTri := table;
		  GeneralQuickSort(1,table^.cardinal,LectureTriParties60,AffectationTriParties60,CompareTriParties60);
		end;
end;

procedure EcrireTableParties60DansRapport(table : TableParties60Ptr);
var i : SInt16;
    s : String255;
begin
  if (table <> NIL) then
    begin
      WritelnNumDansRapport('orbite.cardinal = ',table^.cardinal);
		  for i := 1 to table^.cardinal do
		    begin
		      TraductionThorEnAlphanumerique(table^.table[table^.ref[i]],s);
		      WritelnDansRapport(s);
		    end;
		end;
end;

(* Si la fonction reussit, alors table contient
   les lignes de l'orbite maximale connue (arbre +
   graphe) triee, et index est l'entier > 0 tel
   que table^.table[table^.ref[index]]
   est la ligne de l'arbre menant a GameNode *)
function CalculeCycleTrieDesInterversions(whichNode : GameTree; var table : TableParties60Ptr; var index : SInt16) : boolean;
var whichGame,s : String255;
    s60 : PackedThorGame;
    whichPosition : PositionEtTraitRec;
    premierCoup,k,i : SInt16;
    autreCoupQuatreDiagDansPartie : boolean;
begin

  CalculeCycleTrieDesInterversions := false;
  table^.cardinal := 0;
  index := -1;

  if GameTreeHasStandardInitialPosition &
     CreatePartieEnAlphaJusqua(whichNode,whichGame,whichPosition) &
     (LENGTH_OF_STRING(whichGame) > 0)
    then
      begin

			  if InterversionDansLeGrapheApprentissage(whichGame,false,table) then
			    begin

			      ExtraitPremierCoup(premierCoup,autreCoupQuatreDiagDansPartie);

			      if autreCoupQuatreDiagDansPartie &
			         (GET_LENGTH_OF_PACKED_GAME(table^.table[1]) >= 4) then
			        for i := 1 to table^.cardinal do
			          begin
			            s60 := table^.table[i];

			            (** Astuce : on sait deja que l'on a une diagonale. Pour trouver
			                         si la partie commence par E6F6F5 ou bien par D3C3C4, on
			                         peut tester les coups 1 à 3 a l'envers *)
			            s := CoupEnStringEnMajuscules(GET_NTH_MOVE_OF_PACKED_GAME(s60, 3, 'CalculeCycleTrieDesInterversions(3)')) +
			                 CoupEnStringEnMajuscules(GET_NTH_MOVE_OF_PACKED_GAME(s60, 2, 'CalculeCycleTrieDesInterversions(2)')) +
			                 CoupEnStringEnMajuscules(GET_NTH_MOVE_OF_PACKED_GAME(s60, 1, 'CalculeCycleTrieDesInterversions(1)'));

			            if Pos(s,whichGame) = 1 then
			              SymetriserPartieFormatThor(s60,axeSE_NW,1,3);

			            table^.table[i] := s60;
			          end;


			      AjouterInterversionsOfGameTreeDansTable(whichNode,table);
			      TrierTableParties60(table);
			      {EcrireTableParties60DansRapport(table);}
			      TraductionAlphanumeriqueEnThor(whichGame,s60);

			      if TrouvePartieDansTableParties60(s60,table,k) &
			         (table^.cardinal > 0) then
			        begin
			          for i := 1 to table^.cardinal do
			            if (table^.ref[i] = k) then
			              index := i;

			          CalculeCycleTrieDesInterversions := true;
					    end;
			    end;
			end;

end;


procedure CyclerDansOrbiteInterversionDuGraphe(whichNode : GameTree; avancerDansOrbite : boolean);
var gameNodeLePlusProfond : GameTree;
    s : String255;
    s60 : PackedThorGame;
    whichPosition,positionTestee : PositionEtTraitRec;
    aux : PositionEtTraitRec;
    index : SInt16;
    longueur,indexPrime,typeErreur,longueurOrbite : SInt32;
    compteurProp : Property;
    changed : boolean;
    oldCheckDangerousEvents : boolean;
begin

  SetCassioMustCheckDangerousEvents(false,@oldCheckDangerousEvents);

  if CalculeCycleTrieDesInterversions(whichNode,tableLignes,index) &
     GetPositionEtTraitACeNoeud(whichNode, whichPosition, 'CyclerDansOrbiteInterversionDuGraphe {1}') then
    begin

      longueurOrbite := tableLignes^.cardinal;

      if avancerDansOrbite
        then indexPrime := index + 1
        else indexPrime := index - 1;
      while (indexPrime < 1) do
        indexPrime := indexPrime + longueurOrbite;
      while (indexPrime > longueurOrbite) do
        indexPrime := indexPrime - longueurOrbite;

      s60 := tableLignes^.table[tableLignes^.ref[indexPrime]];
      TraductionThorEnAlphanumerique(s60,s);

      longueur := LENGTH_OF_STRING(s) div 2;

      aux := PositionEtTraitAfterMoveNumberAlpha(s,longueur,typeErreur);

      if SamePositionEtTrait(whichPosition, aux)
        then
          begin
            SetEnTrainDeRejouerUneInterversion(true);
            SetLongueurInterversionEnTrainDEtreRejouee(longueur);
            RejouePartieOthello(s,longueur,true,bidPlat,0,gameNodeLePlusProfond,true,true);
            SetEnTrainDeRejouerUneInterversion(false);

            if GetPositionEtTraitACeNoeud(gameNodeLePlusProfond, positionTestee, 'CyclerDansOrbiteInterversionDuGraphe {2}') &
               SamePositionEtTrait(positionTestee,whichPosition)
              then
                begin
                  FusionOrbitesInterversions(whichNode,gameNodeLePlusProfond);

                  {on rajoute les property "1/7" et "2/7"}
                  compteurProp := MakeCoupleLongintProperty(TranspositionRangeProp,index,longueurOrbite);
                  OverWritePropertyToGameTree(compteurProp,whichNode,changed);
                  DisposePropertyStuff(compteurProp);

                  compteurProp := MakeCoupleLongintProperty(TranspositionRangeProp,indexPrime,longueurOrbite);
                  OverWritePropertyToGameTree(compteurProp,gameNodeLePlusProfond,changed);
                  DisposePropertyStuff(compteurProp);

                  {redessiner}
                  if changed & (GetAffichageProprietesOfCurrentNode <> kAucunePropriete) then
                    begin
                      EffaceNoeudDansFenetreArbreDeJeu;
                      LireBibliothequeDeZebraPourCurrentNode('CyclerDansOrbiteInterversionDuGraphe');
                      EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
                    end;
                end
              else
                WritelnDansRapport('Should NEVER happen in CyclerDansOrbiteInterversionDuGraphe…');
          end
        else
          begin
            SysBeep(0);
            WritelnDansRapport('ERREUR dans CyclerDansOrbiteInterversionDuGraphe : positions differentes!!');
          end;

    end;

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
end;


procedure EcrireInterversionsDuGrapheCeNoeudDansRapport(whichNode : GameTree);
var index : SInt16;
    position : PositionEtTraitRec;
    compteurProp : Property;
    bidlong : SInt32;
    changed : boolean;
begin

  if CalculeCycleTrieDesInterversions(whichNode,tableLignes,index) &
     GetPositionEtTraitACeNoeud(whichNode, position, 'EcrireInterversionsDuGrapheCeNoeudDansRapport') then
    begin

      compteurProp := MakeCoupleLongintProperty(TranspositionRangeProp,index,tableLignes^.cardinal);
      OverWritePropertyToGameTree(compteurProp,whichNode,changed);
      DisposePropertyStuff(compteurProp);
      if changed & (GetAffichageProprietesOfCurrentNode <> kAucunePropriete) then
        begin
          EffaceNoeudDansFenetreArbreDeJeu;
          LireBibliothequeDeZebraPourCurrentNode('EcrireInterversionsDuGrapheCeNoeudDansRapport');
          EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
        end;

      {mettre dans rapport ?}
      if not(MemberOfPositionEtTraitSet(position,bidlong,PositionsDontOnAEcritLOrbite)) then
        begin
          AddPositionEtTraitToSet(position,0,PositionsDontOnAEcritLOrbite);
          (*
          WritelnDansRapport('');
          WritelnDansRapport('position touchée =');
          WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
          EcrireTableParties60DansRapport(tableLignes);
          *)
        end;
    end;
end;

procedure SetEnTrainDeRejouerUneInterversion(flag : boolean);
begin
  gEnTrainDeRejouerUneInterversion := flag;
end;

function EstEnTrainDeRejouerUneInterversion : boolean;
begin
  EstEnTrainDeRejouerUneInterversion := gEnTrainDeRejouerUneInterversion;
end;


procedure SetLongueurInterversionEnTrainDEtreRejouee(longueur : SInt32);
begin
  gLongueurInterversionEnTrainDEtreRejouee := longueur;
end;

function LongueurInterversionEnTrainDEtreRejouee : SInt32;
begin
  LongueurInterversionEnTrainDEtreRejouee := gLongueurInterversionEnTrainDEtreRejouee;
end;

procedure VidePositionsDontOnAEcritLOrbite;
begin
  DisposePositionEtTraitSet(PositionsDontOnAEcritLOrbite);
end;


function ToujoursAjouterInterversionDansGrapheInterversions : boolean;
begin
  ToujoursAjouterInterversionDansGrapheInterversions := gToujoursAjouterInterversionDansGrapheInterversions;
end;


procedure SetToujoursAjouterInterversionDansGrapheInterversions(flag : boolean);
begin
  gToujoursAjouterInterversionDansGrapheInterversions := flag;
end;


procedure TraiteInterversionFormatThorCompile(var whichGame : PackedThorGame);
var nroInterversion,t,i : SInt32;
    compare,canonique : String255;
    longueurEnCours,lengthOfTheGame : SInt32;
begin
  lengthOfTheGame := GET_LENGTH_OF_PACKED_GAME(whichGame);

  for i := NbinterversionsCompatibles downto 1 do
    begin
      nroInterversion := interversionsCompatibles[i];
      compare := interversionFautive^^[nroInterversion];
      longueurEnCours := LENGTH_OF_STRING(compare);

      if (longueurEnCours > 1) & (longueurEnCours <= lengthOfTheGame) then
        begin
          t := longueurEnCours;
          while (compare[t] = chr(GET_NTH_MOVE_OF_PACKED_GAME(whichGame,t, 'TraiteInterversionFormatThorCompile'))) do
            dec(t);
          if (t <= 1) then
            begin
              canonique := interversionCanonique^^[nroInterversion];
              MoveMemory(@canonique[1],GET_ADRESS_OF_FIRST_MOVE(whichGame),longueurEnCours);
            end;
        end;
    end;
end;


procedure TraiteInterversionFormatThor(var whichGame : PackedThorGame; longueur : SInt16);
var nroInterversion,t : SInt32;
    compare,canonique : String255;
    longueurEnCours,lengthOfTheGame : SInt32;
begin
  lengthOfTheGame := GET_LENGTH_OF_PACKED_GAME(whichGame);

  if longueur > 33 then longueur := 33;

  for nroInterversion := 1 to numeroInterversion[longueur] do
    begin
      compare := interversionFautive^^[nroInterversion];
      longueurEnCours := LENGTH_OF_STRING(compare);

      if (longueurEnCours > 1) & (longueurEnCours <= lengthOfTheGame) then
        begin
          t := longueurEnCours;
          while (compare[t] = chr(GET_NTH_MOVE_OF_PACKED_GAME(whichGame,t, 'TraiteInterversionFormatThor'))) do
            dec(t);
          if t <= 1 then
            begin
              canonique := interversionCanonique^^[nroInterversion];
              MoveMemory(@canonique[1],GET_ADRESS_OF_FIRST_MOVE(whichGame),longueurEnCours);
            end;
        end;
    end;
end;


procedure PrecompileInterversions(var whichGame : PackedThorGame; longueur : SInt16);
var nroInterversion,t,i,nbInterARegarder : SInt32;
    compare,canonique : String255;
    longueurEnCours,lengthOfTheGame : SInt32;
    encoreUtile : boolean;
begin
  {
  if debuggage.general then
    begin
      TraductionThorEnAlphanumerique(whichGame,s255);
      s255 := s255+'  avant precompile   ';
      WriteNumAt(s255,0,10,120);
    end;
  }

  NbinterversionsCompatibles := 0;

  if (longueur < 3) then
    exit(PrecompileInterversions);

  if longueur > 33 then longueur := 33;

  lengthOfTheGame := GET_LENGTH_OF_PACKED_GAME(whichGame);

  nbInterARegarder := numeroInterversion[longueur];
  nroInterversion := 0;
  repeat
    inc(nroInterversion);
    compare := interversionFautive^^[nroInterversion];
    longueurEnCours := LENGTH_OF_STRING(compare);

    if (longueurEnCours > 1) & (longueurEnCours <= lengthOfTheGame) then
      begin
        t := longueurEnCours;
        while (compare[t] = chr(GET_NTH_MOVE_OF_PACKED_GAME(whichGame,t, 'PrecompileInterversions(1)'))) do
          dec(t);
        if t <= 1 then
          begin
            canonique := interversionCanonique^^[nroInterversion];
            MoveMemory(@canonique[1],GET_ADRESS_OF_FIRST_MOVE(whichGame),longueurEnCours);
            nroInterversion := numeroInterversion[longueurEnCours];
          end;
      end;
  until (nroInterversion >= nbInterARegarder);

  {
  if debuggage.general then
    begin
      TraductionThorEnAlphanumerique(whichGame,s255);
      s255 := s255+'  apres precompile   ';
      WriteNumAt(s255,0,10,132);
    end;
  }

  lengthOfTheGame := GET_LENGTH_OF_PACKED_GAME(whichGame);

  NbinterversionsCompatibles := 0;
  for nroInterversion := numeroInterversion[longueur] downto 1 do
    begin
      canonique := interversionCanonique^^[nroInterversion];
      canonique[1] := chr(132);    { sentinelle }
      longueurEnCours := LENGTH_OF_STRING(canonique);

      t := longueurEnCours;
      if (longueurEnCours > 1) & (longueurEnCours <= lengthOfTheGame) then
        begin
          while (canonique[t] = chr(GET_NTH_MOVE_OF_PACKED_GAME(whichGame,t, 'PrecompileInterversions(2)'))) do
            dec(t);
        end;

      if t <= 1
        then
          begin
            inc(NbinterversionsCompatibles);
            interversionsCompatibles[NbinterversionsCompatibles] := nroInterversion;
          end
        else
          begin
            encoreUtile := true;
            for i := 1 to NbinterversionsCompatibles do
              if encoreUtile then
              begin
                compare := interversionFautive^^[interversionsCompatibles[i]];
                compare[1] := chr(151);   { sentinelle }
                t := longueurEnCours;
                while canonique[t] = compare[t] do dec(t);
                if t <= 1 then
                  begin
                    inc(NbinterversionsCompatibles);
                    interversionsCompatibles[NbinterversionsCompatibles] := nroInterversion;
                    encoreutile := false;
                  end;
              end;
          end;
    end;
  {WritelnNumDansRapport('NbinterversionsCompatibles = ',NbinterversionsCompatibles);}

  {
  t := 0;
  for i := 3 to 33 do
    begin
      WriteNumDansRapport('numeroInterversion[',i);
      WritelnNumDansRapport('] = ',numeroInterversion[i]);
      t := t + i*(numeroInterversion[i]-numeroInterversion[i-1]);
      WritelnNumDansRapport('t = ',t);
    end;
  }
end;


procedure TraiteIntervertionsCoups(var s : String255);
var s60 : PackedThorGame;
    s255 : String255;
begin
  s255 := s;
  TraductionAlphanumeriqueEnThor(s255,s60);
  TraiteInterversionFormatThor(s60,GET_LENGTH_OF_PACKED_GAME(s60));
  TraductionThorEnAlphanumerique(s60,s255);
  s := s255;
end;


procedure InterversionPuisNormalisation(var partie120 : String255; var autreCoupQuatreDiag : boolean);
var charAux : char;
    nbrecoupDansPartie,i : SInt16;
begin
  nbrecoupDansPartie := LENGTH_OF_STRING(partie120) div 2;
  if nbrecoupDansPartie > 0 then
  begin
    TraiteIntervertionsCoups(partie120);
    if nbrecoupDansPartie >= 4 then
         begin
           if Pos('F5F6E6D6',partie120) = 1 then
             begin
               autreCoupQuatreDiag := true;
               for i := 4 to nbrecoupDansPartie do
                 begin
                   charAux := chr(ord(partie120[2*i-1])-16);
                   partie120[2*i-1] := chr(ord(partie120[2*i])+16);
                   partie120[2*i] := charAux;
                 end;
             end;
         end;
   end;
end;


procedure AjouterInterversion(variante,canonique : String255);
var longueur,i : SInt16;
    fautivePacked,principalePacked,auxPacked : PackedThorGame;
    fautive,principale : String255;
    fautive60 : String255;
    autreCoupDiagFaut,autreCoupDiagPrinc,dejaRentree : boolean;
    fautiveEstLegale,princEstLegale : boolean;
    nbInterversion : SInt16;
    platFaut,platPrinc : plateauOthello;
    nbCoupsLegauxFaut,nbCoupsLegauxPrinc : SInt32;
begin
  dejaRentree := false;
  fautive := variante;
  principale := canonique;

  if DoitEcrireInterversions then
    begin
      Normalisation(fautive,autreCoupDiagFaut,false);    {enlever les commentaires pour la moulinette}
      Normalisation(principale,autreCoupDiagPrinc,false);
    end;

  CalculePositionFinale(fautive,platFaut,fautiveEstLegale,nbCoupsLegauxFaut);
  CalculePositionFinale(principale,platPrinc,princEstLegale,nbCoupsLegauxPrinc);
  if not(fautiveEstLegale & princEstLegale) then
    begin
      AlerteSimple(' ligne illégale : '+fautive+' ou '+principale);
      exit(ajouterInterversion);
    end;
  if not(PositionsEgales(platFaut,platPrinc)) then
    begin
      AlerteSimple(fautive+' <> '+principale);
      exit(ajouterInterversion);
    end;

  TraductionAlphanumeriqueEnThor(fautive,fautivePacked);
  TraductionAlphanumeriqueEnThor(principale,principalePacked);

  if DoitEcrireInterversions then
    begin
      TraiteInterversionFormatThor(fautivePacked,GET_LENGTH_OF_PACKED_GAME(fautivePacked));
      TraiteInterversionFormatThor(principalePacked,GET_LENGTH_OF_PACKED_GAME(principalePacked));
    end;

  longueur := GET_LENGTH_OF_PACKED_GAME(fautivePacked);
  nbInterversion := numeroInterversion[33];
  dejaRentree := SAME_PACKED_GAMES(fautivePacked, principalePacked);

  if (longueur <= 33) then
    begin
      if not(dejaRentree) then
         begin
           if DoitEcrireInterversions then
             begin
               COPY_PACKED_GAME_TO_STR60(fautivePacked,fautive60);
               for i := 1 to nbInterversion do
                 begin
                   if (fautive60 = interversionCanonique^^[i]) then
                     begin
                       auxPacked        := principalePacked;
                       principalePacked := fautivePacked;
                       fautivePacked    := auxPacked;
                       SysBeep(0);
                       WriteNumAt('mauvais ordre !!! '+ variante+'  ',GET_LENGTH_OF_PACKED_GAME(fautivePacked),10,100);
                       AttendFrappeClavier;
                     end;
                 end;
             end;

           if nbInterversion < nbMaxInterversions then
             begin
               nbInterversion := nbInterversion+1;
               COPY_PACKED_GAME_TO_STR60(fautivePacked,    interversionFautive^^[nbInterversion]);
               COPY_PACKED_GAME_TO_STR60(principalePacked, interversionCanonique^^[nbInterversion]);
               for i := longueur to 33 do
                 numeroInterversion[i] := nbInterversion;
               interversionFautive^^[nbInterversion][1] := chr(230);   {•• sentinelle ••}
             end;
         end;
    end
    else
    begin
      WriteNumAt('ligne trop longue !!!  '+variante, longueur,10,50);
      SysBeep(0);
      dejaRentree := true;
    end;
end;


end.
