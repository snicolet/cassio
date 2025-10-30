unit rapport;

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

procedure WriteDansRapport(s : String255);
procedure WritelnDansRapport(s : String255);
procedure WritelnStringAndNumDansRapport(s : String255; value : SInt32);


implementation


procedure WriteDansRapport(s : String255);
begin
    write(s); 
end;

procedure WritelnDansRapport(s : String255);
begin
    writeln(s); 
end;

procedure WritelnStringAndNumDansRapport(s : String255; value : SInt32);
begin
    writeln(s, value);
end;


begin
end.