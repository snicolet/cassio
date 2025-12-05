unit basicterminal;

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


{insertion de texte dans le rapport}
procedure WriteDansRapport(s : String255);
procedure WritelnDansRapport(s : String255);


{ecriture des numeriques dans le rapport}
procedure WriteNumDansRapport(s : String255; num : SInt32);
procedure WritelnNumDansRapport(s : String255; num : SInt32);


{Fonction d'insertion d'un texte dans le rapport}
{si scrollerSynchronisation est vrai, on demande que les}
{eventuels ascenseurs du rapport soient mis a jours automatiquement}
procedure InsereTexteDansRapportSync(text : Ptr; length : SInt32; scrollerSynchronisation : boolean);
procedure InsereTexteDansRapport(text : Ptr; length : SInt32);


{effacement des caracteres de l'intervalle positionDebut..positionFin}
procedure DetruireTexteDansRapport(posDebut,posFin : SInt32; scrollerSynchronisation : boolean);


{Diverses fonctions d'acces aux caracteres du texte du rapport}
function GetTailleRapport : SInt32;
procedure FinRapport;

{Fonctions de gestion de la selection du rapport}
function GetDebutSelectionRapport : SInt32;
function GetFinSelectionRapport : SInt32;
procedure SetDebutSelectionRapport(debut : SInt32);
procedure SetFinSelectionRapport(fin : SInt32);


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

function GetDebutSelectionRapport : SInt32;
begin
  TODO({$I %CURRENTROUTINE%});
  Result := 0;
end;

function GetFinSelectionRapport : SInt32;
begin
  TODO({$I %CURRENTROUTINE%});
  Result := 0;
end;

procedure SetDebutSelectionRapport(debut : SInt32);
begin
  TODO({$I %CURRENTROUTINE%});
end;

procedure SetFinSelectionRapport(fin : SInt32);
begin
  TODO({$I %CURRENTROUTINE%});
end;

function GetTailleRapport : SInt32;
begin
  TODO({$I %CURRENTROUTINE%});
  Result := 0;
end;

procedure FinRapport;
begin
  TODO({$I %CURRENTROUTINE%});
end;

procedure InsereStringDansRapportSync(s : String255; scrollerSynchronisation : boolean);
begin
  TODO({$I %CURRENTROUTINE%});
end;

procedure InsereTexteDansRapportSync(text : Ptr; length : SInt32; scrollerSynchronisation : boolean);
begin
  TODO({$I %CURRENTROUTINE%});
end;

procedure InsereTexteDansRapport(text : Ptr; length : SInt32);
begin
  InsereTexteDansRapportSync(text,length,true);
end;

{effacement des caracteres de l'intervalle positionDebut..positionFin}
procedure DetruireTexteDansRapport(posDebut,posFin : SInt32; scrollerSynchronisation : boolean);
begin
  TODO({$I %CURRENTROUTINE%});
end;

procedure Foo(n : Sint32);
begin
   TODO({$I %CURRENTROUTINE%});
end;


begin
   foo(5);
end.