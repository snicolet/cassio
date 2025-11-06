UNIT UnitEPS;




INTERFACE







 USES UnitDefCassio;


function WritePositionEtTraitEnEPSDansFichier(position : PositionEtTraitRec; fic : basicfile) : OSErr;


function WritePrologueEPSDansFichier(var fic : FichierAbstrait; nomFichier : String255) : OSErr;





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES DateTimeUtils
{$IFC NOT(USE_PRELINK)}
     , UnitDiagramFforum, UnitScannerUtils, basicfile, UnitDiagramFforum, MyStrings, UnitRapport
     , UnitArbreDeJeuCourant, UnitPositionEtTrait, UnitPressePapier, UnitPierresDelta, UnitFichierAbstrait
     ;
{$ELSEC}
    ;
    {$I prelink/EPS.lk}
{$ENDC}


{END_USE_CLAUSE}



function WritePrologueEPSDansFichier(var fic : FichierAbstrait; nomFichier : String255) : OSErr;
var err : OSErr;
    scaleForEPS : double;
    boudingRectEPS : Rect;
    myDate : DateTimeRec;
    initialPosition : PositionEtTraitRec;
    ligne : String255;
begin

  scaleForEPS := CalculateScaleFactorForEPSDiagram(boudingRectEPS);

  GetTime(myDate);

  (* debut des commenatires ADOBE *)
  err := WritelnDansFichierAbstrait(fic,'%!PS-Adobe-3.0 EPSF-3.0');
  err := WritelnDansFichierAbstrait(fic,'%%Creator: Cassio ');
  err := WritelnDansFichierAbstrait(fic,'%%Title: '+ExtractFileOrDirectoryName(nomFichier));
  err := WritelnDansFichierAbstrait(fic,'%%CreationDate: '+IntToStrWithPadding(myDate.month,2, '0')+'/'+
		                                                    IntToStrWithPadding(myDate.day,2,'0')+'/'+
		                                                    IntToStrWithPadding(myDate.year,4,'0')+' '+
		                                                    IntToStrWithPadding(myDate.hour,2,'0')+':'+
		                                                    IntToStrWithPadding(myDate.minute,2,'0')+':'+
		                                                    IntToStrWithPadding(myDate.second,2,'0'));

  with boudingRectEPS do
    err := WritelnDansFichierAbstrait(fic,'%%BoundingBox: ' + IntToStr(left) + ' '
                                                         + IntToStr(top) + ' '
                                                         + IntToStr(right) + ' '
                                                         + IntToStr(bottom) );

  (* ecriture des infos d'othello en commentaire dans le fichier EPS *)
  if positionFeerique then
    begin
      initialPosition := GetPositionEtTraitInitiauxOfGameTree;
      err := WritelnDansFichierAbstrait(fic,'%%Othello-initial-position: '+PositionEtTraitEnString(initialPosition));
    end;
  err := WritelnDansFichierAbstrait(fic,'%%Othello-moves: '+PartiePourPressePapier(true,false,60));
  err := WritelnDansFichierAbstrait(fic,'%%Othello-current-move-number: '+IntToStr(nbreCoup));
  ligne := GetPierresDeltaCourantesEnString;
  if (ligne <> '') then
    err := WritelnDansFichierAbstrait(fic,'%%Othello-SGF-annotations: '+ligne);

  if (ParamDiagPositionFFORUM.commentPositionFFORUM^^ <> '') then
    err := WritelnDansFichierAbstrait(fic,'%%Othello-diagram-comment: '+ParamDiagPositionFFORUM.commentPositionFFORUM^^);

  if (ParamDiagPartieFFORUM.titreFFORUM^^ <> '') then
    err := WritelnDansFichierAbstrait(fic,'%%Othello-diagram-title: '+ParamDiagPartieFFORUM.titreFFORUM^^);


  (* fin des commenataires ADOBE *)
  err := WritelnDansFichierAbstrait(fic,'%%EndComments');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'%%BeginProlog');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello coordinates');
  err := WritelnDansFichierAbstrait(fic,'/A1 {40 160} def /A2 {40 140} def /A3 {40 120} def /A4 {40 100} def /A5 {40 80} def /A6 {40 60} def /A7 {40 40} def /A8 {40 20} def');
  err := WritelnDansFichierAbstrait(fic,'/B1 {60 160} def /B2 {60 140} def /B3 {60 120} def /B4 {60 100} def /B5 {60 80} def /B6 {60 60} def /B7 {60 40} def /B8 {60 20} def');
  err := WritelnDansFichierAbstrait(fic,'/C1 {80 160} def /C2 {80 140} def /C3 {80 120} def /C4 {80 100} def /C5 {80 80} def /C6 {80 60} def /C7 {80 40} def /C8 {80 20} def');
  err := WritelnDansFichierAbstrait(fic,'/D1 {100 160} def /D2 {100 140} def /D3 {100 120} def /D4 {100 100} def /D5 {100 80} def /D6 {100 60} def /D7 {100 40} def /D8 {100 20} def');
  err := WritelnDansFichierAbstrait(fic,'/E1 {120 160} def /E2 {120 140} def /E3 {120 120} def /E4 {120 100} def /E5 {120 80} def /E6 {120 60} def /E7 {120 40} def /E8 {120 20} def');
  err := WritelnDansFichierAbstrait(fic,'/F1 {140 160} def /F2 {140 140} def /F3 {140 120} def /F4 {140 100} def /F5 {140 80} def /F6 {140 60} def /F7 {140 40} def /F8 {140 20} def');
  err := WritelnDansFichierAbstrait(fic,'/G1 {160 160} def /G2 {160 140} def /G3 {160 120} def /G4 {160 100} def /G5 {160 80} def /G6 {160 60} def /G7 {160 40} def /G8 {160 20} def');
  err := WritelnDansFichierAbstrait(fic,'/H1 {180 160} def /H2 {180 140} def /H3 {180 120} def /H4 {180 100} def /H5 {180 80} def /H6 {180 60} def /H7 {180 40} def /H8 {180 20} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% some geometric factors and shapes');
  err := WritelnDansFichierAbstrait(fic,'');
  err := WritelnDansFichierAbstrait(fic,'/discscalefactor { 1.0 } def');
  err := WritelnDansFichierAbstrait(fic,'/scaledisc { discscalefactor mul } def');
  err := WritelnDansFichierAbstrait(fic,'/movenumberscale { 1.0 } def');
  err := WritelnDansFichierAbstrait(fic,'/scalemovenumber {movenumberscale mul scaledisc scalefont} def');
  err := WritelnDansFichierAbstrait(fic,'/moveverticaloffset { 0.0 } def');
  err := WritelnDansFichierAbstrait(fic,'');

  err := WritelnDansFichierAbstrait(fic,'% circles');
  err := WritelnDansFichierAbstrait(fic,'/circle { 0 360 arc } def');
  err := WritelnDansFichierAbstrait(fic,'/solid_circle {scaledisc circle fill} def');
  err := WritelnDansFichierAbstrait(fic,'/hollow_circle {scaledisc circle stroke } def');
  err := WritelnDansFichierAbstrait(fic,'/black_small_circle { 0.25 penwidth newpath 4 scaledisc circle fill closepath } def');
  err := WritelnDansFichierAbstrait(fic,'/white_small_circle { 0.25 penwidth 1 setgray newpath 4 scaledisc circle fill closepath 0 setgray } def');
  err := WritelnDansFichierAbstrait(fic,'/hollow_small_circle { 0.25 penwidth newpath 4 scaledisc circle stroke closepath } def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% diamonds');
  err := WritelnDansFichierAbstrait(fic,'/diamond { 0.3 penwidth scaledisc newpath 3 1 roll moveto dup 0 rmoveto dup neg dup rlineto dup neg dup neg rlineto dup dup rlineto dup dup neg rlineto closepath} def');
  err := WritelnDansFichierAbstrait(fic,'/solid_diamond { 8.0 diamond fill } def');
  err := WritelnDansFichierAbstrait(fic,'/hollow_diamond { 8.0 diamond stroke } def');
  err := WritelnDansFichierAbstrait(fic,'/white_diamond {/y exch def /x exch def 1 setgray x y solid_diamond 0 setgray x y hollow_diamond} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% boxes');
  err := WritelnDansFichierAbstrait(fic,'/square {');
  err := WritelnDansFichierAbstrait(fic,'  0.3 penwidth');
  err := WritelnDansFichierAbstrait(fic,'  newpath moveto ');
  err := WritelnDansFichierAbstrait(fic,'  -5 scaledisc -5 scaledisc rmoveto');
  err := WritelnDansFichierAbstrait(fic,'  10 scaledisc 0   rlineto');
  err := WritelnDansFichierAbstrait(fic,'   0 10 scaledisc  rlineto');
  err := WritelnDansFichierAbstrait(fic,'  -10 scaledisc 0  rlineto');
  err := WritelnDansFichierAbstrait(fic,'  closepath');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'/solid_square { square fill } def');
  err := WritelnDansFichierAbstrait(fic,'/hollow_square { square stroke } def');
  err := WritelnDansFichierAbstrait(fic,'/white_square { /y exch def /x exch def 1 setgray x y solid_square 0 setgray x y hollow_square} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% deltas');
  err := WritelnDansFichierAbstrait(fic,'/delta { 0.3 penwidth newpath moveto 0 7.9 scaledisc rmoveto 6.75 scaledisc -12 scaledisc rlineto -13.5 scaledisc 0 rlineto closepath} def');
  err := WritelnDansFichierAbstrait(fic,'/solid_delta { delta fill } def');
  err := WritelnDansFichierAbstrait(fic,'/hollow_delta { delta stroke } def');
  err := WritelnDansFichierAbstrait(fic,'/white_delta { /y exch def /x exch def 1 setgray x y solid_delta 0 setgray x y hollow_delta} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% lines and arrows');
  err := WritelnDansFichierAbstrait(fic,'/pensize 1.0 def');
  err := WritelnDansFichierAbstrait(fic,'/penwidth {pensize mul setlinewidth} def');
  err := WritelnDansFichierAbstrait(fic,'/line { moveto lineto } def');
  err := WritelnDansFichierAbstrait(fic,'/cross { 1 setlinejoin 0.5 penwidth');
  err := WritelnDansFichierAbstrait(fic,'         moveto ');
  err := WritelnDansFichierAbstrait(fic,'         -6 scaledisc -6 scaledisc rmoveto ');
  err := WritelnDansFichierAbstrait(fic,'         12 scaledisc 12 scaledisc rlineto ');
  err := WritelnDansFichierAbstrait(fic,'         -12 scaledisc 0 rmoveto ');
  err := WritelnDansFichierAbstrait(fic,'         12 scaledisc -12 scaledisc rlineto ');
  err := WritelnDansFichierAbstrait(fic,'         stroke} def');
  err := WritelnDansFichierAbstrait(fic,'/red_line { gsave 2.2 setlinewidth 1 0 0 setrgbcolor 1 setlinejoin newpath line closepath stroke grestore } def');
  err := WritelnDansFichierAbstrait(fic,'/red_arrow {');
  err := WritelnDansFichierAbstrait(fic,'	/y1 exch def');
  err := WritelnDansFichierAbstrait(fic,'	/x1 exch def');
  err := WritelnDansFichierAbstrait(fic,'	/y0 exch def');
  err := WritelnDansFichierAbstrait(fic,'	/x0 exch def');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	x0 y0 x1 y1 red_line');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	y1 y0 sub /y exch def');
  err := WritelnDansFichierAbstrait(fic,'	x1 x0 sub /x exch def');
  err := WritelnDansFichierAbstrait(fic,'	y x atan /theta exch def');
  err := WritelnDansFichierAbstrait(fic,'	x x mul y y mul add sqrt 0.26 mul /len exch def');
  err := WritelnDansFichierAbstrait(fic,'	len 9 gt {9}{len} ifelse /len exch def');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	x1 theta 28 add cos len mul sub');
  err := WritelnDansFichierAbstrait(fic,'	y1 theta 28 add sin len mul sub');
  err := WritelnDansFichierAbstrait(fic,'	x1 y1 red_line');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	x1 theta 28 sub cos len mul sub');
  err := WritelnDansFichierAbstrait(fic,'	y1 theta 28 sub sin len mul sub');
  err := WritelnDansFichierAbstrait(fic,'	x1 y1 red_line');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% stars');
  err := WritelnDansFichierAbstrait(fic,'/starside { 16 scaledisc 0 lineto currentpoint translate -144 rotate} def');
  err := WritelnDansFichierAbstrait(fic,'/star { newpath moveto -8 scaledisc 2.5 scaledisc rmoveto currentpoint translate 4 {starside} repeat closepath } def ');
  err := WritelnDansFichierAbstrait(fic,'/solid_star { gsave 1 setlinejoin star fill grestore } def');
  err := WritelnDansFichierAbstrait(fic,'/white_star { gsave 1 setlinejoin 1 setgray star fill grestore } def');
  err := WritelnDansFichierAbstrait(fic,'/hollow_star {');
  err := WritelnDansFichierAbstrait(fic,'gsave');
  err := WritelnDansFichierAbstrait(fic,'	1.0 scaledisc /old_scale exch def ');
  err := WritelnDansFichierAbstrait(fic,'	/y exch def');
  err := WritelnDansFichierAbstrait(fic,'	/x exch def');
  err := WritelnDansFichierAbstrait(fic,'	x y solid_star');
  err := WritelnDansFichierAbstrait(fic,'	x y /scaledisc { 0.82 old_scale mul mul } def white_star');
  err := WritelnDansFichierAbstrait(fic,'	/scaledisc { old_scale mul } def');
  err := WritelnDansFichierAbstrait(fic,'grestore');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw a black disc');
  err := WritelnDansFichierAbstrait(fic,'/black_disc{');
  err := WritelnDansFichierAbstrait(fic,'	/y exch def');
  err := WritelnDansFichierAbstrait(fic,'	/x exch def');
  err := WritelnDansFichierAbstrait(fic,'	0.4 penwidth');
  err := WritelnDansFichierAbstrait(fic,'	x y 8.5 solid_circle');
  err := WritelnDansFichierAbstrait(fic,'	x y 8.5 hollow_circle');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw a white disc');
  err := WritelnDansFichierAbstrait(fic,'/white_disc{');
  err := WritelnDansFichierAbstrait(fic,'	/y exch def');
  err := WritelnDansFichierAbstrait(fic,'	/x exch def');
  err := WritelnDansFichierAbstrait(fic,'	0.4 penwidth');
  err := WritelnDansFichierAbstrait(fic,'	1 setgray x y 8.5 solid_circle ');
  err := WritelnDansFichierAbstrait(fic,'	0 setgray x y 8.5 hollow_circle');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw a move number');
  err := WritelnDansFichierAbstrait(fic,'/move_number{');
  err := WritelnDansFichierAbstrait(fic,'	moveto');
  err := WritelnDansFichierAbstrait(fic,'	dup stringwidth pop 2 div neg');
  err := WritelnDansFichierAbstrait(fic,'	-4.0 moveverticaloffset add movenumberscale mul scaledisc');
  err := WritelnDansFichierAbstrait(fic,'	rmoveto');
  err := WritelnDansFichierAbstrait(fic,'	show');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw a white move');
  err := WritelnDansFichierAbstrait(fic,'/white_move{');
  err := WritelnDansFichierAbstrait(fic,'	/y exch def');
  err := WritelnDansFichierAbstrait(fic,'	/x exch def');
  err := WritelnDansFichierAbstrait(fic,'	x y white_disc');
  err := WritelnDansFichierAbstrait(fic,'	x y move_number');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw a black move');
  err := WritelnDansFichierAbstrait(fic,'/black_move{');
  err := WritelnDansFichierAbstrait(fic,'	/y exch def');
  err := WritelnDansFichierAbstrait(fic,'	/x exch def');
  err := WritelnDansFichierAbstrait(fic,'	x y black_disc');
  err := WritelnDansFichierAbstrait(fic,'	boldfont findfont 12 scalemovenumber setfont');
  err := WritelnDansFichierAbstrait(fic,'	1 setgray x y move_number 0 setgray');
  err := WritelnDansFichierAbstrait(fic,'	regularfont findfont 12 scalemovenumber setfont');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw the border around the board');
  err := WritelnDansFichierAbstrait(fic,'/has_frame false def');
  err := WritelnDansFichierAbstrait(fic,'/board_frame{');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	0 setlinejoin');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	1.7 setlinewidth');
  err := WritelnDansFichierAbstrait(fic,'	newpath');
  err := WritelnDansFichierAbstrait(fic,'	27.5  7.5  moveto');
  err := WritelnDansFichierAbstrait(fic,'	 165    0  rlineto');
  err := WritelnDansFichierAbstrait(fic,'	   0  165  rlineto');
  err := WritelnDansFichierAbstrait(fic,'	-165    0  rlineto');
  err := WritelnDansFichierAbstrait(fic,'	closepath');
  err := WritelnDansFichierAbstrait(fic,'	stroke');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	1 setlinejoin');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	/has_frame true def');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw the board');
  err := WritelnDansFichierAbstrait(fic,'/board_grid{');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	1 setlinejoin');
  err := WritelnDansFichierAbstrait(fic,'	');
  err := WritelnDansFichierAbstrait(fic,'	0.4 penwidth');
  err := WritelnDansFichierAbstrait(fic,'	newpath');
  err := WritelnDansFichierAbstrait(fic,'	  30   10 moveto');
  err := WritelnDansFichierAbstrait(fic,'	 160   0 rlineto');
  err := WritelnDansFichierAbstrait(fic,'	   0 160 rlineto');
  err := WritelnDansFichierAbstrait(fic,'	-160   0 rlineto');
  err := WritelnDansFichierAbstrait(fic,'	closepath');
  err := WritelnDansFichierAbstrait(fic,'');
  err := WritelnDansFichierAbstrait(fic,'	%vertical lines');
  err := WritelnDansFichierAbstrait(fic,'	30 10 moveto');
  err := WritelnDansFichierAbstrait(fic,'	0 1 8{');
  err := WritelnDansFichierAbstrait(fic,'		 0  160 rlineto');
  err := WritelnDansFichierAbstrait(fic,'		20 -160 rmoveto');
  err := WritelnDansFichierAbstrait(fic,'	}for');
  err := WritelnDansFichierAbstrait(fic,'');
  err := WritelnDansFichierAbstrait(fic,'	%horizontal lines');
  err := WritelnDansFichierAbstrait(fic,'	30 10 moveto');
  err := WritelnDansFichierAbstrait(fic,'	0 1 8{');
  err := WritelnDansFichierAbstrait(fic,'		 160  0 rlineto');
  err := WritelnDansFichierAbstrait(fic,'		-160 20 rmoveto');
  err := WritelnDansFichierAbstrait(fic,'	}for');
  err := WritelnDansFichierAbstrait(fic,'	stroke');
  err := WritelnDansFichierAbstrait(fic,'}def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw the small marks around the sweet 16');
  err := WritelnDansFichierAbstrait(fic,'/board_marks {');
  err := WritelnDansFichierAbstrait(fic,'	 70  50 moveto');
  err := WritelnDansFichierAbstrait(fic,'	 70  50 2 circle fill');
  err := WritelnDansFichierAbstrait(fic,'	150  50 2 circle fill');
  err := WritelnDansFichierAbstrait(fic,'	 70 130 2 circle fill');
  err := WritelnDansFichierAbstrait(fic,'	150 130 2 circle fill');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : fill the board with the RGB color on the stack');
  err := WritelnDansFichierAbstrait(fic,'/board_rgbcolor{');
  err := WritelnDansFichierAbstrait(fic,'	newpath');
  err := WritelnDansFichierAbstrait(fic,'	0.4 penwidth');
  err := WritelnDansFichierAbstrait(fic,'	  30   10 moveto');
  err := WritelnDansFichierAbstrait(fic,'	 160   0  rlineto');
  err := WritelnDansFichierAbstrait(fic,'	   0 160  rlineto');
  err := WritelnDansFichierAbstrait(fic,'	 -160   0 rlineto');
  err := WritelnDansFichierAbstrait(fic,'	closepath');
  err := WritelnDansFichierAbstrait(fic,'	setrgbcolor             % Use the RGB color on the stack');
  err := WritelnDansFichierAbstrait(fic,'	fill                    % Fill the box');
  err := WritelnDansFichierAbstrait(fic,'	0 0 0 setrgbcolor       % Set the color back to black');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw coordinates');
  err := WritelnDansFichierAbstrait(fic,'/board_coord{');
  err := WritelnDansFichierAbstrait(fic,'	regularfont findfont 12 scalefont setfont');
  err := WritelnDansFichierAbstrait(fic,'	0.45 setgray');
  err := WritelnDansFichierAbstrait(fic,'	newpath');
  err := WritelnDansFichierAbstrait(fic,'	has_frame {0 3 translate} if');
  err := WritelnDansFichierAbstrait(fic,'	(a)  37 174 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(b)  57 174 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(c)  77 174 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(d)  97 174 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(e) 117 174 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(f) 137 174 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(g) 157 174 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(h) 177 174 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	has_frame {-4 -3 translate} if');
  err := WritelnDansFichierAbstrait(fic,'	(1)  20 156 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(2)  20 136 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(3)  20 116 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(4)  20  96 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(5)  20  76 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(6)  20  56 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(7)  20  36 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	(8)  20  16 moveto show');
  err := WritelnDansFichierAbstrait(fic,'	has_frame {4 0 translate} if');
  err := WritelnDansFichierAbstrait(fic,'	0 setgray');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');


  err := WritelnDansFichierAbstrait(fic,'% othello command : draw a text under the diagram');
  err := WritelnDansFichierAbstrait(fic,'/center_text{');
  err := WritelnDansFichierAbstrait(fic,'	/string2 exch def');
  err := WritelnDansFichierAbstrait(fic,'	/string1 exch def');
  err := WritelnDansFichierAbstrait(fic,'  /RegularFontLatin');
  err := WritelnDansFichierAbstrait(fic,'  << regularfont findfont {} forall >>');
  err := WritelnDansFichierAbstrait(fic,'    begin');
  err := WritelnDansFichierAbstrait(fic,'	    /Encoding ISOLatin1Encoding 256 array copy def currentdict');
  err := WritelnDansFichierAbstrait(fic,'	  end');
  err := WritelnDansFichierAbstrait(fic,'  definefont pop');
  err := WritelnDansFichierAbstrait(fic,'  /BoldFontLatin');
  err := WritelnDansFichierAbstrait(fic,'  << boldfont findfont {} forall >>');
  err := WritelnDansFichierAbstrait(fic,'    begin');
  err := WritelnDansFichierAbstrait(fic,'	    /Encoding ISOLatin1Encoding 256 array copy def currentdict');
  err := WritelnDansFichierAbstrait(fic,'	  end');
  err := WritelnDansFichierAbstrait(fic,'  definefont pop');
  err := WritelnDansFichierAbstrait(fic,'  ');
  err := WritelnDansFichierAbstrait(fic,'  /RegularFontLatin 11 selectfont string1 stringwidth pop');
  err := WritelnDansFichierAbstrait(fic,'  /BoldFontLatin    11 selectfont string2 stringwidth pop');
  err := WritelnDansFichierAbstrait(fic,'  ');
  err := WritelnDansFichierAbstrait(fic,'  has_frame {0 -3 translate} if');
  err := WritelnDansFichierAbstrait(fic,'  110 2 moveto');
  err := WritelnDansFichierAbstrait(fic,'  add 2 div neg -4.0 rmoveto');
  err := WritelnDansFichierAbstrait(fic,'  /RegularFontLatin 11 selectfont string1 show');
  err := WritelnDansFichierAbstrait(fic,'  /BoldFontLatin    11 selectfont string2 show');
  err := WritelnDansFichierAbstrait(fic,'  has_frame {0 3 translate} if');
  err := WritelnDansFichierAbstrait(fic,'} def');
  err := WritelnDansFichierAbstrait(fic,'');

  err := WritelnDansFichierAbstrait(fic,'% font defaults');
  err := WritelnDansFichierAbstrait(fic,'/regularfont /Times-Roman def');
  err := WritelnDansFichierAbstrait(fic,'/boldfont    /Times-Bold  def');
  err := WritelnDansFichierAbstrait(fic,'');

  err := WritelnDansFichierAbstrait(fic,'%%EndProlog');
  err := WritelnDansFichierAbstrait(fic,'');
  err := WritelnDansFichierAbstrait(fic,'');

  WritePrologueEPSDansFichier := err;
end;


function WriteDescriptionPositionEPSDansFichier(position : PositionEtTraitRec; var fic : basicfile) : OSErr;
var i,j : SInt32;
    err : OSErr;
begin
  err := Writeln(fic,'	% draw the discs');
  for i := 1 to 8 do
    for j := 1 to 8 do
      case position.position[i*10+j] of
        pionBlanc : err := Writeln(fic,'	'+CoupEnStringEnMajuscules(i*10+j)+' white_disc');
        pionNoir  : err := Writeln(fic,'	'+CoupEnStringEnMajuscules(i*10+j)+' black_disc');
        pionVide  : ;
      end;
  err := Writeln(fic,'');
  WriteDescriptionPositionEPSDansFichier := err;
end;



function WriteCoupsPartieEPSDansFichier(var fic : basicfile) : OSErr;
var err : OSErr;
begin
  err := Writeln(fic,'	% draw the moves');
  err := Writeln(fic,'	regularfont findfont 12 scalemovenumber setfont');
  err := Writeln(fic,'	(1) E6 black_move');
  err := Writeln(fic,'	(2) F4 white_move');
  err := Writeln(fic,'	(3) C3 black_move');
  err := Writeln(fic,'	(4) C4 white_move');
  err := Writeln(fic,'	(5) D3 black_move');
  err := Writeln(fic,'	(6) D6 white_move');
  err := Writeln(fic,'	(7) E3 black_move');
  err := Writeln(fic,'	(8) C2 white_move');
  err := Writeln(fic,'	(9) B3 black_move');
  err := Writeln(fic,'');

  WriteCoupsPartieEPSDansFichier := err;
end;


function WritePositionEtTraitEnEPSDansFichier(position : PositionEtTraitRec; fic : basicfile) : OSErr;
begin
  Discard(position);
  Discard(fic);

  WritelnDansRapport('WARNING : WritePositionEtTraitEnEPSDansFichier is no longer implemented');

  WritePositionEtTraitEnEPSDansFichier := -1;
end;

(*
function WritePositionEtTraitEnEPSDansFichier(position : PositionEtTraitRec; fic : basicfile) : OSErr;
var fichierEtaitOuvertEnArrivant : boolean;
    err : OSErr;
begin
  err := NoErr;

  fichierEtaitOuvertEnArrivant := FileIsOpen(fic);
  if not(fichierEtaitOuvertEnArrivant) then err := OpenFile(fic);

  err := WritePrologueEPSDansFichier(fic);

  err := Writeln(fic,'% do the drawing');
  err := Writeln(fic,'gsave');
  err := Writeln(fic,'');
  err := Writeln(fic,'	% draw an empty board');
  err := Writeln(fic,'	board_coord');
  err := Writeln(fic,'	board_grid');
  err := Writeln(fic,'	board_marks');
  err := Writeln(fic,'');


  err := WriteDescriptionPositionEPSDansFichier(position,fic);
  {err := WriteCoupsPartieEPSDansFichier(fic);}


  err := Writeln(fic,'grestore');

  if not(fichierEtaitOuvertEnArrivant) then err := CloseFile(fic);


  WritePositionEtTraitEnEPSDansFichier := err;
end;
*)

end.
