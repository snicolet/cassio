UNIT UnitTriListe;


INTERFACE


 USES UnitDefCassio;


(* Initialisation de l'unité *)
procedure InitUnitTriListe;
procedure LibereMemoireUnitTriListe;


(* Tri de la liste des parties *)
procedure TrierListePartie(critereDeTri,algorithmeDeTri : SInt32);
procedure DoTrierListe(critereDeTri,algorithmeDeTri : SInt32);
function AlgoDeTriOptimum(critereDeTri : SInt32) : SInt32;
procedure InverserOrdreDeLaListeDansChaqueTournoi;


(* Tri des parties selectionnees de la liste suivant un classement dans le rapport *)
function TrierListeSuivantUnClassement : boolean;
procedure SetDoitExpliquerTrierListeSuivantUnClassement(flag : boolean);
function DoitExpliquerTrierListeSuivantUnClassement : boolean;
procedure ForceDoubleTriApresUnAjoutDeParties(whichGenreDeTri : SInt32);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils, Scrap, fp, Sound
{$IFC NOT(USE_PRELINK)}
    , SNEvents, UnitServicesRapport, UnitRapport
    , MyQuickDraw, UnitNouveauFormat, UnitListe, UnitCriteres, UnitServicesMemoire, UnitAccesNouveauFormat, UnitJaponais, UnitServicesDialogs
    , UnitCurseur, UnitOth2, UnitRapport, UnitPackedThorGame, MyMathUtils, UnitImportDesNoms, UnitSet, UnitRapportImplementation
    , UnitGeneralSort, MyStrings, UnitCarbonisation, UnitPressePapier, UnitGeometrie, UnitFichiersTEXT ;
{$ELSEC}
    ;
    {$I prelink/TriListe.lk}
{$ENDC}


{END_USE_CLAUSE}











var gDernierAlgoDeTriUtilise : SInt32;
    gTriPartiesParClassement :
       record
         ensembleDesJoueursClasses       : IntegerSet;
         nbrePartiesATrier               : SInt32;
         maTable                         : tableNumeroHdl;
         doitAfficherDialogueExplication : boolean;
       end;


procedure InitUnitTriListe;
begin
  gTriPartiesParClassement.ensembleDesJoueursClasses := MakeEmptyIntegerSet;
  gTriPartiesParClassement.doitAfficherDialogueExplication := true;
end;


procedure LibereMemoireUnitTriListe;
begin
  DisposeIntegerSet(gTriPartiesParClassement.ensembleDesJoueursClasses);
end;


procedure InverserOrdreDeLaListeDansChaqueTournoi;
var i,j,k,m,annee,tournoi : SInt32;
    a,b,lo,up : SInt32;
begin

  i := 1;
  k := tableTriListe^^[i];
  annee := GetAnneePartieParNroRefPartie(k);
  tournoi := GetNroTournoiParNroRefPartie(k);

  for j := 1 to nbPartiesChargees do
    begin
      m := tableTriListe^^[j];
      if (GetNroTournoiParNroRefPartie(m) <> tournoi) or (GetAnneePartieParNroRefPartie(m) <> annee) then
        begin
          // echanger l'ordre dans le morceau [i ... j-1]

          lo := i;
          up := j - 1;

          while (lo < up) do
            begin
              a := tableTriListe^^[lo];
              b := tableTriListe^^[up];
              tableTriListe^^[lo] := b;
              tableTriListe^^[up] := a;

              inc(lo);
              dec(up);
            end;


          i := j;
          k := tableTriListe^^[i];
          annee := GetAnneePartieParNroRefPartie(k);
          tournoi := GetNroTournoiParNroRefPartie(k);
        end;

    end;

end;


procedure TrierListePartie(critereDeTri,algorithmeDeTri : SInt32);
var s1,s2 : PackedThorGame;
    n1,n2 : SInt32;
    c1,c2 : String255;
    tick : SInt32;
    nbTests : SInt32;
    comparaison : SInt32;
    err : OSErr;

  function PlusGrand(a,b : SInt32) : boolean;
  begin
     inc(nbTests);
     PlusGrand := false;
     case critereDeTri of
       TriParDate           :
         begin
           n1 := GetAnneePartieParNroRefPartie(a);
           n2 := GetAnneePartieParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 < n2 then PlusGrand := false else
             begin  {meme annee : on classe par tournoi}
               n1 := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(a);
               n2 := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(b);
               if n1 > n2 then PlusGrand := true else
               if n1 < n2 then PlusGrand := false else
                 begin
                   if DernierCritereDeTriListeParJoueur = TriParJoueurNoir {on simule un tri stable}
                     then
                       begin
                         {meme tournoi : on classe par joueur noir}
    		                  n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
    		                  n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
    		                  if n1 > n2 then PlusGrand := true else
    		                  if n1 < n2 then PlusGrand := false else
    		                    begin  {meme joueur noir : on classe par joueur blanc}
    		                      n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
    		                      n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
    		                      if n1 > n2 then PlusGrand := true else
    		                      if n1 = n2 then PlusGrand := a > b;
    		                    end;
                       end
                     else
                       begin
                         {meme tournoi : on classe par joueur Blanc}
    		                  n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
    		                  n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
    		                  if n1 > n2 then PlusGrand := true else
    		                  if n1 < n2 then PlusGrand := false else
    		                    begin  {meme joueur Blanc : on classe par joueur noir}
    		                      n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
    		                      n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
    		                      if n1 > n2 then PlusGrand := true else
    		                      if n1 = n2 then PlusGrand := a > b;
    		                    end;
                       end;
                 end;
             end;
         end;
       TriParAntiDate           :
         begin
           n1 := GetAnneePartieParNroRefPartie(a);
           n2 := GetAnneePartieParNroRefPartie(b);
           if n1 < n2 then PlusGrand := true else
           if n1 > n2 then PlusGrand := false else
             begin  {meme annee : on classe par tournoi}
               n1 := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(a);
               n2 := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(b);
               if n1 < n2 then PlusGrand := true else
               if n1 > n2 then PlusGrand := false else
                 begin  {meme tournoi : on classe par joueur noir}
                   if DernierCritereDeTriListeParJoueur = TriParJoueurNoir {on simule un tri stable}
                     then
                       begin
                         {meme tournoi : on classe par joueur noir}
    		                  n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
    		                  n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
    		                  if n1 > n2 then PlusGrand := true else
    		                  if n1 < n2 then PlusGrand := false else
    		                    begin  {meme joueur noir : on classe par joueur blanc}
    		                      n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
    		                      n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
    		                      if n1 > n2 then PlusGrand := true else
    		                      if n1 = n2 then PlusGrand := a > b;
    		                    end;
                       end
                     else
                       begin
                         {meme tournoi : on classe par joueur Blanc}
    		                  n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
    		                  n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
    		                  if n1 > n2 then PlusGrand := true else
    		                  if n1 < n2 then PlusGrand := false else
    		                    begin  {meme joueur Blanc : on classe par joueur noir}
    		                      n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
    		                      n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
    		                      if n1 > n2 then PlusGrand := true else
    		                      if n1 = n2 then PlusGrand := a > b;
    		                    end;
                       end;
                 end;
             end;
         end;
       TriParJoueurNoir     :
         begin
           n1 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(a);
           n2 := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParJoueurBlanc    :
         begin
           n1 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(a);
           n2 := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParNroJoueurNoir     :
         begin
           n1 := GetNroJoueurNoirParNroRefPartie(a);
           n2 := GetNroJoueurNoirParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParNroJoueurBlanc    :
         begin
           n1 := GetNroJoueurBlancParNroRefPartie(a);
           n2 := GetNroJoueurBlancParNroRefPartie(b);
           if n1 > n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParOuverture      :
          begin
            ExtraitPartieTableStockageParties(a,s1);
            ExtraitPartieTableStockageParties(b,s2);
            comparaison := COMPARE_PACKED_GAMES(s1, s2);
            if (comparaison > 0) then PlusGrand := true else  (** s1 > s2 **)
            if (comparaison = 0) then PlusGrand := a > b;     (** s1 = s2 **)
          end;
       TriParScoreTheorique :
         begin
           c1 := GetGainTheoriqueParNroRefPartie(a);
           c2 := GetGainTheoriqueParNroRefPartie(b);
           if c1 < c2 then PlusGrand := true else
           if c1 = c2 then PlusGrand := a > b;
         end;
       TriParScoreReel      :
         begin
           n1 := GetScoreReelParNroRefPartie(a);
           n2 := GetScoreReelParNroRefPartie(b);
           if n1 < n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
       TriParDistribution   :
         begin
           n1 := GetNroDistributionParNroRefPartie(a);
           n2 := GetNroDistributionParNroRefPartie(b);
           if n1 < n2 then PlusGrand := true else
           if n1 = n2 then PlusGrand := a > b;
         end;
     end;
  end;

  (** tri par dénombrement, voir Cormen-Leiserson-Rivest p.172  **)
  procedure EnumerationSort(lo,up : SInt32; critereDeTri : SInt16);
  type CountingTable = array[-10..100000] of SInt32;
       CountingTablePtr = ^CountingTable;
  var valeur,i,j,kmin,kmax : SInt32;
      count : CountingTablePtr;
      taille : SInt32;
  begin

    taille := (20+Max(Max(3000,nbMaxJoueursEnMemoire),nbMaxTournoisEnMemoire)) *sizeof(SInt32);

    count := CountingTablePtr(AllocateMemoryPtr(taille));

    if (count <> NIL) then
      begin
  	    for i := lo to up do tableTriListeAux^^[i] := tableTriListe^^[i];
  	    case critereDeTri of
  	      TriParDate           :
  	        begin
  	          kmin := 1900; kmax := 3000;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetAnneePartieParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetAnneePartieParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParAntiDate       :
  	        begin
  	          kmin := 0; kmax := 3000;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[kmax-GetAnneePartieParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := kmax-GetAnneePartieParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParTournoi        :
  	        begin
  	          kmin := -1; kmax := TournoisNouveauFormat.nbTournoisNouveauFormat+10;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParJoueurNoir     :
  	        begin
  	          kmin := -1; kmax := JoueursNouveauFormat.nbJoueursNouveauFormat+10;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParJoueurBlanc    :
  	        begin
  	          kmin := -1; kmax := JoueursNouveauFormat.nbJoueursNouveauFormat+10;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParNroJoueurNoir     :
  	        begin
  	          kmin := -1; kmax := JoueursNouveauFormat.nbJoueursNouveauFormat+10;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetNroJoueurNoirParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetNroJoueurNoirParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParNroJoueurBlanc    :
  	        begin
  	          kmin := -1; kmax := JoueursNouveauFormat.nbJoueursNouveauFormat+10;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetNroJoueurBlancParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetNroJoueurBlancParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParScoreTheorique :
  	        begin
  	          kmin := 0; kmax := 64;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetScoreTheoriqueParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetScoreTheoriqueParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParScoreReel      :
  	        begin
  	          kmin := 0; kmax := 64;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetScoreReelParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetScoreReelParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	      TriParDistribution      :
  	        begin
  	          kmin := 0; kmax := nbMaxDistributions+10;
  	          for i := kmin to kmax do count^[i] := 0;
  	          for j := lo to up do inc(count^[GetNroDistributionParNroRefPartie(tableTriListeAux^^[j])]);
  	          for i := kmin+1 to kmax do count^[i] := count^[i]+count^[i-1];
  	          for j := up downto lo do
  	            begin
  	              valeur := GetNroDistributionParNroRefPartie(tableTriListeAux^^[j]);
  	              tableTriListe^^[count^[valeur]] := tableTriListeAux^^[j];
  	              dec(count^[valeur]);
  	            end;
  	        end;
  	    end;
  	  end;
	  if count <> NIL then DisposeMemoryPtr(Ptr(count));
  end;

  procedure RadixSort(lo,up : SInt32);
  var i : SInt32;
  begin
    for i := lo to up do tableTriListe^^[i] := i;
    case critereDeTri of
      TriParDate           :
        begin
          EnumerationSort(lo,up,TriParTournoi);
          EnumerationSort(lo,up,TriParDate);
        end;
      TriParAntiDate       :
        begin
          EnumerationSort(lo,up,TriParTournoi);
          EnumerationSort(lo,up,TriParAntiDate);
        end;
      TriParJoueurNoir     :
        begin
          EnumerationSort(lo,up,TriParJoueurNoir);
        end;
      TriParJoueurBlanc    :
        begin
          EnumerationSort(lo,up,TriParJoueurBlanc);
        end;
      TriParScoreTheorique :
        begin
          EnumerationSort(lo,up,TriParScoreReel);
          EnumerationSort(lo,up,TriParScoreTheorique);
        end;
      TriParScoreReel      :
        begin
          EnumerationSort(lo,up,TriParScoreReel);
        end;
      TriParDistribution      :
        begin
          EnumerationSort(lo,up,TriParDistribution);
        end;
    end;
  end;

  procedure ShellSort(lo,up : SInt32);
  var i,d,j,temp : SInt32;
  begin
    for i := lo to up do tableTriListe^^[i] := i;
    if up-lo > 0 then
      begin
        d := up-lo+1;
        while d > 1 do
          begin
            if d < 5
              then d := 1
              else d := Trunc(0.45454*d);
            for i := up-d downto lo do
              begin
                temp := tableTriListe^^[i];
                j := i+d;
                while (j <= up) and PlusGrand(temp,tableTriListe^^[j]) do
                  begin
                    tableTriListe^^[j-d] := tableTriListe^^[j];
                    j := j+d;
                  end;
                tableTriListe^^[j-d] := temp;
              end;
          end;
      end;
  end; {shellSort}

  procedure ShellSortWithFixIncrements(lo,up : SInt32);
  var i,d,j,k,temp : SInt32;
      increments : array[1..20] of SInt32;
  begin
    increments[1] := 34807;
    increments[2] := 15823;
    increments[3] := 7193;
    increments[4] := 3271;
    increments[5] := 1489;
    increments[6] := 677;
    increments[7] := 307;
    increments[8] := 137;
    increments[9] := 61;
    increments[10] := 29;
    increments[11] := 13;
    increments[12] := 5;
    increments[13] := 2;
    increments[14] := 1;
    increments[15] := 0;
    for i := lo to up do tableTriListe^^[i] := i;
    if up-lo > 0 then
      begin
        for k := 1 to 14 do
          begin
            d := increments[k];
            for i := up-d downto lo do
              begin
                temp := tableTriListe^^[i];
                j := i+d;
                while (j <= up) and PlusGrand(temp,tableTriListe^^[j]) do
                  begin
                    tableTriListe^^[j-d] := tableTriListe^^[j];
                    j := j+d;
                  end;
                tableTriListe^^[j-d] := temp;
              end;
          end;
      end;
  end; {shellSortWithFixIncrements}


  { ATTENTION ! La routine d'ordre doit renvoyer vrai
              pour des éléments egaux, sinon QuickSort
              ne s'arrete pas ! }
  procedure QuickSort(lo,up : SInt32);
  const nstack = 200;
        m = 7;
  var i,j,k,l,ir,jstack : SInt32;
      a,temp : SInt32;
      istack : array[1..nstack] of SInt32;
  label 10,20,99;
  begin
    for i := lo to up do tableTriListe^^[i] := i;
    if up-lo > 0 then
      begin
        jstack := 0;
        l := lo;
        ir := up;
        while true do begin
          if ir-l < m then begin
            for j := l+1 to ir do
              begin
                temp := tableTriListe^^[j];
                for i := j-1 downto l do
                  begin
                    if PlusGrand(temp,tableTriListe^^[i]) then goto 10;
                    tableTriListe^^[i+1] := tableTriListe^^[i];
                  end;
                i := l-1;
                10:
                tableTriListe^^[i+1] := temp;
              end;

            if jstack = 0 then exit;
            ir := istack[jstack];
            l := istack[jstack-1];
            jstack := jstack-2;
          end
          else begin
            k := l + (ir - l) div 2;
            temp := tableTriListe^^[k];
            tableTriListe^^[k] := tableTriListe^^[l+1];
            tableTriListe^^[l+1] := temp;
            if PlusGrand(tableTriListe^^[l+1],tableTriListe^^[ir]) then begin
              temp := tableTriListe^^[l+1];
              tableTriListe^^[l+1] := tableTriListe^^[ir];
              tableTriListe^^[ir] := temp;
            end;
            if PlusGrand(tableTriListe^^[l],tableTriListe^^[ir]) then begin
              temp := tableTriListe^^[l];
              tableTriListe^^[l] := tableTriListe^^[ir];
              tableTriListe^^[ir] := temp;
            end;
            if PlusGrand(tableTriListe^^[l+1],tableTriListe^^[l]) then begin
              temp := tableTriListe^^[l+1];
              tableTriListe^^[l+1] := tableTriListe^^[l];
              tableTriListe^^[l] := temp;
            end;
            i := l+1;
            j := ir;
            a := tableTriListe^^[l];
            while true do begin
              repeat inc(i) until (j < i) or PlusGrand(tableTriListe^^[i],a);
              repeat dec(j) until (j < i) or PlusGrand(a,tableTriListe^^[j]);
              if j < i then goto 20; {break}
              temp := tableTriListe^^[i];
              tableTriListe^^[i] := tableTriListe^^[j];
              tableTriListe^^[j] := temp;
            end;
    20:     tableTriListe^^[l] := tableTriListe^^[j];
            tableTriListe^^[j] := a;
            jstack := jstack+2;
            if jstack > nstack then AlerteSimple('Erreur dans QuickSort : nstack est trop petit');
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
   end;

begin  {TrierListePartie}

  if not(AutorisationCalculsLongsSurListe)
    then exit;

  if problemeMemoireBase
     then exit;

  if ((critereDeTri = TriParJoueurBlanc) or (critereDeTri = TriParJoueurNoir)) and not(JoueursEtTournoisEnMemoire)
     then exit;

  if (critereDeTri = TriParDate) and LectureAntichronologique then critereDeTri := TriParAntiDate;
  if (critereDeTri = TriParAntiDate) and not(LectureAntichronologique) then critereDeTri := TriParDate;

  if ((critereDeTri = TriParJoueurBlanc) or
      (critereDeTri = TriParJoueurNoir) or
      (critereDeTri = TriParDate) or
      (critereDeTri = TriParAntiDate)) then
        begin
          if not(JoueursNouveauFormat.dejaTriesAlphabetiquement) then
            begin
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant TrierAlphabetiquementJoueursNouveauFormat dans TrierListePartie',true);
              TrierAlphabetiquementJoueursNouveauFormat;
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Apres TrierAlphabetiquementJoueursNouveauFormat dans TrierListePartie',true);
              if gVersionJaponaiseDeCassio and gHasJapaneseScript
                then err := LitNomsDesJoueursEnJaponais;
            end;
          if not(TournoisNouveauFormat.dejaTriesAlphabetiquement) then
            begin
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant TrierAlphabetiquementTournoisNouveauFormat dans TrierListePartie',true);
              TrierAlphabetiquementTournoisNouveauFormat;
              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Apres TrierAlphabetiquementTournoisNouveauFormat dans TrierListePartie',true);
              if gVersionJaponaiseDeCassio and gHasJapaneseScript
                then err := LitNomsDesTournoisEnJaponais;
            end;
        end;

  {
  if BAND(theEvent.modifiers,optionKey) <> 0 then algorithmeDeTri := kShellSort;
  if BAND(theEvent.modifiers,controlKey) <> 0 then algorithmeDeTri := kRadixSort;
  if BAND(theEvent.modifiers,shiftKey) <> 0 then algorithmeDeTri := kEnumerationSort;
  }

  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant le tri des parties proprement dit dans TrierListePartie',true);

  nbTests := 0;
  tick := TickCount;
  if critereDeTri = TriParClassementDuRapport
    then
      begin
        if not(TrierListeSuivantUnClassement)
          then exit;
      end
    else
      case algorithmeDeTri of
        kShellSort                  : ShellSort(1,nbPartiesChargees);
        kShellsortWithFixIncrements : ShellSortWithFixIncrements(1,nbPartiesChargees);
        kQuickSort                  : QuickSort(1,nbPartiesChargees);
        kRadixSort                  : RadixSort(1,nbPartiesChargees);
        kEnumerationSort            : EnumerationSort(1,nbPartiesChargees,critereDeTri);
      end;
  tick := TickCount-tick;

  {
  case critereDeTri of
   TriParDate           : WriteDansRapport('TriParDate : ');
   TriParAntiDate       : WriteDansRapport('TriParAntiDate : ');
   TriParJoueurNoir     : WriteDansRapport('TriParJoueurNoir : ');
   TriParJoueurBlanc    : WriteDansRapport('TriParJoueurBlanc : ');
   TriParNroJoueurNoir  : WriteDansRapport('TriParNroJoueurNoir : ');
   TriParNroJoueurBlanc : WriteDansRapport('TriParNroJoueurBlanc : ');
   TriParOuverture      : WriteDansRapport('TriParOuverture : ');
   TriParScoreTheorique : WriteDansRapport('TriParScoreTheorique : ');
   TriParScoreReel      : WriteDansRapport('TriParScoreReel : ');
   TriParDistribution   : WriteDansRapport('TriParDistribution : ');
  end;
  case algorithmeDeTri of
    kShellSort                  : WriteDansRapport('ShellSort');
    kShellsortWithFixIncrements : WriteDansRapport('ShellSortWithFixIncrements');
    kQuickSort                  : WriteDansRapport('QuickSort');
    kRadixSort                  : WriteDansRapport('RadixSort');
    kEnumerationSort            : WriteDansRapport('EnumerationSort');
  end;
  WriteNumDansRapport(', nb de tests  =',nbTests);
  WritelnNumDansRapport(',  temps =',tick);
  }

  if (critereDeTri = TriParAntiDate) then InverserOrdreDeLaListeDansChaqueTournoi;


  if critereDeTri = TriParAntiDate then critereDeTri := TriParDate;
  if critereDeTri = TriParJoueurNoir then DernierCritereDeTriListeParJoueur := TriParJoueurNoir;
  if critereDeTri = TriParJoueurBlanc then DernierCritereDeTriListeParJoueur := TriParJoueurBlanc;

  gDernierAlgoDeTriUtilise := algorithmeDeTri;
end;




procedure DoTrierListe(critereDeTri,algorithmeDeTri : SInt32);
var i,etat : SInt32;
    ancienCritereDeTri,ancienAlgoDeTri : SInt32;
    unRect : rect;
    oldport : grafPtr;
begin
  {if (nbPartiesActives > 0) then}
    begin
      GetPort(oldport);
      ancienCritereDeTri := gGenreDeTriListe;
      ancienAlgoDeTri := gDernierAlgoDeTriUtilise;
      if (ancienCritereDeTri <> critereDeTri) or (critereDeTri = TriParClassementDuRapport) or
         (ancienAlgoDeTri <> algorithmeDeTri) then
        begin
          AnnulerSousCriteresRuban;
          if windowListeOpen then
            begin
              SetPortByWindow(wListePtr);
              case critereDeTri of
                TriParDistribution        : unRect := RubanDistributionRect;
                TriParDate                : unRect := RubanTournoiRect;
                TriParJoueurNoir          : unRect := RubanNoirsRect;
                TriParJoueurBlanc         : unRect := RubanBlancsRect;
                TriParOuverture           : unRect := RubanCoupRect;
                TriParScoreTheorique      : unRect := RubanTheoriqueRect;
                TriParScoreReel           : unRect := RubanReelRect;
                TriParClassementDuRapport : unRect := MakeRect(0,0,0,0);
              end;
              InvertRect(unRect);
            end;

          if not(gPendantLesInitialisationsDeCassio) then
            begin
              watch := GetCursor(watchcursor);
              SafeSetCursor(watch);
            end;
          OrdreDuTriRenverse := false;
          gGenreDeTriListe := critereDeTri;
          for i := 0 to 65 do
            begin
              etat := GetNombreDePartiesActivesDansLeCachePourCeCoup(i);
              if (etat <> PasDePartieActive) and (etat <> 1) then
                if ListePartiesEstGardeeDansLeCache(i,etat) then
                  InvalidateNombrePartiesActivesDansLeCache(i);
            end;
          TrierListePartie(critereDeTri,algorithmeDeTri);
          if windowListeOpen then
            begin
              SetPortByWindow(wListePtr);
              InvertRect(unRect);
            end;
          EcritRubanListe(false);
          CalculEmplacementCriteresListe;
          LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
          RemettreLeCurseurNormalDeCassio;
        end;
      SetPort(oldport);
    end;
end;


function AlgoDeTriOptimum(critereDeTri : SInt32) : SInt32;
begin
  if critereDeTri = TriParOuverture
    then AlgoDeTriOptimum := kQuickSort
    else AlgoDeTriOptimum := kRadixSort;
end;


procedure NettoyerLigneClassementAvantApprentissageDuJoueur(var ligne : String255);
begin
  EnleveEspacesDeGaucheSurPlace(ligne);

  // on enleve les numeros FFO
  ligne := EnleveChiffresEntreCesCaracteres('(',')',ligne,false);

  // on enleve les departages
  ligne := EnleveChiffresEntreCesCaracteres('{','}',ligne,false);
  ligne := EnleveChiffresEntreCesCaracteres('[',']',ligne,false);

  // on enleve les noms de pays
  ligne := EnleveCesCaracteresEntreCesCaracteres(['A'..'Z'],'{','}',ligne,false);

  // on enleve le 1.  en debut de ligne
  ligne := EnleveChiffresAvantCeCaractereEnDebutDeLigne('.',ligne,false);

  // on enleve le +1 et +1.5/3  en fin de ligne
  ligne := EnleveCesCaracteresApresCeCaractereEnFinDeLigne(['0'..'9','.','/'],'+',ligne,false);
  ligne := EnleveChiffresApresCeCaractereEnFinDeLigne('+',ligne,false);

end;


procedure AjouterJoueurDansClassement(var ligne : String255; var numeroJoueur : SInt32);
var s : String255;
    numeroNoir, numeroBlanc : SInt32;
    confianceDansLesJoueurs : double;
    rangDeCeJoueur : SInt32;
    oldData : SInt32;
begin

  NettoyerLigneClassementAvantApprentissageDuJoueur(ligne);

  (* on fabrique un score de partie fictive *)
  s := ligne + '32-32' + ligne;

  if TrouverNomsDesJoueursDansNomDeFichier(s, numeroNoir, numeroBlanc, 0, confianceDansLesJoueurs) then
    begin
      with gTriPartiesParClassement do
        begin
          numeroJoueur   := numeroNoir;

          if not(MemberOfIntegerSet(numeroJoueur,oldData,ensembleDesJoueursClasses)) then
            begin
              rangDeCeJoueur := ensembleDesJoueursClasses.cardinal + 1;
              AddIntegerToSet(numeroJoueur, rangDeCeJoueur, ensembleDesJoueursClasses);
            end;
        end;
    end;
end;


procedure AjouterJoueurDansClassementFromFichier(var myLongString : LongString; var theFic : FichierTEXT; var numeroJoueur : SInt32);
begin {$unused theFic }
  AjouterJoueurDansClassement(myLongString.debutLigne,numeroJoueur);
end;


function GetRangDeCeJoueurDansClassementDuRapport(whichPlayer : SInt32) : SInt32;
var result : SInt32;
begin
  if MemberOfIntegerSet(whichPlayer, result, gTriPartiesParClassement.ensembleDesJoueursClasses)
    then GetRangDeCeJoueurDansClassementDuRapport := result
    else GetRangDeCeJoueurDansClassementDuRapport := 100000;
end;


procedure EcritJoueurClasseDansRapport(var x : ABR);
begin
  WritelnNumDansRapport(GetNomJoueur(x^.cle) + ' => ', x^.data);
end;


function OrdreSuivantUnClassement(a,b : SInt32) : boolean;
var ref1,ref2 : SInt32;
    n1,n2,b1,b2 : SInt32;
    min1,min2,max1,max2 : SInt32;
begin


  ref1 := a;
  ref2 := b;

  n1 := GetRangDeCeJoueurDansClassementDuRapport(GetNroJoueurNoirParNroRefPartie(ref1));
  n2 := GetRangDeCeJoueurDansClassementDuRapport(GetNroJoueurNoirParNroRefPartie(ref2));

  b1 := GetRangDeCeJoueurDansClassementDuRapport(GetNroJoueurBlancParNroRefPartie(ref1));
  b2 := GetRangDeCeJoueurDansClassementDuRapport(GetNroJoueurBlancParNroRefPartie(ref2));

  min1 := Min(n1,b1);
  max1 := Max(n1,b1);

  min2 := Min(n2,b2);
  max2 := Max(n2,b2);


  OrdreSuivantUnClassement := (a > b);

  if min1 > min2 then OrdreSuivantUnClassement := true else
  if min1 < min2 then OrdreSuivantUnClassement := false else
    begin
      { on sait que min1 = min2 }
      { maintenant il faut choisir si on met toutes les parties de Noir,
        puis toutes les parties de Blanc, ou si on trie les parties
        strictement, quitte à mixer les couleurs }

      if BAND(theEvent.modifiers,optionKey) = 0
        then
          begin { on sépare les couleurs }
            if (min1 = n1) and (min2 = b2) then OrdreSuivantUnClassement := false else
            if (min1 = b1) and (min2 = n2) then OrdreSuivantUnClassement := true else

            if max1 > max2 then OrdreSuivantUnClassement := true else
            if max1 < max2 then OrdreSuivantUnClassement := false;
          end
        else
          begin { on mixte les couleurs }
            if max1 > max2 then OrdreSuivantUnClassement := true else
            if max1 < max2 then OrdreSuivantUnClassement := false;
          end;

    end;

  {Tamenori}

end;

function PartieEstDansLeTriSuivantClassementDuRapport(nroRef : SInt32) : boolean;
begin
  if NbPartiesDansLaSelectionDeLaListe <= 1
    then PartieEstDansLeTriSuivantClassementDuRapport := true  {dans ce cas, on veut trier toutes les parties}
    else PartieEstDansLeTriSuivantClassementDuRapport := PartieEstActiveEtSelectionnee(nroRef);
end;


procedure ApprendrePartiesSelectionneesDeLaListe;
var nroDansLaListe : SInt32;
    nroReferencePartie : SInt32;
begin
  with gTriPartiesParClassement do
    begin
      nbrePartiesATrier := 0;
      for nroDansLaListe := 1 to nbPartiesChargees do
        begin
          nroReferencePartie := tableTriListe^^[nroDansLaListe];
          if PartieEstDansLeTriSuivantClassementDuRapport(nroReferencePartie) then
            begin
              inc(nbrePartiesATrier);
              tableTriListeAux^^[nbrePartiesATrier] := nroReferencePartie;
            end;
        end;

    end;
end;


procedure SetDansTableTriListeAux(index,element : SInt32);
begin
  gTriPartiesParClassement.maTable^^[index] := element;
end;



function GetDansTableTriListeAux(index : SInt32) : SInt32;
begin
  GetDanstableTriListeAux := gTriPartiesParClassement.maTable^^[index];
end;



function OrdreTableTriListeAux(a,b : SInt32) : boolean;
var ref1,ref2 : SInt32;
begin
  ref1 := tableTriListeAux^^[a];
  ref2 := tableTriListeAux^^[b];
  OrdretableTriListeAux := OrdreSuivantUnClassement(ref1,ref2);
end;


procedure CalculerLeBonOrdreDesPartiesSelectionnees;
var uneTaille : SInt32;
    uneTailleLongint : SInt32;
begin

  with gTriPartiesParClassement do
    begin
      uneTaille        := nbrePartiesATrier + 10;
      uneTailleLongint := 4 * uneTaille;

      maTable := tableNumeroHdl(AllocateMemoryHdl(UneTailleLongint));

      if maTable <> NIL then
        begin
          GeneralShellSort(1,nbrePartiesATrier,GetDansTableTriListeAux,SetDansTableTriListeAux,OrdreTableTriListeAux);
        end;
    end;
end;


procedure MettrePartiesSelectionneesDansLeBonOrdre;
var nroDansLaListe,compteur : SInt32;
    nroReferencePartie : SInt32;
begin
  with gTriPartiesParClassement do
    if maTable <> NIL then
      begin

        compteur := 0;
        for nroDansLaListe := 1 to nbPartiesChargees do
          begin
            nroReferencePartie := tableTriListe^^[nroDansLaListe];
            if PartieEstDansLeTriSuivantClassementDuRapport(nroReferencePartie) then
              begin
                inc(compteur);
                tableTriListe^^[nroDansLaListe] := tableTriListeAux^^[GetDansTableTriListeAux(compteur)];
              end;
          end;

        DisposeMemoryHdl(Handle(maTable));
      end;
end;


procedure ApprendreClassementDuTournoi;
var bidon : SInt32;
    myError : OSErr;
    fic : FichierTEXT;
begin
  with gTriPartiesParClassement do
    begin
      DisposeIntegerSet(ensembleDesJoueursClasses);

      if (LongueurSelectionRapport > 3)
        then
          begin
            (* on prend le classement selectionné dans le rapport *)
            ForEachLineSelectedInRapportDo(AjouterJoueurDansClassement, bidon);
          end
        else
          begin
            (* on prend le classement dans le presse-papier *)
            myError := DumpPressePapierToFile(fic, MY_FOUR_CHAR_CODE('TEXT'));
            if (myError = NoErr) then
              begin
                ForEachLineInFileDo(fic.info, AjouterJoueurDansClassementFromFichier, bidon);
                myError := DetruitFichierTexte(fic);
              end;
          end;

    end;
end;


procedure SetDoitExpliquerTrierListeSuivantUnClassement(flag : boolean);
begin
  gTriPartiesParClassement.doitAfficherDialogueExplication := flag;
end;


function DoitExpliquerTrierListeSuivantUnClassement : boolean;
begin
  DoitExpliquerTrierListeSuivantUnClassement := gTriPartiesParClassement.doitAfficherDialogueExplication;
end;



function TrierListeSuivantUnClassement : boolean;
const kDialogueSyntaxeTriSuivantClassementID = 1135;


  procedure ExplicationSyntaxeTriListeSuivantClassementTournoi;
    begin
      if DoitExpliquerTrierListeSuivantUnClassement then
        begin
          DialogueSimple(kDialogueSyntaxeTriSuivantClassementID);
          TrierListeSuivantUnClassement := false;
          exit;
        end;
    end;



begin {TrierListeSuivantUnClassement}

  TrierListeSuivantUnClassement := false;

  if (LongueurSelectionRapport <= 3) and (LongueurPressePapier(MY_FOUR_CHAR_CODE('TEXT')) <= 10) then
    ExplicationSyntaxeTriListeSuivantClassementTournoi;

  ApprendreClassementDuTournoi;

  if gTriPartiesParClassement.ensembleDesJoueursClasses.cardinal <= 0
    then
      ExplicationSyntaxeTriListeSuivantClassementTournoi
    else
      begin
        ApprendrePartiesSelectionneesDeLaListe;
        CalculerLeBonOrdreDesPartiesSelectionnees;
        MettrePartiesSelectionneesDansLeBonOrdre;
        TrierListeSuivantUnClassement := true;
      end;

end;  {TrierListeSuivantUnClassement}


procedure ForceDoubleTriApresUnAjoutDeParties(whichGenreDeTri : SInt32);
begin
  if (whichGenreDeTri = TriParClassementDuRapport) then
    begin
      // correction d'un bug : si les anciennes parties étaient triées par classement,
      // alors les nouvelles n'apparaissaient pas lors de l'import (jusqu'au prochain tri) !
      // On remedie à cela en faisant une phase de tri supplémentaire...
      gGenreDeTriListe := TriParDate;
      TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
      CalculsEtAffichagePourBase(false,false);

      gGenreDeTriListe := whichGenreDeTri;
      TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
      CalculsEtAffichagePourBase(false,false);
    end;
end;



end.












































