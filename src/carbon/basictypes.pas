unit basictypes;

interface

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  SysUtils;


  // common types
  type
    SInt64 = Int64;    // signed integer, 64 bits
    SInt32 = Longint;  // signed integer, 32 bits
    SInt16 = SmallInt; // signed integer, 16 bits
    SInt8  = Int8;     // signed integer,  8 bits

    // t = UInt64;        // unsigned integer, 64 bits (already in FreePascal)
    // t = UInt32;        // unsigned integer, 32 bits (already in FreePascal)
    // t = UInt16;        // unsigned integer, 16 bits (already in FreePascal)
    // t = UInt8;         // unsigned integer,  8 bits (already in FreePascal)

    short = SInt16;
    long = SInt32;

    charP = ^char;
    bytePtr =  ^UInt8;
    integerP = ^SInt16;
    integerH = ^integerP;
    UInt16Ptr = ^UInt16;
    UInt32Ptr = ^UInt32;
    UInt64Ptr = ^UInt64;
    unsignedword = UInt16;
    unsignedwordP = ^unsignedword;
    unsignedwordH = ^unsignedwordP;
    longintP = ^SInt32;
    longintH = ^longintP;
    unsignedlongP = ^UInt32;
    unsignedlongH = ^unsignedlongP;

    CRLFTypes = (CL_CRLF, CL_CR, CL_LF);
    CharSet = set of char;

    Ptr = Pointer;
    Handle = ^Pointer;
    UnivPtr = Pointer;
    UnivHandle = Handle;

    LongintArray = array[0..0] of SInt32;
    LongintArrayPtr = ^LongintArray;
    LongintArrayHdl = ^LongintArrayPtr;

    IntegerArray = array[0..0] of SInt16;
    IntegerArrayPtr = ^IntegerArray;
    IntegerArrayHdl = ^IntegerArrayPtr;

    PackedArrayOfByte = packed array[0..0] of byte;
    PackedArrayOfBytePtr = ^PackedArrayOfByte;

    PackedArrayOfChar = packed array[0..0] of char;
    PackedArrayOfCharPtr = ^PackedArrayOfChar;

    TwoBytesArray = packed array[0..1] of UInt8;
    FourBytesArray = packed array[0..3] of UInt8;
    buf255 = packed array[0..255] of char;

  // capacity constants
  const
    MAXINT_16BITS = 32767;   // upper bound of SInt16 integers

  // function types
  type
    ProcedureType = procedure();
    ProcedureTypeWithLongint = procedure(var param : SInt32);

  // time transformation constants
  const
    second_in_ms = 1000;
    minute_in_ms = SInt32(60) * second_in_ms;
    hour_in_ms = SInt32(60) * minute_in_ms;
    day_in_ms = SInt32(24) * hour_in_ms;
    second_in_ticks = SInt32(60);
    minute_in_ticks = SInt32(60) * second_in_ticks;
    hour_in_ticks = SInt32(60) * minute_in_ticks;
    day_in_ticks = SInt32(24) * hour_in_ticks;
    minute_in_seconds = SInt32(60);
    hour_in_seconds = SInt32(60) * minute_in_seconds;
    day_in_seconds = SInt32(24) * hour_in_seconds;
    hour_in_minutes = SInt32(60);
    day_in_minutes = SInt32(24) * hour_in_minutes;
    day_in_hours = SInt32(24);

  // some ANSI and keyboard hexa values constants ...
  const
    nulChar = 0;
    homeChar = $01;
    enterChar = $03;
    endChar = $04;
    helpChar = $05;
    backSpaceChar = $08;
    tabChar = $09;
    lfChar = $0A;
    pageUpChar = $0b;
    pageDownChar = $0c;
    crChar = $0D;
    escChar = $1b;
    escKey = $35;
    clearChar = $1b;
    clearKey = $47;
    leftArrowChar = $1c;
    rightArrowChar = $1d;
    upArrowChar = $1e;
    downArrowChar = $1f;
    spaceChar = $20;
    delChar = $7f;
    bulletChar = $a5;
    undoKey = $7a;
    cutKey = $78;
    copyKey = $63;
    pasteKey = $76;

  // ... and the corresponding chars constants
  const
    nul = chr(nulChar);
    enter = chr(enterChar);
    bs = chr(backSpaceChar);
    tab = chr(tabChar);
    lf = chr(lfChar);
    cr = chr(crChar);
    leftArrow = chr(leftArrowChar);
    rightArrow = chr(rightArrowChar);
    upArrow = chr(upArrowChar);
    downArrow = chr(downArrowChar);
    esc = chr(escChar);
    spc = chr(spaceChar);
    del = chr(delChar);


implementation


// TestBasicTypes() : performing some tests for the BasicTypes unit

procedure TestBasicTypes;
type myEnum = (kUnusedFooBar,kUnusedFooBar2);
begin
    Writeln('');
    Writeln('Verifying that enums types start at zero...');
    Write('SInt32(kUnusedFooBar) = ',SInt32(kUnusedFooBar));
    if SInt32(kUnusedFooBar) = 0
      then Writeln('...   OK')
      else Writeln('...   ERREUR !');
    Writeln('');

    Writeln('sizeof(SInt8) = ', sizeof(SInt8));
    Writeln('sizeof(UInt8) = ', sizeof(UInt8));
    Writeln('sizeof(double) = ', sizeof(double));
    Writeln('sizeof(TwoBytesArray) = ', sizeof(TwoBytesArray));
    Writeln('sizeof(FourBytesArray) = ', sizeof(FourBytesArray));
    Writeln('sizeof(Pointer) = ', sizeof(Pointer));
    Writeln('sizeof(Pointer^) = ', sizeof(Pointer^));
    Writeln('sizeof(Handle) = ', sizeof(Handle));
    Writeln('sizeof(Handle^) = ', sizeof(Handle^));
    Writeln('sizeof(Handle^^) = ', sizeof(Handle^^));
end;


begin
    TestBasicTypes();
end.







