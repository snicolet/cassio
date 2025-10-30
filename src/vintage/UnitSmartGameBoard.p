UNIT UnitSmartGameBoard;




INTERFACE





 USES
     {$IFC USE_PROFILER_SMART_GAME_BOARD}
     Profiler ,
     {$ENDC}
     UnitDefCassio;


{initialisation de l'unité}
procedure InitUnitSmartGameBoard;
procedure LibereMemoireUnitSmartGameBoard;


{lecture et ecriture du format Smart Game Board (SGF)}
procedure LitFormatSmartGameBoard(G : GameTree; whichFichierAbstrait : FichierAbstrait);
procedure EcritFormatSmartGameBoard(G : GameTree; var whichFichierAbstrait : FichierAbstrait);


{tests de reconnaissance format SGF}
function EstUneFichierAbstraitAuFormatSmartGameBoard(whichFichierAbstrait : FichierAbstrait) : boolean;
function EstUnFichierAuFormatSmartGameBoard(nomFichier : String255 ; vRefNum : SInt16) : boolean;


{lecture simplifiee : position initiale et ligne principale}
function GetPositionInitialeEtPartieDansFichierSmartGameBoard(var fic : basicfile; var posInitiale : PositionEtTraitRec; var coups : String255) : OSErr;


{fonctions de bas niveau }
function LectureSmartGameBoardEnCours : boolean;
procedure BeginLectureSmartGameBoard(whichFichierAbstrait : FichierAbstrait);
function LitProperty : Property;
function LitPropertyList : PropertyList;
procedure LitEtAjoutePropertyListACeNoeud(var G : GameTree);
procedure EndLectureSmartGameBoard;


{on gere une petite base de donnees des derniers fichiers SGF lus/ecrits}
procedure SauvegarderDatabaseOfRecentSGFFiles;
procedure LireDatabaseOfRecentSGFFiles;
procedure AjouterNomDansDatabaseOfRecentSGFFiles(const whichDate,whichName : String255);
function FichierExisteDansDatabaseOfRecentSGFFiles(whichName : String255; var modificationDate : String255) : boolean;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, UnitDebuggage, OSUtils, MacMemory, fp
{$IFC NOT(USE_PRELINK)}
    , UnitSetUp, UnitRapportImplementation, UnitGameTree, UnitJeu
    , UnitArbreDeJeuCourant, UnitInterversions, UnitPierresDelta, UnitSauvegardeRapport, MyMathUtils, MyStrings, UnitRapport, UnitServicesDialogs
    , UnitMiniProfiler, UnitPressePapier, UnitScannerUtils, UnitServicesMemoire, UnitGenericGameFormat, basicfile, UnitProperties, UnitPositionEtTrait
    , UnitPropertyList, UnitFichierAbstrait ;
{$ELSEC}
    ;
    {$I prelink/SmartGameBoard.lk}
{$ENDC}


{END_USE_CLAUSE}











{$IFC USE_PROFILER_SMART_GAME_BOARD}
var nomFichierProfileSmartGameBoard : String255;
{$ENDC}


const kMaxRecentSGFFiles = 10;
var   gDatabaseRecentSGFFiles : array[1..kMaxRecentSGFFiles] of
                                  record
                                    date,name : String255;
                                  end;

procedure InitUnitSmartGameBoard;
begin
  LectureSmartGameBoard.enCours := false;
end;

procedure LibereMemoireUnitSmartGameBoard;
begin
end;

function GetNextChar(SauterLesCaracteresDeControle : boolean) : char;
var err : OSErr;
    c : char;
    codeAsciiCaractere : SInt16;
    EstUnCaractereDeControle : boolean;
    oldPositionDansFichierAbstrait,count,nouvellePositionPourBuffer : SInt32;
begin
  with LectureSmartGameBoard do
    begin
		  repeat


		    with theFile do
		      begin
		        if (position < premierOctetDansBuffer) or (position > dernierOctetDansBuffer) then
		          begin  {defaut de page : on lit un nouveau buffer}

		            {WritelnNumDansRapport('defaut de page : position = ',theFichierAbstrait.position);}
		            oldPositionDansFichierAbstrait := position;
		            nouvellePositionPourBuffer := Max(0,oldPositionDansFichierAbstrait-10);
		            count := sizeof(buffer);

		            err := ReadFromFichierAbstrait(theFile,nouvellePositionPourBuffer,count,@buffer);

		            premierOctetDansBuffer := nouvellePositionPourBuffer;
		            dernierOctetDansBuffer := nouvellePositionPourBuffer + count - 1;

		            err := SetPositionMarqueurFichierAbstrait(theFile,oldPositionDansFichierAbstrait);

		            {WritelnNumDansRapport('premierOctetDansBuffer = ',premierOctetDansBuffer);
		            WritelnNumDansRapport('dernierOctetDansBuffer = ',dernierOctetDansBuffer);
		            WritelnNumDansRapport('count = ',count);
		            WritelnNumDansRapport('apres la lecture du buffer : position = ',theFichierAbstrait.position);}
		          end;

		        if (position >= premierOctetDansBuffer) and (position <= dernierOctetDansBuffer)
		          then
		            begin
		              c := buffer[position-premierOctetDansBuffer];
		              position := position+1;
		              err := NoErr;
		              inc(compteurCaracteres);
		            end
		          else
		            begin
		              err := SetPositionMarqueurFichierAbstrait(theFile,position);
		              err := GetNextCharOfFichierAbstrait(theFile,c);
		              inc(compteurCaracteres);
		            end;
		      end;


		    QuitterLecture := QuitterLecture or
		                      (err <> NoErr)   or
		                      (compteurCaracteres > theFile.nbOctetsOccupes);

		    GetNextChar := c;



		    codeAsciiCaractere := ord(c);
		    EstUnCaractereDeControle := (c = ' ') or (codeAsciiCaractere <= 32);

		  until not(EstUnCaractereDeControle and SauterLesCaracteresDeControle) or QuitterLecture;

		  avantDernierCaractereLu := dernierCaractereLu;
		  dernierCaractereLu := c;
    end;
end;


procedure RevientEnArriereDansFichier(nbCaracteres : SInt32);
var err : OSErr;
    nouvellePositionVoulue : SInt32;
begin
  with LectureSmartGameBoard do
    with theFile do
	    begin
	      nouvellePositionVoulue := Max(position-nbCaracteres,0);

	      if (nouvellePositionVoulue >= premierOctetDansBuffer) and
	         (nouvellePositionVoulue <= dernierOctetDansBuffer)
          then
            begin
              position := nouvellePositionVoulue;
              compteurCaracteres := position;
              err := NoErr;
            end
          else
            begin
              err := RevientEnArriereDansFichierAbstrait(theFile,nbCaracteres);
	            compteurCaracteres := position;
            end;

	      if (nbCaracteres = 1)
	        then dernierCaractereLu := avantDernierCaractereLu
	        else dernierCaractereLu := chr(0);
	      avantDernierCaractereLu := chr(0);

	      QuitterLecture := QuitterLecture or (err <> NoErr);
	    end;
end;



function LitArgumentOfPropertyEnChaine(SauterLesCaracteresDeControle : boolean) : String255;
var s : String255;
    c : char;
    longueur : SInt16;
begin
  with LectureSmartGameBoard do
    begin
		  s := '';
		  longueur := 0;
		  c := GetNextChar(SauterLesCaracteresDeControle);
		  {WritelnDansRapport('LitArgumentOfPropertyEnChaine : lecture de '+c+' (code ascii = '+IntToStr(ord(c))+')');
		  }
		  while not((c = ']') and (avantDernierCaractereLu <> '\')) and
		       (longueur < 255) and not(QuitterLecture) do
		    begin
		      if not((c = '\') and (avantDernierCaractereLu <> '\')) then
		        begin
		          s := Concat(s,c);
		          inc(longueur);

		          {ne pas lire deux \ dans les sequences du genre \\\[ }
		          if (c = '\') and (avantDernierCaractereLu = '\') then
		            begin
		              dernierCaractereLu := chr(0);
		              avantDernierCaractereLu := chr(0);
		            end;

		        end;
		      c := GetNextChar(SauterLesCaracteresDeControle);
		      {WritelnDansRapport('LitArgumentOfPropertyEnChaine : lecture de '+c+' (code ascii = '+IntToStr(ord(c))+')');
		      }
		    end;
		  {WritelnDansRapport('LitArgumentOfPropertyEnChaine ='+s);}
		  LitArgumentOfPropertyEnChaine := s;
    end;
end;

function LitArgumentOfPropertyEnCoup : SInt16;
var s : String255;
    square : SInt16;
    colonne,ligne : SInt16;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  if s = 'tt'
    then LitArgumentOfPropertyEnCoup := CoupSpecialPourPasse
    else
      begin
        square := StringEnCoup(s);
        if (square = -1) and (LENGTH_OF_STRING(s) >= 2) then
          begin
            {not found, cela pourrait etre un coup au format aa, ab, etc... (c'est-a-dire comme au go, deux coordonees en chiffres)}
            if StringSGFEnCoup(s, colonne, ligne) then
              square := 10*ligne + colonne;
          end;
        LitArgumentOfPropertyEnCoup := square;
      end;
end;

function LitArgumentOfPropertyEnLongint : SInt32;
var s : String255;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  LitArgumentOfPropertyEnLongint := StrToInt32(s);
end;


function LitArgumentOfPropertyEnTriple : Triple;
var s : String255;
    aux : Triple;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  aux.nbTriples := StrToInt32(s);
  LitArgumentOfPropertyEnTriple := aux;
end;

function LitArgumentOfPropertyEnReel : double;
var s : String255;
    r : double;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  r := StringSimpleEnReel(s);
  LitArgumentOfPropertyEnReel := r;
end;

function LitArgumentOfPropertyEnSquareSet : SquareSet;
var result : SquareSet;
    s : String255;
    c : char;
    compteur,aux : SInt32;
begin
  result := [];

  compteur := 0;
  repeat
    s := LitArgumentOfPropertyEnChaine(true);
    if s <> '' then
      begin
        aux := StringEnCoup(s);
        if (aux >= 11) and (aux <= 88) then result := result+[aux];
      end;
    c := GetNextChar(true);
    inc(compteur);
  until (c <> '[') or (compteur >= 1000);
  RevientEnArriereDansFichier(1);

  LitArgumentOfPropertyEnSquareSet := result;
end;

function LitArgumentOfPropertyEnChar : char;
var s : String255;
begin
  s := LitArgumentOfPropertyEnChaine(false);
  LitArgumentOfPropertyEnChar := s[1];
end;

function LitArgumentVideOfProperty : boolean;
var s : String255;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  LitArgumentVideOfProperty := (s = '');
end;


function LitArgumentOfPropertyEnBooleen : boolean;
var s : String255;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  LitArgumentOfPropertyEnBooleen := (s = 'true');
end;


function ReadLongintProperty(genre : SInt16) : Property;
begin
  ReadLongintProperty := MakeLongintProperty(genre,LitArgumentOfPropertyEnLongint);
end;


function ReadOthelloValueProperty(genre : SInt16; avecRedressement : boolean) : Property;
var s,s1,appName,version : String255;
    couleur,signe : SInt16;
    integerValue,centiemes : SInt32;
    realValue : double;
begin
  s := LitArgumentOfPropertyEnChaine(true);
  s1 := s;

  {Cas particuliers : gain noir et gain blanc}
  if (s = 'B+') or ((genre = NodeValueProp) and (s = 'B+1')) then
    begin
      ReadOthelloValueProperty := MakeValeurOthelloProperty(genre, pionNoir, +1, 1, 0);
      exit;
    end;
  if (s = 'W+') or ((genre = NodeValueProp) and (s = 'W+1')) then
    begin
      ReadOthelloValueProperty := MakeValeurOthelloProperty(genre, pionBlanc, +1, 1, 0);
      exit;
    end;

  {WriteDansRapport('s = '+s);}

  {valeurs par defaut}
  couleur := pionNoir;  {conforme à la thèse de Kierulf}
  signe := +1;
  integerValue := 0;
  centiemes := 0;

  if (s[1] = 'B') or (s[1] = 'b') then
    begin
      couleur := pionNoir;
      s := TPCopy(s,2,LENGTH_OF_STRING(s)-1);
    end else
  if (s[1] = 'W') or (s[1] = 'w') then
    begin
      couleur := pionBlanc;
      s := TPCopy(s,2,LENGTH_OF_STRING(s)-1);
    end else
  if (s[1] = 'D') or (s[1] = 'd') then
    begin
      couleur := pionVide;
      s := TPCopy(s,2,LENGTH_OF_STRING(s)-1);
    end;

  if (s[1] = '-') then
    begin
      signe := -1;
      s := TPCopy(s,2,LENGTH_OF_STRING(s)-1);
    end else
  if (s[1] = '+') then
    begin
      signe := +1;
      s := TPCopy(s,2,LENGTH_OF_STRING(s)-1);
    end;


  realValue := StringSimpleEnReel(s);

  {WritelnStringAndReelDansRapport('s = '+s+' =>  realValue = ',realValue,5);}

  integerValue := Trunc(realValue);
  centiemes := Trunc(100*(realValue-1.0*integerValue )+0.499);

  {cas particulier : les EL[valeur] de Cassio étaient auparavant
   stockees comme des entiers, on divise par 100}
  if (genre = ComputerEvaluationProp) and
     (Pos('.',s) = 0) and (centiemes = 0) and
     GetApplicationNameDansArbre(appName,version) and
     (Pos('Cassio',appName) > 0) then
    begin
      if (integerValue >= 0)
        then centiemes := integerValue mod 100
        else centiemes := -((-integerValue) mod 100);
      integerValue := integerValue div 100;
    end;

  if (genre = NodeValueProp) and odd(integerValue) then
    begin
      WritelnDansRapport('WARNING : note impaire dans V['+s1+'], je corrige');
      if integerValue > 0
        then inc(integerValue)
        else dec(integerValue);
    end;

  if avecRedressement and (signe < 0)
    then ReadOthelloValueProperty := MakeValeurOthelloProperty(genre,-couleur,-signe,integerValue,centiemes)
    else ReadOthelloValueProperty := MakeValeurOthelloProperty(genre, couleur, signe,integerValue,centiemes);
end;


function ReadRealProperty(genre : SInt16) : Property;
begin
  ReadRealProperty := MakeRealProperty(genre,LitArgumentOfPropertyEnReel);
end;


function ReadStringProperty(genre : SInt16) : Property;
begin
  ReadStringProperty := MakeStringProperty(genre,LitArgumentOfPropertyEnChaine(false));
end;


function ReadSquareAndStringProperty(genre : SInt16) : Property;
var result : Property;
begin
  result := MakeStringProperty(genre,LitArgumentOfPropertyEnChaine(false));
  result.stockage := StockageEnCaseOthelloAlpha;
  ReadSquareAndStringProperty := result;
end;



function ReadSquareProperty(genre : SInt16) : Property;
var whichSquare : SInt16;
begin
  whichSquare := LitArgumentOfPropertyEnCoup;
  if (genre = BlackMoveProp) and (whichSquare = CoupSpecialPourPasse) then ReadSquareProperty := MakeArgumentVideProperty(BlackPassProp) else
  if (genre = WhiteMoveProp) and (whichSquare = CoupSpecialPourPasse) then ReadSquareProperty := MakeArgumentVideProperty(WhitePassProp) else
  ReadSquareProperty := MakeOthelloSquareProperty(genre,whichSquare)
end;


function ReadArgumentVideProperty(genre : SInt16) : Property;
begin
  if LitArgumentVideOfProperty then DoNothing;
  ReadArgumentVideProperty := MakeArgumentVideProperty(genre);
end;


function ReadSquareSetProperty(genre : SInt16) : Property;
begin
  ReadSquareSetProperty := MakeSquareSetProperty(genre,LitArgumentOfPropertyEnSquareSet);
end;


function ReadSquareCoupleProperty(genre : SInt16) : Property;
var whichSquare1,whichSquare2 : SInt16;
    s,s1,s2 : String255;
    oldParsingSet : SetOfChar;
begin
	s := LitArgumentOfPropertyEnChaine(true);

	oldParsingSet := GetParserDelimiters;
	SetParserDelimiters([':']);
	Parse(s,s1,s2);
	SetParserDelimiters(oldParsingSet);

	whichSquare1 := StringEnCoup(s1);
	whichSquare2 := StringEnCoup(s2);

  ReadSquareCoupleProperty := MakeSquareCoupleProperty(genre,whichSquare1,whichSquare2);
end;


function ReadTripleProperty(genre : SInt16) : Property;
begin
  ReadTripleProperty := MakeTripleProperty(genre,LitArgumentOfPropertyEnTriple);
end;


function ReadBooleanProperty(genre : SInt16) : Property;
begin
  ReadBooleanProperty := MakeBooleanProperty(genre,LitArgumentOfPropertyEnBooleen);
end;

function ReadCharProperty(genre : SInt16) : Property;
begin
  ReadCharProperty := MakeCharProperty(genre,LitArgumentOfPropertyEnChar);
end;


procedure ReadArgumentOfTexteProperty(var prop : Property; TailleMaximumDuTexte : SInt32);
var c : char;
    s : String255;
    compteur,longueurTotaleDuTexte : SInt32;
begin
  with LectureSmartGameBoard do
    begin
		  longueurTotaleDuTexte := prop.taille;

		  repeat
		    s := '';
		    c := GetNextChar(false);
		    compteur := 1;
		    inc(longueurTotaleDuTexte);

		    while not((c = ']') and (avantDernierCaractereLu <> '\')) and
		          (longueurTotaleDuTexte < TailleMaximumDuTexte) and
		          (compteur < 200) and not(QuitterLecture) do
		    begin
		      if not((c = '\') and (avantDernierCaractereLu <> '\')) then
				    begin
				      s := Concat(s,c);
				      inc(longueurTotaleDuTexte);
				      inc(compteur);

				      {ne pas lire deux \ dans les sequences du genre \\\[ }
		          if (c = '\') and (avantDernierCaractereLu = '\') then
		            begin
		              dernierCaractereLu := chr(0);
		              avantDernierCaractereLu := chr(0);
		            end;
				    end;

		      c := GetNextChar(false);
		    end;

		    if (c = ']') and (avantDernierCaractereLu <> '\')
		      then AddStringToTexteProperty(prop,s)
		      else AddStringToTexteProperty(prop,Concat(s,c));

		  until ((c = ']') and (avantDernierCaractereLu <> '\')) or
		        (longueurTotaleDuTexte >= TailleMaximumDuTexte) or
		        QuitterLecture;

		  if (c <> ']') and (avantDernierCaractereLu <> '\') then
		    repeat
		      c := GetNextChar(false);
		    until (c = ']') or LectureSmartGameBoard.QuitterLecture;
		end;

end;


function ReadTexteProperty(genre : SInt16; TailleMaximumDuTexte : SInt32) : Property;
var aux : Property;
begin
  aux := MakeTexteProperty(genre,NIL,0);
  ReadArgumentOfTexteProperty(aux,TailleMaximumDuTexte);
  ReadTexteProperty := aux;
end;


function ReadRapportProperty(genre : SInt16) : Property;
var aux : Property;
    textePtr : Ptr;
    longueurTexte,ancienPointDInsertion : SInt32;
    fichier : basicfile;
begin
  aux := MakeTexteProperty(RapportProp,NIL,0);
  ReadArgumentOfTexteProperty(aux,32500);
  GetTexteOfProperty(aux,textePtr,longueurTexte);
  ancienPointDInsertion := GetPositionPointDinsertion;
  InsereTexteDansRapport(textePtr,longueurTexte);
  if GetFichierTEXTOfFichierAbstraitPtr(@LectureSmartGameBoard.theFile,fichier) = NoErr then
    begin
      AppliquerStyleDuFichierAuRapport(fichier,ancienPointDInsertion,GetPositionPointDinsertion);
      WritelnDansRapport('');
    end;
  if (genre = GameCommentProp) and (longueurTexte > 0) and (longueurTexte < 500)
    then ReadRapportProperty := MakeTexteProperty(GameCommentProp,textePtr,longueurTexte)
    else ReadRapportProperty := MakeEmptyProperty;

  DisposePropertyStuff(aux);
end;

function ReadUnknownProperty(propertyName : String255) : Property;
var prop : Property;
    c : char;
begin
  prop := MakeTexteProperty(VerbatimProp,NIL,0);
  AddStringToTexteProperty(prop,concat(propertyName,'['));
  repeat
    ReadArgumentOfTexteProperty(prop,32050);
    c := GetNextChar(true);
    RevientEnArriereDansFichier(1);
    if c = '[' then AddStringToTexteProperty(prop,']');
  until (c <> '[') or (prop.Taille >= 32000);
  AddStringToTexteProperty(prop,']');
  ReadUnknownProperty := prop;
end;


function LitProperty : Property;
var prop : Property;
    compteur : SInt16;
    nomProperty : String255;
    propertyGenre : SInt16;
    textePropertyNonReconnue : Ptr;
    longueurPropertyNonReconnue : SInt32;
    c : char;
begin
  nomProperty := '';
  compteur := 0;
  repeat
    c := GetNextChar(true);
    {WritelnDansRapport('LitProperty : lecture de '+c+ ' ( code ascii = '+IntToStr(ord(c))+')');}

    if (c <> '[') then
      begin
        nomProperty := nomProperty+c;
        inc(compteur);
      end;
  until (c = '[') or (c = ']') or (compteur >= 10);

  {WritelnDansRapport('LitProperty : nomProperty = '+nomProperty);}


  if (compteur >= 10) or (c = ']') then
    begin
      if debuggage.lectureSmartGameBoard then
        AlerteSimple('erreur dans la reconnaissance du nom de la propriété : '+nomProperty);
      LitProperty := MakeEmptyProperty;
      exit;
    end;

  propertyGenre := StringToPropertyGenre(nomProperty);

  if (propertyGenre = UnknowProp)
    then propertyGenre := StringToPropertyGenre(sysutils.UpperCase(nomProperty));

  case propertyGenre of
    BlackMoveProp              : prop := ReadSquareProperty(propertyGenre);
    WhiteMoveProp              : prop := ReadSquareProperty(propertyGenre);
    CommentProp                : prop := ReadTexteProperty(propertyGenre,10000);
    NodeNameProp               : prop := ReadStringProperty(propertyGenre);
    NodeValueProp              : prop := ReadOthelloValueProperty(propertyGenre,true);
    CheckMarkProp              : prop := ReadTripleProperty(propertyGenre);
    GoodForBlackProp           : prop := ReadTripleProperty(propertyGenre);
    GoodForWhiteProp 	         : prop := ReadTripleProperty(propertyGenre);
    TesujiProp                 : prop := ReadTripleProperty(propertyGenre);
    BadMoveProp                : prop := ReadTripleProperty(propertyGenre);
    TimeLeftBlackProp          : prop := ReadRealProperty(propertyGenre);
    TimeLeftWhiteProp          : prop := ReadRealProperty(propertyGenre);
    FigureProp                 : prop := ReadArgumentVideProperty(propertyGenre);
    AddBlackStoneProp          : prop := ReadSquareSetProperty(propertyGenre);
    AddWhiteStoneProp          : prop := ReadSquareSetProperty(propertyGenre);
    RemoveStoneProp            : prop := ReadSquareSetProperty(propertyGenre);
    PlayerToPlayFirstProp      : prop := ReadCharProperty(propertyGenre);

    GameNameProp               : prop := ReadStringProperty(propertyGenre);
   {GameCommentProp            : prop := ReadTexteProperty(propertyGenre,10000);}
    GameCommentProp            : prop := ReadRapportProperty(propertyGenre);
    EventProp                  : prop := ReadStringProperty(propertyGenre);
    RoundProp                  : prop := ReadStringProperty(propertyGenre);
    DateProp                   : prop := ReadStringProperty(propertyGenre);
    PlaceProp                  : prop := ReadStringProperty(propertyGenre);
    BlackPlayerNameProp        : prop := ReadStringProperty(propertyGenre);
    WhitePlayerNameProp        : prop := ReadStringProperty(propertyGenre);
    ResultProp                 : prop := ReadStringProperty(propertyGenre);
    UserProp                   : prop := ReadStringProperty(propertyGenre);
    TimeLimitByPlayerProp      : prop := ReadStringProperty(propertyGenre);
    SourceProp                 : prop := ReadStringProperty(propertyGenre);

    GameNumberIDProp           : prop := ReadLongintProperty(propertyGenre);
    BoardSizeProp              : prop := ReadLongintProperty(propertyGenre);
    PartialViewProp            : prop := ReadSquareSetProperty(propertyGenre);
    BlackSpeciesProp           : prop := ReadLongintProperty(propertyGenre);
    WhiteSpeciesProp           : prop := ReadLongintProperty(propertyGenre);
    ComputerEvaluationProp     : prop := ReadOthelloValueProperty(propertyGenre,false);
    ZebraBookProp              : prop := ReadOthelloValueProperty(propertyGenre,false);
    ExpectedNextMoveProp       : prop := ReadSquareProperty(propertyGenre);

    SelectedPointsProp         : prop := ReadSquareSetProperty(propertyGenre);
    MarkedPointsProp           : prop := ReadSquareSetProperty(propertyGenre);
    LabelOnPointsProp          : prop := ReadSquareAndStringProperty(propertyGenre);

    BlackRankProp              : prop := ReadStringProperty(propertyGenre);
    WhiteRankProp              : prop := ReadStringProperty(propertyGenre);
    HandicapProp               : prop := ReadLongintProperty(propertyGenre);
    KomiProp                   : prop := ReadRealProperty(propertyGenre);

    BlackTerritoryProp         : prop := ReadSquareSetProperty(propertyGenre);
    WhiteTerritoryProp         : prop := ReadSquareSetProperty(propertyGenre);
    SecureStonesProp           : prop := ReadSquareSetProperty(propertyGenre);
    RegionOfTheBoardProp       : prop := ReadSquareSetProperty(propertyGenre);

    PerfectScoreProp           : prop := ReadOthelloValueProperty(propertyGenre,true);
    OptimalScoreProp           : prop := ReadOthelloValueProperty(propertyGenre,true);
    EmptiesForOptimalScoreProp : prop := ReadLongintProperty(propertyGenre);

    DeltaWhiteProp             : prop := ReadSquareSetProperty(propertyGenre);
    DeltaBlackProp             : prop := ReadSquareSetProperty(propertyGenre);
    DeltaProp                  : prop := ReadSquareSetProperty(propertyGenre);
    LosangeWhiteProp           : prop := ReadSquareSetProperty(propertyGenre);
    LosangeBlackProp           : prop := ReadSquareSetProperty(propertyGenre);
   {LosangeProp                : prop := ReadSquareSetProperty(propertyGenre);
    CarreWhiteProp             : prop := ReadSquareSetProperty(propertyGenre);
    CarreBlackProp             : prop := ReadSquareSetProperty(propertyGenre);}
    CarreProp                  : prop := ReadSquareSetProperty(propertyGenre);
    EtoileProp                 : prop := ReadSquareSetProperty(propertyGenre);
    PetitCercleWhiteProp       : prop := ReadSquareSetProperty(propertyGenre);
    PetitCercleBlackProp       : prop := ReadSquareSetProperty(propertyGenre);
    PetitCercleProp            : prop := ReadSquareSetProperty(propertyGenre);
    TranspositionProp          : prop := ReadStringProperty(propertyGenre);
    RapportProp                : prop := ReadRapportProperty(propertyGenre);
    BlackPassProp              : prop := ReadArgumentVideProperty(propertyGenre);
    WhitePassProp              : prop := ReadArgumentVideProperty(propertyGenre);
    ValueMinProp               : prop := ReadLongintProperty(propertyGenre);
    ValueMaxProp               : prop := ReadLongintProperty(propertyGenre);
    SigmaProp                  : prop := ReadTripleProperty(propertyGenre);
    TimeTakenProp              : prop := ReadRealProperty(propertyGenre);

    WhiteTeamProp              : prop := ReadStringProperty(propertyGenre);
    BlackTeamProp              : prop := ReadStringProperty(propertyGenre);
    OpeningNameProp            : prop := ReadStringProperty(propertyGenre);
    FileFormatProp             : prop := ReadLongintProperty(propertyGenre);
    FlippedProp                : prop := ReadSquareSetProperty(propertyGenre);
    DrawMarkProp               : prop := ReadTripleProperty(propertyGenre);
    InterestingMoveProp        : prop := ReadArgumentVideProperty(propertyGenre);
    DubiousMoveProp            : prop := ReadArgumentVideProperty(propertyGenre);
    ExoticMoveProp             : prop := ReadArgumentVideProperty(propertyGenre);
    UnclearPositionProp        : prop := ReadTripleProperty(propertyGenre);
    DepthProp                  : prop := ReadLongintProperty(propertyGenre);

    {propriétés définies dans SGF FF[4]}
    HotSpotProp                : prop := ReadLongintProperty(propertyGenre);
    PDProp                     : prop := ReadLongintProperty(propertyGenre);
    ApplicationProp            : prop := ReadStringProperty(propertyGenre);
    CharSetProp                : prop := ReadStringProperty(propertyGenre);
    StyleOfDisplayProp         : prop := ReadLongintProperty(propertyGenre);
    DimPointsProp              : prop := ReadSquareSetProperty(propertyGenre);
    CopyrightProp              : prop := ReadStringProperty(propertyGenre);
    AnnotatorProp              : prop := ReadStringProperty(propertyGenre);
    ArrowProp                  : prop := ReadSquareCoupleProperty(propertyGenre);
    LineProp                   : prop := ReadSquareCoupleProperty(propertyGenre);

    otherwise
      begin
       {prop := MakeEmptyProperty;
        argumentPropertyNonReconnue := LitArgumentOfPropertyEnChaine(false);}

        prop := ReadUnknownProperty(nomProperty);

        if LectureSmartGameBoard.reportErrors then
          begin
            WritelnDansRapport('erreur : lecture d''une propriété inconnue !!');
            WritelnDansRapport('nomProperty = '+nomProperty);
            GetTexteOfProperty(prop,textePropertyNonReconnue,longueurPropertyNonReconnue);
            InsereTexteDansRapport(textePropertyNonReconnue,longueurPropertyNonReconnue);
            WritelnDansRapport('');
          end;


      end;
  end;   {case}

  if debuggage.lectureSmartGameBoard then
    WritelnStringAndPropertyDansRapport('prop = ',prop);

  {on saute les proprietes Sigma[3] qui denotent des noeuds "virtuels"}
  (* if (prop.genre = SigmaProp) and (GetTripleOfProperty(prop).nbTriples >= 3)
    then
      begin
        DisposePropertyStuff(prop);
        LitProperty := MakeEmptyProperty;
      end
    else *)
      LitProperty := prop;
end;


procedure LitEtAjoutePropertyListACeNoeud(var G : GameTree);
var prop : Property;
    c : char;
    separateurDeNoeuds : boolean;
    separateurDeGameTree : boolean;
begin
  repeat
    c := GetNextChar(true);
    separateurDeNoeuds := (c = ';');
    separateurDeGameTree := (c = '(') or (c = ')');
    RevientEnArriereDansFichier(1);
    if not(separateurDeNoeuds or separateurDeGameTree) then
      begin
        prop := LitProperty;
        if not(PropertyEstVide(prop)) then AddPropertyToGameTree(prop,G);
        DisposePropertyStuff(prop);
      end;
  until separateurDeNoeuds or separateurDeGameTree or LectureSmartGameBoard.QuitterLecture;
end;


function LitPropertyList : PropertyList;
var result : PropertyList;
    prop : Property;
    c : char;
    separateurDeNoeuds : boolean;
    separateurDeGameTree : boolean;
begin
  result := NIL;

  repeat

    c := GetNextChar(true);
    separateurDeNoeuds := (c = ';');
    separateurDeGameTree := (c = '(') or (c = ')');

    RevientEnArriereDansFichier(1);

    if not(separateurDeNoeuds or separateurDeGameTree) then
      begin

        prop := LitProperty;

        if not(PropertyEstVide(prop)) then
          begin
            if result = NIL then result := NewPropertyList;
            AddPropertyToList(prop,result);
          end;

        DisposePropertyStuff(prop);
      end;
  until separateurDeNoeuds or separateurDeGameTree or LectureSmartGameBoard.QuitterLecture;


  CompacterPropertyList(result);


  LitPropertyList := result;
end;

procedure LectureRecursiveArbre(ArbreDerniereParenthese : GameTree; peutCreerLesSousArbres : boolean);
var c : char;
    propSpeciale : Property;
    G,subtree : GameTree;
    propertiesLues : PropertyList;
    coup : PropertyPtr;
    fils : GameTree;
    positionEtTraitDerniereParenthese : PositionEtTraitRec;
    profondeurDerniereParenthese : SInt32;
    oldPositionInitiale,newPositionInitiale : PositionEtTraitRec;
    jeu : plateauOthello;
    trait,whichSquare : SInt32;
    numeroPremierCoup,nbBlancsInitial,nbNoirsInitial : SInt32;
begin

  with LectureSmartGameBoard do
    begin
      if debuggage.lectureSmartGameBoard then
		     WritelnDansRapport('entree dans LectureRecursiveArbre');

		  positionEtTraitDerniereParenthese := thePosition;
		  profondeurDerniereParenthese := profondeur;

		  if not(QuitterLecture) then
		    repeat
		      c := GetNextChar(true);

		      if debuggage.lectureSmartGameBoard then
		        begin
		         {WriteDansRapport('LectureRecursiveArbre : ');}
		          WriteDansRapport('analyse de '+c);
		         {WriteDansRapport(' (code ascii = '+IntToStr(ord(c))+')');}
		          WriteDansRapport(' : ');
		        end;
		      case c of
		        '(' : begin
		                inc(EmboitementParentheses);
		                if debuggage.lectureSmartGameBoard then
		                  WritelnDansRapport('appel résursif de LectureRecursiveArbre');
		                LectureRecursiveArbre(GetCurrentNode,peutCreerLesSousArbres);
		              end;
		        ';' : begin {A}
		                if not(peutCreerLesSousArbres)
		                  then
		                    begin {B}
		                      PropertiesLues := LitPropertyList;
		                      WritelnStringAndPropertyListDansRapport('Proprietes sautées = ',PropertiesLues);
		                      DisposePropertyList(propertiesLues);
		                    end   {B}
		                  else
		                    begin {B}
					                G := GetCurrentNode;
					                if EstLaRacineDeLaPartie(G) and not(ProprietesDeLaRacinesDejaLues)
					                  then
					                    begin {C}
					                      if debuggage.lectureSmartGameBoard then
					                        WritelnDansRapport('lecture des propriétés de la racine');

					                  {   WritelnDansRapport('•••••••••• DEBUT DE LA LECTURE DES PROPS DE LA RACINE •••••••••••');  }

					                      PropertiesLues := LitPropertyList;

					                  {    WritelnDansRapport('•••••••••• FIN DE LA LECTURE DES PROPS DE LA RACINE •••••••••••');  }

					                      GetPositionInitialeOfGameTree(jeu,numeroPremierCoup,trait,nbBlancsInitial,nbNoirsInitial);
					                      oldPositionInitiale := MakePositionEtTrait(jeu,trait);

					                      if CalculeNouvellePositionInitialeFromThisList(PropertiesLues,jeu,numeroPremierCoup,trait,nbBlancsInitial,nbNoirsInitial)
					                        then
					                          begin {D}
					                            newPositionInitiale := MakePositionEtTrait(jeu,trait);
					                            if not(SamePositionEtTrait(newPositionInitiale,oldPositionInitiale))
					                              then
					                                begin {E}
					                                  if debuggage.lectureSmartGameBoard then
					                                    WritelnDansRapport('positions initiales differentes : destruction de l''ancien arbre de jeu');
					                                  DeleteAllSons(G);
					                                  DisposePropertyList(G^.properties);
					                                  VideTableHashageInterversions;
					                                  avecAlerteSoldeCreationDestructionNonNul := false;
					                                  PlaquerPosition(jeu,trait,kRedessineEcran);
					                                  avecAlerteSoldeCreationDestructionNonNul := true;
					                                end {E}
					                              else
					                                begin {E}
					                                  if debuggage.lectureSmartGameBoard then
					                                    WritelnDansRapport('les positions initiales sont les memes');
					                                end; {E}
					                          end  {D}
					                        else
					                          begin {D}
					                            newPositionInitiale := oldPositionInitiale;
					                          end;  {D}
					                      thePosition := newPositionInitiale;


					                      ConcatPropertyLists(G^.properties,propertiesLues,AllPropertyTypes - TypesPierresDelta,[]);
					                      CalculePositionInitialeFromThisRoot(G);
					                      ProprietesDeLaRacinesDejaLues := true;

					                      DisposePropertyList(propertiesLues);

					                   {   WritelnDansRapport('•••••••••• FIN DE L''UTILISATION DES PROPS DE LA RACINE •••••••••••');  }

					                    end  {C}
					                  else
					                    begin  {C}

					                      if debuggage.lectureSmartGameBoard then
						                      WritelnDansRapport('lecture des propriétés du prochain noeud');

					                      inc(profondeur);

					                   {  WritelnDansRapport('•••••••••• DEBUT DE LA LECTURE D''UNE NOUVELLE LISTE DE PROPS •••••••••••');  }

					                      propertiesLues := LitPropertyList;

					                   {  WritelnStringAndPropertyListDansRapport('•••••••••• FIN DE LA LECTURE D''UNE NOUVELLE LISTE DE PROPS ••••••••••• = ',propertiesLues);  }

					                      coup := SelectFirstPropertyOfTypes([BlackMoveProp,WhiteMoveProp],propertiesLues);

					                      if (coup = NIL)
					                        then
					                          begin  {nouveau fils sans coup !} {D}
					                            if PropertyListEstVide(propertiesLues) or
					                               ((PropertyListLength(propertiesLues) = 1) and InPropertyTypes(propertiesLues^.head.genre,[BlackPassProp,WhitePassProp]))
					                              then
					                                begin  {E}
					                                  (*
					                                  AlerteSimple('Il y a des passes ou des noeuds vides dans ce fichier, je les ignore… (et je modifie donc la structure de l''arbre de Smart Othello Board, mais c''est pas grave)');
					                                  *)
					                                  DisposePropertyList(propertiesLues);
					                                end  {E}
					                              else
					                                begin {E}
								                            if debuggage.lectureSmartGameBoard then
								                              WritelnDansRapport('création d''un nouveau sous-arbre sans coup');

								                            WritelnDansRapport('erreur : lecture d''un noeud sans coup dans le fichier !!');
								                            WritelnStringAndPropertyListDansRapport('La liste des proprietes du noeud en question est : ',propertiesLues);

								                            propSpeciale := MakeArgumentVideProperty(MarquageProp);
								                            AddPropertyToList(propSpeciale,propertiesLues);
								                            subTree := MakeGameTreeFromPropertyList(propertiesLues);
								                            AddSonToGameTree(subTree,G);
								                            SetCurrentNode(SelectFirstSubtreeWithThisProperty(propSpeciale,G), 'LectureRecursiveArbre {1}');
								                            DeletePropertyFromCurrentNode(propSpeciale);
								                            DisposePropertyStuff(propSpeciale);
								                            DisposeGameTree(subTree);
								                            DisposePropertyList(propertiesLues);

					                                end; {E}
					                          end {D}
					                        else
					                          begin  {D}
					                            whichSquare := GetOthelloSquareOfProperty(coup^);
					                            if (whichSquare = CoupSpecialPourPasse)
					                              then
					                                begin  {E}
					                                  (*
					                                  AlerteSimple('Il y a des passes dans ce fichier, je les ignore… (et je modifie donc la structure de l''arbre de Smart Othello Board, mais c''est pas grave)')}
					                                  *)
					                                end  {E}
					                              else
					                                begin {E}

								                            if not(PlayMoveProperty(coup^,thePosition)) then
								                              begin  {F}
								                                AlerteSimple('Coup illégal dans le fichier !! Je saute le sous-arbre correspondant !! Voyez la ligne fautive dans rapport si vous voulez corriger le fichier avec Smart Othello Board.');
								                                WritelnDansRapport('Erreur : coup illégal dans le fichier !!');
								                                WritelnStringAndPropertyListDansRapport('La liste des proprietes du noeud avec le coup illegal est : ',propertiesLues);
								                                WritelnDansRapport('chemin courant menant au coup illégal = '+CoupsDuCheminJusquauNoeudEnString(GetCurrentNode));
								                                DisposePropertyList(propertiesLues);

								                                peutCreerLesSousArbres := false;
								                              end;  {F}

								                            if peutCreerLesSousArbres then
								                              begin  {F}

								                                fils := SelectFirstSubtreeWithThisProperty(coup^,G);

										                            if fils = NIL
										                              then  {nouveau coup : on crée un nouveau fils}
										                                begin  {G}

										                                  if debuggage.lectureSmartGameBoard then
										                                    WritelnDansRapport('création d''un nouveau sous-arbre pour le coup '+PropertyToString(coup^));

										                                  {CompacterPropertyList(propertiesLues);}

													                            subTree := MakeGameTreeFromPropertyListSansDupliquer(propertiesLues);
													                            AddSonToGameTreeSansDupliquer(subTree,G);
													                            SetCurrentNode(subTree, 'LectureRecursiveArbre {2}');

													                            if avecInterversions and (profondeur >= 1) and
														                             (profondeur <= numeroCoupMaxPourRechercheIntervesionDansArbre) then
														                            GererInterversionDeCeNoeud(GetCurrentNode,thePosition);

										                                end  {G}
										                              else
										                                begin  {coup deja existant}  {G}

										                                  if debuggage.lectureSmartGameBoard then
										                                    WritelnDansRapport('ajouts des propriétés au sous-arbre du coup '+PropertyToString(coup^));
										                                  ConcatPropertyLists(fils^.properties,propertiesLues,[],[NodeValueProp,GoodForBlackProp,GoodForWhiteProp]);
										                                  SetCurrentNode(fils, 'LectureRecursiveArbre {3}');
										                                  DisposePropertyList(propertiesLues);

										                                end;  {G}
										                          end; {F}
								                          end; {E}
					                          end; {D}

					                   {  WritelnStringAndPropertyListDansRapport('•••••••••• FIN DE L''UTILISATION DE LA LISTE DU COUP •••••••••••',PropertiesLues);  }


					                    end;  {C}
					             end; {B}
					        end;  {A}
		        ')' : begin
		                if debuggage.lectureSmartGameBoard then
		                  WritelnDansRapport('retour a ArbreDerniereParenthese');

		                dec(EmboitementParentheses);
		                SetCurrentNode(ArbreDerniereParenthese, 'LectureRecursiveArbre {4}');
		                thePosition := positionEtTraitDerniereParenthese;
		                profondeur := profondeurDerniereParenthese;

		                if debuggage.lectureSmartGameBoard then
		                  WritelnDansRapport('sortie de LectureRecursiveArbre');
		                exit;
		              end;
		         otherwise
		               WritelnDansRapport('erreur : caractere non traité = '+c+ ' (code ascii = '+IntToStr(ord(c))+')');
		      end; {case}

		    until (EmboitementParentheses <= 0) or QuitterLecture;
	  end;
end;


function LectureSmartGameBoardEnCours : boolean;
begin
  LectureSmartGameBoardEnCours := LectureSmartGameBoard.enCours;
end;



procedure BeginLectureSmartGameBoard(whichFichierAbstrait : FichierAbstrait);
begin
  with LectureSmartGameBoard do
    begin
      theFile                        := whichFichierAbstrait;
      QuitterLecture                 := false;
      dernierCaractereLu             := chr(0);
      avantDernierCaractereLu        := chr(0);
      compteurCaracteres             := 0;
      EmboitementParentheses         := 0;
      profondeur                     := 0;
      ProprietesDeLaRacinesDejaLues  := false;
      enCours                        := true;
      reportErrors                   := true;
      MemoryFillChar(@buffer,sizeof(buffer),chr(0));
      premierOctetDansBuffer         := -1;
      dernierOctetDansBuffer         := -1;
    end;
end;


procedure EndLectureSmartGameBoard;
begin
  with LectureSmartGameBoard do
    begin
      compteurCaracteres := 0;
      enCours            := false;
      reportErrors       := true;
    end;
end;


procedure LitFormatSmartGameBoard(G : GameTree; whichFichierAbstrait : FichierAbstrait);
var TaillePlusGrandBloc,grow : Size;
    temp : boolean;
    tickDepart : SInt32;
begin {$UNUSED tickDepart}

  if not(LectureSmartGameBoardEnCours) then
    begin

      temp := gEnEntreeSortieLongueSurLeDisque;
      gEnEntreeSortieLongueSurLeDisque := true;

      {on compacte la memoire}
      TaillePlusGrandBloc := MaxMem(grow);

      {$IFC USE_PROFILER_SMART_GAME_BOARD}
      if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr
        then ProfilerSetStatus(1);
      {$ENDC}

      {$IFC UTILISE_MINIPROFILER_LECTURE_SMART_GAME_BOARD}
      tickDepart := TickCount;
      InitMiniProfiler;
      {$ENDC}

      BeginLectureSmartGameBoard(whichFichierAbstrait);
      LectureSmartGameBoard.thePosition := MakeEmptyPositionEtTrait;

      LectureRecursiveArbre(G,true);

      EndLectureSmartGameBoard;


      {$IFC UTILISE_MINIPROFILER_LECTURE_SMART_GAME_BOARD}
      AfficheMiniProfilerDansRapport(kpourcentage+ktempsMoyen);
      WritelnSoldesCreationsPropertiesDansRapport('');
      WritelnNumDansRapport('temps de lecture Smart Game Board en ticks = ',TickCount-tickDepart);
      {$ENDC}

      {$IFC USE_PROFILER_SMART_GAME_BOARD}
      nomFichierProfileSmartGameBoard := 'lecture_smart_' + IntToStr(Tickcount div 60) + '.profile';
      WritelnDansRapport('nomFichierProfileSmartGameBoard = '+nomFichierProfileSmartGameBoard);
      if ProfilerDump(nomFichierProfileSmartGameBoard) <> NoErr
        then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfileSmartGameBoard+') a échoué !')
        else ProfilerSetStatus(0);
      ProfilerTerm;
      {$ENDC}

      gEnEntreeSortieLongueSurLeDisque := temp;

    end;
end;




function EstUneFichierAbstraitAuFormatSmartGameBoard(whichFichierAbstrait : FichierAbstrait) : boolean;
var c1,c2 : char;
    oldPosition : SInt32;
begin

  if not(FichierAbstraitEstCorrect(whichFichierAbstrait)) or LectureSmartGameBoardEnCours then
    begin
      EstUneFichierAbstraitAuFormatSmartGameBoard := false;
      exit;
    end;


  BeginLectureSmartGameBoard(whichFichierAbstrait);

  oldPosition := whichFichierAbstrait.position;
  c1 := GetNextChar(true);
  c2 := GetNextChar(true);
  if SetPositionMarqueurFichierAbstrait(whichFichierAbstrait,oldPosition) = NoErr then DoNothing;

  EndLectureSmartGameBoard;

  EstUneFichierAbstraitAuFormatSmartGameBoard := (c1 = '(') and (c2 = ';');
end;


function EstUnFichierAuFormatSmartGameBoard(nomFichier : String255 ; vRefNum : SInt16) : boolean;
var theFile : FichierAbstrait;
begin
  theFile := MakeFichierAbstraitFichier(nomFichier,vRefNum);
  EstUnFichierAuFormatSmartGameBoard := EstUneFichierAbstraitAuFormatSmartGameBoard(theFile);
  if FichierAbstraitEstCorrect(theFile) then DisposeFichierAbstrait(theFile);
end;


{Ecriture au format SmartGameBoard}

function EcrireAvecProtectionCaracteresStructureSGF(text : Ptr; var nbOctets : SInt32) : OSErr;
var i : SInt32;
    c : char;
    table : PackedArrayOfCharPtr;
    err : OSErr;
    s : String255;
    longueur : SInt32;
begin

  with EcritureSmartGameBoard do
    begin
      {InsereTexteDansRapport(text,nbOctets);}
      table := PackedArrayOfCharPtr(text);
		  for i := 0 to nbOctets-1 do
		    begin
		      c := table^[i];
		      case c of
		        '[',']',';','(',')','\'  :
		           begin
		             s := Concat('\',c);
		             longueur := 2;
		             {WriteDansRapport(s);}
		             err := EcrireFichierAbstrait(theFile,-1,@s[1],longueur);
		           end;
		         otherwise
		           begin
		             (* attention ! A cause d'un bug dans la library Pascal de CodeWarrior,
		                l'affectation s := CharToString(c)  ne marche pas si "c" est le
		                caractere nul, il faut donc fabriquer la chaine a la main   *)

		             SET_LENGTH_OF_STRING(s,1);
		             s[1] := c;

		             longueur := 1;
		             {WriteDansRapport(s);}
		             err := EcrireFichierAbstrait(theFile,-1,@s[1],longueur);
		           end;
		      end; {case}
		    end;
		  {WritelnDansRapport('');}
		end;

  EcrireAvecProtectionCaracteresStructureSGF := err;

end;

procedure EcritProperty(var prop : Property; var positionCurseurEcriture : SInt32; var continuer : boolean);
var propName : String255;
    propValue : String255;
    err : OSErr;
    textePtr : Ptr;
    longueurTexte : SInt32;
begin
  if not(PropertyEstVide(prop)) then
    with EcritureSmartGameBoard do
      begin
        if prop.genre = VerbatimProp then
          begin
            GetTexteOfProperty(prop,textePtr,longueurTexte);
            err := EcrireFichierAbstrait(theFile,-1,textePtr,longueurTexte);


            positionCurseurEcriture := theFile.position;
            continuer := (err = NoErr);
            exit;
          end;

	      if prop.stockage = StockageEnTexte
	        then
	          begin
	            propName := PropertyTypeToString(prop.genre);
	            GetTexteOfProperty(prop,textePtr,longueurTexte);

				      err := WriteDansFichierAbstrait(theFile,propName+'[');
				      err := EcrireAvecProtectionCaracteresStructureSGF(textePtr,longueurTexte);
				      err := WriteDansFichierAbstrait(theFile,']');

				      positionCurseurEcriture := theFile.position;
				      continuer := (err = NoErr);
	          end
	        else
	          begin
	            propName := PropertyTypeToString(prop.genre);
				      propValue := PropertyValueToString(prop);

				      err := WriteDansFichierAbstrait(theFile,propName);

				      if (prop.stockage = StockageEnStr255)
				        then
				          begin
				            longueurTexte := LENGTH_OF_STRING(propValue) - 2;
				            err := WriteDansFichierAbstrait(theFile,'[');
				            err := EcrireAvecProtectionCaracteresStructureSGF(@propValue[2],longueurTexte);
				            err := WriteDansFichierAbstrait(theFile,']');
				          end
				        else
				          begin
				            err := WriteDansFichierAbstrait(theFile,propValue);
				          end;


				      positionCurseurEcriture := theFile.position;
				      continuer := (err = NoErr);
	          end;
      end;
end;

procedure EcritPropertyList(L : PropertyList);
begin
  if (L <> NIL) then
    with EcritureSmartGameBoard do
      ForEachPropertyOfTheseTypesDoAvecResult(L,typesDePropertyAEcrire,EcritProperty,compteurCaracteres);
end;


procedure EcritureRecursiveParenthesesEtArbre(var G : GameTree); forward; {pour gerer les fonctions mutuellement recursives}


procedure EcritureRecursiveArbre(var G : GameTree);
var err : OSErr;
    i : SInt16;
begin
  if (G <> NIL) then
    with EcritureSmartGameBoard do
    begin

      if IsAVirtualNodeUsedForZebraBookDisplay(G)
        then exit;

      (* un petit peu de formatage : on rajoute des espaces et
         et sauts de ligne pour faciliter l'edition du fichier *)
      if AvecPrettyPrinter then
	      if (GetCouleurOfMoveInNode(G) = pionNoir) then
	        begin
	          inc(CompteurDeCoupsNoirsEcrits);
	          if CompteurDeCoupsNoirsEcrits >= 3 then
	            begin
	              err := WritelnDansFichierAbstrait(theFile,'');
	              inc(CompteurCaracteres);

	              for i := 1 to EmboitementParentheses do
	                begin
	                  err := WriteDansFichierAbstrait(theFile,' ');
	                  inc(CompteurCaracteres);
	                end;

	              CompteurDeCoupsNoirsEcrits := 0;
	            end;
	        end;

      (* et maintenant la vraie ecriture au format SGF *)
      err := WriteDansFichierAbstrait(theFile,';');
      inc(CompteurCaracteres);

      EcritPropertyList(G^.properties);

      if (NumberOfSons(G) - NumberOfVirtualNodesUsedForZebraBookDisplay(G) >= 2)
        then ForEachGameTreeInListDo(G^.sons,EcritureRecursiveParenthesesEtArbre)
        else ForEachGameTreeInListDo(G^.sons,EcritureRecursiveArbre);
    end;
end;


procedure EcritureRecursiveParenthesesEtArbre(var G : GameTree);
var err : OSErr;
    i : SInt32;
begin
  with EcritureSmartGameBoard do
    begin

      if IsAVirtualNodeUsedForZebraBookDisplay(G)
        then exit;

      CompteurDeCoupsNoirsEcrits := 0;

		  err := WritelnDansFichierAbstrait(theFile,'');
		  inc(CompteurCaracteres);

		  (* formatage *)
		  if AvecPrettyPrinter then
			  for i := 1 to EmboitementParentheses do
	        begin
	          err := WriteDansFichierAbstrait(theFile,' ');
	          inc(CompteurCaracteres);
	        end;

		  err := WriteDansFichierAbstrait(theFile,'(');
		  inc(CompteurCaracteres);

		  inc(EmboitementParentheses);
		  EcritureRecursiveArbre(G);
		  dec(EmboitementParentheses);

		  err := WriteDansFichierAbstrait(theFile,')');
		  inc(CompteurCaracteres);
		end;
end;



procedure EcritFormatSmartGameBoard(G : GameTree; var whichFichierAbstrait : FichierAbstrait);
begin
  with EcritureSmartGameBoard do
    begin
      theFile                          := whichFichierAbstrait;
      QuitterEcriture                  := false;
      DernierCaractereEcrit            := chr(0);
      compteurCaracteres               := 0;
      EmboitementParentheses           := 0;
      profondeur                       := 0;
      ProprietesDeLaRacinesDejaEcrites := false;
      AvecPrettyPrinter                := false;
      typesDePropertyAEcrire           := AllPropertyTypes - [MarquageProp,PointeurPropertyProp,FinVarianteProp,EmbranchementProp,ContinuationProp,TranspositionRangeProp,ZebraBookProp(*,SigmaProp*)];
    end;
  EcritureRecursiveParenthesesEtArbre(G);

  EcritureSmartGameBoard.compteurCaracteres := 0;
end;


function GetPositionInitialeEtPartieDansFichierSmartGameBoard(var fic : basicfile; var posInitiale : PositionEtTraitRec; var coups : String255) : OSErr;
begin
  GetPositionInitialeEtPartieDansFichierSmartGameBoard := GetPositionInitialeEtPartieDansFichierSGF_ou_GGF_8x8(fic,kTypeFichierSGF,posInitiale,coups);
end;


procedure SauvegarderDatabaseOfRecentSGFFiles;
var filename : String255;
    erreurES : OSErr;
    fic : basicfile;
    s : String255;
    i : SInt32;
begin
  filename := 'RecentSGFFilesList.txt';
  erreurES := FichierTexteDeCassioExiste(filename,fic);
  if erreurES = fnfErr  {-43 => File not found}
    then erreurES := CreeFichierTexteDeCassio(fileName,fic);
  if erreurES = NoErr {le fichier de la liste des fichiers preference existe : on l'ouvre et on le vide}
    then
      begin
        erreurES := OpenFile(fic);
        erreurES := EmptyFile(fic);
      end;
  if erreurES <> 0 then exit;

  for i := 1 to kMaxRecentSGFFiles do
    if (gDatabaseRecentSGFFiles[i].date <> '') and
       (gDatabaseRecentSGFFiles[i].name <> '') then
      begin
        s := gDatabaseRecentSGFFiles[i].date + ' ' + gDatabaseRecentSGFFiles[i].name;
        erreurES := Writeln(fic,s);
      end;

  erreurES := CloseFile(fic);
end;


procedure LireDatabaseOfRecentSGFFiles;
var filename : String255;
    erreurES : OSErr;
    fic : basicfile;
    s : String255;
    i,nbPrefFiles : SInt32;
begin

  for i := 1 to kMaxRecentSGFFiles do
    begin
      gDatabaseRecentSGFFiles[i].date := '';
      gDatabaseRecentSGFFiles[i].name := '';
    end;

  filename := 'RecentSGFFilesList.txt';
  erreurES := FichierTexteDeCassioExiste(filename,fic);
  if erreurES = NoErr
    then erreurES := OpenFile(fic);
  if erreurES <> 0 then exit;


  nbPrefFiles := 0;
  repeat
    erreurES := ReadlnDansFichierTexte(fic,s);
    if (s <> '') and (erreurES = NoErr) then
      begin
        inc(nbPrefFiles);
        Parse(s,gDatabaseRecentSGFFiles[nbPrefFiles].date,gDatabaseRecentSGFFiles[nbPrefFiles].name);
      end;
  until (nbPrefFiles >= kMaxRecentSGFFiles) or (erreurES <> NoErr) or EndOfFile(fic,erreurES);

  erreurES := CloseFile(fic);
end;


procedure AjouterNomDansDatabaseOfRecentSGFFiles(const whichDate,whichName : String255);
var i,indexCourant : SInt32;
begin

  if not(EstUnNomDeFichierTemporaireDePressePapier(whichName)) then
    begin

      LireDatabaseOfRecentSGFFiles;

      {chercher quel enregistrement ecraser}
      indexCourant := kMaxRecentSGFFiles;
      for i := kMaxRecentSGFFiles downto 1 do
        if gDatabaseRecentSGFFiles[i].name = whichName then
          indexCourant := i;

      {placer le nom courant en tete}
      for i := indexCourant downto 2 do
        begin
          gDatabaseRecentSGFFiles[i].date := gDatabaseRecentSGFFiles[i-1].date;
          gDatabaseRecentSGFFiles[i].name := gDatabaseRecentSGFFiles[i-1].name;
        end;
      gDatabaseRecentSGFFiles[1].date := whichDate;
      gDatabaseRecentSGFFiles[1].name := whichName;

      SauvegarderDatabaseOfRecentSGFFiles;
    end;
end;


function FichierExisteDansDatabaseOfRecentSGFFiles(whichName : String255; var modificationDate : String255) : boolean;
var i : SInt32;
begin

  if (whichName <> '') and not(EstUnNomDeFichierTemporaireDePressePapier(whichName)) then
    begin
      LireDatabaseOfRecentSGFFiles;
      for i := 1 to kMaxRecentSGFFiles do
        if (gDatabaseRecentSGFFiles[i].name = whichName) then
          begin
            FichierExisteDansDatabaseOfRecentSGFFiles := true;
            modificationDate := gDatabaseRecentSGFFiles[i].date;
            exit;
          end;
    end;

  FichierExisteDansDatabaseOfRecentSGFFiles := false;
  modificationDate := '';
end;


end.























