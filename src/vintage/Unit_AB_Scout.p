UNIT Unit_AB_Scout;

INTERFACE







 USES UnitDefCassio;

{ Initialisation de l'unité }
procedure InitUnit_AB_Scout;
procedure LibereMemoireUnit_AB_SCout;


{ La fonction principale de l'unite, qui lance une rechreche alpha-beta }
function ABScout(var pl : plateauOthello; var joua : plBool; var bstDef : SInt32; pere,coul,prof,profMaximum,horizon,longPath,distPV,couleurDeCassio,alpha,beta,nbBlancs,nbNoirs : SInt32; var fr : InfoFront; var conseilTurbulence : SInt32; canDoProbCut : boolean) : SInt32;


{ Fonction utilitaire }
function PlusGrandeProfondeurAvecProbCut : SInt32;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, Sound, OSUtils
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitSuperviseur, UnitEvaluation, UnitHashTableExacte, UnitMiniProfiler
    , UnitPositionEtTrait, UnitServicesMemoire, UnitBitboardAlphaBeta, UnitUtilitaires, UnitOth2, UnitTraceLog, UnitStrategie, UnitRapport
    , UnitScannerUtils, MyStrings, UnitFenetres, UnitGestionDuTemps, MyMathUtils, SNEvents, UnitAffichagePlateau, UnitPositionEtTrait
    , UnitEngine ;
{$ELSEC}
    ;
    {$I prelink/_AB_Scout.lk}
{$ENDC}


{END_USE_CLAUSE}







{$IFC DEFINED __GPC__}
  procedure flush_standard_output; external name('flush_standard_output');
{$ENDC}





CONST kNOT_EVALUATED = -100000;

var compteur_tentative_ProbCut : SInt32;
		compteur_echec_ProbCut : SInt32;



function PlusGrandeProfondeurAvecProbCut : SInt32;
begin
  PlusGrandeProfondeurAvecProbCut := 22;
end;



procedure VerifieAssertionABScout(condition : boolean; const s : String255);
begin
  if not(condition) then
    begin
      WritelnDansRapport('ASSERT dans ABScout : ' + s);
      AttendFrappeClavier;
    end;
end;




function ABScout(var pl : plateauOthello; var joua : plBool; var bstDef : SInt32;
                  pere,coul,prof,profMaximum,horizon,longPath,distPV,couleurDeCassio,alpha,beta,nbBlancs,nbNoirs : SInt32; var fr : InfoFront; var conseilTurbulence : SInt32; canDoProbCut : boolean) : SInt32;
const kEMPTIES_FOR_PV_EXTENSION = 15;
var platEssai : plateauOthello;
    jouablEssai : plBool;
    nbBlcEssai,nbNrEssai : SInt32;
    nbNoirs2,nbBlancs2 : SInt32;
    nbCasesVidesRestantes : SInt32;
    nroDuCoup : SInt32;
    largeur1,largeur2,largeur3 : SInt32;
    frontEssai : InfoFront;
    ii,k,t_counter : SInt32;
    profMoins1,longPathPlus1 : SInt32;
    notecourante : SInt32;
    seuilProbCutAlpha,seuilProbCutBeta : SInt32;
    maxPourBestDef,BestSuite : SInt32;
    aJoue,evaluerMaintenant : boolean;
    iCourant,adversaire : SInt32;
    conseilTurbulencePourLeFils : SInt32;
    dejaEvalue : plBool;
    nbEvalues : SInt32;
    clefHashConseil,conseilHash : SInt32;
    bonusPourLeConseilHash : SInt32;
    valeurExacteMax,valeurExacteMin : SInt16;
    clefHashExacte,nroTableExacte : SInt32;
    CodePosition : record
                   platLigne1,platLigne2,platLigne3,platLigne4 : SInt32;
                   platLigne5,platLigne6,platLigne7,platLigne8 : SInt32;
                 end;
    QuelleHashTableExacte : HashTableExactePtr;
    nbCoupsLegaux : SInt32;
    nbCoupsLegauxTriesRestantAEvaluer : SInt32;
    clefMaxDansGenerationCoupsLegaux : SInt32;
    CoupsLegauxTries : array[0..32] of record
                                        note,coup,clefDeTri : SInt32;
                                     end;
    indicePourGenerationCoups,nbCoupsAManger : SInt32;
    tousLesCoupsLegauxGeneres : boolean;
    nbEvalsRecursives : SInt32;
    alphaArrivee,betaArrivee : SInt32;
    augmentation_selectivite : SInt32;
    utilise_hash_table : boolean;
    conseil_dans_hash_table : boolean;
    utilise_hash_table_exacte : boolean;
    debugABScout : boolean;
    debugPosition : PositionEtTraitRec;
    {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    useMicroProfiler : boolean;
    microSecondesCurrent,microSecondesDepart : UnsignedWide;
    {$ENDC}
    {magicCookieABSCout : SInt32;}
label sortie;


 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
  procedure BeginMiniprofilerMilieu;
  begin
    Microseconds(microSecondesDepart);
	end;

  procedure EndMiniprofilerMilieu;
  begin
    Microseconds(microSecondesCurrent);
	  AjouterTempsDansMiniProfiler(60-nroDuCoup,prof,microSecondesCurrent.lo-microSecondesDepart.lo,ktempsMoyen);
	end;
 {$ENDC}


  procedure PreparerTriDesCoups;
  begin
    indicePourGenerationCoups := 0;
    nbCoupsLegauxTriesRestantAEvaluer := 0;
    nbCoupsLegaux := 0;
    tousLesCoupsLegauxGeneres := false;
  end;

  procedure GenererEtTrierDesCoupsLegaux;
  var platTri : plateauOthello;
      jouablTri : plBool;
      nbBlcTri,nbNrTri : SInt32;
      bestSuiteTri : SInt32;
      caseTurbulentePourFils : SInt32;
      frontTri : InfoFront;
      k,j,iCourantTri,eval,clef : SInt32;
      nbCoupsApresElagage : SInt32;
      nbAppelsRecursifsTri : SInt32;
      alpha_fenetre_tri,beta_fenetre_tri : SInt32;
      nbExtensions : SInt32;
      seuil_sortie : SInt32;
      trierLentement : boolean;
      tempoEvalRecursives : boolean;
      tempoDebrancherRecursivite : boolean;
      sortieAccelereeDuTriCarSansDouteCoupureBeta : boolean;
      faireElagageAPriori : boolean;
      casesDejaEvaluees : plBool;


    procedure GenererCasUn;
    begin

       eval := -ABScout(platTri,jouablTri,bestSuiteTri,iCourantTri,adversaire,2,profMaximum,horizon,1000,-1000000,
                        couleurDeCassio,-beta_fenetre_tri,-alpha_fenetre_tri,nbBlcTri,nbNrTri,frontTri,caseTurbulentePourFils,false);
    end;

    procedure GegererCasDeux;
    begin

      eval := -ABScout(platTri,jouablTri,bestSuiteTri,iCourantTri,adversaire,1,profMaximum,horizon,1000,-1000000,
                       couleurDeCassio,-beta_fenetre_tri,-alpha_fenetre_tri,nbBlcTri,nbNrTri,frontTri,caseTurbulentePourFils,false);
    end;


    procedure GenererCasTrois;
    begin

      eval := -Evaluation(platTri,adversaire,nbBlcTri,nbNrTri,jouablTri,frontTri,true,-beta_fenetre_tri,-alpha_fenetre_tri,nbAppelsRecursifsTri);



    end;


  begin
    trierLentement := ((prof >= profMaximum-1) and (profMaximum >= 6)) or
                      ((prof >= 4) and (adversaire = -couleurDeCassio)) or
                      ((prof >= 5));

    nbExtensions := 0;
    nbCoupsApresElagage := 0;

    alpha_fenetre_tri  := -30000;
    beta_fenetre_tri   :=  30000;
    if (beta  <  20000) then beta_fenetre_tri  := beta  + 700;
    if (alpha > -20000) then alpha_fenetre_tri := alpha - 700;


    platTri := pl;
    jouablTri := joua;
    nbBlcTri := nbBlancs;
    nbNrTri := nbNoirs;
    frontTri := fr;
    repeat
      inc(indicePourGenerationCoups);
      iCourantTri := othellier[indicePourGenerationCoups];

      (*** pour debugage seulement ***)
      {if (iCourantTri < 11) or (icourantTri > 88) then debugger;}

      if joua[iCourantTri] then
          if ModifPlat(iCourantTri,coul,platTri,jouablTri,nbBlcTri,nbNrTri,frontTri) then
            begin
              inc(nbCoupsLegaux);
              inc(nbCoupsLegauxTriesRestantAEvaluer);


              if trierLentement
                then
                  begin
                    caseTurbulentePourFils := -1;
                    if ((prof >= profMaximum-1) and (prof >= 9))
                      then
                        begin
                          tempoDebrancherRecursivite := peutDebrancherRecursiviteDansEval;
                          peutDebrancherRecursiviteDansEval := false;
                          GenererCasUn;
                          peutDebrancherRecursiviteDansEval := tempoDebrancherRecursivite;
                        end
                      else
                        begin
                          GegererCasDeux;
                        end;
                  end
                else
                  begin
                    tempoEvalRecursives := avecRecursiviteDansEval;
			              { si on n'est pas sur la branche principale, on peut
			                essayer de debrancher la recursivite dans l'eval.
			                Note : desactivé dans Cassio 5.5 }
			              if FALSE and peutDebrancherRecursiviteDansEval and not(canDoProbCut) then
			                avecRecursiviteDansEval := false;
			              GenererCasTrois;
			              avecRecursiviteDansEval := tempoEvalRecursives;
                  end;


              {un bonus pour le conseil de la table de hachage}
              if (iCourantTri = conseilHash) then eval := eval + bonusPourLeConseilHash;


              clef := eval;
              if (clef >= clefMaxDansGenerationCoupsLegaux) then clefMaxDansGenerationCoupsLegaux := clef;

              {insertion dans la liste CoupsLegauxTries, classée par note décroissante}
              k := 1;
              while (k < nbCoupsLegauxTriesRestantAEvaluer) and (clef <= CoupsLegauxTries[k].clefDeTri) do k := k+1;


              for j := nbCoupsLegauxTriesRestantAEvaluer downto succ(k) do
                CoupsLegauxTries[j].clefDeTri := CoupsLegauxTries[j-1].clefDeTri;
              for j := nbCoupsLegauxTriesRestantAEvaluer downto succ(k) do
                CoupsLegauxTries[j].note := CoupsLegauxTries[j-1].note;
              for j := nbCoupsLegauxTriesRestantAEvaluer downto succ(k) do
                CoupsLegauxTries[j].coup := CoupsLegauxTries[j-1].coup;


              CoupsLegauxTries[k].clefDeTri := clef;
              CoupsLegauxTries[k].note := eval;
              CoupsLegauxTries[k].coup := iCourantTri;

              (*** pour debugage seulement ***)
              { if (iCourantTri < 11) or (icourantTri > 88) then debugger; }

              (*
              {if (prof >= profMinimalePourTriDesCoupsParAlphaBeta)}
              probleme := false;
              for k := 1 to nbCoupsLegauxTriesRestantAEvaluer do
                if (CoupsLegauxTries[k].coup < 11) then probleme := true else
                if (CoupsLegauxTries[k].coup > 88) then probleme := true else
                if (pl[CoupsLegauxTries[k].coup] <> pionVide) then probleme := true;

              if probleme then
                 begin
                   EssaieSetPortWindowPlateau;
					         EcritPlatBoolAt(SquareSetToPlatBool(dejaEvalue),120,10);
					         if tousLesCoupsLegauxGeneres
					           then WriteStringAt('TousLesCoupsGeneres = TRUE ',10,120)
					           else WriteStringAt('TousLesCoupsGeneres = FALSE',10,120);
					         WriteNumAt('nbCoupsRestantAEvaluer = ',nbCoupsLegauxTriesRestantAEvaluer,10,140);
					         WriteNumAt('nbCoupsApresElagage = ',nbCoupsApresElagage,150,140);
					         WriteNumAt('nbExtensions = ',nbExtensions,290,140);
					         if conseilHash = 0
					           then WriteStringAt('ConseilHash =  ??      ',10,130)
					           else WriteStringAt('ConseilHash = '+CoupEnStringEnMajuscules(conseilHash)+'      ',10,130);
					         WriteNumAt(' prof = ',prof,100,130);
					         WriteNumAt(' profMax = ',profMaximum,140,130);
					         if coul = pionBlanc
					           then WriteStringAt('pionBlanc  ',210,130)
					           else WriteStringAt('pionNoir    ',210,130);
					         WriteNumAt(' nbVides = ',NbCasesVidesDansPosition(pl),290,130);
					         WriteNumAt('alpha = ',alpha,10,150);
					         WriteNumAt('beta = ',beta,100,150);
					         WriteNumAt('alpha_fenetre_tri = ',alpha_fenetre_tri,10,160);
					         WriteNumAt('beta_fenetre_tri = ' ,beta_fenetre_tri,140,160);
					         WriteNumAt('clef = ' ,clef,270,160);

					         for k := 1 to nbCoupsLegauxTriesRestantAEvaluer do
					           begin
					             WriteStringAt(NumEnString(k)+')  '+CoupEnStringEnMajuscules(CoupsLegauxTries[k].coup),10,170+k*10);
					             WriteNumAt('note = ',CoupsLegauxTries[k].note,70,170+k*10);
					             WriteNumAt('clÈ = ',CoupsLegauxTries[k].clefDeTri,150,170+k*10);
					           end;
					         for k := nbCoupsLegauxTriesRestantAEvaluer+1 to nbCoupsLegauxTriesRestantAEvaluer+5 do
					           WriteStringAt('                                                                                 ',10,170+k*10);
                   AttendFrappeClavier;
                   EcranStandard(NIL,false);
                 end;
                 *)

              platTri := pl;
              jouablTri := joua;
              nbBlcTri := nbBlancs;
              nbNrTri := nbNoirs;
              frontTri := fr;
            end;

      tousLesCoupsLegauxGeneres := (indicePourGenerationCoups >= 64);




      seuil_sortie := 500;
      sortieAccelereeDuTriCarSansDouteCoupureBeta := (nbCoupsLegauxTriesRestantAEvaluer >= 1) and (prof <= 5) and
                                                     (CoupsLegauxTries[1].note >= (beta + seuil_sortie));


      (*
      probleme := false;
      for k := 1 to nbCoupsLegauxTriesRestantAEvaluer do
        if (CoupsLegauxTries[k].coup < 11) then probleme := true else
        if (CoupsLegauxTries[k].coup > 88) then probleme := true else
        if (pl[CoupsLegauxTries[k].coup] <> pionVide) then probleme := true; *)


      (*
      if tousLesCoupsLegauxGeneres  or sortieAccelereeDuTriCarSansDouteCoupureBeta {or probleme} then
       begin
         SysBeep(0);
         EssaieSetPortWindowPlateau;
         EcritPositionAt(pl,10,10);
         EcritPlatBoolAt(SquareSetToPlatBool(dejaEvalue),120,10);
         if tousLesCoupsLegauxGeneres
           then WriteStringAt('TousLesCoupsGeneres = TRUE ',10,120)
           else WriteStringAt('TousLesCoupsGeneres = FALSE',10,120);
         WriteNumAt('nbCoupsRestantAEvaluer = ',nbCoupsLegauxTriesRestantAEvaluer,10,140);
         WriteNumAt('nbCoupsApresElagage = ',nbCoupsApresElagage,150,140);
         WriteNumAt('nbExtensions = ',nbExtensions,290,140);
         if conseilHash = 0
           then WriteStringAt('ConseilHash =  ??      ',10,130)
           else WriteStringAt('ConseilHash = '+CoupEnStringEnMajuscules(conseilHash)+'      ',10,130);
         WriteNumAt(' prof = ',prof,100,130);
         WriteNumAt(' profMax = ',profMaximum,140,130);
         if coul = pionBlanc
           then WriteStringAt('pionBlanc  ',210,130)
           else WriteStringAt('pionNoir    ',210,130);
         WriteNumAt(' nbVides = ',NbCasesVidesDansPosition(pl),290,130);
         WriteNumAt('alpha = ',alpha,10,150);
         WriteNumAt('beta = ',beta,100,150);
         WriteNumAt('alpha_fenetre_tri = ',alpha_fenetre_tri,10,160);
         WriteNumAt('beta_fenetre_tri = ' ,beta_fenetre_tri,140,160);
         WriteNumAt('clef = ' ,clef,270,160);

         for k := 1 to nbCoupsLegauxTriesRestantAEvaluer do
           begin
             WriteStringAt(NumEnString(k)+')  '+CoupEnStringEnMajuscules(CoupsLegauxTries[k].coup),10,170+k*10);
             WriteNumAt('note = ',CoupsLegauxTries[k].note,70,170+k*10);
             WriteNumAt('clé = ',CoupsLegauxTries[k].clefDeTri,150,170+k*10);
           end;
         for k := nbCoupsLegauxTriesRestantAEvaluer+1 to nbCoupsLegauxTriesRestantAEvaluer+5 do
           WriteStringAt('                                                                                 ',10,170+k*10);
         AttendFrappeClavier;
         EcranStandard(NIL,false);
       end;
     *)

    until tousLesCoupsLegauxGeneres or sortieAccelereeDuTriCarSansDouteCoupureBeta;



    nroDuCoup := nbBlancs + nbNoirs - 4;
    faireElagageAPriori := tousLesCoupsLegauxGeneres and (prof >= 3) and (nbCoupsLegauxTriesRestantAEvaluer > 1);


    if faireElagageAPriori then
      begin

        nbCoupsApresElagage := nbCoupsLegaux div 2 ;
			  nbCoupsApresElagage := Max(7,nbCoupsApresElagage);

        (*
        if effetspecial then nbCoupsApresElagage := Max(17,nbCoupsApresElagage);
        *)

        if ( nbCoupsApresElagage < nbCoupsLegauxTriesRestantAEvaluer ) then
           begin

             clef := clefMaxDansGenerationCoupsLegaux;


             {on compare les notes des coups elagues avec celle du coup en tete
              pour ne pas elaguer *a priori* des coups trop proches}

             nbExtensions := 0;
             while ( nbCoupsApresElagage < nbCoupsLegauxTriesRestantAEvaluer ) and
                   ( alpha_fenetre_tri <= clef) and ( clef <= beta_fenetre_tri) and
                   ( alpha_fenetre_tri <= CoupsLegauxTries[nbCoupsApresElagage+1].clefDeTri) and
                   ( CoupsLegauxTries[nbCoupsApresElagage+1].clefDeTri <= beta_fenetre_tri) and
                   ( Abs(CoupsLegauxTries[nbCoupsApresElagage+1].clefDeTri - clef) <= 750)  do
               begin
                 inc(nbCoupsApresElagage);
                 inc(nbExtensions);
               end;



             {effetspecial2 := ( CoupsLegauxTries[1].note +700 <= alpha);}
             {effetspecial2 := true;}

             if effetspecial2 and (nbExtensions > 0) then
               begin
	             EssaieSetPortWindowPlateau;
	             EcritPositionAt(pl,10,10);

	             casesDejaEvaluees := dejaEvalue;

	             EcritPlatBoolAt(casesDejaEvaluees,120,10);
	             if tousLesCoupsLegauxGeneres
			           then WriteStringAt('TousLesCoupsGeneres = TRUE ',10,120)
			           else WriteStringAt('TousLesCoupsGeneres = FALSE',10,120);
			         WriteNumAt('nbCoupsRestantAEvaluer = ',nbCoupsLegauxTriesRestantAEvaluer,10,140);
			         WriteNumAt('nbCoupsApresElagage = ',nbCoupsApresElagage,150,140);
			         WriteNumAt('nbExtensions = ',nbExtensions,290,140);
			         if conseilHash = 0
			           then WriteStringAt('ConseilHash =  ??      ',10,130)
			           else WriteStringAt('ConseilHash = '+CoupEnStringEnMajuscules(conseilHash)+'      ',10,130);
			         WriteNumAt(' prof = ',prof,100,130);
			         WriteNumAt(' profMax = ',profMaximum,140,130);
			         if coul = pionBlanc
			           then WriteStringAt('pionBlanc  ',210,130)
			           else WriteStringAt('pionNoir    ',210,130);
			         WriteNumAt('alpha = ',alpha,10,150);
			         WriteNumAt('beta = ',beta,100,150);
			         WriteNumAt('alpha_fenetre_tri = ',alpha_fenetre_tri,10,160);
			         WriteNumAt('beta_fenetre_tri = ' ,beta_fenetre_tri,140,160);
			         WriteNumAt('clef = ' ,clef,270,160);

			         for k := 1 to nbCoupsLegauxTriesRestantAEvaluer do
			           begin
			             WriteStringAt(NumEnString(k)+')  '+CoupEnStringEnMajuscules(CoupsLegauxTries[k].coup),10,170+k*10);
			             WriteNumAt('note = ',CoupsLegauxTries[k].note,70,170+k*10);
			             WriteNumAt('clé = ',CoupsLegauxTries[k].clefDeTri,150,170+k*10);
			           end;
			         for k := nbCoupsLegauxTriesRestantAEvaluer+1 to nbCoupsLegauxTriesRestantAEvaluer+5 do
			           WriteStringAt('                                                                                 ',10,170+k*10);
			         AttendFrappeClavierOuSouris(effetspecial2);
			         EcranStandard(NIL,false);
               end;


             nbCoupsLegauxTriesRestantAEvaluer := nbCoupsApresElagage;
           end;
      end;


    (*** pour debugage seulement ***)
    { for k := 1 to nbCoupsLegauxTriesRestantAEvaluer do
      if (CoupsLegauxTries[k].coup < 11) then Debugger else
      if (CoupsLegauxTries[k].coup > 88) then Debugger else
      if (pl[CoupsLegauxTries[k].coup] <> pionVide) then Debugger;
    }

  end;


  procedure VerifieJouableEtDoSystemTask;
    var n,t,k : SInt32;
    begin
      for n := 1 to 64 do
        begin
          iCourant := othellier[n];
          if pl[iCourant] = pionVide then
            if not(joua[iCourant]) then
              if PeutJouerIci(coul,iCourant,pl) then
                begin
                  InitialiseDirectionsJouables;
                  CarteJouable(pl,joua);
                  if true or debuggage.general then
                    begin
                      SysBeep(0);
                      EssaieSetPortWindowPlateau;
                      WriteNumAt('iCourant = ',iCourant,320,90*profMoins1+20);
                      WriteNumAt('pere = ',pere,320,90*profMoins1+30);
                      for k := 1 to 8 do
                        for t := 1 to 8 do
                          begin
                            iCourant := 10*t+k;
                            if joua[iCourant]
                              then WriteNumAt('',1,10*k,90*profMoins1+10*t)
                              else WriteNumAt('',0,10*k,90*profMoins1+10*t);
                            WriteNumAt('',pl[iCourant],100+12*k,90*profMoins1+10*t);
                          end;
                    end;
                end;
        end;
      DoSystemTask(AQuiDeJouer);
    end;


  procedure CreeCodePosition;
  begin
    with CodePosition do
      begin
        platLigne1 := codage_c1[pl[11]]+codage_c2[pl[12]]+codage_c3[pl[13]]+codage_c4[pl[14]]+
                    codage_c5[pl[15]]+codage_c6[pl[16]]+codage_c7[pl[17]]+codage_c8[pl[18]];
        platLigne2 := codage_c1[pl[21]]+codage_c2[pl[22]]+codage_c3[pl[23]]+codage_c4[pl[24]]+
                    codage_c5[pl[25]]+codage_c6[pl[26]]+codage_c7[pl[27]]+codage_c8[pl[28]];
        platLigne3 := codage_c1[pl[31]]+codage_c2[pl[32]]+codage_c3[pl[33]]+codage_c4[pl[34]]+
                    codage_c5[pl[35]]+codage_c6[pl[36]]+codage_c7[pl[37]]+codage_c8[pl[38]];
        platLigne4 := codage_c1[pl[41]]+codage_c2[pl[42]]+codage_c3[pl[43]]+codage_c4[pl[44]]+
                    codage_c5[pl[45]]+codage_c6[pl[46]]+codage_c7[pl[47]]+codage_c8[pl[48]];
        platLigne5 := codage_c1[pl[51]]+codage_c2[pl[52]]+codage_c3[pl[53]]+codage_c4[pl[54]]+
                    codage_c5[pl[55]]+codage_c6[pl[56]]+codage_c7[pl[57]]+codage_c8[pl[58]];
        platLigne6 := codage_c1[pl[61]]+codage_c2[pl[62]]+codage_c3[pl[63]]+codage_c4[pl[64]]+
                    codage_c5[pl[65]]+codage_c6[pl[66]]+codage_c7[pl[67]]+codage_c8[pl[68]];
        platLigne7 := codage_c1[pl[71]]+codage_c2[pl[72]]+codage_c3[pl[73]]+codage_c4[pl[74]]+
                    codage_c5[pl[75]]+codage_c6[pl[76]]+codage_c7[pl[77]]+codage_c8[pl[78]];
        platLigne8 := codage_c1[pl[81]]+codage_c2[pl[82]]+codage_c3[pl[83]]+codage_c4[pl[84]]+
                    codage_c5[pl[85]]+codage_c6[pl[86]]+codage_c7[pl[87]]+codage_c8[pl[88]];
      end;
  end;

  procedure ExpandHashTableExacteMilieu;
    begin
      with QuelleHashTableExacte^[clefHashExacte],CodePosition do
        begin
          ligne1 := platLigne1;
          ligne2 := platLigne2;
          ligne3 := platLigne3;
          ligne4 := platLigne4;
          ligne5 := platLigne5;
          ligne6 := platLigne6;
          ligne7 := platLigne7;
          ligne8 := platLigne8;
          SetBestDefenseDansHashExacte(0,QuelleHashTableExacte^[clefHashExacte]);
          SetTraitDansHashExacte(coul,QuelleHashTableExacte^[clefHashExacte]);
          SetValMinEtMaxDeMilieu(-noteMax,noteMax,QuelleHashTableExacte^[clefHashExacte]);
          profondeur := prof;
        end;
    end;

  procedure MetPosDansHashTableExacteMilieu;
    begin

      if not(utilise_hash_table_exacte) then
        begin
          WritelnDansRapport('Entree dans MetPosDansHashTableExacteMilieu');
          WritelnNumDansRapport('prof = ',prof);
          WritelnStringAndBoolDansRapport('utilise_hash_table = ',utilise_hash_table);
          WritelnStringAndBoolDansRapport('conseil_dans_hash_table = ',conseil_dans_hash_table);
          WritelnStringAndBoolDansRapport('utilise_hash_table_exacte = ',utilise_hash_table_exacte);
          WritelnNumDansRapport('POINTER_VALUE(QuelleHashTableExacte) = ',POINTER_VALUE(QuelleHashTableExacte));
          WritelnNumDansRapport('clefHashExacte = ',POINTER_VALUE(clefHashExacte));
          AttendFrappeClavier;
        end;


      with QuelleHashTableExacte^[clefHashExacte],CodePosition do
        begin
          ligne1 := platLigne1;
          ligne2 := platLigne2;
          ligne3 := platLigne3;
          ligne4 := platLigne4;
          ligne5 := platLigne5;
          ligne6 := platLigne6;
          ligne7 := platLigne7;
          ligne8 := platLigne8;
          SetTraitDansHashExacte(coul,QuelleHashTableExacte^[clefHashExacte]);
          profondeur := prof;
        end;

      if not(utilise_hash_table_exacte) then
        begin
          WritelnDansRapport('Sortie de MetPosDansHashTableExacteMilieu');
          WritelnDansRapport('');
          AttendFrappeClavier;
        end;
    end;



  function InfoTrouveeDansHashTableExacteMilieu : boolean;
  var increment1,increment2,longueurCollisionPath : SInt32;
      clefHashExacteInitiale,clefAEcraser,minProf : SInt32;
  begin
    SetQDGlobalsRandomSeed(gClefHashage+CodePosition.platLigne1+CodePosition.platLigne8+CodePosition.platLigne2+CodePosition.platLigne7);

    increment1 := BAnd(Random,1023);

    if BAnd(increment1,1) = 0 then inc(increment1); {pour avoir un nombre premier avec 1024}

    clefHashExacte := BAnd((clefHashExacte+increment1),1023);

    {WritelnNumDansRapport('clefHashExacte (3) = ',clefHashExacte);}

    clefHashExacteInitiale := clefHashExacte;

    (** on cherche si la position apparait dans la HashTable  **)
    longueurCollisionPath := 0;
    repeat
      with QuelleHashTableExacte^[clefHashExacte],CodePosition do
        begin
          if GetTraitDansHashExacte(QuelleHashTableExacte^[clefHashExacte]) = 0 then
            begin
              (** une place vide : on peut stopper la recherche **)
              InfoTrouveeDansHashTableExacteMilieu := false;
              exit(InfoTrouveeDansHashTableExacteMilieu);
            end;
          if ligne1 = platLigne1 then
          if ligne2 = platLigne2 then
          if ligne3 = platLigne3 then
          if ligne4 = platLigne4 then
          if ligne5 = platLigne5 then
          if ligne6 = platLigne6 then
          if ligne7 = platLigne7 then
          if ligne8 = platLigne8 then
          if GetTraitDansHashExacte(QuelleHashTableExacte^[clefHashExacte]) = coul then
            begin
              (** on a trouve la position dans la table **)
              InfoTrouveeDansHashTableExacteMilieu := (profondeur >= prof);
              conseilHash := GetBestDefenseDansHashExacte(QuelleHashTableExacte^[clefHashExacte]);
              if profondeur > 0
                then bonusPourLeConseilHash := 300 + 100*profondeur
                else bonusPourLeConseilHash := 300;
              exit(InfoTrouveeDansHashTableExacteMilieu);
            end;
          clefHashExacte := BAnd((clefHashExacte+increment1),1023);

          {WritelnNumDansRapport('clefHashExacte (4) = ',clefHashExacte);}

          inc(longueurCollisionPath);
        end;
    until (longueurCollisionPath > 12);

    SetQDGlobalsRandomSeed(clefHashExacteInitiale+CodePosition.platLigne2+CodePosition.platLigne7);

    increment2 := BAnd(Random,1023);

    if BAnd(increment2,1) = 0 then inc(increment2); {pour avoir un nb premier avec 1024}

    (** on cherche si la position apparait dans la HashTable  **)
    clefHashExacte := clefHashExacteInitiale;

    {WritelnNumDansRapport('clefHashExacte (5) = ',clefHashExacte);}

    longueurCollisionPath := 0;
    repeat
      with QuelleHashTableExacte^[clefHashExacte],CodePosition do
        begin
          if GetTraitDansHashExacte(QuelleHashTableExacte^[clefHashExacte]) = 0 then
            begin
              (** une place vide : on peut stopper la recherche **)
              InfoTrouveeDansHashTableExacteMilieu := false;
              exit(InfoTrouveeDansHashTableExacteMilieu);
            end;
          if ligne1 = platLigne1 then
          if ligne2 = platLigne2 then
          if ligne3 = platLigne3 then
          if ligne4 = platLigne4 then
          if ligne5 = platLigne5 then
          if ligne6 = platLigne6 then
          if ligne7 = platLigne7 then
          if ligne8 = platLigne8 then
          if GetTraitDansHashExacte(QuelleHashTableExacte^[clefHashExacte]) = coul then
            begin
              (** on a trouve la position dans la table **)
              InfoTrouveeDansHashTableExacteMilieu := (profondeur >= prof);
              conseilHash := GetBestDefenseDansHashExacte(QuelleHashTableExacte^[clefHashExacte]);
              if profondeur > 0
                then bonusPourLeConseilHash := 300 + 100*profondeur
                else bonusPourLeConseilHash := 300;
              exit(InfoTrouveeDansHashTableExacteMilieu);
            end;

          clefHashExacte := BAnd((clefHashExacte+increment2),1023);

          {WritelnNumDansRapport('clefHashExacte (6) = ',clefHashExacte);}

          inc(longueurCollisionPath);
        end;
    until (longueurCollisionPath > 12);

    InfoTrouveeDansHashTableExacteMilieu := false;


    (** collision : on ecrase une place le plus bas possible dans l'arbre  **)

    minProf := 10000;

    clefHashExacte := clefHashExacteInitiale;

    {WritelnNumDansRapport('clefHashExacte (7) = ',clefHashExacte);}

    longueurCollisionPath := 0;
    repeat
      if QuelleHashTableExacte^[clefHashExacte].profondeur < minProf then
        begin
          clefAEcraser := clefHashExacte;
          minProf := QuelleHashTableExacte^[clefHashExacte].profondeur;
        end;
      clefHashExacte := BAnd((clefHashExacte+increment1),1023);

      {WritelnNumDansRapport('clefHashExacte (8) = ',clefHashExacte);}

      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);

    clefHashExacte := clefHashExacteInitiale;

    {WritelnNumDansRapport('clefHashExacte (9) = ',clefHashExacte);}

    longueurCollisionPath := 0;
    repeat
      if QuelleHashTableExacte^[clefHashExacte].profondeur < minProf then
        begin
          clefAEcraser := clefHashExacte;
          minProf := QuelleHashTableExacte^[clefHashExacte].profondeur;
        end;
      clefHashExacte := BAnd((clefHashExacte+increment2),1023);

      {WritelnNumDansRapport('clefHashExacte (10) = ',clefHashExacte);}

      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);

    {
    WriteNumAt('minProf = ',minProf,10,40);
    WriteNumAt('clefAEcraser = ',clefAEcraser,10,50);
    SysBeep(0);
    AttendFrappeClavier;
    }

    clefHashExacte := clefAEcraser;  (** on ecrase cette position **)

    {WritelnNumDansRapport('clefHashExacte (11) = ',clefHashExacte);}

  end;


  procedure EcritCoupEtProf;
	begin
	  if (prof >= 2) then
	    begin
		    EssaieSetPortWindowPlateau;
		    WriteStringAt(CoupEnStringEnMajuscules(pere)+' ',50*longPath,100);
		    WriteStringAt(NumEnString(prof)+' ',50*longPath,112);
		    WriteStringAt(NumEnString(alpha)+'       ',50*longPath,124);
		    WriteStringAt(NumEnString(beta)+'       ',50*longPath,136);
		  end;
		if (alpha >= beta) then
		  begin
		    SysBeep(0);
		    WritelnPositionEtTraitDansRapport(pl,coul);
		    WritelnNumDansRapport('alpha = ',alpha);
		    WritelnNumDansRapport('beta = ',beta);
		    WritelnNumDansRapport('alphaArrivee = ',alphaArrivee);
		    WritelnNumDansRapport('betaArrivee = ',betaArrivee);
		    WritelnNumDansRapport('valeurExacteMin = ',valeurExacteMin);
		    WritelnNumDansRapport('valeurExacteMax = ',valeurExacteMax);
		    WritelnDansRapport('');
		    AttendFrappeClavier;
		  end;
	end;

	procedure EffaceCoupEtProf;
	begin
	  if (prof >= 2) then
	    begin
		    EssaieSetPortWindowPlateau;
		    WriteStringAt('          ',50*longPath,100);
		    WriteStringAt('          ',50*longPath,112);
		    WriteStringAt('          ',50*longPath,124);
		    WriteStringAt('          ',50*longPath,136);
		  end;
	end;


  procedure DoProbCut(profDepart,profReduite1,fenetre_probcut1,profReduite2,fenetre_probcut2 : SInt32);
  var eval,compteurEvalRecursives : SInt32;
      centre_fenetre_bas,centre_fenetre_haut : double_t;
      kCentreFenetre : double_t;

    procedure TryAlphaProbCut(profReduite,fenetre_probcut : SInt32);
    var
      val : SInt32;
    begin
      if (alpha > -20000) then
	      begin
	        SeuilProbCutAlpha := alpha - fenetre_probcut;
	        val := ABScout(pl,joua,bstDef,pere,coul,profReduite,profMaximum,horizon,longPath,distPV,couleurDeCassio,SeuilProbCutAlpha,SeuilProbCutAlpha+1,nbBlancs,nbNoirs,fr,conseilTurbulence,false);

	        if (val <= SeuilProbCutAlpha) then
	          begin
	            ABScout := alpha;
	            {EffaceCoupEtProf;}
	            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	            if useMicroProfiler then EndMiniProfilerMilieu;
						  {$ENDC}
	            exit(ABScout);
	          end;
	      end;
    end;



    procedure TryBetaProbCut(profReduite,fenetre_probcut : SInt32);
    var
      val : SInt32;
    begin
	    if (beta < 20000) then
	      begin
	        SeuilProbCutBeta := beta + fenetre_probcut;
	        val := ABScout(pl,joua,bstDef,pere,coul,profReduite,profMaximum,horizon,longPath,distPV,couleurDeCassio,SeuilProbCutBeta-1,SeuilProbCutBeta,nbBlancs,nbNoirs,fr,conseilTurbulence,false);

	        if (val >= SeuilProbCutBeta) then
	          begin
	            ABScout := beta;
	            {EffaceCoupEtProf;}
	            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
						  if useMicroProfiler then EndMiniProfilerMilieu;
						  {$ENDC}
	            exit(ABScout);
	          end;
	      end;
    end;


    function TryAlphaBetaProbCut(profReduite,fenetre_probcut : SInt32) : SInt32;
    var
      val : SInt32;
    begin
      SeuilProbCutAlpha := alpha - fenetre_probcut;
      SeuilProbCutBeta  := beta  + fenetre_probcut;

	    val := ABScout(pl,joua,bstDef,pere,coul,profReduite,profMaximum,horizon,longPath,distPV,couleurDeCassio,SeuilProbCutAlpha,SeuilProbCutBeta,nbBlancs,nbNoirs,fr,conseilTurbulence,false);


      if (val <= SeuilProbCutAlpha) then
        begin
          ABScout := alpha;
          {EffaceCoupEtProf;}
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
          if useMicroProfiler then EndMiniProfilerMilieu;
				  {$ENDC}
          exit(ABScout);
        end;

      if (val >= SeuilProbCutBeta) then
        begin
          ABScout := beta;
          {EffaceCoupEtProf;}
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
				  if useMicroProfiler then EndMiniProfilerMilieu;
				  {$ENDC}
          exit(ABScout);
        end;

	    if (profReduite >= 3) then conseilTurbulence := bstDef;

	    TryAlphaBetaProbCut := val;

    end;


  begin  {DoProbCut}

    {$UNUSED profDepart}

    if (alpha > -20000) and (beta < 20000)
      then eval := Evaluation(pl,coul,nbBlancs,nbNoirs,joua,fr,true,alpha,beta,compteurEvalRecursives)
      else eval := -100000;  {probCut alpha, puis beta}


    kCentreFenetre := 0.75;
		centre_fenetre_bas  := alpha - kCentreFenetre*fenetre_probcut1;
		centre_fenetre_haut := beta  + kCentreFenetre*fenetre_probcut1;

    if (alpha <= -20000) or (beta >= 20000) or
       ((eval <> -100000) and ((eval < centre_fenetre_bas) or (eval > centre_fenetre_haut)))
      then
        begin

          if Abs(alpha - eval) < Abs(beta - eval)
			      then
			        begin  {on cherche une coupure probabiliste alpha, puis beta}
			          TryAlphaProbCut(profReduite1,fenetre_probcut1);
			          if not((eval <> -100000) and (eval < centre_fenetre_bas))
			            then TryBetaProbCut (profReduite1,fenetre_probcut1);

			          if (profReduite2 > 0) then
			            begin
			              TryAlphaProbCut(profReduite2,fenetre_probcut2);
			              if not((eval <> -100000) and (eval < centre_fenetre_bas))
			                then TryBetaProbCut (profReduite2,fenetre_probcut2);
			            end;
			        end
			      else
			        begin {on cherche une coupure probabiliste beta, puis alpha}
			          TryBetaProbCut (profReduite1,fenetre_probcut1);
			          if not((eval <> -100000) and (eval > centre_fenetre_haut))
			            then TryAlphaProbCut(profReduite1,fenetre_probcut1);

			          if (profReduite2 > 0) then
			            begin
			              TryBetaProbCut (profReduite2,fenetre_probcut2);
			              if not((eval <> -100000) and (eval > centre_fenetre_haut))
			                then TryAlphaProbCut(profReduite2,fenetre_probcut2);
			            end;
			        end;
			  end
			else
			  begin
			    eval := TryAlphaBetaProbCut(profReduite1,fenetre_probcut1);

			    if (profReduite2 > 0) then
			      begin

			        kCentreFenetre := 0.3;

			        centre_fenetre_bas  := alpha - kCentreFenetre*fenetre_probcut1;
			        centre_fenetre_haut := beta  + kCentreFenetre*fenetre_probcut1;

			        {on ne fait le second test que si la premiere valeur n'est pas
			         tombe au milieu de la fenetre : si on est au milieu, la proba-
			         bilite d'avoir une coupure est tres faible}

			        if not(((centre_fenetre_bas <= eval) and (eval <= centre_fenetre_haut))) then
		            begin
		              if Abs(alpha - eval) < Abs(beta - eval)
							      then
							        begin  {on cherche une coupure probabiliste alpha}
							          TryAlphaProbCut(profReduite2,fenetre_probcut2);
							        end
							      else
							        begin {on cherche une coupure probabiliste beta}
							          TryBetaProbCut(profReduite2,fenetre_probcut2);
							        end;
		            end;

			      end;
			  end;

  end;


  procedure TryProbCut;
  begin

      {if beta > alpha+1 then
        begin
          EssaieSetPortWindowPlateau;
          EcritPositionAt(pl,10,10);
          WriteNumAt('alpha = ',alpha,10,150);
          WriteNumAt('beta = ',beta,100,150);
          WriteNumAt('prof = ',prof,200,150);
          AttendFrappeClavierOuSouris(effetspecial2);
        end;}

  (* if utilisationNouvelleEval and (prof >= 3)
       then DoProbCut(prof,0,Max(prof*100,600));  *)



     nroDuCoup := nbBlancs + nbNoirs - 4;
     largeur1 := table_FenetreProbCut[nroDuCoup];
     largeur2 := table_GrandeFenetreProbCut[nroDuCoup];
     largeur3 := table_GrandeFenetreProbCut[nroDuCoup] + 200;
     {largeur3 := table_HyperGrandeFenetreProbCut[nroDuCoup];}



     {selectivite variable : plus on est loin de la ligne principale, plus
      on se permet d'etre selectif}
     if (nroDuCoup < 40) then
       begin
         augmentation_selectivite := 7*(distPV - 1);
         if augmentation_selectivite > 100 then augmentation_selectivite := 100;

         largeur1 := largeur1 - augmentation_selectivite;
         largeur2 := largeur2 - augmentation_selectivite;
         largeur3 := largeur3 - augmentation_selectivite;
       end;



		 {
		 if (nroDuCoup = 40) then
		   begin
		     WriteNumDansRapport('(p = ',prof);
		     WriteNumDansRapport(', n = ',nroDuCoup);
		     WriteNumDansRapport(', d = ',distPV);
		     WriteNumDansRapport(', l1 = ',largeur1);
		     WriteNumDansRapport(', l2 = ',largeur2);
		     WriteNumDansRapport(', l3 = ',largeur3);
		     WritelnDansRapport(')');
		   end;
		 }

     if (prof =  3) then DoProbCut( 3, 1,largeur1, -1,0) else
     if (prof =  4) then DoProbCut( 4, 2,largeur1, -1,0) else
     if (prof =  5) then DoProbCut( 5, 1,largeur2, -1,0) else
     if (prof =  6) then DoProbCut( 6, 2,largeur1, -1,0) else
     if (prof =  7) then DoProbCut( 7, 1,largeur2, 3,largeur1) else
     if (prof =  8) then DoProbCut( 8, 2,largeur2, 4,largeur1) else
     if (prof =  9) then DoProbCut( 9, 3,largeur2, 5,largeur1) else
     if (prof = 10) then DoProbCut(10, 2,largeur3, 4,largeur2) else
     if (prof = 11) then DoProbCut(11, 3,largeur3, 5,largeur2) else
     if (prof = 12) then DoProbCut(12, 2,largeur3, 4,largeur2) else
     if (prof = 13) then DoProbCut(13, 3,largeur3, 5,largeur2) else
     if (prof = 14) then DoProbCut(14, 2,largeur3, 4,largeur2) else
     if (prof = 15) then DoProbCut(15, 3,largeur3, 5,largeur2) else
     if (prof = 16) then DoProbCut(16, 4,largeur3, 6,largeur2) else
     if (prof = 17) then DoProbCut(17, 5,largeur3, 7,largeur2) else

     (*
      if effetspecial then
       begin
     if (prof = 18) then DoProbCut(18, 4,largeur3, 6,largeur2) else
     if (prof = 19) then DoProbCut(19, 5,largeur3, 7,largeur2) else
     if (prof = 20) then DoProbCut(20, 4,largeur3, 6,largeur2) else
     if (prof = 21) then DoProbCut(21, 5,largeur3, 7,largeur2) else
     if (prof = 22) then DoProbCut(22, 4,largeur3, 6,largeur2);
       end;
     { Attention : bien penser a changer PlusGrandeProfondeurAvecProbCut quand
                   on rajoute des profondeurs utilisant ProbCut ! }
     *)

  end;


  function DetermineSiBitboardEstMieux(nbreCasesVides : SInt32) : boolean;
  begin
    (* DetermineSiBitboardEstMieux := (nbreCasesVides > 67200); *)

     if ((nbreCasesVides < 0) or (nbreCasesVides > 64))
      then
        begin
          DetermineSiBitboardEstMieux := false;
          Sysbeep(0);
          WritelnNumDansRapport('Erreur dans DetermineSiBitboardEstMieux : nbreCasesVides = ',nbreCasesVides);
          AttendFrappeClavier;
        end
      else
        begin
          {Tellement peu de cases vides que la finale va plus vite ? }
          DetermineSiBitboardEstMieux := (prof >= profOuBiboardEstMieuxPourCeNbreVides[nbreCasesVides]);
        end;
  end;

 procedure PrintTraceDebugageABScout(const message : String255);
 var oldTraceLog : boolean;
 begin
   if debugABScout then
     begin
       oldTraceLog := GetTraceLogState;
       SetTracingLog(true);
       WriteInTraceLog(message);
       SetTracingLog(oldTraceLog);

       WritelnDansRapport(message);
       AttendFrappeClavier;
     end;
 end;


begin   {ABScout}

 debugABScout := false;

 {PrintTraceDebugageABScout('Entree dans ABScout');}

 if (interruptionReflexion = pasdinterruption) and not(Quitter) then
 begin

   (*
   magicCookieABSCout := NewMagicCookie;
   WriteInTraceLog('Entree dans ABSCout, magicCookie = '+NumEnString(magicCookieABSCout));
   *)

   if (coul <> pionNoir) and (coul <> pionBlanc) then
     begin
       WritelnNumDansRapport('ASSERT !! dans ABSCout, couleur = ',coul);
       ABScout := -noteMax;
       exit(ABScout);
     end;

   {if (TickCount - dernierTick) >= delaiAvantDoSystemTask then VerifieJouableEtDoSystemTask;}
   if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

   (* ATTENTION !! A cause d'un bug dans CodeWarrior, le calcul de nbCasesVidesRestantes
                   doit se faire en deux etapes, comme ci-dessous !!! *)
   nbCasesVidesRestantes := 62 - nbNoirs - nbBlancs;
   nbCasesVidesRestantes := nbCasesVidesRestantes + 2;



   if debugABScout then
     begin
       debugPosition := MakePositionEtTrait(pl,coul);
       PrintTraceDebugageABScout(PositionEtTraitEnString(debugPosition));
       PrintTraceDebugageABScout('nbCasesVidesRestantes = '+NumEnString(nbCasesVidesRestantes));
     end;

   (* PV extension : est-on près de la fin, sur la ligne principale ? *)
   if (nbCasesVidesRestantes <= kEMPTIES_FOR_PV_EXTENSION) and (nbCasesVidesRestantes >= 10)
      and (beta > alpha+1) and canDoProbCut then
     if PeutFaireFinaleBitboardCettePosition(pl,coul,-6400,6400,nbNoirs,nbBlancs,noteCourante) then
       begin
        nbreFeuillesMilieu := nbreFeuillesMilieu + nbNoeudsEstimes[nbCasesVidesRestantes];
        nbreNoeudsGeneresMilieu := nbreNoeudsGeneresMilieu + nbNoeudsEstimes[nbCasesVidesRestantes];
        bstDef := 0;
        conseilTurbulence := 0;

        {
        WritelnPositionEtTraitDansRapport(pl,coul);
        WritelnNumDansRapport('PV extension, alors que distPV = ',distPV);
        WritelnNumDansRapport('nbCasesVidesRestantes = ',nbCasesVidesRestantes);
        WritelnNumDansRapport('alpha = ',alpha);
        WritelnNumDansRapport('beta = ',beta);
        WritelnNumDansRapport('noteCourante = ',noteCourante);
        WritelnDansRapport('');
        }

        ABScout := noteCourante;
        exit(ABScout);
      end;

   (* La finale en bitboard est-elle plus rapide que le milieu de partie ? *)
   if (nbCasesVidesRestantes > 8) and DetermineSiBitboardEstMieux(nbCasesVidesRestantes) then
     if PeutFaireFinaleBitboardCettePosition(pl,coul,alpha,beta,nbNoirs,nbBlancs,noteCourante) then
      begin
        nbreFeuillesMilieu := nbreFeuillesMilieu + nbNoeudsEstimes[nbCasesVidesRestantes];
        nbreNoeudsGeneresMilieu := nbreNoeudsGeneresMilieu + nbNoeudsEstimes[nbCasesVidesRestantes];
        bstDef := 0;
        conseilTurbulence := 0;
        ABScout := noteCourante;
        exit(ABScout);
      end;


   {if (conseilTurbulence = -1) then
     if EstTurbulent(pl,coul,nbBlancs,nbNoirs,fr,conseilTurbulence) then DoNothing;
   }
   conseilTurbulence := 0;
   bstDef            := 0;

   if (effetspecial2 and (conseilTurbulence <> -1) and (conseilTurbulence <> 0)) then
     begin
       EssaieSetPortWindowPlateau;
       EcritPositionAt(pl,50,50);
       if conseilTurbulence = 0
         then
           if coul = pionNoir
             then WriteStringAt('X en ??',200,100)
             else WriteStringAt('O en ??',200,100)
         else
           if coul = pionNoir
             then WriteStringAt('X en '+CoupEnStringEnMajuscules(conseilTurbulence),200,100)
             else WriteStringAt('O en '+CoupEnStringEnMajuscules(conseilTurbulence),200,100);
       WriteNumAt('prof = ',prof,200,110);
       AttendFrappeClavierOuSouris(effetspecial2);
       WriteStringAt('            ',200,100);
       WriteStringAt('            ',200,110);
     end;

   {PrintTraceDebugageABScout('Avant alphaArrivee dans ABSCout');}

   alphaArrivee := alpha;
   betaArrivee  := beta;
   {EcritCoupEtProf;}


   {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   nroDuCoup := nbBlancs + nbNoirs - 4;
   useMicroProfiler := (nroDuCoup >=  48);
   if useMicroProfiler then BeginMiniProfilerMilieu;
   {$ENDC}


	 {attention : le test (beta <= alpha+1) est indispensable pour NegaScout}
   if (canDoProbCut and (beta <= alpha+1)) then TryProbCut;


   {EcritCoupEtProf;
   WritelnNumDansRapport('∂ = ',(profMaximum - longPath) - prof);}

   utilise_hash_table        := (prof >= ProfUtilisationHash);
	 conseil_dans_hash_table   := (prof >= profondeurRemplissageHash);
	 utilise_hash_table_exacte := (prof >= ProfPourHashExacte);

   {
   WritelnNumDansRapport('prof = ',prof);
   WritelnNumDansRapport('ProfUtilisationHash = ',ProfUtilisationHash);
   WritelnNumDansRapport('profondeurRemplissageHash = ',profondeurRemplissageHash);
   WritelnNumDansRapport('ProfPourHashExacte = ',ProfPourHashExacte);

   WritelnStringAndBoolDansRapport('utilise_hash_table = ',utilise_hash_table);
   WritelnStringAndBoolDansRapport('conseil_dans_hash_table = ',conseil_dans_hash_table);
   WritelnStringAndBoolDansRapport('utilise_hash_table_exacte = ',utilise_hash_table_exacte);
   }

   valeurExacteMax := noteMax;
   valeurExacteMin := -noteMax;
   bonusPourLeConseilHash := 0;
   if utilise_hash_table
     then
       begin
         gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]) );
         if conseil_dans_hash_table
           then
             begin
               clefHashConseil := BAnd(gClefHashage,32767);
               conseilHash := HashTable^^[clefHashConseil];
               bonusPourLeConseilHash := 400;
             end
           else conseilHash := 0;

         if utilise_hash_table_exacte then
           begin

             nroTableExacte := BAnd(gClefHashage div 1024,nbTablesHashExactesMoins1);
             clefHashExacte := BAnd(gClefHashage,1023);

             {WritelnNumDansRapport('clefHashExacte (12) = ',clefHashExacte);}

             QuelleHashTableExacte := HashTableExacte[nroTableExacte];

             CreeCodePosition;
             if InfoTrouveeDansHashTableExacteMilieu
               then
                 begin
                   GetValMinEtMaxDeMilieu(valeurExacteMin,valeurExacteMax,QuelleHashTableExacte^[clefHashExacte]);
                   bstDef := GetBestDefenseDansHashExacte(QuelleHashTableExacte^[clefHashExacte]);
                   conseilHash := bstDef;

                   if (valeurExacteMin >  alpha) then alpha := valeurExacteMin;
                   if (valeurExacteMax <  beta)  then beta  := valeurExacteMax;
                   if (valeurExacteMin >= beta) then
                     begin
                       ABScout := valeurExacteMin;
                       if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                       gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                       {EffaceCoupEtProf;}
                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
											 if useMicroProfiler then EndMiniProfilerMilieu;
											 {$ENDC}
											 (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                       exit(ABScout);
                     end;
                   if (valeurExacteMin >= valeurExacteMax) then
                     begin
                       ABScout := valeurExacteMin;
                       if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                       gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                       {EffaceCoupEtProf;}
                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
											 if useMicroProfiler then EndMiniProfilerMilieu;
											 {$ENDC}
											 (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                       exit(ABScout);
                     end;
                   if (valeurExacteMax <= alpha) then
                     begin
                       ABScout := valeurExacteMax;
                       if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                       gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                       {EffaceCoupEtProf;}
                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
											 if useMicroProfiler then EndMiniProfilerMilieu;
											 {$ENDC}
											 (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                       exit(ABScout);
                     end;

                   {
                   EssaieSetPortWindowPlateau;
                   WriteNumAt('ValeurMin = ',valeurExacteMin,10,10);
                   WriteNumAt('ValeurMax = ',valeurExacteMax,10,20);
                   AttendFrappeClavier;
                   }

                 end
               else
                 begin
                   ExpandHashTableExacteMilieu;
                   GetValMinEtMaxDeMilieu(valeurExacteMin,valeurExacteMax,QuelleHashTableExacte^[clefHashExacte]);
                 end;
           end;
       end
     else
       conseilHash := 0;

   {EcritCoupEtProf;}

   {PrintTraceDebugageABScout('Apres examen des coupures de hachage dans ABSCout');}

   MemoryFillChar(@dejaEvalue,sizeof(dejaEvalue),char(false));
   nbEvalues := 0;
   adversaire := -coul;
   aJoue := false;
   maxPourBestDef := -noteMax;
   clefMaxDansGenerationCoupsLegaux := -noteMax;


   profMoins1 := pred(prof);
   longPathPlus1 := succ(longPath);


   if (interruptionReflexion <> pasdinterruption) then
    begin
      ABScout := -noteMax;
      goto sortie;
    end;


   // la ligne suivante pour simuler des inetrruptions (pour le debuggage seulement !)
   // if ((Tickcount mod 15) = 0) then LanceInterruption(interruptionSimple,'Attention : interruption ajoutee dans ABScout');


   {PrintTraceDebugageABScout('Avant test du coup conseilTurbulence dans ABSCout');}


   platEssai := pl;
   jouablEssai := joua;
   nbBlcEssai := nbBlancs;
   nbNrEssai := nbNoirs;
   frontEssai := fr;

   {PrintTraceDebugageABScout('conseilTurbulence = '+CoupEnString(conseilTurbulence,true)+' '+NumEnString(conseilTurbulence)+' dans ABSCout');}

   iCourant := conseilTurbulence;
   if maxPourBestDef < valeurExacteMax then
   if (iCourant >= 11) and (iCourant <= 88) then
   if joua[iCourant] then
   if not(dejaEvalue[iCourant]) then
    begin
      dejaEvalue[iCourant] := true;
      if ModifPlat(iCourant,coul,platEssai,jouablEssai,nbBlcEssai,nbNrEssai,frontessai)
       then begin
         suiteJoueeGlb^[prof] := iCourant;
         aJoue := true;

         conseilTurbulencePourLeFils := -1;
         if (profMoins1 <= SelectivitePourCetteRecherche)
           then
             begin
               {if (profMoins1 = SelectivitePourCetteRecherche)
                 then evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils))
                 else evaluerMaintenant := true;}
               evaluerMaintenant := true;
             end
           else
             if (profMoins1 > 0)
               then evaluerMaintenant := false
               else
                 begin
                   {evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils));}
                   evaluerMaintenant := true;
                   if evaluerMaintenant and not(utilisationNouvelleEval) then
                     evaluerMaintenant := PasDeBordDeCinqAttaque(adversaire,frontessai,platessai);
                   {if evaluerMaintenant and avecselectivite then
                     evaluerMaintenant := not(BordDeCinqUrgent(platessai,frontessai));}
                   {if evaluerMaintenant then
                       evaluerMaintenant := PasDeControleDeDiagonaleEnCours(adversaire,platEssai);}
                 end;

         if evaluerMaintenant
           then
             begin
               noteCourante := -Evaluation(platEssai,adversaire,nbBlcEssai,nbNrEssai,
                                        jouablEssai,frontEssai,true,-beta,-alpha,nbEvalsRecursives);
             end
           else
             begin
               if (nbEvalues = 0) or (beta <= alpha+1)
                 then
                   noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                          profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                          -beta,-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut)
                 else
                   begin
                     noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                            profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                            pred(-alpha),-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                     if (alpha < notecourante) and (notecourante < beta) then
                       begin
                         noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                profMoins1,profMaximum,horizon,longPathPlus1,0,couleurDeCassio,
                                               -beta,-notecourante,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                         if (notecourante = succ(alpha)) then notecourante := alpha;
                       end;
                   end;
              end;
         inc(nbEvalues);

         if (noteCourante > clefMaxDansGenerationCoupsLegaux) then clefMaxDansGenerationCoupsLegaux := noteCourante;
         if (noteCourante > maxPourBestDef) then
              begin
                maxPourBestDef := noteCourante;
                bstDef := iCourant;
                {for k := 1 to profMoins1 do
                   meilleureSuiteGlb^[prof,k] := meilleureSuiteGlb^[profMoins1,k];}
                if profMoins1 > 0 then
                  Moveright(meilleureSuiteGlb^[profMoins1,1],meilleureSuiteGlb^[prof,1],profMoins1+profMoins1);
                meilleureSuiteGlb^[prof,prof] := iCourant;
                if noteCourante > alpha then
                  begin
                    alpha := noteCourante;
                    if utilise_hash_table_exacte then
                      begin
                        valeurExacteMin := maxPourBestDef;
                        {WritelnDansRapport('Appel de MetPosDansHashTableExacteMilieu (1)');}
                        MetPosDansHashTableExacteMilieu;
                        SetValMinEtMaxDeMilieu(maxPourBestDef,valeurExacteMax,QuelleHashTableExacte^[clefHashExacte]);
                        SetBestDefenseDansHashExacte(bstDef,QuelleHashTableExacte^[clefHashExacte]);
                      end;
                    if (alpha >= beta) then
                      begin
                        if utilise_hash_table then
                          begin
                            if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                            gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                          end;
                        ABScout := maxPourBestDef;
                        {EffaceCoupEtProf;}
                        {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
											  if useMicroProfiler then EndMiniProfilerMilieu;
											  {$ENDC}
                        (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                       exit(ABScout);
                      end;
                  end;
              end;


         platEssai := pl;
         jouablEssai := joua;
         nbBlcEssai := nbBlancs;
         nbNrEssai := nbNoirs;
         frontEssai := fr;

         end;
     end;


  if (interruptionReflexion <> pasdinterruption) then
    begin
      ABScout := -noteMax;
      goto sortie;
    end;


   if (prof >= profMinimalePourTriDesCoups)
     then
       BEGIN
         {PrintTraceDebugageABScout('Avant PreparerTriDesCoups dans ABSCout');}

         PreparerTriDesCoups;
         repeat
           GenererEtTrierDesCoupsLegaux;
           if tousLesCoupsLegauxGeneres
              then nbCoupsAManger := nbCoupsLegauxTriesRestantAEvaluer
              else nbCoupsAManger := 1;
           for ii := 1 to nbCoupsAManger do
           begin
             iCourant := CoupsLegauxTries[ii].coup;

             {PrintTraceDebugageABScout('iCourant = '+CoupEnString(iCourant,true)+' '+NumEnString(iCourant)+' dans ABSCout');}

             if maxPourBestDef < valeurExacteMax then
             if (iCourant >= 11) and (iCourant <= 88) then
             if not(dejaEvalue[iCourant]) then
              begin
                dejaEvalue[iCourant] := true;
                if ModifPlat(iCourant,coul,platEssai,jouablEssai,nbBlcEssai,nbNrEssai,frontessai)
                 then begin


                   (*
                   SysBeep(0);
                   EssaieSetPortWindowPlateau;
                   EcritPositionAt(pl,410,10);
                   EcritPositionAt(platEssai,520,10);
                   EcritPlatBoolAt(SquareSetToPlatBool(dejaEvalue),630,10);
                   if tousLesCoupsLegauxGeneres
                     then WriteStringAt('TousLesCoupsGeneres = TRUE ',410,120)
                     else WriteStringAt('TousLesCoupsGeneres = FALSE',410,120);
                   WriteNumAt('nbCoupsAManger = ',nbCoupsAManger,410,140);
                   if conseilHash = 0
                     then WriteStringAt('ConseilHash =  ??      ',410,130)
                     else WriteStringAt('ConseilHash = '+CoupEnStringEnMajuscules(conseilHash)+'      ',410,130);
                   WriteNumAt(' prof = ',prof,500,130);
                   WriteNumAt(' profMax = ',profMaximum,540,130);
                   if coul = pionBlanc
                     then WriteStringAt('pionBlanc  ',610,130)
                     else WriteStringAt('pionNoir    ',610,130);
                   WriteNumAt(' nbVides = ',NbCasesVidesDansPosition(pl),690,130);
                   WriteNumAt('alpha = ',alpha,410,150);
                   WriteNumAt('beta = ',beta,500,150);

                   for k := 1 to nbCoupsAManger do
                     begin
                       WriteStringAt(NumEnString(k)+')  '+CoupEnStringEnMajuscules(CoupsLegauxTries[k].coup),410,170+k*10);
                       WriteNumAt('note = ',CoupsLegauxTries[k].note,470,170+k*10);
                       WriteNumAt('clé = ',CoupsLegauxTries[k].clefDeTri,550,170+k*10);
                     end;
                   for k := nbCoupsLegauxTriesRestantAEvaluer+1 to nbCoupsLegauxTriesRestantAEvaluer+5 do
                     WriteStringAt('                                                                                 ',410,170+k*10);
                   AttendFrappeClavier;
                   *)






                   suiteJoueeGlb^[prof] := iCourant;
                   aJoue := true;

                   conseilTurbulencePourLeFils := -1;
                   if (profMoins1 <= SelectivitePourCetteRecherche)
                     then
                       begin
                         {if (profMoins1 = SelectivitePourCetteRecherche)
                           then evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils))
                           else evaluerMaintenant := true;}
                         evaluerMaintenant := true;
                       end
                     else
                       if (profMoins1 > 0)
                         then evaluerMaintenant := false
                         else
                           begin
                             {evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils));}
                             evaluerMaintenant := true;
                             if evaluerMaintenant and not(utilisationNouvelleEval) then
                               evaluerMaintenant := PasDeBordDeCinqAttaque(adversaire,frontessai,platessai);
                             {if evaluerMaintenant and avecselectivite then
                               evaluerMaintenant := not(BordDeCinqUrgent(platessai,frontessai));}
                             {if evaluerMaintenant then
                               evaluerMaintenant := PasDeControleDeDiagonaleEnCours(adversaire,platEssai);}
                           end;

                   if evaluerMaintenant
                     then
                       begin
                         { noteCourante := -Evaluation(platEssai,adversaire,nbBlcEssai,nbNrEssai,
                                                   jouablEssai,frontEssai,true,-beta,-alpha,nbEvalsRecursives);}

                         {ATTENTION : optimisation, on utilise l'evaluation calculee pour trier les coups}
                         noteCourante := CoupsLegauxTries[ii].note;

                         {
                         EssaieSetPortWindowPlateau;
                         WriteNumAt('CoupsLegauxTries[ii].note = ',CoupsLegauxTries[ii].note,10,10);
                         WriteNumAt('noteCourante = ',noteCourante,10,20);
                         SysBeep(0);
                         AttendFrappeClavier;
                         }

                       end
                     else
                       begin
                         if (nbEvalues = 0) or (beta <= alpha+1)
                           then
                             noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                    profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                    -beta,-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut)
                           else
                             begin
                               noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                      profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                      pred(-alpha),-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                               if (alpha < notecourante) and (notecourante < beta) then
                                 begin
                                   noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                         profMoins1,profMaximum,horizon,longPathPlus1,0,couleurDeCassio,
                                                         -beta,-notecourante,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                                   if (notecourante = succ(alpha)) then notecourante := alpha;
                                 end;
                             end;
                        end;
                   inc(nbEvalues);

                   if (noteCourante > clefMaxDansGenerationCoupsLegaux) then clefMaxDansGenerationCoupsLegaux := noteCourante;
                   if (noteCourante > maxPourBestDef) then
                        begin
                          maxPourBestDef := noteCourante;
                          bstDef := iCourant;
                          {for k := 1 to profMoins1 do
                             meilleureSuiteGlb^[prof,k] := meilleureSuiteGlb^[profMoins1,k];}
                          if profMoins1 > 0 then
                            moveright(meilleureSuiteGlb^[profMoins1,1],meilleureSuiteGlb^[prof,1],profMoins1+profMoins1);
                          meilleureSuiteGlb^[prof,prof] := iCourant;
                          if noteCourante > alpha then
                            begin
                              alpha := noteCourante;
                              if utilise_hash_table_exacte then
                                begin
                                  valeurExacteMin := maxPourBestDef;
                                  {WritelnDansRapport('Appel de MetPosDansHashTableExacteMilieu (2)');}
                                  MetPosDansHashTableExacteMilieu;
                                  SetValMinEtMaxDeMilieu(maxPourBestDef,valeurExacteMax,QuelleHashTableExacte^[clefHashExacte]);
                                  SetBestDefenseDansHashExacte(bstDef,QuelleHashTableExacte^[clefHashExacte]);
                                end;
                              if (alpha >= beta) then
                                begin
                                  if utilise_hash_table then
                                    begin
                                      if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                                      gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                                    end;
                                  ABScout := maxPourBestDef;
                                  {EffaceCoupEtProf;}
                                  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
																	if useMicroProfiler then EndMiniProfilerMilieu;
																	{$ENDC}
                                  (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                                  exit(ABScout);
                                end;
                            end;
                        end;
                   platEssai := pl;
                   jouablEssai := joua;
                   nbBlcEssai := nbBlancs;
                   nbNrEssai := nbNoirs;
                   frontEssai := fr;
                   end;
               end;
           end;
           for ii := (nbCoupsAManger+1) to nbCoupsLegauxTriesRestantAEvaluer do
               CoupsLegauxTries[ii-nbCoupsAManger] := CoupsLegauxTries[ii];
           nbCoupsLegauxTriesRestantAEvaluer := nbCoupsLegauxTriesRestantAEvaluer-nbCoupsAManger;
         until tousLesCoupsLegauxGeneres;


       END    { prof >= profMinimalePourTriDesCoups }
     else
       BEGIN
         for ii := 1 to 4 do
         BEGIN
           iCourant := othellier[ii];
           if maxPourBestDef < valeurExacteMax then
           if (iCourant >= 11) and (iCourant <= 88) then
           if joua[iCourant] then
           if not(dejaEvalue[iCourant]) then
            begin
              dejaEvalue[iCourant] := true;
              if ModifPlat(iCourant,coul,platEssai,jouablEssai,nbBlcEssai,nbNrEssai,frontessai)
               then begin
                 suiteJoueeGlb^[prof] := iCourant;
                 aJoue := true;
                 conseilTurbulencePourLeFils := -1;

                 if (profMoins1 <= SelectivitePourCetteRecherche)
                   then
                     begin
                       {if (profMoins1 = SelectivitePourCetteRecherche)
                         then evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils))
                         else evaluerMaintenant := true;}
                       evaluerMaintenant := true;
                     end
                   else
                     if (profMoins1 > 0)
                       then evaluerMaintenant := false
                       else
                         begin
                           {evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils));}
                           evaluerMaintenant := true;
                           if evaluerMaintenant and not(utilisationNouvelleEval) then
                             evaluerMaintenant := PasDeBordDeCinqAttaque(adversaire,frontessai,platessai);
                           {if evaluerMaintenant and avecselectivite then
                             evaluerMaintenant := not(BordDeCinqUrgent(platessai,frontessai));}
                           {if evaluerMaintenant then
                                 evaluerMaintenant := PasDeControleDeDiagonaleEnCours(adversaire,platEssai);}
                         end;

                 if evaluerMaintenant
                   then
                     begin
                       noteCourante := -Evaluation(platEssai,adversaire,nbBlcEssai,nbNrEssai,
                                                jouablEssai,frontEssai,true,-beta,-alpha,nbEvalsRecursives);
                     end
                   else
                     begin
                       if (nbEvalues = 0) or (beta <= alpha+1)
                         then
                           noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                  profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                  -beta,-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut)
                         else
                           begin
                             noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                    profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                    pred(-alpha),-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                             if (alpha < notecourante) and (notecourante < beta) then
                               begin
                                 noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                        profMoins1,profMaximum,horizon,longPathPlus1,0,couleurDeCassio,
                                                        -beta,-notecourante,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                                  if (notecourante = succ(alpha)) then notecourante := alpha;
                               end;
                           end;
                      end;
                 inc(nbEvalues);

                 if (noteCourante > clefMaxDansGenerationCoupsLegaux) then clefMaxDansGenerationCoupsLegaux := noteCourante;
                 if (noteCourante > maxPourBestDef) then
                      begin
                        maxPourBestDef := noteCourante;
                        bstDef := iCourant;
                        {for k := 1 to profMoins1 do
                           meilleureSuiteGlb^[prof,k] := meilleureSuiteGlb^[profMoins1,k];}
                        if profMoins1 > 0 then
                          moveright(meilleureSuiteGlb^[profMoins1,1],meilleureSuiteGlb^[prof,1],profMoins1+profMoins1);
                        meilleureSuiteGlb^[prof,prof] := iCourant;
                        if noteCourante > alpha then
                          begin
                            alpha := noteCourante;
                            if utilise_hash_table_exacte then
                              begin
                                valeurExacteMin := maxPourBestDef;
                                {WritelnDansRapport('Appel de MetPosDansHashTableExacteMilieu (3)');}
                                MetPosDansHashTableExacteMilieu;
                                SetValMinEtMaxDeMilieu(maxPourBestDef,valeurExacteMax,QuelleHashTableExacte^[clefHashExacte]);
                                SetBestDefenseDansHashExacte(bstDef,QuelleHashTableExacte^[clefHashExacte]);
                              end;
                            if (alpha >= beta) then
                              begin
                                if utilise_hash_table then
                                  begin
                                    if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                                    gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                                  end;
                                ABScout := maxPourBestDef;
                                {EffaceCoupEtProf;}
                                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
											          if useMicroProfiler then EndMiniProfilerMilieu;
											          {$ENDC}
                                (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                                exit(ABScout);
                              end;
                          end;
                      end;


                 platEssai := pl;
                 jouablEssai := joua;
                 nbBlcEssai := nbBlancs;
                 nbNrEssai := nbNoirs;
                 frontEssai := fr;

                 end;
             end;
         end;

         for ii := 1 to nbKillerGlb^[prof] do
         BEGIN
           iCourant := KillerGlb^[prof,ii];
           if maxPourBestDef < valeurExacteMax then
           if (iCourant >= 11) and (iCourant <= 88) then
           if joua[iCourant] then
            if not(dejaEvalue[iCourant]) then
            begin
              dejaEvalue[iCourant] := true;
              if ModifPlat(iCourant,coul,platEssai,jouablEssai,nbBlcEssai,nbNrEssai,frontessai)
               then begin
                 suiteJoueeGlb^[prof] := iCourant;
                 aJoue := true;

                 conseilTurbulencePourLeFils := -1;

                 if (profMoins1 <= SelectivitePourCetteRecherche)
                   then
                     begin
                       {if (profMoins1 = SelectivitePourCetteRecherche)
                         then evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils))
                         else evaluerMaintenant := true;}
                       evaluerMaintenant := true;
                     end
                   else
                     if (profMoins1 > 0)
                       then evaluerMaintenant := false
                       else
                         begin
                           {evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils));}
                           evaluerMaintenant := true;
                           if evaluerMaintenant and not(utilisationNouvelleEval) then
                             evaluerMaintenant := PasDeBordDeCinqAttaque(adversaire,frontessai,platessai);
                           {if evaluerMaintenant and avecselectivite then
                             evaluerMaintenant := not(BordDeCinqUrgent(platessai,frontessai));}
                           {if evaluerMaintenant then
                                 evaluerMaintenant := PasDeControleDeDiagonaleEnCours(adversaire,platEssai);}
                         end;

                 if evaluerMaintenant
                   then
                     begin
                       noteCourante := -Evaluation(platEssai,adversaire,nbBlcEssai,nbNrEssai,
                                                jouablEssai,frontEssai,true,-beta,-alpha,nbEvalsRecursives);
                     end
                   else
                     begin
                       if (nbEvalues = 0) or (beta <= alpha+1)
                         then
                           noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                  profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                  -beta,-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut)
                         else
                           begin
                             noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                    profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                    pred(-alpha),-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                             if (alpha < notecourante) and (notecourante < beta) then
                               begin
                                 noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                        profMoins1,profMaximum,horizon,longPathPlus1,0,couleurDeCassio,
                                                        -beta,-notecourante,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                                  if (notecourante = succ(alpha)) then notecourante := alpha;
                               end;
                           end;
                      end;
                 inc(nbEvalues);

                 if (noteCourante > clefMaxDansGenerationCoupsLegaux) then clefMaxDansGenerationCoupsLegaux := noteCourante;
                 if (noteCourante > maxPourBestDef) then
                      begin
                        maxPourBestDef := noteCourante;
                        bstDef := iCourant;
                        {for k := 1 to profMoins1 do
                           meilleureSuiteGlb^[prof,k] := meilleureSuiteGlb^[profMoins1,k];}
                        if profMoins1 > 0 then
                          moveright(meilleureSuiteGlb^[profMoins1,1],meilleureSuiteGlb^[prof,1],profMoins1+profMoins1);
                        meilleureSuiteGlb^[prof,prof] := iCourant;
                        if noteCourante > alpha then
                          begin
                            alpha := noteCourante;
                            if utilise_hash_table_exacte then
                              begin
                                valeurExacteMin := maxPourBestDef;
                                {WritelnDansRapport('Appel de MetPosDansHashTableExacteMilieu (4)');}
                                MetPosDansHashTableExacteMilieu;
                                SetValMinEtMaxDeMilieu(maxPourBestDef,valeurExacteMax,QuelleHashTableExacte^[clefHashExacte]);
                                SetBestDefenseDansHashExacte(bstDef,QuelleHashTableExacte^[clefHashExacte]);
                              end;
                            if (alpha >= beta) then
                              begin
                                for t_counter := ii downto 2 do
                                  KillerGlb^[prof,t_counter] := KillerGlb^[prof,pred(t_counter)];
                                KillerGlb^[prof,1] := iCourant;

                                if utilise_hash_table then
                                  begin
                                    if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                                    gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                                  end;
                                ABScout := maxPourBestDef;
                                {EffaceCoupEtProf;}
                                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
											          if useMicroProfiler then EndMiniProfilerMilieu;
											          {$ENDC}
                                (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                                exit(ABScout);
                              end;
                          end;
                      end;


                 platEssai := pl;
                 jouablEssai := joua;
                 nbBlcEssai := nbBlancs;
                 nbNrEssai := nbNoirs;
                 frontEssai := fr;

                 end;        {  if ModifPlat  }
             end;            {  if joua[iCourant]  }
         end;                {  for ii := 1 to nbKillerGlb^[prof]  }



      if coul = pionNoir then
        begin
         {PrintTraceDebugageABScout('coul = '+NumEnString(coul));
         PrintTraceDebugageABScout('Avant tableHeurisBlanc[pere,0] dans ABSCout, avec pere = '+NumEnString(pere));
         PrintTraceDebugageABScout('tableHeurisBlanc[pere,0] = '+NumEnString(tableHeurisBlanc[pere,0]));}

         for ii := 1 to tableHeurisBlanc[pere,0] do
          begin
           iCourant := tableHeurisBlanc[pere,ii];
           if maxPourBestDef < valeurExacteMax then
           if (iCourant >= 11) and (iCourant <= 88) then
           if joua[iCourant] then
           if not(dejaEvalue[iCourant]) then
             begin
              dejaEvalue[iCourant] := true;
              if ModifPlat(iCourant,coul,platEssai,jouablEssai,nbBlcEssai,nbNrEssai,frontessai)
               then begin
                 suiteJoueeGlb^[prof] := iCourant;
                 aJoue := true;

                 conseilTurbulencePourLeFils := -1;

                 if (profMoins1 <= SelectivitePourCetteRecherche)
                   then
                     begin
                       {if (profMoins1 = SelectivitePourCetteRecherche)
                         then evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils))
                         else evaluerMaintenant := true;}
                       evaluerMaintenant := true;
                     end
                   else
                     if (profMoins1 > 0)
                       then evaluerMaintenant := false
                       else
                         begin
                           {evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils));}
                           evaluerMaintenant := true;
                           if evaluerMaintenant and not(utilisationNouvelleEval) then
                             evaluerMaintenant := PasDeBordDeCinqAttaque(adversaire,frontessai,platessai);
                           {if evaluerMaintenant and avecselectivite then
                             evaluerMaintenant := not(BordDeCinqUrgent(platessai,frontessai));}
                           {if evaluerMaintenant then
                                 evaluerMaintenant := PasDeControleDeDiagonaleEnCours(adversaire,platEssai);}
                         end;

                 if evaluerMaintenant
                   then
                     begin
                       noteCourante := -Evaluation(platEssai,adversaire,nbBlcEssai,nbNrEssai,
                                                jouablEssai,frontEssai,true,-beta,-alpha,nbEvalsRecursives);
                     end
                   else
                     begin
                       if (nbEvalues = 0) or (beta <= alpha+1)
                         then
                           noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                  profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                  -beta,-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut)
                         else
                           begin
                             noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                    profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                    pred(-alpha),-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                             if (alpha < notecourante) and (notecourante < beta) then
                               begin
                                 noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                        profMoins1,profMaximum,horizon,longPathPlus1,0,couleurDeCassio,
                                                        -beta,-notecourante,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                                 if (notecourante = succ(alpha)) then notecourante := alpha;
                               end;
                           end;
                      end;
                 inc(nbEvalues);

                 if (noteCourante > clefMaxDansGenerationCoupsLegaux) then clefMaxDansGenerationCoupsLegaux := noteCourante;
                 if (noteCourante > maxPourBestDef) then
                      begin
                        maxPourBestDef := noteCourante;
                        bstDef := iCourant;
                        {for k := 1 to profMoins1 do
                            meilleureSuiteGlb^[prof,k] := meilleureSuiteGlb^[profMoins1,k];}
                        if profMoins1 > 0 then
                          moveright(meilleureSuiteGlb^[profMoins1,1],meilleureSuiteGlb^[prof,1],profMoins1+profMoins1);
                        meilleureSuiteGlb^[prof,prof] := iCourant;
                        if noteCourante > alpha then
                          begin
                            alpha := noteCourante;
                            if utilise_hash_table_exacte then
                              begin
                                valeurExacteMin := maxPourBestDef;
                                {WritelnDansRapport('Appel de MetPosDansHashTableExacteMilieu (5)');}
                                MetPosDansHashTableExacteMilieu;
                                SetValMinEtMaxDeMilieu(maxPourBestDef,valeurExacteMax,QuelleHashTableExacte^[clefHashExacte]);
                                SetBestDefenseDansHashExacte(bstDef,QuelleHashTableExacte^[clefHashExacte]);
                              end;
                            if (alpha >= beta) then
                              begin
                                moveright(tableHeurisBlanc[pere,1],tableHeurisBlanc[pere,2],pred(ii));
		                            tableHeurisBlanc[pere,1] := iCourant;

                                if nbKillerGlb^[prof] < nbCoupsMeurtriers
                                  then
                                    begin
                                      nbKillerGlb^[prof] := nbKillerGlb^[prof]+1;
                                      for t_counter := nbKillerGlb^[prof] downto 2 do
                                         KillerGlb^[prof,t_counter] := KillerGlb^[prof,pred(t_counter)];
                                    end
                                  else
                                    for t_counter := nbCoupsMeurtriers downto 2 do
                                      KillerGlb^[prof,t_counter] := KillerGlb^[prof,pred(t_counter)];
                                KillerGlb^[prof,1] := iCourant;

                                if utilise_hash_table then
                                  begin
                                    if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                                    gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                                  end;
                                ABScout := maxPourBestDef;
                                {EffaceCoupEtProf;}
                                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
											          if useMicroProfiler then EndMiniProfilerMilieu;
											          {$ENDC}
                                (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                                exit(ABScout);
                              end;
                          end;
                      end;


                 platEssai := pl;
                 jouablEssai := joua;
                 nbBlcEssai := nbBlancs;
                 nbNrEssai := nbNoirs;
                 frontEssai := fr;

                 end;        {  if ModifPlat  }
             end;            {  if joua[iCourant]  }
          end
       end                   {  if coul = pionNoir  }
        else
         begin

           {PrintTraceDebugageABScout('coul = '+NumEnString(coul));
           PrintTraceDebugageABScout('Avant tableHeurisNoir[pere,0] dans ABSCout, avec pere = '+NumEnString(pere));
           PrintTraceDebugageABScout('tableHeurisNoir[pere,0] = '+NumEnString(tableHeurisNoir[pere,0]));}

           for ii := 1 to tableHeurisNoir[pere,0] do
           begin
           iCourant := tableHeurisNoir[pere,ii];
           if maxPourBestDef < valeurExacteMax then
           if (iCourant >= 11) and (iCourant <= 88) then
           if joua[iCourant] then
           if not(dejaEvalue[iCourant]) then
            begin
              dejaEvalue[iCourant] := true;
              if ModifPlat(iCourant,coul,platEssai,jouablEssai,nbBlcEssai,nbNrEssai,frontessai)
               then begin
                 suiteJoueeGlb^[prof] := iCourant;
                 aJoue := true;

                 conseilTurbulencePourLeFils := -1;

                 if (profMoins1 <= SelectivitePourCetteRecherche)
                   then
                     begin
                       {if (profMoins1 = SelectivitePourCetteRecherche)
                         then evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils))
                         else evaluerMaintenant := true;}
                       evaluerMaintenant := true;
                     end
                   else
                     if (profMoins1 > 0)
                       then evaluerMaintenant := false
                       else
                         begin
                           {evaluerMaintenant := not(EstTurbulent(platEssai,adversaire,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils));}
                           evaluerMaintenant := true;
                           if evaluerMaintenant and not(utilisationNouvelleEval) then
                             evaluerMaintenant := PasDeBordDeCinqAttaque(adversaire,frontessai,platessai);
                           {if evaluerMaintenant and avecselectivite then
                             evaluerMaintenant := not(BordDeCinqUrgent(platessai,frontessai));}
                           {if evaluerMaintenant then
                                 evaluerMaintenant := PasDeControleDeDiagonaleEnCours(adversaire,platEssai);}
                         end;

                 if evaluerMaintenant
                   then
                     begin
                       noteCourante := -Evaluation(platEssai,adversaire,nbBlcEssai,nbNrEssai,
                                                jouablEssai,frontEssai,true,-beta,-alpha,nbEvalsRecursives);
                     end
                   else
                     begin
                      if (nbEvalues = 0) or (beta <= alpha+1)
                         then
                           begin
                             noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                  profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                  -beta,-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                           end
                         else
                           begin
                             noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                    profMoins1,profMaximum,horizon,longPathPlus1,distPV+nbEvalues,couleurDeCassio,
                                                    pred(-alpha),-alpha,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                             if (alpha < notecourante) and (notecourante < beta) then
                               begin
                                 noteCourante := -ABScout(platEssai,jouablEssai,BestSuite,iCourant,adversaire,
                                                        profMoins1,profMaximum,horizon,longPathPlus1,0,couleurDeCassio,
                                                       -beta,-notecourante,nbBlcEssai,nbNrEssai,frontEssai,conseilTurbulencePourLeFils,canDoProbCut);
                                 if (notecourante = succ(alpha)) then notecourante := alpha;
                               end;
                           end;
                      end;
                 inc(nbEvalues);

                 if (noteCourante > clefMaxDansGenerationCoupsLegaux) then clefMaxDansGenerationCoupsLegaux := noteCourante;
                 if (noteCourante > maxPourBestDef) then
                      begin
                        maxPourBestDef := noteCourante;
                        bstDef := iCourant;
                        {for k := 1 to profMoins1 do
                           meilleureSuiteGlb^[prof,k] := meilleureSuiteGlb^[profMoins1,k];}
                        if profMoins1 > 0 then
                          moveright(meilleureSuiteGlb^[profMoins1,1],meilleureSuiteGlb^[prof,1],profMoins1+profMoins1);
                        meilleureSuiteGlb^[prof,prof] := iCourant;
                        if noteCourante > alpha then
                         begin
                          alpha := noteCourante;
                          if utilise_hash_table_exacte then
                            begin
                              valeurExacteMin := maxPourBestDef;
                              {WritelnDansRapport('Appel de MetPosDansHashTableExacteMilieu (6)');}
                              MetPosDansHashTableExacteMilieu;
                              SetValMinEtMaxDeMilieu(maxPourBestDef,valeurExacteMax,QuelleHashTableExacte^[clefHashExacte]);
                              SetBestDefenseDansHashExacte(bstDef,QuelleHashTableExacte^[clefHashExacte]);
                            end;
                          if (alpha >= beta) then
                            begin
                              Moveright(tableHeurisNoir[pere,1],tableHeurisNoir[pere,2],pred(ii));
                              tableHeurisNoir[pere,1] := iCourant;

                              if nbKillerGlb^[prof] < nbCoupsMeurtriers
                                then
                                  begin
                                    nbKillerGlb^[prof] := nbKillerGlb^[prof]+1;
                                    for t_counter := nbKillerGlb^[prof] downto 2 do
                                       KillerGlb^[prof,t_counter] := KillerGlb^[prof,pred(t_counter)];
                                  end
                                else
                                  for t_counter := nbCoupsMeurtriers downto 2 do
                                     KillerGlb^[prof,t_counter] := KillerGlb^[prof,pred(t_counter)];
                               KillerGlb^[prof,1] := iCourant;

                               if utilise_hash_table then
                                 begin
                                   if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;
                                   gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
                                 end;
                               ABScout := maxPourBestDef;
                               {EffaceCoupEtProf;}
                               {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
											         if useMicroProfiler then EndMiniProfilerMilieu;
											         {$ENDC}
                               (* WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout)); *)
                               exit(ABScout);
                             end;
                         end;
                      end;


                 platEssai := pl;
                 jouablEssai := joua;
                 nbBlcEssai := nbBlancs;
                 nbNrEssai := nbNoirs;
                 frontEssai := fr;

                 end;
             end;
          end;
        end;                  {  if coul = pionNoir .. else }


       END;  { ELSE de prof >= profMinimalePourTriDesCoups }

  {PrintTraceDebugageABScout('Fin de la boucle dans ABSCout');}


 sortie :

  if (interruptionReflexion <> pasdinterruption)
    then
      begin
        if utilise_hash_table then gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
        ABScout := -noteMax;
      end
    else
      begin

        if aJoue
          then
            begin
              if utilise_hash_table then
                begin
                  gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));

                  if conseil_dans_hash_table then HashTable^^[clefHashConseil] := bstDef;

                  if utilise_hash_table_exacte then
                    begin
                      {WritelnDansRapport('Appel de MetPosDansHashTableExacteMilieu (7)');}
                      MetPosDansHashTableExacteMilieu;
                      SetValMinEtMaxDeMilieu(valeurExacteMin,maxPourBestDef,QuelleHashTableExacte^[clefHashExacte]);
                      SetBestDefenseDansHashExacte(bstDef,QuelleHashTableExacte^[clefHashExacte]);
                    end;
                end;
              ABScout := maxPourBestDef;
            end
          else
            begin
              if utilise_hash_table then gClefHashage := BXOr(gClefHashage, (IndiceHash^^[coul,pere]));
              if DoitPasser(adversaire,pl,joua) then   { la partie est finie !}
                begin
                  for k := 1 to prof do meilleureSuiteGlb^[prof,k] := 0;
                  if nbBlancs+nbNoirs < 64
                    then
                      begin
                        if nbBlancs > nbNoirs
                          then
                            begin
                              nbNoirs2 := nbNoirs;
                              nbBlancs2 := 64-nbNoirs;
                            end
                          else
                            begin
                              nbNoirs2 := 64-nbBlancs;
                              nbBlancs2 := nbBlancs;
                            end;
                        if Coul = pionBlanc
      	                  then ABScout := 100*(nbBlancs2-nbNoirs2)
      	                  else ABScout := 100*(nbNoirs2-nbBlancs2);
                      end
                    else
                      begin
      	                if Coul = pionBlanc
      	                  then ABScout := 100*(nbBlancs-nbNoirs)
      	                  else ABScout := 100*(nbNoirs-nbBlancs);
      		            end;
                end
              else
                begin                             { passe !}
                  conseilTurbulence := -1;
                  noteCourante := ABScout(pl,joua,bstDef,pere,adversaire,prof,profMaximum,horizon,longPath,distPV,couleurDeCassio,
                                          -beta,-alpha,nbBlancs,nbNoirs,fr,conseilTurbulence,canDoProbCut);

                  ABScout      := -noteCourante;
                end;
            end;
      end;

   {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   if useMicroProfiler then EndMiniProfilerMilieu;
   {$ENDC}

   {WriteInTraceLog('Sortie ABSCout, magicCookie = '+NumEnString(magicCookieABSCout));}

 end;  { if (interruptionReflexion = pasdinterruption) then... }
 {EffaceCoupEtProf;}

 {PrintTraceDebugageABScout('Sortie de ABSCout');}

end;   { ABScout }






procedure InitUnit_AB_Scout;
begin
  compteur_tentative_ProbCut := 0;
  compteur_echec_ProbCut := 0;
  SelectivitePourCetteRecherche := -6;
end;

procedure LibereMemoireUnit_AB_SCout;
begin
end;

end.
