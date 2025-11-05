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

{ecriture des numeriques dans le rapport}
procedure WriteNumDansRapport(s : String255; num : SInt32);
procedure WritelnNumDansRapport(s : String255; num : SInt32);



implementation


procedure WriteDansRapport(s : String255);
begin
    write(s); 
end;

procedure WritelnDansRapport(s : String255);
begin
    writeln(s); 
end;

procedure WriteNumDansRapport(s : String255; num : SInt32);
begin
   write(s, num);
end;

procedure WritelnNumDansRapport(s : String255; num : SInt32);
begin
    writeln(s, num);
end;


begin
end.