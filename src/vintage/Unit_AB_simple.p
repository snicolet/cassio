UNIT Unit_AB_simple;

INTERFACE







 USES UnitDefCassio;


function AB_simple(var pl : plateauOthello; var joua : plBool; var bstBef : SInt32; coul,prof,alpha,beta,nBla,nNoi : SInt32; var fr : InfoFront; canDoProbCut : boolean) : SInt32;
function AB_tore(var pl : plateauOthello; var bstBef : SInt32; coul,prof,alpha,beta,nBla,nNoi : SInt32) : SInt32;

function ProofNumberMapping(v,valeurCible : SInt32; facteurExponentiel : double_t) : double_t;
function ProofNumber(var plat : plateauOthello; depth,trait,couleurProof,nbCasesVides : SInt32; alpha_PN,beta_PN : double_t; var casesVides : listeVides) : double_t;
function ProofNumberMilieu(var pl : plateauOthello; depth,trait,couleurProof,valCible,nbCasesVides : SInt32; alpha_PN,beta_PN : double_t; var casesVides : listeVides; var infosMilieu : InfosMilieuRec) : double_t;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitEvaluation, UnitUtilitaires, UnitStrategie, UnitTore, UnitGestionDuTemps, UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/_AB_simple.lk}
{$ENDC}


{END_USE_CLAUSE}














function AB_simple(var pl : plateauOthello; var joua : plBool; var bstBef : SInt32;
                  coul,prof,alpha,beta,nBla,nNoi : SInt32; var fr : InfoFront; canDoProbCut : boolean) : SInt32;
var platEssai : plateauOthello;
    jouablEssai : plBool;
    nbBlcEssai,nbNrEssai : SInt32;
    nroDuCoup : SInt32;
    largeur1,largeur2,largeur3 : SInt32;
    frontEssai : InfoFront;
    i : SInt32;
    adversaire,profms1 : SInt32;
    maxCourant,notecourante : SInt32;
    maxPourBestDef : SInt32;
    coupPossible,aJoue,evaluerMaintenant : boolean;
    iCourant : SInt32;
    note : SInt32;
    bestSuite : SInt32;
    nbEvalsRecursives : SInt32;
    {s1,s2 : String255;}

    nbCoupsLegauxPotentiels : SInt32;
    coupsPotentiels : array[1..64] of record
                                      coup : SInt32;
                                      noteAdv : SInt32;
                                    end;


  procedure EtablitListeCoupsPotentiels;
  var i,j,k,iCourant : SInt32;
      platTri : plateauOthello;
      jouablTri : plBool;
      nbBlcTri,nbNrTri : SInt32;
      frontTri : InfoFront;
      evalAdverse : SInt32;
      nbAppelsRecursifs : SInt32;
      profMinimalePourTrierAvecEval : SInt32;
      tempoRecursivite : boolean;
  begin
    nbCoupsLegauxPotentiels := 0;

    profMinimalePourTrierAvecEval := 3;

    if (prof >= profMinimalePourTrierAvecEval)
      then
        begin
		      platTri := pl;
          jouablTri := joua;
          nbBlcTri := nBla;
          nbNrTri := nNoi;
          frontTri := fr;
          for i := 1 to 64 do
				    begin
				      iCourant := othellier[i];
				      if (platTri[iCourant] = pionVide) & jouablTri[iCourant] &
				         ModifPlat(iCourant,coul,platTri,jouablTri,nbBlcTri,nbNrTri,frontTri) then
					       begin
					         inc(nbCoupsLegauxPotentiels);

					         tempoRecursivite := avecRecursiviteDansEval;
					         avecRecursiviteDansEval := false;

					         evalAdverse := Evaluation(platTri,-coul,nbBlcTri,nbNrTri,jouablTri,frontTri,false,-30000,30000,nbAppelsRecursifs);

					         avecRecursiviteDansEval := tempoRecursivite;

					         platTri := pl;
                   jouablTri := joua;
                   nbBlcTri := nBla;
                   nbNrTri := nNoi;
                   frontTri := fr;

                   {tri par insertion}
                   k := 1;
                   while (coupsPotentiels[k].noteAdv <= evalAdverse) & (k < nbCoupsLegauxPotentiels) do
                     inc(k);
                   for j := nbCoupsLegauxPotentiels downto succ(k) do
                     coupsPotentiels[j].coup := coupsPotentiels[pred(j)].coup;
                   for j := nbCoupsLegauxPotentiels downto succ(k) do
                     coupsPotentiels[j].noteAdv := coupsPotentiels[pred(j)].noteAdv;
                   coupsPotentiels[k].coup := iCourant;
                   coupsPotentiels[k].noteAdv := evalAdverse;

					       end;
				    end;
		    end
      else
	      begin
			    for i := 1 to 64 do
				    begin
				      iCourant := othellier[i];
				      if platEssai[iCourant] = pionVide then
				        begin
				          inc(nbCoupsLegauxPotentiels);
				          coupsPotentiels[nbCoupsLegauxPotentiels].coup := iCourant;
				        end;
				    end;
				end;
  end;


  procedure DoProbCutABSimple(profDepart,profArrivee,fenetre_alpha,fenetre_beta : SInt32);
  var seuilProbCut,t : SInt32;
  begin     {$UNUSED profDepart}
    if beta < 20000 then
      begin
        seuilProbCut := beta+fenetre_beta;
        t := AB_simple(pl,joua,bstBef,coul,profArrivee,SeuilProbCut-1,SeuilProbCut,nBla,nNoi,fr,false);
        if t >= seuilProbCut then
          begin
            {AB_simple := t-fenetre_beta;}  {Fail soft ProbCut}
            AB_simple := beta;
            exit(AB_simple);
          end;
      end;
    if alpha > -20000 then
      begin
        seuilProbCut := alpha-fenetre_alpha;
        t := AB_simple(pl,joua,bstBef,coul,profArrivee,SeuilProbCut,SeuilProbCut+1,nBla,nNoi,fr,false);
        if t <= seuilProbCut then
          begin
            {AB_simple := t+fenetre_alpha;}  {Fail soft ProbCut}
            AB_simple := alpha;
            exit(AB_simple);
          end;
      end;
  end;




begin

 AB_simple := -32000;

 if (interruptionReflexion = pasdinterruption) then
 begin
   if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);



   if (canDoProbCut & (beta <= alpha+1)) then
	   begin

	     nroDuCoup := nBla + nNoi - 4;
       largeur1 := table_FenetreProbCut[nroDuCoup];
       largeur2 := table_GrandeFenetreProbCut[nroDuCoup];
       largeur3 := table_HyperGrandeFenetreProbCut[nroDuCoup];

	     if (prof =  3) then DoProbCutABSimple( 3,1,largeur1,largeur1) else
	     if (prof =  4) then DoProbCutABSimple( 4,2,largeur1,largeur1) else
	     if (prof =  5) then DoProbCutABSimple( 5,1,largeur2,largeur2) else
	     if (prof =  6) then DoProbCutABSimple( 6,2,largeur1,largeur1) else
	     if (prof =  7) then DoProbCutABSimple( 7,3,largeur1,largeur1) else
	     if (prof =  8) then DoProbCutABSimple( 8,4,largeur1,largeur1) else
	     if (prof =  9) then DoProbCutABSimple( 9,3,largeur2,largeur2);
	     if (prof =  9) then DoProbCutABSimple( 9,5,largeur1,largeur1);
	     if (prof = 10) then DoProbCutABSimple(10,4,largeur2,largeur2);
	     if (prof = 10) then DoProbCutABSimple(10,6,largeur2,largeur2);
	     if (prof = 11) then DoProbCutABSimple(11,3,largeur2,largeur2);
	     if (prof = 11) then DoProbCutABSimple(11,5,largeur2,largeur2) else
	     if (prof = 12) then DoProbCutABSimple(12,4,largeur2,largeur2) else
	     if (prof = 13) then DoProbCutABSimple(13,5,largeur2,largeur2) else
	     if (prof = 14) then DoProbCutABSimple(14,4,largeur2,largeur2) else
	     if (prof = 15) then DoProbCutABSimple(15,5,largeur2,largeur2) else
	     if (prof = 16) then DoProbCutABSimple(16,6,largeur2,largeur2) else
	     if (prof = 17) then DoProbCutABSimple(17,5,largeur2,largeur2);

	   end;  {if canDoProbCut}


   adversaire := -coul;
   profms1 := prof-1;
   if alpha > 32000 then alpha := 32000;
   if beta < -32000 then beta := -32000;
   maxCourant := alpha;
   maxPourBestDef := -32000;
   aJoue := false;



   platEssai := pl;
   jouablEssai := joua;
   nbBlcEssai := nBla;
   nbNrEssai := nNoi;
   frontEssai := fr;


   {
   EssaieSetPortWindowPlateau;
	 WriteNumAt('prof = ',prof,10,10);
	 Ecritpositionat(platEssai,10,20);
	 WriteNumAt('max = ',maxCourant,10,140);
	 WriteNumAt('coul = ',coul,10,150);
   WriteNumAt('nbBlcEssai = ',nbBlcEssai,100,150);
   WriteNumAt('nbNrEssai = ',nbNrEssai,200,150);
	 SysBeep(0);
	 AttendFrappeClavier;
   }

   EtablitListeCoupsPotentiels;

   for i := 1 to nbCoupsLegauxPotentiels do
   BEGIN
     iCourant := coupsPotentiels[i].coup;
     if platEssai[iCourant] = pionVide then
     if joua[iCourant] then
      begin
        coupPossible := ModifPlat(iCourant,coul,platEssai,jouablEssai,nbBlcEssai,nbNrEssai,frontessai);
        if coupPossible then begin



           evaluerMaintenant := (profms1 <= 0);


           if evaluerMaintenant
             then
               begin
                 noteCourante := -Evaluation(platEssai,adversaire,nbBlcEssai,nbNrEssai,
                                           jouablEssai,frontEssai,true,-beta,-maxCourant,nbEvalsRecursives);
               end
             else
               begin
                 if not(aJoue) | (beta <= maxCourant+1)
                   then
                     begin
                       noteCourante := -AB_simple(platEssai,jouablEssai,bestSuite,adversaire,profms1,
                                              -beta,-maxCourant,nbBlcEssai,nbNrEssai,frontEssai,canDoProbCut);
                     end
                   else
                     begin
                       noteCourante := -AB_simple(platEssai,jouablEssai,bestSuite,adversaire,profms1,
                                              -maxCourant-1,-maxCourant,nbBlcEssai,nbNrEssai,frontEssai,canDoProbCut);
                       if (maxCourant < noteCourante) & (noteCourante < beta) then
                         begin
                           noteCourante := -AB_simple(platEssai,jouablEssai,bestSuite,adversaire,profms1,
                                                  -beta,-noteCourante,nbBlcEssai,nbNrEssai,frontEssai,canDoProbCut);
                           if noteCourante = maxCourant+1 then noteCourante := maxCourant;
                         end;
                     end;
               end;

           aJoue := true;

           if (noteCourante > maxPourBestDef) then
             begin
               maxPourBestDef := noteCourante;
               if noteCourante > maxCourant then maxCourant := noteCourante;
               bstBef := iCourant;
             end;
           if (maxCourant >= beta) then
             begin
               AB_simple := maxCourant;
               exit(AB_simple)
             end;
           platEssai := pl;
           jouablEssai := joua;
           nbBlcEssai := nBla;
           nbNrEssai := nNoi;
           frontEssai := fr;

         end;
       end;
   end;

  if not(aJoue) then
      begin
        if DoitPasser(adversaire,pl,joua) then
          begin
            if Coul = pionBlanc
               then note := nBla-nNoi
               else note := nNoi-nBla;
            AB_simple := 100*note;
          end
        else
          AB_simple := -AB_simple(pl,joua,bstBef,adversaire,prof,-beta,-alpha,nBla,nNoi,fr,canDoProbCut);
      end
  else AB_simple := maxCourant;
 end;  { if (interruptionReflexion = pasdinterruption) then... }
end;   { AB_simple }




function ProofNumber(var plat : plateauOthello; depth,trait,couleurProof,nbCasesVides : SInt32; alpha_PN,beta_PN : double_t; var casesVides : listeVides) : double_t;
var coup,j : SInt32;
    platProof : plateauOthello;
    aux,somme,minCourant : double_t;
    aJoue : boolean;
begin
  if depth <= 0
    then ProofNumber := 1.0
    else
      begin
        platProof := plat;

        if trait = -couleurProof
          then
            begin
              somme := 0.0;
              aJoue := false;

              for j := 1 to nbCasesVides do
                begin
                  coup := casesVides[j];
                  if platProof[coup] = pionVide then
                    if ModifPlatSeulement(coup,platProof,trait) then
                      begin
                        aJoue := true;
                        if depth <= 1
                          then aux := 1.0
                          else aux := ProofNumber(platProof,pred(depth),-trait,couleurProof,nbCasesVides,alpha_PN,beta_PN,casesVides);

                        somme := somme + aux;
                        if EstUnCoin[coup] then somme := somme + aux;


                        {mise a jour des bornes (alpha_PN,beta_PN)}
                        if somme > alpha_PN then alpha_PN := somme;

                        {coupures alpha-beta sur les proof numbers ?}
                        if somme >= beta_PN
                          then
                            begin
                              ProofNumber := somme;
                              exit(ProofNumber);
                            end;

                        platProof := plat;
                      end;
                end;

              if aJoue
                then ProofNumber := somme
                else ProofNumber := ProofNumber(plat,depth,-trait,couleurProof,nbCasesVides,alpha_PN,beta_PN,casesVides);
            end
          else
            begin
              minCourant := 1e50;
              aJoue := false;

              for j := 1 to nbCasesVides do
                begin
                  coup := casesVides[j];
                  if platProof[coup] = pionVide then
                    if ModifPlatSeulement(coup,platProof,trait) then
                      begin
                        aJoue := true;

                        if depth <= 1
	                        then aux := 1.0
	                        else aux := ProofNumber(platProof,pred(depth),-trait,couleurProof,nbCasesVides,alpha_PN,beta_PN,casesVides);

	                      if aux < minCourant then minCourant := aux;

	                      {mise a jour des bornes (alpha_PN,beta_PN)}
	                      if aux < beta_PN then beta_PN := aux;

	                      {coupures alpha-beta sur les proof numbers ?}
                        if aux <= alpha_PN then
                          begin
                            ProofNumber := aux;
                            exit(ProofNumber);
                          end;

                        platProof := plat;
	                    end;


                end;

              if aJoue
                then ProofNumber := minCourant
                else ProofNumber := ProofNumber(plat,depth,-trait,couleurProof,nbCasesVides,alpha_PN,beta_PN,casesVides);
            end
      end;
 end;

{Quantity of work to prove that a node has a true value >= valCible,
 given that its midgame estimation is v}
function ProofNumberMapping(v,valeurCible : SInt32; facteurExponentiel : double_t) : double_t;
var diffEval : double_t;
begin
  diffEval := 0.01*(valeurCible - v);  {car l'evaluation de Cassio est en centiemes de pions}
  ProofNumberMapping := quantumProofNumber + exp(facteurExponentiel*diffEval);
end;



function ProofNumberMilieu(var pl : plateauOthello; depth,trait,couleurProof,valCible,nbCasesVides : SInt32; alpha_PN,beta_PN : double_t; var casesVides : listeVides; var infosMilieu : InfosMilieuRec) : double_t;
var eval,nbEvalRecursives : SInt32;
    coup,j : SInt32;
    platProof : plateauOthello;
    infosProof : InfosMilieuRec;
    aux,somme,minCourant : double_t;
    aJoue : boolean;
begin
  if depth <= 0
    then
      begin
        inc(nbEvaluationsPourProofNumber);
        with InfosMilieu do
          if trait = couleurProof
            then eval :=  Evaluation(pl,trait,nbBlancs,nbNoirs,jouable,frontiere,false,-30000,30000,nbEvalRecursives)
            else eval := -Evaluation(pl,trait,nbBlancs,nbNoirs,jouable,frontiere,false,-30000,30000,nbEvalRecursives);

        aux := ProofNumberMapping(eval,valCible,exponentialMappingProofNumber);

        {
        WritelnPositionEtTraitDansRapport(pl,trait);
        WritelnNumDansRapport('couleurProof = ',couleurProof);
        WritelnNumDansRapport('eval = ',eval);
        WritelnNumDansRapport('valCible = ',valCible);
        WritelnStringAndReelDansRapport('ProofNumberMilieu = ',aux,10);
        }

        ProofNumberMilieu := aux;
      end
    else
      begin
        platProof := pl;
        infosProof := infosMilieu;

        if trait = -couleurProof
          then
            begin
              somme := 0.0;
              aJoue := false;

              for j := 1 to nbCasesVides do
                begin
                  coup := casesVides[j];

                  //WritelnNumDansRapport('ProofNumberMilieu, coup = ',coup);

                  if platProof[coup] = pionVide then
                    with infosProof do
                    if ModifPlatLongint(coup,trait,platProof,jouable,nbBlancs,nbNoirs,frontiere) then
                      begin
                        aJoue := true;

                        aux := ProofNumberMilieu(platProof,pred(depth),-trait,couleurProof,valCible,nbCasesVides,alpha_PN,beta_PN,casesVides,infosProof);

                        somme := somme+aux;



                        {mise a jour des bornes (alpha_PN,beta_PN)}
                        if somme > alpha_PN then alpha_PN := somme;

                        {coupures alpha-beta sur les proof numbers ?}
                        if somme >= beta_PN
                          then
                            begin
                              ProofNumberMilieu := somme;
                              exit(ProofNumberMilieu);
                            end;

                        platProof := pl;
                        infosProof := infosMilieu;
                      end;
                end;

              if aJoue
                then ProofNumberMilieu := somme
                else ProofNumberMilieu := ProofNumberMilieu(pl,depth,-trait,couleurProof,valCible,nbCasesVides,alpha_PN,beta_PN,casesVides,infosMilieu);
            end
          else
            begin
              minCourant := 1e50;
              aJoue := false;

              for j := 1 to nbCasesVides do
                begin
                  coup := casesVides[j];

                  //WritelnNumDansRapport('ProofNumberMilieu, coup = ',coup);

                  if platProof[coup] = pionVide then
                    with infosProof do
                    if ModifPlatLongint(coup,trait,platProof,jouable,nbBlancs,nbNoirs,frontiere) then
                      begin
                        aJoue := true;

                        aux := ProofNumberMilieu(platProof,pred(depth),-trait,couleurProof,valCible,nbCasesVides,alpha_PN,beta_PN,casesVides,infosProof);

	                      if aux < minCourant then minCourant := aux;

	                      {mise a jour des bornes (alpha_PN,beta_PN)}
	                      if aux < beta_PN then beta_PN := aux;

	                      {coupures alpha-beta sur les proof numbers ?}
                        if aux <= alpha_PN then
                          begin
                            ProofNumberMilieu := aux;
                            exit(ProofNumberMilieu);
                          end;

                        platProof := pl;
                        infosProof := infosMilieu;
	                    end;


                end;

              if aJoue
                then ProofNumberMilieu := minCourant
                else ProofNumberMilieu := ProofNumberMilieu(pl,depth,-trait,couleurProof,valCible,nbCasesVides,alpha_PN,beta_PN,casesVides,infosMilieu);
            end
      end;
end;


(*
PN(P) = quantity of work for Player to prove that val(P) >= t
DP(P) = .....................Opponent to prove that val(P) < t


so we have the usual recurrence formulas for internal nodes of the top tree:

if P is a Player's node
  PN(P) = Min(PN(Pi))        ( Pi sons of P)
  DP(P) = Sigma(DP(Pi))

if P is an Opponent's node
  PN(P) = Sigma(PN(Pi))
  DP(P) = Min(Pi)

at leaves node for the top tree we can use the estimation given by the evaluation
function (of course, we only calculate this estimation v of val(P) (maybe via a
local, heuristic sub-search) the first time we hit that node)

PN(P) = exp(a*(t-v))
DP(P) = exp(a*(v-t))

Note that the "a" parameter and the choice of the exponentiel function as a mapping
function is arbitrary : we only need that the increasing mapping f exhibits
f(-infinity) = 0 and f(+infinity) = +infinity.


Of course, oce we have proven that a node P has val(P) >= t, we set PN(P) = 0 and
DP(P) = infinity, and reciprocally if val(P) < t.


What I realised only yesterday is that we can calculate the proof and disproof
numbers efficiently on the fly, using a cutting scheme similar to the alpha-beta
cuts. I will show you the algo here only for proof numbers :


function Calculate_PN(node P, float alpha_PN,beta_PN) :float

if P is at depth d
  return estimatation_of_PN_with_midgame(P)  // using the above exponential

if P is a Player node do
  let current_min := infinity
  for each son Pi of P do
    let n := Calculate_PN(Pi,alpha_PN,beta_PN)
    if n <= cur_min
      current_min := n
    if n < beta_PN
      beta_PN := n
    if n <= alpha_PN
      return n
  return current_min

if P is an Opponent's node
  let sum := 0
  for each son Pi of P do
    let n := Calculate_PN(Pi,alpha_PN,beta_PN)
    let sum := sum + n
    if sum > alpha_PN
      alpha_PN = sum
    if sum >= beta_PN
      return beta_PN
  return sum


function Calculate_Root_PN(node Root)
return Calculate_PN(R,0,+infinity)


My "intuition" for the pair (alpha_PN,beta_PN), of course, is that during
the recursive calculations of PN(root), alpha_PN is the minimal quantity
of work that Opponent has already proved to be able to force Player to do
to prove tha val(P) >= t, whereas beta_PN is the maximum quantity of work that
Player has already proved will be necessary to prove val(P) >= t


The calculation for disproof numbers DP are (dualy) similar, using another
cutting pair (alpha_DP,beta_DP), initialized to (infinity,0).

*)


function AB_tore(var pl : plateauOthello; var bstBef : SInt32;
                  coul,prof,alpha,beta,nBla,nNoi : SInt32) : SInt32;
var platEssai : plateauOthello;
    nbBlcEssai,nbNrEssai : SInt32;
    i : SInt32;
    adversaire,profms1 : SInt32;
    maxCourant,notecourante : SInt32;
    maxPourBestDef : SInt32;
    coupPossible,aJoue : boolean;
    iCourant : SInt32;
    note : SInt32;
    bestSuite : SInt32;
    {s1,s2 : String255;}
begin
 if (interruptionReflexion = pasdinterruption) then
 begin
   if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

   adversaire := -coul;
   profms1 := prof-1;
   maxCourant := alpha;
   maxPourBestDef := -noteMax;
   aJoue := false;



   platEssai := pl;
   nbBlcEssai := nBla;
   nbNrEssai := nNoi;


   for i := 1 to 64 do
   BEGIN
     iCourant := othellier[i];
     if platessai[iCourant] = pionVide then
      begin
        coupPossible := ModifPlatTore(iCourant,coul,platEssai,nbBlcEssai,nbNrEssai);
        if coupPossible then begin
           aJoue := true;
           if (profms1 <= 0 )
            then
             begin
              noteCourante := -EvaluationTore({platEssai,}adversaire,nbBlcEssai,nbNrEssai);
             end
           else
             begin
               noteCourante := -AB_tore(platEssai,bestSuite,adversaire,profms1,
                                     -beta,-maxCourant,nbBlcEssai,nbNrEssai);
             end;

           if (noteCourante > maxPourBestDef) then
                begin
                  maxPourBestDef := noteCourante;
                  if noteCourante > maxCourant then maxCourant := noteCourante;
                  bstBef := iCourant;
                end;
           if (maxCourant >= beta) then
                 begin
                   AB_tore := maxCourant;
                   exit(AB_tore)
                 end;
           platEssai := pl;
           nbBlcEssai := nBla;
           nbNrEssai := nNoi;

           end;
       end;
   end;

  if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

  if not(aJoue) then
      begin
        if DoitPasserTore(adversaire,pl) then
          begin
            if Coul = pionBlanc
               then note := nBla-nNoi
               else note := nNoi-nBla;
            AB_tore := 100*note;
          end
        else
          AB_tore := -AB_tore(pl,bstBef,adversaire,prof,-beta,-alpha,nBla,nNoi);
      end
  else AB_tore := maxCourant;
 end;  { if (interruptionReflexion = pasdinterruption) then... }
end;   { AB_tore }





end.
