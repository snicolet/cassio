UNIT UnitSortedSet;



{Gestion d'ensembles tries de SInt32, avec des listes}

INTERFACE







 USES UnitDefCassio;



{Creation et destruction}
function MakeEmptySortedSet : SortedSet;
function MakeOneElementSortedSet(element : SInt32) : SortedSet;
procedure DisposeSortedSet(var S : SortedSet);

{Fonctions de test}
function SortedSetEstVide(S : SortedSet) : boolean;
function CardinalOfSortedSet(S : SortedSet) : SInt32;

{Union et Intersection}
function DuplicateSortedSet(S : SortedSet) : SortedSet;
function UnionSortedSet(S1,S2 : SortedSet) : SortedSet;
function IntersectionSortedSet(S1,S2 : SortedSet) : SortedSet;

{Union destructive}
procedure AddElementToSortedSet(element : SInt32; var S : SortedSet);


{Ecriture dans le rapport}
procedure WriteSortedSetDansRapport(const nom : String255; S : SortedSet; avecCardinal : boolean);
procedure WritelnSortedSetDansRapport(const nom : String255; S : SortedSet; avecCardinal : boolean);

{Verification de l'unite}
procedure TestSortedSet;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapport, UnitPropertyList, UnitProperties ;
{$ELSEC}
    {$I prelink/SortedSet.lk}
{$ENDC}


{END_USE_CLAUSE}












function MakeEmptySortedSet : SortedSet;
var result : SortedSet;
begin
  result.cardinal := 0;
  result.theSet := NIL;
  MakeEmptySortedSet := result;
end;

function MakeOneElementSortedSet(element : SInt32) : SortedSet;
var prop : Property;
    result : SortedSet;
begin
  prop := MakeLongintProperty(UnknowProp,element);
  result.cardinal := 1;
  result.theSet := CreateOneElementPropertyList(prop);
  DisposePropertyStuff(prop);

  MakeOneElementSortedSet := result;
end;


procedure DisposeSortedSet(var S : SortedSet);
begin
  S.cardinal := 0;
  DisposePropertyList(S.theSet);
end;


function SortedSetEstVide(S : SortedSet) : boolean;
begin
  SortedSetEstVide := (S.cardinal = 0) | PropertyListEstVide(S.theSet);
end;

function CardinalOfSortedSet(S : SortedSet) : SInt32;
begin
  CardinalOfSortedSet := S.cardinal;
end;


procedure WriteSortedSetDansRapport(const nom : String255; S : SortedSet; avecCardinal : boolean);
var L : PropertyList;
begin
  if nom <> '' then WriteDansRapport(Concat(nom,' = '));
  if SortedSetEstVide(S)
    then WriteNumDansRapport('{ }, cardinal = ',S.cardinal)
    else
      begin
        WriteDansRapport('{');
        L := S.theSet;
        repeat
          WriteNumDansRapport('',GetLongintInfoOfProperty(L^.head));
          L := L^.tail;
          if (L <> NIL) then WriteDansRapport(' ');
        until (L = NIL);
        WriteStringDansRapport('}');
        if avecCardinal then WriteNumDansRapport(', cardinal = ',S.cardinal);
      end;
end;

procedure WritelnSortedSetDansRapport(const nom : String255; S : SortedSet; avecCardinal : boolean);
begin
  WriteSortedSetDansRapport(nom,S,avecCardinal);
  WritelnDansRapport('');
end;

function DuplicateSortedSet(S : SortedSet) : SortedSet;
var result : SortedSet;
begin
  result.cardinal := S.cardinal;
  result.theSet := DuplicatePropertyList(S.theSet);
  DuplicateSortedSet := result;
end;

function UnionSortedSet(S1,S2 : SortedSet) : SortedSet;
var result : SortedSet;
    L1,L2 : PropertyList;
    queueCourante : PropertyList;
    element1,element2 : SInt32;

  procedure AddToResult(prop : Property);
  begin
    inc(result.cardinal);
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
  if SortedSetEstVide(S1) then
    begin
      UnionSortedSet := DuplicateSortedSet(S2);
      exit(UnionSortedSet);
    end;
  if SortedSetEstVide(S2) then
    begin
      UnionSortedSet := DuplicateSortedSet(S1);
      exit(UnionSortedSet);
    end;

  with result do
    begin
      cardinal := 0;
      theSet := NIL;
      queueCourante := NIL;

      L1 := S1.theSet;
      L2 := S2.theSet;
      while (L1 <> NIL) & (L2 <> NIL) do
        begin
          element1 := GetLongintInfoOfProperty(L1^.head);
          element2 := GetLongintInfoOfProperty(L2^.head);
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
  UnionSortedSet := result;
end;



function IntersectionSortedSet(S1,S2 : SortedSet) : SortedSet;
var result : SortedSet;
    L1,L2 : PropertyList;
    queueCourante : PropertyList;
    element1,element2 : SInt32;

  procedure AddToResult(prop : Property);
  begin
    inc(result.cardinal);
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
  if SortedSetEstVide(S1) | SortedSetEstVide(S2) then
    begin
      IntersectionSortedSet := MakeEmptySortedSet;
      exit(IntersectionSortedSet);
    end;

  with result do
    begin
      cardinal := 0;
      theSet := NIL;
      queueCourante := NIL;

      L1 := S1.theSet;
      L2 := S2.theSet;
      while (L1 <> NIL) & (L2 <> NIL) do
        begin
          element1 := GetLongintInfoOfProperty(L1^.head);
          element2 := GetLongintInfoOfProperty(L2^.head);
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
  IntersectionSortedSet := result;
end;



procedure AddElementToSortedSet(element : SInt32; var S : SortedSet);
var singleton,resultat : SortedSet;
begin
  singleton := MakeOneElementSortedSet(element);
  resultat := UnionSortedSet(singleton,S);
  DisposeSortedSet(singleton);
  DisposeSortedSet(S);
  S := resultat;
end;


procedure TestSortedSet;
var S1,S2,S3,S4 : SortedSet;
begin
  WritelnSoldesCreationsPropertiesDansRapport('entrée dans TestSortedSet : ');


  S1 := MakeEmptySortedSet;
  WritelnSortedSetDansRapport('ensemble vide S1',S1,true);
  S2 := UnionSortedSet(S1,S1);
  WritelnSortedSetDansRapport('union vide S2',S2,true);
  S3 := IntersectionSortedSet(S1,S2);
  WritelnSortedSetDansRapport('Intersection vide S3',S3,true);
  DisposeSortedSet(S1);
  DisposeSortedSet(S2);
  DisposeSortedSet(S3);

  WritelnSoldesCreationsPropertiesDansRapport('après ensemble vide : ');

  S1 := MakeOneElementSortedSet(-4);
  WritelnSortedSetDansRapport('singleton S1',S1,true);
  S2 := UnionSortedSet(S1,S1);
  WritelnSortedSetDansRapport('union singleton S2',S2,true);
  S3 := IntersectionSortedSet(S1,S2);
  WritelnSortedSetDansRapport('Intersection singleton S3',S3,true);
  DisposeSortedSet(S1);
  DisposeSortedSet(S2);
  DisposeSortedSet(S3);

  WritelnSoldesCreationsPropertiesDansRapport('après singleton : ');

  S1 := MakeOneElementSortedSet(7);
  WritelnSortedSetDansRapport('S1',S1,true);
  S2 := MakeOneElementSortedSet(5);
  WritelnSortedSetDansRapport('S2',S2,true);
  S3 := UnionSortedSet(S1,S2);
  WritelnSortedSetDansRapport('S3',S3,true);
  S4 := IntersectionSortedSet(S1,S2);
  WritelnSortedSetDansRapport('S4',S4,true);
  DisposeSortedSet(S1);
  DisposeSortedSet(S2);
  DisposeSortedSet(S3);
  DisposeSortedSet(S4);

  WritelnSoldesCreationsPropertiesDansRapport('après union : ');


  S1 := MakeOneElementSortedSet(5);
  AddElementToSortedSet(7,S1);
  AddElementToSortedSet(52,S1);
  AddElementToSortedSet(32,S1);
  AddElementToSortedSet(-10,S1);
  AddElementToSortedSet(63,S1);
  AddElementToSortedSet(5,S1);
  AddElementToSortedSet(-1,S1);
  AddElementToSortedSet(7,S1);
  WritelnSortedSetDansRapport('S1',S1,true);
  S2 := MakeOneElementSortedSet(100);
  AddElementToSortedSet(7,S2);
  AddElementToSortedSet(120,S2);
  AddElementToSortedSet(5,S2);
  AddElementToSortedSet(-1,S2);
  AddElementToSortedSet(-1,S2);
  AddElementToSortedSet(-44,S2);
  AddElementToSortedSet(100,S2);
  AddElementToSortedSet(52,S2);
  AddElementToSortedSet(120,S2);
  AddElementToSortedSet(51,S2);
  WritelnSortedSetDansRapport('S2',S2,true);
  S3 := UnionSortedSet(S1,S2);
  WritelnSortedSetDansRapport('S3',S3,true);
  S4 := IntersectionSortedSet(S1,S2);
  WritelnSortedSetDansRapport('S4',S4,true);
  DisposeSortedSet(S1);
  DisposeSortedSet(S2);
  DisposeSortedSet(S3);
  DisposeSortedSet(S4);

  WritelnSoldesCreationsPropertiesDansRapport('après union et Intersection des ensembles compliqués : ');


  WritelnSoldesCreationsPropertiesDansRapport('sortie de TestSortedSet : ');
end;

END.
