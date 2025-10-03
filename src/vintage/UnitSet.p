UNIT UnitSet;


{Gestion d'ensembles d'entiers,
avec des arbres binaires de recherche}

INTERFACE



 USES UnitDefCassio;




{Creation et destruction}
function MakeEmptyIntegerSet : IntegerSet;                                                                                                                                          ATTRIBUTE_NAME('MakeEmptyIntegerSet')
function MakeOneElementIntegerSet(theKey : SInt32; data : SInt32) : IntegerSet;                                                                                                     ATTRIBUTE_NAME('MakeOneElementIntegerSet')
procedure DisposeIntegerSet(var S : IntegerSet);                                                                                                                                    ATTRIBUTE_NAME('DisposeIntegerSet')

{Fonctions de test}
function IntegerSetEstVide(S : IntegerSet) : boolean;                                                                                                                               ATTRIBUTE_NAME('IntegerSetEstVide')
function CardinalOfIntegerSet(S : IntegerSet) : SInt32;                                                                                                                             ATTRIBUTE_NAME('CardinalOfIntegerSet')
function MemberOfIntegerSet(theKey: SInt32; var data : SInt32; S : IntegerSet) : boolean;                                                                                           ATTRIBUTE_NAME('MemberOfIntegerSet')

{Ajout et retrait destructifs}
procedure AddIntegerToSet(theKey : SInt32; data : SInt32; var S : IntegerSet);                                                                                                      ATTRIBUTE_NAME('AddIntegerToSet')
procedure RemoveIntegerFromSet(theKey : SInt32; var S : IntegerSet);                                                                                                                ATTRIBUTE_NAME('RemoveIntegerFromSet')

{Ecriture dans le rapport}
procedure WriteIntegerSetDansRapport(const nom : String255; S : IntegerSet; avecCardinal : boolean);                                                                                ATTRIBUTE_NAME('WriteIntegerSetDansRapport')
procedure WritelnIntegerSetDansRapport(const nom : String255; S : IntegerSet; avecCardinal : boolean);                                                                              ATTRIBUTE_NAME('WritelnIntegerSetDansRapport')

{Verification de l'unite}
procedure TestIntegerSet;                                                                                                                                                           ATTRIBUTE_NAME('TestIntegerSet')


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapport, UnitABR ;
{$ELSEC}
    {$I prelink/Set.lk}
{$ENDC}


{END_USE_CLAUSE}











function MakeEmptyIntegerSet : IntegerSet;
var result : IntegerSet;
begin
  result.cardinal := 0;
  result.arbre := MakeEmptyABR;
  MakeEmptyIntegerSet := result;
end;

function MakeOneElementIntegerSet(theKey : SInt32; data : SInt32) : IntegerSet;
var result : IntegerSet;
begin
  result.cardinal := 1;
  result.arbre := MakeOneElementABR(theKey,data);
  MakeOneElementIntegerSet := result;
end;

procedure DisposeIntegerSet(var S : IntegerSet);
begin
  with S do
    begin
      cardinal := 0;
      DisposeABR(arbre);
    end;
end;

function IntegerSetEstVide(S : IntegerSet) : boolean;
begin
  IntegerSetEstVide := (S.cardinal = 0) | ABRIsEmpty(S.arbre);
end;


function CardinalOfIntegerSet(S : IntegerSet) : SInt32;
begin
  CardinalOfIntegerSet := S.cardinal;
end;


function MemberOfIntegerSet(theKey: SInt32; var data : SInt32; S : IntegerSet) : boolean;
var elementTrouve : ABR;
begin
  if IntegerSetEstVide(S)
    then MemberOfIntegerSet := false
    else
      begin
        elementTrouve := ABRSearch(S.arbre,theKey);
        if elementTrouve <> NIL
          then
            begin
              MemberOfIntegerSet := true;
              data := elementTrouve^.data;
            end
          else
            begin
              MemberOfIntegerSet := false;
              data := -1;
            end;
      end;
end;


procedure AddIntegerToSet(theKey : SInt32; data : SInt32; var S : IntegerSet);
var element : ABR;
begin
  if IntegerSetEstVide(S)
    then S := MakeOneElementIntegerSet(theKey,data)
    else
      begin
        if (ABRSearch(S.arbre,theKey) = NIL) then {s'il n'y est pas deja...}
          begin
            element := MakeOneElementABR(theKey,data);
            if element <> NIL then
              begin
                S.cardinal := S.cardinal+1;
                ABRInserer(S.arbre,element);
              end;
          end;
    end;
end;


procedure RemoveIntegerFromSet(theKey : SInt32; var S : IntegerSet);
var element : ABR;
begin
  if not(IntegerSetEstVide(S)) then
    begin
      element := ABRSearch(S.arbre,theKey);
      if (element <> NIL) then {s'il y est...}
        begin
          S.cardinal := S.cardinal - 1;
          SupprimerDansABR(S.arbre,element);
        end;
    end;
end;


procedure WriteIntegerSetDansRapport(const nom : String255; S : IntegerSet; avecCardinal : boolean);
begin
  WritelnStringDansRapport('IntegerSet '+nom+' :');
  if avecCardinal then
    WritelnNumDansRapport(Concat(nom,'.cardinal = '),S.cardinal);
  WritelnStringDansRapport(Concat(nom,'.ABR = {'));
  ABRAffichageInfixe('',S.arbre);
  WriteDansRapport('}');
end;


procedure WritelnIntegerSetDansRapport(const nom : String255; S : IntegerSet; avecCardinal : boolean);
begin
  WriteIntegerSetDansRapport(nom,S,avecCardinal);
  WritelnDansRapport('');
end;



procedure TestIntegerSet;
begin

end;


END.
