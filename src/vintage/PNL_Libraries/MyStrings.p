UNIT MyStrings;

INTERFACE







 USES
     UnitDefCassio;

	procedure KeepPrefix (var s : String255; len : SInt32);
	procedure LeftAssignP (var s : String255; len : SInt16; var rhs : String255);
	procedure KeepSuffix (var s : String255; len : SInt32);
	procedure RightAssignP (var s : String255; len : SInt16; var rhs : String255);
	
	function LeftStr (const s : String255; len : SInt32) : String255;
	function LeftAssign (var s : String255; len : SInt16; var rhs : String255) : String255;
	function RightStr (const s : String255; len : SInt16) : String255;
	function RightAssign (var s : String255; len : SInt16; var rhs : String255) : String255;
	
	procedure MidP (var s : String255; p, len : SInt16);
	procedure MidAssignP (var s : String255; p, len : SInt16; const rhs : String255);
	
	function Mid (var s : String255; p, len : SInt16) : String255;
	function MidAssign (const s : String255; p, len : SInt16; const rhs : String255) : String255;
	
	
	procedure HandleToString (hhhh : UnivHandle; var s : String255);
	function HandleToStr (hhhh : UnivHandle) : String255;
	procedure StringToHandle (const s : String255; hhhh : UnivHandle);
	
	
	function Trim (s : String255) : String255;



	procedure UpCaseString (var s : String255);
	procedure LowerCaseString (var s : String255);
	
	function UpCaseStr (s : String255) : String255;
	function LowerCaseStr (s : String255) : String255;

	function NoCaseEquals( s1, s2 : String255 ) : boolean;
	function NoCasePos( s1, s2 : String255 ) : SInt16;

	procedure SPrintS5(var dst: String255; const src, s1, s2, s3, s4, s5 : String255);
	procedure SPrintS3(var dst: String255; const src, s1, s2, s3:  String255);

	function PosRight (sub : char; const s : String255) : SInt16;
	function PosRightStr (const sub, s : String255) : SInt16;
	
	function Contains( sub : char; const s : String255 ) : boolean;
	function ContainsStr( const sub, s : String255 ) : boolean;
	
	procedure SplitByChar (s : String255; sub : char; var left, right: String255);
	procedure SplitRightByChar (s : String255; sub : char; var left, right: String255);
	
	procedure SplitByStr (s : String255; const sub : String255; var left, right: String255);
	procedure SplitRightByStr (s : String255; const sub : String255; var left, right: String255);
	
	function Split (s : String255; sub : char; var s1, s2 : String255) : boolean;
	function SplitRight(s : String255; sub : char; var s1, s2 : String255) : boolean;
	
	function Split (s : String255; const sub : String255; var s1, s2 : String255) : boolean;
	function SplitRight (s : String255; const sub : String255; var s1, s2 : String255) : boolean;

	function FirstPos(const sub, str : String255) : SInt32;
    function LastPos (sub, str : String255) : SInt16;
	function TPCopy (source : String255; start, count: SInt32) : String255;


	function Match (pattern, name: String255) : boolean;
    function StringBeginsWith(const s, pattern : String255) : boolean;
    function EndsWith(const s : String255; const sub : String255) : boolean;
	function EndsWithDeuxPoints(var s : String255) : boolean;


	procedure LimitStringLength (var s : String255; len : SInt16; delimiter : char);
	procedure MySetStringLength (var s : String255; len : SInt16);
    function MyStr255ToString( const s : Str255 ) : String255;


	function StringToOSType (const s : String255) : OSType;
	function OSTypeToString (t : OSType) : String255;
	function FindCharacter(p : Ptr; len : SInt32; ch : char; var pos : SInt32) : boolean;
	function CharInSet(ch : char; mySet : CharSet) : boolean;

	function ReadStringFromRessource(stringListID, index : SInt16) : String255;

	function ReelEnString(unreel : double) : String255;
  function ReelEnStringAvecDecimales(unreel : double; nbChiffresSignificatifs : SInt16) : String255;
  function PourcentageReelEnString(x : double) : String255;
  function ReelEnStringRapide(unreel : double) : String255;
  function StringSimpleEnReel(alpha : String255) : double;
  function PourcentageEntierEnString(num : SInt32) : String255;
  function ChaineEnInteger(const s : String255) : SInt16;
  function StrToInt32(const s : String255) : SInt32;
  procedure ChaineToInteger(const s : String255; var theInteger : SInt16);
  procedure StrToInt32(const s : String255; var theLongint : SInt32);



  function EstUnReel(alpha : String255) : boolean;
  function BigNumEnString(milliards,num : SInt32) : String255;


  function EnleveEspacesDeGauche(const s : String255) : String255;
  function EnleveEspacesDeDroite(const s : String255) : String255;
  procedure EnleveEspacesDeGaucheSurPlace(var s : String255);
  procedure EnleveEspacesDeDroiteSurPlace(var s : String255);
  procedure EnleveEtCompteEspacesDeGauche(var s : String255; var nbEspacesEnleves : SInt16);
  procedure EnleveEtCompteEspacesDeDroite(var s : String255; var nbEspacesEnleves : SInt16);
  procedure EnleveEtCompteCeCaractereAGauche(var s : String255; ch : char; var nbCaracteresEnleves : SInt16);
  procedure EnleveEtCompteCeCaractereADroite(var s : String255; ch : char; var nbCaracteresEnleves : SInt16);
  procedure EnleveEtCompteCeCaractereAGaucheDansBuffer(buffer : Ptr; var tailleBuffer : SInt32; ch : char; var nbCaracteresEnleves : SInt32);
  function CompterOccurencesDeSousChaine(const subString, s : String255) : SInt32;


  function UpperCase(const s : String255; keepDiacritics : boolean) : String255;
  function LowerCase(const s : String255; keepDiacritics : boolean) : String255;
  procedure StripHTMLAccents(var s : String255);


{$ifc not string_accessors_are_macros}
  function MY_LENGTH_OF_STRING(const s : String255) : SInt32;
  procedure MY_SET_LENGTH_OF_STRING(var s : String255; len : SInt32);
{$endc}

  procedure InitUnitMyStrings;

	function ExtraitNomDirectoryOuFichier(chemin : String255) : String255;
	function ExtraitCheminDAcces(nomComplet : String255) : String255;
	function ExtraitNomDeVolume(nomComplet : String255) : String255;
	function EstUnNomDeFichierTronquePourPanther(const nomFichier : String255) : boolean;

	function ChaineMirroir(const s : String255) : String255;
  function ReplaceStringOnce(const s, pattern, replacement : String255) : String255;
  function ReplaceStringAll(const s, pattern,replacement : String255) : String255;

  function DeleteSpacesBefore(const s : String255; p : SInt16) : String255;
  function DeleteSpacesAfter(const s : String255; p : SInt16) : String255;
  procedure ReplaceCharByCharInString(var s : String255; old, new : char);
  procedure TripleRemplacementDeCaractereDansString(var s : String255; old1, new1, old2, new2, old3, new3 : char);



  {le premier argument n'est pas un const ni un var pour pouvoir passer s dans tete ou dans reste}
  procedure Parse(s : String255; var tete,reste : String255);
  procedure Parse2(s : String255; var s1,s2,reste : String255);
  procedure Parse3(s : String255; var s1,s2,s3,reste : String255);
  procedure Parse4(s : String255; var s1,s2,s3,s4,reste : String255);
  procedure Parse5(s : String255; var s1,s2,s3,s4,s5,reste : String255);
  procedure Parse6(s : String255; var s1,s2,s3,s4,s5,s6,reste : String255);
  procedure ParseWithQuoteProtection(s : String255; var tete,reste : String255);

  procedure SetParserProtectionWithQuotes(flag : boolean);
  function  GetParserProtectionWithQuotes : boolean;
  procedure SetParserDelimiters(parsingCaracters : SetOfChar);
  function  GetParserDelimiters : SetOfChar;



	function BoolEnString(myBool : boolean) : String255;
  function IntToStrWithPadding(num,nbDeChiffres : SInt32; formatChar : char) : String255;
  function RemoveLeadingZeros(const s : String255) : String255;

  function CharInRange(ch : char; min,max : char) : boolean;
  function ContientUneLettre(const s : String255) : boolean;
  function IsAnArrowKey(ch : char) : boolean;
  function EstUnChiffreHexa(ch : char) : boolean;


  function GarderSeulementLesChiffres(var s : String255) : String255;
	function GarderSeulementLesChiffresOuLesPoints(var s : String255) : String255;
  function EnleverTousLesChiffres(var s : String255) : String255;
  function EnleverLesCaracteresMajusculesEntreCesCaracteres(gauche, droite : char; var s : String255) : String255;

	function ChaineNeContientQueDesChiffres(const s : String255) : boolean;
	function ChaineNeContientQueCesCaracteres(const s : String255; whichChars : SetOfChar) : boolean;
  function ASeulementCeCaractere(c : char; var s : String255) : boolean;


	function EnMinuscule(var s : String255) : String255;
	function ReplaceParameters(s, p0, p1, p2, p3 : String255) : String255;


  procedure MyDeleteString( var s : String255; index, nb_chars_to_delete : SInt32);

  function DeleteSubstringBeforeThisChar(delim : char; const s : String255; keepDelimitor : boolean) : String255;
  function DeleteSubstringAfterThisChar(delim : char; const s : String255; keepDelimitor : boolean) : String255;

  function EnleveChiffresEntreCesCaracteres(delim1,delim2 : char; const s : String255; keepDelimitors : boolean) : String255;
  function EnleveChiffresAvantCeCaractereEnDebutDeLigne(delim : char; const s : String255; keepDelimitor : boolean) : String255;
  function EnleveChiffresApresCeCaractereEnFinDeLigne(delim : char; const s : String255; keepDelimitor : boolean) : String255;

  function EnleveCesCaracteresEntreCesCaracteres(whichChars : SetOfChar; delim1,delim2 : char; const s : String255; keepDelimitors : boolean) : String255;
  function EnleveCesCaracteresAvantCeCaractereEnDebutDeLigne(whichChars : SetOfChar; delim : char; const s : String255; keepDelimitor : boolean) : String255;
  function EnleveCesCaracteresApresCeCaractereEnFinDeLigne(whichChars : SetOfChar; delim : char; const s : String255; keepDelimitor : boolean) : String255;





  function SeparerLesChiffresParTrois(var s : String255) : String255;
  function SecondesEnJoursHeuresSecondes(secondes : SInt32) : String255;


  function BufferToPascalString(buffer : Ptr; indexDepart,indexFin : SInt32) : String255;
  function FindStringInBuffer(const s : String255; buffer : Ptr; bufferLength,from,direction : SInt32; var positionTrouvee : SInt32) : boolean;
  function ParseBuffer(buffer : Ptr; bufferLength, from : SInt32; var indexDernierCaractereLu : SInt32) : String255;


  function PseudoHammingDistance(const s1, s2 : String255) : SInt32;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{$DEFINEC USE_PRELINK true}

USES
    MacMemory, TextUtils, NumberFormatting, Script, UnitRapport, UnitEnvirons
{$IFC NOT(USE_PRELINK)}
    , MyMathUtils ;
{$ELSEC}
    ;
    {$I prelink/MyStrings.lk}
{$ENDC}


{END_USE_CLAUSE}




function BigNumEnString(milliards,num : SInt32) : String255;
var
		s,s1 : String255;
begin
  if milliards = 0
  	then
    	begin
    		s := IntToStr(num);
    		BigNumEnString := s;
    	end
    else
    	begin
    	  if num < 0 then
    	    begin
    	      num := -num;
    	      milliards := -milliards;
    	    end;
    	 	s1 := IntToStr(milliards);
    	 	s := IntToStr(num);
    	 	if num < 100000000 then begin s := Concat('0',s);
    	 	if num <  10000000 then begin s := Concat('0',s);
    	 	if num <   1000000 then begin s := Concat('0',s);
    	 	if num <    100000 then begin s := Concat('0',s);
    	 	if num <     10000 then begin s := Concat('0',s);
    	 	if num <      1000 then begin s := Concat('0',s);
    	 	if num <       100 then begin s := Concat('0',s);
    	 	if num <        10 then begin s := Concat('0',s); end; end; end; end; end; end; end; end;
    		BigNumEnString := Concat(s1,s);
    	end;
end;

function EstUnReel(alpha : String255) : boolean;
	var
		i, nbPoints: SInt16;
		flag: boolean;
begin
	if alpha = '' then
		begin
			EstUnReel := false;
			exit;
		end;

	if Pos('.', alpha) = 0 then
		begin
			i := Pos(',', alpha);
			if i <> 0 then alpha[i] := '.';  {on remplace la virgule par un point}
		end;
	nbPoints := 0;
	flag := true;
	for i := 1 to LENGTH_OF_STRING(alpha) do
		if (IsDigit(alpha[i])
		    or (alpha[i] = '.')
		    or (alpha[i] = 'e')
		    or (alpha[i] = 'E')
		    or (alpha[i] = '-'))
		then {bons caractres}
			begin
				if alpha[i] = '.' then
					begin
						nbPoints := nbPoints + 1;
						if nbPoints > 1 then
							flag := false;
					end;
			end
		else
			flag := false;
	EstUnReel := flag;
end;

  {ReelEnString pour un reel qui doit etre entre 0.0 et 100.0 (avec une seule decimale) }
function ReelEnStringRapide(unreel : double) : String255;
var aux : SInt32;
begin
  if unreel = 100.0
   then ReelEnStringRapide := '100.0'
   else
     begin
       unreel := unreel+0.05;
       aux := Trunc(unreel);
       if aux < 10
         then
           ReelEnStringRapide := Concat(chr((aux mod 10)+48),
                                     '.',
                                     chr(Trunc(10*(unreel-aux))+48))
         else
           ReelEnStringRapide := Concat(chr((aux div 10)+48),
                                      chr((aux mod 10)+48),
                                      '.',
                                      chr(Trunc(10*(unreel-aux))+48))
     end;
end;


{marche seulement pour les chaines au format aaaaaaaa.bbbbbbbb (pas aaaaa.bbbbbEEEEcc)
 et ne conserve que les 7 premieres decimales !}
function StringSimpleEnReel(alpha : String255) : double;
var i : SInt16;
    ChainePartieEntiere,ChainePartieDecimale : String255;
    partieEntiere,partieDecimale,mult : double;
    aux2 : SInt32;
    signe : double;
begin
  signe := 1.0;

  if (alpha[1] = '+')
    then alpha := TPCopy(alpha,2,LENGTH_OF_STRING(alpha) - 1)
    else
      if (alpha[1] = '-') then
        begin
          signe := -1.0;
          alpha := TPCopy(alpha,2,LENGTH_OF_STRING(alpha) - 1);
        end;

  if EstUnReel(alpha)
    then
      begin
        if Pos('.',alpha) = 0 then
          begin
            i := Pos(',',alpha);
            if i <> 0 then alpha[i] := '.';   {on remplace la virgule par un point}
          end;

        i := Pos('.',alpha);
        if i = 0 then
          begin
            alpha := alpha + '.0';
            i := Pos('.',alpha);
          end;


        ChainePartieEntiere := TPCopy(alpha,1,i - 1);

        ChainePartieDecimale := TPCopy(alpha,i + 1,LENGTH_OF_STRING(alpha) - i);
        for i := LENGTH_OF_STRING(ChainePartieDecimale) + 1 to 7 do
          ChainePartieDecimale := ChainePartieDecimale + '0';


        partieEntiere := 0.0;
        mult := 1.0;
        for i := LENGTH_OF_STRING(ChainePartieEntiere) downto 1 do
          begin
            aux2 := ord(ChainePartieEntiere[i]) - 48;
            partieEntiere := partieEntiere + mult*aux2;
            mult := mult * 10.0;
          end;


        partieDecimale := 0.0;
        mult := 0.1;
        for i := 1 to 7 do
          begin
            aux2 := ord(ChainePartieDecimale[i]) - 48;
            partieDecimale := partieDecimale + mult*aux2;
            mult := mult * 0.1;
          end;

        StringSimpleEnReel := signe * (partieEntiere + partieDecimale);

      end
    else
      StringSimpleEnReel := 0.0;
end;




{IntToStr pour un num qui doit etre entre 0 et 100}
function PourcentageEntierEnString(num : SInt32) : String255;
begin
  if num = 100
   then PourcentageEntierEnString := '100'
   else if num < 10
         then PourcentageEntierEnString := chr((num mod 10)+48)
         else PourcentageEntierEnString := Concat(chr((num div 10)+48),chr((num mod 10)+48));
end;



function ReelEnString(unreel : double) : String255;
var s,s1 : String255;
begin
  if unreel < 0 then s := '-' else s := '';
  unreel := Abs(unreel);
  unreel := unreel+0.00499;
  s1 := IntToStr(Trunc(unreel));
  s := s + s1+CharToString('.');
  unreel := 10.0*(unreel-Trunc(unreel));
  s1 := IntToStr(Trunc(unreel));
  s := s + s1;
  unreel := 10.0*(unreel-Trunc(unreel));
  s1 := IntToStr(Trunc(unreel));
  s := s + s1;
  ReelEnString := s;
end;



function ReelEnStringAvecDecimales(unreel : double; nbChiffresSignificatifs : SInt16) : String255;
var s,s1,s2 : String255;
    i,longueur : SInt32;
    nbUnites,nbMilliers,nbMillions,nbMilliards,nbBillions,nbBilliards : SInt32;
    dejaEcritDesChiffres : boolean;
begin

  if unreel < 0 then s := '-' else s := '';
  unreel := Abs(unreel);

  dejaEcritDesChiffres := false;
  s1 := '';
  nbBilliards := Trunc(unreel/1000000000000000.0);
  if (nbBilliards >= 1) then
    begin
      s2 := IntToStr(nbBilliards);
      s1 := s1 + s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbBilliards*1000000000000000.0;
    end;
  nbBillions := Trunc(unreel/1000000000000.0);
  if (nbBillions = 0) and (dejaEcritDesChiffres) then s1 := s1 + '000' else
  if (nbBillions >= 1) then
    begin
      s2 := IntToStr(nbBillions);
      if (nbBillions >= 1)  and (nbBillions <= 9)  and dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbBillions >= 10) and (nbBillions <= 99) and dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1 + s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbBillions*1000000000000.0;
    end;
  nbMilliards := Trunc(unreel/1000000000.0);
  if (nbMilliards = 0) and (dejaEcritDesChiffres) then s1 := s1 + '000' else
  if (nbMilliards >= 1) then
    begin
      s2 := IntToStr(nbMilliards);
      if (nbMilliards >= 1)  and (nbMilliards <= 9)  and dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbMilliards >= 10) and (nbMilliards <= 99) and dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1 + s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbMilliards*1000000000.0;
    end;
  nbMillions := Trunc(unreel/1000000.0);
  if (nbMillions = 0) and (dejaEcritDesChiffres) then s1 := s1 + '000' else
  if (nbMillions >= 1) then
    begin
      s2 := IntToStr(nbMillions);
      if (nbMillions >= 1)  and (nbMillions <= 9)  and dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbMillions >= 10) and (nbMillions <= 99) and dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1 + s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbMillions*1000000.0;
    end;
  nbMilliers := Trunc(unreel/1000.0);
  if (nbMilliers = 0) and (dejaEcritDesChiffres) then s1 := s1 + '000' else
  if (nbMilliers >= 1) then
    begin
      s2 := IntToStr(nbMilliers);
      if (nbMilliers >= 1)  and (nbMilliers <= 9)  and dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbMilliers >= 10) and (nbMilliers <= 99) and dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1 + s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbMilliers*1000.0;
    end;
  nbUnites := Trunc(unreel);
  if (nbUnites = 0) and (dejaEcritDesChiffres) then s1 := s1 + '000' else
  if (nbUnites >= 0) then   { >= 0 au lieu de >= 1 car on veut ecrire 0.abc et non pas .abc}
    begin
      s2 := IntToStr(nbUnites);
      if (nbUnites >= 1)  and (nbUnites <= 9)  and dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbUnites >= 10) and (nbUnites <= 99) and dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1 + s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbUnites;
    end;

  longueur := LENGTH_OF_STRING(s1);
  if (nbChiffresSignificatifs < 1) then nbChiffresSignificatifs := 1;
  if (nbChiffresSignificatifs > 20) then nbChiffresSignificatifs := 20;
  if (nbChiffresSignificatifs > longueur)
    then s := s + s1+CharToString('.')
    else s := s + s1;
  for i := 1 to nbChiffresSignificatifs - longueur do
    begin
      unreel := 10.0*(unreel-Trunc(unreel));
      s1 := IntToStr(Trunc(unreel));
      s := s + s1;
    end;
  ReelEnStringAvecDecimales := s;
end;


procedure ChaineToInteger(const s : String255; var theInteger : SInt16);
var unlong : SInt32;
begin
  StrToInt32(EnleveEspacesDeDroite(s),unlong);
  theInteger := unlong;
end;

procedure StrToInt32(const s : String255; var theLongint : SInt32);
var unlong : SInt32;
    aux : str255;
begin
  aux := StringToStr255(EnleveEspacesDeDroite(s));
  StringToNum(aux,unlong);
  theLongint := unlong;
end;


function ChaineEnInteger(const s : String255) : SInt16;
var unlong : SInt32;
begin
  StrToInt32(EnleveEspacesDeDroite(s),unlong);
  ChaineEnInteger := unlong;
end;


function StrToInt32(const s : String255) : SInt32;
var unlong : SInt32;
begin
  StrToInt32(EnleveEspacesDeDroite(s),unlong);
  StrToInt32 := unlong;
end;


function PourcentageReelEnString(x : double) : String255;
var aux : SInt32;
    s : String255;
begin
  aux := Trunc(100*Abs(x));
  s := IntToStr(aux);
  if x < 0 then s := Concat('-',s);
  PourcentageReelEnString := Concat(s,'%');
end;


  function ReadStringFromRessource(stringListID, index : SInt16) : String255;
	var
		s : Str255;
  begin
  	s := StringToStr255('');
  	GetIndString(s, stringListID, index);
  	ReadStringFromRessource := MyStr255ToString(s);
  end;

	function FindCharacter(p : Ptr; len : SInt32; ch : char; var pos : SInt32) : boolean;
	begin
		pos := 0;
		while (pos < len) and (Ptr(POINTER_VALUE(p)+pos)^ <> ord(ch)) do begin
			pos := pos+1;
		end;
		FindCharacter := pos < len;
	end;

	function CharInSet(ch : char; mySet : CharSet) : boolean;
	begin
	  CharInSet := ch in mySet;
	end;

	procedure KeepPrefix (var s : String255; len : SInt32);
	begin
		s := TPCopy(s, 1, len);
	end;

	function LeftStr (const s : String255; len : SInt32) : String255;
	begin
		LeftStr := TPCopy(s, 1, len);
	end;

	procedure LeftAssignP (var s : String255; len : SInt16; var rhs : String255);
	begin
		s := Concat(rhs, TPCopy(s, len + 1, 255));
	end;

	function LeftAssign (var s : String255; len : SInt16; var rhs : String255) : String255;
	begin
		LeftAssign := Concat(rhs, TPCopy(s, len + 1, 255));
	end;

	procedure KeepSuffix (var s : String255; len : SInt32);
		var
			p : SInt16;
	begin
		p := LENGTH_OF_STRING(s) - len;
		if p < 1 then begin
			p := 1;
		end;
		s := TPCopy(s, p, 255);
	end;

	function RightStr (const s : String255; len : SInt16) : String255;
		var
			p : SInt16;
	begin
		p := LENGTH_OF_STRING(s) - len + 1;
		if p < 1 then begin
			p := 1;
		end;
		RightStr := TPCopy(s, p, 255);
	end;

	procedure RightAssignP (var s : String255; len : SInt16; var rhs : String255);
	begin
		s := Concat(TPCopy(s, 1, LENGTH_OF_STRING(s) - len), rhs);
	end;

	function RightAssign (var s : String255; len : SInt16; var rhs : String255) : String255;
	begin
		RightAssign := Concat(TPCopy(s, 1, LENGTH_OF_STRING(s) - len), rhs);
	end;

	procedure MidP (var s : String255; p, len : SInt16);
	begin
		s := TPCopy(s, p, len);
	end;

	function Mid (var s : String255; p, len : SInt16) : String255;
	begin
		Mid := TPCopy(s, p, len);
	end;

	procedure MidAssignP (var s : String255; p, len : SInt16; const rhs : String255);
	begin
		s := Concat(TPCopy(s, 1, p - 1), rhs, TPCopy(s, p + len, 255));
	end;

	function MidAssign (const s : String255; p, len : SInt16; const rhs : String255) : String255;
	begin
		MidAssign := Concat(TPCopy(s, 1, p - 1), rhs, TPCopy(s, p + len, 255));
	end;

{$PUSH}
{$R-}
	procedure HandleToString (hhhh : UnivHandle; var s : String255);
		var
			len : SInt32;
	begin
		len := Min(255, GetHandleSize(Handle(hhhh)));
		SET_LENGTH_OF_STRING(s,len);
		BlockMoveData(hhhh^, @s[1], len);
	end;
{$POP}

	function HandleToStr (hhhh : UnivHandle) : String255;
		var
			s : String255;
	begin
		HandleToString(hhhh, s);
		HandleToStr := s;
	end;

	procedure StringToHandle (const s : String255; hhhh : UnivHandle);
	begin
		SetHandleSize(Handle(hhhh), LENGTH_OF_STRING(s));
		if (MemError = noErr) and (LENGTH_OF_STRING(s) > 0) then begin
			BlockMoveData(@s[1], hhhh^, LENGTH_OF_STRING(s));
		end;
	end;

	function Trim (s : String255) : String255;
	begin
		while (LENGTH_OF_STRING(s) > 0) and CharInSet(s[1],[spc, tab, cr, lf]) do begin
			Delete(s, 1, 1);
		end;
		while (LENGTH_OF_STRING(s) > 0) and CharInSet(s[LENGTH_OF_STRING(s)],[spc, tab, cr, lf]) do begin
			Delete(s, LENGTH_OF_STRING(s), 1);
		end;
		Trim := s;
	end;


	function NoCaseEquals( s1, s2 : String255 ) : boolean;
	begin
		LowerCaseString( s1 );
		LowerCaseString( s2 );
		NoCaseEquals := s1 = s2;
	end;

	function NoCasePos( s1, s2 : String255 ) : SInt16;
	begin
		LowerCaseString( s1 );
		LowerCaseString( s2 );
		NoCasePos := Pos( s1, s2 );
	end;

	procedure LowerCaseString (var s : String255);
		var
			i : SInt16;
	begin
		for i := 1 to LENGTH_OF_STRING(s) do begin
			s[i] := LowerCase(s[i]);
		end;
	end;

	function LowerCaseStr (s : String255) : String255;
		var
			i : SInt16;
	begin
		for i := 1 to LENGTH_OF_STRING(s) do begin
			s[i] := LowerCase(s[i]);
		end;
		LowerCaseStr := s;
	end;

	procedure UpCaseString (var s : String255);
		var
			i : SInt16;
	begin
		for i := 1 to LENGTH_OF_STRING(s) do begin
			s[i] := UpperCase(s[i]);
		end;
	end;

	function UpCaseStr (s : String255) : String255;
		var
			i : SInt16;
	begin
		for i := 1 to LENGTH_OF_STRING(s) do begin
			s[i] := UpperCase(s[i]);
		end;
		UpCaseStr := s;
	end;

	function TPCopy (source : String255; start, count : SInt32) : String255;
	var result : String255;
	begin
		if (start < 1) then begin
			count := count - (1 - start);
			start := 1;
		end;
		if start + count > LENGTH_OF_STRING(source) then begin
			count := LENGTH_OF_STRING(source) - start + 1;
		end;
		if count < 0 then begin
			count := 0;
		end;

		(*
		SET_LENGTH_OF_STRING(source,count);
		BlockMoveData(@source[start], @source[1], count);
		TPCopy := source;
		*)
		
		{ autre version : }
		SET_LENGTH_OF_STRING(result,count);
		if (count > 0) then
		  BlockMoveData(@source[start], @result[1], count);
		TPCopy := result;
		

		{ autre version : }
		(*
		SET_LENGTH_OF_STRING(result,count);
		for k := 1 to count do
		  result[k] := source[start + k - 1];
		TPCopy := result;
		*)

	end;



function LastPos (sub, str : String255) : SInt16;
var i, j : SInt16;
begin
  LastPos := 0;
	if (LENGTH_OF_STRING(sub) > 0) and (LENGTH_OF_STRING(sub) <= LENGTH_OF_STRING(str)) then
	  begin
		i := succ(LENGTH_OF_STRING(str)-LENGTH_OF_STRING(sub));
		while (i >= 1) do
		  begin
			 if str[i] = sub[1] then
			   begin
				   j := 2;
				   while j <= LENGTH_OF_STRING(sub) do
				     begin
					     if str[i+j-1] <> sub[j] then Leave;
					     j := j+1;
				     end;
				   if j > LENGTH_OF_STRING(sub) then
				     begin
					     LastPos := i;
					     exit;
				     end;
			   end;
			 i := pred(i);
		 end;
	end;
end;


function FirstPos(const sub, str : String255) : SInt32;
var i, k, len_sub, len_str : SInt32;
    c : char;
label  next_char;
begin

  len_sub := LENGTH_OF_STRING(sub);

  if (len_sub = 0)
    then
      FirstPos := 1
    else
      begin
        len_str := LENGTH_OF_STRING(str);

        if (len_str = 0)
          then
            FirstPos := 0
          else
            begin
              if (len_sub = 1)
                then
                  begin
                    i := 1;
                    c := sub[1];
                    while (i <= len_str) and (str[i] <> c) do
                      inc(i);

                    if (i > len_str)
                      then FirstPos := 0
                      else FirstPos := i;
                  end
                else
                  begin

                    c := sub[1];

                    for i := 1 to (len_str - len_sub + 1) do
                      begin
                        if (str[i] = c) then
                          begin
                            for k := 2 to len_sub do
                              if (sub[k] <> str[i + k - 1]) then goto next_char;

                            FirstPos := i;
                            exit;
                          end;

                        next_char :
                      end;

                    FirstPos := 0;

                  end;
             end;
      end;
end;


procedure DoSub (var dst: String255; n : SInt16; const s : String255);
var p : SInt16;
	begin
		p := Pos(Concat('^', chr(n + 48)), dst);
		if p > 0 then begin
			Delete(dst, p, 2);
			Insert(s, dst, p);
		end;
	end;

procedure SPrintS5 (var dst: String255; const src, s1, s2, s3, s4, s5 : String255);
var temp : String255;
	begin
		temp := src;
		DoSub(temp, 5, s5);
		DoSub(temp, 4, s4);
		DoSub(temp, 3, s3);
		DoSub(temp, 2, s2);
		DoSub(temp, 1, s1);
		dst := temp;
	end;

procedure SPrintS3 (var dst: String255; const src, s1, s2, s3 : String255);
var temp : String255;
begin
		temp := src;
		DoSub(temp, 3, s3);
		DoSub(temp, 2, s2);
		DoSub(temp, 1, s1);
		dst := temp;
end;

	function PosRight (sub : char; const s : String255) : SInt16;
		var
			p : SInt16;
	begin
		p := LENGTH_OF_STRING(s);
		while p > 0 do begin
			if s[p] = sub then begin
				leave;
			end;
			Dec(p);
		end;
		PosRight := p;
	end;

	function PosRightStr (const sub, s : String255) : SInt16;
		var
			p, q: SInt16;
	begin
		p := Pos(sub, s);
		if p > 0 then begin
			q := LENGTH_OF_STRING(s) - LENGTH_OF_STRING(sub) + 1;
			while q > p do begin
				if TPCopy(s, q, LENGTH_OF_STRING(sub)) = sub then begin
					p := q;
				end else begin
					q := q - 1;
				end;
			end;
		end;
		PosRightStr := p;
	end;

	function Contains( sub : char; const s : String255 ) : boolean;
	begin
		Contains := Pos( sub, s ) > 0;
	end;

	function ContainsStr( const sub, s : String255 ) : boolean;
	begin
		ContainsStr := Pos( sub, s ) > 0;
	end;

	procedure SplitByChar (s : String255; sub : char; var left, right: String255);
		var
			p : SInt16;
	begin
		p := Pos(sub, s);
		if p <= 0 then begin
			left := s;
			right := '';
		end else begin
			left := TPCopy(s, 1, p - 1);
			right := TPCopy(s, p + 1, 255);
		end;
	end;

	procedure SplitRightByChar (s : String255; sub : char; var left, right: String255);
		var
			p : SInt16;
	begin
		p := PosRight(sub, s);
		if p <= 0 then begin
			left := '';
			right := s;
		end else begin
			left := TPCopy(s, 1, p - 1);
			right := TPCopy(s, p + 1, 255);
		end;
	end;

	procedure SplitByStr (s : String255; const sub : String255; var left, right: String255);
		var
			p : SInt16;
	begin
		p := Pos(sub, s);
		if p <= 0 then begin
			left := s;
			right := '';
		end else begin
			left  := TPCopy(s, 1, p - 1);
			right := TPCopy(s, p + LENGTH_OF_STRING(sub), 255);
		end;
	end;

	procedure SplitRightByStr (s : String255; const sub : String255; var left, right: String255);
		var
			p : SInt16;
	begin
		p := PosRightStr(sub, s);
		if p <= 0 then begin
			left := '';
			right := s;
		end else begin
			left := TPCopy(s, 1, p - 1);
			right := TPCopy(s, p + LENGTH_OF_STRING(sub), 255);
		end;
	end;

	function Split (s : String255; sub : char; var s1, s2 : String255) : boolean;
		var
			p : SInt16;
	begin
		p := Pos(sub, s);
		if p > 0 then begin
			s1 := TPCopy(s, 1, p - 1);
			s2 := TPCopy(s, p + 1, 255);
		end;
		Split := p > 0;
	end;

	function SplitRight(s : String255; sub : char; var s1, s2 : String255) : boolean;
		var
			p : SInt16;
	begin
		p := PosRight(sub, s);
		if p > 0 then begin
			s1 := TPCopy(s, 1, p - 1);
			s2 := TPCopy(s, p + 1, 255);
		end;
		SplitRight := p > 0;
	end;

	function Split (s : String255; const sub : String255; var s1, s2 : String255) : boolean;
		var
			p : SInt16;
	begin
		p := Pos(sub, s);
		if p > 0 then begin
			s1 := TPCopy(s, 1, p - 1);
			s2 := TPCopy(s, p + LENGTH_OF_STRING(sub), 255);
		end;
		Split := p > 0;
	end;

	function SplitRight (s : String255; const sub : String255; var s1, s2 : String255) : boolean;
		var
			p : SInt16;
	begin
		p := PosRightStr(sub, s);
		if p > 0 then begin
			s1 := TPCopy(s, 1, p - 1);
			s2 := TPCopy(s, p + LENGTH_OF_STRING(sub), 255);
		end;
		SplitRight := p > 0;
	end;

	function Match (pattern, name: String255) : boolean;
		function M (p, n : SInt16) : boolean;
			var
				state: (searching, failed, success);
		begin
			state := searching;
			while state = searching do begin
				case ord(p <= LENGTH_OF_STRING(pattern)) * 2 + ord(n <= LENGTH_OF_STRING(name)) of
					0:  begin
						state := success;
					end;
					1:  begin
						state := failed;
					end;
					2:  begin
						state := success;
						while p <= LENGTH_OF_STRING(pattern) do begin
							if pattern[p] <> '*' then begin
								state := failed;
								leave;
							end;
							p := p + 1;
						end;
					end;
					3:  begin
						case pattern[p] of
							'?':  begin
								p := p + 1;
								n := n + 1;
							end;
							'*':  begin
								p := p + 1;
								if p > LENGTH_OF_STRING(pattern) then begin { short circuit the * at the end case }
									state := success;
								end else begin
									state := failed;
									while n <= LENGTH_OF_STRING(name) do begin
										if M(p, n) then begin
											state := success;
											leave;
										end;
										n := n + 1;
									end;
								end;
							end;
							otherwise begin
								if name[n] <> pattern[p] then begin
									state := failed;
								end;
								n := n + 1;
								p := p + 1;
							end;
						end;
					end;
				end;
			end;
			M := state = success;
		end;
	begin
		pattern := UpperCase(pattern, false);
		name := UpperCase(name, false);
		Match := M(1, 1);
	end;
	
	
 function StringBeginsWith(const s, pattern : String255) : boolean;
 begin
   if (s = '') or (pattern = '') then
     begin
       StringBeginsWith := false;
       exit;
     end;

   if (s[1] <> pattern[1]) then
     begin
       StringBeginsWith := false;
       exit;
     end;

   // on sait que les deux chaines ont le meme premier caractere

   StringBeginsWith := (Pos(pattern, s) = 1);

 end;
	
	

	procedure LimitStringLength (var s : String255; len : SInt16; delimiter : char);
		var
			p : SInt16;
	begin
		if LENGTH_OF_STRING(s) > len then begin
			p := Pos(delimiter, s);
			if p <= 0 then begin
				p := LENGTH_OF_STRING(s) div 2 + 1;
				s[p] := delimiter;
			end;
			while LENGTH_OF_STRING(s) > len do begin
				if p > len div 2 + 1 then begin
					Delete(s, p - 1, 1);
					p := p - 1;
				end else begin
					Delete(s, p + 1, 1);
				end;
			end;
		end;
	end;

	procedure MySetStringLength (var s : String255; len : SInt16);
	begin
	  {$ifc defined __GPC__ }

	     SetLength(s,len);

	  {$elsec}
	     s[0] := chr(len);
	  {$endc}
	end;


	function MyStr255ToString( const s : Str255 ) : String255;
	var theResult : String255;
	    len, k : SInt32;
  begin
    theResult := '';


    {$ifc defined __GPC__ }
	     MySetStringLength(theResult, Min(s.sLength, theResult.Capacity ) );
	  {$elsec}
	     MySetStringLength(theResult, LENGTH_OF_STRING(s));
	  {$endc}

	  len := LENGTH_OF_STRING( theResult );
    if len > 0 then
      for k := 1 to len do
        begin
          {$ifc defined __GPC__ }
	         theResult[k] := s.sChars[k];
	        {$elsec}
	         theResult[k] := s[k];
	        {$endc}

        end;

    MyStr255ToString := theResult;
  end;


	function StringToOSType (const s : String255) : OSType;
		var
			t : OSType;
	begin
		if LENGTH_OF_STRING(s) >= 4 then begin
			BlockMoveData(@s[1], @t, 4);
		end else begin
			t := OSType(0);
			BlockMoveData(@s[1], @t, LENGTH_OF_STRING(s));
		end;
		StringToOSType := t;
	end;

	function OSTypeToString (t : OSType) : String255;
		var
			s : String255;
	begin
		s := Concat(nul,nul,nul,nul);
		BlockMoveData(@t,@s[1],4);
		OSTypeToString := s;
	end;



function EnleveEspacesDeGauche(const s : String255) : String255;
var len,i,j : SInt16;
    result : String255;
begin
  len := LENGTH_OF_STRING(s);
  result := '';
  if (len > 0) then
    begin
      i := 1;
      if ((s[1] = ' ') or (s[1] = tab)) then
        repeat inc(i); until (i > len) or ((s[i] <> ' ') and (s[i] <> tab));
      for j := i to len do result := result + s[j];
    end;
  EnleveEspacesDeGauche := result;

  {WritelnNumDansRapport('len = ',len);
  for i := 1 to len do
    WritelnNumDansRapport('s['+IntToStr(i)+'] = ',ord(s[i]));
  WritelnNumDansRapport('LENGTH_OF_STRING(result) = ',LENGTH_OF_STRING(result));
  for i := 1 to LENGTH_OF_STRING(result) do
    WritelnNumDansRapport('result['+IntToStr(i)+'] = ',ord(result[i]));}
end;

procedure EnleveEtCompteEspacesDeGauche(var s : String255; var nbEspacesEnleves : SInt16);
var len,i,j : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  nbEspacesEnleves := 0;
  if (len > 0) then
    begin
      i := 1;
      if ((s[1] = ' ') or (s[1] = tab)) then
        repeat
          inc(i);
          inc(nbEspacesEnleves);
        until (i > len) or ((s[i] <> ' ') and (s[i] <> tab));
      if nbEspacesEnleves > 0 then
        begin
          for j := 1 to len - nbEspacesEnleves do
            s[j] := s[j + nbEspacesEnleves];
          SET_LENGTH_OF_STRING(s,len-nbEspacesEnleves);
        end;
    end;
end;

function EnleveEspacesDeDroite(const s : String255) : String255;
var len,i,j : SInt16;
    result : String255;
begin
  len := LENGTH_OF_STRING(s);
  result := '';
  if (len > 0) then
    begin
      i := len;
      if ((s[len] = ' ') or (s[len] = tab)) then
        repeat
          dec(i);
        until (i < 1) or ((s[i] <> ' ') and (s[i] <> tab));
      for j := 1 to i do result := result + s[j];
    end;
  EnleveEspacesDeDroite := result;
end;


procedure EnleveEtCompteEspacesDeDroite(var s : String255; var nbEspacesEnleves : SInt16);
var len,i : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  nbEspacesEnleves := 0;
  if (len > 0) then
    begin
      i := len;
      if ((s[len] = ' ') or (s[len] = tab)) then
        repeat
          dec(i);
          inc(nbEspacesEnleves);
        until (i < 1) or ((s[i] <> ' ') and (s[i] <> tab));
      if nbEspacesEnleves > 0 then
        SET_LENGTH_OF_STRING(s,len-nbEspacesEnleves);
    end;
end;

procedure EnleveEtCompteCeCaractereAGauche(var s : String255; ch : char; var nbCaracteresEnleves : SInt16);
var len,i,j : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  nbCaracteresEnleves := 0;
  if (len > 0) then
    begin
      i := 1;
      if (s[1] = ch) then
        repeat
          inc(i);
          inc(nbCaracteresEnleves);
        until (i > len) or (s[i] <> ch);
      if nbCaracteresEnleves > 0 then
        begin
          for j := 1 to len-nbCaracteresEnleves do
            s[j] := s[j+nbCaracteresEnleves];
          SET_LENGTH_OF_STRING(s,len-nbCaracteresEnleves);
        end;
    end;
end;

procedure EnleveEtCompteCeCaractereADroite(var s : String255; ch : char; var nbCaracteresEnleves : SInt16);
var len,i : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  nbCaracteresEnleves := 0;
  if (len > 0) then
    begin
      i := len;
      if (s[len] = ch) then
        repeat
          dec(i);
          inc(nbCaracteresEnleves);
        until (i < 1) or (s[i] <> ch);
      if nbCaracteresEnleves > 0 then
        SET_LENGTH_OF_STRING(s,len-nbCaracteresEnleves);
    end;
end;

procedure EnleveEspacesDeGaucheSurPlace(var s : String255);
var nbEspacesEnleves : SInt16;
begin
  EnleveEtCompteEspacesDeGauche(s,nbEspacesEnleves);
end;


procedure EnleveEspacesDeDroiteSurPlace(var s : String255);
var nbEspacesEnleves : SInt16;
begin
  EnleveEtCompteEspacesDeDroite(s,nbEspacesEnleves);
end;


procedure EnleveEtCompteCeCaractereAGaucheDansBuffer(buffer : Ptr; var tailleBuffer : SInt32; ch : char; var nbCaracteresEnleves : SInt32);
var len,i,j : SInt32;
    localBuffer : PackedArrayOfCharPtr;
begin
  if (buffer <> NIL) then
    begin
      localBuffer := PackedArrayOfCharPtr(buffer);

      len := tailleBuffer;
      nbCaracteresEnleves := 0;

      if (len > 0) then
        begin
          i := 0;
          if (localBuffer^[0] = ch) then
            repeat
              inc(i);
              inc(nbCaracteresEnleves);
            until (i >= len) or (localBuffer^[i] <> ch);

          if (nbCaracteresEnleves > 0) then
            begin
              for j := 0 to (len - 1 - nbCaracteresEnleves) do
                localBuffer^[j] := localBuffer^[j+nbCaracteresEnleves];
              tailleBuffer := len-nbCaracteresEnleves;
            end;
        end;
    end;
end;



function ASeulementCeCaractere(c : char; var s : String255) : boolean;
var len,i : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  if len <= 0
    then
      begin
        ASeulementCeCaractere := false;
        exit;
      end
    else
      begin
        for i := 1 to len do
          if s[i] <> c then
            begin
              ASeulementCeCaractere := false;
              exit;
            end;
        ASeulementCeCaractere := true;
      end;
end;



{Compte les occurences de la chaine subString dans s, sans recouvrement.
 Par exemple CompterOccurencesDeSousChaine('aa','aabaaa') renvoie 2 }
function CompterOccurencesDeSousChaine(const subString, s : String255) : SInt32;
var len,lensub,i,k : SInt32;
    occ : SInt32;
begin
  len := LENGTH_OF_STRING(s);
  lenSub := LENGTH_OF_STRING(subString);
  if (len <= 0) or (lensub <= 0)
    then
      begin
        CompterOccurencesDeSousChaine := 0;
        exit;
      end
    else
      begin
        occ := 0;

        i := 1;

        while (i <= len-lensub+1) do
          begin
            k := 1;
            while (k <= lenSub) and (i+k-1 <= len) and (s[i+k-1] = subString[k]) do
             inc(k);

            if (k > lenSub)
              then
                begin
                  inc(occ);
                  i := i + lensub;
                end
              else
                inc(i);
          end;

        CompterOccurencesDeSousChaine := occ;
      end;
end;


function UpperCase(const s : String255; keepDiacritics : boolean) : String255;
var aux : Str255;
begin
  aux := StringToStr255(s);
  UpperString(aux,keepDiacritics);
  MyUpperString := MyStr255ToString(aux);
end;

function LowerCase(const s : String255; keepDiacritics : boolean) : String255;
var aux : String255;
begin
  if not(keepDiacritics)
    then aux := StripDiacritics(s)
    else aux := s;
  Result := sysutils.LowerCase(aux);
end;



procedure StripHTMLAccents(var s : String255);
var changed : boolean;
begin

  //WritelnDansRapport(s);


  while (Pos('&', s ) > 0) and (Pos( ';', s ) > 0) do
    begin


      //WritelnDansRapport(s);

      changed := false;

      if Pos('&nbsp;',   s) > 0 then begin s := ReplaceStringOnce(s, '&nbsp;'   , ' ' ); changed := true; end;

      if Pos('&aelig;',  s) > 0 then begin s := ReplaceStringOnce(s, '&aelig;'  , 'ae'); changed := true; end;
      if Pos('&AElig;',  s) > 0 then begin s := ReplaceStringOnce(s, '&AElig;'  , 'AE'); changed := true; end;
      if Pos('&oelig;',  s) > 0 then begin s := ReplaceStringOnce(s, '&oelig;'  , 'oe'); changed := true; end;
      if Pos('&OElig;',  s) > 0 then begin s := ReplaceStringOnce(s, '&OElig;'  , 'OE'); changed := true; end;

      if Pos('&Agrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Agrave;' , 'A' ); changed := true; end;
      if Pos('&Auml;' ,  s) > 0 then begin s := ReplaceStringOnce(s, '&Auml;'   , 'A' ); changed := true; end;
      if Pos('&Acirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Acirc;'  , 'A' ); changed := true; end;
      if Pos('&Aacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Aacute;' , 'A' ); changed := true; end;

      if Pos('&Egrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Egrave;' , 'E' ); changed := true; end;
      if Pos('&Euml;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Euml;'   , 'E' ); changed := true; end;
      if Pos('&Ecirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Ecirc;'  , 'E' ); changed := true; end;
      if Pos('&Eacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Eacute;' , 'E' ); changed := true; end;

      if Pos('&Icirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Icirc;'  , 'I' ); changed := true; end;
      if Pos('&Igrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Igrave;' , 'I' ); changed := true; end;
      if Pos('&Iacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Iacute;' , 'I' ); changed := true; end;
      if Pos('&Iulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Iulm;'   , 'I' ); changed := true; end;

      if Pos('&Ocirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Ocirc;'  , 'O' ); changed := true; end;
      if Pos('&Ograve;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ograve;' , 'O' ); changed := true; end;
      if Pos('&Oacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Oacute;' , 'O' ); changed := true; end;
      if Pos('&Oulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Oulm;'   , 'O' ); changed := true; end;

      if Pos('&Ucirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Ucirc;'  , 'U' ); changed := true; end;
      if Pos('&Ugrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ugrave;' , 'U' ); changed := true; end;
      if Pos('&Uacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Uacute;' , 'U' ); changed := true; end;
      if Pos('&Uulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Uulm;'   , 'U' ); changed := true; end;

      if Pos('&Ycirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Ycirc;'  , 'Y' ); changed := true; end;
      if Pos('&Ygrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ygrave;' , 'Y' ); changed := true; end;
      if Pos('&Yacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Yacute;' , 'Y' ); changed := true; end;
      if Pos('&Yulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Yulm;'   , 'Y' ); changed := true; end;

      if Pos('&Icirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Icirc;'  , 'I' ); changed := true; end;

      if Pos('&Ntilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ntilde;' , 'N' ); changed := true; end;
      if Pos('&ntilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&ntilde;' , 'n' ); changed := true; end;
      if Pos('&Atilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Atilde;' , 'A' ); changed := true; end;
      if Pos('&atilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&atilde;' , 'a' ); changed := true; end;
      if Pos('&Etilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Etilde;' , 'E' ); changed := true; end;
      if Pos('&etilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&etilde;' , 'e' ); changed := true; end;
      if Pos('&Itilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Itilde;' , 'I' ); changed := true; end;
      if Pos('&itilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&itilde;' , 'i' ); changed := true; end;
      if Pos('&Otilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Otilde;' , 'O' ); changed := true; end;
      if Pos('&otilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&otilde;' , 'o' ); changed := true; end;
      if Pos('&Utilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Utilde;' , 'U' ); changed := true; end;
      if Pos('&utilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&utilde;' , 'u' ); changed := true; end;
      if Pos('&Ytilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ytilde;' , 'Y' ); changed := true; end;
      if Pos('&ytilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&ytilde;' , 'y' ); changed := true; end;

      if Pos('&copy;',   s) > 0 then begin s := ReplaceStringOnce(s, '&copy;'   , ''  ); changed := true; end;
      if Pos('&reg;',    s) > 0 then begin s := ReplaceStringOnce(s, '&reg;'    , ''  ); changed := true; end;

      if Pos('&agrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&agrave;' , 'a' ); changed := true; end;
      if Pos('&aacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&aacute;' , 'a' ); changed := true; end;
      if Pos('&acirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&acirc;'  , 'a' ); changed := true; end;
      if Pos('&auml;',   s) > 0 then begin s := ReplaceStringOnce(s, '&auml;'   , 'a' ); changed := true; end;

      if Pos('&egrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&egrave;' , 'e' ); changed := true; end;
      if Pos('&eacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&eacute;' , 'e' ); changed := true; end;
      if Pos('&ecirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&ecirc;'  , 'e' ); changed := true; end;
      if Pos('&euml;',   s) > 0 then begin s := ReplaceStringOnce(s, '&euml;'   , 'e' ); changed := true; end;

      if Pos('&iuml;',   s) > 0 then begin s := ReplaceStringOnce(s, '&iuml;'   , 'i' ); changed := true; end;
      if Pos('&icirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&icirc;'  , 'i' ); changed := true; end;
      if Pos('&igrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&igrave;' , 'i' ); changed := true; end;
      if Pos('&iacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&iacute;' , 'i' ); changed := true; end;

      if Pos('&ocirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&ocirc;'  , 'o' ); changed := true; end;
      if Pos('&ograve;', s) > 0 then begin s := ReplaceStringOnce(s, '&ograve;' , 'o' ); changed := true; end;
      if Pos('&oacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&oacute;' , 'o' ); changed := true; end;
      if Pos('&oulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&oulm;'   , 'o' ); changed := true; end;

      if Pos('&ugrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&ugrave;' , 'u' ); changed := true; end;
      if Pos('&uacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&uacute;' , 'u' ); changed := true; end;
      if Pos('&uuml;'  , s) > 0 then begin s := ReplaceStringOnce(s, '&uuml;'   , 'u' ); changed := true; end;
      if Pos('&ucirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&ucirc;'  , 'u' ); changed := true; end;

      if Pos('&ycirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&ycirc;'  , 'y' ); changed := true; end;
      if Pos('&ygrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&ygrave;' , 'y' ); changed := true; end;
      if Pos('&yacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&yacute;' , 'y' ); changed := true; end;
      if Pos('&yulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&yulm;'   , 'y' ); changed := true; end;

      if Pos('&ccedil;', s) > 0 then begin s := ReplaceStringOnce(s, '&ccedil;' , 'c' ); changed := true; end;
      if Pos('&Ccedil;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ccedil;' , 'C' ); changed := true; end;
      if Pos('&szlig;' , s) > 0 then begin s := ReplaceStringOnce(s, '&szlig;'  , 'ss'); changed := true; end;

      if Pos('&Oslash;', s) > 0 then begin s := ReplaceStringOnce(s, '&Oslash;' , 'O' ); changed := true; end;
      if Pos('&oslash;', s) > 0 then begin s := ReplaceStringOnce(s, '&oslash;' , 'o' ); changed := true; end;

      if Pos('&Aring;' , s) > 0 then begin s := ReplaceStringOnce(s, '&Aring;'  , 'A' ); changed := true; end;
      if Pos('&aring;' , s) > 0 then begin s := ReplaceStringOnce(s, '&aring;'  , 'a' ); changed := true; end;

      if Pos('&#321;'  , s) > 0 then begin s := ReplaceStringOnce(s, '&#321;'   , 'L' ); changed := true; end;  { pour le polonais }
      if Pos('&#322;'  , s) > 0 then begin s := ReplaceStringOnce(s, '&#322;'   , 'l' ); changed := true; end;  { pour le polonais }

      // WritelnDansRapport(s);

      if not(changed) then exit;
    end;
end;



var protect_parser_with_quotes : boolean;
    parser_delimiters : SetOfChar;
    parser_delimiters_as_booleans : array[0..255] of boolean;


{$ifc not string_accessors_are_macros}
function MY_LENGTH_OF_STRING(const s : String255) : SInt32;
begin
  MY_LENGTH_OF_STRING := ord(s[0]);
end;

procedure MY_SET_LENGTH_OF_STRING(var s : String255; len : SInt32);
begin
  s[0] := chr((len));
end;
{$endc}

procedure InitUnitMyStrings;
begin
  SetParserProtectionWithQuotes(false);
  SetParserDelimiters([' ',tab]);
end;

procedure SetParserProtectionWithQuotes(flag : boolean);
begin
  protect_parser_with_quotes := flag;
end;

function GetParserProtectionWithQuotes : boolean;
begin
  GetParserProtectionWithQuotes := protect_parser_with_quotes;
end;

function GetParserDelimiters : SetOfChar;
begin
  GetParserDelimiters := parser_delimiters;
end;

procedure SetParserDelimiters(parsingCaracters : SetOfChar);
var i : SInt32;
begin
  parser_delimiters := parsingCaracters;
  for i := 0 to 255 do
    parser_delimiters_as_booleans[i] := (chr(i) in parser_delimiters);
end;


function ExtraitNomDirectoryOuFichier(chemin : String255) : String255;
const separateur = DirectorySeparator ;
var lastPosDeuxPoints : SInt16;
begin
  if RightStr(chemin,1) = CharToString(separateur)
    then KeepPrefix(chemin,LENGTH_OF_STRING(chemin)-1);
  lastPosDeuxPoints := LastPos(separateur,chemin);
  ExtraitNomDirectoryOuFichier := RightStr(chemin,LENGTH_OF_STRING(chemin)-lastPosDeuxPoints);
end;


function ExtraitCheminDAcces(nomComplet : String255) : String255;
var nomFichier : String255;
begin
  nomFichier := ExtraitNomDirectoryOuFichier(nomComplet);
  ExtraitCheminDAcces := LeftStr(nomComplet,LENGTH_OF_STRING(nomComplet)-LENGTH_OF_STRING(nomFichier));
end;


function ExtraitNomDeVolume(nomComplet : String255) : String255;
var volumeName, reste : String255;
begin
  (* the volume name should be the left part of the path *)
	if Split(nomComplet, DirectorySeparator ,volumeName,reste)
	  then ExtraitNomDeVolume := volumeName
	  else ExtraitNomDeVolume := nomComplet;
end;


function EstUnNomDeFichierTronquePourPanther(const nomFichier : String255) : boolean;
var longueur,i : SInt32;
begin
  longueur := LENGTH_OF_STRING(nomFichier);



  if (longueur >= 10) and (nomFichier[longueur-3] = '.') then
    begin

      for i := (longueur - 9) to (longueur - 4) do
        if not(EstUnChiffreHexa(nomFichier[i])) then
          begin
            EstUnNomDeFichierTronquePourPanther := false;
            exit;
          end;
       EstUnNomDeFichierTronquePourPanther := true;
       exit;
    end;

  if (longueur >= 11) and (nomFichier[longueur-4] = '.') then
    begin
      for i := (longueur - 10) to (longueur - 5) do
        if not(EstUnChiffreHexa(nomFichier[i])) then
          begin
            EstUnNomDeFichierTronquePourPanther := false;
            exit;
          end;
       EstUnNomDeFichierTronquePourPanther := true;
       exit;
    end;

  if (longueur >= 6) then
    begin
      for i := (longueur - 5) to (longueur) do
        if not(EstUnChiffreHexa(nomFichier[i])) then
          begin
            EstUnNomDeFichierTronquePourPanther := false;
            exit;
          end;
       EstUnNomDeFichierTronquePourPanther := true;
       exit;
    end;

  EstUnNomDeFichierTronquePourPanther := false;
end;


function ChaineMirroir(const s : String255) : String255;
var i,longueur : SInt32;
    s1 : String255;
begin
  s1 := '';
  longueur := LENGTH_OF_STRING(s);
  for i := longueur downto 1 do s1 := s1 + s[i];
  ChaineMirroir := s1;
end;


function ReplaceStringOnce(const s, pattern, replacement : String255) : String255;
var positionSubstring : SInt32;
    res : String255;
begin
  positionSubstring := Pos(pattern,s);
  if (positionSubstring > 0)
     then
       begin
         res := s;
         Delete(res, positionSubstring, LENGTH_OF_STRING(pattern));
         Insert(replacement, res, positionSubstring);
         ReplaceStringOnce := res;
       end
     else
       ReplaceStringOnce := s;
end;


function ReplaceStringAll(const s, pattern, replacement : String255) : String255;
begin
  ReplaceStringAll := StringReplace(s, pattern, replacement, [rfReplaceAll]);
end;






function DeleteSpacesBefore(const s : String255; p : SInt16) : String255;
var n,len : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  if (p > len) or (p < 1) then
    begin
      DeleteSpacesBefore := s;
      exit;
    end;
  n := p;
  while (n >= 1) and (s[n] = ' ') do n := n-1;
  if (n >= 1)
    then DeleteSpacesBefore := TPCopy(s,1,n) + TPCopy(s,p+1,len-p)
    else DeleteSpacesBefore := TPCopy(s,p+1,len-p);
end;


function DeleteSpacesAfter(const s : String255; p : SInt16) : String255;
var n,len : SInt16;
begin
  len := LENGTH_OF_STRING(s);
  if (p > len) or (p < 1) then
    begin
      DeleteSpacesAfter := s;
      exit;
    end;
  n := p;
  while (n <= len) and (s[n] = ' ') do n := n+1;
  if (n <= len)
    then DeleteSpacesAfter := TPCopy(s,1,p-1) + TPCopy(s,n,len-n+1)
    else DeleteSpacesAfter := TPCopy(s,1,p-1);
end;


procedure ReplaceCharByCharInString(var s : String255; old, new : char);
var i,len : SInt32;
    c : char;
begin
  len := LENGTH_OF_STRING(s);
  for i := 1 to len do
    begin
      c := s[i];
      if (c = old) then s[i] := new;
    end;
end;


procedure TripleRemplacementDeCaractereDansString(var s : String255; old1, new1, old2, new2, old3, new3 : char);
var i,len : SInt32;
    c : char;
begin
  len := LENGTH_OF_STRING(s);
  for i := 1 to len do
    begin
      c := s[i];
      if (c = old1) then s[i] := new1 else
      if (c = old2) then s[i] := new2 else
      if (c = old3) then s[i] := new3;
    end;
end;


procedure Parse(s : String255; var tete,reste : String255);
var n,len : SInt16;
begin
  tete := '';
  reste := '';
  len := LENGTH_OF_STRING(s);
  if len > 0 then
    begin
      n := 1;
      while (n <= len) and (parser_delimiters_as_booleans[ord(s[n])]) do n := n + 1;  {on saute les espaces en tete de s}
      if (n <= len) then
        begin
          if protect_parser_with_quotes and (s[n] = '"')
            then
              begin
                n := n + 1;
                while (n <= len) and (s[n] <> '"') do   {on va jusqu'au prochain quote}
                  begin
                    tete := Concat(tete,s[n]);
                    n := n + 1;
                  end;
                if (s[n] = '"') and (n <= len) then n := n + 1; {on saute le quote fermant}
              end
            else
              while (n <= len) and (not(parser_delimiters_as_booleans[ord(s[n])])) do {on va jusqu'au prochain espace}
                begin
                  tete := Concat(tete,s[n]);
                  n := n + 1;
                end;
          while (n <= len) and (parser_delimiters_as_booleans[ord(s[n])]) do n := n + 1; {on saute les espaces en tete du reste}
          if (n <= len) then reste := TPCopy(s,n,len - n + 1);
        end;
    end;
end;

procedure Parse2(s : String255; var s1,s2,reste : String255);
begin
  Parse(s,s1,reste);
  Parse(reste,s2,reste);
end;

procedure Parse3(s : String255; var s1,s2,s3,reste : String255);
begin
  Parse(s,s1,reste);
  Parse(reste,s2,reste);
  Parse(reste,s3,reste);
end;

procedure Parse4(s : String255; var s1,s2,s3,s4,reste : String255);
begin
  Parse(s,s1,reste);
  Parse(reste,s2,reste);
  Parse(reste,s3,reste);
  Parse(reste,s4,reste);
end;

procedure Parse5(s : String255; var s1,s2,s3,s4,s5,reste : String255);
begin
  Parse(s,s1,reste);
  Parse(reste,s2,reste);
  Parse(reste,s3,reste);
  Parse(reste,s4,reste);
  Parse(reste,s5,reste);
end;

procedure Parse6(s : String255; var s1,s2,s3,s4,s5,s6,reste : String255);
begin
  Parse(s,s1,reste);
  Parse(reste,s2,reste);
  Parse(reste,s3,reste);
  Parse(reste,s4,reste);
  Parse(reste,s5,reste);
  Parse(reste,s6,reste);
end;


procedure ParseWithQuoteProtection(s : String255; var tete,reste : String255);
var oldParsingProtection : boolean;
begin
  oldParsingProtection := GetParserProtectionWithQuotes;
  SetParserProtectionWithQuotes(true);
  Parse(s, tete, reste);
  SetParserProtectionWithQuotes(oldParsingProtection);
end;


function EndsWith(const s : String255; const sub : String255) : boolean;
var len1,len2,i : SInt16;
begin
  len1 := LENGTH_OF_STRING(s);
  len2 := LENGTH_OF_STRING(sub);
  if (len1 <= 0) or (len2 <= 0) or (len1 < len2)
    then
      EndsWith := false
    else
      begin
        for i := 1 to len2 do
          if s[len1-len2+i] <> sub[i] then
            begin
              EndsWith := false;
              exit;
            end;
        EndsWith := true;
      end;
end;

function EndsWithDeuxPoints(var s : String255) : boolean;
begin
  EndsWithDeuxPoints := (s[LENGTH_OF_STRING(s)] = DirectorySeparator );
end;


function BoolEnString(myBool : boolean) : String255;
begin
  if myBool
    then BoolEnString := 'TRUE'
    else BoolEnString := 'FALSE';
end;






function IntToStrWithPadding(num,nbDeChiffres : SInt32; formatChar : char) : String255;
var i : SInt32;
		s : String255;
begin
	s := IntToStr(num);
	for i := 1 to (nbDeChiffres - LENGTH_OF_STRING(s)) do
	  s := formatChar + s;
	IntToStrWithPadding := s;
end;

function CharInRange(ch : char; min,max : char) : boolean;
begin
  CharInRange := (ch >= min) and (ch <= max);
end;

function ContientUneLettre(const s : String255) : boolean;
var i : SInt32;
    c : char;
begin
  for i := 1 to LENGTH_OF_STRING(s) do
    begin
      c := s[i];
      if ((c >= 'a') and (c <= 'z')) or ((c >= 'A') and (c <= 'Z')) then
        begin
          ContientUneLettre := true;
          exit;
        end;
    end;
  ContientUneLettre := false;
end;


function EstUnChiffreHexa(ch : char) : boolean;
begin
  EstUnChiffreHexa := CharInRange(ch,'0','9') or
                      CharInRange(ch,'A','F') or
                      CharInRange(ch,'a','f');
end;


function IsAnArrowKey(ch : char) : boolean;
const TopDocumentKey = 1;
      BottomDocumentKey = 4;
      PageUpKey = 11;
      PageDownKey = 12;
      FlecheGaucheKey = 28;
      FlecheDroiteKey = 29;
      FlecheHautKey = 30;
      FlecheBasKey = 31;
var ascii : SInt32;
begin
  ascii := ord(ch);
  IsAnArrowKey := (ascii = TopDocumentKey)    or
                  (ascii = BottomDocumentKey) or
                  (ascii = PageUpKey)         or
                  (ascii = PageDownKey)       or
                  (ascii = FlecheGaucheKey)   or
                  (ascii = FlecheDroiteKey)   or
                  (ascii = FlecheHautKey)     or
                  (ascii = FlecheBasKey);
end;



function EnMinuscule(var s : String255) : String255;
	var
		c : char;
		s1 : String255;
		i : SInt16;
begin
	s1 := '';
	for i := 1 to LENGTH_OF_STRING(s) do
		begin
			c := s[i];
			if (c >= 'A') and (c <= 'Z') then
				c := chr(ord(c) + 32);
			s1 := s1 + c;
		end;
	EnMinuscule := s1;
end;


function ReplaceParameters(s, p0, p1, p2, p3 : String255) : String255;
var aux : String255;
		j : SInt32;
begin

  if (s = '') then
    begin
      ParamStr := '';
      exit;
    end;

  aux := s;

	j := Pos('^0', aux);
  if (j > 0) and (j < 255) then
    begin
      Delete(aux, j, 2);
      if (p0 <> '') then Insert(p0, aux, j);
    end;


  j := Pos('^1', aux);
  if (j > 0) and (j < 255) then
    begin
      Delete(aux, j, 2);
      if (p1 <> '') then Insert(p1, aux, j);
    end;


  j := Pos('^2', aux);
  if (j > 0) and (j < 255) then
    begin
      Delete(aux, j, 2);
      if (p2 <> '') then Insert(p2, aux, j);
    end;


  j := Pos('^3', aux);
  if (j > 0) and (j < 255) then
    begin
      Delete(aux, j, 2);
      if (p3 <> '') then Insert(p3, aux, j);
    end;

	ParamStr := aux;
end;




function GarderSeulementLesChiffres(var s : String255) : String255;
	var
		i : SInt16;
		result : String255;
		c : char;
begin
	result := '';
	for i := 1 to LENGTH_OF_STRING(s) do
		begin
			c := s[i];
			if (c >= '0') and (c <= '9') then
				result := result + c;
		end;
	GarderSeulementLesChiffres := result;
end;

function GarderSeulementLesChiffresOuLesPoints(var s : String255) : String255;
	var
		i : SInt16;
		result : String255;
		c : char;
begin
	result := '';
	for i := 1 to LENGTH_OF_STRING(s) do
		begin
			c := s[i];
			if ((c >= '0') and (c <= '9')) or (c = '.') or (c = ',') then
				result := result + c;
		end;
	GarderSeulementLesChiffresOuLesPoints := result;
end;


function EnleverTousLesChiffres(var s : String255) : String255;
	var
		i : SInt16;
		result : String255;
		c : char;
begin
	result := '';
	for i := 1 to LENGTH_OF_STRING(s) do
		begin
			c := s[i];
			if not((c >= '0') and (c <= '9')) then
				result := result + c;
		end;
	EnleverTousLesChiffres := result;
end;


function EnleverLesCaracteresMajusculesEntreCesCaracteres(gauche, droite : char; var s : String255) : String255;
	var
		i : SInt16;
		result : String255;
		c : char;
begin
	result := '';
	for i := 1 to LENGTH_OF_STRING(s) do
		begin
			c := s[i];
			
			if (i = 1) or (i = LENGTH_OF_STRING(s))
			  then result := result + c
			  else
			    if not((c >= 'A') and (c <= 'Z') and (s[i - 1] = gauche) and (s[i + 1] = droite))
			      then result := result + c;
		end;
	EnleverLesCaracteresMajusculesEntreCesCaracteres := result;
end;




function ChaineNeContientQueDesChiffres(const s : String255) : boolean;
var i : SInt32;
    c : char;
begin

  for i := 1 to LENGTH_OF_STRING(s) do
    begin
      c := s[i];
			if ((c < '0') or (c > '9')) then
			  begin
			    ChaineNeContientQueDesChiffres := false;
			    exit;
			  end;
    end;

  ChaineNeContientQueDesChiffres := true;
end;


function ChaineNeContientQueCesCaracteres(const s : String255; whichChars : SetOfChar) : boolean;
var i : SInt32;
    c : char;
begin

  for i := 1 to LENGTH_OF_STRING(s) do
    begin
      c := s[i];
			if not(c in whichChars) then
			  begin
			    ChaineNeContientQueCesCaracteres := false;
			    exit;
			  end;
    end;

  ChaineNeContientQueCesCaracteres := true;
end;




function DeleteSubstringAfterThisChar(delim : char; const s : String255; keepDelimitor : boolean) : String255;
var position : SInt16;
begin
  position := Pos(delim,s);
  if position > 0
    then
      begin
        if keepDelimitor
          then DeleteSubstringAfterThisChar := TPCopy(s,1,position)
          else DeleteSubstringAfterThisChar := TPCopy(s,1,position-1);
      end
    else DeleteSubstringAfterThisChar := s;
end;


procedure MyDeleteString( var s : String255; index, nb_chars_to_delete : SInt32);
var result : String255;
    longueur,k : SInt32;
    a,b : SInt32;
begin
  if (nb_chars_to_delete <= 0) then exit;

  {$IFC DEFINED __GPC__}

  // l'implementation de Delete de GNU-PASCAL est buguee : on la remplace

  result := '';

  longueur := LENGTH_OF_STRING(s);

  if (longueur <= 0) then exit;

  a := 1;
  b := index - 1;
  if (b > longueur) then b := longueur;

  if (a <= b) then
    for k := a to b do
      result := result + s[k];


  a := index + nb_chars_to_delete;
  b := longueur;

  if (a <= longueur) and (a <= b) then
    for k := a to b do
      result := result + s[k];

  s := result;

  {$ELSEC}

  // l'implementation de Delete de CodeWarrior n'est pas buguee : on l'utilise

  Discard5(result,longueur,k,a,b);

  Delete(s, index, nb_chars_to_delete);

  {$ENDC}
end;

function DeleteSubstringBeforeThisChar(delim : char; const s : String255; keepDelimitor : boolean) : String255;
var position : SInt16;
begin
  position := Pos(delim,s);
  if position > 0
    then
      begin
        if keepDelimitor
          then DeleteSubstringBeforeThisChar := TPCopy(s, position,     LENGTH_OF_STRING(s) - position + 1)
          else DeleteSubstringBeforeThisChar := TPCopy(s, position + 1, LENGTH_OF_STRING(s) - position);
      end
    else DeleteSubstringBeforeThisChar := s;
end;


function EnleveChiffresEntreCesCaracteres(delim1,delim2 : char; const s : String255; keepDelimitors : boolean) : String255;
var position1,position2 : SInt32;
    s1 : String255;
begin
  position1 := Pos(delim1,s);
  position2 := Pos(delim2,s);
  if (position1 > 0) and (position2 > 0) and (position2 > position1) then
    begin
      s1 := TPCopy(s,position1 + 1, position2 - position1 - 1);
      if ChaineNeContientQueDesChiffres(s1) then
        begin
          if keepDelimitors
            then EnleveChiffresEntreCesCaracteres := TPCopy(s, 1, position1)     + TPCopy(s, position2    , LENGTH_OF_STRING(s) - position2 + 1)
            else EnleveChiffresEntreCesCaracteres := TPCopy(s, 1, position1 - 1) + TPCopy(s, position2 + 1, LENGTH_OF_STRING(s) - position2);
          exit;
        end;
    end;
  EnleveChiffresEntreCesCaracteres := s;
end;


function EnleveChiffresAvantCeCaractereEnDebutDeLigne(delim : char; const s : String255; keepDelimitor : boolean) : String255;
var position : SInt32;
    s1 : String255;
begin
  position := Pos(delim,s);
  if (position > 0) then
    begin
      s1 := TPCopy(s,1,position - 1);
      if ChaineNeContientQueDesChiffres(s1) then
        begin
          if keepDelimitor
            then EnleveChiffresAvantCeCaractereEnDebutDeLigne := TPCopy(s, position    , LENGTH_OF_STRING(s) - position + 1)
            else EnleveChiffresAvantCeCaractereEnDebutDeLigne := TPCopy(s, position + 1, LENGTH_OF_STRING(s) - position);
          exit;
        end;
    end;
  EnleveChiffresAvantCeCaractereEnDebutDeLigne := s;
end;



function EnleveChiffresApresCeCaractereEnFinDeLigne(delim : char; const s : String255; keepDelimitor : boolean) : String255;
var position : SInt32;
    s1 : String255;
begin
  position := LastPos(CharToString(delim),s);
  if (position > 0) then
    begin
      s1 := TPCopy(s,position+1,LENGTH_OF_STRING(s)-position);
      if ChaineNeContientQueDesChiffres(s1) then
        begin
          if keepDelimitor
            then EnleveChiffresApresCeCaractereEnFinDeLigne := TPCopy(s,1,position)
            else EnleveChiffresApresCeCaractereEnFinDeLigne := TPCopy(s,1,position - 1);
          exit;
        end;
    end;
  EnleveChiffresApresCeCaractereEnFinDeLigne := s;
end;


function EnleveCesCaracteresEntreCesCaracteres(whichChars : SetOfChar; delim1,delim2 : char; const s : String255; keepDelimitors : boolean) : String255;
var position1,position2 : SInt32;
    s1 : String255;
begin
  position1 := Pos(delim1,s);
  position2 := Pos(delim2,s);
  if (position1 > 0) and (position2 > 0) and (position2 > position1) then
    begin
      s1 := TPCopy(s,position1 + 1,position2 - position1 - 1);
      if ChaineNeContientQueCesCaracteres(s1,whichChars) then
        begin
          if keepDelimitors
            then EnleveCesCaracteresEntreCesCaracteres := TPCopy(s, 1, position1)     + TPCopy(s, position2    , LENGTH_OF_STRING(s) - position2 + 1)
            else EnleveCesCaracteresEntreCesCaracteres := TPCopy(s, 1, position1 - 1) + TPCopy(s, position2 + 1, LENGTH_OF_STRING(s) - position2);
          exit;
        end;
    end;
  EnleveCesCaracteresEntreCesCaracteres := s;
end;


function EnleveCesCaracteresAvantCeCaractereEnDebutDeLigne(whichChars : SetOfChar; delim : char; const s : String255; keepDelimitor : boolean) : String255;
var position : SInt32;
    s1 : String255;
begin
  position := Pos(delim,s);
  if (position > 0) then
    begin
      s1 := TPCopy(s,1,position - 1);
      if ChaineNeContientQueCesCaracteres(s1,whichChars) then
        begin
          if keepDelimitor
            then EnleveCesCaracteresAvantCeCaractereEnDebutDeLigne := TPCopy(s, position    , LENGTH_OF_STRING(s) - position + 1)
            else EnleveCesCaracteresAvantCeCaractereEnDebutDeLigne := TPCopy(s, position + 1, LENGTH_OF_STRING(s) - position);
          exit;
        end;
    end;
  EnleveCesCaracteresAvantCeCaractereEnDebutDeLigne := s;
end;


function EnleveCesCaracteresApresCeCaractereEnFinDeLigne(whichChars : SetOfChar; delim : char; const s : String255; keepDelimitor : boolean) : String255;
var position : SInt32;
    s1 : String255;
begin
  position := LastPos(CharToString(delim),s);
  if (position > 0) then
    begin
      s1 := TPCopy(s,position+1,LENGTH_OF_STRING(s)-position);
      if ChaineNeContientQueCesCaracteres(s1,whichChars) then
        begin
          if keepDelimitor
            then EnleveCesCaracteresApresCeCaractereEnFinDeLigne := TPCopy(s,1,position)
            else EnleveCesCaracteresApresCeCaractereEnFinDeLigne := TPCopy(s,1,position - 1);
          exit;
        end;
    end;
  EnleveCesCaracteresApresCeCaractereEnFinDeLigne := s;
end;






function SeparerLesChiffresParTrois(var s : String255) : String255;
var len,i : SInt16;
    result : String255;
begin
  result := '';
  len := LENGTH_OF_STRING(s);
  if len > 0
    then
      begin
        i := len;
			  while i > 3 do
			    begin
			      result := CharToString(' ') + s[i-2] + s[i-1] + s[i] + result;
			      i := i - 3;
			    end;
			  if i >= 3
			    then SeparerLesChiffresParTrois := Concat(s[1],s[2],s[3],result) else
			  if i >= 2
			    then SeparerLesChiffresParTrois := Concat(s[1],s[2],result) else
			  if i >= 1
			    then SeparerLesChiffresParTrois := Concat(s[1],result);
      end
    else
      SeparerLesChiffresParTrois := '';
end;

function SecondesEnJoursHeuresSecondes(secondes : SInt32) : String255;
var s : String255;
    aux : SInt32;
    jours,heures : boolean;
begin
  s := '';
  if secondes > 0
    then
      begin
        jours := false;
        if (secondes > 86400) then
          begin
            jours := true;
            aux := secondes div 86400;
            secondes := secondes - aux*86400;
            if EstLaVersionFrancaiseDeCassio
              then
                if aux <= 1
                  then s := s + IntToStr(aux) + ' jour '
                  else s := s + IntToStr(aux) + ' jours '
              else
                if aux <= 1
                  then s := s + IntToStr(aux) + ' day '
                  else s := s + IntToStr(aux) + ' days ';
          end;
        heures := false;
        if (secondes > 3600) or jours then
          begin
            heures := true;
            aux := secondes div 3600;
            secondes := secondes - aux*3600;
            s := s + IntToStr(aux) + ' h. ';
          end;
        if (secondes > 60) or heures then
          begin
            aux := secondes div 60;
            secondes := secondes - aux*60;
            s := s + IntToStr(aux) + ' min. ';
          end;
        s := s + IntToStr(secondes) + ' sec. ';
      end
    else
      begin
        s := IntToStr(secondes)+' sec.';
      end;
  SecondesEnJoursHeuresSecondes := s;
end;


function BufferToPascalString(buffer : Ptr; indexDepart,indexFin : SInt32) : String255;
var s : String255;
    len,i : SInt32;
    localBuffer : PackedArrayOfCharPtr;
begin
  s := '';

  if (buffer <> NIL) then
    begin
      len := indexFin - indexDepart + 1;
      if len > 255 then len := 255;

      if len > 0 then
        begin
          localBuffer := PackedArrayOfCharPtr(buffer);
          for i := 0 to len - 1 do
            s[i + 1] := localBuffer^[indexDepart + i];
          SET_LENGTH_OF_STRING(s,len);
        end;
    end;

  BufferToPascalString := s;
end;


function FindStringInBuffer(const s : String255; buffer : Ptr; bufferLength,from,direction : SInt32; var positionTrouvee : SInt32) : boolean;
var len,depart,k : SInt32;
    texte : PackedArrayOfCharPtr;
begin

  FindStringInBuffer := false;
  positionTrouvee := 0;

  if (buffer <> NIL) and (bufferLength > 0) then
    begin
		  len := LENGTH_OF_STRING(s);
		  if (len > 0) then
		    begin
				  texte := PackedArrayOfCharPtr(buffer);

				  if (from < 0) then from := 0;
				  if (from > bufferLength - 1) then from := bufferLength - 1;
				  if (direction <  0) then direction := -1;
				  if (direction >= 0) then direction := +1;

				  depart := from;

				  while (depart >= 0) and ((depart + len - 1) <= bufferLength) do
				    begin
						  k := 0;
						  while (k < len) and (texte^[depart + k] = s[k + 1]) do
						    inc(k);

						  if (k = len) then
						    begin
						      FindStringInBuffer := true;
						      positionTrouvee := depart;
						      exit;
						    end;

						  depart := depart + direction;
						end;
				end;
	  end;
end;


function ParseBuffer(buffer : Ptr; bufferLength,from : SInt32; var indexDernierCaractereLu : SInt32) : String255;
var n : SInt32;
    texte : PackedArrayOfCharPtr;
    result : String255;
begin

  result := '';
  indexDernierCaractereLu := from - 1;

  if (buffer <> NIL) and (bufferLength > 0) then
    begin
		  texte := PackedArrayOfCharPtr(buffer);

		  if (from < 0) then from := 0;
		  if (from > bufferLength - 1) then from := bufferLength - 1;

		  n := from;
		
      while (n < bufferLength) and (parser_delimiters_as_booleans[ord(texte^[n])]) do n := n + 1;  {on saute les espaces en tete }
      if (n < bufferLength) then
        begin
          if protect_parser_with_quotes and (texte^[n] = '"')
            then
              begin
                n := n + 1;
                while (n < bufferLength) and (texte^[n] <> '"') do   {on va jusqu'au prochain quote}
                  begin
                    result := Concat(result,texte^[n]);
                    n := n + 1;
                  end;
                if (texte^[n] = '"') and (n < bufferLength) then n := n + 1; {on saute le quote fermant}
              end
            else
              while (n < bufferLength) and (not(parser_delimiters_as_booleans[ord(texte^[n])])) do {on va jusqu'au prochain espace}
                begin
                  result := Concat(result,texte^[n]);
                  n := n + 1;
                end;
        end;
						
		  indexDernierCaractereLu := (n - 1);
	  end;
	
	ParseBuffer := result;
end;


function PseudoHammingDistance(const s1, s2 : String255) : SInt32;
var  count1, count2 : array[0..255] of SInt32;
     k, dist : SInt32;
begin
  for k := 0 to 255 do
    begin
      count1[k] := 0;
      count2[k] := 0;
    end;

  for k := 1 to LENGTH_OF_STRING(s1) do inc(count1[ord(s1[k])]);
  for k := 1 to LENGTH_OF_STRING(s2) do inc(count2[ord(s2[k])]);

  dist := 0;
  for k := 0 to 255 do
    dist := dist + abs(count1[k] - count2[k]);

  PseudoHammingDistance := dist;
end;


// Pour normaliser un nombre decimal ou hexa en enlevant les zeros initiaux inutiles
function RemoveLeadingZeros(const s : String255) : String255;
var k,len : SInt32;
begin
  len := LENGTH_OF_STRING(s);
  if (len >= 2) and (s[1] = '0')
    then
      begin
        k := 2;
        while (k < len) and (s[k] = '0') do
          inc(k);
        RemoveLeadingZeros := TPCopy(s, k, len - k + 1);
      end
    else
      RemoveLeadingZeros := s;
end;


end.
