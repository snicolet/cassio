UNIT UnitEndgameTree;



INTERFACE







 USES UnitDefCassio;



(* initialisation de l'unite *)
procedure InitUnitEndgameTree;


(* fonction pour parcourir localement l'arbre en finale *)
procedure SearchPositionFromThisNode(whichPosition : PositionEtTraitRec; whichNode : GameTree; var result : GameTree);
function AllocateNewEndgameTree(startingNode : GameTree; var numeroArbre : SInt32) : boolean;
procedure LibereEndgameTree(numeroArbre : SInt32);
procedure DoMoveEndgameTree(numeroArbre,coup,trait : SInt32);
procedure UndoMoveEndgameTree(numeroArbre : SInt32);
function GetActiveNodeOfEndgameTree(numeroArbre : SInt32) : GameTree;
function GetMagicCookieInitialEndgameTree(numeroArbre : SInt32) : SInt32;
function NbMaxEndgameTrees : SInt32;
procedure EcritStatistiquesEndgameTrees;

(* fonction de minimax utilisant les GameTree *)
function TrouveMeilleurFilsNoir(G : GameTree; var bestScoreNoir : SInt32) : GameTree;
function TrouveMeilleurFilsBlanc(G : GameTree; var bestScoreBlanc : SInt32) : GameTree;
function SelectionneMeilleurCoupNoirDansListe(L : GameTreeList; var bestBlackScore : SInt32) : GameTree;
function SelectionneMeilleurCoupBlancDansListe(L : GameTreeList; var bestWhiteScore : SInt32) : GameTree;


(* recherche des valeurs minimales et maximales stockees dans les EndgameTree *)
function GetValeurMinimumParEndgameTree(numeroArbre,deltaFinale : SInt32) : SInt32;
function GetValeurMaximumParEndgameTree(numeroArbre,deltaFinale : SInt32) : SInt32;
function ConnaitValeurDuNoeudParEndgameTree(numeroArbre,deltaFinale : SInt32; var vmin,vmax : SInt32) : boolean;

(* finale par l'arbre *)
function PeutCalculerFinaleParEndgameTree(numeroArbre : SInt32; position : PositionEtTraitRec; var listeDesCoups : PropertyList; var meilleurScore : SInt32) : boolean;
function SuiteParfaiteEstConnueDansGameTree : boolean;
procedure SetSuiteParfaiteEstConnueDansGameTree(flag : boolean);





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitArbreDeJeuCourant, UnitHashTableExacte, UnitServicesDialogs, UnitFinaleFast, UnitRapport, UnitGameTree
    , MyStrings, MyMathUtils, UnitPositionEtTrait, UnitPropertyList, UnitProperties, UnitScannerUtils ;
{$ELSEC}
    ;
    {$I prelink/EndgameTree.lk}
{$ENDC}


{END_USE_CLAUSE}











const kNbMaxEndgameTrees = 5;  {suffisant pour 5 appels imbriques a MakeEndgameSearch}
      kMaxDepthOfEachEndagmeTree = 3;
var gSuiteParfaiteEstConnueDansGameTree : boolean;
    endgameTrees:
      record
        nbEndgameTreeUtilises : SInt32;
        theTree:
          array[1..kNbMaxEndgameTrees] of
		        record
		          initialCookie : SInt32;
		          activeNode : GameTree;
		          activeNodeCookie : SInt32;
		          pathNodes : array[0..kMaxDepthOfEachEndagmeTree] of GameTree;
		          pathNodesCookies : array[0..kMaxDepthOfEachEndagmeTree] of SInt32;
		          activeDepth : SInt32;
		          estLibre : boolean;
		        end;
	    end;


procedure SetActiveNodeEndgameTree(numeroEndgameTree : SInt32; G : GameTree);
begin
  if (numeroEndgameTree >= 1) and (numeroEndgameTree <= kNbMaxEndgameTrees) then
	  with endgameTrees.theTree[numeroEndgameTree] do
		  if G = NIL
		    then
		      begin
		        activeNode := NIL;
		        activeNodeCookie := 0;
		        {WritelnDansRapport('WARNING : G = NIL dans SetActiveNodeEndgameTree');}
		      end
		    else
		      begin
		        activeNode := G;
		        activeNodeCookie := GetGameNodeMagicCookie(G);
		      end;
end;

procedure SetPathNodeEndgameTree(numeroEndgameTree : SInt32; depth : SInt32; G : GameTree);
begin
  if (numeroEndgameTree >= 1) and (numeroEndgameTree <= kNbMaxEndgameTrees) then
	  with endgameTrees.theTree[numeroEndgameTree] do
		  if (depth >= 0) and (depth <= kMaxDepthOfEachEndagmeTree)
		    then
		      begin
		        if G = NIL
		          then
		            begin
		              pathNodes[depth]        := NIL;
		              pathNodesCookies[depth] := 0;
		              {WritelnNumDansRapport('WARNING : G = NIL dans SetPathNodeEndgameTree, depth = ',depth);}
		            end
		          else
		            begin
		              pathNodes[depth]        := G;
		              pathNodesCookies[depth] := GetGameNodeMagicCookie(G);
		            end;
		      end
		    else
		      begin
		        WritelnDansRapport('ERREUR : depth = '+NumEnString(depth)+' dans SetPathNodeEndgameTree');
		      end;
end;


procedure InitUnitEndgameTree;
var i,d : SInt32;
begin

  usingEndgameTrees := true;

  with endgameTrees do
    begin
      nbEndgameTreeUtilises := 0;
      for i := 1 to kNbMaxEndgameTrees do
        with theTree[i] do
	      begin
	        estLibre      := true;
	        activeDepth   := 0;
	        initialCookie := 0;
	        SetActiveNodeEndgameTree(i,NIL);
	        for d := 0 to kMaxDepthOfEachEndagmeTree  do
	          SetPathNodeEndgameTree(i,d,NIL);
	      end;
    end;

  SetSuiteParfaiteEstConnueDansGameTree(false);

end;



function ActiveNodeEstValideEndgameTree(numeroEndgameTree : SInt32) : boolean;
begin
  if (numeroEndgameTree < 1) and (numeroEndgameTree > kNbMaxEndgameTrees)
    then
      ActiveNodeEstValideEndgameTree := false
    else
      begin
        with endgameTrees.theTree[numeroEndgameTree] do
				  begin
				    ActiveNodeEstValideEndgameTree := (activeNode <> NIL) and
				                                      (activeNodeCookie = GetGameNodeMagicCookie(activeNode));
				   {WritelnNumDansRapport('dans ActiveNodeEstValideEndgameTree(',numeroEndgameTree);
				    WritelnNumDansRapport('         activeNode = ',SInt32(activeNode));
				    WritelnNumDansRapport('         activeNodeCookie = ',activeNodeCookie);
				    WritelnNumDansRapport('         GetGameNodeMagicCookie(activeNode) = ',GetGameNodeMagicCookie(activeNode));
				   }
				  end;
		  end;
end;

function PathNodeEstValideEndgameTree(numeroEndgameTree : SInt32; depth : SInt32) : boolean;
begin
  if (numeroEndgameTree < 1) and (numeroEndgameTree > kNbMaxEndgameTrees)
    then
      PathNodeEstValideEndgameTree := false
    else
      begin
			  with endgameTrees.theTree[numeroEndgameTree] do
				  if (depth >= 0) and (depth <= kMaxDepthOfEachEndagmeTree)
				    then
				      begin
				        PathNodeEstValideEndgameTree := (pathNodes[depth] <> NIL) and
				                                        (pathNodesCookies[depth] = GetGameNodeMagicCookie(pathNodes[depth]))
				      end
				    else
				      begin
				        WritelnDansRapport('ERREUR : depth = '+NumEnString(depth)+' dans PathNodeEstValideEndgameTree');
				        PathNodeEstValideEndgameTree := false;
				      end;
			end;
end;






procedure MaximiseScoreNoir(var G, bestBlackNode : GameTree; var bestBlackScore : SInt32; var continuer : boolean);
var scoreMinCourant,scoreMaxCourant,couleur : SInt32;
    bonneCouleur : boolean;
begin
  couleur := pionNoir;
  case couleur of
    pionNoir  : bonneCouleur := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp],G) <> NIL;
    pionBlanc : bonneCouleur := SelectFirstPropertyOfTypesInGameTree([WhiteMoveProp],G) <> NIL;
    otherwise   bonneCouleur := false;
  end;

  if not(bonneCouleur)
    then
      begin
	      SysBeep(0);
	      WritelnDansRapport('ERREUR : mauvaise couleur dans MaximiseScoreNoir, prevenez Stephane');
	      AlerteSimple('ERREUR : mauvaise couleur dans MaximiseScoreNoir, prevenez Stephane');
	    end
    else
	    begin
	      if GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMinCourant,scoreMaxCourant) then
		      if scoreMinCourant > bestBlackScore then
		        begin
		          bestBlackNode := G;
		          bestBlackScore := scoreMinCourant;
		        end;
	    end;

  continuer := bonneCouleur;
end;

procedure MaximiseScoreBlanc(var G, bestWhiteNode : GameTree; var bestWhiteScore : SInt32; var continuer : boolean);
var scoreMinCourant,scoreMaxCourant,couleur : SInt32;
    bonneCouleur : boolean;
begin
  couleur := pionBlanc;
  case couleur of
    pionNoir  : bonneCouleur := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp],G) <> NIL;
    pionBlanc : bonneCouleur := SelectFirstPropertyOfTypesInGameTree([WhiteMoveProp],G) <> NIL;
    otherwise   bonneCouleur := false;
  end;

  if not(bonneCouleur)
    then
      begin
	      SysBeep(0);
	      WritelnDansRapport('ERREUR : mauvaise couleur dans MaximiseScoreBlanc, prevenez Stephane');
	      AlerteSimple('ERREUR : mauvaise couleur dans MaximiseScoreBlanc, prevenez Stephane');
	    end
    else
	    begin
	      if GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMinCourant,scoreMaxCourant) then
		      if scoreMinCourant > bestWhiteScore then
		        begin
		          bestWhiteNode := G;
		          bestWhiteScore := scoreMinCourant;
		        end;
	    end;

  continuer := bonneCouleur;
end;




function SelectionneMeilleurCoupNoirDansListe(L : GameTreeList; var bestBlackScore : SInt32) : GameTree;
var bestBlackNode : GameTree;
begin
  bestBlackScore := -1000;
  bestBlackNode := NIL;

  ForEachGameTreeInListDoAvecGameTreeEtResult(L,MaximiseScoreNoir,bestBlackNode,bestBlackScore);
  SelectionneMeilleurCoupNoirDansListe := bestBlackNode;
end;



function SelectionneMeilleurCoupBlancDansListe(L : GameTreeList; var bestWhiteScore : SInt32) : GameTree;
var bestWhiteNode : GameTree;
begin
  bestWhiteScore := -1000;
  bestWhiteNode := NIL;

  ForEachGameTreeInListDoAvecGameTreeEtResult(L,MaximiseScoreBlanc,bestWhiteNode,bestWhiteScore);
  SelectionneMeilleurCoupBlancDansListe := bestWhiteNode;
end;


function TrouveMeilleurFilsNoir(G : GameTree; var bestScoreNoir : SInt32) : GameTree;
begin
  TrouveMeilleurFilsNoir := SelectionneMeilleurCoupNoirDansListe(GetSons(G),bestScoreNoir);
end;


function TrouveMeilleurFilsBlanc(G : GameTree; var bestScoreBlanc : SInt32) : GameTree;
begin
  TrouveMeilleurFilsBlanc := SelectionneMeilleurCoupBlancDansListe(GetSons(G),bestScoreBlanc);
end;



procedure SearchPositionFromThisNode(whichPosition : PositionEtTraitRec; whichNode : GameTree; var result : GameTree);
var t,coup : SInt32;
    positionArbre,positionFils : PositionEtTraitRec;
    oldCurrentNode : GameTree;
    err : OSErr;
    isNew : boolean;
begin
  result := NIL;

  if GetPositionEtTraitACeNoeud(whichNode, positionArbre, 'SearchPositionFromThisNode') then
    begin

		  (* whichNode est-il directement la position whichPosition ? *)
		  if SamePositionEtTrait(whichPosition,positionArbre)
		    then
		      begin
		        (* WritelnDansRapport('CompareNodeAndPosition : mêmes positions'); *)
		        result := whichNode;
		      end
		    else
		      begin
		        (* sinon on cherche whichPosition parmi les fils de whichNode,
		          en creeant eventuellement ce fils *)
		        positionFils := positionArbre;
		        for t := 1 to 64 do
		          begin
		            coup := othellier[t];
		            if UpdatePositionEtTrait(positionFils,coup) then
		              begin
		                if SamePositionEtTrait(whichPosition,positionFils) then
		                  begin

		                    oldCurrentNode := GetCurrentNode;
		                    SetCurrentNode(whichNode, 'SearchPositionFromThisNode {1}');

		                    err := ChangeCurrentNodeAfterThisMove(coup,GetTraitOfPosition(positionArbre),'SearchPositionFromThisNode',isNew);
		                    if (err = 0) then
		                      begin
		                        result := GetCurrentNode;
		                        if isNew then MarquerCeNoeudCommeVirtuel(result);
		                      end;

		                    SetCurrentNode(oldCurrentNode, 'SearchPositionFromThisNode {2}');

		                    (* WritelnDansRapport('CompareNodeAndPosition : position trouvée parmi les fils'); *)
		                    exit(SearchPositionFromThisNode);
		                  end;
		                positionFils := positionArbre;
		              end;
		          end;
		        (* meme pas trouve parmi les fils, on abandonne *)
		        WritelnDansRapport('SearchPositionFromThisNode : position non trouvee !!');
		        SysBeep(0);
		      end;
		end
  else
		begin
		  WritelnDansRapport('SearchPositionFromThisNode : not(GetPositionEtTraitACeNoeud) !!');
		  SysBeep(0);
		end;
end;

function AllocateNewEndgameTree(startingNode : GameTree; var numeroArbre : SInt32) : boolean;
var i,d : SInt32;
begin
  with endgameTrees do
    begin
      numeroArbre := -1;  {par defaut : allocation non reussie}
      AllocateNewEndgameTree := false;

      if (startingNode <> NIL) and (nbEndgameTreeUtilises < kNbMaxEndgameTrees) then
		      for i := 1 to kNbMaxEndgameTrees do
		        with theTree[i] do
		          if estLibre then
		            begin
		              inc(nbEndgameTreeUtilises);

		              SetActiveNodeEndgameTree(i,startingNode);
		              SetPathNodeEndgameTree(i,0,startingNode);
		              for d := 1 to kMaxDepthOfEachEndagmeTree do
		                SetPathNodeEndgameTree(i,d,NIL);

		              estLibre      := false;
		              activeDepth   := 0;
		              initialCookie := NewMagicCookie;

		              (* WritelnDansRapport('trouvé ! => AllocateNewEndgameTree('+NumEnString(i)+')'); *)

		              AllocateNewEndgameTree := true;
		              numeroArbre := i;
		              exit(AllocateNewEndgameTree);
		            end;
		end;
end;

procedure LibereEndgameTree(numeroArbre : SInt32);
var d : SInt32;
begin
  (* WritelnDansRapport('LibereEndgameTree('+NumEnString(numeroArbre)+')'); *)
  with endgameTrees do
    begin
      if (numeroArbre >= 1) and (numeroArbre <= kNbMaxEndgameTrees) then
        begin
          if not(ActiveNodeEstValideEndgameTree(numeroArbre)) and
             (interruptionReflexion = pasdinterruption) then
            begin
              SysBeep(0);
              WritelnDansRapport('WARNING : activeNode non valide dans LibereEndgameTree');
              exit(LibereEndgameTree);
            end;

	        dec(nbEndgameTreeUtilises);
	        with theTree[numeroArbre] do
	          begin
	            estLibre      := true;
	            activeDepth   := 0;
	            initialCookie := 0;

	            SetActiveNodeEndgameTree(numeroArbre,NIL);
	            for d := 0 to kMaxDepthOfEachEndagmeTree  do
		            SetPathNodeEndgameTree(numeroArbre,d,NIL);
	          end;
	      end;
	  end;
end;




procedure DoMoveEndgameTree(numeroArbre,coup,trait : SInt32);
var oldCurrentNode : GameTree;
    err : OSErr;
    isNew : boolean;
begin
  if (numeroArbre >= 1) and (numeroArbre <= kNbMaxEndgameTrees) then
    with endgameTrees.theTree[numeroArbre] do
      if (activeDepth < kMaxDepthOfEachEndagmeTree) and
         ActiveNodeEstValideEndgameTree(numeroArbre)
        then
	        begin
	          oldCurrentNode := GetCurrentNode;

	          SetCurrentNode(activeNode, 'DoMoveEndgameTree {1}');
	          err := ChangeCurrentNodeAfterThisMove(coup,trait,'DoMoveEndgameTree',isNew);
	          if err = NoErr
	            then
	              begin
	                SetActiveNodeEndgameTree(numeroArbre,GetCurrentNode);
	                inc(activeDepth);
	                SetPathNodeEndgameTree(numeroArbre,activeDepth,activeNode);
	                if isNew then MarquerCurrentNodeCommeVirtuel;
	              end
	            else
	              begin
	                SetActiveNodeEndgameTree(numeroArbre,NIL);
	                SysBeep(0);
	                WritelnNumDansRapport('erreur 1 dans DoMoveEndgameTree : err = ',err);
	              end;

	          SetCurrentNode(oldCurrentNode, 'DoMoveEndgameTree {2}');
	        end
        else
          begin
            WritelnNumDansRapport('erreur 2 dans DoMoveEndgameTree : activeDepth = ',activeDepth);
            WritelnNumDansRapport('                            activeNode = ',SInt32(activeNode));
          end;
end;

procedure UndoMoveEndgameTree(numeroArbre : SInt32);
begin
  if (numeroArbre >= 1) and (numeroArbre <= kNbMaxEndgameTrees) then
    with endgameTrees.theTree[numeroArbre] do
      if (activeDepth > 0) and
         ActiveNodeEstValideEndgameTree(numeroArbre)
        then
	        begin
	          dec(activeDepth);
	          SetActiveNodeEndgameTree(numeroArbre,activeNode^.father);
	          if not(ActiveNodeEstValideEndgameTree(numeroArbre)) then
	            begin
	              WritelnDansRapport('ERREUR : activeNode invalide apres activeNode^.father dans UndoMoveEndgameTree');
	            end;
	        end
	      else
	        begin
	          WritelnNumDansRapport('erreur dans UndoMoveEndgameTree : activeDepth = ',activeDepth);
            WritelnNumDansRapport('                            activeNode = ',SInt32(activeNode));
	        end;
end;

function GetActiveNodeOfEndgameTree(numeroArbre : SInt32) : GameTree;
begin
  if (numeroArbre >= 1) and (numeroArbre <= kNbMaxEndgameTrees) and
     ActiveNodeEstValideEndgameTree(numeroArbre)
    then GetActiveNodeOfEndgameTree := endgameTrees.theTree[numeroArbre].activeNode
    else GetActiveNodeOfEndgameTree := NIL;
end;

function GetMagicCookieInitialEndgameTree(numeroArbre : SInt32) : SInt32;
begin
  if (numeroArbre >= 1) and (numeroArbre <= kNbMaxEndgameTrees)
    then GetMagicCookieInitialEndgameTree := endgameTrees.theTree[numeroArbre].initialCookie
    else GetMagicCookieInitialEndgameTree := 0;
end;

function NbMaxEndgameTrees : SInt32;
begin
  NbMaxEndgameTrees := kNbMaxEndgameTrees;
end;

procedure EcritStatistiquesEndgameTrees;
begin
  WritelnNumDansRapport('nbEndgameTreeUtilises = ', endgameTrees.nbEndgameTreeUtilises);
end;



function GetValeurMinimumParEndgameTree(numeroArbre,deltaFinale : SInt32) : SInt32;
begin
  if (numeroArbre >= 1) and (numeroArbre <= kNbMaxEndgameTrees) and ActiveNodeEstValideEndgameTree(numeroArbre)
    then GetValeurMinimumParEndgameTree := GetValeurMinimumOfNode(GetActiveNodeOfEndgameTree(numeroArbre),deltaFinale)
    else GetValeurMinimumParEndgameTree := -64;
end;


function GetValeurMaximumParEndgameTree(numeroArbre,deltaFinale : SInt32) : SInt32;
begin
  if (numeroArbre >= 1) and (numeroArbre <= kNbMaxEndgameTrees) and ActiveNodeEstValideEndgameTree(numeroArbre)
    then GetValeurMaximumParEndgameTree := GetValeurMaximumOfNode(GetActiveNodeOfEndgameTree(numeroArbre),deltaFinale)
    else GetValeurMaximumParEndgameTree := +64;
end;


function ConnaitValeurDuNoeudParEndgameTree(numeroArbre,deltaFinale : SInt32; var vmin,vmax : SInt32) : boolean;
begin
  if (numeroArbre >= 1) and (numeroArbre <= kNbMaxEndgameTrees) and ActiveNodeEstValideEndgameTree(numeroArbre)
    then
      ConnaitValeurDuNoeudParEndgameTree := ConnaitValeurDuNoeud(GetActiveNodeOfEndgameTree(numeroArbre),deltaFinale,vmin,vmax)
    else
      begin
        ConnaitValeurDuNoeudParEndgameTree := false;
        vmin := -64;
        vmax := +64;
      end;
end;




function PeutCalculerFinaleParEndgameTree(numeroArbre : SInt32; position : PositionEtTraitRec; var listeDesCoups : PropertyList; var meilleurScore : SInt32) : boolean;
var G : GameTree;
    vmin,vmax : SInt32;
begin
  PeutCalculerFinaleParEndgameTree := false;

(*WritelnDansRapport('avant ConnaitValeurDuNoeudParEndgameTree');
  AttendFrappeClavier;*)

  if (listeDesCoups = NIL) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT : listeDesCoups = NIL dans PeutCalculerFinaleParEndgameTree');
      exit(PeutCalculerFinaleParEndgameTree);
    end;

  if (GetTraitOfPosition(position) <> pionVide) and
     ConnaitValeurDuNoeudParEndgameTree(numeroArbre,kDeltaFinaleInfini,vmin,vmax) then
    begin

    (*WritelnNumDansRapport('deltaFinale = ',kDeltaFinaleInfini);
      WritelnNumDansRapport('vmin = ',vmin);
      WritelnNumDansRapport('vmax = ',vmin);
      WritelnDansRapport('avant GetActiveNodeOfEndgameTree');
      AttendFrappeClavier;*)

      G := GetActiveNodeOfEndgameTree(numeroArbre);

      if PeutCompleterSuiteParfaiteParGameTree(G, position, vmin, vmax, listeDesCoups)
        then
          begin
            meilleurScore := vmin;
            PeutCalculerFinaleParEndgameTree := true;
          end;

    end;
end;








function SuiteParfaiteEstConnueDansGameTree : boolean;
begin
  SuiteParfaiteEstConnueDansGameTree := gSuiteParfaiteEstConnueDansGameTree;
end;


procedure SetSuiteParfaiteEstConnueDansGameTree(flag : boolean);
begin
  gSuiteParfaiteEstConnueDansGameTree := flag;
end;






























END.
