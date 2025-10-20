UNIT UnitWeightedSet;



{Gestion d'ensembles tries de SInt32 pondéré par un poids en SInt32, avec des listes}

INTERFACE


 USES UnitDefCassio;



{Creation et destruction}
function MakeEmptyWeightedSet : WeightedSet;
function MakeOneElementWeightedSet(element,poids : SInt32) : WeightedSet;
procedure DisposeWeightedSet(var S : WeightedSet);

{Fonctions de test}
function WeightedSetEstVide(S : WeightedSet) : boolean;
function CardinalOfWeightedSet(S : WeightedSet) : SInt32;
function SommeOfWeightedSet(S : WeightedSet) : SInt32;

{Union et Intersection}
function DuplicateWeightedSet(S : WeightedSet) : WeightedSet;
function UnionWeightedSet(S1,S2 : WeightedSet) : WeightedSet;
function IntersectionWeightedSet(S1,S2 : WeightedSet) : WeightedSet;

{Union destructive}
procedure AddElementToWeightedSet(element,poids : SInt32; var S : WeightedSet);


{Ecriture dans le rapport}
procedure WriteWeightedSetDansRapport(const nom : String255; S : WeightedSet; avecCardinal : boolean);
procedure WritelnWeightedSetDansRapport(const nom : String255; S : WeightedSet; avecCardinal : boolean);

{Verification de l'unite}
procedure TestWeightedSet;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapport, UnitPropertyList, UnitProperties ;
{$ELSEC}
    {$I prelink/WeightedSet.lk}
{$ENDC}


{END_USE_CLAUSE}










function MakeEmptyWeightedSet : WeightedSet;
var result : WeightedSet;
begin
  result.cardinal := 0;
  result.somme := 0;
  result.theSet := NIL;
  MakeEmptyWeightedSet := result;
end;

function MakeOneElementWeightedSet(element,poids : SInt32) : WeightedSet;
var prop : Property;
    result : WeightedSet;
begin
  prop := MakeCoupleLongintProperty(UnknowProp,element,poids);
  result.cardinal := 1;
  result.somme := poids;
  result.theSet := CreateOneElementPropertyList(prop);
  DisposePropertyStuff(prop);

  MakeOneElementWeightedSet := result;
end;


procedure DisposeWeightedSet(var S : WeightedSet);
begin
  S.cardinal := 0;
  S.somme := 0;
  DisposePropertyList(S.theSet);
end;


function WeightedSetEstVide(S : WeightedSet) : boolean;
begin
  WeightedSetEstVide := (S.cardinal = 0) | PropertyListEstVide(S.theSet);
end;

function CardinalOfWeightedSet(S : WeightedSet) : SInt32;
begin
  CardinalOfWeightedSet := S.cardinal;
end;

function SommeOfWeightedSet(S : WeightedSet) : SInt32;
begin
  SommeOfWeightedSet := S.somme;
end;


procedure WriteWeightedSetDansRapport(const nom : String255; S : WeightedSet; avecCardinal : boolean);
var L : PropertyList;
    element,poids : SInt32;
begin
  if nom <> '' then WriteDansRapport(Concat(nom,' = '));
  if WeightedSetEstVide(S)
    then WriteNumDansRapport('{ }, cardinal = ',S.cardinal)
    else
      begin
        WriteDansRapport('{');
        L := S.theSet;
        repeat
          GetCoupleLongintOfProperty(L^.head,element,poids);
          WriteNumDansRapport('(',element);
          WriteNumDansRapport(',',poids);
          WriteDansRapport(')');
          L := L^.tail;
          if (L <> NIL) then WriteDansRapport(' ');
        until (L = NIL);
        WriteStringDansRapport('}');
        if avecCardinal then WriteNumDansRapport(', cardinal = ',S.cardinal);
        if avecCardinal then WriteNumDansRapport(', somme = ',S.somme);
      end;
end;

procedure WritelnWeightedSetDansRapport(const nom : String255; S : WeightedSet; avecCardinal : boolean);
begin
  WriteWeightedSetDansRapport(nom,S,avecCardinal);
  WritelnDansRapport('');
end;

function DuplicateWeightedSet(S : WeightedSet) : WeightedSet;
var result : WeightedSet;
begin
  result.cardinal := S.cardinal;
  result.somme := S.somme;
  result.theSet := DuplicatePropertyList(S.theSet);
  DuplicateWeightedSet := result;
end;

function UnionWeightedSet(S1,S2 : WeightedSet) : WeightedSet;
var result : WeightedSet;
    L1,L2 : PropertyList;
    queueCourante : PropertyList;
    element1,element2,poids1,poids2 : SInt32;

  procedure AddToResult(prop : Property);
  var element,poids : SInt32;
  begin
    GetCoupleLongintOfProperty(prop,element,poids);
    inc(result.cardinal);
    result.somme := result.somme+poids;
    if result.theSet = NIL
      then
        begin
          result.theSet := CreateOneElementPropertyList(prop);
          queueCourante := result.theSet;
        end
      else
        begin
          queueCourante^.tail := CreateOneElementPropertyList(prop);
          queueCourante := queueCourante^.tail;
        end;
  end;

begin
  if WeightedSetEstVide(S1) then
    begin
      UnionWeightedSet := DuplicateWeightedSet(S2);
      exit(UnionWeightedSet);
    end;
  if WeightedSetEstVide(S2) then
    begin
      UnionWeightedSet := DuplicateWeightedSet(S1);
      exit(UnionWeightedSet);
    end;

  with result do
    begin
      cardinal := 0;
      somme := 0;
      theSet := NIL;
      queueCourante := NIL;

      L1 := S1.theSet;
      L2 := S2.theSet;
      while (L1 <> NIL) & (L2 <> NIL) do
        begin
          GetCoupleLongintOfProperty(L1^.head,element1,poids1);
          GetCoupleLongintOfProperty(L2^.head,element2,poids2);
          if element1 = element2 then
            begin
              AddToResult(L1^.head);
              L1 := L1^.tail;
              L2 := L2^.tail;
            end;
          if element1 < element2 then
            begin
              AddToResult(L1^.head);
              L1 := L1^.tail;
            end;
          if element1 > element2 then
            begin
              AddToResult(L2^.head);
              L2 := L2^.tail;
            end;
          if (L1 = NIL) & (L2 <> NIL) then
            repeat
              AddToResult(L2^.head);
              L2 := L2^.tail;
            until (L2 = NIL);
          if (L2 = NIL) & (L1 <> NIL) then
            repeat
              AddToResult(L1^.head);
              L1 := L1^.tail;
            until (L1 = NIL);
        end;
    end;
  UnionWeightedSet := result;
end;



function IntersectionWeightedSet(S1,S2 : WeightedSet) : WeightedSet;
var result : WeightedSet;
    L1,L2 : PropertyList;
    queueCourante : PropertyList;
    element1,element2,poids1,poids2 : SInt32;

  procedure AddToResult(prop : Property);
  var element,poids : SInt32;
  begin
    GetCoupleLongintOfProperty(prop,element,poids);
    inc(result.cardinal);
    result.somme := result.somme+poids;
    if result.theSet = NIL
      then
        begin
          result.theSet := CreateOneElementPropertyList(prop);
          queueCourante := result.theSet;
        end
      else
        begin
          queueCourante^.tail := CreateOneElementPropertyList(prop);
          queueCourante := queueCourante^.tail;
        end;
  end;

begin
  if WeightedSetEstVide(S1) | WeightedSetEstVide(S2) then
    begin
      IntersectionWeightedSet := MakeEmptyWeightedSet;
      exit(IntersectionWeightedSet);
    end;

  with result do
    begin
      cardinal := 0;
      somme := 0;
      theSet := NIL;
      queueCourante := NIL;

      L1 := S1.theSet;
      L2 := S2.theSet;
      while (L1 <> NIL) & (L2 <> NIL) do
        begin
          GetCoupleLongintOfProperty(L1^.head,element1,poids1);
          GetCoupleLongintOfProperty(L2^.head,element2,poids2);
          if element1 = element2 then
            begin
              AddToResult(L1^.head);
              L1 := L1^.tail;
              L2 := L2^.tail;
            end;
          if element1 < element2 then L1 := L1^.tail;
          if element1 > element2 then L2 := L2^.tail;

          if (L1 = NIL) & (L2 <> NIL) then L2 := NIL;
          if (L2 = NIL) & (L1 <> NIL) then L1 := NIL;
        end;
    end;
  IntersectionWeightedSet := result;
end;



procedure AddElementToWeightedSet(element,poids : SInt32; var S : WeightedSet);
var singleton,resultat : WeightedSet;
begin
  singleton := MakeOneElementWeightedSet(element,poids);
  resultat := UnionWeightedSet(singleton,S);
  DisposeWeightedSet(singleton);
  DisposeWeightedSet(S);
  S := resultat;
end;


procedure TestWeightedSet;
var S1,S2,S3,S4 : WeightedSet;
begin
  WritelnSoldesCreationsPropertiesDansRapport('entrée dans TestWeightedSet : ');


  S1 := MakeEmptyWeightedSet;
  WritelnWeightedSetDansRapport('ensemble vide S1',S1,true);
  S2 := UnionWeightedSet(S1,S1);
  WritelnWeightedSetDansRapport('union vide S2',S2,true);
  S3 := IntersectionWeightedSet(S1,S2);
  WritelnWeightedSetDansRapport('Intersection vide S3',S3,true);
  DisposeWeightedSet(S1);
  DisposeWeightedSet(S2);
  DisposeWeightedSet(S3);

  WritelnSoldesCreationsPropertiesDansRapport('après ensemble vide : ');

  S1 := MakeOneElementWeightedSet(-4,4);
  WritelnWeightedSetDansRapport('singleton S1',S1,true);
  S2 := UnionWeightedSet(S1,S1);
  WritelnWeightedSetDansRapport('union singleton S2',S2,true);
  S3 := IntersectionWeightedSet(S1,S2);
  WritelnWeightedSetDansRapport('Intersection singleton S3',S3,true);
  DisposeWeightedSet(S1);
  DisposeWeightedSet(S2);
  DisposeWeightedSet(S3);

  WritelnSoldesCreationsPropertiesDansRapport('après singleton : ');

  S1 := MakeOneElementWeightedSet(7,-7);
  WritelnWeightedSetDansRapport('S1',S1,true);
  S2 := MakeOneElementWeightedSet(5,-5);
  WritelnWeightedSetDansRapport('S2',S2,true);
  S3 := UnionWeightedSet(S1,S2);
  WritelnWeightedSetDansRapport('S3',S3,true);
  S4 := IntersectionWeightedSet(S1,S2);
  WritelnWeightedSetDansRapport('S4',S4,true);
  DisposeWeightedSet(S1);
  DisposeWeightedSet(S2);
  DisposeWeightedSet(S3);
  DisposeWeightedSet(S4);

  WritelnSoldesCreationsPropertiesDansRapport('après union : ');


  S1 := MakeOneElementWeightedSet(5,-5);
  AddElementToWeightedSet(7,-7,S1);
  AddElementToWeightedSet(52,-52,S1);
  AddElementToWeightedSet(32,-32,S1);
  AddElementToWeightedSet(-10,10,S1);
  AddElementToWeightedSet(63,-63,S1);
  AddElementToWeightedSet(5,-5,S1);
  AddElementToWeightedSet(-1,1,S1);
  AddElementToWeightedSet(7,-7,S1);
  WritelnWeightedSetDansRapport('S1',S1,true);
  S2 := MakeOneElementWeightedSet(100,100);
  AddElementToWeightedSet(7,-7,S2);
  AddElementToWeightedSet(120,-120,S2);
  AddElementToWeightedSet(5,-5,S2);
  AddElementToWeightedSet(-1,1,S2);
  AddElementToWeightedSet(-1,1,S2);
  AddElementToWeightedSet(-44,44,S2);
  AddElementToWeightedSet(100,-100,S2);
  AddElementToWeightedSet(52,-52,S2);
  AddElementToWeightedSet(120,-120,S2);
  AddElementToWeightedSet(51,-51,S2);
  WritelnWeightedSetDansRapport('S2',S2,true);
  S3 := UnionWeightedSet(S1,S2);
  WritelnWeightedSetDansRapport('S3',S3,true);
  S4 := IntersectionWeightedSet(S1,S2);
  WritelnWeightedSetDansRapport('S4',S4,true);
  DisposeWeightedSet(S1);
  DisposeWeightedSet(S2);
  DisposeWeightedSet(S3);
  DisposeWeightedSet(S4);

  WritelnSoldesCreationsPropertiesDansRapport('après union et Intersection des ensembles compliqués : ');


  WritelnSoldesCreationsPropertiesDansRapport('sortie de TestWeightedSet : ');
end;

END.
