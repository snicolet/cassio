UNIT UnitAffichageArbreDeJeu;




INTERFACE







 USES UnitDefCassio;




{initialisation et destruction de l'unité}
procedure InitUnitAfficheArbreJeuCourant;
procedure LibereMemoireUnitAfficheArbreJeuCourant;


{fonctions d'affichage des infos courantes à l'ecran}
procedure SetAffichageProprietesOfCurrentNode(flags : UInt32);
procedure SetEffacageProprietesOfCurrentNode(flags : UInt32);
function GetAffichageProprietesOfCurrentNode : UInt32;
function GetEffacageProprietesOfCurrentNode : UInt32;
procedure SetPhaseCalculListePositionsProperties(flag : boolean);
procedure VideListePositionsProperties;
procedure AfficheProprietesOfCurrentNode(dessinerAideDebutantSiNecessaire : boolean; surQuellesCases : SquareSet; const fonctionAppelante : String255);
procedure EffaceProprietesOfCurrentNode;
procedure AfficheProprietes(G : GameTree; surQuellesCases : SquareSet);
procedure EffaceProprietes(G : GameTree);
procedure EcritCommentaires(G : GameTree);
procedure EcritCommentairesOfCurrentNode;
procedure SetTexteFenetreArbreDeJeuFromArbreDeJeu(G : GameTree; redessineCommentaires : boolean; var commentaireChange : boolean);
function EstVisibleDansFenetreArbreDeJeu(G : GameTree) : boolean;
function GetSignesDiacritiques(G : GameTree) : String255;


{gestion des coups etiquetes 'a', 'b', 'c', ... sur l'othellier }
procedure EcritProchainsCoupsSurOthellier(G : GameTree; trait : SInt16; avecSignesDiacritiques : boolean; surQuellesCases : SquareSet);
procedure EffaceProchainsCoupsSurOthellier(G : GameTree; trait : SInt16);
procedure ViderEtiquetesDesCasesSurLOthellier(surQuellesCases : SquareSet);
function GetEtiqueteOnThisSquare(square : SInt32) : char;
procedure SetEtiquetteOnThisSquare(square : SInt32; etiquette : char);
function FindSquareWithThisEtiquette(etiquette : char; var square : SInt32) : boolean;


{fonctions d'affichage dans la fenetre « arbre de jeu »}
procedure DessineCoupDansFenetreArbreDeJeu(L : PropertyList; numeroDuCoup : SInt16; var positionHorizontale : SInt32);
procedure EcritNoeudDansFenetreArbreDeJeu(G : GameTree; avecEcritureDesFils : boolean);
procedure EcritCurrentNodeDansFenetreArbreDeJeu(avecEcritureDesFils, doitEffacerPremiereLigneDeLaFenetre : boolean);
procedure EffaceNoeudDansFenetreArbreDeJeu;
procedure EffacePremiereLigneFenetreArbreDeJeu;
procedure ValideZoneCommentaireDansFenetreArbreDeJeu;
procedure InverserLeNiemeFilsDansFenetreArbreDeJeu(N : SInt16);
procedure EcritProprietesDeCeNoeudHorizontalement(var G : GameTree; var positionVerticale : SInt32; var continuer : boolean);
procedure EcritProprietesDeCeFilsHorizontalement(var G : GameTree; var positionVerticale : SInt32; var continuer : boolean);
procedure SetDisplayColorOfNodeInFenetreArbreDeJeu(color : SInt32);
function GetDisplayColorOfNodeInFenetreArbreDeJeu : SInt32;


{fonction de dessin des icones des proprietes}
function InterligneArbreFenetreArbreDeJeu : SInt16;
procedure DessinePetiteIconeFenetreArbreDeJeu(IconeID : SInt32; where : Point; var dimension : Point);
procedure DessineImagetteFenetreArbreDeJeu(quelleImage : typeImagette; where : Point; var dimension : Point);
function DessineIconeProperty(prop : Property; where : Point; var dimension : Point) : boolean;
procedure EcritChaineOfProperty(const s : String255; var largeur : SInt16);
procedure EcritIconesDeStructureDeLArbre(var G : GameTree; traiteEmbranchement,traiteFeuille : boolean; var positionHorizontale : SInt32);


{fonction de destruction}
procedure DetruireCeFilsOfCurrentNode(var whichSon : GameTree);


{fonction de test de souris}
function PropertyPointeeParSouris : PropertyPtr;
function SurIconeInterversion(whichPoint : Point; var noeudCorrespondant : GameTree) : boolean;
procedure AddTranspositionPropertyToCurrentNode(var texte : String255);


{fonction d'affichage du commentaire dans le rapport}
procedure AfficheCommentaireOfNodeDansRapport(var G : GameTree; var numeroDuCoup : SInt32; var commentaireVide : boolean);
procedure AfficheCommentairePartieDansRapport;


{fonction d'affichage de l'arbre courant dans le rapport}
procedure WritelnRacineDeLaPartieDansRapport;
procedure WritelnGameTreeCourantDansRapport;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Resources, MacWindows, Dialogs, QuickdrawText, Fonts
{$IFC NOT(USE_PRELINK)}
    , Zebra_to_Cassio, MyQuickDraw, UnitServicesDialogs, UnitHashing
    , SNEvents, UnitSquareSet, Zebra_to_Cassio, UnitFenetres, UnitRapport, UnitArbreDeJeuCourant, UnitCarbonisation, UnitPierresDelta
    , UnitRapportImplementation, UnitJaponais, UnitAffichageReflexion, UnitCouleur, UnitScannerUtils, MyStrings, UnitGameTree, UnitGeometrie
    , MyAntialiasing, UnitCurseur, UnitAffichagePlateau, UnitCommentaireArbreDeJeu, UnitPropertyList, UnitProperties, UnitImagettesMeteo ;
{$ELSEC}
    ;
    {$I prelink/AffichageArbreDeJeu.lk}
{$ENDC}


{END_USE_CLAUSE}


var DernierNoeudDontOnAAfficheLesCommentaires : GameTree;
    gAffichageProprietesOfCurrentNode : SInt32;
    gEffacageProprietesOfCurrentNode : SInt32;
    phaseCalculListePositionsProperties : boolean;
    listePositionsProperties : PropertyList;
    gNoeudQuOnDessineSurCetteLigne : GameTree;
    gCouleurDuCoupDeCetteLigne : SInt32;
    etiquetteSurCase : platValeur;
    gDisplayColorOfNodeInFenetreArbreDeJeu : SInt32;

    gPileAppelsRecursifsAfficheProprietesCurrentNode :
     record
        nbAppelsRecursifs : SInt32;
        cardinalPile      : SInt32;
        pileParametres    : array[0..100] of SInt32;
     end;

procedure InitUnitAfficheArbreJeuCourant;
var k : SInt32;
begin
  DernierNoeudDontOnAAfficheLesCommentaires := NIL;
  SetAffichageProprietesOfCurrentNode(kToutesLesProprietes);
  SetEffacageProprietesOfCurrentNode(kToutesLesProprietes);
  SetPhaseCalculListePositionsProperties(false);
  listePositionsProperties := NIL;
  gNoeudQuOnDessineSurCetteLigne := NIL;
  gCouleurDuCoupDeCetteLigne := pionVide;
  for k := 0 to 99 do
    etiquetteSurCase[k] := -1;

  gPileAppelsRecursifsAfficheProprietesCurrentNode.cardinalPile      := 0;
  gPileAppelsRecursifsAfficheProprietesCurrentNode.nbAppelsRecursifs := 0;

  for k := 0 to 100 do
    gPileAppelsRecursifsAfficheProprietesCurrentNode.pileParametres[k] := -1;

end;

procedure LibereMemoireUnitAfficheArbreJeuCourant;
begin
  DisposePropertyList(listePositionsProperties);
  listePositionsProperties := NIL;
end;

procedure SetAffichageProprietesOfCurrentNode(flags : UInt32);
begin
  gAffichageProprietesOfCurrentNode := flags;
end;

function GetAffichageProprietesOfCurrentNode : UInt32;
begin
  GetAffichageProprietesOfCurrentNode := gAffichageProprietesOfCurrentNode;
end;

procedure SetEffacageProprietesOfCurrentNode(flags : UInt32);
begin
  gEffacageProprietesOfCurrentNode := flags;
end;

function GetEffacageProprietesOfCurrentNode : UInt32;
begin
  GetEffacageProprietesOfCurrentNode := gEffacageProprietesOfCurrentNode;
end;

procedure SetPhaseCalculListePositionsProperties(flag : boolean);
begin
  phaseCalculListePositionsProperties := flag;
end;

procedure VideListePositionsProperties;
begin
  DisposePropertyList(listePositionsProperties);
  listePositionsProperties := NIL;
end;

procedure ViderEtiquetesDesCasesSurLOthellier(surQuellesCases : SquareSet);
var square : SInt32;
begin
  for square := 11 to 88 do
    if (square in surQuellesCases) then
      etiquetteSurCase[square] := -1;
end;

function GetEtiqueteOnThisSquare(square : SInt32) : char;
var t : SInt32;
begin
  GetEtiqueteOnThisSquare := ' ';
  if (square >= 11) and (square <= 88) then
    begin
      t := etiquetteSurCase[square];
      if (t >= 0) and (t <= 100) then
        GetEtiqueteOnThisSquare := chr(t + ord('a'));
    end;
end;


procedure SetEtiquetteOnThisSquare(square : SInt32; etiquette : char);
begin
  etiquette := LowerCase(etiquette);
  if (square >= 11) and (square <= 88) then
    etiquetteSurCase[square] := ord(etiquette) - ord('a');
end;


function FindSquareWithThisEtiquette(etiquette : char; var square : SInt32) : boolean;
var k : SInt32;
begin
  etiquette := LowerCase(etiquette);

  for k := 11 to 88 do
    if (etiquetteSurCase[k] >= 0) and (etiquetteSurCase[k] = (ord(etiquette) - ord('a'))) then
      begin
        square := k;
        FindSquareWithThisEtiquette := true;
        exit(FindSquareWithThisEtiquette);
      end;

  square := -1;
  FindSquareWithThisEtiquette := false;
end;

procedure EcritProchainsCoupsSurOthellier(G : GameTree; trait : SInt16; avecSignesDiacritiques : boolean; surQuellesCases : SquareSet);
var L,L1,L2 : PropertyList;
    theSon : GameTree;
    codeAsciiCaractere,whichSquare : SInt16;
    tempoBool,bidbool : boolean;
    oldPort : grafPtr;
    s : String255;
    imagetteADessiner : typeImagette;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      (*
      WritelnDansRapport('EcritProchainsCoupsSurOthellier');
      WritelnDansRapport(SquareSetEnString(surQuellesCases));
      *)

      {on donne au drapeau doitEffacerSousLesTextesSurOthellier la valeur true pour eviter
       que Quartz ne bave sur les textes quand on ecrit plusieurs fois de suite les textes
       dans les cases }

      tempoBool := doitEffacerSousLesTextesSurOthellier;
      doitEffacerSousLesTextesSurOthellier := true;

      ViderEtiquetesDesCasesSurLOthellier(surQuellesCases);

      L := MakeListOfMovePropertyOfSons(trait,G);
      if (L <> NIL) then
        begin
          L1 := L;
	        codeAsciiCaractere := ord('a');
	        while L1 <> NIL do
	          begin
	            whichSquare := GetOthelloSquareOfProperty(L1^.head);

	            s := Concat('',chr(codeAsciiCaractere));

              theSon := SelectFirstSubtreeWithThisProperty(L1^.head,G);
              if theSon = NIL then
                begin
                  AlerteSimple('erreur : fils non trouvé EcritProchainsCoupsSurOthellier !! Prévenez Stéphane');
                  exit(EcritProchainsCoupsSurOthellier);
                end;

              imagetteADessiner := kAucuneImagette;

              if IsARealNode(theSon) or
                 (IsAVirtualNode(theSon) and not(IsAVirtualNodeUsedForZebraBookDisplay(theSon)) and (codeAsciiCaractere <= ord('a')))
                 then
                begin
                  if avecSignesDiacritiques then
	                  begin

	                    L2 := theSon^.properties;
	                    while L2 <> NIL do
	                      begin
	                        case L2^.head.genre of
	                          TesujiProp :
	                            begin
	                              if GetTripleOfProperty(L2^.head).nbTriples >= 2
	                                then s := s + '!!'
	                                else s := s + '!';
	                            end;
	                          BadMoveProp :
	                            begin
	                              if GetTripleOfProperty(L2^.head).nbTriples >= 2
	                                then
  	                                begin
  	                                  s := s + '??';
  	                                  imagetteADessiner := kAlertBig;
  	                                end
  	                              else s := s + '?';
  	                          end;
	                          InterestingMoveProp :
	                            begin
	                              {s := s + '!?';}
	                              imagetteADessiner := kSunCloudBig;
	                            end;
	                          DubiousMoveProp :
	                            begin
	                              {s := s + '?!';}
	                              imagetteADessiner := kThunderstormBig;
	                            end;
	                          ExoticMoveProp :
	                            begin
	                              s := s + '?!';
	                            end;
	                        end; {case}
	                        if L2^.tail = L2 then
			                      begin
			                        AlerteSimple('erreur : boucle infinie sur L1 dans EcritProchainsCoupsSurOthellier !! Prévenez Stéphane');
			                        exit(EcritProchainsCoupsSurOthellier);
			                      end;
	                        L2 := L2^.tail;
	                      end;
	                    if L1^.tail = L1 then
	                      begin
	                        AlerteSimple('erreur : boucle infinie sur L1 dans EcritProchainsCoupsSurOthellier !! Prévenez Stéphane');
	                        exit(EcritProchainsCoupsSurOthellier);
	                      end;
	                  end;



                  if (whichSquare in surQuellesCases) then
		                begin
		                  SetEtiquetteOnThisSquare(whichSquare,chr(codeAsciiCaractere));

		                  case L1^.head.genre of
  			                WhiteMoveProp : if not(gCouleurOthellier.estTresClaire)
  			                                 then DessineStringOnSquare(whichSquare,pionBlanc,s,bidbool)
  			                                 else DessineStringOnSquare(whichSquare,pionNoir,s,bidbool);
  			                BlackMoveProp : DessineStringOnSquare(whichSquare,pionNoir,s,bidbool);
  			                otherwise       DessineStringOnSquare(whichSquare,pionNoir,s,bidbool);
  			              end;

  			              if (imagetteADessiner <> kAucuneImagette) then
			                  DrawImagetteMeteoOnSquare(imagetteADessiner,whichSquare);

  			            end;

		              inc(codeAsciiCaractere);
		            end;


	            L1 := L1^.tail;
	          end;
	      end;
      DisposePropertyList(L);


      doitEffacerSousLesTextesSurOthellier := tempoBool;
      SetPort(oldPort);
    end;
end;

procedure EffaceProchainsCoupsSurOthellier(G : GameTree; trait : SInt16);
var L : PropertyList;
    oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      ViderEtiquetesDesCasesSurLOthellier(othellierToutEntier);

      L := MakeListOfMovePropertyOfSons(trait,G);
      if (L <> NIL) then
        EffaceCasesDeLaListe(L);
      DisposePropertyList(L);

      SetPort(oldPort);
    end;
end;


procedure WritelnRacineDeLaPartieDansRapport;
var G : GameTree;
begin
  G := GetRacineDeLaPartie;
  WritelnStringAndGameTreeDansRapport('racine = ' + chr(13),G);
end;

procedure WritelnGameTreeCourantDansRapport;
var G : GameTree;
begin
  G := GetCurrentNode;
  WritelnStringAndGameTreeDansRapport('GameTreeCourant = ' + chr(13),G);
end;

procedure AfficheProprietes(G : GameTree; surQuellesCases : SquareSet);
begin

  {WritelnDansRapport('AfficheProprietes');}
  {WritelnNumDansRapport('gAffichageProprietesOfCurrentNode = ',gAffichageProprietesOfCurrentNode);}

  if affichePierresDelta and (BAND(gAffichageProprietesOfCurrentNode,kPierresDeltas) <> 0)
    then DesssinePierresDelta(G, surQuellesCases);

  if afficheProchainsCoups and (BAND(gAffichageProprietesOfCurrentNode,kProchainCoup) <> 0)
    then EcritProchainsCoupsSurOthellier(G, 0, afficheSignesDiacritiques, surQuellesCases);

  if (BAND(gAffichageProprietesOfCurrentNode,kCommentaires) <> 0)
    then
      begin
        {WritelnDansRapport('AfficheProprietes appelle EcritCommentaires');}
        EcritCommentaires(G);
      end;

  if (BAND(gAffichageProprietesOfCurrentNode,kNoeudDansFenetreArbreDeJeu) <> 0)
    then EcritNoeudDansFenetreArbreDeJeu(G, true);


  if (BAND(gAffichageProprietesOfCurrentNode,kCommentaires + kNoeudDansFenetreArbreDeJeu) <> 0) then
    FlushWindow(GetArbreDeJeuWindow);


  {
  WritelnNumDansRapport('adresse de G = ',SInt32(G));
  WritelnNumDansRapport('adresse de la racine = ',SInt32(GetRacineDeLaPartie));
  WritelnStringAndPropertyListDansRapport('proprietes de G = ',G^.properties);
  WritelnStringAndPropertyListDansRapport('proprietes de la racine = ',GetRacineDeLaPartie^.properties);
  }
end;

procedure EffaceProprietes(G : GameTree);
begin
  {WritelnDansRapport('EffaceProprietes');}
  EffaceProchainsCoupsSurOthellier(G,0);
  if affichePierresDelta then EffacePierresDelta(G);
  EffaceNoeudDansFenetreArbreDeJeu;
end;





function GetHashOfParametres(dessinerAideDebutantSiNecessaire : boolean; surQuellesCases : SquareSet) : SInt32;
type Params = record
                dessinerAide : boolean;
                aideActive   : boolean;
                affichage    : SInt32;
                nrocoup      : SInt32;
                cases        : SquareSet;
              end;
var p : Params;
begin
  p.dessinerAide := dessinerAideDebutantSiNecessaire;
  p.aideActive   := aideDebutant;
  p.affichage    := gAffichageProprietesOfCurrentNode;
  p.nrocoup      := nbreCoup;
  p.cases        := surQuellesCases;

  GetHashOfParametres := GenericHash(@p, SizeOf(params));
end;


function GetNombreAppelsRecursifsAfficheProprietesOfCurrentNode(params : SInt32) : SInt32;
var k, compteur : SInt32;
begin
  compteur := 0;

  with gPileAppelsRecursifsAfficheProprietesCurrentNode do
    begin
      for k := 1 to cardinalPile do
        if (pileParametres[k] = params)
          then inc(compteur);
    end;

  GetNombreAppelsRecursifsAfficheProprietesOfCurrentNode := compteur;
end;


function AddDansPileParametresRecursifsAfficheProprietesOfCurrentNode(params : SInt32) : SInt32;
var index : SInt32;
begin
  index := -1;

  with gPileAppelsRecursifsAfficheProprietesCurrentNode do
    begin
      if (cardinalPile < 100) then
        begin
          inc(cardinalPile);
          index := cardinalPile;

          pileParametres[cardinalPile]  := params;
        end;
    end;

  AddDansPileParametresRecursifsAfficheProprietesOfCurrentNode := index;
end;


procedure RemoveDansPileParametresRecursifsAfficheProprietesOfCurrentNode(index : SInt32; params : SInt32);
begin
  Discard(params);

  if (index >= 1) and (index <= 100) then
    with gPileAppelsRecursifsAfficheProprietesCurrentNode do
      begin
        pileParametres[index] := -1;

        if (index = cardinalPile) and (cardinalPile >= 1)
          then dec(cardinalPile)
          else WritelnDansRapport('ASSERT : pile des appels recursifs fausse dans RemoveDansPileParametresRecursifsAfficheProprietesOfCurrentNode !!');
      end;
end;


procedure AfficheProprietesOfCurrentNode(dessinerAideDebutantSiNecessaire : boolean; surQuellesCases : SquareSet; const fonctionAppelante : String255);
var G : GameTree;
    params, index : SInt32;
    nbAppelsRecursifs : SInt32;
    niveau, t : SInt32;
begin  {$UNUSED fonctionAppelante, t}

  ClearUselessVirtualZebraNodes;

  if (gAffichageProprietesOfCurrentNode <> kAucunePropriete) then
    begin

      inc(gPileAppelsRecursifsAfficheProprietesCurrentNode.nbAppelsRecursifs);


      niveau := gPileAppelsRecursifsAfficheProprietesCurrentNode.nbAppelsRecursifs;
      params := GetHashOfParametres(dessinerAideDebutantSiNecessaire, surQuellesCases);


      nbAppelsRecursifs := GetNombreAppelsRecursifsAfficheProprietesOfCurrentNode(params);

      if (nbAppelsRecursifs <= 0) then
        begin

          index  := AddDansPileParametresRecursifsAfficheProprietesOfCurrentNode(params);

          (*
          for t := 1 to niveau - 1 do
            WriteDansRapport('  ');
          WriteDansRapport('—> Entree ');
          WriteDansRapport('dans AfficheProprietesOfCurrentNode ');
    		  WriteNumDansRapport('  params = ',params);
          WriteDansRapport('  appel = ' + fonctionAppelante);
          // WriteNumDansRapport('  nbreCoup = ',nbreCoup);
          WriteDansRapport('   squares = ' + SquareSetEnString(surQuellesCases));
          WriteNumDansRapport('  level = ',niveau);
          WritelnNumDansRapport('  recur = ',nbAppelsRecursifs);
          *)

    		  if (dessinerAideDebutantSiNecessaire and aideDebutant)
    		    then
    		      begin
    		        if (BAND(gAffichageProprietesOfCurrentNode, kAideDebutant) <> 0)
    		          then DessineAideDebutant(true, surQuellesCases);  {ceci inclut un appel recursif AfficheProprietesOfCurrentNode(false,surQuellesCases)}
    		      end
    		    else
    		      begin
    		        G := GetCurrentNode;
    		        AfficheProprietes(G, surQuellesCases);
    		      end;
    		
    		
    		  (*
    		  for t := 1 to niveau - 1 do
            WriteDansRapport('  ');
    		  WriteDansRapport('<— Sortie ');
    		  WriteDansRapport('de AfficheProprietesOfCurrentNode ');
    		  WriteNumDansRapport('  params = ',params);
    		  WriteDansRapport('  appel = ' + fonctionAppelante);
    		  // WriteNumDansRapport('  nbreCoup = ',nbreCoup);
    		  WriteNumDansRapport('  level = ',niveau);
          WritelnNumDansRapport('  recur = ',nbAppelsRecursifs);
          *)


          RemoveDansPileParametresRecursifsAfficheProprietesOfCurrentNode(index, params);

        end;


      dec(gPileAppelsRecursifsAfficheProprietesCurrentNode.nbAppelsRecursifs);
		
		end;
end;


procedure EffaceProprietesOfCurrentNode;
var G : GameTree;
begin
  if (gEffacageProprietesOfCurrentNode <> 0) then
    begin
      {WritelnDansRapport('EffaceProprietesOfCurrentNode');}
      G := GetCurrentNode;
      EffaceProprietes(G);
    end;
end;


procedure EcritCommentaires(G : GameTree);
var commentaireChange : boolean;
begin
  if (G <> NIL) then
    begin
      {WritelnDansRapport('EcritCommentaires');}
      SetTexteFenetreArbreDeJeuFromArbreDeJeu(G,false,commentaireChange);
      if commentaireChange
        then DessineZoneDeTexteDansFenetreArbreDeJeu(false);
    end;
end;


procedure EcritCommentairesOfCurrentNode;
begin
  {WritelnDansRapport('EcritCommentairesOfCurrentNode');}
  EcritCommentaires(GetCurrentNode);
end;


procedure SetTexteFenetreArbreDeJeuFromArbreDeJeu(G : GameTree; redessineCommentaires : boolean; var commentaireChange : boolean);
var myText : TEHandle;
    texte : Ptr;
    longueur,longueurCouranteCommentaire : SInt32;
begin
 if arbreDeJeu.windowOpen and (GetArbreDeJeuWindow <> NIL) then
    begin
      myText := GetDialogTextEditHandle(arbreDeJeu.theDialog);
      if myText <> NIL then
        begin
          commentaireChange := false;
          GetCommentaireDeCeNoeud(G,texte,longueur);
          if (longueur > 0) and (texte <> NIL)
            then
              begin
                TESetText(texte,longueur,myText);
                commentaireChange := true;
              end
            else
              begin
                longueurCouranteCommentaire := TEGetTextLength(myText);
                {WritelnNumDansRapport('longueurCouranteCommentaire = ',longueurCouranteCommentaire);}
                if longueurCouranteCommentaire > 0 then
                  begin
                    TESetSelect(0,2000000000,myText);  {2000000000 was MaxLongint}
                    TEDelete(myText);
                    commentaireChange := true;
                  end;
              end;
          if redessineCommentaires and commentaireChange
            then DessineZoneDeTexteDansFenetreArbreDeJeu(false)
            else DessineRubanDuCommentaireDansFenetreArbreDeJeu(false);
        end;
    end;
end;


function EstVisibleDansFenetreArbreDeJeu(G : GameTree) : boolean;
var theCurrentNode : GameTree;
begin
  if G = NIL
    then
      EstVisibleDansFenetreArbreDeJeu := false
    else
      begin
        theCurrentNode := GetCurrentNode;
        EstVisibleDansFenetreArbreDeJeu := (G = theCurrentNode) or
                                           ((G^.father <> NIL) and (G^.father = theCurrentNode));
      end;
end;

function GetSignesDiacritiques(G : GameTree) : String255;
var s : String255;
    L : PropertyList;
    aux : PropertyPtr;
begin
  s := '';
  L := GetPropertyList(G);
  aux := SelectFirstPropertyOfTypes([TesujiProp,BadMoveProp,InterestingMoveProp,DubiousMoveProp,ExoticMoveProp],L);
  if (aux <> NIL) then
    case aux^.genre of
      TesujiProp :
	      if GetTripleOfProperty(aux^).nbTriples >= 2
	        then s := s + '!!'
	        else s := s + '!';
	    BadMoveProp :
	      if GetTripleOfProperty(aux^).nbTriples >= 2
	        then s := s + '??'
	        else s := s + '?';
	    InterestingMoveProp :
	      begin
	        {s := s + '!?';}
	      end;
	    DubiousMoveProp :
	      begin
	        {s := s + '?!';}
	      end;
	    ExoticMoveProp :
	      begin
	        s := s + '?!';
	      end;
    end;
  GetSignesDiacritiques := s;
end;


function DoitInverserLesScoresDeCetteCouleur(couleur : SInt32) : boolean;
begin
  DoitInverserLesScoresDeCetteCouleur := (couleur = -gCouleurDuCoupDeCetteLigne);
end;


procedure DessineGraphiquementTemperatureBibliothequeZebra(prop : Property; where : Point; var dimension : Point);
var theRect : rect;
    couleur,signe : SInt16;
    valeurEntiere,centiemes : SInt16;
    valeur, decalage : SInt32;
begin
  decalage := 2;
  SetPt(dimension,12 + decalage, 12);
  theRect := MakeRect(where.h + decalage ,
                      where.v + 2 ,
                      where.h + decalage + dimension.h ,
                      where.v + 2 + dimension.v );

  GetOthelloValueOfProperty(prop,couleur,signe,valeurEntiere,centiemes);

  valeur := valeurEntiere;
  valeur := 100*valeur+centiemes;
  if DoitInverserLesScoresDeCetteCouleur(couleur) then valeur := -valeur;

  if not(phaseCalculListePositionsProperties) then
    DessineCouleurDeZebraBookDansRect(theRect,gCouleurDuCoupDeCetteLigne,valeur,true);
end;


procedure DessinePropertyDansFenetreArbreDeJeu(var prop : Property; var positionHorizontale : SInt32; var continuer : boolean);
var largeur,couleur,signe,largeur1,largeur2 : SInt16;
    valeurEntiere,centiemes : SInt16;
    oldPositionHorizontale,n1,n2 : SInt32;
    s : String255;
    dimension,positionDessinIcone : Point;
    propertyBox : rect;
    description, aux : Property;
    inversion : boolean;
    useIconeForEndgameScores : boolean;
begin
  Discard(aux);

  largeur := 0;

  ForeColor(GetDisplayColorOfNodeInFenetreArbreDeJeu);

  GetPen(positionDessinIcone);
  positionDessinIcone.v := positionDessinIcone.v-12;
  case prop.genre of
    {BlackMoveProp,WhiteMoveProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        Move(dimension.h,0);
        s := CoupEnString(GetOthelloSquareOfProperty(prop),CassioUtiliseDesMajuscules);
        TextFace(bold);
        Move(2,0);
        MyDrawString(s);
        Move(espaceEntreProperties,0);
        largeur := dimension.h+MyStringWidth(s)+2;
        TextFace(normal);
      end;}
    GoodForWhiteProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    GoodForBlackProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    DrawMarkProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    InterestingMoveProp,DubiousMoveProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    ExoticMoveProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
        {EcritChaineOfProperty('!?',largeur);}
      end;
    BadMoveProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    {TesujiProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;}
    UnclearPositionProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    NodeNameProp :
      begin
        s := Concat(' «',GetStringInfoOfProperty(prop),'» ');
        EcritChaineOfProperty(s,largeur);
      end;
    NodeValueProp,
    ComputerEvaluationProp,
    ZebraBookProp,
    PerfectScoreProp :
      begin
        largeur := 0;
        largeur1 := 0;
        largeur2 := 0;
        SetPt(dimension, 0, 0);

        GetOthelloValueOfProperty(prop,couleur,signe,valeurEntiere,centiemes);

        if (valeurEntiere = 0) and (centiemes = 0) and
           (prop.genre <> ComputerEvaluationProp) and (prop.genre <> ZebraBookProp)
          then
            begin
              s := ReadStringFromRessource(TextesReflexionID,20);                {'Nulle'}
              s := Concat('  ',s,' ');
            end
          else
            begin

              inversion := DoitInverserLesScoresDeCetteCouleur(couleur);
              if (prop.genre = ZebraBookProp) and inversion then
                begin
                  couleur := -couleur;
                  signe := -signe;
                end;

	            if (prop.genre = ComputerEvaluationProp) or (prop.genre = ZebraBookProp)
	              then
	                begin
	                  case couleur of
      	              pionNoir  : {s := ReadStringFromRessource(TextesSolitairesID,19);}   {'Noir'}
      	                          s := CaracterePourNoir;
      	              pionBlanc : {s := ReadStringFromRessource(TextesSolitairesID,20);}   {'Blanc'}
      	                          s := CaracterePourBlanc;
      	              otherwise   s := '';
      	            end;
	                  if (signe >= 0)
	                    then s := Concat(' ',s,NoteEnString(valeurEntiere*100+centiemes,true,0,2),' ')
	                    else s := Concat(' ',s,NoteEnString(-(valeurEntiere*100+centiemes),true,0,2),' ')
	                end
	              else
			            begin
			              case couleur of
      	              pionNoir  : s := ReadStringFromRessource(TextesSolitairesID,19);   {'Noir'}
      	              pionBlanc : s := ReadStringFromRessource(TextesSolitairesID,20);   {'Blanc'}
      	              otherwise   s := '';
      	            end;

			              if (valeurEntiere >= 0)
			                then
			                  if signe >= 0
			                    then s := Concat('  ',s,'+',IntToStr(valeurEntiere),' ')
			                    else s := Concat('  ',s,'-',IntToStr(valeurEntiere),' ')
			                else
			                  if signe >= 0
			                    then s := Concat('  ',s,'-',IntToStr(-valeurEntiere),' ')
			                    else s := Concat('  ',s,'+',IntToStr(-valeurEntiere),' ');

			              useIconeForEndgameScores := false;

			              if useIconeForEndgameScores then
			                begin
    			              if (valeurEntiere >= 0)
    			                then
    			                  if signe >= 0
    			                    then s := Concat(' (', IntToStr(valeurEntiere),') ')
    			                    else s := Concat(' (-',IntToStr(valeurEntiere),') ')
    			                else
    			                  if signe >= 0
    			                    then s := Concat(' (-',IntToStr(-valeurEntiere),') ')
    			                    else s := Concat(' (', IntToStr(-valeurEntiere),') ');

    			              case couleur of
    			                pionNoir  : aux := MakeTripleProperty(GoodForBlackProp,MakeTriple(1));
          	              pionBlanc : aux := MakeTripleProperty(GoodForWhiteProp,MakeTriple(1));
          	            end;

          	            largeur1 := 0;
          	            SetPt(dimension, 0, 0);

          	            if DessineIconeProperty(aux,positionDessinIcone,dimension) then
                          begin
                            largeur1 := largeur1 + dimension.h;
                            Move(largeur1+ (espaceEntreProperties div 3),0);
                          end;

          	            DisposePropertyStuff(aux);
      	            end;


			            end;
	          end;


        SetPt(dimension, 0, 0);
        if (prop.genre = ZebraBookProp) and ZebraBookACetteOption(kAfficherCouleursZebraDansArbre) then
          DessineGraphiquementTemperatureBibliothequeZebra(prop,positionDessinIcone,dimension);
        Move(dimension.h, 0);

        if not((prop.genre = ZebraBookProp) and not(ZebraBookACetteOption(kAfficherNotesZebraDansArbre))) then
          begin
            ForeColor(GetDisplayColorOfNodeInFenetreArbreDeJeu);
            EcritChaineOfProperty(s,largeur2);
            largeur2 := largeur2 + dimension.h;
          end;

        largeur := largeur1 + largeur2;

      end;
    OpeningNameProp :
      begin
        s := Concat('«',GetStringInfoOfProperty(prop),'» ');
        EcritChaineOfProperty(s,largeur);
      end;
    TranspositionProp :
      begin
        if DessineIconeProperty(prop,positionDessinIcone,dimension) then
		      begin
		        largeur := dimension.h;
		        Move(largeur+espaceEntreProperties,0);
		      end;
      end;
    TranspositionRangeProp :
      begin
        GetCoupleLongintOfProperty(prop,n1,n2);
        s := IntToStr(n1) + '/' + IntToStr(n2);
        EcritChaineOfProperty(s,largeur);
      end;
    AddBlackStoneProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    AddWhiteStoneProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    RemoveStoneProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    CheckMarkProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    FigureProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    CommentProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    GameCommentProp :
      if DessineIconeProperty(prop,positionDessinIcone,dimension) then
      begin
        largeur := dimension.h;
        Move(largeur+espaceEntreProperties,0);
      end;
    SigmaProp :
      begin
        case GetTripleOfProperty(prop).nbTriples of
          1 : s := '∑';
          2 : s := '∑∑';
          otherwise s := ''{s := 'virtual'};
        end;
        if (s <> '') then
          EcritChaineOfProperty(s,largeur);
      end;
  end; {case}



  if largeur <> 0 then
    begin
      oldPositionHorizontale := positionHorizontale;
      positionHorizontale := positionHorizontale+largeur+espaceEntreProperties;
      if phaseCalculListePositionsProperties then
		    begin
		      propertyBox := MakeRect(oldPositionHorizontale-1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v+14);
		      {FrameRect(propertyBox);}
		      description := MakePointeurPropertyProperty(PointeurPropertyProp,gNoeudQuOnDessineSurCetteLigne,@prop,propertyBox);
		      AddPropertyInFrontOfList(description,listePositionsProperties);
		      DisposePropertyStuff(description);
		    end;
		end;

  ForeColor(BlackColor);

  continuer := true;
end;


{si le noeud est un embranchement, on dessine la marque d'embranchement}
{si le noeud est une feuille de l'arbre, on dessine la marque terminale}
procedure EcritIconesDeStructureDeLArbre(var G : GameTree; traiteEmbranchement,traiteFeuille : boolean; var positionHorizontale : SInt32);
const IconeEnbranchementID = 1158;
      IconeNoeudTerminalID = 1159;
      IconeNoeudNonTerminalID = 1164;
var positionDessinIcone,dimension : Point;
    oldPositionHorizontale : SInt32;
    description : Property;
    propertyBox : rect;
    nbFilsReels : SInt32;
begin

  traiteFeuille := traiteFeuille or not(IsAVirtualNode(G));

  nbFilsReels := NumberOfRealSons(G);

  oldPositionHorizontale := positionHorizontale;
  if traiteEmbranchement and (nbFilsReels >= 2) then
    begin
      GetPen(positionDessinIcone);
      positionDessinIcone.v := positionDessinIcone.v-12;
      DessinePetiteIconeFenetreArbreDeJeu(IconeEnbranchementID,positionDessinIcone,dimension);
      Move(dimension.h+espaceEntreProperties,0);
      positionHorizontale := positionHorizontale+dimension.h+espaceEntreProperties;
      if phaseCalculListePositionsProperties then
		    begin
		      propertyBox := MakeRect(oldPositionHorizontale-1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v+14);
		      {FrameRect(propertyBox);}
		      description := MakePointeurPropertyProperty(EmbranchementProp,G,NIL,propertyBox);
		      AddPropertyInFrontOfList(description,listePositionsProperties);
		      DisposePropertyStuff(description);
		    end;
    end else
  if traiteEmbranchement and (nbFilsReels = 1) and not(EstLaRacineDeLaPartie(G)) then
    begin
      GetPen(positionDessinIcone);
      positionDessinIcone.v := positionDessinIcone.v-12;
      DessinePetiteIconeFenetreArbreDeJeu(IconeNoeudNonTerminalID,positionDessinIcone,dimension);
      Move(dimension.h+espaceEntreProperties,0);
      positionHorizontale := positionHorizontale+dimension.h+espaceEntreProperties;
      if phaseCalculListePositionsProperties then
		    begin
		      propertyBox := MakeRect(oldPositionHorizontale-1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v+14);
		      {FrameRect(propertyBox);}
		      description := MakePointeurPropertyProperty(ContinuationProp,G,NIL,propertyBox);
		      AddPropertyInFrontOfList(description,listePositionsProperties);
		      DisposePropertyStuff(description);
		    end;
    end else
  if traiteFeuille and (nbFilsReels = 0) and not(EstLaRacineDeLaPartie(G)) then
    begin
      GetPen(positionDessinIcone);
      positionDessinIcone.v := positionDessinIcone.v-11;
      DessinePetiteIconeFenetreArbreDeJeu(IconeNoeudTerminalID,positionDessinIcone,dimension);
      Move(dimension.h+espaceEntreProperties,0);
      positionHorizontale := positionHorizontale+dimension.h+espaceEntreProperties;
      if phaseCalculListePositionsProperties then
		    begin
		      propertyBox := MakeRect(oldPositionHorizontale-1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v+14);
		      {FrameRect(propertyBox);}
		      description := MakePointeurPropertyProperty(FinVarianteProp,G,NIL,propertyBox);
		      AddPropertyInFrontOfList(description,listePositionsProperties);
		      DisposePropertyStuff(description);
		    end;
    end;
end;


procedure EcritProprietesDeCeFilsHorizontalement(var G : GameTree; var positionVerticale : SInt32; var continuer : boolean);
var positionHorizontale : SInt32;
    effacement : rect;
begin
  {WritelnNumDansRapport('EcritProprietesDeCeFilsHorizontalement, vert = ',positionVerticale);}

  positionHorizontale := 23;
  Moveto(positionHorizontale,positionVerticale);

  gNoeudQuOnDessineSurCetteLigne := G;
  SetDisplayColorOfNodeInFenetreArbreDeJeu(BlueColor);
  if nbreCoup <= 0  {on est à la racine de la partie}
    then DessineCoupDansFenetreArbreDeJeu(G^.properties,nbreCoup + 1,positionHorizontale)
    else DessineCoupDansFenetreArbreDeJeu(G^.properties,-1,positionHorizontale);
  ForEachPropertyInListDoAvecResult(G^.properties,DessinePropertyDansFenetreArbreDeJeu,positionHorizontale);

  EcritIconesDeStructureDeLArbre(G,true,false,positionHorizontale);

  if not(phaseCalculListePositionsProperties) then
    begin
      effacement := MakeRect(positionHorizontale,positionVerticale-espaceEntreLignesProperties+3,positionHorizontale+80,positionVerticale+1);
      MyEraseRect(effacement);
      MyEraseRectWithColor(effacement,VioletCmd,blackPattern,'');
    end;

  positionVerticale := positionVerticale+espaceEntreLignesProperties;
  continuer := (positionVerticale <= arbreDeJeu.EditionRect.top-12);

end;


procedure EcritProprietesDeCeNoeudHorizontalement(var G : GameTree; var positionVerticale : SInt32; var continuer : boolean);
var positionHorizontale : SInt32;
    effacement : rect;
    temporaire : boolean;
begin

  temporaire := ZebraBookACetteOption(kAfficherCouleursZebraDansArbre);
  if temporaire then ToggleZebraOption(kAfficherCouleursZebraDansArbre);

  positionHorizontale := 3;
  Moveto(positionHorizontale,positionVerticale);

  gNoeudQuOnDessineSurCetteLigne := G;
  SetDisplayColorOfNodeInFenetreArbreDeJeu(BlackColor);
  DessineCoupDansFenetreArbreDeJeu(G^.properties,nbreCoup,positionHorizontale);
  ForEachPropertyInListDoAvecResult(G^.properties,DessinePropertyDansFenetreArbreDeJeu,positionHorizontale);

  EcritIconesDeStructureDeLArbre(G,true,false,positionHorizontale);

  if not(phaseCalculListePositionsProperties) then
    begin
      effacement := MakeRect(positionHorizontale,positionVerticale-espaceEntreLignesProperties+3,positionHorizontale+80,positionVerticale+1);
      MyEraseRect(effacement);
      MyEraseRectWithColor(effacement,VioletCmd,blackPattern,'');
    end;

  positionVerticale := positionVerticale+espaceEntreLignesProperties;
  continuer := (positionVerticale <= arbreDeJeu.EditionRect.top-12);


  if temporaire then ToggleZebraOption(kAfficherCouleursZebraDansArbre);

end;

procedure SetDisplayColorOfNodeInFenetreArbreDeJeu(color : SInt32);
begin
  gDisplayColorOfNodeInFenetreArbreDeJeu := color;
end;


function GetDisplayColorOfNodeInFenetreArbreDeJeu : SInt32;
begin
  GetDisplayColorOfNodeInFenetreArbreDeJeu := gDisplayColorOfNodeInFenetreArbreDeJeu;
end;


procedure EcritNoeudDansFenetreArbreDeJeu(G : GameTree; avecEcritureDesFils : boolean);
var positionVerticale : SInt32;
    oldPort : grafPtr;
    continuer : boolean;
begin
  if arbreDeJeu.windowOpen and (G <> NIL) then
    begin
      {WritelnDansRapport('EcritNoeudDansFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow);

      PenMode(patCopy);
      RGBForeColor(gPurNoir);
      RGBBackColor(gPurBlanc);

      if (nbreCoup <= 0) and not(phaseCalculListePositionsProperties)
        then EffaceNoeudDansFenetreArbreDeJeu;

      positionVerticale := espaceEntreLignesProperties-1;
      continuer := (positionVerticale <= arbreDeJeu.EditionRect.top-12);
      if continuer then
        begin
          EcritProprietesDeCeNoeudHorizontalement(G,positionVerticale,continuer);
		      if continuer and avecEcritureDesFils then
		        ForEachSonDoAvecResult(G,EcritProprietesDeCeFilsHorizontalement,positionVerticale);
		    end;

      SetPort(oldPort);
    end;
end;

procedure EcritCurrentNodeDansFenetreArbreDeJeu(avecEcritureDesFils, doitEffacerPremiereLigneDeLaFenetre : boolean);
begin
  {WritelnDansRapport('EcritCurrentNodeDansFenetreArbreDeJeu');}

  if EstLaRacineDeLaPartie(GetCurrentNode) then EffaceNoeudDansFenetreArbreDeJeu;
  if doitEffacerPremiereLigneDeLaFenetre then EffacePremiereLigneFenetreArbreDeJeu;
  EcritNoeudDansFenetreArbreDeJeu(GetCurrentNode,avecEcritureDesFils);
end;


procedure EffaceNoeudDansFenetreArbreDeJeu;
var EffacageRect : rect;
    oldPort : grafPtr;
begin
  if arbreDeJeu.windowOpen then
    begin
      {WritelnDansRapport('EffaceNoeudDansFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow);

      SetRect(EffacageRect,0,0,arbreDeJeu.EditionRect.right+4,arbreDeJeu.EditionRect.top-12);
      MyEraseRect(EffacageRect);
      MyEraseRectWithColor(EffacageRect,VioletCmd,blackPattern,'');

      SetPort(oldPort);
    end;
end;

procedure EffacePremiereLigneFenetreArbreDeJeu;
var EffacageRect : rect;
    oldPort : grafPtr;
begin
  if arbreDeJeu.windowOpen then
    begin
      {WritelnDansRapport('EffacePremiereLigneFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow);

      SetRect(EffacageRect,0,0,arbreDeJeu.EditionRect.right+4,espaceEntreLignesProperties+1);
      MyEraseRect(EffacageRect);
      MyEraseRectWithColor(EffacageRect,VioletCmd,blackPattern,'');

      SetPort(oldPort);
    end;
end;


procedure ValideZoneCommentaireDansFenetreArbreDeJeu;
var myText : TEHandle;
begin
  with arbreDeJeu do
   begin
     if enModeEdition then
       begin
         enModeEdition := false;
         if not(EnTraitementDeTexte) then
           arbreDeJeu.doitResterEnModeEdition := false;
         GetCurrentScript(gLastScriptUsedInDialogs);
         SwitchToRomanScript;
       end;
	   if windowOpen and (theDialog <> NIL) then
	     begin
	       myText := GetDialogTextEditHandle(theDialog);
	       if myText <> NIL then TEDeactivate(myText);
	       DessineZoneDeTexteDansFenetreArbreDeJeu(false);
		     EcritCurrentNodeDansFenetreArbreDeJeu(false,true);  {on affiche ou non la petite incone de texte}
	     end;
   end;
end;

function InterligneArbreFenetreArbreDeJeu : SInt16;
begin
  InterligneArbreFenetreArbreDeJeu := espaceEntreLignesProperties;
end;

procedure DessinePetiteIconeFenetreArbreDeJeu(IconeID : SInt32; where : Point; var dimension : Point);
var unePicture : PicHandle;
    unRect : rect;
    oldport : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(GetArbreDeJeuWindow);
  unePicture := MyGetPicture(IconeID);
  unRect := GetPicFrameOfPicture(UnePicture);
  dimension.h := unRect.right-unRect.left;
  dimension.v := unRect.bottom-unRect.top;
  if not(phaseCalculListePositionsProperties) then
    begin
      OffsetRect(unRect,where.h,where.v);
      DrawPicture(unePicture,unRect);
    end;
  ReleaseResource(Handle(unePicture));
  SetPort(oldPort);
end;


procedure DessineImagetteFenetreArbreDeJeu(quelleImage : typeImagette; where : Point; var dimension : Point);
var bounds : rect;
begin
  dimension.h := 16;
  dimension.v := 16;
  bounds := MakeRect(where.h, where.v-1, where.h+dimension.h, where.v + dimension.v-1);

  if not(phaseCalculListePositionsProperties) then
    DrawImagetteMeteo(quelleImage,GetArbreDeJeuWindow,bounds,'DessineImagetteFenetreArbreDeJeu');
end;


function DessineIconeProperty(prop : Property; where : Point; var dimension : Point) : boolean;
var PictureADessinerID : SInt32;
    imagetteADessiner : typeImagette;
const IconeInformationID             = 1129;
      IconeCommentairesID            = 1130;
      IconeNodeNameID                = 1131;
      IconeSquareRootMarkID          = 1132;
      IconeDoubleSquareRootMarkID    = 1133;
      IconeExclamationMarkID         = 1134;
      IconeDoubleExclamationID       = 1135;
      IconeInterrogationMarkID       = 1136;
      IconeDoubleInterrogationMarkID = 1137;
      IconeCoupDouteuxID             = 1138;
      IconeCoupInteressantID         = 1139;
      IconeAvantageNoirID            = 1140;
      IconeGrosAvantageNoirID        = 1141;
      IconeAvantageBlancID           = 1142;
      IconeGrosAvantageBlancID       = 1143;
      IconeEgalID                    = 1144;
      IconeTresEgalID                = 1145;
      IconeInfiniID                  = 1146;
      IconeDoubleInfiniID            = 1147;
      IconeFinDeVarianteID           = 1148;
      IconeSigmaMarkID               = 1149;
      IconeDoubleSigmaMarkID         = 1150;
      IconePositionRemarquableID     = 1151;
      IconePositionTresRemarquableID = 1152;
      IconePosePionNoirsID           = 1153;
      IconePosePionsBlancsID         = 1154;
      IconeEnlevePionsID             = 1155;
      IconeRondNoirID                = 1156;
      IconeRondBlancID               = 1157;
      IconeEnbranchementID           = 1158;
      IconeNoeudTerminalID           = 1159;
      IconeInterversion1ID           = 1160;
      IconeInterversion2ID           = 1161;
      IconeMoinsBlancID              = 1162;
      IconeMoinsNoirID               = 1163;
begin
  PictureADessinerID := 0;
  imagetteADessiner  := kAucuneImagette;

  case prop.genre of
    BlackMoveProp                : PictureADessinerID := IconeRondNoirID;
    WhiteMoveProp                : PictureADessinerID := IconeRondBlancID;
    AddBlackStoneProp            : PictureADessinerID := IconePosePionNoirsID;
    AddWhiteStoneProp            : PictureADessinerID := IconePosePionsBlancsID;
    RemoveStoneProp              : PictureADessinerID := IconeEnlevePionsID;
    GoodForBlackProp             : if GetTripleOfProperty(prop).nbTriples < 2
                                       then
                                         begin
                                           case gCouleurDuCoupDeCetteLigne of
                                             pionNoir  : begin
                                                           PictureADessinerID := IconeAvantageNoirID;
                                                           {imagetteADessiner := kSunSmall;}
                                                         end;
                                             {pionBlanc : PictureADessinerID := IconeMoinsBlancID;}
                                             otherwise   PictureADessinerID := IconeAvantageNoirID;
                                           end;

                                         end
                                       else PictureADessinerID := IconeGrosAvantageNoirID;
    GoodForWhiteProp             : if GetTripleOfProperty(prop).nbTriples < 2
                                       then
                                         begin
                                           case gCouleurDuCoupDeCetteLigne of
                                             {pionNoir  : PictureADessinerID := IconeMoinsNoirID;}
                                             pionBlanc : begin
                                                            PictureADessinerID := IconeAvantageBlancID;
                                                            {imagetteADessiner := kSunSmall;}
                                                         end;
                                             otherwise   PictureADessinerID := IconeAvantageBlancID;
                                           end;

                                         end
                                       else PictureADessinerID := IconeGrosAvantageBlancID;
    DrawMarkProp                 : if GetTripleOfProperty(prop).nbTriples < 2
                                       then PictureADessinerID := IconeEgalID
                                       else PictureADessinerID := IconeTresEgalID;
    TesujiProp                   : if GetTripleOfProperty(prop).nbTriples < 2
                                       then PictureADessinerID := IconeExclamationMarkID
                                       else PictureADessinerID := IconeDoubleExclamationID;
    BadMoveProp                  : if GetTripleOfProperty(prop).nbTriples < 2
                                       then
                                         begin
                                           {PictureADessinerID := IconeInterrogationMarkID;}
                                         end
                                       else
                                         begin
                                           {PictureADessinerID := IconeDoubleInterrogationMarkID;}
                                           imagetteADessiner := kAlertSmall;
                                         end;
    InterestingMoveProp          : begin
                                     {PictureADessinerID := IconeCoupInteressantID;}
                                     imagetteADessiner := kSunCloudSmall;
                                   end;
    DubiousMoveProp              : begin
                                     {PictureADessinerID := IconeCoupDouteuxID;}
                                     imagetteADessiner := kThunderstormSmall;
                                   end;
    ExoticMoveProp               : PictureADessinerID := IconeCoupDouteuxID;
    UnclearPositionProp          : if GetTripleOfProperty(prop).nbTriples < 2
                                       then PictureADessinerID := IconeInfiniID
                                       else PictureADessinerID := IconeDoubleInfiniID;
    CheckMarkProp                : if GetTripleOfProperty(prop).nbTriples < 2
                                       then PictureADessinerID := IconeSquareRootMarkID
                                       else PictureADessinerID := IconeDoubleSquareRootMarkID;
    FigureProp                   : PictureADessinerID := IconePositionRemarquableID;
    CommentProp                  : PictureADessinerID := IconeCommentairesID;
    GameCommentProp              : PictureADessinerID := IconeCommentairesID;
    TranspositionProp            : PictureADessinerID := IconeInterversion1ID;
    EventProp,RoundProp,
    DateProp,PlaceProp,
    BlackPlayerNameProp,
    WhitePlayerNameProp,
    UserProp,SourceProp,
    WhiteTeamProp,
    BlackTeamProp                : PictureADessinerID := IconeInformationID;

  end;{case}

  if (PictureADessinerID = 0) and (imagetteADessiner = kAucuneImagette)
    then
      begin
        SetPt(dimension,0,0);
        DessineIconeProperty := false;
      end
    else
	    begin
	      if (PictureADessinerID <> 0) then
	        DessinePetiteIconeFenetreArbreDeJeu(PictureADessinerID,where,dimension);

	      if (imagetteADessiner <> kAucuneImagette) then
	        DessineImagetteFenetreArbreDeJeu(imagetteADessiner,where,dimension);

	      DessineIconeProperty := true;
	    end;
end;

procedure EcritChaineOfProperty(const s : String255; var largeur : SInt16);
var penLocation : Point;
    myRect : Rect;
begin
  TextFont(gCassioApplicationFont);
  TextSize(10);

  if gCassioUseQuartzAntialiasing then
    begin
      if SetAntiAliasedTextEnabled(true,9) = NoErr then DoNothing;
	    EnableQuartzAntiAliasingThisPort(GetDialogPort(arbreDeJeu.theDialog),true);
    end;

  largeur := MyStringWidth(s);
  if phaseCalculListePositionsProperties
    then
      Move(largeur+espaceEntreProperties,0)
    else
      begin
        if gCassioUseQuartzAntialiasing and (GetPortPenLocation(qdThePort, penLocation) <> NIL) then
          begin
            myRect := MakeRect(penLocation.h,
                             penLocation.v - espaceEntreLignesProperties + 3,
                             penLocation.h + largeur+1,
                             penLocation.v+2);
            MyEraseRect(myRect);
            MyEraseRectWithColor(myRect,VioletCmd,blackPattern,'');
          end;
        MyDrawString(s);
        Move(espaceEntreProperties,0);
      end;
  TextSize(9);
end;

procedure DessineCoupDansFenetreArbreDeJeu(L : PropertyList; numeroDuCoup : SInt16; var positionHorizontale : SInt32);
var s : String255;
    prop : PropertyPtr;
    description : Property;
    dimension,positionDessinIcone : Point;
    largeur : SInt16;
    oldPositionHorizontale : SInt32;
    propertyBox : rect;
begin
  prop := SelectFirstPropertyOfTypes([BlackMoveProp,WhiteMoveProp],L);
  if prop = NIL
    then
      gCouleurDuCoupDeCetteLigne := pionVide
    else
	    begin
	      if prop^.genre = BlackMoveProp
	        then gCouleurDuCoupDeCetteLigne := pionNoir
	        else gCouleurDuCoupDeCetteLigne := pionBlanc;
	      oldPositionHorizontale := positionHorizontale;
	      GetPen(positionDessinIcone);
	      positionDessinIcone.v := positionDessinIcone.v-12;
	      if DessineIconeProperty(prop^,positionDessinIcone,dimension) then
	        begin
	          Move(dimension.h,0);
	          positionHorizontale := positionHorizontale+dimension.h;

	          if (numeroDuCoup > 0) and (numeroDuCoup <= 64)
	            then s := IntToStr(numeroDuCoup)+'.'
	            else s := '';
	          s := s + CoupEnString(GetOthelloSquareOfProperty(prop^),CassioUtiliseDesMajuscules);

	          prop := SelectFirstPropertyOfTypes([TesujiProp,BadMoveProp,InterestingMoveProp,DubiousMoveProp,ExoticMoveProp],L);
	          if prop <> NIL then
	            case prop^.genre of
	              TesujiProp :
	                if GetTripleOfProperty(prop^).nbTriples >= 2
	                  then s := s + ' !!'
	                  else s := s + ' !';
	              BadMoveProp :
	                if GetTripleOfProperty(prop^).nbTriples >= 2
	                  then s := s + ' ??'
	                  else s := s + ' ?';
	              InterestingMoveProp :
	                begin
	                  {s := s + '!?';}
	                end;
	              DubiousMoveProp :
	                begin
	                  {s := s + '?!';}
	                end;
	              ExoticMoveProp :
	                begin
	                  {s := s + '?!';}
	                end;
	            end; {case}

	          TextFace(bold);
	          Move(4,0);
	          positionHorizontale := positionHorizontale + 4;

	          EcritChaineOfProperty(s,largeur);

	          TextFace(normal);
	          positionHorizontale := positionHorizontale + largeur + espaceEntreProperties;

	          if phaseCalculListePositionsProperties then
					    begin
					      propertyBox := MakeRect(oldPositionHorizontale - 1,positionDessinIcone.v,positionHorizontale-1,positionDessinIcone.v + 14);
					      {FrameRect(propertyBox);}
					      description := MakePointeurPropertyProperty(PointeurPropertyProp,gNoeudQuOnDessineSurCetteLigne,prop,propertyBox);
					      AddPropertyInFrontOfList(description,ListePositionsProperties);
					      DisposePropertyStuff(description);
					    end;
	        end;
	    end;
end;


procedure DetruireCeFilsOfCurrentNode(var whichSon : GameTree);
begin
  EffaceProprietesOfCurrentNode;
  DeleteSonOfCurrentNode(whichSon);
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DetruireCeFilsOfCurrentNode');
  AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DetruireCeFilsOfCurrentNode');
  SetNiveauTeteDeMort(0);
  AjusteCurseur;
  GarbageCollectionDansTableHashageInterversions;
end;



procedure InverserLeNiemeFilsDansFenetreArbreDeJeu(N : SInt16);
var unRect : rect;
    minimum : SInt32;
    oldport : grafPtr;
begin
  with arbreDeJeu do
    begin
		  GetPort(oldport);
		  SetPortByWindow(GetArbreDeJeuWindow);
		  minimum := backMoveRect.bottom+espaceEntreLignesProperties*(N-1);

		  SetRect(unRect , 23 , minimum  , 400, minimum + 1);
		  HiliteRect(unRect);

		  SetRect(unRect , 399 , minimum  , 400 , minimum + 13);
		  HiliteRect(unRect);

		  SetRect(unRect , 23 , minimum + 13 , 400 , minimum + 14);
		  HiliteRect(unRect);

		  SetRect(unRect , 23  ,minimum  , 25 , minimum + 14);
		  HiliteRect(unRect);

		  SetPort(oldport);
		end;
end;

procedure CalculePropertiesDescriptionList;
begin
  VideListePositionsProperties;
  SetPhaseCalculListePositionsProperties(true);
  EcritNoeudDansFenetreArbreDeJeu(GetCurrentNode,true);
  SetPhaseCalculListePositionsProperties(false);
end;

function PtInPropertyRect(var prop : Property; var mouseLocEnLongint : SInt32) : boolean;
begin
  PtInPropertyRect := PtInRect(Point(mouseLocEnLongint),GetRectangleAffichageOfProperty(prop));
end;

function PropertyPointeeParSouris : PropertyPtr;
var mouseLoc : Point;
begin
  if not(phaseCalculListePositionsProperties) then { pas d'appel recursif }
    begin
      GetMouse(mouseLoc);
      CalculePropertiesDescriptionList;
      PropertyPointeeParSouris := SelectInPropertList(listePositionsProperties,PtInPropertyRect,SInt32(mouseLoc));
      VideListePositionsProperties;
    end;
end;

function SurIconeInterversion(whichPoint : Point; var noeudCorrespondant : GameTree) : boolean;
var description,prop : PropertyPtr;
begin
  SurIconeInterversion := false;
  noeudCorrespondant := NIL;
  if not(phaseCalculListePositionsProperties) then { pas d'appel recursif }
    begin
      CalculePropertiesDescriptionList;
      description := SelectInPropertList(listePositionsProperties,PtInPropertyRect,SInt32(whichPoint));
      if (description <> NIL) then
        begin
          prop := GetPropertyPtrOfProperty(description^);
          noeudCorrespondant := GetPossesseurOfPointeurPropertyProperty(description^);
          SurIconeInterversion := (prop <> NIL) and
                                  ((prop^.genre = TranspositionProp) or (prop^.genre = TranspositionRangeProp));
        end;
      VideListePositionsProperties;
    end;
end;


procedure AfficheCommentaireOfNodeDansRapport(var G : GameTree; var numeroDuCoup : SInt32; var commentaireVide : boolean);
var texte : Ptr;
    coup : SInt32;
    longueurDuCommentaire : SInt32;
begin
  longueurDuCommentaire := 0;
  commentaireVide := true;
  if NoeudHasCommentaire(G) then
    begin
      commentaireVide := false;
      if not(EstLaRacineDeLaPartie(G)) and GetSquareOfMoveInNode(G,coup) then
        begin
          ChangeFontSizeDansRapport(gCassioRapportBoldSize);
          ChangeFontDansRapport(gCassioRapportBoldFont);
          ChangeFontFaceDansRapport(bold);
          WriteDansRapport(IntToStr(numeroDuCoup)+'.'+CoupEnString(coup,CassioUtiliseDesMajuscules)+' ');
          TextNormalDansRapport;
          WriteDansRapport(': ');
        end;
      GetCommentaireDeCeNoeud(G,texte,longueurDuCommentaire);
      InsereTexteDansRapport(texte,longueurDuCommentaire);
      WritelnDansRapport('');
    end;
end;

procedure AfficheCommentairePartieDansRapport;
var partieEnAlpha,s : String255;
    positionCourante : PositionEtTraitRec;
begin
  if CreatePartieEnAlphaJusqua(GetCurrentNode,partieEnAlpha,positionCourante) then
    begin
      s := ReadStringFromRessource(10020,9) + partieEnAlpha;  {'Commentaires de '}

      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport(s);
      TextNormalDansRapport;

      ForEachPositionOnPathToCurrentNodeDo(AfficheCommentaireOfNodeDansRapport);
    end;
end;


procedure AddTranspositionPropertyToCurrentNode(var texte : String255);
var interversionProp : Property;
    G : GameTree;
begin
  G := GetCurrentNode;
  if (G <> NIL) and (SelectFirstPropertyOfTypesInGameTree([TranspositionProp],G) = NIL) then
    begin
      interversionProp := MakeStringProperty(TranspositionProp,texte);
      AddPropertyToGameTree(interversionProp,G);
      if not(PendantLectureFormatSmartGameBoard) and
         (GetAffichageProprietesOfCurrentNode <> kAucunePropriete) then
        begin
          EcritCurrentNodeDansFenetreArbreDeJeu(false,true);
        end;
      DisposePropertyStuff(interversionProp);
    end;
end;



end.
