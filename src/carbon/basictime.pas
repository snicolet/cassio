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

procedure GetTime(var r : DateTimeRec);
function DateCouranteEnString : String255;
function DateEnString(const whichDate : DateTimeRec) : String255;



implementation


procedure GetTime(var r : DateTimeRec);
begin
   with r do
     begin
        DeCodeDate(Date(),year,month,day);
        DecodeTime(Time(),hour,minute,second,millisecond);
     end;
end;

function DateEnString(const whichDate : DateTimeRec) : String255;
var s : String255;
begin
  with whichDate do
    s := IntToStrWithPadding(year,   4, '0') +
         IntToStrWithPadding(month,  2, '0') +
         IntToStrWithPadding(day,    2, '0') +
         IntToStrWithPadding(hour,   2, '0') +
         IntToStrWithPadding(minute, 2, '0') +
         IntToStrWithPadding(second, 2, '0');
  DateEnString := s;
end;


function DateCouranteEnString : String255;
var myDate : DateTimeRec;
begin
  GetTime(myDate);
  DateCouranteEnString := DateEnString(myDate);
end;


begin
end.