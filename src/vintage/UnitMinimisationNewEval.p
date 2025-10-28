UNIT UnitMinimisationNewEval;

INTERFACE







 USES UnitDefCassio;



procedure LineMinimisationChi2(var p,xi : VectNewEval; valeurChi2PourP : TypeReel; var fret : TypeReel);
procedure ConjugateGradientChi2(var whichEval : VectNewEval; ftol : TypeReel; var iter : SInt32; var fret : TypeReel; avecRabotagePatternsRares : boolean);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitUtilitaires, UnitServicesDialogs, UnitRapport, MyStrings, UnitGestionDuTemps, UnitFichiersTEXT
    , UnitPositionEtTrait, UnitVecteursEval, UnitNouvelleEval, UnitChi2NouvelleEval, UnitMinimisation ;
{$ELSEC}
    ;
    {$I prelink/MinimisationNewEval.lk}
{$ENDC}


{END_USE_CLAUSE}











var MemoisationFonctionLigneChi2:
      record
        nbValeursMemoisees : SInt32;
        positionSurLaLigne : array[0..100] of TypeReel;
        tableValeurChi2 : array[0..100] of TypeReel;
      end;


procedure VideTableMemoisationFonctionLigneChi2;
var k : SInt32;
begin
  with MemoisationFonctionLigneChi2 do
    begin
      nbValeursMemoisees := 0;
      for k := 0 to 100 do
        begin
          positionSurLaLigne[k] := -1.0;
          tableValeurChi2[k] := -1.0;
        end;
    end;
end;

procedure AjoutePaireDansTableMemoisationFonctionLigneChi2(lambda,theChi2 : TypeReel);
begin
  with MemoisationFonctionLigneChi2 do
    if nbValeursMemoisees < 100 then
    begin
      inc(nbValeursMemoisees);
      positionSurLaLigne[nbValeursMemoisees] := lambda;
      tableValeurChi2[nbValeursMemoisees] := theChi2;
    end;
end;

procedure InitialiseFonctionLigneChi2(var p,xi : VectNewEval);
begin
  if memoireAlloueeFonctionLigneChi2 then
    begin
      CopierPointeursVecteursEval(p,vecteursFonctionLigneChi2.p);
      CopierPointeursVecteursEval(xi,vecteursFonctionLigneChi2.dir);
    end;
  VideTableMemoisationFonctionLigneChi2;
end;


function FonctionLigneChi2(lambda : TypeReel) : TypeReel;
var k : SInt32;
    theChi2 : TypeReel;
begin
  if memoireAlloueeFonctionLigneChi2 then
    with vecteursFonctionLigneChi2 do
      begin
        {on cherche si la valeur a ete memoisee}
         with MemoisationFonctionLigneChi2 do
           if nbValeursMemoisees > 0 then
             for k := 1 to nbValeursMemoisees do
               if (positionSurLaLigne[k] = lambda) and (tableValeurChi2[k] >= 0.0) then
                 begin  {trouve !}
                   if not(verboseMinimisationChi2) then
                      begin
                        WriteStringAndReelDansRapport('Memoisation utile dans FonctionLigneChi2 !! lambda = ',lambda,10);
                        WritelnStringAndReelDansRapport('  =>  chi2 = ',tableValeurChi2[k],10);
                      end;
                   FonctionLigneChi2 := tableValeurChi2[k];
                   exit;
                 end;

        if not(verboseMinimisationChi2) then
          WritelnStringAndReelDansRapport('FonctionLigneChi2 : lambda = ',lambda,10);
        CombinaisonLineaireVecteurEval(P,dir,1.0,lambda,P);  { P := P+lambda*dir; }
        theChi2 := CalculeChi2(P);
        CombinaisonLineaireVecteurEval(P,dir,1.0,-lambda,P);  { P := P-lambda*dir;  on remet l'ancien P }

        {on memoise le resultat}
        AjoutePaireDansTableMemoisationFonctionLigneChi2(lambda,theChi2);

        FonctionLigneChi2 := theChi2;
      end;
end;

procedure LineMinimisationChi2(var p,xi : VectNewEval; valeurChi2PourP : TypeReel; var fret : TypeReel);
const
  tol = 1.0e-2;
var
  xx,lambda,fx,fb,fa,bx,ax : TypeReel;
begin

  DoSystemTask(AQuiDeJouer);
  if Quitter then exit;

  if memoireAlloueeFonctionLigneChi2 and not(Quitter) then
    begin
		  InitialiseFonctionLigneChi2(p,xi);
		  AjoutePaireDansTableMemoisationFonctionLigneChi2(0.0,valeurChi2PourP);
		  ax := 0.0;
		  xx := 0.05;

		  if not(verboseMinimisationChi2) then
		    WritelnDansRapport('entrée dans LineMinimisationChi2');

      DoSystemTask(AQuiDeJouer);
      if Quitter then exit;

		  SetPrefixeCalculeChi2('MinimumBracketting');
		  SetPrefixeCalculeChi2EtGradient('MinimumBracketting');
		  if not(verboseMinimisationChi2) then
		    WritelnDansRapport('appel de MinimumBracketting');

		  MinimumBracketting(FonctionLigneChi2,ax,xx,bx,fa,fx,fb);

		  DoSystemTask(AQuiDeJouer);
      if Quitter then exit;

		  SetPrefixeCalculeChi2('MinimisationParBrent');
		  SetPrefixeCalculeChi2EtGradient('MinimisationParBrent');
		  if not(verboseMinimisationChi2) then
		    WritelnDansRapport('appel de MinimisationParBrent');

		  fret := MinimisationParBrent(FonctionLigneChi2,ax,xx,bx,tol,lambda);

		  DoSystemTask(AQuiDeJouer);
      if Quitter then exit;

		  HomothetieVecteurEval(xi,xi,lambda);  {xi := lambda*xi}
		  AddVecteurEval(p,xi,p);               {p := p+xi}
		end;
end;


{calcule la meilleure evaluation, au sens des moindres carres,
 des parties de la liste. Attention : whichEval est ecrase}
procedure ConjugateGradientChi2(var whichEval : VectNewEval; ftol : TypeReel; var iter : SInt32; var fret : TypeReel; avecRabotagePatternsRares : boolean);
const
  itmax = 100;
  eps = 1.0e-10;
label finNormale;
var
  its : SInt32;
  gg,gam,chi2,dgg : TypeReel;
  erreurES : OSErr;
  fichierEval : FichierTEXT;
  tick : SInt32;
begin
  verboseMinimisationChi2 := false;

  if (nbPartiesActives <= 0) then
    begin
      AlerteSimple('Aucune partie active pour ConjugateGradientChi2 !!!');
      exit;
    end;

  if VecteurEvalEstVide(whichEval) or
     not(memoireAlloueeConjugateGradientChi2) or
     not(memoireAlloueeFonctionLigneChi2) then
     begin
       AlerteSimple('Pas assez de memoire pour allouer les vecteurs pour ConjugateGradientChi2 !!!');
       exit;
     end;

  (*
  if not(verboseMinimisationChi2) then
        begin
          WritelnDansRapport('avant SmoothThisEvaluation…');
          EcritVecteurMobiliteDansRapport(whichEval);
        end;

  WritelnDansRapport('appel de SmoothThisEvaluation…');
  SmoothThisEvaluation(whichEval,occurences);
  CalculeEvalPatternsInexistantParEchangeCouleur(whichEval,occurences);
  AbaisseEvalPatternsRares(whichEval,occurences,10.0,8.0);
  WritelnDansRapport('fin de SmoothThisEvaluation !');

  if not(verboseMinimisationChi2) then
    begin
      WritelnDansRapport('après SmoothThisEvaluation…');
      EcritVecteurMobiliteDansRapport(whichEval);
    end;
  *)

  WriteDansRapport('création (et vidage) du fichier "BestEvaluation"…');
  erreurES := FichierTexteDeCassioExiste('BestEvaluation',fichierEval);
  if erreurES = fnfErr {-43 => fichier non trouvé, on le crée}
    then erreurES := CreeFichierTexteDeCassio('BestEvaluation',fichierEval);
  if erreurES = NoErr then
     begin
       erreurES := OuvreFichierTexte(fichierEval);
       if erreurES <> NoErr then WritelnNumDansRapport(' => erreurES = ',erreurES);
       erreurES := VideFichierTexte(fichierEval);
       if erreurES <> NoErr then WritelnNumDansRapport(' => erreurES = ',erreurES);
       erreurES := FermeFichierTexte(fichierEval);
       if erreurES <> NoErr then WritelnNumDansRapport(' => erreurES = ',erreurES);
     end;
  WritelnNumDansRapport(' => erreurES = ',erreurES);


  SetPrefixeCalculeChi2('ConjugateGradientChi2');
  SetPrefixeCalculeChi2EtGradient('ConjugateGradientChi2');
  if not(verboseMinimisationChi2) then
    WritelnDansRapport('entrée dans ConjugateGradientChi2');

  SetBornePourCalculGradientChi2(1.0);
  with vecteursConjugateGradientChi2 do
    begin
      if avecRabotagePatternsRares then
        begin
          WriteDansRapport('rabotage de l''evaluation…');
          AbaisseEvalPatternsRares(whichEval,occurences,10.0,8.0);
          WritelnDansRapport(' OK');
        end;

      chi2 := CalculeChi2EtGradient(whichEval,xi);

      if avecRabotagePatternsRares then
        begin
          WriteDansRapport('rabotage du gradient…');
          AbaisseGradientPatternsRares(whichEval,xi,occurences,10.0,8.0);
          WritelnDansRapport(' OK');
        end;


      CopierOpposeVecteurEval(xi,g);  { g := -xi }
      CopierVecteurEval(g,h);         { h := g }
      CopierVecteurEval(h,xi);        { xi := h }
    end;

  tick := TickCount;

  WritelnStringAndReelDansRapport('ConjugateGradientChi2 : iter = 0 => temps = '+IntToStr(TickCount-tick)+', chi2 = ',chi2,10);


  for its := 1 to itmax do
    begin

      DoSystemTask(AQuiDeJouer);
      if Quitter then exit;

      iter := its;

      if iter <= 30
        then SetBornePourCalculGradientChi2(1.0)
        else SetBornePourCalculGradientChi2(1.0*(iter-30));

      if avecRabotagePatternsRares then
        begin
          WriteDansRapport('rabotage du gradient…');
          AbaisseGradientPatternsRares(whichEval,vecteursConjugateGradientChi2.xi,occurences,10.0,8.0);
          WritelnDansRapport(' OK');
        end;

      LineMinimisationChi2(whichEval,vecteursConjugateGradientChi2.xi,chi2,fret);

      if avecRabotagePatternsRares then
        begin
          WriteDansRapport('rabotage de l''evaluation…');
          AbaisseEvalPatternsRares(whichEval,occurences,10.0,8.0);
          WritelnDansRapport(' OK');
        end;

      DoSystemTask(AQuiDeJouer);
      if Quitter then exit;

      WritelnStringAndReelDansRapport('ConjugateGradientChi2 : iter = '+IntToStr(iter)+' => temps = '+IntToStr(TickCount-tick)+', chi2 = ',fret,10);

      (*
      if not(verboseMinimisationChi2) then
        begin
          WritelnDansRapport('avant SmoothThisEvaluation…');
          EcritVecteurMobiliteDansRapport(whichEval);
        end;
      WritelnDansRapport('appel de SmoothThisEvaluation…');
      SmoothThisEvaluation(whichEval,occurences);
      CalculeEvalPatternsInexistantParEchangeCouleur(whichEval,occurences);
      AbaisseEvalPatternsRares(whichEval,occurences,10.0,8.0);
      WritelnDansRapport('fin de SmoothThisEvaluation !');
      if not(verboseMinimisationChi2) then
        begin
          WritelnDansRapport('après SmoothThisEvaluation…');
          EcritVecteurMobiliteDansRapport(whichEval);
        end;
      *)

      if not(verboseMinimisationChi2) then
        WriteDansRapport('Ecriture de l''évaluation dans le fichier…');
      erreurES := OuvreFichierTexte(fichierEval);
      if erreurES <> NoErr then WritelnNumDansRapport(' => erreurES = ',erreurES);
      erreurES := VideFichierTexte(fichierEval);
      if erreurES <> NoErr then WritelnNumDansRapport(' => erreurES = ',erreurES);
      erreurES := EcritEvalDansFichierTexte(fichierEval,whichEval);
      if erreurES <> NoErr then WritelnNumDansRapport(' => erreurES = ',erreurES);
      erreurES := FermeFichierTexte(fichierEval);
      if erreurES <> NoErr then WritelnNumDansRapport(' => erreurES = ',erreurES);
      if not(verboseMinimisationChi2) then
        WritelnDansRapport(' OK');

      DoSystemTask(AQuiDeJouer);
      if Quitter then exit;

      if not(verboseMinimisationChi2) then
        EcritQuelsquesPositionsPartieAleatoireDansListe;
      {if not(verboseMinimisationChi2) then
        EcritVecteurMobiliteDansRapport(whichEval);}

      DoSystemTask(AQuiDeJouer);
      if Quitter then exit;

      if (2*Abs(fret-chi2) <= ftol*(Abs(fret)+Abs(chi2)+eps))
        then goto finNormale;

      with vecteursConjugateGradientChi2 do
        begin

          SetPrefixeCalculeChi2('ConjugateGradientChi2');
          SetPrefixeCalculeChi2EtGradient('ConjugateGradientChi2');

          if avecRabotagePatternsRares then
            begin
              WriteDansRapport('rabotage de l''evaluation…');
              AbaisseEvalPatternsRares(whichEval,occurences,10.0,8.0);
              WritelnDansRapport(' OK');
            end;

          chi2 := CalculeChi2EtGradient(whichEval,xi);

          if avecRabotagePatternsRares then
            begin
              WriteDansRapport('rabotage du gradient…');
              AbaisseGradientPatternsRares(whichEval,xi,occurences,10.0,8.0);
              WritelnDansRapport(' OK');
            end;

          if not(verboseMinimisationChi2) then
            WritelnStringAndReelDansRapport('ConjugateGradientChi2 : iter = '+IntToStr(iter)+' => chi2 = ',chi2,10);

          gg := ProduitScalaireVecteurEval(g,g);    { gg := g.g }
       (* dgg := ProduitScalaireVecteurEval(xi,xi); { dgg := xi.xi , Fletcher-Reeves }  *)
          dgg := CombinaisonScalaireVecteurEval(xi,g,xi,1.0,1.0);  { dgg := (xi+g).xi , Polak-Ribiere }
          if gg = 0.0 then
            begin
              WritelnDansRapport('gradient nul dans ConjugateGradientChi2 =  >  gagné !');
              goto finNormale;       { norme du gradient = 0 ? gagne !}
            end;
          gam := dgg/gg;
          CopierOpposeVecteurEval(xi,g);                 { g := -xi }
          CombinaisonLineaireVecteurEval(g,h,1.0,gam,h); { h := g + gam*h }
          CopierVecteurEval(h,xi);                       { xi := h }
		    end;
    end;

  WritelnDansRapport('Pause dans la routine MinimisationMultidimensionnelleParConjugateGradient : trop d''iterations');
  finNormale :
end;


END.
