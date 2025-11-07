unit basictime;

interface

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  BaseUnix,
  SysUtils,
  DateUtils,
  basictypes,
  basicstring;
  

type
   DateTimeRec = 
     record
        year        : UInt16;
        month       : UInt16;  
        day         : UInt16;
        hour        : UInt16;
        minute      : UInt16;
        second      : UInt16;
        millisecond : UInt16;
     end;


// Conversion
function DecodeDateTime(const whichDate : TDateTime) : DateTimeRec;
function CompactTime(const whichDate : DateTimeRec) : String255;


// Get current time and date
procedure GetTime(var r : DateTimeRec);
function CurrentTime() : String255;





implementation



// DecodeDateTime() returns the DateTimeRec from the FreePascal whichDate
function DecodeDateTime(const whichDate : TDateTime) : DateTimeRec;
begin
   with result do
     dateUtils.DecodeDateTime(whichDate,year,month,day,hour,minute,second,millisecond);
end;


// CompactTime convert a DateTimeRec record to a compact string
// Example of output : 20250131083701 for 31 jan 2025 at 08:37:01
function CompactTime(const whichDate : DateTimeRec) : String255;
var s : String255;
begin
  with whichDate do
    s := IntToStrWithPadding(year,   4, '0') +
         IntToStrWithPadding(month,  2, '0') +
         IntToStrWithPadding(day,    2, '0') +
         IntToStrWithPadding(hour,   2, '0') +
         IntToStrWithPadding(minute, 2, '0') +
         IntToStrWithPadding(second, 2, '0');
  CompactTime := s;
end;


// GetTime() returns the current date and time with milliseconds accuracy
procedure GetTime(var r : DateTimeRec);
begin
   with r do
     begin
        DeCodeDate(Date(),year,month,day);
        DecodeTime(Time(),hour,minute,second,millisecond);
     end;
end;

// CurrentTime() returns the current date and time in compact form with seconds accuracy
function CurrentTime() : String255;
var myDate : DateTimeRec;
begin
  GetTime(myDate);
  CurrentTime := CompactTime(myDate);
end;


begin
end.