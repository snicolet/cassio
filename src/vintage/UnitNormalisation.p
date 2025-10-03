UNIT UnitNormalisation;





INTERFACE







 USES UnitDefCassio;



{ Orientation d'un coup ou d'une suite de coups suivant le coup 1 courant}
procedure TransposeCoupPourOrientation(var whichSquare : SInt16; autreCoupQuatreDiagonal : boolean);                                                                                ATTRIBUTE_NAME('TransposeCoupPourOrientation')
procedure TransposePartiePourOrientation(var partie60 : PackedThorGame; autreCoupQuatreDiagonal : boolean; minCoupTranspose,maxCoupTranspose : SInt32);                             ATTRIBUTE_NAME('TransposePartiePourOrientation')


{ Normalisations diverses, en particulier pour la base WThor }
function PartieNormalisee(var autreCoupQuatreDiag : boolean; interversions : boolean) : String255;                                                                                  ATTRIBUTE_NAME('PartieNormalisee')
procedure Normalisation(var partie120 : String255; var autreCoupQuatreDiag : boolean; interversions : boolean);                                                                     ATTRIBUTE_NAME('Normalisation')
function NormaliserLaPartiePourInclusionDansLaBaseWThor(const partieEnAlpha : String255) : String255;                                                                               ATTRIBUTE_NAME('NormaliserLaPartiePourInclusionDansLaBaseWThor')
procedure ExtraitPremierCoup(var premierCoup : SInt16; var autreCoupQuatreDiag : boolean);                                                                                          ATTRIBUTE_NAME('ExtraitPremierCoup')
function PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6 : boolean;                                                                                                               ATTRIBUTE_NAME('PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6')


{ Gestion du premier coup affiche dans la liste de parties }
function GetPremierCoupParDefaut : SInt32;                                                                                                                                          ATTRIBUTE_NAME('GetPremierCoupParDefaut')
procedure SetPremierCoupParDefaut(coup : SInt32);                                                                                                                                   ATTRIBUTE_NAME('SetPremierCoupParDefaut')


{ Fonctions de symetries }
procedure EffectueSymetrieAxeNW_SE(var plat : plateauOthello);                                                                                                                      ATTRIBUTE_NAME('EffectueSymetrieAxeNW_SE')
procedure EffectueSymetrieAxeNE_SW(var plat : plateauOthello);                                                                                                                      ATTRIBUTE_NAME('EffectueSymetrieAxeNE_SW')
function CaseSymetrique(whichSquare : SInt16; axeSymetrie : SInt32) : SInt16;                                                                                                       ATTRIBUTE_NAME('CaseSymetrique')
procedure SymetriserPartieFormatThor(var s60 : PackedThorGame; axeSymetrie : SInt32; debut,fin : SInt32);                                                                           ATTRIBUTE_NAME('SymetriserPartieFormatThor')
procedure SymetriserPartieFormatAlphanumerique(var s : String255; axeSymetrie : SInt32; debut,fin : SInt32);                                                                        ATTRIBUTE_NAME('SymetriserPartieFormatAlphanumerique')
procedure EffectueSymetrieOnSquare(var whichSquare : SInt16; var axeSymetrie : SInt32; var continuer : boolean);                                                                    ATTRIBUTE_NAME('EffectueSymetrieOnSquare')
function TrouveSymetrieEgalisante(whichPos : plateauOthello; numeroCoup : SInt16; var s60 : PackedThorGame; var axe : SInt16) : boolean;                                            ATTRIBUTE_NAME('TrouveSymetrieEgalisante')


{ Une petite gestion de numeros d'ouvertures (tres basique) }
function NroOuverture(var s : packed7) : SInt32;                                                                                                                                    ATTRIBUTE_NAME('NroOuverture')
procedure IntervalleOuverture_6(var s : packed7; var minimum,maximum : SInt32);                                                                                                      ATTRIBUTE_NAME('IntervalleOuverture_6')
procedure IntervalleOuverture_5(var s : packed7; var minimum,maximum : SInt32);                                                                                                      ATTRIBUTE_NAME('IntervalleOuverture_5')
procedure IntervalleOuverture_4(var s : packed7; var minimum,maximum : SInt32);                                                                                                      ATTRIBUTE_NAME('IntervalleOuverture_4')
procedure IntervalleOuverture_3(var s : packed7; var minimum,maximum : SInt32);                                                                                                      ATTRIBUTE_NAME('IntervalleOuverture_3')
procedure IntervalleOuverture_2(var s : packed7; var minimum,maximum : SInt32);                                                                                                      ATTRIBUTE_NAME('IntervalleOuverture_2')
procedure DetermineIntervalleOuverture(var ouv : packed7; longueur : SInt16; var minimum,maximum : SInt32);                                                                          ATTRIBUTE_NAME('DetermineIntervalleOuverture')
function EstDansTableOuverture(nom : String255; var nroDansTable : SInt16) : boolean;                                                                                               ATTRIBUTE_NAME('EstDansTableOuverture')


{ Acces aux coups de la parties courante }
function GetNiemeCoupPartieCourante(numeroDuCoup : SInt32) : SInt32;                                                                                                                ATTRIBUTE_NAME('GetNiemeCoupPartieCourante')
function DerniereCaseJouee : SInt32;                                                                                                                                                ATTRIBUTE_NAME('DerniereCaseJouee')
procedure SetNiemeCoup(numeroDuCoup : SInt32; square : SInt32);                                                                                                                     ATTRIBUTE_NAME('SetNiemeCoup')
function TrouveCoupDansPartieCourante(whichSquare : SInt16; var numeroDuCoup : SInt16) : boolean;                                                                                   ATTRIBUTE_NAME('TrouveCoupDansPartieCourante')
function DernierCoupEnString(enMajuscules : boolean) : String255;                                                                                                                   ATTRIBUTE_NAME('DernierCoupEnString')
function GetDernierCoup : SInt16;                                                                                                                                                   ATTRIBUTE_NAME('GetDernierCoup')
function GetCouleurNiemeCoupPartieCourante(numeroDuCoup : SInt32) : SInt32;                                                                                                         ATTRIBUTE_NAME('GetCouleurNiemeCoupPartieCourante')
function GetCouleurDernierCoup : SInt32;                                                                                                                                            ATTRIBUTE_NAME('GetCouleurDernierCoup')
function UnJoueurVientDePasser : boolean;                                                                                                                                           ATTRIBUTE_NAME('UnJoueurVientDePasser')
function GetPositionInitialePartieEnCours : PositionEtTraitRec;                                                                                                                     ATTRIBUTE_NAME('GetPositionInitialePartieEnCours')
function GetPositionEtTraitPartieCouranteApresCeCoup(numeroCoup : SInt16; var typeErreur : SInt32) : PositionEtTraitRec;                                                            ATTRIBUTE_NAME('GetPositionEtTraitPartieCouranteApresCeCoup')
function EstLaPositionInitialeDeLaPartieEnCours(var whichPos : PositionEtTraitRec) : boolean;                                                                                       ATTRIBUTE_NAME('EstLaPositionInitialeDeLaPartieEnCours')


{ Des utilitaires sur les positions }
function PositionsSontEgales(const pos1,pos2 : plateauOthello) : boolean;                                                                                                           ATTRIBUTE_NAME('PositionsSontEgales')
function CalculePositionApres(numero : SInt16; partie60 : PackedThorGame) : plateauOthello;                                                                                         ATTRIBUTE_NAME('CalculePositionApres')
function CalculePositionEtTraitApres(var partie60 : PackedThorGame; numeroCoup : SInt16; var position : plateauOthello; var trait,nbBlanc,nbNoir : SInt32) : boolean;               ATTRIBUTE_NAME('CalculePositionEtTraitApres')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    TextUtils
{$IFC NOT(USE_PRELINK)}
    , UnitUtilitaires, UnitStrategie, MyMathUtils, UnitRapport, UnitScannerUtils, MyStrings, UnitServicesMemoire
    , UnitPackedThorGame, UnitPositionEtTrait, UnitInterversions, UnitArbreDeJeuCourant, UnitPressePapier, UnitScannerOthellistique ;
{$ELSEC}
    ;
    {$I prelink/Normalisation.lk}
{$ENDC}


{END_USE_CLAUSE}











var premierCoupParDefautDansListe : SInt32;




function TrouveCoupDansPartieCourante(whichSquare : SInt16; var numeroDuCoup : SInt16) : boolean;
var i : SInt16;
begin
  for i := 1 to nroDernierCoupAtteint do
    if GetNiemeCoupPartieCourante(i) = whichSquare then
      begin
        numeroDuCoup := i-1;
        TrouveCoupDansPartieCourante := true;
        exit(TrouveCoupDansPartieCourante);
      end;
  numeroDuCoup := -1;
  TrouveCoupDansPartieCourante := false;
end;


function GetNiemeCoupPartieCourante(numeroDuCoup : SInt32) : SInt32;
begin
  GetNiemeCoupPartieCourante := partie^^[numeroDuCoup].theSquare;
end;

function DerniereCaseJouee : SInt32;
begin
  DerniereCaseJouee := partie^^[nbreCoup].theSquare;
end;

procedure SetNiemeCoup(numeroDuCoup : SInt32; square : SInt32);
begin
  partie^^[numeroDuCoup].theSquare := square;
end;



function GetCouleurNiemeCoupPartieCourante(numeroDuCoup : SInt32) : SInt32;
begin
  GetCouleurNiemeCoupPartieCourante := partie^^[numeroDuCoup].trait;
end;

function GetCouleurDernierCoup : SInt32;
begin
  GetCouleurDernierCoup := partie^^[nbreCoup].trait;
end;

function UnJoueurVientDePasser : boolean;
begin
  UnJoueurVientDePasser := (AQuiDeJouer <> pionVide)
                           & (nbreCoup > 0)
                           & (AQuiDeJouer = partie^^[nbreCoup].trait);
end;



procedure TransposeCoupPourOrientation(var whichSquare : SInt16; autreCoupQuatreDiagonal : boolean);
var premierCoupParDefaut : SInt32;
  begin
    premierCoupParDefaut := GetPremierCoupParDefaut;
    if (GetNiemeCoupPartieCourante(1) = 65) | (premierCoupParDefaut = 65) then whichSquare := 10*platMod10[whichSquare]+platDiv10[whichSquare] else
    if (GetNiemeCoupPartieCourante(1) = 43) | (premierCoupParDefaut = 43) then whichSquare := 10*(9-platDiv10[whichSquare])+9-platMod10[whichSquare] else
    if (GetNiemeCoupPartieCourante(1) = 34) | (premierCoupParDefaut = 34) then whichSquare := 10*(9-platMod10[whichSquare])+9-platDiv10[whichSquare];
    if autreCoupQuatreDiagonal then whichSquare := 10*platMod10[whichSquare]+platDiv10[whichSquare];
  end;


procedure TransposePartiePourOrientation(var partie60 : PackedThorGame; autreCoupQuatreDiagonal : boolean; minCoupTranspose,maxCoupTranspose : SInt32);
var i,whichSquare,longueur : SInt16;
    premierCoupParDefaut : SInt32;
  begin
    longueur := GET_LENGTH_OF_PACKED_GAME(partie60);
    premierCoupParDefaut := GetPremierCoupParDefaut;
    if (GetNiemeCoupPartieCourante(1) = 65) | (premierCoupParDefaut = 65)
      then
        for i := 1 to longueur do
          begin
            whichSquare := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'TransposePartiePourOrientation(1)');
            whichSquare := 10*platMod10[whichSquare]+platDiv10[whichSquare];
            SET_NTH_MOVE_OF_PACKED_GAME(partie60, i, whichSquare);
          end
      else
        if (GetNiemeCoupPartieCourante(1) = 43) | (premierCoupParDefaut = 43)
          then
            for i := 1 to longueur do
              begin
                whichSquare := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'TransposePartiePourOrientation(2)');
                whichSquare := 10*(9-platDiv10[whichSquare])+9-platMod10[whichSquare];
                SET_NTH_MOVE_OF_PACKED_GAME(partie60, i, whichSquare);
              end
             else
               if (GetNiemeCoupPartieCourante(1) = 34) | (premierCoupParDefaut = 34)
                 then
                  for i := 1 to longueur do
                    begin
                      whichSquare := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'TransposePartiePourOrientation(3)');
                      whichSquare := 10*(9-platMod10[whichSquare])+9-platDiv10[whichSquare];
                      SET_NTH_MOVE_OF_PACKED_GAME(partie60, i, whichSquare);
                    end;
    if autreCoupQuatreDiagonal &
       (minCoupTranspose >= 1) & (minCoupTranspose <= 60) &
       (maxCoupTranspose >= 1) & (maxCoupTranspose <= 60) then
        begin
          for i := Min(minCoupTranspose,longueur) to Min(maxCoupTranspose,longueur) do
            begin
              whichSquare := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'TransposePartiePourOrientation(4)');
              whichSquare := 10*platMod10[whichSquare]+platDiv10[whichSquare];
              SET_NTH_MOVE_OF_PACKED_GAME(partie60 , i, whichSquare);
            end;
        end;
  end;



function PartieNormalisee(var autreCoupQuatreDiag : boolean; interversions : boolean) : String255;
var s : String255;
    i,coup : SInt16;
    charAux : char;
    premierCoupParDefaut : SInt32;
begin
  s := '';
  premierCoupParDefaut := GetPremierCoupParDefaut;
  autreCoupQuatreDiag := false;
  if nbreCoup > 0 then
    begin
      if (GetNiemeCoupPartieCourante(1) = 56) | (premierCoupParDefaut = 56) then
       for i := 1 to nbreCoup do
         begin
           coup := GetNiemeCoupPartieCourante(i);
           s := s + CoupEnStringEnMajuscules(coup);
         end
       else
        if (GetNiemeCoupPartieCourante(1) = 65) | (premierCoupParDefaut = 65) then
          for i := 1 to nbreCoup do
           begin
             coup := GetNiemeCoupPartieCourante(i);
             s := s + CHR(64+platDiv10[coup]) + chr(48+platMod10[coup]);
           end
          else
           if (GetNiemeCoupPartieCourante(1) = 43) | (premierCoupParDefaut = 43) then
             for i := 1 to nbreCoup do
             begin
               coup := GetNiemeCoupPartieCourante(i);
               s := s + CHR(73-(platMod10[coup])) + chr(57-(platDiv10[coup]));
             end
            else
             if (GetNiemeCoupPartieCourante(1) = 34) | (premierCoupParDefaut = 34) then
              for i := 1 to nbreCoup do
                begin
                 coup := GetNiemeCoupPartieCourante(i);
                 s := s + CHR(73-(platDiv10[coup])) + chr(57-(platMod10[coup]));
                end;
       if nbreCoup >= 4 then
         begin
           if Pos('F5F6E6D6',s) = 1 then
             begin
               autreCoupQuatreDiag := true;
               for i := 4 to nbreCoup do
                 begin
                   charAux := chr(ord(s[2*i-1])-16);
                   s[2*i-1] := chr(ord(s[2*i])+16);
                   s[2*i] := charAux;
                 end;
             end;
         end
    end;
    if interversions
      then
        begin
          TraiteIntervertionsCoups(s);
          if nbreCoup >= 4 then
               begin
                 if Pos('F5F6E6D6',s) = 1 then
                   begin
                     autreCoupQuatreDiag := not(autreCoupQuatreDiag);
                     for i := 4 to nbreCoup do
                       begin
                         charAux := chr(ord(s[2*i-1])-16);
                         s[2*i-1] := chr(ord(s[2*i])+16);
                         s[2*i] := charAux;
                       end;
                   end;
               end;
        end;
    PartieNormalisee := s;
end;


procedure ExtraitPremierCoup(var premierCoup : SInt16; var autreCoupQuatreDiag : boolean);
var premierCoupParDefaut : SInt32;
begin
  premierCoup := 0;
  autreCoupQuatreDiag := false;
  premierCoupParDefaut := GetPremierCoupParDefaut;
  if nbreCoup > 0 then
    begin
      if (GetNiemeCoupPartieCourante(1) = 56) | (premierCoupParDefaut = 56)
        then begin
          premierCoup := 56;
          autreCoupQuatreDiag := (GetNiemeCoupPartieCourante(2) = 66) & (GetNiemeCoupPartieCourante(3) = 65) & (GetNiemeCoupPartieCourante(4) = 64);
        end else
      if (GetNiemeCoupPartieCourante(1) = 65) | (premierCoupParDefaut = 65)
        then begin
          premierCoup := 65;
          autreCoupQuatreDiag := (GetNiemeCoupPartieCourante(2) = 66) & (GetNiemeCoupPartieCourante(3) = 56) & (GetNiemeCoupPartieCourante(4) = 46);
        end else
      if (GetNiemeCoupPartieCourante(1) = 43) | (premierCoupParDefaut = 43)
        then begin
          premierCoup := 43;
          autreCoupQuatreDiag := (GetNiemeCoupPartieCourante(2) = 33) & (GetNiemeCoupPartieCourante(3) = 34) & (GetNiemeCoupPartieCourante(4) = 35);
        end else
      if (GetNiemeCoupPartieCourante(1) = 34) | (premierCoupParDefaut = 34)
        then begin
          premierCoup := 34;
          autreCoupQuatreDiag := (GetNiemeCoupPartieCourante(2) = 33) & (GetNiemeCoupPartieCourante(3) = 43) & (GetNiemeCoupPartieCourante(4) = 53);
        end;
    end;
end;

function PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6 : boolean;
var premierCoup : SInt16;
    autreCoupDiagonale : boolean;
begin
  ExtraitPremierCoup(premierCoup,autreCoupDiagonale);
  PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6 := autreCoupDiagonale;
end;

procedure Normalisation(var partie120 : String255; var autreCoupQuatreDiag : boolean; interversions : boolean);
var s : String255;
    i,coup : SInt16;
    charAux : char;
    longueurPartie : SInt16;
begin
  s := '';
  longueurPartie := LENGTH_OF_STRING(partie120) div 2;
  autreCoupQuatreDiag := false;
  if longueurPartie > 0 then
    begin
      if  (partie120[1] = 'F') & (partie120[2] = '5') then
        begin
          s := partie120;
        end
       else
        if (partie120[1] = 'E') & (partie120[2] = '6') then
          for i := 1 to longueurPartie do
           begin
             coup := ord(partie120[2*i-1])-64 + 10*(ord(partie120[2*i])-48);
             s := s + CHR(64+platDiv10[coup]) + chr(48+platMod10[coup]);
           end
          else
           if (partie120[1] = 'C') & (partie120[2] = '4') then
             for i := 1 to longueurPartie do
             begin
               coup := ord(partie120[2*i-1])-64 + 10*(ord(partie120[2*i])-48);
               s := s + CHR(73-(platMod10[coup])) + chr(57-(platDiv10[coup]));
             end
            else
             if (partie120[1] = 'D') & (partie120[2] = '3') then
              for i := 1 to longueurPartie do
                begin
                 coup := ord(partie120[2*i-1])-64 + 10*(ord(partie120[2*i])-48);
                 s := s + CHR(73-(platDiv10[coup])) + chr(57-(platMod10[coup]));
                end;
       if longueurPartie >= 4 then
         begin
           if Pos('F5F6E6D6',s) = 1 then
             begin
               autreCoupQuatreDiag := true;
               for i := 4 to longueurPartie do
                 begin
                   charAux := chr(ord(s[2*i-1])-16);
                   s[2*i-1] := chr(ord(s[2*i])+16);
                   s[2*i] := charAux;
                 end;
             end;
         end
    end;
    if interversions
      then
        begin
          TraiteIntervertionsCoups(s);
          if (longueurPartie >= 4) & (Pos('F5F6E6D6',s) = 1) then
            begin
               autreCoupQuatreDiag := true;
               for i := 4 to longueurPartie do
                 begin
                   charAux := chr(ord(s[2*i-1])-16);
                   s[2*i-1] := chr(ord(s[2*i])+16);
                   s[2*i] := charAux;
                 end;
             end;
        end;
    partie120 := s;
end;


{ NormaliserLaPartiePourInclusionDansLaBaseWThor suppose que la partie
  commence en F5 (c'est le cas par exemple si on a appelle la procedure
  "Normalisation" ci-dessus avant d'appeler cette fonction) }
function NormaliserLaPartiePourInclusionDansLaBaseWThor(const partieEnAlpha : String255) : String255;
var s : String255;
    longueurPartie : SInt32;
begin
  s := partieEnAlpha;
  longueurPartie := LENGTH_OF_STRING(s) div 2;

  { Diagonale }
  if (longueurPartie >= 4) & (Pos('F5F6E6D6',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,4,longueurPartie);

  { Heath Cheminee Diagonale }
  if (longueurPartie >= 8) & (Pos('F5F6E6F4G5D6E7F7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,8,longueurPartie);

  { Coup 6 bizarre sur la Rose }
  if (longueurPartie >= 8) & (Pos('F5D6C5F4E3C3E6F2',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,8,longueurPartie);

  if (longueurPartie >= 8) & (Pos('F5D6C5F4E3C3E6D2',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,8,longueurPartie);

  { Coup 6 bizarre sur la Rose, un coup plus loin }
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C3E6F6C4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C3E6F6D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C3E6F6E7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C3E6F6F7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  { Inoue }
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3C4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3B7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3C7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C6E6F3E7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeSE_NW,9,longueurPartie);

  { Ball }
  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6C3',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6B4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6B5',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6C6',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);

  if (longueurPartie >= 9) & (Pos('F5D6C5F4E3C4D3E6D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,9,longueurPartie);

  { position de Cedric }
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B3',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B5',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B6',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6B7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6C7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4E6C6D3F6D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  { position de Cedric, par interversion }
  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B3',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B4',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B5',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B6',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6B7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6C7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  if (longueurPartie >= 11) & (Pos('F5D6C5F4E3C4D3C6E6F6D7',s) = 1) then
    SymetriserPartieFormatAlphanumerique(s,axeVertical,11,longueurPartie);

  NormaliserLaPartiePourInclusionDansLaBaseWThor := s;
end;





 { donne un numero au debut de partie dans s.
   Le premier coup est supposé etre en F5}
function NroOuverture(var s : packed7) : SInt32;
begin
  if s[2] = 66 then begin                           {diagonale}
    if s[3] = 65 then begin
      if s[4] = 46 then begin
        if s[5] = 35 then begin
          if s[6] = 53 then begin
            if s[7] = 43 then NroOuverture := 1 else
            if s[7] = 57 then NroOuverture := 2 else
            NroOuverture := 3 end else
          if s[6] = 64 then begin
            if s[7] = 43 then NroOuverture := 4 else
            NroOuverture := 5 end else
          NroOuverture := 6 end else
        if s[5] = 57 then begin
          if s[6] = 75 then begin
            if s[7] = 76 then NroOuverture := 7 else
            if s[7] = 35 then NroOuverture := 8 else
            NroOuverture := 9 end else
          if s[6] = 64 then begin
            if s[7] = 75 then NroOuverture := 10 else
            NroOuverture := 11 end else
          NroOuverture := 12 end else
        if s[5] = 33 then begin
          if s[6] = 64 then begin
            if s[7] = 36 then NroOuverture := 13 else
            NroOuverture := 14 end else
          if s[6] = 74 then begin
            if s[7] = 36 then NroOuverture := 15 else
            NroOuverture := 16 end else
          NroOuverture := 17 end else
        if s[5] = 67 then begin
          if s[6] = 64 then begin
            if s[7] = 47 then NroOuverture := 18 else
            NroOuverture := 19 end else
          if s[6] = 53 then begin
            if s[7] = 47 then NroOuverture := 20 else
            NroOuverture := 21 end else
          NroOuverture := 22 end else
        if s[5] = 77 then NroOuverture := 23 else
        if s[5] = 34 then NroOuverture := 24 else
        if s[5] = 36 then NroOuverture := 25 else
        if s[5] = 37 then NroOuverture := 26 else
        NroOuverture := 27 end else
      NroOuverture := 28 end else
    NroOuverture := 29 end else
  if s[2] = 64 then begin                         {perpendiculaire}
    if s[3] = 53 then begin
      if s[4] = 46 then begin
        if s[5] = 35 then begin
          if s[6] = 63 then begin
            if s[7] = 34 then NroOuverture := 30 else
            if s[7] = 36 then NroOuverture := 31 else
            if s[7] = 65 then NroOuverture := 32 else
            if s[7] = 74 then NroOuverture := 33 else
            NroOuverture := 34 end else
          if s[6] = 66 then begin
            if s[7] = 36 then NroOuverture := 35 else
            NroOuverture := 36 end else
          NroOuverture := 37 end else
        if s[5] = 34 then begin
          if s[6] = 35 then NroOuverture := 38 else
          if s[6] = 43 then NroOuverture := 39 else
          NroOuverture := 40 end else
        if s[5] = 74 then NroOuverture := 41 else
        NroOuverture := 42 end else
      NroOuverture := 43 end else
    if s[3] = 33 then begin
      if s[4] = 34 then begin
        if s[5] = 43 then begin
          if s[6] = 46 then begin
            if s[7] = 66 then NroOuverture := 44 else
            if s[7] = 53 then NroOuverture := 45 else
            if s[7] = 35 then NroOuverture := 46 else
            if s[7] = 65 then NroOuverture := 47 else
            NroOuverture := 48 end else
          if s[6] = 32 then NroOuverture := 49 else
          NroOuverture := 50 end else
        NroOuverture := 51 end else
      if s[4] = 46 then begin
        if s[5] = 66 then NroOuverture := 52 else
        if s[5] = 65 then NroOuverture := 53 else
        NroOuverture := 54 end else
      if s[4] = 57 then begin
        if s[5] = 63 then NroOuverture := 55 else
        if s[5] = 66 then NroOuverture := 56 else
        if s[5] = 67 then NroOuverture := 57 else
        NroOuverture := 58 end else
      NroOuverture := 59 end else
    if s[3] = 43 then begin
      if s[4] = 34 then begin
        if s[5] = 53 then begin
          if s[6] = 56 then NroOuverture := 60 else
          if s[6] = 42 then NroOuverture := 61 else
          NroOuverture := 62 end else
        if s[5] = 65 then NroOuverture := 63 else
        if s[5] = 33 then NroOuverture := 64 else
        NroOuverture := 65 end else
      if s[4] = 57 then begin
        if s[5] = 63 then NroOuverture := 66 else
        if s[5] = 66 then NroOuverture := 67 else
        if s[5] = 67 then NroOuverture := 68 else
        NroOuverture := 69 end else
      if s[4] = 46 then begin
        if s[5] = 53 then NroOuverture := 70 else
        NroOuverture := 71 end else
      NroOuverture := 72 end else
    NroOuverture := 73 end else
  if s[2] = 46 then begin                           {parallele}
    if s[3] = 35 then begin
      if s[4] = 66 then begin
        if s[5] = 65 then NroOuverture := 74 else
        if s[5] = 34 then NroOuverture := 75 else
        NroOuverture := 76 end else
      if s[4] = 64 then begin
        if s[5] = 65 then NroOuverture := 77 else
        if s[5] = 36 then NroOuverture := 78 else
        NroOuverture := 79 end else
      if s[4] = 24 then begin
        if s[5] = 25 then NroOuverture := 80 else
        if s[5] = 65 then NroOuverture := 81 else
        NroOuverture := 82 end else
      if s[4] = 26 then begin
        if s[5] = 25 then NroOuverture := 83 else
        if s[5] = 65 then NroOuverture := 84 else
        NroOuverture := 85 end else
      NroOuverture := 86 end else
    NroOuverture := 87 end else
  NroOuverture := 0;
end;

procedure IntervalleOuverture_6(var s : packed7; var minimum,maximum : SInt32);
var NroOuverture : SInt16;
begin
  NroOuverture := -1;
  if s[2] = 66 then begin                           {diagonale}
    if s[3] = 65 then begin
      if s[4] = 46 then begin
        if s[5] = 35 then begin
          if s[6] = 53 then begin
            minimum := 1;
            maximum := 3;
            end else
          if s[6] = 64 then begin
            minimum := 4;
            maximum := 5;
            end else
          NroOuverture := 6 end else
        if s[5] = 57 then begin
          if s[6] = 75 then begin
            minimum := 7;
            maximum := 9;
            end else
          if s[6] = 64 then begin
            minimum := 10;
            maximum := 11;
            end else
          NroOuverture := 12 end else
        if s[5] = 33 then begin
          if s[6] = 64 then begin
            minimum := 13;
            maximum := 14;
            end else
          if s[6] = 74 then begin
            minimum := 15;
            maximum := 16;
            end else
          NroOuverture := 17 end else
        if s[5] = 67 then begin
          if s[6] = 64 then begin
            minimum := 18;
            maximum := 19;
            end else
          if s[6] = 53 then begin
            minimum := 20;
            maximum := 21;
            end else
          NroOuverture := 22 end else
        if s[5] = 77 then NroOuverture := 23 else
        if s[5] = 34 then NroOuverture := 24 else
        if s[5] = 36 then NroOuverture := 25 else
        if s[5] = 37 then NroOuverture := 26 else
        NroOuverture := 27 end else
      NroOuverture := 28 end else
    NroOuverture := 29 end else
  if s[2] = 64 then begin                         {perpendiculaire}
    if s[3] = 53 then begin
      if s[4] = 46 then begin
        if s[5] = 35 then begin
          if s[6] = 63 then begin
            minimum := 30;
            maximum := 34;
            end else
          if s[6] = 66 then begin
            minimum := 35;
            maximum := 36;
            end else
          NroOuverture := 37 end else
        if s[5] = 34 then begin
            minimum := 38;
            maximum := 40;
            end else
        if s[5] = 74 then NroOuverture := 41 else
        NroOuverture := 42 end else
      NroOuverture := 43 end else
    if s[3] = 33 then begin
      if s[4] = 34 then begin
        if s[5] = 43 then begin
          if s[6] = 46 then begin
            minimum := 44;
            maximum := 48;
            end else
          if s[6] = 32 then NroOuverture := 49 else
          NroOuverture := 50 end else
        NroOuverture := 51 end else
      if s[4] = 46 then begin
        if s[5] = 66 then NroOuverture := 52 else
        if s[5] = 65 then NroOuverture := 53 else
        NroOuverture := 54 end else
      if s[4] = 57 then begin
        if s[5] = 63 then NroOuverture := 55 else
        if s[5] = 66 then NroOuverture := 56 else
        if s[5] = 67 then NroOuverture := 57 else
        NroOuverture := 58 end else
      NroOuverture := 59 end else
    if s[3] = 43 then begin
      if s[4] = 34 then begin
        if s[5] = 53 then begin
          if s[6] = 56 then NroOuverture := 60 else
          if s[6] = 42 then NroOuverture := 61 else
          NroOuverture := 62 end else
        if s[5] = 65 then NroOuverture := 63 else
        if s[5] = 33 then NroOuverture := 64 else
        NroOuverture := 65 end else
      if s[4] = 57 then begin
        if s[5] = 63 then NroOuverture := 66 else
        if s[5] = 66 then NroOuverture := 67 else
        if s[5] = 67 then NroOuverture := 68 else
        NroOuverture := 69 end else
      if s[4] = 46 then begin
        if s[5] = 53 then NroOuverture := 70 else
        NroOuverture := 71 end else
      NroOuverture := 72 end else
    NroOuverture := 73 end else
  if s[2] = 46 then begin                           {parallele}
    if s[3] = 35 then begin
      if s[4] = 66 then begin
        if s[5] = 65 then NroOuverture := 74 else
        if s[5] = 34 then NroOuverture := 75 else
        NroOuverture := 76 end else
      if s[4] = 64 then begin
        if s[5] = 65 then NroOuverture := 77 else
        if s[5] = 36 then NroOuverture := 78 else
        NroOuverture := 79 end else
      if s[4] = 24 then begin
        if s[5] = 25 then NroOuverture := 80 else
        if s[5] = 65 then NroOuverture := 81 else
        NroOuverture := 82 end else
      if s[4] = 26 then begin
        if s[5] = 25 then NroOuverture := 83 else
        if s[5] = 65 then NroOuverture := 84 else
        NroOuverture := 85 end else
      NroOuverture := 86 end else
    NroOuverture := 87 end else
  NroOuverture := 0;

  if NroOuverture <> -1 then
    begin
      minimum := NroOuverture;
      maximum := NroOuverture;
    end;
end;

procedure IntervalleOuverture_5(var s : packed7; var minimum,maximum : SInt32);
var NroOuverture : SInt16;
begin
  NroOuverture := -1;
  if s[2] = 66 then begin                           {diagonale}
    if s[3] = 65 then begin
      if s[4] = 46 then begin
        if s[5] = 35 then begin
            minimum := 1;
            maximum := 6;
            end else
        if s[5] = 57 then begin
            minimum := 7;
            maximum := 12;
            end else
        if s[5] = 33 then begin
            minimum := 13;
            maximum := 17;
            end else
        if s[5] = 67 then begin
            minimum := 18;
            maximum := 22;
            end else
        if s[5] = 77 then NroOuverture := 23 else
        if s[5] = 34 then NroOuverture := 24 else
        if s[5] = 36 then NroOuverture := 25 else
        if s[5] = 37 then NroOuverture := 26 else
        NroOuverture := 27 end else
      NroOuverture := 28 end else
    NroOuverture := 29 end else
  if s[2] = 64 then begin                         {perpendiculaire}
    if s[3] = 53 then begin
      if s[4] = 46 then begin
        if s[5] = 35 then begin
            minimum := 30;
            maximum := 37;
            end else
        if s[5] = 34 then begin
            minimum := 38;
            maximum := 40;
            end else
        if s[5] = 74 then NroOuverture := 41 else
        NroOuverture := 42 end else
      NroOuverture := 43 end else
    if s[3] = 33 then begin
      if s[4] = 34 then begin
        if s[5] = 43 then begin
            minimum := 44;
            maximum := 50;
            end else
        NroOuverture := 51 end else
      if s[4] = 46 then begin
        if s[5] = 66 then NroOuverture := 52 else
        if s[5] = 65 then NroOuverture := 53 else
        NroOuverture := 54 end else
      if s[4] = 57 then begin
        if s[5] = 63 then NroOuverture := 55 else
        if s[5] = 66 then NroOuverture := 56 else
        if s[5] = 67 then NroOuverture := 57 else
        NroOuverture := 58 end else
      NroOuverture := 59 end else
    if s[3] = 43 then begin
      if s[4] = 34 then begin
        if s[5] = 53 then begin
          minimum := 60;
          maximum := 62;
          end else
        if s[5] = 65 then NroOuverture := 63 else
        if s[5] = 33 then NroOuverture := 64 else
        NroOuverture := 65 end else
      if s[4] = 57 then begin
        if s[5] = 63 then NroOuverture := 66 else
        if s[5] = 66 then NroOuverture := 67 else
        if s[5] = 67 then NroOuverture := 68 else
        NroOuverture := 69 end else
      if s[4] = 46 then begin
        if s[5] = 53 then NroOuverture := 70 else
        NroOuverture := 71 end else
      NroOuverture := 72 end else
    NroOuverture := 73 end else
  if s[2] = 46 then begin                           {parallele}
    if s[3] = 35 then begin
      if s[4] = 66 then begin
        if s[5] = 65 then NroOuverture := 74 else
        if s[5] = 34 then NroOuverture := 75 else
        NroOuverture := 76 end else
      if s[4] = 64 then begin
        if s[5] = 65 then NroOuverture := 77 else
        if s[5] = 36 then NroOuverture := 78 else
        NroOuverture := 79 end else
      if s[4] = 24 then begin
        if s[5] = 25 then NroOuverture := 80 else
        if s[5] = 65 then NroOuverture := 81 else
        NroOuverture := 82 end else
      if s[4] = 26 then begin
        if s[5] = 25 then NroOuverture := 83 else
        if s[5] = 65 then NroOuverture := 84 else
        NroOuverture := 85 end else
      NroOuverture := 86 end else
    NroOuverture := 87 end else
  NroOuverture := 0;

  if NroOuverture <> -1 then
    begin
      minimum := NroOuverture;
      maximum := NroOuverture;
    end;
end;

procedure IntervalleOuverture_4(var s : packed7; var minimum,maximum : SInt32);
var NroOuverture : SInt16;
begin
  NroOuverture := -1;
  if s[2] = 66 then begin                           {diagonale}
    if s[3] = 65 then begin
      if s[4] = 46 then begin
            minimum := 1;
            maximum := 27;
            end else
      NroOuverture := 28 end else
    NroOuverture := 29 end else
  if s[2] = 64 then begin                         {perpendiculaire}
    if s[3] = 53 then begin
      if s[4] = 46 then begin
            minimum := 30;
            maximum := 42;
            end else
      NroOuverture := 43 end else
    if s[3] = 33 then begin
      if s[4] = 34 then begin
            minimum := 44;
            maximum := 51;
            end else
      if s[4] = 46 then begin
            minimum := 52;
            maximum := 54;
            end else
      if s[4] = 57 then begin
            minimum := 55;
            maximum := 58;
            end else
      NroOuverture := 59 end else
    if s[3] = 43 then begin
      if s[4] = 34 then begin
          minimum := 60;
          maximum := 65;
          end else
      if s[4] = 57 then begin
          minimum := 66;
          maximum := 69;
          end else
      if s[4] = 46 then begin
          minimum := 70;
          maximum := 71;
          end else
      NroOuverture := 72 end else
    NroOuverture := 73 end else
  if s[2] = 46 then begin                           {parallele}
    if s[3] = 35 then begin
      if s[4] = 66 then begin
        minimum := 74;
        maximum := 76;
        end else
      if s[4] = 64 then begin
        minimum := 77;
        maximum := 79;
        end else
      if s[4] = 24 then begin
        minimum := 80;
        maximum := 82;
        end else
      if s[4] = 26 then begin
        minimum := 83;
        maximum := 85;
        end else
      NroOuverture := 86 end else
    NroOuverture := 87 end else
  NroOuverture := 0;

  if NroOuverture <> -1 then
    begin
      minimum := NroOuverture;
      maximum := NroOuverture;
    end;
end;

procedure IntervalleOuverture_3(var s : packed7; var minimum,maximum : SInt32);
var NroOuverture : SInt16;
begin
  NroOuverture := -1;
  if s[2] = 66 then begin                           {diagonale}
    if s[3] = 65 then begin
            minimum := 1;
            maximum := 28;
            end else
    NroOuverture := 29 end else
  if s[2] = 64 then begin                         {perpendiculaire}
    if s[3] = 53 then begin
            minimum := 30;
            maximum := 43;
            end else
    if s[3] = 33 then begin
            minimum := 44;
            maximum := 59;
            end else
    if s[3] = 43 then begin
          minimum := 60;
          maximum := 72;
          end else
    NroOuverture := 73 end else
  if s[2] = 46 then begin                           {parallele}
    if s[3] = 35 then begin
        minimum := 74;
        maximum := 86;
        end else
    NroOuverture := 87 end else
  NroOuverture := 0;

  if NroOuverture <> -1 then
    begin
      minimum := NroOuverture;
      maximum := NroOuverture;
    end;
end;


procedure IntervalleOuverture_2(var s : packed7; var minimum,maximum : SInt32);
 { donne un l'intervalle des debuts de partie dans s apres 2 coups.
   Le premier coup est supposé etre en F5}
begin
  if s[2] = 66
    then
      begin
        minimum := 1;
        maximum := 29;
      end
    else
  if s[2] = 64
    then
      begin
        minimum := 30;
        maximum := 73;
      end
    else
  if s[2] = 46
    then
      begin
        minimum := 74;
        maximum := 87;
      end
    else
      begin
        minimum := 0;
        maximum := 0;
      end;
end;

procedure DetermineIntervalleOuverture(var ouv : packed7; longueur : SInt16; var minimum,maximum : SInt32);
begin
  case longueur of
    0:begin
        minimum := 1;
        maximum := 87;
      end;
    1:begin
        minimum := 1;
        maximum := 87;
      end;
    2:IntervalleOuverture_2(ouv,minimum,maximum);
    3:IntervalleOuverture_3(ouv,minimum,maximum);
    4:IntervalleOuverture_4(ouv,minimum,maximum);
    5:IntervalleOuverture_5(ouv,minimum,maximum);
    6:IntervalleOuverture_6(ouv,minimum,maximum);
    7:begin
        minimum := NroOuverture(ouv);
        maximum := minimum;
      end;
   end;  {case}
end;




function EstDansTableOuverture(nom : String255; var nroDansTable : SInt16) : boolean;
var comment : String255;
    t,i,indexCommentaireFin,indexCommentaireDeb : SInt16;
begin
  nroDansTable := -1;
  estDansTableOuverture := false;
  if bibliothequeLisible then
    for t := 1 to nbreLignesEnBibl do
      begin
        indexCommentaireDeb := indexCommentaireBibl^^[t-1]+1;
        indexCommentaireFin := indexCommentaireBibl^^[t];
        if (indexCommentaireFin > indexCommentaireDeb)
          then
            begin
              comment := '';
              for i := indexCommentaireDeb to indexCommentaireFin do
                comment := comment+commentaireBiblEnTas^^[i];
              if comment = nom then
                begin
                  estDansTableOuverture := true;
                  nroDansTable := t;
                  exit(estDansTableOuverture);
                end;
            end;
      end;
end;


function GetPremierCoupParDefaut : SInt32;
begin
  GetPremierCoupParDefaut := premierCoupParDefautDansListe;
end;


procedure SetPremierCoupParDefaut(coup : SInt32);
begin
  if (coup = 34) | (coup = 43) | (coup = 56) | (coup = 65)
    then premierCoupParDefautDansListe := coup;
end;


procedure EffectueSymetrieAxeNW_SE(var plat : plateauOthello);
var i,j : SInt16;
    platAux : plateauOthello;
begin
  platAux := plat;
  for i := 1 to 8 do
    for j := 1 to 8 do
      plat[i+10*j] := platAux[j+10*i];
end;


procedure EffectueSymetrieAxeNE_SW(var plat : plateauOthello);
var i,j : SInt16;
    platAux : plateauOthello;
begin
  platAux := plat;
  for i := 1 to 8 do
    for j := 1 to 8 do
      plat[i+10*j] := platAux[(9-j)+10*(9-i)];
end;


function CaseSymetrique(whichSquare : SInt16; axeSymetrie : SInt32) : SInt16;
begin
  case axeSymetrie of
    central              : CaseSymetrique := 99 - whichSquare;
    axeSE_NW             : CaseSymetrique := platDiv10[whichSquare]+10*platMod10[whichSquare];
    axeSW_NE             : CaseSymetrique := 99 - (platDiv10[whichSquare]+10*platMod10[whichSquare]);
    axeVertical          : CaseSymetrique := 10*platDiv10[whichSquare]+(9-platMod10[whichSquare]);
    axeHorizontal        : CaseSymetrique := 10*(9-platDiv10[whichSquare])+platMod10[whichSquare];
    quartDeTourTrigo     : CaseSymetrique := 10*(9-platMod10[whichSquare])+platDiv10[whichSquare];
    quartDeTourAntiTrigo : CaseSymetrique := 10*platMod10[whichSquare]+(9-platDiv10[whichSquare]);
    pasDeSymetrie        : CaseSymetrique := whichSquare;
    otherwise  CaseSymetrique := whichSquare;
  end;
end;


procedure SymetriserPartieFormatThor(var s60 : PackedThorGame; axeSymetrie : SInt32; debut,fin : SInt32);
var i : SInt16;
begin
  if (debut >= 1) & (debut <= 60) & (fin >= 1) & (fin <= 60) then
	  for i := debut to fin do
	    SET_NTH_MOVE_OF_PACKED_GAME(s60, i, CaseSymetrique(GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'SymetriserPartieFormatThor'), axeSymetrie));
end;




// Cherche une symetrie à appliquer à la partie "s60" pour que, apres "numeroCoup" coups,
// elle corresponde à la position "whichPos".
// SI la fonction renvoie true, en sortie, la partie "s60" a été symetrisée
// et "axe" contient la symetrie que l'on vient d'effectuer
function TrouveSymetrieEgalisante(whichPos : plateauOthello; numeroCoup : SInt16; var s60 : PackedThorGame; var axe : SInt16) : boolean;
var aux60 : PackedThorGame;
    longueur : SInt16;

  procedure EssayerCetteSymetrie(whichSymetrie : SInt16);
  begin
    aux60 := s60;
    SymetriserPartieFormatThor(aux60, whichSymetrie,1,longueur);
    if PositionsSontEgales(whichPos,CalculePositionApres(numeroCoup,aux60)) then
      begin

        {WritelnNumDansRapport('TrouveSymetrieEgalisante = TRUE,  axe = ',whichSymetrie);}

        axe := whichSymetrie;
        s60 := aux60;
        TrouveSymetrieEgalisante := true;
        exit(TrouveSymetrieEgalisante);
      end;
  end;

begin
  TrouveSymetrieEgalisante := false;

  longueur := GET_LENGTH_OF_PACKED_GAME(s60);

  if (longueur > 0) & (numeroCoup >= 1) & (numeroCoup <= longueur) then
    begin
      EssayerCetteSymetrie(axeSE_NW);
      EssayerCetteSymetrie(axeSW_NE);
      EssayerCetteSymetrie(central);
      EssayerCetteSymetrie(pasDeSymetrie);
      EssayerCetteSymetrie(axeVertical);
      EssayerCetteSymetrie(axeHorizontal);
      EssayerCetteSymetrie(quartDeTourTrigo);
      EssayerCetteSymetrie(quartDeTourAntiTrigo);
    end;

end;


procedure SymetriserPartieFormatAlphanumerique(var s : String255; axeSymetrie : SInt32; debut,fin : SInt32);
var i,coup : SInt16;
    s1 : String255;
begin
  if (debut >= 1) & (debut <= 60) & (fin >= 1) & (fin <= 60) then
	  for i := debut to fin do
	    begin
	      coup := PositionDansStringAlphaEnCoup(s,2*i-1);
	      coup := CaseSymetrique(coup,axeSymetrie);
	      s1 := CoupEnString(coup,CharInRange(s[2*i-1],'A','H'));
	      s[2*i-1] := s1[1];
	      s[2*i]   := s1[2];
	    end;
end;


procedure EffectueSymetrieOnSquare(var whichSquare : SInt16; var axeSymetrie : SInt32; var continuer : boolean);
begin
  {$UNUSED continuer}
  whichSquare := CaseSymetrique(whichSquare,axeSymetrie);
end;


function DernierCoupEnString(enMajuscules : boolean) : String255;
var coup : SInt16;
begin
  if (nbreCoup > 0)
    then
      begin
        coup := DerniereCaseJouee;
        if InRange(coup,11,88)
          then DernierCoupEnString := CoupEnString(coup,enMajuscules)
          else DernierCoupEnString := '';
      end
    else
      DernierCoupEnString := '';
end;




function GetDernierCoup : SInt16;
begin
  if (nbreCoup > 0)
    then GetDernierCoup := DerniereCaseJouee
    else GetDernierCoup := coupInconnu;
end;


function PositionsSontEgales(const pos1,pos2 : plateauOthello) : boolean;
var i : SInt16;
begin
  for i := 11 to 88 do
    if pos1[i] <> pos2[i] then
      begin
        PositionsSontEgales := false;
        exit(PositionsSontEgales);
      end;
  PositionsSontEgales := true;
end;


function CalculePositionApres(numero : SInt16; partie60 : PackedThorGame) : plateauOthello;
var trait,i : SInt16;
    plat : plateauOthello;
    foo : boolean;
begin
  OthellierDeDepart(plat);
  trait := pionNoir;
  for i := 1 to Min(GET_LENGTH_OF_PACKED_GAME(partie60),numero) do
    begin
      if ModifPlatSeulement(GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'CalculePositionApres(1)'),plat,trait)
        then trait := -trait
        else foo := ModifPlatSeulement(GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'CalculePositionApres(1)'),plat,-trait);
    end;
  CalculePositionApres := plat;
end;


function CalculePositionEtTraitApres(var partie60 : PackedThorGame; numeroCoup : SInt16; var position : plateauOthello; var trait,nbBlanc,nbNoir : SInt32) : boolean;
var i,coup : SInt16;
begin
  CalculePositionEtTraitApres := false;
  if (GET_LENGTH_OF_PACKED_GAME(partie60) < numeroCoup)
    then exit(CalculePositionEtTraitApres);      {pas assez de coups}

  OthellierEtPionsDeDepart(position,nbNoir,nbBlanc);
  trait := pionNoir;
  for i := 1 to Min(GET_LENGTH_OF_PACKED_GAME(partie60),numeroCoup) do
    begin
      coup := GET_NTH_MOVE_OF_PACKED_GAME(partie60,i,'CalculePositionEtTraitApres(1)');
      if (coup < 11) | (coup > 88)
        then exit(CalculePositionEtTraitApres);  {coup impensable}
      if ModifPlatFin(coup,trait,position,nbBlanc,nbNoir) then trait := -trait else
      if not(ModifPlatFin(coup,-trait,position,nbBlanc,nbNoir))
        then exit(CalculePositionEtTraitApres);  {coup impossible ou game over}
    end;
  if DoitPasserPlatSeulement(trait,position) then
    begin
      trait := -trait;
      if DoitPasserPlatSeulement(trait,position)
        then exit(CalculePositionEtTraitApres);  {game over!}
     end;
  CalculePositionEtTraitApres := true;
end;


function EstLaPositionInitialeDeLaPartieEnCours(var whichPos : PositionEtTraitRec) : boolean;
var initiale : PositionEtTraitRec;
begin
  initiale := GetPositionInitialePartieEnCours;
  EstLaPositionInitialeDeLaPartieEnCours := SamePositionEtTrait(whichPos, initiale);
end;


function GetPositionInitialePartieEnCours : PositionEtTraitRec;
var numeroPremierCoup,trait,nbBlancsInitial,nbNoirsInitial : SInt32;
    jeu : plateauOthello;
begin
  GetPositionInitialeOfGameTree(jeu,numeroPremierCoup,trait,nbBlancsInitial,nbNoirsInitial);
  GetPositionInitialePartieEnCours := MakePositionEtTrait(jeu,trait);
end;


function GetPositionEtTraitPartieCouranteApresCeCoup(numeroCoup : SInt16; var typeErreur : SInt32) : PositionEtTraitRec;
var s : String255;
    partie60 : PackedThorGame;
begin
  s := PartiePourPressePapier(true,false,numeroCoup);
  TraductionAlphanumeriqueEnThor(s,partie60);
  GetPositionEtTraitPartieCouranteApresCeCoup := PositionEtTraitAfterMoveNumber(partie60,numeroCoup,typeErreur);
end;



end.





























