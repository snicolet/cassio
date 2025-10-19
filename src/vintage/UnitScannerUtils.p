UNIT UnitScannerUtils;


INTERFACE


 USES UnitDefCassio;




{ Fonctions pour transformer un coup en chaine, ou trouver un coup dans une chaine }
function CoupEnStringEnMajuscules(coup : SInt16) : String255;                                                                                                                       ATTRIBUTE_NAME('CoupEnStringEnMajuscules')
function CoupEnStringEnMinuscules(coup : SInt16) : String255;                                                                                                                       ATTRIBUTE_NAME('CoupEnStringEnMinuscules')
function CoupEnString(coup : SInt16; enMajuscules : boolean) : String255;                                                                                                           ATTRIBUTE_NAME('CoupEnString')
function StringEnCoup(const s : String255) : SInt16;                                                                                                                                ATTRIBUTE_NAME('StringEnCoup')
function ScannerStringPourTrouverCoup(debutScan : SInt16; const s : String255; var positionDuCoupDansChaine : SInt16) : SInt16;                                                     ATTRIBUTE_NAME('ScannerStringPourTrouverCoup')
function PositionDansStringAlphaEnCoup(const s : String255; positionDansChaine : SInt16) : SInt16;                                                                                  ATTRIBUTE_NAME('PositionDansStringAlphaEnCoup')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}











USES
    UnitOth0;

{END_USE_CLAUSE}






function CoupEnStringEnMajuscules(coup : SInt16) : String255;
begin
  if (coup >= 11) & (coup <= 88)
    then CoupEnStringEnMajuscules := CharToString(chr(64+platMod10[coup]))+CharToString(chr(48+platDiv10[coup]))
    else CoupEnStringEnMajuscules := '';
end;

function CoupEnStringEnMinuscules(coup : SInt16) : String255;
begin
  if (coup >= 11) & (coup <= 88)
    then CoupEnStringEnMinuscules := CharToString(chr(96+platMod10[coup]))+CharToString(chr(48+platDiv10[coup]))
    else CoupEnStringEnMinuscules := '';
end;

function CoupEnString(coup : SInt16; enMajuscules : boolean) : String255;
begin
  if enMajuscules
    then CoupEnString := CoupEnStringEnMajuscules(coup)
    else CoupEnString := CoupEnStringEnMinuscules(coup);
end;


{recherche la premiere case d'Othello apparaissant dans la chaine s. Majuscules et minuscules}
function StringEnCoup(const s : String255) : SInt16;
var col,lign : char;
    k,len : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  k := 0;
  while (k < (len-1)) do
    begin
      inc(k);
      col := s[k];
      lign := s[k+1];
      if (lign >= '1') & (lign <= '8') then
        begin
          if (col >= 'A') & (col  <= 'H') then
            begin
              StringEnCoup := (ord(col)-ord('A')+1) + 10*(ord(lign)-ord('1')+1);
              exit(StringEnCoup);
            end;
          if (col >= 'a') & (col  <= 'h') then
            begin
              StringEnCoup := (ord(col)-ord('a')+1) + 10*(ord(lign)-ord('1')+1);
              exit(StringEnCoup);
            end;
        end;
    end;
  StringEnCoup := -1;  {not found}
end;

{Recherche la premiere case d'Othello apparaissant dans la chaine s. Majuscules et minuscules.}
{On renvoie dans positionDuCoupDansChaine la position o apparait ce coup dans la chaine}
function ScannerStringPourTrouverCoup(debutScan : SInt16; const s : String255; var positionDuCoupDansChaine : SInt16) : SInt16;
var col,lign : char;
    k,len : SInt16;
begin
  { Assert( debutScan >= 1 ); }
  len := LENGTH_OF_STRING(s);
  k := debutScan - 1;
  if k < 0 then k := 0;
  while (k < (len - 1)) do
    begin
      inc(k);
      col := s[k];
      lign := s[k + 1];
      if (lign >= '1') & (lign <= '8') then
        begin
          if (col >= 'A') & (col  <= 'H') then
            begin
              ScannerStringPourTrouverCoup := (ord(col) - ord('A') + 1) + 10*(ord(lign) - ord('1') + 1);
              positionDuCoupDansChaine := k;
              exit(ScannerStringPourTrouverCoup);
            end;
          if (col >= 'a') & (col  <= 'h') then
            begin
              ScannerStringPourTrouverCoup := (ord(col) - ord('a') + 1) + 10*(ord(lign) - ord('1') + 1);
              positionDuCoupDansChaine := k;
              exit(ScannerStringPourTrouverCoup);
            end;
        end;
    end;
  ScannerStringPourTrouverCoup := -1;  {not found}
  positionDuCoupDansChaine := 0;
end;


{ Renvoie la case d'Othello apparaissant a la position positionDansChaine dans la chaine s.}
{ Majuscules et minuscules. }
function PositionDansStringAlphaEnCoup(const s : String255; positionDansChaine : SInt16) : SInt16;
var col,lign : char;
    len : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  if (positionDansChaine < len) then
    begin
      col := s[positionDansChaine];
      lign := s[positionDansChaine+1];
      if (lign >= '1') & (lign <= '8') then
        begin
          if (col >= 'A') & (col  <= 'H') then
            begin
              PositionDansStringAlphaEnCoup := (ord(col)-ord('A')+1) + 10*(ord(lign)-ord('1')+1);
              exit(PositionDansStringAlphaEnCoup);
            end;
          if (col >= 'a') & (col  <= 'h') then
            begin
              PositionDansStringAlphaEnCoup := (ord(col)-ord('a')+1) + 10*(ord(lign)-ord('1')+1);
              exit(PositionDansStringAlphaEnCoup);
            end;
        end;
    end;
  PositionDansStringAlphaEnCoup := -1;  {not found}
end;





END.
