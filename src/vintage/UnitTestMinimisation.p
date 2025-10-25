UNIT UnitTestMinimisation;


INTERFACE








procedure TestMinimisation;
procedure TestStraightLineFitting;

procedure OptimiserLaFermeDuRallye;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDefCassio, Timer, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitMinimisation, UnitRapport, UnitStatisticalFitting, MyStrings, MyMathUtils
    , UnitBigVectors, UnitPositionEtTrait, UnitGestionDuTemps, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/TestMinimisation.lk}
{$ENDC}


{END_USE_CLAUSE}





var attraction : array[1..7,1..7] of TypeReel;
    barriere : array[1..7] of TypeReel;


procedure BornerLesAnimauxDeLaFerme(var animaux : PointMultidimensionnel; var bornage : boolean);
var i : SInt32;
    left,right,top,bottom : TypeReel;
begin

  left   := 90.0  ;
  right  := 441.0 ;
  top    := 215.0 ;
  bottom := 465.0 ;

  bornage := false;

  for i := 1 to 7 do
    begin
      if (animaux^[i] < left)       then begin animaux^[i] := left       ;  bornage := true; end;
      if (animaux^[i] > right)      then begin animaux^[i] := right      ;  bornage := true; end;
      if (animaux^[i + 7] < top)    then begin animaux^[i + 7] := top    ;  bornage := true; end;
      if (animaux^[i + 7] > bottom) then begin animaux^[i + 7] := bottom ;  bornage := true; end;
    end;

end;

function FermeDuRallyeMathematique(var animaux : PointMultidimensionnel) : TypeReel;
var i,j : SInt32;
    note : TypeReel;
    left,right,top,bottom : TypeReel;
    x,y : array[1..7] of TypeReel;
    dist : array[1..7,1..7] of TypeReel;
    distBarriere : TypeReel;
    bornage : boolean;
begin

    BornerLesAnimauxDeLaFerme(animaux, bornage);

    x[1] := 1.0 * animaux^[1];
    x[2] := 1.0 * animaux^[2];
    x[3] := 1.0 * animaux^[3];
    x[4] := 1.0 * animaux^[4];
    x[5] := 1.0 * animaux^[5];
    x[6] := 1.0 * animaux^[6];
    x[7] := 1.0 * animaux^[7];
    y[1] := 1.0 * animaux^[8];
    y[2] := 1.0 * animaux^[9];
    y[3] := 1.0 * animaux^[10];
    y[4] := 1.0 * animaux^[11];
    y[5] := 1.0 * animaux^[12];
    y[6] := 1.0 * animaux^[13];
    y[7] := 1.0 * animaux^[14];

    if bornage
       then note := -10000000.0
       else note := 0;


    for i := 1 to 7 do
       for j := 1 to 7 do
         dist[i,j] := sqrt((x[i]-x[j])*(x[i]-x[j]) + (y[i]-y[j])*(y[i]-y[j]));

    left   := 90.0  ;
    right  := 441.0 ;
    top    := 215.0 ;
    bottom := 465.0 ;

    for i := 1 to 7 do
      begin
        distBarriere := 1000000.0;

        if ((x[i]-left)   <  distBarriere)  then distBarriere := (x[i]-left);
        if ((right-x[i])  <  distBarriere)  then distBarriere := (right-x[i]);
        if ((y[i]-top)    <  distBarriere)  then distBarriere := (y[i]-top);
        if ((bottom-y[i]) <  distBarriere)  then distBarriere := (bottom-y[i]);

        note := note + barriere[i]*sqrt(distBarriere);
      end;

    for i := 1 to 7 do
      for j := 1 to 7 do
        note := note + attraction[i,j]*sqrt(dist[i,j]) - 100.0/(1 + dist[i,j]);

    note := (50.0 * (note - 200.0));

    FermeDuRallyeMathematique := note;

end;








function f(x : PointMultidimensionnel) : TypeReel;
begin
  f := sqr(x^[1]-1.0)+sqr(x^[2]+5.0)+sqr(x^[3]-3.141592659);
end;


procedure TestMinimisation;
var j,n,nbiter : SInt32;
    p : PointMultidimensionnel;
    resultat,tolerance : TypeReel;
begin
  n := 3;
  if AllocatePointMultidimensionnel(n,p) then
    begin
      for j := 1 to n do
        p^[j] := 100.0;

      tolerance := 0.001;
      MinimisationMultidimensionnelleParConjugateGradient(f,p,tolerance,nbiter,resultat);

      WritelnNumDansRapport('nbiter = ',nbiter);
      WritelnDansRapport('positions du minimum :');
      for j := 1 to n do
        begin
          WritelnDansRapport('p['+NumEnString(j)+'] = '+ReelEnStringAvecDecimales(p^[j],10));
        end;
      WritelnDansRapport('minimum = '+ReelEnStringAvecDecimales(resultat,10));

      DisposePointMultidimensionnel(p);
    end;

end;

procedure TestStraightLineFitting;
var n,k : SInt32;
    valPetiteProf,valGrandeProf : TypeReel;
    x,y,sigma : PointMultidimensionnel;
    a,b,sigmaa,sigmab,chi2,q : TypeReel;
    pente : TypeReel;
begin
  n := 100;
  x := NIL;
  y := NIL;
  sigma := NIL;
  if AllocatePointMultidimensionnel(n,x) and
     AllocatePointMultidimensionnel(n,y) then
    begin
      RandomizeTimer;
      for k := 1 to n do
        begin

          pente := Abs(Random)/32768.0;   {nombre aleatoire entre 0.0 et 1.0}

          valPetiteProf := RandomLongintEntreBornes(-6400,6400);
          valGrandeProf := pente*valPetiteProf + RandomLongintEntreBornes(-500,500);

          x^[k] := valPetiteProf;
          y^[k] := valGrandeProf;
        end;



      StraightLineFitting(x,y,sigma,n,false,a,b,sigmaa,sigmab,chi2,q);

      WritelnDansRapport('a = '+ReelEnStringAvecDecimales(a,10));
      WritelnDansRapport('b = '+ReelEnStringAvecDecimales(b,10));
      WritelnDansRapport('sigmaa = '+ReelEnStringAvecDecimales(sigmaa,10));
      WritelnDansRapport('sigmab = '+ReelEnStringAvecDecimales(sigmab,10));
      WritelnDansRapport('chi2 = '+ReelEnStringAvecDecimales(chi2,10));
      WritelnDansRapport('sigdata = '+ReelEnStringAvecDecimales(sqrt(chi2/(n-2)),10));
      WritelnDansRapport('q = '+ReelEnStringAvecDecimales(q,10));

      DisposePointMultidimensionnel(x);
      DisposePointMultidimensionnel(y);
      DisposePointMultidimensionnel(sigma);
    end;


end;


procedure EcrireSolutionDeLaFerme(var animaux : PointMultidimensionnel);
var score : TypeReel;
begin
  score := FermeDuRallyeMathematique(animaux);
  WritelnStringAndReelDansRapport('score = ',score, 10);
  WritelnDansRapport('');
  WritelnDansRapport('  ane = '+ReelEnString(animaux^[1]) + ' ' + ReelEnString(animaux^[8]));
  WritelnDansRapport('  cheval = '+ReelEnString(animaux^[2]) + ' ' + ReelEnString(animaux^[9]));
  WritelnDansRapport('  chevre = '+ReelEnString(animaux^[3]) + ' ' + ReelEnString(animaux^[10]));
  WritelnDansRapport('  cochon = '+ReelEnString(animaux^[4]) + ' ' + ReelEnString(animaux^[11]));
  WritelnDansRapport('  lapin = '+ReelEnString(animaux^[5]) + ' ' + ReelEnString(animaux^[12]));
  WritelnDansRapport('  mouton = '+ReelEnString(animaux^[6]) + ' ' + ReelEnString(animaux^[13]));
  WritelnDansRapport('  vache = '+ReelEnString(animaux^[7]) + ' ' + ReelEnString(animaux^[14]));
  WritelnDansRapport('');
end;


procedure GetRandomInitialePositionDeLaFerme(var animaux : PointMultidimensionnel);
var i : SInt32;
begin
  for i := 1 to 7 do
    begin
      animaux^[i]     := RandomEntreBornes(90,441);
      animaux^[i + 7] := RandomEntreBornes(215,465);
    end;
end;


procedure OptimisationLocaleDeLaFerme(var animaux, aux : PointMultidimensionnel; temperature : SInt32);
var i_x,j_x,k_x,i_y,j_y,k_y,t : SInt32;
    best_i_x,best_j_x,best_k_x : SInt32;
    best_i_y,best_j_y,best_k_y : SInt32;
    oldScore,bestScore,score : TypeReel;
    changer : array[1..3] of SInt32;
    temperature_i_x,temperature_j_x,temperature_k_x : SInt32;
    temperature_i_y,temperature_j_y,temperature_k_y : SInt32;
begin

  oldScore := FermeDuRallyeMathematique(animaux);

  bestScore := oldScore;

  for t := 1 to 3 do
    changer[t] := RandomEntreBornes(1,7);

   temperature_i_x := RandomEntreBornes(1,temperature);
   temperature_i_y := RandomEntreBornes(1,temperature);

   temperature_j_x := RandomEntreBornes(1,temperature);
   temperature_j_y := RandomEntreBornes(1,temperature);

   temperature_k_x := RandomEntreBornes(1,temperature);
   temperature_k_y := RandomEntreBornes(1,temperature);


  // temperature_i := temperature;
  // temperature_j := temperature;
  // temperature_k := temperature;

  if (changer[2] = changer[1]) then
    begin
      temperature_j_x := 0;
      temperature_j_y := 0;
    end;
  if (changer[3] = changer[2]) or (changer[3] = changer[1]) then
    begin
      temperature_k_x := 0;
      temperature_k_y := 0;
    end;

  i_x := 0;
  i_y := 0;
  k_x := 0;
  k_y := 0;
  j_x := 0;
  j_y := 0;

  for i_x := -1 to 1 do
  for i_y := -1 to 1 do
    for j_x := -1 to 1 do
    for j_y := -1 to 1 do
      // for k_x := -1 to 1 do  // enlever les commentaires pour permettre
      // for k_y := -1 to 1 do  // à 3 variables de changer simultanement
        begin
          for t := 1 to 14 do
            aux^[t] := animaux^[t];

          aux^[changer[1]]     := aux^[changer[1]]     + i_x * temperature_i_x;
          aux^[changer[1] + 7] := aux^[changer[1] + 7] + i_y * temperature_i_y;

          aux^[changer[2]]     := aux^[changer[2]]     + j_x * temperature_j_x;
          aux^[changer[2] + 7] := aux^[changer[2] + 7] + j_y * temperature_j_y;

          aux^[changer[3]]     := aux^[changer[3]]     + k_x * temperature_k_x;
          aux^[changer[3] + 7] := aux^[changer[3] + 7] + k_y * temperature_k_y;

          score := FermeDuRallyeMathematique(aux);

          if score >= bestScore - 0.05  then
            begin
              best_i_x := i_x;
              best_j_x := j_x;
              best_k_x := k_x;

              best_i_y := i_y;
              best_j_y := j_y;
              best_k_y := k_y;

              bestScore := score;
            end;

        end;

  if bestScore > oldScore then
    begin

      for t := 1 to 14 do
        aux^[t] := animaux^[t];

      aux^[changer[1]]     := aux^[changer[1]]     + best_i_x * temperature_i_x;
      aux^[changer[1] + 7] := aux^[changer[1] + 7] + best_i_y * temperature_i_y;

      aux^[changer[2]]     := aux^[changer[2]]     + best_j_x * temperature_j_x;
      aux^[changer[2] + 7] := aux^[changer[2] + 7] + best_j_y * temperature_j_y;

      aux^[changer[3]]     := aux^[changer[3]]     + best_k_x * temperature_k_x;
      aux^[changer[3] + 7] := aux^[changer[3] + 7] + best_k_y * temperature_k_y;

      for t := 1 to 14 do
        animaux^[t] := aux^[t];
    end;

end;

function OptimisationParRecuitSimule(var animaux,aux : PointMultidimensionnel) : TypeReel;
var i,temperature : SInt32;
begin
  for i := 1 to 10000 do
    begin
      temperature := 1 + (i mod 300);
      OptimisationLocaleDeLaFerme(animaux, aux, temperature);

      // WritelnNumDansRapport('Dans RecuitSimule, temp = '+NumEnString(temperature) + ', iter = ',i);
      // EcrireSolutionDeLaFerme(animaux);
    end;

  for i := 1 to 2000 do
    begin
      temperature := 1 + (i mod 10);
      OptimisationLocaleDeLaFerme(animaux, aux, temperature);

      // WritelnNumDansRapport('Dans RecuitSimule, temp = '+NumEnString(temperature) + ', iter = ',i);
      // EcrireSolutionDeLaFerme(animaux);
    end;


  //WritelnDansRapport('############');


  OptimisationParRecuitSimule := FermeDuRallyeMathematique(animaux);
end;


procedure OptimiserLaFermeDuRallye;
var animaux,aux,best : PointMultidimensionnel;
    i, j, t, tickDepart : SInt32;
    score, bestScore : TypeReel;
    vals : array[1..7] of String255;
    s : array[1..7] of String255;
    fooCalculateur, tempoRapportLog : boolean;
    iter : SInt32;
begin

  RandomizeTimer;

  for i := 1 to 7 do
      for j := 1 to 7 do
        attraction[i,j] := 0.0;

    barriere[1] := 12;
    barriere[2] := 18;
    barriere[3] := 9;
    barriere[4] := 6;
    barriere[5] := 2;
    barriere[6] := 6;
    barriere[7] := 7;

    vals[1] := '0 -2 2 2 -1 3 3';
    vals[2] := '-2 0 3 2 -1 1 2';
    vals[3] := '2 3 0 3 -1 -3 2';
    vals[4] := '2 2 3 0 -2 -3 3';
    vals[5] := '-1 -1 -1 -2 0 -1 -3';
    vals[6] := '3 1 -3 -3 -1 0 1';
    vals[7] := '3 2 2 3 -3 1 0';

    for i := 1 to 7 do
      begin
        Parser6(vals[i],s[1],s[2],s[3],s[4],s[5],s[6],s[7]);
        for j := 1 to 7 do
          attraction[i,j] := ChaineEnLongint(s[j]);
      end;


  tempoRapportLog := GetEcritToutDansRapportLog;
  SetEcritToutDansRapportLog(true);
  SetCassioEstEnTrainDeReflechir(true,@fooCalculateur);


  if AllocatePointMultidimensionnel(16,animaux) and
     AllocatePointMultidimensionnel(16,aux) and
     AllocatePointMultidimensionnel(16,best) then
    begin
      // position initiale
      for i := 1 to 14 do
        animaux^[i] := 250.0 + 10 * i;

      tickDepart := TickCount;

      bestScore := - 1000000.0;

      iter := 0;
      while not(Quitter) do
        begin
          inc(iter);
          //WritelnNumDansRapport('iter = ',iter);

          kWNESleep := 0;
          DoSystemTask(AQuiDeJouer);

          GetRandomInitialePositionDeLaFerme(animaux);
          score := OptimisationParRecuitSimule(animaux,aux);

          if score > bestScore then
            begin
              bestScore := score;

              WritelnDansRapport('NEW BEST SCORE : ');
              EcrireSolutionDeLaFerme(animaux);

              for t := 1 to 14 do
                best^[t] := animaux^[t];

            end;

          kWNESleep := 0;
          DoSystemTask(AQuiDeJouer);
        end;

      WritelnDansRapport('#################');
      WritelnNumDansRapport('nombre d''iterations = ',iter);
      WritelnNumDansRapport('temps en secondes = ',(Tickcount - tickDepart) div 60);
      WritelnDansRapport('TERMINE : l''optimum trouvé est :');
      EcrireSolutionDeLaFerme(best);

    end;

  SetCassioEstEnTrainDeReflechir(fooCalculateur,NIL);
  SetEcritToutDansRapportLog(tempoRapportLog);

  Quitter := false;
end;




END.
