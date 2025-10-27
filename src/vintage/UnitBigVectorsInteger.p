UNIT UnitBigVectorsInteger;


INTERFACE







 USES UnitDefCassio;





function AllocatePointMultidimensionnelInteger(n : SInt32; var p : PointMultidimensionnelInteger) : boolean;
procedure DisposePointMultidimensionnelInteger(var p : PointMultidimensionnelInteger);
function DimensionDuPointMultidimensionnelInteger(var p : PointMultidimensionnelInteger) : SInt32;
function DuplicatePointMultidimensionnelInteger(var p : PointMultidimensionnelInteger) : PointMultidimensionnelInteger;

procedure AnnulePointMultidimensionnelInteger(var p : PointMultidimensionnelInteger);
procedure SetValeurDansPointMultidimensionnelInteger(var p : PointMultidimensionnelInteger; valeur : SInt16);
procedure HomothetiePointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger; scale : SInt16);
procedure NegationPointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger);
procedure ValeurAbsoluePointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger);
procedure MaxPointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger; valeur : SInt16);
procedure MinPointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger; valeur : SInt16);
procedure AddPointMultidimensionnelInteger(var p1,p2,resultat : PointMultidimensionnelInteger);
procedure DiffPointMultidimensionnelInteger(var p1,p2,resultat : PointMultidimensionnelInteger);
procedure DivisionPointMultidimensionnelInteger(var p1,p2,resultat : PointMultidimensionnelInteger);
procedure DivisionBorneePointMultidimensionnelInteger(var p1,p2,resultat : PointMultidimensionnelInteger; borne : SInt16);
procedure CopierPointMultidimensionnelInteger(var source,dest : PointMultidimensionnelInteger);
procedure CopierOpposePointMultidimensionnelInteger(var source,dest : PointMultidimensionnelInteger);
procedure CombinaisonLineairePointMultidimensionnelInteger(var p1,p2 : PointMultidimensionnelInteger; lambda1,lambda2 : SInt16; var resultat : PointMultidimensionnelInteger);
function ProduitScalairePointMultidimensionnelInteger(var p1,p2 : PointMultidimensionnelInteger) : SInt16;
function CombinaisonScalairePointMultidimensionnelInteger(var p1,p2,p3 : PointMultidimensionnelInteger; lambda1,lambda2 : SInt16) : SInt16;
procedure HomothetieEtTruncaturePointMultidimensionnel(var p : PointMultidimensionnel; scale : TypeReel; var result : PointMultidimensionnelInteger);
procedure HomothetieEtPassageEnFloatPointMultidimensionnel(var p : PointMultidimensionnelInteger; scale : TypeReel; var result : PointMultidimensionnel);


function EcritPointMultidimensionnelIntegerDansFichierTexte(var fic : FichierTEXT; var p : PointMultidimensionnelInteger) : OSErr;
function LitPointMultidimensionnelIntegerDansFichierTexte(var fic : FichierTEXT; var p : PointMultidimensionnelInteger) : OSErr;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    fp
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitServicesMemoire, UnitFichiersTEXT, UnitBigVectors, MyMathUtils ;
{$ELSEC}
    ;
    {$I prelink/BigVectorsInteger.lk}
{$ENDC}


{END_USE_CLAUSE}












function AllocatePointMultidimensionnelInteger(n : SInt32; var p : PointMultidimensionnelInteger) : boolean;
var count : SInt32;
begin
  AllocatePointMultidimensionnelInteger := false;
  p.taille := 0;
  p.data := NIL;
  p.alloue := false;

  count := SizeOf(SInt16);
  count := (n+1)*count;
  p.data := IntegerArrayPtr(AllocateMemoryPtr(count));
  if p.data <> NIL
    then
      begin
        p.taille := n;
        p.alloue := true;
        AllocatePointMultidimensionnelInteger := true;
      end;
end;

procedure DisposePointMultidimensionnelInteger(var p : PointMultidimensionnelInteger);
begin


  if p.alloue and (p.data <> NIL)
    then DisposeMemoryPtr(Ptr(p.data))
    else
      begin
        (*
        if (p.data = NIL)
          then
            begin
              TraceLog('DisposePointMultidimensionnelInteger : p = NIL');
            end;
        if not(p.alloue)
          then
            begin
              WritelnNumDansRapport('DisposePointMultidimensionnelInteger : pointeur non alloue : ',SInt32(p.data));
              TraceLog('DisposePointMultidimensionnelInteger : pointeur non alloue : '+IntToStr(SInt32(p.data)));
            end;
        *)
      end;

  p.data := NIL;
  p.taille := 0;
  p.alloue := false;
end;

function DimensionDuPointMultidimensionnelInteger(var p : PointMultidimensionnelInteger) : SInt32;
var aux : SInt32;
begin
  if p.data = NIL
    then aux := 0
    else aux := p.taille;
  if aux > 0
    then DimensionDuPointMultidimensionnelInteger := aux
    else DimensionDuPointMultidimensionnelInteger := 0;
end;


{ Duplication au sens de la copie des pointeurs }
function DuplicatePointMultidimensionnelInteger(var p : PointMultidimensionnelInteger) : PointMultidimensionnelInteger;
var result : PointMultidimensionnelInteger;
begin
  result.data   := p.data;
  result.taille := p.taille;
  result.alloue := false;

  DuplicatePointMultidimensionnelInteger := result;
end;

{ p := 0 }
procedure AnnulePointMultidimensionnelInteger(var p : PointMultidimensionnelInteger);
var n,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  if (n <= 0)
    then WritelnDansRapport('Erreur dans AnnulePointMultidimensionnelInteger !!')
    else
      for j := 1 to n do
        p.data^[j] := 0;
end;

{ p[i] := valeur    pour tout i  }
procedure SetValeurDansPointMultidimensionnelInteger(var p : PointMultidimensionnelInteger; valeur : SInt16);
var n,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  if (n <= 0)
    then WritelnDansRapport('Erreur dans SetValeurDansPointMultidimensionnelInteger !!')
    else
      for j := 1 to n do
        p.data^[j] := valeur;
end;

{ result := scale*p }
procedure HomothetiePointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger; scale : SInt16);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  m := DimensionDuPointMultidimensionnelInteger(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans HomothetiePointMultidimensionnelInteger !!')
    else
      for j := 1 to n do
        result.data^[j] := p.data^[j]*scale;
end;

{ result := -p }
procedure NegationPointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  m := DimensionDuPointMultidimensionnelInteger(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans NegationPointMultidimensionnelInteger !!')
    else
      for j := 1 to n do
        result.data^[j] := -p.data^[j];
end;

{ result[i] := Abs(p[i]) }
procedure ValeurAbsoluePointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  m := DimensionDuPointMultidimensionnelInteger(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans ValeurAbsoluePointMultidimensionnelInteger !!')
    else
      for j := 1 to n do
        result.data^[j] := Abs(p.data^[j]);
end;

{ result[i] := Max(p[i],valeur) }
procedure MaxPointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger; valeur : SInt16);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  m := DimensionDuPointMultidimensionnelInteger(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans ValeurAbsoluePointMultidimensionnelInteger !!')
    else
      for j := 1 to n do
        begin
          if valeur > p.data^[j]
            then result.data^[j] := valeur
            else result.data^[j] := p.data^[j];
        end;
end;

{ result[i] := Min(p[i],valeur) }
procedure MinPointMultidimensionnelInteger(var p,result : PointMultidimensionnelInteger; valeur : SInt16);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  m := DimensionDuPointMultidimensionnelInteger(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans ValeurAbsoluePointMultidimensionnelInteger !!')
    else
      for j := 1 to n do
        begin
          if valeur < p.data^[j]
            then result.data^[j] := valeur
            else result.data^[j] := p.data^[j];
        end;
end;

{ resultat := p1 + p2 }
procedure AddPointMultidimensionnelInteger(var p1,p2,resultat : PointMultidimensionnelInteger);
var n1,n2,m,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnelInteger(p1);
  n2 := DimensionDuPointMultidimensionnelInteger(p2);
  m := DimensionDuPointMultidimensionnelInteger(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans AddPointMultidimensionnelInteger !!')
    else
      for j := 1 to m do
        resultat.data^[j] := p1.data^[j]+p2.data^[j];
end;

{ resultat := p1 - p2 }
procedure DiffPointMultidimensionnelInteger(var p1,p2,resultat : PointMultidimensionnelInteger);
var n1,n2,m,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnelInteger(p1);
  n2 := DimensionDuPointMultidimensionnelInteger(p2);
  m := DimensionDuPointMultidimensionnelInteger(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans DiffPointMultidimensionnelInteger !!')
    else
      for j := 1 to m do
        resultat.data^[j] := p1.data^[j]-p2.data^[j];
end;

{ resultat[i] := p1[i] / p2[i] si p2[i] <> 0, p1[i] sinon}
procedure DivisionPointMultidimensionnelInteger(var p1,p2,resultat : PointMultidimensionnelInteger);
var n1,n2,m,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnelInteger(p1);
  n2 := DimensionDuPointMultidimensionnelInteger(p2);
  m := DimensionDuPointMultidimensionnelInteger(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans DiffPointMultidimensionnelInteger !!')
    else
      for j := 1 to m do
        if (p2.data^[j] <> 0)
          then resultat.data^[j] := p1.data^[j] div p2.data^[j]
          else resultat.data^[j] := p1.data^[j];
end;

{ resultat[i] := p1[i] * (Min(1,(p2[i]/borne)) / p2[i]    si p2[i] <> 0,   p1[i] sinon}
procedure DivisionBorneePointMultidimensionnelInteger(var p1,p2,resultat : PointMultidimensionnelInteger; borne : SInt16);
var n1,n2,m,j : SInt32;
    aux : SInt16;
begin
  n1 := DimensionDuPointMultidimensionnelInteger(p1);
  n2 := DimensionDuPointMultidimensionnelInteger(p2);
  m := DimensionDuPointMultidimensionnelInteger(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans DiffPointMultidimensionnelInteger !!')
    else
      for j := 1 to m do
        if (p2.data^[j] <> 0)
          then
            begin
              if borne <> 0
                then aux := p2.data^[j] div borne
                else aux := 1;
              if (aux > 1) or (aux <= 0) then aux := 1;
              resultat.data^[j] := (p1.data^[j]*aux) div p2.data^[j];
            end
          else resultat.data^[j] := p1.data^[j];
end;

{ dest := source }
procedure CopierPointMultidimensionnelInteger(var source,dest : PointMultidimensionnelInteger);
var n1,n2,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnelInteger(source);
  n2 := DimensionDuPointMultidimensionnelInteger(dest);
  if (n1 <> n2) or (n1 <= 0) or (n2 <= 0)
    then WritelnDansRapport('Erreur dans CopierPointMultidimensionnelInteger !!')
    else
      for j := 1 to n1 do
         dest.data^[j] := source.data^[j];
end;

{ dest := -source }
procedure CopierOpposePointMultidimensionnelInteger(var source,dest : PointMultidimensionnelInteger);
var n1,n2,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnelInteger(source);
  n2 := DimensionDuPointMultidimensionnelInteger(dest);
  if (n1 <> n2) or (n1 <= 0) or (n2 <= 0)
    then WritelnDansRapport('Erreur dans CopierOpposePointMultidimensionnelInteger !!')
    else
      for j := 1 to n1 do
         dest.data^[j] := -source.data^[j];
end;

{ p1.p2 }
function ProduitScalairePointMultidimensionnelInteger(var p1,p2 : PointMultidimensionnelInteger) : SInt16;
var n1,n2,j : SInt32;
    sum : SInt16;
begin
  ProduitScalairePointMultidimensionnelInteger := 0;
  sum := 0;
  n1 := DimensionDuPointMultidimensionnelInteger(p1);
  n2 := DimensionDuPointMultidimensionnelInteger(p2);
  if (n1 <> n2) or (n1 <= 0) or (n2 <= 0)
    then WritelnDansRapport('Erreur dans ProduitScalairePointMultidimensionnelInteger !!')
    else
      for j := 1 to n1 do
         sum := sum+p1.data^[j]*p2.data^[j];
  ProduitScalairePointMultidimensionnelInteger := sum;
end;

{ result := lambda1*p1 + lambda2*p2 }
procedure CombinaisonLineairePointMultidimensionnelInteger(var p1,p2 : PointMultidimensionnelInteger; lambda1,lambda2 : SInt16; var resultat : PointMultidimensionnelInteger);
var n1,n2,m,j : SInt32;
begin
  n1 := DimensionDuPointMultidimensionnelInteger(p1);
  n2 := DimensionDuPointMultidimensionnelInteger(p2);
  m := DimensionDuPointMultidimensionnelInteger(resultat);
  if (n1 <= 0) or (n2 <= 0) or (m <= 0) or
     (n1 <> n2) or (n1 <> m) or (n2 <> m)
    then WritelnDansRapport('Erreur dans CombinaisonLineairePointMultidimensionnelInteger !!')
    else
      for j := 1 to m do
        resultat.data^[j] := lambda1*p1.data^[j] + lambda2*p2.data^[j];
end;

{ calcule (lambda1*p1 + lambda2*p2).p3 }
function CombinaisonScalairePointMultidimensionnelInteger(var p1,p2,p3 : PointMultidimensionnelInteger; lambda1,lambda2 : SInt16) : SInt16;
var n1,n2,n3,j : SInt32;
    sum : SInt16;
begin
  CombinaisonScalairePointMultidimensionnelInteger := 0;
  sum := 0;
  n1 := DimensionDuPointMultidimensionnelInteger(p1);
  n2 := DimensionDuPointMultidimensionnelInteger(p2);
  n3 := DimensionDuPointMultidimensionnelInteger(p3);
  if (n1 <= 0) or (n2 <= 0) or (n3 <= 0) or
     (n1 <> n2) or (n1 <> n3) or (n2 <> n3)
    then WritelnDansRapport('Erreur dans CombinaisonScalairePointMultidimensionnelInteger !!')
    else
      for j := 1 to n1 do
         sum := sum + (lambda1*p1.data^[j] + lambda2*p2.data^[j])*p3.data^[j];
  CombinaisonScalairePointMultidimensionnelInteger := sum;
end;

{ result[i] := RoundToL(scale*p[i]) }
procedure HomothetieEtTruncaturePointMultidimensionnel(var p : PointMultidimensionnel; scale : TypeReel; var result : PointMultidimensionnelInteger);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnel(p);
  m := DimensionDuPointMultidimensionnelInteger(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans HomothetieEtTruncaturePointMultidimensionnel !!')
    else
      for j := 1 to n do
        result.data^[j] := RoundToL(p^[j]*scale);
end;

{ result[i] := Float(scale*p[i]) }
procedure HomothetieEtPassageEnFloatPointMultidimensionnel(var p : PointMultidimensionnelInteger; scale : TypeReel; var result : PointMultidimensionnel);
var n,m,j : SInt32;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  m := DimensionDuPointMultidimensionnel(result);
  if (n <= 0) or (m <= 0) or (n <> m)
    then WritelnDansRapport('Erreur dans HomothetieEtPassageEnFloatPointMultidimensionnel !!')
    else
      for j := 1 to n do
        result^[j] := p.data^[j]*scale;
end;



function EcritPointMultidimensionnelIntegerDansFichierTexte(var fic : FichierTEXT; var p : PointMultidimensionnelInteger) : OSErr;
var n,count : SInt32;
    err : OSErr;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  if (n <= 0) then
    begin
      EcritPointMultidimensionnelIntegerDansFichierTexte := -1;
      exit(EcritPointMultidimensionnelIntegerDansFichierTexte);
    end;

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  if (p.data <> NIL) then
    begin
      SWAP_LONGINT( @p.taille);
      SWAP_INTEGER_ARRAY( UnivPtr(p.data), 0, p.taille);
    end;
  {$ENDC}

  count := 4;
  err := WriteBufferDansFichierTexte(fic,@p.taille,count);

  count := sizeof(SInt16);
  count := (n+1)*count;
  err := WriteBufferDansFichierTexte(fic,Ptr(p.data),count);
  EcritPointMultidimensionnelIntegerDansFichierTexte := err;


  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  if (p.data <> NIL) then
    begin
      SWAP_LONGINT( @p.taille);
      SWAP_INTEGER_ARRAY( UnivPtr(p.data), 0, p.taille);
    end;
  {$ENDC}

end;


function LitPointMultidimensionnelIntegerDansFichierTexte(var fic : FichierTEXT; var p : PointMultidimensionnelInteger) : OSErr;
var n,count : SInt32;
    err : OSErr;
begin
  n := DimensionDuPointMultidimensionnelInteger(p);
  if (n <= 0) then
    begin
      LitPointMultidimensionnelIntegerDansFichierTexte := -1;
      exit(LitPointMultidimensionnelIntegerDansFichierTexte);
    end;


  count := 4;
  err := ReadBufferDansFichierTexte(fic,@p.taille,count);

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  SWAP_LONGINT( @p.taille);
  {$ENDC}

  count := sizeof(SInt16);
  count := (n+1)*count;
  err := ReadBufferDansFichierTexte(fic,Ptr(p.data),count);

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  if (p.data <> NIL)
    then SWAP_INTEGER_ARRAY( UnivPtr(p.data), 0, p.taille);
  {$ENDC}


  LitPointMultidimensionnelIntegerDansFichierTexte := err;
end;



END.
