UNIT MyMathUtils;

INTERFACE







 uses
     UnitDefCassio , fp;

	function Min (a, b: SInt32) : SInt32;
	function Max (a, b: SInt32) : SInt32;
	function Choose (cond: boolean; a, b: SInt32) : SInt32;
  function InRange(n, minimum, maximum : SInt32) : boolean;




	function RectWidth( const r : Rect ) : SInt32;
	function RectHeight( const r : Rect ) : SInt32;


	function Trunc(x : double) : SInt32;
  function RealToLongint(r : double) : SInt32;

  function Signe(n : SInt32) : SInt32;
  function InterpolationLineaire(x, x1, y1, x2, y2 : SInt32) : SInt32;
  function SafeAdd(x,y,bornesuperieure : SInt32) : SInt32;
	function ProchainMultipleDeN(a, N : SInt32) : SInt32;
  function PrecedentMultipleDeN(a, N : SInt32) : SInt32;


	procedure RandomizeTimer;
  function Random32() : SInt32;
  function RandomEntreBornes(a, b : SInt16) : SInt16;
  function RandomLongintEntreBornes(a, b : SInt32) : SInt32;
	function RandBelow( n : SInt32 ) : SInt32;
	function RandBetween( a, b: SInt32 ) : SInt32;
  function UneChanceSur(N : SInt32) : boolean;
  function PChancesSurN(P,N : SInt32) : boolean;


  function PuissanceReelle(x,exposant : double) : double;
	function Puissance(r : double; n : SInt32) : double;



	function NewMagicCookie : SInt32;

  procedure MY_SWAP_INTEGER( arg : UInt16Ptr );
  procedure MY_SWAP_LONGINT( arg : UInt32Ptr );

  function MySwapInteger(num : SInt16) : SInt16;
  function MySwapLongint(num : SInt32) : SInt32;

  procedure MySwapIntegerArray(theArray : UnivPtr; indexMin, indexMax : SInt32);
  procedure MySwapLongintArray(theArray : UnivPtr; indexMin, indexMax : SInt32);



  function Hexa(num : SInt32) : String255;
  function HexaWithoutDollar(num : UInt32) : String255;
	function HexN (n : SInt32) : char;
	function HexN2 (n : SInt32) : String255;
	function HexNN (n : SInt32; len : SInt16) : String255;
	function HexToNum (s : String255) : SInt32;
	
  function UInt64ToHexa(num : UInt64) : String255;
  function UInt64ToHexaWithDollar(num : UInt64) : String255;                                                                                                                         	
  function HexToUInt64(const s : String255) : UInt64;




  function Same64Bits(a , b : UInt64) : boolean;




IMPLEMENTATION


USES QuickDraw, Sound, OSUtils, MyTypes, UnitRapport, Timer, MyAssertions, MyStrings, Processes;

CONST
  unit_MyMathsUtils_magicCookieSeed : SInt32 = 0;


function InRange(n, minimum, maximum : SInt32) : boolean;
begin
	InRange := (n >= minimum) and (n <= maximum);
end;


function PuissanceReelle(x,exposant : double) : double;
begin
  if x <= 0.0
    then PuissanceReelle := 0.0
    else PuissanceReelle := exp( exposant * ln(x));
end;


function Puissance(r : double; n : SInt32) : double;
var i : SInt16;
    aux : double;
begin
  aux := 1.0;
  for i := 1 to n do
    aux := aux*r;
  Puissance := aux;
end;



{donne un identificateur unique et positif
 la periode est de 2^31 }
function NewMagicCookie : SInt32;
begin
  inc(unit_MyMathsUtils_magicCookieSeed);
  if unit_MyMathsUtils_magicCookieSeed <= 0
    then unit_MyMathsUtils_magicCookieSeed := 1;
  NewMagicCookie := unit_MyMathsUtils_magicCookieSeed;
end;


procedure RandomizeTimer;
var alea : SInt32;
    time : UnsignedWide;
    processNumber : ProcessSerialNumber;
begin
  alea := Random16();
  if (alea = 0) then alea := 1;
  alea := alea + NewMagicCookie;
  MicroSeconds(time);
  alea := alea + time.lo + TickCount;

  if (GetCurrentProcess(processNumber) = NoErr) then
    alea := alea xor processNumber.highLongOfPSN xor processNumber.lowLongOfPSN;

  SetRandomSeed(alea);
end;



function PChancesSurN(P,N : SInt32) : boolean;
begin
  if (0 <= P) and (P <= N) and (0 < N)
    then
      begin
        RandomizeTimer;
        PChancesSurN := ((Abs(Random32()) mod N) < P);
      end
    else
      begin
        SysBeep(0);
        PChancesSurN := false;
      end;
end;

function UneChanceSur(N : SInt32) : boolean;
begin
  UneChanceSur := PChancesSurN(1,N);
end;

function Signe(n : SInt32) : SInt32;
begin
  if n > 0 then Signe := 1 else
  if n = 0 then Signe := 0 else
  Signe := -1;
end;

{renvoie la valeur de y pour que (x,y) soit sur la droite(x1,y1),(x2,y2) }
function InterpolationLineaire(x, x1, y1, x2, y2 : SInt32) : SInt32;
begin
	if x1 = x2 then
		InterpolationLineaire := (y1 + y2) div 2    { should never happen !!! }
	else
		InterpolationLineaire := y1 + (((x - x1) * (y2 - y1)) div (x2 - x1));
end;

{renvoie la valeur de x+y en faisant attention a de pas depasser bornesuperieure }
{x,y,bornesuperieure sont supposes etre vaguement positifs}
function SafeAdd(x,y,bornesuperieure : SInt32) : SInt32;
begin
  if (x  > (bornesuperieure - y)) or (y  > (bornesuperieure - x))
    then SafeAdd := bornesuperieure
    else SafeAdd := x+y;
end;

function RandomEntreBornes(a, b : SInt16) : SInt16;
	var
		len : SInt16;
begin
	len := (b - a + 1);
	if len <= 0 then
		RandomEntreBornes := -1
	else
		RandomEntreBornes := a +(Abs(Random16()) mod len)
end;

function RandomLongintEntreBornes(a, b : SInt32) : SInt32;
	var
		len : SInt32;
begin
	len := (b - a + 1);
	if len <= 0 then
		RandomLongintEntreBornes := -1
	else
		RandomLongintEntreBornes := a +(Abs(Random32()) mod len)
end;


	function RandBelow( n : SInt32 ) : SInt32;
		var
			junk: SInt16;
	begin
		Assert( n >= 1 );
		junk := Random16();
		RandBelow := BAND(GetQDGlobalsRandomSeed, $7FFFFFFF) mod n;
	end;

	function RandBetween( a, b: SInt32 ) : SInt32;
		var
			result : SInt32;
	begin
		Assert( b >= a );
		if b <= a then begin
			result := a;
		end else begin
			result := RandBelow(b-a+1) + a;
		end;
		RandBetween := result;
	end;




function Trunc(x : double) : SInt32;
begin
  MyTrunc := roundtol(Trunc(x));
end;

function RealToLongint(r : double) : SInt32;
begin
  RealToLongint := Trunc(r);
end;

function Random32() : SInt32;
var aux1,aux2 : SInt32;
begin
  aux1 := Random16();
  aux2 := Random16();
  Random32() := aux1+aux2*65536;
end;





	function Max (a, b: SInt32) : SInt32;
	begin
		if a > b then begin
			Max := a;
		end else begin
			Max := b;
		end;
	end;

	function Min (a, b: SInt32) : SInt32;
	begin
		if a < b then begin
			Min := a;
		end else begin
			Min := b;
		end;
	end;


	function Choose (cond: boolean; a, b: SInt32) : SInt32;
	begin
		if cond then begin
			Choose := a;
		end else begin
			Choose := b;
		end;
	end;


function PrecedentMultipleDeN(a, N : SInt32) : SInt32;
var r : SInt32;
begin
  if (N = 0) then PrecedentMultipleDeN := 0 else
  if (N < 0) then PrecedentMultipleDeN := PrecedentMultipleDeN(a, -N)
   else
    begin
      r := a mod N;
      if (r = 0) then PrecedentMultipleDeN := a else
      if (a < 0)
        then PrecedentMultipleDeN := -ProchainMultipleDeN(-a, N)
        else PrecedentMultipleDeN := a - r;
    end;
end;


function ProchainMultipleDeN(a, N : SInt32) : SInt32;
var r : SInt32;
begin
  if (N = 0) then ProchainMultipleDeN := 0 else
  if (N < 0) then ProchainMultipleDeN := ProchainMultipleDeN(a, -N)
   else
    begin
      r := a mod N;
      if (r = 0) then ProchainMultipleDeN := a else
      if (a < 0)
        then ProchainMultipleDeN := -PrecedentMultipleDeN(-a, N)
        else ProchainMultipleDeN := a - r + N;
    end;
end;




	function RectWidth( const r : Rect ) : SInt32;
	begin
		RectWidth := r.right - r.left;
	end;

	function RectHeight( const r : Rect ) : SInt32;
	begin
		RectHeight := r.bottom - r.top;
	end;



procedure MY_SWAP_INTEGER( arg : UInt16Ptr );
var aux : UInt16;
begin
  aux := arg^;

	aux := (( aux shl 8) and $0FF00) or (( aux shr 8) and $00FF);

	arg^ := aux;
end;

procedure MY_SWAP_LONGINT( arg : UInt32Ptr );
var aux : UInt32;
begin
  aux := arg^;

  aux := ((aux and $FF) shl 24) or ((aux and $0FF00) shl 8) or ((aux shr 8) and $0FF00) or ((aux shr 24) and $FF);

  arg^ := aux;
end;



function MySwapInteger(num : SInt16) : SInt16;
	type
		TwoBytesArray = packed array[0..1] of UInt8;
		TwoBytesArrayPtr = ^TwoBytesArray;
	var
		twoBytes : TwoBytesArrayPtr;
		result,aux : SInt32;
begin
	twoBytes := TwoBytesArrayPtr(@num);
	result := 0;

	aux := twoBytes^[0];
	result := result + aux;
	aux := twoBytes^[1];
	aux := aux*256;
	result := result + aux;

	MySwapInteger := result;
end;


function MySwapLongint(num : SInt32) : SInt32;
  type
    FourBytesArrayPtr = ^FourBytesArray;
	var
		FourBytes : FourBytesArrayPtr;
		result,aux : SInt32;
begin
	FourBytes := FourBytesArrayPtr(@num);
	result := 0;

	aux := FourBytes^[0];
	result := result + aux;
	aux := FourBytes^[1];
	aux := aux*256;
	result := result + aux;
	aux := FourBytes^[2];
	aux := aux*65536;
	result := result + aux;
	aux := FourBytes^[3];
	aux := aux*16777216;
	result := result + aux;

	MySwapLongint := result;
end;


procedure MySwapIntegerArray(theArray : UnivPtr; indexMin, indexMax : SInt32);
var i : SInt32;
    myPointer : UInt16Ptr;
begin

  // WritelnDansRapport('Dans MySwapIntegerArray...');
  // WritelnNumDansRapport('   indexMin = ',indexMin);
  // WritelnNumDansRapport('   indexMax = ',indexMax);

  if (indexMin > indexMax) then
    begin
      WritelnDansRapport('ERROR : (indexMin > indexMax) dans MySwapIntegerArray !!! ');
      WritelnNumDansRapport('indexMin = ',indexMin);
      WritelnNumDansRapport('indexMax = ',indexMax);
    end;

  if (theArray = NIL) then
    begin
      WritelnDansRapport('ERROR : (theArray = NIL) dans MySwapIntegerArray !!! ');
    end;

  if ((indexMin > indexMax) or (theArray = NIL))
    then exit(MySwapIntegerArray);

  myPointer := UInt16Ptr(theArray);                  { c'est l'adresse de table[0] }
  myPointer := POINTER_ADD( myPointer, 2*indexMin);  { c'est donc l'adresse de table[indexMin] }

  for i := indexMin to indexMax do
    begin
      MY_SWAP_INTEGER( myPointer );                  { swapper les octets de table[i] }
      myPointer := POINTER_ADD(myPointer, 2);        { car un entier sur 16 bits fait 2 octets }
    end;
end;



procedure MySwapLongintArray(theArray : UnivPtr; indexMin, indexMax : SInt32);
var i : SInt32;
    myPointer : UInt32Ptr;
begin

  if (indexMin > indexMax) then
    begin
      WritelnDansRapport('ERROR : (indexMin > indexMax) dans MySwapLongintArray !!! ');
      WritelnNumDansRapport('indexMin = ',indexMin);
      WritelnNumDansRapport('indexMax = ',indexMax);
    end;

  if (theArray = NIL) then
    begin
      WritelnDansRapport('ERROR : (theArray = NIL) dans MySwapLongintArray !!! ');
    end;

  if ((indexMin > indexMax) or (theArray = NIL))
    then exit(MySwapLongintArray);

  myPointer := UInt32Ptr(theArray);                  { c'est l'adresse de table[0] }
  myPointer := POINTER_ADD( myPointer, 4*indexMin);  { c'est donc l'adresse de table[indexMin] }

  for i := indexMin to indexMax do
    begin
      MY_SWAP_LONGINT( myPointer );                  { swapper les octets de table[i] }
      myPointer := POINTER_ADD(myPointer, 4);        { car un entier sur 32 bits fait 4 octets }
    end;
end;



function HexaWithoutDollar(num : UInt32) : String255;
const chiffres = '0123456789abcdef';
var i : SInt32;
    v : UInt32;
    s : String255;
begin
  s := '';
  for i := 1 to 8 do
    begin
      v := BAND(BSR(num,(8-i)*4),$F);
      s := Concat(s,chiffres[v+1]);
    end;
  HexaWithoutDollar := s;
end;

function Hexa(num : SInt32) : String255;
const chiffres = '0123456789abcdef';
var i : SInt32;
    v : UInt32;
    s : String255;
begin
  s := '$';
  for i := 1 to 8 do
    begin
      v := BAND(BSR(num,(8-i)*4),$F);
      s := Concat(s,chiffres[v+1]);
    end;
  Hexa := s;
end;




	function HexN (n : SInt32) : char;
	begin
		n := BAND(n, $000F);
		if n >= 10 then begin
			n := n + 7;
		end;
		n := n + 48;
		HexN := Chr(n);
	end;

	function HexN2 (n : SInt32) : String255;
	begin
		HexN2 := Concat(HexN(BSR(n, 4)), HexN(n));
	end;

	function HexNN (n : SInt32; len : SInt16) : String255;
		var
			s : String255;
	begin
		if len > 15 then begin
			len := 15;
		end;
		s := HexN(n);
		while LENGTH_OF_STRING(s) < len do begin
			n := BAND(BSR(n, 4), $0FFFFFFF);
			s := Concat(HexN(n), s);
		end;
		HexNN := s;
	end;

function HexToNum (s : String255) : SInt32;
var n : SInt32;
		i, v: SInt16;
	begin
		i := 1;
		n := 0;
		while (i <= LENGTH_OF_STRING(s)) and
		      (IsDigit(s[i]) or IsAlpha(s[i])) do begin
			case s[i] of
				'A'..'Z':
					v := ord(s[i]) - 55;
				'a'..'z':
					v := ord(s[i]) - 87;
				'0'..'9':
					v := ord(s[i]) - 48;
			end;
			n := BSL(n, 4) + v;
			i := i + 1;
		end;
		HexToNum := n;
	end;


{$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }

function HexToUInt64(const s : String255) : UInt64;
var i, numDigits, v : UInt32;
    result : UInt64;
begin
  result := 0;

  numDigits := 0;

  i := LENGTH_OF_STRING(s);

  while (i > 0) do
    begin

          case s[i] of
            'A'..'Z': v := ord(s[i]) - 55;
		    'a'..'z': v := ord(s[i]) - 87;
		    '0'..'9': v := ord(s[i]) - 48;
		  end;
		
		  if (numDigits <= 15) then result := result + BSL(v, 4 * numDigits);
		
		  inc(numDigits);
		  dec(i);

    end;

  HexToUInt64 := result;
end;


function UInt64ToHexa(num : UInt64) : String255;
begin
  if ((num and $F000000000000000) = 0)
    then UInt64ToHexa := RemoveLeadingZeros(HexaWithoutDollar((num and $FFFFFFFF00000000) shr 32) +  HexaWithoutDollar(num and $00000000FFFFFFFF))
    else UInt64ToHexa := HexaWithoutDollar((num and $FFFFFFFF00000000) shr 32) +  HexaWithoutDollar(num and $00000000FFFFFFFF);
end;


function UInt64ToHexaWithDollar(num : UInt64) : String255;
begin
  UInt64ToHexaWithDollar := '$' + HexaWithoutDollar((num and $FFFFFFFF00000000) shr 32) +  HexaWithoutDollar(num and $00000000FFFFFFFF);
end;




{$ELSEC}

function HexToUInt64(const s : String255) : UInt64;
var i, numDigits, v : UInt32;
    result : UInt64;
begin

  with result do
    begin
      lo  := 0;
      hi := 0;

      numDigits := 0;

      i :=  LENGTH_OF_STRING(s);

      while (i > 0) do
        begin

          case s[i] of
            'A'..'Z':
    					v := ord(s[i]) - 55;
    				'a'..'z':
    					v := ord(s[i]) - 87;
    				'0'..'9':
    					v := ord(s[i]) - 48;
    		  end;
    		
    		  if (numDigits <= 7)  then lo := lo + BSL(v, 4*numDigits) else
    		  if (numDigits <= 15) then hi := hi + BSL(v, 4*(numDigits - 8));
    		
    		  inc(numDigits);
    		  dec(i);

        end;
    end;
  HexToUInt64 := result;
end;


function UInt64ToHexa(num : UInt64) : String255;
begin
  if ((num.hi and $F0000000) = 0)
    then UInt64ToHexa := RemoveLeadingZeros(HexaWithoutDollar(num.hi) +  HexaWithoutDollar(num.lo))
    else UInt64ToHexa := HexaWithoutDollar(num.hi) +  HexaWithoutDollar(num.lo);
end;


function UInt64ToHexaWithDollar(num : UInt64) : String255;
begin
  UInt64ToHexaWithDollar := '$' + HexaWithoutDollar(num.hi) +  HexaWithoutDollar(num.lo);
end;


{$ENDC}







{$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }

function Same64Bits(a , b : UInt64) : boolean;
begin
  Same64Bits := (a = b);
end;

{$ELSEC }

function Same64Bits(a , b : UInt64) : boolean;
begin
  Same64Bits := (b.lo = a.lo) and
                (b.hi = a.hi);
end;

{$ENDC}


end.
