UNIT UnitEstimationCharge;



INTERFACE


 USES UnitDefCassio;


procedure InitUnitEstimationCharge;
function InitCoeffsEstimationCharge : boolean;
procedure LibereMemoireUnitEstimationCharge;


procedure AjouterDataEstimationCharge(prof,rang,mobilite,indexMu,alpha,beta: SInt32; eval,vraiTempsEnTicks : TypeReel);



function TempsEstimeEnTicksPourResoudreCettePositionAvecCesCoeffs(prof,rang,mobilite,indexMu,alpha,beta : SInt32; eval : TypeReel; coeffs : PointMultidimensionnel) : TypeReel;

function TempsEstimeEnTicksPourResoudreCettePosition(prof,rang,mobilite,indexMu,alpha,beta : SInt32; eval : TypeReel) : TypeReel;
function TempsEstimeEnSecondesPourResoudreCettePosition(prof,rang,mobilite,indexMu,alpha,beta : SInt32; eval : TypeReel) : TypeReel;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}




{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitMinimisation, UnitRapport, MyStrings, UnitBigVectors, MyMathUtils, UnitServicesRapport ;
{$ELSEC}
    {$I prelink/EstimationCharge.lk}
{$ENDC}


{END_USE_CLAUSE}






const kMaxNombreDataEstimationCharge = 10000;

var coeffEstimationTemps : PointMultidimensionnel;

    dataEstimationCharge : record
                             cardinal        : SInt32;
                             nbPoints        : SInt32;
                             points : packed array[1..kMaxNombreDataEstimationCharge] of
                                        record
                                          prof : SInt16;
                                          rang : SInt16;
                                          mobilite : SInt16;
                                          eval : TypeReel;
                                          indexMu : SInt16;
                                          alpha : SInt16;
                                          beta : SInt16;
                                          temps : TypeReel;
                                        end;
                           end;

     penalitePourKendall : SInt32;


function InitCoeffsEstimationCharge : boolean;
var n,j : SInt32;
begin

  InitCoeffsEstimationCharge := false;

  n := 7;

  if AllocatePointMultidimensionnel(n,coeffEstimationTemps) then
    begin
      for j := 1 to n do coeffEstimationTemps^[j] := 0.01;


coeffEstimationTemps^[1] := 0.16621;
coeffEstimationTemps^[2] := 0.35808;
coeffEstimationTemps^[3] := -0.04172;
coeffEstimationTemps^[4] := 1.46661;
coeffEstimationTemps^[5] := 0.00094;
coeffEstimationTemps^[6] := 0.27046;
coeffEstimationTemps^[7] := 0.42524;


      InitCoeffsEstimationCharge := true;
    end;

end;


procedure InitUnitEstimationCharge;
begin
  dataEstimationCharge.nbPoints := 0;

  if InitCoeffsEstimationCharge
    then dataEstimationCharge.cardinal := 0
    else dataEstimationCharge.cardinal := -1;
end;


procedure LibereMemoireUnitEstimationCharge;
begin
  DisposePointMultidimensionnel(coeffEstimationTemps);
end;


function TempsEstimeEnTicksPourResoudreCettePositionAvecCesCoeffs(prof,rang,mobilite,indexMu,alpha,beta : SInt32; eval : TypeReel; coeffs : PointMultidimensionnel) : TypeReel;
var estim : TypeReel;
begin

  Discard2(beta,indexMu);

  { on estime le temps necessaire a cette recherche,
    en ticks (c'est-a-dire en 1/60 de secondes), sur un
    iMac Intel 2.4 Ghz bi-coeur (indiceVitesseMac = 6225) }

  estim :=  coeffs^[1] * exp(coeffs^[2] * (prof - 20))
                       * exp(coeffs^[3] * rang)
                       * exp(coeffs^[4] * ln(mobilite))
                       * exp(coeffs^[5] * (eval - alpha))

            +

            coeffs^[6] * exp(coeffs^[7] * (prof - 20));
           ;

  {on normalise pour la vitesse du mac actuel}

  estim := estim * ( 6225.0 / indiceVitesseMac ) ;

  TempsEstimeEnTicksPourResoudreCettePositionAvecCesCoeffs := estim;
end;


procedure EcrireFonctionEstimationChargeDansRapport;
var j : SInt32;
begin
  {for j := 1 to DimensionDuPointMultidimensionnel(coeffEstimationTemps) do}

  for j := 1 to 7 do
    begin
      WriteStringAndReelDansRapport('coeffEstimationTemps^['+NumEnString(j)+'] := ',coeffEstimationTemps^[j],6);
      WritelnDansRapport(';');
    end;
end;


function TempsEstimeEnTicksPourResoudreCettePosition(prof,rang,mobilite,indexMu,alpha,beta : SInt32; eval : TypeReel) : TypeReel;
var estim : TypeReel;
begin
  estim := TempsEstimeEnTicksPourResoudreCettePositionAvecCesCoeffs(prof,rang,mobilite,indexMu,alpha,beta,eval,coeffEstimationTemps);

  if estim <= 0.0 then estim := 1.0;  {au moins un tick}

  TempsEstimeEnTicksPourResoudreCettePosition := estim;
end;



function TempsEstimeEnSecondesPourResoudreCettePosition(prof,rang,mobilite,indexMu,alpha,beta : SInt32; eval : TypeReel) : TypeReel;
var estim : TypeReel;
begin

  { 1 tick = 1/60 seconde = 0.016666666666 seconde }

  estim := 0.01666666666 * TempsEstimeEnTicksPourResoudreCettePositionAvecCesCoeffs(prof,rang,mobilite,indexMu,alpha,beta,eval,coeffEstimationTemps);

  if estim <= 0.0 then estim := 1.0/60.0;  {au moins un tick}

  TempsEstimeEnSecondesPourResoudreCettePosition := estim;
end;


function ChiSquareEstimationCharge(coeffs : PointMultidimensionnel) : TypeReel;
var somme,erreur,estim : double;
    erreurRelative : double;
    i : SInt32;
begin

  ChiSquareEstimationCharge := 0.0;

  with dataEstimationCharge do
    if cardinal > 0 then
      begin
        somme := 0.0;
        for i := 1 to cardinal do
          begin

            with points[i] do
              begin
                estim := TempsEstimeEnTicksPourResoudreCettePositionAvecCesCoeffs(prof,rang,mobilite,indexMu,alpha,beta,eval,coeffs);

                {erreur := (temps - estim) * (temps - estim) * (temps - estim) * (temps - estim);}

                erreur := (abs(temps - estim)) * (abs(temps - estim)) / (temps);

                erreurRelative := estim/temps;

                if erreurRelative > 0.0
                  then erreur := erreur + 0.1*(abs(temps - estim))*((erreurRelative * erreurRelative) + 1.0 / (erreurRelative * erreurRelative))
                  else erreur := erreur + 10000000000.0;

                (*
                if (temps > 60.0) and (estim < 60.0) then erreur := erreur + 500;  // 500 est super super !
                if (temps < 60.0) and (estim > 60.0) then erreur := erreur + 500;
                *)


                if (temps > 60.0) and (estim < 60.0) then erreur := erreur + penalitePourKendall;  // 500 est super super !
                if (temps < 60.0) and (estim > 60.0) then erreur := erreur + penalitePourKendall;


                (*
                if (temps > 30.0) and (estim < 30.0) then erreur := erreur + 0.25 * penalitePourKendall;  // 500 est super super !
                if (temps < 30.0) and (estim > 30.0) then erreur := erreur + 0.25 * penalitePourKendall;
                *)

                (*
                if (temps > 120.0) and (estim < 120.0) then erreur := erreur + 4.0 * penalitePourKendall;  // 500 est super super !
                if (temps < 120.0) and (estim > 120.0) then erreur := erreur + 4.0 * penalitePourKendall;
                *)

                {erreur := abs(temps - estim);}

                somme := somme + erreur;
              end;
          end;

        ChiSquareEstimationCharge := somme/cardinal;

        {ChiSquareEstimationCharge := sqrt(somme/cardinal);}

        {ChiSquareEstimationCharge := sqrt(sqrt(somme/cardinal));}

        {ChiSquareEstimationCharge := somme;}
      end;
end;







procedure OptimiserLesCoefficientsDEstimationDeLaCharge;
var resultat,tolerance : TypeReel;
    nbIter,aux : SInt32;
begin

  SetEcritToutDansRapportLog(true);

  aux := Abs(Random16()) mod 3;

  case aux of
    0 :  penalitePourKendall := 4;
    1 :  penalitePourKendall := 500;
    2 :  penalitePourKendall := (Abs(Random16()) mod 100);
  end;


  WritelnDansRapport('');
  WritelnNumDansRapport('dataEstimationCharge.nbPoints = ',dataEstimationCharge.nbPoints);
  WritelnNumDansRapport('Kendall = ',penalitePourKendall);
  WritelnStringAndReelDansRapport('avant optimisation, chi2 = ',ChiSquareEstimationCharge(coeffEstimationTemps),5);

  {
  MinimisationMultidimensionnelleSimple(ChiSquareEstimationCharge,coeffEstimationTemps,nbIter,resultat);
  }


  tolerance := 0.0001;
  MinimisationMultidimensionnelleParConjugateGradient(ChiSquareEstimationCharge,coeffEstimationTemps,tolerance,nbIter,resultat);


  WritelnStringAndReelDansRapport('apres optimisation, chi2 = ',ChiSquareEstimationCharge(coeffEstimationTemps),5);

  {WritelnStringAndReelDansRapport('soit en moyenne : ',sqrt(ChiSquareEstimationCharge(coeffEstimationTemps)) / dataEstimationCharge.cardinal,5);}

  {WritelnStringAndReelDansRapport('soit en moyenne : ',ChiSquareEstimationCharge(coeffEstimationTemps) / dataEstimationCharge.cardinal,5);}

  WritelnDansRapport('');

  EcrireFonctionEstimationChargeDansRapport;

end;


procedure AjouterDataEstimationCharge(prof,rang,mobilite,indexMu,alpha,beta: SInt32; eval, vraiTempsEnTicks : TypeReel);
var index,j : SInt32;
    estim : TypeReel;
begin

  DIscard(j);


  with dataEstimationCharge do
    if (cardinal >= 0) then
      begin

        inc(nbPoints);

        if cardinal < kMaxNombreDataEstimationCharge
          then
            begin

              inc(cardinal);

              points[cardinal].prof     := prof;
              points[cardinal].rang     := rang;
              points[cardinal].mobilite := mobilite;
              points[cardinal].eval     := eval;
              points[cardinal].indexMu  := indexMu;
              points[cardinal].alpha    := alpha;
              points[cardinal].beta     := beta;
              points[cardinal].temps    := vraiTempsEnTicks;


            end
          else
            begin
              index := 1 + (Abs(Random32()) mod kMaxNombreDataEstimationCharge);

              if index < 1 then index := 1;
              if index > kMaxNombreDataEstimationCharge then index := kMaxNombreDataEstimationCharge;

              points[index].prof     := prof;
              points[index].rang     := rang;
              points[index].mobilite := mobilite;
              points[index].eval     := eval;
              points[index].indexMu  := indexMu;
              points[index].alpha    := alpha;
              points[index].beta     := beta;
              points[index].temps    := vraiTempsEnTicks;

            end;

        if (nbPoints mod 100) = 0 then
          begin
            {for j := 1 to DimensionDuPointMultidimensionnel(coeffEstimationTemps) do
              coeffEstimationTemps^[j] := 0.0;}
            coeffEstimationTemps^[1 + ((j div 100) mod 7)] := 0.1 * coeffEstimationTemps^[1 + ((j div 100) mod 7)];
            OptimiserLesCoefficientsDEstimationDeLaCharge;
          end;

        if (nbPoints mod 23) = 0
          then
            begin
              estim := TempsEstimeEnTicksPourResoudreCettePosition(prof,rang,mobilite,indexMu,alpha,beta,eval);

              WritelnDansRapport('');
              WritelnNumDansRapport('n = ',nbPoints);
              WritelnStringAndReelDansRapport('temps estimé en 1/60 sec = ',estim,5);
              WritelnStringAndReelDansRapport('temps vrai en 1/60 sec = ',vraiTempsEnTicks,5);

            end;

      end;
end;





END.
