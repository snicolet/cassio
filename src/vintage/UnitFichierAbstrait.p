UNIT UnitFichierAbstrait;




INTERFACE







 USES UnitDefCassio,
      basicfiles;






{fonctions de creation et de destruction}
function NewEmptyFichierAbstrait : FichierAbstrait;
function MakeFichierAbstraitFichier(nomFichier : String255 ; vRefNum : SInt16) : FichierAbstrait;
function MakeFichierAbstraitEnMemoire(taille : SInt32) : FichierAbstrait;
function MakeFichierAbstraitFromString(s : String255) : FichierAbstrait;
function FichierAbstraitEstCorrect(const theFile : FichierAbstrait) : boolean;
procedure DisposeFichierAbstrait(var theFile : FichierAbstrait);


{fonctions d'ecriture}
{note : passer une valeur négative dans fromPos pour écrire à la fin du fichier abstrait}
function EcrireFichierAbstrait(var theFile : FichierAbstrait; fromPos : SInt32; text : Ptr; var nbOctets : SInt32) : OSErr;
function WriteDansFichierAbstrait(var theFile : FichierAbstrait; s : String255) : OSErr;
function WritelnDansFichierAbstrait(var theFile : FichierAbstrait; s : String255) : OSErr;
function ViderFichierAbstrait(var theFile : FichierAbstrait) : OSErr;


{fonctions de lecture}
{note : passer fromPos < 0 pour lire après les derniers octets lus/écrits}
function ReadFromFichierAbstrait(var theFile : FichierAbstrait; fromPos : SInt32; var count : SInt32; buffer : Ptr) : OSErr;
function GetNextCharOfFichierAbstrait(var theFile : FichierAbstrait; var c : char) : OSErr;
function ReadlnDansFichierAbstrait(var theFile : FichierAbstrait; var s : String255) : OSErr;
function ReadlnLongStringDansFichierAbstrait(var theFile : FichierAbstrait; var s : LongString; ignoreLeadingSpaces : boolean) : OSErr;
function EOFFichierAbstrait(var theFile : FichierAbstrait; var erreurES : OSErr) : boolean;


{gestion du marqueur}
function GetPositionMarqueurFichierAbstrait(var theFile : FichierAbstrait) : SInt32;
function SetPositionMarqueurFichierAbstrait(var theFile : FichierAbstrait; whichPosition : SInt32) : OSErr;
function RevientEnArriereDansFichierAbstrait(var theFile : FichierAbstrait; nbOctets : SInt32) : OSErr;


{gestion du type et du createur}
function GetAbstractFileType(var theFile : FichierAbstrait) : OSType;
function GetAbstractFileCreator(var theFile : FichierAbstrait) : OSType;
procedure SetAbstractFileType(var theFile : FichierAbstrait; whichType : OSType);
procedure SetAbstractFileCreator(var theFile : FichierAbstrait; whichCreator : OSType);


{gestion d'acces au fichier disque, si le fichier abstrait est un fichier disque}
function GetBasicFileOfFichierAbstraitPtr(theAbstractFilePtr : FichierAbstraitPtr; var fic : basicfile) : OSErr;
procedure FermerFichierEtFabriquerFichierAbstrait(var fic : basicfile; var theFile : FichierAbstrait);
procedure DisposeFichierAbstraitEtOuvrirFichier(var fic : basicfile; var theFile : FichierAbstrait);

{lecture/ecriture dans un basicFile depuis un fichier abstrait}
function Write(var fic : basicfile; ficAbstrait : FichierAbstrait; fromPos : SInt32; var count : SInt32) : OSErr;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors
{$IFC NOT(USE_PRELINK)}
    , UnitServicesMemoire, MyMathUtils, UnitRapport, MyStrings, basicfile, UnitLongString ;
{$ELSEC}
    ;
    {$I prelink/FichierAbstrait.lk}
{$ENDC}


{END_USE_CLAUSE}











function FonctionFichierAbstraitBidon(theAbstractFilePtr : FichierAbstraitPtr) : OSErr;
begin
  {$UNUSED theAbstractFilePtr}
  FonctionFichierAbstraitBidon := 0;
end;

function FonctionFichierAbstraitLongintBidon(theAbstractFilePtr : FichierAbstraitPtr; var param : SInt32) : OSErr;
begin
  {$UNUSED theAbstractFilePtr,Param}
  FonctionFichierAbstraitLongintBidon := 0;
end;

function FonctionEcritureBidon(theAbstractFilePtr : FichierAbstraitPtr; text : Ptr; fromPos : SInt32; var nbOctets : SInt32) : OSErr;
begin
  {$UNUSED theAbstractFilePtr,text,fromPos,nbOctets}
  FonctionEcritureBidon := 0;
end;


function GetFichierAbstraitOfFichierAbstraitPtr(theAbstractFilePtr : FichierAbstraitPtr; var theFile : FichierAbstrait) : OSErr;
begin
  if (theAbstractFilePtr = NIL)  then
    begin
      GetFichierAbstraitOfFichierAbstraitPtr := -1;
      exit;
    end;
  MoveMemory(theAbstractFilePtr,@theFile,sizeof(FichierAbstrait));
  GetFichierAbstraitOfFichierAbstraitPtr := NoErr;
end;



function GetBasicFileOfFichierAbstraitPtr(theAbstractFilePtr : FichierAbstraitPtr; var fic : basicfile) : OSErr;
var theFile : FichierAbstrait;
begin
  if GetFichierAbstraitOfFichierAbstraitPtr(theAbstractFilePtr,theFile) <> NoErr  then
    begin
      GetBasicFileOfFichierAbstraitPtr := -1;
      exit;
    end;
  if (theFile.genre <> FichierAbstraitEstFichier) or (theFile.data = NIL) then
     begin
      GetBasicFileOfFichierAbstraitPtr := -2;
      exit;
    end;
  MoveMemory(theFile.data,@fic,sizeof(basicfile));
  GetBasicFileOfFichierAbstraitPtr := NoErr;
end;



function EcrireDansFichierAbstraitFichier(theAbstractFilePtr : FichierAbstraitPtr; text : Ptr; fromPos : SInt32; var nbOctets : SInt32) : OSErr;
var Err : OSErr;
    fic : basicfile;
begin
  Err := GetBasicFileOfFichierAbstraitPtr(theAbstractFilePtr,fic);
  if Err <> NoErr then
    begin
      EcrireDansFichierAbstraitFichier := Err;
      exit;
    end;
  if (fromPos >= 0)
    then Err := SetFilePosition(fic,fromPos)
    else Err := SetFilePositionAtEnd(fic);
  if Err <> NoErr then
    begin
      EcrireDansFichierAbstraitFichier := Err;
      exit;
    end;
  Err := Write(fic,text,nbOctets);
  EcrireDansFichierAbstraitFichier := Err;
end;



function LireFromFichierAbstraitFichier(theAbstractFilePtr : FichierAbstraitPtr; text : Ptr; fromPos : SInt32; var nbOctets : SInt32) : OSErr;
var Err : OSErr;
    fic : basicfile;
    theFile : FichierAbstrait;
begin
  if GetFichierAbstraitOfFichierAbstraitPtr(theAbstractFilePtr,theFile) <> NoErr  then
    begin
      LireFromFichierAbstraitFichier := -1;
      exit;
    end;
  Err := GetBasicFileOfFichierAbstraitPtr(theAbstractFilePtr,fic);
  if Err <> NoErr then
    begin
      LireFromFichierAbstraitFichier := Err;
      exit;
    end;
  if (fromPos >= 0)
    then Err := SetFilePosition(fic,fromPos)
    else Err := SetFilePosition(fic,theFile.position);
  if Err <> NoErr then
    begin
      LireFromFichierAbstraitFichier := Err;
      exit;
    end;
  Err := Read(fic,text,nbOctets);
  LireFromFichierAbstraitFichier := Err;
end;

function SetPositionFichierAbstraitFichier(theAbstractFilePtr : FichierAbstraitPtr; var whichPosition : SInt32) : OSErr;
var Err : OSErr;
    fic : basicfile;
    theFile : FichierAbstrait;
begin
  Err := GetFichierAbstraitOfFichierAbstraitPtr(theAbstractFilePtr,theFile);
  if Err <> NoErr then
    begin
      SetPositionFichierAbstraitFichier := Err;
      exit;
    end;

  if whichPosition > theFile.nbOctetsOccupes
    then whichPosition := theFile.nbOctetsOccupes;

  Err := GetBasicFileOfFichierAbstraitPtr(theAbstractFilePtr,fic);
  if Err <> NoErr then
    begin
      SetPositionFichierAbstraitFichier := Err;
      exit;
    end;
  Err := SetFilePosition(fic,whichPosition);
  SetPositionFichierAbstraitFichier := Err;
end;


function FermerFichierFichierAbstrait(theAbstractFilePtr : FichierAbstraitPtr) : OSErr;
var Err : OSErr;
    fic : basicfile;
begin
  Err := GetBasicFileOfFichierAbstraitPtr(theAbstractFilePtr,fic);
  if Err <> NoErr then
    begin
      FermerFichierFichierAbstrait := Err;
      exit;
    end;
  Err := CloseFile(fic);
  FermerFichierFichierAbstrait := Err;
end;

function ViderFichierFichierAbstrait(theAbstractFilePtr : FichierAbstraitPtr) : OSErr;
var Err : OSErr;
    fic : basicfile;
begin
  Err := GetBasicFileOfFichierAbstraitPtr(theAbstractFilePtr,fic);
  if Err <> NoErr then
    begin
      ViderFichierFichierAbstrait := Err;
      exit;
    end;
  Err := EmptyFile(fic);
  ViderFichierFichierAbstrait := Err;
end;




function EcrireDansFichierAbstraitPointeur(theAbstractFilePtr : FichierAbstraitPtr; buffer : Ptr; fromPos : SInt32; var nbOctets : SInt32) : OSErr;
var theFile : FichierAbstrait;
begin
  if (GetFichierAbstraitOfFichierAbstraitPtr(theAbstractFilePtr,theFile) <> NoErr) or
     (theFile.data = NIL)  then
    begin
      EcrireDansFichierAbstraitPointeur := -1;
      exit;
    end;
  if (fromPos >= 0)
    then MoveMemory(buffer,Ptr(SInt32(theFile.data)+fromPos),nbOctets)
    else MoveMemory(buffer,Ptr(SInt32(theFile.data)+theFile.nbOctetsOccupes),nbOctets);
  EcrireDansFichierAbstraitPointeur := NoErr;
end;


function LireFromFichierAbstraitPointeur(theAbstractFilePtr : FichierAbstraitPtr; buffer : Ptr; fromPos : SInt32; var nbOctets : SInt32) : OSErr;
var theFile : FichierAbstrait;
begin
  if (GetFichierAbstraitOfFichierAbstraitPtr(theAbstractFilePtr,theFile) <> NoErr) or
     (theFile.data = NIL)  then
    begin
      LireFromFichierAbstraitPointeur := -1;
      exit;
    end;
  if (fromPos >= 0)
    then MoveMemory(Ptr(SInt32(theFile.data)+fromPos),buffer,nbOctets)
    else MoveMemory(Ptr(SInt32(theFile.data)+theFile.position),buffer,nbOctets);
  LireFromFichierAbstraitPointeur := NoErr;
end;


function ClearFichierAbstraitEnMemoire(theAbstractFilePtr : FichierAbstraitPtr) : OSErr;
var theFile : FichierAbstrait;
    count : SInt32;
begin
  if (GetFichierAbstraitOfFichierAbstraitPtr(theAbstractFilePtr,theFile) <> NoErr) or
     (theFile.data = NIL)  then
    begin
      ClearFichierAbstraitEnMemoire := -1;
      exit;
    end;
  with theFile do
    begin
      count := nbOctetsOccupes;
      if count > tailleMaximalePossible then count := tailleMaximalePossible;
      MemoryFillChar(infos,count,chr(0));
    end;
  ClearFichierAbstraitEnMemoire := NoErr;
end;


function NewEmptyFichierAbstrait : FichierAbstrait;
var aux : FichierAbstrait;
begin
  with aux do
    begin
      infos := NIL;
      tailleMaximalePossible := 0;
      nbOctetsOccupes        := 0;
      position               := 0;
      genre                  := BadFichierAbstrait;
      refCon                 := -1;
      zoneType               := FOUR_CHAR_CODE('????');
      zoneCreator            := FOUR_CHAR_CODE('????');
      Ecrire                 := FonctionEcritureBidon;
      Lire                   := FonctionEcritureBidon;
      Fermer                 := FonctionFichierAbstraitBidon;
      Clear                  := FonctionFichierAbstraitBidon;
      SetPosition            := FonctionFichierAbstraitLongintBidon;
    end;
  NewEmptyFichierAbstrait := aux;
end;

function MakeFichierAbstraitFichier(nomFichier : String255 ; vRefNum : SInt16) : FichierAbstrait;
var aux : FichierAbstrait;
    fic : basicfile;
    err : OSErr;
begin
  aux := NewEmptyFichierAbstrait;
  MakeFichierAbstraitFichier := aux;

  with aux do
    begin
      infos := AllocateMemoryPtrClear(sizeof(basicfile));
      if infos = NIL then exit;

      err := FileExists(nomFichier,vRefNum,fic);
      if (err = fnfErr) then {file not found, on crée le fichier}
        err := CreateFile(nomFichier,vRefNum,fic);
      if (err = NoErr) then
        err := OpenFile(fic);

	    if err = NoErr then
        begin
          MoveMemory(@fic, aux.data, sizeof(basicfile));

          Ecrire      := EcrireDansFichierAbstraitFichier;
          Lire        := LireFromFichierAbstraitFichier;
          Clear       := ViderFichierFichierAbstrait;
          Fermer      := FermerFichierFichierAbstrait;
          SetPosition := SetPositionFichierAbstraitFichier;

          zoneType    := GetFileTypeFichierTexte(fic);
          zoneCreator := GetFileCreatorFichierTexte(fic);

          err := GetFileSize(fic,nbOctetsOccupes);
          tailleMaximalePossible := 2000000000;   {was MaxLongint;}
          genre := FichierAbstraitEstFichier;
        end;
    end;
  MakeFichierAbstraitFichier := aux;
end;


function MakeFichierAbstraitEnMemoire(taille : SInt32) : FichierAbstrait;
var aux : FichierAbstrait;
begin
  aux := NewEmptyFichierAbstrait;
  MakeFichierAbstraitEnMemoire := aux;

  with aux do
    begin
      if taille < 256 then taille := 256;
      infos := AllocateMemoryPtrClear(taille);
      if infos = NIL
        then exit
        else
          begin

            Ecrire := EcrireDansFichierAbstraitPointeur;
            Lire   := LireFromFichierAbstraitPointeur;
            Clear  := ClearFichierAbstraitEnMemoire;

            tailleMaximalePossible := taille;
            genre  := FichierAbstraitEstPointeur;
          end;
    end;

  MakeFichierAbstraitEnMemoire := aux;
end;


function MakeFichierAbstraitFromString(s : String255) : FichierAbstrait;
var taille : SInt32;
    aux : FichierAbstrait;
    err : OSErr;
begin
  taille := LENGTH_OF_STRING(s);

  if (taille > 0) and (s <> '')
    then
      begin
        aux := MakeFichierAbstraitEnMemoire(taille+10);
        err := WriteDansFichierAbstrait(aux,s);
        err := SetPositionMarqueurFichierAbstrait(aux,0);
        MakeFichierAbstraitFromString := aux;
      end
    else
      MakeFichierAbstraitFromString := NewEmptyFichierAbstrait;
end;


function FichierAbstraitEstCorrect(const theFile : FichierAbstrait) : boolean;
begin
  FichierAbstraitEstCorrect := (theFile.genre = FichierAbstraitEstPointeur) or
                               (theFile.genre = FichierAbstraitEstFichier);
end;


procedure DisposeFichierAbstrait(var theFile : FichierAbstrait);
var err : OSErr;
begin
  if not(FichierAbstraitEstCorrect(theFile)) then
    begin
      DisplayMessageInConsole('### ASSERT FAILED ### '+'(theFile.genre = BadFichierAbstrait) in DisposeFichierAbstrait');
      exit;
    end;

  with theFile do
    begin
      err := Fermer(@theFile);
      if infos <> NIL then
        begin
          DisposeMemoryPtr(Ptr(infos));
          infos := NIL;
        end;
      tailleMaximalePossible := 0;
      nbOctetsOccupes := 0;
      position := 0;
      genre := BadFichierAbstrait;
      Ecrire := FonctionEcritureBidon;
      Fermer := FonctionFichierAbstraitBidon;
    end;
end;


{note : passer une valeur négative dans fromPos pour écrire à la fin du fichier abstrait}
function EcrireFichierAbstrait(var theFile : FichierAbstrait; fromPos : SInt32; text : Ptr; var nbOctets : SInt32) : OSErr;
var err : OSErr;
begin
  err := 0;
  with theFile do
    begin
      if (fromPos >= 0) and (nbOctets > tailleMaximalePossible - fromPos)
		    then nbOctets := tailleMaximalePossible - fromPos;
		  if (fromPos < 0)  and (nbOctets > tailleMaximalePossible - nbOctetsOccupes)
		    then nbOctets := tailleMaximalePossible - nbOctetsOccupes;
		  err := Ecrire(@theFile,text,fromPos,nbOctets);
		  if err <> NoErr then
		    begin
		      EcrireFichierAbstrait := err;
		      exit;
		    end;
		  if fromPos >= 0
				then position := fromPos+nbOctets
			  else position := nbOctetsOccupes+nbOctets;
			if position > nbOctetsOccupes then nbOctetsOccupes := position;
	  end;
  EcrireFichierAbstrait := err;
end;

function WriteDansFichierAbstrait(var theFile : FichierAbstrait; s : String255) : OSErr;
var len : SInt32;
begin
  len := LENGTH_OF_STRING(s);
  WriteDansFichierAbstrait := EcrireFichierAbstrait(theFile,-1,@s[1],len);
end;

function WritelnDansFichierAbstrait(var theFile : FichierAbstrait; s : String255) : OSErr;
begin
  WritelnDansFichierAbstrait := WriteDansFichierAbstrait(theFile, s + chr(13));
end;


function ViderFichierAbstrait(var theFile : FichierAbstrait) : OSErr;
var err : OSErr;
begin
  err := 0;
  with theFile do
    begin
      nbOctetsOccupes := 0;
      position := 0;
      err := Clear(@theFile);
    end;
  ViderFichierAbstrait := err;
end;



function MySetPositionMarqueurFichierAbstrait(var theFile : FichierAbstrait; var whichPosition : SInt32) : OSErr;
var err : OSErr;
begin
  err := 0;
  with theFile do
    begin
      position := whichPosition;
      if position < 0 then position := 0;
      if position > TailleMaximalePossible then position := TailleMaximalePossible;

      err := SetPosition(@theFile,position);
    end;
  MySetPositionMarqueurFichierAbstrait := err;
end;


function GetPositionMarqueurFichierAbstrait(var theFile : FichierAbstrait) : SInt32;
begin
  GetPositionMarqueurFichierAbstrait := theFile.position;
end;


function SetPositionMarqueurFichierAbstrait(var theFile : FichierAbstrait; whichPosition : SInt32) : OSErr;
begin
  SetPositionMarqueurFichierAbstrait := MySetPositionMarqueurFichierAbstrait(theFile,whichPosition);
end;


function RevientEnArriereDansFichierAbstrait(var theFile : FichierAbstrait; nbOctets : SInt32) : OSErr;
var oldPosition,newPosition : SInt32;
begin
  oldPosition := theFile.position;
  newPosition := oldPosition-nbOctets;
  if newPosition < 0 then newPosition := 0;
  RevientEnArriereDansFichierAbstrait := SetPositionMarqueurFichierAbstrait(theFile,newPosition);
end;



function ReadFromFichierAbstrait(var theFile : FichierAbstrait; fromPos : SInt32; var count : SInt32; buffer : Ptr) : OSErr;
var err : OSErr;
begin
  err := 0;
  with theFile do
    begin
		  if (fromPos >= 0) and (count > nbOctetsOccupes - fromPos)
		    then count := nbOctetsOccupes - fromPos;
		  if (fromPos < 0)  and (count > nbOctetsOccupes - position)
		    then count := nbOctetsOccupes - position;
		  err := Lire(@theFile, buffer, fromPos, count);
		  if err <> NoErr then
		    begin
		      ReadFromFichierAbstrait := err;
		      exit;
		    end;
		  if fromPos >= 0
				then position := fromPos + count
			  else position := position + count;
			if position > nbOctetsOccupes then nbOctetsOccupes := position;
	  end;
  ReadFromFichierAbstrait := err;
end;



function GetNextCharOfFichierAbstrait(var theFile : FichierAbstrait; var c : char) : OSErr;
var err : OSErr;
    nbOctets : SInt32;
    s : String255;
begin
  c := chr(0);
  with theFile do
    begin
      if position >= nbOctetsOccupes then
        begin
          GetNextCharOfFichierAbstrait := -1;
          exit;
        end;
      nbOctets := 1;
      err := ReadFromFichierAbstrait(theFile,-1,nbOctets,@s[1]);

      if nbOctets <= 0
        then
          GetNextCharOfFichierAbstrait := -1
        else
          begin
            if (err = NoErr) then c := s[1];
            GetNextCharOfFichierAbstrait := err;
          end;
    end;
end;


function ReadlnDansFichierAbstrait(var theFile : FichierAbstrait; var s : String255) : OSErr;
var err : OSErr;
    i,len,n : SInt32;
    oldPosition,newPosition : SInt32;
begin
  s := '';
  oldPosition := theFile.position;

  n := 255;
  err := ReadFromFichierAbstrait(theFile,-1,n,@s[1]);

  if (err <> NoErr) then
    begin
      ReadlnDansFichierAbstrait := err;
      exit;
    end;

  if (n <= 0) then
    begin
      ReadlnDansFichierAbstrait := -1;
      exit;
    end;

  len := 0;
  i := 1;
  while (i < n) and (s[i] <> cr) and (s[i] <> lf) do inc(i); {line feed or carriage return}
  if (s[i] = cr)
    then
      begin
        len := i-1;
        if (i < 255) and (s[i+1] = lf)
          then newPosition := oldPosition + len + 2  {+2 car on veut sauter le CR-LF}
          else newPosition := oldPosition + len + 1; {+1 car on veut sauter le CR}
      end
    else
  if (s[i] = lf)
    then
      begin
        len := i-1;
        if (i < 255) and (s[i+1] = cr)
          then newPosition := oldPosition + len + 2  {+2 car on veut sauter le CR-LF}
          else newPosition := oldPosition + len + 1; {+1 car on veut sauter le LF}
      end
    else
      begin
        i := Min(255,i);
        len := i;                      {on a lus n caracteres sans rencontrer de CR ni de LF}
        newPosition := oldPosition + len;
      end;
  SET_LENGTH_OF_STRING(s,len);
  for i := len + 1 to 255 do s[i] := chr(0);



  err := MySetPositionMarqueurFichierAbstrait(theFile,newPosition);
  ReadlnDansFichierAbstrait := err;
end;


function ReadlnLongStringDansFichierAbstrait(var theFile : FichierAbstrait; var s : LongString; ignoreLeadingSpaces : boolean) : OSErr;
const kTailleMaxOfLongString = 510;
var err : OSErr;
    i,len,n,first : SInt32;
    oldPosition,newPosition : SInt32;
    buffer : packed array [0..1023] of char;
begin
  InitLongString(s);

  oldPosition := theFile.position;

  n := kTailleMaxOfLongString;
  err := ReadFromFichierAbstrait(theFile , -1 , n , @buffer[1]);

  if (err <> NoErr) then
    begin
      ReadlnLongStringDansFichierAbstrait := err;
      exit;
    end;

  if (n <= 0) then
    begin
      ReadlnLongStringDansFichierAbstrait := -1;
      exit;
    end;

  len := 0;
  i := 1;
  while (i < n) and (buffer[i] <> cr) and (buffer[i] <> lf) do inc(i); {line feed or carriage return}
  if (buffer[i] = cr)
    then
      begin
        len := i-1;
        if (i < kTailleMaxOfLongString) and (buffer[i+1] = lf)
          then newPosition := oldPosition + len + 2  {+2 car on veut sauter le CR-LF}
          else newPosition := oldPosition + len + 1; {+1 car on veut sauter le CR}
      end
    else
  if (buffer[i] = lf)
    then
      begin
        len := i-1;
        if (i < kTailleMaxOfLongString) and (buffer[i+1] = cr)
          then newPosition := oldPosition + len + 2  {+2 car on veut sauter le CR-LF}
          else newPosition := oldPosition + len + 1; {+1 car on veut sauter le LF}
      end
    else
      begin
        i := Min(kTailleMaxOfLongString,i);
        len := i;                      {on a lus n caracteres sans rencontrer de CR ni de LF}
        newPosition := oldPosition + len;
      end;


  first := 1;

  if ignoreLeadingSpaces then
    while (len > 0) and (buffer[first] = ' ') do
      begin
        inc(first);
        dec(len);
      end;

  if (len > 0) then
    BufferToLongString(@buffer[first], len, s);

  err := MySetPositionMarqueurFichierAbstrait(theFile , newPosition);
  ReadlnLongStringDansFichierAbstrait := err;
end;


function EOFFichierAbstrait(var theFile : FichierAbstrait; var erreurES : OSErr) : boolean;
var fic : basicfile;
begin
  if (theFile.genre = FichierAbstraitEstFichier) and
     (GetBasicFileOfFichierAbstraitPtr(@theFile,fic) = NoErr)
    then
      EOFFichierAbstrait := EndOfFile(fic,erreurES)
    else
      begin
        EOFFichierAbstrait := (theFile.position >= theFile.nbOctetsOccupes);
        erreurES       := NoErr;
      end;
end;


function GetAbstractFileType(var theFile : FichierAbstrait) : OSType;
begin
  GetAbstractFileType := theFile.zoneType;
end;


function GetAbstractFileCreator(var theFile : FichierAbstrait) : OSType;
begin
  GetAbstractFileCreator := theFile.zoneCreator;
end;


procedure SetAbstractFileType(var theFile : FichierAbstrait; whichType : OSType);
var fic : basicfile;
begin
   theFile.zoneType := whichType;
   if (theFile.genre = FichierAbstraitEstFichier) and
     (GetBasicFileOfFichierAbstraitPtr(@theFile,fic) = NoErr)
    then SetFileTypeFichierTexte(fic,whichType);
end;

procedure SetAbstractFileCreator(var theFile : FichierAbstrait; whichCreator : OSType);
var fic : basicfile;
begin
  theFile.zoneCreator := whichCreator;
  if (theFile.genre = FichierAbstraitEstFichier) and
     (GetBasicFileOfFichierAbstraitPtr(@theFile,fic) = NoErr)
    then SetFileCreatorFichierTexte(fic,whichCreator);
end;

procedure FermerFichierEtFabriquerFichierAbstrait(var fic : basicfile; var theFile : FichierAbstrait);
var name : String255;
    erreur : OSErr;
    num : SInt32;
begin
  name := fic.nomFichier;
  num  := fic.vRefNum;
  erreur := CloseFile(fic);
  theFile := MakeFichierAbstraitFichier(name,num);
end;

procedure DisposeFichierAbstraitEtOuvrirFichier(var fic : basicfile; var theFile : FichierAbstrait);
var erreur : OSErr;
    ficFichierAbstrait : basicfile;
    name : String255;
    num : SInt32;
    positionMarqueur : SInt32;
begin
  if GetBasicFileOfFichierAbstraitPtr(@theFile,ficFichierAbstrait) = NoErr
    then
      begin
        name             := ficFichierAbstrait.nomFichier;
        num              := ficFichierAbstrait.vRefNum;
        positionMarqueur := theFile.position;
        DisposeFichierAbstrait(theFile);
        erreur := CreateFile(name,num,fic);
        erreur := OpenFile(fic);
        if (positionMarqueur >= 0)
          then erreur := SetFilePosition(fic,positionMarqueur)
          else erreur := SetFilePositionAtEnd(fic);
      end
    else
      begin
        DisposeFichierAbstrait(theFile);
        erreur := OpenFile(fic);
      end;
end;

function Write(var fic : basicfile; ficAbstrait : FichierAbstrait; fromPos : SInt32; var count : SInt32) : OSErr;
var err : OSErr;
    buffer : Ptr;
begin
  err := -1;

  if (count <= 0) then
    exit;

  buffer := AllocateMemoryPtr(count + 100);
  if (buffer <> NIL) then
    begin
      err := ReadFromFichierAbstrait(ficAbstrait, fromPos , count, buffer);
      if err = NoErr then
        err := Write(fic, buffer, count);
      DisposeMemoryPtr(buffer);
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSWrite dans Write :');
      DisplayMessageWithNumInConsole('fic.refNum = ',fic.refNum);
      DisplayMessageWithNumInConsole('   ==> Err = ',err);
    end;

  Write := err;
end;




end.
