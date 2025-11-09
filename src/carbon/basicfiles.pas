UNIT basicfiles;


INTERFACE


USES basictypes, 
     basicstring,
     basictime;


TYPE 
     fileInfo = 
        record
           vRefNum : Integer;   {private and unused  ("volume reference number") }
           parID   : LongInt;   {private and unused  ("directory ID of parent directory") }
           name    : String255; {private             ("filename or directory name") }
        end;

     TReadBuffer =
        record
           bufferLecture      : PackedArrayOfCharPtr;  {private}
           debutDuBuffer      : SInt32;                {private}
           positionDansBuffer : SInt32;                {private}
           tailleDuFichier    : SInt32;                {private}
           tailleDuBuffer     : SInt32;                {private}
           positionTeteFichier: SInt32;                {private}
           doitUtiliserBuffer : boolean;               {private}
        end;

     basicfile =
          record
            fileName : String255;                 {private}
            uniqueID : SInt32;                    {private}
            parID : SInt32;                       {private}
            handle : THandle;                     {private}
            vRefNum : SInt16;                     {private}
            ressourceForkRefNum : SInt32;         {private}
            dataForkOuvertCorrectement : SInt32;  {private}
            rsrcForkOuvertCorrectement : SInt32;  {private}
            info : fileInfo;                      {private}
            readBuffer : TReadBuffer              {private}
          end;

{WARNING :    on risque de perturber InfosFichiersNouveauFormat dans le
              fichier UnitDefNouveauFormat (tableau trop gros)
              si on rajoute des gros champs à basicfile... }
              

TYPE  
   {functional type for ForEachLineInFileDo}
   LineOfFileProc = procedure(var ligne : LongString; var theFic : basicfile; var result : SInt32);



// Initiliazing the library
procedure InitUnitBasicFile;

// Creating a fileInfo structure
function MakeFileInfo(name : String255; var info : fileInfo) : OSErr;
function MakeFileInfo(name : String255) : fileInfo;
// function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255; var info : fileInfo) : OSErr;
// function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255) : fileInfo;

// Existence and creation of files
function FileExists(info : fileInfo; var fic : basicfile) : OSErr;
function CreateFile(info : fileInfo; var fic : basicfile) : OSErr;
// function FileExists(name : String255 ; vRefNum : SInt16; var fic : basicfile) : OSErr;
// function CreateFile(name : String255 ; vRefNum : SInt16; var fic : basicfile) : OSErr;

// Open and close
function OpenFile(var fic : basicfile) : OSErr;
function CloseFile(var fic : basicfile) : OSErr;
function DeleteFile(var fic : basicfile) : OSErr;
function FileIsOpen(var fic : basicfile) : boolean;

// Manipulating the file cursor
function SetFilePosition(var fic : basicfile; position : SInt32) : OSErr;
function SetFilePositionAtEnd(var fic : basicfile) : OSErr;
function GetFilePosition(var fic : basicfile; var position : SInt32) : OSErr;
function EndOfFile(var fic : basicfile; var err : OSErr) : boolean;
function SetEndOfFile(var fic : basicfile; posEOF : SInt32) : OSErr;
function EmptyFile(var fic : basicfile) : OSErr;

// Accessing properties of files
function GetName(var fic : basicfile) : String255;
function GetName(var info : fileInfo) : String255;
function GetFileSize(var fic : basicfile; var taille : SInt32) : OSErr;
function GetUniqueID(var fic : basicfile) : SInt32;
function GetCreationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
function GetModificationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;

// Write data
function Write(var fic : basicfile; s : String255) : OSErr;
function Write(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
function Write(var fic : basicfile; value : SInt32) : OSErr;
function Writeln(var fic : basicfile; s : String255) : OSErr;
function InsertFileInFile(var fic : basicfile; pathFichierAInserer : String255) : OSErr;
function InsertFileInFile(var insere,receptacle : basicfile) : OSErr;

// Read data
function Read(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
function Read(var fic : basicfile; count : SInt16; var s : String255) : OSErr;
function Read(var fic : basicfile; var value : SInt32) : OSErr;
function Readln(var fic : basicfile; var s : String255) : OSErr;
function Readln(var fic : basicfile; var s : LongString) : OSErr;
function Readln(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;

// Iterate on each line of a text file
procedure ForEachLineInFileDo(whichFile : fileInfo ; DoWhat : LineOfFileProc; var result : SInt32);

// Manipulating paths of files and directories
procedure DoDirSeparators(var filename : String255);
function EndsWithDirectorySeparator(var s : String255) : boolean;
function ExtractFileName(whichFile : fileInfo; var theLongName : String255) : OSErr;
function ExtractFileName(path : String255; var theLongName : String255) : OSErr;
function ExtractFileOrDirectoryName(chemin : String255) : String255;

// Manipulating the standard output as a file
function CreateStandardOutputAsFile(var fic : basicfile) : OSErr;
function FileIsStandardOutput(var fic : basicfile) : boolean;

// Useful flag to debug the library
procedure SetDebugFiles(flag : boolean);
function  GetDebugFiles() : boolean;

// Display simple alert for file errors
procedure SimpleAlertForFile(fileName : String255; erreurES : SInt32);

(* Installation des procedures pour l'affichage de message :    *)
(* sur la sortie standard par defaut. On peut installer des     *)
(* routines personalisees d'impression de messages et d'alerte  *)
(* juste apres l'appel a InitUnitBasicFile                      *)
procedure InstallMessageDisplayerBasicFile(theProc : MessageDisplayerProc);
procedure InstallMessageAndNumDisplayerBasicFile(theProc : MessageAndNumDisplayerProc);
procedure InstallAlertBasicFile(theProc : MessageAndNumDisplayerProc);

procedure DisplayMessageInConsole(s : String255);
procedure DisplayMessageAndNumInConsole(s : String255; num : SInt32);
procedure DisplayAlerteWithNumInConsole(s : String255; num : SInt32);




IMPLEMENTATION

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  SysUtils,
  math,
  quickdraw,
  basicMemory,
  basicHashing,
  basicTerminal;


const unit_initialized : boolean = false;
      debugBasicFiles : boolean = false;

var useStandardConsole : boolean;
    CustomDisplayMessage : MessageDisplayerProc;
    CustomDisplayMessageWithNum : MessageAndNumDisplayerProc;
    CustomDisplayAlerteWithNum : MessageAndNumDisplayerProc;
    nameOfStandardOutputForRapport : String255;

    gEndOfLineFoundInReadln : boolean;


procedure StandardConsoleDisplayer(s : String255);
begin
  system.Writeln(s);
end;

procedure StandardConsoleDisplayerWithNum(s : String255; num : SInt32);
begin
  system.Writeln(s,num);
end;

procedure StandardConsoleAlertWithNum(s : String255; num : SInt32);
begin
  system.Writeln('### WARNING ### '+s+' ',num);
end;


procedure DisplayMessageInConsole(s : String255);
begin
  if unit_initialized
    then CustomDisplayMessage(s)
    else StandardConsoleDisplayer(s);
end;

procedure DisplayMessageAndNumInConsole(s : String255; num : SInt32);
begin
  if unit_initialized
    then CustomDisplayMessageWithNum(s,num)
    else StandardConsoleDisplayerWithNum(s,num);
end;

procedure DisplayAlerteWithNumInConsole(s : String255; num : SInt32);
begin
  if unit_initialized
    then CustomDisplayAlerteWithNum(s,num)
    else StandardConsoleAlertWithNum(s,num)
end;

procedure DoDirSeparators(var filename : String255);
var s : String;
begin
   s := filename;
   sysUtils.DoDirSeparators(s);
   filename := s;
end;

function EndsWithDirectorySeparator(var s : String255) : boolean;
begin
  EndsWithDirectorySeparator := (s[LENGTH_OF_STRING(s)] = DirectorySeparator );
end;


function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255; var info : fileInfo) : OSErr;
var err : OSErr;
begin
   info.name    := name;
   info.vRefNum := vrn;
   info.parID   := dirID;
   
   if not(sysUtils.FileExists(name)) and not(sysUtils.DirectoryExists(name))
      then err := fnfErr   {file not found error}
      else err := NoErr;
      
   result := err;
end;

function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255) : fileInfo;
var info : fileInfo;
begin
   MakeFileInfo(vrn, dirID, name, info); // discard error !
   
   MakeFileInfo := info;
end;


function MakeFileInfo(name : String255; var info : fileInfo) : OSErr;
begin
   result := MakeFileInfo(0, 0, name, info);
end;


function MakeFileInfo(name : String255) : fileInfo;
begin
  result := MakeFileInfo(0, 0, name);
end;


function ExpandFileName(fs : fileInfo; var path : String255) : OSErr;
var err : OSErr;
    s : String255;
    info : fileInfo;
begin
  s := GetName(fs);
  err := MakeFileInfo(fs.vRefNum, fs.parID, s, info);
  if err = fnfErr then err := NoErr;
  if err = NoErr then
     path := sysUtils.ExpandFileName(s);

  Result := err;
end;


function ExpandFileName(var fs : fileInfo) : String255;
var path : String255;
begin
   ExpandFileName(fs, path);
   fs := MakeFileInfo(path);

   Result := path;
end;



function ExpandFileName(var fullName : String255) : OSErr;
var debut,reste,resolvedDebut : String255;
    myFileInfo : fileInfo;
    err : OSErr;
    posDeuxPoints : SInt16;
begin
  debut := '';
  reste := fullName;
  err := 0;
  
  DoDirSeparators(reste);

  while (reste <> '') and (err = 0) do
    begin
      posDeuxPoints := Pos( DirectorySeparator ,reste);
      if posDeuxPoints > 0
        then
          begin
            debut := debut + TPCopy(reste,1,posDeuxPoints);
            reste := TPCopy(reste,posDeuxPoints+1,LENGTH_OF_STRING(reste)-posDeuxPoints);
          end
        else
          begin
            debut := debut + reste;
            reste := '';
          end;

      err := MakeFileInfo(debut,myFileInfo);
      ExpandFileName(myFileInfo);
      
      resolvedDebut := debut;
      err := ExpandFileName(myFileInfo,resolvedDebut);
      
      if err = 0 then
        begin
          if EndsWithDirectorySeparator(debut) and not(EndsWithDirectorySeparator(resolvedDebut))
            then debut := resolvedDebut + DirectorySeparator 
            else debut := resolvedDebut;
        end;
    end;
  if err = 0 then fullName := debut;

  Result := err;
end;


function ExpandFileName(var fic : basicfile) : OSErr;
var err : OSErr;
    fullName : String255;
begin
  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' avant MakeFileInfo dans ExpandFileName :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
    end;

  if FileIsStandardOutput(fic) then
    begin
      ExpandFileName := NoErr;
      exit;
    end;

  with fic do
    begin
      err := MakeFileInfo(vRefNum,parID,fileName,info);
      
      fullName := fileName;
      if (err = NoErr) then
        begin
          ExpandFileName(info);
          err := ExpandFileName(info,fullName);
        end else
      if (err = fnfErr) then {-43 : File Not Found, mais le fileInfo est valable}
        ExpandFileName(info, fullName);
        
      parID      := info.parID;
      fileName   := fullName;
      uniqueID   := HashString(fullName);

      {DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('LENGTH_OF_STRING(fic.fullName) = ',LENGTH_OF_STRING(fullName));
      DisplayMessageAndNumInConsole('hashing -> uniqueID = ',uniqueID);}
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MakeFileInfo dans ExpandFileName :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;
  ExpandFileName := err;
end;

function FileIsStandardOutput(var fic : basicfile) : boolean;
begin
  FileIsStandardOutput := (fic.vRefNum = 0) and
                          (fic.parID = 0) and
                          (fic.handle = 0) and
                          (fic.fileName = nameOfStandardOutputForRapport);
end;


procedure InitializeBasicFile(var name : String255; var vRefNum : SInt16; var fic : basicfile);
var nomDirectory : String255;
    len : SInt16;
begin
  DoDirSeparators(name);

  if (Pos( DirectorySeparator ,name) > 0) and (vRefNum <> 0)
    then
      begin
        nomDirectory := GetCurrentDir();
        len := LENGTH_OF_STRING(nomDirectory);
        
        if (len > 0) and
           (nomDirectory <> DirectorySeparator ) and 
           ((LENGTH_OF_STRING(nomDirectory)+LENGTH_OF_STRING(name)) <= 255) then
          begin
            if (name[1] = DirectorySeparator ) and EndsWithDirectorySeparator(nomDirectory)
              then name := TPCopy(nomDirectory,1,len-1) + name
              else name := nomDirectory + name;
              
            name := sysUtils.ExpandFileName(name);
            vRefNum := 0;
          end;
      end;

  fic.fileName := name;
  fic.vRefNum := vRefNum;
  fic.parID := 0;
  fic.handle := 0;
  fic.uniqueID := 0;  {not yet initialised, we'll do it in ExpandFileName}

  fic.info := MakeFileInfo(name);

  fic.ressourceForkRefNum        := -1;
  fic.dataForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}

  with fic.readBuffer do
    begin
      bufferLecture       := NIL;
      debutDuBuffer       := 0;
      positionDansBuffer  := 0;
      tailleDuFichier     := -1;
      tailleDuBuffer      := -1;
      positionTeteFichier := 0;
      doitUtiliserBuffer  := true;
    end;
end;


procedure InitializeBasicFile(info : fileInfo; var fic : basicfile);
begin

  fic.fileName   := info.name;
  fic.vRefNum    := info.vRefNum;
  fic.parID      := info.parID;
  fic.handle     := 0;
  fic.uniqueID   := 0;  {not yet initialised, we'll do it in ExpandFileName}
  fic.info  := info;
  fic.ressourceForkRefNum        := -1;
  fic.dataForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkOuvertCorrectement := -1; {niveau d'ouverture = 0 veut dire correct}

  with fic.readBuffer do
    begin
      bufferLecture       := NIL;
      debutDuBuffer       := 0;
      positionDansBuffer  := 0;
      tailleDuFichier     := -1;
      tailleDuBuffer      := -1;
      positionTeteFichier := 0;
      doitUtiliserBuffer  := true;
    end;
end;


function ExtractFileName(whichFile : fileInfo; var theLongName : String255) : OSErr;
var err : OSErr;
    aux : fileInfo;
begin
  err := MakeFileInfo(whichFile.name, aux);
  if err = NoErr
    then theLongName := sysUtils.ExtractFileName(aux.name)
    else theLongName := whichFile.name;
  Result := err;
end;




function ExtractFileName(path : String255; var theLongName : String255) : OSErr;
var err : OSErr;
    aux : fileInfo;
begin
   theLongName := path;
   err := MakeFileInfo(path,aux);
   if err = NoErr
      then err := ExtractFileName(aux,theLongName);
   Result := err;
end;


function ExtractFileOrDirectoryName(chemin : String255) : String255;
const separator = DirectorySeparator;
begin
  if RightStr(chemin,1) = separator
    then KeepPrefix(chemin,LENGTH_OF_STRING(chemin)-1);

  ExtractFileOrDirectoryName := RightStr(chemin,LENGTH_OF_STRING(chemin)-PosRight(separator,chemin));
end;


function FileExists(name : String255 ; vRefNum : SInt16; var fic : basicfile) : OSErr;
var err1,err2 : OSErr;
begin
  
  if (name = '') then
    begin
      DisplayMessageInConsole('WARNING ! (name = '''') dans FileExists');
      FileExists := -1;
      exit;
    end;

  {TraceLog('FileExists : name =' + name);}

  DoDirSeparators(name);
  InitializeBasicFile(name,vRefNum,fic);

  if FileIsStandardOutput(fic) then
    begin
      FileExists := NoErr;
      exit;
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres InitializeBasicFile dans FileExists :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
    end;

  err2 := ExpandFileName(fic);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres ExpandFileName dans FileExists :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageAndNumInConsole('   ==> Err2 = ',err2);
    end;

  if (err2 <> NoErr)
    then
      FileExists := err2
    else
      begin
        if sysUtils.FileExists(fic.info.name)
          then err1 := NoErr
          else err1 := fnfErr;   {file not found error}

		if debugBasicFiles then
		  begin
			DisplayMessageInConsole('');
			DisplayMessageInConsole(' apres sysUtils.FileExists dans FileExists :');
			DisplayMessageInConsole('fic.fileName = '+fic.fileName);
			DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
			DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
			DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
			DisplayMessageInConsole('fic.info.name = '+fic.info.name);
			DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
			DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
			DisplayMessageAndNumInConsole('   ==> Err1 = ',err1);
		  end;

		FileExists := err1;
	  end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' a la fin de FileExists :');
      DisplayMessageAndNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
    end;
end;


function FileExists(info : fileInfo; var fic : basicfile) : OSErr;
var err1,err2 : OSErr;
begin
  if (info.name = '') then
    begin
      DisplayMessageInConsole('WARNING ! info.name) = '''' dans FileExists');
      FileExists := -1;
      exit;
    end;

  InitializeBasicFile(info, fic);

  if FileIsStandardOutput(fic) then
    begin
      FileExists := NoErr;
      exit;
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres InitializeBasicFile dans FileExists :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
    end;

  err2 := ExpandFileName(fic);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres ExpandFileName dans FileExists :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageAndNumInConsole('   ==> Err2 = ',err2);
    end;

  if (err2 <> NoErr)
    then
      FileExists := err2
    else
      begin
		if sysUtils.FileExists(fic.info.name)
          then err1 := NoErr
          else err1 := fnfErr;   {file not found error}

		if debugBasicFiles then
		  begin
			DisplayMessageInConsole('');
			DisplayMessageInConsole(' apres FSpGetFInfo dans FileExists :');
			DisplayMessageInConsole('fic.fileName = '+fic.fileName);
			DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
			DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
			DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
			DisplayMessageInConsole('fic.info.name = '+fic.info.name);
			DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
			DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
			DisplayMessageAndNumInConsole('   ==> Err1 = ',err1);
		  end;

		FileExists := err1;
	  end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' a la fin de FileExists :');
      DisplayMessageAndNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
    end;
end;


function CreateFile(name : String255 ; vRefNum : SInt16; var fic : basicfile) : OSErr;
var err : OSErr;
begin
  InitializeBasicFile(name,vRefNum, fic);
  
  err := ExpandFileName(fic);

  if FileIsStandardOutput(fic) then
    begin
      CreateFile := NoErr;
      exit;
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres ExpandFileName dans CreateFile :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  // err := FSpCreate(fic.info,FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('TEXT'),0);
  fic.handle := FileCreate(fic.info.name);
  if fic.handle = THandle(-1)
     then err := -1
     else err := NoErr;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileCreate dans CreateFile :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  CreateFile := err;
end;

function CreateFile(info : fileInfo; var fic : basicfile) : OSErr;
var err : OSErr;
begin
  InitializeBasicFile(info, fic);
  
  err := ExpandFileName(fic);

  if FileIsStandardOutput(fic) then
    begin
      CreateFile := NoErr;
      exit;
    end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres ExpandFileName dans CreateFile :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  // err := FSpCreate(fic.info,FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('TEXT'),0);
  fic.handle := FileCreate(fic.info.name);
  if fic.handle = THandle(-1)
     then err := -1
     else err := NoErr;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSpCreate dans CreateFile :');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
      DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  CreateFile := err;
end;




function OpenFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      OpenFile := NoErr;
      exit;
    end;

  if fic.dataForkOuvertCorrectement <> -1 then
    begin
      Beep();
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le data Fork d''un fichier dont fic.dataForkOuvertCorrectement <> -1 !');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageInConsole('fic.info.name) = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
      DisplayMessageInConsole('');
      OpenFile := -1;
      exit;
    end;

  fic.handle := FileOpen(fic.info.name, fmOpenReadWrite);
  if fic.handle = THandle(-1)
     then err := -1
     else err := NoErr;

  if debugBasicFiles then
	begin
	    DisplayMessageInConsole('');
		DisplayMessageInConsole(' apres FileOpen dans OpenFile :');
		DisplayMessageInConsole('fic.fileName = '+fic.fileName);
		DisplayMessageAndNumInConsole('fic.vRefNum = ',fic.vRefNum);
		DisplayMessageAndNumInConsole('fic.parID = ',fic.parID);
		DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
		DisplayMessageInConsole('fic.info.name = '+fic.info.name);
		DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
		DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
		DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  if err = NoErr then
    begin
      inc(fic.dataForkOuvertCorrectement);
      if fic.dataForkOuvertCorrectement <> 0 then
        begin
          Beep();
          DisplayMessageInConsole('');
          DisplayMessageInConsole('## WARNING : après une ouverture réussie, dataForkOuvertCorrectement <> 0 !');
          DisplayMessageInConsole('fic.fileName = '+fic.fileName);
          DisplayMessageAndNumInConsole('fic.dataForkOuvertCorrectement',fic.dataForkOuvertCorrectement);
          DisplayMessageInConsole('');
        end;
    end;

  OpenFile := err;
end;


function CloseFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      CloseFile := NoErr;
      exit;
    end;

  if fic.dataForkOuvertCorrectement <> 0 then
    begin
      Beep();
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le data Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
      DisplayMessageInConsole('');
      CloseFile := -1;

      (* ForconsLePlantageDeCassio; *)

      exit;
    end;

  FileClose(fic.handle);
  err := NoErr;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSClose dans CloseFile :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  with fic.readBuffer do
    begin
      if (bufferLecture <> NIL) then DisposeMemoryPtr(Ptr(bufferLecture));
      debutDuBuffer       := 0;
      positionDansBuffer  := 0;
      tailleDuFichier     := -1;
      tailleDuBuffer      := -1;
      positionTeteFichier := 0;
      doitUtiliserBuffer  := false;
    end;

  if err = NoErr then
      begin
        dec(fic.dataForkOuvertCorrectement);
        if (fic.dataForkOuvertCorrectement <> -1) then
          begin
            Beep();
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une fermeture correcte du data fork d''un fichier, dataForkOuvertCorrectement <> -1 !');
            DisplayMessageInConsole('fic.fileName = '+fic.fileName);
            DisplayMessageAndNumInConsole('fic.dataForkOuvertCorrectement = ',fic.dataForkOuvertCorrectement);
            DisplayMessageInConsole('');
          end;
      end;

  CloseFile := err;
end;


function DeleteFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      DeleteFile := NoErr;
      exit;
    end;


  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' entree dans DeleteFile :');
      DisplayMessageInConsole('     appel de OpenFile/CloseFile :');
    end;

  if not(FileIsOpen(fic)) then
    err := OpenFile(fic);

  err := CloseFile(fic);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres OpenFile/CloseFile dans DeleteFile :');
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  if sysUtils.DeleteFile(fic.info.name)
     then err := NoErr
     else err := -1;

  if debugBasicFiles then
	begin
	  DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres sysUtils.DeleteFile dans DeleteFile :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
	end;

  DeleteFile := err;
end;


function FileIsOpen(var fic : basicfile) : boolean;
begin

  if FileIsStandardOutput(fic) then
    begin
      FileIsOpen := true;
      exit;
    end;

  FileIsOpen := (fic.dataForkOuvertCorrectement = 0);
end;

function GetUniqueID(var fic : basicfile) : SInt32;
begin
  GetUniqueID := fic.uniqueID;
end;

function GetFileSize(var fic : basicfile; var taille : SInt32) : OSErr;
var err : OSErr;
    searchData : TSearchRec;
begin

  if FileIsStandardOutput(fic) then
    begin
      taille := GetTailleRapport;
      GetFileSize := NoErr;
      exit;
    end;
  
  if FindFirst(fic.info.name, 0, searchData) = 0 then
    begin
      err := NoErr;
      taille := searchData.Size;
    end
  else
    begin
      err := -1;
      taille := -1;
    end;
  FindClose(searchData);


  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FindFirst dans GetFileSize :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('taille = ',taille);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  GetFileSize := err;
end;

function GetName(var fic : basicfile) : String255;
begin
  GetName := fic.info.name;
end;

function GetName(var info : fileInfo) : String255;
begin
  GetName := info.name;
end;

function SetFilePosition(var fic : basicfile; position : SInt32) : OSErr;
var err : OSErr;
    newPosition : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      SetDebutSelectionRapport(position);
      SetFinSelectionRapport(position);
      SetFilePosition := NoErr;
      exit;
    end;
  
  newPosition := FileSeek(fic.handle, position, fsFromBeginning);
  if newPosition >= 0
     then err := NoErr
     else err := -1;

  if fic.readBuffer.doitUtiliserBuffer then
    with fic.readBuffer do
      begin
        if (position >= debutDuBuffer) and
           (position < debutDuBuffer + tailleDuBuffer)
          then positionDansBuffer := (position - debutDuBuffer);
      end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileSeek dans SetFilePosition :');
      DisplayMessageAndNumInConsole(' pos = ',position);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;


  SetFilePosition := err;
end;

function SetFilePositionAtEnd(var fic : basicfile) : OSErr;
var err : OSErr;
    newPosition : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      FinRapport;
      SetFilePositionAtEnd := NoErr;
      exit;
    end;

  newPosition := FileSeek(fic.handle, 0, fsFromEnd);
  if newPosition >= 0
     then err := NoErr
     else err := -1;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileSeek dans SetFilePositionAtEnd :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  SetFilePositionAtEnd := err;
end;


function GetFilePosition(var fic : basicfile; var position : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      position := GetDebutSelectionRapport;
      GetFilePosition := NoErr;
      exit;
    end;

  position := FileSeek(fic.handle, 0, fsFromCurrent);
  if position >= 0
     then err := NoErr
     else err := -1;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileSeek dans GetFilePosition :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  GetFilePosition := err;
end;


function EndOfFile(var fic : basicfile; var err : OSErr) : boolean;
var position, logicalEOF : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      position := GetDebutSelectionRapport;
      EndOfFile := (position >= GetTailleRapport);
      exit;
    end;

  EndOfFile := true;

  position := FileSeek(fic.handle, 0, fsFromCurrent);
  if position >= 0
     then err := NoErr
     else err := -1;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetFPos dans EndOfFile :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('position = ',position);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  if err <> NoErr then exit;
  
  err := GetFileSize(fic, logicalEOF);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres GetFileSize dans EndOfFile :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('logicalEOF = ',logicalEOF);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  if err <> NoErr then exit;
  
  EndOfFile := (position >= logicalEOF);
end;

function SetEndOfFile(var fic : basicfile; posEOF : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      SetEndOfFile := NoErr;
      exit;
    end;

  if FileTruncate(fic.handle, posEOF)
    then err := NoErr
    else err := -1;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileTruncate dans SetEndOfFile :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  SetEndOfFile := err;
end;


function EmptyFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      DetruireTexteDansRapport(0,2000000000,true);  {2000000000 was MawLongint}
      EmptyFile := NoErr;
      exit;
    end;

  err := SetEndOfFile(fic,0);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetEndOfFile dans EmptyFile :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  EmptyFile := err;
end;



function Write(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
begin

  if count <= 0 then
    begin
      Write := NoErr;
      exit;
    end;

  if FileIsStandardOutput(fic) then
    begin
      InsereTexteDansRapport(buffPtr,count);
      Write := NoErr;
      exit;
    end;

  count := FileWrite(fic.handle, buffPtr, count);
  if count > 0
    then err := NoErr
    else err := -1;
    

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileWrite dans Write :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Write := err;
end;





function Write(var fic : basicfile; s : String255) : OSErr;
var err : OSErr;
    count : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      WriteDansRapport(s);
      Write := NoErr;
      exit;
    end;

  count := LENGTH_OF_STRING(s);
  err := Write(fic, @s[1], count);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans Write :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Write := err;
end;


function Writeln(var fic : basicfile; s : String255) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      WritelnDansRapport(s);
      Writeln := NoErr;
      exit;
    end;

  err := Write(fic, s + chr(13));

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans Writeln( :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Writeln := err;
end;





function Write(var fic : basicfile; value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
    buffPtr : Ptr;
begin

  if FileIsStandardOutput(fic) then
    begin
      InsereTexteDansRapport(@value,4);
      Write := NoErr;
      exit;
    end;

  buffPtr :=  @value;
  count := FileWrite(fic.handle, buffPtr, 4);
  if count > 0
    then err := NoErr
    else err := -1;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileWrite dans Write :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Write := err;
end;

function Read(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
    nbBytesRead : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      Result := -1;
      exit;
    end;

  nbBytesRead := FileRead(fic.handle, buffPtr, count);
  if nbBytesRead > 0
     then 
       begin
         err := NoErr;
         count := nbBytesRead;
       end
     else
       begin
         err := -1;
         count:= 0;
       end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileRead dans Read :');
      DisplayMessageAndNumInConsole('count = ',count);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Result := err;
end;


function Read(var fic : basicfile; count : SInt16; var s : String255) : OSErr;
var len, nbBytesRead : SInt32;
    buffPtr : Ptr;
    err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      Result := -1;
      exit;
    end;

  len := count;
  if len > 255 then len := 255;
  if len < 0 then len := 0;

  buffPtr := @s[1];
  nbBytesRead := FileRead(fic.handle, buffPtr, len);
  if nbBytesRead >= 0
     then 
       begin
         err := NoErr;
         SET_LENGTH_OF_STRING(s,len);
       end
     else
       begin
         err := -1;
         SET_LENGTH_OF_STRING(s,0);
       end;

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FileRead dans Read :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Result := err;
end;



function MyFSBufferedReadPourReadln(var fic : basicfile; var length : SInt32; buffer : Ptr) : OSErr;
const SIZE_OF_BUFFER = 1024 * 34;
var luDansLeBuffer : boolean;
    resultBuffer : PackedArrayOfCharPtr;
    k, nbOctetsLusSurLeDisque : SInt32;
    err : OSErr;
    debug : boolean;
label Bail;
begin

 // debug := (Pos('rence',fic.fileName) > 0);
  debug := false;

  luDansLeBuffer := false;


  with fic.readBuffer do
    if doitUtiliserBuffer then
      begin

        if (bufferLecture = NIL) then
          begin
            if debug then WritelnDansRapport('FIX ME : allocation du buffer de lecture');
            bufferLecture := PackedArrayOfCharPtr(AllocateMemoryPtr(SIZE_OF_BUFFER));
            if (bufferLecture = NIL) then
              begin
                doitUtiliserBuffer := false;
                goto Bail;
              end;
          end;

        if (tailleDuFichier < 0) then
          begin
            if (GetFileSize(fic,tailleDuFichier) <> NoErr) then
              begin
                tailleDuFichier := -1;
                doitUtiliserBuffer := false;
                if debug then WritelnNumDansRapport('FIX ME : erreur dans le calcul de la taille du fichier : ',tailleDuFichier);
                goto Bail;
              end;
            if debug then WritelnNumDansRapport('FIX ME : calcul de la taille du fichier : ',tailleDuFichier);
          end;


        if (tailleDuFichier > 0) and
           (length > tailleDuFichier - (debutDuBuffer + positionDansBuffer)) and
           ((positionDansBuffer + length) > tailleDuBuffer)
           then length := tailleDuFichier - (debutDuBuffer + positionDansBuffer);


        if ((positionDansBuffer + length) > tailleDuBuffer) then
          begin
            nbOctetsLusSurLeDisque := SIZE_OF_BUFFER;

            err := GetFilePosition(fic, debutDuBuffer);

            if debug then WritelnNumDansRapport('FIX ME : apres GetFilePosition, err = ',err);

            if (err = NoErr) then
              begin
              
                nbOctetsLusSurLeDisque := FileRead(fic.handle, bufferLecture, nbOctetsLusSurLeDisque);
                
                if nbOctetsLusSurLeDisque = 0 then
                  begin
                     err := eofErr; {-39 is eofErr, end of file error}
                  end else
                if nbOctetsLusSurLeDisque < 0 then
                  begin
                     err := -1;
                     nbOctetsLusSurLeDisque:= 0;
                  end else
                if nbOctetsLusSurLeDisque > 0 then
                  begin
                     err := NoErr;
                  end;
              end;

            if (err = NoErr) and (nbOctetsLusSurLeDisque > 0)
              then
                begin
                  tailleDuBuffer     := nbOctetsLusSurLeDisque;
                  positionDansBuffer := 0;
                  if debug then WritelnNumDansRapport('FIX ME : lecture dans le fichier : ',tailleDuBuffer);
                end
              else
                begin
                  if debug then WritelnNumDansRapport('FIX ME : erreur de lecture dans le fichier, err = ',err);
                  if debug then WritelnNumDansRapport('FIX ME : nbOctetsLusSurLeDisque = ',nbOctetsLusSurLeDisque);

                  
                  if (err = eofErr) and (nbOctetsLusSurLeDisque > 0)   {-39 is eofErr, end of file error}
                    then
                      begin
                        tailleDuBuffer     := nbOctetsLusSurLeDisque;
                        positionDansBuffer := 0;
                        err := SetFilePosition(fic, debutDuBuffer);
                      end
                    else
                      begin
                        doitUtiliserBuffer := false;
                        err := SetFilePosition(fic, debutDuBuffer);
                        goto Bail;
                      end;
                end;

          end;

        if ((positionDansBuffer + length) <= tailleDuBuffer) then
          begin
            resultBuffer := PackedArrayOfCharPtr(buffer);

            for k := 0 to length - 1 do
              resultBuffer^[k] := bufferLecture^[positionDansBuffer + k];

            positionDansBuffer := positionDansBuffer + length;

            luDansLeBuffer := true;
            MyFSBufferedReadPourReadln := NoErr;

            // if debug then WritelnNumDansRapport('FIX ME : OK, positionDansBuffer = ',positionDansBuffer);
          end;

      end;

Bail :

  if not(luDansLeBuffer) then
    begin
      if debug then WritelnNumDansRapport('avant, length = ',length);


      length := FileRead(fic.handle, buffer, length);
      if length > 0 then
          begin
             err := NoErr;
          end
        else
          begin
             err := -1;
             length := 0;
          end;

      MyFSBufferedReadPourReadln := err;

      if debug then WritelnNumDansRapport('apres, length = ',length);
      if debug then WritelnNumDansRapport('apres, err = ',err);
    end;
end;


function Readln(var fic : basicfile; var s : String255) : OSErr;
var err : OSErr;
    i,len,longueurLigne : SInt32;
    positionTeteDeLecture : SInt32;
    buffer : packed array[0..300] of char;
begin
  s := '';

  if FileIsStandardOutput(fic) then
    begin
      Readln := -1;
      exit;
    end;

  err := GetFilePosition(fic,positionTeteDeLecture);

  {on essaie de lire 258 caracteres du fichier pour les mettre dans notre buffer}
  len := 258;
  err := MyFSBufferedReadPourReadln(fic, len, @buffer[1]);
  //err := FSRead(fic.handle, len, @buffer[1]);
  for i := len + 1 to 258 do buffer[i] := chr(0);

  {on cherche le premier retour charriot dans le buffer}
  len := Min(256,len);
  longueurLigne := Min(255,len);
  gEndOfLineFoundInReadln := false;
  for i := len downto 1 do
    if (buffer[i] = cr) or (buffer[i] = lf) then
      begin
        longueurLigne := i-1;
        gEndOfLineFoundInReadln := true;
      end;

  {on ajuste en consequence la longueur de s, et on recopie la chaine}
  for i := 1 to longueurLigne do s[i] := buffer[i];
  for i := longueurLigne + 1 to 255 do s[i] := chr(0);
  SET_LENGTH_OF_STRING(s,longueurLigne);

  {on gere les retours charriots DOS, UNIX, Mac, etc}
  if gEndOfLineFoundInReadln then
    begin
      if ((buffer[longueurLigne+1] = cr) and (buffer[longueurLigne+2] = lf)) or
         ((buffer[longueurLigne+1] = lf) and (buffer[longueurLigne+2] = cr))
         then inc(longueurLigne);
    end;

  {on deplace la tete de lecture}
  if gEndOfLineFoundInReadln
    then positionTeteDeLecture := 1 + positionTeteDeLecture + longueurLigne
    else positionTeteDeLecture :=     positionTeteDeLecture + longueurLigne;
  err := SetFilePosition(fic,positionTeteDeLecture);

  {
  WriteStringAndBoolDansRapport(s+' ',gEndOfLineFoundInReadln);
  WritelnNumDansRapport(' ==>  err = ',err);
  }

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FSRead dans Readln :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Readln := err;
end;



function Readln(var fic : basicfile; var s : LongString) : OSErr;
var longueur : SInt32;
    err : OSErr;
begin
  with s do
    begin
      debutLigne := '';
      finLigne   := '';
      complete   := true;

      err := Readln(fic, debutLigne);

      if (err = NoErr) then
        begin
          longueur := LENGTH_OF_STRING(debutLigne);
          if (longueur < 255) or
             ((longueur = 255) and gEndOfLineFoundInReadln)
            then
              begin
                Readln := err;
                exit;
              end
            else
              begin
                err := Readln(fic, finLigne);
                complete := gEndOfLineFoundInReadln;
              end;
        end;

      Readln := err;
    end;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   Readln()  : lit un fichier jusqu'au premier retour                        *
 *   chariot et met le resultat dans buffer. Cette fonction n'alloue pas le    *
 *   buffer, il doit avoir ete cree a la bonne taille auparavant.              *
 *      -> En entree, count est la taille du buffer                            *
 *      -> En sortie, count contient le nombre de caracteres jusqu'au premier  *
 *                    retour chariot, si on en a trouve un...                  *
 *                                                                             *
 *******************************************************************************
 *)
function Readln(var fic : basicfile; buffPtr : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
    i,len,longueurLigne : SInt32;
    positionTeteDeLecture : SInt32;
    localBuffer : PackedArrayOfCharPtr;
begin

  if FileIsStandardOutput(fic) then
    begin
      Readln := -1;
      exit;
    end;

  err := GetFilePosition(fic,positionTeteDeLecture);

  {on essaie de lire count caracteres dans buffPtr}
  len := count;
  err := Read(fic, buffPtr, count);
  localBuffer := PackedArrayOfCharPtr(buffPtr);

  {on cherche le premier retour charriot dans buffPtr}
  longueurLigne := Min(len,count);
  gEndOfLineFoundInReadln := false;
  for i := count-1 downto 0 do
    if (localBuffer^[i] = cr) or (localBuffer^[i] = lf) then
      begin
        longueurLigne := i;
        count := i;
        gEndOfLineFoundInReadln := true;
      end;


  {on deplace la tete de lecture}
  if gEndOfLineFoundInReadln
    then positionTeteDeLecture := 1 + positionTeteDeLecture + longueurLigne
    else positionTeteDeLecture :=     positionTeteDeLecture + longueurLigne;
  err := SetFilePosition(fic,positionTeteDeLecture);

  {
  WriteStringAndBoolDansRapport(s+' ',gEndOfLineFoundInReadln);
  WritelnNumDansRapport(' ==>  err = ',err);
  }

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres Read dans Readln :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Readln := err;
end;


function Read(var fic : basicfile; var value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      Read := -1;
      exit;
    end;

  count := 4;
  err := Read(fic, @value, count);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres Read dans Read :');
      DisplayMessageAndNumInConsole('count = ',count);
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Read := err;
end;


procedure ForEachLineInFileDo(whichFile : fileInfo; DoWhat : LineOfFileProc; var result : SInt32);
var theFic : basicfile;
    erreurES : OSErr;
    ligne : LongString;
begin
  erreurES := FileExists(whichFile, theFic);
  if (erreurES <> NoErr) then exit;

  erreurES := OpenFile(theFic);
  if (erreurES <> NoErr) then exit;

  with ligne do
    begin
      debutLigne := '';
      finLigne   := '';
      complete   := true;
    end;

  while not(EndOfFile(theFic,erreurES)) do
    begin

      erreurES := Readln(theFic,ligne);

      DoWhat(ligne,theFic,result);
    end;

  erreurES := CloseFile(theFic);
end;



function InsertFileInFile(var fic : basicfile; pathFichierAInserer : String255) : OSErr;
var insertion : basicfile;
    err : OSErr;
begin
  err := FileExists(pathFichierAInserer,0,insertion);
  if err = NoErr then
    begin
      err := OpenFile(insertion);
      err := InsertFileInFile(insertion,fic);
      CloseFile(insertion);
    end;

  InsertFileInFile := err;
end;


function InsertFileInFile(var insere,receptacle : basicfile) : OSErr;
const kTailleBufferCopie = 10000;
var err,err2 : OSErr;
    fichierInsereOuvert : boolean;
    fichierReceptacleOuvert : boolean;
    buffer : packed array[0.. (kTailleBufferCopie-1) ] of char;
    longueurInsertion : SInt32;
    count,nbOctetsCopies : SInt32;
begin

  err := NoErr;
  err2 := NoErr;

  fichierInsereOuvert := FileIsOpen(insere);
  if not(fichierInsereOuvert) then err := OpenFile(insere);
  err := SetFilePosition(insere,0);

  fichierReceptacleOuvert := FileIsOpen(receptacle);
  if not(fichierReceptacleOuvert) then
    begin  {ouvrir le fichier et placer le curseur à la fin}
      err2 := OpenFile(receptacle);
      err2 := SetFilePositionAtEnd(receptacle);
    end;

  if (err = NoErr) and (err2 = NoErr) then
    begin
      err := GetFileSize(insere,longueurInsertion);

      nbOctetsCopies := 0;

      repeat
        count := Min(kTailleBufferCopie, longueurInsertion-nbOctetsCopies);
        err  := Read(insere,@buffer[0],count);
        err2 := Write(receptacle,@buffer[0],count);
        nbOctetsCopies := nbOctetsCopies + count;
      until (err <> NoErr) or (err2 <> NoErr) or (nbOctetsCopies >= longueurInsertion);

    end;

  if not(fichierInsereOuvert)     then err  := CloseFile(insere);
  if not(fichierReceptacleOuvert) then err2 := CloseFile(receptacle);

  if (err <> NoErr)
    then InsertFileInFile := err
    else InsertFileInFile := err2;

end;




procedure SimpleAlertForFile(fileName : String255; erreurES : SInt32);
CONST TextesErreursID       = 10016;
var s,texte,explication,pathFichier : String255;
begin
  s := ReadStringFromRessource(TextesErreursID, 5);  {'erreur I/O sur fichier «^0» ! code erreur =  ^1'}

  pathFichier := fileName;
  if (Pos(DirectorySeparator, pathFichier) > 0)
    then
      begin
        fileName := ExtractFileOrDirectoryName(pathFichier);

        pathFichier := ReplaceStringAll(pathFichier, ':' , DirectorySeparator);

        s := ReplaceParameters(s,fileName,IntToStr(erreurES) + chr(13)+'  path = '+pathFichier,'','');
      end
    else
      begin
        s := ReplaceParameters(s,fileName,IntToStr(erreurES),'','');
      end;

  Split(s,'!',texte,explication);
  
  AlerteDouble(texte+'!',explication);
end;



function GetCreationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
begin
  if FileIsStandardOutput(fic) then
    begin
      GetCreationDate := -1;
      exit;
    end;

  GetCreationDate := -1;
end;


function GetModificationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
var err : OSErr;
    age : SInt32;
begin
  if FileIsStandardOutput(fic) then
    begin
      GetModificationDate := -1;
      exit;
    end;

  age := FileAge(fic.info.name);

  if age < 0 then
    begin
      err := -1;
    end
  else
    begin
      theDate := DecodeDateTime(FileDateToDateTime(age));
      err := NoErr;
    end;

  GetModificationDate := err;
end;


procedure InstallMessageDisplayerBasicFile(theProc : MessageDisplayerProc);
begin
  CustomDisplayMessage := theProc;
  useStandardConsole := false;
end;

procedure InstallMessageAndNumDisplayerBasicFile(theProc : MessageAndNumDisplayerProc);
begin
  CustomDisplayMessageWithNum := theProc;
  useStandardConsole := false;
end;

procedure InstallAlertBasicFile(theProc : MessageAndNumDisplayerProc);
begin
  CustomDisplayAlerteWithNum := theProc;
  useStandardConsole := false;
end;

procedure InitUnitBasicFile;
begin
  SetDebugFiles(false);

  (* installation des procedure pour l'affichage de message :
     sur la sortie standard par defaut. On peut installer des
     routines personalisees d'impression de messages et d'alerte
     juste apres l'appel a InitUnitBasicFile *)
  //InstallMessageDisplayerBasicFile(StandardConsoleDisplayer);
  //InstallMessageAndNumDisplayerBasicFile(StandardConsoleDisplayerWithNum);
 // InstallAlertBasicFile(StandardConsoleAlertWithNum);
  useStandardConsole := true;

  nameOfStandardOutputForRapport := 'Rapport-stdErr-fake-Cassio';

  unit_initialized := true;
end;


function CreateStandardOutputAsFile(var fic : basicfile) : OSErr;
begin
  if not(unit_initialized) then InitUnitBasicFile;
  CreateStandardOutputAsFile := CreateFile(nameOfStandardOutputForRapport,0,fic);
end;


procedure SetDebugFiles(flag : boolean);
begin
  debugBasicFiles := flag;
end;

function GetDebugFiles() : boolean;
begin
  GetDebugFiles := debugBasicFiles;
end;

procedure TestBasicFiles;
begin
   system.Writeln('');
   system.Writeln('Testing file system functions...');
   system.Writeln( DirectorySeparator );
   system.Writeln(GetCurrentDir());
end;

begin
  TestBasicFiles;
end.








