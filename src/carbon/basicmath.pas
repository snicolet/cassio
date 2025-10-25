unit basicmath;

interface

uses

{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  SysUtils,
  basictypes,
  basicstring;
  
  
implementation


function id(b : boolean; name : string255) : boolean;
begin
   write(name + ' = ');
   writeln(b);
   
   result := b;
end;

var c1, c2 : boolean;
begin

   c1 := true;
   c2 := false;
   
   if (id(c1, 'c1') and id(c2, 'c2')) then
      writeln('| marche : OK');

end.


















