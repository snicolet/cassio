UNIT UnitStatisticalFitting;



INTERFACE







 USES UnitDefCassio , fp;


function gammp(a,x : TypeReel) : TypeReel;
function gammq(a,x : TypeReel) : TypeReel;


procedure MomentsOfPointMultidimensionnel(var data : PointMultidimensionnel; nData : SInt32; var moyenne, deviationAbsolueMoyenne, standardDeviation, variance, skewness, kurtosis : TypeReel);

procedure StraightLineFitting(var x,y,sigma : PointMultidimensionnel; nData : SInt32; variancesIndividuellesConnues : boolean; var a,b,sigmaa,sigmab,chi2,q : TypeReel);

IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapport, UnitBigVectors ;
{$ELSEC}
    {$I prelink/StatisticalFitting.lk}
{$ENDC}


{END_USE_CLAUSE}










procedure gser(a,x : TypeReel; var gamser,gln : TypeReel);
label 99;
const itmax = 100;
      eps = 3.0e-7;
var n : SInt32;
    sum,del,ap : TypeReel;
begin
  gln := lgamma(a);
  if x <= 0.0
    then
	    begin
	      if x < 0.0 then
	        begin
	          WritelnDansRapport('Pause in gser : x less than 0');
	          exit(gser);
	        end;
	      gamser := 0.0;
	    end
    else
      begin
        ap := a;
        sum := 1.0/a;
        del := sum;
        for n := 1 to itmax do
          begin
            ap := ap+1.0;
            del := del*x/ap;
            sum := sum+del;
            if Abs(del) < Abs(sum)*eps then goto 99;
          end;
          WritelnDansRapport('Pause in gser - a too large, itmax too small');
          exit(gser);
 99 :   gamser := sum*exp(-x*a*ln(x)-gln);
      end;
end;

procedure gcf(a,x : TypeReel; var gamcf,gln : TypeReel);
label 99;
const itmax = 100;
      eps = 3.0e-7;
var n : SInt32;
    gold,g,fac,b1,b0,anf,ana,an,a1,a0 : TypeReel;
begin
  gln := lgamma(a);
  gold := 0.0;
  a0 := 1.0;
  a1 := x;
  b0 := 0.0;
  b1 := 1.0;
  fac := 1.0;
  for n := 1 to itmax do
    begin
      an := 1.0*n;
      ana := an-a;
      a0 := (a1+a0*ana)*fac;
      b0 := (b1+b0*ana)*fac;
      anf := an*fac;
      a1 := x*a0+anf*a1;
      b1 := x*b0+anf*b1;
      if a1 <> 0.0 then
        begin
          fac := 1.0/a1;
          g := b1*fac;
          if Abs((g-gold)/g) < eps then goto 99;
          gold := g;
        end;
    end;
  WritelnDansRapport('Pause in gcf - a too large, itmax too small');
  exit(gcf);
99 : gamcf := exp(-x+a*ln(x)-gln)*g;
end;

function gammp(a,x : TypeReel) : TypeReel;
var gamser,gamcf,gln : TypeReel;
begin
  if (x < 0.0) | (a <=  0.0) then
    begin
      WritelnDansRapport('Pause dans gammp : invalid arguments');
      exit(gammp);
    end;

  if x < (a + 1.0)
    then
      begin
        gser(a,x,gamser,gln);
        gammp := gamser;
      end
    else
      begin
        gcf(a,x,gamcf,gln);
        gammp := 1.0 - gamcf;
      end;
end;

function gammq(a,x : TypeReel) : TypeReel;
var gamser,gamcf,gln : TypeReel;
begin
  if (x < 0.0) | (a <=  0.0) then
    begin
      WritelnDansRapport('Pause dans gammp : invalid arguments');
      exit(gammq);
    end;

  if x < (a + 1.0)
    then
      begin
        gser(a,x,gamser,gln);
        gammq := 1.0 - gamser;
      end
    else
      begin
        gcf(a,x,gamcf,gln);
        gammq := gamcf;
      end;
end;



procedure MomentsOfPointMultidimensionnel(var data : PointMultidimensionnel;
                                          nData : SInt32;
                                          var moyenne,
                                              deviationAbsolueMoyenne,
                                              standardDeviation,
                                              variance,
                                              skewness,
                                              kurtosis : TypeReel);
var n,j : SInt32;
    s,p,ep : TypeReel;
begin
  n := DimensionDuPointMultidimensionnel(data);
  if n <= 1 then
    begin
      WritelnDansRapport('erreur : n doit etre au moins 2 dans MomentsOfPointMultidimensionnel');
      exit(MomentsOfPointMultidimensionnel);
    end;
  if nData > n then
    begin
      WritelnDansRapport('erreur : nData > n dans MomentsOfPointMultidimensionnel');
      exit(MomentsOfPointMultidimensionnel);
    end;
  n := nData;


  s := 0.0;
  {premiere passe pour calculer la moyenne}
  for j := 1 to n do s := s + data^[j];
  moyenne := s/n;
  deviationAbsolueMoyenne := 0.0;
  standardDeviation := 0.0;
  variance := 0.0;
  skewness := 0.0;
  kurtosis := 0.0;

  {seconde passe pour obtenir les moments superieurs de la deviation}
  ep := 0.0;
  for j := 1 to n do
    begin
      s := data^[j]-moyenne;
      deviationAbsolueMoyenne := deviationAbsolueMoyenne+Abs(s);
      ep := ep+s;
      p := s*s;
      variance := variance+p;
      p := p*s;
      skewness := skewness+p;
      p := p*s;
      kurtosis := kurtosis+p;
    end;

  deviationAbsolueMoyenne := deviationAbsolueMoyenne/n;
  variance := (variance- ((ep*ep)/n))/(n-1); {correction de la variance pour les erreurs d'arrondi}
  standardDeviation := sqrt(variance);
  if variance <> 0.0
    then
      begin
        skewness := skewness/(n*standardDeviation*variance);
        kurtosis := kurtosis/(n*variance*variance) - 3.0;
      end
    else
      begin
        WritelnDansRapport('erreur dans MomentsOfPointMultidimensionnel : pas de skewness ni de kurtosis quand variance = 0 !');
        exit(MomentsOfPointMultidimensionnel);
      end;
end;


procedure StraightLineFitting(var x,y,sigma : PointMultidimensionnel;
                              nData : SInt32;
                              variancesIndividuellesConnues : boolean;
                              var a,b,sigmaa,sigmab,chi2,q : TypeReel);
var n,i : SInt32;
    wt,t,sxoss,sx,sy,st2,ss,sigdat : TypeReel;
begin

  if (x = NIL) | (y = NIL) then
    begin
      WritelnDansRapport('erreur dans StraightLineFitting : (x = NIL) ou (y = NIL) !');
      exit(StraightLineFitting);
    end;

  n := DimensionDuPointMultidimensionnel(x);

  if (DimensionDuPointMultidimensionnel(y) <> n) |
     ((sigma <> NIL) & (DimensionDuPointMultidimensionnel(y) <> n)) then
    begin
      WritelnDansRapport('erreur dans StraightLineFitting : vecteurs de longueurs differentes !');
      exit(StraightLineFitting);
    end;
  if (nData > n) then
    begin
      WritelnDansRapport('erreur dans StraightLineFitting : nData > n !');
      exit(StraightLineFitting);
    end;

  variancesIndividuellesConnues := variancesIndividuellesConnues & (sigma <> NIL);

  sx := 0.0;
  sy := 0.0;
  st2 := 0.0;
  b := 0.0;
  if variancesIndividuellesConnues
    then
      begin
        ss := 0.0;
        for i := 1 to ndata do
          begin
            wt := 1/(sigma^[i]*sigma^[i]);
            ss := ss+wt;
            sx := sx+x^[i]*wt;
            sy := sy+y^[i]*wt;
          end;
      end
    else
      begin
        for i := 1 to ndata do
          begin
            sx := sx+x^[i];
            sy := sy+y^[i];
          end;
        ss := ndata;
      end;

  sxoss := sx/ss;
  if variancesIndividuellesConnues
    then
      begin
        for i := 1 to ndata do
          begin
            t := (x^[i]-sxoss)/sigma^[i];
            st2 := st2+t*t;
            b := b+t*y^[i]/sigma^[i];
          end;
      end
    else
      begin
        for i := 1 to ndata do
          begin
            t := x^[i]-sxoss;
            st2 := st2+t*t;
            b := b+t*y^[i];
          end;
      end;

  b := b/st2;
  a := (sy-sx*b)/ss;
  sigmaa := sqrt((1.0+sx*sx/(ss*st2))/ss);
  sigmab := sqrt(1/st2);

  chi2 := 0;
  if variancesIndividuellesConnues
    then
      begin
        for i := 1 to ndata do
          chi2 := chi2+sqr((y^[i]-a-b*x^[i])/sigma^[i]);
        q := gammq(0.5*(ndata-2),0.5*chi2);
      end
    else
      begin
        for i := 1 to ndata do
          chi2 := chi2+sqr(y^[i]-a-b*x^[i]);
        q := 1.0;
        sigdat := sqrt(chi2/(ndata-2));
        sigmaa := sigmaa*sigdat;
        sigmab := sigmab*sigdat;
      end;
end;




END.
