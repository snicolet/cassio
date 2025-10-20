UNIT UnitGeneralSort;


INTERFACE





 uses UnitDefCassio;




procedure GeneralQuickSort(lo,up : SInt32; lecture : LectureTableauProc; affectation : AffectationProc; ordre : OrdreProc);
procedure GeneralShellSort(lo,up : SInt32; lecture : LectureTableauProc; affectation : AffectationProc; ordre : OrdreProc);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    fp
{$IFC NOT(USE_PRELINK)}
    , UnitSound, UnitRapport, UnitServicesDialogs, MyMathUtils ;
{$ELSEC}
    ;
    {$I prelink/GeneralSort.lk}
{$ENDC}


{END_USE_CLAUSE}












{ ATTENTION ! La routine d'ordre doit renvoyer vrai
              pour des ŽlŽments egaux, sinon QuickSort
              ne s'arrete pas ! }
procedure GeneralQuickSort(lo,up : SInt32; lecture : LectureTableauProc; affectation : AffectationProc; ordre : OrdreProc);
const nstack = 100;
      m = 7;
var i,j,k,l,ir,jstack : SInt32;
    a,temp,compar : SInt32;
    istack : array[1..nstack] of SInt32;
label 10,20,99;
begin
  if lo > up then
    begin
      temp := up;
      up := lo;
      lo := temp;
    end;
  for i := lo to up do affectation(i,i);
  if up-lo > 0 then
    begin
      jstack := 0;
      l := lo;
      ir := up;
      while true do begin
        if ir-l < m then begin
          for j := l+1 to ir do
            begin
              temp := lecture(j);
              for i := j-1 downto l do
                begin
                  compar := lecture(i);
                  if ordre(temp,compar) then goto 10;
                  affectation(i+1,compar);
                end;
              i := l-1;
              10:
              affectation(i+1,temp);
            end;

          if jstack = 0 then exit(GeneralQuickSort);
          ir := istack[jstack];
          l := istack[jstack-1];
          jstack := jstack-2;
        end
        else begin
          k := l + (ir - l) div 2;
          temp := lecture(k);
          affectation(k,lecture(l+1));
          affectation(l+1,temp);
          if ordre(lecture(l+1),lecture(ir)) then begin
            temp := lecture(l+1);
            affectation(l+1,lecture(ir));
            affectation(ir,temp);
          end;
          if ordre(lecture(l),lecture(ir)) then begin
            temp := lecture(l);
            affectation(l,lecture(ir));
            affectation(ir,temp);
          end;
          if ordre(lecture(l+1),lecture(l)) then begin
            temp := lecture(l+1);
            affectation(l+1,lecture(l));
            affectation(l,temp);
          end;
          i := l+1;
          j := ir;
          a := lecture(l);
          while true do begin
            repeat inc(i) until ordre(lecture(i),a);
            repeat dec(j) until ordre(a,lecture(j));
            if j < i then goto 20; {break}
            temp := lecture(i);
            affectation(i,lecture(j));
            affectation(j,temp);
          end;
  20:     affectation(l,lecture(j));
          affectation(j,a);
          jstack := jstack+2;
          if jstack > nstack then AlerteSimple('Erreur dans GeneralQuickSort : nstack est trop petit');
          if ir-i+1 >= j-l then begin
            istack[jstack] := ir;
            istack[jstack-1] := i;
            ir := j-1;
          end
          else begin
            istack[jstack] := j-1;
            istack[jstack-1] := l;
            l := i;
          end;
        end;
      end;
   99 :
   end;
end;  {GeneralQuickSort}



procedure GeneralShellSort(lo,up : SInt32; lecture : LectureTableauProc; affectation : AffectationProc; ordre : OrdreProc);
var i,d,j : SInt32;
    temp,compar : SInt32;
label 999;
begin
  if lo > up then
    begin
      temp := up;
      up := lo;
      lo := temp;
    end;
  for i := lo to up do
    affectation(i,i);
  if up-lo > 0 then
    begin
      d := up-lo+1;
      while d > 1 do
        begin
          if d < 5
            then d := 1
            else d := MyTrunc(0.45454*d);
          for i := up-d downto lo do
            begin
              temp := lecture(i);
              j := i+d;
              while j <= up do
                begin
                  compar := lecture(j);
                  if ordre(temp,compar)
                    then
                      begin
                        affectation(j-d,compar);
                        j := j+d;
                      end
                  else
                    goto 999;
                end;
              999:
              affectation(j-d,temp);
            end;
        end;
    end;
end; {GeneralShellSort}




end.
