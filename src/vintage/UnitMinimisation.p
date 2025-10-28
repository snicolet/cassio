UNIT UnitMinimisation;



INTERFACE

 USES UnitDefCassio;





function DeriveeNumerique(f : FonctionReelle; x : TypeReel) : TypeReel;
procedure CalculeGradientNumerique(f : FonctionMultidimensionnelle; var p : PointMultidimensionnel; var fonctionEnP : TypeReel; var GradientEnP : PointMultidimensionnel);
function bidDiff(x : TypeReel; var dfx : TypeReel) : TypeReel;  {une differentielle bidon !!}

{minimisation en une dimension}
procedure MinimumBracketting(f : FonctionReelle; var ax,bx,cx,fa,fb,fc : TypeReel);
function MinimisationParBrent(f : FonctionReelle; ax,bx,cx,tol : TypeReel; var xmin : TypeReel) : TypeReel;
function MinimisationParBrentAvecDerivee(derivationNumerique : boolean; f : FonctionReelle; {calcul de f} diff : DifferentielleReelle; {calcul simultanŽ de f et de f' : passer bidDiff si l'on veut utiliser la derivation numŽriqe} ax,bx,cx,tol : TypeReel; var xmin : TypeReel) : TypeReel;

{minimisation suivant la droite P+lambda*xi dans un espace multidimensionnel}
procedure LineMinimisation(f : FonctionMultidimensionnelle; var p,xi : PointMultidimensionnel; var fret : TypeReel);



{minimisation multidimensionnelle}
procedure MinimisationMultidimensionnelleParConjugateGradient(f : FonctionMultidimensionnelle; var p : PointMultidimensionnel; ftol : TypeReel; var iter : SInt32; var fret : TypeReel);
procedure MinimisationMultidimensionnelleSimple(f : FonctionMultidimensionnelle; var p : PointMultidimensionnel; var iter : SInt32; var fret : TypeReel);




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesDialogs, UnitRapport, MyStrings, UnitBigVectors ;
{$ELSEC}
    {$I prelink/Minimisation.lk}
{$ENDC}


{END_USE_CLAUSE}










var g_dimensionDesPoints : SInt32;
    g_vecteurP : PointMultidimensionnel;
    g_vecteurDirection : PointMultidimensionnel;
    g_vecteurPPlusXFoisDir : PointMultidimensionnel;
    g_fonctionMultidimesionnelle : FonctionMultidimensionnelle;



function DeriveeNumerique(f : FonctionReelle; x : TypeReel) : TypeReel;
const h = 0.001;
begin
  DeriveeNumerique := (f(x+h)-f(x))/h;
end;

function bidDiff(x : TypeReel; var dfx : TypeReel) : TypeReel;  {une differentielle bidon !!}
begin {$UNUSED x}
  dfx := 0.0;
  bidDiff := 0.0;
end;


procedure CalculeGradientNumerique(f : FonctionMultidimensionnelle; var p : PointMultidimensionnel; var fonctionEnP : TypeReel; var GradientEnP : PointMultidimensionnel);
var n,j : SInt32;
    fpp,oldpj : TypeReel;
    h : TypeReel;
begin
  fonctionEnP := f(p);

  {
  WritelnStringAndReelDansRapport('fonctionEnP = ',fonctionEnP,5);
  }

  n := DimensionDuPointMultidimensionnel(p);

  {
  WritelnNumDansRapport('n = ',n);
  }

  h := 0.001;

  for j := 1 to n do
    begin

      {
      WritelnNumDansRapport('j = ',j);
      }

      oldpj := p^[j];

      {
      WritelnStringAndReelDansRapport('oldpj = ',oldpj,5);
      }

      p^[j] := p^[j]+h;

      fpp := f(p);

      {
      WritelnStringAndReelDansRapport('fpp = ',fpp,5);
      }

      GradientEnP^[j] := (fpp-fonctionEnP)/h;

      {
      WritelnStringAndReelDansRapport('GradientEnP^[j] = ',GradientEnP^[j],5);
      }

      p^[j] := oldpj;

      {
      WritelnStringAndReelDansRapport('p^[j] = ',p^[j],5);
      }

    end;
end;


procedure MinimumBracketting(f : FonctionReelle; var ax,bx,cx,fa,fb,fc : TypeReel);
const
  gold = 1.618034;
  glimit = 100.0;
  tiny = 1.0e-20;
var
  ulim,u,r,q,fu,dum : TypeReel;
  nbIter : SInt32;
begin  {0}



  fa := f(ax);
  fb := f(bx);
  if fb > fa then
    begin {1}
      dum := ax;
      ax := bx;
      bx := dum;
      dum := fa;
      fa := fb;
      fb := dum;
    end;  {1}
    cx := bx + gold*(bx-ax);
    fc := f(cx);
    nbIter := 0;
    while (fb >= fc) and (nbIter <= 100) do
      begin  {1}
        r := (bx-ax)*(fb-fc);
        q := (bx-cx)*(fb-fa);
        if Abs(q-r) > tiny
          then dum := Abs(q-r)
          else dum := tiny;
        if q-r < 0.0 then dum := -dum;
        u := bx - ((bx-cx)*q-(bx-ax)*r)/(2.0*dum);
        ulim := bx + glimit*(cx-bx);
        if (bx-u)*(u-cx) > 0.0
          then
	          begin {2}
	            fu := f(u);
	            if fu < fc
	              then
		              begin {3}
			              ax := bx;
			              fa := fb;
			              bx := u;
			              fb := fu;
			              exit;
			            end  {3}
			          else
			            if fu > fb then
			              begin {3}
			                cx := u;
			                fc := fu;
			                exit;
			              end; {3}
			        u := cx+gold*(cx-bx);
			        fu := f(u);
			      end {2}
		      else
		        begin {2 bis}
              if (cx-u)*(u-ulim) > 0.0
                then
                  begin {2}
                    fu := f(u);
                    if fu < fc
                      then
                        begin {3}
                          bx := cx;
                          cx := u;
                          u := cx+gold*(cx-bx);
                          fb := fc;
                          fc := fu;
                          fu := f(u);
                        end {3}
                  end {2}
                else
                  begin {2 ter}
                    if (u-ulim)*(ulim-cx) >= 0.0
                      then
                        begin {2}
                          u := ulim;
                          fu := f(u);
                        end  {2}
                      else
                        begin {2}
                          u := cx+gold*(cx-bx);
                          fu := f(u);
                        end; {2}
                  end; {2 ter}
            end; {2 bis}
        ax := bx;
        bx := cx;
        cx := u;
        fa := fb;
        fb := fc;
        fc := fu;
        inc(nbIter);
      end;
end;


function MinimisationParBrent(f : FonctionReelle; ax,bx,cx,tol : TypeReel; var xmin : TypeReel) : TypeReel;
const
  itmax = 100;
  cgold = 0.3819660;
  zeps = 1.0e-10;
var
  a,b,d,e,etemp : TypeReel;
  fu,fv,fw,fx : TypeReel;
  iter : SInt32;
  p,q,r,tol1,tol2 : TypeReel;
  u,v,w,x,xm : TypeReel;

  function sign(a,b : TypeReel) : TypeReel;
  begin
    if b >= 0.0
     then sign := Abs(a)
     else sign := -Abs(a);
  end;



begin {0}
  if ax < cx then a := ax else a := cx;
  if ax > cx then b := ax else b := cx;
  v := bx;
  w := v;
  x := v;
  e := 0.0;
  fx := f(x);
  fv := fx;
  fw := fx;
  for iter := 1 to itmax do
    begin  {1}
      xm := 0.5*(a+b);
      tol1 := tol*Abs(x)+zeps;
      tol2 := 2.0*tol1;
      if Abs(x-xm) <= tol2-0.5*(b-a) then
        begin {2}
          xmin := x;
          MinimisationParBrent := fx;
          exit;
        end;  {2}
      if Abs(e) > tol1
        then
	        begin {2}
	          r := (x-w)*(fx-fv);
	          q := (x-v)*(fx-fw);
	          p := (x-v)*q-(x-w)*r;
	          q := 2.0*(q-r);
	          if q > 0.0 then p := -p;
	          q := Abs(q);
	          etemp := e;
	          e := d;
	          if (Abs(p) >= Abs(0.5*q*etemp)) or (p <= q*(a-x)) or (p >= q*(b-x))
	            then
	              begin  {3}
	                if x >= xm
	                  then e := a-x
	                  else e := b-x;
	                d := cgold*e;
	              end  {3}
	            else
	              begin  {3}
	                d := p/q;
	                u := x+d;
	                if (u-a < tol2) or (b-u < tol2) then
	                  d := sign(tol1,xm-x);
	              end;  {3}
	        end  {2}
	      else
	        begin  {2}
	          if x >= xm
	            then e := a-x
	            else e := b-x;
	          d := cgold*e;
	        end; {2}
	    if Abs(d) >= tol1
	      then u := x+d
	      else u := x+sign(tol1,d);
	    fu := f(u);
	    if fu <= fx
	      then
	        begin {2}
	          if u >= x
	            then a := x
	            else b := x;
	          v := w;
	          fv := fw;
	          w := x;
	          fw := fx;
	          x := u;
	          fx := fu;
	        end {2}
	      else
	        begin {2}
	          if u < x
	            then a := u
	            else b := u;
	          if (fu <= fw) or (w = x)
	            then
	              begin {3}
	                v := w;
	                fv := fw;
	                w := u;
	                fw := fu;
	              end {3}
	            else
	              begin {3}
	                if (fu <= fv) or (v = x) or (v = w) then
	                  begin {4}
	                    v := u;
	                    fv := fu;
	                  end; {4}
	              end; {3}
	        end; {2}
    end; {1}
  WritelnDansRapport('Pause dans la routine "MinimisationParBrent" : trop d''iterations');
  xmin := x;
  MinimisationParBrent := fx;
end;

procedure DoNothingWithThisVariable(x : TypeReel);
begin
  x := x;
end;


function MinimisationParBrentAvecDerivee(derivationNumerique : boolean;
                                         f : FonctionReelle; diff : DifferentielleReelle;
                                         ax,bx,cx,tol : TypeReel; var xmin : TypeReel) : TypeReel;
const
  itmax = 30;
  zeps = 1.0e-10;
  {zeps = 1.0e-5;}
var
  a,b,d,d1,d2 : TypeReel;
  du,dv,dw,dx : TypeReel;
  e,fu,fv,fw,fx : TypeReel;
  iter : SInt32;
  olde,tol1,tol2 : TypeReel;
  u,u1,u2,v,w,x,xm : TypeReel;
  ok1,ok2 : boolean;

  function sign(a,b : TypeReel) : TypeReel;
  begin
    if b >= 0.0
     then sign := Abs(a)
     else sign := -Abs(a);
  end;


  procedure CalculeFonctionEtDerivee(x : TypeReel; var fx,dfx : TypeReel);
  var h,temp : TypeReel;
  begin
    if derivationNumerique
	    then
	      begin
	        if (x <= 1e-4) and (x >= -1e-4)
	          then h := 0.0001
	          else h := 0.0001*Abs(x);
	        if h < 0.0000001 then h := 0.0000001;
	        temp := x+h;
	        DoNothingWithThisVariable(temp);
	        h := temp-x;
	        {WritelnStringAndReelDansRapport('x = ',x,10);
	        WritelnStringAndReelDansRapport('h = ',h,10);}
	        fx := f(x);
	        dfx := (f(x+h)-fx)/h;
	      end
	    else
	      begin
	        fx := diff(x,dfx)
	      end;
  end;

begin
  if ax < cx then a := ax else a := cx;
  if ax > cx then b := ax else b := cx;
  v := bx;
  w := v;
  x := v;
  e := 0.0;
  CalculeFonctionEtDerivee(x,fx,dx);
  fv := fx;
  fw := fx;
  dv := dx;
  dw := dx;
  for iter := 1 to itmax do
    begin
      xm := 0.5*(a+b);
      tol1 := tol*Abs(x)+zeps;
      tol2 := 2.0*tol1;
      if Abs(x-xm) <= tol2-0.5*(b-a) then
        begin
          xmin := x;
          MinimisationParBrentAvecDerivee := fx;
          exit;
        end;
      if Abs(e) > tol1
        then
	        begin
	          d1 := 2.0*(b-a);
	          d2 := d1;
	          if dw <> dx then d1 := (w-x)*dx/(dx-dw);
	          if dv <> dx then d2 := (v-x)*dx/(dx-dv);
	          u1 := x+d1;
	          u2 := x+d2;
	          ok1 := ((a-u1)*(u1-b) > 0.0) and (dx*d1 <= 0.0);
	          ok2 := ((a-u2)*(u2-b) > 0.0) and (dx*d2 <= 0.0);
	          olde := e;
	          e := d;
	          if ok1 or ok2
	            then
		            begin
		              if ok1 and ok2
		                then
		                  if Abs(d1) < Abs(d2)
		                    then d := d1
		                    else d := d2
		                else
		                  if ok1
		                    then d := d1
		                    else d := d2;
		              if Abs(d) <= Abs(0.5*olde)
		                then
		                  begin
		                    u := x+d;
		                    if (u-a  < tol2) or (b-u < tol2) then d := sign(tol1,xm-x);
		                  end
		                else
		                  begin
		                    if dx >= 0.0
		                      then e := a-x
		                      else e := b-x;
		                    d := 0.5*e;
		                  end
		            end
	            else
	              begin
	                if dx >= 0.0
	                  then e := a-x
	                  else e := b-x;
	                d := 0.5*e;
	              end
	        end
	      else
	        begin
	          if dx >= 0.0
              then e := a-x
              else e := b-x;
            d := 0.5*e;
	        end;
	    if Abs(d) >= tol1
	      then
	        begin
	          u := x+d;
	          CalculeFonctionEtDerivee(u,fu,du);
	        end
	      else
	        begin
	          u := x+sign(tol1,d);
	          CalculeFonctionEtDerivee(u,fu,du);
	          if fu > fx then
	            begin
	              xmin := x;
	              MinimisationParBrentAvecDerivee := fx;
	              exit;
	            end;
	        end;
	    if fu <= fx
	      then
	        begin
	          if u >= x
	            then a := x
	            else b := x;
	            v := w;
	            fv := fw;
	            dv := dw;
	            w := x;
	            fw := fx;
	            dw := dx;
	            x := u;
	            fx := fu;
	            dx := du;
	        end
	      else
	        begin
	          if u < x
	            then a := u
	            else b := u;
	          if (fu <= fw) or (w = x)
	            then
	              begin
	                v := w;
	                fv := fw;
	                dv := dw;
	                w := u;
	                fw := fu;
	                dw := du;
	              end
	            else
	              begin
	                if (fu < fv) or (v = x) or (v = w) then
	                  begin
	                    v := u;
	                    fv := fu;
	                    dv := du;
	                  end;
	              end;
	        end;
    end;
  WritelnDansRapport('Pause dans la routine "MinimisationParBrentAvecDerivee" : trop d''iterations');
  xmin := x;
  MinimisationParBrentAvecDerivee := fx;
end;





procedure InitialiseFonctionLigne(f : FonctionMultidimensionnelle; var p,xi : PointMultidimensionnel);
var j : SInt32;
begin
  for j := 1 to g_dimensionDesPoints do
    begin
      g_vecteurP^[j] := p^[j];
      g_vecteurDirection^[j] := xi^[j];
    end;
  g_fonctionMultidimesionnelle := f;
end;


function AlloueMemoireFonctionLigne(n : SInt32) : boolean;
begin
  if AllocatePointMultidimensionnel(n,g_vecteurP) and
     AllocatePointMultidimensionnel(n,g_vecteurDirection) and
     AllocatePointMultidimensionnel(n,g_vecteurPPlusXFoisDir)
     then
       begin
         g_dimensionDesPoints := n;
         AlloueMemoireFonctionLigne := true;
       end
     else
       begin
         g_dimensionDesPoints := 0;
         AlerteSimple('Erreur : pas assez de mŽmoire pour executer AlloueMemoireFonctionLigne !');
         AlloueMemoireFonctionLigne := false;
       end;
end;

procedure LibereMemoireFonctionLigne;
begin
  DisposePointMultidimensionnel(g_vecteurP);
  DisposePointMultidimensionnel(g_vecteurDirection);
  DisposePointMultidimensionnel(g_vecteurPPlusXFoisDir);
end;

function FonctionLigne(x : TypeReel) : TypeReel;
var j : SInt32;
begin
  for j := 1 to g_dimensionDesPoints do
    g_vecteurPPlusXFoisDir^[j] := g_vecteurP^[j]+x*g_vecteurDirection^[j];
  FonctionLigne := g_fonctionMultidimesionnelle(g_vecteurPPlusXFoisDir);
end;



procedure LineMinimisation(f : FonctionMultidimensionnelle; var p,xi : PointMultidimensionnel; var fret : TypeReel);
const
  tol = 1.0e-4;
  {tol = 1.0e-2;}
var
  j : SInt32;
  xx,xmin,fx,fb,fa,bx,ax : TypeReel;
begin

  InitialiseFonctionLigne(f,p,xi);
  ax := 0.0;
  xx := 0.0001;
  MinimumBracketting(FonctionLigne,ax,xx,bx,fa,fx,fb);

  fret := MinimisationParBrent(FonctionLigne,ax,xx,bx,tol,xmin);
  {fret := MinimisationParBrentAvecDerivee(true,FonctionLigne,bidDiff,ax,xx,bx,tol,xmin);}

  for j := 1 to g_dimensionDesPoints do
    begin
      xi^[j] := xmin*xi^[j];
      p^[j] := p^[j]+xi^[j];
    end;
end;


procedure MinimisationMultidimensionnelleSimple(f : FonctionMultidimensionnelle; var p : PointMultidimensionnel; var iter : SInt32; var fret : TypeReel);
const
  itmax = 200;
label finNormale;
var
  n,its,i : SInt32;
  xi : PointMultidimensionnel;
  lambda, fold : TypeReel;
begin
  n := DimensionDuPointMultidimensionnel(p);

  if not(AllocatePointMultidimensionnel(n,xi))
   then
     begin
       AlerteSimple('pas assez de memoire pour allouer les vecteurs dans MinimisationMultidimensionnelleSimple !!!');
       exit;
     end;

  for its := 1 to itmax do
    begin

      fold := fret;
      CalculeGradientNumerique(f,p,fret,xi);


      for i := 1 to 100 do
        begin

          fold := fret;

          if abs(fret) > 1.0
            then lambda := 0.01 / abs(fret)
            else lambda := 0.01;

          {lambda := 0.000001;}

          CombinaisonLineairePointMultidimensionnel(p,xi,1,-lambda,p);

          fret := f(p);

          if fret > fold then
            begin
              {WritelnNumDansRapport('i = ',i);}
              leave;
            end;
        end;

    end;

  iter := itmax;


  finNormale :
  DisposePointMultidimensionnel(xi);

end;



procedure MinimisationMultidimensionnelleParConjugateGradient(f : FonctionMultidimensionnelle; var p : PointMultidimensionnel; ftol : TypeReel; var iter : SInt32; var fret : TypeReel);
const
  itmax = 100;
  eps = 1.0e-10;
  {eps = 1.0e-5;}
label finNormale;
var
  n,j,its : SInt32;
  gg,gam,fp,dgg : TypeReel;
  g,h,xi : PointMultidimensionnel;
begin
  n := DimensionDuPointMultidimensionnel(p);
  if not(AllocatePointMultidimensionnel(n,g))  or
     not(AllocatePointMultidimensionnel(n,h))  or
     not(AllocatePointMultidimensionnel(n,xi)) or
     not(AlloueMemoireFonctionLigne(n))
   then
     begin
       AlerteSimple('pas assez de memoire pour allouer les vecteurs dans MinimisationMultidimensionnelleParConjugateGradient !!!');
       exit;
     end;

  CalculeGradientNumerique(f,p,fp,xi);

  for j := 1 to n do
    begin
      g^[j] := -xi^[j];
      h^[j] := g^[j];
      xi^[j] := h^[j];
    end;

  for its := 1 to itmax do
    begin

      (*
      for j := 1 to n do
        begin
          WritelnDansRapport('p['+IntToStr(j)+'] = '+ReelEnStringAvecDecimales(p^[j],10));
        end;
      *)

      iter := its;
      LineMinimisation(f,p,xi,fret);
      if (2*Abs(fret-fp) <= ftol*(Abs(fret)+Abs(fp)+eps))
         and (its >= 10) then goto finNormale;

      CalculeGradientNumerique(f,p,fp,xi);

      gg := 0.0;
      dgg := 0.0;
      for j := 1 to n do
        begin
          gg := gg+sqr(g^[j]);
        (* dgg := dgg+sqr(xi^[j]);  *)     (* this statement for Fletcher-Reeves  *)
          dgg := dgg+(xi^[j]+g^[j])*xi^[j]; (* this statement for Polak-Ribiere    *)
        end;
      if gg < 0.000001 then goto finNormale;  {(norme du) gradient = 0 ? gagne !}
      gam := dgg/gg;
      for j := 1 to n do
        begin
          g^[j] := -xi^[j];
          h^[j] := g^[j]+gam*h^[j];
          xi^[j] := h^[j];
        end;
    end;

  WritelnDansRapport('Pause dans la routine MinimisationMultidimensionnelleParConjugateGradient : trop d''iterations');

  finNormale :
  DisposePointMultidimensionnel(xi);
  DisposePointMultidimensionnel(h);
  DisposePointMultidimensionnel(g);

end;










END.

