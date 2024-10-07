unit quickdraw;


interface

uses SysUtils;


function Milliseconds() : QWord;
function Tickcount() : QWord;

implementation

var start : QWord;

function Milliseconds() : QWord;
begin
   result := GetTickCount64() - start;
end;

function Tickcount() : QWord;
begin
   result := Milliseconds() * 60 div 1000;
end;

begin
  start := GetTickCount64();
end.