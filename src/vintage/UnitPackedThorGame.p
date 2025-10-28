UNIT UnitPackedThorGame;


INTERFACE



 USES UnitDefCassio;






{ must be a var parameter! }
function GET_ADRESS_OF_FIRST_MOVE(var whichGame : PackedThorGame) : Ptr;
function GET_ADRESS_OF_NTH_MOVE(var whichGame : PackedThorGame; n : UInt8) : Ptr;

{$ifc not packed_thor_accessors_are_macros}
function ALT_GET_LENGTH_OF_PACKED_GAME(const whichGame : PackedThorGame) : UInt8;
{$endc}
procedure SET_LENGTH_OF_PACKED_GAME(var whichGame : PackedThorGame; whichLength : UInt8);
procedure SHORTEN_PACKED_GAME(var whichGame : PackedThorGame; whichLength : UInt8);

procedure ADD_MOVE_TO_PACKED_GAME(var whichGame : PackedThorGame; whichSquare : UInt8);
procedure DESTROY_LAST_MOVE_OF_PACKED_GAME(var whichGame : PackedThorGame);

{$ifc not packed_thor_accessors_are_macros}
function ALT_GET_NTH_MOVE_OF_PACKED_GAME(const whichGame : PackedThorGame; n : UInt8; fonctionAppelante : String255) : UInt8;
procedure ALT_NTH_MOVE_OF_PACKED_GAME(var whichGame : PackedThorGame; n : UInt8; whichSquare : UInt8);
{$endc}

procedure COPY_PACKED_GAME_TO_PACKED_GAME(const source : PackedThorGame; whichLength : UInt8; var result : PackedThorGame);
procedure COPY_STR60_TO_PACKED_GAME(const s60 : String255; var result : PackedThorGame);
procedure COPY_PACKED_GAME_TO_STR60(const game : PackedThorGame; var result60 : String255);
procedure COPY_PACKED_GAME_TO_STR255(const game : PackedThorGame; var result : String255);

procedure FILL_PACKED_GAME_WITH_ZEROS(var game : PackedThorGame);

function SAME_PACKED_GAMES(const game1, game2 : PackedThorGame) : boolean;
function COMPARE_PACKED_GAMES(const game1, game2 : PackedThorGame) : SInt32;

function PACKED_GAME_IS_A_DIAGONAL(const whichGame : PackedThorGame) : boolean;

procedure WRITELN_PACKED_GAME_DANS_RAPPORT(message : String255; whichGame : PackedThorGame);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesMemoire, MyMathUtils, UnitRapport, MyStrings ;
{$ELSEC}
    {$I prelink/PackedThorGame.lk}
{$ENDC}


{END_USE_CLAUSE}











function GET_ADRESS_OF_FIRST_MOVE(var whichGame : PackedThorGame) : Ptr;
begin
  GET_ADRESS_OF_FIRST_MOVE := @whichGame.theMoves[1];
end;

function GET_ADRESS_OF_NTH_MOVE(var whichGame : PackedThorGame; n : UInt8) : Ptr;
begin
  GET_ADRESS_OF_NTH_MOVE := @whichGame.theMoves[n];
end;


{$ifc not packed_thor_accessors_are_macros}
function GET_LENGTH_OF_PACKED_GAME(const whichGame : PackedThorGame) : UInt8;
begin

  if (whichGame.theMoves[0] < 0) or (whichGame.theMoves[0] > 60) then
    begin
      WritelnStringDansRapport('WARNING : resultat out of range dans GET_LENGTH_OF_PACKED_GAME  !!');
      WritelnNumDansRapport('@ = ', SInt32(@whichGame));
      WritelnNumDansRapport('whichGame.theMoves[0] = ',whichGame.theMoves[0]);
      WRITELN_PACKED_GAME_DANS_RAPPORT('whichGame = ',whichGame);
    end;

  GET_LENGTH_OF_PACKED_GAME := whichGame.theMoves[0];
end;
{$endc}

procedure SET_LENGTH_OF_PACKED_GAME(var whichGame : PackedThorGame; whichLength : UInt8);
begin
  whichGame.theMoves[0] := whichLength;
end;

procedure SHORTEN_PACKED_GAME(var whichGame : PackedThorGame; whichLength : UInt8);
begin
  if (whichGame.theMoves[0] > whichLength)
    then whichGame.theMoves[0] := whichLength;
end;


procedure ADD_MOVE_TO_PACKED_GAME(var whichGame : PackedThorGame; whichSquare : UInt8);
begin
  inc(whichGame.theMoves[0]);
  whichGame.theMoves[whichGame.theMoves[0]] := whichSquare;
end;


procedure DESTROY_LAST_MOVE_OF_PACKED_GAME(var whichGame : PackedThorGame);
var longueur : UInt8;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(whichGame);
  if (longueur > 0) then
    SET_LENGTH_OF_PACKED_GAME(whichGame, longueur - 1);
end;


{$ifc not packed_thor_accessors_are_macros}
function GET_NTH_MOVE_OF_PACKED_GAME(const whichGame : PackedThorGame; n : UInt8; fonctionAppelante : String255 ) : UInt8;
var exceptionDeSentinelleConnue : boolean;
begin

  if (n < 1) or (n > 60) or (n > whichGame.theMoves[0]) then
    begin
      WritelnStringDansRapport('WARNING : l''index n est bizarre dans GET_NTH_MOVE_OF_PACKED_GAME  !!');
      WritelnStringDansRapport('fonction appelante = '+fonctionAppelante);
      WritelnNumDansRapport('@ = ', SInt32(@whichGame));
      WritelnNumDansRapport('n = ',n);
      WRITELN_PACKED_GAME_DANS_RAPPORT('whichGame = ',whichGame);
    end;


  exceptionDeSentinelleConnue := ((n = 1) and (whichGame.theMoves[n] = 197)) or
                                 ((n = 1) and (whichGame.theMoves[n] = 200)) or
                                 ((n = 1) and (whichGame.theMoves[n] = 230)) or
                                 ((n = 1) and (whichGame.theMoves[n] = 132)) or
                                 ((n = 1) and (whichGame.theMoves[n] = 151)) or
                                 ((n = 1) and (whichGame.theMoves[n] = 150)) or
                                 ((whichGame.theMoves[0] = 60) and (n > 0) and (n <= 60) and (whichGame.theMoves[n] = 0));

  if ((whichGame.theMoves[n] < 11) or (whichGame.theMoves[n] > 88)) and not(exceptionDeSentinelleConnue)
    then
    begin
      WritelnStringDansRapport('WARNING : resultat out of range dans GET_NTH_MOVE_OF_PACKED_GAME  !!');
      WritelnStringDansRapport('fonction appelante = '+fonctionAppelante);
      WritelnNumDansRapport('@ = ', SInt32(@whichGame));
      WritelnNumDansRapport('n = ',n);
      WritelnNumDansRapport('whichGame.theMoves[n] = ',whichGame.theMoves[n]);
      WRITELN_PACKED_GAME_DANS_RAPPORT('whichGame = ',whichGame);
    end;


  GET_NTH_MOVE_OF_PACKED_GAME := whichGame.theMoves[n];
end;



procedure SET_NTH_MOVE_OF_PACKED_GAME(var whichGame : PackedThorGame; n : UInt8; whichSquare : UInt8);
begin

  if (n < 1) or (n > 60) then
    begin
      WritelnNumDansRapport('WARNING : n out of range dans SET_NTH_MOVE_OF_PACKED_GAME  !! @ = ', SInt32(@whichGame));
      WritelnNumDansRapport('n = ',n);
      WRITELN_PACKED_GAME_DANS_RAPPORT('whichGame = ',whichGame);
    end;

  whichGame.theMoves[n] := whichSquare;
end;
{$endc}

procedure COPY_PACKED_GAME_TO_PACKED_GAME(const source : PackedThorGame; whichLength : UInt8; var result : PackedThorGame);
var i,longueur : SInt32;
begin
  longueur := Min(whichLength, source.theMoves[0]);

  result.theMoves[0] := longueur;

  for i := 1 to longueur do
    result.theMoves[i] := source.theMoves[i];
end;

procedure COPY_STR60_TO_PACKED_GAME(const s60 : String255; var result : PackedThorGame);
var longueur : SInt32;
begin
  longueur := LENGTH_OF_STRING(s60);

  result.theMoves[0] := longueur;
  MoveMemory(@s60[1], @result.theMoves[1], longueur);
end;

procedure COPY_PACKED_GAME_TO_STR60(const game : PackedThorGame; var result60 : String255);
var longueur : SInt32;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(game);
  SET_LENGTH_OF_STRING(result60,longueur);
  MoveMemory(@game.theMoves[1], @result60[1], longueur);
end;

procedure COPY_PACKED_GAME_TO_STR255(const game : PackedThorGame; var result : String255);
var longueur : SInt32;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(game);
  SET_LENGTH_OF_STRING(result,longueur);
  MoveMemory(@game.theMoves[1], @result[1], longueur);
end;


procedure FILL_PACKED_GAME_WITH_ZEROS(var game : PackedThorGame);
var i : SInt32;
begin
  for i := 0 to 60 do
    game.theMoves[i] := 0;
end;


{ Test d'egalite de deux parties. Pour gagner de la rapidite, on part de la fin. }
function SAME_PACKED_GAMES(const game1, game2 : PackedThorGame) : boolean;
var i,len : SInt32;
begin
  if (game1.theMoves[0] <> game2.theMoves[0])
    then
      begin  { pas la meme longueur }
        SAME_PACKED_GAMES := false;
        exit;
      end
    else
      begin
        len := game1.theMoves[0];
        for i := len downto 0 do
          if (game1.theMoves[i] <> game2.theMoves[i]) then
            begin
              SAME_PACKED_GAMES := false;
              exit;
            end
      end;
  SAME_PACKED_GAMES := true;
end;

{ Comparaison lexicagraphique de deux parties.
  Renvoie :  -1   si  game1 < game2
             0    si  game1 = game2
             1    si  game1 > game2
 }
function COMPARE_PACKED_GAMES(const game1, game2 : PackedThorGame) : SInt32;
var i,len1,len2, len : SInt32;
    coup1, coup2 : SInt32;
begin
  len1 := game1.theMoves[0];
  len2 := game2.theMoves[0];

  if (len1 = 0) and (len2 = 0) then
    begin
      COMPARE_PACKED_GAMES :=  0;
      exit;
    end;

  if (len1 = 0) then
    begin
      COMPARE_PACKED_GAMES := -1;
      exit;
    end;

  if (len2 = 0) then
    begin
      COMPARE_PACKED_GAMES := +1;
      exit;
    end;

  len := Min(len1,len2);

  for i := 1 to len do
    begin
      coup1 := game1.theMoves[i];
      coup2 := game2.theMoves[i];

      if (coup1 < coup2) then
        begin
          COMPARE_PACKED_GAMES := -1;
          exit;
        end;

      if (coup1 > coup2) then
        begin
          COMPARE_PACKED_GAMES := +1;
          exit;
        end;
    end;

  if (len1 = len2) then
    begin
      COMPARE_PACKED_GAMES := 0;
      exit;
    end;

  if (len1 < len2) then
    begin
      COMPARE_PACKED_GAMES := -1;
      exit;
    end;

  if (len1 > len2) then
    begin
      COMPARE_PACKED_GAMES := +1;
      exit;
    end;
end;


function PACKED_GAME_IS_A_DIAGONAL(const whichGame : PackedThorGame) : boolean;
begin
  if (GET_NTH_MOVE_OF_PACKED_GAME(whichGame,1, 'LectureSurCriteres(1)') = 56) and  { F5F6E6F4 ? }
     (GET_NTH_MOVE_OF_PACKED_GAME(whichGame,2, 'LectureSurCriteres(2)') = 66) and
     (GET_NTH_MOVE_OF_PACKED_GAME(whichGame,3, 'LectureSurCriteres(3)') = 65) and
     (GET_NTH_MOVE_OF_PACKED_GAME(whichGame,4, 'LectureSurCriteres(4)') = 46)
     then PACKED_GAME_IS_A_DIAGONAL := true
     else PACKED_GAME_IS_A_DIAGONAL := false;
end;

procedure WRITELN_PACKED_GAME_DANS_RAPPORT(message : String255; whichGame : PackedThorGame);
var len,i,coup  : SInt32;
begin
  len := whichGame.theMoves[0];

  WriteStringDansRapport(message);
  WriteNumDansRapport(' (len = ',len);
  WritelnStringDansRapport(' )');
  for i := 1 to len do
    begin
      coup := whichGame.theMoves[i];
      WriteNumDansRapport(IntToStr(i) + ':',i);
      WriteNumDansRapport(' => ',coup);
      WritelnStringAndCoupDansRapport(' , ',coup);
    end;
  WritelnDansRapport('');
  WritelnDansRapport('');
end;


END.






























