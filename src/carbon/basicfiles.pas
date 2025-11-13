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
            dataForkCorrectlyOpen : SInt32;       {private}
            rsrcForkCorrectlyOpen : SInt32;       {private}
            info : fileInfo;                      {private}
            readBuffer : TReadBuffer              {private}
          end;

{WARNING :    on risque de perturber InfosFichiersNouveauFormat dans le
              fichier UnitDefNouveauFormat (tableau trop gros)
              si on rajoute des gros champs à basicfile... }
              

TYPE  
   {functional type for ForEachLineInFileDo}
   LineOfFileProc = procedure(var ligne : LongString; var theFic : basicfile; var value : SInt32);



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
function SetEndOfFile(var fic : basicfile; whichSize : SInt32) : OSErr;
function ClearFileContent(var fic : basicfile) : OSErr;

// Accessing properties of files
function GetName(var fic : basicfile) : String255;
function GetName(var info : fileInfo) : String255;
function GetFileSize(var fic : basicfile; var whichSize : SInt32) : OSErr;
function GetUniqueID(var fic : basicfile) : SInt32;
function GetCreationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
function GetModificationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;

// Write data
function Write(var fic : basicfile; s : String255) : OSErr;
function Write(var fic : basicfile; buffer : Ptr; var count : SInt32) : OSErr;
function Write(var fic : basicfile; value : SInt32) : OSErr;
function Writeln(var fic : basicfile; s : String255) : OSErr;
function InsertFileInFile(var fic : basicfile; pathOfFileToInsert : String255) : OSErr;
function InsertFileInFile(var inserted, receptacle : basicfile) : OSErr;

// Read data
function Read(var fic : basicfile; buffer : Ptr; var count : SInt32) : OSErr;
function Read(var fic : basicfile; count : SInt16; var s : String255) : OSErr;
function Read(var fic : basicfile; var value : SInt32) : OSErr;
function Readln(var fic : basicfile; var s : String255) : OSErr;
function Readln(var fic : basicfile; var s : LongString) : OSErr;
function Readln(var fic : basicfile; buffer : Ptr; var count : SInt32) : OSErr;

// Iterate on each line of a text file
procedure ForEachLineInFileDo(whichFile : fileInfo ; DoWhat : LineOfFileProc; var value : SInt32);

// Manipulating paths of files and directories
procedure DoDirSeparators(var path : String255);
function EndsWithDirectorySeparator(var s : String255) : boolean;
function ExtractFileName(whichFile : fileInfo; var theLongName : String255) : OSErr;
function ExtractFileName(path : String255; var theLongName : String255) : OSErr;
function ExtractFileOrDirectoryName(path : String255) : String255;

// Manipulating the standard output as a file
function CreateStandardOutputAsFile(var fic : basicfile) : OSErr;
function FileIsStandardOutput(var fic : basicfile) : boolean;

// Useful flag to debug the library
procedure SetDebugFiles(flag : boolean);
function  GetDebugFiles() : boolean;

// Display simple alert for file errors
procedure SimpleAlertForFile(fileName : String255; erreurES : SInt32);

// Display messages in the console
procedure InstallMessageDisplayerBasicFile(theProc : MessageDisplayerProc);
procedure InstallMessageAndNumDisplayerBasicFile(theProc : MessageAndNumDisplayerProc);
procedure InstallAlertBasicFile(theProc : MessageAndNumDisplayerProc);
procedure DisplayMessageInConsole(s : String255);
procedure DisplayMessageAndNumInConsole(s : String255; num : SInt32);
procedure DisplayAlertWithNumInConsole(s : String255; num : SInt32);




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


// StandardConsoleDisplayer(s) : write s to the standard output
procedure StandardConsoleDisplayer(s : String255);
begin
  system.Writeln(s);
end;


// StandardConsoleDisplayerWithNum(s,n) : write s and n to the standard output
procedure StandardConsoleDisplayerWithNum(s : String255; num : SInt32);
begin
  system.Writeln(s,num);
end;


// StandardConsoleAlertWithNum(s,n) : write a warning to the standard output
procedure StandardConsoleAlertWithNum(s : String255; num : SInt32);
begin
  system.Writeln('### WARNING ### '+s+' ',num);
end;


// DisplayMessageInConsole(s) : write s to the custom terminal
procedure DisplayMessageInConsole(s : String255);
begin
  if unit_initialized and false
    then CustomDisplayMessage(s)
    else StandardConsoleDisplayer(s);
end;


// DisplayMessageAndNumInConsole(s,n) : write s to the custom terminal
procedure DisplayMessageAndNumInConsole(s : String255; num : SInt32);
begin
  if unit_initialized and false
    then CustomDisplayMessageWithNum(s,num)
    else StandardConsoleDisplayerWithNum(s,num);
end;


// DisplayAlertWithNumInConsole(s,n) : write a warning to the custom terminal
procedure DisplayAlertWithNumInConsole(s : String255; num : SInt32);
begin
  if unit_initialized and false
    then CustomDisplayAlerteWithNum(s,num)
    else StandardConsoleAlertWithNum(s,num)
end;


// DoDirSeparators() : replace the directory separators for the current OS
procedure DoDirSeparators(var path : String255);
var s : String;
begin
   s := path;
   sysUtils.DoDirSeparators(s);
   path := s;
end;


// EndsWithDirectorySeparator() : true iff s ends with a directory separator
function EndsWithDirectorySeparator(var s : String255) : boolean;
begin
  EndsWithDirectorySeparator := (s[LENGTH_OF_STRING(s)] = DirectorySeparator );
end;


// MakeFileInfo(volume, dir, name, info) : should not be used anymore outside
// the basicFile library, because it uses Macintosh specific concepts.
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


// MakeFileInfo(volume, dir, name) : should not be used anymore outside
// the basicFile library, because it uses Macintosh specific concepts.
function MakeFileInfo(vrn : SInt16; dirID : SInt32; name : String255) : fileInfo;
var info : fileInfo;
begin
   MakeFileInfo(vrn, dirID, name, info); // discard error !
   
   MakeFileInfo := info;
end;


// MakeFileInfo(name, info) : create a file info record, if a directory or a
// file with the given name exists. The returned fileInfo record is valid for 
// both directories and files.
function MakeFileInfo(name : String255; var info : fileInfo) : OSErr;
begin
   result := MakeFileInfo(0, 0, name, info);
end;


// MakeFileInfo(name) : create a file info record, if a directory or a file
// with the given name exists. The returned fileInfo record is valid for 
// both directories and files.
function MakeFileInfo(name : String255) : fileInfo;
begin
  result := MakeFileInfo(0, 0, name);
end;


// ExpandFileName(info, path) : returns the full path of the file
function ExpandFileName(var fs : fileInfo; var path : String255) : OSErr;
var err : OSErr;
    s : String255;
    info : fileInfo;
begin
  s := GetName(fs);
  err := MakeFileInfo(fs.vRefNum, fs.parID, s, info);
  if err = fnfErr then err := NoErr;
  if err = NoErr then
     begin
        path := sysUtils.ExpandFileName(s);
        fs := MakeFileInfo(path);
     end;

  Result := err;
end;


// ExpandFileName(info) : returns the full path of the file
function ExpandFileName(var fs : fileInfo) : String255;
var path : String255;
begin
   ExpandFileName(fs, path);
   fs := MakeFileInfo(path);

   Result := path;
end;


// ExpandFileName(name) : expand the given file name to a full path+name. 
// This functions tries hard to follow links, resolve aliases, etc.
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


// ExpandFileName(fic) : expand the name of the given file
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
      uniqueID   := abs(HashString(fullName));

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
      DisplayMessageAndNumInConsole('fic.uniqueID = ',fic.uniqueID);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.info.vRefNum = ',fic.info.vRefNum);
      DisplayMessageAndNumInConsole('fic.info.parID = ',fic.info.parID);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;
  ExpandFileName := err;
end;


// FileIsStandardOutput() : true if the given file is in fact the standard output
function FileIsStandardOutput(var fic : basicfile) : boolean;
begin
  FileIsStandardOutput := (fic.vRefNum = 0) and
                          (fic.parID = 0) and
                          (fic.handle = 0) and
                          (fic.fileName = nameOfStandardOutputForRapport);
end;


// InitializeBasicFile() : Initialise a basicfile record. This function is
// for internal use only inside the basicFile library. 
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
  fic.dataForkCorrectlyOpen := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkCorrectlyOpen := -1; {niveau d'ouverture = 0 veut dire correct}

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


// InitializeBasicFile() : Initialise a basicfile record. This function is
// for internal use only inside the basicFile library. 
procedure InitializeBasicFile(info : fileInfo; var fic : basicfile);
begin

  fic.fileName   := info.name;
  fic.vRefNum    := info.vRefNum;
  fic.parID      := info.parID;
  fic.handle     := 0;
  fic.uniqueID   := 0;  {not yet initialised, we'll do it in ExpandFileName}
  fic.info       := info;
  fic.ressourceForkRefNum        := -1;
  fic.dataForkCorrectlyOpen := -1; {niveau d'ouverture = 0 veut dire correct}
  fic.rsrcForkCorrectlyOpen := -1; {niveau d'ouverture = 0 veut dire correct}

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


// ExtractFileName() : extract the file name of a given fileInfo
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


// ExtractFileName() : extract the file name of a given path
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


// ExtractFileName() : extract the file name or the directory name of a path.
// This function works both for directories and files.
function ExtractFileOrDirectoryName(path : String255) : String255;
const separator = DirectorySeparator;
begin
  if RightStr(path,1) = separator
    then KeepPrefix(path, LENGTH_OF_STRING(path)-1);

  ExtractFileOrDirectoryName := RightStr(path,LENGTH_OF_STRING(path)-PosRight(separator,path));
end;


// FileExists() : checks that a file with the given name exists, and 
// constructs a valid basicfile record to open and manipulate that file.
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
      DisplayMessageAndNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
    end;
end;


// FileExists() : checks that a file with the given fileInfo exists, and 
// constructs a valid basicfile record to open and manipulate that file.
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
      DisplayMessageAndNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
    end;
end;


// CreatFile() : create file on the disc
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


// CreateFile() : create file on the disc
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



// OpenFile() : open the file, and set the file cursor at start
function OpenFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      OpenFile := NoErr;
      exit;
    end;

  if fic.dataForkCorrectlyOpen <> -1 then
    begin
      // Beep();
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut ouvrir le data Fork d''un fichier dont fic.dataForkCorrectlyOpen <> -1 !');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageInConsole('fic.info.name) = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
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
      inc(fic.dataForkCorrectlyOpen);
      if fic.dataForkCorrectlyOpen <> 0 then
        begin
          // Beep();
          DisplayMessageInConsole('');
          DisplayMessageInConsole('## WARNING : après une ouverture réussie, dataForkCorrectlyOpen <> 0 !');
          DisplayMessageInConsole('fic.fileName = '+fic.fileName);
          DisplayMessageAndNumInConsole('fic.dataForkCorrectlyOpen',fic.dataForkCorrectlyOpen);
          DisplayMessageInConsole('');
        end;
    end;

  OpenFile := err;
end;


// CloseFile() : close the file
function CloseFile(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      CloseFile := NoErr;
      exit;
    end;

  if fic.dataForkCorrectlyOpen <> 0 then
    begin
      // Beep();
      DisplayMessageInConsole('');
      DisplayMessageInConsole('## WARNING : on veut fermer le data Fork d''un fichier qui n''a pas ete correctement ouvert !');
      DisplayMessageInConsole('fic.fileName = '+fic.fileName);
      DisplayMessageInConsole('fic.info.name = '+fic.info.name);
      DisplayMessageAndNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
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
        dec(fic.dataForkCorrectlyOpen);
        if (fic.dataForkCorrectlyOpen <> -1) then
          begin
            // Beep();
            DisplayMessageInConsole('');
            DisplayMessageInConsole('## WARNING : après une fermeture correcte du data fork d''un fichier, dataForkCorrectlyOpen <> -1 !');
            DisplayMessageInConsole('fic.fileName = '+fic.fileName);
            DisplayMessageAndNumInConsole('fic.dataForkCorrectlyOpen = ',fic.dataForkCorrectlyOpen);
            DisplayMessageInConsole('');
          end;
      end;

  CloseFile := err;
end;


// DeleteFile() : delete the file on the disc
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


// FileIsOpen() : check if a file is open
function FileIsOpen(var fic : basicfile) : boolean;
begin

  if FileIsStandardOutput(fic) then
    begin
      FileIsOpen := true;
      exit;
    end;

  FileIsOpen := (fic.dataForkCorrectlyOpen = 0);
end;


// GetUniqueID() : return a 32 bit identificator for the given file. 
// This identificator is calculated via hashing of the full path of the file, 
// so should be quite unique.
function GetUniqueID(var fic : basicfile) : SInt32;
begin
  GetUniqueID := fic.uniqueID;
end;


// GetFileSize() : returns the size of the file on the disc
function GetFileSize(var fic : basicfile; var whichSize : SInt32) : OSErr;
var err : OSErr;
    searchData : TSearchRec;
begin

  if FileIsStandardOutput(fic) then
    begin
      whichSize := GetTailleRapport;
      GetFileSize := NoErr;
      exit;
    end;
  
  if FindFirst(fic.info.name, 0, searchData) = 0 then
    begin
      err := NoErr;
      whichSize := searchData.Size;
    end
  else
    begin
      err := -1;
      whichSize := -1;
    end;
  FindClose(searchData);


  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres FindFirst dans GetFileSize :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('whichSize = ',whichSize);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  GetFileSize := err;
end;


// GetName() : name of the file
function GetName(var fic : basicfile) : String255;
begin
  GetName := fic.info.name;
end;


// GetName() : name of the file
function GetName(var info : fileInfo) : String255;
begin
  GetName := info.name;
end;


// SetFilePosition() : set the file cursor position for reading and writing
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


// SetFilePositionAtEnd() : set the file cursor position at the end of the file
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


// GetFilePosition() : get the file cursor position
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


// EndOfFile() : true if the file position is at the end of the file
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


// SetEndOfFile() : truncate the file size on disc at the given size
function SetEndOfFile(var fic : basicfile; whichSize : SInt32) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      SetEndOfFile := NoErr;
      exit;
    end;

  if FileTruncate(fic.handle, whichSize)
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


// ClearFileContent() : empty the file content by setting its size to zero
function ClearFileContent(var fic : basicfile) : OSErr;
var err : OSErr;
begin

  if FileIsStandardOutput(fic) then
    begin
      DetruireTexteDansRapport(0,2000000000,true);  {2000000000 was MawLongint}
      ClearFileContent := NoErr;
      exit;
    end;

  err := SetEndOfFile(fic,0);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres SetEndOfFile dans ClearFileContent :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  ClearFileContent := err;
end;


// Write(fic, buffer, count) : write 'count' bytes from buffer to the file
function Write(var fic : basicfile; buffer : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
begin

  if count <= 0 then
    begin
      Write := NoErr;
      exit;
    end;

  if FileIsStandardOutput(fic) then
    begin
      InsereTexteDansRapport(buffer, count);
      Write := NoErr;
      exit;
    end;

  count := FileWrite(fic.handle, buffer^, count);
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


// Write(fic, s) : write string s to the file
function Write(var fic : basicfile; s : String255) : OSErr;
var err : OSErr;
    count : SInt32;
    buffer : Ptr;
begin

  if FileIsStandardOutput(fic) then
    begin
      WriteDansRapport(s);
      Write := NoErr;
      exit;
    end;

  count := LENGTH_OF_STRING(s);
  buffer :=  @s[1];
  err := FileWrite(fic.handle, buffer^, count);

  if debugBasicFiles then
    begin
      DisplayMessageInConsole('');
      DisplayMessageInConsole(' apres MyFSWriteString dans Write :');
      DisplayMessageAndNumInConsole('fic.handle = ',fic.handle);
      DisplayMessageAndNumInConsole('   ==> Err = ',err);
    end;

  Write := err;
end;


// Writeln(fic, s) : write string s to the file, followed by a carriage return (#13)
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


// Write(fic, n) : write the (4 bytes) integer n to the file, as raw bytes.
// Beware of endianness when reading the bytes back afterwards. 
function Write(var fic : basicfile; value : SInt32) : OSErr;
var err : OSErr;
    count : SInt32;
    buffer : Ptr;
begin

  if FileIsStandardOutput(fic) then
    begin
      InsereTexteDansRapport(@value,4);
      Write := NoErr;
      exit;
    end;

  buffer :=  @value;
  count := FileWrite(fic.handle, buffer^, 4);
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


// Read(fic, buffer, count) : read 'count' bytes from the file, and put them
// in the given buffer. On exit, count is set to number of bytes actually read.
function Read(var fic : basicfile; buffer : Ptr; var count : SInt32) : OSErr;
var err : OSErr;
    nbBytesRead : SInt32;
begin

  if FileIsStandardOutput(fic) then
    begin
      Result := -1;
      exit;
    end;

  nbBytesRead := FileRead(fic.handle, buffer^, count);
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


// Read(fic, count, s) : read count bytes from the file, and put them as
// characters in the string s. 
function Read(var fic : basicfile; count : SInt16; var s : String255) : OSErr;
var len, nbBytesRead : SInt32;
    buffer : Ptr;
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

  buffer := @s[1];
  nbBytesRead := FileRead(fic.handle, buffer^, len);
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


// BufferedReadPourReadln() : internal function to speed up the Readln()
// function. Use a buffer instead of reading the file character by character.

function BufferedReadPourReadln(var fic : basicfile; var length : SInt32; outBuffer : Ptr) : OSErr;
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
            if debug then WritelnDansRapport('DEBUG : allocation du buffer de lecture');
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
                if debug then WritelnNumDansRapport('DEBUG : erreur dans le calcul de la taille du fichier : ',tailleDuFichier);
                goto Bail;
              end;
            if debug then WritelnNumDansRapport('DEBUG : calcul de la taille du fichier : ',tailleDuFichier);
          end;


        if (tailleDuFichier > 0) and
           (length > tailleDuFichier - (debutDuBuffer + positionDansBuffer)) and
           ((positionDansBuffer + length) > tailleDuBuffer)
           then length := tailleDuFichier - (debutDuBuffer + positionDansBuffer);


        if ((positionDansBuffer + length) > tailleDuBuffer) then
          begin
            nbOctetsLusSurLeDisque := SIZE_OF_BUFFER;

            err := GetFilePosition(fic, debutDuBuffer);

            if debug then WritelnNumDansRapport('DEBUG : apres GetFilePosition, err = ',err);

            if (err = NoErr) then
              begin
              
                if debug then WritelnNumDansRapport('DEBUG : avant FileRead(1), nbOctetsLusSurLeDisque = ', nbOctetsLusSurLeDisque);
                if debug then WritelnNumDansRapport('DEBUG : avant FileRead(1), fic.handle = ', fic.handle);
                
                nbOctetsLusSurLeDisque := FileRead(fic.handle, bufferLecture^, nbOctetsLusSurLeDisque);
                
                if debug then WritelnNumDansRapport('DEBUG : apres FileRead(1), nbOctetsLusSurLeDisque = ', nbOctetsLusSurLeDisque);
                
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
                  if debug then WritelnNumDansRapport('DEBUG : lecture dans le fichier : ',tailleDuBuffer);
                end
              else
                begin
                  if debug then WritelnNumDansRapport('DEBUG : erreur de lecture dans le fichier, err = ',err);
                  if debug then WritelnNumDansRapport('DEBUG : nbOctetsLusSurLeDisque = ',nbOctetsLusSurLeDisque);

                  
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
            resultBuffer := PackedArrayOfCharPtr(outBuffer);

            for k := 0 to length - 1 do
              resultBuffer^[k] := bufferLecture^[positionDansBuffer + k];

            positionDansBuffer := positionDansBuffer + length;

            luDansLeBuffer := true;
            BufferedReadPourReadln := NoErr;

            // if debug then WritelnNumDansRapport('DEBUG : OK, positionDansBuffer = ',positionDansBuffer);
          end;

      end;

Bail :

  if not(luDansLeBuffer) then
    begin
      if debug then WritelnNumDansRapport('avant desesperate FileRead, length = ',length);
      
      length := FileRead(fic.handle, outBuffer^, length);
      if length > 0 then
          begin
             err := NoErr;
          end
        else
          begin
             err := -1;
             length := 0;
          end;

      BufferedReadPourReadln := err;

      if debug then WritelnNumDansRapport('apres desesperate FileRead, length = ',length);
      if debug then WritelnNumDansRapport('apres desesperate FileRead, err = ',err);
    end;
end;



// Readln(fic, s) : read the next line in the file (String255 version).
// Separators for lines in the file are the CR and/or LF characters.
// This version outputs a short string (255 characters max).

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
  err := BufferedReadPourReadln(fic, len, @buffer[1]);
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


// Readln(fic, s) : read the next line in the file (LongString version).
// Separators for lines in the file are the CR and/or LF characters.
// This version outputs a long string (510 characters max).

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
 *      -> En sortie, count devient le nombre de caracteres jusqu'au premier   *
 *                    retour chariot, si on en a trouve un.                    *
 *                                                                             *
 *******************************************************************************
 *)
function Readln(var fic : basicfile; buffer : Ptr; var count : SInt32) : OSErr;
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

  err := GetFilePosition(fic, positionTeteDeLecture);

  {on essaie de lire count caracteres dans buffer}
  len := count;
  err := Read(fic, buffer, count);
  localBuffer := PackedArrayOfCharPtr(buffer);

  {on cherche le premier retour charriot dans buffer}
  longueurLigne := Min(len,count);
  gEndOfLineFoundInReadln := false;
  for i := count - 1 downto 0 do
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
  err := SetFilePosition(fic, positionTeteDeLecture);

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



// Read(fic, n) : read 4 binary bytes in the file, and interpret them 
// as the 4 bytes of a 32-bits integer n.
// Beware of endianness issues if the file has been created on a machine
// with a different endianness to the endianness of the current machine.

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


// ForEachLineInFileDo(fic, what, value) : call the function 'what' on each
// line of the text file 'fic'. The value 'value' can be used and modified
// by the function 'what' during the iteration to calculate a number which 
// depends of each line of the file.

procedure ForEachLineInFileDo(whichFile : fileInfo; DoWhat : LineOfFileProc; var value : SInt32);
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

  // call the DoWhat function on each line of the file
  while not(EndOfFile(theFic,erreurES)) do
    begin
      erreurES := Readln(theFic,ligne);
      DoWhat(ligne, theFic, value);
    end;

  erreurES := CloseFile(theFic);
end;


// InsertFileInFile(fic, name) : copy the content of file named 'name'
// at the current position of the file 'fic'.

function InsertFileInFile(var fic : basicfile; pathOfFileToInsert : String255) : OSErr;
var inserted : basicfile;
    err : OSErr;
begin
  err := FileExists(pathOfFileToInsert, 0, inserted);
  if err = NoErr then
    begin
      err := OpenFile(inserted);
      err := InsertFileInFile(inserted, fic);
      CloseFile(inserted);
    end;

  InsertFileInFile := err;
end;


// InsertFileInFile(inserted, receptacle) : copy the content of file 'inserted'
// at the current position of the file 'receptacle'.

function InsertFileInFile(var inserted, receptacle : basicfile) : OSErr;
const BUFFSIZE = 10000;
var err,err2 : OSErr;
    fileInsertedIsOpen : boolean;
    fileReceptacleIsOpen : boolean;
    buffer : packed array[0..(BUFFSIZE-1)] of char;
    insertedLength : SInt32;
    count, copied : SInt32;
begin

  err := NoErr;
  err2 := NoErr;

  fileInsertedIsOpen := FileIsOpen(inserted);
  if not(fileInsertedIsOpen) then err := OpenFile(inserted);
  err := SetFilePosition(inserted,0);

  fileReceptacleIsOpen := FileIsOpen(receptacle);
  if not(fileReceptacleIsOpen) then
    begin  
      err2 := OpenFile(receptacle);
      err2 := SetFilePositionAtEnd(receptacle);
    end;

  if (err = NoErr) and (err2 = NoErr) then
    begin
      err := GetFileSize(inserted, insertedLength);

      copied := 0;

      repeat
      
        count := Min(BUFFSIZE, insertedLength - copied);
        err  := Read(inserted,@buffer[0],count);
        err2 := Write(receptacle,@buffer[0],count);
        copied := copied + count;
        
      until (err <> NoErr) or (err2 <> NoErr) or (copied >= insertedLength);

    end;

  if not(fileInsertedIsOpen)   then err  := CloseFile(inserted);
  if not(fileReceptacleIsOpen) then err2 := CloseFile(receptacle);

  if (err <> NoErr)
    then InsertFileInFile := err
    else InsertFileInFile := err2;

end;



// SimpleAlertForFile() : show simple alert for file errors
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


// GetCreationDate() : get creation date of a file
// Warning : not implemented !
function GetCreationDate(var fic : basicfile; var theDate : DateTimeRec) : OSErr;
begin
  if FileIsStandardOutput(fic) then
    begin
      GetCreationDate := -1;
      exit;
    end;

  GetCreationDate := -1;
end;


// GetCreationDate() : get modification date of a file
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


(* Installation des procedures pour l'affichage de message :    *)
(* sur la sortie standard par defaut. On peut installer des     *)
(* routines personalisees d'impression de messages et d'alerte  *)
(* juste apres l'appel a InitUnitBasicFile                      *)
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

  (* installation des procedures pour l'affichage de message :
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


// Useful flag to debug the library
procedure SetDebugFiles(flag : boolean);
begin
  debugBasicFiles := flag;
end;

// Useful flag to debug the library
function GetDebugFiles() : boolean;
begin
  GetDebugFiles := debugBasicFiles;
end;


// Testing the unit
procedure TestBasicFiles;
var i : SInt32;
    name : String255;
    err : OSErr;
    info : fileInfo;
    fic : basicFile;
    ligne : longString;
    s : String255;
    n, p, count : SInt32;
    buffer : packed array[0..99] of UInt8;
begin
   system.Writeln('');
   system.Writeln('Testing file system functions...');
   system.Writeln('DirectorySeparator = ', DirectorySeparator);
   system.Writeln('GetCurrentDir()' = GetCurrentDir());
   system.Writeln(paramstr(0),' : Got ',ParamCount(),' command-line parameters: ');
   For i := 1 to ParamCount() do
      system.Writeln(ParamStr(i));
   system.Writeln('');

   system.Writeln('Testing the BasicFiles library...');
   
   
   SetDebugFiles(false);
   
   name := 'toto.txt';
   n    := HexToInt('00008000');
   system.writeln( '################ ' + name + ' ################');
   
   system.writeln( MakeFileInfo(name, info) );
   system.writeln( FileExists(info, fic) );
   system.writeln( CreateFile(info, fic) );
   
   
   system.writeln( 'n = ' , n );
   system.writeln( Write(fic, n) );
   system.writeln( Write(fic, n+1) );
   system.writeln( Writeln(fic, 'toto') );
   system.writeln( Writeln(fic, 'est') );
   system.writeln( Writeln(fic, 'grand') );

   system.writeln( SetFilePosition(fic, 0) );
   system.writeln( Read(fic, p) );
   system.writeln( 'p = ' , p );
   system.writeln( Read(fic, p) );
   system.writeln( 'p = ' , p );
   system.writeln( SetFilePosition(fic, 0) );
   count := 8;
   system.writeln( Read(fic, Ptr(@buffer), count) );
   system.writeln( 'count = ' , count );
   for n := 0 to 7 do
      system.writeln(n, '  -->  ', buffer[n]);

   
      
   system.writeln( SetFilePosition(fic, 0) );
   count := 100;
   system.writeln( Read(fic, Ptr(@buffer), count) );
   for n := 0 to 25 do
      system.writeln(n, '  -->  ', buffer[n] , ' = ', char(buffer[n]) );
   
   system.writeln( ClearFileContent(fic) );
   system.writeln( OpenFile(fic) );
   system.writeln( CloseFile(fic) );
   system.writeln( OpenFile(fic) );
   
   
   s := 'il est 4 heures';
   count := length(s);
   system.writeln( 'length(s) = ', count);
   MemoryFillChar( @buffer, sizeof(buffer), chr(0));
   for n := 1 to count do
     buffer[n - 1] := ord(s[n]);
   for n := 0 to 20 do
     system.writeln(n, '  -->  ', buffer[n] , ' = ', char(buffer[n]) );
    
   system.writeln( Write(fic, Ptr(@buffer), count) );
   system.writeln( Writeln(fic, 'toto') );
   system.writeln( Writeln(fic, 'est') );
   system.writeln( Writeln(fic, 'grand') );

   system.writeln( SetFilePosition(fic, 0) );
   system.writeln( 'sizeof(buffer) = ', sizeof(buffer));
   MemoryFillChar( @buffer, sizeof(buffer), chr(0));
   for n := 0 to 20 do
     system.writeln(n, '  -->  ', buffer[n] , ' = ', char(buffer[n]) );
   count := 100;
   system.writeln( Readln(fic, Ptr(@buffer), count) );
   GetFilePosition(fic, p);
   system.writeln( 'count = ' , count );
   system.writeln( 'GetFilePosition(fic) = ' , p );
   for n := 0 to count-1 do
      system.writeln(n, '  -->  ', buffer[n] , ' = ', char(buffer[n]) );
   count := 100;
   system.writeln( Readln(fic, Ptr(@buffer), count) );
   GetFilePosition(fic, p);
   system.writeln( 'count = ' , count );
   system.writeln( 'GetFilePosition(fic) = ' , p );
   for n := 0 to count-1 do
      system.writeln(n, '  -->  ', buffer[n] , ' = ', char(buffer[n]) );

   system.writeln( Read(fic, 2, s) );
   system.writeln( 's = ' + s);
   system.writeln( Readln(fic, s) );
   system.writeln( 's = ' + s);
      
   system.writeln( ClearFileContent(fic) );
      
   system.writeln( CloseFile(fic) );
   system.writeln( OpenFile(fic) );
   system.writeln( CloseFile(fic) );
   
   name := paramstr(0);            // the name of the current executable
   system.writeln( '################ ' + name + ' ################');
   system.writeln( MakeFileInfo(name, info) );
   system.writeln( FileExists(info, fic) );
   system.writeln( OpenFile(fic) );
   system.writeln( CloseFile(fic) );
   
   name := './images/';
   system.writeln( '################ ' + name + ' ################');
   system.writeln(sysUtils.DirectoryExists(name));
   system.writeln( MakeFileInfo(name, info) );
   system.writeln( FileExists(info, fic) );
   system.writeln( OpenFile(fic) );
   system.writeln( CloseFile(fic) );
   system.writeln(sysUtils.DirectoryExists(fic.filename));
   
   name := 'temp.foo.txt';
   system.writeln( '################ ' + name + ' ################');
   system.writeln( MakeFileInfo(name, info) );
   system.writeln( FileExists(info, fic) );
   system.writeln( OpenFile(fic) );
   with ligne do
      begin
        debutLigne := '';
        finLigne   := '';
        complete   := true;
      end;
   while not(EndOfFile(fic,err)) do
      begin
        err := Readln(fic,ligne);
        //WritelnLongStringDansRapport(ligne);
      end;
   system.writeln( CloseFile(fic) );
   
   name := 'temp.foo.txt';
   system.writeln( '################ ' + name + ' ################');
   system.writeln( MakeFileInfo(name, info) );
   system.writeln( FileExists(info, fic) );
   system.writeln( OpenFile(fic) );
   with ligne do
      begin
        debutLigne := '';
        finLigne   := '';
        complete   := true;
      end;
   while not(EndOfFile(fic,err)) do
      begin
        err := Readln(fic,s);
        //WritelnDansRapport(s);
      end;
   system.writeln( CloseFile(fic) );
   
   
   
end;

begin
  // Always init the library
  InitUnitBasicFile;
  
  // TestBasicFiles;
end.








