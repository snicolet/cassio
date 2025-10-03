UNIT UnitEvaluation;

INTERFACE







 USES UnitDefCassio;



{ initialisation de l'unite }
procedure InitUnitEvaluation;                                                                                                                                                       ATTRIBUTE_NAME('InitUnitEvaluation')
procedure LibereMemoireUnitEvaluation;                                                                                                                                              ATTRIBUTE_NAME('LibereMemoireUnitEvaluation')


{ Gestion des types d'evaluation disponibles dans Cassio }
function TypeEvalEnChaine(whichEval : EvalsDisponibles) : String255;                                                                                                                ATTRIBUTE_NAME('TypeEvalEnChaine')
procedure SetTypeEvaluationEnCours(laquelle : SInt32);                                                                                                                              ATTRIBUTE_NAME('SetTypeEvaluationEnCours')
function TypeEvalEnCoursEnInteger : SInt32;                                                                                                                                         ATTRIBUTE_NAME('TypeEvalEnCoursEnInteger')



{ L'evaluation elle-meme ! }
function Evaluation(var position : plateauOthello; coulEvaluation,nbBlancs,nbNoirs : SInt32; var jouable : plBool; var front : InfoFront; afraidOfWipeOut : boolean; alpha,beta : SInt32; var nbEvaluationsRecursives : SInt32) : SInt32;                                     ATTRIBUTE_NAME('Evaluation')



{ ATTENTION : ces fonctions sont lentes car elle doivent recalculer
              tous les index des patterns, la frontiere, etc. alors
              que l'alpha-beta calcule normalement ceci incrementalement }
function EvaluationHorsContexte(var whichPos : PositionEtTraitRec) : SInt32;                                                                                                        ATTRIBUTE_NAME('EvaluationHorsContexte')
function EvaluationHorsContexteACetteProfondeur(var whichPos : PositionEtTraitRec; prof : SInt32; var meilleurCoup : SInt32; withCheckEvents : boolean) : SInt32;                   ATTRIBUTE_NAME('EvaluationHorsContexteACetteProfondeur')
function GetListeTrieeDesCoupsACetteProfondeurHorsContexte(var whichPos : PositionEtTraitRec; prof : SInt32;  var liste : ListOfMoveRecords; withCheckEvents : boolean) : SInt32;   ATTRIBUTE_NAME('GetListeTrieeDesCoupsACetteProfondeurHorsContexte')



{ Une petite fonction pour faire des statistiques sur les composantes de l'eval (obsolete) }
function CreeEvaluationCassioRec(var position : plateauOthello; coulEvaluation,nbBlancs,nbNoirs : SInt32; var jouable : plBool; var front : InfoFront) : EvaluationCassioRec;       ATTRIBUTE_NAME('CreeEvaluationCassioRec')



{ Des evaluations pittoresques pour les niveaux faibles de Cassio }
function EvaluationMaximisation(var position : plateauOthello; coulEvaluation,nbBlancs,nbNoirs : SInt32) : SInt32;                                                                  ATTRIBUTE_NAME('EvaluationMaximisation')
function EvaluationDesBords(var position : plateauOthello; coulEvaluation : SInt32; var front : InfoFront) : SInt32;                                                                ATTRIBUTE_NAME('EvaluationDesBords')


{ Une fonction utile por le debugage }
function EstLaPositionBizarreDansEvaluation(var position : plateauOthello; coulEvaluation : SInt32) : boolean;                                                                      ATTRIBUTE_NAME('EstLaPositionBizarreDansEvaluation')








IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    EdmondEvaluation, UnitNouvelleEval, UnitStrategie, UnitBlocsDeCoin, UnitBords, UnitRapport, UnitHashing, UnitServicesMemoire
    , UnitPositionEtTrait, UnitSuperviseur, UnitGestionDuTemps, UnitEvenement, Unit_AB_simple ;
{$ELSEC}
    {$I prelink/Evaluation.lk}
{$ENDC}


{END_USE_CLAUSE}








const kTailleCacheDesEvaluationsHorsContexte = 1024;

var gIndexCourantDansCacheDesEvaluationsHorsContexte : SInt32;
    glastUsedIndexinSearch : SInt32;
    gCacheDesEvaluationsHorsContexte :
       array[ 0 .. kTailleCacheDesEvaluationsHorsContexte - 1 ] of
         record
           whichHashkey : SInt32;
           whichProf    : SInt32;
           whichNote    : SInt32;
           whichMove    : SInt32;
         end;




procedure InitUnitEvaluation;
var k : SInt32;
begin
  typeEvalEnCours := EVAL_EDMOND;

  glastUsedIndexinSearch := 0;
  gIndexCourantDansCacheDesEvaluationsHorsContexte := 0;
  for k := 0 to kTailleCacheDesEvaluationsHorsContexte - 1 do
    gCacheDesEvaluationsHorsContexte[k].whichProf := -1000;
end;


procedure LibereMemoireUnitEvaluation;
begin
end;


procedure SetTypeEvaluationEnCours(laquelle : SInt32);
begin
  if laquelle <= SInt32(EVAL_STUB_MIN) then laquelle := succ(SInt32(EVAL_STUB_MIN));
  if laquelle >= SInt32(EVAL_STUB_MAX) then laquelle := pred(SInt32(EVAL_STUB_MAX));

  typeEvalEnCours := EvalsDisponibles(laquelle);

  {WritelnDansRapport('eval en cours = ' + TypeEvalEnChaine(typeEvalEnCours));}
end;


function TypeEvalEnCoursEnInteger : SInt32;
begin
  TypeEvalEnCoursEnInteger := SInt32(typeEvalEnCours);
end;


function TypeEvalEnChaine(whichEval : EvalsDisponibles) : String255;
begin
  case whichEval of
    EVAL_CASSIO               : TypeEvalEnChaine := 'EVAL_CASSIO';
    EVAL_EDMOND               : TypeEvalEnChaine := 'EVAL_EDMOND';
    EVAL_MIXTE_CASSIO_EDMOND  : TypeEvalEnChaine := 'EVAL_MIXTE_CASSIO_EDMOND';
    EVAL_MAXIMISATION         : TypeEvalEnChaine := 'EVAL_MAXIMISATION';
    EVAL_SEULEMENT_LES_BORDS  : TypeEvalEnChaine := 'EVAL_SEULEMENT_LES_BORDS';
    EVAL_HISTORIQUE_DE_CASSIO : TypeEvalEnChaine := 'EVAL_HISTORIQUE_DE_CASSIO';
    otherwise                   TypeEvalEnChaine := 'EVAL INCONNUE !!';
  end;
end;


function EstLaPositionBizarreDansEvaluation(var position : plateauOthello; coulEvaluation : SInt32) : boolean;
var chainePositionBizarre : String255;
    positionEvalueeBizarrement : PositionEtTraitRec;
    aux : PositionEtTraitRec;
begin
	chainePositionBizarre := '-----------------------O--OOOOOX--OOOOOXOOOOXXXX-OOOOOOX--XXXXXX';
  positionEvalueeBizarrement := PositionRapportEnPositionEtTrait(chainePositionBizarre,pionNoir);

  aux := MakePositionEtTrait(position,coulEvaluation);

  if SamePositionEtTrait(aux, positionEvalueeBizarrement)
    then
      begin
        EstLaPositionBizarreDansEvaluation := true;
        WritelnDansRapport('');
        WritelnDansRapport('Je suis arrivé à la position bizarre');
      end
    else
      EstLaPositionBizarreDansEvaluation := false;
end;



function AlphaBetaLocalDansEvaluation(var position : plateauOthello; coulEvaluation,nbBlancs,nbNoirs : SInt32; var jouable : plBool; var front : InfoFront; afraidOfWipeOut : boolean; var alpha,beta : SInt32; var dejaEssayes : plBool) : SInt32;
var platRecur : plateauOthello;
    jouableRecur : plBool;
    frontRecur : InfoFront;
    nbBlancsRecur,nbNoirsRecur : SInt32;
    evalApresCoupCritique,MaxApresTousLesCoupsCritiques : SInt32;
    k,nbAppelsRecursifs : SInt32;
    {ecrireCoupsCritiques : boolean;}


  procedure EvalueCoupCritique(caseCritique : SInt32);
  begin

    {
     if (indexDansTableABLocal < 0) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : indexDansTableABLocal < 0 !!');
	      WritelnNumDansRapport('indexDansTableABLocal = ',indexDansTableABLocal);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (indexDansTableABLocal > kTaille_Max_Index_Bords_AB_Local) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : indexDansTableABLocal > kTaille_Max_Index_Bords_AB_Local !!');
	      WritelnNumDansRapport('indexDansTableABLocal = ',indexDansTableABLocal);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;

	 if (table_index_bords_AB_local[indexDansTableABLocal] < 1) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : table_index_bords_AB_local[indexDansTableABLocal] < 1 !!');
	      WritelnNumDansRapport('table_index_bords_AB_local[indexDansTableABLocal] = ',table_index_bords_AB_local[indexDansTableABLocal]);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (table_index_bords_AB_local[indexDansTableABLocal] > 8) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : table_index_bords_AB_local[indexDansTableABLocal] > 8 !!');
	      WritelnNumDansRapport('table_index_bords_AB_local[indexDansTableABLocal] = ',table_index_bords_AB_local[indexDansTableABLocal]);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (caseCritique <= 10) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : caseCritique < 11 !!');
	      WritelnNumDansRapport('caseCritique = ',caseCritique);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (caseCritique >= 89) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : caseCritique > 88 !!');
	      WritelnNumDansRapport('caseCritique = ',caseCritique);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
   }


    { if ecrireCoupsCritiques | EstLaPositionBizarreDansEvaluation(position,coulEvaluation) then
        begin
          WritelnDansRapport('');
          WritelnDansRapport('   ………position bizarre dans EvalueCoupCritique');
          WritelnStringAndCoupDansRapport('   caseCritique = ',caseCritique);
        end;
    }



     if not(dejaEssayes[caseCritique]) then
       begin
         dejaEssayes[caseCritique] := true;

         platRecur := position;
         jouableRecur := jouable;
         nbBlancsRecur := nbBlancs;
         nbNoirsRecur := nbNoirs;
         frontRecur := front;
         if ModifPlat(caseCritique,coulEvaluation,platRecur,jouableRecur,nbBlancsRecur,nbNoirsRecur,frontRecur)
          then
            begin
              {AjouteDansStatistiquesDeBordsABLocal(essai_bord_AB_local,bord,indexDansTable);}
              evalApresCoupCritique := -Evaluation(platRecur,-coulEvaluation,nbBlancsRecur,nbNoirsRecur,jouableRecur,frontRecur,
                                                   afraidOfWipeOut,-beta,-alpha,nbAppelsRecursifs);

              if evalApresCoupCritique > MaxApresTousLesCoupsCritiques then
                begin
                  MaxApresTousLesCoupsCritiques := evalApresCoupCritique;

                  if (MaxApresTousLesCoupsCritiques >= beta) then
                    begin
                      {AjouteDansStatistiquesDeBordsABLocal(coupure_bord_AB_local,bord,indexDansTable);}
                      AlphaBetaLocalDansEvaluation := MaxApresTousLesCoupsCritiques;
                      exit(AlphaBetaLocalDansEvaluation);
                    end;

                  if (MaxApresTousLesCoupsCritiques > alpha) then alpha := MaxApresTousLesCoupsCritiques;
                end;
            end;
       end;
   end;


begin
  MaxApresTousLesCoupsCritiques := -30000;

  {ecrireCoupsCritiques := false;
  if EstLaPositionBizarreDansEvaluation(position,coulEvaluation) then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('   ………position bizarre dans AlphaBetaLocalDansEvaluation');
      WritelnNumDansRapport('   alpha = ',alpha);
      WritelnNumDansRapport('   beta = ',beta);
      WritelnStringAndBoolDansRapport('TurbulenceBordsEstInitialisee = ',TurbulenceBordsEstInitialisee);
      ecrireCoupsCritiques := true;
    end; }

  with front do
	  if coulEvaluation = pionBlanc
	     then
	       begin
	         for k := table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordNord]-1] to table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordNord]]-1 do
	           EvalueCoupCritique(caseBordNord[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordOuest]-1] to table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordOuest]]-1 do
	           EvalueCoupCritique(caseBordOuest[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordEst]-1] to table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordEst]]-1 do
	           EvalueCoupCritique(caseBordEst[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordSud]-1] to table_Turbulence_alpha_beta_local^[AdressePattern[kAdresseBordSud]]-1 do
	           EvalueCoupCritique(caseBordSud[table_index_bords_AB_local[k]]);
	       end
	     else
	       begin
	         for k := table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordNord]-1] to table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordNord]]-1 do
	           EvalueCoupCritique(caseBordNord[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordOuest]-1] to table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordOuest]]-1 do
	           EvalueCoupCritique(caseBordOuest[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordEst]-1] to table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordEst]]-1 do
	           EvalueCoupCritique(caseBordEst[table_index_bords_AB_local[k]]);
	         for k := table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordSud]-1] to table_Turbulence_alpha_beta_local^[-AdressePattern[kAdresseBordSud]]-1 do
	           EvalueCoupCritique(caseBordSud[table_index_bords_AB_local[k]]);
	       end;

   AlphaBetaLocalDansEvaluation := MaxApresTousLesCoupsCritiques;
end;


function AlphaBetaCoupsTranquillesDansEvaluation(var position : plateauOthello; coulEvaluation,nbBlancs,nbNoirs : SInt32; var jouable : plBool; var front : InfoFront; afraidOfWipeOut : boolean; var alpha,beta : SInt32; var listeDesCoupsTranquilles : ListeDeCases; var dejaEssayes : plBool) : SInt32;         
var platRecur : plateauOthello;
    jouableRecur : plBool;
    frontRecur : InfoFront;
    nbBlancsRecur,nbNoirsRecur : SInt32;
    evalApresCoupTranquille,MaxApresTousLesCoupsTranquilles : SInt32;
    k,nbAppelsRecursifs : SInt32;

  procedure EvalueCoupTranquille(coupTranquille : SInt32);
  begin

  {
	 if (coupTranquille <= 10) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : coupTranquille < 11 !!');
	      WritelnNumDansRapport('coupTranquille = ',coupTranquille);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
	 if (coupTranquille >= 89) then
        begin
	      SysBeep(0);
	      WritelnDansRapport('problème : coupTranquille > 88 !!');
	      WritelnNumDansRapport('coupTranquille = ',coupTranquille);
	      WritelnPositionEtTraitDansRapport(position,coulEvaluation);
	      AttendFrappeClavier;
	    end;
    }


     if not(dejaEssayes[coupTranquille]) then
       begin

         dejaEssayes[coupTranquille] := true;

         platRecur := position;
         jouableRecur := jouable;
         nbBlancsRecur := nbBlancs;
         nbNoirsRecur := nbNoirs;
         frontRecur := front;
         if ModifPlat(coupTranquille,coulEvaluation,platRecur,jouableRecur,nbBlancsRecur,nbNoirsRecur,frontRecur)
          then
            begin
              evalApresCoupTranquille := -Evaluation(platRecur,-coulEvaluation,nbBlancsRecur,nbNoirsRecur,jouableRecur,frontRecur,
                                                     afraidOfWipeOut,-beta,-alpha,nbAppelsRecursifs);

              if evalApresCoupTranquille > MaxApresTousLesCoupsTranquilles then
                begin
                  MaxApresTousLesCoupsTranquilles := evalApresCoupTranquille;

                  if (MaxApresTousLesCoupsTranquilles >= beta) then
                    begin
                      {if utilisationNouvelleEval then
                        begin
    			                SysBeep(0);
    		  	              WritelnStringDansRapport('coupTranquille = '+CoupEnStringEnMajuscules(coupTranquille));
    			                WritelnPositionEtTraitDansRapport(position,coulEvaluation);
    			                AttendFrappeClavier;
    			              end;}
    	                AlphaBetaCoupsTranquillesDansEvaluation := MaxApresTousLesCoupsTranquilles;
                      exit(AlphaBetaCoupsTranquillesDansEvaluation);
                    end;

                  if (MaxApresTousLesCoupsTranquilles > alpha) then alpha := MaxApresTousLesCoupsTranquilles;
                end;
            end;
        end;
   end;


begin
  MaxApresTousLesCoupsTranquilles := -30000;


  for k := 1 to listeDesCoupsTranquilles.cardinal do {tout l'othellier, sauf les bords, les cases X et le carre E4-E5-D4-D5}
    EvalueCoupTranquille(listeDesCoupsTranquilles.liste[k]);


  AlphaBetaCoupsTranquillesDansEvaluation := MaxApresTousLesCoupsTranquilles;
end;



function Evaluation(var position : plateauOthello; coulEvaluation,nbBlancs,nbNoirs : SInt32;
                    var jouable : plBool; var front : InfoFront; afraidOfWipeOut : boolean;
                    alpha,beta : SInt32; var nbEvaluationsRecursives : SInt32) : SInt32;
const MoinsInfini = -30000;
var t,x,evalPartielle,adversaire,coins,centre,petitcentre : SInt32;
    evalFrontiere,evalMobilite,mobiliteCoulEvaluation,mobiliteAdversaire : SInt32;
    platRecur : plateauOthello;
    jouableRecur : plBool;
    frontRecur : InfoFront;
    dejaEssayes : plBool;
    nbBlancsRecur,nbNoirsRecur : SInt32;
    evalApresPriseCoin,MaxApresPriseCoin : SInt32;
    valeurAlphaBetaCoins,valeurAlphaBetaBordsCritiques : SInt32;
    evalFrontiereNonLineaire{,evalRendementDeLaFrontriere} : SInt32;
    listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire : ListeDeCases;
    valeurAlphaBetaCoupsTranquilles : SInt32;
    nbAppelsRecursifs : SInt32;
    legal : boolean;
    ramdomPerturbation : SInt32;

begin


  {if EstLaPositionBizarreDansEvaluation(position,coulEvaluation) then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('   ………position bizarre dans Evaluation');
      WritelnStringAndBooleenDansRapport('   avecRecursiviteDansEval = ',avecRecursiviteDansEval);


      if (alpha = -6400) then alpha := -10000;
      if (beta = 6400) then beta := 10000;

      WritelnNumDansRapport('   alpha = ',alpha);
      WritelnNumDansRapport('   beta = ',beta);
    end;}



  if (nbBlancs = 0) then
		begin
		  if coulEvaluation = pionBlanc
			  then Evaluation := {-100*nbNoirs} -6400
			  else Evaluation := {100*nbNoirs }  6400;
		  exit(Evaluation);
		end;
  if (nbNoirs = 0) then
    begin
      if coulEvaluation = pionBlanc
			  then Evaluation := {100*nbBlancs}   6400
			  else Evaluation := {-100*nbBlancs} -6400;
	    exit(Evaluation);
	  end;

  nbEvaluationsRecursives := nbreFeuillesMilieu;  {par definition nbEvaluationsRecursives = delta(nbreFeuillesMilieu)}
  inc(nbreFeuillesMilieu);
  adversaire := -coulEvaluation;
  listeDesCoupsTranquilles.cardinal := 0;
  listeDesCoupsTranquillesAdversaire.cardinal := 0;
  valeurAlphaBetaCoins := -32000;

  MemoryFillChar(@dejaEssayes,sizeof(dejaEssayes),chr(0));

  if utilisationNouvelleEval
    then
      begin
        evalPartielle := 0;


        {prises de coin}
			  MaxApresPriseCoin := MoinsInfini;
			  if avecRecursiviteDansEval then
			  for t := 1 to 4 do
					begin
					  x := othellier[t];
					  if jouable[x] then
					    begin
					      if PeutJouerIci(coulEvaluation,x,position) then   {minimax local}
					        begin

					          platRecur := position;
					          jouableRecur := jouable;
					          nbBlancsRecur := nbBlancs;
					          nbNoirsRecur := nbNoirs;
					          frontRecur := front;
					          legal := ModifPlat(x,coulEvaluation,platRecur,jouableRecur,nbBlancsRecur,nbNoirsRecur,frontRecur);

					          evalApresPriseCoin := -Evaluation(platRecur,adversaire,nbBlancsRecur,nbNoirsRecur,jouableRecur,frontRecur,
					                                            afraidOfWipeOut,-beta,-alpha,nbAppelsRecursifs);

					          (* WritelnNumDansRapport('evalApresPriseCoin = ',evalApresPriseCoin); *)

					          if evalApresPriseCoin > MaxApresPriseCoin then MaxApresPriseCoin := evalApresPriseCoin;

					          if (MaxApresPriseCoin >= beta) then
					            begin
					              Evaluation := MaxApresPriseCoin;
					              nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
					              exit(Evaluation);
					            end;

					          if (MaxApresPriseCoin > alpha) then alpha := MaxApresPriseCoin;
					        end;
					    end;
					  dejaEssayes[x] := true;
					end;
			  valeurAlphaBetaCoins := MaxApresPriseCoin;



        {appel de la nouvelle evaluation}

        case typeEvalEnCours of
         EVAL_CASSIO :
            begin
              if coulEvaluation = pionNoir
                then evalPartielle := NewEvalDeCassio(position,jouable,front,nbNoirs,nbBlancs,coulEvaluation,vecteurEvaluationInteger,listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire,alpha,beta)
                else evalPartielle := NewEvalDeCassio(position,jouable,front,nbNoirs,nbBlancs,coulEvaluation,vecteurEvaluationInteger,listeDesCoupsTranquillesAdversaire,listeDesCoupsTranquilles,alpha,beta);
            end;
          EVAL_EDMOND :
            begin
              if EvaluationEdmondEstDisponible
                then
                  begin
                    evalPartielle := EvaluationEdmond(position,front,nbNoirs,nbBlancs,coulEvaluation);
                  end
                else
                  begin

                    // Edmond non disponible : on se rabat sur l'eval de Cassio
                    typeEvalEnCours := EVAL_CASSIO;

                    if coulEvaluation = pionNoir
                      then evalPartielle := NewEvalDeCassio(position,jouable,front,nbNoirs,nbBlancs,coulEvaluation,vecteurEvaluationInteger,listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire,alpha,beta)
                      else evalPartielle := NewEvalDeCassio(position,jouable,front,nbNoirs,nbBlancs,coulEvaluation,vecteurEvaluationInteger,listeDesCoupsTranquillesAdversaire,listeDesCoupsTranquilles,alpha,beta);

                  end;
            end;
          EVAL_MIXTE_CASSIO_EDMOND :
            begin
              if coulEvaluation = pionNoir
                then evalPartielle := EvaluationMixteCassioEdmond(position,jouable,front,nbNoirs,nbBlancs,coulEvaluation,vecteurEvaluationInteger,listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire,alpha,beta)
                else evalPartielle := EvaluationMixteCassioEdmond(position,jouable,front,nbNoirs,nbBlancs,coulEvaluation,vecteurEvaluationInteger,listeDesCoupsTranquillesAdversaire,listeDesCoupsTranquilles,alpha,beta);
            end;

        end; {case}

      end
    else
      begin
			  if evaluationAleatoire
				  then
				    begin
				      ramdomPerturbation := Random;
				      if ramdomPerturbation >= 0
				        then evalPartielle := -penalitePourLeTrait + (ramdomPerturbation mod 200)
				        else evalPartielle := -penalitePourLeTrait - ((-ramdomPerturbation) mod 200);
				    end
				  else evalPartielle := -penalitePourLeTrait;

			  if (nbBlancs <= 3) & (nbNoirs > 13) & afraidOfWipeOut then
			    if (coulEvaluation = pionBlanc)
				  then evalPartielle := evalPartielle-5000
				  else evalPartielle := evalPartielle+5000;
			  if (nbNoirs <= 3) & (nbBlancs > 13) & afraidOfWipeOut then
				if (coulEvaluation = pionNoir)
				  then evalPartielle := evalPartielle-5000
				  else evalPartielle := evalPartielle+5000;

			 {prises et sacrifices de coin}
			  MaxApresPriseCoin := MoinsInfini;
			  for t := 1 to 4 do
				begin
				  x := othellier[t];
				  if jouable[x] then
				    begin
				      if PeutJouerIci(adversaire,x,position) then evalPartielle := evalPartielle-valDefenseCoin;
				      if PeutJouerIci(coulEvaluation,x,position) then   {minimax local}
				        begin
				          evalPartielle := evalPartielle+valPriseCoin;

				          platRecur := position;
				          jouableRecur := jouable;
				          nbBlancsRecur := nbBlancs;
				          nbNoirsRecur := nbNoirs;
				          frontRecur := front;
				          legal := ModifPlat(x,coulEvaluation,platRecur,jouableRecur,nbBlancsRecur,nbNoirsRecur,frontRecur);
				          evalApresPriseCoin := -Evaluation(platRecur,adversaire,nbBlancsRecur,nbNoirsRecur,jouableRecur,frontRecur,
				                                            afraidOfWipeOut,-beta,-alpha,nbAppelsRecursifs);
				          if evalApresPriseCoin > MaxApresPriseCoin then MaxApresPriseCoin := evalApresPriseCoin;

				          if (MaxApresPriseCoin >= beta) then
				            begin
				              Evaluation := MaxApresPriseCoin;
				              nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
				              exit(Evaluation);
				            end;

				          if (MaxApresPriseCoin > alpha) then alpha := MaxApresPriseCoin;
				        end;
				      dejaEssayes[x] := true;
				    end;
				end;
			  valeurAlphaBetaCoins := MaxApresPriseCoin;




			  petitcentre := valPionpetitcentre*(position[casepetitcentre1]+position[casepetitcentre2]+
			                                   position[casepetitcentre3]+position[casepetitcentre4]+
			                                   position[casepetitcentre5]+position[casepetitcentre6]+
			                                   position[casepetitcentre7]+position[casepetitcentre8]);
			  centre := valPionCentre*(position[Casecentre1]+position[Casecentre2]+
			                         position[Casecentre3]+position[Casecentre4]);
			  coins := valCoin*(position[88]+position[11]+position[18]+position[81]);

			  with front do
			   begin
			    if coulEvaluation = pionBlanc   {evaluation pour Blanc}
			      then
			        begin

			          evalPartielle := evalPartielle+NoteJeuCasesXPourBlanc(position,nbNoirs,nbBlancs);

			          if (position[11] = pionVide) & (position[18] = pionVide) & (position[81] = pionVide) & (position[88] = pionVide)
			            then evalPartielle := evalPartielle+valMinimisationAvantCoins*(nbBlancs-nbNoirs);
			            {else evalPartielle := evalPartielle+valMinimisationApresCoins*(nbBlancs-nbNoirs);}
			          evalPartielle := evalPartielle+centre;
			          evalPartielle := evalPartielle+petitcentre;
			          evalPartielle := evalPartielle+coins;

			          evalPartielle := evalPartielle-occupationTactique;
			          evalPartielle := evalPartielle+valeurBord^[AdressePattern[kAdresseBordSud]]+valeurBord^[AdressePattern[kAdresseBordOuest]]+valeurBord^[AdressePattern[kAdresseBordEst]]+valeurBord^[AdressePattern[kAdresseBordNord]];


			          evalPartielle := evalPartielle+TrousDeTroisNoirsHorribles(position);
			          evalPartielle := evalPartielle-TrousDeTroisBlancsHorribles(position);
			          evalPartielle := evalPartielle+LibertesBlanchesSurCasesA(position,front);
			          evalPartielle := evalPartielle-LibertesNoiresSurCasesA(position,front);
			          evalPartielle := evalPartielle+LibertesBlanchesSurCasesB(position);
			          evalPartielle := evalPartielle-LibertesNoiresSurCasesB(position);



			          evalPartielle := evalPartielle-BordDeSixNoirAvecPrebordHomogene(position,front);
			          evalPartielle := evalPartielle+BordDeSixBlancAvecPrebordHomogene(position,front);
			          evalPartielle := evalPartielle+ArnaqueSurBordDeCinqBlanc(position,front);
			          evalPartielle := evalPartielle-ArnaqueSurBordDeCinqNoir(position,front);


			          evalPartielle := evalPartielle+(4+((nbBlancs+nbNoirs) div 4))*ValeurBlocsDeCoinPourBlanc(position);


			          {evalPartielle := evalPartielle-NoteCasesCoinsCarreCentralPourNoir(position);}

			          {
			          evalPartielle := evalPartielle+TrousNoirsDeDeuxPerdantLaParite(position);
			          evalPartielle := evalPartielle-TrousBlancsDeDeuxPerdantLaParite(position);
			          }

			          {
			            begin
			              evalPartielle := evalPartielle+BonsBordsDeCinqBlancs(position,front);
			              evalPartielle := evalPartielle-BonsBordsDeCinqNoirs(position,front);
			              evalPartielle := evalPartielle+TrousNoirsDeDeuxPerdantLaParite(position);
			              evalPartielle := evalPartielle-TrousBlancsDeDeuxPerdantLaParite(position);
			              evalPartielle := evalPartielle+ValeurBlocsDeCoinPourBlanc(position);
			              evalPartielle := evalPartielle-NotationBordsOpposesPourNoir(position);
			            end;
			          }


			          {
			          if avecselectivite then
			            evalPartielle := evalPartielle + valBordDeCinqTransformable*nbBordDeCinqTransformablesPourBlanc(position,front);
			          }

			        end
			      else
			        begin       {evaluation pour Noir}

			          evalPartielle := evalPartielle+NoteJeuCasesXPourNoir(position,nbNoirs,nbBlancs);

			          if (position[11] = pionVide) & (position[18] = pionVide) & (position[81] = pionVide) & (position[88] = pionVide)
			            then evalPartielle := evalPartielle+valMinimisationAvantCoins*(nbNoirs-nbBlancs);
			            {else evalPartielle := evalPartielle+valMinimisationApresCoins*(nbNoirs-nbBlancs);}
			          evalPartielle := evalPartielle-centre;
			          evalPartielle := evalPartielle-petitcentre;
			          evalPartielle := evalPartielle-coins;

			          evalPartielle := evalPartielle+occupationTactique;
			          evalPartielle := evalPartielle+valeurBord^[-AdressePattern[kAdresseBordSud]]+valeurBord^[-AdressePattern[kAdresseBordOuest]]+valeurBord^[-AdressePattern[kAdresseBordEst]]+valeurBord^[-AdressePattern[kAdresseBordNord]];


			          evalPartielle := evalPartielle-TrousDeTroisNoirsHorribles(position);
			          evalPartielle := evalPartielle+TrousDeTroisBlancsHorribles(position);
			          evalPartielle := evalPartielle-LibertesBlanchesSurCasesA(position,front);
			          evalPartielle := evalPartielle+LibertesNoiresSurCasesA(position,front);
			          evalPartielle := evalPartielle-LibertesBlanchesSurCasesB(position);
			          evalPartielle := evalPartielle+LibertesNoiresSurCasesB(position);



			          evalPartielle := evalPartielle+BordDeSixNoirAvecPrebordHomogene(position,front);
			          evalPartielle := evalPartielle-BordDeSixBlancAvecPrebordHomogene(position,front);
			          evalPartielle := evalPartielle-ArnaqueSurBordDeCinqBlanc(position,front);
			          evalPartielle := evalPartielle+ArnaqueSurBordDeCinqNoir(position,front);

			          evalPartielle := evalPartielle+(4+((nbBlancs+nbNoirs) div 4))*ValeurBlocsDeCoinPourNoir(position);


			          {evalPartielle := evalPartielle+NoteCasesCoinsCarreCentralPourNoir(position);}

			         {
			          evalPartielle := evalPartielle-TrousNoirsDeDeuxPerdantLaParite(position);
			          evalPartielle := evalPartielle+TrousBlancsDeDeuxPerdantLaParite(position);
			          }

			          {
			            begin
			             evalPartielle := evalPartielle-BonsBordsDeCinqBlancs(position,front);
			             evalPartielle := evalPartielle+BonsBordsDeCinqNoirs(position,front);
			             evalPartielle := evalPartielle-TrousNoirsDeDeuxPerdantLaParite(position);
			             evalPartielle := evalPartielle+TrousBlancsDeDeuxPerdantLaParite(position);
			             evalPartielle := evalPartielle+ValeurBlocsDeCoinPourNoir(position);
			             evalPartielle := evalPartielle+NotationBordsOpposesPourNoir(position);
			             evalPartielle := evalPartielle+NoteCasesCoinsCarreCentralPourNoir(position);
			            end;
			          }

			          {
			          if avecselectivite then
			            evalPartielle := evalPartielle - valBordDeCinqTransformable*nbBordDeCinqTransformablesPourBlanc(position,front);
			          }
			        end;



			     evalFrontiere  := valFrontiere*(nbadjacent[adversaire]-nbadjacent[coulEvaluation]) +
			                         valEquivalentFrontiere*(nbfront[adversaire]-nbfront[coulEvaluation]);
			     evalPartielle := evalPartielle + evalFrontiere;




			     mobiliteCoulEvaluation := MobiliteSemiTranquilleAvecCasesC(coulEvaluation,position,jouable,front,listeDesCoupsTranquilles,100000);
			     mobiliteAdversaire     := MobiliteSemiTranquilleAvecCasesC(adversaire,position,jouable,front,listeDesCoupsTranquillesAdversaire,100000);
			     evalMobilite           := valMobiliteUnidirectionnelle*(mobiliteCoulEvaluation-mobiliteAdversaire);
			     evalPartielle          := evalPartielle + evalMobilite;


			     {grosse masse}
			     if (mobiliteCoulEvaluation <= seuilMobilitePourGrosseMasse) & (evalFrontiere >= 0) then
			       if CalculeMobilite(coulEvaluation,position,jouable) <= 5 then
			       begin
			         {EssaieSetPortWindowPlateau;
			         if (coulEvaluation = pionNoir)
			           then WriteStringAt('grosse masse de O (ennemie) ',10,125)
			           else WriteStringAt('grosse masse de X (ennemie) ',10,125);
			         WriteNumAt('evalPartielle avant = ',evalPartielle,10,135);}
			         evalPartielle := evalPartielle-valGrosseMasse;
			        {ecritPositionAt(position,10,10);
			         WriteNumAt('evalPartielle apres = ',evalPartielle,10,145);
			         AttendFrappeClavier;}
			       end;

			     evalFrontiereNonLineaire := 3*(nbadjacent[adversaire]*nbfront[adversaire] -
			                                   nbadjacent[coulEvaluation]*nbfront[coulEvaluation]);
			     if evalFrontiereNonLineaire >  700 then evalFrontiereNonLineaire := 700;
			     if evalFrontiereNonLineaire < -700 then evalFrontiereNonLineaire := -700;
			     evalPartielle := evalPartielle + evalFrontiereNonLineaire;


			     { evalPartielle := evalPartielle+
			                      +50*( nbLibertes(coulEvaluation,position,jouable)
			                            -nbLibertes(adversaire,position,jouable)); }

			    end;  { with front do }

			  { normalisation : ajoutee dans Cassio 7.0.9 }

			  evalPartielle := (evalPartielle * 90) div 128;   // en gros, on retourne evalPartielle * 0.7

			  if evalPartielle >  6400 then evalPartielle :=  6400;
			  if evalPartielle < -6400 then evalPartielle := -6400;
      end;




  if valeurAlphaBetaCoins > evalPartielle then evalPartielle := valeurAlphaBetaCoins;

  {
  if (MaxApresPriseCoin <> MoinsInfini) &
     (MaxApresPriseCoin < evalPartielle) then
    begin
      if MaxApresPriseCoin > (evalPartielle - valPriseCoin)
        then evalPartielle := MaxApresPriseCoin
        else evalPartielle := evalPartielle - valPriseCoin;
    end;
  }

  if (evalPartielle >= beta) then
    begin
      Evaluation := evalPartielle;
      nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
      exit(Evaluation);
    end;
  if (evalPartielle > alpha) then alpha := evalPartielle;

  if avecRecursiviteDansEval then
    begin

		  if (listeDesCoupsTranquilles.cardinal > 0) then
		    begin
				  valeurAlphaBetaCoupsTranquilles := AlphaBetaCoupsTranquillesDansEvaluation(position,coulEvaluation,nbBlancs,nbNoirs,jouable,front,afraidOfWipeOut,alpha,beta,listeDesCoupsTranquilles,dejaEssayes);

				  if (valeurAlphaBetaCoupsTranquilles >= beta) then
				    begin
				      Evaluation := valeurAlphaBetaCoupsTranquilles;
				      nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
				      exit(Evaluation);
				    end;
				  if (valeurAlphaBetaCoupsTranquilles > evalPartielle)
				    then evalPartielle := valeurAlphaBetaCoupsTranquilles;
		    end;

		  valeurAlphaBetaBordsCritiques := AlphaBetaLocalDansEvaluation(position,coulEvaluation,nbBlancs,nbNoirs,jouable,front,afraidOfWipeOut,alpha,beta,dejaEssayes);


		  if (valeurAlphaBetaBordsCritiques >= beta) then
		    begin
		      Evaluation := valeurAlphaBetaBordsCritiques;
		      nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
		      exit(Evaluation);
		    end;
		  if valeurAlphaBetaBordsCritiques > evalPartielle
		    then evalPartielle := valeurAlphaBetaBordsCritiques;

		end;

  (* WritelnNumDansRapport('avant fin normale, evalPartielle = ',evalPartielle); *)

  {fin normale}
  nbEvaluationsRecursives := nbreFeuillesMilieu-nbEvaluationsRecursives;
  Evaluation := evalPartielle;


end;




function CreeEvaluationCassioRec(var position : plateauOthello; coulEvaluation,nbBlancs,nbNoirs : SInt32;
                               var jouable : plBool; var front : InfoFront) : EvaluationCassioRec;
var t,x,adversaire,coins,centre,petitcentre,aux,mobiliteAmie,mobiliteEnnemie : SInt32;
    result : EvaluationCassioRec;
    listeDesCoupsTranquilles,listeDesCoupsTranquillesAdversaire : ListeDeCases;
begin


 with result do
   begin
     notePenalite := 0;
     noteBord := 0;
     noteCoin := 0;
     notePriseCoin := 0;
     noteDefenseCoin := 0;
     noteMinimisationAvant := 0;
     noteMinimisationApres := 0;
     noteCentre := 0;
     noteGrandCentre := 0;
     noteFrontiere := 0;
     noteEquivalentFrontiere := 0;
     noteMobilite := 0;
     noteCaseX := 0;
     noteCaseXEntreCasesC := 0;
     noteCaseXPlusCoin := 0;
     noteTrouCaseC := 0;
     noteOccupationTactique := 0;
     noteWipeOut := 0;
     noteAleatoire := 0;
     noteTrousDeTroisHorrible := 0;
     noteLiberteSurCaseA := 0;
     noteLiberteSurCaseB := 0;
     noteBonsBordsDeCinq := 0;
     noteTrousDeDeuxPerdantLaParite := 0;
     noteArnaqueSurBordDeCinq := 0;
     noteValeurBlocsDeCoin := 0;
     noteBordsOpposes := 0;
     noteBordDeCinqTransformable := 0;
     noteGameOver := 0;
     noteBordDeSixPlusQuatre := 0;
     noteGrosseMasse := 0;
     noteCaseXConsolidantBordDeSix := 0;
   end;


with result do
  begin
    if (nbBlancs = 0) then
			begin
			  if coulEvaluation = pionBlanc
				  then noteGameOver := -100*nbNoirs
				  else noteGameOver := 100*nbNoirs;
			end else
    if (nbNoirs = 0) then
	    begin
	      if coulEvaluation = pionBlanc
				  then noteGameOver := 100*nbBlancs
				  else noteGameOver := -100*nbBlancs;
			end
		 else
		  begin
        adversaire := -coulEvaluation;

		    notePenalite := -penalitePourLeTrait;

		    noteAleatoire := Random;
		    if (noteAleatoire > 0)
		      then noteAleatoire := noteAleatoire mod 200
		      else noteAleatoire := -((-noteAleatoire) mod 200);

			  if (nbBlancs <= 3) & (nbNoirs > 13) then
			    if (coulEvaluation = pionBlanc)
			      then noteWipeOut := -5000
			      else noteWipeOut := +5000;
			  if (nbNoirs <= 3) & (nbBlancs > 13) then
			    if (coulEvaluation = pionNoir)
			      then noteWipeOut := -5000
			      else noteWipeOut := +5000;

			  for t := 1 to 4 do
			    begin
			      x := othellier[t];
			      if jouable[x] then
			        begin
			          {prises et sacrifices de coin}
			          if PeutJouerIci(coulEvaluation,x,position) then
			              notePriseCoin := notePriseCoin+valPriseCoin;
			          if PeutJouerIci(adversaire,x,position) then
			              noteDefenseCoin := noteDefenseCoin-valDefenseCoin;
			        end;
			    end;

			  petitcentre := valPionpetitcentre*(position[casepetitcentre1]+position[casepetitcentre2]+
			                                   position[casepetitcentre3]+position[casepetitcentre4]+
			                                   position[casepetitcentre5]+position[casepetitcentre6]+
			                                   position[casepetitcentre7]+position[casepetitcentre8]);


			  centre := valPionCentre*(position[Casecentre1]+position[Casecentre2]+
			                         position[Casecentre3]+position[Casecentre4]);
			  coins := valCoin*(position[88]+position[11]+position[18]+position[81]);

			  with front do
			   begin
			    if coulEvaluation = pionBlanc
			      then
			        begin    {evaluation pour Blanc}
			          {cases X}
			          if (position[22] = pionNoir) then
			            case position[11] of
			              pionVide: if (position[12] <> pionVide) & (position[21] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			                                                                               else noteCaseX := noteCaseX+valCaseX;
			              pionNoir,pionBlanc:
			                begin
			                  aux := 0;
			                  if (position[12] <> pionVide) & (position[21] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[12] =  pionVide) & (position[13] =  pionNoir) & (position[23] =  pionNoir) then aux := aux+valTrouCaseC;
			                  if (position[21] =  pionVide) & (position[31] =  pionNoir) & (position[32] =  pionNoir) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[22] = pionBlanc) then
			            case position[11] of
			              pionVide: if (position[12] <> pionVide) & (position[21] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionNoir,pionBlanc:
			                begin
			                  aux := 0;
			                  if (position[12] <> pionVide) & (position[21] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[12] =  pionVide) & (position[13] =  pionBlanc) & (position[23] =  pionBlanc) then aux := aux-valTrouCaseC;
			                  if (position[21] =  pionVide) & (position[31] =  pionBlanc) & (position[32] =  pionBlanc) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[27] = pionNoir)  then
			            case position[18] of
			              pionVide: if (position[17] <> pionVide) & (position[28] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionNoir,pionBlanc:
			                begin
			                  aux := 0;
			                  if (position[17] <> pionVide) & (position[28] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[17] =  pionVide) & (position[16] =  pionNoir) & (position[26] =  pionNoir) then aux := aux+valTrouCaseC;
			                  if (position[28] =  pionVide) & (position[38] =  pionNoir) & (position[37] =  pionNoir) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[27] = pionBlanc) then
			            case position[18] of
			              pionVide: if (position[17] <> pionVide) & (position[28] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionNoir,pionBlanc:
			                begin
			                  aux := 0;
			                  if (position[17] <> pionVide) & (position[28] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[17] =  pionVide) & (position[16] =  pionBlanc) & (position[26] =  pionBlanc) then aux := aux-valTrouCaseC;
			                  if (position[28] =  pionVide) & (position[38] =  pionBlanc) & (position[37] =  pionBlanc) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[72] = pionNoir)  then
			            case position[81] of
			              pionVide: if (position[71] <> pionVide) & (position[82] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																															   else noteCaseX := noteCaseX+valCaseX;
			              pionNoir,pionBlanc:
			                begin
			                  aux := 0;
			                  if (position[71] <> pionVide) & (position[82] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[71] =  pionVide) & (position[61] =  pionNoir) & (position[62] =  pionNoir) then aux := aux+valTrouCaseC;
			                  if (position[82] =  pionVide) & (position[83] =  pionNoir) & (position[73] =  pionNoir) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[72] = pionBlanc) then
			            case position[81] of
			              pionVide: if (position[71] <> pionVide) & (position[82] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionNoir,pionBlanc:
			                begin
			                  aux := 0;
			                  if (position[71] <> pionVide) & (position[82] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[71] =  pionVide) & (position[61] =  pionBlanc) & (position[62] =  pionBlanc) then aux := aux-valTrouCaseC;
			                  if (position[82] =  pionVide) & (position[83] =  pionBlanc) & (position[73] =  pionBlanc) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[77] = pionNoir) then
			            case position[88] of
			              pionVide: if (position[78] <> pionVide) & (position[87] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionNoir,pionBlanc:
			                begin
			                  aux := 0;
			                  if (position[78] <> pionVide) & (position[87] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[78] =  pionVide) & (position[68] =  pionNoir) & (position[67] =  pionNoir) then aux := aux+valTrouCaseC;
			                  if (position[87] =  pionVide) & (position[86] =  pionNoir) & (position[76] =  pionNoir) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[77] = pionBlanc) then
			            case position[88] of
			              pionVide: if (position[78] <> pionVide) & (position[87] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionNoir,pionBlanc:
			                begin
			                  aux := 0;
			                  if (position[78] <> pionVide) & (position[87] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[78] =  pionVide) & (position[68] =  pionBlanc) & (position[67] =  pionBlanc) then aux := aux-valTrouCaseC;
			                  if (position[87] =  pionVide) & (position[86] =  pionBlanc) & (position[76] =  pionBlanc) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;

			          if (position[11] = pionVide) & (position[18] = pionVide) & (position[81] = pionVide) & (position[88] = pionVide)
			            then noteMinimisationAvant  := valMinimisationAvantCoins*(nbBlancs-nbNoirs)
			            else noteMinimisationApres  := valMinimisationApresCoins*(nbBlancs-nbNoirs);
			          noteCentre                    := centre;
			          noteGrandCentre               := petitcentre;
			          noteCoin                      := coins;
			          noteOccupationTactique        := -occupationTactique;
			          noteBord                      := valeurBord^[AdressePattern[kAdresseBordSud]]+valeurBord^[AdressePattern[kAdresseBordOuest]]+valeurBord^[AdressePattern[kAdresseBordEst]]+valeurBord^[AdressePattern[kAdresseBordNord]];
			          noteTrousDeTroisHorrible      := TrousDeTroisNoirsHorribles(position) - TrousDeTroisBlancsHorribles(position);
			          noteLiberteSurCaseA           := LibertesBlanchesSurCasesA(position,front) - LibertesNoiresSurCasesA(position,front);
			          noteLiberteSurCaseB           := LibertesBlanchesSurCasesB(position) - LibertesNoiresSurCasesB(position);
			          noteBonsBordsDeCinq           := BonsBordsDeCinqBlancs(position,front) - BonsBordsDeCinqNoirs(position,front);
			          noteTrousDeDeuxPerdantLaParite := TrousNoirsDeDeuxPerdantLaParite(position) - TrousBlancsDeDeuxPerdantLaParite(position);
			          noteArnaqueSurBordDeCinq      := ArnaqueSurBordDeCinqBlanc(position,front) - ArnaqueSurBordDeCinqNoir(position,front);
			          noteValeurBlocsDeCoin         := ValeurBlocsDeCoinPourBlanc(position);
			          noteBordsOpposes              := -NotationBordsOpposesPourNoir(position);
                noteBordDeCinqTransformable   := valBordDeCinqTransformable*nbBordDeCinqTransformablesPourBlanc(position,front);
			          noteBordDeSixPlusQuatre       := -BordDeSixNoirAvecPrebordHomogene(position,front)+BordDeSixBlancAvecPrebordHomogene(position,front);
			        end
			      else
			        begin     {evaluation pour Noir}
			          {cases X}
			          if (position[22] = pionBlanc) then
			            case position[11] of
			              pionVide: if (position[12] <> pionVide) & (position[21] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionBlanc,pionNoir:
			                begin
			                  aux := 0;
			                  if (position[12] <> pionVide) & (position[21] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[12] =  pionVide) & (position[13] =  pionBlanc) & (position[23] =  pionBlanc) then aux := aux+valTrouCaseC;
			                  if (position[21] =  pionVide) & (position[31] =  pionBlanc) & (position[32] =  pionBlanc) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[22] = pionNoir) then
			            case position[11] of
			              pionVide: if (position[12] <> pionVide) & (position[21] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionBlanc,pionNoir:
			                begin
			                  aux := 0;
			                  if (position[12] <> pionVide) & (position[21] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[12] =  pionVide) & (position[13] =  pionNoir) & (position[23] =  pionNoir) then aux := aux-valTrouCaseC;
			                  if (position[21] =  pionVide) & (position[31] =  pionNoir) & (position[32] =  pionNoir) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[27] = pionBlanc)  then
			            case position[18] of
			              pionVide: if (position[17] <> pionVide) & (position[28] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionBlanc,pionNoir:
			                begin
			                  aux := 0;
			                  if (position[17] <> pionVide) & (position[28] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[17] =  pionVide) & (position[16] =  pionBlanc) & (position[26] =  pionBlanc) then aux := aux+valTrouCaseC;
			                  if (position[28] =  pionVide) & (position[38] =  pionBlanc) & (position[37] =  pionBlanc) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[27] = pionNoir) then
			            case position[18] of
			              pionVide: if (position[17] <> pionVide) & (position[28] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionBlanc,pionNoir:
			                begin
			                  aux := 0;
			                  if (position[17] <> pionVide) & (position[28] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[17] =  pionVide) & (position[16] =  pionNoir) & (position[26] =  pionNoir) then aux := aux-valTrouCaseC;
			                  if (position[28] =  pionVide) & (position[38] =  pionNoir) & (position[37] =  pionNoir) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[72] = pionBlanc)  then
			            case position[81] of
			              pionVide: if (position[71] <> pionVide) & (position[82] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionBlanc,pionNoir:
			                begin
			                  aux := 0;
			                  if (position[71] <> pionVide) & (position[82] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[71] =  pionVide) & (position[61] =  pionBlanc) & (position[62] =  pionBlanc) then aux := aux+valTrouCaseC;
			                  if (position[82] =  pionVide) & (position[83] =  pionBlanc) & (position[73] =  pionBlanc) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[72] = pionNoir) then
			            case position[81] of
			              pionVide: if (position[71] <> pionVide) & (position[82] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionBlanc,pionNoir:
			                begin
			                  aux := 0;
			                  if (position[71] <> pionVide) & (position[82] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[71] =  pionVide) & (position[61] =  pionNoir) & (position[62] =  pionNoir) then aux := aux-valTrouCaseC;
			                  if (position[82] =  pionVide) & (position[83] =  pionNoir) & (position[73] =  pionNoir) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin) then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                                           else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;
			          if (position[77] = pionBlanc) then
			            case position[88] of
			              pionVide: if (position[78] <> pionVide) & (position[87] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC+valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX+valCaseX;
			              pionBlanc,pionNoir:
			                begin
			                  aux := 0;
			                  if (position[78] <> pionVide) & (position[87] <> pionVide) then aux := -valCaseXPlusCoin;
			                  if (position[78] =  pionVide) & (position[68] =  pionBlanc) & (position[67] =  pionBlanc) then aux := aux+valTrouCaseC;
			                  if (position[87] =  pionVide) & (position[86] =  pionBlanc) & (position[76] =  pionBlanc) then aux := aux+valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin)
			                                  then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                  else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX+valCaseX;
			                end;
			            end else
			          if (position[77] = pionNoir) then
			            case position[88] of
			              pionVide: if (position[78] <> pionVide) & (position[87] <> pionVide) then noteCaseXEntreCasesC := noteCaseXEntreCasesC-valCaseXEntreCasesC
			              																																 else noteCaseX := noteCaseX-valCaseX;
			              pionBlanc,pionNoir:
			                begin
			                  aux := 0;
			                  if (position[78] <> pionVide) & (position[87] <> pionVide) then aux := valCaseXPlusCoin;
			                  if (position[78] =  pionVide) & (position[68] =  pionNoir) & (position[67] =  pionNoir) then aux := aux-valTrouCaseC;
			                  if (position[87] =  pionVide) & (position[86] =  pionNoir) & (position[76] =  pionNoir) then aux := aux-valTrouCaseC;
			                  if aux <> 0 then
			                              begin
			                                if (aux = valCaseXPlusCoin) | (aux = -valCaseXPlusCoin)
			                                  then noteCaseXPlusCoin := noteCaseXPlusCoin+aux
			                                  else noteTrouCaseC := noteTrouCaseC+aux;
			                              end
			                            else noteCaseX := noteCaseX-valCaseX;
			                end;
			            end;

			          if (position[11] = pionVide) & (position[18] = pionVide) & (position[81] = pionVide) & (position[88] = pionVide)
			            then noteMinimisationAvant  := valMinimisationAvantCoins*(nbNoirs-nbBlancs)
			            else noteMinimisationApres  := valMinimisationApresCoins*(nbNoirs-nbBlancs);
			          noteCentre                    := -centre;
			          noteGrandCentre               := -petitcentre;
			          noteCoin                      := -coins;
			          noteOccupationTactique        := occupationTactique;
			          noteBord                      := valeurBord^[-AdressePattern[kAdresseBordSud]]+valeurBord^[-AdressePattern[kAdresseBordOuest]]+valeurBord^[-AdressePattern[kAdresseBordEst]]+valeurBord^[-AdressePattern[kAdresseBordNord]];
			          noteTrousDeTroisHorrible      := -TrousDeTroisNoirsHorribles(position) + TrousDeTroisBlancsHorribles(position);
			          noteLiberteSurCaseA           := -LibertesBlanchesSurCasesA(position,front) + LibertesNoiresSurCasesA(position,front);
			          noteLiberteSurCaseB           := -LibertesBlanchesSurCasesB(position) + LibertesNoiresSurCasesB(position);
			          noteBonsBordsDeCinq           := -BonsBordsDeCinqBlancs(position,front) + BonsBordsDeCinqNoirs(position,front);
			          noteTrousDeDeuxPerdantLaParite := -TrousNoirsDeDeuxPerdantLaParite(position) + TrousBlancsDeDeuxPerdantLaParite(position);
			          noteArnaqueSurBordDeCinq      := -ArnaqueSurBordDeCinqBlanc(position,front) + ArnaqueSurBordDeCinqNoir(position,front);
			          noteValeurBlocsDeCoin         := ValeurBlocsDeCoinPourNoir(position);
			          noteBordsOpposes              := NotationBordsOpposesPourNoir(position);
			          noteBordDeCinqTransformable   := -valBordDeCinqTransformable*nbBordDeCinqTransformablesPourBlanc(position,front);
			          noteBordDeSixPlusQuatre       := BordDeSixNoirAvecPrebordHomogene(position,front)-BordDeSixBlancAvecPrebordHomogene(position,front);

			        end;



			     noteFrontiere := valFrontiere*(nbadjacent[adversaire]-nbadjacent[coulEvaluation]);
			     noteEquivalentFrontiere := valEquivalentFrontiere*(nbfront[adversaire]-nbfront[coulEvaluation]);

			     mobiliteAmie    := MobiliteSemiTranquilleAvecCasesC(coulEvaluation,position,jouable,front,listeDesCoupsTranquilles,100000);
           mobiliteEnnemie := MobiliteSemiTranquilleAvecCasesC(adversaire,position,jouable,front,listeDesCoupsTranquillesAdversaire,100000);

			     noteMobilite := valMobiliteUnidirectionnelle*(mobiliteAmie-mobiliteEnnemie);


			      if (mobiliteAmie <= seuilMobilitePourGrosseMasse) & ((noteFrontiere+noteEquivalentFrontiere) >= 0) then
				       if CalculeMobilite(coulEvaluation,position,jouable) <= 5 then
				         noteGrosseMasse := -valGrosseMasse;
			    end;  { with front do }
		  end;
  end;  {with result do}

  CreeEvaluationCassioRec := result;
end;







function EvaluationMaximisation(var position : plateauOthello; coulEvaluation,nbBlancs,nbNoirs : SInt32) : SInt32;
var aux : SInt32;
begin
  {$UNUSED position}
  aux := 0;
  if coulEvaluation = pionBlanc
    then aux := aux + 50*(nbBlancs-nbNoirs)
    else aux := aux + 50*(nbNoirs-nbBlancs);
  EvaluationMaximisation := aux;
end;


function EvaluationDesBords(var position : plateauOthello; coulEvaluation : SInt32; var front : InfoFront) : SInt32;
var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;
    numeroDuCoup,theStage,aux : SInt32;
begin {$UNUSED position,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst,numeroDuCoup,theStage}
  aux := 0;
  with front do
  if coulEvaluation = pionBlanc
    then aux := aux + valeurBord^[AdressePattern[kAdresseBordSud]]+valeurBord^[AdressePattern[kAdresseBordOuest]]+valeurBord^[AdressePattern[kAdresseBordEst]]+valeurBord^[AdressePattern[kAdresseBordNord]]
    else aux := aux + valeurBord^[-AdressePattern[kAdresseBordSud]]+valeurBord^[-AdressePattern[kAdresseBordOuest]]+valeurBord^[-AdressePattern[kAdresseBordEst]]+valeurBord^[-AdressePattern[kAdresseBordNord]];
  EvaluationDesBords := aux;
end;



function EvaluationHorsContexte(var whichPos : PositionEtTraitRec) : SInt32;
var nbBlancs,nbNoirs : SInt32;
    jouables : plBool;
    frontiere : InfoFront;
    nbRecursives : SInt32;
begin
  with whichPos do
    begin
      nbBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,position);
      nbNoirs := NbPionsDeCetteCouleurDansPosition(pionNoir,position);
      CarteJouable(position,jouables);
      CarteFrontiere(position,frontiere);
      EvaluationHorsContexte := Evaluation(position,GetTraitOfPosition(whichPos),nbBlancs,nbNoirs,jouables,frontiere,false,-30000,30000,nbRecursives);
    end;
end;


function FindInHistoryOfEvaluationHorsContexte(key, prof : SInt32; var note, bestMove : SInt32) : boolean;
var k, index : SInt32;
begin
  FindInHistoryOfEvaluationHorsContexte := false;

  for k := 0 to ((kTailleCacheDesEvaluationsHorsContexte div 2) + 1) do
    begin

      { un coup en montant... }

      index := glastUsedIndexinSearch + k;
      if index >= kTailleCacheDesEvaluationsHorsContexte then index := index - kTailleCacheDesEvaluationsHorsContexte;
      if index < 0                                       then index := index + kTailleCacheDesEvaluationsHorsContexte;

      with gCacheDesEvaluationsHorsContexte[index] do
        if (whichHashKey = key) & (whichProf = prof) then
          begin
            glastUsedIndexinSearch := index;
            FindInHistoryOfEvaluationHorsContexte := true;
            note     := whichNote;
            bestMove := whichMove;
            exit(FindInHistoryOfEvaluationHorsContexte);
          end;

      { un coup en descendant... }

      index := glastUsedIndexinSearch - k - 1;
      if index >= kTailleCacheDesEvaluationsHorsContexte then index := index - kTailleCacheDesEvaluationsHorsContexte;
      if index < 0                                       then index := index + kTailleCacheDesEvaluationsHorsContexte;

      with gCacheDesEvaluationsHorsContexte[index] do
        if (whichHashKey = key) & (whichProf = prof) then
          begin
            glastUsedIndexinSearch := index;
            FindInHistoryOfEvaluationHorsContexte := true;
            note     := whichNote;
            bestMove := whichMove;
            exit(FindInHistoryOfEvaluationHorsContexte);
          end;

    end;
end;


procedure StoreInHistoryOfEvaluationHorsContexte(key, prof, note, coup : SInt32);
begin
  glastUsedIndexinSearch := gIndexCourantDansCacheDesEvaluationsHorsContexte;

  with gCacheDesEvaluationsHorsContexte[gIndexCourantDansCacheDesEvaluationsHorsContexte] do
    begin
      whichHashKey   := key;
      whichProf      := prof;
      whichNote      := note;
      whichMove      := coup;
    end;

  inc(gIndexCourantDansCacheDesEvaluationsHorsContexte);
  if gIndexCourantDansCacheDesEvaluationsHorsContexte >= kTailleCacheDesEvaluationsHorsContexte
    then gIndexCourantDansCacheDesEvaluationsHorsContexte := 0;
end;


function EvaluationHorsContexteACetteProfondeur(var whichPos : PositionEtTraitRec; prof : SInt32; var meilleurCoup : SInt32; withCheckEvents : boolean) : SInt32;
var nbBlancs,nbNoirs : SInt32;
    jouables : plBool;
    frontiere : InfoFront;
    trait : SInt32;
    note,nbEvalsRecursives : SInt32;
    oldInterruption : SInt16;
    tempoUtilisationNouvelleEval : boolean;
    tempoDiscretisation : boolean;
    tempoCassioChecksEvents : boolean;
    tempoDiscretisationEstOK : boolean;
    oldCheckDangerousEvents : boolean;
    tempoTypeEvalEnCours : EvalsDisponibles;
    tempoDelaiAvantDoSystemTask : SInt32;
    hash : SInt32;
begin

  trait := GetTraitOfPosition(whichPos);
  hash  := GenericHash(@whichPos,sizeof(PositionEtTraitRec)) xor GenericHash(@prof, sizeof(SInt32));

  if FindInHistoryOfEvaluationHorsContexte(hash, prof, note, meilleurCoup) then
    begin
      // WritelnPositionEtTraitDansRapport(whichPos.position,GetTraitOfPosition(whichPos));
      // WritelnNumDansRapport('BINGO a prof = ',prof);
      EvaluationHorsContexteACetteProfondeur := note;
      exit(EvaluationHorsContexteACetteProfondeur);
    end;

  with whichPos do
    begin

      nbBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,position);
      nbNoirs := NbPionsDeCetteCouleurDansPosition(pionNoir,position);

      Calcule_Valeurs_Tactiques(position,true);
      CarteFrontiere(position,frontiere);
      CarteJouable(position,jouables);

      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);


      // on ne veut pas se faire interrompre pendant l'evaluation

      oldInterruption := GetCurrentInterruption;
      EnleveCetteInterruption(oldInterruption);


      // sauvegarde des reglages generaux

      tempoUtilisationNouvelleEval := utilisationNouvelleEval;
      tempoTypeEvalEnCours         := typeEvalEnCours;
      tempoDiscretisation          := utilisateurVeutDiscretiserEvaluation;
      tempoDiscretisationEstOK     := discretisationEvaluationEstOK;
      tempoCassioChecksEvents      := gCassioChecksEvents;
      tempoDelaiAvantDoSystemTask  := delaiAvantDoSystemTask;


      // modifions temporairement les reglages generaux pour evaluer rapidement cette position

      utilisationNouvelleEval              := true;
      utilisateurVeutDiscretiserEvaluation := false;
      discretisationEvaluationEstOK        := false;
      typeEvalEnCours                      := EVAL_EDMOND;


      // desactiver, si l'utilisateur le demande, l'ecoute des evenements

      if not(withCheckEvents) then
        begin
          gCassioChecksEvents                  := false;
          delaiAvantDoSystemTask               := 100000000;
          SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);
          if (prof >= 5) then
            WritelnNumDansRapport('WARNING : calling EvaluationHorsContexteACetteProfondeur without checking events at quite a large depth !! depth = ',prof);
        end;

      // on ne connait pas encore le meilleur coup

      meilleurCoup := -1;

      // on evalue, hein !
      if (prof < 0)
        then note :=  Evaluation(position,trait,nbBlancs,nbNoirs,jouables,frontiere,true,-30000,30000,nbEvalsRecursives)
        else note :=  AB_simple(position,jouables, meilleurCoup, trait, prof, -30000, 30000, nbBlancs, nbNoirs, frontiere, true);


      // on remet les reglages generaux

      utilisationNouvelleEval               := tempoUtilisationNouvelleEval;
      typeEvalEnCours                       := tempoTypeEvalEnCours;
      utilisateurVeutDiscretiserEvaluation  := tempoDiscretisation;
      discretisationEvaluationEstOK         := tempoDiscretisationEstOK;


      // remettre l'ecoute des evenements

      gCassioChecksEvents                   := tempoCassioChecksEvents;
      delaiAvantDoSystemTask                := tempoDelaiAvantDoSystemTask;
      SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);


      // on remet les interruptions

      LanceInterruption(oldInterruption,'ValeurEvaluationDeCassioPourNoirDeLaPartie');


      // on stocke le calcul dans le petit hash local (memoisation)

      StoreInHistoryOfEvaluationHorsContexte(hash, prof, note, meilleurCoup);


      // on renvoie les deux resultats

      EvaluationHorsContexteACetteProfondeur := note;


    end;
end;


function GetListeTrieeDesCoupsACetteProfondeurHorsContexte(var whichPos : PositionEtTraitRec; prof : SInt32; var liste : ListOfMoveRecords; withCheckEvents : boolean) : SInt32;
var square, t, k, nbFilsTrouves, defense, note : SInt32;
    platAux : PositionEtTraitRec;
    temp : MoveRecord;
begin

  platAux := whichPos;
  nbFilsTrouves := 0;

  for t := 1 to 64 do
    begin
      liste[t].notePourLeTri := -100000;
      liste[t].x             := 0;
      liste[t].theDefense    := 0;
    end;

  for t := 1 to 64 do
    begin
      square := othellier[t];
      if UpdatePositionEtTrait(platAux, square) then
        begin
          inc(nbFilsTrouves);

          note := -EvaluationHorsContexteACetteProfondeur(platAux, prof - 1, defense, withCheckEvents);

          liste[nbFilsTrouves].x             := square;
          liste[nbFilsTrouves].theDefense    := defense;
          liste[nbFilsTrouves].notePourLeTri := note;

          (*
          WritelnStringAndCoupDansRapport('square = ',square);
          WritelnNumDansRapport('note = ',note);
          *)

          {tri par insertion}
		      for k := nbFilsTrouves downto 2 do
		        if (liste[k].notePourLeTri > liste[k-1].notePourLeTri) then
		          begin
		            temp := liste[k-1];
		            liste[k-1] := liste[k];
		            liste[k] := temp;
		          end;

          platAux := whichPos;
        end;
    end;

  (*
  for k := 1 to nbFilsTrouves do
    begin
      WritelnStringAndCoupDansRapport('square = ',liste[k].x);
      WritelnNumDansRapport('note = ',liste[k].notePourLeTri);
    end;
  *)

  GetListeTrieeDesCoupsACetteProfondeurHorsContexte := nbFilsTrouves;
end;




END.
