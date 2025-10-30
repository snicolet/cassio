UNIT UnitBigVectors;


INTERFACE







 USES UnitDefCassio;




function AllocatePointMultidimensionnel(n : SInt32; var p : PointMultidimensionnel) : boolean;
procedure DisposePointMultidimensionnel(var p : PointMultidimensionnel);
function DimensionDuPointMultidimensionnel(var p : PointMultidimensionnel) : SInt32;


procedure AnnulePointMultidimensionnel(var p : PointMultidimensionnel);
procedure SetValeurDansPointMultidimensionnel(var p : PointMultidimensionnel; valeur : TypeReel);
procedure IdentitePointMultidimensionnel(var p : PointMultidimensionnel);
procedure HomothetiePointMultidimensionnel(var p,result : PointMultidimensionnel; scale : TypeReel);
procedure NegationPointMultidimensionnel(var p,result : PointMultidimensionnel);
procedure ValeurAbsoluePointMultidimensionnel(var p,result : PointMultidimensionnel);
procedure MaxPointMultidimensionnel(var p,result : PointMultidimensionnel; valeur : TypeReel);
procedure MinPointMultidimensionnel(var p,result : PointMultidimensionnel; valeur : TypeReel);
procedure AddPointMultidimensionnel(var p1,p2,resultat : PointMultidimensionnel);
procedure DiffPointMultidimensionnel(var p1,p2,resultat : PointMultidimensionnel);
procedure DivisionPointMultidimensionnel(var p1,p2,resultat : PointMultidimensionnel);
procedure DivisionBorneePointMultidimensionnel(var p1,p2,resultat : PointMultidimensionnel; borne : TypeReel);
procedure CopierPointMultidimensionnel(var source,dest : PointMultidimensionnel);
procedure CopierOpposePointMultidimensionnel(var source,dest : PointMultidimensionnel);
procedure CombinaisonLineairePointMultidimensionnel(var p1,p2 : PointMultidimensionnel; lambda1,lambda2 : TypeReel; var resultat : PointMultidimensionnel);
function ProduitScalairePointMultidimensionnel(var p1,p2 : PointMultidimensionnel) : TypeReel;
function CombinaisonScalairePointMultidimensionnel(var p1,p2,p3 : PointMultidimensionnel; lambda1,lambda2 : TypeReel) : TypeReel;


function EcritPointMultidimensionnelDansFichierTexte(var fic : basicfile; var p : PointMultidimensionnel) : OSErr;
function LitPointMultidimensionnelDansFichierTexte(var fic : basicfile; var p : PointMultidimensionnel) : OSErr;


procedure TrierPointMultidiemnsionnel(var p : PointMultidimensionnel; var rankingTable : PointMultidimensionnel);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    fp
{$IFC NOT(USE_PRELINK)}
    , UnitServicesMemoire, UnitRapport, basicfile, UnitGeneralSort ;
{$ELSEC}
    ;
    {$I prelink/BigVectors.lk}
{$ENDC}


{END_USE_CLAUSE}











function AllocatePointMultidimensionnel(n : SInt32; var p : PointMultidimensionnel) : boolean;
var count : SInt32;
begin
  AllocatePointMultidimensionnel := false;
  count := sizeof(TypeReel);
  count := (n+1)*count;
  p := TypeReelArrayPtr(AllocateMemoryPtr(count));
  if p <> NIL
    then
      begin
        p^[0] := n;
        AllocatePointMultidimensionnel := true;
      end;
end;

procedure DisposePointMultidimensionnel(var p : PointMultidimensionnel);
begin
  if p <> NIL then DisposeMemoryPtr(Ptr(p));
  p := NIL;
end;

function DimensionDuPointMultidimensionnel(var p : PointMultidimensionnel) : SInt32;
var aux : SInt32;
begin
  if p = NIL
    then aux := 0
    else aux := RoundToL(p^[0]+0.45);
  if aux > 0
    then DimensionDuPointMultidimensionnel := aux
    else DimensionDuPointMultidimensionnel := 0;
end;

{ p := 0 }
procedure AnnulePointMultidimensionnel(var p : PointMultidimensionnel);
var n,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  if (n <= 0)
    then WritelnDansRapport('Erreur dans AnnulePointMultidimensionnel !!')
    else
      for j := 1 to n do
        p^[j] := 0.0;
end;

{ p[i] := valeur    pour tout i  }
procedure SetValeurDansPointMultidimensionnel(var p : PointMultidimensionnel; valeur : TypeReel);
var n,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  if (n <= 0)
    then WritelnDansRapport('Erreur dans SetValeurDansPointMultidimensionnel !!')
    else
      for j := 1 to n do
        p^[j] := valeur;
end;


{ p[i] := i    pour tout i  }
procedure IdentitePointMultidimensionnel(var p : PointMultidimensionnel);
var n,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  if (n <= 0)
    then WritelnDansRapport('Erreur dans SetValeurDansPointMultidimensionnel !!')
    else
      for j := 1 to n do
        p^[j] := (j+0.001);
end;


{ result := scale*p }
procedure HomothetiePointMultidimensionnel(var p,result : PointMultidimensionnel; scale : TypeReel);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  m := DimensionDuPointMultidimensionnel(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans HomothetiePointMultidimensionnel !!')
    else
      for j := 1 to n do
        result^[j] := p^[j]*scale;
end;

{ result := -p }
procedure NegationPointMultidimensionnel(var p,result : PointMultidimensionnel);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  m := DimensionDuPointMultidimensionnel(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans NegationPointMultidimensionnel !!')
    else
      for j := 1 to n do
        result^[j] := -p^[j];
end;

{ result[i] := Abs(p[i]) }
procedure ValeurAbsoluePointMultidimensionnel(var p,result : PointMultidimensionnel);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  m := DimensionDuPointMultidimensionnel(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans ValeurAbsoluePointMultidimensionnel !!')
    else
      for j := 1 to n do
        result^[j] := Abs(p^[j]);
end;

{ result[i] := Max(p[i],valeur) }
procedure MaxPointMultidimensionnel(var p,result : PointMultidimensionnel; valeur : TypeReel);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  m := DimensionDuPointMultidimensionnel(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans MaxPointMultidimensionnel !!')
    else
      for j := 1 to n do
        begin
          if valeur > p^[j]
            then result^[j] := valeur
            else result^[j] := p^[j];
        end;
end;

{ result[i] := Min(p[i],valeur) }
procedure MinPointMultidimensionnel(var p,result : PointMultidimensionnel; valeur : TypeReel);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  m := DimensionDuPointMultidimensionnel(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans MinPointMultidimensionnel !!')
    else
      for j := 1 to n do
        begin
          if valeur < p^[j]
            then result^[j] := valeur
            else result^[j] := p^[j];
        end;
end;

{ resultat := p1 + p2 }
procedure AddPointMultidimensionnel(var p1,p2,resultat : PointMultidimensionnel);
var n1,n2,m,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnel(p1);
  n2 := DimensionDuPointMultidimensionnel(p2);
  m := DimensionDuPointMultidimensionnel(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans AddPointMultidimensionnel !!')
    else
      for j := 1 to m do
        resultat^[j] := p1^[j]+p2^[j];
end;

{ resultat := p1 - p2 }
procedure DiffPointMultidimensionnel(var p1,p2,resultat : PointMultidimensionnel);
var n1,n2,m,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnel(p1);
  n2 := DimensionDuPointMultidimensionnel(p2);
  m := DimensionDuPointMultidimensionnel(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans DiffPointMultidimensionnel !!')
    else
      for j := 1 to m do
        resultat^[j] := p1^[j]-p2^[j];
end;

{ resultat[i] := p1[i] / p2[i] si p2[i] <> 0, p1[i] sinon}
procedure DivisionPointMultidimensionnel(var p1,p2,resultat : PointMultidimensionnel);
const eps = 1e-10;
var n1,n2,m,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnel(p1);
  n2 := DimensionDuPointMultidimensionnel(p2);
  m := DimensionDuPointMultidimensionnel(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans DivisionPointMultidimensionnel !!')
    else
      for j := 1 to m do
        if (p2^[j] > eps) or (p2^[j] < -eps)
          then resultat^[j] := p1^[j]/p2^[j]
          else resultat^[j] := p1^[j];
end;

{ resultat[i] := p1[i] * (Min(1,(p2[i]/borne)) / p2[i]    si p2[i] <> 0,   p1[i] sinon}
procedure DivisionBorneePointMultidimensionnel(var p1,p2,resultat : PointMultidimensionnel; borne : TypeReel);
const eps = 1e-10;
var n1,n2,m,j : SInt32;
    aux : TypeReel;
begin
  n1 := DimensionDuPointMultidimensionnel(p1);
  n2 := DimensionDuPointMultidimensionnel(p2);
  m := DimensionDuPointMultidimensionnel(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans DivisionBorneePointMultidimensionnel !!')
    else
      for j := 1 to m do
        if (p2^[j] > eps) or (p2^[j] < -eps)
          then
            begin
              if borne <> 0.0
                then aux := p2^[j]/borne
                else aux := 1.0;
              if (aux > 1.0) or (aux <= 0.0) then aux := 1.0;
              resultat^[j] := p1^[j]*aux/p2^[j];
            end
          else resultat^[j] := p1^[j];
end;

{ dest := source }
procedure CopierPointMultidimensionnel(var source,dest : PointMultidimensionnel);
var n1,n2,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnel(source);
  n2 := DimensionDuPointMultidimensionnel(dest);
  if (n1 <> n2) or (n1 <= 0) or (n2 <= 0)
    then WritelnDansRapport('Erreur dans CopierPointMultidimensionnel !!')
    else
      for j := 1 to n1 do
         dest^[j] := source^[j];
end;

{ dest := -source }
procedure CopierOpposePointMultidimensionnel(var source,dest : PointMultidimensionnel);
var n1,n2,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnel(source);
  n2 := DimensionDuPointMultidimensionnel(dest);
  if (n1 <> n2) or (n1 <= 0) or (n2 <= 0)
    then WritelnDansRapport('Erreur dans CopierOpposePointMultidimensionnel !!')
    else
      for j := 1 to n1 do
         dest^[j] := -source^[j];
end;

{ p1.p2 }
function ProduitScalairePointMultidimensionnel(var p1,p2 : PointMultidimensionnel) : TypeReel;
var n1,n2,j : SInt32;
    sum : TypeReel;
begin
  ProduitScalairePointMultidimensionnel := 0.0;
  sum := 0.0;
  n1 := DimensionDuPointMultidimensionnel(p1);
  n2 := DimensionDuPointMultidimensionnel(p2);
  if (n1 <> n2) or (n1 <= 0) or (n2 <= 0)
    then WritelnDansRapport('Erreur dans ProduitScalairePointMultidimensionnel !!')
    else
      for j := 1 to n1 do
         sum := sum+p1^[j]*p2^[j];
  ProduitScalairePointMultidimensionnel := sum;
end;

{ result := lambda1*p1 + lambda2*p2 }
procedure CombinaisonLineairePointMultidimensionnel(var p1,p2 : PointMultidimensionnel; lambda1,lambda2 : TypeReel; var resultat : PointMultidimensionnel);
var n1,n2,m,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnel(p1);
  n2 := DimensionDuPointMultidimensionnel(p2);
  m := DimensionDuPointMultidimensionnel(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans CombinaisonLineairePointMultidimensionnel !!')
    else
      for j := 1 to m do
        begin
          resultat^[j] := lambda1*p1^[j] + lambda2*p2^[j];
          {WritelnStringAndReelDansRapport('resultat^[j] = ',resultat^[j],5);}
        end;
end;

{ calcule (lambda1*p1 + lambda2*p2).p3 }
function CombinaisonScalairePointMultidimensionnel(var p1,p2,p3 : PointMultidimensionnel; lambda1,lambda2 : TypeReel) : TypeReel;
var n1,n2,n3,j : SInt32;
    sum : TypeReel;
begin
  CombinaisonScalairePointMultidimensionnel := 0.0;
  sum := 0.0;
  n1 := DimensionDuPointMultidimensionnel(p1);
  n2 := DimensionDuPointMultidimensionnel(p2);
  n3 := DimensionDuPointMultidimensionnel(p3);
  if (n1 <= 0) or (n2 <= 0) or (n3 <= 0) or
     (n1 <> n2) or (n1 <> n3) or (n2 <> n3)
    then WritelnDansRapport('Erreur dans CombinaisonScalairePointMultidimensionnel !!')
    else
      for j := 1 to n1 do
         sum := sum + (lambda1*p1^[j] + lambda2*p2^[j])*p3^[j];
  CombinaisonScalairePointMultidimensionnel := sum;
end;

function EcritPointMultidimensionnelDansFichierTexte(var fic : basicfile; var p : PointMultidimensionnel) : OSErr;
var n,count : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  if (n <= 0) then
    begin
      EcritPointMultidimensionnelDansFichierTexte := -1;
      exit;
    end;
  count := (n+1)*sizeof(TypeReel);
  EcritPointMultidimensionnelDansFichierTexte := Write(fic,Ptr(@p^[0]),count);
end;


function LitPointMultidimensionnelDansFichierTexte(var fic : basicfile; var p : PointMultidimensionnel) : OSErr;
var n,count : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  if (n <= 0) then
    begin
      LitPointMultidimensionnelDansFichierTexte := -1;
      exit;
    end;
  count := (n+1)*sizeof(TypeReel);
  LitPointMultidimensionnelDansFichierTexte := Read(fic,Ptr(@p^[0]),count);
end;


var InfosTri :
       record
         tailleVecteur : SInt32;
         IndexDeTri : PointMultidimensionnel;
         TableauATrier : PointMultidimensionnel;
       end;

function LitIndexTriPointMultidimensionnel(index : SInt32) : SInt32;
begin
  if (index < 1) or (index > InfosTri.TailleVecteur)
    then
      begin
        WritelnNumDansRapport('pb dans LitIndexTriPointMultidimensionnel !! index = ',index);
        LitIndexTriPointMultidimensionnel := -1;
        exit;
      end
    else
      LitIndexTriPointMultidimensionnel := RoundToL(InfosTri.IndexDeTri^[index]+0.25);
end;

procedure AffecteIndexTriPointMultidimensionnel(index,element : SInt32);
begin
  if (index < 1) or (index > InfosTri.TailleVecteur)
    then
      begin
        WritelnNumDansRapport('pb dans AffecteIndexTriPointMultidimensionnel !! index = ',index);
        exit;
      end
    else
      InfosTri.IndexDeTri^[index] := 1.0*element;
end;

function OrdreTriPointMultidimensionnel(element1,element2 : SInt32) : boolean;
begin
  if (element1 < 1) or (element1 > InfosTri.TailleVecteur) then
    begin
      WritelnNumDansRapport('pb dans OrdreTriPointMultidimensionnel !! element1 = ',element1);
      OrdreTriPointMultidimensionnel := false;
      exit;
    end;
  if (element2 < 1) or (element2 > InfosTri.TailleVecteur) then
    begin
      WritelnNumDansRapport('pb dans OrdreTriPointMultidimensionnel !! element2 = ',element2);
      OrdreTriPointMultidimensionnel := false;
      exit;
    end;
  OrdreTriPointMultidimensionnel := (InfosTri.TableauATrier^[element1] <= InfosTri.TableauATrier^[element2]);
end;


{  en sortie, le tableau :                                   }
{  p[rankingTable[1]],p[rankingTable[2]],...etc              }
{  est triŽ par ordre croissant                              }
procedure TrierPointMultidiemnsionnel(var p : PointMultidimensionnel; var rankingTable : PointMultidimensionnel);
var n,m : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  m := DimensionDuPointMultidimensionnel(rankingTable);
  if n <> m
    then WritelnDansRapport('Erreur dans TrierPointMultidiemnsionnel !!')
    else
      begin
        InfosTri.TailleVecteur := n;
        InfosTri.TableauATrier := p;
        InfosTri.IndexDeTri   := rankingTable;
        GeneralQuickSort(1,n,LitIndexTriPointMultidimensionnel,AffecteIndexTriPointMultidimensionnel,OrdreTriPointMultidimensionnel);
        {GeneralShellSort(1,n,LitIndexTriPointMultidimensionnel,AffecteIndexTriPointMultidimensionnel,OrdreTriPointMultidimensionnel);}
      end;
end;


END.
