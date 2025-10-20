UNIT UnitMetaphone;




INTERFACE


USES MyTypes;




procedure MakeDoubleMetaphone(original : String255; var primary,secondary : String255);
function FabriqueMetaphoneDesLexemes(original : String255) : String255;




procedure TestUnitDoubleMetaphone;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitServicesMemoire, MyStrings ;
{$ELSEC}
    ;
    {$I prelink/Metaphone.lk}
{$ENDC}


{END_USE_CLAUSE}



type arrayOfArrayOfChar = array[0..1] of PackedArrayOfCharPtr;

var primaryBuffer   : packed array[0..255] of char;
    secondaryBuffer : packed array[0..255] of char;


{ Traduction en Pascal des typages des fonctions C de double_metaphone.c }
procedure DoubleMetaphone(str : charP; var codes : arrayOfArrayOfChar);              EXTERNAL_NAME('DoubleMetaphone');



procedure MakeDoubleMetaphone(original : String255; var primary,secondary : String255);
var original255 : str255;
    codes : arrayOfArrayOfChar;
    i : SInt32;
    c : char;
begin


  original255 := StringToStr255(original + chr(0));


  primaryBuffer[0]   := chr(0);
  secondaryBuffer[0] := chr(0);

  codes[0] := @primaryBuffer;
  codes[1] := @secondaryBuffer;

  {$ifc defined __GPC__ }
   DoubleMetaphone(@original255.sChars[1], codes);
  {$elsec}
   DoubleMetaphone(@original255[1], codes);
  {$endc}


  primary := '';
  secondary := '';

  i := 0;
  while (i < 255) do
    begin
      c := codes[0]^[i];
      if (c = char(0))
        then leave
        else primary := primary + c;
      inc(i);
    end;

  i := 0;
  while (i < 255) do
    begin
      c := codes[1]^[i];
      if (c = char(0))
        then leave
        else secondary := secondary + c;
      inc(i);
    end;

  (*
  WritelnDansRapport('original = ' + original);
  WritelnDansRapport('primary = ' + primary);
  WritelnDansRapport('secondary = ' + secondary);
  *)

end;


function FabriqueMetaphoneDesLexemes(original : String255) : String255;
var nbLexemes, compteurBoucle : SInt32;
    lexeme, reste, primary, secondary, resultat : String255;
begin

  reste := original;
  nbLexemes := 0;
  compteurBoucle := 0;

  resultat := '';

  repeat
    Parser(reste, lexeme, reste);
    if (lexeme <> '') then
      begin
        inc(nbLexemes);
        MakeDoubleMetaphone(lexeme,primary, secondary);
        if nbLexemes >= 2 then resultat := resultat + ' ';
        resultat := resultat + secondary;
      end;
    inc(compteurBoucle);
  until (reste = '') | (nbLexemes >= 200) | (compteurBoucle > 255);

  FabriqueMetaphoneDesLexemes := resultat;
end;


procedure TestUnitDoubleMetaphone;
var s1,s2 : String255;
begin


  MakeDoubleMetaphone('Alexander',s1,s2);
  MakeDoubleMetaphone('Aleksander',s1,s2);
  MakeDoubleMetaphone('Alexandre',s1,s2);

  MakeDoubleMetaphone('Cluson Gilles',s1,s2);
  MakeDoubleMetaphone('Cluzon Gille',s1,s2);

  MakeDoubleMetaphone('Tatuya Mine',s1,s2);
  MakeDoubleMetaphone('Tatsuja Mine',s1,s2);

  MakeDoubleMetaphone('Takuji Kashiwabara',s1,s2);
  MakeDoubleMetaphone('Takuji Kashiwabara',s1,s2);

  MakeDoubleMetaphone('Andersson Kristoff',s1,s2);
  MakeDoubleMetaphone('Anderson Kristoph',s1,s2);



  MakeDoubleMetaphone('maurice',s1,s2);
  MakeDoubleMetaphone('aubrey',s1,s2);
  MakeDoubleMetaphone('cambrillo',s1,s2);
  MakeDoubleMetaphone('heidi',s1,s2);
  MakeDoubleMetaphone('katherine',s1,s2);
  MakeDoubleMetaphone('catherine',s1,s2);
  MakeDoubleMetaphone('richard',s1,s2);
  MakeDoubleMetaphone('bob',s1,s2);
  MakeDoubleMetaphone('eric',s1,s2);
  MakeDoubleMetaphone('geoff',s1,s2);
  MakeDoubleMetaphone('dave',s1,s2);
  MakeDoubleMetaphone('ray',s1,s2);
  MakeDoubleMetaphone('steven',s1,s2);
  MakeDoubleMetaphone('bryce',s1,s2);
  MakeDoubleMetaphone('randy',s1,s2);
  MakeDoubleMetaphone('bryan',s1,s2);
  MakeDoubleMetaphone('brian',s1,s2);
  MakeDoubleMetaphone('otto',s1,s2);
  MakeDoubleMetaphone('auto',s1,s2);



end;



END.

