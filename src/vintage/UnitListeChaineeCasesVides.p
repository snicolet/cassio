UNIT UnitListeChaineeCasesVides;



INTERFACE







 USES UnitDefCassio;




procedure InitUnitListeChaineeCasesVides;
function ListeChaineeDesCasesVidesEstDisponible : boolean;
procedure SetListeChaineeDesCasesVidesEstDisponible(flag : boolean);

procedure CreeListeCasesVidesDeCettePosition(jeu : plateauOthello; listeChaineeUtiliseOrdreOptmisiseDesCases : boolean);
procedure CreerListeChaineeDesCasesVides( nbVides : SInt32; var tete : celluleCaseVideDansListeChainee; var buffer : t_bufferCellulesListeChainee; var whichTablePointeurs : tableDePointeurs; fonctionAppelante : String255);
procedure EnleverDeLaListeChaineeDesCasesVides(whichSquare : SInt32);
procedure RemettreDansLaListeChaineeDesCasesVides(whichSquare : SInt32);
procedure EcrireListeChaineeDesCasesVidesDansRapport(theList : celluleCaseVideDansListeChaineePtr);
procedure EcrireDeuxListesChaineesDesCasesVidesDansRapport(liste1,liste2 : celluleCaseVideDansListeChaineePtr);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitUtilitaires, UnitServicesDialogs, UnitScannerUtils, UnitRapport, UnitGestionDuTemps, UnitUtilitairesFinale, UnitConstrListeBitboard
     ;
{$ELSEC}
    ;
    {$I prelink/ListeChaineeCasesVides.lk}
{$ENDC}


{END_USE_CLAUSE}











var listeChaineeDisponible : boolean;

procedure InitUnitListeChaineeCasesVides;
begin
  SetListeChaineeDesCasesVidesEstDisponible(true);
end;

function ListeChaineeDesCasesVidesEstDisponible : boolean;
begin
  ListeChaineeDesCasesVidesEstDisponible := listeChaineeDisponible;
end;

procedure SetListeChaineeDesCasesVidesEstDisponible(flag : boolean);
begin
  listeChaineeDisponible := flag;
end;

procedure CreeListeCasesVidesDeCettePosition(jeu : plateauOthello; listeChaineeUtiliseOrdreOptmisiseDesCases : boolean);
var i,j,iCourant : SInt32;
begin

  gNbreNonCoins_entreeCoupGagnant := 0;
  gNbreVides_entreeCoupGagnant := 0;
  gNbreCoins_entreeCoupGagnant := 0;
  gNbreCoinsPlus1_entreeCoupGagnant := 0;
  gNbreCoinsPlus2_entreeCoupGagnant := 0;

 for i := 1 to 4 do       {les coins}
   begin
    iCourant := othellier[i];
    if jeu[iCourant] = pionVide then
      begin
        gNbreCoins_entreeCoupGagnant := gNbreCoins_entreeCoupGagnant+1;
        gCoins_entreeCoupGagnant[gNbreCoins_entreeCoupGagnant] := iCourant;
      end;
   end;
 gNbreCoinsPlus1_entreeCoupGagnant := gNbreCoins_entreeCoupGagnant+1;
 gNbreCoinsPlus2_entreeCoupGagnant := gNbreCoins_entreeCoupGagnant+2;

 for i := 5 to 64 do       {les autres cases vides (sans les coins) }
   begin
    iCourant := othellier[i];
    if jeu[iCourant] = pionVide then
      begin
        gNbreNonCoins_entreeCoupGagnant := gNbreNonCoins_entreeCoupGagnant+1;
        gNonCoins_entreeCoupGagnant[gNbreNonCoins_entreeCoupGagnant] := iCourant;
      end;
   end;

 for i := 1 to 64 do   {toutes les cases vides}
   begin
    iCourant := othellier[i];
    if jeu[iCourant] = pionVide then
      begin
        gNbreVides_entreeCoupGagnant := gNbreVides_entreeCoupGagnant+1;
        gCasesVides_entreeCoupGagnant[gNbreVides_entreeCoupGagnant] := iCourant;
        gVecteurParite := BXOR(gVecteurParite,constanteDeParite[iCourant]);
        inc(gNbreVidesCeQuadrantCoupGagnant[numeroQuadrant[iCourant]]);
      end;
   end;

 if listeChaineeUtiliseOrdreOptmisiseDesCases
   then
     begin
			 j := 0;
			 for i := 64 downto 1 do
			   begin
			     iCourant := worst2bestOrder[i];
			     if jeu[iCourant] = pionVide then
			       begin
			         j := j+1;
			         gListeCasesVidesOrdreJCWCoupGagnant[j] := iCourant;
			       end;
			   end;
		 end
   else
     begin
       for j := 1 to gNbreVides_entreeCoupGagnant do
         gListeCasesVidesOrdreJCWCoupGagnant[j] := gCasesVides_entreeCoupGagnant[j];
     end;
end;

procedure CreerListeChaineeDesCasesVides(nbVides : SInt32;
														             var tete : celluleCaseVideDansListeChainee;
														             var buffer : t_bufferCellulesListeChainee;
														             var whichTablePointeurs : tableDePointeurs;
														             fonctionAppelante : String255);
var i,whichSquare : SInt32;
    celluleDansListeChainee : celluleCaseVideDansListeChaineePtr;
    celluleDepart : celluleCaseVideDansListeChaineePtr;
    s : String255;
begin

  SetDoitReconstruireLaListeBitboard(true);

  if nbVides <= 0 then
    begin
      s := 'ERREUR : nbVides <= 0 dans CreerListeChaineeDesCasesVides (fonctionAppelante = '+fonctionAppelante+') Prevenez Stéphane.';
      AlerteSimple(s);
      WritelnDansRapport(s);
      with tete do
        begin
          square := 0;
          next := @tete;
          previous := @tete;
          constantePariteDeSquare := 0;
        end;
      exit(CreerListeChaineeDesCasesVides);
    end;

  for i := 0 to 65 do
    with buffer[i] do
      begin
        square := 0;
        next := NIL;
        previous := NIL;
        constantePariteDeSquare := 0;
      end;

  for i := 1 to nbVides do
    begin
      whichSquare := gListeCasesVidesOrdreJCWCoupGagnant[i];
      with buffer[i] do
        begin
          square := whichSquare;
          if i < nbVides
            then next := @buffer[i+1]
            else next := @tete;
          if i > 1
            then previous := @buffer[i-1]
            else previous := @tete;
          constantePariteDeSquare := constanteDeParite[whichSquare];
        end;
    end;

  with tete do
    begin
      square := 0;
      next := @buffer[1];
      previous := @buffer[nbVides];
      constantePariteDeSquare := 0;
    end;

  for i := 0 to 99 do
    whichTablePointeurs[i] := NIL;

  celluleDepart := @tete;
  celluleDansListeChainee := celluleDepart^.next;
  repeat
    whichTablePointeurs[celluleDansListeChainee^.square] := celluleDansListeChainee;
    celluleDansListeChainee := celluleDansListeChainee^.next;
  until celluleDansListeChainee = celluleDepart;

  ReconstruireLaTableListeBitboardToSquareSiNecessaire(nbVides,@tete);

end;



procedure EnleverDeLaListeChaineeDesCasesVides(whichSquare : SInt32);
var celluleDansListeChaineeCasesVides : celluleCaseVideDansListeChaineePtr;
begin
  if (whichSquare < 11) or (whichSquare > 88) then
    begin
      SysBeep(0);
      WritelnNumDansRapport('ERROR !! dans EnleverDeLaListeChaineeDesCasesVides, whichSquare = ',whichSquare);
      AlerteSimple('Gros problème dans EnleverDeLaListeChaineeDesCasesVides, prévenez Stéphane !');
      LanceInterruptionSimple('EnleverDeLaListeChaineeDesCasesVides (1)');
      exit(EnleverDeLaListeChaineeDesCasesVides);
    end;

  celluleDansListeChaineeCasesVides := gTableDesPointeurs[whichSquare];

  if celluleDansListeChaineeCasesVides = NIL then
    begin
      SysBeep(0);
      WritelnDansRapport('ERROR !! celluleDansListeChaineeCasesVides = NIL dans EnleverDeLaListeChaineeDesCasesVides');
      AlerteSimple('Enorme problème dans EnleverDeLaListeChaineeDesCasesVides, prévenez Stéphane !');
      LanceInterruptionSimple('EnleverDeLaListeChaineeDesCasesVides (2)');
      exit(EnleverDeLaListeChaineeDesCasesVides);
    end;

  with celluleDansListeChaineeCasesVides^ do
    begin
      previous^.next := next;
      next^.previous := previous;
    end;
end;

procedure RemettreDansLaListeChaineeDesCasesVides(whichSquare : SInt32);
var celluleDansListeChaineeCasesVides : celluleCaseVideDansListeChaineePtr;
begin
  if (whichSquare < 11) or (whichSquare > 88) then
    begin
      SysBeep(0);
      WritelnNumDansRapport('ERROR !! dans RemettreDansLaListeChaineeDesCasesVides, whichSquare = ',whichSquare);
      AlerteSimple('Gros problème dans RemettreDansLaListeChaineeDesCasesVides, prévenez Stéphane !');
      LanceInterruptionSimple('RemettreDansLaListeChaineeDesCasesVides (1)');
      exit(RemettreDansLaListeChaineeDesCasesVides);
    end;

  celluleDansListeChaineeCasesVides := gTableDesPointeurs[whichSquare];

  if celluleDansListeChaineeCasesVides = NIL then
    begin
      SysBeep(0);
      WritelnDansRapport('ERROR !! celluleDansListeChaineeCasesVides = NIL dans RemettreDansLaListeChaineeDesCasesVides');
      AlerteSimple('Enorme problème dans RemettreDansLaListeChaineeDesCasesVides, prévenez Stéphane !');
      LanceInterruptionSimple('RemettreDansLaListeChaineeDesCasesVides (2)');
      exit(RemettreDansLaListeChaineeDesCasesVides);
    end;

  with celluleDansListeChaineeCasesVides^ do
    begin
      previous^.next := celluleDansListeChaineeCasesVides;
      next^.previous := celluleDansListeChaineeCasesVides;
    end;
end;

procedure EcrireListeChaineeDesCasesVidesDansRapport(theList : celluleCaseVideDansListeChaineePtr);
var longueur : SInt32;
    celluleDansListeChainee : celluleCaseVideDansListeChaineePtr;
    celluleDepart : celluleCaseVideDansListeChaineePtr;
begin
  longueur := 0;
  celluleDepart := theList;
  celluleDansListeChainee := celluleDepart^.next;
  repeat
    with celluleDansListeChainee^ do
      begin
        inc(longueur);
        if (square >= 11) and (square <= 88)
          then
            begin
              if longueur = 1
			          then WriteStringDansRapport('[ '+CoupEnString(square,true))
			          else WriteStringDansRapport(', '+CoupEnString(square,true));
            end
          else
            begin
			        if longueur = 1
			          then WriteNumDansRapport('[',square)
			          else WriteNumDansRapport(',',square);
			      end;
        celluleDansListeChainee := next;
      end;
  until celluleDansListeChainee = celluleDepart;
  WritelnNumDansRapport(']   longueur = ',longueur);
end;

procedure EcrireDeuxListesChaineesDesCasesVidesDansRapport(liste1,liste2 : celluleCaseVideDansListeChaineePtr);
var celluleDansListeChainee1 : celluleCaseVideDansListeChaineePtr;
    celluleDepart1 : celluleCaseVideDansListeChaineePtr;
    celluleDansListeChainee2 : celluleCaseVideDansListeChaineePtr;
    celluleDepart2 : celluleCaseVideDansListeChaineePtr;
    longueur : SInt32;
begin
  longueur := 0;
  celluleDepart1 := liste1;
  celluleDansListeChainee1 := celluleDepart1^.next;
  celluleDepart2 := liste2;
  celluleDansListeChainee2 := celluleDepart2^.next;
  repeat
    inc(longueur);

    if longueur = 1
      then WriteDansRapport('[')
      else WriteDansRapport(',');
    WriteStringDansRapport('  square = '+CoupEnString(celluleDansListeChainee1^.square,true));
    WriteNumDansRapport('  next = ',SInt32(@celluleDansListeChainee1^.next));
    WriteNumDansRapport('  previous = ',SInt32(@celluleDansListeChainee1^.previous));


    if longueur = 1
      then WriteDansRapport('         [')
      else WriteDansRapport('         ,');
    WriteStringDansRapport('  square = '+CoupEnString(celluleDansListeChainee2^.square,true));
    WriteNumDansRapport('  next = ',SInt32(@celluleDansListeChainee2^.next));
    WriteNumDansRapport('  previous = ',SInt32(@celluleDansListeChainee2^.previous));

    WritelnDansRapport('');

    celluleDansListeChainee1 := celluleDansListeChainee1^.next;
    celluleDansListeChainee2 := celluleDansListeChainee2^.next;

  until (celluleDansListeChainee1 = celluleDepart1) or (longueur > 64);


  WritelnDansRapport(']');
  WritelnDansRapport('');
end;



procedure EtablitListeCasesVidesParListeChaineeTableau(var listeCasesVides : listeVides);
var nbVidesTrouvees : SInt32;
    celluleDansListeChaineeCasesVides : celluleCaseVideDansListeChaineePtr;
    celluleDepart : celluleCaseVideDansListeChaineePtr;
begin
  nbVidesTrouvees := 0;
  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  repeat
    with celluleDansListeChaineeCasesVides^ do
    BEGIN

      inc(nbVidesTrouvees);
      listeCasesVides[nbVidesTrouvees] := square;


      previous^.next := next;
		  next^.previous := previous;


      previous^.next := celluleDansListeChaineeCasesVides;
			next^.previous := celluleDansListeChaineeCasesVides;


      celluleDansListeChaineeCasesVides := next;
    END;
  until celluleDansListeChaineeCasesVides = celluleDepart;
end;

procedure EtablitListeCasesVidesParListeChaineePtr(var listeCasesVides : listeVides);
var nbVidesTrouvees : SInt32;
    celluleDansListeChaineeCasesVides : celluleCaseVideDansListeChaineePtr;
    celluleNext,cellulePrevious : celluleCaseVideDansListeChaineePtr;
    celluleDepart : celluleCaseVideDansListeChaineePtr;
begin
  nbVidesTrouvees := 0;
  celluleDepart := celluleCaseVideDansListeChaineePtr(@gTeteListeChaineeCasesVides);
  celluleDansListeChaineeCasesVides := celluleDepart^.next;
  cellulePrevious := celluleDepart;
  repeat
    with celluleDansListeChaineeCasesVides^ do
    BEGIN
      celluleNext := next;


      inc(nbVidesTrouvees);
      listeCasesVides[nbVidesTrouvees] := square;


      cellulePrevious^.next := celluleNext;
		  celluleNext^.previous := cellulePrevious;

		 {
		  previous^.next := next;
		  next^.previous := previous;
		 }


      cellulePrevious^.next := celluleDansListeChaineeCasesVides;
			celluleNext^.previous := celluleDansListeChaineeCasesVides;

			{
			previous^.next := celluleDansListeChaineeCasesVides;
		  next^.previous := celluleDansListeChaineeCasesVides;
		  }


      cellulePrevious := celluleDansListeChaineeCasesVides;
      celluleDansListeChaineeCasesVides := celluleNext;

    END;
  until celluleDansListeChaineeCasesVides = celluleDepart;
end;


END.
