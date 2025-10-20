UNIT UnitAlgebreLineaire;




INTERFACE




USES UnitDefCassio;





function EstUneMatriceCarree(var A : MatriceReels) : boolean;
procedure AnnuleMatrice(var M : MatriceReels);
procedure AnnuleVecteur(var V : VecteurReels);
procedure SetMatriceCarreeNulle(n : SInt32; var M : MatriceReels);
procedure SetMatriceIdentite(n : SInt32; var M : MatriceReels);
procedure SetVecteurNul(n : SInt32; var V : VecteurReels);
procedure CopierMatrice(var source,dest : MatriceReels);
procedure CopierVecteur(var source,dest : VecteurReels);

function ProduitScalaireVecteurs(var v1,v2 : VecteurReels) : RealType;
procedure AppliqueMatrice(var M : MatriceReels; var x : VecteurReels; var result : VecteurReels);
procedure MultMatriceParReel(var M : MatriceReels; r : RealType; var result : MatriceReels);
procedure SommeMatrices(var M1,M2 : MatriceReels; var result : MatriceReels);

procedure WritelnMatriceReelsDansRapport(var M : MatriceReels; nbChiffres : SInt16);
procedure WritelnVecteurReelsDansRapport(var v : VecteurReels; nbChiffres : SInt16);

procedure LUDecompose(var A : MatriceReels; var index : VecteurLongint; var d : RealType);
procedure LUBackSubsitute(var A : MatriceReels; var index : VecteurLongint; var b : VecteurReels);

function ResoudSystemeEquationsCarre(A : MatriceReels; b : VecteurReels; var Inverse : MatriceReels; var x : VecteurReels) : boolean;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapport, MyStrings ;
{$ELSEC}
    {$I prelink/AlgebreLineaire.lk}
{$ENDC}


{END_USE_CLAUSE}










procedure annuleMatrice(var M : MatriceReels);
var j,k : SInt32;
begin
  for j := 1 to M.nbLignes do
    for k := 1 to M.nbColonnes do
      M.mat[j,k] := 0.0;
end;

procedure annuleVecteur(var V : VecteurReels);
var j : SInt32;
begin
  for j := 1 to V.longueur do
      V.vec[j] := 0.0;
end;

procedure SetMatriceIdentite(n : SInt32; var M : MatriceReels);
var j : SInt32;
begin
  SetMatriceCarreeNulle(n,M);
  for j := 1 to n do
    M.mat[j,j] := 1.0;
end;

procedure SetMatriceCarreeNulle(n : SInt32; var M : MatriceReels);
begin
  M.nbLignes := n;
  M.nbColonnes := n;
  annuleMatrice(M);
end;

procedure SetVecteurNul(n : SInt32; var V : VecteurReels);
begin
  V.longueur := n;
  annuleVecteur(V);
end;


procedure CopierMatrice(var source,dest : MatriceReels);
var i,j : SInt32;
begin
  dest.nbLignes := source.nbLignes;
  dest.nbColonnes := source.nbColonnes;
  for i := 1 to source.nbLignes do
    for j := 1 to source.nbColonnes do
      dest.mat[i,j] := source.mat[i,j];
end;


procedure CopierVecteur(var source,dest : VecteurReels);
var i : SInt32;
begin
  dest.longueur := source.longueur;
  for i := 1 to source.longueur do
    dest.vec[i] := source.vec[i];
end;


function EstUneMatriceCarree(var A : MatriceReels) : boolean;
begin
  EstUneMatriceCarree := (A.nbLignes > 0) &
                        (A.nbLignes <= dimensionMatrice) &
                        (A.nbLignes = A.nbColonnes);
end;



{attention : la matrice A est detruite !}
procedure LUDecompose(var A : MatriceReels; var index : VecteurLongint; var d : RealType);
var k,j,imax,i,n : SInt32;
    sum,dum,big : RealType;
    vv : VecteurReels;
    tiny : RealType;
begin
  tiny := 1e-20;
  d := 1.0;

  if not(EstUneMatriceCarree(A)) then
    begin
      WritelnDansRapport('La matrice doit etre carree dans LUDecompose !');
      d := 0.0;
      exit(LUDecompose);
    end;

  n := A.nbLignes;
  index.longueur := n;
  SetVecteurNul(n,vv);
  for i := 1 to n do
    begin
      big := 0.0;
      for j := 1 to n do
        if Abs(A.mat[i,j]) > big then big := Abs(A.mat[i,j]);
      if big = 0.0 then
        begin
          WritelnDansRapport('Matrice singuliere dans LUDecompose !');
          d := 0.0;
          exit(LUDecompose);
        end;
      vv.vec[i] := 1.0/big;
    end;

  for j := 1 to n do
    begin
      for i := 1 to j-1 do
        begin
          sum := A.mat[i,j];
          for k := 1 to i-1 do
            sum := sum-A.mat[i,k]*A.mat[k,j];
          A.mat[i,j] := sum;
        end;
      big := 0.0;
      for i := j to n do
        begin
          sum := A.mat[i,j];
          for k := 1 to j-1 do
            sum := sum-A.mat[i,k]*A.mat[k,j];
          A.mat[i,j] := sum;
          dum := vv.vec[i]*Abs(sum);
          if dum >= big then
            begin
              big := dum;
              imax := i;
            end;
        end;
      if j <> imax then
        begin
          for k := 1 to n do
            begin
              dum := A.mat[imax,k];
              A.mat[imax,k] := A.mat[j,k];
              A.mat[j,k] := dum;
            end;
          d := -d;
          vv.vec[imax] := vv.vec[j];
        end;
      index.val[j] := imax;
      if A.mat[j,j] = 0.0 then
        begin
          A.mat[j,j] := tiny;
          d := 0.0;
          WritelnDansRapport('je substitue tiny à zéro dans LUDecompose');
        end;
      if j <> n then
        begin
          dum := 1.0/A.mat[j,j];
          for i := j+1 to n do
            A.mat[i,j] := A.mat[i,j]*dum;
        end;
    end;
end;




procedure LUBackSubsitute(var A : MatriceReels; var index : VecteurLongint; var b : VecteurReels);
var j,ip,ii,i,n : SInt32;
    sum : RealType;
begin
  if not(EstUneMatriceCarree(A)) then
    begin
      WritelnDansRapport('La matrice doit etre carree dans LUBackSubsitute !');
      exit(LUBackSubsitute);
    end;
  n := A.nbLignes;
  if b.longueur <> n then
    begin
      WritelnDansRapport('mauvaise dimension du vecteur dans LUBackSubsitute !');
      exit(LUBackSubsitute);
    end;
  ii := 0;
  for i := 1 to n do
    begin
      ip := index.val[i];
      sum := b.vec[ip];
      b.vec[ip] := b.vec[i];
      if ii <> 0
        then for j := ii to i-1 do sum := sum-A.mat[i,j]*b.vec[j]
        else if sum <> 0.0 then ii := i;
      b.vec[i] := sum;
    end;
  for i := n downto 1 do
    begin
      sum := b.vec[i];
      for j := i+1 to n do
        sum := sum-A.mat[i,j]*b.vec[j];
      b.vec[i] := sum/A.mat[i,i];
    end;
end;


function ProduitScalaireVecteurs(var v1,v2 : VecteurReels) : RealType;
var i : SInt32;
    sum : RealType;
begin
  if v1.longueur <> v2.longueur then
    begin
      WritelnDansRapport('produits scalaire de vecteurs de tailles differentes !');
      ProduitScalaireVecteurs := 0;
      exit(ProduitScalaireVecteurs);
    end;
  sum := 0.0;
  for i := 1 to v1.longueur do
    sum := sum+v1.vec[i]*v2.vec[i];
  ProduitScalaireVecteurs := sum;
end;

procedure AppliqueMatrice(var M : MatriceReels; var x : VecteurReels; var result : VecteurReels);
var i,k : SInt32;
    sum : RealType;
begin
  if M.nbColonnes <> x.longueur then
    begin
      WritelnDansRapport('mauvaises dimensions dans AppliqueMatrice !');
      exit(AppliqueMatrice);
    end;
  SetVecteurNul(M.nbLignes,result);
  for i := 1 to M.nbLignes do
    begin
      sum := 0.0;
      for k := 1 to M.nbColonnes do
        sum := sum+x.vec[k]*M.mat[i,k];
      result.vec[i] := sum;
    end;
end;

procedure MultMatriceParReel(var M : MatriceReels; r : RealType; var result : MatriceReels);
var i,j : SInt32;
begin
  result.nbLignes := M.nbLignes;
  result.nbColonnes := M.nbColonnes;
  for i := 1 to M.nbLignes do
    for j := 1 to M.nbColonnes do
      result.mat[i,j] := M.mat[i,j]*r;
end;


procedure SommeMatrices(var M1,M2 : MatriceReels; var result : MatriceReels);
var i,j : SInt32;
begin
  if (M1.nbLignes <> M2.nbLignes) | (M1.nbColonnes <> M2.nbColonnes) then
    begin
      WritelnDansRapport('Dimensions incompatibles dans SommeMatrices !');
      exit(SommeMatrices);
    end;
  result.nbLignes := M1.nbLignes;
  result.nbColonnes := M1.nbColonnes;
  for i := 1 to M1.nbLignes do
    for j := 1 to M1.nbColonnes do
      result.mat[i,j] := M1.mat[i,j]+M2.mat[i,j];
end;


procedure WritelnMatriceReelsDansRapport(var M : MatriceReels; nbChiffres : SInt16);
var s : String255;
    i,j : SInt32;
begin
  with M do
    begin
      WritelnDansRapport('matrice :'+
                         ' nbLignes = '+NumEnString(nbLignes)+
                         ' nbColonnes = '+NumEnString(nbColonnes));
      for i := 1 to nbLignes do
        begin
          for j := 1 to nbColonnes do
            begin
              s := ReelEnStringAvecDecimales(M.mat[i,j],nbChiffres);
              WriteDansRapport(s+' ');
            end;
          WritelnDansRapport('');
        end;
    end;
end;

procedure WritelnVecteurReelsDansRapport(var v : VecteurReels; nbChiffres : SInt16);
var s : String255;
    i : SInt32;
begin
  with v do
    begin
      WritelnDansRapport('vecteur :'+
                         ' longueur = '+NumEnString(longueur));
      for i := 1 to longueur do
        begin
          s := ReelEnStringAvecDecimales(v.vec[i],nbChiffres);
          WriteDansRapport(s+' ');
        end;
      WritelnDansRapport('');
    end;
end;


{resolution d'un systeme d'equation carre : Ax = b}
{entrees : A et b
           attention : on doit avoir A.nbLignes = A.nbColonnes;
 sorties : x
           Inverse = inverse de A }
function ResoudSystemeEquationsCarre(A : MatriceReels;
                                      b : VecteurReels;
                                      var Inverse : MatriceReels;
                                      var x : VecteurReels) : boolean;
var i,j,n : SInt32;
    d,determinant : RealType;
    index : VecteurLongint;
    col : VecteurReels;

begin

  if not(EstUneMatriceCarree(A)) then
    begin
      WritelnDansRapport('La matrice doit etre carree dans ResoudSystemeEquationsCarre !');
      exit(ResoudSystemeEquationsCarre);
    end;
  n := A.nbLignes;

  if b.longueur <> n then
    begin
      WritelnDansRapport('Mauvaise dimension du vecteur dans ResoudSystemeEquationsCarre !');
      exit(ResoudSystemeEquationsCarre);
    end;

  LUDecompose(A,index,d);
  for j := 1 to n do d := d * A.mat[j,j];
  determinant := d;
  if determinant = 0.0
    then
      begin  {erreur, matrice singuliere !}
        SetMatriceIdentite(n,inverse);
        CopierVecteur(b,x);
        ResoudSystemeEquationsCarre := false;
        exit(ResoudSystemeEquationsCarre);
      end
    else
      begin
       {calcul de la matrice inverse}
       inverse.nbLignes := n;
       inverse.nbColonnes := n;
       for j := 1 to n do
         begin
           SetVecteurNul(n,col);
           col.vec[j] := 1.0;
           LUBackSubsitute(A,index,col);
           for i := 1 to n do inverse.mat[i,j] := col.vec[i];
         end;
       {calcul de la solution}
       CopierVecteur(b,x);
       LUBackSubsitute(A,index,x);
       ResoudSystemeEquationsCarre := true;
     end;
end;


end.
