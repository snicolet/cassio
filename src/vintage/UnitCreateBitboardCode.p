UNIT UnitCreateBitboardCode;



INTERFACE









procedure InitUnitCreateBitboardCode;
procedure CreateJansEndgameCode(C_language : boolean);

IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDefCassio, Sound
{$IFC NOT(USE_PRELINK)}
    , UnitScannerUtils, UnitStrategie, UnitRapport, UnitBitboardUtils, UnitBitboardModifPlat, MyStrings
    , basicfile, MyMathUtils ;
{$ELSEC}
    ;
    {$I prelink/CreateBitboardCode.lk}
{$ENDC}


{END_USE_CLAUSE}










const
   _MY_BITS_  = 1;
   _OPP_BITS_ = 2;

type
  JanSquareSet = set of 0..63;




var
  margeBitboardCode : String255;
  niveauDeLaMarge : SInt16;
  powers3 : array[0..10] of SInt32;

procedure InitPowers3;
var i : SInt16;
begin
  powers3[0] := 1;
  for i := 1 to 10 do
    powers3[i] := 3*powers3[i-1];
end;

procedure InitOthellierBitboardDescritor;
var i,col,row : SInt16;
    col_value : array[1..8] of SInt32;
    row_value : array[1..8] of SInt32;
begin

  col_value[1] := $00000001;
  col_value[2] := $00000002;
  col_value[3] := $00000004;
  col_value[4] := $00000008;
  col_value[5] := $00000010;
  col_value[6] := $00000020;
  col_value[7] := $00000040;
  col_value[8] := $00000080;

  row_value[1] := $00000001;
  row_value[2] := $00000100;
  row_value[3] := $00010000;
  row_value[4] := $01000000;
  row_value[5] := $00000001;
  row_value[6] := $00000100;
  row_value[7] := $00010000;
  row_value[8] := $01000000;


  for i := 0 to 99 do
    with othellierBitboardDescr[i] do
	    begin
	      if i <= 49
	        then
	          begin
	            isLow  := true;
	            isHigh := false;
	          end
	        else
	          begin
	            isLow  := false;
	            isHigh := true;
	          end;
	      col := i mod 10;
	      row := i div 10;
	      if (col >= 1) and (col <= 8) and (row  >= 1) and (row  <= 8)
	        then constanteHexa := col_value[col]*row_value[row]
	        else constanteHexa := 0;
	    end;
end;

function BitboardName(color : SInt16; isLow : boolean) : String255;
begin
  case color of
    _MY_BITS_ :
      if isLow
        then BitboardName := 'my_bits_low'
        else BitboardName := 'my_bits_high';
    _OPP_BITS_ :
      if isLow
        then BitboardName := 'opp_bits_low'
        else BitboardName := 'opp_bits_high';
  end;
end;


procedure AddToBitboard(square,color : SInt16; var theBitboard : bitboard);
begin
  with othellierBitboardDescr[square],theBitboard do
    begin
		  case color of
		    _MY_BITS_ :
		      if isLow
		        then g_my_bits_low   := BOR(SInt32(g_my_bits_low),SInt32(constanteHexa))
		        else g_my_bits_high  := BOR(SInt32(g_my_bits_high),SInt32(constanteHexa));
		    _OPP_BITS_ :
		      if isLow
		        then g_opp_bits_low  := BOR(SInt32(g_opp_bits_low),SInt32(constanteHexa))
		        else g_opp_bits_high := BOR(SInt32(g_opp_bits_high),SInt32(constanteHexa));
		  end; {case}
  end;
end;



function StringToJanSquare(s : String255) : SInt16;
var col,line : SInt16;
begin
  col  := ord(s[1]) - ord('a');
  line := ord(s[2]) - ord('1');
  if (line >= 0) and (line <= 7) and (col >= 0) and (col <= 7)
    then StringToJanSquare := col + 8*line
    else SysBeep(0);
end;


function JanSquareToString(square : SInt16) : String255;
var col,line : SInt16;
begin
  line := square div 8;
  col  := square mod 8;
  JanSquareToString := Concat(chr(ord('a')+col) , chr(ord('1')+line));
end;


function JanSquareToCassioSquare(square : SInt16) : SInt16;
begin
  JanSquareToCassioSquare := StringEnCoup(JanSquareToString(square));
end;




const
  _INT_  = 1;
  _VOID_ = 2;

var
  generatingPascal : boolean;
  fichierCodeGenere : basicfile;


procedure WritelnDansFichierEndgame(s : String255);
var err : OSErr;
begin {$UNUSED err}
  {WritelnDansRapport(margeBitboardCode+s);}
  err := Writeln(fichierCodeGenere,margeBitboardCode+s);
end;

procedure WriteDansFichierEndgame(s : String255);
var err : OSErr;
begin {$UNUSED err}
  {WriteDansRapport(margeBitboardCode+s);}
  err := Write(fichierCodeGenere,margeBitboardCode+s);
end;

procedure WritelnSansMargeDansFichierEndgame(s : String255);
var err : OSErr;
begin {$UNUSED err}
  err := Writeln(fichierCodeGenere,s);
end;

procedure WriteSansMargeDansFichierEndgame(s : String255);
var err : OSErr;
begin {$UNUSED err}
  err := Write(fichierCodeGenere,s);
end;

procedure WritelnCommentaireDansFichierEndgame(s : String255);
var err : OSErr;
begin {$UNUSED err}
  (* WritelnDansRapport(' { '+s+' }'); *)
  err := Writeln(fichierCodeGenere,' { '+s+' }');
end;

procedure WriteCommentaireDansFichierEndgame(s : String255);
var err : OSErr;
begin {$UNUSED err}
  (* WriteDansRapport(' { '+s+' }'); *)
  err := Write(fichierCodeGenere,' { '+s+' }');
end;

function CreateFunctionLine(whichName : String255; whichType : SInt16) : String255;
var s : String255;
begin
  s := '';
  if generatingPascal
    then
      begin
        case whichType of
          _INT_  : s := 'function '+ whichName + '(JanData:JanDataRecPtr) : SInt32;';
          _VOID_ : s := 'procedure '+ whichName + '(JanData:JanDataRecPtr);';
        end;
      end
    else
      begin
        case whichType of
          _INT_  : s := 'int ' + whichName + '';
          _VOID_ : s := 'void ' + whichName + '';
        end;
      end;
  CreateFunctionLine := s;
end;

function CreateFunctionCall(whichName : String255) : String255;
var s : String255;
begin
  s := '';
  if generatingPascal
    then
      begin
        s := whichName + '(JanData)';
      end
    else
      begin
        s := '(*' + whichName + ')';
      end;
  CreateFunctionCall := s;
end;

procedure WriteFunctionLine(whichName : String255; whichType : SInt16);
var s : String255;
begin
  s := CreateFunctionLine(whichName,whichType);
  WritelnDansFichierEndgame(s);
end;

procedure WriteFunctionCall(whichName : String255);
var s : String255;
begin
  s := '  ' + CreateFunctionCall(whichName) + ';';
  WritelnDansFichierEndgame(s);
end;

procedure WriteBeginDebutFonction;
begin
  if generatingPascal
    then
      begin
        WritelnDansFichierEndgame('begin');
        WritelnDansFichierEndgame('  with JanData^ do');
        WritelnDansFichierEndgame('    begin');
        margeBitboardCode := '    ';
      end
    else WritelnDansFichierEndgame('{');
end;

procedure WriteEndFinFonction;
begin
  if generatingPascal
    then
      begin
        margeBitboardCode := '';
        WritelnDansFichierEndgame('    end; {with}');
        WritelnDansFichierEndgame('end;');
      end
    else WritelnDansFichierEndgame('}');
end;

procedure WriteBegin;
begin
  if generatingPascal
    then WritelnDansFichierEndgame('begin')
    else WritelnDansFichierEndgame('{');
end;

procedure WriteEnd;
begin
  if generatingPascal
    then WritelnDansFichierEndgame('end;')
    else WritelnDansFichierEndgame('}');
end;

procedure WriteEndSansPointVirgule;
begin
  if generatingPascal
    then WritelnDansFichierEndgame('end')
    else WritelnDansFichierEndgame('}');
end;



procedure WriteAffectation(variableName,rightSide : String255);
begin
  if generatingPascal
    then WritelnDansFichierEndgame('  ' + variableName + ' := ' + rightSide + ';')
    else WritelnDansFichierEndgame('  ' + variableName + ' = ' + rightSide + ';');
end;

procedure WriteReturns(whichName,result : String255);
begin
  if generatingPascal
    then WritelnDansFichierEndgame('  ' + whichName + ' := ' + result + ';')
    else WritelnDansFichierEndgame('  return ' + result + ';')
end;

procedure WriteNewLine;
begin
  WritelnDansFichierEndgame('');
end;

function ArrayReference(s : String255) : String255;
begin
  ArrayReference := Concat('[',s,']');
end;

function IntegerReference(num : SInt32) : String255;
begin
  IntegerReference := ArrayReference(IntToStr(num));
end;

function CreatePlusEgal(variable,increment : String255) : String255;
begin
  if generatingPascal
    then CreatePlusEgal := variable + ' := ' + variable + ' + ' + increment + ';'
    else CreatePlusEgal := variable + ' += ' + increment + ';';
end;

function CreateMoinsEgal(variable,decrement : String255) : String255;
begin
  if generatingPascal
    then CreateMoinsEgal := variable + ' := ' + variable + ' - ' + decrement + ';'
    else CreateMoinsEgal := variable + ' -= ' + decrement + ';';
end;

procedure WritePlusEgal(variable,increment : String255);
begin
  WritelnDansFichierEndgame('  ' + CreatePlusEgal(variable,increment));
end;

procedure WriteMoinsEgal(variable,increment : String255);
begin
  WritelnDansFichierEndgame('  ' + CreateMoinsEgal(variable,increment));
end;



procedure WriteIncrementation(variable : String255);
begin
  if generatingPascal
    then WritelnDansFichierEndgame('  inc(' + variable + ');')
    else WritelnDansFichierEndgame('  ' + variable + '++;');
end;

procedure WriteDecrementation(variable : String255);
begin
  if generatingPascal
    then WritelnDansFichierEndgame('  dec(' + variable + ');')
    else WritelnDansFichierEndgame('  ' + variable + '--;');
end;

procedure WriteIf(test : String255; thenSurLaMemeLigne : boolean);
begin
  if generatingPascal
    then
      begin
        if thenSurLaMemeLigne
          then
            WriteDansFichierEndgame('  if (' + test + ') then')
          else
            begin
              WritelnDansFichierEndgame('  if (' + test + ')');
              WriteDansFichierEndgame('    then');
            end;
      end
    else
      WriteDansFichierEndgame('  if (' + test + ')');
end;

procedure WritelnIf(test : String255; thenSurLaMemeLigne : boolean);
begin
  WriteIf(test,thenSurLaMemeLigne);
  WritelnDansFichierEndgame('');
end;


procedure WriteElse;
begin
  if generatingPascal
    then WriteDansFichierEndgame('    else')
    else WriteDansFichierEndgame('  else');
end;

procedure WritelnElse;
begin
  WriteElse;
  WritelnDansFichierEndgame('');
end;


procedure WriteWith(s : String255);
begin
  WritelnDansFichierEndgame('  with ' + s + ' do begin');
end;

procedure WriteEndWith;
begin
  WritelnDansFichierEndgame('  end; {with}');
end;






procedure WriteTestEnnemi(square,couleurAdversaire : SInt16);
var s1,s2 : String255;
begin
  s1 := BitboardName(couleurAdversaire,othellierBitboardDescr[square].isLow);
  s2 := Hexa(othellierBitboardDescr[square].constanteHexa);
  WriteDansFichierEndgame('if BAND('+s1+','+s2+') <> 0 then');
  case couleurAdversaire of
    _OPP_BITS_ : WritelnCommentaireDansFichierEndgame('if plat['+CoupEnString(square,true)+'] = adversaire then');
    _MY_BITS_ : WritelnCommentaireDansFichierEndgame('if plat['+CoupEnString(square,true)+'] = couleur then');
  end;
end;

procedure WriteTestAmi(square,couleur : SInt16);
var s1,s2 : String255;
begin
  s1 := BitboardName(couleur,othellierBitboardDescr[square].isLow);
  s2 := Hexa(othellierBitboardDescr[square].constanteHexa);
  WriteDansFichierEndgame('if BAND('+s1+','+s2+') <> 0 then');
  case couleur of
    _OPP_BITS_ : WritelnCommentaireDansFichierEndgame('if plat['+CoupEnString(square,true)+'] = adversaire then');
    _MY_BITS_ : WritelnCommentaireDansFichierEndgame('if plat['+CoupEnString(square,true)+'] = couleur then');
  end;
end;

procedure WriteBitboardFlip(flippedDiscs : bitboard);
var s1,s2 : String255;
begin
  if flippedDiscs.g_opp_bits_low <> 0 then
    begin
      s1 := Hexa(flippedDiscs.g_opp_bits_low);
      s2 := BitboardName(_MY_BITS_,true);
      WritelnDansFichierEndgame(s2 + ' := BOR(' + s2 + ',' + s1 + ');');
      s2 := BitboardName(_OPP_BITS_,true);
      WritelnDansFichierEndgame(s2 + ' := BXOR(' + s2 + ',' + s1 + ');');
    end;
  if flippedDiscs.g_opp_bits_high <> 0 then
    begin
      s1 := Hexa(flippedDiscs.g_opp_bits_high);
      s2 := BitboardName(_MY_BITS_,false);
      WritelnDansFichierEndgame(s2 + ' := BOR(' + s2 + ',' + s1 + ');');
      s2 := BitboardName(_OPP_BITS_,false);
      WritelnDansFichierEndgame(s2 + ' := BXOR(' + s2 + ',' + s1 + ');');
    end;
end;

procedure FabriqueMarge(niveauDeLaMarge : SInt16);
var i : SInt16;
begin
  margeBitboardCode := '';
  for i := 1 to niveauDeLaMarge do
    margeBitboardCode := margeBitboardCode + '  ';
end;

procedure SetNiveauMarge(niveau : SInt16);
begin
  niveauDeLaMarge := niveau;
  FabriqueMarge(niveauDeLaMarge);
end;

procedure IncrementeMarge;
begin
  niveauDeLaMarge := niveauDeLaMarge + 1;
  FabriqueMarge(niveauDeLaMarge);
end;

procedure DecrementeMarge;
begin
  niveauDeLaMarge := niveauDeLaMarge - 1;
  if niveauDeLaMarge < 0 then niveauDeLaMarge := 0;
  FabriqueMarge(niveauDeLaMarge);
end;

procedure WritePlusEgalBitboard(variable,increment : String255);
begin
  WritelnDansFichierEndgame(variable+' := '+ variable + ' + '+increment+';');
end;

procedure CreateBitBoardFlipsOfSquareThisDirection(square,dx : SInt16; generatingDernierCoup,generatingCoupLegal : boolean; couleur,couleurAdversaire : SInt16);
var x1,x2,x3,x4,x5,x6 : SInt32;
    othellierVide : plateauOthello;
    flippedDiscs : bitboard;
begin

   VideOthellier(othellierVide);

   x1 := square+dx;
   WriteTestEnnemi(x1,couleurAdversaire);{1}
   IncrementeMarge;
     begin
       WriteBegin;
       IncrementeMarge;
       x2 := x1+dx;

       if othellierVide[x2+dx] <> PionInterdit then
         BEGIN


		       WriteTestEnnemi(x2,couleurAdversaire);  {2}
		       IncrementeMarge;
		       begin
		         WriteBegin;
		         IncrementeMarge;
		         x3 := x2+dx;

		         if othellierVide[x3+dx] <> PionInterdit then
               BEGIN



				         WriteTestEnnemi(x3,couleurAdversaire);  {3}
				         IncrementeMarge;
				           begin
				             WriteBegin;
				             IncrementeMarge;
				             x4 := x3+dx;

				             if othellierVide[x4+dx] <> PionInterdit then
		                   BEGIN

						             WriteTestEnnemi(x4,couleurAdversaire); {4}
						             IncrementeMarge;
								           begin
								             WriteBegin;
								             IncrementeMarge;
								             x5 := x4+dx;

								             if othellierVide[x5+dx] <> PionInterdit then
				                       BEGIN

										             WriteTestEnnemi(x5,couleurAdversaire);  {5}
										             IncrementeMarge;
												           begin
												             WriteBegin;
												             IncrementeMarge;
												             x6 := x5+dx;

												             if othellierVide[x6+dx] <> PionInterdit then
						                           BEGIN

														             WriteTestEnnemi(x6,couleurAdversaire);  {6}
														             IncrementeMarge;
														               begin
																             WriteBegin;
																             IncrementeMarge;
																             WriteTestAmi(x6+dx,couleur);  {seul cas à tester}
																             IncrementeMarge;
																             if generatingCoupLegal
														                   then
														                     WritelnDansFichierEndgame('goto LeCoupEstLegal')
														                   else
																	              begin
																	               if not(generatingDernierCoup) then WriteBegin;
																	               IncrementeMarge;
																	               WritePlusEgalBitboard('nbPrise','12');
																	               if not(generatingDernierCoup) then
																	                 begin
																	                   flippedDiscs := EmptyBitboard;
																			               AddToBitboard(x6,_OPP_BITS_,flippedDiscs);
																			               AddToBitboard(x5,_OPP_BITS_,flippedDiscs);
																			               AddToBitboard(x4,_OPP_BITS_,flippedDiscs);
																			               AddToBitboard(x3,_OPP_BITS_,flippedDiscs);
																			               AddToBitboard(x2,_OPP_BITS_,flippedDiscs);
																			               AddToBitboard(x1,_OPP_BITS_,flippedDiscs);
																			               WriteBitboardFlip(flippedDiscs);
																			             end;
																	               DecrementeMarge;
																	               if not(generatingDernierCoup) then WriteEnd;
																	              end;
																	           DecrementeMarge;
																	           DecrementeMarge;
																	           WriteEndSansPointVirgule;
																           end;
																         DecrementeMarge;
																         WritelnDansFichierEndgame('else');

														           END; {if othellierVide[x6+dx] <> PionInterdit}

														           WriteTestAmi(x6,couleur);
														           IncrementeMarge;
														           if generatingCoupLegal
														             then
														               WritelnDansFichierEndgame('goto LeCoupEstLegal')
														             else
														              begin
														               if not(generatingDernierCoup) then WriteBegin;
														               IncrementeMarge;
														               WritePlusEgalBitboard('nbPrise','10');
														               if not(generatingDernierCoup) then
																	           begin
																	             flippedDiscs := EmptyBitboard;
																               AddToBitboard(x5,_OPP_BITS_,flippedDiscs);
																               AddToBitboard(x4,_OPP_BITS_,flippedDiscs);
																               AddToBitboard(x3,_OPP_BITS_,flippedDiscs);
																               AddToBitboard(x2,_OPP_BITS_,flippedDiscs);
																               AddToBitboard(x1,_OPP_BITS_,flippedDiscs);
																               WriteBitboardFlip(flippedDiscs);
																             end;
														               DecrementeMarge;
														               if not(generatingDernierCoup) then WriteEnd;
														              end;
														         DecrementeMarge;
														         DecrementeMarge;
														         WriteEndSansPointVirgule;
												           end;
												         DecrementeMarge;
												         WritelnDansFichierEndgame('else');

										           END; {if othellierVide[x5+dx] <> PionInterdit}

										           WriteTestAmi(x5,couleur);
										           IncrementeMarge;
										           if generatingCoupLegal
														     then
														       WritelnDansFichierEndgame('goto LeCoupEstLegal')
														     else
										              begin
										               if not(generatingDernierCoup) then WriteBegin;
										               IncrementeMarge;
										               WritePlusEgalBitboard('nbPrise','8');
										               if not(generatingDernierCoup) then
																	   begin
																	     flippedDiscs := EmptyBitboard;
										                   AddToBitboard(x4,_OPP_BITS_,flippedDiscs);
										                   AddToBitboard(x3,_OPP_BITS_,flippedDiscs);
										                   AddToBitboard(x2,_OPP_BITS_,flippedDiscs);
										                   AddToBitboard(x1,_OPP_BITS_,flippedDiscs);
										                   WriteBitboardFlip(flippedDiscs);
										                 end;
										               DecrementeMarge;
										               if not(generatingDernierCoup) then WriteEnd;
										              end;
										         DecrementeMarge;
										         DecrementeMarge;
										         WriteEndSansPointVirgule;
								           end;
								         DecrementeMarge;
						             WritelnDansFichierEndgame('else');

				               END; {if othellierVide[x4+dx] <> PionInterdit}


						           WriteTestAmi(x4,couleur);
						           IncrementeMarge;
						           if generatingCoupLegal
												 then
													 WritelnDansFichierEndgame('goto LeCoupEstLegal')
												 else
						              begin
						               if not(generatingDernierCoup) then WriteBegin;
						               IncrementeMarge;
						               WritePlusEgalBitboard('nbPrise','6');
						               if not(generatingDernierCoup) then
														 begin
															 flippedDiscs := EmptyBitboard;
						                   AddToBitboard(x3,_OPP_BITS_,flippedDiscs);
						                   AddToBitboard(x2,_OPP_BITS_,flippedDiscs);
						                   AddToBitboard(x1,_OPP_BITS_,flippedDiscs);
						                   WriteBitboardFlip(flippedDiscs);
						                 end;
						               DecrementeMarge;
						               if not(generatingDernierCoup) then WriteEnd;
						              end;
						         DecrementeMarge;
						         DecrementeMarge;
						         WriteEndSansPointVirgule;
				           end;
				         DecrementeMarge;
				         WritelnDansFichierEndgame('else');

		           END; {if othellierVide[x3+dx] <> PionInterdit}

		           WriteTestAmi(x3,couleur);
		           IncrementeMarge;
		           if generatingCoupLegal
								 then
									 WritelnDansFichierEndgame('goto LeCoupEstLegal')
								 else
		              begin
		               if not(generatingDernierCoup) then WriteBegin;
		               IncrementeMarge;
		               WritePlusEgalBitboard('nbPrise','4');
		               if not(generatingDernierCoup) then
										 begin
											 flippedDiscs := EmptyBitboard;
		                   AddToBitboard(x2,_OPP_BITS_,flippedDiscs);
		                   AddToBitboard(x1,_OPP_BITS_,flippedDiscs);
		                   WriteBitboardFlip(flippedDiscs);
		                 end;
		               DecrementeMarge;
		               if not(generatingDernierCoup) then WriteEnd;
		              end;
		         DecrementeMarge;
		         DecrementeMarge;
		         WriteEndSansPointVirgule;
		       end;
		     DecrementeMarge;
		     WritelnDansFichierEndgame('else');

       END;  {if othellierVide[x2+dx] <> PionInterdit}


       WriteTestAmi(x2,couleur);
       IncrementeMarge;
       if generatingCoupLegal
				 then
					 WritelnDansFichierEndgame('goto LeCoupEstLegal')
				 else
          begin
           if not(generatingDernierCoup) then WriteBegin;
           IncrementeMarge;
           WritePlusEgalBitboard('nbPrise','2');
           if not(generatingDernierCoup) then
						 begin
							 flippedDiscs := EmptyBitboard;
               AddToBitboard(x1,_OPP_BITS_,flippedDiscs);
               WriteBitboardFlip(flippedDiscs);
             end;
           DecrementeMarge;
           if not(generatingDernierCoup) then WriteEnd;
          end;
      DecrementeMarge;
      DecrementeMarge;
      WriteEnd;
    end;
    DecrementeMarge;
end;

procedure CreateCoupLegalParAdditionBitBoard(square,dx : SInt16; couleur,couleurAdversaire : SInt16);
var premierPionRetourne,pionsDAppelPossibles : bitboard;
    othellierVide : plateauOthello;
    x : SInt32;
    s1,s2,s3,s4 : String255;
begin
  VideOthellier(othellierVide);
  if dx = +1 then
    begin
      premierPionRetourne := EmptyBitboard;
      AddToBitboard(square+dx,_OPP_BITS_,premierPionRetourne);

      pionsDAppelPossibles := EmptyBitboard;
      x := square + dx + dx;
      while othellierVide[x] <> PionInterdit do
        begin
          AddToBitboard(x,_MY_BITS_,pionsDAppelPossibles);
          x := x + dx;
        end;

      if othellierBitboardDescr[square].isLow
        then
          begin
            s1 := Hexa(premierPionRetourne.g_opp_bits_low);
            s2 := BitboardName(couleurAdversaire,true);
            s3 := Hexa(pionsDAppelPossibles.g_my_bits_low);
            s4 := BitboardName(couleur,true);
            WritelnDansFichierEndgame('if BAND('+s2+'+'+s1+',BAND('+s4+','+s3+')) <> 0 then goto LeCoupEstLegal;');
          end
        else
          begin
            s1 := Hexa(premierPionRetourne.g_opp_bits_high);
            s2 := BitboardName(couleurAdversaire,false);
            s3 := Hexa(pionsDAppelPossibles.g_my_bits_high);
            s4 := BitboardName(couleur,false);
            WritelnDansFichierEndgame('if BAND('+s2+'+'+s1+',BAND('+s4+','+s3+')) <> 0 then goto LeCoupEstLegal;');
          end;

    end;

  if dx = -1 then
    begin
      premierPionRetourne := EmptyBitboard;
      AddToBitboard(square+dx,_OPP_BITS_,premierPionRetourne);

      pionsDAppelPossibles := EmptyBitboard;
      x := square + dx + dx;
      while othellierVide[x] <> PionInterdit do
        begin
          AddToBitboard(x,_MY_BITS_,pionsDAppelPossibles);
          x := x + dx;
        end;

      if othellierBitboardDescr[square].isLow
        then
          begin
            s1 := Hexa(premierPionRetourne.g_opp_bits_low);
            s2 := BitboardName(couleurAdversaire,true);
            s4 := BitboardName(couleur,true);
            WritelnDansFichierEndgame('if BAND(BSR('+s2+',1)+'+s4+',BAND('+s2+','+s1+')) <> 0 then goto LeCoupEstLegal;');
          end
        else
          begin
            s1 := Hexa(premierPionRetourne.g_opp_bits_high);
            s2 := BitboardName(couleurAdversaire,false);
            s4 := BitboardName(couleur,false);
            WritelnDansFichierEndgame('if BAND(BSR('+s2+',1)+'+s4+',BAND('+s2+','+s1+')) <> 0 then goto LeCoupEstLegal;');
          end;

    end;
end;


procedure CreateModifPlatBitboardOfSquare(square : SInt16);
var dx,t,nbreDirectionDePrise : SInt32;
    s1,s2,s3 : String255;
begin
  SetNiveauMarge(4);
  WritelnDansFichierEndgame(IntToStr(square)+ ' :    { ' + CoupEnString(square,true) + ' }');
  IncrementeMarge;
  WriteBegin;
  IncrementeMarge;

  nbreDirectionDePrise := 0;
  for t := dirPriseDeb[square] to dirPriseFin[square] do
    begin
      inc(nbreDirectionDePrise);
      dx := dirPrise[t];
      CreateBitBoardFlipsOfSquareThisDirection(square,dx,false,false,_MY_BITS_,_OPP_BITS_);
    end;


  WritelnDansFichierEndgame('if (nbPrise <> 0) ');
  WritelnDansFichierEndgame('  then');
    IncrementeMarge;
    IncrementeMarge;
      WriteBegin;
        IncrementeMarge;
        WritelnDansFichierEndgame('diffPions := succ(diffPions+nbPrise);');

        s3 := Hexa(constanteDeParite[square]);
        WritelnDansFichierEndgame('ModifPlatBitboard := BXOR(vecteurParite,' + s3 + ');');

        s1 := BitboardName(_MY_BITS_,othellierBitboardDescr[square].isLow);
		    s2 := Hexa(othellierBitboardDescr[square].constanteHexa);
		    WritelnDansFichierEndgame(s1 + ' := BOR(' + s1 + ',' + s2 + ');  { place the disc in '+CoupEnString(square,true)+' }');

        WritelnDansFichierEndgame('g_my_bits_low   := opp_bits_low;  {le trait change : on echange my_bits et opp_bits}');
        WritelnDansFichierEndgame('g_my_bits_high  := opp_bits_high;');
        WritelnDansFichierEndgame('g_opp_bits_low  := my_bits_low;');
        WritelnDansFichierEndgame('g_opp_bits_high := my_bits_high;');

        DecrementeMarge;
      WriteEndSansPointVirgule;
    DecrementeMarge;
    WritelnDansFichierEndgame('else');
    WritelnDansFichierEndgame('  ModifPlatBitboard := vecteurParite;');

  DecrementeMarge;
  DecrementeMarge;
  WriteEnd;
  DecrementeMarge;
end;

procedure CreateValeurDeuxDerniersCoupsBitboardOfSquare(square : SInt16);
var dx,t,nbreDirectionDePrise : SInt32;
    s1,s2 : String255;
begin
  SetNiveauMarge(4);
  WritelnDansFichierEndgame(IntToStr(square)+ ' :    { ' + CoupEnString(square,true) + ' }');
  IncrementeMarge;
  WriteBegin;
  IncrementeMarge;

  nbreDirectionDePrise := 0;
  for t := dirPriseDeb[square] to dirPriseFin[square] do
    begin
      inc(nbreDirectionDePrise);
      dx := dirPrise[t];
      CreateBitBoardFlipsOfSquareThisDirection(square,dx,false,false,_MY_BITS_,_OPP_BITS_);
    end;


  WritelnDansFichierEndgame('if (nbPrise <> 0) ');
  WritelnDansFichierEndgame('  then');
    IncrementeMarge;
    IncrementeMarge;
      WriteBegin;
        IncrementeMarge;
        WritelnDansFichierEndgame('diffPions := succ(diffPions+nbPrise);');
        s1 := BitboardName(_MY_BITS_,othellierBitboardDescr[square].isLow);
		    s2 := Hexa(othellierBitboardDescr[square].constanteHexa);
		    WritelnDansFichierEndgame(s1 + ' := BOR(' + s1 + ',' + s2 + ');  { place the disc in '+CoupEnString(square,true)+' }');
        WritelnDansFichierEndgame('goto iCourant1EstLegal;');
        DecrementeMarge;
      WriteEndSansPointVirgule;
    DecrementeMarge;
    WritelnDansFichierEndgame('else');
    WritelnDansFichierEndgame('  goto iCourant1EstIllegal;');

  DecrementeMarge;
  DecrementeMarge;
  WriteEnd;
  DecrementeMarge;
end;


procedure CreateBitboardNeighborhoodMasks;
var dx,t,i,j,nbreDirectionDePrise : SInt32;
    square,neighbour : SInt32;
    mask_low,mask_high : UInt32;
begin
  SetNiveauMarge(4);
  IncrementeMarge;
  WriteBegin;
  IncrementeMarge;

  for j := 1 to 8 do
    for i := 1 to 8 do
      begin

        square := i + j*10;

        mask_low  := 0;
        mask_high := 0;

        nbreDirectionDePrise := 0;
        for t := dirPriseDeb[square] to dirPriseFin[square] do
          begin
            inc(nbreDirectionDePrise);
            dx := dirPrise[t];

            neighbour := square + dx;

            if othellierBitboardDescr[neighbour].isLow
              then mask_low  := mask_low  + othellierBitboardDescr[neighbour].constanteHexa
              else mask_high := mask_high + othellierBitboardDescr[neighbour].constanteHexa;


          end;

         WritelnDansFichierEndgame('masque_voisinage['+IntToStr(square)+'].low  := '+Hexa(mask_low)+';'+ '   { ' + CoupEnString(square,true) + ' }');
         WritelnDansFichierEndgame('masque_voisinage['+IntToStr(square)+'].high := '+Hexa(mask_high)+';');

       end;


  DecrementeMarge;
  DecrementeMarge;
  WriteEnd;
  DecrementeMarge;
end;


procedure CreateBitboardValidOneEmptyOfSquare(square : SInt32);
var dx,t,nbreDirectionDePrise : SInt32;
    aux,neighbour : SInt32;
    mask_low,mask_high : UInt32;
begin


  IncrementeMarge;



  nbreDirectionDePrise := 0;
  for t := dirPriseDeb[square] to dirPriseFin[square] do
    begin
      mask_low  := 0;
      mask_high := 0;

      inc(nbreDirectionDePrise);
      dx := dirPrise[t];

      neighbour := square + dx;

      if othellierBitboardDescr[neighbour].isLow
        then
          begin
            mask_low  := mask_low  + othellierBitboardDescr[neighbour].constanteHexa;
            WritelnDansFichierEndgame('((BAND(opp_bits_low,'+Hexa(mask_low)+') = 0) and ');
          end
        else
          begin
            mask_high := mask_high + othellierBitboardDescr[neighbour].constanteHexa;
            WritelnDansFichierEndgame('((BAND(opp_bits_high,'+Hexa(mask_high)+') = 0) &');
          end;

      mask_low  := 0;
      mask_high := 0;

      aux := neighbour + dx;
      while not(interdit[aux]) do
        begin
          if othellierBitboardDescr[aux].isLow
            then mask_low  := mask_low  + othellierBitboardDescr[aux].constanteHexa
            else mask_high := mask_high + othellierBitboardDescr[aux].constanteHexa;
          aux := aux + dx;
        end;

      if (mask_low = 0) and (mask_high = 0) then WritelnDansFichierEndgame('ERREUR !!');
      if (mask_low <> 0) and (mask_high <> 0) then
        WriteDansFichierEndgame(' ((BAND(opp_bits_low,'+Hexa(mask_low)+') <> 0) or (BAND(opp_bits_high,'+Hexa(mask_high)+') <> 0)))');
      if (mask_low <> 0) and (mask_high = 0) then
        WriteDansFichierEndgame(' (BAND(opp_bits_low,'+Hexa(mask_low)+') <> 0))');
      if (mask_low = 0) and (mask_high <> 0) then
        WriteDansFichierEndgame(' (BAND(opp_bits_high,'+Hexa(mask_high)+') <> 0))');

      if t <> dirPriseFin[square]
        then WritelnSansMargeDansFichierEndgame(' or')
        else WritelnSansMargeDansFichierEndgame(' ')
    end;


  DecrementeMarge;
end;


procedure CreateBitboardValidOneEmptyMoves;
var i,j : SInt32;
begin
  for i := 1 to 8 do
    for j := 1 to 8 do
      CreateBitboardValidOneEmptyOfSquare(i*10 + j);
end;


procedure CreateDernierCoupBitboardOfSquare(square : SInt16);
var dx,t,nbreDirectionDePrise : SInt32;
begin
  SetNiveauMarge(4);
  WritelnDansFichierEndgame(IntToStr(square)+ ' :    { ' + CoupEnString(square,true) + ' }');
  IncrementeMarge;
  WriteBegin;
  IncrementeMarge;

  nbreDirectionDePrise := 0;
  for t := dirPriseDeb[square] to dirPriseFin[square] do
    begin
      inc(nbreDirectionDePrise);
      dx := dirPrise[t];
      CreateBitBoardFlipsOfSquareThisDirection(square,dx,true,false,_MY_BITS_,_OPP_BITS_);
    end;


  WritelnDansFichierEndgame('if (nbPrise <> 0) ');
  WritelnDansFichierEndgame('  then');
    IncrementeMarge;
    IncrementeMarge;
      WriteBegin;
        IncrementeMarge;
        WritelnDansFichierEndgame('DernierCoupBitboard := pred(diffPions-nbPrise);');
        WritelnDansFichierEndgame('exit;
        DecrementeMarge;
      WriteEndSansPointVirgule;
    DecrementeMarge;
    WritelnDansFichierEndgame('else');
      WriteBegin;
        IncrementeMarge;
        nbreDirectionDePrise := 0;
        for t := dirPriseDeb[square] to dirPriseFin[square] do
			    begin
			      inc(nbreDirectionDePrise);
			      dx := dirPrise[t];
			      CreateBitBoardFlipsOfSquareThisDirection(square,dx,true,false,_OPP_BITS_,_MY_BITS_);
			    end;
        DecrementeMarge;
      WriteEnd;

  DecrementeMarge;
  DecrementeMarge;
  WriteEnd;
  DecrementeMarge;
end;


procedure CreateTestSecondeCaseDansDeuxCasesVidesBitboardOfSquare(square : SInt16);
var dx,t,nbreDirectionDePrise : SInt32;
begin
  SetNiveauMarge(4);
  WritelnDansFichierEndgame(IntToStr(square)+ ' :    { ' + CoupEnString(square,true) + ' }');
  IncrementeMarge;
  WriteBegin;
  IncrementeMarge;

  WritelnDansFichierEndgame('IF (diffPions - 3) <= alpha');
  IncrementeMarge;
  WritelnDansFichierEndgame('THEN');
  IncrementeMarge;
  WritelnDansFichierEndgame('BEGIN');
  IncrementeMarge;
  WritelnDansFichierEndgame('{ l''adversaire peut-il jouer en ' + CoupEnString(square,true)+' ? }');
  WritelnDansFichierEndgame('if ');
  CreateBitboardValidOneEmptyOfSquare(square);
  WritelnDansFichierEndgame('  then');
  IncrementeMarge;
  IncrementeMarge;
  WriteBegin;
    IncrementeMarge;
      WritelnDansFichierEndgame('noteCourante := diffPions - 3;');
      WritelnDansFichierEndgame('goto apresCalculNoteCourante;');
    DecrementeMarge;
  WriteEnd;
  DecrementeMarge;
  DecrementeMarge;
  DecrementeMarge;
  WritelnDansFichierEndgame('END');
  DecrementeMarge;
  WritelnDansFichierEndgame('ELSE');

  IncrementeMarge;
  WritelnDansFichierEndgame('BEGIN  { on teste si il peut jouer en '+CoupEnString(square,true) + ', en calculant le score }');
  IncrementeMarge;
  nbreDirectionDePrise := 0;
  for t := dirPriseDeb[square] to dirPriseFin[square] do
    begin
      inc(nbreDirectionDePrise);
      dx := dirPrise[t];
      CreateBitBoardFlipsOfSquareThisDirection(square,dx,true,false,_OPP_BITS_,_MY_BITS_);
    end;

  WritelnDansFichierEndgame('');

  WriteDansFichierEndgame('');
  WritelnCommentaireDansFichierEndgame('l''adversaire peut-il jouer ?');
  WritelnDansFichierEndgame('if (nbPrise <> 0) then goto iCourant2EstLegalPourAdversaire;');

  DecrementeMarge;
  WritelnDansFichierEndgame('END;');
  DecrementeMarge;
  DecrementeMarge;

  WritelnDansFichierEndgame('');

  WriteDansFichierEndgame('');
  WritelnCommentaireDansFichierEndgame('il passe, testons si on a une coupure beta evidente');

  WritelnDansFichierEndgame('if (diffPions > 0)');
  WritelnDansFichierEndgame('  then');
    IncrementeMarge;
    IncrementeMarge;
      WriteBegin;

      IncrementeMarge;
      WritelnDansFichierEndgame('if (diffPions + 1) >= beta then   { +1, car on aura au moins une case vide }');
      IncrementeMarge;
      WriteBegin;
      IncrementeMarge;
      WritelnDansFichierEndgame('noteCourante := diffPions + 1;');
      WritelnDansFichierEndgame('goto apresCalculNoteCourante;');
      DecrementeMarge;
      WriteEndSansPointVirgule;
      DecrementeMarge;
      DecrementeMarge;
      WriteEndSansPointVirgule;
      DecrementeMarge;
      WritelnDansFichierEndgame('else');
      IncrementeMarge;
      WriteBegin;
      IncrementeMarge;
      WritelnDansFichierEndgame('if (diffPions - 1) >= beta then   { -1, car au pire on perdra une case vide }');
      IncrementeMarge;
      WriteBegin;
      IncrementeMarge;
      WritelnDansFichierEndgame('noteCourante := diffPions - 1;');
      WritelnDansFichierEndgame('goto apresCalculNoteCourante;');
      DecrementeMarge;
      WriteEnd;
      DecrementeMarge;
      DecrementeMarge;
      WriteEnd;


    DecrementeMarge;
    WritelnDansFichierEndgame('');

      WritelnDansFichierEndgame('{il passe, et il faut calculer le score qui risque de tomber dans l''intervalle [-64, beta] }');
      WriteBegin;
      IncrementeMarge;
        nbreDirectionDePrise := 0;
        for t := dirPriseDeb[square] to dirPriseFin[square] do
			    begin
			      inc(nbreDirectionDePrise);
			      dx := dirPrise[t];
			      CreateBitBoardFlipsOfSquareThisDirection(square,dx,true,false,_MY_BITS_,_OPP_BITS_);
			    end;
        DecrementeMarge;
      WriteEnd;

  DecrementeMarge;
  DecrementeMarge;
  WriteEnd;
  DecrementeMarge;
end;


procedure CreateTestSecondeCaseDansDeuxCasesVides;
var square : SInt16;
begin
  for square := 11 to 88 do
    if not(interdit[square]) then
      CreateTestSecondeCaseDansDeuxCasesVidesBitboardOfSquare(square);
end;

procedure CreateDernierCoupInverseBitboardOfSquare(square : SInt16);
var dx,t,nbreDirectionDePrise : SInt32;
begin
  SetNiveauMarge(4);
  WritelnDansFichierEndgame(IntToStr(square)+ ' :    { ' + CoupEnString(square,true) + ' }');
  IncrementeMarge;
  WriteBegin;
  IncrementeMarge;

  nbreDirectionDePrise := 0;
  for t := dirPriseDeb[square] to dirPriseFin[square] do
    begin
      inc(nbreDirectionDePrise);
      dx := dirPrise[t];
      CreateBitBoardFlipsOfSquareThisDirection(square,dx,true,false,_OPP_BITS_,_MY_BITS_);
    end;


  WritelnDansFichierEndgame('if (nbPrise <> 0) ');
  WritelnDansFichierEndgame('  then');
    IncrementeMarge;
    IncrementeMarge;
      WriteBegin;
        IncrementeMarge;
        WritelnDansFichierEndgame('ValeurDeuxDerniersCoupsBitboard := pred(diffPions-nbPrise);');
        WritelnDansFichierEndgame('exit;
        DecrementeMarge;
      WriteEndSansPointVirgule;
    DecrementeMarge;
    WritelnDansFichierEndgame('else');
      WriteBegin;
        IncrementeMarge;
        nbreDirectionDePrise := 0;
        for t := dirPriseDeb[square] to dirPriseFin[square] do
			    begin
			      inc(nbreDirectionDePrise);
			      dx := dirPrise[t];
			      CreateBitBoardFlipsOfSquareThisDirection(square,dx,true,false,_MY_BITS_,_OPP_BITS_);
			    end;
        DecrementeMarge;
      WriteEnd;

  DecrementeMarge;
  DecrementeMarge;
  WriteEnd;
  DecrementeMarge;
end;



procedure CreateCoupLegalBitboardOfSquare(square,couleur,couleurAdversaire : SInt16);
var dx,t : SInt32;
    directionsDeRetournement,directionsDejaFaites : set of 0..20;
begin
  SetNiveauMarge(4);
  WritelnDansFichierEndgame(IntToStr(square)+ ' :    { ' + CoupEnString(square,true) + ' }');
  IncrementeMarge;
  WriteBegin;
  IncrementeMarge;

  directionsDejaFaites := [];
  directionsDeRetournement := [];
  for t := dirPriseDeb[square] to dirPriseFin[square] do
    directionsDeRetournement := directionsDeRetournement + [dirPrise[t] + 10];

  dx := 1;   {horizontalement à droite}
  if (dx+10) in directionsDeRetournement then
    begin
      CreateCoupLegalParAdditionBitBoard(square,dx,couleur,couleurAdversaire);
      directionsDejaFaites := directionsDejaFaites + [dx + 10];
    end;

  dx := -1;  {horizontalement à gauche}
  if (dx+10) in directionsDeRetournement then
    begin
      CreateCoupLegalParAdditionBitBoard(square,dx,couleur,couleurAdversaire);
      directionsDejaFaites := directionsDejaFaites + [dx + 10];
    end;

  for t := dirPriseDeb[square] to dirPriseFin[square] do
    begin
      dx := dirPrise[t];
      if not((dx+10) in directionsDejaFaites) then
        begin
          CreateBitBoardFlipsOfSquareThisDirection(square,dx,false,true,couleur,couleurAdversaire);
          directionsDejaFaites := directionsDejaFaites + [dx + 10];
        end;
    end;

  WritelnDansFichierEndgame('goto LeCoupEstIllegal;');


  DecrementeMarge;
  WriteEnd;
  DecrementeMarge;
end;


procedure CreateModifPlatBitboard;
var square : SInt16;
begin
  for square := 11 to 88 do
    if not(interdit[square]) then
      CreateModifPlatBitboardOfSquare(square);
end;


procedure CreateModifPlatBitboardFunction(square : SInt32);
var dx,t,nbreDirectionDePrise : SInt32;
    s1,s2,s3 : String255;
    nomFonction : String255;
begin
  nomFonction := 'ModifPlatBitboard_'+CoupEnString(square,false);

  SetNiveauMarge(0);
  WritelnDansFichierEndgame('');
  WritelnDansFichierEndgame('function '+nomFonction+'(vecteurParite : SInt32; my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32;');
  WritelnDansFichierEndgame('                           var resultat : bitboard; var diffPions : SInt32) : SInt32;');
  WritelnDansFichierEndgame('var nbPrise : SInt32;');
  WriteBegin;
  IncrementeMarge;

  WritelnDansFichierEndgame('with resultat do');
  IncrementeMarge;
  WriteBegin;
  IncrementeMarge;

  WritelnDansFichierEndgame('nbPrise := 0;');

  nbreDirectionDePrise := 0;
  for t := dirPriseDeb[square] to dirPriseFin[square] do
    begin
      inc(nbreDirectionDePrise);
      dx := dirPrise[t];
      CreateBitBoardFlipsOfSquareThisDirection(square,dx,false,false,_MY_BITS_,_OPP_BITS_);
    end;

  DecrementeMarge;

  WritelnDansFichierEndgame('if (nbPrise <> 0) ');
  WritelnDansFichierEndgame('  then');
    IncrementeMarge;
    IncrementeMarge;
      WriteBegin;
        IncrementeMarge;
        WritelnDansFichierEndgame('diffPions := succ(diffPions+nbPrise);');

        s3 := Hexa(constanteDeParite[square]);
        WritelnDansFichierEndgame(nomFonction+' := BXOR(vecteurParite,' + s3 + ');');

        s1 := BitboardName(_MY_BITS_,othellierBitboardDescr[square].isLow);
		    s2 := Hexa(othellierBitboardDescr[square].constanteHexa);
		    WritelnDansFichierEndgame(s1 + ' := BOR(' + s1 + ',' + s2 + ');  { place the disc in '+CoupEnString(square,true)+' }');

        WritelnDansFichierEndgame('g_my_bits_low   := opp_bits_low;  {le trait change : on echange my_bits et opp_bits}');
        WritelnDansFichierEndgame('g_my_bits_high  := opp_bits_high;');
        WritelnDansFichierEndgame('g_opp_bits_low  := my_bits_low;');
        WritelnDansFichierEndgame('g_opp_bits_high := my_bits_high;');

        DecrementeMarge;
      WriteEndSansPointVirgule;
    DecrementeMarge;
    WritelnDansFichierEndgame('else');
    WritelnDansFichierEndgame('  '+nomFonction+' := vecteurParite;');

  DecrementeMarge;

  DecrementeMarge;
  WriteEnd;

  DecrementeMarge;
  DecrementeMarge;
  WriteEnd;

  WritelnDansFichierEndgame('');
  WritelnDansFichierEndgame('');

end;

procedure CreateModifPlatBitboardFunctions;
var square : SInt16;
    nomFonction : String255;
begin
  for square := 11 to 88 do
    if not(interdit[square]) then
      begin
        {CreateModifPlatBitboardFunction(square);}
        nomFonction := 'ModifPlatBitboard_'+CoupEnString(square,false);
        WritelnDansFichierEndgame('function '+nomFonction+'(vecteurParite : SInt32; my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32; var resultat : bitboard; var diffPions : SInt32) : SInt32;');
      end;
end;

procedure CreateValeurDeuxDerniersCoupsBitboard;
var square : SInt16;
begin
  for square := 11 to 88 do
    if not(interdit[square]) then
      CreateValeurDeuxDerniersCoupsBitboardOfSquare(square);
end;

procedure CreateBitboardDernierCoup;
var square : SInt16;
begin
  for square := 11 to 88 do
    if not(interdit[square]) then
      CreateDernierCoupBitboardOfSquare(square);
end;

procedure CreateBitboardDernierCoupInverse;
var square : SInt16;
begin
  for square := 11 to 88 do
    if not(interdit[square]) then
      CreateDernierCoupInverseBitboardOfSquare(square);
end;

procedure CreateBitboardCoupLegal(couleur,couleurAdversaire : SInt16);
var square : SInt16;
begin
  for square := 11 to 88 do
    if not(interdit[square]) then
      CreateCoupLegalBitboardOfSquare(square,couleur,couleurAdversaire);

  WritelnNumDansRapport('BSL(16,1) = ',BSL(16,1));
  WritelnNumDansRapport('BSR(16,1) = ',BSR(16,1));
end;

procedure InitUnitCreateBitboardCode;
begin
  InitPowers3;
  InitOthellierBitboardDescritor;
end;

procedure CreateJansEndgameCode(C_language : boolean);
var err : OSErr;
begin
  generatingPascal := not(C_language);
  generatingPascal := true;
  margeBitboardCode := '';
  niveauDeLaMarge := 0;


  err := FileExists('Generated code',0,fichierCodeGenere);
  if err <> NoErr then
    err := CreateFile('Generated code',0,fichierCodeGenere);
  if err = NoErr then err := OpenFile(fichierCodeGenere);
  if err = NoErr then err := EmptyFile(fichierCodeGenere);

  WritelnNumDansRapport('CreateJansEndgameCode : err =',err);

  if err = NoErr then
    begin
     {Create_possible_move_functions(_WHITE_);
      Create_possible_move_functions(_BLACK_);}
     {Create_init_flip_fps(_WHITE_);
      Create_init_flip_fps(_BLACK_);}
     {Create_flip_back_functions(_WHITE_);
      Create_flip_back_functions(_BLACK_);}
     {Create_flip_functions(_WHITE_);
      Create_flip_functions(_BLACK_);}
     {Create_end_eval_1_ply_functions(_WHITE_);
      Create_end_eval_1_ply_functions(_BLACK_);}
     {Create_remove_functions(_WHITE_);
      Create_remove_functions(_BLACK_);
      Create_place_functions(_WHITE_);
      Create_place_functions(_BLACK_);}
     {Create_init_place_fps(_WHITE_);
      Create_init_place_fps(_BLACK_);}
     {Create_init_move_if_possible_fps(_WHITE_);
      Create_init_move_if_possible_fps(_BLACK_);}
     {Create_init_end_eval_1_ply_fps(_WHITE_);
      Create_init_end_eval_1_ply_fps(_BLACK_);}
     {Create_init_flips_codes(_WHITE_);
      Create_init_flips_codes(_BLACK_);}
     {Create_init_flips_1ply(_WHITE_);
      Create_init_flips_1ply(_BLACK_);}

      {CreateModifPlatBitboard;}
      {CreateValeurDeuxDerniersCoupsBitboard;}
      {CreateBitboardNeighborhoodMasks;}
      {CreateBitboardValidOneEmptyMoves;}
      {CreateBitboardDernierCoup;}
      {CreateBitboardDernierCoupInverse;}
      {CreateBitboardCoupLegal(_MY_BITS_,_OPP_BITS_);}
      {CreateBitboardCoupLegal(_OPP_BITS_,_MY_BITS_);}
      {CreateTestSecondeCaseDansDeuxCasesVides;}
      CreateModifPlatBitboardFunctions;

    end;

  err := CloseFile(fichierCodeGenere);
  SetFileCreatorFichierTexte(fichierCodeGenere,MY_FOUR_CHAR_CODE('R*ch'));
  SetFileTypeFichierTexte(fichierCodeGenere,MY_FOUR_CHAR_CODE('TEXT'));

  WritelnNumDansRapport('CreateJansEndgameCode : terminé!   err = ',err);
end;

END.
