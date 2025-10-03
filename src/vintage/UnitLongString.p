UNIT UnitLongString;



INTERFACE


USES UnitDefLongString;


{ Creation et/ou initialisation d'une LongString }
procedure InitLongString(var ligne : LongString);                                                                                                                                   ATTRIBUTE_NAME('InitLongString')
function MakeLongString(const s : String255) : LongString;                                                                                                                          ATTRIBUTE_NAME('MakeLongString')
function CopyLongString(const ligne : LongString) : LongString;                                                                                                                     ATTRIBUTE_NAME('CopyLongString')
procedure NormaliserLongString(var ligne : LongString);                                                                                                                             ATTRIBUTE_NAME('NormaliserLongString')


{ Acces à une LongString : recherche, comparaison, extraction d'une sous-chaine, etc... }
function LengthOfLongString(const ligne : LongString) : SInt32;                                                                                                                     ATTRIBUTE_NAME('LengthOfLongString')
function LongStringIsEmpty(const ligne : LongString) : boolean;                                                                                                                     ATTRIBUTE_NAME('LongStringIsEmpty')
function SameLongString(const ligne1, ligne2 : LongString) : boolean;                                                                                                               ATTRIBUTE_NAME('SameLongString')
function LongStringBeginsWith(const s : String255; const ligne : LongString) : boolean;                                                                                             ATTRIBUTE_NAME('LongStringBeginsWith')
function FindStringInLongString(const s : String255; const ligne : LongString) : SInt32;                                                                                            ATTRIBUTE_NAME('FindStringInLongString')
function LeftOfLongString(const ligne : LongString; len : SInt32) : LongString;                                                                                                     ATTRIBUTE_NAME('LeftOfLongString')


{ Concatenation sur une LongString }
procedure AppendToLongString(var ligne : LongString; const s : String255);                                                                                                          ATTRIBUTE_NAME('AppendToLongString')
procedure AppendCharToLongString(var ligne : LongString; c : char);                                                                                                                 ATTRIBUTE_NAME('AppendCharToLongString')
procedure AppendToLeftOfLongString(const s : String255; var ligne : LongString);                                                                                                    ATTRIBUTE_NAME('AppendToLeftOfLongString')


{ Conversion de LongString }
procedure LongStringToBuffer(var ligne : LongString; buffer : PackedArrayOfCharPtr; var nbOctets : SInt32);                                                                         ATTRIBUTE_NAME('LongStringToBuffer')
procedure BufferToLongString(buffer : PackedArrayOfCharPtr; nbOctets : SInt32; var ligne : LongString);                                                                             ATTRIBUTE_NAME('BufferToLongString')


{ Ecriture d'une LongString dans le rapport }
procedure WriteLongStringDansRapport(const ligne : LongString);                                                                                                                     ATTRIBUTE_NAME('WriteLongStringDansRapport')
procedure WritelnLongStringDansRapport(const ligne : LongString);                                                                                                                   ATTRIBUTE_NAME('WritelnLongStringDansRapport')


{ Voir aussi ReadlnLongStringDansFichierTexte() dans UnitFichiersTEXT.p }


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , MyStrings, UnitRapport, MyMathUtils ;
{$ELSEC}
    ;
    {$I prelink/LongString.lk}
{$ENDC}


{END_USE_CLAUSE}



(*
 *******************************************************************************
 *                                                                             *
 *   InitLongString() permet d'initialiser d'une chaine à la chaine vide.      *
 *                                                                             *
 *******************************************************************************
 *)
procedure InitLongString(var ligne : LongString);
begin
  with ligne do
    begin
      debutLigne := '';
      finLigne   := '';
      complete   := false;
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   MakeLongString() : fabrication d'une LongString a partir d'une chaine     *
 *   standard Pascal.                                                          *
 *                                                                             *
 *******************************************************************************
 *)
function MakeLongString(const s : String255) : LongString;
var result : LongString;
begin
  with result do
    begin
      debutLigne := s;
      finLigne   := '';
      complete   := false;
    end;
  MakeLongString := result;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   CopyLongString() : copie d'une chaine. Pour une implémentation simple     *
 *   comme actuellement, il est plus elegant d'utiliser une simple affectation *
 *   dest := source                                                            *
 *                                                                             *
 *******************************************************************************
 *)
function CopyLongString(const ligne : LongString) : LongString;
var result : LongString;
begin
  with result do
    begin
      debutLigne := ligne.debutLigne;
      finLigne   := ligne.finLigne;
      complete   := ligne.complete;
    end;
  CopyLongString := result;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SameLongString() : test d'égalite de deux chaines.                        *
 *                                                                             *
 *******************************************************************************
 *)
function SameLongString(const ligne1, ligne2 : LongString) : boolean;
begin
  SameLongString := (LENGTH_OF_STRING(ligne1.debutLigne) = LENGTH_OF_STRING(ligne2.debutLigne)) &
                    (LENGTH_OF_STRING(ligne1.finLigne)   = LENGTH_OF_STRING(ligne2.finLigne)) &
                    (ligne1.debutLigne = ligne2.debutLigne) &
                    (ligne1.finLigne   = ligne2.finLigne);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LengthOfLongString()  renvoie la longueur de la chaine.                   *
 *                                                                             *
 *******************************************************************************
 *)
function LengthOfLongString(const ligne : LongString) : SInt32;
begin
  LengthOfLongString := LENGTH_OF_STRING(ligne.debutLigne) + LENGTH_OF_STRING(ligne.finLigne);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LongStringIsEmpty() permet de tester si une chaine est vide.              *
 *                                                                             *
 *******************************************************************************
 *)
function LongStringIsEmpty(const ligne : LongString) : boolean;
begin
  LongStringIsEmpty := (LengthOfLongString(ligne) <= 0);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   FindStringInLongString() permet de trouver une chaine Pascal dans une     *
 *   LongString. Cette fonction renvoie la position de la chaine trouvee, ou   *
 *   zero si la chaine cherchee n'apparait pas dans la LongString.             *
 *                                                                             *
 *******************************************************************************
 *)
function FindStringInLongString(const s : String255; const ligne : LongString) : SInt32;
var trouve,dec2,len2 : SInt32;
    aux : String255;
begin

  trouve := Pos(s, ligne.debutLigne);

  if (trouve > 0) | (ligne.finLigne = '')
    then
      begin
        FindStringInLongString := trouve;
        exit(FindStringInLongString);
      end
    else
      begin
        len2 := LENGTH_OF_STRING(ligne.finLigne);
        dec2 := LENGTH_OF_STRING(ligne.debutLigne) - len2;

        if (dec2 <= 0) then
          WritelnDansRapport('WARNING : LENGTH_OF_STRING(finLigne) >= LENGTH_OF_STRING(debutLigne) dans FindStringInLongString !');

        aux := RightOfString(ligne.debutLigne, dec2) + ligne.finLigne;

        trouve := Pos(s, aux);
        if (trouve > 0)
          then FindStringInLongString := len2 + trouve
          else FindStringInLongString := trouve;
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LongStringBeginsWith() permet de tester (de maniere rapide et efficace)   *
 *   si une LongString commence par une chaine Pascal donnee.                  *
 *                                                                             *
 *******************************************************************************
 *)
function LongStringBeginsWith(const s : String255; const ligne : LongString) : boolean;
begin
  if (s = '') | (ligne.debutLigne = '') | (s[1] <> ligne.debutLigne[1]) then
    begin
      LongStringBeginsWith := false;
      exit(LongStringBeginsWith);
    end;
  
  LongStringBeginsWith := (Pos(s, ligne.debutLigne) = 1);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   NormaliserLongString() : dans l'implementation actuelle des LongString    *
 *   comme couple de chaines Pascal de 255 caracteres, il faut pour que les    *
 *   algos marchent que la premiere chaine soit pleine (255 caracteres) avant  *
 *   que l'on commence à remplir la seconde. Cette fonction assure que c'est   *
 *   le cas, en deplacant si necessaire des caracteres de la seconde chaine    *
 *   vers la premiere.                                                         *
 *                                                                             *
 *******************************************************************************
 *)
procedure NormaliserLongString(var ligne : LongString);
var len1, len2, nbOctetsDeplaces : SInt32;
begin
  with ligne do
    begin
    
      len1 := LENGTH_OF_STRING(debutLigne);
      len2 := LENGTH_OF_STRING(finLigne);
  
      if (len1 < 255) & (len2 > 0) then
        begin
          nbOctetsDeplaces := Min(len2, 255 - len1);
          
          debutLigne := debutLigne + LeftOfString(finLigne, nbOctetsDeplaces);
          finLigne   := RightOfString(finLigne, len2 - nbOctetsDeplaces);
        end;
        
        
      if (LengthOfLongString(ligne) <> len1 + len2) |
         ((LENGTH_OF_STRING(ligne.debutLigne) < 255) & (LENGTH_OF_STRING(ligne.finLigne) > 0)) then
        begin
          WritelnDansRapport('ASSERT : LongString mal normalisee dans NormaliserLongString !');
          WritelnLongStringDansRapport(ligne);
          exit(NormaliserLongString);
        end;
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AppendToLongString() : concatenation d'une LongString avec une string     *
 *   Pascal.                                                                   *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendToLongString(var ligne : LongString; const s : String255);
var i, len, len2 : SInt32;
begin

  with ligne do
    begin
      if (LENGTH_OF_STRING(debutLigne) < 255) & (LENGTH_OF_STRING(finLigne) > 0) 
        then NormaliserLongString(ligne);


      len := LENGTH_OF_STRING(debutLigne);

      if (len = 0)
        then
          debutLigne := s
        else
          begin
            if (len < 255)
              then
                begin
                  len2 := LENGTH_OF_STRING(s);
                  
                  if (len + len2 <= 255)
                    then 
                      begin
                        debutLigne := debutLigne + s;
                      end
                    else
                      begin
                        i := 1;
                        while (i <= len2) & ((len + i) <= 255) do
                          begin
                            debutLigne := debutLigne + s[i];
                            i := i + 1;
                          end;
                        while (i <= len2) do
                          begin
                            finLigne := finLigne + s[i];
                            i := i + 1;
                          end;
                      end;
                end
              else
                finLigne := finLigne + s;
         end;
     
   end; {with}
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AppendCharToLongString() : ajout d'un caractere à une LongString.         *
 *                                                                             *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendCharToLongString(var ligne : LongString; c : char);
var len : SInt32;
begin

  if (LENGTH_OF_STRING(ligne.debutLigne) < 255) & (LENGTH_OF_STRING(ligne.finLigne) > 0) 
    then NormaliserLongString(ligne);

  len := LENGTH_OF_STRING(ligne.debutLigne);
  if len < 255
    then ligne.debutLigne := ligne.debutLigne + c
    else ligne.finLigne   := ligne.finLigne + c;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AppendToLeftOfLongString() : concatenation d'une chaine Pascal avec une   *
 *   LongString. La difference de cette fonction avec AppendToLongString est   *
 *   qu'ici la chaine Pascal est ajoutee a gauche de la LongString.            *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendToLeftOfLongString(const s : String255; var ligne : LongString);
var aux : LongString;
begin
  if (LENGTH_OF_STRING(s) > 0) then
    with ligne do
      begin
        aux := MakeLongString(s);
      	if (LENGTH_OF_STRING(debutLigne) > 0) then AppendToLongString(aux, debutLigne);
      	if (LENGTH_OF_STRING(finLigne)   > 0) then AppendToLongString(aux, finLigne);
      	ligne := aux;
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LongStringToBuffer() permet de transformer une LongString en buffer de    *
 *   caracteres, en placant le premier caractere de la chaine dans buffer[0],  *
 *   etc. La fonction n'alloue pas le buffer : c'est l'appelant qui doit four- *
 *   nir un buffer assez grand. La fonction renvoie aussi, dans le parametre   *
 *   nbOctets, le nombre de caracteres utilises dans le buffer (la longueur de *
 *   la LongString) : les caracteres utiles dans le buffer après la fonction   *
 *   sont donc dans  buffer[0]...buffer[nbOctets - 1] .                        *
 *                                                                             *
 *******************************************************************************
 *)
procedure LongStringToBuffer(var ligne : LongString; buffer : PackedArrayOfCharPtr; var nbOctets : SInt32);
var k : SInt32;
begin
  nbOctets := 0;

  with ligne do
    begin
      for k := 1 to LENGTH_OF_STRING(debutLigne) do
        begin
          buffer^[nbOctets] := debutLigne[k];
          inc(nbOctets);
        end;

      for k := 1 to LENGTH_OF_STRING(finLigne) do
        begin
          buffer^[nbOctets] := finLigne[k];
          inc(nbOctets);
        end;
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   BufferToLongString() transforme un buffer de caracteres en LongString.    *
 *                                                                             *
 *******************************************************************************
 *)
procedure BufferToLongString(buffer : PackedArrayOfCharPtr; nbOctets : SInt32; var ligne : LongString);
const kTailleMaxOfLongString = 510;
var k, len1, len2 : SInt32;
begin

  with ligne do
    begin
    
      len1 := 0;
      len2 := 0;
  
      if (nbOctets > kTailleMaxOfLongString) 
        then
          begin
            WritelnDansRapport('ASSERT : (nbOctets > kTailleMaxOfLongString) dans BufferToLongString !!');
          end
        else
          begin
            len1 := Min(nbOctets, 255);
            len2 := nbOctets - len1;
            
            for k := 1 to len1 do
              debutLigne[k] := buffer^[k - 1];
              
            for k := 1 to len2 do
              finLigne[k] := buffer^[len1 + k - 1]
            
          end;
  
      SET_LENGTH_OF_STRING(debutLigne , len1);
      SET_LENGTH_OF_STRING(finLigne   , len2);
      
    end;
  
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LeftOfLongString() permet de tronquer une LongString.                     *
 *                                                                             *
 *******************************************************************************
 *)
function LeftOfLongString(const ligne : LongString; len : SInt32) : LongString;
var result : LongString;
    aux : SInt32;
begin
  result.debutLigne := '';
  result.finLigne   := '';
  result.complete   := false;

  aux := LENGTH_OF_STRING(ligne.debutLigne);

  if (len <= aux)
    then result.debutLigne := TPCopy(ligne.debutLigne,1,len)
    else
       begin
         result.debutLigne := ligne.debutLigne;
         result.finLigne   := TPCopy(ligne.finLigne,1,len - aux);
       end;

  LeftOfLongString := result;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   WriteLongStringDansRapport() ecrit une chaine dans le rapport sans        *
 *   ajouter de retour chariot à la fin.                                       *
 *                                                                             *
 *******************************************************************************
 *)
procedure WriteLongStringDansRapport(const ligne : LongString);
var longueur : SInt32;
begin
  longueur := LENGTH_OF_STRING(ligne.finLigne);
  if (longueur > 0)
    then
      begin
        WriteDansRapport(ligne.debutLigne);
        WriteDansRapport(ligne.finLigne);
      end
    else
      begin
        WriteDansRapport(ligne.debutLigne);
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   WritelnLongStringDansRapport() ecrit une chaine dans le rapport en        *
 *   ajoutant un retour chariot a la fin.                                      *   
 *                                                                             *
 *******************************************************************************
 *)
procedure WritelnLongStringDansRapport(const ligne : LongString);
var longueur : SInt32;
begin
  longueur := LENGTH_OF_STRING(ligne.finLigne);
  if (longueur > 0)
    then
      begin
        WriteDansRapport(ligne.debutLigne);
        WriteDansRapport(ligne.finLigne);
        WritelnDansRapport('');
      end
    else
      begin
        WriteDansRapport(ligne.debutLigne);
        WritelnDansRapport('');
      end;
end;



END.
