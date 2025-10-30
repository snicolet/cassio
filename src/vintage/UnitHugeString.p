UNIT UnitHugeString;



INTERFACE


USES UnitDefHugeString;



{ Creation et/ou initialisation d'une HugeString }
function NewHugeString : HugeString;
function MakeHugeString(const s : String255) : HugeString;
function HugeStringIsUsable(const ligne : HugeString) : boolean;
procedure CopyHugeString(var source, dest : HugeString);


{ Acces ˆ une HugeString : recherche, comparaison, extraction d'une sous-chaine, etc... }
function LengthOfHugeString(const ligne : HugeString) : SInt32;
function GetBufferOfHugeString(const ligne : HugeString) : CharArrayPtr;
function GetMaximumCapacityOfHugeString() : SInt32;
function HugeStringIsEmpty(const ligne : HugeString) : boolean;
function SameHugeString(const ligne1, ligne2 : HugeString) : boolean;

{ Manipulations de HugeString }
function HugeStringBeginsWith(const s : String255; const ligne : HugeString) : boolean;
function FindStringInHugeString(const s : String255; const ligne : HugeString) : SInt32;
procedure TruncateHugeString(var ligne : HugeString; len : SInt32);
procedure SetLengthOfHugeString(var ligne : HugeString; len : SInt32);


{ Concatenation sur une HugeString }
procedure AppendToHugeString(var ligne : HugeString; const s : String255);
procedure AppendCharToHugeString(var ligne : HugeString; c : char);
procedure AppendToLeftOfHugeString(const s : String255; var ligne : HugeString);


{ Conversion de HugeString }
procedure HugeStringToBuffer(var ligne : HugeString; buffer : PackedArrayOfCharPtr; var nbOctets : SInt32);
procedure BufferToHugeString(buffer : PackedArrayOfCharPtr; nbOctets : SInt32; var ligne : HugeString);


{ Ecriture d'une HugeString dans le rapport }
procedure WriteHugeStringDansRapport(const ligne : HugeString);
procedure WritelnHugeStringDansRapport(const ligne : HugeString);


{ Lecture/ecriture d'une HugeString dans un fichier }
function Write(var fic : basicfile; const s : HugeString) : OSErr;
function Writeln(var fic : basicfile; const s : HugeString) : OSErr;
function Readln(var fic : basicfile; var s : HugeString) : OSErr;


{ Voir aussi Readln() et Writeln() dans basicfile.p }




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , MyStrings, UnitRapport, MyMathUtils, UnitServicesMemoire ;
{$ELSEC}
    ;
    {$I prelink/HugeString.lk}
{$ENDC}


{END_USE_CLAUSE}



CONST k_HUGE_STRING_BUFFER_SIZE = 32000;



(*
 *******************************************************************************
 *                                                                             *
 *   NewHugeString() permet d'initialiser d'une chaine ˆ la chaine vide.       *
 *                                                                             *
 *******************************************************************************
 *)
function NewHugeString : HugeString;
var ligne : HugeString;
begin
  with ligne do
    begin
      longueur   := 0;
      theChars   := CharArrayPtr(AllocateMemoryPtrClear(k_HUGE_STRING_BUFFER_SIZE + 10));
    end;
  NewHugeString := ligne;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   DisposeHugeString() libere la memoire occupee par une HugeString.         *
 *                                                                             *
 *******************************************************************************
 *)
procedure DisposeHugeString(var ligne : HugeString);
begin
  with ligne do
    begin
      longueur   := 0;
      if theChars <> NIL then
        DisposeMemoryPtr(Ptr(theChars));
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   MakeHugeString() : fabrication d'une HugeString a partir d'une chaine     *
 *   standard Pascal.                                                          *
 *                                                                             *
 *******************************************************************************
 *)
function MakeHugeString(const s : String255) : HugeString;
var result : HugeString;
begin
  result := NewHugeString;

  if HugeStringIsUsable(result) then
    AppendToHugeString(result, s);

  MakeHugeString := result;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   CopyHugeString() : copie d'une chaine. Pour une implŽmentation simple     *
 *   comme actuellement, il est plus elegant d'utiliser une simple affectation *
 *   dest := source                                                            *
 *                                                                             *
 *******************************************************************************
 *)
procedure CopyHugeString(var source, dest : HugeString);
var k : SInt32;
begin
  if (HugeStringIsUsable(source) and HugeStringIsUsable(dest)) then
    begin
      dest.longueur := source.longueur;
      for k := 1 to dest.longueur do
        dest.theChars^[k] := source.theChars^[k];
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   HugeStringIsUsable() : test si le buffer de la HugeString ne vaut pas NIL *
 *                                                                             *
 *******************************************************************************
 *)
function HugeStringIsUsable(const ligne : HugeString) : boolean;
begin
  HugeStringIsUsable := (ligne.longueur >= 0) and (ligne.theChars <> NIL);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SameHugeString() : test d'Žgalite de deux chaines.                        *
 *                                                                             *
 *******************************************************************************
 *)
function SameHugeString(const ligne1, ligne2 : HugeString) : boolean;
var k : SInt32;
begin

  SameHugeString := false;

  if not(HugeStringIsUsable(ligne1)) or not(HugeStringIsUsable(ligne2)) then
    exit;

  if (ligne1.longueur <> ligne2.longueur) then
    exit;

  for k := 1 to ligne1.longueur do
    if (ligne1.theChars^[k] <> ligne2.theChars^[k]) then
    exit;

  SameHugeString := true;
end;




(*
 *******************************************************************************
 *                                                                             *
 *   LengthOfHugeString()  renvoie la longueur de la chaine.                   *
 *                                                                             *
 *******************************************************************************
 *)
function LengthOfHugeString(const ligne : HugeString) : SInt32;
begin
  if HugeStringIsUsable(ligne)
    then LengthOfHugeString := ligne.longueur
    else LengthOfHugeString := 0;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetBufferOfHugeString()  renvoie le buffer des caracteres de la chaine.   *
 *                                                                             *
 *******************************************************************************
 *)
function GetBufferOfHugeString(const ligne : HugeString) : CharArrayPtr;
begin
  GetBufferOfHugeString := ligne.theChars;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   GetMaximumCapacityOfHugeString() renvoie la taille theorique maximale     *
 *   d'une HugeString (la taille du buffer sous-jacent).                       *
 *                                                                             *
 *******************************************************************************
 *)
function GetMaximumCapacityOfHugeString() : SInt32;
begin
  GetMaximumCapacityOfHugeString := k_HUGE_STRING_BUFFER_SIZE + 1;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   HugeStringIsEmpty() permet de tester si une chaine est vide.              *
 *                                                                             *
 *******************************************************************************
 *)
function HugeStringIsEmpty(const ligne : HugeString) : boolean;
begin
  HugeStringIsEmpty := (LengthOfHugeString(ligne) <= 0);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   FindStringInHugeString() permet de trouver une chaine Pascal dans une     *
 *   HugeString. Cette fonction renvoie la position de la chaine trouvee, ou   *
 *   zero si la chaine cherchee n'apparait pas dans la HugeString.             *
 *                                                                             *
 *******************************************************************************
 *)
function FindStringInHugeString(const s : String255; const ligne : HugeString) : SInt32;
var k,j,len : SInt32;
begin

  if HugeStringIsUsable(ligne) then
    with ligne do
      begin

        len := LENGTH_OF_STRING(s);

        if (len > 0)
          then
            begin
              for k := 1 to (LengthOfHugeString(ligne) - len + 1) do
                begin
                  j := 1;
                  while (j <= len) and (theChars^[k + j - 1] = s[j]) do
                    inc(j);

                  if (j > len) then  // found in position k
                    begin
                      FindStringInHugeString := k;
                      exit;
                    end;
                end;
            end
          else
            if (len <= 0) and (LengthOfHugeString(ligne) > 0) then
              begin
                FindStringInHugeString := 1;  // par convention
                exit;
              end;
      end;

  FindStringInHugeString := 0;  // not found

end;


(*
 *******************************************************************************
 *                                                                             *
 *   HugeStringBeginsWith() permet de tester (de maniere rapide et efficace)   *
 *   si une HugeString commence par une chaine Pascal donnee.                  *
 *                                                                             *
 *******************************************************************************
 *)
function HugeStringBeginsWith(const s : String255; const ligne : HugeString) : boolean;
begin
  if (s = '') or
     (LengthOfHugeString(ligne) <= 0) or
     not(HugeStringIsUsable(ligne))   or
     (ligne.theChars^[1] <> s[1]) then
    begin
      HugeStringBeginsWith := false;
      exit;
    end;

  HugeStringBeginsWith := (FindStringInHugeString(s, ligne) = 1);
end;




(*
 *******************************************************************************
 *                                                                             *
 *   AppendToHugeString() : concatenation d'une HugeString avec une string     *
 *   Pascal.                                                                   *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendToHugeString(var ligne : HugeString; const s : String255);
var k : SInt32;
begin

  for k := 1 to LENGTH_OF_STRING(s) do
    AppendCharToHugeString(ligne, s[k]);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AppendCharToHugeString() : ajout d'un caractere ˆ une HugeString.         *
 *                                                                             *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendCharToHugeString(var ligne : HugeString; c : char);
begin
  if HugeStringIsUsable(ligne) then
    with ligne do
      begin
        if (longueur < k_HUGE_STRING_BUFFER_SIZE) then
          begin
            inc(longueur);
            theChars^[longueur] := c;
          end;
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AppendToLeftOfHugeString() : concatenation d'une chaine Pascal avec une   *
 *   HugeString. La difference de cette fonction avec AppendToHugeString est   *
 *   qu'ici la chaine Pascal est ajoutee a gauche de la HugeString.            *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendToLeftOfHugeString(const s : String255; var ligne : HugeString);
var k , b : SInt32;
begin

  if HugeStringIsUsable(ligne) then
    begin
      b := LENGTH_OF_STRING(s);

      if (b > 0) then
        with ligne do
          begin

            for k := 1 to longueur do
              if ((k + b) <= k_HUGE_STRING_BUFFER_SIZE) then
                theChars^[k + b] := theChars^[k];

            longueur := Min(longueur + b, k_HUGE_STRING_BUFFER_SIZE);

            for k := 1 to b do
              theChars^[k] := s[k];

          end;
   end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   HugeStringToBuffer() permet de transformer une HugeString en buffer de    *
 *   caracteres, en placant le premier caractere de la chaine dans buffer[0],  *
 *   etc. La fonction n'alloue pas le buffer : c'est l'appelant qui doit four- *
 *   nir un buffer assez grand. La fonction renvoie aussi, dans le parametre   *
 *   nbOctets, le nombre de caracteres utilises dans le buffer (la longueur de *
 *   la HugeString) : les caracteres utiles dans le buffer aprs la fonction   *
 *   sont donc dans  buffer[0]...buffer[nbOctets - 1] .                        *
 *                                                                             *
 *******************************************************************************
 *)
procedure HugeStringToBuffer(var ligne : HugeString; buffer : PackedArrayOfCharPtr; var nbOctets : SInt32);
var k : SInt32;
begin
  nbOctets := 0;

  if HugeStringIsUsable(ligne) then
    with ligne do
      begin
        nbOctets := longueur;

        for k := 1 to nbOctets do
          buffer^[k - 1] := theChars^[k];
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   BufferToHugeString() recopie un buffer de caracteres dans une HugeString. *
 *   Cette procedure n'alloue pas de memoire : la HugeString doit etre valable *
 *   lors de l'appel de la procedure et doit avoir ete cree auparavant avec    *
 *   NewHugeString() ou MakeHugeString().                                      *
 *                                                                             *
 *******************************************************************************
 *)
procedure BufferToHugeString(buffer : PackedArrayOfCharPtr; nbOctets : SInt32; var ligne : HugeString);
var k : SInt32;
begin

  if HugeStringIsUsable(ligne) and (buffer <> NIL) and (nbOctets >= 0) then
      with ligne do
        begin

          longueur := Min(nbOctets , k_HUGE_STRING_BUFFER_SIZE);

          if (nbOctets > k_HUGE_STRING_BUFFER_SIZE)
            then
              begin
                WritelnDansRapport('ASSERT : (nbOctets > k_HUGE_STRING_BUFFER_SIZE) dans BufferToHugeString !!');
              end
            else
              begin

                for k := 1 to longueur do
                  theChars^[k] := buffer^[k - 1];

              end;
        end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   TruncateHugeString() permet de tronquer une HugeString.                   *
 *                                                                             *
 *******************************************************************************
 *)
procedure TruncateHugeString(var ligne : HugeString; len : SInt32);
begin
  if (len >= 0) and (len < LengthOfHugeString(ligne))
    then ligne.longueur := len;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SetLengthOfHugeString() permet de modifier brutalement la longueur d'une  *
 *   HugeString. A utiliser avec precaution !                                  *
 *                                                                             *
 *******************************************************************************
 *)
procedure SetLengthOfHugeString(var ligne : HugeString; len : SInt32);
begin
  if (len < 0)
    then len := 0;
  if (len > k_HUGE_STRING_BUFFER_SIZE)
    then len := k_HUGE_STRING_BUFFER_SIZE;

  ligne.longueur := len;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   WriteHugeStringDansRapport() ecrit une chaine dans le rapport sans        *
 *   ajouter de retour chariot ˆ la fin.                                       *
 *                                                                             *
 *******************************************************************************
 *)
procedure WriteHugeStringDansRapport(const ligne : HugeString);
begin

  if HugeStringIsUsable(ligne) and (ligne.longueur > 0) then
    InsereTexteDansRapport(Ptr(ligne.theChars), ligne.longueur);

end;


(*
 *******************************************************************************
 *                                                                             *
 *   WritelnHugeStringDansRapport() ecrit une chaine dans le rapport en        *
 *   ajoutant un retour chariot a la fin.                                      *
 *                                                                             *
 *******************************************************************************
 *)
procedure WritelnHugeStringDansRapport(const ligne : HugeString);
begin
  WriteHugeStringDansRapport(ligne);
  WritelnDansRapport('');
end;

function Write(var fic : basicfile; const s : HugeString) : OSErr;
var err : OSErr;
    count : SInt32;
    buffer : CharArrayPtr;
begin

  if FileIsStandardOutput(fic) then
    begin
      WriteHugeStringDansRapport(s);
      Write := NoErr;
      exit;
    end;

  err := -1;

  if HugeStringIsUsable(s) then
    begin
      count   := LengthOfHugeString(s);
      buffer  := GetBufferOfHugeString(s);

      err     := MyFSWrite(fic.refNum, count, @buffer^[1]);
    end;

  Write := err;
end;


function Writeln(var fic : basicfile; const s : HugeString) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      WritelnHugeStringDansRapport(s);
      Writeln := NoErr;
      exit;
    end;

  err := Write(fic, s);

  if (err = NoErr) then
    err := Writeln(fic, '');

  Writeln := err;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   Readln()  : lit un fichier fic de type basicfile jusqu'au premier         *
 *   retour chariot et met le resultat dans une HugeString. Cette fonction     *
 *   n'alloue pas la HugeString, elle doit avoir ete creee auparavant par un   *
 *   appel a NewHugeString() ou MakeHugeString().                              *
 *                                                                             *
 *******************************************************************************
 *)
function Readln(var fic : basicfile; var s : HugeString) : OSErr;
var buffer : CharArrayPtr;
    err : OSErr;
    count : SInt32;
begin

  err := -1;

  if HugeStringIsUsable(s) then
    begin
      count  := GetMaximumCapacityOfHugeString();
      buffer := GetBufferOfHugeString(s);

      err    := Readln(fic, @buffer^[1], count);

      if (err = NoErr)
        then SetLengthOfHugeString(s, count);

    end;

  Readln := err;
end;


END.
