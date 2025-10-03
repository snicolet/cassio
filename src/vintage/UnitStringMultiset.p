UNIT UnitStringMultiset;


{Gestion d'ensembles de chaines de caracteres,
avec du hachage puis des arbres binaires de recherche}

INTERFACE




 USES UnitDefCassio;



{Creation et destruction}
function MakeEmptyStringMultiset(charSize, stringSize : SInt32) : StringMultiset;                                                                                                   ATTRIBUTE_NAME('MakeEmptyStringMultiset')
function MakeOneElementStringMultiset(const theString : String255) : StringMultiset;                                                                                                ATTRIBUTE_NAME('MakeOneElementStringMultiset')
procedure DisposeStringMultiset(var S : StringMultiset);                                                                                                                            ATTRIBUTE_NAME('DisposeStringMultiset')

{Fonctions de test}
function StringMultisetEstVide(S : StringMultiset) : boolean;                                                                                                                       ATTRIBUTE_NAME('StringMultisetEstVide')
function CardinalOfStringMultiset(S : StringMultiset) : SInt32;                                                                                                                     ATTRIBUTE_NAME('CardinalOfStringMultiset')
function MemberOfStringMultiset(const theString : String255; var nbOccurences : SInt32; S : StringMultiset) : boolean;                                                              ATTRIBUTE_NAME('MemberOfStringMultiset')

{Ajout et retrait destructifs}
function AddStringToMultiset(const theString : String255; var S : StringMultiset) : boolean;                                                                                        ATTRIBUTE_NAME('AddStringToMultiset')
procedure RemoveMultipleOccurencesOfStringFromMultiset(const theString : String255; N : SInt32; var S : StringMultiset);                                                            ATTRIBUTE_NAME('RemoveMultipleOccurencesOfStringFromMultiset')
procedure RemoveStringFromMultiset(const theString : String255; var S : StringMultiset);                                                                                            ATTRIBUTE_NAME('RemoveStringFromMultiset')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitHashing, UnitRapport, MyStrings, UnitStringSet, UnitServicesMemoire ;
{$ELSEC}
    ;
    {$I prelink/StringMultiset.lk}
{$ENDC}


{END_USE_CLAUSE}











const kDeletedFromStringMultiSet = -1;



function MakeEmptyStringMultiset(charSize, stringSize : SInt32) : StringMultiset;
var result : StringMultiset;
    taille : SInt32;
begin

  result.theSet                  := MakeEmptyStringSet;
  result.theChars                := NIL;
  result.fin                     := NIL;
  result.occurence               := NIL;
  result.totalOccurences         := 0;
  result.nbreChainesMax          := 0;
  result.tailleCumuleeChainesMax := 0;
  result.derniereCaseVideTrouvee := 0;

  if (charSize > 0) & (stringSize > 0)
    then
      begin

        taille := (stringSize + 10) * Sizeof(SInt32);

        result.theChars                := PackedArrayOfCharPtr(AllocateMemoryPtr(charSize + 10));
        result.fin                     := LongintArrayPtr(AllocateMemoryPtrClear(taille));
        result.occurence               := LongintArrayPtr(AllocateMemoryPtrClear(taille));
        result.nbreChainesMax          := stringSize;
        result.tailleCumuleeChainesMax := charSize;

      end
    else
      begin
        Sysbeep(0);
        WritelnDansRapport('ASSERT ! (charSize <= 0) | (stringSize <= 0) dans MakeEmptyStringMultiset !!!');
      end;

  MakeEmptyStringMultiset := result;
end;



procedure DisposeStringMultiset(var S : StringMultiset);
begin
  with S do
    begin
      DisposeStringSet(theSet);
      DisposeMemoryPtr(Ptr(theChars));
      DisposeMemoryPtr(Ptr(fin));
      DisposeMemoryPtr(Ptr(occurence));
      totalOccurences         := 0;
      nbreChainesMax          := 0;
      tailleCumuleeChainesMax := 0;
      derniereCaseVideTrouvee := 0;
    end;
end;


function CardinalOfStringMultiset(S : StringMultiset) : SInt32;
begin
  CardinalOfStringMultiset := S.theSet.cardinal;
end;


function StringMultisetEstVide(S : StringMultiset) : boolean;
begin
  StringMultisetEstVide := (CardinalOfStringMultiset(S) = 0) | StringSetEstVide(S.theSet) | (S.totalOccurences <= 0);
end;



function MemberOfStringMultiset(const theString : String255; var nbOccurences : SInt32; S : StringMultiset) : boolean;
var index : SInt32;
begin
  MemberOfStringMultiset := false;
  nbOccurences := 0;

  if MemberOfStringSet(theString, index, S.theSet) & (S.occurence^[index] > 0) then
    begin
      MemberOfStringMultiset := true;
      nbOccurences := S.occurence^[index];
    end;
end;


function TrouveIndexVideDansStringMultiset(var S : StringMultiset; var index : SInt32) : boolean;
var i : SInt32;
begin

  i := S.derniereCaseVideTrouvee + 1;

  if (i > 0) & (i <= S.nbreChainesMax) & (S.occurence^[i] = 0)
    then
      begin
        TrouveIndexVideDansStringMultiset := true;
        index := i;
        S.derniereCaseVideTrouvee := i;
      end
    else
      TrouveIndexVideDansStringMultiset := false;

end;


function AddStringToMultiset(const theString : String255; var S : StringMultiset) : boolean;
var index : SInt32;
    longueur, i : SInt32;
    isMemberOfStheSet : boolean;
begin

  AddStringToMultiset := false;

  with S do
    begin

      isMemberOfStheSet := MemberOfStringSet(theString, index, theSet);

      if isMemberOfStheSet & (occurence^[index] > 0) then
        begin
          inc(occurence^[index]);
          inc(totalOccurences);
          AddStringToMultiset := true;
          exit(AddStringToMultiset);
        end;

      if isMemberOfStheSet & (occurence^[index] = kDeletedFromStringMultiSet) then
        begin
          occurence^[index] := 1;
          inc(totalOccurences);
          AddStringToMultiset := true;
          exit(AddStringToMultiset);
        end;

      if not(isMemberOfStheSet) then
        begin
          longueur := LENGTH_OF_STRING(theString);

          if TrouveIndexVideDansStringMultiset(S,index) &
             (index > 0) & (index <= nbreChainesMax) &
             ((fin^[index - 1] + longueur) <= tailleCumuleeChainesMax) then
            begin

              occurence^[index] := 1;
              inc(totalOccurences);

              fin^[index] := fin^[index - 1] + longueur;

              for i := 1 to longueur do
                theChars^[fin^[index - 1] + i] := theString[i];

              AddStringToSet(theString, index, theSet);

              AddStringToMultiset := true;
              exit(AddStringToMultiset);
            end;
        end;

    end;
end;



function MakeOneElementStringMultiset(const theString : String255) : StringMultiset;
var result : StringMultiset;
begin

  result := MakeEmptyStringMultiset(20000,5000);

  if AddStringToMultiset(theString, result) then DoNothing;

  MakeOneElementStringMultiset := result;
end;



procedure RemoveMultipleOccurencesOfStringFromMultiset(const theString : String255; N : SInt32; var S : StringMultiset);
var index : SInt32;
    temp : SInt32;
begin


  with S do
    if MemberOfStringSet(theString, index, theSet) then
      begin

        temp := occurence^[index];
        occurence^[index] := occurence^[index] - N;

        if occurence^[index] <= 0
          then
            begin
              occurence^[index] := kDeletedFromStringMultiSet;
              totalOccurences := totalOccurences - temp;
            end
          else
           totalOccurences := totalOccurences - N;
      end;
end;



procedure RemoveStringFromMultiset(const theString : String255; var S : StringMultiset);
begin
  RemoveMultipleOccurencesOfStringFromMultiset(theString, 1, S);
end;

(*
procedure WriteStringMultisetDansRapport(const nom : String255; S : StringMultiset; avecCardinal : boolean);
begin
  WritelnStringDansRapport('StringMultiset '+nom+' :');
  if avecCardinal then
    WritelnNumDansRapport(Concat(nom,'.cardinal = '),CardinalOfStringMultiset(S));
  WritelnStringDansRapport(Concat(nom,'.ABR = {'));
  ABRAffichageInfixe('',S.arbre);
  WriteDansRapport('}');
end;




procedure WritelnStringMultisetDansRapport(const nom : String255; S : StringMultiset; avecCardinal : boolean);
begin
  WriteStringMultisetDansRapport(nom,S,avecCardinal);
  WritelnDansRapport('');
end;


procedure WritelnStringDansRapportSansRepetition(theString : String255; var stringPool : StringMultiset);
var data : SInt32;
begin
  if not(MemberOfStringMultiset(theString,data,stringPool)) then
    begin
      WritelnDansRapport(theString);
      AddStringToMultiset(theString,stringPool);
    end;
end;


procedure TestStringMultiset;
var S : StringMultiset;
    theString : String255;
    data : SInt32;
begin
  S := MakeOneElementStringMultiset('');
  WritelnStringMultisetDansRapport('initial ',S,true);
  DisposeStringMultiset(S);

  WritelnStringMultisetDansRapport('apres dispose, initial ',S,true);


  S := MakeEmptyStringMultiset(200000,10000);

  theString := '';
  AddStringToMultiset(theString,S);
  AddStringToMultiset('F5',S);
  AddStringToMultiset('F5D6',S);
  AddStringToMultiset('F5D6C3',S);
  AddStringToMultiset('F5D6C3D3',S);
  AddStringToMultiset('F5D6C3D3C4',S);
  WritelnStringMultisetDansRapport('apres 5 coups ',S,true);


  theString := '';
  AddStringToMultiset(theString,S);
  AddStringToMultiset('F5',S);
  AddStringToMultiset('F5D6',S);
  AddStringToMultiset('F5D6C4',S);
  AddStringToMultiset('F5D6C4D3',S);
  AddStringToMultiset('F5D6C4D3C3',S);
  WritelnStringMultisetDansRapport('apres 5 coups (inter)',S,true);


  WritelnStringAndBoolDansRapport('member('',S) = ',MemberOfStringMultiset('',data,S));

  RemoveStringFromMultiset('',S);
  WritelnStringMultisetDansRapport('apres avoir enleve la position de depart',S,true);

  RemoveStringFromMultiset('',S);
  WritelnStringMultisetDansRapport('apres avoir enleve la position de depart',S,true);

  DisposeStringMultiset(S);

  WritelnStringMultisetDansRapport('apres dispose, S ',S,true);
end;

*)
END.


















