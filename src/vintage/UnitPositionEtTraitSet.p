UNIT UnitPositionEtTraitSet;



{Gestion d'ensembles de PositionEtTraitRec,
avec du hachage puis des arbres binaires de recherche}

INTERFACE







 USES UnitDefCassio;



{Creation et destruction}
function MakeEmptyPositionEtTraitSet : PositionEtTraitSet;
function MakeOneElementPositionEtTraitSet(var position : PositionEtTraitRec; data : SInt32) : PositionEtTraitSet;
procedure DisposePositionEtTraitSet(var S : PositionEtTraitSet);

{Fonctions de test}
function PositionEtTraitSetEstVide(S : PositionEtTraitSet) : boolean;
function CardinalOfPositionEtTraitSet(S : PositionEtTraitSet) : SInt32;
function MemberOfPositionEtTraitSet(var position : PositionEtTraitRec; var data : SInt32; S : PositionEtTraitSet) : boolean;

{Ajout et retrait destructifs}
procedure AddPositionEtTraitToSet(var position : PositionEtTraitRec; data : SInt32; var S : PositionEtTraitSet);
procedure RemovePositionEtTraitFromSet(var position : PositionEtTraitRec; var S : PositionEtTraitSet);

{Ecriture dans le rapport}
procedure WritePositionEtTraitSetDansRapport(const nom : String255; S : PositionEtTraitSet; avecCardinal : boolean);
procedure WritelnPositionEtTraitSetDansRapport(const nom : String255; S : PositionEtTraitSet; avecCardinal : boolean);

{Verification de l'unite}
procedure TestPositionEtTraitSet;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitScannerUtils, UnitHashing, UnitRapport, UnitABR, UnitPositionEtTrait ;
{$ELSEC}
    {$I prelink/PositionEtTraitSet.lk}
{$ENDC}


{END_USE_CLAUSE}










function MakeEmptyPositionEtTraitSet : PositionEtTraitSet;
var result : PositionEtTraitSet;
begin
  result.cardinal := 0;
  result.arbre := MakeEmptyABR;
  MakeEmptyPositionEtTraitSet := result;
end;

function MakeOneElementPositionEtTraitSet(var position : PositionEtTraitRec; data : SInt32) : PositionEtTraitSet;
var hash : SInt32;
    result : PositionEtTraitSet;
    trait : SInt32;
begin
  trait := GetTraitOfPosition(position);
  hash := GenericHash(@position,sizeof(PositionEtTraitRec));
  result.cardinal := 1;
  result.arbre := MakeOneElementABR(hash,data);
  MakeOneElementPositionEtTraitSet := result;
end;

procedure DisposePositionEtTraitSet(var S : PositionEtTraitSet);
begin
  with S do
    begin
      cardinal := 0;
      DisposeABR(arbre);
    end;
end;

function PositionEtTraitSetEstVide(S : PositionEtTraitSet) : boolean;
begin
  PositionEtTraitSetEstVide := (S.cardinal = 0) | ABRIsEmpty(S.arbre);
end;


function CardinalOfPositionEtTraitSet(S : PositionEtTraitSet) : SInt32;
begin
  CardinalOfPositionEtTraitSet := S.cardinal;
end;


function MemberOfPositionEtTraitSet(var position : PositionEtTraitRec; var data : SInt32; S : PositionEtTraitSet) : boolean;
var hash : SInt32;
    elementTrouve : ABR;
    trait : SInt32;
begin
  if PositionEtTraitSetEstVide(S)
    then MemberOfPositionEtTraitSet := false
    else
      begin
        trait := GetTraitOfPosition(position);
        hash := GenericHash(@position,sizeof(PositionEtTraitRec));
        elementTrouve := ABRSearch(S.arbre,hash);
        if elementTrouve <> NIL
          then
            begin
              MemberOfPositionEtTraitSet := true;
              data := elementTrouve^.data;
            end
          else
            begin
              MemberOfPositionEtTraitSet := false;
              data := -1;
            end;
      end;
end;


procedure AddPositionEtTraitToSet(var position : PositionEtTraitRec; data : SInt32; var S : PositionEtTraitSet);
var element : ABR;
    hash : SInt32;
    trait : SInt32;
begin
  if PositionEtTraitSetEstVide(S)
    then S := MakeOneElementPositionEtTraitSet(position,data)
    else
      begin
        trait := GetTraitOfPosition(position);
        hash := GenericHash(@position,sizeof(PositionEtTraitRec));
        if (ABRSearch(S.arbre,hash) = NIL) then {s'il n'y est pas deja...}
          begin
            element := MakeOneElementABR(hash,data);
            if element <> NIL then
              begin
                S.cardinal := S.cardinal+1;
                ABRInserer(S.arbre,element);
              end;
          end;
    end;
end;


procedure RemovePositionEtTraitFromSet(var position : PositionEtTraitRec; var S : PositionEtTraitSet);
var element : ABR;
    hash : SInt32;
    trait : SInt32;
begin
  if not(PositionEtTraitSetEstVide(S)) then
    begin
      trait := GetTraitOfPosition(position);
      hash := GenericHash(@position,sizeof(PositionEtTraitRec));
      element := ABRSearch(S.arbre,hash);
      if (element <> NIL) then {s'il y est...}
        begin
          S.cardinal := S.cardinal-1;
          SupprimerDansABR(S.arbre,element);
        end;
    end;
end;


procedure WritePositionEtTraitSetDansRapport(const nom : String255; S : PositionEtTraitSet; avecCardinal : boolean);
begin
  WritelnStringDansRapport('PositionEtTraitSet '+nom+' :');
  if avecCardinal then
    WritelnNumDansRapport(Concat(nom,'.cardinal = '),S.cardinal);
  WritelnStringDansRapport(Concat(nom,'.ABR = {'));
  ABRAffichageInfixe('',S.arbre);
  WriteDansRapport('}');
end;

procedure WritelnPositionEtTraitSetDansRapport(const nom : String255; S : PositionEtTraitSet; avecCardinal : boolean);
begin
  WritePositionEtTraitSetDansRapport(nom,S,avecCardinal);
  WritelnDansRapport('');
end;


procedure TestPositionEtTraitSet;
var S : PositionEtTraitSet;
    position : PositionEtTraitRec;
    data : SInt32;
begin
  position := PositionEtTraitInitiauxStandard;
  S := MakeOneElementPositionEtTraitSet(position,0);
  WritelnPositionEtTraitSetDansRapport('initial ',S,true);
  DisposePositionEtTraitSet(S);

  WritelnPositionEtTraitSetDansRapport('apres dispose, initial ',S,true);


  S := MakeEmptyPositionEtTraitSet;

  position := PositionEtTraitInitiauxStandard;
  AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('F5')) then AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('D6')) then AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('C3')) then AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('D3')) then AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('C4')) then AddPositionEtTraitToSet(position,0,S);
  WritelnPositionEtTraitSetDansRapport('apres 5 coups ',S,true);


  position := PositionEtTraitInitiauxStandard;
  AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('F5')) then AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('D6')) then AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('C4')) then AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('D3')) then AddPositionEtTraitToSet(position,0,S);
  if UpdatePositionEtTrait(position,StringEnCoup('C3')) then AddPositionEtTraitToSet(position,0,S);
  WritelnPositionEtTraitSetDansRapport('apres 5 coups (inter)',S,true);


  WritelnStringAndBoolDansRapport('member(pos. initiale,S) = ',MemberOfPositionEtTraitSet(position,data,S));

  position := PositionEtTraitInitiauxStandard;
  RemovePositionEtTraitFromSet(position,S);
  WritelnPositionEtTraitSetDansRapport('apres avoir enleve la position de depart',S,true);

  position := PositionEtTraitInitiauxStandard;
  RemovePositionEtTraitFromSet(position,S);
  WritelnPositionEtTraitSetDansRapport('apres avoir enleve la position de depart',S,true);

  DisposePositionEtTraitSet(S);

  WritelnPositionEtTraitSetDansRapport('apres dispose, S ',S,true);
end;


END.
