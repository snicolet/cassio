UNIT UnitArbreDeJeuCourant;






INTERFACE







 USES
     {$IFC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL}
     Profiler ,
     {$ENDC}
     UnitDefCassio;




{Initialisation et destruction de l'unité}
procedure InitUnitArbreDeJeuCourant;
procedure LibereMemoireUnitArbreDeJeuCourant;


{fonctions d'acces de l'arbre et du noeud courant}
function GetCurrentNode : GameTree;
function GetRacineDeLaPartie : GameTree;
function EstLaRacineDeLaPartie(G : GameTree) : boolean;
function NbDeFilsOfCurrentNode : SInt16;
function GetCurrentSons : GameTreeList;


{fonction d'initialisation de l'arbre de jeu courant}
procedure ReInitialiseGameRootGlobalDeLaPartie;
procedure SetCurrentNodeToGameRoot;


{fonctions de modification de l'arbre de jeu courant}
procedure SetSonsOfCurrentNode(theSons : GameTreeList);
procedure DeleteSonOfCurrentNode(var whichSon : GameTree);
procedure DeleteAllSonsOfCurrentNode;
procedure BringSonOfCurrentNodeToFront(whichSon : GameTree);
procedure BringSonOfCurrentNodeInPositionN(whichSon : GameTree;N : SInt16);
function DeleteSonsOfThatColorInCurrentNode(couleur : SInt16) : SInt16;
procedure JumpToPosition(var G : GameTree);


{utilitaires sur les PositionsEtTraitRec}
function PlayMoveProperty(prop : Property; var positionEtTrait : PositionEtTraitRec) : boolean;


{fonctions de gestion des proprietes l'arbre de jeu}
procedure GetPropertyListOfCurrentNode(var L : PropertyList);
procedure SetPropertyListOfCurrentNode(L : PropertyList);
procedure AddPropertyToCurrentNode(prop : Property);
procedure AddPropertyToCurrentNodeSansDuplication(prop : Property);
procedure AddScorePropertyToCurrentNodeSansDuplication(prop : Property);
procedure DeletePropertyFromCurrentNode(prop : Property);
procedure DeletePropertiesOfTheseTypeFromCurrentNode(whichType : SInt16);
procedure DeletePropertiesOfTheseTypesFromCurrentNode(whichTypes : SetOfPropertyTypes);
function SelectFirstPropertyOfTypesInCurrentNode(whichTypes : SetOfPropertyTypes) : PropertyPtr;
function SelectPropertyInCurrentNode(choice : PropertyPredicate; var result : SInt32) : PropertyPtr;


{iterateur sur les proprietes d'un noeud ou du noeud courant}
procedure ForEachPropertyOfTheseTypesInCurrentNodeDo(whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProc);
procedure ForEachPositionOnPathToGameNodeDo(G : GameTree ; DoWhat : GameTreeProcAvecResult);
procedure ForEachPositionOnPathToCurrentNodeDo(DoWhat : GameTreeProcAvecResult);


{fonction de navigation dans l'arbre de jeu courant}
function ChangeCurrentNodeAfterThisMove(square,couleur : SInt16; const fonctionAppelante : String255; var isNew : boolean) : OSErr;
function ChangeCurrentNodeAfterNewMove(square,couleur : SInt16; const fonctionAppelante : String255) : OSErr;
procedure ChangeCurrentNodeForBackMove;
procedure DoChangeCurrentNodeBackwardUntil(G : GameTree);
procedure SetCurrentNode(G : GameTree; const fonctionAppelante : String255);


{fonction de symetrie}
procedure EffectueSymetrieArbreDeJeuGlobal(axeSymetrie : SInt32);


{fonctions de gestion des positions initiales}
procedure SetPositionInitialeOfGameTree(position : plateauOthello; trait,nbBlancs,nbNoirs : SInt16);
procedure SetPositionInitialeStandardDansGameTree;
procedure GetPositionInitialeOfGameTree(var position : plateauOthello; var numeroPremierCoup,trait,nbBlancs,nbNoirs : SInt32);
function GetPositionEtTraitInitiauxOfGameTree : PositionEtTraitRec;
function PositionIsTheInitialPositionOfGameTree(var whichPos : PositionEtTraitRec) : boolean;
function GameTreeHasStandardInitialPosition : boolean;
function GameTreeHasStandardInitialPositionInversed : boolean;
procedure CalculePositionInitialeFromThisRoot(whichRoot : GameTree);
function CalculeNouvellePositionInitialeFromThisList(L : PropertyList; var jeu : plateauOthello; var numeroPremierCoup,trait,nbBlancs,nbNoirs : SInt32) : boolean;
procedure AjouteDescriptionPositionEtTraitACeNoeud(description : PositionEtTraitRec; G : GameTree);
procedure DeleteDescriptionPositionEtTraitDeCeNoeud(G : GameTree);


{fonctions de gestions des infos standard dans les fichiers SGF}
procedure AddInfosStandardsFormatSGFDansArbre;
function GetApplicationNameDansArbre(var name : String255; var version : String255) : boolean;


{fonctions d'ajout de properties dans la racine de l'arbre }
procedure OverWritePropertyToRoot(prop : Property; var changed : boolean);
procedure AddPropertyToRoot(prop : Property);


{fonctions d'ajout de properties dans un noeud de l'arbre }
function AddPropertyAsStringDansCeNoeud(var G : GameTree; propertyDescription : String255) : boolean;
function DeletePropertyAsStringDansCeNoeud(var G : GameTree; propertyDescription : String255) : boolean;
function AddPropertyListAsStringDansCeNoeud(var G : GameTree; propertyListDescription : String255) : boolean;
function AddPropertyListAsStringDansCurrentNode(propertyListDescription : String255) : boolean;


{gestions des commentaires}
function NoeudHasCommentaire(G : GameTree) : boolean;
procedure DeleteCommentaireDeCeNoeud(var G : GameTree);
procedure GetCommentaireDeCeNoeud(G : GameTree; var texte : Ptr; var longueur : SInt32);
procedure SetCommentaireDeCeNoeud(var G : GameTree; texte : Ptr; longueur : SInt32);
procedure SetCommentaireDeCeNoeudFromString(var G : GameTree; s : String255);
function CurrentNodeHasCommentaire : boolean;
procedure DeleteCommentaireCurrentNode;
procedure GetCommentaireCurrentNode(var texte : Ptr; var longueur : SInt32);
procedure SetCommentaireCurrentNode(texte : Ptr; longueur : SInt32);
procedure SetCommentaireCurrentNodeFromString(s : String255);
procedure SetCommentairesCurrentNodeFromFenetreArbreDeJeu;


{commandes textuelles pour l'arbre de jeu}
function TrouveCommandeDansCommentaireDansFenetreArbreDeJeu(var commande,argument : String255) : boolean;
procedure ExecuteCommandeArbreDeJeu(G : GameTree; commande,argument : String255);


{fonctions calculant une position dans l'arbre, le trait ou les pions retournes}
function CreateListeDesCoupsJusqua(G : GameTree) : PropertyList;
function CreatePartieEnAlphaJusqua(G : GameTree; var partieAlpha : String255; var positionTerminale : PositionEtTraitRec) : boolean;
function GetPositionEtTraitACeNoeud(G : GameTree; var position : PositionEtTraitRec; const fonctionAppelante : String255) : boolean;
function GetCouleurOfCurrentNode : SInt32;
function VerifieHomogeneiteDesCouleurs(G : GameTree; problemePourLesCoupsVides : boolean) : SInt16;
(*function GetFlippedDiscsAtThisNode(G : GameTree) : SquareSet;*)


{fonctions pour rajouter/lire un score ou une ligne parfaite dans l'arbre courant}
procedure AjoutePropertyValeurDeCoupDansCurrentNode(quelGenreDeReflexion,scorePourNoir : SInt32);
function SelectScorePropertyOfCurrentNode : PropertyPtr;
procedure AjouteMeilleureSuiteDansGameTree(genreReflexion : SInt32; meilleureSuite : String255; scoreDeNoir : SInt32; G : GameTree; exclamation : boolean; virtualite : SInt16);
procedure AjouteMeilleureSuiteDansArbreDeJeuCourant(genreReflexion : SInt32; meilleureSuite : String255; scoreDeLaLignePourNoir : SInt32);
procedure MarquerCurrentNodeCommeVirtuel;
procedure MarquerCurrentNodeCommeReel(const fonctionAppelante : String255);
function PeutCalculerFinaleParfaiteParArbreDeJeuCourant(var listeDesCoups : PropertyList; var valeurCouranteMin,valeurCouranteMax : SInt32) : boolean;



{recherche dans l'arbre de jeu}
procedure FindStringDansArbreDeJeuCourant(const s : String255; ignoreCase : boolean);
procedure ChercherLeProchainNoeudAvecBeaucoupDeFils(nbreDeFils : SInt32);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils, MacMemory, DateTimeUtils, Sound, Dialogs
{$IFC NOT(USE_PRELINK)}
    , UnitHashTableExacte, UnitRapport, UnitJeu, UnitPierresDelta
    , UnitProperties, UnitRapportImplementation, UnitAffichageArbreDeJeu, UnitActions, UnitStrategie, UnitEndgameTree, UnitFenetres, UnitInterversions
    , UnitServicesDialogs, UnitMiniProfiler, MyStrings, UnitSetUp, UnitGestionDuTemps, UnitScannerUtils, UnitCarbonisation, UnitPositionEtTrait
    , UnitEnvirons, UnitSquareSet, UnitGameTree, UnitPropertyList, UnitEnvirons ;
{$ELSEC}
    ;
    {$I prelink/ArbreDeJeuCourant.lk}
{$ENDC}


{END_USE_CLAUSE}



var RacineDeLaPartie:
       record
         RacineArbre                : GameTree;
         InitialPosition            : plateauOthello;
         TraitInitial               : SInt16;
         nbPionsBlancsInitial       : SInt16;
         nbPionsNoirsInitial        : SInt16;
         initialPositionIsStandard  : boolean;
       end;
    GameTreeCourant : GameTree;
    gDoitEcrireMessageDeTransfoArbreDansRapport : boolean;



procedure InitUnitArbreDeJeuCourant;
begin
  avecAlerteSoldeCreationDestructionNonNul := true;
  SoldeCreationProperties := 0;
  SoldeCreationPropertyList := 0;
  SoldeCreationGameTree := 0;
  SoldeCreationGameTreeList := 0;

  RacineDeLaPartie.RacineArbre := NewGameTree;
  GameTreeCourant              := RacineDeLaPartie.RacineArbre;

  gDoitEcrireMessageDeTransfoArbreDansRapport := false;

  CreeTableHachageInterversions;
  VideTableHashageInterversions;
  SetNbCollisionsInterversions(0);

end;

procedure LibereMemoireUnitArbreDeJeuCourant;
begin
  {if GameTreeCourant <> NIL              then DisposeGameTree(GameTreeCourant);}
  if RacineDeLaPartie.RacineArbre <> NIL then DisposeGameTree(RacineDeLaPartie.RacineArbre);
  DisposeTableHachageInterversions;
end;

procedure DisposeGameTreeGlobalDeLaPartie;
var grow,TaillePlusGrandBloc : Size;
{$IFC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL}
    nomFichierProfileDisposeGameTree : String255;
{$ENDC}
begin
  {WritelnSoldesCreationsPropertiesDansRapport('en entrant dans DisposeGameTreeGlobalDeLaPartie, ');
  WritelnNumDansRapport('avant MaxMem, FreeMem = ',FreeMem);}

  TaillePlusGrandBloc := MaxMem(grow);

  {
  WritelnNumDansRapport('apres MaxMem, FreeMem = ',FreeMem);
  WritelnNumDansRapport('apres MaxMem, grow = ',grow);
  WritelnNumDansRapport('apres MaxMem, TaillePlusGrandBloc = ',TaillePlusGrandBloc);
  }

  {if GameTreeCourant <> NIL              then DisposeGameTree(GameTreeCourant);}


{$IFC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr
    then ProfilerSetStatus(1);
{$ENDC}

  if RacineDeLaPartie.RacineArbre <> NIL then DisposeGameTree(RacineDeLaPartie.RacineArbre);

{$IFC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL}
  nomFichierProfileDisposeGameTree := 'dispose_game_tree_' + IntToStr(Tickcount div 60) + '.profile';
  WritelnDansRapport('nomFichierProfileDisposeGameTree = '+nomFichierProfileDisposeGameTree);
  if ProfilerDump(nomFichierProfileDisposeGameTree) <> NoErr
    then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfileDisposeGameTree+') a échoué !')
    else ProfilerSetStatus(0);
  ProfilerTerm;
{$ENDC}

  if avecAlerteSoldeCreationDestructionNonNul and
     ((SoldeCreationProperties <> 0) or (SoldeCreationPropertyList <> 0) or
      (SoldeCreationGameTree <> 0) or (SoldeCreationGameTreeList <> 0)) then
    begin
      AlerteSimple('Erreur dans le solde creations-destruction de memoire, voir le rapport !!! Prévénez Stéphane');
		  WritelnSoldesCreationsPropertiesDansRapport('Erreur : en sortant de DisposeGameTreeGlobalDeLaPartie, ');
    end;



  {
  WritelnNumDansRapport('avant MaxMem, FreeMem = ',FreeMem);
  }

  TaillePlusGrandBloc := MaxMem(grow);

  {WritelnNumDansRapport('apres MaxMem, FreeMem = ',FreeMem);
  WritelnNumDansRapport('apres MaxMem, grow = ',grow);}
  {WritelnNumDansRapport('apres MaxMem, mémoire disponible = ',TaillePlusGrandBloc);}
  {WritelnNumDansRapport('apres MaxMem, FreeMem = ',FreeMem);}



end;

procedure ReInitialiseGameRootGlobalDeLaPartie;
begin
  DisposeGameTreeGlobalDeLaPartie;
  RacineDeLaPartie.RacineArbre := NewGameTree;
  GameTreeCourant              := RacineDeLaPartie.RacineArbre;
  SetPositionInitialeStandardDansGameTree;
  VideTableHashageInterversions;
end;



function PlayMoveProperty(prop : Property; var positionEtTrait : PositionEtTraitRec) : boolean;
var traitProp,coup : SInt32;
    traitPosition : SInt32;
    ok : boolean;
begin
  PlayMoveProperty := true;

  if (prop.genre = BlackMoveProp) then traitProp := pionNoir else
  if (prop.genre = WhiteMoveProp) then traitProp := pionBlanc else
    begin
      PlayMoveProperty := false;
      exit;
    end;

  traitPosition := GetTraitOfPosition(positionEtTrait);

  if (traitProp <> traitPosition) then
    begin
      PlayMoveProperty := false;
      exit;
    end;

  coup := GetOthelloSquareOfProperty(prop);
  if (coup < 11) or (coup > 88) then
    begin
      PlayMoveProperty := false;
      exit;
    end;

  ok := (positionEtTrait.position[coup] = pionVide) and
        UpdatePositionEtTrait(positionEtTrait,coup);
  if not(ok) then
    begin
      PlayMoveProperty := false;
      exit;
    end;
end;




procedure GetPropertyListOfCurrentNode(var L : PropertyList);
begin
  if GameTreeCourant = NIL
    then L := NIL
    else L := GameTreeCourant^.properties;
end;


procedure SetPropertyListOfCurrentNode(L : PropertyList);
begin
  if GameTreeEstVide(GameTreeCourant)
    then GameTreeCourant := MakeGameTreeFromPropertyList(L)
    else GameTreeCourant^.properties := L;
end;


procedure AddPropertyToCurrentNode(prop : Property);
begin
  AddPropertyToGameTree(prop,GameTreeCourant);
end;

procedure AddPropertyToCurrentNodeSansDuplication(prop : Property);
begin
  AddPropertyToGameTreeSansDuplication(prop,GameTreeCourant);
end;

procedure AddScorePropertyToCurrentNodeSansDuplication(prop : Property);
begin
  AddScorePropertyToGameTreeSansDuplication(prop,GameTreeCourant);
end;


procedure DeletePropertyFromCurrentNode(prop : Property);
begin
  DeletePropertyFromGameNode(prop,GameTreeCourant);
end;

procedure DeletePropertiesOfTheseTypeFromCurrentNode(whichType : SInt16);
begin
  DeletePropertiesOfTheseTypeFromGameNode(whichType,GameTreeCourant);
end;

procedure DeletePropertiesOfTheseTypesFromCurrentNode(whichTypes : SetOfPropertyTypes);
begin
  DeletePropertiesOfTheseTypesFromGameNode(whichTypes,GameTreeCourant);
end;

function SelectFirstPropertyOfTypesInCurrentNode(whichTypes : SetOfPropertyTypes) : PropertyPtr;
var L : PropertyList;
begin
  GetPropertyListOfCurrentNode(L);
  SelectFirstPropertyOfTypesInCurrentNode := SelectFirstPropertyOfTypes(whichTypes,L);
end;

function SelectPropertyInCurrentNode(choice : PropertyPredicate; var result : SInt32) : PropertyPtr;
var L : PropertyList;
begin
  GetPropertyListOfCurrentNode(L);
  SelectPropertyInCurrentNode := SelectInPropertList(L,choice,result);
end;

procedure ForEachPropertyOfTheseTypesInCurrentNodeDo(whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProc);
var L,L2 : PropertyList;
begin
   GetPropertyListOfCurrentNode(L);
	 L2 := ExtractPropertiesOfTypes(whichTypes,L);
	 ForEachPropertyInListDo(L2,DoWhat);
	 DisposePropertyList(L2);
end;


function GetCurrentNode : GameTree;
begin
  GetCurrentNode := GameTreeCourant;
end;


function GetRacineDeLaPartie : GameTree;
begin
  GetRacineDeLaPartie := RacineDeLaPartie.RacineArbre;
end;

function EstLaRacineDeLaPartie(G : GameTree) : boolean;
begin
  EstLaRacineDeLaPartie := (G = RacineDeLaPartie.RacineArbre);  {egalité des pointeurs}
end;

function NbDeFilsOfCurrentNode : SInt16;
begin
  NbDeFilsOfCurrentNode := NumberOfSons(GetCurrentNode);
end;

function GetCurrentSons : GameTreeList;
begin
  GetCurrentSons := GetSons(GetCurrentNode);
end;

procedure SetCurrentNodeToGameRoot;
begin
  GameTreeCourant := RacineDeLaPartie.RacineArbre;
end;

procedure SetSonsOfCurrentNode(theSons : GameTreeList);
begin
  SetSons(GameTreeCourant,theSons);
end;

procedure DeleteSonOfCurrentNode(var whichSon : GameTree);
var G : GameTree;
begin
  G := GetCurrentNode;
  DeleteThisSon(G,whichSon);
end;


procedure DeleteAllSonsOfCurrentNode;
var G : GameTree;
begin
  G := GetCurrentNode;
  DeleteAllSons(G);
end;

procedure BringSonOfCurrentNodeToFront(whichSon : GameTree);
var theSons : GameTreeList;
begin
  theSons := GetSons(GetCurrentNode);
  BringToFrontInGameTreeList(whichSon,theSons);
  SetSonsOfCurrentNode(theSons);
end;


procedure BringSonOfCurrentNodeInPositionN(whichSon : GameTree;N : SInt16);
var theSons : GameTreeList;
begin
  theSons := GetSons(GetCurrentNode);
  BringToPositionNInGameTreeList(whichSon,N,theSons);
  SetSonsOfCurrentNode(theSons);
end;


function DeleteSonsOfThatColorInCurrentNode(couleur : SInt16) : SInt16;
var G : GameTree;
begin
  G := GetCurrentNode;
  DeleteSonsOfThatColorInCurrentNode := DeleteSonsOfThatColor(G, couleur);
end;



function GetCouleurOfCurrentNode : SInt32;
begin
  GetCouleurOfCurrentNode := GetCouleurOfMoveInNode(GetCurrentNode);
end;


function VerifieHomogeneiteDesCouleurs(G : GameTree; problemePourLesCoupsVides : boolean) : SInt16;
var brothers,L,L1 : GameTreeList;
    firstColor,colorOfThisBrother : SInt32;
    erreurForceePourPhaseDeTest : boolean;
begin
  VerifieHomogeneiteDesCouleurs := 0;
  if (G = NIL) then exit;

  brothers := GetBrothers(G);

  if (brothers = NIL) and (EstLaRacineDeLaPartie(G)) then
    exit;  {c'est normal}


  if (brothers = NIL) then
    begin
      if debuggage.arbreDeJeu or true then
        begin
		      WritelnDansRapport('');
		      WritelnDansRapport('erreur dans VerifieHomogeneiteDesCouleurs : brothers = NIL !!');
		      WritelnNumDansRapport('adresse du noeud = ',SInt32(G));
		      WritelnNumDansRapport('adresse de la racine = ',SInt32(GetRacineDeLaPartie));
		      WritelnDansRapport('');
		    end;
      VerifieHomogeneiteDesCouleurs := -2;
      exit;
    end;


  erreurForceePourPhaseDeTest := false;

  L := brothers;
  firstColor := GetCouleurOfMoveInNode(L^.head);
  while L <> NIL do
    begin
      L := L^.tail;
      if (L <> NIL) then
        begin
          colorOfThisBrother := GetCouleurOfMoveInNode(L^.head);

         {erreurForceePourPhaseDeTest := UnChanceSurN(100);}
          erreurForceePourPhaseDeTest := false;
          if erreurForceePourPhaseDeTest then WritelnDansRapport('Random16() dans VerifieHomogeneiteDesCouleurs');

          if erreurForceePourPhaseDeTest or
             ((colorOfThisBrother <> firstColor) and
              (problemePourLesCoupsVides or ((firstColor <> pionVide) and (colorOfThisBrother <> pionVide)))) then
	          begin
	            AlerteSimple('Deux couleurs différentes dans des noeuds freres dans VerifieHomogeneiteDesCouleurs!! Prévenez Stéphane');
		          {if debuggage.arbreDeJeu then}
		            begin
		              WritelnDansRapport('');
		              WritelnDansRapport('la liste des freres fautifs est :');
				          L1 := brothers;
				          while L1 <> NIL do
				            begin
				              WritelnPropertyListDansRapport(L1^.head^.properties);
				              L1 := L1^.tail;
				            end;
				          WritelnDansRapport('');
				        end;

				      VerifieHomogeneiteDesCouleurs := -1;
              exit;
				    end;
        end;
    end;
end;


function ChangeCurrentNodeAfterThisMove(square,couleur : SInt16; const fonctionAppelante : String255; var isNew : boolean) : OSErr;
var noeudsDejaGeneres : SquareSet;
    freresDeLaMauvaiseCouleur : SquareSet;
    prop : Property;
    subtree : GameTree;
    problemeDeCouleursDansLArbre,erreurForceePourPhaseDeTest : boolean;
    err : OSErr;
begin
  ChangeCurrentNodeAfterThisMove := 0;
  problemeDeCouleursDansLArbre := false;
  isNew := true;

  if (square < 11) or (square > 88) then
    begin
      WritelnDansRapport('erreur : case hors de l''intervalle (11..88) dans ChangeCurrentNodeAfterMove !!!');
      ChangeCurrentNodeAfterThisMove := -1;
      exit;
    end;

  if (couleur <> pionNoir) and (couleur <> pionBlanc) then
    begin
      WritelnDansRapport('erreur : couleur non legale dans ChangeCurrentNodeAfterMove !!!');
      ChangeCurrentNodeAfterThisMove := -1;
      exit;
    end;

  if GameTreeCourant = NIL then
    begin
      WritelnDansRapport('erreur : GameTreeCourant = NIL dans ChangeCurrentNodeAfterMove !!!');
      ChangeCurrentNodeAfterThisMove := -1;
      exit;
    end;

  if debuggage.arbreDeJeu then
    WritelnDansRapport('appel de ChangeCurrentNodeAfterThisMove('+
                       CoupEnStringEnMajuscules(square)+','+IntToStr(couleur)+
                       ') par '+fonctionAppelante);

  err := VerifieHomogeneiteDesCouleurs(GameTreeCourant,true);
  if err <> 0 then
    begin
      WritelnDansRapport('on a reporté un probleme dans ChangeCurrentNodeAfterMove avant la creation du nouveau nœud, fonctionAppelante = '+fonctionAppelante);
      problemeDeCouleursDansLArbre := true;
      ChangeCurrentNodeAfterThisMove := err;
      exit;
    end;

  noeudsDejaGeneres := GetEnsembleDesCoupsDesFils(couleur,GameTreeCourant);

 {erreurForceePourPhaseDeTest := UneChanceSur(10) and (Pos('JoueEn',fonctionAppelante) > 0);}
  erreurForceePourPhaseDeTest := false;

  freresDeLaMauvaiseCouleur := GetEnsembleDesCoupsDesFils(-couleur,GameTreeCourant);
  if (freresDeLaMauvaiseCouleur <> []) or erreurForceePourPhaseDeTest then
    begin

      if erreurForceePourPhaseDeTest then
        WritelnDansRapport('erreurForceePourPhaseDeTest dans freresDeLaMauvaiseCouleur dans ChangeCurrentNodeAfterMove');

      AlerteSimple('Problème : on s''apprete à créer deux noeuds freres de couleurs différentes !! Sauvegardez le rapport et prévenez Stéphane');
      WritelnDansRapport('Probleme : freresDeLaMauvaiseCouleur dans ChangeCurrentNodeAfterMove, fonctionAppelante = '+fonctionAppelante);

      case couleur of
          pionNoir    : prop := MakeOthelloSquareProperty(BlackMoveProp,square);
          pionBlanc   : prop := MakeOthelloSquareProperty(WhiteMoveProp,square);
          otherwise     prop := MakeEmptyProperty;
      end; {case}
      WritelnStringAndPropertyDansRapport('je dois créer le fils suivant : ',prop);
      DisposePropertyStuff(prop);

      case couleur of
          pionNoir    : WritelnDansRapport('Les freres de la mauvaise couleur (ennemie) existant deja sont : W'+SquareSetEnString(freresDeLaMauvaiseCouleur));
          pionBlanc   : WritelnDansRapport('Les freres de la mauvaise couleur (ennemie) existant deja sont : B'+SquareSetEnString(freresDeLaMauvaiseCouleur));
          otherwise     WritelnDansRapport('Les freres de la mauvaise couleur (ennemie) existant deja sont : '+SquareSetEnString(freresDeLaMauvaiseCouleur));
      end; {case}

      problemeDeCouleursDansLArbre := true;

      ChangeCurrentNodeAfterThisMove := -1;
      exit;
    end;

  if debuggage.arbreDeJeu or problemeDeCouleursDansLArbre then
    begin
      if (noeudsDejaGeneres = [])
        then
          case couleur of
		        pionBlanc : WritelnDansRapport('pas de fils blancs du noeud courant ! ');
		        pionNoir  : WritelnDansRapport('pas de fils noirs du noeud courant ! ');
		      end
        else
		      case couleur of
		        pionBlanc : WritelnDansRapport('fils blancs du noeud courant = '+SquareSetEnString(noeudsDejaGeneres));
		        pionNoir  : WritelnDansRapport('fils noirs du noeud courant = '+SquareSetEnString(noeudsDejaGeneres));
		      end;
    end;

  if square in noeudsDejaGeneres
    then
      begin
        isNew := false;
        case couleur of
          pionNoir    : prop := MakeOthelloSquareProperty(BlackMoveProp,square);
          pionBlanc   : prop := MakeOthelloSquareProperty(WhiteMoveProp,square);
          otherwise     prop := MakeEmptyProperty;
        end; {case}
        GameTreeCourant := SelectFirstSubtreeWithThisProperty(prop,GameTreeCourant);
        DisposePropertyStuff(prop);
      end
    else
      begin
        isNew := true;
        case couleur of
          pionNoir    : prop := MakeOthelloSquareProperty(BlackMoveProp,square);
          pionBlanc   : prop := MakeOthelloSquareProperty(WhiteMoveProp,square);
          otherwise     prop := MakeEmptyProperty;
        end; {case}

        if debuggage.arbreDeJeu or problemeDeCouleursDansLArbre then
           WritelnStringAndPropertyDansRapport(Concat(fonctionAppelante, ' : création de '),prop);

        subtree := MakeGameTreeFromProperty(prop);
        AddSonToGameTree(subtree,GameTreeCourant);
        GameTreeCourant := SelectFirstSubtreeWithThisProperty(prop,GameTreeCourant);
        DisposeGameTree(subtree);
        DisposePropertyStuff(prop);
      end;

  err := VerifieHomogeneiteDesCouleurs(GameTreeCourant,true);
  if err <> 0 then
    begin
      WritelnDansRapport('on a reporté un probleme dans ChangeCurrentNodeAfterMove apres la creation du nouveau nœud, fonctionAppelante = '+fonctionAppelante);
      problemeDeCouleursDansLArbre := true;
      ChangeCurrentNodeAfterThisMove := err;
      exit;
    end;

end;


function ChangeCurrentNodeAfterNewMove(square,couleur : SInt16; const fonctionAppelante : String255) : OSErr;
var isNew : boolean;
begin
  ChangeCurrentNodeAfterNewMove := ChangeCurrentNodeAfterThisMove(square,couleur,fonctionAppelante,isNew);
end;

procedure ChangeCurrentNodeForBackMove;
begin
  if not(GameTreeEstVide(GameTreeCourant)) and not(GameTreeEstVide(GameTreeCourant^.father)) then
    GameTreeCourant := GameTreeCourant^.father;

   if VerifieHomogeneiteDesCouleurs(GameTreeCourant,true) <> 0 then
     WritelnDansRapport('on a reporté un probleme dans ChangeCurrentNodeForBackMove');

end;

procedure DoChangeCurrentNodeBackwardUntil(G : GameTree);
begin
  if (G = NIL) or (GameTreeCourant = G) then
    exit;

	while not(GameTreeEstVide(GameTreeCourant)) and not(GameTreeEstVide(GameTreeCourant^.father)) do
		begin
		  GameTreeCourant := GameTreeCourant^.father;
		  if (GameTreeCourant = G) then exit;
    end;

   if VerifieHomogeneiteDesCouleurs(GameTreeCourant,true) <> 0 then
     WritelnDansRapport('on a reporté un probleme dans DoChangeCurrentNodeBackwardUntil');

end;

procedure SetCurrentNode(G : GameTree; const fonctionAppelante : String255);
var error : SInt32;
begin
  if (G = NIL) or (GameTreeCourant = G) then
    exit;

  GameTreeCourant := G;

  if VerifieHomogeneiteDesCouleurs(GameTreeCourant,false) <> 0 then
    begin
      WritelnDansRapport('on a reporté un probleme dans SetCurrentNode, fonctionAppelante = '+fonctionAppelante);

      error := VerifieHomogeneiteDesCouleurs(G, false);
      if error <> 0 then
        WritelnNumDansRapport('    …et d''ailleurs, VerifieHomogeneiteDesCouleurs(G) = ', error);


    end;
end;

procedure EffectueSymetrieArbreDeJeuGlobal(axeSymetrie : SInt32);
begin
  EffectueSymetrieOnGameTree(GetRacineDeLaPartie,axeSymetrie);
end;


procedure SetPositionInitialeOfGameTree(position : plateauOthello; trait,nbBlancs,nbNoirs : SInt16);
var myPosition : PositionEtTraitRec;
begin
  with RacineDeLaPartie do
    begin
      InitialPosition           := position;
      TraitInitial              := trait;
      nbPionsBlancsInitial      := nbBlancs;
      nbPionsNoirsInitial       := nbNoirs;

      myPosition := MakePositionEtTrait(position,trait);

      initialPositionIsStandard := EstLaPositionInitialeStandard(myPosition);
    end;

  {
  with RacineDeLaPartie do
    begin
      WritelnPositionEtTraitDansRapport(position,traitInitial);
      WritelnNumDansRapport('traitInitial = ',traitInitial);
      WritelnNumDansRapport('nbPionsBlancsInitial = ',nbPionsBlancsInitial);
      WritelnNumDansRapport('nbPionsNoirsInitial = ',nbPionsNoirsInitial);
    end;
  }
end;


procedure SetPositionInitialeStandardDansGameTree;
var jeu : plateauOthello;
    nBla,nNoi : SInt32;
begin
  OthellierEtPionsDeDepart(jeu,nBla,nNoi);
  SetPositionInitialeOfGameTree(jeu,pionNoir,nBla,nNoi);
end;


procedure GetPositionInitialeOfGameTree(var position : plateauOthello; var numeroPremierCoup,trait,nbBlancs,nbNoirs : SInt32);
begin
  with RacineDeLaPartie do
    begin
      position := InitialPosition;
      trait    := TraitInitial;
      nbBlancs := nbPionsBlancsInitial;
      nbNoirs  := nbPionsNoirsInitial;

      numeroPremierCoup := nbBlancs+nbNoirs-4+1;
    end;
end;

function GetPositionEtTraitInitiauxOfGameTree : PositionEtTraitRec;
var plat : plateauOthello;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
  GetPositionInitialeOfGameTree(plat,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
  GetPositionEtTraitInitiauxOfGameTree := MakePositionEtTrait(plat,traitInitial);
end;


function PositionIsTheInitialPositionOfGameTree(var whichPos : PositionEtTraitRec) : boolean;
var initiale : PositionEtTraitRec;
begin
  initiale := GetPositionEtTraitInitiauxOfGameTree;
  PositionIsTheInitialPositionOfGameTree := SamePositionEtTrait(whichPos, initiale);
end;


function GameTreeHasStandardInitialPosition : boolean;
begin
  GameTreeHasStandardInitialPosition := RacineDeLaPartie.initialPositionIsStandard;
end;


function GameTreeHasStandardInitialPositionInversed : boolean;
var posDepart : PositionEtTraitRec;
begin
  if GameTreeHasStandardInitialPosition
    then GameTreeHasStandardInitialPositionInversed := false
    else
      begin
        posDepart := GetPositionEtTraitInitiauxOfGameTree;
        GameTreeHasStandardInitialPositionInversed := EstLaPositionInitialeStandardInversee(posDepart);
      end;
end;

function CalculeNouvellePositionInitialeFromThisList(L : PropertyList; var jeu : plateauOthello; var numeroPremierCoup,trait,nbBlancs,nbNoirs : SInt32) : boolean;
var aux : PropertyPtr;
    theSquares : SquareSet;
    c : char;
    i : SInt16;
begin

  CalculeNouvellePositionInitialeFromThisList := false;
  VideOthellier(jeu);

  nbNoirs := 0;
  aux := SelectFirstPropertyOfTypes([AddBlackStoneProp],L);
  if aux <> NIL then
    begin
      theSquares := GetSquareSetOfProperty(aux^);
      for i := 11 to 88 do
        if i in theSquares then
          begin
            inc(nbNoirs);
            jeu[i] := pionNoir;
            CalculeNouvellePositionInitialeFromThisList := true;
          end;
    end;

  nbBlancs := 0;
  aux := SelectFirstPropertyOfTypes([AddWhiteStoneProp],L);
  if aux <> NIL then
    begin
      theSquares := GetSquareSetOfProperty(aux^);
      for i := 11 to 88 do
        if i in theSquares then
          begin
            inc(nbBlancs);
            jeu[i] := pionBlanc;
            CalculeNouvellePositionInitialeFromThisList := true;
          end;
    end;

  numeroPremierCoup := nbNoirs+nbBlancs-4+1;

  if odd(nbNoirs+nbBlancs)  {parité naturelle par défaut}
    then trait := pionBlanc
    else trait := pionNoir;
  aux := SelectFirstPropertyOfTypes([PlayerToPlayFirstProp],L);
  if aux <> NIL then
    begin
      c := GetCharOfProperty(aux^);
      if (c = 'B') or (c = 'b') then trait := pionNoir else
      if (c = 'W') or (c = 'w') then trait := pionBlanc;
      CalculeNouvellePositionInitialeFromThisList := true;
    end;
end;



procedure CalculePositionInitialeFromThisRoot(whichRoot : GameTree);
var trait,nbNoirs,nbBlancs,numeroPremierCoup : SInt32;
    jeu : plateauOthello;
begin
  SetPositionInitialeStandardDansGameTree;  {par defaut}

  if (whichRoot <> NIL) then
    begin
      if CalculeNouvellePositionInitialeFromThisList(whichRoot^.properties,jeu,numeroPremierCoup,trait,nbBlancs,nbNoirs) then
        if (nbBlancs+nbNoirs >= 3) then
          SetPositionInitialeOfGameTree(jeu,trait,nbBlancs,nbNoirs);
    end;

end;

procedure AjouteDescriptionPositionEtTraitACeNoeud(description : PositionEtTraitRec; G : GameTree);
var prop : Property;
    squares : SquareSet;
    i : SInt16;
begin
  if (G <> NIL) then
    begin
      {les pions noirs}
      squares := [];
      for i := 1 to 64 do
        if description.position[othellier[i]] = pionNoir then
          squares := squares + [othellier[i]];
      prop := MakeSquareSetProperty(AddBlackStoneProp,squares);
      AddPropertyToList(prop,G^.properties);
      DisposePropertyStuff(prop);

      {les pions blancs}
      squares := [];
      for i := 1 to 64 do
        if description.position[othellier[i]] = pionBlanc then
          squares := squares + [othellier[i]];
      prop := MakeSquareSetProperty(AddWhiteStoneProp,squares);
      AddPropertyToList(prop,G^.properties);
      DisposePropertyStuff(prop);

      if (GetTraitOfPosition(description) <> pionVide) then
        begin
          if (GetTraitOfPosition(description) = pionNoir)
            then prop := MakeCharProperty(PlayerToPlayFirstProp,'B')
            else prop := MakeCharProperty(PlayerToPlayFirstProp,'W');
          AddPropertyToList(prop,G^.properties);
          DisposePropertyStuff(prop);
        end;

    end;
end;


procedure DeleteDescriptionPositionEtTraitDeCeNoeud(G : GameTree);
var aux : PropertyPtr;
begin
  if (G <> NIL) then
    begin
      aux := SelectFirstPropertyOfTypes([AddBlackStoneProp],G^.properties);
      if aux <> NIL then DeletePropertyFromList(aux^,G^.properties);

      aux := SelectFirstPropertyOfTypes([AddWhiteStoneProp],G^.properties);
      if aux <> NIL then DeletePropertyFromList(aux^,G^.properties);

      aux := SelectFirstPropertyOfTypes([PlayerToPlayFirstProp],G^.properties);
      if aux <> NIL then DeletePropertyFromList(aux^,G^.properties);
    end;
end;


procedure OverWritePropertyToRoot(prop : Property; var changed : boolean);
var root : GameTree;
begin
  root := GetRacineDeLaPartie;
  OverWritePropertyToGameTree(prop, root, changed);
end;


procedure AddPropertyToRoot(prop : Property);
var root : GameTree;
begin
  root := GetRacineDeLaPartie;
  AddPropertyToGameTree(prop, root);
end;


procedure AddInfosStandardsFormatSGFDansArbre;
var prop : Property;
    myDate : DateTimeRec;
    changed : boolean;
begin

  {game ID}
  prop := MakeLongintProperty(GameNumberIDProp,2);    { 2 = Othello}
  OverWritePropertyToRoot(prop,changed);
  DisposePropertyStuff(prop);

  {file format}
  prop := MakeLongintProperty(FileFormatProp,4);
  OverWritePropertyToRoot(prop,changed);
  DisposePropertyStuff(prop);

  {creator application name}
  if SelectFirstPropertyOfTypesInGameTree([ApplicationProp],GetRacineDeLaPartie) = NIL then
    begin
      prop := MakeStringProperty(ApplicationProp,'Cassio:'+VersionDeCassioEnString);
      AddPropertyToRoot(prop);
      DisposePropertyStuff(prop);
    end;

  {user}
  if SelectFirstPropertyOfTypesInGameTree([UserProp],GetRacineDeLaPartie) = NIL then
    begin
      prop := MakeStringProperty(UserProp,'Stephane Nicolet');
      AddPropertyToRoot(prop);
      DisposePropertyStuff(prop);
    end;

  {date}
  if SelectFirstPropertyOfTypesInGameTree([DateProp],GetRacineDeLaPartie) = NIL then
    begin
      GetTime(myDate);
      prop := MakeStringProperty(DateProp,IntToStr(myDate.year)+'-'+
                                        IntToStr(myDate.month)+'-'+
                                        IntToStr(myDate.day));
      AddPropertyToRoot(prop);
      DisposePropertyStuff(prop);
    end;

  {copyright}
  if SelectFirstPropertyOfTypesInGameTree([CopyrightProp],GetRacineDeLaPartie) = NIL then
    begin
      GetTime(myDate);
      prop := MakeStringProperty(CopyrightProp,'Copyleft '+IntToStr(myDate.year)+', French Federation of Othello');
      AddPropertyToRoot(prop);
      DisposePropertyStuff(prop);
    end;

  {board size}
  if SelectFirstPropertyOfTypesInGameTree([BoardSizeProp],GetRacineDeLaPartie) = NIL then
    begin
      prop := MakeLongintProperty(BoardSizeProp,8);
      AddPropertyToRoot(prop);
      DisposePropertyStuff(prop);
    end;

  {time limit}
  if SelectFirstPropertyOfTypesInGameTree([TimeLimitByPlayerProp],GetRacineDeLaPartie) = NIL then
    begin
      if (GetCadence = minutes10000000)
        then prop := MakeLongintProperty(TimeLimitByPlayerProp,1500)    {defaut = 25 min.}
        else prop := MakeLongintProperty(TimeLimitByPlayerProp,GetCadence);
		  OverWritePropertyToRoot(prop,changed);
		  DisposePropertyStuff(prop);
		end;

  {time for black}
  if SelectFirstPropertyOfTypesInGameTree([TimeLeftBlackProp],GetRacineDeLaPartie) = NIL then
    begin
		  if (GetCadence <> minutes10000000)
        then prop := MakeLongintProperty(TimeLeftBlackProp,GetCadence)
        else prop := MakeLongintProperty(TimeLeftBlackProp,1500); {defaut = 25 min.}
		  OverWritePropertyToRoot(prop,changed);
		  DisposePropertyStuff(prop);
		end;

  {time for white}
  if SelectFirstPropertyOfTypesInGameTree([TimeLeftWhiteProp],GetRacineDeLaPartie) = NIL then
    begin
		  if (GetCadence <> minutes10000000)
        then prop := MakeLongintProperty(TimeLeftWhiteProp,GetCadence)
        else prop := MakeLongintProperty(TimeLeftWhiteProp,1500); {defaut = 25 min.}
		  OverWritePropertyToRoot(prop,changed);
		  DisposePropertyStuff(prop);
		end;

	{result}
	(*
	s := CoupsOfMainLineInGameTreeEnString(GetRacineDeLaPartie);
	WritelnDansRapport('MainLine = '+s);
	*)
	(*
	prop := MakeLongintProperty(GameNumberIDProp,2);    { 2 = Othello}
  OverWritePropertyToRoot(prop,changed);
  DisposePropertyStuff(prop);
  *)

end;


function GetApplicationNameDansArbre(var name : String255; var version : String255) : boolean;
var aux : PropertyPtr;
    s : String255;
    positionDeuxPoints : SInt16;
begin
  aux := SelectFirstPropertyOfTypesInGameTree([ApplicationProp],GetRacineDeLaPartie);

  if (aux = NIL)
    then s := ''
    else s := GetStringInfoOfProperty(aux^);

  if (s = '')
    then
      begin
        name := '';
        version := '';
        GetApplicationNameDansArbre := false;
      end
    else
      begin
        positionDeuxPoints := Pos(':',s);
        if positionDeuxPoints > 0
          then
            begin
              name := TPCopy(s,1,positionDeuxPoints-1);
              version := TPCopy(s,positionDeuxPoints+1,LENGTH_OF_STRING(s)-positionDeuxPoints);
            end
          else
            begin
              name := s;
              version := '';
            end;
        GetApplicationNameDansArbre := true;
      end;
end;


procedure SetDoitEcrireMessageDeTransfoArbreDansRapport(flag : boolean);
begin
  gDoitEcrireMessageDeTransfoArbreDansRapport := flag;
end;


function DoitEcrireMessageDeTransfoArbreDansRapport : boolean;
begin
  DoitEcrireMessageDeTransfoArbreDansRapport := gDoitEcrireMessageDeTransfoArbreDansRapport;
end;



{ attention : AddPropertyAsStringDansCeNoeud est une fonction ** LENTE **   }
function AddPropertyAsStringDansCeNoeud(var G : GameTree; propertyDescription : String255) : boolean;
var prop : Property;
    changed : boolean;
begin
  AddPropertyAsStringDansCeNoeud := false;

  if (G <> NIL) then
    begin
      prop := MakePropertyFromString(propertyDescription);

      if not(PropertyEstValide(prop)) then
        begin
          WritelnDansRapport('WARNING : invalid property in AddPropertyAsStringDansCeNoeud, prévenez Stéphane !');
          DisposePropertyStuff(prop);
          exit;
        end;


      if PropertyEstVide(prop) or (prop.genre = VerbatimProp)
        then
          begin
            WritelnDansRapport(ReadStringFromRessource(TextesDiversID,14)+'   ' + propertyDescription);  { Syntax error : unrecognizable property ?!? }
          end
        else
          begin
            if (prop.genre in TypesPierresDelta)
              then AddPropertyToGameTree(prop,G)
              else OverWritePropertyToGameTree(prop,G,changed);

            if DoitEcrireMessageDeTransfoArbreDansRapport then
              begin
                WritelnDansRapport('');
                ChangeFontFaceDansRapport(bold);
                WritelnDansRapport('add : '+PropertyToString(prop));
                TextNormalDansRapport;
                WritelnDansRapport(ReadStringFromRessource(TextesDiversID,17)+' '+PropertyToString(prop));  { 'Property added to the game tree : '}
                WritelnDansRapport('');
              end;

            AddPropertyAsStringDansCeNoeud := true;
          end;

      DisposePropertyStuff(prop);
    end;
end;

{ attention : DeletePropertyAsStringDansCeNoeud est une fonction ** LENTE **   }
function DeletePropertyAsStringDansCeNoeud(var G : GameTree; propertyDescription : String255) : boolean;
var prop : Property;
begin
  DeletePropertyAsStringDansCeNoeud := false;

  if (G <> NIL) then
    begin
      prop := MakePropertyFromString(propertyDescription);

      if not(PropertyEstValide(prop)) then
        begin
          WritelnDansRapport('WARNING : invalid property in DeletePropertyAsStringDansCeNoeud, prévenez Stéphane !');
          DisposePropertyStuff(prop);
          exit;
        end;


      if PropertyEstVide(prop) or (prop.genre = VerbatimProp)
        then
          begin
            WritelnDansRapport(ReadStringFromRessource(TextesDiversID,14)+'   ' + propertyDescription);  { Syntax error : unrecognizable property ?!? }
          end
        else
          begin
            if not(ExistsInPropertyList(prop,G^.properties))
              then
                begin
                  WritelnDansRapport(ReadStringFromRessource(TextesDiversID,15)+ ' '+PropertyToString(prop));  { ERROR, property not found in the game tree : '}
                end
              else
                begin
                  DeletePropertyFromGameNode(prop,G);

                  if DoitEcrireMessageDeTransfoArbreDansRapport then
                    begin
                      WritelnDansRapport('');
                      ChangeFontFaceDansRapport(bold);
                      WritelnDansRapport('delete : '+PropertyToString(prop));
                      TextNormalDansRapport;
                      WritelnDansRapport(ReadStringFromRessource(TextesDiversID,16)+' '+PropertyToString(prop));  { 'Property deleted from the game tree : '}
                      WritelnDansRapport('');
                    end;

                  DeletePropertyAsStringDansCeNoeud := true;
                end;
          end;

       DisposePropertyStuff(prop);
    end;
end;





{ attention : AddPropertyListAsStringDansCeNoeud est une fonction ** LENTE **   }
function AddPropertyListAsStringDansCeNoeud(var G : GameTree; propertyListDescription : String255) : boolean;
var theProperty, left, right : String255;
    changed : boolean;
label boucle;
begin
  changed := false;

  if (G <> NIL) and (propertyListDescription <> '') then
    begin

      changed := false;

      repeat
        theProperty := '';

        repeat
          boucle :

          SplitAt(propertyListDescription, ']', left, right);

          theProperty := theProperty + left + ']';
          propertyListDescription := right;

          if ((LENGTH_OF_STRING(right) >= 1) and (right[1] = '[')) then goto boucle;

        until (propertyListDescription = '') or
              ((LENGTH_OF_STRING(theProperty) >= 2) and (theProperty[LENGTH_OF_STRING(theProperty) - 1] <> '\'));

        changed := AddPropertyAsStringDansCeNoeud(G, theProperty) or changed;

      until (propertyListDescription = '');

    end;

  AddPropertyListAsStringDansCeNoeud := changed;
end;


function AddPropertyListAsStringDansCurrentNode(propertyListDescription : String255) : boolean;
var G : GameTree;
begin
  G := GetCurrentNode;
  AddPropertyListAsStringDansCurrentNode := AddPropertyListAsStringDansCeNoeud(G, propertyListDescription);
end;


procedure DeleteCommentaireDeCeNoeud(var G : GameTree);
var aux : PropertyPtr;
begin
  if (G <> NIL) then
    begin
      if EstLaRacineDeLaPartie(G)
        then aux := SelectFirstPropertyOfTypes([GameCommentProp],G^.properties)
        else aux := SelectFirstPropertyOfTypes([CommentProp],G^.properties);
      {if aux = NIL
        then WritelnDansRapport('aux = NIL')
        else WritelnStringAndPropertyDansRapport('aux = ',aux^);}
      if aux <> NIL then DeletePropertyFromList(aux^,G^.properties);
      {WritelnStringAndPropertyListDansRapport('G^.properties = ',G^.properties);}
    end;
end;

function NoeudHasCommentaire(G : GameTree) : boolean;
var texte : Ptr;
    longueur : SInt32;
begin
  GetCommentaireDeCeNoeud(G,texte,longueur);
  NoeudHasCommentaire := (texte <> NIL) and (longueur > 0);
end;

function CurrentNodeHasCommentaire : boolean;
begin
  CurrentNodeHasCommentaire := NoeudHasCommentaire(GetCurrentNode);
end;

procedure DeleteCommentaireCurrentNode;
var G : GameTree;
begin
  G := GetCurrentNode;
  DeleteCommentaireDeCeNoeud(G);
end;

procedure GetCommentaireDeCeNoeud(G : GameTree; var texte : Ptr; var longueur : SInt32);
var aux : PropertyPtr;
    s : String255;
begin
  texte := NIL;
  longueur := 0;
  if (G <> NIL) then
    begin
      if EstLaRacineDeLaPartie(G)
        then aux := SelectFirstPropertyOfTypes([GameCommentProp],G^.properties)
        else aux := SelectFirstPropertyOfTypes([CommentProp],G^.properties);
      if aux <> NIL then
        case aux^.stockage of
		      StockageEnStr255 :
		        begin
		          s := GetStringInfoOfProperty(aux^);
		          if LENGTH_OF_STRING(s) <= 0
		            then
		              begin
		                texte := NIL;
		                longueur := 0;
		              end
		            else
		              begin
		                texte := Ptr(SInt32(aux^.info)+1);
		                longueur := aux^.taille-1;
		              end;
		        end;
		      StockageEnTexte :
		        begin
		          texte := aux^.info;
		          longueur := aux^.taille;
		        end;
		    end; {case}
    end;
end;


procedure SetCommentaireDeCeNoeud(var G : GameTree; texte : Ptr; longueur : SInt32);
var prop : Property;
begin
  if (G <> NIL) then
    begin
      DeleteCommentaireDeCeNoeud(G);
      if (texte <> NIL) and (longueur > 0) then
        begin
          if EstLaRacineDeLaPartie(G)
            then prop := MakeTexteProperty(GameCommentProp,texte,longueur)
            else prop := MakeTexteProperty(CommentProp,texte,longueur);
          AddPropertyToList(prop,G^.properties);
          {WritelnStringAndPropertyListDansRapport('G^.properties = ',G^.properties);}
          DisposePropertyStuff(prop);
        end;
    end;
end;


procedure SetCommentaireDeCeNoeudFromString(var G : GameTree; s : String255);
begin
  if (G <> NIL) then
    begin
      if s = ''
        then DeleteCommentaireDeCeNoeud(G)
        else SetCommentaireDeCeNoeud(G,@s[1],LENGTH_OF_STRING(s));
    end;
end;

procedure GetCommentaireCurrentNode(var texte : Ptr; var longueur : SInt32);
begin
  GetCommentaireDeCeNoeud(GetCurrentNode,texte,longueur);
end;


procedure SetCommentaireCurrentNode(texte : Ptr; longueur : SInt32);
var G : GameTree;
begin
  G := GetCurrentNode;
  SetCommentaireDeCeNoeud(G,texte,longueur);
end;



procedure SetCommentaireCurrentNodeFromString(s : String255);
var G : GameTree;
begin
  G := GetCurrentNode;
  SetCommentaireDeCeNoeudFromString(G,s);
end;


procedure SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
var myText : TEHandle;
    longueur : SInt32;
    caracteres : charsHandle;
    state : SInt8;
begin
  with arbreDeJeu do
    if windowOpen and (GetArbreDeJeuWindow <> NIL) then
      begin
        myText := GetDialogTextEditHandle(theDialog);
        if myText  <> NIL then
          begin
            longueur := TEGetTextLength(myText);
            caracteres := TEGetText(myText);
            state := HGetState(Handle(caracteres));
            HLock(Handle(caracteres));
            SetCommentaireCurrentNode(Ptr(caracteres^),longueur);
            HSetState(Handle(caracteres),state);
          end;
      end;
end;


function TrouveCommandeDansCommentaireDansFenetreArbreDeJeu(var commande,argument : String255) : boolean;
var buffer : Ptr;
    len, position : SInt32;
    s : String255;
    aux : String255;
    trouve : boolean;
begin
  trouve := false;
  commande := '';
  argument := '';

  if CurrentNodeHasCommentaire then
    begin
      GetCommentaireCurrentNode(buffer, len);

      if (buffer <> NIL) then
        begin

          if FindStringInBuffer('search :', buffer, len, 0, +1, position) or
             FindStringInBuffer('search:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('Search :', buffer, len, 0, +1, position) or
             FindStringInBuffer('Search:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('SEARCH :', buffer, len, 0, +1, position) or
             FindStringInBuffer('SEARCH:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('find :'  , buffer, len, 0, +1, position) or
             FindStringInBuffer('find:'   , buffer, len, 0, +1, position) or
             FindStringInBuffer('Find :'  , buffer, len, 0, +1, position) or
             FindStringInBuffer('Find:'   , buffer, len, 0, +1, position) or
             FindStringInBuffer('FIND :'  , buffer, len, 0, +1, position) or
             FindStringInBuffer('FIND:'   , buffer, len, 0, +1, position) or
             FindStringInBuffer('google :', buffer, len, 0, +1, position) or
             FindStringInBuffer('google:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('Google :', buffer, len, 0, +1, position) or
             FindStringInBuffer('Google:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('GOOGLE :', buffer, len, 0, +1, position) or
             FindStringInBuffer('GOOGLE:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('add :'   , buffer, len, 0, +1, position) or
             FindStringInBuffer('add:'    , buffer, len, 0, +1, position) or
             FindStringInBuffer('Add :'   , buffer, len, 0, +1, position) or
             FindStringInBuffer('Add:'    , buffer, len, 0, +1, position) or
             FindStringInBuffer('ADD :'   , buffer, len, 0, +1, position) or
             FindStringInBuffer('ADD:'    , buffer, len, 0, +1, position) or
             FindStringInBuffer('delete :', buffer, len, 0, +1, position) or
             FindStringInBuffer('delete:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('Delete :', buffer, len, 0, +1, position) or
             FindStringInBuffer('Delete:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('DELETE :', buffer, len, 0, +1, position) or
             FindStringInBuffer('DELETE:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('remove :', buffer, len, 0, +1, position) or
             FindStringInBuffer('remove:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('Remove :', buffer, len, 0, +1, position) or
             FindStringInBuffer('Remove:' , buffer, len, 0, +1, position) or
             FindStringInBuffer('REMOVE :', buffer, len, 0, +1, position) or
             FindStringInBuffer('REMOVE:' , buffer, len, 0, +1, position) then
            begin
              trouve := true;

              s := BufferToPascalString(buffer, position, len - 1);
              s := ReplaceStringOnce(':',' : ',s);

              Parser2(s, commande, aux, argument);

              SetCommentaireCurrentNode(buffer, position - 1);
            end;

        end;

    end;

  TrouveCommandeDansCommentaireDansFenetreArbreDeJeu := trouve;
end;


const gNombreAvertissementsModificationArbre : SInt32 = 0;



procedure AfficheAlerteModificationDeLArbreDeJeu;
var message, warranty : String255;

begin

  if (gNombreAvertissementsModificationArbre <= 0) then
    begin

      message  := ReadStringFromRessource(TextesErreursID,20);
      warranty := ReadStringFromRessource(TextesErreursID,21);

      (*
      message := 'Vous avez modifié à la main l''arbre de jeu !';
      warranty := 'IN NO EVENT SHALL CASSIO OR ANY OTHER CONTRIBUTOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE EDITION OF THE GAME TREE OR ITS SUBSEQUENT USE.';
      *)

      AlerteDouble(message,warranty);

      inc(gNombreAvertissementsModificationArbre);
    end;
end;



procedure ExecuteCommandeArbreDeJeu(G : GameTree; commande,argument : String255);
var gameTreeChanged, textChanged : boolean;

begin

  (*
  WritelnDansRapport('COMMAND = '+commande);
  WritelnDansRapport('ARGUMENT = '+argument);
  WritelnDansRapport('');
  *)

  if (commande <> '') then
    begin
      commande := MyUpperString(commande,false);

      if (commande = 'SEARCH' ) or (commande = 'FIND') or (commande = 'GOOGLE') then
        begin
          SetLastStringSearchedInGameTree(argument);
          FindStringDansArbreDeJeuCourant(argument,true);
        end;


      gameTreeChanged := false;

      SetDoitEcrireMessageDeTransfoArbreDansRapport(true);

      if (commande = 'ADD')                            then gameTreeChanged := AddPropertyAsStringDansCeNoeud(G,argument) else
      if (commande = 'DELETE') or (commande = 'REMOVE') then gameTreeChanged := DeletePropertyAsStringDansCeNoeud(G,argument);

      SetDoitEcrireMessageDeTransfoArbreDansRapport(false);

      if gameTreeChanged then
        begin
          SetTexteFenetreArbreDeJeuFromArbreDeJeu(G,false,textChanged);
          EffacePremiereLigneFenetreArbreDeJeu;
          DrawContents(GetArbreDeJeuWindow);
          AfficheAlerteModificationDeLArbreDeJeu;
        end;

    end;
end;



{la fonction suivante est assez inefficace et gagnerait a etre acceleree}
function CreateListeDesCoupsJusqua(G : GameTree) : PropertyList;
var G1 : GameTree;
    coupProp : PropertyPtr;
    listeDesCoups : PropertyList;
begin
  if (G = NIL) or EstLaRacineDeLaPartie(G)
    then CreateListeDesCoupsJusqua := NIL
    else
      begin
			  listeDesCoups := NIL;
			  G1 := G;
			  while (G1 <> NIL) and not(EstLaRacineDeLaPartie(G1)) do
			    begin
			      coupProp := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],G1);
			      if coupProp <> NIL then
			        AddPropertyInFrontOfList(coupProp^,listeDesCoups);
			      if G1 = G1^.father then
			        begin
			          AlerteSimple('Boucle infinie dans CreateListeDesCoupsJusqua !!! Prévenez Stéphane');
			          exit;
			        end;
			      G1 := G1^.father;
			    end;
			  CreateListeDesCoupsJusqua := DuplicatePropertyList(listeDesCoups);
			  DisposePropertyList(listeDesCoups);
			end;
end;


function CreatePartieEnAlphaJusqua(G : GameTree; var partieAlpha : String255; var positionTerminale : PositionEtTraitRec) : boolean;
var listeAReboursDesCoups : array[1..64] of PropertyPtr;
    nbCoupsDansListe,i : SInt32;
    G1 : GameTree;
    plat : plateauOthello;
    nbBlancs,nbNoirs : SInt32;
    numeroPremierCoup,trait : SInt32;
    coup : SInt16;
    ok : boolean;
begin

  partieAlpha := '';
  CreatePartieEnAlphaJusqua := false;

  if (G = NIL) then
    begin
      positionTerminale := PositionEtTraitInitiauxStandard;
      exit;
    end;

  if CalculeNouvellePositionInitialeFromThisList(GetRacineDeLaPartie^.properties,plat,numeroPremierCoup,trait,nbBlancs,nbNoirs)
    then positionTerminale := MakePositionEtTrait(plat,trait)
    else positionTerminale := PositionEtTraitInitiauxStandard;

  nbCoupsDansListe := 0;
  G1 := G;
  while not((G1 = NIL) or EstLaRacineDeLaPartie(G1)) do
    begin
      inc(nbCoupsDansListe);
      if (nbCoupsDansListe <= 64) then
        listeAReboursDesCoups[nbCoupsDansListe] := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],G1);

      if (G1 = G1^.father) then
        begin
          AlerteSimple('Boucle infinie dans CreatePartieEnAlphaJusqua !!! Prévenez Stéphane');
          positionTerminale := PositionEtTraitInitiauxStandard;
          CreatePartieEnAlphaJusqua := false;
          exit;
        end;

      G1 := G1^.father;
    end;

  ok := false;
  if (nbCoupsDansListe > 0) then
    begin
      ok := true;
      for i := nbCoupsDansListe downto 1 do
        begin
          if (listeAReboursDesCoups[i] <> NIL)
            then coup := GetOthelloSquareOfProperty(listeAReboursDesCoups[i]^)
            else coup := 0;
          partieAlpha := Concat(partieAlpha,CoupEnStringEnMajuscules(coup));
          ok := ok and UpdatePositionEtTrait(positionTerminale,coup);
        end;

      if not(ok) then
        WritelnDansRapport('WARNING : CreatePartieEnAlphaJusqua = false');
    end;



  CreatePartieEnAlphaJusqua := ok;
end;


procedure ForEachPositionOnPathToGameNodeDo(G : GameTree ; DoWhat : GameTreeProcAvecResult);
var numeroCoupTerminal : SInt32;
    position : PositionEtTraitRec;

  procedure ItererRecursivement(whichNode : GameTree; numeroCoup : SInt32);
  var continuer : boolean;
  begin
    if whichNode <> NIL then
      begin
        if whichNode = whichNode^.father then
          begin
            AlerteSimple('Boucle infinie dans ForEachPositionOnPathToCurrentNodeDo !!! Prévenez Stéphane');
            exit;
          end;
        ItererRecursivement(whichNode^.father,numeroCoup-1);
        continuer := true;
        DoWhat(whichNode,numeroCoup,continuer);
      end;
  end;

begin  {ForEachPositionOnPathToGameNodeDo}
  if GetPositionEtTraitACeNoeud(G, position, 'ForEachPositionOnPathToGameNodeDo') then
    begin
      numeroCoupTerminal := 60 - NbCasesVidesDansPosition(position.position);
      ItererRecursivement(G,numeroCoupTerminal);
    end;
end;


procedure ForEachPositionOnPathToCurrentNodeDo(DoWhat : GameTreeProcAvecResult);
begin
  ForEachPositionOnPathToGameNodeDo(GetCurrentNode,DoWhat);
end;



function GetPositionEtTraitACeNoeud(G : GameTree; var position : PositionEtTraitRec; const fonctionAppelante : String255) : boolean;
var listeAReboursDesCoups : array[1..64] of PropertyPtr;
    nbCoupsDansListe,i : SInt32;
    G1 : GameTree;
    plat : plateauOthello;
    nbBlancs,nbNoirs : SInt32;
    numeroPremierCoup,trait : SInt32;
    ok : boolean;
    coup : SInt16;
begin
  if (G = NIL) then
    begin
      position := PositionEtTraitInitiauxStandard;
      GetPositionEtTraitACeNoeud := false;
      exit;
    end;


  if CalculeNouvellePositionInitialeFromThisList(GetRacineDeLaPartie^.properties,plat,numeroPremierCoup,trait,nbBlancs,nbNoirs)
    then position := MakePositionEtTrait(plat,trait)
    else position := PositionEtTraitInitiauxStandard;

  {
  WritelnDansRapport('apres CalculeNouvellePositionInitialeFromThisList dans GetPositionEtTraitACeNoeud :');
  WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
  }

  nbCoupsDansListe := 0;
  G1 := G;
  while not((G1 = NIL) or EstLaRacineDeLaPartie(G1)) do
    begin
      inc(nbCoupsDansListe);
      if (nbCoupsDansListe <= 64) then
        listeAReboursDesCoups[nbCoupsDansListe] := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],G1);

      if G1 = G1^.father then
        begin
          AlerteSimple('Boucle infinie dans GetPositionEtTraitACeNoeud (fonction appelante = ' + fonctionAppelante + ' !!! Prévenez Stéphane');
          position := PositionEtTraitInitiauxStandard;
          GetPositionEtTraitACeNoeud := false;
          exit;
        end;

      G1 := G1^.father;
    end;

  {
  WritelnNumDansRapport('nbCoupsDansListe = ',nbCoupsDansListe);
  WritelnDansRapport('');
  }

  ok := true;
  for i := nbCoupsDansListe downto 1 do
    begin
      if (listeAReboursDesCoups[i] <> NIL)
        then coup := GetOthelloSquareOfProperty(listeAReboursDesCoups[i]^)
        else coup := 0;
      ok := ok and UpdatePositionEtTrait(position,coup);
    end;

  if not(ok) then
    WritelnDansRapport('WARNING : GetPositionEtTraitACeNoeud = false (fonction appelante = ' + fonctionAppelante + ')');

  GetPositionEtTraitACeNoeud := ok;
end;


procedure AjouteMeilleureSuiteDansGameTree(genreReflexion : SInt32; meilleureSuite : String255; scoreDeNoir : SInt32; G : GameTree; exclamation : boolean; virtualite : SInt16);
 var scoreProperty,moveProperty,pointExclamationProp : Property;
     oldCurrentNode : GameTree;
     positionEtTrait : PositionEtTraitRec;
     whichSquare,vMinPourNoir,vMaxPourNoir : SInt32;
     positionDansChaine,positionParenthese : SInt16;
     premierCoupDeLaSuite,ok,isNew,debugage : boolean;
     err : OSErr;
     estUnScoreDeFinale,confirmation : boolean;
     confirmationFaible : boolean;
begin
  debugage := false;

  if enTournoi then exit;

  if debugage then
    begin
      WritelnDansRapport('•••••••••••••••••••••••••••••••••••••••');
      WritelnDansRapport('Entree dans AjouteMeilleureSuiteDansGameTree ');
      WritelnNumDansRapport('meilleureSuite = '+meilleureSuite+' et scoreDeNoir = ',scoreDeNoir);
    end;

  if (G = NIL) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT(G <> NIL) dans AjouteMeilleureSuiteDansGameTree !!');
      exit;
    end;

  if (G <> NIL) then
    begin
      estUnScoreDeFinale := GenreDeReflexionInSet(genreReflexion,
                                              [ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif,
                                               ReflGagnant,ReflRetrogradeGagnant,ReflParfaitExhaustPhaseGagnant,
                                               ReflGagnantExhaustif]);



      oldCurrentNode := GetCurrentNode;
		  SetCurrentNode(G, 'AjouteMeilleureSuiteDansGameTree {1}');
		  ok := GetPositionEtTraitACeNoeud(G, positionEtTrait, 'AjouteMeilleureSuiteDansGameTree {1}');

	    if ok and (GetTraitOfPosition(positionEtTrait) <> pionVide) then
	      begin

	        if (genreReflexion in [ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif]) and odd(scoreDeNoir) then
          begin
            Sysbeep(0);
            WritelnNumDansRapport('BIZARRE : score impair dans AjouteMeilleureSuiteDansGameTree, scorePourNoir = ',scoreDeNoir);
          end;


          if ((scoreDeNoir < -64) or (scoreDeNoir > 64)) and
             not(GenreDeReflexionInSet(genreReflexion,[ReflMilieu,ReflRetrogradeMilieu,ReflMilieuExhaustif,ReflZebraBookEval,ReflZebraBookEvalSansDoutePerdant,ReflZebraBookEvalSansDouteGagnant])) then
            begin
              WritelnDansRapport('ERREUR : scorePourNoir = '+IntToStr(scoreDeNoir)+' dans AjouteMeilleureSuiteDansGameTree(ReflParfait), prévenez Stéphane !');
              WritelnNumDansRapport('quelGenreDeReflexion = ',genreReflexion);
              SysBeep(0);

              SetCurrentNode(oldCurrentNode, 'AjouteMeilleureSuiteDansGameTree {2}');
              exit;
            end;

	        scoreProperty := MakeScoringProperty(genreReflexion,scoreDeNoir);


			    if GenreDeReflexionInSet(genreReflexion,[ReflGagnant,ReflRetrogradeGagnant,ReflParfaitExhaustPhaseGagnant,ReflGagnantExhaustif]) then
			      begin
			        positionParenthese := Pos('(',meilleureSuite);
			        if positionParenthese > 0 then
			          meilleureSuite := TPCopy(meilleureSuite,positionParenthese,LENGTH_OF_STRING(meilleureSuite)-positionParenthese+1);
			      end;
			    meilleureSuite := EnleveEspacesDeDroite(meilleureSuite);
			    if debugage then WritelnDansRapport('Voici les coups pour '+meilleureSuite);


			    premierCoupDeLaSuite := true;
			    repeat
			      ok := false;
			      EnleveEspacesDeGaucheSurPlace(meilleureSuite);
			      whichSquare := ScannerStringPourTrouverCoup(1,meilleureSuite,positionDansChaine);
			      if (whichSquare <> -1) then
			        begin
			          meilleureSuite := TPCopy(meilleureSuite,positionDansChaine+2,LENGTH_OF_STRING(meilleureSuite)-positionDansChaine-1);
			          case GetTraitOfPosition(positionEtTrait) of
					        pionNoir  : moveProperty := MakeOthelloSquareProperty(BlackMoveProp,whichSquare);
					        pionBlanc : moveProperty := MakeOthelloSquareProperty(WhiteMoveProp,whichSquare);
					        otherwise   moveProperty := MakeEmptyProperty;
					      end;
					      ok := PlayMoveProperty(moveProperty,positionEtTrait);
					      if ok
					        then
						        begin
						          if debugage then WritelnPropertyDansRapport(moveProperty);
								      err := ChangeCurrentNodeAfterThisMove(whichSquare,GetCouleurOfMoveProperty(moveProperty),'AjouteMeilleureSuiteDansGameTree',isNew);

						          if estUnScoreDeFinale and GetEndgameValuesInHashTableFromThisNode(positionEtTrait,GetCurrentNode,kDeltaFinaleInfini,vMinPourNoir,vMaxPourNoir) then
							          begin


							            if debugage  then
							              begin
							                WritelnDansRapport('Dans AjouteMeilleureSuiteDansGameTree : ');
							                WritelnNumDansRapport('scoreDeNoir = ',scoreDeNoir);
									            WritelnNumDansRapport('vMinPourNoir = ',vMinPourNoir);
									            WritelnNumDansRapport('vMaxPourNoir = ',vMaxPourNoir);
									            WritelnDansRapport('');
									          end;



							            confirmation := ScoreFinalEstConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir);


							            if confirmation
							              then
							                confirmationFaible := true
							              else
  							              begin
  							                confirmationFaible := ScoreFinalEstFaiblementConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir);

  							                (*
  							                WritelnDansRapport('WARNING : not(confirmation) dans AjouteMeilleureSuiteDansGameTree...');
  							                WritelnStringAndBoolDansRapport('  ... et ScoreFinalEstFaiblementConfirmeParValeursHashExacte = ',confirmationFaible);
  							                *)
  							              end;

							            ok := ok and (confirmation or confirmationFaible);

							            if debugage or (not(confirmation) and not(confirmationFaible)) then
							              begin
							                WritelnDansRapport('Dans AjouteMeilleureSuiteDansGameTree : ');
							                WritelnNumDansRapport('scoreDeNoir = ',scoreDeNoir);
									            WritelnNumDansRapport('vMinPourNoir = ',vMinPourNoir);
									            WritelnNumDansRapport('vMaxPourNoir = ',vMaxPourNoir);
									            WritelnStringAndBoolDansRapport('  =>  confirmation = ',confirmation);
									            WritelnStringAndBoolDansRapport('  =>  confirmationFaible = ',confirmationFaible);
									            WritelnDansRapport('');
									          end;
							          end;


						          if ok then
						            begin
								          AddScorePropertyToCurrentNodeSansDuplication(scoreProperty);

								          (* statut reel/virtuel des noueuds *)
								          if (virtualite = kForceReel)               then MarquerCurrentNodeCommeReel('AjouteMeilleureSuiteDansGameTree {1}') else
								          if (virtualite = kForceVirtual)            then MarquerCurrentNodeCommeVirtuel else
								          if isNew and (virtualite = kNewMovesReel)    then MarquerCurrentNodeCommeReel('AjouteMeilleureSuiteDansGameTree {2}') else
								          if isNew and (virtualite = kNewMovesVirtual) then MarquerCurrentNodeCommeVirtuel;


								          if premierCoupDeLaSuite
								            then
									            begin
									              if exclamation then
									                begin
											              pointExclamationProp := MakeTripleProperty(TesujiProp,MakeTriple(1));
											              AddPropertyToCurrentNodeSansDuplication(pointExclamationProp);
											              DisposePropertyStuff(pointExclamationProp);
											            end;
											          premierCoupDeLaSuite := false;
									            end
									          else
									            begin
									              if GenreDeReflexionInSet(genreReflexion,[ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif]) then
									                if (virtualite = kForceReel) or (virtualite = kNewMovesReel) then
									                  PromeutParmiSesFreres(GetCurrentNode);
									            end;
									      end;
							      end
							    else
							      begin
							        SysBeep(0);
							        WritelnDansRapport('ERROR : coup illegal dans AjouteMeilleureSuiteDansGameTree');
							        WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
							        WriteStringAndPropertyDansRapport('moveProperty = ',moveProperty);
							      end;
			          DisposePropertyStuff(moveProperty);
			        end;
			    until (whichSquare = -1) or not(ok) or (meilleureSuite = '') or (GetTraitOfPosition(positionEtTrait) = pionVide);

			    DisposePropertyStuff(scoreProperty);
	      end;
	    SetCurrentNode(oldCurrentNode, 'AjouteMeilleureSuiteDansGameTree {3}');
	  end;
	if debugage then
    begin
      WritelnDansRapport('Sortie de AjouteMeilleureSuiteDansGameTree ');
      WritelnDansRapport('•••••••••••••••••••••••••••••••••••••••');
    end;
end;


procedure AjouteMeilleureSuiteDansArbreDeJeuCourant(genreReflexion : SInt32; meilleureSuite : String255; scoreDeLaLignePourNoir : SInt32);
var oldCurrentNode : GameTree;
begin
  oldCurrentNode := GetCurrentNode;

  if (genreReflexion in [ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif]) and odd(scoreDeLaLignePourNoir) then
    begin
      WritelnNumDansRapport('ASSERT : score impair dans AjouteMeilleureSuiteDansArbreDeJeuCourant, scoreDeLaLignePourNoir = ',scoreDeLaLignePourNoir);
    end;

  AjouteMeilleureSuiteDansGameTree(genreReflexion,meilleureSuite,scoreDeLaLignePourNoir,GetCurrentNode,true,kForceReel);
  SetCurrentNode(oldCurrentNode, 'AjouteMeilleureSuiteDansArbreDeJeuCourant');
  MarquerCurrentNodeCommeReel('AjouteMeilleureSuiteDansArbreDeJeuCourant');
end;


procedure AjoutePropertyValeurDeCoupDansCurrentNode(quelGenreDeReflexion,scorePourNoir : SInt32);
begin
  if (quelGenreDeReflexion = ReflParfait) and odd(scorePourNoir) then
    begin
      {SysBeep(0);}
      WritelnNumDansRapport('PAS NORMAL ! dans AjoutePropertyValeurDeCoupDansCurrentNode, scorePourNoir = ',scorePourNoir);
    end;
  if ((scorePourNoir < -64) or (scorePourNoir > 64)) and
     not(GenreDeReflexionInSet(quelGenreDeReflexion,[ReflMilieu,ReflRetrogradeMilieu,ReflMilieuExhaustif,ReflZebraBookEval,ReflZebraBookEvalSansDoutePerdant,ReflZebraBookEvalSansDouteGagnant])) then
    begin
      WritelnDansRapport('ERREUR : scorePourNoir = '+IntToStr(scorePourNoir)+' dans AjoutePropertyValeurDeCoupDansCurrentNode(reflexion de finale), prévenez Stéphane !');
      WritelnNumDansRapport('quelGenreDeReflexion = ',quelGenreDeReflexion);
      SysBeep(0);
      exit;
    end;

  AjoutePropertyValeurDeCoupDansGameTree(quelGenreDeReflexion,scorePourNoir,GetCurrentNode);
end;


function SelectScorePropertyOfCurrentNode : PropertyPtr;
begin
  SelectScorePropertyOfCurrentNode := SelectScorePropertyOfNode(GetCurrentNode);
end;


procedure MarquerCurrentNodeCommeVirtuel;
begin
  MarquerCeNoeudCommeVirtuel(GameTreeCourant);
end;


procedure MarquerCurrentNodeCommeReel(const fonctionAppelante : String255);
 var partieAlpha : String255;
    positionTerminale : PositionEtTraitRec;
begin
  Discard3(fonctionAppelante, partieAlpha, positionTerminale);

  (*
  if CreatePartieEnAlphaJusqua(GameTreeCourant,partieAlpha,positionTerminale) then
    begin
      WritelnDansRapport('MarquerCurrentNodeCommeReel '+partieAlpha+' : fonctionAppelante = '+fonctionAppelante);
    end;
  *)

  MarquerCeNoeudCommeReel(GameTreeCourant);
end;



procedure JumpToPosition(var G : GameTree);
var bidbool : boolean;
    ligne : String255;
    positionCourante : PositionEtTraitRec;
begin
  if (G <> NIL) then
    begin
      bidbool := CreatePartieEnAlphaJusqua(G,ligne,positionCourante);
      PlaquerPositionEtPartie(GetPositionEtTraitInitiauxOfGameTree,ligne,kNePasRejouerLesCoupsEnDirect);
    end;
end;




procedure FindStringDansArbreDeJeuCourant(const s : String255; ignoreCase : boolean);
var G,noeudDepart : GameTree;
    stringAdresse : SInt32;
    chaineCherchee : String255;
begin

  if (s <> '') then
    begin
      if ignoreCase
        then chaineCherchee := MyUpperString(s,false)
        else chaineCherchee := s;

      stringAdresse := SInt32(@chaineCherchee);

      noeudDepart := NextNodePourParcoursEnProfondeurArbre(GetCurrentNode);

      if ignoreCase
        then G := FindNodeInGameTree(noeudDepart,FindUpperStringWithoutDiacriticsInNode, stringAdresse)
        else G := FindNodeInGameTree(noeudDepart,FindStringInNode, stringAdresse);

      if (G <> NIL) and (G <> GetCurrentNode)
        then JumpToPosition(G);
    end;
end;



procedure ChercherLeProchainNoeudAvecBeaucoupDeFils(nbreDeFils : SInt32);
var G,noeudDepart : GameTree;
begin

  noeudDepart := NextNodePourParcoursEnProfondeurArbre(GetCurrentNode);

  G := FindNodeInGameTree(noeudDepart,GameNodeHasTooManySons,nbreDeFils);

  if (G <> NIL) and (G <> GetCurrentNode)
    then JumpToPosition(G);
end;


function PeutCalculerFinaleParfaiteParArbreDeJeuCourant(var listeDesCoups : PropertyList; var valeurCouranteMin,valeurCouranteMax : SInt32) : boolean;
var temp, trouve : boolean;
    suiteOptimaleLocale : PropertyList;
    positionArbre : PositionEtTraitRec;
    a,b : SInt32;
begin

  trouve := false;

  temp := SuiteParfaiteEstConnueDansGameTree;
  if ConnaitValeurDuNoeud(GetCurrentNode,kDeltaFinaleInfini,a,b) then
    if GetPositionEtTraitACeNoeud(GetCurrentNode, positionArbre, 'PeutCalculerFinaleParfaiteParArbreDeJeuCourant') then
      if EstLaPositionCourante(positionArbre) then
        begin
          if (listeDesCoups <> NIL)
            then
              trouve := PeutCalculerFinaleDansGameTree(GetCurrentNode,PositionEtTraitCourant,listeDesCoups,valeurCouranteMin,valeurCouranteMax)
            else
              begin
                suiteOptimaleLocale := NewPropertyList;
                trouve := PeutCalculerFinaleDansGameTree(GetCurrentNode,PositionEtTraitCourant,suiteOptimaleLocale,valeurCouranteMin,valeurCouranteMax);
                DisposePropertyList(suiteOptimaleLocale);
              end;
        end;
  SetSuiteParfaiteEstConnueDansGameTree(temp);

  PeutCalculerFinaleParfaiteParArbreDeJeuCourant := trouve;

end;
































END.
