UNIT UnitScannerOthellistique;


INTERFACE




 USES UnitDefCassio;




{ Fonctions de traductions }
procedure TraductionThorEnAlphanumerique(const s : PackedThorGame; var result : String255);
procedure TraductionAlphanumeriqueEnThor(const s : String255; var result : PackedThorGame);
procedure TraductionThorEnSuedois(const s : PackedThorGame; var result : String255);
procedure CompacterPartieAlphanumerique(var s : String255; modification : SInt16);
procedure ComparerFormatThorEtFormatSuedois(const s1,s2 : PackedThorGame);


{ Calculs des nombres de pions }
function NbPionsDeCetteCouleurApresCeCoup(var game : PackedThorGame; couleur,numeroCoup : SInt16; var typeErreur : SInt32) : SInt16;
function PeutCalculerScoreFinalDeCettePartie(var game : PackedThorGame; var nbPionsFinalNoirs,nbPionsFinalBlancs : SInt32; var partieTerminee : boolean) : boolean;


{ Calculs des traits }
procedure CalculeLesTraitsDeCettePartie(var s : PackedThorGame; var traitDansPartie : Tableau60Longint);
function CalculeLeTraitApresTelCoup(n : SInt16; s : String255; platDebut : plateauOthello; traitDebut : SInt16) : SInt16;


{ Fonctions de reconnaissance d'une partie d'othello dans une chaine }
function EstUnePartieOthello(var s : String255; compacterPartie : boolean) : boolean;
function EstUnePartieOthelloAvecMiroir(var s : String255) : boolean;
function EstUnePartieOthelloTerminee(var s : String255; compacterPartie : boolean; var nbPionsFinalNoirs,nbPionsFinalBlancs : SInt32) : boolean;


{ Fonction cherchant simultanement une partie et des joueurs dans une chaine }
function TrouverPartieEtJoueursDansChaine(chaine : String255; var partieEnAlpha : String255; var numeroJoueur1,numeroJoueur2 : SInt32; var qualiteSolution : double) : boolean;






IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    MyStrings, UnitRapport, MyMathUtils, UnitNormalisation, UnitPositionEtTrait, UnitScannerUtils, UnitImportDesNoms, UnitStrategie
    , UnitPackedThorGame ;
{$ELSEC}
    {$I prelink/ScannerOthellistique.lk}
{$ENDC}


{END_USE_CLAUSE}












VAR gThorToSuedish : array[0..99] of char;
CONST gThorToSuedishInitialised : boolean = false;



procedure TraductionThorEnAlphanumerique(const s : PackedThorGame; var result : String255);
var i,aux : SInt16;
    chaine : String255;
begin
 chaine := '';
 for i := 1 to GET_LENGTH_OF_PACKED_GAME(s) do
  begin
    aux := GET_NTH_MOVE_OF_PACKED_GAME(s,i,'TraductionThorEnAlphanumerique');
    if (aux >= 11) and (aux <= 88) then
      chaine := chaine + CoupEnStringEnMajuscules(aux);
  end;
 result := chaine;
end;




procedure InitThorToSuedishArray;
var i : SInt32;
begin
  for i := 0 to 99 do
    gThorToSuedish[i] := ' ';

  gThorToSuedish[StringEnCoup('A1')] := 'A';
  gThorToSuedish[StringEnCoup('A2')] := 'B';
  gThorToSuedish[StringEnCoup('A3')] := 'C';
  gThorToSuedish[StringEnCoup('A4')] := 'D';
  gThorToSuedish[StringEnCoup('A5')] := 'E';
  gThorToSuedish[StringEnCoup('A6')] := 'F';
  gThorToSuedish[StringEnCoup('A7')] := 'G';
  gThorToSuedish[StringEnCoup('A8')] := 'H';

  gThorToSuedish[StringEnCoup('B1')] := 'I';
  gThorToSuedish[StringEnCoup('B2')] := 'J';
  gThorToSuedish[StringEnCoup('B3')] := 'K';
  gThorToSuedish[StringEnCoup('B4')] := 'L';
  gThorToSuedish[StringEnCoup('B5')] := 'M';
  gThorToSuedish[StringEnCoup('B6')] := 'N';
  gThorToSuedish[StringEnCoup('B7')] := 'O';
  gThorToSuedish[StringEnCoup('B8')] := 'P';

  gThorToSuedish[StringEnCoup('C1')] := 'Q';
  gThorToSuedish[StringEnCoup('C2')] := 'R';
  gThorToSuedish[StringEnCoup('C3')] := 'S';
  gThorToSuedish[StringEnCoup('C4')] := 'T';
  gThorToSuedish[StringEnCoup('C5')] := 'U';
  gThorToSuedish[StringEnCoup('C6')] := 'V';
  gThorToSuedish[StringEnCoup('C7')] := 'W';
  gThorToSuedish[StringEnCoup('C8')] := 'X';

  gThorToSuedish[StringEnCoup('D1')] := 'Y';
  gThorToSuedish[StringEnCoup('D2')] := 'Z';
  gThorToSuedish[StringEnCoup('D3')] := 'a';
  gThorToSuedish[StringEnCoup('D6')] := 'b';
  gThorToSuedish[StringEnCoup('D7')] := 'c';
  gThorToSuedish[StringEnCoup('D8')] := 'd';

  gThorToSuedish[StringEnCoup('E1')] := 'e';
  gThorToSuedish[StringEnCoup('E2')] := 'f';
  gThorToSuedish[StringEnCoup('E3')] := 'g';
  gThorToSuedish[StringEnCoup('E6')] := 'h';
  gThorToSuedish[StringEnCoup('E7')] := 'i';
  gThorToSuedish[StringEnCoup('E8')] := 'j';

  gThorToSuedish[StringEnCoup('F1')] := 'k';
  gThorToSuedish[StringEnCoup('F2')] := 'l';
  gThorToSuedish[StringEnCoup('F3')] := 'm';
  gThorToSuedish[StringEnCoup('F4')] := 'n';
  gThorToSuedish[StringEnCoup('F5')] := 'o';
  gThorToSuedish[StringEnCoup('F6')] := 'p';
  gThorToSuedish[StringEnCoup('F7')] := 'q';
  gThorToSuedish[StringEnCoup('F8')] := 'r';

  gThorToSuedish[StringEnCoup('G1')] := 's';
  gThorToSuedish[StringEnCoup('G2')] := 't';
  gThorToSuedish[StringEnCoup('G3')] := 'u';
  gThorToSuedish[StringEnCoup('G4')] := 'v';
  gThorToSuedish[StringEnCoup('G5')] := 'w';
  gThorToSuedish[StringEnCoup('G6')] := 'x';
  gThorToSuedish[StringEnCoup('G7')] := 'y';
  gThorToSuedish[StringEnCoup('G8')] := 'z';

  gThorToSuedish[StringEnCoup('H1')] := '0';
  gThorToSuedish[StringEnCoup('H2')] := '1';
  gThorToSuedish[StringEnCoup('H3')] := '2';
  gThorToSuedish[StringEnCoup('H4')] := '3';
  gThorToSuedish[StringEnCoup('H5')] := '4';
  gThorToSuedish[StringEnCoup('H6')] := '5';
  gThorToSuedish[StringEnCoup('H7')] := '6';
  gThorToSuedish[StringEnCoup('H8')] := '7';


  gThorToSuedishInitialised := true;
end;


procedure TraductionThorEnSuedois(const s : PackedThorGame; var result : String255);
var i,aux : SInt16;
    chaine : String255;
begin
  if not(gThorToSuedishInitialised) then InitThorToSuedishArray;

  chaine := '';
  for i := 1 to GET_LENGTH_OF_PACKED_GAME(s) do
    begin
      aux := GET_NTH_MOVE_OF_PACKED_GAME(s,i,'TraductionThorEnSuedois');
      if (aux >= 11) and (aux <= 88) then
        chaine := chaine + gThorToSuedish[aux];
    end;
  result := chaine;

end;

procedure TraductionAlphanumeriqueEnThor(const s : String255; var result : PackedThorGame);
var i,aux : SInt16;
    chaine : String255;
begin

 chaine := '';
 for i := 1 to LENGTH_OF_STRING(s) div 2 do
   begin
     aux := PositionDansStringAlphaEnCoup(s,2*i-1);
     if (aux >= 11) and (aux <= 88) then
       chaine := chaine + CharToString(chr(aux));
   end;

 FILL_PACKED_GAME_WITH_ZEROS(result);
 COPY_STR60_TO_PACKED_GAME(chaine, result);

end;


procedure ComparerFormatThorEtFormatSuedois(const s1,s2 : PackedThorGame);
var i,aux : SInt16;
begin
 for i := 1 to GET_LENGTH_OF_PACKED_GAME(s1) do
  begin
    aux := GET_NTH_MOVE_OF_PACKED_GAME(s1,i,'ComparerFormatThorEtFormatSuedois(1)');
    if (aux >= 11) and (aux <= 88) then
      begin
        WriteDansRapport('  gThorToSuedish[StringEnCoup('''+CoupEnStringEnMajuscules(aux)+''')] := ''');
        WritelnDansRapport(chr(GET_NTH_MOVE_OF_PACKED_GAME(s2,i,'ComparerFormatThorEtFormatSuedois(2)'))+''';');
      end;
  end;
end;

procedure CompacterPartieAlphanumerique(var s : String255; modification : SInt16);
const kNotFound = -1;
var result : String255;
    k,prochainCoupDansChaine,posProchainCoupDansChaine : SInt16;
begin
  EnleveEspacesDeGaucheSurPlace(s);

  result := '';

  prochainCoupDansChaine := ScannerStringPourTrouverCoup(1 , s , posProchainCoupDansChaine);
  while prochainCoupDansChaine <> kNotFound do
    begin
      result := result + s[posProchainCoupDansChaine] + s[posProchainCoupDansChaine+1];
      k := posProchainCoupDansChaine + 2;
      prochainCoupDansChaine := ScannerStringPourTrouverCoup(k , s , posProchainCoupDansChaine);
    end;

  {if (result <> '')
    then }
		  case modification of
		    kCompacterEnMajuscules : s := UpCaseStr(result);
		    kCompacterEnMinuscules : s := LowerCaseStr(result);
		    kCompacterTelQuel      : s := result;    {ne rien faire}
		    otherwise                WritelnDansRapport(' WARNING !! modification inconnue dans CompacterPartieAlphanumeriqueÉ ');
		  end;
end;


function NbPionsDeCetteCouleurApresCeCoup(var game : PackedThorGame; couleur,numeroCoup : SInt16; var typeErreur : SInt32) : SInt16;
var positionEtTrait : PositionEtTraitRec;
    i,j,compteur : SInt16;
begin
  positionEtTrait := PositionEtTraitAfterMoveNumber(game,numeroCoup,typeErreur);

  if typeErreur = kPasErreur
    then
      begin
        compteur := 0;
			  with positionEtTrait do
			    for i := 1 to 8 do
			      for j := 1 to 8 do
			        if position[i*10+j] = couleur then inc(compteur);
			  NbPionsDeCetteCouleurApresCeCoup := compteur;
      end
    else
      NbPionsDeCetteCouleurApresCeCoup := -1;
end;

function PeutCalculerScoreFinalDeCettePartie(var game : PackedThorGame; var nbPionsFinalNoirs,nbPionsFinalBlancs : SInt32; var partieTerminee : boolean) : boolean;
var positionEtTrait : PositionEtTraitRec;
    i,j,t : SInt16;
    ok : boolean;
    coup : SInt32;
begin

   PeutCalculerScoreFinalDeCettePartie := false;
   nbPionsFinalNoirs := 0;
   nbPionsFinalBlancs := 0;
   partieTerminee := false;

   if GET_LENGTH_OF_PACKED_GAME(game) > 0 then
     begin
       positionEtTrait := PositionEtTraitInitiauxStandard;
       for t := 1 to Min(60, GET_LENGTH_OF_PACKED_GAME(game)) do
			   begin
			     coup := GET_NTH_MOVE_OF_PACKED_GAME(game,t,'PeutCalculerScoreFinalDeCettePartie');
			     if (coup <> 0) then
  			     begin
  			       ok := (UpdatePositionEtTrait(positionEtTrait, coup));
  			       {WritelnStringAndBoolDansRapport(NumEnString(t)+'.'+CoupEnString(ord(game[t]),true)+' ('+NumEnString(ord(game[t]))+') => ',ok);}
  			       if not(ok) then
  			         begin {partie illegale}
  			           PeutCalculerScoreFinalDeCettePartie := false;
  			           exit(PeutCalculerScoreFinalDeCettePartie);
  			         end;
			       end;
			   end;

			 PeutCalculerScoreFinalDeCettePartie := true;
			 partieTerminee := (GetTraitOfPosition(positionEtTrait) = pionVide);
			 with positionEtTrait do
			   for i := 1 to 8 do
			     for j := 1 to 8 do
			       case position[i*10+j] of
			         pionNoir : inc(nbPionsFinalNoirs);
			         pionBlanc: inc(nbPionsFinalBlancs);
			       end; {case}

			 if partieTerminee and ((nbPionsFinalNoirs+nbPionsFinalBlancs) <> 64) then
			   begin
			     if nbPionsFinalNoirs  > nbPionsFinalBlancs then nbPionsFinalNoirs  := 64 - nbPionsFinalBlancs else
			     if nbPionsFinalBlancs > nbPionsFinalNoirs  then nbPionsFinalBlancs := 64 - nbPionsFinalNoirs  else
			     if nbPionsFinalNoirs  = nbPionsFinalBlancs then
			       begin
			         nbPionsFinalNoirs  := 32;
			         nbPionsFinalBlancs := 32;
			       end
			   end;

     end;
end;


procedure CalculeLesTraitsDeCettePartie(var s : PackedThorGame; var traitDansPartie : Tableau60Longint);
var plat : plateauOthello;
    i,trait : SInt32;
    ok : boolean;
begin
  OthellierDeDepart(plat);
  trait := pionNoir;
  ok := true;
  for i := 1 to Min(GET_LENGTH_OF_PACKED_GAME(s),60) do
    if ok then
    begin
      if ModifPlatSeulement(GET_NTH_MOVE_OF_PACKED_GAME(s,i,'CalculeLesTraitsDeCettePartie(1)'),plat,trait)
        then
          begin
            traitDansPartie[i] := trait;
            trait := -trait;
          end
        else
          if ModifPlatSeulement(GET_NTH_MOVE_OF_PACKED_GAME(s,i,'CalculeLesTraitsDeCettePartie(2)'),plat,-trait)
            then traitDansPartie[i] := -trait
            else ok := false;
    end;
end;


{ s doit etre au format F5D6C3 etc. }
function CalculeLeTraitApresTelCoup(n : SInt16; s : String255; platDebut : plateauOthello; traitDebut : SInt16) : SInt16;
var i,coup : SInt16;
    ok : boolean;
begin
  if (traitDebut <> pionNoir) and (traitDebut <> pionBlanc)
    then traitDebut := pionNoir;   {on ne sait jamais....}

  if (n >= (LENGTH_OF_STRING(s) div 2)) then n := LENGTH_OF_STRING(s) div 2;
  if (n >= 64) then n := 64;
  ok := true;
  for i := 1 to n do
    if ok then
    begin
      coup := PositionDansStringAlphaEnCoup(s,2*i-1);
      if ModifPlatSeulement(coup,platDebut,traitDebut)
        then traitDebut := -traitDebut
        else ok := ModifPlatSeulement(coup,platDebut,-traitDebut);
    end;

  if not(ok) then CalculeLeTraitApresTelCoup := pionVide else
  if not(DoitPasserPlatSeulement(traitDebut,platDebut))
    then CalculeLeTraitApresTelCoup := traitDebut
    else if not(DoitPasserPlatSeulement(-traitDebut,platDebut))
       then CalculeLeTraitApresTelCoup := -TraitDebut
       else CalculeLeTraitApresTelCoup := pionVide;
end;


function EstUnePartieOthello(var s : String255; compacterPartie : boolean) : boolean;
var partieToujoursLegale,attendUneLettre,attendUnChiffre,coupComplet,dejaCompactee : boolean;
    coup,longueurChaine,k : SInt16;
    nbCoupsRecus : SInt16;
    position : PositionEtTraitRec;
    c,derniereLettreLue : char;
    partieCompactee : String255;

     procedure RecoitCaractere(whichChar : char);
		 begin
		   c := whichChar;
		   if IsLower(c) then c := chr(ord(c)-32);
		   if attendUnChiffre and CharInRange(c,'A','H') then
		     begin
		       derniereLettreLue := c;
		     end;
		   if attendUneLettre
		     then
		       begin
		         if CharInRange(c,'A','H')
		           then
			           begin
		               derniereLettreLue := c;
			             partieCompactee := partieCompactee+whichChar;
			             attendUneLettre := false;
			             attendUnChiffre := true;
			             coup := ord(c)-ord('A')+1;
			           end
			         else
			           dejaCompactee := false;
		       end
		     else
		       begin
		         if CharInRange(c,'1','8')
		           then
			           begin
			             partieCompactee := partieCompactee+whichChar;
			             attendUneLettre := true;
			             attendUnChiffre := false;
			             coup := coup+10*(ord(c)-ord('1')+1);
			             coupComplet := true;
			             inc(nbCoupsRecus);
			           end
			         else
			           dejaCompactee := false;
		       end;
		 end;

begin
  if compacterPartie then CompacterPartieAlphanumerique(s, kCompacterEnMajuscules);

  longueurChaine := LENGTH_OF_STRING(s);
  position := PositionEtTraitInitiauxStandard;

  partieToujoursLegale := (longueurChaine > 0);
  nbCoupsRecus := 0;
  attendUneLettre := true;
  attendUnChiffre := false;
  coupComplet := false;
  dejaCompactee := true;
  partieCompactee := '';

  k := 0;
  if partieToujoursLegale then
    repeat
      inc(k);
      RecoitCaractere(s[k]);
      {
      WritelnNumDansRapport('k = ',k);
      WritelnStringAndBoolDansRapport('attendUneLettre = ',attendUneLettre);
      WritelnStringAndBoolDansRapport('attendUnChiffre = ',attendUnChiffre);
      WritelnStringAndBoolDansRapport('coupComplet = ',coupComplet);
      WritelnStringAndBoolDansRapport('dejaCompactee = ',dejaCompactee);
      WritelnNumDansRapport('coup = ',coup);
      }
      if coupComplet then
        begin
		      if (coup >= 11) and (coup <= 88)
		        then partieToujoursLegale := UpdatePositionEtTrait(position,coup)
		        else partieToujoursLegale := false;
		      coupComplet := false;
		    end;
    until (k >= longueurChaine) or not(partieToujoursLegale);

  if (longueurChaine > 0) and (nbCoupsRecus <= 0) then partieToujoursLegale := false;

  if partieToujoursLegale
    then
      begin
        EstUnePartieOthello := true;
        if compacterPartie then s := partieCompactee;
      end
    else
      EstUnePartieOthello := false;
end;


function EstUnePartieOthelloAvecMiroir(var s : String255) : boolean;
var chaineTest : String255;
begin

  {on teste la chaine telle quelle}
  chaineTest := s;
  if EstUnePartieOthello(chaineTest,true) then
    begin
      s := chaineTest;
      EstUnePartieOthelloAvecMiroir := true;
      {WritelnDansRapport('Sortie 1 de EstUnePartieOthelloAvecMiroir, s = '+s);}
      exit(EstUnePartieOthelloAvecMiroir);
    end;

  {on teste la chaine en enlevant le bruit}
  chaineTest := s;
  CompacterPartieAlphanumerique(chaineTest,kCompacterEnMajuscules);
  if EstUnePartieOthello(chaineTest,true) then
    begin
      s := chaineTest;
      EstUnePartieOthelloAvecMiroir := true;
      {WritelnDansRapport('Sortie 2 de EstUnePartieOthelloAvecMiroir, s = '+s);}
      exit(EstUnePartieOthelloAvecMiroir);
    end;

  {on teste pour voir si ca ne serait pas une position initiale miroir}
  SymetriserPartieFormatAlphanumerique(chaineTest,axeVertical,1,LENGTH_OF_STRING(chaineTest) div 2);
  if EstUnePartieOthello(chaineTest,true) then
    begin
      s := chaineTest;
      EstUnePartieOthelloAvecMiroir := true;
      {WritelnDansRapport('Sortie 3 de EstUnePartieOthelloAvecMiroir, s = '+s);}
      exit(EstUnePartieOthelloAvecMiroir);
    end;

  EstUnePartieOthelloAvecMiroir := false;
end;


function EstUnePartieOthelloTerminee(var s : String255; compacterPartie : boolean; var nbPionsFinalNoirs,nbPionsFinalBlancs : SInt32) : boolean;
var partieAlpha : String255;
    s60 : PackedThorGame;
    partieTerminee : boolean;
begin
  EstUnePartieOthelloTerminee := false;

  partieAlpha := s;
  if EstUnePartieOthello(partieAlpha,compacterPartie) then
    begin
      TraductionAlphanumeriqueEnThor(partieAlpha,s60);
      if PeutCalculerScoreFinalDeCettePartie(s60,nbPionsFinalNoirs,nbPionsFinalBlancs,partieTerminee) and partieTerminee then
        begin
          EstUnePartieOthelloTerminee := true;
          s := partieAlpha;
          exit(EstUnePartieOthelloTerminee);
        end;
    end;


  {si on est autorisŽ a compacter la partie, autant essayer aussi les miroirs}
  if compacterPartie then
    begin
      partieAlpha := s;
      if EstUnePartieOthelloAvecMiroir(partieAlpha) then
        begin
          TraductionAlphanumeriqueEnThor(partieAlpha,s60);
          if PeutCalculerScoreFinalDeCettePartie(s60,nbPionsFinalNoirs,nbPionsFinalBlancs,partieTerminee) and partieTerminee then
            begin
              EstUnePartieOthelloTerminee := true;
              s := partieAlpha;
              exit(EstUnePartieOthelloTerminee);
            end;
        end;
    end;

end;


function TrouverPartieEtJoueursDansChaine(chaine : String255; var partieEnAlpha : String255; var numeroJoueur1,numeroJoueur2 : SInt32; var qualiteSolution : double) : boolean;
var s,lesJoueurs : String255;
    indexDebutDesCoups : SInt32;
    indexFinDesCoups : SInt32;
    partieTrouvee : boolean;
    joueursTrouves : boolean;
    longueurBestSolution : SInt32;

  procedure RechercherCoupsCommencantPar(firstMove : String255; axeSymetrie : SInt32);
  var deb,fin,longueurDeCetteSolution : SInt32;
      reste,moves,lastMove : String255;
  begin
    if (longueurBestSolution < 60) then
      begin
        deb := Pos(firstMove,s);
        if (deb > 0) then
          begin

            reste := RightOfString(s,LENGTH_OF_STRING(s)-deb+1);

            moves := reste;
            if EstUnePartieOthelloAvecMiroir(moves) then
              begin

                longueurDeCetteSolution := LENGTH_OF_STRING(moves) div 2;

                SymetriserPartieFormatAlphanumerique(moves,axeSymetrie,1,longueurDeCetteSolution);

                lastMove := moves[longueurDeCetteSolution*2 -1] + moves[2*longueurDeCetteSolution];

                if (longueurDeCetteSolution > longueurBestSolution) then
                  begin

                    longueurBestSolution := longueurDeCetteSolution;
                    partieEnAlpha := moves;
                    SymetriserPartieFormatAlphanumerique(partieEnAlpha,axeSymetrie,1,longueurDeCetteSolution);

                    fin := Pos(lastMove,reste);

                    indexDebutDesCoups := deb;
                    indexFinDesCoups   := deb+fin;

                  end;
              end;
          end;
      end;
  end;

begin  { TrouverPartieEtJoueursDansChaine }

  partieTrouvee  := false;
  joueursTrouves := false;
  partieEnAlpha  := '';
  numeroJoueur1  := kNroJoueurInconnu;
  numeroJoueur2  := kNroJoueurInconnu;

  indexDebutDesCoups := 1;
  indexFinDesCoups   := LENGTH_OF_STRING(s);

  s := UpCaseStr(chaine);

  longueurBestSolution := 0;
  RechercherCoupsCommencantPar('D3',0);
  RechercherCoupsCommencantPar('F5',0);
  RechercherCoupsCommencantPar('E6',0);
  RechercherCoupsCommencantPar('C4',0);
  RechercherCoupsCommencantPar('F4',axeVertical);
  RechercherCoupsCommencantPar('D6',axeVertical);
  RechercherCoupsCommencantPar('C5',axeVertical);
  RechercherCoupsCommencantPar('E3',axeVertical);

  partieTrouvee := (longueurBestSolution >= 3);

  lesJoueurs := LeftOfString(chaine,indexDebutDesCoups-1) + RightOfString(chaine,LENGTH_OF_STRING(chaine)-indexFinDesCoups);

  joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(lesJoueurs,numeroJoueur1,numeroJoueur2,0,qualiteSolution);

  TrouverPartieEtJoueursDansChaine := partieTrouvee and joueursTrouves;

end;  { TrouverPartieEtJoueursDansChaine }









END.















































