UNIT UnitSuperviseur;




INTERFACE







 uses UnitDefCassio;




procedure InitialiseConstantesCodagePosition;
procedure InitialiseDirectionsJouables;
procedure Initialise_othellier;
procedure Initialise_IndexInfoDejaCalculees;
procedure Initialise_valeurs_tactiques;
procedure Initialise_TableCalculAdressesPatterns;


procedure InitialiseEndgameSquareOrder(whichOrder : SquareOrderType);
procedure RajouteWorst2Best(i1,i2,i3,i4 : SInt16);


procedure Calcul_position_centre(plat : plateauOthello);
procedure Calcule_Valeurs_Tactiques(plat : plateauOthello; avecCalculCentre : boolean);
procedure Initialise_table_heuristique(jeu : plateauOthello; debug : boolean);
function Elagage_a_priori(couleur,nbBla,nbNoi : SInt16; jeu : plateauOthello; var class : ListOfMoveRecords; longClass : SInt16) : SInt16;
procedure CoefficientsStandard;
procedure MultiplicationParCoeff;
procedure AppliqueCoeffsBienChoisis;
procedure Superviseur(n : SInt16);
procedure SetLargeurFenetreProbCut;

procedure InitUnitSuperviseur;





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, OSUtils, fp
{$IFC NOT(USE_PRELINK)}
    , UnitUtilitaires, UnitStrategie, UnitRapport, MyStrings, UnitGestionDuTemps
    , UnitModes, UnitScannerUtils, UnitServicesMemoire, MyMathUtils, SNEvents ;
{$ELSEC}
    ;
    {$I prelink/Superviseur.lk}
{$ENDC}


{END_USE_CLAUSE}








var compteurWorst2Best : SInt32;




procedure InitialiseConstantesCodagePosition;
begin
  codage_c1[pionVide] := $0000;     codage_c1[pionNoir] := $8000;  codage_c1[pionBlanc] := $C000;
  codage_c2[pionVide] := $0000;     codage_c2[pionNoir] := $2000;  codage_c2[pionBlanc] := $3000;
  codage_c3[pionVide] := $0000;     codage_c3[pionNoir] := $0800;  codage_c3[pionBlanc] := $0C00;
  codage_c4[pionVide] := $0000;     codage_c4[pionNoir] := $0200;  codage_c4[pionBlanc] := $0300;
  codage_c5[pionVide] := $0000;     codage_c5[pionNoir] := $0080;  codage_c5[pionBlanc] := $00C0;
  codage_c6[pionVide] := $0000;     codage_c6[pionNoir] := $0020;  codage_c6[pionBlanc] := $0030;
  codage_c7[pionVide] := $0000;     codage_c7[pionNoir] := $0008;  codage_c7[pionBlanc] := $000C;
  codage_c8[pionVide] := $0000;     codage_c8[pionNoir] := $0002;  codage_c8[pionBlanc] := $0003;
end;

procedure InitialiseDirectionsJouables;
var i,t : SInt16;
begin

  dirJouable[1] := -1;
  dirJouable[2] := 1;
  dirJouable[3] := -11;
  dirJouable[4] := -9;
  dirJouable[5] := 9;
  dirJouable[6] := 11;
  dirJouable[7] := -10;
  dirJouable[8] := 10;


  {directions jouables case par case}
  for t := 0 to 99 do dirJouableDeb[t] := 1;
  for t := 0 to 99 do dirJouableFin[t] := 0;
  for i := 1 to 64 do
    begin
      t := othellier[i];
      dirJouableDeb[t] := 1;
      dirJouableFin[t] := 8;
      if EstUneCaseBordNord(t) or EstUneCaseBordSud(t) then
        begin
          dirJouableDeb[t] := 1;
          dirJouableFin[t] := 2;
        end;
      if EstUneCaseBordOuest(t) or EstUneCaseBordEst(t) then
        begin
          dirJouableDeb[t] := 7;
          dirJouableFin[t] := 8;
        end;
      if estUnCoin[t] then
        begin
          dirJouableDeb[t] := 1;
          dirJouableFin[t] := 0;
        end;
    end;

end;

procedure Initialise_TableCalculAdressesPatterns;
var i,t : SInt16;

	procedure AjouterDescriptionLigne(numeroPattern,CaseDebutLigne,CaseFinLigne,LongueurLigne : SInt32; var indexDansPattern : SInt32);
	var x,dx,i : SInt32;
	begin
	  if LongueurLigne > 1
	    then dx := (CaseFinLigne-CaseDebutLigne) div (LongueurLigne-1)
	    else dx := 0;
	  if CaseDebutLigne+dx*(LongueurLigne-1) <> CaseFinLigne then
	    begin
	      SysBeep(0);
	      WritelnNumDansRapport('erreur dans le pattern : ',numeroPattern);
	      exit;
	    end;
	  x := CaseDebutLigne;
	  for i := 1 to LongueurLigne do
	    begin
	      inc(indexDansPattern);
	      descriptionParCases[numeroPattern,indexDansPattern] := x;
	      inc(nbPatternsImpliques[x]);
	      nroPattern[x,nbPatternsImpliques[x]] := numeroPattern;
	      deltaAdresse[x,nbPatternsImpliques[x]] := puiss3[indexDansPattern];
	      doubleDeltaAdresse[x,nbPatternsImpliques[x]] := doublePuiss3[indexDansPattern];
	      x := x+dx;
	    end;
	  taillePattern[numeroPattern] := indexDansPattern;
	  decalagePourPattern[numeroPattern] := (puiss3[indexDansPattern+1] div 2) +1;
  end;

  procedure AjouterDescriptionPattern1(numeroPattern,
                                      CaseDebutLigne1,CaseFinLigne1,LongueurLigne1 : SInt16);
	var indexDansPattern : SInt32;
	begin
	  indexDansPattern := 0;
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne1,CaseFinLigne1,LongueurLigne1,indexDansPattern);
  end;

  procedure AjouterDescriptionPattern2(numeroPattern,
                                      CaseDebutLigne1,CaseFinLigne1,LongueurLigne1 : SInt16;
                                      CaseDebutLigne2,CaseFinLigne2,LongueurLigne2 : SInt16);
	var indexDansPattern : SInt32;
	begin
	  indexDansPattern := 0;
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne1,CaseFinLigne1,LongueurLigne1,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne2,CaseFinLigne2,LongueurLigne2,indexDansPattern);
  end;

  procedure AjouterDescriptionPattern3(numeroPattern,
                                      CaseDebutLigne1,CaseFinLigne1,LongueurLigne1 : SInt16;
                                      CaseDebutLigne2,CaseFinLigne2,LongueurLigne2 : SInt16;
                                      CaseDebutLigne3,CaseFinLigne3,LongueurLigne3 : SInt16);
	var indexDansPattern : SInt32;
	begin
	  indexDansPattern := 0;
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne1,CaseFinLigne1,LongueurLigne1,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne2,CaseFinLigne2,LongueurLigne2,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne3,CaseFinLigne3,LongueurLigne3,indexDansPattern);
  end;

  procedure AjouterDescriptionPattern4(numeroPattern,
                                      CaseDebutLigne1,CaseFinLigne1,LongueurLigne1 : SInt16;
                                      CaseDebutLigne2,CaseFinLigne2,LongueurLigne2 : SInt16;
                                      CaseDebutLigne3,CaseFinLigne3,LongueurLigne3 : SInt16;
                                      CaseDebutLigne4,CaseFinLigne4,LongueurLigne4 : SInt16);
	var indexDansPattern : SInt32;
	begin
	  indexDansPattern := 0;
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne1,CaseFinLigne1,LongueurLigne1,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne2,CaseFinLigne2,LongueurLigne2,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne3,CaseFinLigne3,LongueurLigne3,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne4,CaseFinLigne4,LongueurLigne4,indexDansPattern);
  end;

  procedure AjouterDescriptionPattern5(numeroPattern,
                                      CaseDebutLigne1,CaseFinLigne1,LongueurLigne1 : SInt16;
                                      CaseDebutLigne2,CaseFinLigne2,LongueurLigne2 : SInt16;
                                      CaseDebutLigne3,CaseFinLigne3,LongueurLigne3 : SInt16;
                                      CaseDebutLigne4,CaseFinLigne4,LongueurLigne4 : SInt16;
                                      CaseDebutLigne5,CaseFinLigne5,LongueurLigne5 : SInt16);
	var indexDansPattern : SInt32;
	begin
	  indexDansPattern := 0;
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne1,CaseFinLigne1,LongueurLigne1,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne2,CaseFinLigne2,LongueurLigne2,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne3,CaseFinLigne3,LongueurLigne3,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne4,CaseFinLigne4,LongueurLigne4,indexDansPattern);
	  AjouterDescriptionLigne(numeroPattern,CaseDebutLigne5,CaseFinLigne5,LongueurLigne5,indexDansPattern);
  end;


begin
  for t := 0 to 99 do
    nbPatternsImpliques[t] := 0;

  for t := 0 to 99 do
    for i := 1 to kNbMaxPatternsParCase do
      begin
        nroPattern[t,i] := 0;
        deltaAdresse[t,i] := 0;
        doubleDeltaAdresse[t,i] := 0;
      end;

  for t := 0 to kNbPatternsDansEval do
    begin
      taillePattern[t] := 0;
      for i := -1 to kTailleMaximumPattern+3 do
        descriptionParCases[t,i] := 0;
      decalagePourPattern[t] := 0;
    end;

  AjouterDescriptionPattern1(kAdresseColonne1,11,81,8);
  AjouterDescriptionPattern1(kAdresseColonne2,12,82,8);
  AjouterDescriptionPattern1(kAdresseColonne3,13,83,8);
  AjouterDescriptionPattern1(kAdresseColonne4,14,84,8);
  AjouterDescriptionPattern1(kAdresseColonne5,15,85,8);
  AjouterDescriptionPattern1(kAdresseColonne6,16,86,8);
  AjouterDescriptionPattern1(kAdresseColonne7,17,87,8);
  AjouterDescriptionPattern1(kAdresseColonne8,18,88,8);
  AjouterDescriptionPattern1(kAdresseLigne1,11,18,8);
  AjouterDescriptionPattern1(kAdresseLigne2,21,28,8);
  AjouterDescriptionPattern1(kAdresseLigne3,31,38,8);
  AjouterDescriptionPattern1(kAdresseLigne4,41,48,8);
  AjouterDescriptionPattern1(kAdresseLigne5,51,58,8);
  AjouterDescriptionPattern1(kAdresseLigne6,61,68,8);
  AjouterDescriptionPattern1(kAdresseLigne7,71,78,8);
  AjouterDescriptionPattern1(kAdresseLigne8,81,88,8);
  AjouterDescriptionPattern1(kAdresseDiagonaleA4E8,41,85,5);
  AjouterDescriptionPattern1(kAdresseDiagonaleA3F8,31,86,6);
  AjouterDescriptionPattern1(kAdresseDiagonaleA2G8,21,87,7);
  AjouterDescriptionPattern1(kAdresseDiagonaleA1H8,11,88,8);
  AjouterDescriptionPattern1(kAdresseDiagonaleB1H7,12,78,7);
  AjouterDescriptionPattern1(kAdresseDiagonaleC1H6,13,68,6);
  AjouterDescriptionPattern1(kAdresseDiagonaleD1H5,14,58,5);
  AjouterDescriptionPattern1(kAdresseDiagonaleA5E1,51,15,5);
  AjouterDescriptionPattern1(kAdresseDiagonaleA6F1,61,16,6);
  AjouterDescriptionPattern1(kAdresseDiagonaleA7G1,71,17,7);
  AjouterDescriptionPattern1(kAdresseDiagonaleA8H1,81,18,8);
  AjouterDescriptionPattern1(kAdresseDiagonaleB8H2,82,28,7);
  AjouterDescriptionPattern1(kAdresseDiagonaleC8H3,83,38,6);
  AjouterDescriptionPattern1(kAdresseDiagonaleD8H4,84,48,5);

  { les blocs de 13 cases dans le coin, ˆ la Cassio }
  AjouterDescriptionPattern4(kAdresseBlocCoinA1,11,14,4,
                                                21,24,4,
                                                31,33,3,
                                                41,42,2);
  AjouterDescriptionPattern4(kAdresseBlocCoinH1,18,15,4,
                                                28,25,4,
                                                38,36,3,
                                                48,47,2);
  AjouterDescriptionPattern4(kAdresseBlocCoinA8,81,84,4,
                                                71,74,4,
                                                61,63,3,
                                                51,52,2);
  AjouterDescriptionPattern4(kAdresseBlocCoinH8,88,85,4,
                                                78,75,4,
                                                68,66,3,
                                                58,57,2);



  { les blocs de 11 cases dans le coin, pour Edmond }
  AjouterDescriptionPattern5(kAdresseCorner11A1,11,14,4,
                                                23,33,2,
                                                32,32,1,
                                                41,21,3,
                                                22,22,1);
  AjouterDescriptionPattern5(kAdresseCorner11H1,18,48,4,
                                                37,36,2,
                                                26,26,1,
                                                15,17,3,
                                                27,27,1);
  AjouterDescriptionPattern5(kAdresseCorner11A8,81,51,4,
                                                62,63,2,
                                                73,73,1,
                                                84,82,3,
                                                72,72,1);
  AjouterDescriptionPattern5(kAdresseCorner11H8,88,85,4,
                                                76,66,2,
                                                67,67,1,
                                                58,78,3,
                                                77,77,1);



  { les blocs de 2x5 cases dans le coin, pour Edmond }
  AjouterDescriptionPattern2(kAdresseCorner25A1E1,11,15,5,
                                                  25,21,5);
  AjouterDescriptionPattern2(kAdresseCorner25A1A5,11,51,5,
                                                  52,12,5);
  AjouterDescriptionPattern2(kAdresseCorner25H1D1,18,14,5,
                                                  24,28,5);
  AjouterDescriptionPattern2(kAdresseCorner25H1H5,18,58,5,
                                                  57,17,5);
  AjouterDescriptionPattern2(kAdresseCorner25A8E8,81,85,5,
                                                  75,71,5);
  AjouterDescriptionPattern2(kAdresseCorner25A8A4,81,41,5,
                                                  42,82,5);
  AjouterDescriptionPattern2(kAdresseCorner25H8D8,88,84,5,
                                                  74,78,5);
  AjouterDescriptionPattern2(kAdresseCorner25H8H4,88,48,5,
                                                  47,87,5);

  { les bords 6+4, pour Edmond }
  AjouterDescriptionPattern3(kAdresseBord6Plus4Nord,24,23,2,
                                                    12,17,6,
                                                    26,25,2);
  AjouterDescriptionPattern3(kAdresseBord6Plus4Ouest,52,62,2,
                                                     71,21,6,
                                                     32,42,2);
  AjouterDescriptionPattern3(kAdresseBord6Plus4Est, 47,37,2,
                                                    28,78,6,
                                                    67,57,2);
  AjouterDescriptionPattern3(kAdresseBord6Plus4Sud, 75,76,2,
                                                    87,82,6,
                                                    73,74,2);

  { les bords + 2X + 2C, pour Edmond }
  AjouterDescriptionPattern3(kAdresseBord2XCNord,22,21,2,
                                                 11,18,8,
                                                 28,27,2);
  AjouterDescriptionPattern3(kAdresseBord2XCOuest,72,82,2,
                                                  81,11,8,
                                                  12,22,2);
  AjouterDescriptionPattern3(kAdresseBord2XCEst, 27,17,2,
                                                 18,88,8,
                                                 87,77,2);
  AjouterDescriptionPattern3(kAdresseBord2XCSud, 77,78,2,
                                                 88,81,8,
                                                 71,72,2);



end;



procedure RajouteWorst2Best(i1,i2,i3,i4 : SInt16);
begin
  worst2bestOrder[compteurWorst2Best] := i1;
  worst2bestOrder[compteurWorst2Best+1] := i2;
  worst2bestOrder[compteurWorst2Best+2] := i3;
  worst2bestOrder[compteurWorst2Best+3] := i4;
  compteurWorst2Best := compteurWorst2Best+4;
end;


procedure InitialiseEndgameSquareOrder(whichOrder : SquareOrderType);
begin
  case whichOrder of
    ordreDesCasesDeJeanCristopheWeil :
      begin
        compteurWorst2Best := 1;
        RajouteWorst2Best(22,27,72,77);  {b2 = cases X}
        RajouteWorst2Best(12,17,21,28);  {b1 = cases C}
        RajouteWorst2Best(71,78,82,87);
        RajouteWorst2Best(23,26,32,37);  {c2 = cases Thill}
        RajouteWorst2Best(62,67,73,76);
        RajouteWorst2Best(24,25,42,47);  {d2 = milieu des prebords}
        RajouteWorst2Best(52,57,74,75);
        RajouteWorst2Best(34,35,43,46);  {d3 = cases centrales}
        RajouteWorst2Best(53,56,64,65);
        RajouteWorst2Best(14,15,41,48);  {d1 = milieu des bords}
        RajouteWorst2Best(51,58,84,85);
        RajouteWorst2Best(33,36,63,66);  {c3 = cases coins carre central}
        RajouteWorst2Best(13,16,31,38);  {c1 = cases A}
        RajouteWorst2Best(61,68,83,86);
        RajouteWorst2Best(11,18,81,88);  {a1 = coins}
        RajouteWorst2Best(44,45,54,55);  {d4 = cases inutilisees}
      end;
    ordreDesCasesDeCassio :
      begin
        compteurWorst2Best := 1;
        RajouteWorst2Best(22,27,72,77);  {b2 = cases X}
        RajouteWorst2Best(12,17,21,28);  {b1 = cases C}
        RajouteWorst2Best(71,78,82,87);
        RajouteWorst2Best(23,26,32,37);  {c2 = cases Thill}
        RajouteWorst2Best(62,67,73,76);
        RajouteWorst2Best(13,16,31,38);  {c1 = cases A}
        RajouteWorst2Best(61,68,83,86);
        RajouteWorst2Best(24,25,42,47);  {d2 = milieu des prebords }
        RajouteWorst2Best(52,57,74,75);
        RajouteWorst2Best(14,15,41,48);  {d1 = milieu des bords}
        RajouteWorst2Best(51,58,84,85);
        RajouteWorst2Best(33,36,63,66);  {c3 = cases coins carre central}
        RajouteWorst2Best(34,35,43,46);  {d3 = cases centrales}
        RajouteWorst2Best(53,56,64,65);
        RajouteWorst2Best(11,18,81,88);  {a1 = coins}
        RajouteWorst2Best(44,45,54,55);  {d4 = pions initiaux}
      end;
  end; {case}
end;

procedure Initialise_othellier;
var i,j,t,compteur : SInt16;
    valeur,deb,fin : SInt32;
    tableau : array[1..8] of String255;

begin
  MemoryFillChar(@estUnCoin,sizeof(estUnCoin),chr(0));
   estUnCoin[11] := true;
   estUnCoin[81] := true;
   estUnCoin[18] := true;
   estUnCoin[88] := true;

  MemoryFillChar(@estUneCaseC,sizeof(estUneCaseC),chr(0));
   estUneCaseC[12] := true;
   estUneCaseC[17] := true;
   estUneCaseC[21] := true;
   estUneCaseC[28] := true;
   estUneCaseC[71] := true;
   estUneCaseC[78] := true;
   estUneCaseC[82] := true;
   estUneCaseC[87] := true;

  MemoryFillChar(@estUneCaseA,sizeof(estUneCaseA),chr(0));
   estUneCaseA[13] := true;
   estUneCaseA[16] := true;
   estUneCaseA[31] := true;
   estUneCaseA[38] := true;
   estUneCaseA[61] := true;
   estUneCaseA[68] := true;
   estUneCaseA[83] := true;
   estUneCaseA[86] := true;

   MemoryFillChar(@estUneCaseDeBord,sizeof(estUneCaseDeBord),chr(0));
   for i := 1 to 8 do
   begin
     estUneCaseDeBord[10+i] := true;
     estUneCaseDeBord[80+i] := true;
     estUneCaseDeBord[10*i+1] := true;
     estUneCaseDeBord[10*i+8] := true;
   end;

   MemoryFillChar(@estCaseBordNord,sizeof(estCaseBordNord),chr(0));
   MemoryFillChar(@estCaseBordSud,sizeof(estCaseBordSud),chr(0));
   MemoryFillChar(@estCaseBordOuest,sizeof(estCaseBordOuest),chr(0));
   MemoryFillChar(@estCaseBordEst,sizeof(estCaseBordEst),chr(0));
   for i := 1 to 8 do
   begin
      estCaseBordNord[10+i] := true;
      estCaseBordSud[80+i] := true;
      estCaseBordOuest[10*i+1] := true;
      estCaseBordEst[10*i+8] := true;
   end;

   MemoryFillChar(@caseBordNord,sizeof(CaseBordNord),chr(0));
   MemoryFillChar(@caseBordSud,sizeof(CaseBordSud),chr(0));
   MemoryFillChar(@caseBordOuest,sizeof(CaseBordOuest),chr(0));
   MemoryFillChar(@caseBordEst,sizeof(CaseBordEst),chr(0));
   for i := 1 to 8 do
   begin
      CaseBordNord[i] := 10+i;
      CaseBordSud[i] := 80+i;
      CaseBordOuest[i] := 10*i+1;
      CaseBordEst[i] := 10*i+8;
   end;


  dir[1] := +10;   caseBord[1] := 21;
  dir[2] := -10;   caseBord[2] := 78;
  dir[3] := +1;    caseBord[3] := 12;
  dir[4] := -1;    caseBord[4] := 87;
  dir[5] := +9;
  dir[6] := -9;
  dir[7] := -11;
  dir[8] := +11;

  dirJouable[1] := -1;
  dirJouable[2] := 1;
  dirJouable[3] := -11;
  dirJouable[4] := -9;
  dirJouable[5] := 9;
  dirJouable[6] := 11;
  dirJouable[7] := -10;
  dirJouable[8] := 10;

  dirPrise[1] := -11;
  dirPrise[2] := -10;
  dirPrise[3] := -9;
  dirPrise[4] := 1;
  dirPrise[5] := 11;
  dirPrise[6] := 10;
  dirPrise[7] := 9;
  dirPrise[8] := -1;
  for i := 1 to 8 do dirPrise[8+i] := dirPrise[i];

  (* description de l'othellier dans l'ordre *)
  (* ancien ordre = coins,A,B,G,F,E,D,X,C,Cases centrales *)
  (* attention : les coins doivent toujours etre en tete
                 les cases centrales doivent toujours etre ˆ la fin
                 les cases X doivent toujours avoir les indices de 49 ˆ 52
                 les cases C doivent toujours avoir les indices de 53 ˆ 60
  *)
  {coins}
  othellier[1] := 11;
  othellier[2] := 81;
  othellier[3] := 18;
  othellier[4] := 88;
  compteur := 4;
  {G comme D3,E3,F4,F5,E6,D6,C5,C4}
  for i := 4 to 5 do
    begin
      othellier[compteur+1] := 3+10*i;
      othellier[compteur+2] := i+30;
      othellier[compteur+3] := 6+10*i;
      othellier[compteur+4] := 9-i+60;
      compteur := compteur+4;
    end;
  {F comme C3,F3,C6,F6}
  for i := 3 to 6 do
  if (i = 3) or (i = 6) then
    begin
      othellier[compteur+1] := 3+10*i;
      othellier[compteur+2] := 6+10*i;
      compteur := compteur+2;
    end;
  {E comme B4,B5,etc }
  for i := 4 to 5 do
    begin
      othellier[compteur+1] := 2+10*i;
      othellier[compteur+2] := i+10*2;
      othellier[compteur+3] := 7+10*I;
      othellier[compteur+4] := 9-i+10*7;
      compteur := compteur+4;
    end;
  {D comme B3,B6,etc }
  for i := 3 to 6 do
  if (i = 3) or (i = 6) then
    begin
      othellier[compteur+1] := 2+10*I;
      othellier[compteur+2] := i+10*2;
      othellier[compteur+3] := 7+10*i;
      othellier[compteur+4] := 9-i+10*7;
      compteur := compteur+4;
    end;
  {A comme A3,A6,etc }
  for i := 3 to 6 do
  if (i = 3) or (i = 6) then
    begin
      othellier[compteur+1] := 1+10*i;
      othellier[compteur+2] := i+10;
      othellier[compteur+3] := 8+10*i;
      othellier[compteur+4] := 9-i+80;
      compteur := compteur+4;
    end;
  {B comme A4,A5,etc }
  for i := 4 to 5 do
    begin
      othellier[compteur+1] := 1+10*i;
      othellier[compteur+2] := i+10;
      othellier[compteur+3] := 8+10*i;
      othellier[compteur+4] := 9-i+80;
      compteur := compteur+4;
    end;
  {X comme B2,G2,B7,G7}
  i := 2; j := 2;
  othellier[compteur+1] := i+10*j;
  othellier[compteur+2] := 9-i+10*(9-j);
  othellier[compteur+3] := i+10*(9-j);
  othellier[compteur+4] := 9-i+10*j;
  compteur := compteur+4;
  {C comme A2,A7,etc}
  i := 2; j := 1;
  othellier[compteur+1] := i+10*j;
  othellier[compteur+2] := 9-i+10*(9-j);
  othellier[compteur+3] := i+10*(9-j);
  othellier[compteur+4] := 9-i+10*j;
  compteur := compteur+4;
  i := 1; j := 2;
  othellier[compteur+1] := i+10*j;
  othellier[compteur+2] := 9-i+10*(9-j);
  othellier[compteur+3] := i+10*(9-j);
  othellier[compteur+4] := 9-i+10*j;
  compteur := compteur+4;
  {CASES CENTRALES comme D4,E4,D5,E5}
  for i := 4 to 5 do
   for j := 4 to 5 do
    begin
      othellier[compteur+1] := i+10*j;
      compteur := compteur+1;
    end;

  {directions jouables case par case}
  for t := 0 to 99 do dirJouableDeb[t] := 1;
  for t := 0 to 99 do dirJouablefin[t] := 0;
  for i := 1 to 64 do
    begin
      t := othellier[i];
      dirJouableDeb[t] := 1;
      dirJouableFin[t] := 8;
      if EstUneCaseBordNord(t) or EstUneCaseBordSud(t) then
        begin
          dirJouableDeb[t] := 1;
          dirJouableFin[t] := 2;
        end;
      if EstUneCaseBordOuest(t) or EstUneCaseBordEst(t) then
        begin
          dirJouableDeb[t] := 7;
          dirJouableFin[t] := 8;
        end;
      if estUnCoin[t] then
        begin
          dirJouableDeb[t] := 1;
          dirJouableFin[t] := 0;
        end;
    end;

   MemoryFillChar(@dirPriseDeb,sizeof(dirPriseDeb),chr(1));
   MemoryFillChar(@dirPriseFin,sizeof(dirPriseFin),chr(0));
   tableau[1] :=  '4006 4008 4008 6008';
   tableau[2] :=  '2006 1008 1008 6010';
   tableau[3] :=  '2006 1008 1008 6010';
   tableau[4] :=  '2004 8012 8012 8010';
   for i := 1 to 4 do
   for j := 1 to 4 do
   begin
      StrToInt32(TPCopy(tableau[j],5*i-4,4),valeur);
      deb := valeur div 1000;
      fin := valeur mod 100;
      t := i*2+10*j*2;
      dirPriseDeb[t] := deb;
      dirPriseFin[t] := fin;
      dirPriseDeb[t-1] := deb;
      dirPriseFin[t-1] := fin;
      dirPriseDeb[t-10] := deb;
      dirPriseFin[t-10] := fin;
      dirPriseDeb[t-11] := deb;
      dirPriseFin[t-11] := fin;
   end;


   dirVoisine[1] := -11;
   dirVoisine[2] := -10;
   dirVoisine[3] := -9;
   dirVoisine[4] := 1;
   dirVoisine[5] := 11;
   dirVoisine[6] := 10;
   dirVoisine[7] := 9;
   dirVoisine[8] := -1;
   for i := 1 to 8 do dirVoisine[8+i] := dirVoisine[i];

   MemoryFillChar(@dirVoisineDeb,sizeof(dirVoisineDeb),chr(1));
   MemoryFillChar(@dirVoisineFin,sizeof(dirVoisineFin),chr(0));
   tableau[1] :=  '4006 4008 4008 4008 4008 4008 4008 6008';
   tableau[2] :=  '2006 1008 1008 1008 1008 1008 1008 6010';
   tableau[3] :=  '2006 1008 1008 1008 1008 1008 1008 6010';
   tableau[4] :=  '2006 1008 1008 1008 1008 1008 1008 6010';
   tableau[5] :=  '2006 1008 1008 1008 1008 1008 1008 6010';
   tableau[6] :=  '2006 1008 1008 1008 1008 1008 1008 6010';
   tableau[7] :=  '2006 1008 1008 1008 1008 1008 1008 6010';
   tableau[8] :=  '2004 8012 8012 8012 8012 8012 8012 8010';
   for i := 1 to 8 do
   for j := 1 to 8 do
   begin
      StrToInt32(TPCopy(tableau[j],5*i-4,4),valeur);
      deb := valeur div 1000;
      fin := valeur mod 100;
      t := j*10+i;
      dirVoisineDeb[t] := deb;
      dirVoisineFin[t] := fin;
   end;


  MemoryFillChar(@interdit,sizeof(interdit),chr(0));
   for i := 0 to 9 do
   begin
      interdit[10*i] := true;
      interdit[i] := true;
      interdit[9+10*i] := true;
      interdit[i+10*9] := true;
   end;

   for t := 0 to 99 do
   begin
     i := t mod 10;
     j := t div 10;
     if (i <= 4) and (j <= 4) then
       begin
         numeroQuadrant[t] := 0;
         constanteDeParite[t] := 1;
       end;
     if (i > 4) and (j <= 4) then
       begin
         numeroQuadrant[t] := 1;
         constanteDeParite[t] := 2;
       end;
     if (i <= 4) and (j > 4) then
       begin
         numeroQuadrant[t] := 2;
         constanteDeParite[t] := 4;
       end;
     if (i > 4) and (j > 4) then
       begin
         numeroQuadrant[t] := 3;
         constanteDeParite[t] := 8;
       end;
   end;

   for t := -5 to 65 do
     begin
       gameStage[t] := t div 10;
       if gameStage[t] < 0 then gameStage[t] := 0;
       if gameStage[t] > kNbMaxGameStage then gameStage[t] := kNbMaxGameStage;
     end;

   puiss3[0] := 0;
   puiss3[1] := 1;
   for i := 2 to kTailleMaximumPattern+1 do
     puiss3[i] := 3*puiss3[i-1];
   for i := 0 to kTailleMaximumPattern+1 do
     doublePuiss3[i] := 2*puiss3[i];


   for t := 0 to 99 do
     begin
       platMod10[t] := t mod 10;
       platDiv10[t] := t div 10;
       puiss3Mod10[t] := puiss3[platMod10[t]];
       puiss3Div10[t] := puiss3[platDiv10[t]];
       doublePuiss3Mod10[t] := doublePuiss3[platMod10[t]];
       doublePuiss3Div10[t] := doublePuiss3[platDiv10[t]];
     end;



  {
  j := 0;
  for i := -1 to 60 do
    begin
      WriteNumAt('info[',i,10+(i div 30)*240,(i mod 30)*10+20);
      WriteNumAt('] = ',IndexInfoDejaCalculeesCoupNro^^[i],70+(i div 30)*240,(i mod 30)*10+20);
    end;
  AttendFrappeClavier;
  }

  InitialiseEndgameSquareOrder(ordreDesCasesDeCassio);

  Initialise_TableCalculAdressesPatterns;

  (*
  for compteur := 1 to kNbMaxPatternsParCase do
    begin
		  for i := 1 to 8 do
		    begin
		      for j := 1 to 8 do
			      begin
			        t := 10*j+i;
			        WriteNumDansRapport('(',nroPattern[t,compteur]);
			        WriteNumDansRapport(',',deltaAdresse[t,compteur]);
			        WriteNumDansRapport(',',doubleDeltaAdresse[t,compteur]);
			        WriteDansRapport(') ');
			      end;
			    WritelnDansRapport('');
			  end;
			WritelnDansRapport('');
		end;
 *)

 (*
 for i := 1 to 8 do
   begin
     for j := 1 to 8 do
	     begin
	       t := 10*j+i;
	       WriteNumDansRapport('',nbPatternsImpliques[t]);
	     end;
	   WritelnDansRapport('');
	 end;
 WritelnDansRapport('');
 *)


    masque_voisinage[0].low   := $00000000;   { case impossible }
    masque_voisinage[0].high  := $00000000;
    masque_voisinage[11].low  := $00000302;   { A1 }
    masque_voisinage[11].high := $00000000;
    masque_voisinage[12].low  := $00000604;   { B1 }
    masque_voisinage[12].high := $00000000;
    masque_voisinage[13].low  := $00000E0A;   { C1 }
    masque_voisinage[13].high := $00000000;
    masque_voisinage[14].low  := $00001C14;   { D1 }
    masque_voisinage[14].high := $00000000;
    masque_voisinage[15].low  := $00003828;   { E1 }
    masque_voisinage[15].high := $00000000;
    masque_voisinage[16].low  := $00007050;   { F1 }
    masque_voisinage[16].high := $00000000;
    masque_voisinage[17].low  := $00006020;   { G1 }
    masque_voisinage[17].high := $00000000;
    masque_voisinage[18].low  := $0000C040;   { H1 }
    masque_voisinage[18].high := $00000000;
    masque_voisinage[21].low  := $00030200;   { A2 }
    masque_voisinage[21].high := $00000000;
    masque_voisinage[22].low  := $00060400;   { B2 }
    masque_voisinage[22].high := $00000000;
    masque_voisinage[23].low  := $000E0A00;   { C2 }
    masque_voisinage[23].high := $00000000;
    masque_voisinage[24].low  := $001C1400;   { D2 }
    masque_voisinage[24].high := $00000000;
    masque_voisinage[25].low  := $00382800;   { E2 }
    masque_voisinage[25].high := $00000000;
    masque_voisinage[26].low  := $00705000;   { F2 }
    masque_voisinage[26].high := $00000000;
    masque_voisinage[27].low  := $00602000;   { G2 }
    masque_voisinage[27].high := $00000000;
    masque_voisinage[28].low  := $00C04000;   { H2 }
    masque_voisinage[28].high := $00000000;
    masque_voisinage[31].low  := $03020300;   { A3 }
    masque_voisinage[31].high := $00000000;
    masque_voisinage[32].low  := $06040600;   { B3 }
    masque_voisinage[32].high := $00000000;
    masque_voisinage[33].low  := $0E0A0E00;   { C3 }
    masque_voisinage[33].high := $00000000;
    masque_voisinage[34].low  := $1C141C00;   { D3 }
    masque_voisinage[34].high := $00000000;
    masque_voisinage[35].low  := $38283800;   { E3 }
    masque_voisinage[35].high := $00000000;
    masque_voisinage[36].low  := $70507000;   { F3 }
    masque_voisinage[36].high := $00000000;
    masque_voisinage[37].low  := $60206000;   { G3 }
    masque_voisinage[37].high := $00000000;
    masque_voisinage[38].low  := $C040C000;   { H3 }
    masque_voisinage[38].high := $00000000;
    masque_voisinage[41].low  := $02030000;   { A4 }
    masque_voisinage[41].high := $00000003;
    masque_voisinage[42].low  := $04060000;   { B4 }
    masque_voisinage[42].high := $00000006;
    masque_voisinage[43].low  := $0A0E0000;   { C4 }
    masque_voisinage[43].high := $0000000E;
    masque_voisinage[44].low  := $141C0000;   { D4 }
    masque_voisinage[44].high := $0000001C;
    masque_voisinage[45].low  := $28380000;   { E4 }
    masque_voisinage[45].high := $00000038;
    masque_voisinage[46].low  := $50700000;   { F4 }
    masque_voisinage[46].high := $00000070;
    masque_voisinage[47].low  := $20600000;   { G4 }
    masque_voisinage[47].high := $00000060;
    masque_voisinage[48].low  := $40C00000;   { H4 }
    masque_voisinage[48].high := $000000C0;
    masque_voisinage[51].low  := $03000000;   { A5 }
    masque_voisinage[51].high := $00000302;
    masque_voisinage[52].low  := $06000000;   { B5 }
    masque_voisinage[52].high := $00000604;
    masque_voisinage[53].low  := $0E000000;   { C5 }
    masque_voisinage[53].high := $00000E0A;
    masque_voisinage[54].low  := $1C000000;   { D5 }
    masque_voisinage[54].high := $00001C14;
    masque_voisinage[55].low  := $38000000;   { E5 }
    masque_voisinage[55].high := $00003828;
    masque_voisinage[56].low  := $70000000;   { F5 }
    masque_voisinage[56].high := $00007050;
    masque_voisinage[57].low  := $60000000;   { G5 }
    masque_voisinage[57].high := $00006020;
    masque_voisinage[58].low  := $C0000000;   { H5 }
    masque_voisinage[58].high := $0000C040;
    masque_voisinage[61].low  := $00000000;   { A6 }
    masque_voisinage[61].high := $00030203;
    masque_voisinage[62].low  := $00000000;   { B6 }
    masque_voisinage[62].high := $00060406;
    masque_voisinage[63].low  := $00000000;   { C6 }
    masque_voisinage[63].high := $000E0A0E;
    masque_voisinage[64].low  := $00000000;   { D6 }
    masque_voisinage[64].high := $001C141C;
    masque_voisinage[65].low  := $00000000;   { E6 }
    masque_voisinage[65].high := $00382838;
    masque_voisinage[66].low  := $00000000;   { F6 }
    masque_voisinage[66].high := $00705070;
    masque_voisinage[67].low  := $00000000;   { G6 }
    masque_voisinage[67].high := $00602060;
    masque_voisinage[68].low  := $00000000;   { H6 }
    masque_voisinage[68].high := $00C040C0;
    masque_voisinage[71].low  := $00000000;   { A7 }
    masque_voisinage[71].high := $00020300;
    masque_voisinage[72].low  := $00000000;   { B7 }
    masque_voisinage[72].high := $00040600;
    masque_voisinage[73].low  := $00000000;   { C7 }
    masque_voisinage[73].high := $000A0E00;
    masque_voisinage[74].low  := $00000000;   { D7 }
    masque_voisinage[74].high := $00141C00;
    masque_voisinage[75].low  := $00000000;   { E7 }
    masque_voisinage[75].high := $00283800;
    masque_voisinage[76].low  := $00000000;   { F7 }
    masque_voisinage[76].high := $00507000;
    masque_voisinage[77].low  := $00000000;   { G7 }
    masque_voisinage[77].high := $00206000;
    masque_voisinage[78].low  := $00000000;   { H7 }
    masque_voisinage[78].high := $0040C000;
    masque_voisinage[81].low  := $00000000;   { A8 }
    masque_voisinage[81].high := $02030000;
    masque_voisinage[82].low  := $00000000;   { B8 }
    masque_voisinage[82].high := $04060000;
    masque_voisinage[83].low  := $00000000;   { C8 }
    masque_voisinage[83].high := $0A0E0000;
    masque_voisinage[84].low  := $00000000;   { D8 }
    masque_voisinage[84].high := $141C0000;
    masque_voisinage[85].low  := $00000000;   { E8 }
    masque_voisinage[85].high := $28380000;
    masque_voisinage[86].low  := $00000000;   { F8 }
    masque_voisinage[86].high := $50700000;
    masque_voisinage[87].low  := $00000000;   { G8 }
    masque_voisinage[87].high := $20600000;
    masque_voisinage[88].low  := $00000000;   { H8 }
    masque_voisinage[88].high := $40C00000;
end;



procedure Initialise_IndexInfoDejaCalculees;
var i : SInt32;
begin
  MemoryFillChar(IndexInfoDejaCalculeesCoupNro^,sizeof(t_IndexInfoDejaCalculeesCoupNro),chr(0));
  IndexInfoDejaCalculeesCoupNro^^[-1] := 0;
  IndexInfoDejaCalculeesCoupNro^^[0] := 0;
  IndexInfoDejaCalculeesCoupNro^^[1] := 0;
  for i := 2 to 20 do IndexInfoDejaCalculeesCoupNro^^[i] := IndexInfoDejaCalculeesCoupNro^^[i-1]+800;
  for i := 21 to 39 do IndexInfoDejaCalculeesCoupNro^^[i] := IndexInfoDejaCalculeesCoupNro^^[i-1]+800 - (i-20)*40;
  for i := 40 to 60 do IndexInfoDejaCalculeesCoupNro^^[i] := IndexInfoDejaCalculeesCoupNro^^[i-1]+8;
end;



procedure Initialise_valeurs_tactiques;
var i,j : SInt16;
    valeur : SInt32;
    tableau : array[1..4] of String255;
begin
   tableau[1] :=  '0000 0000 0010 0000';
   tableau[2] :=  '0000 -709 0000 0020';  {mettre '-034' pour une note  < 0}
   tableau[3] :=  '0010 0000 0051 0050';
   tableau[4] :=  '0000 0020 0050 0000';
   for i := 1 to 4 do
   for j := 1 to 4 do
   begin
      StrToInt32(TPCopy(tableau[i],5*j-4,4),valeur);
      if estUneCaseDeBord[i+10*j] then
         valeur := valeur-100;
      valeurTactAbsolue[i+10*j] := valeur;
      valeurTactAbsolue[9-i+10*j] := valeur;
      valeurTactAbsolue[9-i+10*(9-j)] := valeur;
      valeurTactAbsolue[i+10*(9-j)] := valeur;
   end;
   valeurTactNoir := valeurTactAbsolue;
   valeurTactBlanc := valeurTactAbsolue;

end;

procedure Calcul_position_centre(plat : plateauOthello);
var Ysomme,Xsomme : double;
    SigmaPoids,poids : double;
    x1,y1,x2,y2 : SInt16;
    i,x : SInt16;
    caseOccupee : boolean;
begin
  { avoir le centre de la position }
  Ysomme := 0;
  Xsomme := 0;
  SigmaPoids := 0;
  for i := 1 to 64 do
  begin
    x := othellier[i];
    caseOccupee := false;
    if plat[x] <> pionVide then
    begin
      caseOccupee := true;
      poids := 1.001;
      if estUneCaseDeBord[x] then poids := 1.501;
      ySomme := Ysomme+poids*(x div 10);
      xsomme := Xsomme+poids*(x mod 10);
      SigmaPoids := SigmaPoids+poids;
    end;
  end;
    if SigmaPoids <> 0 then
    begin
      Xsomme := Xsomme/SigmaPoids;
      Ysomme := Ysomme/SigmaPoids;
    end
    else
      begin
        Xsomme := 4.5;
        Ysomme := 4.5;
      end;
    x1 := Trunc(xsomme);
    x2 := x1+1;
    y1 := Trunc(ysomme);
    y2 := y1+1;
    caseCentre[1] := 10*y1+x1;
    caseCentre[2] := 10*y1+x2;
    caseCentre[3] := 10*y2+x1;
    caseCentre[4] := 10*y2+x2;
    caseCentre1 := caseCentre[1];
    caseCentre2 := caseCentre[2];
    caseCentre3 := caseCentre[3];
    caseCentre4 := caseCentre[4];
    casepetitCentre[1] := 10*(y1-1)+x1;
    casepetitCentre[2] := 10*(y1-1)+x2;
    casepetitCentre[3] := 10*(y2+1)+x1;
    casepetitCentre[4] := 10*(y2+1)+x2;
    casepetitCentre[5] := 10*y1+x1-1;
    casepetitCentre[6] := 10*y1+x2+1;
    casepetitCentre[7] := 10*y2+x1-1;
    casepetitCentre[8] := 10*y2+x2+1;
    casepetitCentre1 := casepetitCentre[1];
    casepetitCentre2 := casepetitCentre[2];
    casepetitCentre3 := casepetitCentre[3];
    casepetitCentre4 := casepetitCentre[4];
    casepetitCentre5 := casepetitCentre[5];
    casepetitCentre6 := casepetitCentre[6];
    casepetitCentre7 := casepetitCentre[7];
    casepetitCentre8 := casepetitCentre[8];

end;

procedure Calcule_Valeurs_Tactiques(plat : plateauOthello; avecCalculCentre : boolean);

procedure Nouvelles_valeurs_tactiques(couleur : SInt16; var valeurTact : platValeur);
const debut = 1;
      fin = 2;
var i,t,x,dx : SInt16;
    xX : SInt32;
    s : array[1..4] of String255;
    c : String255;
    caseX : array[1..4,debut..fin] of SInt16;
    xdeb,xfin : SInt16;
    adversaire : SInt16;
    caseThil : SInt16;
begin
   adversaire := -couleur;
   for i := 1 to 64 do
     begin
       x := othellier[i];
       valeurTact[x] := valeurTactAbsolue[x];
     end;
   for i := 53 to 60 do  { cases C  }
   begin
     x := othellier[i];
     if not(CoinPlusProcheVide(x,plat))
       then valeurTact[x] := valeurTact[x]+400;
   end;
   if (GetCadence <= minutes3) or jeuInstantane then
     begin
       valeurtact[22] := valeurtact[22]-300;
       valeurtact[27] := valeurtact[27]-300;
       valeurtact[72] := valeurtact[72]-300;
       valeurtact[77] := valeurtact[77]-300;
     end;


   for t := 1 to 4 do
     begin
       s[t] := '';
       dx := dir[t];
       x := casebord[t]-dx;
       for i := 1 to 8 do
        BEGIN
          if plat[x] = pionVide then s[t] := s[t]+CharToString('0')
          else if plat[x] = couleur then s[t] := s[t]+CharToString('1')
          else s[t] := s[t]+CharToString('2');
          x := x+dx;
         END;
       xX := PlusProcheCaseX(casebord[t]-dx);
       caseX[t,debut] := xX;
       xX := PlusProcheCaseX(casebord[t]+6*dx);
       caseX[t,fin] := xX;
     end;

   for t := 1 to 4 do
   begin
     c := s[t];
     xdeb := caseX[t,debut];
     xfin := caseX[t,fin];

     if (c = '00222220') or (c = '00220020') or (c = '00200220') then valeurtact[xdeb] := 200
     else if (c = '02222200') or (c = '02002200') or (c = '02200200') then valeurtact[xfin] := 200

     else if (c = '00102220') or (c = '00120220') or (c = '00122020')or
             (c = '00110220') or (c = '00111020') or (c = '00112020')or
             (c = '00010220') or (c = '00011020') or (c = '00012020') or (c = '00002220')
     then valeurtact[xdeb] := 200
     else if (c = '02220100') or (c = '02202100') or (c = '02022100')or
             (c = '02201100') or (c = '02011100') or (c = '02021100')or
             (c = '02201000') or (c = '02011000') or (c = '02021000') or (c = '02220000')
     then valeurtact[xfin] := 200

     else if (c = '01022220') or (c = '01102220') or (c = '01110220') or (c = '01111020')then
       begin
         valeurtact[xdeb] := 300;
         valeurtact[xfin] := valeurtact[xfin]-300;
       end
     else if (c = '02222010') or (c = '02220110') or (c = '02201110') or (c = '02011110') then
       begin
         valeurtact[xfin] := 300;
         valeurtact[xdeb] := valeurtact[xdeb]-300;
       end

     else if (c = '01111110') or (c = '02222220')then
       begin
         valeurtact[xdeb] := valeurtact[xdeb]-200;
         valeurtact[xfin] := valeurtact[xfin]-200;
       end;

   end;




   {
   if nbreCoup >= 5 then
   begin
      caseThil := -80;
      valeurtact[32] := valeurtact[32]+caseThil;
      valeurtact[62] := valeurtact[62]+caseThil;
      valeurtact[73] := valeurtact[73]+caseThil;
      valeurtact[76] := valeurtact[76]+caseThil;
      valeurtact[23] := valeurtact[23]+caseThil;
      valeurtact[26] := valeurtact[26]+caseThil;
      valeurtact[37] := valeurtact[37]+caseThil;
      valeurtact[67] := valeurtact[67]+caseThil;
   end;
   }
   {
   caseThil := -30;
   if plat[42] = pionVide then valeurtact[32] := valeurtact[32]+caseThil;
   if plat[52] = pionVide then valeurtact[62] := valeurtact[62]+caseThil;
   if plat[74] = pionVide then valeurtact[73] := valeurtact[73]+caseThil;
   if plat[75] = pionVide then valeurtact[76] := valeurtact[76]+caseThil;
   if plat[24] = pionVide then valeurtact[23] := valeurtact[23]+caseThil;
   if plat[25] = pionVide then valeurtact[26] := valeurtact[26]+caseThil;
   if plat[47] = pionVide then valeurtact[37] := valeurtact[37]+caseThil;
   if plat[57] = pionVide then valeurtact[67] := valeurtact[67]+caseThil;
   }
   {
   caseThil := -300;
   if plat[33] = pionVide then valeurtact[32] := valeurtact[32]+caseThil;
   if plat[63] = pionVide then valeurtact[62] := valeurtact[62]+caseThil;
   if plat[63] = pionVide then valeurtact[73] := valeurtact[73]+caseThil;
   if plat[66] = pionVide then valeurtact[76] := valeurtact[76]+caseThil;
   if plat[33] = pionVide then valeurtact[23] := valeurtact[23]+caseThil;
   if plat[36] = pionVide then valeurtact[26] := valeurtact[26]+caseThil;
   if plat[36] = pionVide then valeurtact[37] := valeurtact[37]+caseThil;
   if plat[66] = pionVide then valeurtact[67] := valeurtact[67]+caseThil;
   }

   caseThil := -40;
   if plat[31] = pionVide then valeurtact[32] := valeurtact[32]+caseThil;
   if plat[61] = pionVide then valeurtact[62] := valeurtact[62]+caseThil;
   if plat[83] = pionVide then valeurtact[73] := valeurtact[73]+caseThil;
   if plat[86] = pionVide then valeurtact[76] := valeurtact[76]+caseThil;
   if plat[13] = pionVide then valeurtact[23] := valeurtact[23]+caseThil;
   if plat[16] = pionVide then valeurtact[26] := valeurtact[26]+caseThil;
   if plat[38] = pionVide then valeurtact[37] := valeurtact[37]+caseThil;
   if plat[68] = pionVide then valeurtact[67] := valeurtact[67]+caseThil;




   if phaseDeLaPartie = phaseDebut then
     begin
      valeurtact[22] := valeurtact[22]-800;
      valeurtact[72] := valeurtact[72]-800;
      valeurtact[77] := valeurtact[77]-800;
      valeurtact[27] := valeurtact[27]-800;
     end;






   if plat[11] <> pionVide then valeurtact[22] := 200;
   if plat[81] <> pionVide then valeurtact[72] := 200;
   if plat[18] <> pionVide then valeurtact[27] := 200;
   if plat[88] <> pionVide then valeurtact[77] := 200;



 for i := 11 to 88 do
   valeurTact[i] := valeurtact[i] div 2;





   {

   for j := 1 to 8 do
     for i := 1 to 8 do
     begin
       a := 100+i*25;
       b := 50+j*15;
       if plat[i+10*j] = pionNoir then WriteNumAt(CaracterePourNoir,0,a,b);
       if plat[i+10*j] = pionBlanc then WriteNumAt(CaracterePourBlanc,0,a,b);
       if plat[i+10*j] = pionVide then WriteNumAt('',valeurtact[i+10*j],a,b);
     end;
   AttendFrappeClavier;
   }

end;

begin  {Calcule_Valeurs_Tactiques}
  if avecCalculCentre then Calcul_position_centre(plat);
  Nouvelles_valeurs_tactiques(pionNoir,valeurTactNoir);
  Nouvelles_valeurs_tactiques(pionBlanc,valeurTactBlanc);
end;

procedure Initialise_table_heuristique(jeu : plateauOthello; debug : boolean);
var a,b : array[1..60] of SInt16;
    y : SInt16;
    ticks : SInt32;

procedure init_heuristique(var heuris : tabl_heuristique);
var i,j,dist,x,compt,m,t,oldDisc : SInt16;
    tableDeTri : array[1..14,1..14] of SInt8;
    nbOccupes : array[1..14] of SInt16;
begin
  MemoryFillChar(@heuris,sizeof(heuris),chr(0));

  if debug then
    begin
      WritelnDansRapport('Entree dans init_heuristique');
      WritelnPositionEtTraitDansRapport(jeu,pionNoir);
      AttendFrappeClavier;
    end;

  for t := 1 to 64 do
  begin
    x := othellier[t];

    oldDisc := jeu[x];

    jeu[x] := PionInterdit;  { pour avoir j <> x dans la suite }

    MemoryFillChar(@tableDeTri,sizeof(tableDeTri),chr(0));
    MemoryFillChar(@nbOccupes,sizeof(nbOccupes),chr(0));

    for i := 5 to 48 do
      begin
        j := othellier[i];
        if jeu[j] = pionVide then
            begin
              dist := Abs(a[i]-a[t])+Abs(b[i]-b[t]);
              nbOccupes[dist] := nbOccupes[dist]+1;
              tableDeTri[dist,nbOccupes[dist]] := j;
            end;
      end;

     compt := 0;  {tri suivant la dist des cases ni Coins ni C ni X}
     for dist := 1 to 14 do
     begin
       for m := 1 to nbOccupes[dist] do
         heuris[x,compt+m] := tableDeTri[dist,m];
       compt := compt+nbOccupes[dist];
     end;

     for i := 49 to 64 do  {cases X et C et carre central D4-E4-D5-E5}
      begin
       j := othellier[i];
       if jeu[j] = pionVide then
         begin
           compt := compt+1;
           heuris[x,compt] := j;
         end;
       end;

     for i := 1 to 4 do
      begin
       j := othellier[i];
       if jeu[j] = pionVide then
         begin
           compt := compt+1;
           heuris[x,compt] := j;
         end;
       end;

     heuris[x,0] := compt;
     jeu[x] := oldDisc;

  end;
end;



begin
  ticks := TickCount;

  for y := 1 to 64 do
  begin
    a[y] := othellier[y] mod 10;
    b[y] := othellier[y] div 10;
  end;
  init_heuristique(tableHeurisNoir);
  init_heuristique(tableHeurisBlanc);
  calculPrepHeurisFait := true;

  ticks := TickCount-ticks;
  {WritelnNumDansRapport('temps de Initialise_table_heuristique = ',ticks);}
end;


function Elagage_a_priori(couleur,nbBla,nbNoi : SInt16; jeu : plateauOthello; var class : ListOfMoveRecords; longClass : SInt16) : SInt16;
var PourcentageElagage : double ;
    i,t : SInt16;
    index : SInt16;
    xcourant,defense : SInt16;
    PlatEl : plateauOthello;
    nbNoiEl,nbBlaEl : SInt32;
    bidbool : boolean;
    numeroCoup : SInt16;
begin
  numeroCoup := nbBla+nbNoi-4;
  if CassioEstEnModeAnalyse or (numeroCoup >= 37)
    then
      PourcentageElagage := 1.0
    else
      begin
       if phaseDeLaPartie <= phaseDebut
          then
            begin
              if numeroCoup <= 10
                then PourcentageElagage := 1.0
                else PourcentageElagage := 0.89
            end
          else PourcentageElagage := 0.81;
      end;
  index := RoundToL(PourcentageElagage*longClass);
  for i := index+1 to longClass do
    begin
      xcourant := class[i].x;
      PlatEl := jeu;
      nbNoiEl := nbNoi;
      nbBlaEl := nbBla;
      bidbool := ModifPlatFin(xCourant,couleur,PlatEl,nbBlaEl,nbNoiEl);
      if ((platEl[11] = pionVide) and PeutJouerIci(couleur,11,PlatEl)) or
         ((platEl[18] = pionVide) and PeutJouerIci(couleur,18,PlatEl)) or
         ((platEl[81] = pionVide) and PeutJouerIci(couleur,81,PlatEl)) or
         ((platEl[88] = pionVide) and PeutJouerIci(couleur,88,PlatEl)) then
         begin
           defense := class[i].theDefense;
           for t := i downto index+2 do class[t] := class[t-1];
           class[index+1].x := xCourant;
           class[index+1].theDefense := defense;
           index := index+1;
         end;
    end;
  if index < 5 then index := 5;
  if index > longClass then index := longClass;
  Elagage_a_priori := index;
end;




procedure CoefficientsStandard;
begin
    CoeffInfluence := 1.0;
    Coefffrontiere := 1.0;
    CoeffEquivalence := 1.0;
    Coeffcentre := 1.0;
    Coeffgrandcentre := 1.0;
    Coeffbetonnage := 1.0;
    Coeffminimisation := 1.0;
    CoeffpriseCoin := 1.0;
    CoeffdefenseCoin := 1.0;
    CoeffValeurCoin := 1.0;
    CoeffValeurCaseX := 1.0;
    CoeffPenalite := 1.0;
    CoeffMobiliteUnidirectionnelle := 1.0;

    CoeffFrontierePourNouvelleEval := 1.0;
    CoeffMinimisationPourNouvelleEval := 1.0;
    CoeffMobiliteUnidirectionnellePourNouvelleEval := 1.0;
    CoeffPenalitePourNouvelleEval := 1.0;

end;


procedure MultiplicationParCoeff;
begin
    valFrontiere := RoundToL(Coefffrontiere*valFrontiere);
    valEquivalentFrontiere := RoundToL(CoeffEquivalence*valEquivalentFrontiere);
    valPionCentre := RoundToL(valPionCentre*Coeffcentre);
    valPionPetitCentre := RoundToL(valPionPetitCentre*Coeffgrandcentre);
    valBetonnage := RoundToL(valBetonnage*Coeffbetonnage);
    valMinimisationAvantCoins := RoundToL(valMinimisationAvantCoins*Coeffminimisation);
    valMinimisationApresCoins := RoundToL(valMinimisationApresCoins*Coeffminimisation);
    valPriseCoin := RoundToL(valPriseCoin*CoeffpriseCoin);
    valDefenseCoin := RoundToL(valDefenseCoin*CoeffdefenseCoin);
    valCoin := RoundToL(valCoin*CoeffValeurCoin);
    valCaseX := RoundToL(valCaseX*CoeffValeurCaseX);
    valMobiliteUnidirectionnelle := RoundToL(valMobiliteUnidirectionnelle*CoeffMobiliteUnidirectionnelle);
    penalitePourTraitAff := RoundToL(penalitePourTraitAff*CoeffPenalite);


    (* Les coefficients suivants ont ete choisis parce qu'il Žtaient
       les coefficients du champion contre Cassio 5.6.6 *)
    if (phaseDeLaPartie < phaseFinale)
      then
        begin
          CoeffFrontierePourNouvelleEval                 := 1.0  * 1.0  * 1.0  * 1.0  ;
          CoeffMinimisationPourNouvelleEval              := 0.8  * 0.66 * 1.0  * 1.30 ;
          CoeffMobiliteUnidirectionnellePourNouvelleEval := 1.0  * 0.66 * 1.15 * 0.66 ;
          CoeffPenalitePourNouvelleEval                  := 1.30 * 0.80 * 0.80 * 1.30 ;
        end
      else
        begin
          CoeffFrontierePourNouvelleEval := 1.0;
          CoeffMinimisationPourNouvelleEval := 1.0;
          CoeffMobiliteUnidirectionnellePourNouvelleEval := 1.0;
          CoeffPenalitePourNouvelleEval := 1.0;
        end;

    if withUserCoeffDansNouvelleEval then
      begin
        CoeffFrontierePourNouvelleEval                 := CoeffFrontierePourNouvelleEval * Coefffrontiere;
        CoeffMinimisationPourNouvelleEval              := CoeffMinimisationPourNouvelleEval * Coeffminimisation;
        CoeffMobiliteUnidirectionnellePourNouvelleEval := CoeffMobiliteUnidirectionnellePourNouvelleEval * CoeffMobiliteUnidirectionnelle;
        CoeffPenalitePourNouvelleEval                  := CoeffPenalitePourNouvelleEval * CoeffPenalite;
      end;

    {
    WritelnStringAndReelDansRapport('CoeffFrontierePourNouvelleEval = ',CoeffFrontierePourNouvelleEval, 2);
    WritelnStringAndReelDansRapport('CoeffMinimisationPourNouvelleEval = ',CoeffMinimisationPourNouvelleEval, 2);
    WritelnStringAndReelDansRapport('CoeffMobiliteUnidirectionnellePourNouvelleEval = ',CoeffMobiliteUnidirectionnellePourNouvelleEval, 2);
    WritelnStringAndReelDansRapport('CoeffPenalitePourNouvelleEval = ',CoeffPenalitePourNouvelleEval, 2);
    }
end;

procedure AppliqueCoeffsBienChoisis;
begin
    valFrontiere :=                 RoundToL(1.4*valFrontiere);
    valEquivalentFrontiere :=       RoundToL(0.56*valEquivalentFrontiere);
    valPionCentre :=                RoundToL(2.0*valPionCentre);
    valPionPetitCentre :=           RoundToL(1.0*valPionPetitCentre);
    valBetonnage :=                 RoundToL(0.5*valBetonnage);
    valMinimisationAvantCoins :=    RoundToL(0.4*valMinimisationAvantCoins);
    valMinimisationApresCoins :=    RoundToL(0.4*valMinimisationApresCoins);
    valMobiliteUnidirectionnelle := RoundToL(1.0*valMobiliteUnidirectionnelle);
    valPriseCoin :=                 RoundToL(0.8*valPriseCoin);
    valDefenseCoin :=               RoundToL(0.8*valDefenseCoin);
    valCoin :=                      RoundToL(0.8*valCoin);
    valCaseX :=                     RoundToL(1.0*valCaseX);

    if utilisationNouvelleEval
      then penalitePourTraitAff := {RoundToL(0.2*penalitePourTraitAff)}
                                    RoundToL(0.0*penalitePourTraitAff)
      else penalitePourTraitAff := RoundToL(1.0*penalitePourTraitAff);

end;

procedure Superviseur(n : SInt16);
const equivalencePionFrontiere = 7;
begin

  if (n < 0) then n := 0;
  if (n > 64) then n := 64;

  valBetonnage := -50;
  valFrontiere := 16 + (n*(65-n) div 65);
  valEquivalentFrontiere := valFrontiere*equivalencePionFrontiere;

  penalitePourLeTrait := RoundToL(3.0*valEquivalentFrontiere) ;
  penalitePourTraitAff := RoundToL(2.5*valEquivalentFrontiere)  - penalitepourletrait;
    {le total des deux precedents doit faire 3.0*valEquivalentFrontiere}


  if n <= 30
    then valRendementDeLaFrontiere := InterpolationLineaire(n,0,25,30,25)  {25 au coup 0, 25 au coup 30}
    else valRendementDeLaFrontiere := 25;

  valMobiliteUnidirectionnelle := 30;
  {mobilite : 25 au coup 10 , 50 au coup 40}
  {if n <= 10 then valMobiliteUnidirectionnelle := 25 else
  if n >= 40 then valMobiliteUnidirectionnelle := 50 else
    valMobiliteUnidirectionnelle := 25+ (25*(n-10) div (40-10));}

  seuilMobilitePourGrosseMasse := 10;  {moins de 2,5 "equivalents coups", cf MobiliteSemiTranquilleAvecCasesC}
  valGrosseMasse := 1000;


  valPriseCoin := 950;
  valDefenseCoin := 1005;
  valCoin := 1030;
  valCaseX := 500;
  valCaseXEntreCasesC := 600;
  valCaseXPlusCoin := 200;     {valeur d'une case X quand le coin et les cases C sont remplies}
  valCaseXDonnantBordDeSix := 600;
  valCaseXDonnantBordDeCinq := 600;
  valCaseXConsolidantBordDeSix := 600;
  valTrouCaseC := 650;
  valLiberteSurCaseA := 500;
  valLiberteSurCaseAApresMarconisation := 100;
	valLiberteSurCaseB := 200;
  valBonBordDeCinq := 200;
  valTrouDeTroisHorrible := 600;
  valTrouDeDeuxPerdantLaParite := 150;
  valArnaqueSurBordDeCinq := 500;
  valPairePionBordOpposes := 40;
  valBordDeSixPlusQuatre := 500;
  valPionsIsoleSurCaseThill := 100;
  valBordDeCinqTransformable := 250;


  if n <= 20
    then valCasesCoinsCarreCentral := InterpolationLineaire(n,0,20,20,20)
    else valCasesCoinsCarreCentral := InterpolationLineaire(n,20,20,60,100);



  valMinimisationAvantCoins := -50 + (n div 2);
  (*  valMinimisationAvantCoins := -45 - (n-10) div 2;  *)
  valMinimisationApresCoins := RoundToL(0.25*valMinimisationAvantCoins);

  valPionCentre := 25;
  valPionPetitCentre := 5;

  if (n <= 6) then begin
                valPionCentre := valPionCentre+35;
                valPionPetitCentre := valPionPetitCentre+1;
              end;
  if (n > 6) and (n <= 12) then
              begin
                valPionCentre := valPionCentre+40;
                valPionPetitCentre := valPionPetitCentre+15;
              end;
  if (n > 12) and (n < 27) then
              begin
                valPionCentre := valPionCentre+45;
                valPionPetitCentre := valPionPetitCentre+20;
              end;
  if (n >= 27) then
              begin
                valPionCentre := valPionCentre+45;
                valPionPetitCentre := valPionPetitCentre+30;
              end;


  AppliqueCoeffsBienChoisis;
  MultiplicationParCoeff;
end;


procedure SetLargeurFenetreProbCut;
var n : SInt32;
begin

  largFenetreProbCut := 400+Trunc(nbreCoup*((800-400)/40.0)); {400 au coup 0,800 au coup 40}
  largGrandeFenetreProbCut := 2*largFenetreProbCut;
  largHyperGrandeFenetreProbCut := largGrandeFenetreProbCut;

  begin
    largFenetreProbCut := Min(largFenetreProbCut,500);
    largGrandeFenetreProbCut := Min(largFenetreProbCut,500);
    largHyperGrandeFenetreProbCut := Min(largFenetreProbCut,500);
  end;

  for n := -4 to 65 do
     begin
       table_FenetreProbCut[n]            := largFenetreProbCut;
       table_GrandeFenetreProbCut[n]      := largGrandeFenetreProbCut;
       table_HyperGrandeFenetreProbCut[n] := largHyperGrandeFenetreProbCut;
     end;

 if utilisationNouvelleEval then
   begin
     largFenetreProbCut := InterpolationLineaire(nbreCoup, 0, 325, 40, 675); {525 et 575 sont bien aussi}
     largGrandeFenetreProbCut := InterpolationLineaire(nbreCoup, 0, 425, 40, 875); {725 et 775 sont bien aussi}
     largHyperGrandeFenetreProbCut := largGrandeFenetreProbCut;

     for n := -4 to 65 do
       begin
         table_FenetreProbCut[n]            := largFenetreProbCut;
         table_GrandeFenetreProbCut[n]      := largGrandeFenetreProbCut;
         table_HyperGrandeFenetreProbCut[n] := largHyperGrandeFenetreProbCut;
       end;

   end;

end;


procedure InitUnitSuperviseur;
var k : SInt32;
begin
  Initialise_othellier;

  for k := -10 to 74 do
    profOuBiboardEstMieuxPourCeNbreVides[k] := 10000; {jamais}

  profOuBiboardEstMieuxPourCeNbreVides[0] := 0;
  profOuBiboardEstMieuxPourCeNbreVides[1] := 0;
  profOuBiboardEstMieuxPourCeNbreVides[2] := 0;
  profOuBiboardEstMieuxPourCeNbreVides[3] := 0;
  profOuBiboardEstMieuxPourCeNbreVides[4] := 0;
  profOuBiboardEstMieuxPourCeNbreVides[5] := 1;
  profOuBiboardEstMieuxPourCeNbreVides[6] := 2;
  profOuBiboardEstMieuxPourCeNbreVides[7] := 2;
  profOuBiboardEstMieuxPourCeNbreVides[8] := 3;
  profOuBiboardEstMieuxPourCeNbreVides[9] := 4;
  profOuBiboardEstMieuxPourCeNbreVides[10] := 5;
  profOuBiboardEstMieuxPourCeNbreVides[11] := 5;
  profOuBiboardEstMieuxPourCeNbreVides[12] := 6;
  for k := 13 to 64 do
    profOuBiboardEstMieuxPourCeNbreVides[k] := 10000; {jamais}
end;


end.
