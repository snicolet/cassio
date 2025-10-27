UNIT UnitFinaleFast;




INTERFACE


{$DEFINEC USE_DEBUG_HASH_VALUES    FALSE}




 USES
     {$IFC USE_PROFILER_FINALE_FAST}
     Profiler ,
     {$ENDC}
     UnitDefCassio;



function MakeEndgameSearch(var paramMakeEndgameSearch : MakeEndgameSearchParamRec ) : boolean;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSAtomic_glue, Sound, OSUtils, fp, UnitDefParallelisme, Timer
{$IFC NOT(USE_PRELINK)}
    , UnitMiniProfiler
    , UnitGestionDuTemps, MyQuickDraw, UnitStrategie, UnitZoo, UnitEstimationCharge, UnitZooAvecArbre, UnitEngine, Zebra_to_Cassio
    , UnitEvenement, UnitSuperviseur, UnitEvaluation, Unit_AB_simple, UnitEndgameTree, UnitHashTableExacte, UnitPositionEtTraitSet, UnitNotesSurCases
    , UnitRapportImplementation, UnitUtilitaires, UnitAffichageReflexion, UnitScannerUtils, UnitArbreDeJeuCourant, UnitAffichageArbreDeJeu, UnitServicesDialogs, UnitMoveRecords
    , UnitSearchValues, UnitBitboardHash, UnitMiniProfiler, UnitJaponais, UnitRapport, UnitUtilitairesFinale, UnitListeChaineeCasesVides, UnitTore
    , UnitRegressionLineaire, UnitPhasesPartie, MyStrings, UnitAffichagePlateau, UnitBitboardAlphaBeta, UnitBitboardFlips, MyMathUtils, UnitModes
    , UnitCourbe, UnitFenetres, UnitScripts, UnitGeneralSort, UnitConstrListeBitboard, UnitParallelisme, SNEvents, UnitServicesMemoire
    , UnitStringSet, UnitPositionEtTrait, UnitGameTree, UnitPropertyList, UnitServicesRapport, UnitLongString ;
{$ELSEC}
    ;
    {$I prelink/FinaleFast.lk}
{$ENDC}


{END_USE_CLAUSE}







{$IFC DEFINED __GPC__}

  procedure flush_standard_output; external name('flush_standard_output');

{$ENDC}




CONST kNbCasesVidesPourAnnonceDansRapport = 10;

      kPropagationMinimax     = 1;
      kPropagationProofNumber = 2;


TYPE
    LocalMessageFinaleRec =  MessageFinaleRec;
    LocalMessageFinalePtr = ^LocalMessageFinaleRec;
    LocalMessageFinaleHdl = ^LocalMessageFinalePtr;




{$IFC USE_DEBUG_HASH_VALUES}
var positionsDejaAffichees : PositionEtTraitSet;
    hashStockeeDansSet : SInt32;
{$ENDC}


procedure MyCopyEnPlOthEndgame(var source : plateauOthello; var dest : plOthEndgame);
var i : SInt32;
begin
  for i := 0 to 99 do
    dest[i] := source[i];
end;



function ModifPlatFinDiffFastLongint(a,couleur,couleurEnnemie : SInt32; var jeu : plOthEndgame; var diffPions : SInt32) : boolean;
var x1,x2,x3,x4,x5,x6,dx,t,nbprise : SInt32;
begin
   nbprise := 0;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x1 := a+dx;
       if jeu[x1] = couleurEnnemie then {1}
         begin
           x2 := x1+dx;
           if jeu[x2] = couleurEnnemie then  {2}
           begin
             x3 := x2+dx;
             if jeu[x3] = couleurEnnemie then  {3}
		           begin
		             x4 := x3+dx;
		             if jeu[x4] = couleurEnnemie then  {4}
				           begin
				             x5 := x4+dx;
				             if jeu[x5] = couleurEnnemie then  {5}
						           begin
						             x6 := x5+dx;
						             if jeu[x6] = couleurEnnemie then  {6}
								           begin
								             if jeu[x6+dx] = couleur then  {seul cas à tester}
									             begin
									               nbprise := nbprise+12;
									               Jeu[x6] := couleur;
									               Jeu[x5] := couleur;
									               Jeu[x4] := couleur;
									               Jeu[x3] := couleur;
									               Jeu[x2] := couleur;
									               Jeu[x1] := couleur;
									             end;
								           end
								           else
								           if jeu[x6] = couleur then
								             begin
								               nbprise := nbprise+10;
								               Jeu[x5] := couleur;
								               Jeu[x4] := couleur;
								               Jeu[x3] := couleur;
								               Jeu[x2] := couleur;
								               Jeu[x1] := couleur;
								             end;
						           end
						           else
						           if jeu[x5] = couleur then
						             begin
						               nbprise := nbprise+8;
						               Jeu[x4] := couleur;
						               Jeu[x3] := couleur;
						               Jeu[x2] := couleur;
						               Jeu[x1] := couleur;
						             end;
				           end
                   else
				           if jeu[x4] = couleur then
				             begin
				               nbprise := nbprise+6;
				               Jeu[x3] := couleur;
				               Jeu[x2] := couleur;
				               Jeu[x1] := couleur;
				             end;
		           end
		           else
		           if jeu[x3] = couleur then
		             begin
		               nbprise := nbprise+4;
		               Jeu[x2] := couleur;
		               Jeu[x1] := couleur;
		             end;
           end
           else
           if jeu[x2] = couleur then
             begin
               nbprise := nbprise+2;
               Jeu[x1] := couleur;
             end;
        end;
     end;
   if (nbprise > 0)
     then
	     begin
	       diffPions := succ(diffPions+nbprise);
	       jeu[a] := couleur;
	       ModifPlatFinDiffFastLongint := true;
	     end
	   else
	     ModifPlatFinDiffFastLongint := false;
end;




function ModifPlatFinLongint(a,coul : SInt32; var jeu : plateauOthello; var nbbl,nbno : SInt32) : boolean;
var x,dx,i,t,nbprise : SInt32;
    pionEnnemi,compteur : SInt32;
    modifie : boolean;
begin
   modifie := false; nbprise := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x := a+dx;
       if jeu[x] = pionennemi then
         begin
           compteur := 0;
           repeat
             inc(compteur);
             x := x+dx;
           until jeu[x] <> pionennemi;
           if (jeu[x] = coul)then
             begin
               modifie := true;
               for i := 1 to compteur do
                 begin
                  x := x-dx;
                  Jeu[x] := coul;
                 end;
               nbprise := nbprise+compteur;
             end;
        end;
     end;
   if modifie then
     begin
       if coul = pionNoir
         then begin
             nbNo := succ(nbNo+nbprise);
             nbbl := nbbl-nbprise;
           end
         else begin
             nbNo := nbNo-nbprise;
             nbbl := succ(nbbl+nbprise);
           end;
       jeu[a] := coul;
     end;
   ModifPlatFinLongint := modifie;
end;




function EtablitListeCasesVidesParOrdreJCW(var plat : plateauOthello; ESprof : SInt32; var listeCasesVides : listeVides) : SInt32;
var nbVidesTrouvees,i,caseTestee : SInt32;
begin
  nbVidesTrouvees := 0;
  i := 0;
  repeat
    inc(i);
    caseTestee := gCasesVides_entreeCoupGagnant[i];
    if plat[caseTestee] = pionVide then
      begin
        inc(nbVidesTrouvees);
        listeCasesVides[nbVidesTrouvees] := caseTestee;
      end;
  until nbVidesTrouvees >= ESprof;
  EtablitListeCasesVidesParOrdreJCW := nbVidesTrouvees;
end;







const kNoteBidonPositionNonTrouveeDansHash = -2536383;  {ou n'importe quoi d'aberrant}


function EstUneNoteDeETCNonValide(note : SInt32) : boolean;
begin

  EstUneNoteDeETCNonValide  :=
                  ((note >=  kNoteBidonPositionNonTrouveeDansHash - 5) and (note <=  kNoteBidonPositionNonTrouveeDansHash + 5))
                or ((note >= -kNoteBidonPositionNonTrouveeDansHash - 5) and (note <= -kNoteBidonPositionNonTrouveeDansHash + 5));


  (*
  EstUneNoteDeETCNonValide := (note =  kNoteBidonPositionNonTrouveeDansHash ) or (note =  -kNoteBidonPositionNonTrouveeDansHash);
  *)

end;


function ValeurDeFinaleInexploitable(whichNote : SInt32) : boolean;
begin
  ValeurDeFinaleInexploitable := EstUneNoteDeETCNonValide(whichNote) or (interruptionReflexion <> pasdinterruption) or
                                 (whichNote = -noteMax) or (whichNote =  noteMax);
end;





procedure MetPosDansHashTableExacteEndgame(var whichElement : HashTableExacteElement;
                                    var codagePosition : codePositionRec;
                                    whichEvaluationHeuristique : SInt32);
  begin
    with whichElement,codagePosition do
      begin
        ligne1 := platLigne1;
        ligne2 := platLigne2;
        ligne3 := platLigne3;
        ligne4 := platLigne4;
        ligne5 := platLigne5;
        ligne6 := platLigne6;
        ligne7 := platLigne7;
        ligne8 := platLigne8;
        SetTraitDansHashExacte(couleurCodage,whichElement);
        profondeur := nbreVidesCodage;
        flags := 0;
        evaluationHeuristique := whichEvaluationHeuristique;
      end;
  end;

procedure AttacheCoupsLegauxDansHash(indexmin,indexmax : SInt32; var whichLegalMoves : CoupsLegauxHashPtr; clefHashExacte : SInt32; var listeFinale : listeVides);
  var n : SInt32;
  begin
    n := succ(indexmax-indexmin);
    if (n <= nbMaxCoupsLegauxDansHash)
      then
        begin
          whichLegalMoves^[clefHashExacte,0] := n;
          for n := indexmin to indexmax do
            whichLegalMoves^[clefHashExacte,succ(n-indexmin)] := listeFinale[n];
        end
      else
        whichLegalMoves^[clefHashExacte,0] := 0;
  end;

procedure ValiderCetteEntreeCoupsLegauxHash(var whichElement : HashTableExacteElement; entreeValide : boolean);
  begin
    with whichElement do
      if entreeValide
        then flags := BAND(flags,BNOT(kMaskRecalculerCoupsLegaux))  { elle est valide, on ne la recalculera pas }
        else flags := BOR(flags,kMaskRecalculerCoupsLegaux); { il faudra la recalculer }
  end;


procedure MetCoupEnTeteEtAttacheCoupsLegauxDansHash(indexmin,indexmax,coupAMettreEnTete : SInt32; var whichLegalMoves : CoupsLegauxHashPtr; clefHashExacte : SInt32; var listeFinale : listeVides);
  var n,k,coup : SInt32;
  begin
    n := succ(indexmax-indexmin);
    if n <= nbMaxCoupsLegauxDansHash
      then
        begin
          whichLegalMoves^[clefHashExacte,0] := n;

          if (coupAMettreEnTete <> 0)
            then
              begin
                whichLegalMoves^[clefHashExacte,1] := coupAMettreEnTete;
                k := 2;
              end
            else
              begin
                k := 1;
              end;

          for n := indexmin to indexmax do
            begin
              coup := listeFinale[n];
              if coup <> coupAMettreEnTete then
                begin
                  whichLegalMoves^[clefHashExacte,k] := coup;
                  inc(k);
                end;
            end;
        end
      else
        whichLegalMoves^[clefHashExacte,0] := 0;
  end;

procedure MetAmeliorationsAphaPuisCoupsLegauxDansHash(indexmin,indexmax : SInt32; var ameliorations:ameliorationsAlphaRec;
                                                     var whichLegalMoves : CoupsLegauxHashPtr; clefHashExacte : SInt32; var listeFinale : listeVides);
  var n,k,t,coup : SInt32;
      coupsEnTete : set of 0..99;
  begin
    n := succ(indexmax-indexmin);
    if n <= nbMaxCoupsLegauxDansHash
      then
        begin
          whichLegalMoves^[clefHashExacte,0] := n;
          coupsEnTete := [];
          k := 1;
          with ameliorations do
	          for t := cardinal downto 1 do
	            begin
	              coup := liste[t].coup;
	              coupsEnTete := coupsEnTete + [coup];
	              whichLegalMoves^[clefHashExacte,k] := coup;
	              inc(k);
	            end;
          for t := indexmin to indexmax do
            begin
              coup := listeFinale[t];
              if not(coup in coupsEnTete) then
                begin
                  whichLegalMoves^[clefHashExacte,k] := coup;
                  inc(k);
                end;
            end;
        end
      else
        whichLegalMoves^[clefHashExacte,0] := 0;
  end;


function PasListeFinaleStockeeDansHash(nbVides : SInt32; var whichLegalMoves : CoupsLegauxHashPtr; clefHashExacte : SInt32; var listeFinale : listeVides; var nbCoupsPourCoul : SInt32) : boolean;
  var i,uncoup,n : SInt32;
  begin
    n := whichLegalMoves^[clefHashExacte,0];
    if (n > 0) and (n <= nbVides) then
      begin
        for i := 1 to n do
          begin
            uncoup := whichLegalMoves^[clefHashExacte,i];
            listeFinale[i] := uncoup;
          end;
          nbCoupsPourCoul := n;
          PasListeFinaleStockeeDansHash := false;
        end
      else
        begin
          PasListeFinaleStockeeDansHash := true;
          whichLegalMoves^[clefHashExacte,0] := 0;
        end;
  end;




function AmeliorerFenetreParHashTableExacte( var meilleureSuite : t_meilleureSuite; bestmode : boolean;
                                             plat : plOthEndgame; pere,couleur,ESprof,whichDeltaFinal : SInt32;
                                             var alpha, beta, note, meiDef, ndsHeuristiques : SInt32) : boolean;
var NbNoeudsHeuristiquesPourAjusterAlpha : SInt32;
    NbNoeudsHeuristiquesPourAjusterBeta : SInt32;
    valeurExacteMax : SInt32;
    valeurExacteMin : SInt32;
    alphaInitial,betaInitial : SInt32;
    quelleHashTableExacte : HashTableExactePtr;
    quelleHashTableCoupsLegaux : CoupsLegauxHashPtr;
    nroTableExacte : SInt32;
    clefHashExacte : SInt32;
    codagePosition : codePositionRec;
    dansHashExacte : boolean;
    bornes : DecompressionHashExacteRec;
    meiDefenseSansHeuristique : SInt32;
    k : SInt32;
    NbNoeudsHeuristiquesDansTousLesFils : SInt32;
    indexDeltaFinale : SInt32;
label sortie;
begin

    begin

     AmeliorerFenetreParHashTableExacte := false;

     NbNoeudsHeuristiquesPourAjusterAlpha := 0;
     NbNoeudsHeuristiquesPourAjusterBeta  := 0;

     valeurExacteMax  := noteMax;
     valeurExacteMin  := -noteMax;
     alphaInitial     := alpha;
     betaInitial      := beta;
     meiDef           := 0;
     note             := -noteMax;
     indexDeltaFinale := IndexOfThisDelta(whichDeltaFinal);

     if ESprof >= ProfUtilisationHash then
       begin

         gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

         if ESprof >= ProfPourHashExacte then
           begin

             nroTableExacte := BAND(gClefHashage div 1024,nbTablesHashExactesMoins1);
             clefHashExacte := BAND(gClefHashage,1023);

             {WritelnNumDansRapport('clefHashExacte (1) = ',clefHashExacte);}

             quelleHashTableExacte := HashTableExacte[nroTableExacte];
             quelleHashTableCoupsLegaux := CoupsLegauxHash[nroTableExacte];

             CreeCodagePosition(plat,couleur,ESprof,codagePosition);

             {WritelnCodagePositionDansRapport(codagePosition);
             WritelnDansRapport('appel de InfoTrouveeDansHashTableExacte…');}

             dansHashExacte := InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,gClefHashage,clefHashExacte);

             if dansHashExacte
               then
                 begin

                   (* WritelnDansRapport('InfoTrouveeDansHashTableExacte : OK'); *)

                   DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                   meiDef := GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]);
                   meiDefenseSansHeuristique := bornes.coupDeCetteValMin[nbreDeltaSuccessifs];

                   {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
                   CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                   {$ENDC}

                   with bornes do
                   if (nbArbresCoupesValMin[nbreDeltaSuccessifs] = 0) and
                      (valMin[nbreDeltaSuccessifs] = valMax[nbreDeltaSuccessifs]) and
		                  (coupDeCetteValMin[nbreDeltaSuccessifs] <> 0) and (coupDeCetteValMin[nbreDeltaSuccessifs] <> meiDef) then
                     begin
                       Sysbeep(0);
                       WritelnDansRapport('');
                       WritelnDansRapport('Vous avez probablement trouvé un bug : ');
                       WritelnDansRapport('Ne faudrait-il pas changer meiDef parce que l''on connait le meilleur coup ?');
                       WritelnPositionEtTraitDansRapport(plat,couleur);
                       WritelnNumDansRapport('valMin['+NumEnString(ThisDeltaFinal(nbreDeltaSuccessifs))+'] = ',valMin[nbreDeltaSuccessifs]);
                       WritelnNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(nbreDeltaSuccessifs))+'] = ',valMax[nbreDeltaSuccessifs]);
                       WritelnStringAndCoupDansRapport('coupDeCetteValMin[nbreDeltaSuccessifs] = ',coupDeCetteValMin[nbreDeltaSuccessifs]);
                       WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                       WritelnDansRapport('');
                     end;

                   with bornes do
                   for k := nbreDeltaSuccessifs downto indexDeltaFinale do
                     begin


                       {Ajustement de la fenetre alpha-beta}
                       if (valMin[k] > alpha) then
                         begin
		                       alpha := valMin[k];
		                       AmeliorerFenetreParHashTableExacte := true;
		                       NbNoeudsHeuristiquesPourAjusterAlpha := NbNoeudsHeuristiquesPourAjusterAlpha + nbArbresCoupesValMin[k];
	                       end;

	                     if (valMax[k] < beta) then
                         begin
                           beta := valMax[k];
                           AmeliorerFenetreParHashTableExacte := true;
                           NbNoeudsHeuristiquesPourAjusterBeta := NbNoeudsHeuristiquesPourAjusterBeta + nbArbresCoupesValMax[k];
                         end;


                       {
                       if (ValMin[k] > valMax[k]) and (whichDeltaFinal = kDeltaFinaleInfini)
                          and (interruptionReflexion = pasdinterruption)  then
                         begin
                           SysBeep(0);
                           WritelnDansRapport('ERROR dans les tests initiaux : (ValeurMin > ValeurMax) and ValeurMinEstAcceptable and ValeurMaxEstAcceptable');
                           WritelnNumDansRapport('gClefHashage = ',gClefHashage);
	                         WritelnNumDansRapport('ValMin['+NumEnString(ThisDeltaFinal(k))+'] = ',ValMin[k]);
                           WritelnNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(k))+'] = ',valMax[k]);
                           WritelnNumDansRapport('ESprof = ',ESprof);
                           WritelnPositionEtTraitDansRapport(plat,couleur);
                           WritelnDansRapport('');
                         end;
                       }

                       (*
                       if (k = nbreDeltaSuccessifs) and (valMin[k] >= valMax[k]) then
                         begin
                           WritelnPositionEtTraitDansRapport(plat,couleur);
                           WritelnNumDansRapport('valMin['+NumEnString(ThisDeltaFinal(k))+'] = ',bornes.valMin[k]);
                           WritelnNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(k))+'] = ',bornes.valMax[k]);
                           WritelnNumDansRapport('alpha = ',alpha);
                           WritelnNumDansRapport('beta = ',beta);
                           WritelnNumDansRapport('alphaInitial = ',alphaInitial);
                           WritelnNumDansRapport('betaInitial = ',betaInitial);
                         end;
                       *)

                       {coupures dues aux valeurs stockees dans la table par interversion ?}
                       if (valMin[k] >= valMax[k])
                         then
                           begin

                             if bestMode and
                                (alpha <= valMax[k]) and
                                (valMin[k] <= beta) and
                                (whichDeltaFinal = kDeltaFinaleInfini)
                               then
                                 begin
                                   if (meiDef <> 0) and (meidef = coupDeCetteValMin[k]) then
                                     begin
		                                   {on connait le score, mais on ne sort pas tout de suite
		                                    de la fonction, on se contente de dire qu'il n'y a qu'un
		                                    coup legal : cela permet de ramener la suite complete}

		                                   AmeliorerFenetreParHashTableExacte := true;
		                                   note := valMin[k];

		                                   quelleHashTableCoupsLegaux^[clefHashExacte,0] := 1;
		                                   quelleHashTableCoupsLegaux^[clefHashExacte,1] := meiDef;
		                                   ndsHeuristiques                     := ndsHeuristiques + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];
		                                   NbNoeudsHeuristiquesDansTousLesFils := NbNoeudsHeuristiquesDansTousLesFils + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];

		                                   goto sortie;

		                                 end;
		
		                               (* WritelnDansRapport('Faudrait peut-etre faire quelque chose ?'); *)

                                 end
                               else
                                 begin

                                   AmeliorerFenetreParHashTableExacte := true;
                                   note := valMin[k];
                                   meilleureSuite[ESprof,ESprof] := meiDef;

                                   ndsHeuristiques := ndsHeuristiques + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];

                                   goto sortie;
                                 end;
                           end
                         else
                           begin
                             if (valMin[k] >= beta) then
                               begin
                                 AmeliorerFenetreParHashTableExacte := true;
                                 note := valMin[k];
                                 meilleureSuite[ESprof,ESprof] := meiDef;

                                 ndsHeuristiques := ndsHeuristiques + nbArbresCoupesValMin[k];

                                 goto sortie;
                               end;

                             if (valMax[k] <= alpha) then
                               begin
                                 AmeliorerFenetreParHashTableExacte := true;
                                 note := valMax[k];
                                 meilleureSuite[ESprof,ESprof] := meiDef;

                                 ndsHeuristiques := ndsHeuristiques + nbArbresCoupesValMax[k];

                                 goto sortie;
                               end;
                           end;
                     end;

                 end
               else
                 begin
                   ExpandHashTableExacte(quelleHashTableExacte^[clefHashExacte],quelleHashTableCoupsLegaux,codagePosition,clefHashExacte);
		               DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                 end;

             valeurExacteMin := bornes.valMin[indexDeltaFinale];
             valeurExacteMax := bornes.valMax[indexDeltaFinale];

           end;


         sortie :
         gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

       end;  {if ESprof >= ProfUtilisationHash then}

    end; {with}
end;


function EndgameTreeEstValide(var whichNumeroEndgameTreeActif : SInt32; var contexte : variablesMakeEndgameSearchRec) : boolean;
var ok : boolean;
begin
  with contexte do
    begin
      ok := coupGagnantUtiliseEndgameTrees and
            (whichNumeroEndgameTreeActif >= 1) and
            (whichNumeroEndgameTreeActif <= NbMaxEndgameTrees) and
            (magicCookieEndgameTree > 0) and
            (GetMagicCookieInitialEndgameTree(whichNumeroEndgameTreeActif) = magicCookieEndgameTree);

      if not(ok) then whichNumeroEndgameTreeActif := -1;

      EndgameTreeEstValide := ok;
    end;
end;



function ABFin( var contexteMakeEndgameSearch : variablesMakeEndgameSearchRec;
                plat : plOthEndgame; var meiDef : SInt32; pere,couleur,ESprof,alpha,beta,diffPions : SInt32;
               var IndiceHashTableExacteRetour : SInt32; vientDePasser : boolean; var InfosMilieuDePartie : InfosMilieuRec;
               var NbNoeudsCoupesParHeuristique : SInt32; essayerMoinsPrecis,seulementChercherDansHash : boolean) : SInt32;
label entree_ABFin;
var platEssai : plOthEndgame;
    diffEssai : SInt32;
    InfosMilieuEssai : InfosMilieuRec;
    indexDeBoucle,k : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDef : SInt32;
    aJoue : boolean;
    nbEvalue,nbVidesTrouvees : SInt32;
    iCourant,nbCoupsPourCoul,constanteDePariteDeiCourant,nbCoupsEnvisages : SInt32;
    bestSuite : SInt32;
    caseTestee : SInt32;
    meiDefenseSansHeuristique : SInt32;
    listeCasesVides,listeTemp : listeVides;
    listeFinale : listeVides;
    clefHashConseil,conseilHash : SInt32;
    quelleHashTableExacte : HashTableExactePtr;
    quelleHashTableCoupsLegaux : CoupsLegauxHashPtr;
    indiceHashDesFils : array[1..64] of SInt32;
    evalHeuristiquesDesFils : array[1..64] of SInt32;
    valeurExacteMax,valeurExacteMin : SInt32;
    valeurHeuristiqueDeLaPosition : SInt32;
    bornes : DecompressionHashExacteRec;
    clefHashExacte,nroTableExacte : SInt32;
    codagePosition : codePositionRec;
    ordreDuMeilleur : SInt32;
    bas_fenetre,haut_fenetre : SInt32;
    largeur_fenetre : SInt32;
    valeurMaxParPionsDefinitifs : SInt32;
    valeurMinParPionsDefinitifs : SInt32;
    alphaInitial,betaInitial : SInt32;
    utiliseMilieuDePartie : boolean;
    coupLegal,dansHashExacte : boolean;
    listeFinaleFromScratch : boolean;
    switchToBitboardAlphaBeta : boolean;
    estPresqueSurementUneCoupureBeta : boolean;
    estPresqueSurementUneCoupureAlpha : boolean;
    celluleDansListeChaineeCasesVides : celluleCaseVideDansListeChaineePtr;
    NbNoeudsHeuristiquesDansCeFils : SInt32;
    NbNoeudsHeuristiquesDansTousLesFils : SInt32;
    NbNoeudsHeuristiquesPourAjusterAlpha : SInt32;
    NbNoeudsHeuristiquesPourAjusterBeta : SInt32;
    ameliorationsAlpha : AmeliorationsAlphaRec;
    nroPremierFilsAParalleliser : SInt32;
    {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
    microSecondesCurrentInfos,microSecondesDepartInfos : UnsignedWide;
    {$ENDC}
    foo_bar_atomic_register : SInt32;
    noteCoupure : SInt32;
    tickPourChronometrerTempsPrisDansCeFils : SInt32;
    tempsEnSecondesPourEvaluerCeFils : TypeReel;  {en secondes}
    evaluationDeLaPosition : SInt32;
    evalsRec : SInt32;
    indexMu : SInt32;
    numeroDePasse : SInt32;
    filsEvalue : array[1..64] of boolean;
    IDUniqueDeCeNoeud : SInt32;
    tempsCalculZoo : double;


procedure LiberePlacesHashTableExacte(nroPremierFils,nroDernierFils : SInt32);
  var i,t : SInt32;
  begin
    for i := nroPremierFils to nroDernierFils do
      if filsEvalue[i] then
        begin
          t := indiceHashDesFils[i];
          if t >= 0 then
            begin
              with HashTableExacte[t div 1024]^[BAND(t,1023)] do
                flags := BOR(flags,kMaskLiberee);
              indiceHashDesFils[i] := -3000;
            end;
        end;
  end;

procedure EtablitListeCasesVidesParListeChainee;
  var celluleDansListeChaineeCasesVides : celluleCaseVideDansListeChaineePtr;
      celluleDepart : celluleCaseVideDansListeChaineePtr;
	begin
	  nbVidesTrouvees := 0;
	  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
    celluleDansListeChaineeCasesVides := celluleDepart^.next;
	  repeat
	    with celluleDansListeChaineeCasesVides^ do
	    BEGIN
	      inc(nbVidesTrouvees);
	      listeCasesVides[nbVidesTrouvees] := square;
	      celluleDansListeChaineeCasesVides := next;
	    END;
	  until celluleDansListeChaineeCasesVides = celluleDepart;
	end;


function CaseVideIsolee(CaseVide : SInt32) : boolean;
  var t : SInt32;
  begin
    for t := DirVoisineDeb[CaseVide] to DirVoisineFin[caseVide] do
      if plat[CaseVide+DirVoisine[t]] = pionVide then
        begin
          CaseVideIsolee := false;
          exit(CaseVideIsolee);
        end;
    CaseVideIsolee := true;
  end;

procedure TrierCasesVidesIsolees;  {cases isolées d'abord}
   var ii,j,k : SInt32;
   begin
     if (plat[conseilHash] = pionVide)
       then
         begin
           j := 1;
           k := 0;
           for ii := 1 to nbVidesTrouvees do
             begin
               caseTestee := listeCasesVides[ii];
               if caseTestee = conseilHash
                 then
                   begin
                     listeFinale[1] := caseTestee;
                   end
                 else
                   if CaseVideIsolee(caseTestee)
                     then
                       begin
                         inc(j);
                         listeFinale[j] := caseTestee;
                       end
                     else
                       begin
                         inc(k);
                         listeTemp[k] := caseTestee;
                       end;
              end;
         end
       else
         begin
           j := 0;
           k := 0;
           for ii := 1 to nbVidesTrouvees do
             begin
               caseTestee := listeCasesVides[ii];
               if CaseVideIsolee(caseTestee)
	               then
	                 begin
	                   inc(j);
	                   listeFinale[j] := caseTestee;
	                 end
	               else
	                 begin
	                   inc(k);
	                   listeTemp[k] := caseTestee;
	                 end;
	            end;
          end;
     for ii := 1 to k do
       begin
         listeFinale[j+ii] := listeTemp[ii];
       end;
   end;




procedure AfficheResultatsPremiersNiveaux(couleurAffichee : SInt32; nro,total : SInt32);
  var typeAffichage,noteAffichee,noteDeTeteVisible : SInt32;
      pourcentageDejaVisible,pourcentageAffiche : SInt32;
      pourcentagePartielProf2 : SInt32;
      profDansArbre : SInt32;
  begin
    with contexteMakeEndgameSearch do
      begin
          if not(doitEcrireReflexFinale) then
            exit(AfficheResultatsPremiersNiveaux);

          if analyseRetrograde.enCours and passeDeRechercheAuMoinsValeurCible and (ReflexData^.class[1].note < valeurCible)
            then noteDeTeteVisible := valeurCible-1
            else noteDeTeteVisible := ReflexData^.class[1].note;

          pourcentageDejaVisible := ReflexData^.class[indexDuCoupDansFntrReflexion].pourcentageCertitude;
          if total > 0
             then pourcentageAffiche := RoundToL(100.0*nro/(1.0*total) - 0.01)
             else pourcentageAffiche := 100;

          profDansArbre := gNbreVides_entreeCoupGagnant-ESprof;
          with InfosPourcentagesCertitudesAffiches[profDansArbre] do
            begin
              mobiliteCetteProf := total;
              indexDuCoupCetteProf := nro;
              PourcentageAfficheCetteProf := pourcentageAffiche;
            end;


          if profDansArbre <> 2
            then pourcentagePartielProf2 := pourcentageAffiche
            else with InfosPourcentagesCertitudesAffiches[1] do
              begin
                pourcentagePartielProf2 := RoundToL(100.0*(indexDuCoupCetteProf - 1 + nro/total)/mobiliteCetteProf -0.01);
              end;

          if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
             not(passeDeRechercheAuMoinsValeurCible) and
             (maxPourBestDef > noteDeTeteVisible) and
             (pourcentagePartielProf2 > pourcentageAffiche)
             then pourcentageAffiche := pourcentagePartielProf2;

          if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
             passeDeRechercheAuMoinsValeurCible and
             (maxPourBestDef = valeurCible)
             then pourcentageAffiche := pourcentagePartielProf2;

          if (nro = 1) and (total > 1) and (indexDuCoupDansFntrReflexion > 1) and
            not(FenetreLargePourRechercheScoreExact) then
            exit(afficheResultatsPremiersNiveaux);

          {
          if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
             not(passeDeRechercheAuMoinsValeurCible) and
             (maxPourBestDef > noteDeTeteVisible+2) and
             (nro > 1) and (total > 1)
           then
             begin
               	EssaieSetPortWindowPlateau;
      			    EcritPositionAt(plat,10,10);
      			     WriteNumAt(' prof = ',ESprof,10,130);
      			     WriteNumAt(' gNbreVides_entreeCoupGagnant = ',gNbreVides_entreeCoupGagnant,80,130);
      			     if couleur = pionBlanc
      			       then WriteStringAt('pionBlanc  ',210,130)
      			       else WriteStringAt('pionNoir    ',210,130);
      			     WriteNumAt('nro = ',nro,10,140);
      			     WriteNumAt('total = ',total,70,140);
      			     WriteNumAt('certitude = ',pourcentageAffiche,150,140);
      			     WriteNumAt('pourcentagePartiel = ',pourcentagePartielProf2,240,140);
      			     WriteStringAt('pere = '+CoupEnStringEnMajuscules(pere),70,150);
      			     WriteNumAt('note = ',maxPourBestDef,200,150);

      			     WriteStringAt('meiDef = '+CoupEnStringEnMajuscules(meiDef),70,160);
      			     WriteNumAt('maxPourBestDef = ',maxPourBestDef,200,160);
      			     WriteNumAt('alpha = ',alpha,10,170);
      			     WriteNumAt('beta = ',beta,90,170);
      			     WriteNumAt('alphaInitial = ',alphaInitial,10,180);
      			     WriteNumAt('betaInitial = ',betaInitial,90,180);

      			     WriteNumAt('coul = ',couleurAffichee,150,170);
      			     WriteNumAt('coulDef = ',CoulDefense,220,170);
      			     SysBeep(0);
      			     AttendFrappeClavier;
             end;
          }

          if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
             passeDeRechercheAuMoinsValeurCible and
             (maxPourBestDef = valeurCible) and
             (nro <= 1) and (total > 1) then
             exit(afficheResultatsPremiersNiveaux);

          {
          if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
             not(passeDeRechercheAuMoinsValeurCible) and
             (indexDuCoupDansFntrReflexion <= 1) then
             exit(afficheResultatsPremiersNiveaux);
          }

          if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
             (couleurAffichee = CoulDefense) then
             exit(afficheResultatsPremiersNiveaux);


          if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
             not(passeDeRechercheAuMoinsValeurCible) and
             (maxPourBestDef > noteDeTeteVisible+2) and
             (indexDuCoupDansFntrReflexion > 1) and
             (nro = 1) and (total > 1)
            then exit(afficheResultatsPremiersNiveaux);


          if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
             (pourcentageDejaVisible > 0) and
             (pourcentageDejaVisible < 100) and
             (pourcentageAffiche < pourcentageDejaVisible) then
             exit(afficheResultatsPremiersNiveaux);

          if not(bestMode) and not(bestmodeArriveeDansCoupGagnant)
            then
              if analyseRetrograde.enCours
                then typeAffichage := ReflRetrogradeGagnant
                else
                  if analyseIntegraleDeFinale
                    then typeAffichage := ReflGagnantExhaustif
                    else typeAffichage := ReflGagnant
            else
              if analyseRetrograde.enCours
                then
                  if FenetreLargePourRechercheScoreExact
                    then typeAffichage := ReflRetrogradeParfaitPhaseRechScore
                    else if (passeDeRechercheAuMoinsValeurCible and (valeurCible = 0))
                           then typeAffichage := ReflRetrogradeParfaitPhaseGagnant
                           else typeAffichage := ReflRetrogradeParfait
                else
                  if FenetreLargePourRechercheScoreExact
                    then
                      if analyseIntegraleDeFinale
                        then typeAffichage := ReflParfaitExhaustif
                        else typeAffichage := ReflParfaitPhaseRechScore
                    else if (passeDeRechercheAuMoinsValeurCible and (valeurCible = 0))
                           then typeAffichage := ReflParfaitPhaseGagnant
                           else typeAffichage := ReflParfait;

           noteAffichee := -maxPourBestDef;
           if (noteAffichee > valeurCible) and passeDeRechercheAuMoinsValeurCible then noteAffichee := valeurCible+1;
           if (noteAffichee = valeurCible) and passeDeRechercheAuMoinsValeurCible then noteAffichee := valeurCible;
           if (noteAffichee < valeurCible) and passeDeRechercheAuMoinsValeurCible then noteAffichee := valeurCible-1;
           if couleurAffichee <> CoulDefense then noteAffichee := -noteAffichee;

           if (ESprof <= gNbreVides_entreeCoupGagnant-2) and
              (not(passeDeRechercheAuMoinsValeurCible) or (maxPourBestDef = valeurCible)) and
              ((maxPourBestDef > noteDeTeteVisible+2) or (indexDuCoupDansFntrReflexion = 1))
            then pourcentageAffiche := pourcentagePartielProf2;

           ReflexData^.typeDonnees := typeAffichage;
           ReflexData^.compteur := indexDuCoupDansFntrReflexion;
           ReflexData^.IndexCoupEnCours := indexDuCoupDansFntrReflexion;
           with ReflexData^.class[indexDuCoupDansFntrReflexion] do
             begin
               note := noteAffichee;
               if (ESprof <= gNbreVides_entreeCoupGagnant-2)
                 then theDefense := pere
                 else theDefense := meiDef;
               pourcentageCertitude := pourcentageAffiche;
               delta := deltaFinaleCourant;
               temps := temps+(TickCount-tickChrono);
               tickChrono := TickCount
             end;
           if affichageReflexion.doitAfficher then
             LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant),'AfficheResultatsPremiersNiveaux');




           {
          EssaieSetPortWindowPlateau;
          EcritPositionAt(plat,10,10);
          EcritPositionAt(position,200,10);
           WriteNumAt(' prof = ',ESprof,10,130);
           WriteNumAt(' gNbreVides_entreeCoupGagnant = ',gNbreVides_entreeCoupGagnant,80,130);
           if couleur = pionBlanc
             then WriteStringAt('pionBlanc  ',210,130)
             else WriteStringAt('pionNoir    ',210,130);
           WriteNumAt('nro = ',nro,10,140);
           WriteNumAt('total = ',total,70,140);
           WriteNumAt('certitude = ',RoundToL(0.4+100.0*nro/(1.0*total)),150,140);
           WriteStringAt('coup = '+CoupEnStringEnMajuscules(coup),70,150);
           WriteNumAt('note = ',note,200,150);
           WriteStringAt('meiDef = '+CoupEnStringEnMajuscules(meiDef),70,160);
           WriteNumAt('maxPourBestDef = ',maxPourBestDef,200,160);
           SysBeep(0);
           AttendFrappeClavier;
           }
      end;
  end;


procedure AjusteStatutsDeKnuthDuNoeud;
begin
  with quelleHashTableExacte^[clefHashExacte] do
    if (evaluationHeuristique <> kEvaluationNonFaite) then
      begin
        estPresqueSurementUneCoupureBeta  := (evaluationHeuristique >= (100*beta  + 800));
        estPresqueSurementUneCoupureAlpha := (evaluationHeuristique <= (100*alpha - 800));
      end;
end;


function PeutFaireCoupureHeuristique(var noteCoupure : SInt32) : boolean;
var estimationPessimiste,estimationOptimiste : SInt32;
    {tickArrivee,}nbEvaluationRecursives : SInt32;
    defense : SInt32;
    deltaMobilite : SInt32;
    deltaFinaleUtiliseDansCeNoueud : SInt32;
    deltaFinaleMaximum : SInt32;
    k : SInt32;
    lower,upper : SInt32;
    coupureHeuristiqueAlpha : boolean;
    coupureHeuristiqueBeta : boolean;
    {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
    microSecondesCurrent,microSecondesDepart : UnsignedWide;
    {$ENDC}
begin
  with contexteMakeEndgameSearch do
    begin

        PeutFaireCoupureHeuristique := false;
        noteCoupure := 0;

        if not(utiliseMilieuDePartie) then exit(PeutFaireCoupureHeuristique);

        {tickArrivee := TickCount;}
        nbEvaluationRecursives := 0;


        with InfosMilieuDePartie do
          begin
            deltaMobilite := CalculeMobilite(couleur,plat,jouable) - CalculeMobilite(-couleur,plat,jouable);

            deltaFinaleUtiliseDansCeNoueud := deltaFinaleCourant + 10*deltaMobilite;

            if (ESprof = profFinaleHeuristique - 1)
              then deltaFinaleUtiliseDansCeNoueud := deltaFinaleUtiliseDansCeNoueud + 75;

            deltaFinaleMaximum := deltaSuccessifs[nbreDeltaSuccessifs-1].valeurDeMu + 10*deltaMobilite + 50;
          end;


        if (deltaFinaleCourant < kDeltaFinaleInfini) then
      	  with quelleHashTableExacte^[clefHashExacte] do
      	    begin
      	      if (evaluationHeuristique = kEvaluationNonFaite) then
      	        with InfosMilieuDePartie do
      	          begin


      	            if (evaluationHeuristique = kEvaluationNonFaite) then
      	              begin


          	            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
          	            Microseconds(microSecondesDepart);
          	            {$ENDC}

          	            if (profEvaluationHeuristique[ESprof] < 0)
          	              then
          	                begin
          	                  lower := Max(-30000, alpha*100 - deltaFinaleMaximum);
          	                  upper := Min( 30000, beta*100  + deltaFinaleMaximum);
          	                  evaluationHeuristique := Evaluation(plat,couleur,nbBlancs,nbNoirs,jouable,frontiere,false,lower,upper,nbEvaluationRecursives);

          	                  defense := 0;


          	                  {$IFC USE_DEBUG_STEP_BY_STEP}
          	                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
                                then
                                  begin
                                    WritelnDansRapport('');
                                    WritelnDansRapport('vient juste de calculer valeur heuristique par Evaluation :');
                                    WritelnStringAndCoupDansRapport('oldMeiDef := ',meiDef);
                                    WritelnStringAndCoupDansRapport('meiDef := ',0);
                                    WritelnDansRapport('');
                                  end;
                              {$ENDC}

          	                  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
          	                  Microseconds(microSecondesCurrent);
          						        AjouterTempsDansMiniProfiler(0,-2,microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
          						        {$ENDC}

          						        meiDef := 0;
          	                end
          	              else
          	                begin
          	                  lower := Max(-30000, alpha*100 - deltaFinaleMaximum);
                              upper := Min( 30000, beta*100  + deltaFinaleMaximum);


                              evaluationHeuristique := AB_simple(plat,jouable,defense,couleur,profEvaluationHeuristique[ESprof],lower,upper,nbBlancs,nbNoirs,frontiere,true);



          	                  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
          	                  Microseconds(microSecondesCurrent);
          						        AjouterTempsDansMiniProfiler(0,profEvaluationHeuristique[ESprof],microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
          						        {$ENDC}

          	                  {$IFC USE_DEBUG_STEP_BY_STEP}
          	                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
                                then
                                  begin
                                    WritelnDansRapport('');
                                    WritelnDansRapport('vient juste de calculer valeur heuristique par AB_simple :');
                                    WritelnStringAndCoupDansRapport('oldMeiDef := ',meiDef);
                                    WritelnStringAndCoupDansRapport('meiDef := ',defense);
                                    WritelnDansRapport('');
                                  end;
                              {$ENDC}

                              meiDef := defense;
          	                end;

                        end;

      							evaluationHeuristique := Trunc(dilatationEvalEnFinale*evaluationHeuristique);

      		        end;


      	      {soyons pessimiste de deltaFinaleCourant…}
      	      estimationPessimiste := 2*(NoteCassioEnScoreFinal(evaluationHeuristique-deltaFinaleUtiliseDansCeNoueud)-32);


      	      for k := indexDeltaFinaleCourant to nbreDeltaSuccessifs do
      	        begin
      			      if (estimationPessimiste > bornes.valMax[k]) and (bornes.nbArbresCoupesValMax[k] = 0)
      			        then estimationPessimiste := Max(-64,bornes.valMax[k]);

      			      if (estimationPessimiste > bornes.valMax[k])
      		          then estimationPessimiste := bornes.valMax[k];

      		        if (estimationPessimiste < bornes.valMin[k])
      		          then estimationPessimiste := bornes.valMin[k];
                end;


      	      { coupure beta heuristique ? }
      	      coupureHeuristiqueBeta := (estimationPessimiste >= beta);

      	      if coupureHeuristiqueBeta then
      	        begin

                  AugmentationMinorant(estimationPessimiste,deltaFinaleCourant,meiDef,couleur,bornes,plat,'coupures heuristiques (1)');
                  SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
                  CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);

                  {$IFC USE_DEBUG_STEP_BY_STEP}
                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
                     then
                        begin
                          WritelnDansRapport('');
                          WritelnDansRapport('appel de CompresserBornes(1)');
                          WritelnPositionEtTraitDansRapport(plat,couleur);
                          WritelnNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
                          WritelnNumDansRapport('bornes.valMax[nbreDeltaSuccessifs] = ',bornes.valMax[nbreDeltaSuccessifs]);
                          WritelnNumDansRapport('ESProf = ',ESProf);
                          WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
                          WritelnDansRapport('');
                        end;
                  {$ENDC}

      	          inc(NbNoeudsCoupesParHeuristique);
      	          meilleureSuite[ESprof,ESprof] := meiDef;
      	          meilleureSuite[ESprof,profMoins1] := 0;
                  gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

                  noteCoupure := estimationPessimiste;

                  PeutFaireCoupureHeuristique := true;
                  exit(PeutFaireCoupureHeuristique);

      	          {WritelnNumDansRapport('coup. beta heuristique, delta = ',deltaFinaleCourant);
      				    WritelnPositionEtTraitDansRapport(plat,couleur);
      				    WriteNumDansRapport('beta = ',beta);
      				    WritelnNumDansRapport(' et heuristique pess. = ',finaleEstimee);
      				    SysBeep(0);
      				    AttendFrappeClavier;}

      	        end;

      	      {soyons optimiste de deltaFinaleCourant…}
      	      estimationOptimiste := 2*(NoteCassioEnScoreFinal(evaluationHeuristique+deltaFinaleUtiliseDansCeNoueud)-32);

      	      for k := indexDeltaFinaleCourant to nbreDeltaSuccessifs do
      	        begin
      			      if (estimationOptimiste < bornes.valMin[k]) and (bornes.nbArbresCoupesValMin[k] = 0)
      			        then estimationOptimiste := Min(64,bornes.valMin[k]);

      			      if (estimationOptimiste < bornes.valMin[k])
      			        then estimationOptimiste := bornes.valMin[k];

      			      if (estimationOptimiste > bornes.valMax[k])
      		          then estimationOptimiste := bornes.valMax[k];
      		      end;



      	      { coupure alpha heuristique ? }
      	      coupureHeuristiqueAlpha := (estimationOptimiste <= alpha);



      	      if coupureHeuristiqueAlpha then
      	        begin

                  DiminutionMajorant(estimationOptimiste,deltaFinaleCourant,couleur,bornes,plat,'coupures heuristiques (3)');
                  SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
                  CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);

                  {$IFC USE_DEBUG_STEP_BY_STEP}
                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
                     then
                          begin
                            WritelnDansRapport('');
                            WritelnDansRapport('appel de CompresserBornes(2)');
                            WritelnPositionEtTraitDansRapport(plat,couleur);
                            WritelnNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
                            WritelnNumDansRapport('bornes.valMax[nbreDeltaSuccessifs] = ',bornes.valMax[nbreDeltaSuccessifs]);
                            WritelnNumDansRapport('ESProf = ',ESProf);
                            WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
                            WritelnDansRapport('');
                          end;
                  {$ENDC}

      	          inc(NbNoeudsCoupesParHeuristique);
      	          meilleureSuite[ESprof,ESprof] := meiDef;
      	          meilleureSuite[ESprof,profMoins1] := 0;
                  gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

                  noteCoupure := estimationOptimiste;

                  PeutFaireCoupureHeuristique := true;
                  exit(PeutFaireCoupureHeuristique);

      	          {WritelnNumDansRapport('coup. alpha heuristique, delta = ',deltaFinaleCourant);
      				    WritelnPositionEtTraitDansRapport(plat,couleur);
      				    WriteNumDansRapport('alpha = ',alpha);
      				    WritelnNumDansRapport(' et heuristique opt. = ',finaleEstimee);
      				    SysBeep(0);
      				    AttendFrappeClavier;}

      	        end;

      	    end;
    end;

end;




function PeutFaireCoupureRapide(alphaRapide,betaRapide : SInt32; var newAlpha,newBeta : SInt32) : boolean;
var t : SInt32;
begin
  if (alphaRapide < betaRapide) then
  if (alphaRapide <> alpha) or (betaRapide <> beta) then
    begin
	  {WritelnStringDansRapport(s);
	   WritelnNumDansRapport('alphaInitial = ',alphaInitial);
	   WritelnNumDansRapport('betaInitial = ',betaInitial);
	   WritelnNumDansRapport('alpha = ',alpha);
	   WritelnNumDansRapport('beta = ',beta);
	   WritelnNumDansRapport('alphaRapide = ',alphaRapide);
	   WritelnNumDansRapport('betaRapide = ',betaRapide);
	   WritelnPositionEtTraitDansRapport(plat,couleur);}

	  if ESprof >= ProfUtilisationHash then
          gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

	   t := ABFin(contexteMakeEndgameSearch, plat,meiDef,pere,couleur,ESprof,alphaRapide,betaRapide,diffPions,IndiceHashTableExacteRetour,
	              vientDePasser,InfosMilieuDePartie,NbNoeudsCoupesParHeuristique,false,false);

     if ESprof >= ProfUtilisationHash then
          gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

       if t >= betaRapide then
         begin
           {WritelnNumDansRapport('t >= betaRapide: t = ',t);}
           if t >= beta then
             begin
               {WritelnNumDansRapport('coupure beta ! car beta = ',beta);}
               {PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);}


               ABFin := t;
               if ESprof >= ProfUtilisationHash then
                 gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
               exit(ABFin);

             end;

           if t > alpha+1 then
             begin
               {WritelnNumDansRapport('alpha augmente ! car alpha = ',alpha);}
               newAlpha := t-1;
               newBeta := Max(beta,newalpha+1);
               PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);
             end;

           if t <= alpha then
             begin
               WritelnNumDansRapport('should never happen (t <= alpha) ! ',0);
               SysBeep(0);
               AttendFrappeClavier;
             end;
         end

           else

       if t <= alphaRapide then
         begin
           {WritelnNumDansRapport('t <= alphaRapide: t = ',t);}
           if t <= alpha then
             begin
               {WritelnNumDansRapport('coupure alpha ! car alpha = ',alpha);}
               {PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);}

               ABFin := t;
               if ESprof >= ProfUtilisationHash then
                 gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
               exit(ABFin);


             end;

           if t < beta-1 then
             begin
               {WritelnNumDansRapport('beta diminue ! car beta = ',beta);}
               newBeta := t+1;
               newAlpha := Min(alpha,newBeta-1);
               PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);
             end;

           if t >= beta then
             begin
               WritelnNumDansRapport('should never happen (t >= beta) ! ',0);
               SysBeep(0);
               AttendFrappeClavier;
             end;
         end

           else

         begin
           WritelnNumDansRapport('alphaRapide < t < betaRapide : t = ',t);
           if (t > alpha) and (t < beta) then
             begin
               WritelnStringDansRapport('valeur exacte !');
               newAlpha := t-1;
               newBeta := t+1;
               PeutFaireCoupureRapide := true;
               exit(PeutFaireCoupureRapide);
             end;
           WritelnNumDansRapport('should never happen (not((t > alpha) and (t < beta))) ! ',0);
           SysBeep(0);
           AttendFrappeClavier;
         end;

	 end;
	PeutFaireCoupureRapide := false;
end;


procedure EssaieApproximationsMoinsPrecises;
var tempDeltaFinaleCourant,k : SInt32;
    dernierDeltaDeCettePosition : SInt32;
    valeur,meiDefBid,indiceBid,nbNoeudsBid : SInt32;
begin
  if (deltaFinaleCourant > deltaSuccessifs[1].valeurDeMu) then
    begin

      (* on trouve le dernier degre d'approximation applique a ce noeud *)

      dernierDeltaDeCettePosition := -100000;
      with bornes do
	      for k := 1 to nbreDeltaSuccessifs do
	        if (bornes.valMin[k] > -64) or (bornes.valMax[k] < 64)         {pas juste developpe ?}
	          then dernierDeltaDeCettePosition := ThisDeltaFinal(k);

      if dernierDeltaDeCettePosition < deltaFinaleCourant then
        begin

		      for k := 1 to nbreDeltaSuccessifs do
		        if (deltaSuccessifs[k].valeurDeMu > dernierDeltaDeCettePosition) and
		           (deltaSuccessifs[k].valeurDeMu < deltaFinaleCourant) then
		          begin

		            tempDeltaFinaleCourant := deltaFinaleCourant;
		            SetDeltaFinalCourant(deltaSuccessifs[k].valeurDeMu);


		            if ESprof >= ProfUtilisationHash then
	                gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

		            valeur := ABFin(contexteMakeEndgameSearch, plat,meiDefBid,pere,couleur,ESprof,alpha,beta,diffPions,indiceBid,
		                            vientDePasser,InfosMilieuDePartie,nbNoeudsBid,false,false);

	              if ESprof >= ProfUtilisationHash then
	                gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));


		            SetDeltaFinalCourant(tempDeltaFinaleCourant);
		          end;
		     end;
    end;
end;


procedure EssaieApproximationsHeuristiquesSecondNiveau;
var tempDeltaFinaleCourant,k : SInt32;
    dernierDeltaDeCettePosition : SInt32;
    valeur,meiDefBid,indiceBid,nbNoeudsBid : SInt32;
begin


  (* on trouve le dernier degre d'approximation applique a ce noeud *)

  dernierDeltaDeCettePosition := -100000;
  with bornes do
    for k := 1 to nbreDeltaSuccessifs do
      if (bornes.valMin[k] > -64) or (bornes.valMax[k] < 64)         {pas juste developpe ?}
        then dernierDeltaDeCettePosition := ThisDeltaFinal(k);



  (* si c'est un noeud juste développé (on arrive à cette position pour le premiere fois),
     alors on essaye de le resoudre avec des approximations heuristiques de second
     type *)

  if dernierDeltaDeCettePosition = -100000 then
    begin

      for k := 1 to nbreDeltaSuccessifs do
        begin

          tempDeltaFinaleCourant := deltaFinaleCourant;
          SetDeltaFinalCourant(deltaSuccessifs[k].valeurDeMu);


          if ESprof >= ProfUtilisationHash then
            gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

          valeur := ABFin(contexteMakeEndgameSearch, plat,meiDefBid,pere,couleur,ESprof,alpha,beta,diffPions,indiceBid,
                          vientDePasser,InfosMilieuDePartie,nbNoeudsBid,false,false);

          if ESprof >= ProfUtilisationHash then
            gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));


          SetDeltaFinalCourant(tempDeltaFinaleCourant);
        end;
     end;
end;


// la fonction pour chercher des ETC (Ehanced Transposition Cutoffs)
function PeutTrouverTranspositionUnCoupPlusLoin(alpha,beta : SInt32; var noteCoupure : SInt32) : boolean;
var noteTransposition : SInt32;
    nbMaxTranspositionsCherchees : SInt32;
    i,iCourant,constanteDePariteDeiCourant : SInt32;
    platTranspo : plOthEndgame;
    diffTranspo : SInt32;
    InfosMilieuTranspo : InfosMilieuRec;
    celluleDansListeChaineeCasesVides : celluleCaseVideDansListeChaineePtr;
    bestSuiteTranspo : SInt32;
    NbNoeudsHeuristiquesDansCeFilsTranspo : SInt32;
    indiceHashDummy : SInt32;
begin


  noteCoupure := 0;
  PeutTrouverTranspositionUnCoupPlusLoin := false;


  platTranspo := plat;
  diffTranspo := diffPions;
  if utiliseMilieuDePartie then InfosMilieuTranspo := InfosMilieuDePartie;


  nbMaxTranspositionsCherchees := nbCoupsPourCoul;
  if nbMaxTranspositionsCherchees > 5 then nbMaxTranspositionsCherchees := 5;

  for i := 1 to nbMaxTranspositionsCherchees do
    BEGIN
      iCourant := listeFinale[i];
      constanteDePariteDeiCourant := constanteDeParite[iCourant];

      if utiliseMilieuDePartie
        then
          begin
            with InfosMilieuTranspo do
              begin
                //WritelnNumDansRapport('PeutTrouverTranspositionUnCoupPlusLoin, coup = ',iCourant);
                coupLegal := ModifPlatLongint(iCourant,couleur,platTranspo,jouable,nbBlancs,nbNoirs,frontiere);
                if coupLegal then
                  if couleur = pionNoir
                    then diffTranspo := nbNoirs-nbBlancs
                    else diffTranspo := nbBlancs-nbNoirs;
              end;
          end
        else
          coupLegal := ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platTranspo,diffTranspo);

      if coupLegal then
        begin


          gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
          {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
          celluleDansListeChaineeCasesVides := gTableDesPointeurs[iCourant];
          with celluleDansListeChaineeCasesVides^ do
            begin
              previous^.next := next;
              next^.previous := previous;
            end;

          NbNoeudsHeuristiquesDansCeFilsTranspo := 0;
          noteTransposition := -ABFin(contexteMakeEndgameSearch, platTranspo,bestSuiteTranspo,iCourant,adversaire,profMoins1,
                                      -beta,-alpha,-diffTranspo,indiceHashDummy,false,
                                      InfosMilieuTranspo,NbNoeudsHeuristiquesDansCeFilsTranspo,false,true);

          gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
          {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
				  with celluleDansListeChaineeCasesVides^ do
						begin
						  previous^.next := celluleDansListeChaineeCasesVides;
						  next^.previous := celluleDansListeChaineeCasesVides;
						end;



					if not(EstUneNoteDeETCNonValide(noteTransposition)) then
					  begin
					    if noteTransposition >= beta then
					      begin

					        {$IFC USE_DEBUG_STEP_BY_STEP}
					        if gDebuggageAlgoFinaleStepByStep.actif and
					           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
					           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
					          begin
					            WritelnDansRapport('');
							        WritelnDansRapport('sortie par coupure beta dans EssaieTrouverTranspositionUnCoupPlusLoin :');
		                  WritelnNumDansRapport('alpha = ',alpha);
		                  WritelnNumDansRapport('beta = ',beta);
		                  WritelnNumDansRapport('noteTransposition = ',noteTransposition);
		                  WritelnStringAndCoupDansRapport('bestSuiteTranspo = ',bestSuiteTranspo);
		                  WritelnNumDansRapport('ESprof = ',ESprof);
		                  WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
		                  WritelnNumDansRapport('i = ',i);
		                  WritelnPositionEtTraitDansRapport(plat,couleur);
		                  WritelnDansRapport('');
                    end;
                  {$ENDC}

                  MetPosDansHashTableExacteEndgame(quelleHashTableExacte^[clefHashExacte],codagePosition,valeurHeuristiqueDeLaPosition);
                  MetCoupEnTeteEtAttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,iCourant,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);

                  SetBestDefenseDansHashExacte(iCourant,quelleHashTableExacte^[clefHashExacte]);

	               {l'ancienne borne superieure}
	                if bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] = 0
	                  then DiminutionMajorant(valeurExacteMax,kDeltaFinaleInfini,couleur,bornes,plat,'transpo (3)')  {borne sure à 100%}
	                  else DiminutionMajorant(valeurExacteMax,deltaFinaleCourant,couleur,bornes,plat,'transpo (4)'); {borne heuristique}

                 {la nouvelle borne inferieure}
                  if NbNoeudsHeuristiquesDansCeFilsTranspo = 0
                    then AugmentationMinorant(noteTransposition,kDeltaFinaleInfini,iCourant,couleur,bornes,plat,'transpo (1)')  {borne sure à 100%}
                    else AugmentationMinorant(noteTransposition,deltaFinaleCourant,iCourant,couleur,bornes,plat,'transpo (2)'); {borne heuristique}

                  CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);

                  {$IFC USE_DEBUG_STEP_BY_STEP}
                  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                    begin
                      WritelnDansRapport('');
                      WritelnDansRapport('appel de CompresserBornes(3)');
                      WritelnPositionEtTraitDansRapport(plat,couleur);
                      WritelnNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
                      WritelnNumDansRapport('bornes.valMax[nbreDeltaSuccessifs] = ',bornes.valMax[nbreDeltaSuccessifs]);
                      WritelnNumDansRapport('ESProf = ',ESProf);
                      WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
                      WritelnDansRapport('');
                    end;
                  {$ENDC}

                  (*
                  WritelnNumDansRapport('ESPRof = ',ESProf);
                  WritelnNumDansRapport('profondeurRemplissageHash = ',profondeurRemplissageHash);
                  WritelnNumDansRapport('clefHashConseil = ',clefHashConseil);
                  WritelnNumDansRapport('couleur = ',couleur);
                  WritelnNumDansRapport('pere = ',pere);
                  *)


	                PeutTrouverTranspositionUnCoupPlusLoin := true;
	                noteCoupure := noteTransposition;

					        if ESprof >= profondeurRemplissageHash
                    then HashTable^^[clefHashConseil] := iCourant;
                  gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
                  NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique+NbNoeudsHeuristiquesDansCeFilsTranspo;

                  exit(PeutTrouverTranspositionUnCoupPlusLoin);



					      end;

					  end;




          platTranspo := plat;
				  diffTranspo := diffPions;
				  if utiliseMilieuDePartie then InfosMilieuTranspo := InfosMilieuDePartie;

        end;

    END;

end;


procedure CalculerLaNoteCouranteDeCeFils;
var valeurParLeZoo, bestSuiteZoo, k : SInt32;
    tempsZoo : double;
    indexMu, numeroArret: SInt32;
begin

  Discard(indexMu);

  with contexteMakeEndgameSearch do
    begin

       switchToBitboardAlphaBeta := (profMoins1 <= profForceBrute);

     // Optimisation introduite dans Cassio 6.1.7 : si on est suffisamment pres de la
     // frontiere entre classement par milieu et classement par bitboard, et si on est
     // presque sûr que le PREMIER coup va donner une coupure beta (presque sûr, grace
     // aux informations de µ ou au tri des coups, par exemple), on peut prendre le
     // risque de classer un peu moins bien les fils de la position resultante au niveau
     // suivant (car on va presque sûrement devoir tous les generer, de toute façon).
     // On gagne ainsi le temps de tri au niveau suivant, au prix d'un leger accroissement
     // du nombre de noeuds.

     if estPresqueSurementUneCoupureBeta
        and (profMoins1 <= profForceBrute + 2)
        and (indexDeBoucle <= 1)
        then switchToBitboardAlphaBeta := true;


     if CassioUtiliseLeMultiprocessing
        and not(estPresqueSurementUneCoupureAlpha)
        and (profMoins1 <= profForceBrute + gExtensionDeParallelisme)
        then switchToBitboardAlphaBeta := true;


     if CassioUtiliseLeMultiprocessing
        and not(estPresqueSurementUneCoupureBeta)
        and (profMoins1 >= profForceBrute)
        then switchToBitboardAlphaBeta := false;


     if CassioUtiliseLeMultiprocessing
        and estPresqueSurementUneCoupureBeta
        and (profMoins1 <= profForceBrute + gExtensionDeParallelisme + gExtensionDeCoupureBetaProbable)
        then switchToBitboardAlphaBeta := true;




     (*
     if estPresqueSurementUneCoupureBeta and (profMoins1 <= profForceBrute + 3) and (indexDeBoucle = 1)
       then
         begin
           inc(gNombreDeCoupuresBetaPresquesSures);
           {WritelnStringAndReelDansRapport('ratio de beta-parallelisme reussi = ',1.0*gNombreDeCoupuresBetaReussies/gNombreDeCoupuresBetaPresquesSures,4);}
         end;
     *)

     if switchToBitboardAlphaBeta
       then
         begin


              if estPresqueSurementUneCoupureBeta  and (indexDeBoucle = 1) and gAvecParallelismeSpeculatif
                then nroPremierFilsAParalleliser := 1
                else nroPremierFilsAParalleliser := Max(gYoungBrotherWaitElders, indexDeBoucle);

              noteCourante := -LanceurBitboardAlphaBeta(platEssai,adversaire,profMoins1,-beta,-alpha,-diffEssai,nroPremierFilsAParalleliser);


              if (noteCourante < -64) or (noteCourante > 64) then
                WritelnNumDansRapport('ASSERT !!! dans CalculerLaNoteCouranteDeCeFils, noteCourante par bitboard = ',noteCourante);


              if (noteCourante >= beta) and (nroPremierFilsAParalleliser > 1)
                then inc(gNbreDeSplitNodesRates);

              {$IFC NOT(NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME) }
              if estPresqueSurementUneCoupureBeta
                then nbreNoeudsGeneresFinale := nbreNoeudsGeneresFinale + (CalculeMobilitePlatSeulement(platEssai,adversaire)*nbNoeudsEstimes[profMoins1 - 2] div 2)
                else nbreNoeudsGeneresFinale := nbreNoeudsGeneresFinale + nbNoeudsEstimes[profMoins1 - 1];
              {$ENDC}



              (*  sans bitboard...
              noteCourante := -ABFinPetite(platEssai,adversaire,profMoins1,-beta,-alpha,-diffEssai,false);
               *)

           inc(nbEvalue);
         end
       else
         begin

          valeurParLeZoo := GetValeurZooDeCeFils(ESProf,iCourant,bestSuite,tempsZoo);

          if (valeurParLeZoo >= -64) and (valeurParLeZoo <= 64)
            then
              begin

                (*
                WriteNumDansRapport('p = ',ESProf);
                WriteDansRapport(' : le coup '+CoupEnStringEnMajuscules(iCourant)+' a été calculé par le zoo ');
                WriteStringAndReelDansRapport('en ',tempsZoo,4);
                WritelnDansRapport(' sec :-)');
                WritelnDansRapport('position père = ');
                WritelnPositionEtTraitDansRapport(plat,couleur);
                WritelnStringAndCoupDansRapport('icourant = ',iCourant);
                WritelnDansRapport('[alpha,beta] = ['+NumEnString(alpha)+','+NumEnString(beta)+']');
                WritelnDansRapport('position fils = ');
                WritelnPositionEtTraitDansRapport(platEssai,adversaire);
                WriteStringAndCoupDansRapport('valeur de ',iCourant);
                WritelnNumDansRapport(' = ',valeurParLeZoo);
                WritelnDansRapport('');
                *)

                noteCourante := valeurParLeZoo;

                if (profMoins1 < profFinaleHeuristique) or (deltaFinaleCourant = kDeltaFinaleInfini)
                  then NbNoeudsHeuristiquesDansCeFils := 0
                  else NbNoeudsHeuristiquesDansCeFils := 1;

                for k := profForceBrutePlusUn to profMoins1 do  meilleureSuite[profMoins1,k] := 0;
                if (bestSuite >= 11) and (bestSuite <= 88)
                  then
                    begin
                      meilleureSuite[profMoins1,profMoins1] := bestSuite;
                    end
                  else
                    begin
                      WritelnNumDansRapport('ASSERT ! bestSuite du zoo out of bounds dans CalculerLaNoteCouranteDeCeFils, bestsuite = ',bestsuite);
                    end;

              end
            else
              begin

                if (valeurParLeZoo = k_ZOO_EN_ATTENTE_DE_RESULTAT) and not(DoitStopperExecutionDeCeSousArbre(ESProf)) and (interruptionReflexion = pasdinterruption)
                  then CassioPrendEnChargeLuiMemeCeFilsDuZoo(ESProf,iCourant);

                if (nbEvalue <= 0)
                  then
                    begin
                      noteCourante := -ABFin(contexteMakeEndgameSearch, platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                             -beta,-alpha,-diffEssai,indiceHashDesFils[indexDeBoucle],false,
                                             InfosMilieuEssai,NbNoeudsHeuristiquesDansCeFils,essayerMoinsPrecis,false);

                    end
                  else
                   begin
                     noteCourante := -ABFin(contexteMakeEndgameSearch, platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                            pred(-alpha),-alpha,-diffEssai,indiceHashDesFils[indexDeBoucle],false,
                                            InfosMilieuEssai,NbNoeudsHeuristiquesDansCeFils,essayerMoinsPrecis,false);
                     if (alpha < noteCourante) and (noteCourante < beta) then
                       if bestMode
                         then
                           begin
                            {largeur_fenetre := 8;}
                             largeur_fenetre := 2;
                             repeat
                               bas_fenetre := pred(noteCourante);
                               haut_fenetre := bas_fenetre+largeur_fenetre;
                               if (bas_fenetre < alpha) then bas_fenetre  := alpha;
                               if (haut_fenetre > beta) then haut_fenetre := beta;

                               noteCourante := -ABFin(contexteMakeEndgameSearch, platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                      -haut_fenetre,-bas_fenetre,-diffEssai,indiceHashDesFils[indexDeBoucle],false,
                                                      InfosMilieuEssai,NbNoeudsHeuristiquesDansCeFils,essayerMoinsPrecis,false);
                               largeur_fenetre := 2*largeur_fenetre;
                               if largeur_fenetre > 16 then largeur_fenetre := 16;
                             until ((bas_fenetre < noteCourante) and (noteCourante < haut_fenetre)) or
                                   (noteCourante >= beta) or (noteCourante <= alpha) or ValeurDeFinaleInexploitable(noteCourante);
                           end
                         else
                           noteCourante := -ABFin(contexteMakeEndgameSearch, platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                  -beta,-noteCourante,-diffEssai,indiceHashDesFils[indexDeBoucle],false,
                                                  InfosMilieuEssai,NbNoeudsHeuristiquesDansCeFils,essayerMoinsPrecis,false);
                   end;

                 if (noteCourante < -64) or (noteCourante > 64) then
                   begin

                     if ValeurDeFinaleInexploitable(noteCourante) and (noteCourante > 0) then noteCourante := - noteCourante;

                     if OnVientDeStoperExecutionDeCeFils(ESProf,iCourant,numeroArret) then
                       begin
                         {WritelnNumDansRapport('p = '+NumEnString(ESProf)+' : TROUVE LE POINT D''ARRET, numeroArret = ',numeroArret);}
                         RetirerDeLaListeDesTracesExecutionAStopperParNumeroArret(numeroArret);
                       end;

                     {WritelnNumDansRapport('p = '+NumEnString(ESProf)+' : noteCourante = ',noteCourante);}
                   end;

                 tempsEnSecondesPourEvaluerCeFils := (TickCount - tickPourChronometrerTempsPrisDansCeFils) / 60.0;


                 valeurParLeZoo := GetValeurZooDeCeFils(ESProf,iCourant,bestSuiteZoo,tempsZoo);

                 if (valeurParLeZoo <> k_ZOO_NOT_INITIALIZED_VALUE) then
                   begin

                     if (valeurParLeZoo >= -64) and (valeurParLeZoo <= 64)
                       then
                         begin
                           (*
                           WriteNumDansRapport('p = ',ESProf);
                           WriteNumDansRapport(' : le coup '+CoupEnStringEnMajuscules(iCourant)+' a une valeur Zoo de ',valeurParLeZoo);
                           WritelnNumDansRapport(' et une valeur locale de ',noteCourante);
                           WritelnStringAndReelDansRapport('   temps Zoo (sec) = ',tempsZoo,5);
                           WritelnStringAndReelDansRapport('   temps local (sec) = ',tempsEnSecondesPourEvaluerCeFils,5);
                           *)

                           noteCourante := valeurParLeZoo;

                         end
                       else
                         begin
                           if (interruptionReflexion = pasdinterruption) and not(DoitStopperExecutionDeCeSousArbre(ESProf)) then
                             begin
                               RetirerCeFilsDuZoo(ESProf,iCourant);

                               (*
                               if (profMoins1 < profFinaleHeuristique)
                                  then indexMu := IndexOfThisDelta(kDeltaFinaleInfini)
                                  else indexMu := IndexOfThisDelta(deltaFinaleCourant);

                               WriteNumDansRapport('p = ',ESProf);
                               WriteNumDansRapport(' i = ',indexDeBoucle);
                               WriteStringAndCoupDansRapport(' suite = ',pere);
                               WriteStringAndCoupDansRapport(',',icourant);
                               WriteNumDansRapport(' alpha,beta = ',100*alpha);
                               WriteNumDansRapport(',',100*beta);
                               WriteNumDansRapport(' eval = ',evalHeuristiquesDesFils[indexDeBoucle]);
                               WriteNumDansRapport(' mu = ',ThisDeltaFinal(indexMu));
                               WritelnStringAndReelDansRapport('  =>  temps (sec) = ',tempsEnSecondesPourEvaluerCeFils,5);
                               *)
                             end;

                         end;

                   end;



               end;

           NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + NbNoeudsHeuristiquesDansCeFils;
           NbNoeudsHeuristiquesDansTousLesFils := NbNoeudsHeuristiquesDansTousLesFils + NbNoeudsHeuristiquesDansCeFils;
           inc(nbEvalue);
         end;

      tempsEnSecondesPourEvaluerCeFils := (TickCount - tickPourChronometrerTempsPrisDansCeFils) / 60.0;

    end;
end;


procedure EnvoyerDesInfosPourEstimerLaCharge;
begin

   if (tempsEnSecondesPourEvaluerCeFils >= 1.0) and (indexDeBoucle > 1) then
     begin
       WriteNumDansRapport('p = ',ESprof);
       WriteNumDansRapport('  , d = ',NbNoeudsHeuristiquesDansCeFils);
       WriteStringAndBoolDansRapport('  , dev = ',(profMoins1 < profFinaleHeuristique) or (deltaFinaleCourant = kDeltaFinaleInfini));
       WriteNumDansRapport('  , µ = ',deltaFinaleCourant);
       WriteNumDansRapport('  , h = ',profFinaleHeuristique);
       WriteNumDansRapport('  , profhash = ',ProfPourHashExacte);
       WriteNumDansRapport('  , alpha = ',alphaInitial);
       WriteNumDansRapport('  , beta = ',betaInitial);
       WriteNumDansRapport('  , note = ',noteCourante);
       WriteNumDansRapport('  , est = ',evaluationDeLaPosition);
       WritelnStringAndReelDansRapport('  , i = '+NumEnString(indexDeBoucle)+' ,  t = ',tempsEnSecondesPourEvaluerCeFils,8);
     end;

   if (profMoins1 < profFinaleHeuristique)
     then indexMu := IndexOfThisDelta(kDeltaFinaleInfini)
     else indexMu := IndexOfThisDelta(deltaFinaleCourant);

   AjouterDataEstimationCharge(ESProf,indexDeBoucle,nbCoupsEnvisages,indexMu,alphaInitial,betaInitial,evaluationDeLaPosition*0.01,tempsEnSecondesPourEvaluerCeFils * 60.0)
end;



procedure EssayerDeParalliserCesFilsSurLeZoo(numPremierFils,numDernierFils : SInt32; dilatation : TypeReel);
var i, foo : SInt32;
    tempsEstimeDeCeFils : TypeReel;  {en secondes}
    nbFilsEnvoyesAuZoo : SInt32;
    fooDouble : double;
    InfosMilieuFils : InfosMilieuRec;
    platFils : plateauOthello;
    nbEvalRecursives : SInt32;
    evalApresCeFils : SInt32;
begin

  with liaisonArbreZoo do
    begin

      if (interruptionReflexion <> pasdinterruption) then
        exit(EssayerDeParalliserCesFilsSurLeZoo);

      if not(CassioUtiliseLeZoo) then
        exit(EssayerDeParalliserCesFilsSurLeZoo);

      if (ESProf < profMinUtilisationZoo ) or
         (ESProf > profMaxUtilisationZoo ) then
        begin
          WritelnNumDansRapport('ASSERT : prof out of bounds dans EssayerDeParalliserCesFilsSurLeZoo,  ESprof = ',ESprof);
          exit(EssayerDeParalliserCesFilsSurLeZoo);
        end;

      // pas de parallelisme recursif sur le zoo pour le moment
      if CassioEstEnTrainDeCalculerPourLeZoo then
        exit(EssayerDeParalliserCesFilsSurLeZoo);


      with InfosMilieuDePartie do
  	    if evaluationDeLaPosition = kEvaluationNonFaite
  	      then evaluationDeLaPosition := Evaluation(plat,couleur,nbBlancs,nbNoirs,jouable,frontiere,false,-30000,30000,evalsRec);

      if (profMoins1 < profFinaleHeuristique)
         then indexMu := IndexOfThisDelta(kDeltaFinaleInfini)
         else indexMu := IndexOfThisDelta(deltaFinaleCourant);

      if indexMu <= 2 then exit(EssayerDeParalliserCesFilsSurLeZoo);

      (*
      WritelnDansRapport('');
      WritelnDansRapport('Je parallelise les fils de cette position : ');
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WritelnStringAndReelDansRapport('dilatation = ',dilatation,5);
      WritelnDansRapport('');
      *)

      nbFilsEnvoyesAuZoo := 0;

      for i := 1 to nbCoupsEnvisages do
        if (i >= numPremierFils) and (i <= numDernierFils) and
           (GetValeurZooDeCeFils(ESProf,listeFinale[i],foo,fooDouble) = k_ZOO_NOT_INITIALIZED_VALUE) then
          begin

            tempsEstimeDeCeFils := TempsEstimeEnSecondesPourResoudreCettePosition(ESProf,i,nbCoupsEnvisages,indexMu,alpha,beta,0.01*evaluationDeLaPosition);


            if (indexMu <> IndexOfThisDelta(kDeltaFinaleInfini)) then
              begin
                platFils := plat;
                InfosMilieuFils := InfosMilieuDePartie;
                with InfosMilieuFils do
      	           begin
      	             //WritelnNumDansRapport('EssayerDeParalliserCesFilsSurLeZoo, coup = ',listeFinale[i]);
      	             coupLegal := ModifPlatLongint(listeFinale[i],couleur,platFils,jouable,nbBlancs,nbNoirs,frontiere);
      	             evalApresCeFils := -Evaluation(platFils,-couleur,nbBlancs,nbNoirs,jouable,frontiere,false,-30000,30000,nbEvalRecursives);

      	             evalHeuristiquesDesFils[i] := evalApresCeFils;
        	         end;

        	      if (indexMu <> IndexOfThisDelta(kDeltaFinaleInfini)) then
        	        if (evalApresCeFils <= 100*alpha - ThisDeltaFinal(indexMu) - liaisonArbreZoo.margePourParallelismeHeuristique) or
        	           (evalApresCeFils >= 100*beta  + ThisDeltaFinal(indexMu) + liaisonArbreZoo.margePourParallelismeHeuristique)
        	          then tempsEstimeDeCeFils := tempsEstimeDeCeFils / 10.0;

        	      (*
        	      WriteNumDansRapport('p = ',ESProf);
        	      WriteNumDansRapport(' i = ',i);
                WriteStringAndCoupDansRapport(' suite = ',pere);
                WriteStringAndCoupDansRapport(',',listeFinale[i]);
                WriteNumDansRapport(' alpha,beta = ',100*alpha);
                WriteNumDansRapport(',',100*beta);
                WriteNumDansRapport(' eval = ',evalHeuristiquesDesFils[i]);
                WriteNumDansRapport(' mu = ',ThisDeltaFinal(indexMu));
                WriteStringAndReelDansRapport(' facteur = ',dilatation,4);
                WriteStringAndReelDansRapport('  =>  tempsEstime1 = ',tempsEstimeDeCeFils,5);
        	      WriteStringAndReelDansRapport(', tempsEstime2 = ',tempsEstimeDeCeFils,5);
        	      WritelnStringAndReelDansRapport(', tempsEstime3 = ',dilatation * tempsEstimeDeCeFils,5);
        	      *)

  	          end;



            { on envoie les fils au zoo a condition que l'estimation de leur temps de resolution soit assez long }

            if (tempsEstimeDeCeFils * dilatation >= tempsMinimalPourEnvoyerAuZoo ) and
               (tempsEstimeDeCeFils              <= tempsMaximalPourEnvoyerAuZoo ) and
               (GetValeurZooDeCeFils(ESProf,listeFinale[i],foo,fooDouble) = k_ZOO_NOT_INITIALIZED_VALUE)
              then
                begin
                  EnvoyerCeFilsAuZoo(ESProf,listeFinale[i],alpha,beta,ThisDeltaFinal(indexMu));

                  inc(nbFilsEnvoyesAuZoo);

                end;

          end;

      if nbFilsEnvoyesAuZoo > 0 then
        inc(gNombreDeCoupuresAlphaPresquesSures);

    end;
end;


procedure InitialiserInfosPourLeZooDeCeNoeud;
begin

  with liaisonArbreZoo do
    begin

      if (ESProf < profMinUtilisationZoo ) or
         (ESProf > profMaxUtilisationZoo ) then
        exit(InitialiserInfosPourLeZooDeCeNoeud);


      { on copie les coups de cette prof }

      CopierListeDesCoupsPourLeZoo(ESProf,nbCoupsEnvisages,couleur,gClefHashage,listeFinale,plat,alpha,beta);

      { pour l'instant on n'a parallelise aucun fils a ce noeud }

      infosNoeuds[ESProf].nbCoupsEnvoyesAuZoo := 0;


      { on parallelise eventuellement la recherche }

      if (ESprof >= profMinimalePourClassementParMilieu) and (nbCoupsEnvisages >= 2) then
        begin

          { On va essayer de deviner si cette position est un noeud alpha qui pourra etre parallelise... }

          with InfosMilieuDePartie do
      	    if evaluationDeLaPosition = kEvaluationNonFaite
      	      then evaluationDeLaPosition := Evaluation(plat,couleur,nbBlancs,nbNoirs,jouable,frontiere,false,-30000,30000,evalsRec);

          if (profMoins1 < profFinaleHeuristique)
             then indexMu := IndexOfThisDelta(kDeltaFinaleInfini)
             else indexMu := IndexOfThisDelta(deltaFinaleCourant);

          if (evaluationDeLaPosition < 100*alpha - margePourParallelismeAlphaSpeculatif)
            then
              begin
                {WritelnDansRapport('demande de parallelisme');}

                EssayerDeParalliserCesFilsSurLeZoo(2, nbCoupsEnvisages, 1.0);

              end;

        end;

    end;
end;







procedure VerifierLeParallelismeDuZoo;
var foo : SInt32;
    facteur : TypeReel;
    fooDouble : double;
begin
  with liaisonArbreZoo do
    begin

      if (ESProf < profMinUtilisationZoo ) or
         (ESProf > profMaxUtilisationZoo ) or
         (interruptionReflexion <> pasdinterruption) or
         DoitStopperExecutionDeCeSousArbre(ESProf) then
        exit(VerifierLeParallelismeDuZoo);

      if (noteCourante >= -64) and (noteCourante < beta) then
         begin


           { if (indexDeBoucle > 1) and (tempsEnSecondesPourEvaluerCeFils >= 0.15) then EnvoyerDesInfosPourEstimerLaCharge; }

           if (indexDeBoucle = 1) and
              (tempsEnSecondesPourEvaluerCeFils >= tempsMinimalPourEnvoyerAuZoo) and
              (tempsEnSecondesPourEvaluerCeFils <= tempsMaximalPourEnvoyerAuZoo) and
              (alpha > -64) {and
              (GetNombreDeFilsParallelisesPourCetteProf(ESProf) <= 0)}
             then
               begin

                 inc(gNombreDeParallelisationVerifiees);
                 inc(gNombreDeParallelisationEnRetard);

                 {facteur de dilation pour mieux estimer le temps des autres fils}
                 facteur := tempsEnSecondesPourEvaluerCeFils / TempsEstimeEnSecondesPourResoudreCettePosition(ESProf,1,nbCoupsEnvisages,indexMu,alpha,beta,0.01*evaluationDeLaPosition);


                 { on va s'occuper nous-meme du deuxieme coup de la liste (snif!), mais on peut
                   quand meme demander au zoo de nous aider pour les coups 3 et suivants... }

                 if (NombreDeResultatsEnAttenteSurLeZoo <= occupationPourParallelismeAlpha2)
                   then EssayerDeParalliserCesFilsSurLeZoo(3,nbCoupsEnvisages,facteur);
               end;

           if (indexDeBoucle >= 2) and
              (tempsEnSecondesPourEvaluerCeFils >= tempsMinimalPourEnvoyerAuZoo) and
              (tempsEnSecondesPourEvaluerCeFils <= tempsMaximalPourEnvoyerAuZoo) and
              (alpha > -64) then
              begin


                if GetValeurZooDeCeFils(ESProf,iCourant,foo,fooDouble) = k_ZOO_EN_ATTENTE_DE_RESULTAT
                  then
                    begin
                      inc(gNombreDeParallelisationVerifiees);
                      inc(gNombreDeCoupuresAlphaReussies);
                    end
                  else
                    begin

                      inc(gNombreDeParallelisationVerifiees);
                      inc(gNombreDeParallelisationEnRetard);


                      {facteur de dilation pour mieux estimer le temps des autres fils}
                      facteur := tempsEnSecondesPourEvaluerCeFils / TempsEstimeEnSecondesPourResoudreCettePosition(ESProf,indexDeBoucle,nbCoupsEnvisages,indexMu,alpha,beta,0.01*evaluationDeLaPosition);


                      { on va s'occuper nous-meme du coup suivant de la liste (snif!), mais on peut
                        quand meme demander au zoo de nous aider pour les coups encore apres... }

                      if (NombreDeResultatsEnAttenteSurLeZoo <= occupationPourParallelismeAlpha2)
                        then EssayerDeParalliserCesFilsSurLeZoo(indexDeBoucle + 2, nbCoupsEnvisages, facteur);

                    end;
              end;

            (*
            if (tempsEnSecondesPourEvaluerCeFils >= tempsMinimalPourEnvoyerAuZoo) and
               (tempsEnSecondesPourEvaluerCeFils <= tempsMaximalPourEnvoyerAuZoo) and
               (ESProf >= 28) and
               (gNombreDeParallelisationVerifiees > 0) then
              begin

                WritelnDansRapport('');
                WritelnNumDansRapport('gNombreDeParallelisationVerifiees = ',gNombreDeParallelisationVerifiees);

                if gNombreDeCoupuresAlphaReussies > 0 then
                  WritelnStringAndReelDansRapport('ratio d''alpha-parallelisme reussi = ',100.0*gNombreDeCoupuresAlphaReussies/gNombreDeParallelisationVerifiees,4);

                if gNombreDeParallelisationEnRetard > 0 then
                  WritelnStringAndReelDansRapport('ratio d''alpha-parallelisme en retard = ',100.0*gNombreDeParallelisationEnRetard/gNombreDeParallelisationVerifiees,4);

                if (gNombreDeMauvaisesParallelisation > 0) then
                  WritelnStringAndReelDansRapport('ratio de mauvais alpha-parallelisme = ',100.0*gNombreDeMauvaisesParallelisation/gNombreDeParallelisationVerifiees,4);
              end;
            *)

         end

      else

       if (noteCourante >= beta) then

         begin

           if (indexDeBoucle = 1) and
              (GetNombreDeFilsParallelisesPourCetteProf(ESProf) > 0)  then
             begin
               inc(gNombreDeParallelisationVerifiees);
               inc(gNombreDeMauvaisesParallelisation);

               (*
               WritelnDansRapport('');
               WritelnNumDansRapport('gNombreDeParallelisationVerifiees = ',gNombreDeParallelisationVerifiees);

               if gNombreDeCoupuresAlphaReussies > 0 then
                 WritelnStringAndReelDansRapport('ratio d''alpha-parallelisme reussi = ',100.0*gNombreDeCoupuresAlphaReussies/gNombreDeParallelisationVerifiees,4);

               if gNombreDeParallelisationEnRetard > 0 then
                 WritelnStringAndReelDansRapport('ratio d''alpha-parallelisme en retard = ',100.0*gNombreDeParallelisationEnRetard/gNombreDeParallelisationVerifiees,4);

               if (gNombreDeMauvaisesParallelisation > 0) and (gNombreDeParallelisationVerifiees > 0) then
                 WritelnStringAndReelDansRapport('ratio de mauvais alpha-parallelisme = ',100.0*gNombreDeMauvaisesParallelisation/gNombreDeParallelisationVerifiees,4);
               *)

             end;

           if (indexDeBoucle = 2) and
              (GetNombreDeFilsParallelisesPourCetteProf(ESProf) > 0) and
              (GetValeurZooDeCeFils(ESProf,iCourant,foo,fooDouble) = k_ZOO_EN_ATTENTE_DE_RESULTAT)
             then
             begin
               inc(gNombreDeParallelisationVerifiees);
               inc(gNombreDeCoupuresAlphaReussies);

               (*
               WritelnDansRapport('');
               WritelnNumDansRapport('gNombreDeParallelisationVerifiees = ',gNombreDeParallelisationVerifiees);

               if gNombreDeCoupuresAlphaReussies > 0 then
                 WritelnStringAndReelDansRapport('ratio d''alpha-parallelisme reussi = ',100.0*gNombreDeCoupuresAlphaReussies/gNombreDeParallelisationVerifiees,4);

               if gNombreDeParallelisationEnRetard > 0 then
                 WritelnStringAndReelDansRapport('ratio d''alpha-parallelisme en retard = ',100.0*gNombreDeParallelisationEnRetard/gNombreDeParallelisationVerifiees,4);

               if (gNombreDeMauvaisesParallelisation > 0) and (gNombreDeParallelisationVerifiees > 0) then
                 WritelnStringAndReelDansRapport('ratio de mauvais alpha-parallelisme = ',100.0*gNombreDeMauvaisesParallelisation/gNombreDeParallelisationVerifiees,4);
               *)
             end;

         end;


   end;
end;



procedure CleanUpPourQuitterABFin;
begin
  EffacerTraceExecutionFinale(ESProf);
  if ESprof >= ProfUtilisationHash then
    gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
end;



begin  {ABFin}
  with contexteMakeEndgameSearch do
    begin

      {$IFC USE_DEBUG_STEP_BY_STEP}
      if gDebuggageAlgoFinaleStepByStep.actif and
    	   (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
    		 MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
    	  begin
    		  WritelnDansRapport('');
    		  WriteStringDansRapport('entrée dans ABFin, interruption = ');
    		  EcritTypeInterruptionDansRapport(interruptionReflexion);
    		  {WritelnNumDansRapport('dans ABFin, TickCount-dernierTick = ',TickCount-dernierTick);
    		  WritelnNumDansRapport('dans ABFin, nbreNoeudsGeneresFinale = ',nbreNoeudsGeneresFinale);
    		  WritelnNumDansRapport('dans ABFin, ProfUtilisationHash = ',ProfUtilisationHash);
    		  WritelnNumDansRapport('dans ABFin, ProfPourHashExacte = ',ProfPourHashExacte);}
    		  WritelnDansRapport('dans ABFin, plat = ');
    		  WritelnPositionEtTraitDansRapport(plat,couleur);
    		  {WritelnStringAndCoupDansRapport('dans ABFin, meiDef = ',meiDef);}
    		  WritelnStringAndCoupDansRapport('dans ABFin, pere = ',pere);
    		  {WritelnNumDansRapport('dans ABFin, couleur = ',couleur);}
    		  WritelnNumDansRapport('dans ABFin, ESprof = ',ESprof);
    		  WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
    		  WritelnNumDansRapport('dans ABFin, alpha = ',alpha);
    		  WritelnNumDansRapport('dans ABFin, beta = ',beta);
    		  {WritelnNumDansRapport('dans ABFin, diffPions = ',diffPions);
    		  WritelnNumDansRapport('dans ABFin, IndiceHashTableExacteRetour = ',IndiceHashTableExacteRetour);
    		  WritelnStringAndBoolDansRapport('dans ABFin, vientDePasser = ',vientDePasser);}
    		  WritelnNumDansRapport('dans ABFin, NbNoeudsCoupesParHeuristique = ',NbNoeudsCoupesParHeuristique);
    		  WritelnStringAndBoolDansRapport('dans ABFin, essayerMoinsPrecis = ',essayerMoinsPrecis);
    		  WritelnStringAndBoolDansRapport('dans ABFin, seulementChercherDansHash = ',seulementChercherDansHash);
    		  WritelnDansRapport('');
        end;
     {$ENDC}

     if (interruptionReflexion <> pasdinterruption) then
       begin
         ABFin := -noteMax;
         exit(ABFin);
       end;


     ReconstruireLaTableListeBitboardToSquareSiNecessaire(ESProf,@gTeteListeChaineeCasesVides);

     VerifierLePoussageDesRequetesAuZoo;

     if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
     ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);


     if DoitStopperExecutionDeCeSousArbre(ESProf) then
       begin
         ABFin := -noteMax;
         exit(ABFin);
       end;


     if ESprof >= ProfUtilisationHash then
       gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));



     {$IFC USE_DEBUG_HASH_VALUES}
     if (ESprof >= gNbreVides_entreeCoupGagnant-1) then
       begin
         if not(MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),hashStockeeDansSet,positionsDejaAffichees))
  		     then
  		       begin
  		         WritelnDansRapport('');
  		         WritelnDansRapport('Ajout de la position suivante : ');
  		         WritelnPositionEtTraitDansRapport(plat,couleur);
  		         WritelnNumDansRapport('gClefHashage = ',gClefHashage);
  		         WritelnNumDansRapport('hachage(position) = ',GenericHash(@plat,sizeof(plat)));
  		         AddPositionEtTraitToSet(MakePositionEtTrait(plat,couleur),gClefHashage,positionsDejaAffichees);
  		       end
  		     else
  		       begin
  		         if (hashStockeeDansSet <> gClefHashage) then
  		           begin
  		             SysBeep(0);
  		             WritelnDansRapport('');
  		             WritelnDansRapport('ERREUR : mismatch de hashStockeeDansSet et gClefHashage : ');
  		             WritelnPositionEtTraitDansRapport(plat,couleur);
  		             WritelnNumDansRapport('gClefHashage = ',gClefHashage);
  		             WritelnNumDansRapport('hashStockeeDansSet = ',hashStockeeDansSet);
  		           end;
  		       end
  		 end;
  	{$ENDC}

  entree_ABFin :



     meiDef := 0;
     meiDefenseSansHeuristique := 0;
     conseilHash := 0;
     listeFinaleFromScratch := true;
     switchToBitboardAlphaBeta := false;
     evaluationDeLaPosition := kEvaluationNonFaite;
     estPresqueSurementUneCoupureBeta  := false;
     estPresqueSurementUneCoupureAlpha := false;
     maxPourBestDef := -noteMax;
     ordreDuMeilleur := -1;
     IDUniqueDeCeNoeud := nbreNoeudsGeneresFinale;
     if seulementChercherDansHash then ABFin := kNoteBidonPositionNonTrouveeDansHash;

     if (ESprof >= liaisonArbreZoo.profMinUtilisationZoo) and
        (ESprof <= liaisonArbreZoo.profMaxUtilisationZoo)
        then utiliseMilieuDePartie :=  ESprof >= profMinimalePourClassementParMilieu
        else utiliseMilieuDePartie := (ESprof >= profMinimalePourClassementParMilieu)
                                       {and (alpha < 40) and (beta > -40)}
                                       and (alpha < 60) and (beta > -60);

     NbNoeudsHeuristiquesDansTousLesFils := 0;
     adversaire := -couleur;
     profMoins1 := pred(ESprof);


     alphaInitial := alpha;
     betaInitial := beta;
     NbNoeudsHeuristiquesPourAjusterAlpha := 0;
     NbNoeudsHeuristiquesPourAjusterBeta  := 0;

     valeurExacteMax := noteMax;
     valeurExacteMin := -noteMax;
     if ESprof >= ProfUtilisationHash
       then
         begin
           if ESprof >= profondeurRemplissageHash
             then
               begin
                 clefHashConseil := BAND(gClefHashage,32767);
                 conseilHash := HashTable^^[clefHashConseil];
               end
             else conseilHash := 0;

           if ESprof >= ProfPourHashExacte then
             begin

               nroTableExacte := BAND(gClefHashage div 1024,nbTablesHashExactesMoins1);
               clefHashExacte := BAND(gClefHashage,1023);

               {WritelnNumDansRapport('clefHashExacte (1) = ',clefHashExacte);}

               quelleHashTableExacte := HashTableExacte[nroTableExacte];
               quelleHashTableCoupsLegaux := CoupsLegauxHash[nroTableExacte];

               {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
  	           Microseconds(microSecondesDepartInfos);
  	           {$ENDC}

               CreeCodagePosition(plat,couleur,ESprof,codagePosition);


               {WritelnCodagePositionDansRapport(codagePosition);
               WritelnDansRapport('appel de InfoTrouveeDansHashTableExacte…');}

               dansHashExacte := InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,gClefHashage,clefHashExacte);

               {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
  	           Microseconds(microSecondesCurrentInfos);
  	           AjouterTempsDansMiniProfiler(0,-3,microSecondesCurrentInfos.lo-microSecondesDepartInfos.lo,kpourcentage);
  	           {$ENDC}

               if dansHashExacte
                 then
                   begin

                     {WritelnDansRapport('InfoTrouveeDansHashTableExacte : OK');}

                     DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                     meiDef := GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]);
                     meiDefenseSansHeuristique := bornes.coupDeCetteValMin[nbreDeltaSuccessifs];

                     {$IFC USE_DEBUG_STEP_BY_STEP}
                     if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                        begin
                          WritelnDansRapport('');
                          WritelnDansRapport('Dans hash exacte :');
                          WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                          WritelnStringAndCoupDansRapport('meiDefenseSansHeuristique = ',meiDefenseSansHeuristique);
                          WritelnDansRapport('');
                        end;
                     {$ENDC}

                     {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
                     CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                     {$ENDC}

                     with bornes do
                     if (nbArbresCoupesValMin[nbreDeltaSuccessifs] = 0) and
                        (valMin[nbreDeltaSuccessifs] = valMax[nbreDeltaSuccessifs]) and
  		                  (coupDeCetteValMin[nbreDeltaSuccessifs] <> 0) and (coupDeCetteValMin[nbreDeltaSuccessifs] <> meiDef) then
                       begin
                         Sysbeep(0);
                         WritelnDansRapport('');
                         WritelnDansRapport('Vous avez probablement trouvé un bug : ');
                         WritelnDansRapport('Ne faudrait-il pas changer meiDef parce que l''on connait le meilleur coup ?');
                         WritelnPositionEtTraitDansRapport(plat,couleur);
                         WritelnNumDansRapport('valMin['+NumEnString(ThisDeltaFinal(nbreDeltaSuccessifs))+'] = ',valMin[nbreDeltaSuccessifs]);
                         WritelnNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(nbreDeltaSuccessifs))+'] = ',valMax[nbreDeltaSuccessifs]);
                         WritelnStringAndCoupDansRapport('coupDeCetteValMin[nbreDeltaSuccessifs] = ',coupDeCetteValMin[nbreDeltaSuccessifs]);
                         WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                         WritelnDansRapport('');
                       end;

                     with bornes do
                     for k := nbreDeltaSuccessifs downto indexDeltaFinaleCourant do
                       begin

                          {$IFC USE_DEBUG_STEP_BY_STEP}
                          if gDebuggageAlgoFinaleStepByStep.actif and
                             (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
  					                 MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                            begin
                              WritelnNumDansRapport('valMin['+NumEnString(ThisDeltaFinal(k))+'] = ',valMin[k]);
                              WritelnNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(k))+'] = ',valMax[k]);
                              WritelnStringAndCoupDansRapport('coupDeCetteValMin['+NumEnString(ThisDeltaFinal(k))+'] = ',coupDeCetteValMin[k]);
                              WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                            end;
                          {$ENDC}

                         {Ajustement de la fenetre alpha-beta}
                         if (valMin[k] > alpha) then
                           begin
  	                         if bestMode and (deltaFinaleCourant = kDeltaFinaleInfini)
  		                         then alpha := pred(valMin[k])
  		                         else alpha := valMin[k];
  		                       NbNoeudsHeuristiquesPourAjusterAlpha := NbNoeudsHeuristiquesPourAjusterAlpha + nbArbresCoupesValMin[k];

  		                       if false and (nbArbresCoupesValMin[k] = 0) and (k = nbreDeltaSuccessifs) and
  		                          (coupDeCetteValMin[k] <> 0) and (coupDeCetteValMin[k] <> meiDef) then
  		                           begin
  		                             Sysbeep(0);
  		                             WritelnDansRapport('');
  		                             WritelnDansRapport('Ne faudrait-il pas changer meiDef en meme temps que alpha ?');
  		                             WritelnPositionEtTraitDansRapport(plat,couleur);
  		                             WritelnNumDansRapport('valMin['+NumEnString(ThisDeltaFinal(k))+'] = ',valMin[k]);
                                   WritelnNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(k))+'] = ',valMax[k]);
                                   WritelnStringAndCoupDansRapport('coupDeCetteValMin[k] = ',coupDeCetteValMin[k]);
                                   WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
  		                           end;

  		                       {$IFC USE_DEBUG_STEP_BY_STEP}
  		                       if gDebuggageAlgoFinaleStepByStep.actif and
  			                        (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
  			                        ((alpha <> alphaInitial) or (beta <> betaInitial)) and
  							                MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
  			                       begin
  			                         WritelnDansRapport('');
  			                         WritelnDansRapport('ajustement de la fenetre alpha-beta : ');
  			                         WritelnNumDansRapport('alphaInitial = ',alphaInitial);
  			                         WritelnNumDansRapport('betaInitial = ',betaInitial);
  			                         WritelnNumDansRapport('alpha = ',alpha);
  			                         WritelnNumDansRapport('beta = ',beta);
  			                         WritelnNumDansRapport('NbNoeudsHeuristiquesPourAjusterAlpha = ',NbNoeudsHeuristiquesPourAjusterAlpha);
  			                       end;
  		                       {$ENDC}

  	                       end;

  	                     if (valMax[k] < beta) then
                           begin
                             if bestMode and (deltaFinaleCourant = kDeltaFinaleInfini)
                               then beta := succ(valMax[k])
                               else beta := valMax[k];
                             NbNoeudsHeuristiquesPourAjusterBeta := NbNoeudsHeuristiquesPourAjusterBeta + nbArbresCoupesValMax[k];

                             {$IFC USE_DEBUG_STEP_BY_STEP}
                             if gDebuggageAlgoFinaleStepByStep.actif and
  			                        (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
  			                        ((alpha <> alphaInitial) or (beta <> betaInitial)) and
  							                MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
  			                       begin
  			                         WritelnDansRapport('');
  			                         WritelnDansRapport('ajustement de la fenetre alpha-beta : ');
  			                         WritelnNumDansRapport('alphaInitial = ',alphaInitial);
  			                         WritelnNumDansRapport('betaInitial = ',betaInitial);
  			                         WritelnNumDansRapport('alpha = ',alpha);
  			                         WritelnNumDansRapport('beta = ',beta);
  			                         WritelnNumDansRapport('NbNoeudsHeuristiquesPourAjusterBeta = ',NbNoeudsHeuristiquesPourAjusterBeta);
  			                         WritelnDansRapport('');
  			                       end;
  			                     {$ENDC}

                           end;


                         {
                         if (ValMin[k] > valMax[k]) and (deltaFinaleCourant = kDeltaFinaleInfini)
                            and (interruptionReflexion = pasdinterruption)  then
                           begin
                             SysBeep(0);
                             WritelnDansRapport('ERROR dans les tests initiaux : (ValeurMin > ValeurMax) and ValeurMinEstAcceptable and ValeurMaxEstAcceptable');
                             WritelnNumDansRapport('gClefHashage = ',gClefHashage);
  	                         WritelnNumDansRapport('ValMin['+NumEnString(ThisDeltaFinal(k))+'] = ',ValMin[k]);
                             WritelnNumDansRapport('valMax['+NumEnString(ThisDeltaFinal(k))+'] = ',valMax[k]);
                             WritelnNumDansRapport('ESprof = ',ESprof);
                             WritelnPositionEtTraitDansRapport(plat,couleur);
                             WritelnDansRapport('');
                           end;
                         }

                         {coupures dues aux valeurs stockees dans la table par interversion ?}
                         if (valMin[k] >= valMax[k])
                           then
                             begin

                               {$IFC USE_DEBUG_STEP_BY_STEP}
                               if gDebuggageAlgoFinaleStepByStep.actif and
  	                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
  	                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
  	                              begin
  	                                WritelnDansRapport('');
  			                            WritelnDansRapport('dans ABFin, on a (valMin[k] >= valMax[k]) :');
  			                            WritelnNumDansRapport('valMin[k] = ',valMin[k]);
  			                            WritelnNumDansRapport('valMax[k] = ',valMax[k]);
                                    WritelnStringAndCoupDansRapport('coupDeCetteValMin[k] = ',coupDeCetteValMin[k]);
                                    WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
  			                            WritelnDansRapport('');
  			                          end;
  			                       {$ENDC}



                               if bestMode and
                                  (alpha <= valMax[k]) and
                                  (valMin[k] <= beta) and
                                  (deltaFinaleCourant = kDeltaFinaleInfini)
                                 then
                                   begin

                                     if (meiDef <> 0) and (meidef = coupDeCetteValMin[k]) then
                                       begin
  		                                   {on connait le score, mais on ne sort pas tout de suite
  		                                    de la fonction, on se contente de dire qu'il n'y a qu'un
  		                                    coup legal : cela permet de ramener la suite complete}
  		                                   ABFin := valMin[k];
  		                                   quelleHashTableCoupsLegaux^[clefHashExacte,0] := 1;
  		                                   quelleHashTableCoupsLegaux^[clefHashExacte,1] := meiDef;
  		                                   NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];
  		                                   NbNoeudsHeuristiquesDansTousLesFils := NbNoeudsHeuristiquesDansTousLesFils + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];
  		                                 end;

                                     {$IFC USE_DEBUG_STEP_BY_STEP}
                                     if (meiDef <> 0) and (meidef = coupDeCetteValMin[k]) and
                                         gDebuggageAlgoFinaleStepByStep.actif and
  				                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
  				                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
  				                              begin
  				                                WritelnDansRapport('');
  						                            WritelnDansRapport('(valMin[k] = valMax[k]) and (meiDef <> 0), donc je mets un seul coup legal dans ABFin :');
  						                            WritelnPositionEtTraitDansRapport(plat,couleur);
  						                            WritelnNumDansRapport('ESProf = ',ESProf);
  						                            WritelnNumDansRapport('alpha = ',alpha);
  						                            WritelnNumDansRapport('beta = ',beta);
  						                            WritelnNumDansRapport('valMin[k] = ',valMin[k]);
  						                            WritelnNumDansRapport('valMax[k] = ',valMax[k]);
  						                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
  						                            WritelnDansRapport('');
  						                          end;
  						                       {$ENDC}

                                     if (k = nbreDeltaSuccessifs) and    // 100%
                                        (coupDeCetteValMin[k] = 0) and
                                        (alphaInitial = betaInitial - 1) and
                                        (valMin[k] >= betaInitial) and
                                        odd(alphaInitial) and
                                        (alphaInitial < 63) and
                                        bestMode then
                                       begin
                                         // WritelnDansRapport('BINGO cas 3');
                                         ABFin := valMin[k];
                                         gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
                                         IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;
                                         NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];
                                         exit(ABFin);
                                       end;


                                   end
                                 else
                                   begin
                                     ABFin := valMin[k];
                                     if ESprof >= profondeurRemplissageHash then
                                       HashTable^^[clefHashConseil] := meiDef;
                                     meilleureSuite[ESprof,ESprof] := meiDef;

                                     gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
                                     IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;
                                     NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMin[k] + nbArbresCoupesValMax[k];

                                     {$IFC USE_DEBUG_STEP_BY_STEP}
                                     if gDebuggageAlgoFinaleStepByStep.actif and
  				                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
  				                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
  				                              begin
  				                                WritelnDansRapport('');
  						                            WritelnDansRapport('sortie par (valMin[k] >= valMax[k]) dans ABFin :');
  						                            WritelnPositionEtTraitDansRapport(plat,couleur);
  						                            WritelnNumDansRapport('ESProf = ',ESProf);
  						                            WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
  						                            WritelnNumDansRapport('alpha = ',alpha);
  						                            WritelnNumDansRapport('beta = ',beta);
  						                            WritelnNumDansRapport('valMin[k] = ',valMin[k]);
  						                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
  						                            WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
  						                            WritelnDansRapport('');
  						                          end;
                                     {$ENDC}

                                     exit(ABFin);
                                   end;
                             end
                           else
                             begin
                               if (valMin[k] >= beta) then
                                 begin
                                   ABFin := valMin[k];
                                   if ESprof >= profondeurRemplissageHash then
                                     HashTable^^[clefHashConseil] := meiDef;
                                   meilleureSuite[ESprof,ESprof] := meiDef;

                                   gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
                                   IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;
                                   NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMin[k];

                                   {$IFC USE_DEBUG_STEP_BY_STEP}
                                   if gDebuggageAlgoFinaleStepByStep.actif and
  				                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
  				                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
  				                              begin
  				                                WritelnDansRapport('');
  						                            WritelnDansRapport('sortie par (valMin[k] >= beta) dans ABFin :');
  						                            WritelnPositionEtTraitDansRapport(plat,couleur);
  						                            WritelnNumDansRapport('ESProf = ',ESProf);
  						                            WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
  						                            WritelnNumDansRapport('alpha = ',alpha);
  						                            WritelnNumDansRapport('beta = ',beta);
  						                            WritelnNumDansRapport('valMin[k] = ',valMin[k]);
  						                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
  						                            WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
  						                            WritelnDansRapport('');
  						                          end;
  						                      {$ENDC}

                                   exit(ABFin);
                                 end;

                               if (valMax[k] <= alpha) then
                                 begin
                                   ABFin := valMax[k];
                                   if ESprof >= profondeurRemplissageHash then
                                     HashTable^^[clefHashConseil] := meiDef;
                                   meilleureSuite[ESprof,ESprof] := meiDef;
                                   gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
                                   IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;
                                   NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + nbArbresCoupesValMax[k];

                                   {$IFC USE_DEBUG_STEP_BY_STEP}
                                   if gDebuggageAlgoFinaleStepByStep.actif and
  				                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
  				                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
  				                              begin
  				                                WritelnDansRapport('');
  						                            WritelnDansRapport('sortie par (valMax[k] <= alpha) dans ABFin :');
  						                            WritelnPositionEtTraitDansRapport(plat,couleur);
  						                            WritelnNumDansRapport('ESProf = ',ESProf);
  						                            WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
  						                            WritelnNumDansRapport('alpha = ',alpha);
  						                            WritelnNumDansRapport('beta = ',beta);
  						                            WritelnNumDansRapport('valMax[k] = ',valMax[k]);
  						                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
  						                            WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
  						                            WritelnDansRapport('');
  						                          end;
  						                     {$ENDC}

                                   exit(ABFin);
                                 end;
                             end;
                       end;

  		               listeFinaleFromScratch := PasListeFinaleStockeeDansHash(ESprof,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale,nbCoupsPourCoul);
                   end
                 else
                   begin
                     ExpandHashTableExacte(quelleHashTableExacte^[clefHashExacte],quelleHashTableCoupsLegaux,codagePosition,clefHashExacte);

  		               DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);

  		               {if essayerMoinsPrecis and (ESprof > profFinaleHeuristique - 1) and utiliseMilieuDePartie then
  		                 begin
  		                   EssaieApproximationsMoinsPrecises;
  		                   DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
  		                 end;
  		               }
  		               {if essayerMoinsPrecis and (ESprof = profFinaleHeuristique - 2) and utiliseMilieuDePartie then
                       begin
                         EssaieApproximationsHeuristiquesSecondNiveau;
                         DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                       end;
  		               }
                   end;

               valeurExacteMin := bornes.valMin[indexDeltaFinaleCourant];
               valeurExacteMax := bornes.valMax[indexDeltaFinaleCourant];

               {$IFC USE_DEBUG_STEP_BY_STEP}
               if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                 begin
                   WritelnDansRapport('');
                   WritelnNumDansRapport('affectation (1) valeurExacteMin := ',valeurExacteMin);
                   WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                   WritelnNumDansRapport('et d''ailleurs, bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] = ',bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant]);
                   WritelnBornesDansRapport(bornes);
                   WritelnDansRapport('');
                 end;
               {$ENDC}


               IndiceHashTableExacteRetour := clefHashExacte+1024*nroTableExacte;


               // pour Cassio's eval
               (*
               if (ESprof >= profFinaleHeuristique - 1) and (ESprof <= profFinaleHeuristique + 1)
                 then EssaieCoupuresHeuristiques;
               *)

               // pour Edmond's eval

               if (ESprof >= profFinaleHeuristique ) and (ESprof <= profFinaleHeuristique + 1) then
                 if PeutFaireCoupureHeuristique(noteCoupure) then
                   begin
                     ABFin := noteCoupure;
                     exit(ABFin);
                   end;




               valeurHeuristiqueDeLaPosition  := quelleHashTableExacte^[clefHashExacte].evaluationHeuristique;
               evaluationDeLaPosition := valeurHeuristiqueDeLaPosition;

               AjusteStatutsDeKnuthDuNoeud;

             end;
         end
       else
         conseilHash := 0;


     {pour les gros scores, utiliser les pions definitifs pour reduire
      les valeurs possibles de la position : cela permet des elagages
      a priori}
     if (alpha >= 40) then
       begin
         if alpha >= 50
           then valeurMaxParPionsDefinitifs := 64-2*NbPionsDefinitifsAvecInterieursEndgame(adversaire,plat)
           else valeurMaxParPionsDefinitifs := 64-2*NbPionsDefinitifsEndgame(adversaire,plat);
         if valeurMaxParPionsDefinitifs < beta then beta := succ(valeurMaxParPionsDefinitifs);
         if valeurMaxParPionsDefinitifs <= alpha then
           begin
             meilleureSuite[ESprof,ESprof] := meiDef;
             meilleureSuite[ESprof,profMoins1] := 0;
             ABFin := valeurMaxParPionsDefinitifs;
             if ESprof >= ProfUtilisationHash then
               begin
                 if ESprof >= profondeurRemplissageHash
                   then HashTable^^[clefHashConseil] := meiDef;
                 gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
               end;
             exit(ABFin);
           end;
       end;
     if (beta <= -40) and (profMoins1 <= profForceBrute) then
       begin
         if beta <= -50
           then valeurMinParPionsDefinitifs := -64+2*nbPionsDefinitifsAvecInterieursEndgame(couleur,plat)
           else valeurMinParPionsDefinitifs := -64+2*nbPionsDefinitifsEndgame(couleur,plat);
         if valeurMinParPionsDefinitifs > alpha then alpha := pred(valeurMinParPionsDefinitifs);
         if valeurMinParPionsDefinitifs >= beta then
           begin
             meilleureSuite[ESprof,ESprof] := meiDef;
             meilleureSuite[ESprof,profMoins1] := 0;
             ABFin := valeurMinParPionsDefinitifs;
             if ESprof >= ProfUtilisationHash then
               begin
                 if ESprof >= profondeurRemplissageHash
                   then HashTable^^[clefHashConseil] := meiDef;
                 gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
               end;
             exit(ABFin);
           end;
       end;



     if seulementChercherDansHash then
       begin

         if ESprof >= ProfUtilisationHash then
           gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));

         {$IFC USE_DEBUG_STEP_BY_STEP}
         if gDebuggageAlgoFinaleStepByStep.actif and
            (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
            MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
           begin
             WritelnDansRapport('');
             WritelnDansRapport('sortie par seulementChercherDansHash : ');
             WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
             WritelnNumDansRapport('je renvoie kNoteBidonPositionNonTrouveeDansHash, ABFin = ',kNoteBidonPositionNonTrouveeDansHash);
             WritelnDansRapport('');
           end;
         {$ENDC}

         exit(ABFin);
       end;

     if listeFinaleFromScratch
       then
  	     begin

  	       EtablitListeCasesVidesParListeChainee;
  	       nbCoupsPourCoul := nbVidesTrouvees;
  	       TrierCasesVidesIsolees;

  	       {$IFC USE_DEBUG_STEP_BY_STEP}
  	       if gDebuggageAlgoFinaleStepByStep.actif and
             (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
             MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('Après TrierCasesVidesIsolees dans ABFin :');
              for i := 1 to nbCoupsPourCoul do
                WriteStringAndCoupDansRapport('>',listeFinale[i]);
              WritelnDansRapport('');
            end;
  	       {$ENDC}

  	       if ESprof >= profPourTriSelonDivergence then
  	          nbCoupsPourCoul := TrierSelonDivergenceAvecMilieu(plat,couleur,nbCoupsPourCoul,conseilHash,listeFinale,listeFinale,InfosMilieuDePartie,
        	                                                      100*alpha,100*beta,estPresqueSurementUneCoupureAlpha,estPresqueSurementUneCoupureBeta,
        	                                                      utiliseMilieuDePartie and not(estPresqueSurementUneCoupureAlpha) and (alpha < 60) and (beta > -60),
        	                                                      evaluationDeLaPosition);

  	       {if (ESprof >= ProfPourHashExacte) then
  	           AttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);}

  	       {$IFC USE_DEBUG_STEP_BY_STEP}
  	       if gDebuggageAlgoFinaleStepByStep.actif and
             (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
             MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
            begin
              WritelnNumDansRapport('ESprof = ',ESprof);
              WritelnNumDansRapport('profPourTriSelonDivergence = ',profPourTriSelonDivergence);
              WritelnNumDansRapport('profMinimalePourClassementParMilieu = ',profMinimalePourClassementParMilieu);
              WritelnStringAndBoolDansRapport('utiliseMilieuDePartie = ',utiliseMilieuDePartie);
              if (ESprof >= profPourTriSelonDivergence) then
                begin
                  WritelnDansRapport('Après TrierSelonDivergenceAvecMilieu :');
                  for i := 1 to nbCoupsPourCoul do
                    WriteStringAndCoupDansRapport('>',listeFinale[i]);
                  WritelnDansRapport('');
                  WritelnDansRapport('');
                end;
            end;
          {$ENDC}

  	     end
       else
         begin

           {$IFC USE_DEBUG_STEP_BY_STEP}
           if gDebuggageAlgoFinaleStepByStep.actif and
             (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
             MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('Liste déjà dans la table de hachage dans ABFin :');
              for i := 1 to nbCoupsPourCoul do
                WriteStringAndCoupDansRapport('>',listeFinale[i]);
              WritelnDansRapport('');
              WritelnDansRapport('');
            end;
            {$ENDC}

           if (ESprof > ProfPourHashExacte) and
  			      (alpha <= 50) and (beta >= -50) then
  			     if PeutTrouverTranspositionUnCoupPlusLoin(alpha,beta,noteCoupure) then
  			       begin  // ETC !
  			         ABFin := noteCoupure;
  			         exit(ABFin);
  			       end;
         end;



     RecordTraceExecutionFinale(ESProf,gClefHashage,pere);

     if DoitStopperExecutionDeCeSousArbre(ESProf) then
       begin
         CleanUpPourQuitterABFin;
         ABFin := -noteMax;
         exit(ABFin);
       end;




     aJoue := false;
     nbEvalue := 0;
     ameliorationsAlpha.cardinal := 0;

     platEssai := plat;
     diffEssai := diffPions;
     if utiliseMilieuDePartie then InfosMilieuEssai := InfosMilieuDePartie;


     nbCoupsEnvisages := nbCoupsPourCoul;

     for indexDeBoucle := 1 to nbCoupsEnvisages do
       filsEvalue[indexDeBoucle] := false;


     if (nbCoupsEnvisages = 1) then
       begin
         meiDefenseSansHeuristique := listeFinale[1];
         meiDef := meiDefenseSansHeuristique;
       end;


    { On recopie les infos utiles au zoo }
    InitialiserInfosPourLeZooDeCeNoeud;


    for numeroDePasse := 1 to 2 do
      for indexDeBoucle := 1 to nbCoupsEnvisages do
        if not(filsEvalue[indexDeBoucle]) and (interruptionReflexion = pasdinterruption) then
          begin
            indiceHashDesFils[indexDeBoucle] := -3000;

            if (maxPourBestDef < valeurExacteMax)
             then
               BEGIN
                iCourant := listeFinale[indexDeBoucle];


                { lors de la premiere passe, on saute les coups pris en charge par le zoo }
                if (numeroDePasse = 1) and (indexDeBoucle >= 2) and
                   (GetValeurZooDeCeFils(ESProf,iCourant,bestSuite,tempsCalculZoo) = k_ZOO_POSITION_PRISE_EN_CHARGE)
                  then
                    begin
                      (*
                      WriteNumDansRapport('p = ',ESProf);
                      WritelnDansRapport(' : le coup '+CoupEnStringEnMajuscules(iCourant)+' semble pris en charge par le zoo, je le saute');
                      *)
                      cycle;   // passer au coup suivant
                    end;


                constanteDePariteDeiCourant := constanteDeParite[iCourant];

                {if (deltaFinaleCourant = kDeltaFinaleInfini) and (NbNoeudsHeuristiquesDansTousLesFils <> 0) and (interruptionReflexion = pasdinterruption)  then
                  begin
                    SysBeep(0);
                    WritelnNumDansRapport('ERROR au début de la boucle des coups légaux : deltaFinaleCourant = infini mais NbNoeudsHeuristiquesDansTousLesFils = ',NbNoeudsHeuristiquesDansTousLesFils);
                    WritelnNumDansRapport('gClefHashage = ',gClefHashage);
      	          WritelnDansRapport('');
                  end;
                  }

                (*** pour debugage seulement ***)
                {if iCourant < 11 then AlerteSimple('Debugger : iCourant = '+NumEnString(iCourant)+' dans ABFin') else
                if iCourant > 88 then AlerteSimple('Debugger : iCourant = '+NumEnString(iCourant)+' dans ABFin') else
                if platEssai[iCourant] <> pionVide then AlerteSimple('Debugger : platEssai['+NumEnString(iCourant)+'] <> 0 dans ABFin');
                }


                if utiliseMilieuDePartie
                  then
                    begin
                      with InfosMilieuEssai do
                        begin
                          //WritelnNumDansRapport('ABFin(1), coup = ',iCourant);
                          coupLegal := ModifPlatLongint(iCourant,couleur,platEssai,jouable,nbBlancs,nbNoirs,frontiere);
                          if coupLegal then
                            if couleur = pionNoir
                              then diffEssai := nbNoirs-nbBlancs
                              else diffEssai := nbBlancs-nbNoirs;
                        end;
                    end
                  else
                    coupLegal := ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platEssai,diffEssai);

                if coupLegal then
                  begin
                    aJoue := true;
                    NbNoeudsHeuristiquesDansCeFils := 0;
                    tickPourChronometrerTempsPrisDansCeFils := TickCount;

                    gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
                    {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
                    celluleDansListeChaineeCasesVides := gTableDesPointeurs[iCourant];
                    with celluleDansListeChaineeCasesVides^ do
      	              begin
      	                previous^.next := next;
      	                next^.previous := previous;
      	              end;

                    if ESprof >= gNbreVides_entreeCoupGagnant-2 then
                      begin
                        with InfosPourcentagesCertitudesAffiches[gNbreVides_entreeCoupGagnant-ESprof] do
      					          begin
      					            mobiliteCetteProf := nbCoupsPourCoul;
      					            indexDuCoupCetteProf := indexDeBoucle;
      				            end;
                      end;

                    {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
      		          BeginCollecteStatsNbreNoeudsEndgame(profMoins1);
      		          {$ENDC}



                    CalculerLaNoteCouranteDeCeFils;



                    filsEvalue[indexDeBoucle] := true;


                    if (noteCourante >= beta) and (noteCourante < betaInitial) then
                      NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + NbNoeudsHeuristiquesPourAjusterBeta;
                    if (noteCourante <= alpha) and (noteCourante > alphaInitial) then
                      NbNoeudsCoupesParHeuristique := NbNoeudsCoupesParHeuristique + NbNoeudsHeuristiquesPourAjusterAlpha;

                    (*
                    if estPresqueSurementUneCoupureBeta and (profMoins1 <= profForceBrute + 3) and (indexDeBoucle = 1) and (noteCourante >= beta) then
                      begin
                        inc(gNombreDeCoupuresBetaReussies);
                        {if (gNombreDeCoupuresBetaPresquesSures mod 128) = 0 then
                          WritelnStringAndReelDansRapport('ratio de beta-parallelisme reussi = ',1.0*gNombreDeCoupuresBetaReussies/gNombreDeCoupuresBetaPresquesSures,4);}
                      end;
                    *)

                    VerifierLeParallelismeDuZoo;


                    {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
                    EndCollecteStatsNbreNoeudsEndgame(profMoins1);
          		      {$ENDC}

          		      {$IFC USE_DEBUG_STEP_BY_STEP}
          		      if gDebuggageAlgoFinaleStepByStep.actif and
          	          (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
          	          MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
          	          begin
          	            WritelnDansRapport('');
          			        WritelnNumDansRapport('apres calcul de noteCourante dans ABFin '+NumEnString(indexDeBoucle)+'/',nbCoupsEnvisages);
                        WritelnNumDansRapport('alpha = ',alpha);
                        WritelnNumDansRapport('beta = ',beta);
                        WritelnNumDansRapport('nbCoupsPourCoul = ',nbCoupsPourCoul);
                        WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                        WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
                        WritelnNumDansRapport('maxPourBestDef = ',maxPourBestDef);
                        WritelnNumDansRapport('noteCourante = ',noteCourante);
                        WritelnNumDansRapport('NbNoeudsHeuristiquesDansCeFils = ',NbNoeudsHeuristiquesDansCeFils);
                        WritelnNumDansRapport('NbNoeudsCoupesParHeuristique = ',NbNoeudsCoupesParHeuristique);
                        WritelnNumDansRapport('NbNoeudsHeuristiquesDansTousLesFils = ',NbNoeudsHeuristiquesDansTousLesFils);
                        WritelnNumDansRapport('ESprof = ',ESprof);
                        WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
                        WritelnDansRapport('');
                      end;
                      {$ENDC}

                    gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
                    {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
          					with celluleDansListeChaineeCasesVides^ do
          					  begin
          						  previous^.next := celluleDansListeChaineeCasesVides;
          						  next^.previous := celluleDansListeChaineeCasesVides;
          						end;

                    if (noteCourante > maxPourBestDef) then
                       begin

                         {$IFC USE_DEBUG_STEP_BY_STEP}
                         if gDebuggageAlgoFinaleStepByStep.actif and
      					           (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
      					           MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
      					          begin
      					            WritelnDansRapport('');
      							        WritelnDansRapport('(noteCourante > maxPourBestDef) dans ABFin :');
      		                  WritelnNumDansRapport('alpha = ',alpha);
      		                  WritelnNumDansRapport('beta = ',beta);
      		                  WritelnNumDansRapport('nbCoupsPourCoul = ',nbCoupsPourCoul);
      		                  WritelnStringAndCoupDansRapport('oldMeiDef = ',meiDef);
      		                  WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
      		                  WritelnNumDansRapport('maxPourBestDef = ',maxPourBestDef);
      		                  WritelnNumDansRapport('noteCourante = ',noteCourante);
      		                  WritelnNumDansRapport('NbNoeudsHeuristiquesDansCeFils = ',NbNoeudsHeuristiquesDansCeFils);
      		                  WritelnNumDansRapport('NbNoeudsCoupesParHeuristique = ',NbNoeudsCoupesParHeuristique);
      		                  WritelnNumDansRapport('NbNoeudsHeuristiquesDansTousLesFils = ',NbNoeudsHeuristiquesDansTousLesFils);
      		                  WritelnNumDansRapport('ESprof = ',ESprof);
      		                  WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
      		                  WritelnPositionEtTraitDansRapport(plat,couleur);
      		                  WritelnDansRapport('');
                          end;
                         {$ENDC}

                         maxPourBestDef := noteCourante;
                         meiDef := iCourant;

                         if (ESprof >= ProfPourHashExacte) and
                            (maxPourBestDef <= bornes.valMin[nbreDeltaSuccessifs]) {and
                            (bornes.coupDeCetteValMin[nbreDeltaSuccessifs] <> 0)} and
                            (maxPourBestDef <= alpha) and
                            (nbCoupsEnvisages > 1)
      	                   then meiDef := bornes.coupDeCetteValMin[nbreDeltaSuccessifs];

                         if (noteCourante > alpha)
                           then
      	                     begin

      	                       if (ESprof >= ProfPourHashExacte) and
      					                  (noteCourante > valeurExacteMax) and
      					                  (NbNoeudsHeuristiquesDansCeFils = 0) and
      					                  (bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] > 0) then
      			                      begin
      			                        ValeurExacteMax := noteCourante;
      			                        bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] := bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant];
      			                      end;

      	                       if (ESprof >= ProfPourHashExacte) and
      					                  (noteCourante > valeurExacteMax) and
      					                  (bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] > 0) then
      			                        begin
      		                            ValeurExacteMax := noteCourante;
      			                          bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] := bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant];
      			                        end;

      	                       if (ESprof >= ProfPourHashExacte) then
      	                         with ameliorationsAlpha do
      	                           begin
      			                         inc(cardinal);
      			                         with liste[cardinal] do
      			                           begin
      			                             coup := iCourant;
      			                             val := noteCourante;
      			                             alphaAvant := alpha;
      			                           end;
      			                       end;


      	                       alpha := noteCourante;
      	                       ordreDuMeilleur := indexDeBoucle;

      	                       if (ESprof >= ProfPourHashExacte) then
      	                         begin

      	                           if (maxPourBestDef > valeurExacteMin)
      	                             then bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] := NbNoeudsHeuristiquesDansCeFils
      	                             else bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] := NbNoeudsHeuristiquesDansTousLesFils;
      	                           valeurExacteMin := maxPourBestDef;

      	                           {$IFC USE_DEBUG_STEP_BY_STEP}
      	                           if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
      	                             begin
      	                               WritelnDansRapport('');
      	                               WritelnNumDansRapport('affectation (2) valeurExacteMin := ',valeurExacteMin);
      	                               WritelnStringAndCoupDansRapport('meidef = ',meiDef);
      	                               WritelnDansRapport('');
      	                             end;
      	                           {$ENDC}

      	                           {WritelnNumDansRapport('setting valeurExacteMin = ',valeurExacteMin);
      	                           WritelnNumDansRapport('setting ValeursArriveeHashExacte.nbSousArbresCoupesValeurMin = ',ValeursArriveeHashExacte.nbSousArbresCoupesValeurMin);
      	                           WritelnDansRapport('');
      	                           }


      	                           MetPosDansHashTableExacteEndgame(quelleHashTableExacte^[clefHashExacte],codagePosition,valeurHeuristiqueDeLaPosition);

      	                           {si les evaluations des coups precedents etaient sures,
      	                            on peut liberer un peu de place dans la table de hashage}
      	                           if (indexDeBoucle > 1) and (ESprof > ProfPourHashExacte) and
      	                              ((ESprof < profFinaleHeuristique) or
      	                              (({(deltaFinaleCourant = kDeltaFinaleInfini) and} (NbNoeudsHeuristiquesDansTousLesFils = 0)))) then
      	                              LiberePlacesHashTableExacte(1,pred(indexDeBoucle));

      	                           {si les evaluations des coups precedents etaient sures,
      	                            on peut elaguer ces coups; sinon on stocke tous les coups
      	                            legaux pour eviter d'avoir à les recalculer}
      	                           if ((ESprof < profFinaleHeuristique) or
      	                               ({(deltaFinaleCourant = kDeltaFinaleInfini) and} (NbNoeudsHeuristiquesDansTousLesFils = 0)))
      	                             then
      	                               begin
      	                                 MetCoupEnTeteEtAttacheCoupsLegauxDansHash(indexDeBoucle,nbCoupsPourCoul,meiDef,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
      	                                 EnleverBornesMinPeuSuresDesAutresCoups(quelleHashTableCoupsLegaux,clefHashExacte,couleur,bornes,plat);
      	                               end
      	                             else
      	                               begin
      	                                 if (ameliorationsAlpha.cardinal >= 2)
      	                                   then MetAmeliorationsAphaPuisCoupsLegauxDansHash(1,nbCoupsPourCoul,ameliorationsAlpha,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale)
      	                                   else MetCoupEnTeteEtAttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,meiDef,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
      	                               end;

      	                           {on vient de trouver un nouvelle borne inferieure}

      	                           {if (NbNoeudsHeuristiquesDansTousLesFils = 0) and (ValeursArriveeHashExacte.nbSousArbresCoupesValeurMax > 0) then
      	                                 begin
      	                                   WritelnDansRapport('WARNING : aurais-je trouvé ???');
      	                                   WritelnNumDansRapport('gClefHashage = ',gClefHashage);
      	                                   WritelnDansRapport('');
      	                                 end;}

                                   {l'ancienne borne superieure}
                                   if bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] = 0
                                     then DiminutionMajorant(valeurExacteMax,kDeltaFinaleInfini,couleur,bornes,plat,'amelioration alpha (3)')  {borne sure à 100%}
                                     else DiminutionMajorant(valeurExacteMax,deltaFinaleCourant,couleur,bornes,plat,'amelioration alpha (4)'); {borne heuristique}


                                   {la nouvelle borne inferieure}
                                   if bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] = 0
                                     then AugmentationMinorant(maxPourBestDef,kDeltaFinaleInfini,meiDef,couleur,bornes,plat,'amelioration alpha (1)') {borne sure à 100%}
                                     else AugmentationMinorant(maxPourBestDef,deltaFinaleCourant,meiDef,couleur,bornes,plat,'amelioration alpha (2)');{borne heuristique}


                                   {le nouveau meilleur coup dans la position (parmi les fils explorés)}
                                   SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
                                   CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);

                                   {$IFC USE_DEBUG_STEP_BY_STEP}
                                   if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
      						                    begin
      						                      WritelnDansRapport('');
      						                      WritelnDansRapport('appel de CompresserBornes(4)');
      						                      WritelnPositionEtTraitDansRapport(plat,couleur);
      						                      WritelnNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
      						                      WritelnNumDansRapport('ESProf = ',ESProf);
      						                      WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
      						                      WritelnDansRapport('');
      						                    end;
                                   {$ENDC}

      	                         end;


      	                       if (alpha >= beta) then
      	                          begin
      	                            ABFin := maxPourBestDef;

      	                            {$IFC USE_DEBUG_STEP_BY_STEP}
      	                            if gDebuggageAlgoFinaleStepByStep.actif and
      	                               (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
      	                               MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
      	                              begin
      			                            WritelnDansRapport('sortie par (alpha >= beta) dans ABFin :');
      			                            WritelnPositionEtTraitDansRapport(plat,couleur);
      			                            WritelnNumDansRapport('ESProf = ',ESProf);
      			                            WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
      			                            WritelnNumDansRapport('alpha = ',alpha);
      			                            WritelnNumDansRapport('beta = ',beta);
      			                            WritelnNumDansRapport('maxPourBestDef = ',maxPourBestDef);
      			                            WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
      			                            WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
      			                          end;
      			                        {$ENDC}

      	                            if (noteCourante = 64) then
      	                              begin
      	                                if switchToBitboardAlphaBeta
      	                                  then for k := profForceBrutePlusUn to profMoins1 do  meilleureSuite[ESprof,k] := 0
      	                                  else for k := profForceBrutePlusUn to profMoins1 do  meilleureSuite[ESprof,k] := meilleureSuite[profMoins1,k];
      	                                meilleureSuite[ESprof,ESprof] := meiDef;
      	                              end;

      	                            if (ESprof >= ProfUtilisationHash) and (ESprof >= profondeurRemplissageHash)
      	                                  then HashTable^^[clefHashConseil] := meiDef;
      	                            NettoyerInfosDuZooPourCetteProf(ESProf);
      	                            CleanUpPourQuitterABFin;

      	                            exit(ABFin);
      	                          end;

      	                     end
                           else  {noteCourante <= alpha}
                             begin

                             end;


                         if switchToBitboardAlphaBeta
                           then for k := profForceBrutePlusUn to profMoins1 do  meilleureSuite[ESprof,k] := 0
                           else for k := profForceBrutePlusUn to profMoins1 do  meilleureSuite[ESprof,k] := meilleureSuite[profMoins1,k];
      		               meilleureSuite[ESprof,ESprof] := iCourant;

      		               {$IFC USE_DEBUG_STEP_BY_STEP}
                         if gDebuggageAlgoFinaleStepByStep.actif and
      	                    (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
      	                    MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
      	                    begin
      	                      WritelnDansRapport('');
      	                      WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
      	                      WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
      	                      WritelnDansRapport('Je mets la meilleure suite suivante :');
      	                      WriteCoupDansRapport(meilleureSuite[ESprof,ESprof]);
      	                      for k := profMoins1 downto profForceBrutePlusUn do
      		                      WriteStringAndCoupDansRapport(' ',meilleureSuite[ESprof,k]);
      		                    WritelnDansRapport('');
      	                    end;
                         {$ENDC}


                       end;  {if noteCourante > MaxPourBestDef}

                  {if ESprof >= gNbreVides_entreeCoupGagnant-2 then
                     AfficheResultatsPremiersNiveaux(couleur,indexDeBoucle,nbCoupsPourCoul);}

                   platEssai := plat;
                   diffEssai := diffPions;
                   if utiliseMilieuDePartie then InfosMilieuEssai := InfosMilieuDePartie;

                  end;
                END;
           end;


     NettoyerInfosDuZooPourCetteProf(ESProf);


     if DoitStopperExecutionDeCeSousArbre(ESProf) then
       begin
         CleanUpPourQuitterABFin;
         ABFin := -noteMax;
         exit(ABFin);
       end;


     if aJoue
      then
        begin
          {si ameliorationsAlpha.cardinal > 0, on sait que alpha < maxPourBestDef = valeurExacteMin < beta}

          if ESprof >= ProfUtilisationHash then
            begin
              if ESprof >= profondeurRemplissageHash then
                HashTable^^[clefHashConseil] := meiDef;

              if (ESprof >= ProfPourHashExacte) then
                  begin

                   if (valeurExacteMin > maxPourBestDef) and
                      (NbNoeudsHeuristiquesDansTousLesFils > 0) and
                      (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] = 0) then
                      begin
                        maxPourBestDef := valeurExacteMin;
                      end;

                   if (valeurExacteMin > maxPourBestDef) and
                      (NbNoeudsHeuristiquesDansTousLesFils = 0) and
                      (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] > 0) then
                      begin
                        valeurExacteMin := maxPourBestDef;

                        {$IFC USE_DEBUG_STEP_BY_STEP}
                        if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                          begin
                            WritelnDansRapport('');
                            WritelnNumDansRapport('affectation (3) valeurExacteMin := ',valeurExacteMin);
                            WritelnDansRapport('');
                          end;
                        {$ENDC}

                      end;

                   if (valeurExacteMin > maxPourBestDef) and
                      (NbNoeudsHeuristiquesDansTousLesFils > 0) and
                      (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] > 0) then
                     begin
                       valeurExacteMin := maxPourBestDef;

                       {$IFC USE_DEBUG_STEP_BY_STEP}
                       if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                         begin
                           WritelnDansRapport('');
                           WritelnNumDansRapport('affectation (4) valeurExacteMin := ',valeurExacteMin);
                           WritelnDansRapport('');
                         end;
                       {$ENDC}

                     end;

                  if (valeurExacteMin <> maxPourBestDef) and
                     (NbNoeudsHeuristiquesDansTousLesFils = 0) and
                      (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] = 0) then
                      begin
                        (*
                        WritelnDansRapport('WARNING cas non traité !!');
                        SysBeep(0);
                        *)
                      end;

                    MetPosDansHashTableExacteEndgame(quelleHashTableExacte^[clefHashExacte],codagePosition,valeurHeuristiqueDeLaPosition);

                    {si les evaluations de tous les fils etaient sures,
                     on peut elaguer tous les fils sauf le meilleur,
                     et liberer les places correspondantes dans la table
                     de hachage}
                    if (ordreDuMeilleur >= 1) and (meiDef <> 0) and
                       ((ESprof < profFinaleHeuristique) or
                       ({(deltaFinaleCourant = kDeltaFinaleInfini) and }
                         (NbNoeudsHeuristiquesDansTousLesFils = 0) and (bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] = 0) and
                                                                     (bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] = 0)))
                      then            { alpha < maxPourBestDef < beta }
                        begin
                          if (ESprof > ProfPourHashExacte) then
                            begin
                              if ordreDuMeilleur > 1 then
                                LiberePlacesHashTableExacte(1,pred(ordreDuMeilleur));
                              if ordreDuMeilleur < nbCoupsPourCoul then
                                LiberePlacesHashTableExacte(succ(ordreDuMeilleur),nbCoupsPourCoul);
                            end;
                          if (listeFinale[ordreDuMeilleur] <> meiDef) then
                            begin
                              SysBeep(0);
                              WritelnNumDansRapport('ordreDuMeilleur = ',ordreDuMeilleur);
                              WritelnStringAndCoupDansRapport('listeFinale[ordreDuMeilleur] = ',listeFinale[ordreDuMeilleur]);
                              WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
                            end;
                          AttacheCoupsLegauxDansHash(ordreDuMeilleur,ordreDuMeilleur,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                          EnleverBornesMinPeuSuresDesAutresCoups(quelleHashTableCoupsLegaux,clefHashExacte,couleur,bornes,plat);
                        end
                      else            { maxPourBestDef <= alpha }
                    {sinon on est oblige de garder tous les fils, pour
                    les retrouver lors des passes moins risquees}
                        begin
                          if (ameliorationsAlpha.cardinal >= 1)
                            then MetAmeliorationsAphaPuisCoupsLegauxDansHash(1,nbCoupsPourCoul,ameliorationsAlpha,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale)
                            else MetCoupEnTeteEtAttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,meiDef,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                        end;

                    {on vient de trouver la vraie valeur de la position,
                     qui est "exacte" quand alpha < maxPourBestDef = valeurExacteMin < beta }

                    {la nouvelle borne superieure}
                    if (maxPourBestDef >= valeurExacteMax)
                      then bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] := NbNoeudsHeuristiquesDansTousLesFils + bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant]
                      else bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] := NbNoeudsHeuristiquesDansTousLesFils;
                    if bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] = 0
                      then DiminutionMajorant(maxPourBestDef,kDeltaFinaleInfini,couleur,bornes,plat,'sortie normale (3)')  {valeur sure à 100%}
                      else DiminutionMajorant(maxPourBestDef,deltaFinaleCourant,couleur,bornes,plat,'sortie normale (4)'); {valeur heuristique}

                    {l'ancienne borne inferieure}
                    if ((valeurExacteMin > alphaInitial) or ((valeurExacteMin = 64) and (alphaInitial = 64)) or
                          ((maxPourBestDef = -64) and (valeurExacteMin = -64) and (bornes.nbArbresCoupesValMax[indexDeltaFinaleCourant] = 0))) and
                       ((valeurExacteMin < betaInitial) or ((valeurExacteMin = -64) and (betaInitial = -64))) and
                       (valeurExacteMin = maxPourBestDef) and (meiDef <> 0) and (NbNoeudsHeuristiquesDansTousLesFils = 0)
                      then meiDefenseSansHeuristique := meiDef;
                    if bornes.nbArbresCoupesValMin[indexDeltaFinaleCourant] = 0
                      then AugmentationMinorant(valeurExacteMin,kDeltaFinaleInfini,meiDefenseSansHeuristique,couleur,bornes,plat,'sortie normale (1)')  {valeur sure à 100%}
                      else AugmentationMinorant(valeurExacteMin,deltaFinaleCourant,meiDef,couleur,bornes,plat,'sortie normale (2)'); {valeur heuristique}


                    {et on a determiné le meilleur coup de la position, en plus du score}
                    SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
                    CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);

                    {$IFC USE_DEBUG_STEP_BY_STEP}
                    if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                      begin
                        WritelnDansRapport('');
                        WritelnDansRapport('appel de CompresserBornes(5)');
                        WritelnPositionEtTraitDansRapport(plat,couleur);
                        WritelnNumDansRapport('bornes.valMin[nbreDeltaSuccessifs] = ',bornes.valMin[nbreDeltaSuccessifs]);
                        WritelnNumDansRapport('ESProf = ',ESProf);
                        WritelnNumDansRapport('alphaInitial = ',alphaInitial);
                        WritelnNumDansRapport('betaInitial = ',betaInitial);
                        WritelnNumDansRapport('alpha = ',alpha);
                        WritelnNumDansRapport('beta = ',beta);
                        WritelnNumDansRapport('ameliorationsAlpha.cardinal = ',ameliorationsAlpha.cardinal);
                        WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
                        WritelnDansRapport('');
                      end;
                    {$ENDC}

                  end;
            end;



          {$IFC USE_DEBUG_STEP_BY_STEP}
          if gDebuggageAlgoFinaleStepByStep.actif and
             (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
             MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('sortie normale dans ABFin :');
              WritelnPositionEtTraitDansRapport(plat,couleur);
              WritelnNumDansRapport('ESProf = ',ESProf);
              WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
              WritelnNumDansRapport('alpha = ',alpha);
              WritelnNumDansRapport('beta = ',beta);
              WritelnNumDansRapport('maxPourBestDef = ',maxPourBestDef);
              WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
              if (ESprof >= ProfPourHashExacte) then
                WritelnStringAndCoupDansRapport('dans hash, bestdef = ',GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]));
              WritelnDansRapport('');
            end;
          {$ENDC}

          CleanUpPourQuitterABFin;

          ABFin := maxPourBestDef;
        end
      else
        begin

          {$IFC USE_DEBUG_STEP_BY_STEP}
          if gDebuggageAlgoFinaleStepByStep.actif and
             (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
             MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('Je n''ai pas trouve de coup legal dans ABFin :');
              WritelnPositionEtTraitDansRapport(plat,couleur);
              WritelnNumDansRapport('ESProf = ',ESProf);
              WritelnStringAndBoolDansRapport('aJoue = ',aJoue);
              WritelnStringAndBoolDansRapport('vientDePasser = ',vientDePasser);
              WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
              WritelnNumDansRapport('alpha = ',alpha);
              WritelnNumDansRapport('beta = ',beta);
              WritelnNumDansRapport('maxPourBestDef = ',maxPourBestDef);
              WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
              WritelnNumDansRapport('nbCoupsEnvisages = ',nbCoupsEnvisages);
              WritelnDansRapport('');
            end;
          {$ENDC}

          CleanUpPourQuitterABFin;

          if vientDePasser
            then
              begin
                if diffPions > 0 then ABFin := diffPions + ESprof else
                if diffPions < 0 then ABFin := diffPions - ESprof else
                  ABFin := 0;
                for k := profForceBrutePlusUn to ESprof do meilleureSuite[ESprof,k] := 0;
              end
            else
              ABFin := -ABFin(contexteMakeEndgameSearch, plat,meiDef,pere,adversaire,ESprof,-beta,-alpha,-diffPions,IndiceHashTableExacteRetour,
                              true,InfosMilieuDePartie,NbNoeudsCoupesParHeuristique,essayerMoinsPrecis,false);
        end;

    end;
end;   { ABFin }




function LanceurABFin(var contexteMakeEndgameSearch : variablesMakeEndgameSearchRec;
                      var plat : plateauOthello; var meiDef : SInt32; pere,couleur,ESprof,alpha,beta,nbBlancs,nbNoirs : SInt32;
                      var InfosMilieuDePartie : InfosMilieuRec) : SInt32;
var platEndgame : plOthEndgame;
    valeur,nbTickLanceur : SInt32;
    myDiffPions : SInt32;
    IndiceHashTableExacte : SInt32;
    precision : SInt32;
    essayerUtiliserLeMoteur : boolean;
    valeurCalculeeParLeMoteurExterne : boolean;
    valeurTrouveeDansLaTableDeHachage : boolean;
    tempoAvecRecursiviteDansEval : boolean;
    numeroEngine : SInt32;
    alphaLanceur,betaLanceur : SInt32;
    coupuresHeuristiques : SInt32;
    G : GameTree;
    treePos, currentPos : PositionEtTraitRec;
    suiteOptimale : PropertyList;
begin
  with contexteMakeEndgameSearch do
    begin

      if debuggage.algoDeFinale then
        begin
    		  FinRapport;
    		  TextNormalDansRapport;
    		  {if analyseRetrograde.enCours then WritelnDansRapport('');}
    		  WriteNumDansRapport('LanceurABFin( '+CoupEnString(pere,true)+' , ',-beta);
    		  WriteNumDansRapport(' , ',-alpha);
    		  WriteNumDansRapport(' , c = ',valeurCible);
    		  if deltaFinaleCourant = kDeltaFinaleInfini
    		    then WriteDansRapport(' , µ=∞')
    		    else WriteStringAndReelDansRapport(' , µ=',0.01*deltaFinaleCourant,2);
    		  if passeEhancedTranspositionCutOffEstEnCours then
    		    WriteStringAndBooleanDansRapport(' , ETC = ',passeEhancedTranspositionCutOffEstEnCours);
    		  WriteStringDansRapport('  )……');
    		end;

      if (alpha > beta) or (alpha < -65) or (beta > 65) then
        begin
          SysBeep(0);
          WritelnDansRapport('');
          WritelnDansRapport('ASSERT((alpha < -64) or (beta > 64) or (alpha > beta)) dans LanceurABFin!!!');
          WritelnPositionEtTraitDansRapport(plat,couleur);
          WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
          WritelnStringAndCoupDansRapport('pere = ',pere);
          WritelnNumDansRapport('ESprof = ',ESprof);
          WritelnNumDansRapport('nbNoirs = ',nbNoirs);
          WritelnNumDansRapport('nbBlancs = ',nbBlancs);
          WritelnNumDansRapport('IndiceHashTableExacte = ',IndiceHashTableExacte);
          WritelnNumDansRapport('nbCoupuresHeuristiquesCettePasse = ',nbCoupuresHeuristiquesCettePasse);
          WritelnNumDansRapport('alpha = ',alpha);
          WritelnNumDansRapport('beta = ',beta);

          WriteDansRapport('interruption = ');
          EcritTypeInterruptionDansRapport(interruptionReflexion);

          LanceInterruptionSimple('LanceurABFin');
          exit(LanceurABFin);
        end;

      {$IFC USE_DEBUG_STEP_BY_STEP}
      with gDebuggageAlgoFinaleStepByStep do
        begin
          positionsCherchees := MakeEmptyPositionEtTraitSet;
          {actif := (pere = 22)} {and (deltaFinaleCourant >= 200) and (alpha = -64)};
          {actif := (pere = 78) and (ESProf = 19);}
          actif := true;
          profMin := 0;
          if actif then AjouterPositionsDevantEtreDebugueesPasAPas(positionsCherchees);
        end;
      {$ENDC}

      (*
      WritelnDansRapport('');
      WritelnStringAndCoupDansRapport('premier appel a ABFin, meiDef = ',meiDef);
      WritelnNumDansRapport('premier appel a ABFin, nbCoupuresHeuristiquesCettePasse = ',nbCoupuresHeuristiquesCettePasse);
      WritelnNumDansRapport('premier appel a ABFin, IndiceHashTableExacte = ',IndiceHashTableExacte);
      WritelnDansRapport('dans ABFin, plat = ');
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WritelnNumDansRapport('dans ABFin, meiDef = ',meiDef);
      WritelnNumDansRapport('dans ABFin, pere = ',pere);
      WritelnNumDansRapport('dans ABFin, couleur = ',couleur);
      WritelnNumDansRapport('dans ABFin, ESprof = ',ESprof);
      WritelnNumDansRapport('dans ABFin, alpha = ',alpha);
      WritelnNumDansRapport('dans ABFin, beta = ',beta);
      WritelnNumDansRapport('dans ABFin, nbNoirs = ',nbNoirs);
      WritelnNumDansRapport('dans ABFin, nbBlancs = ',nbBlancs);
      WritelnNumDansRapport('dans ABFin, IndiceHashTableExacte = ',IndiceHashTableExacte);
      WritelnNumDansRapport('dans ABFin, nbCoupuresHeuristiquesCettePasse = ',nbCoupuresHeuristiquesCettePasse);
      *)

      {
      if (alpha >= beta) then
        WritelnDansRapport('WARNING : alpha >= beta dans LanceurABFin !');
      }

      nbTickLanceur := TickCount;

      valeurCalculeeParLeMoteurExterne  := false;
      valeurTrouveeDansLaTableDeHachage := false;
      meiDef := 0;


      MyCopyEnPlOthEndgame(plat,platEndgame);


      if couleur = pionNoir
        then myDiffPions := nbNoirs-nbBlancs
        else myDiffPions := nbBlancs-nbNoirs;



      alphaLanceur := alpha;
      betaLanceur := beta;
      coupuresHeuristiques := 0;

      if not(CassioEstEnTrainDeCalculerPourLeZoo)
         and AmeliorerFenetreParHashTableExacte(meilleureSuite, bestmode, platEndgame, pere, couleur, ESProf, kDeltaFinaleInfini, alphaLanceur, betaLanceur, valeur, meiDef, coupuresHeuristiques)
         and not(passeEhancedTranspositionCutOffEstEnCours)
         and (not(bestMode) or ((alphaLanceur >= betaLanceur - 1) and (alphaLanceur < 63)) or (deltaFinaleCourant < kDeltaFinaleInfini))
         and (alphaLanceur >= betaLanceur)
         and ((alphaLanceur >= beta) or ((alpha = -64) and (beta = 64)))
         and (coupuresHeuristiques = 0)
        then
          begin
            valeurTrouveeDansLaTableDeHachage := true;
            (* WritelnDansRapport('BINGO ! (cas 0)');
            WritelnNumDansRapport('dans ABFin, alphaLanceur = ',alphaLanceur);
            WritelnNumDansRapport('dans ABFin, betaLanceur = ',betaLanceur);
            *)
          end;



      alphaLanceur := alpha;
      betaLanceur := beta;
      coupuresHeuristiques := 0;

      if not(CassioEstEnTrainDeCalculerPourLeZoo)
         and not(seMefierDesScoresDeLArbre)
         and SuiteParfaiteEstConnueDansGameTree
         and AmeliorerFenetreParHashTableExacte(meilleureSuite, bestmode, platEndgame, pere, couleur, ESProf, deltaFinaleCourant, alphaLanceur, betaLanceur, valeur, meiDef, coupuresHeuristiques)
         and (alphaLanceur >= betaLanceur)
         and (coupuresHeuristiques = 0)
        then
          begin
            valeurTrouveeDansLaTableDeHachage := true;
            (* WritelnDansRapport('BINGO ! (cas 1)');
            WritelnNumDansRapport('dans ABFin, alphaLanceur = ',alphaLanceur);
            WritelnNumDansRapport('dans ABFin, betaLanceur = ',betaLanceur);
            *)
          end;


      if CassioIsUsingAnEngine(numeroEngine) and (ESprof >= 22) and not(passeEhancedTranspositionCutOffEstEnCours) and not(valeurTrouveeDansLaTableDeHachage) then
        begin
           precision := IndexDeltaFinaleEnPrecisionEngine(indexDeltaFinaleCourant);


           // si la precision est < 100% , il suffit d'avoir alpha >= beta dans
           // la table de hachage de Cassio pour provoquer une coupure : il
           // est inutile d'appeler les moteurs dans ce cas
           if (precision < 100) and not(seMefierDesScoresDeLArbre) and not(CassioEstEnTrainDeCalculerPourLeZoo) then
             begin
               alphaLanceur := -64;
               betaLanceur := 64;
               coupuresHeuristiques := 0;
               if AmeliorerFenetreParHashTableExacte(meilleureSuite, bestmode, platEndgame, pere, couleur, ESProf, kDeltaFinaleInfini, alphaLanceur, betaLanceur, valeur, meiDef, coupuresHeuristiques)
                  and (alphaLanceur >= betaLanceur)
                  and (coupuresHeuristiques = 0)
                  then valeurTrouveeDansLaTableDeHachage := true;
             end;

           // si la precision est de 100% , on doit verifier en outre que la table
           // de hachage de Cassio (i.e l'arbre de jeu, en general), contient une
           // suite parfaite complete puisque l'on cherche aussi à ramener une
           // suite de coups.
           if (precision = 100)
              and not(seMefierDesScoresDeLArbre)
              and coupGagnantUtiliseEndgameTrees
              and EndgameTreeEstValide(numeroEndgameTreeActif, contexteMakeEndgameSearch) then
                begin
                  suiteOptimale := NewPropertyList;
                  G := GetActiveNodeOfEndgameTree(numeroEndgameTreeActif);
                  if GetPositionEtTraitACeNoeud(G, treePos, 'LanceurABFin') then
                     begin
                       currentPos := MakePositionEtTrait(platEndgame,couleur);
                       if SamePositionEtTrait(treePos, currentPos)
                          and PeutCalculerFinaleParEndgameTree(numeroEndgameTreeActif, treePos, suiteOptimale, valeur)
                          then valeurTrouveeDansLaTableDeHachage := true; // ligne parfaite trouvee !
                     end;
                  DisposePropertyList(suiteOptimale);
                end;


           // WritelnNumDansRapport('estimationPositionDApresMilieu = ',estimationPositionDApresMilieu);

           essayerUtiliserLeMoteur := ((precision >= 80) or                                                // pour forcer l'utilisation du moteur dans les hautes precisions
                                      ((precision >= 70) and (ESprof > 30))) or                              // idem
                                      ((precision >= 25) and (abs(estimationPositionDApresMilieu) >= 50));  // pour forcer l'utilisation du moteur dans les positions desequilibrees

           essayerUtiliserLeMoteur := essayerUtiliserLeMoteur
                                      and not(valeurTrouveeDansLaTableDeHachage) and (alpha < beta);

           if essayerUtiliserLeMoteur then
             valeurCalculeeParLeMoteurExterne := EnginePeutFaireCalculDeFinale(plat,couleur,alpha,beta,precision,pere,valeur,meiDef,contexteMakeEndgameSearch.meilleureSuite);
        end;


      if not(valeurCalculeeParLeMoteurExterne) then
        begin
          tempoAvecRecursiviteDansEval := avecRecursiviteDansEval;
          avecRecursiviteDansEval := false;

          valeur := ABFin(contexteMakeEndgameSearch, platEndgame,meiDef,pere,couleur,ESprof,alpha,beta,myDiffPions,IndiceHashTableExacte,false,
                      InfosMilieuDePartie,nbCoupuresHeuristiquesCettePasse,true,passeEhancedTranspositionCutOffEstEnCours);

          avecRecursiviteDansEval := tempoAvecRecursiviteDansEval;
        end;

      if ValeurDeFinaleInexploitable(valeur) and (valeur > 0) then valeur := - valeur;

      LanceurABFin := valeur;


      nbTickLanceur := TickCount - nbTickLanceur;


      if ((valeur < -64) or (valeur > 64)) and not(ValeurDeFinaleInexploitable(valeur))  then
        begin
          SysBeep(0);
          WritelnDansRapport('');
          WritelnDansRapport('ASSERT((valeur < -64) or (valeur > 64)) dans LanceurABFin!!!');
          WritelnPositionEtTraitDansRapport(plat,couleur);
          WritelnNumDansRapport('valeur = ',valeur);
          WritelnStringAndCoupDansRapport('meiDef = ',meiDef);
          WritelnStringAndCoupDansRapport('pere = ',pere);
          WritelnNumDansRapport('ESprof = ',ESprof);
          WritelnNumDansRapport('nbNoirs = ',nbNoirs);
          WritelnNumDansRapport('nbBlancs = ',nbBlancs);
          WritelnNumDansRapport('IndiceHashTableExacte = ',IndiceHashTableExacte);
          WritelnNumDansRapport('nbCoupuresHeuristiquesCettePasse = ',nbCoupuresHeuristiquesCettePasse);
          WritelnNumDansRapport('alpha = ',alpha);
          WritelnNumDansRapport('beta = ',beta);

          WriteDansRapport('interruption = ');
          EcritTypeInterruptionDansRapport(interruptionReflexion);

          LanceInterruptionSimple('LanceurABFin');
        end;


      if debuggage.algoDeFinale then
        begin
          if EstUneNoteDeETCNonValide(-valeur)
            then WriteDansRapport('  =>  PAS DANS HASH ')
            else WriteNumDansRapport('  => ',-valeur);
          WriteNumDansRapport(' (',(nbTickLanceur+30) div 60);
          WritelnDansRapport(' s)');
        end;

      {$IFC USE_DEBUG_STEP_BY_STEP}
      with gDebuggageAlgoFinaleStepByStep do
        begin
          DisposePositionEtTraitSet(positionsCherchees);
        end;
      {$ENDC}


    end;
end;



function MakeEndgameSearch(var paramMakeEndgameSearch : MakeEndgameSearchParamRec ) : boolean;

var variablesMakeEndgameSearch : variablesMakeEndgameSearchRec;
    index : SInt32;
    numeroEngine : SInt32;
    changed : boolean;



function DoitPasserFin(couleur : SInt32; var plat : plateauOthello) : boolean;
var a,x,dx,t,adversaire,n : SInt32;
begin
  adversaire := -couleur;
  for n := 1 to gNbreVides_entreeCoupGagnant do
    begin
      a := gCasesVides_entreeCoupGagnant[n];
      if plat[a] = pionVide then
        for t := dirPriseDeb[a] to dirPriseFin[a] do
          begin
            dx := dirPrise[t];
            x := a+dx;
            if plat[x] = adversaire then
              begin
                repeat
                  x := x+dx;
                until plat[x] <> adversaire;
                if (plat[x] = couleur) then
                  begin
                    DoitPasserFin := false;
                    exit(DoitPasserFin)
                  end;
              end;
          end;
    end;
  DoitPasserFin := true;
end;


function DernierCoup(var plat : plOthEndgame; couleur,couleurEnnemie,diffPions : SInt32) : SInt32;
var t,dx,x1,x2,x3,x4,x5,x6,nbprise,iCourant : SInt32;
    foo_bar_atomic_register : SInt32;
begin
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
	iCourant := gTeteListeChaineeCasesVides.next^.square;
	if plat[iCourant] = pionVide then
	  begin
	    nbprise := 0;
	    for t := dirPriseDeb[iCourant] to dirPriseFin[iCourant] do
	      begin
	        dx := dirPrise[t];
	        {on calcule les retournements suivant cette direction}
	        x1 := iCourant+dx;
					if plat[x1] = couleurEnnemie then {1}
					  begin
					    x2 := x1+dx;
					    if plat[x2] = couleurEnnemie then  {2}
					      begin
					        x3 := x2+dx;
					        if plat[x3] = couleurEnnemie then  {3}
					          begin
					            x4 := x3+dx;
					            if plat[x4] = couleurEnnemie then  {4}
						            begin
						              x5 := x4+dx;
						              if plat[x5] = couleurEnnemie then  {5}
								            begin
								              x6 := x5+dx;
								              if plat[x6] = couleurEnnemie then  {6}
										            begin
										              {seul cas à tester}
										              if plat[x6+dx] = couleur then nbprise := nbprise+12;
										            end
										          else
										            if plat[x6] = couleur then nbprise := nbprise+10;
								            end
								          else
								            if plat[x5] = couleur then nbprise := nbprise+8;
						            end
					            else
						            if plat[x4] = couleur then nbprise := nbprise+6;
					          end
					        else
					          if plat[x3] = couleur then nbprise := nbprise+4;
					      end
					    else
					      if plat[x2] = couleur then nbprise := nbprise+2;
					  end;
	      end;

	   if (nbprise > 0)
	     then
	       begin
	         DernierCoup := succ(diffPions+nbprise);
	         exit(DernierCoup);
	       end
	     else
	       begin
	        {nbprise := 0;} {deja Initialise ci-dessus}
	        for t := dirPriseDeb[iCourant] to dirPriseFin[iCourant] do
	          begin
	            dx := dirPrise[t];
	            {on calcule les retournements suivant cette direction}
	            x1 := iCourant+dx;
	            if plat[x1] = couleur then {1}
	              begin
	                x2 := x1+dx;
	                if plat[x2] = couleur then  {2}
	                  begin
	                    x3 := x2+dx;
	                    if plat[x3] = couleur then  {3}
			                  begin
			                    x4 := x3+dx;
			                    if plat[x4] = couleur then  {4}
					                  begin
					                    x5 := x4+dx;
					                    if plat[x5] = couleur then  {5}
							                  begin
							                    x6 := x5+dx;
							                    if plat[x6] = couleur then  {6}
						                        begin
								                      {seul cas à tester}
								                      if plat[x6+dx] = couleurEnnemie then nbprise := nbprise+12;
					                          end
									                else
									                  if plat[x6] = couleurEnnemie then nbprise := nbprise+10;
							                  end
							                else
							                  if plat[x5] = couleurEnnemie then nbprise := nbprise+8;
					                  end
	                        else
					                  if plat[x4] = couleurEnnemie then nbprise := nbprise+6;
			                  end
			                else
			                  if plat[x3] = couleurEnnemie then nbprise := nbprise+4;
	                  end
	                else
	                  if plat[x2] = couleurEnnemie then nbprise := nbprise+2;
	              end;
	          end;

	      if (nbPrise > 0)
	        then
	          begin
	            DernierCoup := pred(diffPions-nbprise);
	            exit(DernierCoup);
	          end
	        else
	          begin
	            if diffPions > 0 then
	              begin
	                DernierCoup := succ(diffPions);  {une case vide au vainqueur}
	                exit(DernierCoup);
	              end;
	            if diffPions < 0 then
	              begin
	                DernierCoup := pred(diffPions);  {une case vide au vainqueur}
	                exit(DernierCoup);
	              end;
	            DernierCoup := 0;             {nulle}
	            exit(DernierCoup);
	          end;
	     end
	  end;
  DernierCoup := diffPions;  {pas de case vide}
end;   { DernierCoup }


{ABFinPetite pour les petites profondeurs ( <= profForceBrute )}
function ABFinPetite(var plat : plOthEndgame; couleur,ESprof,alpha,beta,diffPions : SInt32; vientDePasser : boolean) : SInt32;
var platEssai : plOthEndgame;
    DiffEssai : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    aJoue : boolean;
    iCourant,constanteDePariteDeiCourant : SInt32;
    celluleDansListeChaineeCasesVides : celluleCaseVideDansListeChaineePtr;
    celluleDepart : celluleCaseVideDansListeChaineePtr;
    foo_bar_atomic_register : SInt32;

begin
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);

  adversaire := -couleur;
  profMoins1 := pred(ESprof);
  maxPourBestDefABFinPetite := -noteMax;
  aJoue := false;
  platEssai := plat;
  DiffEssai := diffPions;

  (*
  if (ESprof >= 3) then
    begin
		  WritelnDansRapport('');
		  WritelnPositionEtTraitDansRapport(plat,couleur);
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAND(gVecteurParite,constanteDeParite[11]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAND(gVecteurParite,constanteDeParite[18]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAND(gVecteurParite,constanteDeParite[81]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAND(gVecteurParite,constanteDeParite[88]) = 0);
		  AttendFrappeClavier;
		end;
  *)

{impairs:}
  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  repeat
    with celluleDansListeChaineeCasesVides^ do
      begin
        iCourant := square;
        constanteDePariteDeiCourant := constantePariteDeSquare;

        if (ESprof < 3) or (BAND(gVecteurParite,constanteDePariteDeiCourant) <> 0) then


        if ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platEssai,diffEssai)
          then
	          BEGIN
		          aJoue := true;

		          if (ESprof >= 3) then
		            gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);

		         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
		          previous^.next := next;
		          next^.previous := previous;
		          if (profMoins1 = 1)
		            then noteCourante := -DernierCoup(platEssai,adversaire,couleur,-diffEssai)
		            else noteCourante := -ABFinPetite(platEssai,adversaire,profMoins1,-beta,-alpha,-diffEssai,false);
		         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
		          previous^.next := celluleDansListeChaineeCasesVides;
						  next^.previous := celluleDansListeChaineeCasesVides;

						 if (ESprof >= 3) then
		            gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);

		          if (noteCourante > maxPourBestDefABFinPetite) then
		             begin
		               maxPourBestDefABFinPetite := noteCourante;
		               if (noteCourante > alpha) then
		                 begin
		                   alpha := noteCourante;
		                   if (alpha >= beta) then
		                      begin
		                        ABFinPetite := maxPourBestDefABFinPetite;
		                        exit(ABFinPetite);
		                      end;
		                 end;
		             end;
						  platEssai := plat;
		          diffEssai := diffPions;
            END;
        celluleDansListeChaineeCasesVides := next;
      end;
  until celluleDansListeChaineeCasesVides = celluleDepart;

{pairs:}
if (ESprof >= 3) then
  begin

  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  repeat
    with celluleDansListeChaineeCasesVides^ do
      begin
        iCourant := square;
        constanteDePariteDeiCourant := constantePariteDeSquare;

        if BAND(gVecteurParite,constanteDePariteDeiCourant) = 0 then

        if ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platEssai,diffEssai)
          then
	          BEGIN
		          aJoue := true;

		          gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);
		         {EnleverDeLaListeChaineeDesCasesVides(iCourant)}
		          previous^.next := next;
		          next^.previous := previous;
		          if (profMoins1 = 1)
		            then noteCourante := -DernierCoup(platEssai,adversaire,couleur,-diffEssai)
		            else noteCourante := -ABFinPetite(platEssai,adversaire,profMoins1,-beta,-alpha,-diffEssai,false);
		         {RemettreDansLaListeChaineeDesCasesVides(iCourant);}
		          previous^.next := celluleDansListeChaineeCasesVides;
						  next^.previous := celluleDansListeChaineeCasesVides;
						  gVecteurParite := BXOR(gVecteurParite,constanteDePariteDeiCourant);

		          if (noteCourante > maxPourBestDefABFinPetite) then
		             begin
		               maxPourBestDefABFinPetite := noteCourante;
		               if (noteCourante > alpha) then
		                 begin
		                   alpha := noteCourante;
		                   if (alpha >= beta) then
		                      begin
		                        ABFinPetite := maxPourBestDefABFinPetite;
		                        exit(ABFinPetite);
		                      end;
		                 end;
		             end;
						  platEssai := plat;
		          diffEssai := diffPions;
            END;
        celluleDansListeChaineeCasesVides := next;
      end;
  until celluleDansListeChaineeCasesVides = celluleDepart;
 end;

{fin:}
 if aJoue
   then
     begin
       ABFinPetite := maxPourBestDefABFinPetite;
     end
   else
     begin
       if vientDePasser then
         begin
           if diffPions > 0 then
             begin
               ABFinPetite := diffPions + ESprof;
               exit(ABFinPetite);
             end;
           if diffPions < 0 then
             begin
               ABFinPetite := diffPions - ESprof;
               exit(ABFinPetite);
             end;
           ABFinPetite := 0;
           exit(ABFinPetite);
         end
       else
         ABFinPetite := -ABFinPetite(plat,adversaire,ESprof,-beta,-alpha,-diffPions,true);
     end;
end;   { ABFinPetite }


function DernierCoupPourSuite(var plat : plOthEndgame; var meiDef : SInt32; couleur,adversaire,diffPions : SInt32) : SInt32;
var i,x,t,dx,nbprise,compteur,iCourant : SInt32;
    modifie : boolean;
    foo_bar_atomic_register : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin
       ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);

       for i := 1 to gNbreVides_entreeCoupGagnant do
       BEGIN
        iCourant := gCasesVides_entreeCoupGagnant[i];
        if plat[iCourant] = pionVide then
          begin
            {if modifScoreFin(iCourant,couleur,plat,nBla,nNoi) }

            modifie := false; nbprise := 0;
            for t := dirPriseDeb[iCourant] to dirPriseFin[iCourant] do
              begin
                  dx := dirPrise[t];
                  x := iCourant+dx;
                  if plat[x] = adversaire then
                    begin
                      compteur := 0;
                      repeat
                        inc(compteur);
                        x := x+dx;
                      until plat[x] <> adversaire;
                      if (plat[x] = couleur) then
                         begin
                            modifie := true;
                            nbprise := nbprise+compteur;
                         end;
                    end;
               end;

           if modifie
             then
                begin
                  meiDef := iCourant;
                  meilleuresuite[1,1] := meiDef;
                  DernierCoupPourSuite := succ(diffPions+nbprise+nbprise);
                  exit(DernierCoupPourSuite);
                end
              else
                begin
                  {if modifScoreFin(iCourant,adversaire,plat,nBla,nNoi) }


                    {modifie := false; nbprise := 0;}                   {deja Initialises ci-dessus}
                    for t := dirPriseDeb[iCourant] to dirPriseFin[iCourant] do
                      begin
                          dx := dirPrise[t];
                          x := iCourant+dx;
                          if plat[x] = couleur then
                            begin
                              compteur := 0;
                              repeat
                                inc(compteur);
                                x := x+dx;
                              until plat[x] <> couleur;
                              if (plat[x] = adversaire) then
                                begin
                                   modifie := true;
                                   nbprise := nbprise+compteur;
                                end;
                            end;
                       end;

                   if modifie
                    then
                      begin
                        meiDef := iCourant;
                        meilleuresuite[1,1] := meiDef;
                        DernierCoupPourSuite := pred(diffPions-nbprise-nbprise);
                        exit(DernierCoupPourSuite);
                      end
                    else
                      begin
                        meiDef := 44;
                        meilleuresuite[1,1] := 0;
                        if diffPions > 0 then
                          begin
                            DernierCoupPourSuite := succ(diffPions);
                            exit(DernierCoupPourSuite);
                          end;
                        if diffPions < 0 then
                          begin
                            DernierCoupPourSuite := pred(diffPions);
                            exit(DernierCoupPourSuite);
                          end;
                        DernierCoupPourSuite := 0;
                        exit(DernierCoupPourSuite);
                      end;
                end
          end;
       END;
      DernierCoupPourSuite := diffPions;    {pas de case vide}

    end;
end;   { DernierCoupPourSuite }


function ABFinPetitePourSuite(var plat : plOthEndgame; var meiDef : SInt32; couleur,ESprof,alpha,beta,diffPions : SInt32;
                              vientDePasser : boolean) : SInt32;
{ABFinPetitePourSuite pour les petites profondeurs ( <= profForceBrute )}
var platEssai : plOthEndgame;
    diffEssai : SInt32;
    i,k : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetitePourSuite : SInt32;
    aJoue : boolean;
    nbVidesTrouvees,nbCoupsPourCoul : SInt32;
    iCourant : SInt32;
    bestSuite : SInt32;
    listeCasesVides : listeVides;
    foo_bar_atomic_register : SInt32;
label fin;
begin
  with variablesMakeEndgameSearch do
    begin

      if (interruptionReflexion = pasdinterruption) then
        begin
    	   if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
    	   ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);

    	   adversaire := -couleur;
    	   profMoins1 := pred(ESprof);
    	   maxPourBestDefABFinPetitePourSuite := -noteMax;
    	   aJoue := false;

    	   platEssai := plat;
    	   diffEssai := diffPions;

    	   nbVidesTrouvees := EtablitListeCasesVidesParOrdreJCW(plat,ESprof,listeCasesVides);
    	   if ESprof >= 9
    	     then nbCoupsPourCoul := TrierSelonDivergenceSansMilieu(plat,couleur,nbVidesTrouvees,listeCasesVides,listeCasesVides)
    	     else nbCoupsPourCoul := nbVidesTrouvees;

    	   (*
    	   WritelnPositionEtTraitDansRapport(plat,couleur);
    	   WritelnNumDansRapport('ESprof = ',ESprof);
    	   WritelnNumDansRapport('nbCoupsPourCoul = ',nbCoupsPourCoul);
    	   for i := 1 to nbCoupsPourCoul do
    	     begin
    	       WriteNumDansRapport('-- ',listeCasesVides[i]);
    	       WriteStringAndCoupDansRapport(' ',listeCasesVides[i]);
    	     end;
    	   WritelnDansRapport('');
    	   AttendFrappeClavier;
    	   *)

    	   for i := 1 to nbCoupsPourCoul do
    		   BEGIN
    		    iCourant := listeCasesVides[i];
    		    if plat[iCourant] = pionVide then
    		      begin
    		        if ModifPlatFinDiffFastLongint(iCourant,couleur,adversaire,platEssai,diffEssai) then
    		          BEGIN
    		           aJoue := true;
    		           EnleverDeLaListeChaineeDesCasesVides(iCourant);
    		           if (profMoins1 <= 1)
    		             then noteCourante := -DernierCoupPourSuite(platEssai,bestSuite,adversaire,couleur,-diffEssai)
    		             else noteCourante := -ABFinPetitePourSuite(platEssai,bestSuite,adversaire,profMoins1,-beta,-alpha,-diffEssai,false);
    		           RemettreDansLaListeChaineeDesCasesVides(iCourant);

    		           if (noteCourante > maxPourBestDefABFinPetitePourSuite) then
    		              begin

    		                maxPourBestDefABFinPetitePourSuite := noteCourante;
    		                meiDef := iCourant;
    		                for k := 1 to profMoins1 do
    		                   meilleureSuite[ESprof,k] := meilleureSuite[profMoins1,k];
    		                meilleureSuite[ESprof,ESprof] := meiDef;

    		                if (noteCourante > alpha) then
    		                  begin
    		                    alpha := noteCourante;
    		                    if (alpha >= beta) then
    		                       begin
    		                         ABFinPetitePourSuite := maxPourBestDefABFinPetitePourSuite;
    		                         exit(ABFinPetitePourSuite);
    		                       end;
    		                  end;
    		              end;
    		           platEssai := plat;
    		           diffEssai := diffPions;
    		          END;
    		       end;
    		   END;

    	 fin:
    	  if aJoue
    	    then
    	      begin
    	        ABFinPetitePourSuite := maxPourBestDefABFinPetitePourSuite;
    	      end
    	    else
    	      begin
    	        if vientDePasser then
    	          begin
    	            for k := 1 to ESprof do meilleureSuite[ESprof,k] := 0;
    	            if diffPions > 0 then
    	              begin
    	                ABFinPetitePourSuite := diffPions + ESprof;
    	                exit(ABFinPetitePourSuite);
    	              end;
    	            if diffPions < 0 then
    	              begin
    	                ABFinPetitePourSuite := diffPions - ESprof;
    	                exit(ABFinPetitePourSuite);
    	              end;
    	            ABFinPetitePourSuite := 0;
    	            exit(ABFinPetitePourSuite);
    	          end
    	        else
    	          ABFinPetitePourSuite := -ABFinPetitePourSuite(plat,meiDef,adversaire,ESprof,-beta,-alpha,-diffPions,true);
    	      end;
    	 end;    {if not(interromp) }

    end;

end;   { ABFinPetitePourSuite }







function ABPreOrdre(var plat : plateauOthello; var InfosMilieuDePartie : InfosMilieuRec; var meiDef : SInt32;
                 pere,couleur,ESprof : SInt32; fenetre : SearchWindow; canDoProbCut : boolean) : SearchResult;
var platEssai : plateauOthello;
    InfosMilieuEssai : InfosMilieuRec;
    {nbBlcEssai,nbNrEssai : SInt32;
    frontEssai : InfoFront;
    }
    i : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SearchResult;
    nbCoupsPourCoul : SInt32;
    maxPourBestDef : SearchResult;
    aJoue : boolean;
    coupLegal : boolean;
    nbEvalue : SInt32;
    iCourant : SInt32;
    clefHashConseil,conseilHash : SInt32;
    bestSuite,nbVidesTrouvees : SInt32;
    caseTestee : SInt32;
    nbEvalRecursives : SInt32;
    listeCasesVides,listeTemp : listeVides;
    listeFinale : listeVides;
    evaluerMaintenant : boolean;
    DoitRemplirTableHashSimple : boolean;
    utiliseMilieuDePartiePourTrier : boolean;
    suffisamentLoinDesFeuillesDeLArbre : boolean;
    listeFinaleFromScratch : boolean;
    distanceProfArret : SInt32;
    nroTableExacte : SInt32;
    clefHashExacte : SInt32;
    codagePosition : codePositionRec;
    quelleHashTableExacte : HashTableExactePtr;
    quelleHashTableCoupsLegaux : CoupsLegauxHashPtr;
    ameliorationsAlpha : AmeliorationsAlphaRec;
    bornes : DecompressionHashExacteRec;
    nouvelleFenetre : SearchWindow;
    alphaPourEval : SInt32;
    betaPourEval : SInt32;
    oldAlpha : SInt32;
    ameliorationMinimax : boolean;
    ameliorationProofNumber : boolean;
    evalDuCoup : SInt32;
    valeurDeLaPosition : SInt32;
    nbCasesVides : SInt32;
    distanceALaRacine : SInt32;
    typePropagation : SInt32;
    probableFailLow : boolean;
    probableFailHigh : boolean;
    foo_bar_atomic_register : SInt32;
    evaluationDeLaPosition : SInt32;


    function CaseVideIsolee(CaseVide : SInt32) : boolean;
	  var t : SInt32;
	  begin
	    for t := DirVoisineDeb[CaseVide] to DirVoisineFin[caseVide] do
	      if plat[CaseVide+DirVoisine[t]] = pionVide then
	        begin
	          CaseVideIsolee := false;
	          exit(CaseVideIsolee);
	        end;
	    CaseVideIsolee := true;
	  end;

		procedure EtablitListeCasesVidesPreordre;
		var i : SInt32;
    begin
      nbVidesTrouvees := 0;
      i := 0;
      repeat
        inc(i);
        caseTestee := gListeCasesVidesOrdreJCWCoupGagnant[i];
        if plat[caseTestee] = pionVide then
		      begin
		        inc(nbVidesTrouvees);
		        listeCasesVides[nbVidesTrouvees] := caseTestee;
		      end;
		  until nbVidesTrouvees >= ESprof;
    end;


   {cases isolées d'abord}
   procedure TrierCasesVidesIsolees;
   var ii,j,k : SInt32;
   begin
     if plat[conseilHash] = pionVide
       then
         begin
           j := 1;
           k := 0;
           for ii := 1 to nbVidesTrouvees do
             begin
               caseTestee := listeCasesVides[ii];
               if caseTestee = conseilHash
                 then
                   begin
                     listeFinale[1]           := listeCasesVides[ii];
                   end
                 else
                   if CaseVideIsolee(caseTestee)
                     then
                       begin
                         inc(j);
                         listeFinale[j]           := listeCasesVides[ii];
                       end
                     else
                       begin
                         inc(k);
                         listeTemp[k]           := listeCasesVides[ii];
                       end;
              end;
         end
       else
         begin
           j := 0;
           k := 0;
           for ii := 1 to nbVidesTrouvees do
             if CaseVideIsolee(listeCasesVides[ii])
               then
                 begin
                   inc(j);
                   listeFinale[j]           := listeCasesVides[ii];
                 end
               else
                 begin
                   inc(k);
                   listeTemp[k]           := listeCasesVides[ii];
                 end;
          end;
     for ii := 1 to k do
       begin
         listeFinale[j+ii]           := listeTemp[ii];
       end;
   end;


  procedure TryAlphaProbCut(profDepart,profArrivee,fenetre_alpha : SInt32);
  var SeuilProbCut : SearchWindow;
      t : SearchResult;
      tempoProfArret : SInt32;
  begin     {$UNUSED profDepart}

    with variablesMakeEndgameSearch do
      begin
        tempoProfArret := profondeurArretPreordre;
        profondeurArretPreordre := ESprof - profArrivee;

        SeuilProbCut := MakeNullWindow(DecalerSearchResult(fenetre.alpha, -fenetre_alpha));
        t := ABPreOrdre(plat,InfosMilieuDePartie,meiDef,pere,couleur,ESprof,SeuilProbCut,false);
        if FailSoltInWindow(t,SeuilProbCut) then
          begin
            profondeurArretPreordre := tempoProfArret;
            ABPreOrdre := fenetre.alpha;
            exit(ABPreOrdre);
          end;

        profondeurArretPreordre := tempoProfArret;
      end;
  end;


  procedure TryBetaProbCut(profDepart,profArrivee,fenetre_beta : SInt32);
  var SeuilProbCut : SearchWindow;
      t : SearchResult;
      tempoProfArret : SInt32;
  begin     {$UNUSED profDepart}

     with variablesMakeEndgameSearch do
      begin
        tempoProfArret := profondeurArretPreordre;
        profondeurArretPreordre := ESprof - profArrivee;

        SeuilProbCut := MakeNullWindow(DecalerSearchResult(fenetre.beta, fenetre_beta-1));
        t := ABPreOrdre(plat,InfosMilieuDePartie,meiDef,pere,couleur,ESprof,SeuilProbCut,false);
        if FailHighInWindow(t,SeuilProbCut) then
          begin
            profondeurArretPreordre := tempoProfArret;
            ABPreOrdre := fenetre.beta;
            exit(ABPreOrdre);
          end;

        profondeurArretPreordre := tempoProfArret;
      end;
  end;

  procedure DoProbCutFinale(profDepart,profArrivee,fenetre_alpha,fenetre_beta : SInt32);
  var eval : SInt32;
      nbEvalRecursives : SInt32;
  begin     {$UNUSED profDepart}

     with variablesMakeEndgameSearch do
      begin
        alphaPourEval := GetWindowAlphaEnMidgameEval(fenetre);
        betaPourEval := GetWindowBetaEnMidgameEval(fenetre);

        if (profArrivee > 2) and (alphaPourEval > -20000) and (betaPourEval < 20000)
          then
            begin

              with InfosMilieuDePartie do
                eval := Evaluation(plat,couleur,nbBlancs,nbNoirs,jouable,frontiere,false,alphaPourEval,betaPourEval,nbEvalRecursives);

              if Abs(eval-alphaPourEval) < Abs(eval-betaPourEval)
                then
                  begin
                    TryAlphaProbCut(profDepart,profArrivee,fenetre_alpha);
                    TryBetaProbCut(profDepart,profArrivee,fenetre_beta);
                  end
                else
                  begin
                    TryBetaProbCut(profDepart,profArrivee,fenetre_alpha);
                    TryAlphaProbCut(profDepart,profArrivee,fenetre_beta);
                  end;
            end
          else
            begin
              if (alphaPourEval > -20000) then TryAlphaProbCut(profDepart,profArrivee,fenetre_alpha);
              if (betaPourEval  <  20000) then TryBetaProbCut(profDepart,profArrivee,fenetre_beta);
            end;
      end;
  end;


begin  {ABPreordre}
  with variablesMakeEndgameSearch do
    begin
       ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
       if (interruptionReflexion = pasdinterruption) then
       begin
         if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);



         nbCasesVides := (64 - InfosMilieuDePartie.nbBlancs - InfosMilieuDePartie.nbNoirs);
         distanceALaRacine := (gNbreVides_entreeCoupGagnant - nbCasesVides);
         if (distanceALaRacine <= gProfondeurCoucheProofNumberSearch)
           then typePropagation := kPropagationProofNumber
           else typePropagation := kPropagationMinimax;




         distanceProfArret := ESprof-profondeurArretPreordre;
         suffisamentLoinDesFeuillesDeLArbre := true;

         alphaPourEval := GetWindowAlphaEnMidgameEval(fenetre);
         betaPourEval := GetWindowBetaEnMidgameEval(fenetre);

         probableFailLow  := false;
         probableFailHigh := false;
      	 utiliseMilieuDePartiePourTrier := suffisamentLoinDesFeuillesDeLArbre and
      		                                (ESprof >= profMinimalePourClassementParMilieu)
      		                                and (alphaPourEval < 6000) and (betaPourEval > -6000);

         adversaire := -couleur;
         profMoins1 := pred(ESprof);
         maxPourBestDef := InitialiseSearchResult;
         listeFinaleFromScratch := true;

         (*
         if debuggage.preordonancementDesCoupsEnFinale then
           begin
             WritelnDansRapport('');
             WritelnDansRapport('Entrée dans ABPreordre');
             WritelnPositionEtTraitDansRapport(plat,couleur);
             WritelnStringAndCoupDansRapport('pere = ',pere);
             WritelnNumDansRapport('ESprof = ',ESprof);
             WritelnNumDansRapport('nbCasesVides = ',nbCasesVides);
             WritelnNumDansRapport('distanceProfArret = ',distanceProfArret);
             WritelnNumDansRapport('distanceALaRacine = ',distanceALaRacine);
             if typePropagation = kPropagationMinimax
               then WritelnDansRapport('propagation minimax')
               else WritelnDansRapport('propagation proof number search');
           end;
         *)

         if (canDoProbCut and IsNullWindow(fenetre)) then
      	   begin
      	      {if beta > alpha+1 then
      	        begin
      	          EssaieSetPortWindowPlateau;
      	          EcritPositionAt(pl,10,10);
      	          WriteNumAt('alpha = ',alpha,10,150);
      	          WriteNumAt('beta = ',beta,100,150);
      	          WriteNumAt('prof = ',prof,200,150);
      	        end;}



      	     if (distanceProfArret =  3) then DoProbCutFinale( 3,1,largFenetreProbCut,largFenetreProbCut) else
      	     if (distanceProfArret =  4) then DoProbCutFinale( 4,2,largFenetreProbCut,largFenetreProbCut) else
      	     if (distanceProfArret =  5) then DoProbCutFinale( 5,1,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
      	     if (distanceProfArret =  6) then DoProbCutFinale( 6,2,largFenetreProbCut,largFenetreProbCut) else
      	     if (distanceProfArret =  7) then DoProbCutFinale( 7,3,largFenetreProbCut,largFenetreProbCut) else
      	     if (distanceProfArret =  8) then DoProbCutFinale( 8,4,largFenetreProbCut,largFenetreProbCut) else
      	     if (distanceProfArret =  9) then DoProbCutFinale( 9,3,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
      	     if (distanceProfArret =  9) then DoProbCutFinale( 9,5,largFenetreProbCut,largFenetreProbCut);
      	     if (distanceProfArret = 10) then DoProbCutFinale(10,4,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
      	     if (distanceProfArret = 10) then DoProbCutFinale(10,6,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
      	     if (distanceProfArret = 11) then DoProbCutFinale(11,3,largGrandeFenetreProbCut,largGrandeFenetreProbCut);
      	     if (distanceProfArret = 11) then DoProbCutFinale(11,5,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
      	     if (distanceProfArret = 12) then DoProbCutFinale(12,4,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
      	     if (distanceProfArret = 13) then DoProbCutFinale(13,5,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
      	     if (distanceProfArret = 14) then DoProbCutFinale(14,4,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
      	     if (distanceProfArret = 15) then DoProbCutFinale(15,5,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
      	     if (distanceProfArret = 16) then DoProbCutFinale(16,6,largGrandeFenetreProbCut,largGrandeFenetreProbCut) else
      	     if (distanceProfArret = 17) then DoProbCutFinale(17,5,largGrandeFenetreProbCut,largGrandeFenetreProbCut);



      	   end;  {if canDoProbCut}




         conseilHash := 0;
         DoitRemplirTableHashSimple := (ESprof >= profondeurRemplissageHash);
         {DoitRemplirTableHashSimple := false;}

         if (ESprof >= ProfUtilisationHash)
           then
             begin
               gClefHashage := BXOR(gClefHashage , (IndiceHash^^[couleur,pere]));
               if ESprof >= profondeurRemplissageHash then
                 begin
                   clefHashConseil := BAND(gClefHashage,32767);
                   conseilHash := HashTable^^[clefHashConseil];
                 end;

               if (ESprof >= ProfPourHashExacte) then
                 begin

                   nroTableExacte := BAND(gClefHashage div 1024,nbTablesHashExactesMoins1);
                   clefHashExacte := BAND(gClefHashage,1023);

                   {WritelnNumDansRapport('clefHashExacte (2) = ',clefHashExacte);}

                   quelleHashTableExacte := HashTableExacte[nroTableExacte];
                   quelleHashTableCoupsLegaux := CoupsLegauxHash[nroTableExacte];

                   CreeCodagePosition(plat,couleur,ESprof,codagePosition);
                   if InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,gClefHashage,clefHashExacte)
                     then
                       begin
                         listeFinaleFromScratch := PasListeFinaleStockeeDansHash(ESprof,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale,nbCoupsPourCoul);

                         DecompresserBornesHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                         meiDef := GetBestDefenseDansHashExacte(quelleHashTableExacte^[clefHashExacte]);
                         {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
                         CompresserBornesDansHashTableExacte(quelleHashTableExacte^[clefHashExacte],bornes);
                         {$ENDC}

                         if MeilleurCoupEstStockeDansLesBornes(bornes,meiDef,valeurDeLaPosition) then
                           begin
                             if ESprof >= ProfUtilisationHash then
                               begin
                                 if DoitRemplirTableHashSimple then HashTable^^[clefHashConseil] := meiDef;
                                 gClefHashage := BXOR(gClefHashage, (IndiceHash^^[couleur,pere]));
                               end;

                             ABPreOrdre := MakeSearchResultForSolvedPosition(bornes.valMin[nbreDeltaSuccessifs]);
                             exit(ABPreOrdre);
                           end;
                       end
                     else
                       begin
                         ExpandHashTableExacte(quelleHashTableExacte^[clefHashExacte],quelleHashTableCoupsLegaux,codagePosition,clefHashExacte);
                       end;
                 end;
              end;

         if listeFinaleFromScratch
           then
      	     begin

      	       EtablitListeCasesVidesPreordre;
      	       nbCoupsPourCoul := nbVidesTrouvees;
      	       TrierCasesVidesIsolees;

      	       {$IFC USE_DEBUG_STEP_BY_STEP}
        	     if gDebuggageAlgoFinaleStepByStep.actif and
                   (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
                   MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                  begin
                    WritelnDansRapport('');
                    WritelnDansRapport('Après TrierCasesVidesIsolees dans ABPreOrdre :');
                    for i := 1 to nbCoupsPourCoul do
                      WriteStringAndCoupDansRapport('>',listeFinale[i]);
                    WritelnDansRapport('');
                  end;
               {$ENDC}

      	       if ESprof >= profPourTriSelonDivergence then
      	         begin
      	           alphaPourEval := GetWindowAlphaEnMidgameEval(fenetre);
                   betaPourEval := GetWindowBetaEnMidgameEval(fenetre);
      	           nbCoupsPourCoul := TrierSelonDivergenceAvecMilieu(plat,couleur,nbCoupsPourCoul,conseilHash,listeFinale,listeFinale,InfosMilieuDePartie,
      	                                                             alphaPourEval,betaPourEval,probableFailLow,probableFailHigh,
      	                                                             utiliseMilieuDePartiePourTrier,evaluationDeLaPosition);
      	         end;

      	       {$IFC USE_DEBUG_STEP_BY_STEP}
      	       if gDebuggageAlgoFinaleStepByStep.actif and
                 (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
                 MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                begin
                  WritelnNumDansRapport('ESprof = ',ESprof);
                  WritelnNumDansRapport('profPourTriSelonDivergence = ',profPourTriSelonDivergence);
                  WritelnNumDansRapport('profMinimalePourClassementParMilieu = ',profMinimalePourClassementParMilieu);
                  WritelnStringAndBoolDansRapport('utiliseMilieuDePartiePourTrier = ',utiliseMilieuDePartiePourTrier);
                  if (ESprof >= profPourTriSelonDivergence) then
                    begin
                      WritelnDansRapport('Après TrierSelonDivergenceAvecMilieu :');
                      for i := 1 to nbCoupsPourCoul do
                        WriteStringAndCoupDansRapport('>',listeFinale[i]);
                      WritelnDansRapport('');
                      WritelnDansRapport('');
                    end;
                end;
      	       {$ENDC}

      	     end
      	   else
      	     begin
      	       (*
      	        if (ESprof >= profPourTriSelonDivergence) and suffisamentLoinDesFeuillesDeLArbre and
      	          (ESprof >= ProfPourHashExacte) and (BAND(quelleHashTableExacte^[clefHashExacte].flags,kMaskRecalculerCoupsLegaux) <> 0)
      	         then TrierSelonDivergenceAvecMilieu(listeFinale,listeFinale);
      	       *)

      	       {$IFC USE_DEBUG_STEP_BY_STEP}
      	       if gDebuggageAlgoFinaleStepByStep.actif and
                   (ESProf >= gDebuggageAlgoFinaleStepByStep.profMin) and
                   MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
                  begin
                    WritelnDansRapport('');
                    WritelnDansRapport('Liste des coups stockee dans la table de hachage dans ABPreOrdre :');
                    for i := 1 to nbCoupsPourCoul do
                      WriteStringAndCoupDansRapport('>',listeFinale[i]);
                    WritelnDansRapport('');
                  end;
               {$ENDC}

      	     end;



         aJoue := false;
         nbEvalue := 0;
         meiDef := 0;
         ameliorationsAlpha.cardinal := 0;

         platEssai := plat;
         InfosMilieuEssai := InfosMilieuDePartie;


         for i := 1 to nbCoupsPourCoul do
             BEGIN
              iCourant := listeFinale[i];

              (*** pour debugage seulement ***)
              {if iCourant < 11 then AlerteSimple('Debugger : iCourant = '+NumEnString(iCourant)+' dans ABPreordre') else
              if iCourant > 88 then AlerteSimple('Debugger : iCourant = '+NumEnString(iCourant)+' dans ABPreordre') else
              if platEssai[iCourant] <> pionVide then AlerteSimple('Debugger : platEssai['+NumEnString(iCourant)+'] <> 0 dans ABPreordre');
              }

              //WritelnNumDansRapport('ABPreordre, coup = ',iCourant);

              with InfosMilieuEssai do
                coupLegal := (platEssai[iCourant] = pionVide) and ModifPlatLongint(iCourant,couleur,platEssai,jouable,nbBlancs,nbNoirs,frontiere);

              if coupLegal then
                begin
                  aJoue := true;

                  EnleverDeLaListeChaineeDesCasesVides(iCourant);

                  if (profMoins1 <= profondeurArretPreordre-2)
                    then
                      begin
                        evaluerMaintenant := true;
                      end
                    else
                      if (profMoins1 > profondeurArretPreordre)
                        then evaluerMaintenant := false
                        else
                          begin
                            evaluerMaintenant := true;
                            if evaluerMaintenant and not(utilisationNouvelleEval) then
                              evaluerMaintenant := PasDeBordDeCinqAttaque(adversaire,InfosMilieuEssai.frontiere,platessai);
                          end;


                  if evaluerMaintenant
                    then
                      begin
                        with InfosMilieuEssai do
                          begin
                            alphaPourEval := GetWindowAlphaEnMidgameEval(fenetre);
                            betaPourEval := GetWindowBetaEnMidgameEval(fenetre);

                            evalDuCoup := Evaluation(platEssai,adversaire,nbBlancs,nbNoirs,jouable,frontiere,false,-betaPourEval,-alphaPourEval,nbEvalRecursives);

                            noteCourante := ReverseResult(MakeSearchResultFromHeuristicValue(evalDuCoup));

                          end;
                      end
                    else
                     begin
                      if (nbEvalue <= 0) or IsNullWindow(fenetre)
                       then
                         begin
                          noteCourante := ReverseResult(ABPreOrdre(platEssai,InfosMilieuEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                        ReverseWindow(fenetre),canDoProbCut));
                          inc(nbEvalue);
                         end
                       else
                         begin
                            nouvelleFenetre := MakeNullWindow(fenetre.alpha);
                            noteCourante := ReverseResult(ABPreOrdre(platEssai,InfosMilieuEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                          ReverseWindow(nouvelleFenetre),canDoProbCut));

                            if ResultInsideWindow(noteCourante,fenetre) then
                              begin
                                nouvelleFenetre := MakeSearchWindow(noteCourante,fenetre.beta);
                                noteCourante := ReverseResult(ABPreOrdre(platEssai,InfosMilieuEssai,bestSuite,iCourant,adversaire,profMoins1,
                                                              ReverseWindow(nouvelleFenetre),canDoProbCut));

                                if IsNullWindow(MakeSearchWindow(fenetre.alpha,noteCourante))
                                  then noteCourante := fenetre.alpha;
                              end;
                         end;
                      end;

                   RemettreDansLaListeChaineeDesCasesVides(iCourant);

                   (*
                   if (typePropagation = kPropagationProofNumber) then
                     begin
                       WritelnDansRapport('');
                       WritelnDansRapport('avant UpdateSearchResult');
                       WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
                       WritelnStringAndReelDansRapport('noteCourante.PN = ',GetProofNumberOfResult(noteCourante),15);
                       WritelnStringAndReelDansRapport('noteCourante.DP = ',GetDisproofNumberOfResult(noteCourante),15);
                       WritelnStringAndReelDansRapport('maxPourBestDef.PN = ',GetProofNumberOfResult(maxPourBestDef),15);
                       WritelnStringAndReelDansRapport('maxPourBestDef.DP = ',GetDisproofNumberOfResult(maxPourBestDef),15);
                     end;
                   *)

                   UpdateSearchResult(maxPourBestDef,noteCourante,ameliorationMinimax,ameliorationProofNumber);

                   (*
                   if (typePropagation = kPropagationProofNumber) then
                     begin
                       WritelnDansRapport('après UpdateSearchResult');
                       WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
                       WritelnStringAndReelDansRapport('noteCourante.PN = ',GetProofNumberOfResult(noteCourante),15);
                       WritelnStringAndReelDansRapport('noteCourante.DP = ',GetDisproofNumberOfResult(noteCourante),15);
                       WritelnStringAndReelDansRapport('maxPourBestDef.PN = ',GetProofNumberOfResult(maxPourBestDef),15);
                       WritelnStringAndReelDansRapport('maxPourBestDef.DP = ',GetDisproofNumberOfResult(maxPourBestDef),15);
                       WritelnStringAndBoolDansRapport('ameliorationProofNumber = ',ameliorationProofNumber);
                     end;
                   *)


                   if (ameliorationMinimax and (typePropagation = kPropagationMinimax)) or
                      (ameliorationProofNumber and (typePropagation = kPropagationProofNumber)) then
                      begin

                        meiDef := iCourant;

                        oldAlpha := GetWindowAlphaEnMidgameEval(fenetre);
                        if UpdateSearchWindow(maxPourBestDef,fenetre) or
                           (ameliorationProofNumber and (typePropagation = kPropagationProofNumber)) then
                          begin

                            with ameliorationsAlpha do
                              begin
      		                      inc(cardinal);
      		                      with liste[cardinal] do
      		                        begin
      		                          coup := iCourant;
      		                          val := GetWindowAlphaEnMidgameEval(fenetre);
      		                          alphaAvant := oldAlpha;
      		                        end;
      		                    end;


                            if (ESprof >= ProfPourHashExacte) then
                              begin
                                MetPosDansHashTableExacteEndgame(quelleHashTableExacte^[clefHashExacte],codagePosition,kEvaluationNonFaite);
                                if (ameliorationsAlpha.cardinal >= 2)
                                  then MetAmeliorationsAphaPuisCoupsLegauxDansHash(1,nbCoupsPourCoul,ameliorationsAlpha,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale)
                                  else MetCoupEnTeteEtAttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,iCourant,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                                ValiderCetteEntreeCoupsLegauxHash(quelleHashTableExacte^[clefHashExacte],suffisamentLoinDesFeuillesDeLArbre);
                                SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);
                              end;

                            if (AlphaBetaCut(fenetre) and (typePropagation = kPropagationMinimax)) then
                               begin
                                 ABPreOrdre := maxPourBestDef;
                                 if ESprof >= ProfUtilisationHash  then
                                   begin
                                     if DoitRemplirTableHashSimple then
                                       HashTable^^[clefHashConseil] := meiDef;
                                     gClefHashage := BXOR(gClefHashage, (IndiceHash^^[couleur,pere]));
                                   end;
                                 exit(ABPreOrdre)
                               end;
                          end;
                      end;

                   platEssai := plat;
                   InfosMilieuEssai := InfosMilieuDePartie;
               end;
           END;


        if aJoue
          then
            begin

              if ESprof >= ProfUtilisationHash then
                begin
                  if DoitRemplirTableHashSimple then HashTable^^[clefHashConseil] := meiDef;
                  gClefHashage := BXOR(gClefHashage, (IndiceHash^^[couleur,pere]));

                  if (ESprof >= ProfPourHashExacte) then
                    begin
                      (*if (ESprof = profFinaleHeuristique) and (distanceProfArret >= profEvaluationHeuristique[ESprof]) and (ameliorationsAlpha.cardinal >= 1)
                        then
                          begin
                            {
                            WritelnNumDansRapport('ESprof = ',ESprof);
                            WritelnNumDansRapport('profFinaleHeuristique = ',profFinaleHeuristique);
                            WritelnNumDansRapport('distanceProfArret = ',distanceProfArret);
                            WritelnNumDansRapport('profEvaluationHeuristique[ESprof] = ',profEvaluationHeuristique[ESprof]);
                            WritelnNumDansRapport('ameliorationsAlpha.cardinal = ',ameliorationsAlpha.cardinal);
                            WritelnNumDansRapport('ameliorationsAlpha.liste[1].alphaAvant = ',ameliorationsAlpha.liste[1].alphaAvant);
                            WritelnNumDansRapport('maxPourBestDef = ',maxPourBestDef);
                            WritelnDansRapport('');
                            AttendFrappeClavier;
                            }
                            MetPosDansHashTableExacteEndgame(quelleHashTableExacte^[clefHashExacte],codagePosition,maxPourBestDef);
                          end
                        else *)
                          MetPosDansHashTableExacteEndgame(quelleHashTableExacte^[clefHashExacte],codagePosition,kEvaluationNonFaite);

                      if (ameliorationsAlpha.cardinal >= 1)
                        then MetAmeliorationsAphaPuisCoupsLegauxDansHash(1,nbCoupsPourCoul,ameliorationsAlpha,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale)
                        else AttacheCoupsLegauxDansHash(1,nbCoupsPourCoul,quelleHashTableCoupsLegaux,clefHashExacte,listeFinale);
                      ValiderCetteEntreeCoupsLegauxHash(quelleHashTableExacte^[clefHashExacte],suffisamentLoinDesFeuillesDeLArbre);
                      {SetBestDefenseDansHashExacte(meiDef,quelleHashTableExacte^[clefHashExacte]);}
                    end;
                end;

              ABPreOrdre := maxPourBestDef;
            end
          else
            begin
              if ESprof >= ProfUtilisationHash then
                gClefHashage := BXOR(gClefHashage, (IndiceHash^^[couleur,pere]));
              if DoitPasserFin(adversaire,plat)
                then
                  if couleur = pionBlanc
                    then ABPreOrdre := MakeSearchResultForSolvedPosition(InfosMilieuDePartie.nbBlancs-InfosMilieuDePartie.nbNoirs)
                    else ABPreOrdre := MakeSearchResultForSolvedPosition(InfosMilieuDePartie.nbNoirs-InfosMilieuDePartie.nbBlancs)
                else
                  ABPreOrdre := ReverseResult(ABPreOrdre(plat,InfosMilieuDePartie,meiDef,pere,adversaire,ESprof,ReverseWindow(fenetre),canDoProbCut));
            end;
       end;
    end;

end;   { ABPreOrdre }



procedure AjouteScoreToEndgameTree(positionEtTrait : PositionEtTraitRec; genreRefl,valeur : SInt32);
var scorePourNoir : SInt32;
    posArbre : PositionEtTraitRec;
    G : GameTree;
    OK,debugage : boolean;
begin
  with variablesMakeEndgameSearch do
    begin
      debugage := false;

      if debugage then
        begin
          WritelnDansRapport('');
          WritelnDansRapport('entrée dans AjouteScoreToEndgameTree : ');
        end;

      if not(ValeurDeFinaleInexploitable(valeur)) and
         (GetTraitOfPosition(positionEtTrait) <> pionVide) and
         EndgameTreeEstValide(numeroEndgameTreeActif, variablesMakeEndgameSearch) then
        begin
          G := GetActiveNodeOfEndgameTree(numeroEndgameTreeActif);

          if (G <> NIL) then
            begin
              OK := GetPositionEtTraitACeNoeud(G, posArbre, 'AjouteScoreToEndgameTree');

              if GetTraitOfPosition(positionEtTrait) = pionNoir
                then scorePourNoir := valeur
                else scorePourNoir := -valeur;

              if debugage then
                begin
    		          WritelnPositionEtTraitDansRapport(posArbre.position,GetTraitOfPosition(posArbre));
    			      	WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
    			      	WritelnStringAndBooleanDansRapport('meme positions et traits = ',SamePositionEtTrait(posArbre,positionEtTrait));
    			      	WritelnNumDansRapport('scorePourNoir = ',scorePourNoir);
    			      	if GenreDeReflexionInSet(genreRefl,[ReflGagnant,ReflRetrogradeGagnant])
    			      	  then WritelnDansRapport('genreRefl = gagnant/perdant')
    			      	  else WritelnDansRapport('genreRefl = score exact');
    			      	WritelnStringAndBoolDansRapport('OK = ',OK);
    			      	WritelnDansRapport('');
    	      	  end;

    	      	if OK and SamePositionEtTrait(posArbre,positionEtTrait)
    	      	  then
    	      	    begin
    	      	      if (genreRefl = ReflParfait) and odd(scorePourNoir) then
                      begin
                        {SysBeep(0);}
                        WritelnNumDansRapport('PAS NORMAL ! dans AjouteScoreToEndgameTree, scorePourNoir = ',scorePourNoir);
                      end;
    	      	      AjoutePropertyValeurDeCoupDansGameTree(genreRefl,scorePourNoir,G);
    	      	      if EstVisibleDansFenetreArbreDeJeu(G) then
    	      	        begin
    	      	          EffaceNoeudDansFenetreArbreDeJeu;
    	      	          EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
    	      	        end;
    	      	    end
    	      	  else
    	      	    begin
    	      	      SysBeep(0);
    	      	      WritelnDansRapport('ASSERT( OK and SamePositionEtTrait(posArbre,positionEtTrait)) dans AjouteScoreToEndgameTree');
    	      	    end;
            end;
        end;
    end;
end;


function InfosDansRapportSontCensurees(numeroCoup : SInt32) : boolean;
begin
  InfosDansRapportSontCensurees := false;

  if enTournoi then
    begin
      InfosDansRapportSontCensurees := true;
      exit(InfosDansRapportSontCensurees);
    end;

  if (numeroCoup >= (60-kNbCasesVidesPourAnnonceDansRapport)) then
    InfosDansRapportSontCensurees := true;
end;



procedure AnnonceRechercheDansRapport(numeroCoup : SInt32);
var s,s1,s2 : String255;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin
      if interruptionReflexion = pasdinterruption then
      if not(rechercheDejaAnnonceeDansRapport) and not(InfosDansRapportSontCensurees(numeroCoup)) then
        if (numeroCoup < (60-kNbCasesVidesPourAnnonceDansRapport)) or
           GenreDeReflexionInSet(inTypeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]) then
          begin
            s1 := NumEnString(numeroCoup);
            if inCouleurFinale = pionNoir
              then s2 := ReadStringFromRessource(TextesListeID,7)   {Noir}
              else s2 := ReadStringFromRessource(TextesListeID,8);  {Blanc}
            if bestmodeArriveeDansCoupGagnant
              then s := ParamStr(ReadStringFromRessource(TextesRapportID,5),s1,s2,'','')   {'Recherche au coup ^0 : finale parfaite'}
              else s := ParamStr(ReadStringFromRessource(TextesRapportID,4),s1,s2,'','');  {'Recherche au coup ^0 : finale gagnante'}
            if GetEffetSpecial then s := s + ' (effet special)';

            {
            s := s + ' (eval = ' + ReplaceStringByStringInString('EVAL_','',TypeEvalEnChaine(typeEvalEnCours))+' )';
            }

            DisableKeyboardScriptSwitch;
            FinRapport;
            TextNormalDansRapport;
            WritelnDansRapport('');

            ChangeFontSizeDansRapport(gCassioRapportBoldSize);
            ChangeFontDansRapport(gCassioRapportBoldFont);

            ChangeFontFaceDansRapport(bold);
            WritelnStringDansRapportSansRepetition(s,chainesDejaEcrites);
            TextNormalDansRapport;
            EnableKeyboardScriptSwitch;
            rechercheDejaAnnonceeDansRapport := true;
          end;
    end;
end;

procedure MeilleureSuiteDansRapport(score : SInt32);
var s : String255;
begin
  with variablesMakeEndgameSearch do
    begin
      if not(InfosDansRapportSontCensurees(noCoupRecherche)) then
        begin
          s := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,((deltaFinaleCourant < kDeltaFinaleInfini) or not(bestMode)),score);

          if deltaFinaleCourant < kDeltaFinaleInfini
            then s := s + '    '+DeltaFinaleEnChaine(deltaFinaleCourant);
          EnleveEspacesDeGaucheSurPlace(s);

          if affichageReflexion.afficherToutesLesPasses or debuggage.algoDeFinale or
            (deltaFinaleCourant = kDeltaFinaleInfini) then
            begin
              AnnonceRechercheDansRapport(noCoupRecherche);
              DisableKeyboardScriptSwitch;
              FinRapport;
              TextNormalDansRapport;
              WritelnStringDansRapportSansRepetition('  '+s,chainesDejaEcrites);
              EnableKeyboardScriptSwitch;
            end;
        end;
    end;
end;

procedure MetInfosTechniquesDansRapport;
var s,s1,s2,s3 : String255;
    nbMinutes,aux : SInt32;
    fractionSequentielle,maximumSpeedUp : double;
begin

  Discard2(fractionSequentielle,maximumSpeedUp);

  with variablesMakeEndgameSearch do
    begin
      if rechercheDejaAnnonceeDansRapport then
       if (interruptionReflexion = pasdinterruption) then
         if not(InfosDansRapportSontCensurees(noCoupRecherche)) then
         begin

           nbMinutes := tempsGlobalDeLaFonction div 3600;
           if nbMinutes <= 0
             then
               begin
                 s := ReadStringFromRessource(TextesRapportID,15);
                 s := ParamStr(s,ReelEnString(1.0*tempsGlobalDeLaFonction/60),'','','');
               end
             else
               if nbMinutes >= 60
                 then
                   begin
                     s := ReadStringFromRessource(TextesRapportID,13);
                     s1 := NumEnString(nbMinutes div 60);
                     s2 := NumEnString(nbMinutes mod 60);
                     s3 := NumEnString((tempsGlobalDeLaFonction-nbMinutes*3600) div 60);
                     s := ParamStr(s,ReelEnString(1.0*tempsGlobalDeLaFonction/60),s1,s2,s3);
                   end
                 else
                   begin
                     s := ReadStringFromRessource(TextesRapportID,14);
                     s2 := NumEnString(nbMinutes);
                     s3 := NumEnString((tempsGlobalDeLaFonction-nbMinutes*3600) div 60);
                     s := ParamStr(s,ReelEnString(1.0*tempsGlobalDeLaFonction/60),s2,s3,'');
                   end;
           DisableKeyboardScriptSwitch;
           FinRapport;
           TextNormalDansRapport;

           ChangeFontFaceDansRapport(italic);
           ChangeFontColorDansRapport(MarronCmd);  // VertSapinCmd et MarinePaleCmd sont bien aussi

           WritelnDansRapport('  '+s);
           EnableKeyboardScriptSwitch;


           s := BigNumEnString(nbreToursNoeudsGeneresFinale,nbreNoeudsGeneresFinale);
           s := SeparerLesChiffresParTrois(s);
           s := ReadStringFromRessource(TextesRapportID,12)+CharToString(' ')+s;
           WritelnDansRapport('  '+s);

           if (nbreToursNoeudsGeneresFinale = 0)
             then
               WritelnStringAndNumEnSeparantLesMilliersDansRapport('  nb nœuds/sec = ',60*(nbreNoeudsGeneresFinale div tempsGlobalDeLaFonction))
             else
               begin
                 aux := nbreToursNoeudsGeneresFinale*(1000000000 div tempsGlobalDeLaFonction);
                 aux := aux + (nbreNoeudsGeneresFinale div tempsGlobalDeLaFonction);
                 WritelnStringAndNumEnSeparantLesMilliersDansRapport('  nb nœuds/sec = ',60*aux);
               end;

           (*
           WriteDansRapport('Occupation CPU moyenne à 4 cases vides (%) :   ');
           EcrireMesureDeParallelismeDansRapport;

           WriteDansRapport('Mesure des temps de synchronisation (%) :   ');
           EcrireFraisDeSynchronisationDansRapport;

           WriteDansRapport('  ... et donc, le parallelisme utile est (%) :   ');
           ChangeFontFaceDansRapport(bold);
           EcrireParallelismeUtileDansRapport;
           TextNormalDansRapport;



           WritelnDansRapport('Temps parallelisable = '+NumEnString(gFractionParallelisableSecondes)+' sec.');

           // f est la partie forcement sequentielle de notre implementation
           fractionSequentielle := 1.0 - gFractionParallelisableSecondes / (1.0*tempsGlobalDeLaFonction/60);
           WritelnStringAndReelDansRapport('fraction sequentielle de l''ago :  f = ',fractionSequentielle,8);

           maximumSpeedUp := 1/(fractionSequentielle + (1-fractionSequentielle)/numProcessors);
           WritelnStringAndReelDansRapport('et donc, par la loi de Amdahl, speed-up <= ',maximumSpeedUp,8);


           WritelnNumDansRapport('Nombre de noeuds d''éclatement = ',gNbreDeSplitNodes);
           WritelnNumDansRapport('Nombre de noeuds d''éclatement inutiles = ',gNbreDeCoupuresBetaDansUnSplitNode);
           if (gNbreDeSplitNodes <> 0)
             then WritelnStringAndReelDansRapport('  % de perte algorithmique inutile = ',(100.0*gNbreDeCoupuresBetaDansUnSplitNode/(1.0*gNbreDeSplitNodes)),8);
           WritelnNumDansRapport('Nombre de noeuds d''éclatement rates = ',gNbreDeSplitNodesRates);
           if (gNbreDeSplitNodes <> 0)
             then WritelnStringAndReelDansRapport('  % de perte algorithmique ratee = ',(100.0*gNbreDeSplitNodesRates/(1.0*gNbreDeSplitNodes)),8);


           WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
           {WritelnNumDansRapport('gNbreThreadsDisponibles = ',NbreDeThreadsDisponibles);}
           *)

           ChangeFontFaceDansRapport(normal);
           ChangeFontColorDansRapport(NoirCmd);

         end;
    end;
end;


procedure RemplirMeilleureSuiteAvecHashTable(var whichPlat : plateauOthello; trait,scorePourNoir,premierCoupDeLaSuite,profondeur,genreRefl,deltaDeXCourant : SInt32; var suiteComplete : boolean);
var positionEtTrait : PositionEtTraitRec;
    coupLegal,trouve,confirmationScore,debugage : boolean;
    coup,nbCoupsDeLaSuite : SInt32;
    profondeurCourante,i : SInt32;
    minProfondeurRemplissage : SInt32;
    nroTableExacte,myClefExacte : SInt32;
    quelleHashTableExacte : HashTableExactePtr;
    codagePosition : codePositionRec;
    copieDeClefHashage : SInt32;
    valMinNoir,valMaxNoir : SInt32;
begin  {$UNUSED i}
  with variablesMakeEndgameSearch do
    begin
        debugage := false;

        suiteComplete := false;

        if (premierCoupDeLaSuite < 11) or (premierCoupDeLaSuite > 88) or (profondeur <= 1)
          then exit(RemplirMeilleureSuiteAvecHashTable);

        {WritelnDansRapport('entrée dans RemplirMeilleureSuiteAvecHashTable');
         WritelnDansRapport('tapez une touche…');
         AttendFrappeClavier;
        }

        positionEtTrait := MakePositionEtTrait(whichPlat,trait);
        suiteComplete := PartieEstFinieApresCeCoupDansPositionEtTrait(positionEtTrait,premierCoupDeLaSuite);


        {
        WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
        WritelnStringAndCoupDansRapport('premierCoupDeLaSuite = ',premierCoupDeLaSuite);
        WritelnStringAndBoolDansRapport('  ==> suiteComplete = ',suiteComplete);
        }


        nbCoupsDeLaSuite := 0;
        profondeurCourante := profondeur;
        minProfondeurRemplissage := 0;
        coup := premierCoupDeLaSuite;

        copieDeClefHashage := SetClefHashageGlobale(gClefHashage);

        (*
        WritelnDansRapport('');
        WritelnDansRapport('++++++++++++++');
        *)


        for i := 0 to profondeur do
          begin
            {WritelnNumDansRapport('mise a zero : ',i);}
            meilleureSuite[profondeur,i] := 0;
          end;

        repeat

          (*
          if ((profondeur - profondeurCourante) <= 1) then
            begin
              WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
              WritelnNumDansRapport('hash = ',gClefHashage);
              WritelnStringAndCoupDansRapport('coup = ',coup);
              WritelnDansRapport('');
            end;
          *)


          gClefHashage := BXOR(gClefHashage , (IndiceHash^^[GetTraitOfPosition(positionEtTrait),coup]));
          inc(nbCoupsDeLaSuite);

         // WritelnDansRapport('Dans RemplirMeilleureSuiteAvecHashTable,  profondeurCourante = '+NumEnString(profondeurCourante)+'   < -->  hash = '+NumEnString(gClefHashage));

          {WritelnStringAndCoupDansRapport('coup = ',coup);
          WritelnNumDansRapport('nb vides = ',profondeurCourante);
          WritelnNumDansRapport('nbCoupsDeLaSuite = ',nbCoupsDeLaSuite);
          WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));}

          nroTableExacte := BAND((gClefHashage div 1024),nbTablesHashExactesMoins1);
          myClefExacte := BAND(gClefHashage,1023);
          quelleHashTableExacte := HashTableExacte[nroTableExacte];
          CreeCodagePosition(positionEtTrait.position,GetTraitOfPosition(positionEtTrait),profondeurCourante,codagePosition);
          trouve := InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,gClefHashage,myClefExacte);
          {WritelnStringAndBooleenDansRapport('trouvé = ',trouve);}

          if trouve then
            begin

              GetEndgameValuesInHashTableElement(quelleHashTableExacte^[myClefExacte],deltaDeXCourant,valMinNoir,valMaxNoir);
              confirmationScore := ScoreFinalEstConfirmeParValeursHashExacte(genreRefl,scorePourNoir,valMinNoir,valMaxNoir);

              if debugage then
                begin
                  WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
      		        WritelnNumDansRapport('valMinNoir = ',valMinNoir);
      		        WritelnNumDansRapport('scorePourNoir = ',scorePourNoir);
      		        WritelnNumDansRapport('valMaxNoir = ',valMaxNoir);
      		        WritelnStringAndBoolDansRapport('  =>  confirmationScore = ',confirmationScore);
      		        WritelnDansRapport('');
      		      end;

              if not(confirmationScore) then
                begin
                  meilleureSuite[profondeur,profondeurCourante+1] := 0;
                  inc(minProfondeurRemplissage);
                end;

              coup := GetBestDefenseDansHashExacte(quelleHashTableExacte^[myClefExacte]);
              coupLegal := UpdatePositionEtTrait(positionEtTrait,coup);

              if coupLegal and confirmationScore then
                begin
                  {WriteNumDansRapport('remplissage : meilleureSuite[',profondeur);
                  WriteNumDansRapport(',',profondeurCourante);
                  WritelnStringAndCoupDansRapport('] = ',coup);}

                  meilleureSuite[profondeur,profondeurCourante] := coup;
                  minProfondeurRemplissage := profondeurCourante;

                  (*
                  WritelnStringAndCoupDansRapport('meilleureSuite['+NumEnString(profondeur)+','+NumEnString(profondeurCourante)+'] = ',coup);
                  *)
                end;

              {WritelnStringAndBooleenDansRapport('coup légal = ',coupLegal);}
            end;
          {WritelnDansRapport('');}
          {AttendFrappeClavier;}

          dec(profondeurCourante);

        until not(coupLegal) or not(confirmationScore) or not(trouve) or (coup < 11) or (coup > 88);

        suiteComplete := (GetTraitOfPosition(positionEtTrait) = pionVide);

       {WritelnNumDansRapport('minProfondeurRemplissage = ',minProfondeurRemplissage);}
       for i := 1 to minProfondeurRemplissage - 1 do
         begin
           {WritelnNumDansRapport('mise a zero : ',i);}
           meilleureSuite[profondeur,i] := 0;
         end;

       gClefHashage := copieDeClefHashage;
       TesterClefHashage(copieDeClefHashage,'RemplirMeilleureSuiteAvecHashTable');
    end;

end;


function CompleteMeilleureSuite(minimaxprof : SInt32; var whichPlat : plateauOthello; whichCoul,whichNbreBlancs,whichNbreNoirs,scorePourVerif : SInt32) : boolean;
var platCompl : PositionEtTraitRec;
    platComplEndgame : plOthEndgame;
    nBlaCompl,nNoiCompl : SInt32;
    scoreSuite,coup,p,i,pere,bidBestSuite : SInt32;
    scorePourVerifVuPourNoir : SInt32;
    valminPourNoir,valMaxPourNoir : SInt32;
    coupPossible,partieEstFinie,probleme : boolean;
    s,s1,s2 : String255;
    profondeurMinRelaisParBitboardHash : SInt32;
    profondeurMaxRelaisParBitboardHash : SInt32;
    profondeur_utilisation_bitboard : SInt32;
    essayerAvecBitboardHash : boolean;
    theJob : LongSTring;
label TRY_AGAIN;
begin
  with variablesMakeEndgameSearch do
    begin
        (* WritelnNumDansRapport('Entree dans CompleteMeilleureSuite…    profForceBrute = ',profForceBrute); *)


        // "profondeur_utilisation_bitboard" est la profondeur pour laquelle on sait que la matrice
        // meilleureSuite a été remplie par des infos de la table de hachage bitboard, donc suspectes.

        profondeur_utilisation_bitboard := profForceBrute;

        essayerAvecBitboardHash := true;

        TRY_AGAIN :

          probleme := true;

          // On sait que l'alpha-beta bitboard ne remplit pas la matrice des meilleures variations
          // on efface donc les coups pour les prof <= profondeur_utilisation_bitboard

          if minimaxprof >= ( 1 + profondeur_utilisation_bitboard)
            then for i := 1 to profondeur_utilisation_bitboard do meilleureSuite[minimaxprof,i] := 0
            else for i := 1 to minimaxprof-1 do meilleureSuite[minimaxprof,i] := 0;

          (*
          WritelnNumDansRapport('minimaxprof = ',minimaxprof);
          *)

          {WritelnNumDansRapport('profondeur_utilisation_bitboard = ',profondeur_utilisation_bitboard);}

          if (interruptionReflexion = pasdinterruption) then
            begin
              probleme := false;

              platCompl := MakePositionEtTrait(whichPlat,whichCoul);
              nBlaCompl := whichNbreBlancs;
              nNoiCompl := whichNbreNoirs;


              profondeurMinRelaisParBitboardHash :=  1000;
              profondeurMaxRelaisParBitboardHash := -1000;
              p := minimaxprof+1;

              repeat
                p := p-1;
                coup := meilleuresuite[minimaxprof,p];

                (*
                WritelnStringAndCoupDansRapport('meilleureSuite['+NumEnString(minimaxprof)+','+NumEnString(p)+'] = ',coup);
                *)

                {WritelnStringAndCoupDansRapport('Le coup de la matrice meilleuresuite :   p = '+NumEnString(p) + ' :  ', coup);}

                coupPossible := false;
                if (coup >= 11) and (coup <= 88) then
                  if (platCompl.position[coup] = pionVide) then
                    coupPossible := UpdatePositionEtTrait(platCompl,coup);


                if not(coupPossible) and essayerAvecBitboardHash then
                  if GetEndgameValuesInAllBitboardHashTables(platCompl,valMinPourNoir,valMaxPourNoir,coup) then
                    begin
                      {WritelnDansRapport('Hit dans la table de hachage bitboard !  p = '+NumEnString(p) + ' :  '+CoupEnString(coup,true)+'['+ NumEnString(valMinPourNoir)+','+NumEnString(valMaxPourNoir)+']');}

                      if (whichCoul = pionBlanc)
                        then scorePourVerifVuPourNoir := scorePourVerif
                        else scorePourVerifVuPourNoir := -scorePourVerif;

                      if (valMinPourNoir = valMaxPourNoir) and (valMinPourNoir = scorePourVerifVuPourNoir) and
                         (coup >= 11) and (coup <= 88) and (platCompl.position[coup] = pionVide) then
                          begin
                            coupPossible := UpdatePositionEtTrait(platCompl,coup);
                            if coupPossible then
                              begin
                                meilleuresuite[minimaxprof,p] := coup;

                                if (p >= profondeurMaxRelaisParBitboardHash) then profondeurMaxRelaisParBitboardHash := p;
                                if (p <= profondeurMinRelaisParBitboardHash) then profondeurMinRelaisParBitboardHash := p;

                                {WritelnDansRapport('La table de hachage bitboard peut donc prendre le relais... '+CoupEnString(coup,true)+'['+ NumEnString(valMinPourNoir)+','+NumEnString(valMaxPourNoir)+']');}
                              end;
                          end;
                    end;

              until (p <= 1) or (coup = 0) or not(coupPossible);

              nBlaCompl := NbPionsDeCetteCouleurDansPosition(pionBlanc,platCompl.position);
              nNoiCompl := NbPionsDeCetteCouleurDansPosition(pionNoir,platCompl.position);

              partieEstFinie := (GetTraitOfPosition(platCompl) = pionVide);

              if not(partieEstFinie) then
                if not(coupPossible) then
                  begin
                    if p > (profForceBrute + 2) then
                      begin
                        probleme := true;

                        WritelnPositionEtTraitDansRapport(whichPlat,whichCoul);
                        for i := minimaxprof downto p do
                          WritelnStringAndCoupDansRapport('meilleuresuite[minimaxprof,'+NumEnString(i)+'] = ',meilleuresuite[minimaxprof,i]);


                        WritelnPositionEtTraitDansRapport(platCompl.position,GetTraitOfPosition(platCompl));
                        s := ReadStringFromRessource(TextesRapportID,21);    {"probleme dans mon algorithme !!"}
                        s1 := NumEnString(p);
                        s := ParamStr(s,s1,'','','');
                        if (meilleuresuite[minimaxprof,p] <> 0)
                          then s := s + ' coup impossible à profondeur '+NumEnString(p)
                          else s := s + ' coup introuvable à profondeur '+NumEnString(p);
                        WritelnDansRapport(s);

                        if CassioEstEnTrainDeCalculerPourLeZoo then
                          begin
                            WritelnDansRapport('J''étais en train de calculer ce job pour le zoo : ');
                            theJob := GetCalculCourantDeCassioPourLeZoo;
                            WritelnLongStringDansRapport(theJob);
                          end;

                        if not(enTournoi or CassioEstEnTrainDeCalculerPourLeZoo) then AlerteSimple(s + ' Prévenez Stéphane');
                      end;
                    pere := meilleuresuite[minimaxprof,p+1];


                    (* on essaie de completer la suite en appelant un algo de finale lent,
                       mais qui remplit toujours correctement le tableau meilleureSuite[] *)

                    MyCopyEnPlOthEndgame(platCompl.position,platComplEndgame);
                    if GetTraitOfPosition(platCompl) = pionNoir
                      then
                        if GetTraitOfPosition(platCompl) = whichCoul
                          then scoreSuite := -ABFinPetitePourSuite(platComplEndgame,bidBestSuite,GetTraitOfPosition(platCompl),p,
                                                                 -noteMax,noteMax,nNoiCompl-nBlaCompl,false)
                          else scoreSuite := ABFinPetitePourSuite(platComplEndgame,bidBestSuite,GetTraitOfPosition(platCompl),p,
                                                                 -noteMax,noteMax,nNoiCompl-nBlaCompl,false)
                      else
                        if GetTraitOfPosition(platCompl) = whichCoul
                          then scoreSuite := -ABFinPetitePourSuite(platComplEndgame,bidBestSuite,GetTraitOfPosition(platCompl),p,
                                                                 -noteMax,noteMax,nBlaCompl-nNoiCompl,false)
                          else scoreSuite := ABFinPetitePourSuite(platComplEndgame,bidBestSuite,GetTraitOfPosition(platCompl),p,
                                                                 -noteMax,noteMax,nBlaCompl-nNoiCompl,false);

                    (* on verifie au passage le score de la suite donnee par les tables des hachages *)
                    if (Abs(scorePourVerif-scoreSuite) > 1) and (interruptionReflexion = pasdinterruption) then
                      begin

                        if essayerAvecBitboardHash and (p = profondeurMinRelaisParBitboardHash - 1) then
                          begin
                            {
                            if not(enTournoi) then
                              WritelnDansRapport('WARNING : la table de hachage bitboard renvoie peut-être une ligne avec un score incorrect, je recalcule sans elle…');
                            WritelnNumDansRapport('p = ',p);
                            WritelnNumDansRapport('profondeurMinRelaisParBitboardHash = ',profondeurMinRelaisParBitboardHash);
                            }
                            {WritelnDansRapport('TRY_AGAIN…');}

                            profondeur_utilisation_bitboard := profondeurMaxRelaisParBitboardHash;

                            essayerAvecBitboardHash := false;

                            goto TRY_AGAIN;
                          end;

                        probleme := true;
                        s1 := NumEnString(scorePourVerif);
                        s2 := NumEnString(scoreSuite);
                        s := ReadStringFromRessource(TextesRapportID,22);  {"problème dans mon algorithme !! scoreSuite et scorePourVerif"}
                        s := ParamStr(s,s1,s2,'','');
                        WritelnDansRapport(s);

                        if CassioEstEnTrainDeCalculerPourLeZoo then
                          begin
                            WritelnDansRapport('J''étais en train de calculer ce job pour le zoo :');
                            theJob := GetCalculCourantDeCassioPourLeZoo;
                            WritelnLongStringDansRapport(theJob);
                          end;

                        if not(enTournoi or CassioEstEnTrainDeCalculerPourLeZoo) then AlerteSimple(s + ' Prévenez Stéphane');

                        s := NumEnString(nBlaCompl);
                        s1 := NumEnString(nNoiCompl);
                        s := '(nBlaCompl = '+s+'  et nNoiCompl = '+s1+CharToString(')');
                        WritelnDansRapport(s);
                        if (pere >= 11) and (pere <= 88)
                          then s := CoupEnString(pere,true)
                          else s := NumEnString(pere);
                        if GetTraitOfPosition(platCompl) = pionNoir  then s1 := 'Noir' else
                        if GetTraitOfPosition(platCompl) = pionBlanc then s1 := 'Blanc' else
                          s1 := NumEnString(GetTraitOfPosition(platCompl));
                        s := '(pere = '+s+'  et AquiCompl = '+s1+CharToString(')');
                        WritelnDansRapport(s);
                        s := NumEnString(p);
                        s := '(prof = '+s+CharToString(')');
                        WritelnDansRapport(s);
                        WritelnPositionEtTraitDansRapport(platComplEndgame,GetTraitOfPosition(platCompl));
                      end;

                    (* tout a l'air bon, hein *)
                    for i := p downto 1 do
                      meilleureSuite[minimaxprof,i] := meilleureSuite[p,i];

                  end;
              end;

        {WritelnDansRapport('…sortie de CompleteMeilleureSuite');
        WritelnDansRapport('');}

        CompleteMeilleureSuite := not(probleme);
    end;

end;


procedure GestionMeilleureSuite(ProfRecherche : SInt32; var jeu : plateauOthello; couleur,nbBla,nbNoi,
                                valXY,XCourant,deltaDeXCourant,nroCoup,nbreCoupsLegaux : SInt32; xCourantEstLeMeilleurCoup : boolean);
var message,i,scoreOptimalPourNoir : SInt32;
    oldStatut,positionDuCoup : SInt32;
    suiteEstComplete,OK,suiteEstLegale : boolean;
    s : String255;
    P1,P2 : PositionEtTraitRec;
    G : GameTree;
    oldMeilleureSuiteInfos : meilleureSuiteInfosRec;
    oldMeilleureSuite : String255;
    debugage : boolean;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin
       debugage := false;

       if debugage then
         WritelnStringDansRapportSansRepetition('Entrée dans GestionMeilleureSuite, XCourant = '+CoupEnStringEnMajuscules(XCourant) + ', valXY = '+NumEnString(valXY),chainesDejaEcrites);

        if ValeurDeFinaleInexploitable(valXY) then
          exit(GestionMeilleureSuite);

        if analyseRetrograde.enCours and
           {(analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeParfait) and}
           (XCourant = coupDontLeScoreEstConnu) then
         exit(GestionMeilleureSuite);

        message := pasdemessage;
        if (valXY > 0) and (valeurCible = 0) and (not(bestMode) or passeDeRechercheAuMoinsValeurCible) then message := messageEstGagnant;
        if (valXY = 0) and (valeurCible = 0) and (not(bestMode) or passeDeRechercheAuMoinsValeurCible) then message := messageFaitNulle;
        if (valXY < 0) and (valeurCible = 0) and (not(bestMode) or passeDeRechercheAuMoinsValeurCible) then
          if (nroCoup < nbreCoupsLegaux) or (analyseIntegraleDeFinale {and (deltaDeXCourant < kDeltaFinaleInfini)})
            then message := messageEstPerdant
            else message := messageToutEstPerdant;

        (*
        WritelnNumDansRapport('ProfRecherche = ',ProfRecherche);
        *)

        if bestMode and not(passeDeRechercheAuMoinsValeurCible) and
           (deltaFinaleCourant = kDeltaFinaleInfini) and not(ValeurDeFinaleInexploitable(valXY)) and
           (not(coupGagnantAUneFenetreAlphaBetaReduite) or ((valXY >= inAlphaFinale) and (valXY < inBetaFinale)))
          then
            begin
              (*
              WritelnNumDansRapport('appel de CompleteMeilleureSuite, valXY = ',valXY);
              *)
              suiteEstLegale := CompleteMeilleureSuite(ProfRecherche,jeu,couleur,nbBla,nbNoi,valXY);
              suiteEstComplete := true;
            end
          else
            begin
              (*
              WritelnDansRapport('appel de RemplirMeilleureSuiteAvecHashTable');
              *)
              if CoulPourMeilleurFin = pionNoir
      			    then scoreOptimalPourNoir := valXY
      			    else scoreOptimalPourNoir := -valXY;

      			  if bestmode
                then RemplirMeilleureSuiteAvecHashTable(jeu,couleur,scoreOptimalPourNoir,XCourant,profRecherche,ReflParfait,deltaDeXCourant,suiteEstComplete)
                else RemplirMeilleureSuiteAvecHashTable(jeu,couleur,scoreOptimalPourNoir,XCourant,profRecherche,ReflGagnant,deltaDeXCourant,suiteEstComplete);
              suiteEstLegale := true;
            end;

        for i := profRecherche downto 1 do
          suiteJouee[i] := meilleureSuite[ProfRecherche,i];

        if (interruptionReflexion = pasdinterruption) then
          begin


            {on sauvegarde l'ancienne meilleure suite affichee, a tout hasard}
            GetMeilleureSuiteInfos(oldMeilleureSuiteInfos);
            oldMeilleureSuite := GetMeilleureSuite;

            FabriqueMeilleureSuiteInfos(XCourant,suiteJouee,@meilleureSuite,couleur,jeu,nbBla,nbNoi,message);
            outResult.outLineFinale := CoupEnStringEnMajuscules(XCourant) + StructureMeilleureSuiteToString(meilleureSuite, NbCasesVidesDansPosition(inPositionPourFinale));
      		  SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,not(suiteEstComplete),valXY));
      		  if (deltaDeXCourant < kDeltaFinaleInfini)
      		    then SetMeilleureSuite(GetMeilleureSuite + '   ' + DeltaFinaleEnChaine(deltaDeXCourant));

      		  if afficheMeilleureSuite and not(analyseIntegraleDeFinale) and
      		     not(CassioEstEnModeAnalyse and meilleureSuiteAEteCalculeeParOptimalite) and
      		     not(CassioEstEnTrainDeCalculerPourLeZoo)
      		    then EcritMeilleureSuite;

      		  if bestMode or (valXY >= 0) or
      		    (message = messageToutEstPerdant) or
      		    (message = messageToutEstProbablementPerdant) or
      		    ((inTypeCalculFinale = ReflGagnantExhaustif) and analyseIntegraleDeFinale) then
        		    if inCommentairesDansRapportFinale and not(CassioEstEnTrainDeCalculerPourLeZoo) then
        		      begin
        		        if analyseIntegraleDeFinale
        		          then
        		            begin
        		              MeilleureSuiteDansRapport(valXY);
        		            end
        		          else
        		            begin
        		              if (ProfRecherche+1 > kNbCasesVidesPourAnnonceDansRapport)
        		                then MeilleureSuiteDansRapport(valXY);
        		            end;
        		      end;

      		  if EndgameTreeEstValide(numeroEndgameTreeActif, variablesMakeEndgameSearch) and
      		     (xCourantEstLeMeilleurCoup or GenreDeReflexionInSet(inTypeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif])) and
      		     (deltaFinaleCourant = kDeltaFinaleInfini) and
      		     (suiteEstComplete or not(bestmode)) and suiteEstLegale and
      		     (interruptionReflexion = pasdinterruption) and
      		     not(CassioEstEnTrainDeCalculerPourLeZoo) then
      		    begin
      		      G := GetActiveNodeOfEndgameTree(numeroEndgameTreeActif);

      		      if (G <> NIL) then
      		        begin

      			      P1 := MakePositionEtTrait(jeu,couleur);
      			      OK := GetPositionEtTraitACeNoeud(G, P2, 'GestionMeilleureSuite');

      			      if not(OK) then
      			        begin
      			          WritelnDansRapport('WARNING : NOT(GetPositionEtTraitACeNoeud(G, P2)) dans GestionMeilleureSuite');
      			          SysBeep(0);
      			        end;

      			      if GetTraitOfPosition(P2) = pionNoir
      			        then scoreOptimalPourNoir := valXY
      			        else scoreOptimalPourNoir := -valXY;


      			      oldStatut := GetStatutMeilleureSuite;
      		        if (oldStatut = ToutEstPerdant) or (oldStatut = ToutEstProbablementPerdant) then
      		          if scoreOptimalPourNoir > 0
      		            then SetStatutMeilleureSuite(VictoireNoire)
      		            else SetStatutMeilleureSuite(VictoireBlanche);
      			      s := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0);
      			      positionDuCoup := Pos(CoupEnString(XCourant,CassioUtiliseDesMajuscules),s);
      			      s := TPCopy(s,positionDuCoup,255);
      			      positionDuCoup := Pos(CoupEnString(XCourant,CassioUtiliseDesMajuscules),s);
      			      SetStatutMeilleureSuite(oldStatut);

      			      if debugage then
      			        begin
          			      WritelnDansRapport('');
          			      WritelnPositionEtTraitDansRapport(P1.position,GetTraitOfPosition(P1));
          			      WritelnPositionEtTraitDansRapport(P2.position,GetTraitOfPosition(P2));
          			      WritelnStringAndBooleanDansRapport('meme positions et traits = ',SamePositionEtTrait(P1,P2));
          			      WritelnStringAndCoupDansRapport('XCourant = ',XCourant);
          			      WritelnNumDansRapport('couleur = ',couleur);
          			      WritelnNumDansRapport('valXY = ',valXY);
          			      WritelnNumDansRapport('scoreOptimalPourNoir = ',scoreOptimalPourNoir);
          			      WritelnDansRapport('j''essaie de mettre la meilleure suite suivante dans l''arbre :');
          			      WritelnDansRapport(s);
          			      WritelnNumDansRapport('positionDuCoup = ',positionDuCoup);
          			      WritelnDansRapport('alors que la meilleure suite officielle est :');
          			      MeilleureSuiteDansRapport(valXY);
          			      WritelnDansRapport('');
      			        end;

      			      if not(jeuInstantane) then
      			        begin
      			          if bestmode
      			            then
      			              begin
      			                if odd(scoreOptimalPourNoir) then
      			                  begin
      			                    WritelnNumDansRapport('ASSERT : score impair dans GestionMeilleureSuite, scoreOptimalPourNoir = ',scoreOptimalPourNoir);
      			                  end;
      			                AjouteMeilleureSuiteDansGameTree(ReflParfait, s, scoreOptimalPourNoir, G, false, kNewMovesVirtual);
      			              end
      			            else
      			              begin
      			                AjouteMeilleureSuiteDansGameTree(ReflGagnant, s, scoreOptimalPourNoir, G, false, kNewMovesVirtual);
      			              end;
      			        end;
      			      if EstVisibleDansFenetreArbreDeJeu(G) then
      			        begin
      			          EffaceNoeudDansFenetreArbreDeJeu;
      			          EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
      			        end;

      			    end;
      		    end;


      		  if CassioEstEnTrainDeCalculerPourLeZoo and xCourantEstLeMeilleurCoup then
      		    begin
      		      meilleureSuiteCommeResultatDeMakeEndgameSearch := GetMeilleureSuite;
      		      // WritelnDansRapport(meilleureSuiteCommeResultatDeMakeEndgameSearch);
      		    end;

      		  {si xCourantEstLeMeilleurCoup est faux, cela veut dire que l'on
             veut simplement afficher la suite du coup courant dans
             le rapport sans changer la 'vraie' meilleure suite : on
             encadre la gestion de la suite du coup courant}
      		  if not(xCourantEstLeMeilleurCoup) or analyseIntegraleDeFinale or CassioEstEnTrainDeCalculerPourLeZoo then
              begin
                SetMeilleureSuiteInfos(oldMeilleureSuiteInfos);
                SetMeilleureSuite(oldMeilleureSuite);
              end;

          end;

    end;

end;


function LanceurMilieuDePartie(nbNiveauxMilieu,alpha,beta : SInt32;
                              var plat : plateauOthello; var jouableMilieu : plBool;
                              var defense : SInt32; pere,couleur : SInt32;
                              nbBlancMilieu,nbNoirMilieu : SInt32;
                              var frontMilieu : InfoFront;
                              canDoProbCut : boolean) : SInt32;
var InfosMilieu : InfosMilieuRec;
    copieDeClefHashage : SInt32;
    fenetre : SearchWindow;
    result : SearchResult;
    valeurCalculeeParLeMoteurExterne : boolean;
    valeur : SInt32;
    numeroEngine : SInt32;
    {$IFC USE_DEBUG_STEP_BY_STEP}
    aPosition : PositionEtTraitRec;
    dummy : boolean;
    {$ENDC}
begin
  with variablesMakeEndgameSearch do
    begin

        {$IFC USE_DEBUG_STEP_BY_STEP}
        if debuggage.preordonancementDesCoupsEnFinale and (pere = 48) then
          with gDebuggageAlgoFinaleStepByStep do
            begin
              positionsCherchees := MakeEmptyPositionEtTraitSet;
              actif := true;
              profMin := 1;
              aPosition := MakePositionEtTrait(plat,couleur);
              dummy := UpdatePositionEtTrait(aPosition,87);
              dummy := UpdatePositionEtTrait(aPosition,85);
              if actif then AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
              WritelnDansRapport(PositionEtTraitEnString(aPosition));
            end;
        {$ENDC}


        // c'est parti !

        if (interruptionReflexion = pasdinterruption)
          then
            begin
              SetLargeurFenetreProbCut;

              copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);

              profondeurArretPreordre := MFniv-nbNiveauxMilieu;
              profondeurDepartPreordre := MFniv;


              valeurCalculeeParLeMoteurExterne := false;


              if not(valeurCalculeeParLeMoteurExterne) then
                begin


                  with InfosMilieu do
          			    begin
          			      frontiere := frontMilieu;
          			      jouable  := jouableMilieu;
          			      nbBlancs := nbBlancMilieu;
          			      nbNoirs  := nbNoirMilieu;
          			    end;

          			  fenetre := MakeSearchWindow(MakeSearchResultFromHeuristicValue(alpha),MakeSearchResultFromHeuristicValue(beta));
          			  result := ABPreOrdre(plat,InfosMilieu,defense,pere,couleur,profondeurDepartPreordre,fenetre,canDoProbCut);

          			  {
          			  WritelnCoupDansRapport(coup);
          			  WritelnNumDansRapport('  minimax value = ',GetMinimaxValueOfResult(result));
          			  WritelnStringAndReelDansRapport('  proof number = ',GetProofNumberOfResult(result),4);
          			  WritelnStringAndReelDansRapport('  disproof number = ',GetDisproofNumberOfResult(result),4);
          			  }

          			  if gProfondeurCoucheProofNumberSearch > 0
          			    then LanceurMilieuDePartie := Trunc(GetProofNumberOfResult(result))
          			    else LanceurMilieuDePartie := SearchResultEnMidgameEval(result);

          			end;


      			  TesterClefHashage(copieDeClefHashage,'LanceurMilieuDePartie');

            end
          else
            LanceurMilieuDePartie := -6400;



        {$IFC USE_DEBUG_STEP_BY_STEP}
        with gDebuggageAlgoFinaleStepByStep do
          DisposePositionEtTraitSet(positionsCherchees);
        {$ENDC}
    end;

end;

procedure AfficheClassementPreordre;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin
      if (interruptionReflexion = pasdinterruption)  then
        begin
    		  if (coulPourMeilleurFin = AQuiDeJouer) and not(CassioEstEnTrainDeCalculerPourLeZoo)
    		    then EcritAnnonceFinaleDansMeilleureSuite(inTypeCalculFinale,noCoupRecherche,kDeltaFinaleInfini);

    		  case inTypeCalculFinale of
  		       ReflGagnant,ReflRetrogradeGagnant,ReflGagnantExhaustif:
  		         SetValReflex(classement,MFniv,nbCoup,nbCoup,ReflAnnonceGagnant,noCoupRecherche,MAXINT_16BITS,inCouleurFinale);
  		       ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif:
  		         SetValReflex(classement,MFniv,nbCoup,nbCoup,ReflAnnonceParfait,noCoupRecherche,MAXINT_16BITS,inCouleurFinale);
  		       otherwise
  		         SetValReflex(classement,MFniv,nbCoup,nbCoup,ReflAnnonceGagnant,noCoupRecherche,MAXINT_16BITS,inCouleurFinale);
  		     end;

    		  if affichageReflexion.doitAfficher and doitEcrireReflexFinale then EcritReflexion('AfficheClassementPreordre');
    		end;
    end;
end;

procedure AfficheClassementTriDesCoups(profondeurCettePasse,indexDuCoup : SInt32; affichageImmediat : boolean);
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin
      if (interruptionReflexion = pasdinterruption) then
        begin
    		  if (coulPourMeilleurFin = AQuiDeJouer) and not(CassioEstEnTrainDeCalculerPourLeZoo)
    		    then EcritAnnonceFinaleDansMeilleureSuite(inTypeCalculFinale,noCoupRecherche,kDeltaFinaleInfini);

    		    case inTypeCalculFinale of
    		       ReflGagnant,ReflRetrogradeGagnant,ReflGagnantExhaustif:
    		         SetValReflex(classement,profondeurCettePasse,indexDuCoup,nbCoup,ReflTriGagnant,noCoupRecherche,MAXINT_16BITS,inCouleurFinale);
    		       ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif:
    		         SetValReflex(classement,profondeurCettePasse,indexDuCoup,nbCoup,ReflTriParfait,noCoupRecherche,MAXINT_16BITS,inCouleurFinale);
    		       otherwise
    		         SetValReflex(classement,profondeurCettePasse,indexDuCoup,nbCoup,ReflTriGagnant,noCoupRecherche,MAXINT_16BITS,inCouleurFinale);
    		     end;

    		  if affichageReflexion.doitAfficher and doitEcrireReflexFinale then
    		    if affichageImmediat
    		      then EcritReflexion('AfficheClassementTriDesCoups')
    		      else LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant),'AfficheClassementTriDesCoups');

    		  {SysBeep(0);
    		  AttendFrappeClavier;}
    		end;
    end;
end;

procedure TrierClassementAuTemps(var myClassement : ListOfMoveRecords; indexMin,indexMax : SInt32);
var k,t,maxClefDeTri,indexDuMaximum : SInt32;
    tempElement : MoveRecord;
begin
  with variablesMakeEndgameSearch do
    begin
      if indexMin < indexMax then
        begin
          {tri par extraction suivant le notePourLeTri decroissant}
          for k := indexMin to indexMax do
            begin
              maxClefDeTri := myClassement[k].notePourLeTri;
              for t := k+1 to indexMax do
                if myClassement[t].notePourLeTri > maxClefDeTri then
                  begin
                    maxClefDeTri := myClassement[t].notePourLeTri;
                    indexDuMaximum := t;
                  end;
              if maxClefDeTri > myClassement[k].notePourLeTri then
                begin
                  tempElement := myClassement[k];
                  myClassement[k] := myClassement[indexDuMaximum];
                  myClassement[indexDuMaximum] := tempElement;
                end;
            end;
        end;
    end;
end;


procedure TrierClassementSiMeilleureSuiteAEteCalculeeParOptimalite(var myClassement : ListOfMoveRecords; myNbCoup : SInt32);
var coupAMettreEnTete : SInt32;
    i,k : SInt32;
    temp : MoveRecord;
begin
  with variablesMakeEndgameSearch do
    begin
      if meilleureSuiteAEteCalculeeParOptimalite then
        begin
           coupAMettreEnTete := GetBestMoveAttenteAnalyseDeFinale;
           if (coupAMettreEnTete >= 11) and (coupAMettreEnTete <= 88) then
             begin
               for i := 1 to myNbCoup do
                 if (myClassement[i].x = coupAMettreEnTete) and
                    (scoreDuCoupCalculeParOptimalite >= -64) and (scoreDuCoupCalculeParOptimalite <= 64) then
                   begin
                     temp := myClassement[i];
                     for k := i downto 2 do myClassement[k] := myClassement[k-1];
                     myClassement[1]      := temp;
                     myClassement[1].note := scoreDuCoupCalculeParOptimalite;
                     exit(TrierClassementSiMeilleureSuiteAEteCalculeeParOptimalite);
                   end;
             end;
         end;
    end;
end;


procedure PassePreordonnancementDesCoups(profondeurDeCettePasse : SInt32; canDoProbCut : boolean);
var i,iCourant,alpha,beta : SInt32;
    tickChronoPreordre,meilleurCoupSelonPreordre : SInt32;
    coupLegal : boolean;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      AfficheClassementTriDesCoups(profondeurDeCettePasse,nbCoup,true);

      {WritelnNumDansRapport('Entree dans PassePreordonnancementDesCoups, profondeurDeCettePasse = ', profondeurDeCettePasse);}



      maxPourOrdonnancement := -320000;
      meilleurCoupSelonPreordre := 0;
      for i := 1 to nbCoup do
        if (interruptionReflexion = pasdinterruption) then
          begin
             tickChronoPreordre := TickCount;
             iCourant := classement[i].x;

             platClass := inPositionPourFinale;
             jouableClass := emplacementsJouablesFinale;
             nbBlancClass := inNbreBlancsFinale;
             nbNoirClass := inNbreNoirsFinale;
             frontClass := frontiereFinale;

             //WritelnNumDansRapport('PassePreordonnancementDesCoups, coup = ',iCourant);

             coupLegal := ModifPlatLongint(iCourant,coulPourMeilleurFin,platClass,jouableClass,
                                           nbBlancClass,nbNoirClass,frontClass);

             EnleverDeLaListeChaineeDesCasesVides(iCourant);

             {
             noteClass := -Evaluation(platClass,Couldefense,nbBlancClass,nbNoirClass,
                                 jouableClass,frontClass,false,-30000,30000,bdilong);
             }
             if profondeurDeCettePasse <= 1
               then
                 begin
                   alpha := -6400;
                   beta := 6400;
                 end
               else
                 begin
                   alpha := Max(maxPourOrdonnancement,-6400);
                   beta := 6400;
                 end;

             if alpha <= -6400
               then
                 begin
                    noteclass := -LanceurMilieuDePartie(profondeurDeCettePasse,-beta,-alpha,platClass,jouableClass,defenseEndgameSearch,
                                                        iCourant,coulDefense,nbBlancClass,nbNoirClass,frontClass,canDoProbCut);
                 end
               else
                 begin
                    noteclass := -LanceurMilieuDePartie(profondeurDeCettePasse,-alpha-1,-alpha,platClass,jouableClass,defenseEndgameSearch,
                                                        iCourant,coulDefense,nbBlancClass,nbNoirClass,frontClass,canDoProbCut);
                    if (alpha < noteclass) and (noteclass < beta) and (interruptionReflexion = pasdinterruption) then
                      begin
                        noteclass := -LanceurMilieuDePartie(profondeurDeCettePasse,-beta,-noteclass,platClass,jouableClass,defenseEndgameSearch,
                                                            iCourant,coulDefense,nbBlancClass,nbNoirClass,frontClass,canDoProbCut);
                        if noteclass <= alpha+1 then noteclass := alpha;
                      end;
                 end;
             RemettreDansLaListeChaineeDesCasesVides(iCourant);



             if (BAND(gVecteurParite,constanteDeParite[iCourant]) <> 0) and not(utilisationNouvelleEval)
               then noteclass := noteclass + 400;

             if (gNbreVidesCeQuadrantCoupGagnant[numeroQuadrant[iCourant]] = 1) then
               if PeutJouerIci(coulDefense,iCourant,inPositionPourFinale)
                 then noteclass := noteclass + 4000;

             if (noteclass > 6400)
               then noteclass := 6400;


             {WritelnCoupAndNumDansRapport(iCourant, noteclass);}

             classement[i].note              := noteclass;
             classement[i].theDefense        := defenseEndgameSearch;
             classement[i].temps             := classement[i].temps + (TickCount-tickChronoPreordre);
             if profondeurDeCettePasse <= 2
               then
                 begin
                   classement[i].noteMilieuDePartie := classement[i].note;
                   classement[i].notePourLeTri      := classement[i].noteMilieuDePartie;
                 end
               else
                 begin
                   classement[i].notePourLeTri      := (classement[i].noteMilieuDePartie div 8) + Min(classement[i].temps div 60, 100);
                 end;

             if noteclass > maxPourOrdonnancement then
               begin
                 maxPourOrdonnancement := noteclass;
                 meilleurCoupSelonPreordre := iCourant;
               end;
             {tri par insertion de classement suivant le temps et la note de milieu de partie}
             TrierClassementAuTemps(classement,1,i);
             AfficheClassementTriDesCoups(profondeurDeCettePasse,i,true);
          end;

      if (interruptionReflexion = pasdinterruption) then
        begin

          {on donne un bonus au meilleur coup pour le tri, pour etre sur qu'il sera en tete}
          for i := 1 to nbCoup do
            if classement[i].x = meilleurCoupSelonPreordre then
              classement[i].notePourLeTri := classement[i].notePourLeTri + 20000;

          TrierClassementAuTemps(classement,1,nbCoup);

          AfficheClassementTriDesCoups(profondeurDeCettePasse,nbCoup,true);
        end;


      {WritelnDansRapport('sortie dans PassePreordonnancementDesCoups');
      WritelnDansRapport('');}

    end;
end;




procedure PreordonnancementDesCoups;
var i,ticks : SInt32;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin
      estimationPositionDApresMilieu := 0;
      if (MFniv > 8) then
        begin
          Calcule_Valeurs_Tactiques(inPositionPourFinale,false);
          LanceChrono;
          LanceChronoCetteProf;
          tempsAlloue := 1000000000;  {pour ne pas se faire interrompre pendant l'ordonnancement}

          for i := 1 to nbCoup do
            begin
              classement[i].note := -3200000;
              classement[i].noteMilieuDePartie := -3200000;
              classement[i].notePourLeTri := -3200000;
              classement[i].delta := kTypeMilieuDePartie;
            end;


          ticks := TickCount;
          PassePreordonnancementDesCoups(1,false);

          PassePreordonnancementDesCoups(3,true);


          profondeurPreordre := Min(1 + (inProfondeurFinale div 2),Min((inProfondeurFinale div 3)+5,10));


          { ne pas faire une recherche preliminaire de milieu trop loin
            dans les positions tres deséquilibrées : c'est inutile... }
          if ( classement[1].note < -5600) or
             ( classement[1].note > 5600)
            then profondeurPreordre := Min(profondeurPreordre,6);

          { ni si la suite est dans l'arbre ! }
          if not(seMefierDesScoresDeLArbre) and SuiteParfaiteEstConnueDansGameTree and
             GenreDeReflexionInSet(inTypeCalculFinale,[ReflGagnant,ReflParfait,ReflRetrogradeGagnant,ReflRetrogradeParfait])
            then profondeurPreordre := Min(profondeurPreordre,3);

          { s'il faut la faire, faut la faire... }
          if (profondeurPreordre > 3) then
            PassePreordonnancementDesCoups(profondeurPreordre,true);


          estimationPositionDApresMilieu := 2*(NoteCassioEnScoreFinal(classement[1].note)-32);

          {
          if (inProfondeurFinale >= 25) and utilisationNouvelleEval and InRange(estimationPositionDApresMilieu,-8,8) then
            begin
              profondeurPreordre := 12;
              PassePreordonnancementDesCoups(profondeurPreordre,true);
              estimationPositionDApresMilieu := 2*(NoteCassioEnScoreFinal(classement[1].note)-32);
            end;
          }

          if InfosTechniquesDansRapport and inCommentairesDansRapportFinale and not(InfosDansRapportSontCensurees(noCoupRecherche)) and (interruptionReflexion = pasdinterruption) then
            begin
              AnnonceRechercheDansRapport(noCoupRecherche);
              ChangeFontFaceDansRapport(italic);
              // ChangeFontColorDansRapport(MarronCmd);  // VertSapinCmd et MarinePaleCmd sont bien aussi
              WriteDansRapport('Temps du tri (prof. '+NumEnString(profondeurPreordre+1) + ') par le milieu = ');
              WriteDansRapport(NumEnString((TickCount-ticks+30) div 60)+' sec.');
              if utilisationNouvelleEval
                then WriteDansRapport(' Estimation de la position = '+NoteEnString(classement[1].note,true,0,2))
                else WriteNumDansRapport(' Estimation de la position = ',estimationPositionDApresMilieu);
              WritelnDansRapport(' pions');
              ChangeFontFaceDansRapport(normal);
              ChangeFontColorDansRapport(NoirCmd);
            end;


        end;

     if meilleureSuiteAEteCalculeeParOptimalite then
       TrierClassementSiMeilleureSuiteAEteCalculeeParOptimalite(classement,nbCoup);

      AfficheClassementPreordre;

    end;
end;

function NegaCStar(lower,upper : SInt32; couleur,ProfRecherche,nbBla,nbNoi,XCourant : SInt32; jeu : plateauOthello;
                      var meilleurCoup : SInt32; var InfosMilieuDePartie : InfosMilieuRec) : SInt32;
var v,t: SInt32;
    suiteOK : boolean;
begin
  with variablesMakeEndgameSearch do
    begin

      FenetreLargePourRechercheScoreExact := false;
      suiteOK := false;
      repeat
        v := 2*((lower+upper) div 4);
        t := -LanceurABFin(variablesMakeEndgameSearch, jeu,meilleurCoup,XCourant,couleur,ProfRecherche,
                          -v-1,-v+1,nbBla,nbNoi,InfosMilieuDePartie);
        if t = v then suiteOK := true;
        if t >= v then lower := t;
        if t <= v then upper := t;

        WriteNumAt('lower = ',-upper,10,30);
        WriteNumAt('upper = ',-lower,10,40);
        WriteNumAt('v = ',-v,110,30);
        WriteNumAt('t = ',-t,110,40);

      until suiteOK or (lower >= upper) or ValeurDeFinaleInexploitable(t);

      NegaCStar := t;
    end;
end;


function Algo_SSSStar(lower,upper : SInt32; couleur,ProfRecherche,nbBla,nbNoi : SInt32; jeu : plateauOthello;
                      var meilleurCoup : SInt32; var InfosMilieuDePartie : InfosMilieuRec) : SInt32;
var v,t : SInt32;
    copieDeClefHashage : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin

      bestMode := false;
      FenetreLargePourRechercheScoreExact := false;

      copieDeClefHashage := SetClefHashageGlobale(BXOR(clefHashageCoupGagnant , (IndiceHash^^[couleur,dernierCoupJoue])));

      t := upper;
      repeat
        v := t;
        t := -LanceurABFin(variablesMakeEndgameSearch,jeu,meilleurCoup,dernierCoupJoue,couleur,ProfRecherche,-v,-v+1,nbBla,nbNoi,InfosMilieuDePartie);
        EssaieSetPortWindowPlateau;
        WriteNumAt('SSS* score >= ',-t,10,40);
      until (t = v) or (t <= lower) or ValeurDeFinaleInexploitable(t);

      TesterClefHashage(copieDeClefHashage,'Algo_SSStar');

      Algo_SSSStar := -t;
    end;
end;

function Algo_AlphaBetaBrut(lower,upper : SInt32; couleur,ProfRecherche,nbBla,nbNoi : SInt32; jeu : plateauOthello;
                      var meilleurCoup : SInt32; var InfosMilieuDePartie : InfosMilieuRec) : SInt32;
var t : SInt32;
    copieDeClefHashage : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin

      bestMode := false;
      FenetreLargePourRechercheScoreExact := true;

      copieDeClefHashage := SetClefHashageGlobale(BXOR(clefHashageCoupGagnant , (IndiceHash^^[couleur,dernierCoupJoue])));

      t := -LanceurABFin(variablesMakeEndgameSearch,jeu,meilleurCoup,dernierCoupJoue,couleur,ProfRecherche,-upper,-lower,nbBla,nbNoi,InfosMilieuDePartie);
      EssaieSetPortWindowPlateau;
      WriteNumAt('AlphaBeta score = ',-t,10,30);
      FenetreLargePourRechercheScoreExact := false;

      TesterClefHashage(copieDeClefHashage,'Algo_AlphaBetaBrut');

      Algo_AlphaBetaBrut := -t;
    end;
end;



function Algo_NegaCStar(lower,upper : SInt32; couleur,ProfRecherche,nbBla,nbNoi : SInt32; jeu : plateauOthello;
                      var meilleurCoup : SInt32; var InfosMilieuDePartie : InfosMilieuRec) : SInt32;
var t : SInt32;
    copieDeClefHashage : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin
      bestMode := false;

      copieDeClefHashage := SetClefHashageGlobale(BXOR(clefHashageCoupGagnant , (IndiceHash^^[couleur,dernierCoupJoue])));

      t := NegaCStar(lower,upper,couleur,ProfRecherche,nbBla,nbNoi,dernierCoupJoue,jeu,meilleurCoup,InfosMilieuDePartie);

      TesterClefHashage(copieDeClefHashage,'Algo_NegaCStar');

      Algo_NegaCStar := -t;
    end;
end;




function MinimaxFinale(quelleValeurCible,couleur,minimaxprof,longClass,nbBla,nbNoi : SInt32; var jeu : plateauOthello;
                    var empl : plBool; var frontiereMinimax : InfoFront; classementAuTempsSiTousMoinsBonsQueValeurCible : boolean;
                    var classementMinimax : ListOfMoveRecords) : SInt32;
var XCourant : SInt32;
    valXY : SInt32;
    platMod : plateauOthello;
    jouableMod : plBool;
    nbBlancMod,nbNoirMod : SInt32;
    frontMod : InfoFront;
    InfosMod : InfosMilieuRec;
    sortieDeBoucleAcceleree : boolean;
    toutesLesPassesTerminees : boolean;
    peutUtiliserDichotomie : boolean;
    classAux : ListOfMoveRecords;
    tempElementClass : MoveRecord;
    compteur : SInt32;
    indice_du_meilleur : SInt32;
    nouvelIndexDansClassement : SInt32;
    noteModif : SInt32;
    bestAB,betaAB : SInt32;
    maxConnuSiToutEstMoinsBonQueValeurCible : SInt32;
    TickChronoPourClassaux,TempsDeXCourant : SInt32;
    tempsPourTickChronoPourClassaux : SInt32;
    NoteMilieuDeXCourant,NotePourLeTriDeXCourant : SInt32;
    nbCoupuresHeuristiquesDeXCourant : SInt32;
    AEteEnTete : plOthLongint;
    nbCoupsAyantEteEnTete : SInt32;
    deltaDeXCourantDevientInfini : boolean;
    deltaDeXCourantAvantRecherche : SInt32;
    deltaDeXCourantApresRecherche : SInt32;
    doitAppelerGestionMeilleureSuite : boolean;
    noteAfficheeSurOthellier : SInt32;
    coupLegal : boolean;

label BOUCLE_SUR_LES_FILS;


procedure ChangeBestAB(newBestAB : SInt32; fonctionAppelante : String255);
var messageErreur : String255;
begin
  with variablesMakeEndgameSearch do
    begin

      if debuggage.algoDeFinale then
        begin
          if Pos('init', fonctionAppelante) > 0
            then messageErreur := '?'
            else messageErreur := '???-ASSERT-???';
          FinRapport;
    		  TextNormalDansRapport;
    		  if Pos('init',fonctionAppelante) > 0
    		    then
    		      begin
    		        WritelnDansRapport('');
    		        WriteDansRapport('init BestAB ');
    		      end
    		    else
    		      WriteDansRapport('change BestAB ('+fonctionAppelante+') ');
    		  if bestAB = -infini
    		    then WriteDansRapport('(-∞')
    		    else
    		      if (bestAB >= -64) and (bestAB <= 64)
    		        then WriteNumDansRapport('(',bestAB)
    		        else WriteDansRapport('('+messageErreur);
    		  if betaAB = +infini
    		    then WriteDansRapport(', +∞')
    		    else
    		      if (betaAB >= -64) and (betaAB <= 64)
    		        then WriteNumDansRapport(', ',betaAB)
    		        else WriteDansRapport(', '+messageErreur);
    		  WriteDansRapport(')');
    		end;

      bestAB := newBestAB;

      if debuggage.algoDeFinale then
        begin
    		  WriteDansRapport(' -> ');
    		  if bestAB = -infini
    		    then WriteDansRapport('(-∞')
    		    else
    		      if (bestAB >= -64) and (bestAB <= 64)
    		        then WriteNumDansRapport('(',bestAB)
    		        else WriteDansRapport('('+messageErreur);
    		  if betaAB = +infini
    		    then WriteDansRapport(', +∞')
    		    else
    		      if (betaAB >= -64) and (betaAB <= 64)
    		        then WriteNumDansRapport(', ',betaAB)
    		        else WriteDansRapport(', '+messageErreur);
    		  WriteDansRapport(')');
    		  WritelnDansRapport(' ['+DeltaFinaleEnChaine(deltaFinaleCourant)+']');
    		end;
    end;
end;

procedure ChangeBetaAB(newBetaAB : SInt32; fonctionAppelante : String255);
var messageErreur : String255;
begin
  with variablesMakeEndgameSearch do
    begin
      if debuggage.algoDeFinale then
        begin
          if Pos('init', fonctionAppelante) > 0
            then messageErreur := '?'
            else messageErreur := '???-ASSERT-???';
          FinRapport;
    		  TextNormalDansRapport;
    		  if Pos('init',fonctionAppelante) > 0
    		    then
    		      begin
    		        WriteDansRapport('init betaAB ');
    		      end
    		    else
    		      WriteDansRapport('change betaAB ('+fonctionAppelante+') ');
    		  if bestAB = -infini
    		    then WriteDansRapport('(-∞')
    		    else
    		      if (bestAB >= -64) and (bestAB <= 64)
    		        then WriteNumDansRapport('(',bestAB)
    		        else WriteDansRapport('('+messageErreur);
    		  if betaAB = +infini
    		    then WriteDansRapport(', +∞')
    		    else
    		      if (betaAB >= -64) and (betaAB <= 64)
    		        then WriteNumDansRapport(', ',betaAB)
    		        else WriteDansRapport(', '+messageErreur);
    		  WriteDansRapport(')');
    		end;

      betaAB := newBetaAB;

      if debuggage.algoDeFinale then
        begin
    		  WriteDansRapport(' -> ');
    		  if bestAB = -infini
    		    then WriteDansRapport('(-∞')
    		    else
    		      if (bestAB >= -64) and (bestAB <= 64)
    		        then WriteNumDansRapport('(',bestAB)
    		        else WriteDansRapport('('+messageErreur);
    		  if betaAB = +infini
    		    then WriteDansRapport(', +∞')
    		    else
    		      if (betaAB >= -64) and (betaAB <= 64)
    		        then WriteNumDansRapport(', ',betaAB)
    		        else WriteDansRapport(', '+messageErreur);
    		  WriteDansRapport(')');
    		  WritelnDansRapport(' ['+DeltaFinaleEnChaine(deltaFinaleCourant)+']');
        end;
    end;
end;

procedure SetNoteDansElementClassement(var classement : ListOfMoveRecords; index,valeur,deltaFinale : SInt32; var tickchrono : SInt32);
begin
  //with variablesMakeEndgameSearch do
    begin
      if variablesMakeEndgameSearch.passeEhancedTranspositionCutOffEstEnCours and EstLaListeDesCoupsDeFenetreReflexion(classement)
        then exit(SetNoteDansElementClassement);


      with classement[index] do
        begin
          note := valeur;
          delta := deltaFinale;
          if (@classement <> @classAux) then
            begin
              temps := temps+(TickCount-tickchrono);
              tickchrono := TickCount;
            end;
        end;

      if affichageReflexion.doitAfficher and EstLaListeDesCoupsDeFenetreReflexion(classement) and doitEcrireReflexFinale
        then LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant),'SetNoteDansElementClassement');
    end;
end;


function CalculNormal : SInt32;
var t,bas_fenetre,haut_fenetre: SInt32;
    largeur_fenetre,n,ticks : SInt32;
    copieDeClefHashage : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin
      n := nbreNoeudsGeneresFinale;
      ticks := TickCount;

      passeDeRechercheAuMoinsValeurCible := false;
      valeurCible := 0;

      copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);

      if bestMode and (compteur > 1)
        then
          begin
            FenetreLargePourRechercheScoreExact := false;
            t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                        Max(-bestAB-1,-64),Min(-bestAB,64),nbBlancMod,nbNoirMod,InfosMod);

            largeur_fenetre := 2;

            if not(ValeurDeFinaleInexploitable(t)) then
            if (bestAB < t) and (t < betaAB) then
               repeat
                 FenetreLargePourRechercheScoreExact := false;
                 SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);

                 FenetreLargePourRechercheScoreExact := true;
                 bas_fenetre := t-1;
                 haut_fenetre := Min(bas_fenetre+largeur_fenetre,betaAB);
                 t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                             Max(-haut_fenetre,-64),Min(-bas_fenetre,64),nbBlancMod,nbNoirMod,InfosMod);

                 largeur_fenetre := 2*largeur_fenetre;
                 if largeur_fenetre > 16 then largeur_fenetre := 16;

               until ((bas_fenetre < t) and (t < haut_fenetre)) or (t >= betaAB) or ValeurDeFinaleInexploitable(t);

            {
              begin
                SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
                t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                            Max(-betaAB,-64),Min(-t+1,64),nbBlancMod,nbNoirMod,indiceHashDummy);
              end;
            }
          end
        else
          begin
            FenetreLargePourRechercheScoreExact := false;
            t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                      Max(-betaAB,-64),Min(-bestAB,64),nbBlancMod,nbNoirMod,InfosMod);
          end;
      CalculNormal := t;

      TesterClefHashage(copieDeClefHashage,'CalculNormal(Finale)');

      {
      n := nbreNoeudsGeneresFinale-n;
      ticks := TickCount-ticks;
      WriteNumAt('nb nœuds/sec = ',(n*60) div ticks,30,80);
      }
    end;
end;


function SSS_Dual : SInt32;
var t,bas_fenetre,haut_fenetre,lower,upper : SInt32;
    largeur_fenetre,n,ticks : SInt32;
    copieDeClefHashage : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin
      n := nbreNoeudsGeneresFinale;
      ticks := TickCount;

      passeDeRechercheAuMoinsValeurCible := false;
      valeurCible := 0;

      copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);

      if not(bestMode)
        then
          begin
            FenetreLargePourRechercheScoreExact := false;
            t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                Max(-betaAB,-64),Min(-bestAB,64),nbBlancMod,nbNoirMod,InfosMod);
          end
        else
          if compteur = 1
            then
              begin
                t := NegaCStar(-64,64,coulDefense,minimaxprof,nbBlancMod,nbNoirMod,XCourant,platMod,defenseEndgameSearch,InfosMod);

                SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);
              end
            else
              begin
                FenetreLargePourRechercheScoreExact := false;
                upper := betaAB;
                lower := Max(-64,bestAB);
                t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                            Max(-lower-1,-64),Min(-lower,64),nbBlancMod,nbNoirMod,InfosMod);

                largeur_fenetre := 2;

                if not(ValeurDeFinaleInexploitable(t)) then
                if (lower < t) and (t < upper) then
                   repeat
                     FenetreLargePourRechercheScoreExact := false;
                     SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);

                     FenetreLargePourRechercheScoreExact := true;
                     bas_fenetre := t-1;
                     haut_fenetre := Min(t+largeur_fenetre-1,upper);
                     t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                                 Max(-haut_fenetre,-64),Min(-bas_fenetre,64),nbBlancMod,nbNoirMod,InfosMod);

                     largeur_fenetre := 2*largeur_fenetre;
                     if largeur_fenetre > 16 then largeur_fenetre := 16;

                   until ((bas_fenetre < t) and (t < haut_fenetre)) or (t >= upper) or ValeurDeFinaleInexploitable(t);
               end;
      SSS_Dual := t;

      TesterClefHashage(copieDeClefHashage,'SSS_Dual');

      {
      n := nbreNoeudsGeneresFinale-n;
      ticks := TickCount-ticks;
      WriteNumAt('nb nœuds/sec = ',(n*60) div ticks,30,80);
      }
    end;
end;


function Dichotomie_first(quelleValeurCible : SInt32; forcerDichotomie : boolean) : SInt32;
var t,bas_fenetre,haut_fenetre,lower,upper : SInt32;
    largeur_fenetre,n,ticks : SInt32;
    copieDeClefHashage : SInt32;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      n := nbreNoeudsGeneresFinale;
      ticks := TickCount;

      valeurCible := quelleValeurCible;

      copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);

      if not(bestMode) or coupGagnantAUneFenetreAlphaBetaReduite
        then
          begin
            FenetreLargePourRechercheScoreExact := false;
            t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,-betaAB,-bestAB,nbBlancMod,nbNoirMod,InfosMod);
          end
        else
          if passeDeRechercheAuMoinsValeurCible then
            begin
              FenetreLargePourRechercheScoreExact := false;
              lower := -64;
              upper := 64;

              t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,-valeurCible-1,-valeurCible+1,nbBlancMod,nbNoirMod,InfosMod);

              if (t > valeurCible) and not(ValeurDeFinaleInexploitable(t)) then
                 begin
                    largeur_fenetre := 2;
                    repeat

      	              classAux[compteur].note := t;
      	              classAux[compteur].delta := deltaFinaleCourant;

      	              if not(passeEhancedTranspositionCutOffEstEnCours) then
      	                if analyseRetrograde.enCours
      	                  then
      	                    SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflRetrogradeParfait,noCoupRecherche,compteur,inCouleurFinale)
      	                  else
      	                    if analyseIntegraleDeFinale
      	                      then SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfaitExhaustif,noCoupRecherche,compteur,inCouleurFinale)
      	                      else SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfait,noCoupRecherche,compteur,inCouleurFinale);

      	              SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);

      	              FenetreLargePourRechercheScoreExact := true;
      	              passeDeRechercheAuMoinsValeurCible := false;
      	              bas_fenetre := Max(t-1,lower);
      	              haut_fenetre := Min(bas_fenetre+largeur_fenetre,upper);




      	              if bas_fenetre >= haut_fenetre then
      	                begin
      	                  SysBeep(0);
      	                  WritelnDansRapport('Problème dans Dichotomie_first : bas_fenetre >= haut_fenetre {1}');
      	                  WritelnStringAndBoolDansRapport('FenetreLargePourRechercheScoreExact = ',FenetreLargePourRechercheScoreExact);
      	                  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible = ',passeDeRechercheAuMoinsValeurCible);
      	                  WritelnNumDansRapport('valeurCible = ',valeurCible);
      	                  WritelnNumDansRapport('bas_fenetre = ',bas_fenetre);
      	                  WritelnNumDansRapport('haut_fenetre = ',haut_fenetre);
      	                  WritelnNumDansRapport('t = ',t);
      	                  WritelnNumDansRapport('largeur_fenetre = ',largeur_fenetre);
      	                  WritelnNumDansRapport('lower = ',lower);
      	                  WritelnNumDansRapport('upper = ',upper);
      	                  WritelnNumDansRapport('bestAB = ',bestAB);
      	                  WritelnNumDansRapport('betaAB = ',betaAB);
      	                  WritelnDansRapport('');
      	                  exit(Dichotomie_first);
      	                end;


      	              t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
      	                           -haut_fenetre,-bas_fenetre,nbBlancMod,nbNoirMod,InfosMod);

      	              largeur_fenetre := 2*largeur_fenetre;
      	              if largeur_fenetre > 16 then largeur_fenetre := 16;

      	           until ({(bas_fenetre < t) and} (t < haut_fenetre)) or (t >= upper) or ValeurDeFinaleInexploitable(t);
                 end;

                if not(ValeurDeFinaleInexploitable(t)) then
                  passeDeRechercheAuMoinsValeurCible := (t < valeurCible);

             end
            else  {passeDeRechercheAuMoinsValeurCible = false}
              if (compteur = 1) or forcerDichotomie
                then
                  begin
                    FenetreLargePourRechercheScoreExact := false;
                    lower := Max(-64,bestAB);
                    upper := Min(betaAB,64);

                    t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,-valeurCible-1,-valeurCible+1,nbBlancMod,nbNoirMod,InfosMod);

                    if odd(t) then if t > valeurCible then t := t+1 else t := t-1;

                    largeur_fenetre := 2;

                    if (t > valeurCible) and (t < upper) and not(ValeurDeFinaleInexploitable(t)) then
                        repeat

                        classAux[compteur].note := t;
                        classAux[compteur].delta := deltaFinaleCourant;

                        if not(passeEhancedTranspositionCutOffEstEnCours) then
                          if analyseRetrograde.enCours
                            then SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflRetrogradeParfait,noCoupRecherche,compteur,inCouleurFinale)
                            else
                              if analyseIntegraleDeFinale
                                then SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfaitExhaustif,noCoupRecherche,compteur,inCouleurFinale)
                                else SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfait,noCoupRecherche,compteur,inCouleurFinale);

                        SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);

                        FenetreLargePourRechercheScoreExact := true;
                        bas_fenetre := Max(t-1,lower);
                        haut_fenetre := Min(bas_fenetre+largeur_fenetre,upper);

                        if (bas_fenetre = 64) and (haut_fenetre = 64) then
                           bas_fenetre := 63;


                        if bas_fenetre >= haut_fenetre then
        	                begin
        	                  SysBeep(0);
        	                  WritelnDansRapport('Problème dans Dichotomie_first : bas_fenetre >= haut_fenetre {2}');
        	                  WritelnStringAndBoolDansRapport('FenetreLargePourRechercheScoreExact = ',FenetreLargePourRechercheScoreExact);
        	                  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible = ',passeDeRechercheAuMoinsValeurCible);
        	                  WritelnNumDansRapport('valeurCible = ',valeurCible);
        	                  WritelnNumDansRapport('bas_fenetre = ',bas_fenetre);
        	                  WritelnNumDansRapport('haut_fenetre = ',haut_fenetre);
        	                  WritelnNumDansRapport('t = ',t);
        	                  WritelnNumDansRapport('largeur_fenetre = ',largeur_fenetre);
        	                  WritelnNumDansRapport('lower = ',lower);
        	                  WritelnNumDansRapport('upper = ',upper);
        	                  WritelnNumDansRapport('bestAB = ',bestAB);
        	                  WritelnNumDansRapport('betaAB = ',betaAB);
        	                  WritelnDansRapport('');
        	                  exit(Dichotomie_first);
        	                end;


                        t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                                    -haut_fenetre,-bas_fenetre,nbBlancMod,nbNoirMod,InfosMod);

                        largeur_fenetre := 2*largeur_fenetre;
                        if largeur_fenetre > 16 then largeur_fenetre := 16;

                      until ({(bas_fenetre < t) and} (t < haut_fenetre)) or (t >= upper) or ValeurDeFinaleInexploitable(t);

                    if (t < valeurCible) and (t > lower) and not(ValeurDeFinaleInexploitable(t)) then
                      repeat

                        classAux[compteur].note := t;
                        classAux[compteur].delta := deltaFinaleCourant;

                        if not(passeEhancedTranspositionCutOffEstEnCours) then
                          if analyseRetrograde.enCours
                            then SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflRetrogradeParfait,noCoupRecherche,compteur,inCouleurFinale)
                            else
                              if analyseIntegraleDeFinale
                                then SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfaitExhaustif,noCoupRecherche,compteur,inCouleurFinale)
                                else SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfait,noCoupRecherche,compteur,inCouleurFinale);

                        SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);

                        FenetreLargePourRechercheScoreExact := true;

                        haut_fenetre := Min(t+1,upper);
                        bas_fenetre := Max(haut_fenetre-largeur_fenetre,lower);

                        if bas_fenetre >= haut_fenetre then
        	                begin
        	                  SysBeep(0);
        	                  WritelnDansRapport('Problème dans Dichotomie_first : bas_fenetre >= haut_fenetre {3}');
        	                  WritelnStringAndBoolDansRapport('FenetreLargePourRechercheScoreExact = ',FenetreLargePourRechercheScoreExact);
        	                  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible = ',passeDeRechercheAuMoinsValeurCible);
        	                  WritelnNumDansRapport('valeurCible = ',valeurCible);
        	                  WritelnNumDansRapport('bas_fenetre = ',bas_fenetre);
        	                  WritelnNumDansRapport('haut_fenetre = ',haut_fenetre);
        	                  WritelnNumDansRapport('t = ',t);
        	                  WritelnNumDansRapport('largeur_fenetre = ',largeur_fenetre);
        	                  WritelnNumDansRapport('lower = ',lower);
        	                  WritelnNumDansRapport('upper = ',upper);
        	                  WritelnNumDansRapport('bestAB = ',bestAB);
        	                  WritelnNumDansRapport('betaAB = ',betaAB);
        	                  WritelnDansRapport('');
        	                  exit(Dichotomie_first);
        	                end;


                        t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                                     -haut_fenetre,-bas_fenetre,nbBlancMod,nbNoirMod,InfosMod);

                        largeur_fenetre := 2*largeur_fenetre;
                        if largeur_fenetre > 16 then largeur_fenetre := 16;

                      until ((bas_fenetre < t) {and (t < haut_fenetre)}) or (t <= lower) or ValeurDeFinaleInexploitable(t);

                  end
                else
                  begin
                    lower := Max(-64,bestAB);
                    upper := Min(betaAB,64);

                    FenetreLargePourRechercheScoreExact := false;
                    t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                                Max(-lower-1,-64),Min(-lower,64),nbBlancMod,nbNoirMod,InfosMod);

                    largeur_fenetre := 2;

                    if not(ValeurDeFinaleInexploitable(t)) then
                    if (lower < t) and (t < upper) then
                       repeat
                         SetNoteDansElementClassement(ReflexData^.class,compteur,t,deltaFinaleCourant,tickChrono);

                         FenetreLargePourRechercheScoreExact := true;
                         bas_fenetre := Max(t-1,lower);
                         haut_fenetre := Min(bas_fenetre+largeur_fenetre,upper);


                         if bas_fenetre >= haut_fenetre then
        		                begin
        		                  SysBeep(0);
        		                  WritelnDansRapport('Problème dans Dichotomie_first : bas_fenetre >= haut_fenetre {4}');
        		                  WritelnStringAndBoolDansRapport('FenetreLargePourRechercheScoreExact = ',FenetreLargePourRechercheScoreExact);
        		                  WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible = ',passeDeRechercheAuMoinsValeurCible);
        		                  WritelnNumDansRapport('valeurCible = ',valeurCible);
        		                  WritelnNumDansRapport('bas_fenetre = ',bas_fenetre);
        		                  WritelnNumDansRapport('haut_fenetre = ',haut_fenetre);
        		                  WritelnNumDansRapport('t = ',t);
        		                  WritelnNumDansRapport('largeur_fenetre = ',largeur_fenetre);
        		                  WritelnNumDansRapport('lower = ',lower);
        		                  WritelnNumDansRapport('upper = ',upper);
        		                  WritelnNumDansRapport('bestAB = ',bestAB);
        		                  WritelnNumDansRapport('betaAB = ',betaAB);
        		                  WritelnDansRapport('');
        		                  exit(Dichotomie_first);
        		                end;


                         t := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                                     -haut_fenetre,-bas_fenetre,nbBlancMod,nbNoirMod,InfosMod);

                         largeur_fenetre := 2*largeur_fenetre;
                         if largeur_fenetre > 16 then largeur_fenetre := 16;

                       until ({(bas_fenetre < t) and} (t < haut_fenetre)) or (t >= upper) or ValeurDeFinaleInexploitable(t);

                   end;
      Dichotomie_first := t;

      TesterClefHashage(copieDeClefHashage,'Dichotomie_first');

      {
      n := nbreNoeudsGeneresFinale-n;
      ticks := TickCount-ticks;
      WriteNumAt('nb nœuds/sec = ',(n*60) div ticks,30,80);
      }
    end;
end;


function CalculParAnalyseDeFinale(alpha,beta : SInt32) : SInt32;
var aux : SInt32;
    copieDeClefHashage : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin
      passeDeRechercheAuMoinsValeurCible := false;
      valeurCible := 0;
      FenetreLargePourRechercheScoreExact := ((beta - alpha) > 2);

      copieDeClefHashage := SetClefHashageGlobale(clefHashageCoupGagnant);

      aux := -LanceurABFin(variablesMakeEndgameSearch,platMod,defenseEndgameSearch,XCourant,coulDefense,minimaxprof,
                  Max(-infini,-beta),Min(infini,-alpha),nbBlancMod,nbNoirMod,InfosMod);

      CalculParAnalyseDeFinale := aux;

      TesterClefHashage(copieDeClefHashage,'CalculParAnalyseDeFinale');
    end;
end;


procedure UpdateBestABAvecLeScoreDuCoupConnu(messageHandle : MessageFinaleHdl; var bestAB : SInt32);
var scoreCoupRetrograde : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin
      if messageHandle <> NIL then
        begin
    		  scoreCoupRetrograde := messageHandle^^.data[0];

    		  if debuggage.algoDeFinale then
    		    begin
    		      WritelnNumDansRapport('dans UpdateBestABAvecLeScoreDuCoupConnu, scoreCoupRetrograde = ',scoreCoupRetrograde);
    		    end;

    		  if bestAB < scoreCoupRetrograde then
    		    ChangeBestAB(scoreCoupRetrograde,'UpdateBestABAvecLeScoreDuCoupConnu');
    		  if betaAB <= bestAB then
    		    ChangeBetaAB(succ(bestAB),'UpdateBestABAvecLeScoreDuCoupConnu');
    		end;
    end;
end;


procedure GetCoupDontLeScoreEstConnu(messageHandle : MessageFinaleHdl; var coupDontLeScoreEstConnu,defenseDuCoupDontLeScoreEstConnu,scoreDuCoupDontLeScoreEstConnu : SInt32);
var localMessageData : LocalMessageFinaleHdl;
begin
  with variablesMakeEndgameSearch do
    begin
      if messageHandle <> NIL then
        begin
          localMessageData := LocalMessageFinaleHdl(messageHandle);

          scoreDuCoupDontLeScoreEstConnu   := localMessageData^^.data[0];
    		  coupDontLeScoreEstConnu          := localMessageData^^.data[1];
    		  defenseDuCoupDontLeScoreEstConnu := localMessageData^^.data[2];

    		  SetCoupEtScoreAnalyseRetrogradeDansReflex(coupDontLeScoreEstConnu,scoreDuCoupDontLeScoreEstConnu);
    		end;
    end;
end;


procedure EcritClassement(whichClassement : ListOfMoveRecords);
var i : SInt32;
begin
  with variablesMakeEndgameSearch do
    begin
      EssaieSetPortWindowPlateau;
      WriteStringAt('coup connu = '+CoupEnString(coupDontLeScoreEstConnu,true),10,10);
      WriteNumAt('score connu = ',scoreDuCoupDontLeScoreEstConnu,70,10);
      for i := 1 to longClass do
        begin
          WriteNumAt('i = ',i,10,20+10*i);
          WriteStringAt('coup = '+CoupEnString(whichClassement[i].x,true),30,20+10*i);
          WriteNumAt('score = ',whichClassement[i].note,80,20+10*i);
          WriteNumAt('delta = ',whichClassement[i].delta,80,20+10*i);
        end;
      for i := 1 to 10 do
        WriteStringAt('                                                 ',10,20+(longClass+i)*10);
    end;
end;


procedure MetCoupConnuEnTete(messageHandle : MessageFinaleHdl; var coupDontLeScoreEstConnu : SInt32; var classAux : ListOfMoveRecords);
var i,k,typeAffichage : SInt32;
    tempoMoveRec : MoveRecord;
    localMessageData : LocalMessageFinaleHdl;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin
      if messageHandle <> NIL then
        begin

          localMessageData := LocalMessageFinaleHdl(messageHandle);

    		  scoreDuCoupDontLeScoreEstConnu   := localMessageData^^.data[0];
    		  coupDontLeScoreEstConnu          := localMessageData^^.data[1];
    		  defenseDuCoupDontLeScoreEstConnu := localMessageData^^.data[2];

    		  SetCoupEtScoreAnalyseRetrogradeDansReflex(coupDontLeScoreEstConnu,scoreDuCoupDontLeScoreEstConnu);

    		  k := MAXINT_16BITS;
    		  for i := 1 to longClass do
    		    if classAux[i].x = coupDontLeScoreEstConnu then k := i;
    		  if (k > 1) and (k <= longClass) then
    		    begin
    		      tempoMoveRec := classAux[k];
    		      for i := k downto 2 do classAux[i] := classAux[i-1];
    		      classAux[1] := tempoMoveRec;
    		    end;

    		  classAux[1].note               := scoreDuCoupDontLeScoreEstConnu;
    		  classAux[1].theDefense         := defenseDuCoupDontLeScoreEstConnu;
    		  classAux[1].delta              := kDeltaFinaleInfini;
    		  classAux[1].temps              := 0;
    		  classAux[1].notePourLeTri      := 30000000; {histoire qu'il reste en tete si tous les coups sont perdants}
    		  classAux[1].noteMilieuDePartie := 30000000; {idem}


    		  if (analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeGagnant) or not(bestmodeArriveeDansCoupGagnant)
    		    then typeAffichage := ReflRetrogradeGagnant
    		    else
    		      if bestMode
    		        then typeAffichage := ReflRetrogradeParfait
    		        else typeAffichage := ReflRetrogradeParfaitPhaseGagnant;

    		  if not(passeEhancedTranspositionCutOffEstEnCours) then
    		    begin
    		      SetValReflexFinale(classAux,MFniv,longClass,longClass,typeAffichage,noCoupRecherche,MAXINT_16BITS,inCouleurFinale); {pour copier classAux}
    		      SetValReflexFinale(classAux,MFniv,1,longClass,typeAffichage,noCoupRecherche,MAXINT_16BITS,inCouleurFinale);         {pour mettre LigneDuCoupAnalysé à 1}
    		    end;

    		  if affichageReflexion.doitAfficher and doitEcrireReflexFinale then
    		    LanceDemandeAffichageReflexion(true,'MetCoupConnuEnTete');

    		  for i := 2 to longClass do classAux[i].note := -infini;
    		end;
    end;
end;


procedure MetCetteNoteDansClassement(var classement : ListOfMoveRecords; note,indexMin,indexMax : SInt32);
var k,delta,bidTickChrono : SInt32;
    tempoAfficheReflexion : boolean;
begin
  with variablesMakeEndgameSearch do
    begin
      if indexMin < 1 then indexMin := 1;
      if indexMax > longClass then indexMax := longClass;

      tempoAfficheReflexion := affichageReflexion.doitAfficher;
      affichageReflexion.doitAfficher := false;
      for k := indexMin to indexMax do
        begin
          delta := classement[k].delta;
          bidTickChrono := TickCount;
          if delta <> kTypeMilieuDePartie then
            begin
    		      if classement[k].x = coupDontLeScoreEstConnu
    		        then
    		          begin
    		            SetNoteDansElementClassement(classement,k,scoreDuCoupDontLeScoreEstConnu,kDeltaFinaleInfini,bidTickChrono);
    		            note := scoreDuCoupDontLeScoreEstConnu;  {en dessous, on affichera cette note…}
    		          end
    		        else SetNoteDansElementClassement(classement,k,note,delta,bidTickChrono);
    		    end;
        end;
      affichageReflexion.doitAfficher := tempoAfficheReflexion;
    end;
end;


procedure InstalleCoupAnalyseRetrogradeEnHautDuClassement(messageHandle : MessageFinaleHdl; var classAux : ListOfMoveRecords);
begin
  with variablesMakeEndgameSearch do
    begin
      if messageHandle <> NIL then
        begin
          typeDataDansHandle := messageHandle^^.typeData;
          case typeDataDansHandle of
            ReflScoreDeCeCoupConnuFinale: MetCoupConnuEnTete(messageHandle,coupDontLeScoreEstConnu,classAux);
            otherwise                     AlerteSimple('typeDataDansHandle inconnu dans UnitFinaleFast !');
          end;
        end;
    end;
end;



function Coup1EstPlusPrecisQueCoup2DansHashTableExacte(coup1,coup2 : SInt32) : boolean;
var platDepart : PositionEtTraitRec;
    bornes1, bornes2 : DecompressionHashExacteRec;
    infoExactePourCoup1, infoExactePourCoup2 : boolean;
    bidon : boolean;
begin
  with variablesMakeEndgameSearch do
    begin
      Coup1EstPlusPrecisQueCoup2DansHashTableExacte := true;

      platDepart := positionEtTraitDeMakeEndgameSearch;

      bidon := GetEndgameBornesDansHashExacteAfterThisSon(coup1, platDepart, clefHashageCoupGagnant, bornes1);
      bidon := GetEndgameBornesDansHashExacteAfterThisSon(coup2, platDepart, clefHashageCoupGagnant, bornes2);

      infoExactePourCoup1 := (bornes1.valMin[nbreDeltaSuccessifs] = bornes1.valMax[nbreDeltaSuccessifs]);
      infoExactePourCoup2 := (bornes2.valMin[nbreDeltaSuccessifs] = bornes2.valMax[nbreDeltaSuccessifs]);

      if (infoExactePourCoup1 or infoExactePourCoup2) then
        begin
          {WritelnStringAndCoupDansRapport(CoupEnString(coup1,true) + ' vs ' , coup2);
          WritelnStringAndCoupDansRapport(' Bornes de ',coup1);
          WritelnBornesDansRapport(bornes1);
          WritelnStringAndCoupDansRapport(' Bornes de ',coup2);
          WritelnBornesDansRapport(bornes2);}

          if infoExactePourCoup1 and infoExactePourCoup2 then
            begin
              Coup1EstPlusPrecisQueCoup2DansHashTableExacte := (bornes1.valMin[nbreDeltaSuccessifs] >= bornes2.valMin[nbreDeltaSuccessifs]);
              exit(Coup1EstPlusPrecisQueCoup2DansHashTableExacte);
            end;

          if infoExactePourCoup1 and not(infoExactePourCoup2) then
            begin
              Coup1EstPlusPrecisQueCoup2DansHashTableExacte := true;
              exit(Coup1EstPlusPrecisQueCoup2DansHashTableExacte);
            end;

          if not(infoExactePourCoup1) and infoExactePourCoup2 then
            begin
              Coup1EstPlusPrecisQueCoup2DansHashTableExacte := false;
              exit(Coup1EstPlusPrecisQueCoup2DansHashTableExacte);
            end;

        end;
    end;
end;


function GetScoreExactOfThisSonDansHashTableExacte(coup : SInt32; var score : SInt32) : boolean;
begin
  with variablesMakeEndgameSearch do
    GetScoreExactOfThisSonDansHashTableExacte := GetEndgameScoreDansHashExacteAfterThisSon(coup, positionEtTraitDeMakeEndgameSearch, clefHashageCoupGagnant, score);
end;




var gClassementPourTri : ListOfMoveRecords;
    gIndicesPourTri : array[1..64] of SInt32;


function LectureTriAuTemps(index : SInt32) : SInt32;
begin
  LectureTriAuTemps := gIndicesPourTri[index];
end;

procedure AffectationTriAuTemps(index,element : SInt32);
begin
  gIndicesPourTri[index] := element;
end;


function ComparaisonPourTriAuTemps(element1,element2 : SInt32) : boolean;
begin
  ComparaisonPourTriAuTemps := gClassementPourTri[element1].notePourLeTri <= gClassementPourTri[element2].notePourLeTri;
end;


(***  tri suivant le classement au temps (ie. milieu + 100*temps) si tous  ***)
(***  moins bons que valeurCible                                           ***)
procedure TrierLesCoupsPerdantsAuTemps(lo,up : SInt32);
var i,j,d,temp,compar : SInt32;
label 999;
begin

  (* copie locale du classement *)
  for i := lo to up do
    gClassementPourTri[i] := classAux[i];

  (* on fait un petit ShellSort sur la copie locale *)
  for i := lo to up do
     AffectationTriAuTemps(i,i);
  d := up-lo+1;
  while d > 1 do
    begin
      if d < 5
        then d := 1
        else d := Trunc(0.45454*d);
      for i := up-d downto lo do
        begin
          temp := LectureTriAuTemps(i);
          j := i+d;
          while j <= up do
            begin
              compar := LectureTriAuTemps(j);
              if ComparaisonPourTriAuTemps(temp,compar)
                then
                  begin
                    AffectationTriAuTemps(j-d,compar);
                    j := j+d;
                  end
              else
                goto 999;
            end;
          999:
          AffectationTriAuTemps(j-d,temp);
        end;
    end;

  (* on remet la copie locale dans le classement de depart *)
  for i := lo to up do
    classAux[i] := gClassementPourTri[LectureTriAuTemps(i)];
end;


(* renvoie le nouvel index dans le classement *)
function GererLeClassementDesCoupsAuMerite : SInt32;
var j,k : SInt32;
    noteDeK : SInt32;
begin

  with variablesMakeEndgameSearch do
    begin

      with analyseRetrograde do
        if enCours and ((genreAnalyseEnCours = ReflRetrogradeParfait) or (genreAnalyseEnCours = ReflRetrogradeGagnant)) and
           (not(bestmode) or passeDeRechercheAuMoinsValeurCible) and (compteur >= 2) and (valXY < valeurCible) and (classAux[1].x = coupDontLeScoreEstConnu)
          then k := 2
          else k := 1;

      {classement au mérite}

      while (k < compteur) and
            ((classAux[k].note > valxy) or
             ((classAux[k].note = valXY) and
              Coup1EstPlusPrecisQueCoup2DansHashTableExacte(classAux[k].x,XCourant) and
              not(EstLeCoupParfaitAfficheCommeSuggestionDeFinale(XCourant)) and
              not(GetScoreExactOfThisSonDansHashTableExacte(classAux[k].x,noteDeK) and (noteDeK < valXY))))  do
        k := k+1;
      for j := compteur downto k+1 do
        classAux[j] := classAux[j-1];

      classAux[k].x := XCourant;
      classAux[k].note := ValXY;
      classAux[k].theDefense := defenseEndgameSearch;
      classAux[k].temps := TempsDeXCourant;
      classAux[k].noteMilieuDePartie := NoteMilieuDeXCourant;
      classAux[k].notePourLeTri := NotePourLeTriDeXCourant;
      classAux[k].pourcentageCertitude := 100;
      classAux[k].delta := deltaDeXCourantApresRecherche;

      if FALSE and debuggage.algoDeFinale then
        EcritClassementDansRapport(classAux, 'Classement au mérite de ' + CoupEnString(XCourant,true) + ' : ',longClass);

      GererLeClassementDesCoupsAuMerite := k;
    end;
end;


procedure GererLAffichageDesNotesSurLOthellier(indexDuCoup : SInt32);
var bornes : DecompressionHashExacteRec;
    valMin, valMax : SInt32;
    debugage : boolean;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      {on affiche eventuellement les notes sur l'othellier}

      debugage := false;

      if debugage then
        begin
          WritelnDansRapport('');
          WritelnDansRapport('**********************************');
          WritelnDansRapport('Entree dans GererLAffichageDesNotesSurLOthellier');
          WritelnNumDansRapport('indexDuCoup = ',indexDuCoup);
          WritelnStringAndCoupDansRapport('classAux[indexDuCoup].x = ',classAux[indexDuCoup].x);
          WritelnNumDansRapport('nbCoupuresHeuristiquesDeXCourant = ',nbCoupuresHeuristiquesDeXCourant);
        end;



      if not(ValeurDeFinaleInexploitable(valXY)) then
        begin
          if (CassioEstEnModeAnalyse {or analyseRetrograde.enCours}) and (nbCoupuresHeuristiquesDeXCourant = 0) and
             EstLaPositionCourante(positionEtTraitDeMakeEndgameSearch)
            then
              begin

                if GetEndgameBornesDansHashExacteAfterThisSon(classAux[indexDuCoup].x, positionEtTraitDeMakeEndgameSearch, clefHashageCoupGagnant, bornes)
                  then
                    begin
                      valMin := bornes.valMin[nbreDeltaSuccessifs];
                      valMax := bornes.valMax[nbreDeltaSuccessifs];

                       if debugage then WritelnDansRapport('cas 1');
                    end
                  else
                    begin
                      if bestmode and not(passeDeRechercheAuMoinsValeurCible)
                        then
                          begin
                            valMin := valXY;
                            valMax := valXY;

                            if debugage then WritelnDansRapport('cas 2');
                          end
                        else
                          begin
                            if (valXY = 0) then
                              begin
                                valMin := 0;
                                valMax := 0;

                                if debugage then WritelnDansRapport('cas 3');
                              end
                            else if (valXY > 0) then
                              begin
                                valMin := 2;
                                valMax := 64;

                                if debugage then WritelnDansRapport('cas 4');
                              end
                            else if (valXY < 0) then
                              begin
                                valMin := -64;
                                valMax := -2;

                                if debugage then WritelnDansRapport('cas 5');
                              end;
                          end;
                    end;


                if (valMax <> valMin)
                  then
                    begin


                      if debugage then
                        begin
                          WriteStringAndCoupDansRapport('othellier (WLD) :  ', classAux[indexDuCoup].x);
                          WriteNumDansRapport(' => [', valMin);
                          WriteNumDansRapport(' , ', valMax);
                          WritelnDansRapport(']');
                        end;


                      noteAfficheeSurOthellier := kNoteSurCaseNonDisponible;

                      if (valMax < 0) then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourPerte else
                      if (valMin > 0) then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourGain  else
                      if (valMax = 0) and (valMin = 0) then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourNulle;

                      if (noteAfficheeSurOthellier <> kNoteSurCaseNonDisponible) then
                        begin
                          if not((inProfondeurFinale <=  8) and GenreDeReflexionInSet(inTypeCalculFinale,[ReflParfait,ReflParfaitExhaustif,ReflRetrogradeParfait])) then
                            if analyseIntegraleDeFinale or (classAux[indexDuCoup].note < 0) or (indexDuCoup = 1) then
                              if (indexDuCoup = 1)
                                then SetMeilleureNoteSurCase(kNotesDeCassio,classAux[indexDuCoup].x,noteAfficheeSurOthellier)
                                else SetNoteSurCase(kNotesDeCassio,classAux[indexDuCoup].x,noteAfficheeSurOthellier);
                         end;
                    end
                  else
                    begin

                      if debugage then
                        begin
                          WriteStringAndCoupDansRapport('othellier :  ', classAux[indexDuCoup].x);
                          WriteNumDansRapport(' => [', valMin);
                          WriteNumDansRapport(' , ', valMax);
                          WritelnDansRapport(']');
                        end;


                      noteAfficheeSurOthellier := 100*(valMin);
                      if odd(noteAfficheeSurOthellier div 100) and (noteAfficheeSurOthellier < 0) then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourPerte else
                      if odd(noteAfficheeSurOthellier div 100) and (noteAfficheeSurOthellier > 0) then noteAfficheeSurOthellier := kNoteSpecialeSurCasePourGain;

                      if analyseIntegraleDeFinale or (indexDuCoup = 1) then
                        if (indexDuCoup = 1)
                          then SetMeilleureNoteSurCase(kNotesDeCassio,classAux[indexDuCoup].x,noteAfficheeSurOthellier)
                          else SetNoteSurCase(kNotesDeCassio,classAux[indexDuCoup].x,noteAfficheeSurOthellier);
                    end;
              end;
        end;

      if debugage then
        begin
          WritelnDansRapport('Sortie de GererLAffichageDesNotesSurLOthellier');
          WritelnDansRapport('**********************************');
        end;
    end;
end;


procedure GererLeClassementDesCoupsPerdantsAuTemps;
var k : SINt32;
begin

  with variablesMakeEndgameSearch do
    begin

      (***  tri suivant le classement au temps (ie. milieu + 100*temps) si tous  ***)
      (***  moins bons que valeurCible                                           ***)
      if classementAuTempsSiTousMoinsBonsQueValeurCible and not(passeEhancedTranspositionCutOffEstEnCours) then
        begin
          if (not(bestMode) or passeDeRechercheAuMoinsValeurCible) then
            if (valXY < valeurCible) and (bestAB < valeurCible) and (valXY >= bestAB) then
              begin
                {
                if debuggage.algoDeFinale then
                  begin
                    FinRapport;
                    WritelnDansRapport('classement au temps : ');
                    WritelnStringAndCoupDansRapport('XCourant = ',XCourant);
                    WritelnNumDansRapport('NotePourLeTriDeXCourant = ',NotePourLeTriDeXCourant);
                    WritelnNumDansRapport('compteur = ',compteur);
                    WritelnNumDansRapport('valXY = ',valXY);
                    WritelnNumDansRapport('valeurCible = ',valeurCible);
                    WritelnNumDansRapport('bestAB = ',bestAB);
                  end;
                }

                with analyseRetrograde do
    	            if enCours and
    	              ((genreAnalyseEnCours = ReflRetrogradeParfait) or (genreAnalyseEnCours = ReflRetrogradeGagnant)) and
    	               (not(bestmode) or passeDeRechercheAuMoinsValeurCible) and
    	               (compteur >= 2) and
    	               (valXY < valeurCible) and
    	               (classAux[1].x = coupDontLeScoreEstConnu)
    	              then k := 2
    	              else k := 1;

                {if debuggage.algoDeFinale then EcritClassementDansRapport(classAux, 'Avant classement au temps de ' + CoupEnString(XCourant,true) + ' : ',longClass);}

                TrierLesCoupsPerdantsAuTemps(k,compteur);

                {if debuggage.algoDeFinale then EcritClassementDansRapport(classAux, 'Apres classement au temps de ' + CoupEnString(XCourant,true) + ' : ',longClass);}
              end;
        end;

      AEteEnTete[classAux[1].x] := deltaFinaleCourant;
    end;

end;


procedure GererLaMeilleureSuite;
var j,k : SInt32;
begin

  with variablesMakeEndgameSearch do
    begin
      if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

      if doitAppelerGestionMeilleureSuite then
        begin
          {on trouve la place de XCourant}
          j := -1; {not found}
          for k := 1 to longClass do
            if classAux[k].x = XCourant then j := k;

          GestionMeilleureSuite(minimaxprof,platmod,coulDefense,nbBlancMod,nbNoirMod,valXY,XCourant,deltaDeXCourantApresRecherche,
                                compteur,longClass,(not(bestmode) and (bestAB < 0)) or ((valXY = bestAB) and (j = 1)));


        end;

      if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
    end;

end;


procedure GererLaRecopieFinaleDuClassementQuandOnNEstPasInterrompu;
var i,k : SInt32;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      if meilleureSuiteAEteCalculeeParOptimalite and afficheSuggestionDeCassio and SuggestionAnalyseDeFinaleEstDessinee then
        TrierClassementSiMeilleureSuiteAEteCalculeeParOptimalite(classAux,longClass);


      k := 0;
      for i := 1 to longClass do
        if AEteEnTete[classAux[i].x] >= 0 then
          begin
            inc(k);
            classementMinimax[k] := classAux[i];
          end;
      nbCoupsAyantEteEnTete := k;
      if k <= 0 then
        begin
          SysBeep(0);
          WritelnDansRapport('ERROR : Pas trouve de AEteEnTete[k] à la fin de MinimaxFinale');
        end;

      for i := 1 to longClass do
        if AEteEnTete[classAux[i].x] < 0 then
          begin
            inc(k);
            classementMinimax[k] := classAux[i];
            classementMinimax[k].note := classementMinimax[nbCoupsAyantEteEnTete].note;
          end;
      TrierClassementAuTemps(classementMinimax,nbCoupsAyantEteEnTete+1,longClass);


      SetValReflexFinale(classementMinimax,minimaxprof,nbcoup,nbcoup,ReflexData^.typeDonnees,noCoupRecherche,MAXINT_16BITS,inCouleurFinale);

      if affichageReflexion.doitAfficher and doitEcrireReflexFinale then
        LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant),'GererLaRecopieFinaleDuClassementQuandOnNEstPasInterrompu');


      MinimaxFinale := classementMinimax[1].note;

      if inCommentairesDansRapportFinale and not(GenreDeReflexionInSet(inTypeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif])) and
         ((minimaxprof+1) <= kNbCasesVidesPourAnnonceDansRapport) then
        MeilleureSuiteDansRapport(classementMinimax[1].note);
    end;
end;


procedure GererLaRecopieFinaleDuClassementEnCasDInterruption;
var i : SInt32;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      if compteur <= 1
       then
         begin
           for i := 1 to longClass do
             classementMinimax[i] := classementMinimax[i]; {on ne fait rien : on utilise le milieu de partie}
           MinimaxFinale := classementMinimax[1].note;
         end
       else
         begin
           for i := 1 to compteur-1 do
             classementMinimax[i] := classAux[i];
           for i := compteur to longClass do
             classementMinimax[i].note := classementMinimax[compteur-1].note-100;

           MinimaxFinale := classementMinimax[1].note;

           if inCommentairesDansRapportFinale and not(GenreDeReflexionInSet(inTypeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]))
              and ((minimaxprof+1) <= kNbCasesVidesPourAnnonceDansRapport) then
             MeilleureSuiteDansRapport(classementMinimax[1].note);
         end;
    end;
end;

procedure GererLaRecopieFinaleDuClassement;
begin
  if (interruptionReflexion = pasdinterruption)
    then GererLaRecopieFinaleDuClassementQuandOnNEstPasInterrompu
    else GererLaRecopieFinaleDuClassementEnCasDInterruption;
end;


procedure GererLaRecopieInitialeDuClassement;
var i : SInt32;
    listeFinale : listeVides;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin
      classAux := classementMinimax;
      for i := 0 to 99 do AEteEnTete[i] := -1;

      if analyseRetrograde.enCours and (inMessageHandleFinale <> NIL) then
        begin
          UpdateBestABAvecLeScoreDuCoupConnu(inMessageHandleFinale,bestAB);
          GetCoupDontLeScoreEstConnu(inMessageHandleFinale,coupDontLeScoreEstConnu,defenseDuCoupDontLeScoreEstConnu,scoreDuCoupDontLeScoreEstConnu);

          if (classAux[1].x <> coupDontLeScoreEstConnu) and
             ((deltaFinaleCourant = deltaSuccessifs[1].valeurDeMu) or (classementMinimax[1].note <= scoreDuCoupDontLeScoreEstConnu)) then
            InstalleCoupAnalyseRetrogradeEnHautDuClassement(inMessageHandleFinale,classAux);

          MetLesCoupsDansLeMemeOrdre(classAux,classementMinimax,longClass);
          if (analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeParfait)
            then passeDeRechercheAuMoinsValeurCible := (valeurCible > scoreDuCoupDontLeScoreEstConnu + 2 );

          if debuggage.algoDeFinale then EcritClassementDansRapport(classAux, 'classAux à la fin de GererLaRecopieInitialeDuClassement',longClass);
          if debuggage.algoDeFinale then EcritClassementDansRapport(classementMinimax, 'classementMinimax à la fin de GererLaRecopieInitialeDuClassement',longClass);
        end;

      MetCetteNoteDansClassement(classAux,-infini,1,longClass);


      for i := 1 to longClass do  listeFinale[i] := classAux[i].x;

      CopierListeDesCoupsPourLeZoo(minimaxprof,longClass,inCouleurFinale,gClefHashage,listeFinale,jeu,bestAB,betaAB);
    end;
end;


procedure GererAffichageClassementDansFenetreReflexion;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      if not(doitEcrireReflexFinale) then
        exit(GererAffichageClassementDansFenetreReflexion);

      if not(passeEhancedTranspositionCutOffEstEnCours) then
        begin


          if compteur < longClass then classAux[compteur+1].note := -noteMax;
          if analyseRetrograde.enCours
            then
              if bestmodeArriveeDansCoupGagnant
                then
                  if bestMode
                    then SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflRetrogradeParfait,noCoupRecherche,compteur+1,inCouleurFinale)
                    else SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflRetrogradeParfaitPhaseGagnant,noCoupRecherche,compteur+1,inCouleurFinale)
                else
                  SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflRetrogradeGagnant,noCoupRecherche,compteur+1,inCouleurFinale)
            else
              if bestmodeArriveeDansCoupGagnant
                then
                  if bestMode
                    then
                      if analyseIntegraleDeFinale
                        then SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfaitExhaustif,noCoupRecherche,compteur+1,inCouleurFinale)
                        else SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfait,noCoupRecherche,compteur+1,inCouleurFinale)
                    else SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflParfaitPhaseGagnant,noCoupRecherche,compteur+1,inCouleurFinale)
                else
                  if analyseIntegraleDeFinale
                    then SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflGagnantExhaustif,noCoupRecherche,compteur+1,inCouleurFinale)
                    else SetValReflexFinale(classAux,minimaxprof,compteur,longClass,ReflGagnant,noCoupRecherche,compteur+1,inCouleurFinale);


          if affichageReflexion.doitAfficher and doitEcrireReflexFinale then
            LanceDemandeAffichageReflexion(DeltaAAfficherImmediatement(deltaFinaleCourant) or deltaDeXCourantDevientInfini,'GererAffichageClassementDansFenetreReflexion');

        end;

      if not(RefleSurTempsJoueur) and (GetCouleurOfSquareDansJeuCourant(XCourant) = pionVide) and PionClignotant then
      	EffacePionMontreCoupLegal(XCourant);
    end;
end;


procedure GererAffichageTemporaireDuCoupDansLaFenetreDeReflexionPendantLaRecherche;
begin

  with variablesMakeEndgameSearch do
    begin

      if not(doitEcrireReflexFinale) then
        exit(GererAffichageTemporaireDuCoupDansLaFenetreDeReflexionPendantLaRecherche);

      if not(RefleSurTempsJoueur) and (GetCouleurOfSquareDansJeuCourant(XCourant) = pionVide) and PionClignotant then
        DessinePionMontreCoupLegal(XCourant);

      if passeEhancedTranspositionCutOffEstEnCours
        then exit(GererAffichageTemporaireDuCoupDansLaFenetreDeReflexionPendantLaRecherche);

      if (indexDuCoupDansFntrReflexion > 1) or (deltaFinaleCourant > deltaSuccessifs[1].valeurDeMu) then
        begin

          {afficher que l'on cherche avec ce delta pour ce coup}
          if ReflexData^.class[compteur].delta <> kTypeMilieuDePartie then
            ReflexData^.class[compteur].delta := Max(ReflexData^.class[compteur].delta,deltaFinaleCourant);

          {et si deltaFinaleCourant = kDeltaFinaleInfini, on affiche un joli point d'interrogation}
          if (deltaFinaleCourant = kDeltaFinaleInfini) and (XCourant <> coupDontLeScoreEstConnu) then
            ReflexData^.class[compteur].pourcentageCertitude := kCertitudeSpecialPourPointInterrogation;

          {et afficher des 'pas mieux' en dessous}
          if not(analyseIntegraleDeFinale and (deltaFinaleCourant >= deltaSuccessifs[1].valeurDeMu)) then
            begin
              if analyseRetrograde.enCours and (classAux[1].x = coupDontLeScoreEstConnu)
                then
                  if (compteur = 2)
                    then MetCetteNoteDansClassement(ReflexData^.class,classementMinimax[2].note,compteur,longClass) {note de l'iteration precedente}
                    else MetCetteNoteDansClassement(ReflexData^.class,ReflexData^.class[2].note,compteur,longClass)
                else
                  if not(MinimaxAEvalueAUMoinsUnCoupDansCettePasse)
                    then MetCetteNoteDansClassement(ReflexData^.class,classementMinimax[compteur].note,compteur,longClass) {note de l'iteration precedente}
                    else MetCetteNoteDansClassement(ReflexData^.class,ReflexData^.class[compteur].note,compteur,longClass);
              MetCetteNoteDansClassement(ReflexData^.class,kValeurSpecialeDansReflPourPasMieux,compteur+1,longClass);  {en dessous : pas mieux}
            end;
          SetNroLigneEnCoursDAnalyseDansReflex(compteur);

          LanceDemandeAffichageReflexion((indexDuCoupDansFntrReflexion <= 2) or (deltaFinaleCourant = kDeltaFinaleInfini),'GererAffichageTemporaireDuCoupDansLaFenetreDeReflexionPendantLaRecherche');
        end;
    end;

end;




procedure GererLaDecouverteDunCoupGagnant;
var j,k : SInt32;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

      if not(ValeurDeFinaleInexploitable(valXY)) and
         not(bestMode) and (valXY > quelleValeurCible) and not(analyseIntegraleDeFinale) then
        begin
          MakeEndgameSearch := true;
          outScoreFinale := valXY;
          {on trouve la place de XCourant}
          j := -1; {not found}
          for k := 1 to longClass do
            if classAux[k].x = XCourant then j := k;
          if (j <> -1) then {puis on le met en tete}
            begin
              tempElementClass := classAux[1];
              classAux[1]      := classAux[j];
              classAux[j]      := tempElementClass;

              classAux[1].x := XCourant;
              classAux[1].note := ValXY;
              classAux[1].theDefense := defenseEndgameSearch;
              classAux[1].delta := deltaDeXCourantApresRecherche;
              if not(analyseIntegraleDeFinale) then sortieDeBoucleAcceleree := true;
            end;
        end;
    end;

end;


procedure GererLaDecouverteDunCoupOptimum;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

      if not(ValeurDeFinaleInexploitable(valXY)) then
        begin

          if bestMode and (valXY = maxConnuSiToutEstMoinsBonQueValeurCible) and (betaAB = (maxConnuSiToutEstMoinsBonQueValeurCible+1)) then
            begin
              MakeEndgameSearch := false;
              outScoreFinale := valXY;
              sortieDeBoucleAcceleree := true;
            end;

          if (valxy >= 64) and (nbCoupuresHeuristiquesDeXCourant = 0) and not(analyseIntegraleDeFinale) then
            begin
              MakeEndgameSearch := true;
              outScoreFinale := valXY;
              sortieDeBoucleAcceleree := true;
              toutesLesPassesTerminees := true;
            end;
        end;
    end;

end;

procedure GererLaDecouverteDuneCoupureBeta;
var j,k : SInt32;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

      if not(ValeurDeFinaleInexploitable(valXY)) then
        begin

          if coupGagnantAUneFenetreAlphaBetaReduite and (valXY >= inBetaFinale) then
            begin
              MakeEndgameSearch := true;
              outScoreFinale := valXY;

              {on trouve la place de XCourant}
              j := -1; {not found}
              for k := 1 to longClass do
                if classAux[k].x = XCourant then j := k;
              if (j <> -1) then {puis on le met en tete}
                begin
                  tempElementClass := classAux[1];
                  classAux[1]      := classAux[j];
                  classAux[j]      := tempElementClass;

                  classAux[1].x := XCourant;
                  classAux[1].note := ValXY;
                  classAux[1].theDefense := defenseEndgameSearch;
                  classAux[1].delta := deltaDeXCourantApresRecherche;
                  sortieDeBoucleAcceleree := true;

                  if (nbCoupuresHeuristiquesDeXCourant = 0) then toutesLesPassesTerminees := true;

                  {WritelnDansRapport('Coupure beta dans GererLaDecouverteDuneCoupureBeta !');}
                end;
            end;

        end;
    end;

end;

function CalculParScoreDuCoupDontLeScoreEstConnu : SInt32;
begin

  with variablesMakeEndgameSearch do
    begin

      if debuggage.algoDeFinale then
        begin
    		  FinRapport;
    		  TextNormalDansRapport;
    		  WritelnNumDansRapport('CalculParScoreDuCoupDontLeScoreEstConnu( '+CoupEnString(XCourant,true)+' ) => ',scoreDuCoupDontLeScoreEstConnu);
    		end;

      defenseEndgameSearch := defenseDuCoupDontLeScoreEstConnu;
      CalculParScoreDuCoupDontLeScoreEstConnu := scoreDuCoupDontLeScoreEstConnu;

    end;

end;


function GererLeCalculDeLaValeur : SInt32;
begin

  with variablesMakeEndgameSearch do
    begin

      if minimaxprof <= 0
        then
          begin
            if Couldefense = pionBlanc
               then
                 if nbBlancMod < nbNoirMod
                   then noteModif := nbBlancMod+nbBlancMod-64
                   else noteModif := 64 - nbNoirMod - nbNoirMod
               else
                 if nbBlancMod < nbNoirMod
                   then noteModif := 64 - nbBlancMod - nbBlancMod
                   else noteModif := nbNoirMod+nbNoirMod-64;
            if nbBlancMod = nbNoirMod then notemodif := 0;
            valXY := -noteModif;
          end
        else
          begin
            if (XCourant = coupDontLeScoreEstConnu)
              then
                begin
                  valXY := CalculParScoreDuCoupDontLeScoreEstConnu;
                  AEteEnTete[XCourant] := deltaFinaleCourant;
                end
              else
                begin
                  if analyseIntegraleDeFinale
                    then
                      begin
                        if not(bestMode)
                          then valXY := CalculParAnalyseDeFinale(-1, +1)
                          else valXY := CalculParAnalyseDeFinale(-64, +64);
                        AEteEnTete[XCourant] := deltaFinaleCourant;
                      end
                    else
                      begin
                        peutUtiliserDichotomie := not(MinimaxAEvalueAUMoinsUnCoupDansCettePasse) or
                                                  ((compteur = 2 ) and analyseRetrograde.enCours and
                                                   (classAux[1].x = coupDontLeScoreEstConnu) and
                                                   (valeurCible > scoreDuCoupDontLeScoreEstConnu));
                        valXY := {SSS_Dual;}
                                 {CalculNormal;}
                                  Dichotomie_first(quelleValeurCible,peutUtiliserDichotomie);
                      end;
                end;
          end;

      if ValeurDeFinaleInexploitable(valXY) and (valXY > 0) then valXY := - valXY;

      GererLeCalculDeLaValeur := valXY;

    end;
end;




procedure GererInitialisationDeLaFenetreDeRecherche;
begin

  with variablesMakeEndgameSearch , paramMakeEndgameSearch do
    begin

      if coupGagnantAUneFenetreAlphaBetaReduite
        then
          begin
            if (inAlphaFinale < -64) then
              WritelnNumDansRapport('ASSERT dans GererInitialisationDeLaFenetreDeRecherche :  inAlphaFinale =',inAlphaFinale);
            if (inBetaFinale > 64) then
              WritelnNumDansRapport('ASSERT dans GererInitialisationDeLaFenetreDeRecherche :  inBetaFinale =',inBetaFinale);
            if (inAlphaFinale >= inBetaFinale) then
              WritelnDansRapport('ASSERT (inAlphaFinale >= inBetaFinale) dans GererInitialisationDeLaFenetreDeRecherche');

            ChangeBestAB(inAlphaFinale,'init(fenetreReduite)');
            ChangeBetaAB(inBetaFinale,'init(fenetreReduite)');
          end
        else
          if bestMode
            then
              begin
                ChangeBestAB(-infini,'init(bestMode)');
                ChangeBetaAB( infini,'init(bestMode)');
                valeurCible := quelleValeurCible;

                if not(analyseIntegraleDeFinale)
                  then
                    begin
                      passeDeRechercheAuMoinsValeurCible := (valeurCible = 0);
                      FenetreLargePourRechercheScoreExact := false;
                    end
                  else
                    begin
                      passeDeRechercheAuMoinsValeurCible := false;
                      FenetreLargePourRechercheScoreExact := true;
                    end;
              end
            else               {reduction de la fenetre}
              begin
                ChangeBestAB(quelleValeurCible-1,'init(not bestMode)');
                ChangeBetaAB(quelleValeurCible+1,'init(not bestMode)');
                valeurCible := quelleValeurCible;

                passeDeRechercheAuMoinsValeurCible := true;
                FenetreLargePourRechercheScoreExact := false;
              end;
    end;
end;

procedure GererJouerLeCoupAvantLaRecherche;
begin

  with variablesMakeEndgameSearch do
    begin

      platMod := jeu;
      jouableMod := empl;
      nbBlancMod := nbBla;
      nbNoirMod := nbNoi;
      frontMod := frontiereMinimax;

      //WritelnNumDansRapport('GererJouerLeCoupAvantLaRecherche, coup = ',XCourant);

      coupLegal := ModifPlatLongint(XCourant,couleur,platMod,jouableMod,nbBlancMod,nbNoirMod,frontMod);
      with InfosMod do
        begin
          jouable := jouableMod;
          nbBlancs := nbBlancMod;
          nbNoirs := nbNoirMod;
          frontiere := frontMod;
        end;

      EnleverDeLaListeChaineeDesCasesVides(XCourant);
      gVecteurParite := BXOR(gVecteurParite, (constanteDeParite[XCourant]));
      if EndgameTreeEstValide(numeroEndgameTreeActif, variablesMakeEndgameSearch) then
        DoMoveEndgameTree(numeroEndgameTreeActif,XCourant,couleur);

      TickChrono := TickCount;
      TickChronoPourClassaux := TickCount;
      tempsPourTickChronoPourClassaux := classAux[compteur].temps;
      nbCoupuresHeuristiquesDeXCourant := nbCoupuresHeuristiquesCettePasse;
      deltaDeXCourantAvantRecherche := classAux[compteur].delta;

    end;

end;


procedure GererDejouerLeCoupApresLaRecherche;
begin

  with variablesMakeEndgameSearch do
    begin

      gVecteurParite := BXOR(gVecteurParite, (constanteDeParite[XCourant]));
      RemettreDansLaListeChaineeDesCasesVides(XCourant);
      if EndgameTreeEstValide(numeroEndgameTreeActif, variablesMakeEndgameSearch) and (interruptionReflexion = pasdinterruption) then
        UndoMoveEndgameTree(numeroEndgameTreeActif);


      if not(ValeurDeFinaleInexploitable(valXY))
        then SetNombreDeCoupsEvaluesParMinimaxDansCettePasse(GetNombreDeCoupsEvaluesParMinimaxDansCettePasse + 1);

    end;

end;

procedure GererAnnonceDUneNouvellePasseDeMinimaxFinale;
begin

  with variablesMakeEndgameSearch do
    begin

      if debuggage.algoDeFinale then
        begin
          FinRapport;
          ChangeFontFaceDansRapport(bold);
          WriteDansRapport('Début d''une nouvelle passe');
          TextNormalDansRapport;
          WriteNumDansRapport('( cible = ', valeurCible);
          WriteNumDansRapport(' , BestAB = ', BestAB);
          WriteNumDansRapport(' , betaAB = ', betaAB);
          WriteNumDansRapport(' , µ=', deltaFinaleCourant);
          WriteStringAndBoolDansRapport(' ,  > cible? = ', passeDeRechercheAuMoinsValeurCible);
          WriteStringAndBoolDansRapport(' , bestMode = ', bestMode);
          if passeEhancedTranspositionCutOffEstEnCours then
            WriteDansRapport(' , ETC');
          (* WritelnNumDansRapport('scoreDuCoupDontLeScoreEstConnu = ',scoreDuCoupDontLeScoreEstConnu);
             WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible = ',passeDeRechercheAuMoinsValeurCible); *)
          WritelnDansRapport(' )');
        end;

    end;

end;

procedure GererAnnonceFinDUnePasseDeMinimaxFinale;
begin

  with variablesMakeEndgameSearch do
    begin

      if debuggage.algoDeFinale then
        begin
          FinRapport;
          ChangeFontFaceDansRapport(bold);
          WriteDansRapport('Fin de la passe :');
          TextNormalDansRapport;
          WriteStringAndBooleanDansRapport(' sortieDeBoucleAcceleree = ',sortieDeBoucleAcceleree);
          WriteDansRapport(' ');
          WriteNumDansRapport(' , compteur = ',compteur);
          WriteNumDansRapport(' , longClass = ',longClass);
          if (interruptionReflexion <> pasdinterruption)
            then WritelnInterruptionDansRapport(interruptionReflexion)
            else WritelnDansRapport('');
        end;

    end;

end;



procedure GererLEstimationDeLaPrecisionDeRecherche;
begin

  with variablesMakeEndgameSearch do
    begin

      TempsDeXCourant := tempsPourTickChronoPourClassaux + (TickCount - TickChronoPourClassaux);
      NotePourLeTriDeXCourant := (NoteMilieuDeXCourant div 8) + Min(TempsDeXCourant div 60, 100);

      if ValeurDeFinaleInexploitable(valXY)
        then
          begin
            nbCoupuresHeuristiquesDeXCourant := 1;
            deltaDeXCourantDevientInfini := false;
            deltaDeXCourantApresRecherche := deltaFinaleCourant;
          end
        else
          begin
            nbCoupuresHeuristiquesDeXCourant := nbCoupuresHeuristiquesCettePasse-nbCoupuresHeuristiquesDeXCourant;
            deltaDeXCourantDevientInfini := (nbCoupuresHeuristiquesDeXCourant = 0) and (deltaDeXCourantAvantRecherche <> kDeltaFinaleInfini);

            if nbCoupuresHeuristiquesDeXCourant = 0
              then deltaDeXCourantApresRecherche := kDeltaFinaleInfini
              else deltaDeXCourantApresRecherche := deltaFinaleCourant;
          end;

      if (nbCoupuresHeuristiquesDeXCourant < 0) then
        WritelnNumDansRapport('ASSERT ! dans GererLEstimationDeLaPrecisionDeRecherche, nbCoupuresHeuristiquesDeXCourant = ',nbCoupuresHeuristiquesDeXCourant);
    end;
end;


procedure GererAmeliorationPossibleDuScore;
var noteExacte : SInt32;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

      if debuggage.algoDeFinale then
        begin
          WriteNumDansRapport('entree GererAmeliorationPossibleDuScore, valXY = ',valXY);
          WriteStringAndBoolDansRapport(' , bestmode = ',bestMode);
          WriteNumDansRapport(' , valeurCible = ',valeurCible);
          WritelnNumDansRapport(' , bestAB = ',bestAB);
        end;

      if not(bestMode) and (valeurCible = 0) and (valXY < 0) then valXY := -1;
      if not(bestMode) and (valeurCible = 0) and (valXY > 0) then valXY := +1;
      if bestMode and passeDeRechercheAuMoinsValeurCible and (valXY < valeurCible) then
        if not(analyseRetrograde.enCours) or (XCourant <> coupDontLeScoreEstConnu)
          then
            begin
              if valXY > maxConnuSiToutEstMoinsBonQueValeurCible
                then maxConnuSiToutEstMoinsBonQueValeurCible := valXY;
              if (Sign(valXY) = Sign(valeurCible-1))
                then valXY := valeurCible-1;
            end;
      if bestMode and (valXY > valeurCible) and odd(valXY) then inc(valXY);
      if bestMode and not(analyseIntegraleDeFinale) and (valXY < bestAB) then valXY := bestAB;

      if (bestmode and GetScoreExactOfThisSonDansHashTableExacte(XCourant,noteExacte)) then valXY := noteExacte;

      if (not(bestmode) and GetScoreExactOfThisSonDansHashTableExacte(XCourant,noteExacte) and (noteExacte < valXY)) then valXY := noteExacte;

      if odd(valXY) and coupGagnantAUneFenetreAlphaBetaReduite and (valXY <= inAlphaFinale) then dec(valXY);
      if odd(valXY) and coupGagnantAUneFenetreAlphaBetaReduite and (valXY >= inBetaFinale)  then inc(valXY);

      if (interruptionReflexion <> pasdinterruption) then valXY := -infini;

      doitAppelerGestionMeilleureSuite := false;
      if not(ValeurDeFinaleInexploitable(valXY)) then
        begin
          if (valXY > bestAB) or
             (not(bestMode) and (valXY = bestAB) and (valXY = (valeurCible-1))) or
             (analyseIntegraleDeFinale) then
            begin

              if (valXY > bestAB) then ChangeBestAB(valXY,'valXY > bestAB');

              if analyseIntegraleDeFinale or
                 not(bestMode and passeDeRechercheAuMoinsValeurCible and (valXY < valeurCible))
                  then doitAppelerGestionMeilleureSuite := true;
            end;
        end;

      {WritelnStringAndBoolDansRapport('doitAppelerGestionMeilleureSuite = ',doitAppelerGestionMeilleureSuite);}

      if not(ValeurDeFinaleInexploitable(valXY)) then
        begin
          if (valXY > classAux[1].note) then
            begin
              indice_du_meilleur := compteur;
            end;

          if (compteur = 1) or (valXY > classAux[1].note) then
            AEteEnTete[XCourant] := deltaFinaleCourant;

        end;

      if debuggage.algoDeFinale then
        WritelnNumDansRapport('sortie GererAmeliorationPossibleDuScore, valXY = ',valXY);

    end;
end;



procedure GererLeCalculDuDernierMuVariant;
begin
  with variablesMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    if (interruptionReflexion = pasdinterruption) then
      begin


        if ((classementMinimax[1].x <> infosPourMuVariant.x) and (classementMinimax[1].note <> -1)) or
           (classementMinimax[1].note <> infosPourMuVariant.note) then
         begin
           outDernierMuVariant := deltaFinaleCourant;

           (*
           WritelnDansRapport('');
           WriteStringAndCoupDansRapport('XCourant = ',classementMinimax[1].x);
           WriteNumDansRapport('   ==>  val = ',classementMinimax[1].note);
           WritelnNumDansRapport(' ,  µ = ',outDernierMuVariant);
           WritelnDansRapport('');
           *)

           infosPourMuVariant := classementMinimax[1];
         end;

      end;
end;



procedure GererLeTransfertDeLInformationDansLArbreDeJeu;
begin

  with variablesMakeEndgameSearch do
    begin

      (* on met le score du noeud dans l'arbre de jeu *)
      if not(ValeurDeFinaleInexploitable(classAux[1].note)) and
         ((compteur >= longClass) or sortieDeBoucleAcceleree) and
         (deltaFinaleCourant = kDeltaFinaleInfini) and
         not(bestmode and passeDeRechercheAuMoinsValeurCible and (valeurCible <> 0) and (classAux[1].note <> valeurCible)) then
        begin
         {WritelnStringAndBoolDansRapport('bestMode = ',bestMode);
          WritelnStringAndBoolDansRapport('bestmodeArriveeDansCoupGagnant = ',bestmodeArriveeDansCoupGagnant);
          WritelnStringAndBoolDansRapport('sortieDeBoucleAcceleree = ',sortieDeBoucleAcceleree);
          WritelnStringAndBoolDansRapport('passeDeRechercheAuMoinsValeurCible = ',passeDeRechercheAuMoinsValeurCible);
          WritelnNumDansRapport('valeurCible = ',valeurCible);}

          if bestMode and not(passeDeRechercheAuMoinsValeurCible)
            then
              begin
                if odd(classAux[1].note) then
                  begin
                    WritelnNumDansRapport('ASSERT : score impair dans GererLeTransfertDeLInformationDansLArbreDeJeu, classAux[1].note = ',classAux[1].note);
                  end;
                AjouteScoreToEndgameTree(positionEtTraitDeMakeEndgameSearch,ReflParfait,classAux[1].note);
              end
            else AjouteScoreToEndgameTree(positionEtTraitDeMakeEndgameSearch,ReflGagnant,classAux[1].note);
        end;

    end;
end;


procedure GererLeRetrecissementTerminalDeLaFenetreDeRecherche;
begin

  with variablesMakeEndgameSearch do
    begin

      if MinimaxAEvalueAUMoinsUnCoupDansCettePasse and (maxConnuSiToutEstMoinsBonQueValeurCible <> -infini) then
        begin
          if analyseRetrograde.enCours
            then ChangeBestAB(scoreDuCoupDontLeScoreEstConnu,'bestMode and passeDeRechercheAuMoinsValeurCible{1}')
            else ChangeBestAB(-64,'bestMode and passeDeRechercheAuMoinsValeurCible{2}');

          if MinimaxAEvalueTousLesCoupsDansCettePasse(longClass) then   {on sait que tous les coups sont < à valeurCible}
            ChangeBetaAB(succ(maxConnuSiToutEstMoinsBonQueValeurCible),'bestMode and passeDeRechercheAuMoinsValeurCible{3}');
        end;

    end;

end;

procedure GererLAffichageDesRefutationDansLeRapport;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      if not(ValeurDeFinaleInexploitable(valXY)) and avecRefutationsDansRapport and inCommentairesDansRapportFinale and
        not(bestMode) and (compteur >= longClass) and (bestAB < 0) then
          EcritRefutationsDansRapport(longClass,classAux);

    end;

end;


procedure GererPasserAuCoupSuivant;
begin

  with variablesMakeEndgameSearch do
    begin

      compteur := compteur+1;
      indexDuCoupDansFntrReflexion := compteur;
      XCourant := classAux[compteur].x;

      NoteMilieuDeXCourant := classAux[compteur].noteMilieuDePartie;
      NotePourLeTriDeXCourant := classAux[compteur].notePourLeTri;

    end;

end;

procedure GererLaSynchronisationDesClassementsAffiches;
begin
  MetLesCoupsDansLeMemeOrdre(classAux,classementMinimax,longClass);
  MetLesCoupsDansLeMemeOrdre(classAux,ReflexData^.class,longClass);
  SetNombreDeCoupsEvaluesParMinimaxDansCettePasse(0);
end;


BEGIN {MinimaxFinale}

  with variablesMakeEndgameSearch do
    begin

      if (interruptionReflexion <> pasdinterruption)
        then exit(MinimaxFinale);


      if debuggage.algoDeFinale then
        begin
          SetEcritToutDansRapportLog(true);
          {SetRedirigerContenuFntreReflexionDansRapport(true);}
        end;


      MemoryFillChar(@meilleureSuite,sizeof(meilleureSuite),chr(0));
      indice_du_meilleur := longClass;
      maxConnuSiToutEstMoinsBonQueValeurCible := -infini;
      compteur := 0;
      indexDuCoupDansFntrReflexion := 0;


      GererInitialisationDeLaFenetreDeRecherche;
      GererLaRecopieInitialeDuClassement;



      toutesLesPassesTerminees := false;
      passeEhancedTranspositionCutOffEstEnCours := (deltaFinaleCourant < kDeltaFinaleInfini) and (noCoupRecherche <= 58);

    BOUCLE_SUR_LES_FILS :

      repeat

        GererAnnonceDUneNouvellePasseDeMinimaxFinale;
        GererLaSynchronisationDesClassementsAffiches;

        sortieDeBoucleAcceleree := false;
        compteur := 0;

        repeat
          if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

          if (interruptionReflexion = pasdinterruption) then
            begin

              GererPasserAuCoupSuivant;
              GererAffichageTemporaireDuCoupDansLaFenetreDeReflexionPendantLaRecherche;

              GererJouerLeCoupAvantLaRecherche;
              valXY := GererLeCalculDeLaValeur;
              GererDejouerLeCoupApresLaRecherche;

              GererLEstimationDeLaPrecisionDeRecherche;

              if not(ValeurDeFinaleInexploitable(valXY)) then
                begin

                  GererAmeliorationPossibleDuScore;

    		          nouvelIndexDansClassement := GererLeClassementDesCoupsAuMerite;

    		          GererLAffichageDesNotesSurLOthellier(nouvelIndexDansClassement);
    		          GererLeClassementDesCoupsPerdantsAuTemps;
    		          GererLaMeilleureSuite;

    		          GererAffichageClassementDansFenetreReflexion;
    		          GererLAffichageDesRefutationDansLeRapport;

    		          GererLaDecouverteDunCoupGagnant;
    		          GererLaDecouverteDunCoupOptimum;
    		          GererLaDecouverteDuneCoupureBeta;

    		        end;
           end;

        until sortieDeBoucleAcceleree or (compteur >= longClass) or (interruptionReflexion <> pasdinterruption);


        GererAnnonceFinDUnePasseDeMinimaxFinale;
        GererLeTransfertDeLInformationDansLArbreDeJeu;

        if bestMode and passeDeRechercheAuMoinsValeurCible
          then
            begin
              passeDeRechercheAuMoinsValeurCible := false;
              GererLeRetrecissementTerminalDeLaFenetreDeRecherche;
            end
          else
            toutesLesPassesTerminees := true;

      until toutesLesPassesTerminees or (interruptionReflexion <> pasdinterruption);

      if passeEhancedTranspositionCutOffEstEnCours and (interruptionReflexion = pasdinterruption) then
        begin
          passeEhancedTranspositionCutOffEstEnCours := false;
          goto BOUCLE_SUR_LES_FILS;
        end;

      GererLaRecopieFinaleDuClassement;
      GererLeCalculDuDernierMuVariant;

    end;

END;  {MinimaxFinale}


function Algo_Directionnel(quelleValeurCible,coulPourMeilleurFin,nbbl,nbno : SInt32; jeu : plateauOthello; trierAvecLeTemps : boolean; var meilleurX : SInt32) : SInt32;
var precision, profondeurAffichee : SInt32;
    divergence, nbNoeudsEnFlottant : double;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

      if (interruptionReflexion = pasdinterruption) then
        begin
          { on prépare quelques compteur, etc }
          tempsAlloue := CalculeTempsAlloueEnFinale(CoulPourMeilleurFin);
          SetValeurTempsAlloueDansGestionTemps(tempsAlloue);
          LanceChrono;
          LanceChronoCetteProf;

          { on lance la passe de calcul }
          if afficheGestionTemps and (interruptionReflexion = pasdinterruption) and not(CassioEstEnTrainDeCalculerPourLeZoo) then EcritGestionTemps;
          outScoreFinale := MinimaxFinale(quelleValeurCible,coulPourMeilleurFin,MFniv,nbCoup,nbbl,nbno,jeu,emplacementsJouablesFinale,frontiereFinale,trierAvecLeTemps,classement);
          if afficheGestionTemps and (interruptionReflexion = pasdinterruption) and not(CassioEstEnTrainDeCalculerPourLeZoo) then EcritGestionTemps;


          { affichage des infos dans la fenetre Gestion du temps }
          precision := IndexDeltaFinaleEnPrecisionEngine(indexDeltaFinaleCourant);
          profondeurAffichee := PrecisionFinaleEngineEnProfondeurMilieu(precision, inProfondeurFinale);
          nbNoeudsEnFlottant := (1.0 * nbreToursNoeudsGeneresFinale) * 1000000000.0 + 1.0 * nbreNoeudsGeneresFinale;
          if (nbNoeudsEnFlottant > 0) and (inProfondeurFinale - 2 >  0)
						then divergence := exp(ln(nbNoeudsEnFlottant)/(inProfondeurFinale - 2))
					  else divergence := 0.0;
          SetValeursGestionTemps(tempsAlloue,TickCount-tempsGlobalDeLaFonction,0,divergence,profondeurAffichee,0);
          if afficheGestionTemps and (interruptionReflexion = pasdinterruption) and not(CassioEstEnTrainDeCalculerPourLeZoo) then EcritGestionTemps;


          if (interruptionReflexion = pasdinterruption) and ((outScoreFinale < -64) or (outScoreFinale > 64)) then
            begin
              Sysbeep(0);
              WritelnDansRapport('ASSERT dans Algo_Directionnel : (outScoreFinale < -64) or (outScoreFinale > 64)');
              WritelnNumDansRapport('  outScoreFinale = ',outScoreFinale);
              EcritClassementDansRapport(classement, 'classement retourné : ',nbCoup);
            end;


          { on renvoie le premier du classement }
          meilleurX := classement[1].x;
          outBestDefenseFinale := classement[1].theDefense;
          Algo_Directionnel := classement[1].note;
      end;

    end;

end;


function PasseAlgoDirectionnel(quelleValeurCible,deltaFinaleVoulu : SInt32; trierAvecLeTemps : boolean; var passeTerminee : boolean) : SInt32;
var meilleurScore : SInt32;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

      if (deltaFinaleVoulu >= 0) and (interruptionReflexion = pasdinterruption) then
        begin
      	  SetDeltaFinalCourant(deltaFinaleVoulu);

      	  {WriteNumDansRapport('avant delta = ',deltaFinaleCourant);
      	  WritelnDansRapport('…');
      	  WritelnDansRapport('');}

      	  maxEvalsRecursives := 0;

      	  nbCoupuresHeuristiquesCettePasse := 0;
      	  meilleurScore := Algo_Directionnel(quelleValeurCible,coulPourMeilleurFin,inNbreBlancsFinale,inNbreNoirsFinale,inPositionPourFinale,trierAvecLeTemps,outBestMoveFinale);
      	  passeTerminee := (nbCoupuresHeuristiquesCettePasse = 0);

      	  {WriteNumDansRapport('apres delta = ',deltaFinaleCourant);
      	  WritelnNumDansRapport('…   nbreNoeudsGeneresFinale = ',nbreNoeudsGeneresFinale);
      	  WritelnDansRapport('');}

      	  {WritelnDansRapport('');
      	  WritelnNumDansRapport('deltaFinaleCourant = ',deltaFinaleCourant);
      	  WritelnNumDansRapport('nbCoupuresHeuristiquesCettePasse = ',nbCoupuresHeuristiquesCettePasse);}


      	  {On renvoie le score…}
      	  PasseAlgoDirectionnel := meilleurScore;

      	  {… et on sauvegarde eventuellement le score et la suite parfaite}
      	  if (deltaFinaleVoulu = kDeltaFinaleInfini) and (interruptionReflexion = pasdinterruption) then
      	    begin
              if CoulPourMeilleurFin = pionNoir
                then scoreDeNoir :=  meilleurScore
                else scoreDeNoir := -meilleurScore;

              if inMettreLeScoreDansLaCourbeFinale then
                if bestMode
                  then MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleParfaite,scoreDeNoir)
                  else MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleWLD,scoreDeNoir);

              if inMettreLaSuiteDansLaPartie then
                if bestMode
                  then SauvegardeLigneOptimale(coulDefense);
            end;
    	  end;

    end;
end;


procedure EssaieCalculerFinaleOptimaleParOptimalite;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

       if bestMode and not(analyseRetrograde.enCours) and not(GenreDeReflexionInSet(inTypeCalculFinale,[ReflGagnantExhaustif])) then
         if PeutCalculerFinaleOptimaleParOptimalite(inPositionPourFinale,inNbreNoirsFinale,inNbreBlancsFinale,outBestMoveFinale,outBestDefenseFinale,scoreDeNoir)
           then
             begin

               meilleureSuiteAEteCalculeeParOptimalite := true;

               if coulPourMeilleurFin = pionNoir
                 then scoreDuCoupCalculeParOptimalite := scoreDeNoir
                 else scoreDuCoupCalculeParOptimalite := -scoreDeNoir;
               outScoreFinale := scoreDuCoupCalculeParOptimalite;

               if not(GenreDeReflexionInSet(inTypeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]))
                 then
                   begin
                     resultatSansCalcul := true;

                     {coup gagnannt ?}
                     MakeEndgameSearch := ((scoreDeNoir >= 0) and (coulPourMeilleurFin = pionNoir)) or
                                          ((scoreDeNoir <= 0) and (coulPourMeilleurFin = pionBlanc));

                     outScoreFinale := scoreDuCoupCalculeParOptimalite;

                     SetCassioEstEnTrainDeReflechir(cassioEtaitEnTrainDeReflechir,NIL);
                     SetGenreDerniereReflexionDeCassio(inTypeCalculFinale,(inNbreBlancsFinale + inNbreNoirsFinale) - 4 +1);


                     {if (gNbreThreadsReveillees > 0) then}
                        begin
                          err := StopAlphaBetaTasks;
                          err := CreateAlphaBetaTasks;
                        end;

                     exit(MakeEndgameSearch);
                   end
                 else
                   begin
                     if EstLaPositionCourante(positionEtTraitDeMakeEndgameSearch)
      						     then ActiverSuggestionDeCassio(PositionEtTraitCourant,outBestMoveFinale,outBestDefenseFinale,'EssaieCalculerFinaleOptimaleParOptimalite');
                   end;

               if inMettreLeScoreDansLaCourbeFinale then
                 if bestmode
                   then MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleParfaite,scoreDeNoir)
                   else MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleWLD,scoreDeNoir);
             end;
    end;

end;


procedure EssaieCalculerFinaleOptimaleParGameTree;
var suiteOptimale : PropertyList;
    {longueurListeDesCoups : SInt32;}
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

      if (interruptionReflexion <> pasdinterruption) then
        exit(EssaieCalculerFinaleOptimaleParGameTree);

      if EndgameTreeEstValide(numeroEndgameTreeActif, variablesMakeEndgameSearch) then
    	  begin
    	    suiteOptimale := NewPropertyList;

    	    if PeutCalculerFinaleParEndgameTree(numeroEndgameTreeActif,positionEtTraitDeMakeEndgameSearch,
    	                                        suiteOptimale,outScoreFinale) then
            begin

              SetSuiteParfaiteEstConnueDansGameTree(true);

            end;

          DisposePropertyList(suiteOptimale);
        end;

    end;

end;


function InitToutPourRechercheDeFinaleEnProfondeur : boolean;
var i : SInt32;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      InitToutPourRechercheDeFinaleEnProfondeur := false;  {valeur par defaut si on detecte un probleme}

      listeChaineeEstDisponibleArrivee := ListeChaineeDesCasesVidesEstDisponible;
       if not(listeChaineeEstDisponibleArrivee) then
         begin
           SysBeep(0);
           WritelnDansRapport('ERREUR : listeChaineeEstDisponibleArrivee = false dans InitToutPourRechercheDeFinaleEnProfondeur !');
           exit(InitToutPourRechercheDeFinaleEnProfondeur);
         end;

      {if inCommentairesDansRapportFinale and InfosTechniquesDansRapport and (noCoupRecherche < 43) then
    	           AnnonceRechercheDansRapport(noCoupRecherche);}

    	 tempsGlobalDeLaFonction := TickCount;
       infini := 30000;    {pas noteMax pour eviter l'overflow dans derniercoup}


       MFniv := inProfondeurFinale-1;
       MemoryFillChar(@suiteJouee,sizeof(suiteJouee),chr(0));
       MemoryFillChar(@meilleureSuite,sizeof(meilleureSuite),chr(0));
       MemoryFillChar(@classement,sizeof(classement),chr(0));
       SetDerniereAnnonceFinaleDansMeilleureSuite('');
       if doitEcrireReflexFinale and affichageReflexion.doitAfficher
         then SetPositionDansFntreReflexion(ReflexData^,MakePositionEtTrait(inPositionPourFinale,inCouleurFinale));

       if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
       if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);

       CarteJouable(inPositionPourFinale,emplacementsJouablesFinale);
       CarteFrontiere(inPositionPourFinale,frontiereFinale);

       MemoryFillChar(@gNonCoins_entreeCoupGagnant,sizeof(gNonCoins_entreeCoupGagnant),chr(0));
       MemoryFillChar(@gCasesVides_entreeCoupGagnant,sizeof(gCasesVides_entreeCoupGagnant),chr(0));
       MemoryFillChar(@gListeCasesVidesOrdreJCWCoupGagnant,sizeof(gListeCasesVidesOrdreJCWCoupGagnant),chr(0));
       MemoryFillChar(@gCoins_entreeCoupGagnant,sizeof(gCoins_entreeCoupGagnant),chr(0));
       gVecteurParite := 0;
       MemoryFillChar(@gNbreVidesCeQuadrantCoupGagnant,sizeof(gNbreVidesCeQuadrantCoupGagnant),chr(0));
       nbreToursNoeudsGeneresFinale := 0;
       nbreNoeudsGeneresFinale := 0;
       MemoryFillChar(@NbreDeNoeudsMoyensFinale,sizeof(NbreDeNoeudsMoyensFinale),chr(0));
       MemoryFillChar(@infosPourMuVariant,sizeof(infosPourMuVariant),chr(0));
       infosPourMuVariant.note := -333;

       if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
       if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);

       {version de VideToutesLesHashTablesExactes dans laquelle on verifie les interruptions}
       if (MFniv >= 10) and not(analyseRetrograde.enCours and (nbreCoup >= 40)) then
         begin
    	     for i := 0 to nbTablesHashExactes-1 do
    			   begin
    			     if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
    			     if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);

    			     VideHashTableExacte(HashTableExacte[i]);

    			     if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
    			     if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);

    			     VideHashTableCoupsLegaux(CoupsLegauxHash[i]);
    			   end;
    			 nbCollisionsHashTableExactes := 0;
    			 nbNouvellesEntreesHashTableExactes := 0;
    			 nbPositionsRetrouveesHashTableExactes := 0;
         end;

       if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
    	 if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);

       VideHashTable(HashTable);

       if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
    	 if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);

    	 AllocateAllBitboardHashTables;


       InitialiseConstantesCodagePosition;

       tempsAlloue := CalculeTempsAlloueEnFinale(CoulPourMeilleurFin);
       LanceChrono;

       CarteMove(coulPourMeilleurFin,inPositionPourFinale,move,mob);

       if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
       if (interruptionReflexion <> pasdinterruption) then exit(InitToutPourRechercheDeFinaleEnProfondeur);




       CreeListeCasesVidesDeCettePosition(inPositionPourFinale,true);
       CreerListeChaineeDesCasesVides(gNbreVides_entreeCoupGagnant,
                                    gTeteListeChaineeCasesVides,
                                    gBufferCellulesListeChainee,
                                    gTableDesPointeurs,
                                    'InitToutPourRechercheDeFinaleEnProfondeur');
       SetListeChaineeDesCasesVidesEstDisponible(false);

       ResetTraceExecutionFinale;
       RecordTraceExecutionFinale(inProfondeurFinale,clefHashageCoupGagnant,dernierCoupJoue);


       {$IFC USE_DEBUG_HASH_VALUES}
       positionsDejaAffichees := MakeOneElementPositionEtTraitSet(positionEtTraitDeMakeEndgameSearch,clefHashageCoupGagnant);
       WritelnDansRapport('');
       WritelnDansRapport('••••••••• Creation de positionsDejaAffichees avec la position suivante : ••••••••••••••••••');
       WritelnPositionEtTraitDansRapport(jeu,coulPourMeilleurFin);
       WritelnNumDansRapport('clefHashageCoupGagnant = ',clefHashageCoupGagnant);
       WritelnNumDansRapport('hachage(position) = ',GenericHash(@jeu,sizeof(jeu)));
       {$ENDC}

       tempoUserCoeffDansNouvelleEval := withUserCoeffDansNouvelleEval;
       withUserCoeffDansNouvelleEval := false;

       InitToutPourRechercheDeFinaleEnProfondeur := true;

    end;

end;


procedure LibereToutPourRechercheDeFinaleEnProfondeur;
begin

  with variablesMakeEndgameSearch, paramMakeEndgameSearch do
    begin

      tempsGlobalDeLaFonction := TickCount-tempsGlobalDeLaFonction;
      if tempsGlobalDeLaFonction = 0 then tempsGlobalDeLaFonction := 1;

      SetListeChaineeDesCasesVidesEstDisponible(listeChaineeEstDisponibleArrivee);

      if doitEcrireReflexFinale and affichageReflexion.doitAfficher and not(analyseIntegraleDeFinale) then
        begin
          ReinitilaliseInfosAffichageReflexion;
          EffaceReflexion(HumCtreHum);
        end;

       if InfosTechniquesDansRapport and inCommentairesDansRapportFinale and not(InfosDansRapportSontCensurees(noCoupRecherche)) then
         begin
           {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
           AfficheMiniProfilerDansRapport(ktempsMoyen);
           {$ENDC}
           {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
           AfficheMiniProfilerDansRapport(kpourcentage);
           {$ENDC}
           if (interruptionReflexion = pasdinterruption) then AnnonceRechercheDansRapport(noCoupRecherche);
           MetInfosTechniquesDansRapport;
         end;
       EffaceAnnonceFinaleSiNecessaire;

       if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
         then TraiteEvenements
         else TraiteNullEvent(theEvent);

       {$IFC USE_DEBUG_HASH_VALUES}
       DisposePositionEtTraitSet(positionsDejaAffichees);
       {$ENDC}

      withUserCoeffDansNouvelleEval := tempoUserCoeffDansNouvelleEval;

      SetGenreDerniereReflexionDeCassio(inTypeCalculFinale,(inNbreBlancsFinale + inNbreNoirsFinale) - 4 + 1);

      DetruireListeDesCoupsPourLeZoo(inProfondeurFinale);

      EffacerTraceExecutionFinale(inProfondeurFinale);
      ResetTraceExecutionFinale;

      EnvoyerUneRequetePourArreterTousMesCalculsDuZoo;

    end;

end;


function CalculDirectParLeMoteur : boolean;
var note,bestMove : SInt32;
    line : meilleureSuitePtr;
    done : boolean;
begin

  with paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin
      done := false;
      if CassioIsUsingAnEngine(numeroEngine)
         and (inTypeCalculFinale = ReflFinalePasseeDirectementAuMoteur)
         and (inAlphaFinale < inBetaFinale) then
        begin
          line := meilleureSuitePtr(AllocateMemoryPtrClear(sizeof(t_meilleureSuite)));

          if (line <> NIL) then
            if EnginePeutFaireCalculDeFinale(inPositionPourFinale,inCouleurFinale,inAlphaFinale,inBetaFinale,inPrecisionFinale,44,note,bestMove,line^) then
              if (note >= -64) and (note <= 64) and (interruptionReflexion = pasdinterruption) then
                 begin
                   // tout a l'air bon, hein
                   done := true;

                   outBestMoveFinale       := bestMove;
                   outBestDefenseFinale    := 44;
                   outScoreFinale          := note;
                   outLineFinale           := StructureMeilleureSuiteToString(line^, NbCasesVidesDansPosition(inPositionPourFinale));

                   MakeEndgameSearch       := (outScoreFinale >= 0);
                 end;

         if not(done) then inTypeCalculFinale := ReflParfait;

         if line <> NIL then DisposeMemoryPtr(Ptr(line));
       end;
      CalculDirectParLeMoteur := done;
    end;
end;


BEGIN          {MakeEndgameSearch}

  with variablesMakeEndgameSearch, paramMakeEndgameSearch, paramMakeEndgameSearch.outResult do
    begin

      // WriteDansRapport('entree dans MakeEndgameSearch : ');
      // WritelnInterruptionDansRapport(interruptionReflexion);

      {$IFC USE_PROFILER_FINALE_FAST}
      if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr
        then ProfilerSetStatus(1);
      {$ENDC}

      SetCassioEstEnTrainDeReflechir(true,@cassioEtaitEnTrainDeReflechir);

      tempsGlobalDeLaFonction := 1; { un tick au moins }
      tickDepartDeLaFonction  := Tickcount;

      if (interruptionReflexion = pasdinterruption) and VerifieAssertionsDeFinale and ListeChaineeDesCasesVidesEstDisponible then
        begin

          chainesDejaEcrites := MakeEmptyStringSet;

      	  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
      	  analyseIntegraleDeFinale := false;

      	  if (inTypeCalculFinale = ReflFinalePasseeDirectementAuMoteur) and not(CassioIsUsingAnEngine(numeroEngine))
      	    then inTypeCalculFinale := ReflParfait;


      	  case inTypeCalculFinale of
      	    ReflGagnant :
      	       begin
      	         bestMode := false;
      	       end;
      	    ReflGagnantExhaustif :
      	       begin
      	         bestMode := false;
      	       end;
      	    ReflParfait :
      	       begin
      	         bestMode := true;
      	       end;
      	    ReflParfaitExhaustif :
      	       begin
      	         bestMode := true;
      	       end;
      	    ReflRetrogradeParfait :
      	       begin
      	         bestMode := true;
      	       end;
      	    ReflRetrogradeGagnant :
      	       begin
      	         bestMode := false;
      	       end;
      	    ReflFinalePasseeDirectementAuMoteur :
      	       begin
      	         bestMode := true;
      	       end;
      	    otherwise
      	      begin
      	        bestMode := false;
      	      end;
      	  end;

          doitEcrireReflexFinale := not(CassioEstEnTrainDeCalculerPourLeZoo);
          gAvecAttenteTouchePourDebuguerParallelisme  := true;

      	  if not(ScriptDeFinaleEnCours)
      	    then inCommentairesDansRapportFinale := inCommentairesDansRapportFinale and not(jeuInstantane);

      	  if debuggage.algoDeFinale then
      	    begin
      	      inCommentairesDansRapportFinale := true;
      	      SetAutoVidageDuRapport(true);
      	      SetEcritToutDansRapportLog(true);
      	      WritelnDansRapport('');
      	      ChangeFontFaceDansRapport(bold);
      	      ChangeFontColorDansRapport(VertCmd);
      	      WritelnDansRapport('Appel à MakeEndgameSearch pour la position suivante :');
      	      TextNormalDansRapport;
      	      WritelnPositionEtTraitDansRapport(inPositionPourFinale,inCouleurFinale);
      	      WriteNumDansRapport('nb de noirs = ',inNbreNoirsFinale);
      	      WritelnNumDansRapport('   et nb de blancs = ',inNbreBlancsFinale);
      	      WriteNumDansRapport('coup ',inNbreBlancsFinale+inNbreNoirsFinale-4+1);
      	      WriteNumDansRapport(', (donc nb de cases vides = ',inProfondeurFinale);
      	      WritelnDansRapport(')');
      	      WritelnDansRapport('');
      	    end;


      	  rechercheDejaAnnonceeDansRapport := false;
      	  meilleureSuiteAEteCalculeeParOptimalite := false;
      	  scoreDuCoupCalculeParOptimalite := -1000;
      	  SetSuiteParfaiteEstConnueDansGameTree(false);
      	  bestmodeArriveeDansCoupGagnant := bestMode;
      	  noCoupRecherche := inNbreBlancsFinale+inNbreNoirsFinale-4+1;
      	  coulPourMeilleurFin := inCouleurFinale;
      	  coulDefense := -coulPourMeilleurFin;
      	  positionEtTraitDeMakeEndgameSearch := MakePositionEtTrait(inPositionPourFinale,coulPourMeilleurFin);
      	  meilleureSuiteCommeResultatDeMakeEndgameSearch := '';

      	  clefHashageCoupGagnant := CalculateHashIndexFromThisNode(positionEtTraitDeMakeEndgameSearch,inGameTreeNodeFinale,dernierCoupJoue);

      	  case inTypeCalculFinale of
      	    ReflParfaitExhaustif,ReflGagnantExhaustif :
      	       coupGagnantUtiliseEndgameTrees := usingEndgameTrees and (inGameTreeNodeFinale <> NIL);
      	    ReflParfait,ReflGagnant :
      	       coupGagnantUtiliseEndgameTrees := usingEndgameTrees and (inGameTreeNodeFinale <> NIL) and
      	                                         EstLaPositionCourante(positionEtTraitDeMakeEndgameSearch);
      	    ReflRetrogradeParfait, ReflRetrogradeGagnant:
      	       coupGagnantUtiliseEndgameTrees := usingEndgameTrees and (inGameTreeNodeFinale <> NIL) and
      	                                         EstLaPositionCourante(positionEtTraitDeMakeEndgameSearch);
      	    otherwise
      	       coupGagnantUtiliseEndgameTrees := false;
      	  end; {case}
      	  coupDontLeScoreEstConnu := 0;
      	  coupGagnantAUneFenetreAlphaBetaReduite := (inAlphaFinale > -64) or (inBetaFinale < 64);



      	  (*
      	  WritelnNumDansRapport('inTypeCalculFinale = ',inTypeCalculFinale);
      	  WritelnNumDansRapport('inAlphaFinale = ',inAlphaFinale);
      	  WritelnNumDansRapport('inBetaFinale = ',inBetaFinale);
      	  WritelnStringAndBoolDansRapport('fenetre reduite = ',coupGagnantAUneFenetreAlphaBetaReduite);
      	  WritelnStringAndBoolDansRapport('bestmode = ',bestmode);
      	  *)


      	  if not(CalculDirectParLeMoteur) and (interruptionReflexion = pasdinterruption) then

    	      begin

          	  if EstLaPositionCourante(positionEtTraitDeMakeEndgameSearch) then
          	    ViderNotesSurCases(kNotesDeCassio,true,othellierToutEntier);

          	  resultatSansCalcul := false;

          	  EssaieCalculerFinaleOptimaleParOptimalite;


          	  (* WritelnDansRapport('appel potentiel de AllocateNewEndgameTree'); *)
          	  if coupGagnantUtiliseEndgameTrees then
          	     begin
          	       SearchPositionFromThisNode(positionEtTraitDeMakeEndgameSearch,inGameTreeNodeFinale,endgameNode);
          	       if AllocateNewEndgameTree(endgameNode,numeroEndgameTreeActif)
          	         then magicCookieEndgameTree := GetMagicCookieInitialEndgameTree(numeroEndgameTreeActif)
          	         else magicCookieEndgameTree := 0;
          	     end;

          	  if coupGagnantUtiliseEndgameTrees and not(seMefierDesScoresDeLArbre) then
                 begin
                   RetropropagerScoreDesFilsDansGameTree(inGameTreeNodeFinale);
                   EffaceNoeudDansFenetreArbreDeJeu;
          	       EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
                   EssaieCalculerFinaleOptimaleParGameTree;
                 end;


          	   if not(resultatSansCalcul) then
          	     if InitToutPourRechercheDeFinaleEnProfondeur then
          	       begin

          	         // WritelnStringAndBooleanDansRapport('inDoitAbsolumentRamenerLaSuiteFinale = ',inDoitAbsolumentRamenerLaSuiteFinale);

          	         if (mob > 1) or                                            {**** au moins deux coups jouables ****}
          	            inDoitAbsolumentRamenerLaSuiteFinale or
          	            inDoitAbsolumentRamenerUnScoreFinale or
          	            GenreDeReflexionInSet(inTypeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]) then
          				     BEGIN
          				       if (coulPourMeilleurFin = AQuiDeJouer) and not(CassioEstEnTrainDeCalculerPourLeZoo)
          				         then EcritAnnonceFinaleDansMeilleureSuite(inTypeCalculFinale,noCoupRecherche,kDeltaFinaleInfini);

          				       nbcoup := 0;
          				       for index := 1 to gNbreCoins_entreeCoupGagnant do
          				         if move[gCoins_entreeCoupGagnant[index]]  then
          				           begin
          				             nbCoup := nbCoup+1;
          				             classement[nbCoup].x := gCoins_entreeCoupGagnant[index];
          				           end;
          				       for index := 1 to gNbreNonCoins_entreeCoupGagnant do
          				         if move[gNonCoins_entreeCoupGagnant[index]]  then
          				           begin
          				             nbCoup := nbCoup+1;
          				             classement[nbCoup].x := gNonCoins_entreeCoupGagnant[index];
          				           end;

          				       tempsAlloue := CalculeTempsAlloueEnFinale(CoulPourMeilleurFin);
          				       SetValeursGestionTemps(tempsAlloue,0,0,0.0,0,0);
          				       if afficheGestionTemps and (interruptionReflexion = pasdinterruption) and not(CassioEstEnTrainDeCalculerPourLeZoo) then EcritGestionTemps;




          				       profMinimalePourClassementParMilieu := 16;

          				       nbNiveauxRemplissageHash := 6;
          				       nbNiveauxHashExacte := 25;

          				       profondeurRemplissageHash := inProfondeurFinale-nbNiveauxRemplissageHash;
          				       ProfPourHashExacte := inProfondeurFinale-nbNiveauxHashExacte;


          				       if ProfPourHashExacte < 10 then ProfPourHashExacte := 10;
          				       if profondeurRemplissageHash < 7 then profondeurRemplissageHash := 7;
          				       ProfUtilisationHash := Min(ProfPourHashExacte,profondeurRemplissageHash);



          				       { la ligne suivante est bien !!!!}
          				       profFinaleHeuristique := Max(Max(inProfondeurFinale-gProfondeurCoucheEvalsHeuristiques,profMinimalePourClassementParMilieu),ProfPourHashExacte+1);



          				       profForceBrute := ProfPourHashExacte - 1;

          				       if profForceBrute < 13
          				         then profForceBrute := 13;

          				       if profForceBrute > profMinimalePourClassementParMilieu-1
          				         then profForceBrute := profMinimalePourClassementParMilieu-1;

          				       if profForceBrute > profFinaleHeuristique-2
          				         then profForceBrute := profFinaleHeuristique-2;

          				       if profForceBrute < 5 then profForceBrute := 5; (* attention : profForceBrute doit etre >= 5, sinon Boum ! *)
          				       profPourTriSelonDivergence := 0;  {toujours trier selon divergence tant qu'on est dans ABFin}

          				         {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
          				           (*profForceBrute := 30;*)
          				         {$ENDC}

          				       profForceBrute := profFinaleHeuristique - 2;


          				       if (profForceBrute > 16) then profForceBrute := 16;  // changer cela en 17 semble dangereux





          				       profForceBrutePlusUn := profForceBrute+1;
          				       ProfPourHashExacte := Max(ProfPourHashExacte,profForceBrute+1);


          				       (*
          				       WritelnNumDansRapport('profForceBrute = ',profForceBrute);
          				       WritelnNumDansRapport('profFinaleHeuristique = ',profFinaleHeuristique);
          				       WritelnNumDansRapport('ProfPourHashExacte = ',ProfPourHashExacte);
          				       WritelnNumDansRapport('profMinimalePourClassementParMilieu = ',profMinimalePourClassementParMilieu);
          				       WritelnNumDansRapport('ProfUtilisationHash = ',ProfUtilisationHash);
          				       *)

          				       tempsAlloue := CalculeTempsAlloueEnFinale(CoulPourMeilleurFin);

          			         SetDeltaFinalCourant(deltaSuccessifs[1].valeurDeMu);
          			         termine := false;

          			         PreordonnancementDesCoups;
          			         {DetruitEntreesIncorrectesHashTableCoupsLegaux;}



          			        {$IFC USE_PROFILER_FINALE_FAST}
          						   nomFichierProfile := PrefixeFichierProfiler + NumEnString((TickCount-tempsGlobalDeLaFonction) div 60) + '.preordre';
          						   WritelnDansRapport('nomFichierProfile = '+nomFichierProfile);
          						   if ProfilerDump(nomFichierProfile) <> NoErr
          						     then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfile+') a échoué !')
          						     else ProfilerSetStatus(0);
          						   ProfilerTerm;
          						   {on recommence un autre profile, pour le code de finale}
          						   if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr
          	                         then ProfilerSetStatus(1);
          					    {$ENDC}

          					     if VerifieAssertionsDeFinale then DoNothing;

          			         if (interruptionReflexion = pasdinterruption) and not(seMefierDesScoresDeLArbre) then
          			           begin
          			             EngineBeginFeedHashSequence;
          			             MetSousArbreDansHashTableExacte(inGameTreeNodeFinale,ProfPourHashExacte);
          			             MetSousArbreDansHashTableExacte(inGameTreeNodeFinale,ProfPourHashExacte);  {on redouble pour avoir les valeurs actualisées}
          			             EngineEndFeedHashSequence;
          			             TrierSelonHashTableExacte(positionEtTraitDeMakeEndgameSearch,classement,nbCoup,clefHashageCoupGagnant);
          			             EffaceNoeudDansFenetreArbreDeJeu;
          	      	         EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
          			           end;

                         if bestMode and coupGagnantAUneFenetreAlphaBetaReduite and (inTypeCalculFinale = ReflParfait) {l'algo avec une fenetre alpha-beta personalisée}
                           then
                             begin
                               milieuFenetre := (inAlphaFinale + inBetaFinale) div 2;
                               outScoreFinale := PasseAlgoDirectionnel(milieuFenetre,deltaSuccessifs[1].valeurDeMu,true,termine);
                               for index := 2 to IndexOfThisDelta(inMuMaximumFinale) do
          							         if not(termine) then outScoreFinale := PasseAlgoDirectionnel(milieuFenetre,deltaSuccessifs[index].valeurDeMu,true,termine);
                             end
                           else
          					     if bestMode and not(GenreDeReflexionInSet(inTypeCalculFinale,[ReflParfaitExhaustif,ReflGagnantExhaustif]))  {l'algo de meilleur score standard}
          				         then
          					         begin
          					           bestMode := false;
          							       outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[1].valeurDeMu,true,termine);
          							       for index := 2 to nbreDeltaSuccessifs do
          							         if not(termine) then outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[index].valeurDeMu,true,termine);

          						         bestMode := true;
          						         outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[1].valeurDeMu,true,termine);
          						         for index := 2 to nbreDeltaSuccessifs-1 do
          					             if not(termine) then outScoreFinale := PasseAlgoDirectionnel(outScoreFinale,deltaSuccessifs[index].valeurDeMu,false,termine);
          						         outScoreFinale := PasseAlgoDirectionnel(outScoreFinale,kDeltaFinaleInfini,false,dernierePasseTerminee);
          						       end
          					       else
          					     if bestMode and (inTypeCalculFinale = ReflParfaitExhaustif)  {l'algo pour tous les scores}
          				         then
          					         begin

          					           analyseIntegraleDeFinale := false;
          					           bestMode := false;
          					           outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[1].valeurDeMu,true,termine);
          					           for index := 2 to nbreDeltaSuccessifs do
          					             if not(termine) then outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[index].valeurDeMu,true,termine);

          						         analyseIntegraleDeFinale := false;
          						         bestMode := true;
          						         outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[1].valeurDeMu,true,termine);
          						         for index := 2 to nbreDeltaSuccessifs-1 do
          					             if not(termine) then outScoreFinale := PasseAlgoDirectionnel(outScoreFinale,deltaSuccessifs[index].valeurDeMu,false,termine);
          						         outScoreFinale := PasseAlgoDirectionnel(outScoreFinale,kDeltaFinaleInfini,false,dernierePasseTerminee);

          						         {on connait le meilleur coup : on l'affiche eventuellement comme suggestion de Cassio}
          						         if (interruptionReflexion = pasdinterruption) and
          						            EstLaPositionCourante(positionEtTraitDeMakeEndgameSearch)
          						           then ActiverSuggestionDeCassio(PositionEtTraitCourant,classement[1].x,classement[1].theDefense,'MakeEndgameSearch {ReflParfaitExhaustif}');


          						         analyseIntegraleDeFinale := true;
          						         bestMode := true;
          						         outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[1].valeurDeMu,true,termine);
          						         for index := 2 to nbreDeltaSuccessifs-1 do
          					             if not(termine) then outScoreFinale := PasseAlgoDirectionnel(outScoreFinale,deltaSuccessifs[index].valeurDeMu,false,termine);
          						         outScoreFinale := PasseAlgoDirectionnel(outScoreFinale,kDeltaFinaleInfini,false,dernierePasseTerminee);
          						       end
          						     else  {l'algo gagnant/perdant exhaustif}
          						   if not(bestMode) and (inTypeCalculFinale = ReflGagnantExhaustif)
          						     then
          				           begin
          				             analyseIntegraleDeFinale := false;
          				             outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[1].valeurDeMu,true,termine);
          				             for index := 2 to nbreDeltaSuccessifs-1 do
          					             if not(termine) then outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[index].valeurDeMu,true,termine);
          						         outScoreFinale := PasseAlgoDirectionnel(0,kDeltaFinaleInfini,false,dernierePasseTerminee);

          						         {on connait un coup gagnant : on l'affiche eventuellement comme suggestion de Cassio}
          						         if (interruptionReflexion = pasdinterruption) and (classement[1].note >= 0) and
          						            EstLaPositionCourante(positionEtTraitDeMakeEndgameSearch) then
          						           ActiverSuggestionDeCassio(PositionEtTraitCourant,classement[1].x,classement[1].theDefense,'MakeEndgameSearch {ReflGagnantExhaustif}');

          						         analyseIntegraleDeFinale := true;
          				             outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[1].valeurDeMu,true,termine);
          				             for index := 2 to nbreDeltaSuccessifs-1 do
          					             if not(termine) then outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[index].valeurDeMu,true,termine);
          						         outScoreFinale := PasseAlgoDirectionnel(0,kDeltaFinaleInfini,false,dernierePasseTerminee);
          				           end
          						     else  {l'algo gagnant/perdant standard}
          				           begin
          				             outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[1].valeurDeMu,true,termine);
          				             for index := 2 to nbreDeltaSuccessifs-1 do
          					             if not(termine) then outScoreFinale := PasseAlgoDirectionnel(0,deltaSuccessifs[index].valeurDeMu,not(bestMode),termine);
          						         outScoreFinale := PasseAlgoDirectionnel(0,kDeltaFinaleInfini,false,dernierePasseTerminee);
          				           end;

          				       {outScoreFinale := Algo_NegaCStar(-64,64,coulPourMeilleurFin,inProfondeurFinale,nbbl,nbno,jeu,meilleurX);}
          				       {outScoreFinale := Algo_SSSStar(-64,64,coulPourMeilleurFin,inProfondeurFinale,nbbl,nbno,jeu,meilleurX);}
          				       {outScoreFinale := Algo_AlphaBetaBrut(-64,64,coulPourMeilleurFin,inProfondeurFinale,nbbl,nbno,jeu,meilleurX);}

          				 {      WritelnNumDansRapport('score = ',outScoreFinale);
          			          WritelnNumDansRapport('meilleurCoup = ',meilleurX);     }

          				        MakeEndgameSearch := (outScoreFinale >= 0);

          			        END
          	          else             { sinon on cherche l'unique coup }
          	            BEGIN
          	              for index := 1 to 64 do
          	               if move[othellier[index]] then
          	                 begin
          	                    outBestMoveFinale := othellier[index];
          	                    outBestDefenseFinale := 44;
          	                    MakeEndgameSearch := true;
          	                    outScoreFinale := ScorePourUnSeulCoupLegal;
          	                 end;
          	               EcritMeilleureSuiteParOptimalite;
          	               if analyseRetrograde.enCours then
          	                 if inMessageHandleFinale <> NIL then
          	                   begin
          	                     typeDataDansHandle := inMessageHandleFinale^^.typeData;
          	                     case typeDataDansHandle of
          	                       ReflScoreDejaConnuFinale,ReflScoreDeCeCoupConnuFinale :
          	                         if CoulPourMeilleurFin = pionNoir
          	                           then scoreDeNoir :=  inMessageHandleFinale^^.data[0]
          	                           else scoreDeNoir := -inMessageHandleFinale^^.data[0];
          	                       otherwise
          	                          AlerteSimple('typeDataDansHandle inconnu dans UnitFinaleFast !');
          	                     end; {case}
          	                     if inMettreLeScoreDansLaCourbeFinale then
            	                     if bestMode
            	                       then MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleParfaite,scoreDeNoir)
            	                       else MetScorePrevuParFinaleDansCourbe(noCoupRecherche,noCoupRecherche,kFinaleWLD,scoreDeNoir);
          	                   end;
          	            END;

          	         LibereToutPourRechercheDeFinaleEnProfondeur;
          	      end;


          	  if coupGagnantUtiliseEndgameTrees then
          	    begin
          	      DetruitLesFilsVirtuelsInutilesDeCeNoeud(endgameNode);
          	      DetruitLesFilsVirtuelsInutilesDeCeNoeud(inGameTreeNodeFinale);

          	      TrierLesFilsDeCeNoeud(inGameTreeNodeFinale, kTriSelonValeurDeFinale, changed);

          	      EffaceNoeudDansFenetreArbreDeJeu;
          	      EcritCurrentNodeDansFenetreArbreDeJeu(true,false);

          	      if afficheProchainsCoups and (BAND(GetAffichageProprietesOfCurrentNode,kProchainCoup) <> 0) then
          	        DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'MakeEndgameSearch');
          	    end;
          	  if EndgameTreeEstValide(numeroEndgameTreeActif, variablesMakeEndgameSearch) then
          	    LibereEndgameTree(numeroEndgameTreeActif);
          	  (* EcritStatistiquesEndgameTrees; *)



          	end;


    	    DisposeStringSet(chainesDejaEcrites);

        end;

      {if (interruptionReflexion <> pasdinterruption) then VideToutesLesHashTablesExactes;}

      {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
      EcrireCollecteStatsNbreNoeudsEndgameDansRapport;
      {$ENDC}

      {$IFC USE_PROFILER_FINALE_FAST}
       nomFichierProfile := PrefixeFichierProfiler + NumEnString(tempsGlobalDeLaFonction div 60) + '.profile';
       WritelnDansRapport('nomFichierProfile = '+nomFichierProfile);
       if ProfilerDump(nomFichierProfile) <> NoErr
         then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfile+') a échoué !')
         else ProfilerSetStatus(0);
       ProfilerTerm;
      {$ENDC}


      {if (gNbreThreadsReveillees > 0) then}
        begin
          err := StopAlphaBetaTasks;
          err := CreateAlphaBetaTasks;
        end;


      SetGenreDerniereReflexionDeCassio(inTypeCalculFinale,(inNbreBlancsFinale + inNbreNoirsFinale) - 4 +1);
      SetCassioEstEnTrainDeReflechir(cassioEtaitEnTrainDeReflechir,NIL);

      outTimeTakenFinale := Max(Tickcount - tickDepartDeLaFonction, 1) / 60.0;   { outTimeTakenFinale est en secondes, et tempsGlobalDeLaFonction en ticks }

    end;

  // WriteDansRapport('... sortie de MakeEndgameSearch : ');
  // WritelnInterruptionDansRapport(interruptionReflexion);

END;  {MakeEndgameSearch}


END.
































