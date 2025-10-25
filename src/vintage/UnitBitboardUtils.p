UNIT UnitBitboardUtils;


INTERFACE


 USES UnitDefCassio;


function EmptyBitboard : bitboard;
function MakeBitboard(my_low,my_high,opp_low,opp_hi : UInt32) : bitboard;


procedure EcritBitboardDansRapport(s : String255; position : bitboard);
procedure EcritBitboardState(s : String255; position : bitboard; ESprof,alpha,beta,diffPions : SInt32);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapport, UnitRapportImplementation, MyFonts ;
{$ELSEC}
    {$I prelink/BitboardUtils.lk}
{$ENDC}


{END_USE_CLAUSE}














function EmptyBitboard : bitboard;
var result : bitboard;
begin
  with result do
    begin
      g_my_bits_low   := 0;
      g_my_bits_high  := 0;
      g_opp_bits_low  := 0;
      g_opp_bits_high := 0;
    end;
  EmptyBitboard := result;
end;

function MakeBitboard(my_low,my_high,opp_low,opp_hi : UInt32) : bitboard;
var result : bitboard;
begin
  with result do
    begin
      g_my_bits_low   := my_low;
      g_my_bits_high  := my_high;
      g_opp_bits_low  := opp_low;
      g_opp_bits_high := opp_hi;
    end;
  MakeBitboard := result;
end;


procedure EcritBitboardDansRapport(s : String255; position : bitboard);
var i,j,square : SInt32;
    v : UInt32;
    s1,s2,s3 : String255;
    estUneVraiePosition : boolean;
begin

 { On definit une vraie position comme une position ou
   les deux bitmaps dans position ne se superposent pas;
   Cela permet d'afficher ˆ droite les deux bitboard sous
   une forme compacte (plus lisible) }

  with position do
    estUneVraiePosition := (BAnd(g_my_bits_low,g_opp_bits_low) = 0) and
                           (BAnd(g_my_bits_high,g_opp_bits_high) = 0);

  ChangeFontDansRapport(MonacoID);
  WritelnDansRapport(s);
  for j := 1 to 8 do
    begin
      s1 := '';
      s2 := '';
      s3 := '';
      for i := 1 to 8 do
        begin
          square := i + j*10;
          v := othellierBitboardDescr[square].constanteHexa;
          if othellierBitboardDescr[square].isLow
            then
              begin
                if (BAnd(position.g_my_bits_low,v) = 0) and (BAnd(position.g_opp_bits_low,v) = 0)
                  then
                    begin
                      s1 := s1 + '.';
                      s2 := s2 + '.';
                      s3 := s3 + '.';
                    end
                  else
                    begin
			                if BAnd(position.g_my_bits_low,v) <> 0
			                  then
			                    begin
			                      s1 := s1 + 'X';
			                      s3 := s3 + 'X';
			                    end
			                  else s1 := s1 + '.';
			                if BAnd(position.g_opp_bits_low,v) <> 0
			                  then
			                    begin
			                      s2 := s2 + 'O';
			                      s3 := s3 + 'O';
			                    end
			                  else s2 := s2 + '.';
			              end;
              end
            else
              begin
                if (BAnd(position.g_my_bits_high,v) = 0) and (BAnd(position.g_opp_bits_high,v) = 0)
                  then
                    begin
                      s1 := s1 + '.';
                      s2 := s2 + '.';
                      s3 := s3 + '.';
                    end
                  else
                    begin
			                if BAnd(position.g_my_bits_high,v) <> 0
			                  then
			                    begin
			                      s1 := s1 + 'X';
			                      s3 := s3 + 'X';
			                    end
			                  else s1 := s1 + '.';
			                if BAnd(position.g_opp_bits_high,v) <> 0
			                  then
			                    begin
			                      s2 := s2 + 'O';
			                      s3 := s3 + 'O';
			                    end
			                  else s2 := s2 + '.';
			              end;
              end;
        end;
      if estUneVraiePosition
        then WritelnDansRapport(s1 + '      ' + s2 + '      ' + s3)
        else WritelnDansRapport(s1 + '      ' + s2);
    end;
end;

procedure EcritBitboardState(s : String255; position : bitboard; ESprof,alpha,beta,diffPions : SInt32);
begin
  SetDeroulementAutomatiqueDuRapport(true);
  WritelnDansRapport(s);
  WritelnNumDansRapport('ESProf = ',ESProf);
  WritelnNumDansRapport('diffPions = ',diffPions);
  WritelnNumDansRapport('alpha = ',alpha);
  WritelnNumDansRapport('beta = ',beta);
  EcritBitboardDansRapport('MY_BITS       OPP_BITS',position);
end;



END.
