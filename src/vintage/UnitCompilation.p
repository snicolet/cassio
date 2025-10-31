UNIT UnitCompilation;


INTERFACE


 USES UnitDefCassio;


{initialisation de l'unite}
procedure InitUnitCompilation;
procedure LibereMemoireUnitCompilation;


{ajout d'un module}
function MakeEmptyModule(const name : String255) : Module;
procedure AjouterModule(const name : String255; var nouveauModule : Module);


{acces aux modules}
function ModuleEstChargeEnMemoire(const nom : String255; var numeroModule : SInt64; var theModule : Module) : boolean;
function GetModule(const name : String255) : Module;
function GetModuleByNumero(numero : SInt64) : Module;
function GetNumeroOfModule(whichModule : Module) : SInt64;
function GetNameOfModule(whichModule : Module) : String255;


{liaison nom d'unite  < -> module}
function ModuleDoitEtreAccelere(const name : String255) : boolean;
function ModuleDoitEtrePrelinke(const name : String255) : boolean;
function TrouverFichierDansSourcesDeCassio(const nomUnite : String255; var fic : basicfile) : boolean;



{ecritures des symboles}
function EcrireSymboleExternalDansFichier(sym : Symbole; var fic : basicfile) : OSErr;
function EcrireSymboleAttributeDansFichier(sym : Symbole; var fic : basicfile) : OSErr;


{verification des sources}
procedure VerifierLongueurDeLaLigneDansLesSources(var ligne : LongString; var lectureAddr : SInt64);
procedure VerifierCeFichierSource(const whichFile : fileInfo);
function VerifierCeFichierSourceEtRecursion(var fs : fileInfo; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
procedure VerifierLesSourcesDeCassio;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, UnitDefATR
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyStrings, UnitRapportImplementation, basicfile, MyFileSystemUtils, SNEvents
    , UnitStringSet, UnitPagesDeModules, UnitPagesDeSymboles, UnitATR, UnitLongString ;
{$ELSEC}
    ;
    {$I prelink/Compilation.lk}
{$ENDC}


{END_USE_CLAUSE}







CONST
   kNombreMaxModules = 1000;
   kPathSourcesDeCassio              = 'Glenans:Users:stephane:Jeux:Othello:Cassio:Cassio sources';
   kPathDuplicatesDesSourcesDeCassio = 'Glenans:Users:stephane:Sauvegardes:Sauvegardes Cassio:duplicates';

TYPE
  ListeDeModules =   record
                       cardinal  : SInt64;
                       pointeurs : array[1..kNombreMaxModules] of Module;
                     end;

VAR
  gTableDesModules : ListeDeModules;
  gModulesCharges : StringSet;

  gSymbolesCharges : StringSet;



TYPE

  parties_de_modules = (kPrologue,
                        kInterfacePrologue,
                        kInterfaceUses,
                        kInterfaceDeclarations,
                        kImplementationPrologue,
                        kImplementationUses,
                        kImplementationDeclarations,
                        kImplementationCode,
                        kEpilogue);
  actions_de_compilation = (K_COMPILER_INTERFACE,
                            K_COMPILER_IMPLEMENTATION);

  LectureModulePtr = ^LectureModuleRec;
  LectureModuleRec =
    record
      action                             : actions_de_compilation;
      nombreErreurs                      : SInt64;
      nombreLignesTropLongues            : SInt64;
      nombreDeclarationsIndues           : SInt64;
      enCoursDeLecture                   : parties_de_modules;
      doitEtrePrelinke                   : boolean;
      doitEtreAccelere                   : boolean;
      whichModule                        : Module;
      fichierExternalDeclarations        : basicfile;
      fichierPrelink                     : basicfile;
      duplication                        : basicfile;
      modulesInterface                   : ListeDeModules;
      modulesImplementation              : ListeDeModules;
      clauseUsesInterfaceDejaEcrite      : boolean;
      clauseUsesImplementationDejaEcrite : boolean;
      unitDefCassioDejaEcrite            : boolean;
      fonctionsObligatoiresDejaEcrites   : boolean;
      got_BEGIN_USE_CLAUSE               : boolean;
      flag_USE_PRELINK                   : boolean;
      afficheTransitionsDansFichier      : boolean;
    end;



procedure InitUnitCompilation;
var k : SInt64;
begin

  gTableDesModules.cardinal := 0;
  for k := 1 to kNombreMaxModules do
    gTableDesModules.pointeurs[k] := NIL;


  gModulesCharges := MakeEmptyStringSet;
  gSymbolesCharges := MakeEmptyStringSet;
end;


procedure LibereMemoireUnitCompilation;
begin
  DisposeStringSet(gModulesCharges);
  DisposeStringSet(gSymbolesCharges);
end;


function ModuleEstChargeEnMemoire(const nom : String255; var numeroModule : SInt64; var theModule : Module) : boolean;
begin
  numeroModule := -1;
  theModule := NIL;
  ModuleEstChargeEnMemoire := false;

  if MemberOfStringSet(sysutils.LowerCase(nom), numeroModule, gModulesCharges) then
    begin
      theModule := gTableDesModules.pointeurs[numeroModule];
      ModuleEstChargeEnMemoire := true;
    end;
end;


function SymboleEstChargeEnMemoire(const nom : String255; var theSymbole : Symbole) : boolean;
var adresseSymbole : SInt64;
begin
  theSymbole := NIL;
  SymboleEstChargeEnMemoire := false;

  if MemberOfStringSet(sysutils.LowerCase(nom), adresseSymbole, gSymbolesCharges) then
    begin
      theSymbole := Symbole(adresseSymbole);
      SymboleEstChargeEnMemoire := true;
    end;
end;


function GetSymbole(const name : String255) : Symbole;
var result : Symbole;
begin
  if SymboleEstChargeEnMemoire(name,result)
    then GetSymbole := result
    else GetSymbole := NIL;
end;


function GetModule(const name : String255) : Module;
var result : Module;
    numero : SInt64;
begin
  if ModuleEstChargeEnMemoire(name, numero, result)
    then GetModule := result
    else GetModule := NIL;
end;


function GetModuleByNumero(numero : SInt64) : Module;
begin
  if (numero >= 1) and (numero <= gTableDesModules.cardinal)
    then GetModuleByNumero := gTableDesModules.pointeurs[numero]
    else GetModuleByNumero := NIL;
end;


function GetNumeroOfModule(whichModule : Module) : SInt64;
var numero : SInt64;
    moduleVerif : Module;
begin
  if ModuleEstChargeEnMemoire(GetNameOfModule(whichModule), numero, moduleVerif)
    then GetNumeroOfModule := numero
    else GetNumeroOfModule := -1;
end;


function GetNameOfModule(whichModule : Module) : String255;
begin
  if (whichModule <> NIL)
    then GetNameOfModule := whichModule^.nomModule
    else GetNameOfModule := '';
end;


function MakeEmptyModule(const name : String255) : Module;
var aux : Module;
begin
  aux := NewModulePaginee;
  if aux <> NIL
    then
      begin
        {WritelnDansRapport('Dans MakeEmptyModule, aux <> NIL');}
        aux^.nomModule                 := name;
        aux^.symbolesInterface         := MakeEmptyStringSet;
        aux^.symbolesImplementation    := MakeEmptyStringSet;
        aux^.symbolesImplementationATR := MakeEmptyATR;
        aux^.symbolesDejaPrelinkes     := MakeEmptyStringSet;
      end
    else
      begin
        {WritelnDansRapport('Dans MakeEmptyModule, aux = NIL !! ');}
      end;

  MakeEmptyModule := aux;
end;


procedure AjouterModule(const name : String255; var nouveauModule : Module);
begin

  if (name = '') then
    WritelnDansRapport('WARNING !! name = '''' dans AjouterModule');

  nouveauModule := GetModule(name);

  if (nouveauModule = NIL) then // si le module n'est pas encore charge en memoire
    begin

      {WritelnDansRapport('Le module '+name+' n''est pas encore chargé en mémoire');}

      if (gTableDesModules.cardinal < kNombreMaxModules)
        then
          begin
            inc(gTableDesModules.cardinal);
            gTableDesModules.pointeurs[gTableDesModules.cardinal] := MakeEmptyModule(name);

            {WritelnNumDansRapport('gTableDesModules.cardinal = ',gTableDesModules.cardinal);}

            nouveauModule := gTableDesModules.pointeurs[gTableDesModules.cardinal];

            AddStringToSet(sysutils.LowerCase(name),gTableDesModules.cardinal,gModulesCharges);
          end
        else
          begin
            SysBeep(0);
            WritelnDansRapport('ERREUR !!! Pas assez de place dans la table des modules dans UnitCompilation');

            nouveauModule := NIL;
          end;
    end;
end;


function GetNameOfSymbole(whichSymbole : Symbole) : String255;
begin
  if (whichSymbole <> NIL)
    then GetNameOfSymbole := whichSymbole^.nom
    else GetNameOfSymbole := '';
end;

function GetDefinitionOfSymbole(whichSymbole : Symbole) : LongString;
var aux : LongString;
begin
  if (whichSymbole <> NIL)
    then GetDefinitionOfSymbole := whichSymbole^.definition
    else
      begin
        aux.debutLigne := '';
        aux.finLigne := '';
        aux.complete := true;
        GetDefinitionOfSymbole := aux;
      end;
end;


function GetModuleOfSymbole(whichSymbole : Symbole) : Module;
begin
  if (whichSymbole <> NIL)
    then GetModuleOfSymbole := whichSymbole^.dansQuelModule
    else GetModuleOfSymbole := NIL;
end;

function MakeEmptySymbole(const name : String255) : Symbole;
var aux : Symbole;
begin
  aux := NewSymbolePaginee;
  if aux <> NIL then
    begin
      aux^.nom := name;
      aux^.definition.debutLigne := '';
      aux^.definition.finLigne   := '';
      aux^.definition.complete   := true;
      aux^.dansQuelModule := NIL;
    end;
  MakeEmptySymbole := aux;
end;


procedure AjouterSymbole(const name : String255; const definition : LongString; var whichModule : Module; var nouveauSymbole : Symbole);
var aux : Symbole;
begin

  aux := GetSymbole(name);

  if (aux <> NIL)
    then
      begin
        {Le symbole était déjà en memoire... on fait quelques verifications de coherence}

        if GetNameOfModule(whichModule) <> GetNameOfModule(aux^.dansQuelModule) then
          begin
            WritelnDansRapport('ERREUR !!! le symbole '+name+' est défini dans deux modules différents : ' + GetNameOfModule(whichModule) + ' et '+GetNameOfModule(aux^.dansQuelModule));
          end;

        if (EnleveEspacesDeGauche(GetDefinitionOfSymbole(aux).debutLigne) <> EnleveEspacesDeGauche(definition.debutLigne)) or
           (GetDefinitionOfSymbole(aux).finLigne <> definition.finLigne) then
          begin
            WritelnDansRapport('ERREUR !!! le symbole '+name+' a deux définitions différentes');
            WriteDansRapport(GetDefinitionOfSymbole(aux).debutLigne);
            WritelnDansRapport(GetDefinitionOfSymbole(aux).finLigne);
            WriteDansRapport(definition.debutLigne);
            WritelnDansRapport(definition.finLigne);
          end;

        if GetNameOfSymbole(aux) <> name then
          begin
            WritelnDansRapport('ERREUR !!! le symbole '+name+' donne une collision de hachage');
          end;

        nouveauSymbole := aux;
      end
    else
      begin
        aux := MakeEmptySymbole(name);

        aux^.definition     := definition;
        aux^.dansQuelModule := whichModule;

        AddStringToSet(sysutils.LowerCase(name),POINTER_VALUE(aux),gSymbolesCharges);

        if (whichModule <> NIL)
          then AddStringToSet(name,POINTER_VALUE(aux),whichModule^.symbolesInterface)
          else WritelnDansRapport('ERREUR !!! whichModule = NIL dans AjouterSymbole !! ');

        nouveauSymbole := aux;
      end;

end;


function ModuleDoitEtreAccelere(const name : String255) : boolean;
begin
  ModuleDoitEtreAccelere := ((Pos('Unit',name) > 0)  or
                             (Pos('Cassio.p',name) > 0) or
                             (Pos('Main.p',name) > 0) or
                             (Pos('EdmondPatterns.p',name) > 0) or
                             (Pos('EdmondEvaluation.p',name) > 0) or
                             (Pos('ImportEdmond.p',name) > 0) or
                             (Pos('Zebra_to_Cassio.p',name) > 0) or
                             (Pos('SNEvents.p',name) > 0) or
                             (Pos('SNMenus.p',name) > 0) or
                             (Pos('MyFileSystemUtils.p',name) > 0) or
                             (Pos('MyUtils.p',name) > 0) or
                             (Pos('MyFonts.p',name) > 0) or
                             (Pos('MyStrings.p',name) > 0)) and

                             not(Pos('UnitJan', name) > 0) and

                            ( EndsWith(name,'.p') or EndsWith(name,'.pas'));


  (*
  ModuleDoitEtreAccelere := (name = 'UnitDialog.p');

  ModuleDoitEtreAccelere := (name = 'UnitModes.p');
  *)

end;


function ModuleDoitEtrePrelinke(const name : String255) : boolean;
begin

  ModuleDoitEtrePrelinke := ( EndsWith(name,'.p') or EndsWith(name,'.pas')) and


                           ((Pos('Unit', name) = 1) or
                            (Pos('MyAntialiasing', name) = 1) or
                            (Pos('MyAssertions', name) = 1) or
                            (Pos('MyFileSystemUtils', name) = 1) or
                            (Pos('MyEvents', name) = 1) or
                            (Pos('MyFileIDs', name) = 1) or
                            (Pos('MyFonts', name) = 1) or
                            (Pos('MyKeyMapUtils', name) = 1) or
                            (Pos('MyLists', name) = 1) or
                            (Pos('MyLowLevel', name) = 1) or
                            (Pos('MyMathUtils', name) = 1) or
                            (Pos('MyMemory', name) = 1) or
                            (Pos('MyStrings', name) = 1) or
                            (Pos('MyQuickDraw', name) = 1) or
                            (Pos('MyTMSTE', name) = 1) or
                            (Pos('MyUtils', name) = 1) or
                            (Pos('MyNavigationServices', name) = 1) or
                            (Pos('Cassio.p', name) = 1) or
                            (Pos('Zebra_to_Cassio', name) = 1) or
                            (Pos('EdmondPatterns', name) = 1) or
                            (Pos('EdmondEvaluation', name) = 1) or
                            (Pos('ImportEdmond', name) = 1) or
                            (Pos('SN', name) = 1)) and


                            not((Pos('UnitDef', name) > 0) or
                                (Pos('Type', name) > 0)  or
                                (Pos('UnitOth0', name) > 0)  or
                                (Pos('UnitJan', name) > 0) or
                                (Pos('UnitDebuggage', name) > 0) or
                                (Pos('UnitVar', name) > 0));

  (*

  ModuleDoitEtrePrelinke := (name = 'UnitRapport.p') or
                            (name = 'MyMathUtils.p') or
                            (name = 'UnitServicesMemoire.p') or
                            (name = 'MyStrings.p') or
                            (name = 'UnitPagesATR.p') or
                            (name = 'UnitCarbonisation.p');

   ModuleDoitEtrePrelinke := (name = 'UnitModes.p');
   *)

end;



function FileNameToModuleName(const filename : String255) : String255;
begin
  FileNameToModuleName := DeleteSubstringAfterThisChar('.',filename,false);
end;



function PartieDeModuleToString(whichPart : parties_de_modules) : String255;
begin
  case whichPart of
      kPrologue                   : PartieDeModuleToString := 'Prologue';
      kInterfacePrologue          : PartieDeModuleToString := 'InterfacePrologue';
      kInterfaceUses              : PartieDeModuleToString := 'InterfaceUses';
      kInterfaceDeclarations      : PartieDeModuleToString := 'InterfaceDeclarations';
      kImplementationPrologue     : PartieDeModuleToString := 'ImplementationPrologue';
      kImplementationUses         : PartieDeModuleToString := 'ImplementationUses';
      kImplementationDeclarations : PartieDeModuleToString := 'ImplementationDeclarations';
      kImplementationCode         : PartieDeModuleToString := 'ImplementationCode';
      kEpilogue                   : PartieDeModuleToString := 'Epilogue';
    otherwise                       PartieDeModuleToString := '???? (PartieDeModuleToString inconnue)';
  end; {case}
end;



function TrouverFichierDansSourcesDeCassio(const nomUnite : String255; var fic : basicfile) : boolean;
var err : OSErr;
    path : String255;
begin
  if nomUnite = '' then
    begin
      TrouverFichierDansSourcesDeCassio := false;
      exit;
    end;

  path := kPathSourcesDeCassio + DirectorySeparator + nomUnite + '.p';
  err := FileExists(path,0,fic);

  if (err <> NoErr) then
    begin
      path := kPathSourcesDeCassio + DirectorySeparator + nomUnite + '.pas';
      err := FileExists(path,0,fic);
    end;

  if (err <> NoErr) then
    begin
      path := kPathSourcesDeCassio + DirectorySeparator + 'PNL_Libraries' + DirectorySeparator + nomUnite + '.p';
      err := FileExists(path,0,fic);
    end;

  if (err <> NoErr) then
    begin
      path := kPathSourcesDeCassio + DirectorySeparator + 'PNL_Libraries' + DirectorySeparator + nomUnite + '.pas';
      err := FileExists(path,0,fic);
    end;

  TrouverFichierDansSourcesDeCassio := (err = NoErr);
end;


function EcrireSymboleExternalDansFichier(sym : Symbole; var fic : basicfile) : OSErr;
var symbolName : String255;
    err : OSErr;
    espaces : String255;
    len : SInt64;
begin
  err := -1;

  if (sym <> NIL) then
    begin

      err := Write(fic, sym^.definition.debutLigne);

      if (sym^.definition.finLigne <> '') and
         (err = NoErr) then
        err := Write(fic, sym^.definition.finLigne);

      if (err = NoErr) then
        begin


          len := LENGTH_OF_STRING(sym^.definition.debutLigne) + LENGTH_OF_STRING(sym^.definition.finLigne);

          espaces := ' ';
          len := len + 1;

          while (len < 180) or ((len mod 90) <> 0) do
            begin
              len := len + 1;
              espaces := espaces + ' ';
            end;

          symbolName := espaces + 'external;  {chr(10) = LF , add a UNIX linefeed !}

          err := Write(fic, symbolName);
        end;


    end;

  EcrireSymboleExternalDansFichier := err;
end;



function EcrireSymboleAttributeDansFichier(sym : Symbole; var fic : basicfile) : OSErr;
var symbolName : String255;
    err : OSErr;
    espaces : String255;
    len : SInt64;
begin
  err := -1;

  if (sym <> NIL) then
    begin

    //  EnleveEspacesDeGaucheSurPlace(sym^.definition.debutLigne);

      err := Write(fic, sym^.definition.debutLigne);

      if (sym^.definition.finLigne <> '') and
         (err = NoErr) then
        err := Write(fic, sym^.definition.finLigne);


      if (err = NoErr) then
        begin
          len := LENGTH_OF_STRING(sym^.definition.debutLigne) + LENGTH_OF_STRING(sym^.definition.finLigne);

          espaces := ' ';
          len := len + 1;

          while (len < 180) or ((len mod 90) <> 0) do
            begin
              len := len + 1;
              espaces := espaces + ' ';
            end;


          symbolName := espaces +'' + chr(10);  {chr(10) = LF , add a UNIX linefeed !}

          err := Write(fic, symbolName);
        end;

    end;

  EcrireSymboleAttributeDansFichier := err;
end;





function FabriquerNameOfPrelinkFile(const moduleName : String255) : String255;
var result : String255;
begin
  result := DeleteSubstringAfterThisChar('.',moduleName,false) + '.lk';
  result := ReplaceStringOnce(result, 'Unit' , '');
  FabriquerNameOfPrelinkFile := result;
end;

function FabriquerNameOfExternalDeclarationsFile(const moduleName : String255) : String255;
var result : String255;
begin
  result := DeleteSubstringAfterThisChar('.',moduleName,false) + '.ext';
  result := ReplaceStringOnce(result, 'Unit' , '');
  FabriquerNameOfExternalDeclarationsFile := result;
end;


function FabriquerNameOfDuplicateFile(const moduleName : String255) : String255;
begin
  FabriquerNameOfDuplicateFile := DeleteSubstringAfterThisChar('.',moduleName,false) + '.p';
end;

function GetPathOfTemporaryPrelinkFile(const moduleName : String255) : String255;
begin
  GetPathOfTemporaryPrelinkFile := kPathSourcesDeCassio + DirectorySeparator + 'prelink-temp' + DirectorySeparator + FabriquerNameOfPrelinkFile(moduleName);
end;


function GetPathOfPrelinkFile(const moduleName : String255) : String255;
begin
  GetPathOfPrelinkFile := kPathSourcesDeCassio + DirectorySeparator + 'prelink' + DirectorySeparator + FabriquerNameOfPrelinkFile(moduleName);
end;

function GetPathOfDeclarationsFile(const moduleName : String255) : String255;
begin
  GetPathOfDeclarationsFile := kPathSourcesDeCassio + DirectorySeparator + 'declarations' + DirectorySeparator + FabriquerNameOfExternalDeclarationsFile(moduleName);
end;


function GetPathOfDuplicateFile(const moduleName : String255) : String255;
begin
  GetPathOfDuplicateFile := kPathDuplicatesDesSourcesDeCassio + DirectorySeparator +  FabriquerNameOfDuplicateFile(moduleName);
end;


function CreerPrelinkFile(const moduleName : String255; var fic : basicfile) : OSErr;
var path : String255;
    err : OSErr;
begin

  path := GetPathOfPrelinkFile(moduleName);

  err := FileExists(path,0,fic);

  if (err <> NoErr) then
    err := CreateFile(path,0,fic);

  if (err = NoErr) then
    SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('CWIE'));

  if err <> NoErr then
    WritelnNumDansRapport('dans CreerPrelinkFile, '+moduleName + ' => ',err);

  CreerPrelinkFile := err;
end;


function CreerExternalDeclarationsFile(const moduleName : String255; var fic : basicfile) : OSErr;
var path : String255;
    err : OSErr;
begin

  path := GetPathOfDeclarationsFile(moduleName);

  err := FileExists(path,0,fic);

  if (err <> NoErr) then
    err := CreateFile(path,0,fic);

  if (err = NoErr) then
    SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('CWIE'));

  if err <> NoErr then
    WritelnNumDansRapport('dans CreerExternalDeclarationsFile, '+moduleName + ' => ',err);

  CreerExternalDeclarationsFile := err;
end;


function CreerDuplicateFile(const moduleName : String255; var fic : basicfile) : OSErr;
var path : String255;
    err : OSErr;
begin

  path := GetPathOfDuplicateFile(moduleName);

  err := FileExists(path,0,fic);

  if (err <> NoErr) then
    err := CreateFile(path,0,fic);

  if (err = NoErr) then
    SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('CWIE'));

  if err <> NoErr then
    WritelnNumDansRapport('dans CreerDuplicateFile, '+moduleName + ' => ',err);

  CreerDuplicateFile := err;
end;


function ParserDefinition(const ligne : LongString; whichModule : Module; var wasExternal : boolean) : Symbole;
var fun_or_proc : String255;
    nomSymbole : String255;
    reste : String255;
    oldParsingSet : SetOfChar;
    nouveauSymbole : Symbole;
    position : SInt64;
    definition : LongString;
begin


  ParserDefinition := NIL;
  wasExternal := false;

  position := Pos('//',ligne.debutLigne);
  if (position > 0) then
    if (Pos('function',ligne.debutLigne) > position)  or
       (Pos('FUNCTION',ligne.debutLigne) > position)  or
       (Pos('procedure',ligne.debutLigne) > position) or
       (Pos('PROCEDURE',ligne.debutLigne) > position) then
     begin
       ChangeFontColorDansRapport(RougeCmd);
       WritelnDansRapport(ligne.debutLigne);
       TextNormalDansRapport;
       exit;
     end;

  position := Pos('{',ligne.debutLigne);
  if (position > 0) then
    if (Pos('function',ligne.debutLigne) > position)  or
       (Pos('FUNCTION',ligne.debutLigne) > position)  or
       (Pos('procedure',ligne.debutLigne) > position) or
       (Pos('PROCEDURE',ligne.debutLigne) > position) then
     begin
       if (FindStringInLongString('}',ligne) <= 0) then
         begin
           ChangeFontColorDansRapport(RougeCmd);
           WritelnDansRapport(ligne.debutLigne);
           TextNormalDansRapport;
         end;
       exit;
     end;

  position := Pos('(*',ligne.debutLigne);
  if (position > 0) then
    if (Pos('function',ligne.debutLigne) > position)  or
       (Pos('FUNCTION',ligne.debutLigne) > position)  or
       (Pos('procedure',ligne.debutLigne) > position) or
       (Pos('PROCEDURE',ligne.debutLigne) > position) then
     begin
       if (FindStringInLongString('*)',ligne) <= 0) then
         begin
           ChangeFontColorDansRapport(RougeCmd);
           WritelnDansRapport(ligne.debutLigne);
           TextNormalDansRapport;
         end;
       exit;
     end;


  oldParsingSet := GetParserDelimiters;
  SetParserDelimiters([' ',tab,'(',';',':']);

  Parse2(ligne.debutLigne,fun_or_proc,nomSymbole,reste);

  SetParserDelimiters(oldParsingSet);



  position := 0;

  {on cherche ' EXTERNAL_NAME(blah) ' }

  position := FindStringInLongString(' EXT', ligne);
  if position > 0
    then
      begin
        definition := LeftOfLongString(ligne, position - 1);
        wasExternal := true;
      end
    else
      begin

        {on cherche ' ATTRIBUTE_NAME(blah) ' }

        position := FindStringInLongString(' ATT', ligne);
        if position > 0 then
          begin
            definition := LeftOfLongString(ligne, position - 1);
          end;

      end;

  if position <= 0
    then definition := ligne;

  EnleveEspacesDeDroiteSurPlace(definition.finLigne);
  if definition.finLigne = '' then EnleveEspacesDeDroiteSurPlace(definition.debutLigne);

  if (nomSymbole <> '') and ((definition.debutLigne <> '') or (definition.finLigne <> ''))
    then
      begin
        AjouterSymbole(nomSymbole,definition,whichModule,nouveauSymbole);
        ParserDefinition := nouveauSymbole;
      end
    else
      ParserDefinition := NIL;
end;


procedure AddDeclarationOfThisModuleToATR(const moduleName : String255; var myATR : ATR; var myStringSet : StringSet);
var fileName : String255;
    fic : basicfile;
    err : OSErr;
    ligne : LongString;
    theSymbole : Symbole;
    theModule : Module;
    wasExternal : boolean;
begin
  fileName := GetPathOfDeclarationsFile(moduleName);


  theModule := GetModule(moduleName);
  if (theModule = NIL) then
    begin
      WritelnDansRapport('ERREUR !! theModule = NIL dans AddDeclarationOfThisModuleToATR');
      exit;
    end;

  err := FileExists(fileName, 0, fic);
  if err <> NoErr then
    begin
      WritelnNumDansRapport('apres FileExists dans AddDeclarationOfThisModuleToATR, err = ',err);
      exit;
    end;

  err := OpenFile(fic);
  if err <> NoErr then
    begin
      WritelnNumDansRapport('apres OpenFile dans AddDeclarationOfThisModuleToATR, err = ',err);
      exit;
    end;

  while not(EndOfFile(fic,err)) do
    begin

      err := Readln(fic,ligne);

      theSymbole := ParserDefinition(ligne,theModule,wasExternal);

      if (theSymbole = NIL) then
        begin
          WritelnDansRapport('ERREUR !! theSymbole = NIL dans AddDeclarationOfThisModuleToATR');
          leave;
        end;

      InsererDansATR(myATR,theSymbole^.nom);

      AddStringToSet(theSymbole^.nom,SInt64(theSymbole),myStringSet);

    end;

  err := CloseFile(fic);

end;



procedure VerifierLongueurDeLaLigneDansLesSources(var ligne : LongString; var lectureAddr : SInt64);
var lecture : LectureModulePtr;
begin

  lecture := LectureModulePtr(lectureAddr);

  with lecture^ do
    begin

      if not(ligne.complete) then
        begin
          inc(nombreErreurs);
          inc(nombreLignesTropLongues);

          WriteDansRapport(ligne.debutLigne);
          WritelnDansRapport(ligne.finLigne);

        end;
    end;
end;


function NombreDeModulesDevantEtrePrelinkeDansClause(const usesClause : ListeDeModules) : SInt64;
var compteur,k : SInt64;
begin
  compteur := 0;
  for k := 1 to usesClause.cardinal do
    if ModuleDoitEtrePrelinke(GetNameOfModule(usesClause.pointeurs[k]) + '.p') then
      inc(compteur);
  NombreDeModulesDevantEtrePrelinkeDansClause := compteur;
end;


function UsesClauseADesModulesDevantEtrePrelinke(const usesClause : ListeDeModules) : boolean;
var k : SInt64;
begin
  UsesClauseADesModulesDevantEtrePrelinke := false;

  for k := 1 to usesClause.cardinal do
    if ModuleDoitEtrePrelinke(GetNameOfModule(usesClause.pointeurs[k]) + '.p') then
      begin
        UsesClauseADesModulesDevantEtrePrelinke := true;
        exit;
      end;
end;


function EstUnModuleDeDefinition(nomModule : String255) : boolean;
begin
  EstUnModuleDeDefinition := false;

  nomModule := sysutils.LowerCase(nomModule);

  if (nomModule = sysutils.LowerCase('UnitVarGlobalesFinale')) or
     (nomModule = sysutils.LowerCase('UnitDefPackedThorGame')) or
     (nomModule = sysutils.LowerCase('UnitDefCompilation')) or
     (nomModule = sysutils.LowerCase('UnitDefCouleurs')) or
     (nomModule = sysutils.LowerCase('UnitDefDialog')) or
     (nomModule = sysutils.LowerCase('UnitDefEvaluation')) or
     (nomModule = sysutils.LowerCase('UnitDefEvents')) or
     (nomModule = sysutils.LowerCase('UnitDefFormatsFichiers')) or
     (nomModule = sysutils.LowerCase('UnitDefGeneralSort')) or
     (nomModule = sysutils.LowerCase('UnitDefGraphe')) or
     (nomModule = sysutils.LowerCase('UnitDefHash')) or
     (nomModule = sysutils.LowerCase('UnitDefListeCasesVides')) or
     (nomModule = sysutils.LowerCase('UnitDefMenus')) or
     (nomModule = sysutils.LowerCase('UnitDefNouveauFormat')) or
     (nomModule = sysutils.LowerCase('UnitDefParallelisme')) or
     (nomModule = sysutils.LowerCase('UnitDefSmartGameBoard')) or
     (nomModule = sysutils.LowerCase('UnitDefTranscript')) or
     (nomModule = sysutils.LowerCase('Zebra_types')) or
     (nomModule = sysutils.LowerCase('EdmondTypes')) or
     (nomModule = sysutils.LowerCase('UnitOth0')) or
     (nomModule = sysutils.LowerCase('MacTypes')) or
     (nomModule = sysutils.LowerCase('StringTypes')) or
     (nomModule = sysutils.LowerCase('UnitDefSet')) or
     (nomModule = sysutils.LowerCase('UnitBitboardTypes')) or
     (nomModule = sysutils.LowerCase('MyTypes')) or
     (nomModule = sysutils.LowerCase('UnitDefSet')) or
     (nomModule = sysutils.LowerCase('GPCStrings')) or
     (nomModule = sysutils.LowerCase('UnitDefABR')) or
     (nomModule = sysutils.LowerCase('UnitDefAlgebreLineaire')) or
     (nomModule = sysutils.LowerCase('UnitDefABR')) or
     (nomModule = sysutils.LowerCase('UnitDefCompilation')) or
     (nomModule = sysutils.LowerCase('UnitDefFichiersTEXT')) or
     (nomModule = sysutils.LowerCase('UnitDefOthelloGeneralise')) or
     (nomModule = sysutils.LowerCase('UnitDefGameTree')) or
     (nomModule = sysutils.LowerCase('UnitDefPositionEtTrait')) or
     (nomModule = sysutils.LowerCase('UnitDefFichierAbstrait'))
     then
       EstUnModuleDeDefinition := true;

end;

function UsesClauseContientDesDefinitionsDeDassio(const usesClause : ListeDeModules) : boolean;
var k : SInt64;
    nom : String255;
begin
  UsesClauseContientDesDefinitionsDeDassio := false;

  for k := 1 to usesClause.cardinal do
    begin
      nom := GetNameOfModule(usesClause.pointeurs[k]);

      if EstUnModuleDeDefinition(nom) then
        begin
          UsesClauseContientDesDefinitionsDeDassio := true;
          exit;
        end;
    end;
end;





procedure VerifierCetteLigneDansLesSources(var ligne : LongString; var theFic : basicfile; var lectureAddr : SInt64);
var lecture : LectureModulePtr;
    err : OSErr;
    doitDupliquerLigneCourante : boolean;

  procedure AjouterLesFonctionsObligatoires(listeDeFonctions : String255);
  var s,reste : String255;
      theSymbole : Symbole;
      symboleAddr : SInt64;
      aux : SInt64;
      err : OSErr;
  begin
    with lecture^ do
      begin
        if (action = K_COMPILER_IMPLEMENTATION) then
          begin

            reste := listeDeFonctions;
            while (reste <> '') do
              begin
                Parse(reste,s,reste);

                (* gérer les macros *)
                if (s = 'FIND_IN_BITBOARD_HASH_AND_GET_LOCK') then s := 'BitboardHashGet';
                if (s = 'SET_LENGTH_OF_STRING') then s := 'MySetStringLength';
                if (s = 'MyStringWidth') then s := 'StringWidthPourGNUPascal';
                if (s = 'MyDrawString') then s := 'DrawStringPourGNUPascal';

                if MemberOfStringSet(s,symboleAddr,whichModule^.symbolesImplementation) and
                  not(MemberOfStringSet(s,aux,whichModule^.symbolesDejaPrelinkes)) then
                  begin
                    theSymbole := Symbole(symboleAddr);

                    {WritelnDansRapport('@'+s);}
                    ShareTimeWithOtherProcesses(0);

                    if doitEtreAccelere and (action in [K_COMPILER_IMPLEMENTATION]) then
                      begin
                        err := EcrireSymboleExternalDansFichier(theSymbole,fichierPrelink);
                        if err <> NoErr then
                          begin
                            WriteNumDansRapport('ERREUR !! dans AjouterLesFonctionsObligatoires, err = ',err);
                            if (theSymbole <> NIL)
                              then WritelnDansRapport(' (theSymbole = ' + theSymbole^.nom + ')')
                              else WritelnDansRapport(' (theSymbole = NIL)');
                          end;
                      end;

                    AddStringToSet(s,symboleAddr,whichModule^.symbolesDejaPrelinkes);
                  end;

              end;
            end;
        end;
  end;


  procedure ParserLigneDePascal(const ligne : String255);
  var s,reste : String255;
      oldParsingSet : SetOfChar;
      theSymbole : Symbole;
      symboleAddr : SInt64;
      aux : SInt64;
      err : OSErr;
  begin
    with lecture^ do
      begin
        if (action = K_COMPILER_IMPLEMENTATION) then
          begin


            oldParsingSet := GetParserDelimiters;
            SetParserDelimiters([' ',tab,'.',',',';',':','}','{',')','(','-','+','$','@','=','>','<','|','&','[',']','*','/','''','"','^']);


            if not(fonctionsObligatoiresDejaEcrites) then
              begin

                // Une petite liste de fonctions que l'on veut avoir disponibles dans tous les sources

                reste := 'Min Max AttendFrappeClavier WritelnDansRapport WriteDansRapport WritelnNumDansRapport';
                AjouterLesFonctionsObligatoires(reste);

                reste := 'WriteNumDansRapport WritelnStringAndBoolDansRapport WriteStringAndBoolDansRapport';
                AjouterLesFonctionsObligatoires(reste);

                reste := 'WritelnStringAndBooleenDansRapport WriteStringAndBooleenDansRapport WritelnStringAndBooleanDansRapport WriteStringAndBooleanDansRapport';
                AjouterLesFonctionsObligatoires(reste);

                reste := 'WritelnDansRapportThreadSafe';
                AjouterLesFonctionsObligatoires(reste);

                fonctionsObligatoiresDejaEcrites := true;
              end;

            // Et maintenant on parse la vraie ligne du fichier
            reste := ligne;
            while (reste <> '') do
              begin
                Parse(reste,s,reste);

                (* gérer les macros *)
                if (s = 'FIND_IN_BITBOARD_HASH_AND_GET_LOCK') then s := 'BitboardHashGet';
                if (s = 'SET_LENGTH_OF_STRING') then s := 'MySetStringLength';
                if (s = 'MyStringWidth') then s := 'StringWidthPourGNUPascal';
                if (s = 'MyDrawString') then s := 'DrawStringPourGNUPascal';

                if MemberOfStringSet(s,symboleAddr,whichModule^.symbolesImplementation) and
                   not(MemberOfStringSet(s,aux,whichModule^.symbolesDejaPrelinkes)) then
                  begin
                    theSymbole := Symbole(symboleAddr);

                    {WritelnDansRapport('@'+s);}
                    ShareTimeWithOtherProcesses(0);

                    if doitEtreAccelere and (action in [K_COMPILER_IMPLEMENTATION]) then
                      begin
                        err := EcrireSymboleExternalDansFichier(theSymbole,fichierPrelink);
                        if (err <> 0) then
                          begin
                            WriteNumDansRapport('ERREUR !! dans ParserLigneDePascal, err = ',err);
                            if (theSymbole <> NIL)
                              then WritelnDansRapport(' (theSymbole = ' + theSymbole^.nom + ')')
                              else WritelnDansRapport(' (theSymbole = NIL)');
                          end;
                      end;

                    AddStringToSet(s,symboleAddr,whichModule^.symbolesDejaPrelinkes);
                  end;

              end;

            SetParserDelimiters(oldParsingSet);

          end;
      end;
  end;

  procedure ReduireInterfaceUsesPourDefinitionsDeCassio(var ligne : LongString);
  var s,reste : String255;
      result : String255;
      {nomModule : String255;}
      i : SInt64;
  begin
    with lecture^ do
      begin
        if (ligne.finLigne = '') and not(EstUnModuleDeDefinition(GetNameOfModule(whichModule))) then
          begin
            result := '';

            reste := ligne.debutLigne;

            WritelnDansRapport('avant réduction, reste = '+reste);

            for i := 1 to 30 do
              reste := ReplaceStringOnce(reste, ',', ' • ');

            reste := ReplaceStringAll(reste,'•',',');

            reste := ReplaceStringOnce(reste, ';' , ' ;');

            WritelnDansRapport('après réduction, reste = '+reste);


            while (reste <> '') do
              begin
                Parse(reste,s,reste);

                if EstUnModuleDeDefinition(s)
                  then
                    begin
                      if not(unitDefCassioDejaEcrite) then
                        begin
                          result := result + ' UnitDefCassio';
                          unitDefCassioDejaEcrite := true;
                        end;
                    end
                  else
                    begin
                      result := result + ' ' + s;
                    end;



              end;

            for i := 1 to 30 do
              result := ReplaceStringOnce(result, ', ,' , ',');
            for i := 1 to 30 do
              result := ReplaceStringOnce(result, ', ;' , ';');
            result := ReplaceStringOnce(result, ' ;' , ';');

            if (Pos('USES', result) <= 0) and (Pos('uses', result) <= 0)
              then ligne.debutLigne := '    '+result
              else ligne.debutLigne := result;
          end;
      end;
  end;


  procedure TraiterUseClause(var liste : ListeDeModules);
  var oldParsingSet : SetOfChar;
      s, reste : String255;
      aModule : Module;
  begin
    with lecture^ do
      if (ligne.debutLigne <> '') then
        begin
          {WritelnDansRapport('ligne.debutLigne = '+ligne.debutLigne);}

          if (FindStringInLongString('BEGIN_USE_CLAUSE',ligne) <= 0) then
            begin
              oldParsingSet := GetParserDelimiters;
              SetParserDelimiters([' ',tab,',',';']);

              reste := ligne.debutLigne;
              repeat
                Parse(reste,s,reste);

                if (s <> 'USES') and (s <> 'uses') and (s <> '') then
                  begin

                    {WritelnDansRapport('J''ajoute le module '+s+ ' à la clause uses ');}

                    (*
                    if GetModule(s) = NIL then
                      WritelnDansRapport(s);
                    *)

                    AjouterModule(s,aModule);


                    inc(liste.cardinal);
                    liste.pointeurs[liste.cardinal] := aModule;

                  end;

              until (reste = '');

              SetParserDelimiters(oldParsingSet);
            end;
        end;
  end;


  procedure TraiteInterfaceUses;
  begin
    // ReduireInterfaceUsesPourDefinitionsDeCassio(ligne);
    TraiterUseClause(lecture^.modulesInterface);
  end;


  procedure EcritModulesNormaux(var liste : ListeDeModules; var nombreModulesEcrit : SInt64);
  var k : SInt64;
      moduleName, fileName : String255;
  begin
    with lecture^ do
      begin
        for k := 1 to liste.cardinal do
          begin
            moduleName := GetNameOfModule(liste.pointeurs[k]);
            fileName := moduleName + '.p';


            if EstUnModuleDeDefinition(moduleName) and
               not(EstUnModuleDeDefinition(GetNameOfModule(whichModule)))
              then
                begin
                  if not(unitDefCassioDejaEcrite) then
                    begin
                      if (nombreModulesEcrit > 0) then err := Write(duplication,', ');

                      err := Write(duplication,'UnitDefCassio');
                      unitDefCassioDejaEcrite := true;

                      if ((nombreModulesEcrit + 1) mod 8) = 0 then
                           err := Write(duplication,chr(10)+'    ');
                      inc(nombreModulesEcrit);
                    end;
                end
              else

                if not(ModuleDoitEtrePrelinke(fileName)) then
                  begin

                    if (nombreModulesEcrit > 0) then err := Write(duplication,', ');
                    ChangeFontColorDansRapport(VertCmd);

                    err := Write(duplication,moduleName {+ '['+IntToStr(k)+']'});

                    if ((nombreModulesEcrit + 1) mod 8) = 0 then
                       err := Write(duplication,chr(10)+'    ');
                    inc(nombreModulesEcrit);
                  end;
          end;
      end;
  end;



  procedure EcritModulesPrelinkes(var liste : ListeDeModules; var nombreModulesEcrit : SInt64);
  var k : SInt64;
      moduleName, fileName : String255;
  begin
    with lecture^ do
      begin
        for k := 1 to liste.cardinal do
          begin
            moduleName := GetNameOfModule(liste.pointeurs[k]);
            fileName := moduleName + '.p';
            if ModuleDoitEtrePrelinke(fileName) then
              begin
                AddDeclarationOfThisModuleToATR(moduleName, whichModule^.symbolesImplementationATR, whichModule^.symbolesImplementation);
                if (nombreModulesEcrit > 0) then err := Write(duplication,', ');
                ChangeFontColorDansRapport(RougeCmd);
                err := Write(duplication,moduleName);
                if ((nombreModulesEcrit + 1) mod 8) = 0 then
                   err := Write(duplication,chr(10)+'    ');
                inc(nombreModulesEcrit);
              end;
          end;
      end;
  end;


  procedure TraiteFinInterfaceUses;
  var nombreModulesEcrit : SInt64;
      k : SInt64;
      filename : String255;
      moduleName : String255;
      defCassio : boolean;
  begin
    with lecture^ do
      begin
        if (modulesInterface.cardinal > 0) and not(clauseUsesInterfaceDejaEcrite) and
           (UsesClauseADesModulesDevantEtrePrelinke(modulesInterface) {or UsesClauseContientDesDefinitionsDeDassio(modulesInterface)}) then
          begin
            nombreModulesEcrit := 0;

            defCassio := false;

            ChangeFontFaceDansRapport(bold);

            WriteDansRapport('USES ');

            for k := 1 to modulesInterface.cardinal do
              begin
                moduleName := GetNameOfModule(modulesInterface.pointeurs[k]);
                if EstUnModuleDeDefinition(moduleName)
                  then
                    begin
                      if not(defCassio) then
                        begin
                          if (nombreModulesEcrit > 0) then WriteDansRapport(', ');

                          ChangeFontColorDansRapport(VertCmd);

                          WriteDansRapport('UnitDefCassio');

                          defCassio := true;

                          inc(nombreModulesEcrit);
                        end;
                    end;
              end;


            for k := 1 to modulesInterface.cardinal do
              begin
                moduleName := GetNameOfModule(modulesInterface.pointeurs[k]);
                fileName := moduleName + '.p';
                if not(ModuleDoitEtrePrelinke(fileName)) and
                   not(EstUnModuleDeDefinition(moduleName)) then
                  begin


                    if ((Pos('{$ENDC',moduleName) <= 0) or
                        (Pos('{$IFC',moduleName) <= 0)  or
                        (Pos('USE_',moduleName) <= 0)) then
                      begin
                        if (nombreModulesEcrit > 0) then WriteDansRapport(', ');

                        ChangeFontColorDansRapport(VertCmd);
                        WriteDansRapport(GetNameOfModule(modulesInterface.pointeurs[k]));
                        inc(nombreModulesEcrit);
                      end;
                  end;
              end;



            for k := 1 to modulesInterface.cardinal do
              begin
                moduleName := GetNameOfModule(modulesInterface.pointeurs[k]);
                fileName := moduleName + '.p';
                if ModuleDoitEtrePrelinke(fileName) and
                   not(EstUnModuleDeDefinition(moduleName)) then
                  begin
                    if (nombreModulesEcrit > 0) then WriteDansRapport(', ');

                    ChangeFontColorDansRapport(RougeCmd);
                    WriteDansRapport(GetNameOfModule(modulesInterface.pointeurs[k]));
                    inc(nombreModulesEcrit);
                  end;
              end;

            WriteDansRapport(' ');
            TextNormalDansRapport;
            WritelnDansRapport(';');

            clauseUsesInterfaceDejaEcrite := true;
          end;
      end;
  end;


  procedure TraiteFinImplementationUses;
  var nombreModulesEcrit : SInt64;
      {filename : String255;
      moduleName : String255;}
      err : OSErr;
  begin
    with lecture^ do
      begin
        if doitEtreAccelere and
           not(clauseUsesImplementationDejaEcrite)
          then
            begin
              nombreModulesEcrit := 0;

              if UsesClauseADesModulesDevantEtrePrelinke(modulesImplementation)
                then
                  begin
                    if flag_USE_PRELINK
                      then err := Write(duplication,'{$DEFINEC USE_PRELINK ' + 'true}' + chr(10)+chr(10))
                      else err := Write(duplication,'{$DEFINEC USE_PRELINK ' + 'false}' + chr(10)+chr(10));
                    if NombreDeModulesDevantEtrePrelinkeDansClause(modulesImplementation) = modulesImplementation.cardinal
                      then
                        begin  // il n'a a que des modules prelinkes
                          err := Write(duplication,chr(10)+'{$IFC NOT(USE_PRELINK)}' + chr(10));
                          err := Write(duplication,'USES' + chr(10)+'    ');
                          EcritModulesPrelinkes(modulesImplementation,nombreModulesEcrit);
                          err := Write(duplication,' ;'+chr(10));
                          err := Write(duplication,'{$ELSEC}' + chr(10)+'    ');
                          err := Write(duplication,'{$I prelink/'+FabriquerNameOfPrelinkFile(GetNameOfModule(whichModule))+'}'+chr(10));
                          err := Write(duplication,'{$ENDC}' + chr(10)+chr(10));
                        end
                      else
                        begin  // il y a a la fois des modules normaux et des modules prelinkes
                          ChangeFontFaceDansRapport(bold);
                          err := Write(duplication,'USES' + chr(10)+'    ');
                          EcritModulesNormaux(modulesImplementation,nombreModulesEcrit);
                          if nombreModulesEcrit = 0 then WritelnDansRapport('ERREUR !! nombreModulesEcrit = 0');
                          err := Write(duplication,chr(10)+'{$IFC NOT(USE_PRELINK)}' + chr(10)+'    ');
                          EcritModulesPrelinkes(modulesImplementation,nombreModulesEcrit);
                          err := Write(duplication,' ;'+chr(10));
                          err := Write(duplication,'{$ELSEC}' + chr(10)+'    ;'+chr(10)+'    ');
                          err := Write(duplication,'{$I prelink/'+FabriquerNameOfPrelinkFile(GetNameOfModule(whichModule))+'}'+chr(10));
                          err := Write(duplication,'{$ENDC}' + chr(10)+chr(10));
                          TextNormalDansRapport;
                          WriteNumDansRapport('(',whichModule^.symbolesImplementation.cardinal);
                          WritelnDansRapport(')');
                        end;
                  end
                else
                  begin
                    if (modulesImplementation.cardinal <= 0)
                      then
                        begin // il n'y aucun module dans la clause USES : elle est vide !
                        end
                      else
                        begin // il n'y a que des modules normaux
                          ChangeFontFaceDansRapport(bold);
                          err := Write(duplication,'USES' + chr(10)+'    ');
                          EcritModulesNormaux(modulesImplementation,nombreModulesEcrit);
                          err := Write(duplication,';' + chr(10)+'    ');
                        end;
                  end;

              err := Write(duplication,chr(10)+'{END_USE_CLAUSE}'+chr(10)+chr(10));

              clauseUsesImplementationDejaEcrite := true;
            end;
      end;
  end;


  procedure TraiteDefinitionSymboleDansInterface;
  var theSymbole : Symbole;
      err : OSErr;
      s : String255;
      compteur,i : SInt64;
      wasExternal : boolean;
  begin
    with lecture^ do
      begin
        if (action in [K_COMPILER_INTERFACE]) then
          begin

            wasExternal := false;  // les symboles externes dans les interfaces sont rares, en general c'est de l'import de fonctions C

            theSymbole := ParserDefinition(ligne,whichModule,wasExternal);


            {WritelnDansRapport(ligne.debutLigne);}

            if (theSymbole <> NIL) then
              begin
                with theSymbole^ do
                  if (FindStringInLongString('(',definition) > 0) and (FindStringInLongString(')',definition) <= 0) then
                    begin

                      // La definition s'étend sur plusieurs lignes => traitement special

                      (*
                      ChangeFontFaceDansRapport(bold);
                      ChangeFontColorDansRapport(VertCmd);
                      *)

                      for i := 1 to 100 do
                          definition.debutLigne := ReplaceStringOnce(definition.debutLigne, '    ' , ' ');
                      for i := 1 to 100 do
                          definition.debutLigne := ReplaceStringOnce(definition.debutLigne, '  ' , ' ');

                      for i := 1 to 100 do
                          definition.debutLigne := ReplaceStringOnce(definition.debutLigne, CharToString(tab),' ');
                      for i := 1 to 100 do
                          definition.debutLigne := ReplaceStringOnce(definition.debutLigne, CharToString(tab),' ');

                      compteur := 0;

                      repeat

                        err := Readln(theFic,s);

                        if Pos(' ATT',s) > 0 then s := TPCopy(s,1,Pos(' ATT',s));
                        if Pos(' EXT',s) > 0 then
                          begin
                            s := TPCopy(s,1,Pos(' EXT',s));
                            wasExternal := true;
                          end;


                        s := EnleveEspacesDeGauche(s);
                        s := EnleveEspacesDeDroite(s);

                        for i := 1 to 100 do
                          s := ReplaceStringOnce(s, '    ' , ' ');
                        for i := 1 to 100 do
                          s := ReplaceStringOnce(s, '  ' , ' ');

                        for i := 1 to 100 do
                          s := ReplaceStringOnce(s, CharToString(tab),' ');
                        for i := 1 to 100 do
                          s := ReplaceStringOnce(s, CharToString(tab),' ');

                        AppendToLongString(definition,' '+s);
                        inc(compteur);

                      until (FindStringInLongString(')',definition) > 0) or (compteur >= 15);

                      (*
                      WriteDansRapport(definition.debutLigne);
                      WritelnDansRapport(definition.finLigne);

                      TextNormalDansRapport;
                      *)

                    end;  {with theSymbole}

                if doitEtrePrelinke and (action in [K_COMPILER_INTERFACE]) then
                  begin
                    err := EcrireSymboleExternalDansFichier(theSymbole,fichierExternalDeclarations);
                    if err <> NoErr then
                      WritelnNumDansRapport('ERREUR !! dans TraiteDefinitionSymboleDansInterface, err = ',err);

                    if wasExternal
                      then err := EcrireSymboleExternalDansFichier(theSymbole,duplication)
                      else err := EcrireSymboleAttributeDansFichier(theSymbole,duplication);
                    if err = NoErr
                      then doitDupliquerLigneCourante := false
                      else WritelnNumDansRapport('ERREUR !! dans TraiteDefinitionSymboleDansInterface{2}, err = ',err);

                  end;
             end;
         end;
      end;  {with lecture}
  end;

  procedure TraiteInterfaceDeclaration;
  begin
    with lecture^ do
      begin

        (*
        WriteDansRapport(ligne.debutLigne);
        WritelnDansRapport(ligne.finLigne);
        *)

        if doitEtrePrelinke and
          (((FindStringInLongString('VAR ',ligne) > 0) and (Pos('VAR ',ligne.debutLigne) > 0) and (Pos('VAR ',ligne.debutLigne) <= 10)) or
           ((FindStringInLongString('var ',ligne) > 0) and (Pos('var ',ligne.debutLigne) > 0) and (Pos('var ',ligne.debutLigne) <= 10)) or
           ((FindStringInLongString('TYPE ',ligne) > 0) and (Pos('TYPE ',ligne.debutLigne) > 0) and (Pos('TYPE ',ligne.debutLigne) <= 10)) or
           ((FindStringInLongString('type ',ligne) > 0) and (Pos('type ',ligne.debutLigne) > 0) and (Pos('type ',ligne.debutLigne) <= 10)) or
           ((FindStringInLongString('CONST ',ligne) > 0) and (Pos('CONST ',ligne.debutLigne) > 0) and (Pos('CONST ',ligne.debutLigne) <= 10)) or
           ((FindStringInLongString('const ',ligne) > 0) and (Pos('const ',ligne.debutLigne) > 0) and (Pos('const ',ligne.debutLigne) <= 10)))
           then
             begin
               inc(nombreErreurs);
               inc(nombreDeclarationsIndues);

               WriteDansRapport(ligne.debutLigne);
               WritelnDansRapport(ligne.finLigne);
             end;


        if doitEtrePrelinke and
           ((FindStringInLongString('function ',ligne) > 0) or
            (FindStringInLongString('procedure ',ligne) > 0) or
            (FindStringInLongString('FUNCTION ',ligne) > 0) or
            (FindStringInLongString('PROCEDURE ',ligne) > 0))
           then
             begin
               TraiteDefinitionSymboleDansInterface;
             end;
      end;
  end;

  procedure TraiteImplementationUses;
  begin
    if lecture^.doitEtreAccelere
      then doitDupliquerLigneCourante := false;


    if (FindStringInLongString('{$DEFINEC USE_PRELINK',ligne) > 0)
      then lecture^.flag_USE_PRELINK := (FindStringInLongString('true',ligne) > 0);

    if (FindStringInLongString('BEGIN_USE_CLAUSE',ligne) > 0) or
       (FindStringInLongString('{$DEFINEC USE_PRELINK',ligne) > 0) or
       (FindStringInLongString('{$IFC NOT(USE_PRELINK)',ligne) > 0) or
       (FindStringInLongString('{$ELSEC}',ligne) > 0) or
       (FindStringInLongString('{$I prelink/',ligne) > 0) or
       (FindStringInLongString('{$ENDC}',ligne) > 0) or
       (FindStringInLongString('END_USE_CLAUSE',ligne) > 0)
      then exit;


    TraiterUseClause(lecture^.modulesImplementation);
  end;

  procedure TraiteImplementationDeclaration;
  begin
  end;

  procedure CheckPassageInterfacePrologue;
  begin
    if (lecture^.enCoursDeLecture = kInterfacePrologue) then exit;

    if ((FindStringInLongString('INTERFACE ',ligne) > 0) and (FindStringInLongString('INTERFACE ',ligne) < 5)) or
       ((FindStringInLongString('interface ',ligne) > 0) and (FindStringInLongString('interface ',ligne) < 5)) then
       begin
         lecture^.enCoursDeLecture := kInterfacePrologue;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kInterfacePrologue');
       end;
  end;

  procedure CheckPassageInterfaceDeclarations;
  begin
    if (lecture^.enCoursDeLecture = kInterfaceDeclarations) then exit;

    if (FindStringInLongString(';',ligne) > 0) or
       (FindStringInLongString('VAR ',ligne) > 0) or
       (FindStringInLongString('var ',ligne) > 0) or
       (FindStringInLongString('TYPE ',ligne) > 0) or
       (FindStringInLongString('type ',ligne) > 0) or
       (FindStringInLongString('CONST ',ligne) > 0) or
       (FindStringInLongString('const ',ligne) > 0) or
       (FindStringInLongString('procedure ',ligne) > 0) or
       (FindStringInLongString('function ',ligne) > 0) then
       begin
         lecture^.enCoursDeLecture := kInterfaceDeclarations;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kInterfaceDeclarations');

         TraiteFinInterfaceUses;
         TraiteInterfaceDeclaration;
       end;
  end;

  procedure CheckPassageInterfaceUses;
  begin
    if (lecture^.enCoursDeLecture = kInterfaceUses) then exit;

    if (FindStringInLongString('USES ',ligne) > 0) or
       (FindStringInLongString('uses ',ligne) > 0) then
       begin
         lecture^.enCoursDeLecture := kInterfaceUses;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kInterfaceUses');
         TraiteInterfaceUses;
         CheckPassageInterfaceDeclarations;
       end;
  end;



  procedure CheckPassageImplementationPrologue;
  var err : OSErr;
  begin
    if (lecture^.enCoursDeLecture = kImplementationPrologue) then exit;

    if ((FindStringInLongString('IMPLEMENTATION ',ligne) > 0) and (FindStringInLongString('IMPLEMENTATION ',ligne) < 5)) or
       ((FindStringInLongString('implementation ',ligne) > 0) and (FindStringInLongString('implementation ',ligne) < 5)) then
       begin
         {WritelnDansRapport(ligne.debutLigne);}
         lecture^.enCoursDeLecture := kImplementationPrologue;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kImplementationPrologue');


         if lecture^.action = K_COMPILER_INTERFACE then
           err := SetFilePositionAtEnd(theFic);

       end;
  end;

  procedure CheckPassageImplementationDeclaration;
  begin
    if (lecture^.enCoursDeLecture = kImplementationDeclarations) then exit;

    if lecture^.got_BEGIN_USE_CLAUSE
      then
        begin
          if (FindStringInLongString('END_USE_CLAUSE',ligne) > 0) or
             (FindStringInLongString('VAR ',ligne) > 0) or
             (FindStringInLongString('var ',ligne) > 0) or
             (FindStringInLongString('TYPE ',ligne) > 0) or
             (FindStringInLongString('type ',ligne) > 0) or
             (FindStringInLongString('CONST ',ligne) > 0) or
             (FindStringInLongString('const ',ligne) > 0) or
             (FindStringInLongString('procedure ',ligne) > 0) or
             (FindStringInLongString('function ',ligne) > 0)  then
             begin
               lecture^.enCoursDeLecture := kImplementationDeclarations;
               if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kImplementationDeclarations');

               TraiteFinImplementationUses;
               TraiteImplementationDeclaration;
             end;
        end
      else
        begin
          if (FindStringInLongString(';',ligne) > 0) then
             begin
               lecture^.enCoursDeLecture := kImplementationDeclarations;
               if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kImplementationDeclarations');

               TraiteFinImplementationUses;
               TraiteImplementationDeclaration;
             end;
        end;
  end;

  procedure CheckPassageImplementationUses;
  begin
    if (lecture^.enCoursDeLecture = kImplementationUses) then exit;

    with lecture^ do
      begin
        if ((FindStringInLongString('BEGIN_USE_CLAUSE',ligne) > 0) and doitEtreAccelere) or
           (FindStringInLongString('USES ',ligne) > 0) or
           (FindStringInLongString('uses ',ligne) > 0) then
           begin
             lecture^.enCoursDeLecture := kImplementationUses;
             if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kImplementationUses');

             if ((FindStringInLongString('BEGIN_USE_CLAUSE',ligne) > 0) and doitEtreAccelere)
                then got_BEGIN_USE_CLAUSE := true;

             TraiteImplementationUses;
             CheckPassageImplementationDeclaration;
           end;
      end;
  end;



  procedure CheckPassageImplementationCode;
  begin
    if (lecture^.enCoursDeLecture = kImplementationCode) then exit;

    if (FindStringInLongString('VAR ',ligne) > 0) or
       (FindStringInLongString('var ',ligne) > 0) or
       (FindStringInLongString('TYPE ',ligne) > 0) or
       (FindStringInLongString('type ',ligne) > 0) or
       (FindStringInLongString('CONST ',ligne) > 0) or
       (FindStringInLongString('const ',ligne) > 0) or
       ((FindStringInLongString('procedure ',ligne) > 0) and (FindStringInLongString('EXTERNAL_NAME',ligne) <= 0)) or
       ((FindStringInLongString('function ',ligne) > 0) and (FindStringInLongString('EXTERNAL_NAME',ligne) <= 0))    then
       begin
         lecture^.enCoursDeLecture := kImplementationCode;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kImplementationCode');

         ParserLigneDePascal(ligne.debutLigne);
       end;
  end;



  procedure CheckEndOfModule;
  begin
    if (lecture^.enCoursDeLecture = kEpilogue) then exit;

    if LongStringBeginsWith('END.',ligne) or
       LongStringBeginsWith('end.',ligne) then
       begin
         lecture^.enCoursDeLecture := kEpilogue;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kEpilogue');

       end;
  end;


begin {VerifierCetteLigneDansLesSources}

  lecture := LectureModulePtr(lectureAddr);

  doitDupliquerLigneCourante := true;

  with lecture^ do
    begin

      doitDupliquerLigneCourante := true;

      if (enCoursDeLecture = kImplementationUses) and
         (action = K_COMPILER_IMPLEMENTATION) and
         doitEtreAccelere
        then doitDupliquerLigneCourante := false;

      if (ligne.debutLigne <> '') then
        begin


            VerifierLongueurDeLaLigneDansLesSources(ligne,lectureAddr);

            //if (action = K_COMPILER_INTERFACE) then WritelnDansRapport(ligne.debutLigne);

            AppendToLongString(ligne,' ');

            case enCoursDeLecture of

              kPrologue :
                 CheckPassageInterfacePrologue;

              kInterfacePrologue :
                 begin
                   CheckPassageInterfaceUses;
                   CheckPassageInterfaceDeclarations;
                   CheckPassageImplementationPrologue;  {L'interface peut etre vide ?? }
                 end;

              kInterfaceUses :
                 begin
                   CheckPassageInterfaceDeclarations;
                   if enCoursDeLecture = kInterfaceUses
                     then TraiteInterfaceUses;
                   CheckPassageInterfaceDeclarations;
                 end;


              kInterfaceDeclarations :
                 begin
                   TraiteInterfaceDeclaration;
                   CheckPassageImplementationPrologue;
                 end;

              kImplementationPrologue :
                 begin
                   CheckPassageImplementationUses;
                   CheckEndOfModule;    {L'implementation peut etre vide}
                 end;

              kImplementationUses :
                 begin
                   TraiteImplementationUses;
                   CheckPassageImplementationDeclaration;
                 end;

              kImplementationDeclarations :
                 begin
                   TraiteImplementationDeclaration;
                   CheckPassageImplementationCode;
                   CheckEndOfModule;      {L'implementation peut etre vide}
                 end;

              kImplementationCode :
                  begin
                    ParserLigneDePascal(ligne.debutLigne);
                    CheckEndOfModule;
                  end;

              kEpilogue : DoNothing;

              otherwise    WritelnDansRapport('partie de module non traitee dans le case de VerifierCetteLigneDansLesSources !!!');
            end; {case}

        end;


      if doitDupliquerLigneCourante then
        if ((action = K_COMPILER_INTERFACE) and (enCoursDeLecture < kImplementationPrologue)) or
           ((action = K_COMPILER_IMPLEMENTATION) and (enCoursDeLecture >= kImplementationPrologue)) then
        begin
          if (ligne.finLigne = '') then
             ligne.debutLigne := EnleveEspacesDeDroite(ligne.debutLigne);

          {if action = K_COMPILER_INTERFACE
            then err := Write(duplication, 'K_COMPILER_INTERFACE  =>  ')
            else err := Write(duplication, 'K_COMPILER_IMPLEMENTATION  =>  ');}

          {err := Write(duplication, PartieDeModuleToString(enCoursDeLecture) + '  =>  ');}


          err := Write(duplication, ligne.debutLigne);
          err := Write(duplication, ligne.finLigne);
          err := Write(duplication, chr(10));  // chr(10) = LF, make it UNIX !

          if ((ligne.debutLigne = 'IMPLEMENTATION') or (ligne.debutLigne = 'implementation')) and
             doitEtreAccelere then
            begin
              err := Write(duplication, chr(10)+chr(10)+'{BEGIN_USE_CLAUSE}'+chr(10));
            end;

        end;

    end;

end;



var gActionDeCompilationDemandee : actions_de_compilation;


procedure VerifierCeFichierSource(const whichFile : fileInfo);
var lectureRec : LectureModuleRec;
    lecture : LectureModulePtr;
    lectureAddr : SInt64;
    fileName : String255;
    moduleName : String255;
    err : OSErr;
    k : SInt64;
begin

  fileName := GetName(whichFile);
  moduleName := FileNameToModuleName(fileName);

  // WritelnDansRapport('moduleName = ' + moduleName);

  WritelnDansRapport('Je lis '+fileName);
  ShareTimeWithOtherProcesses(0);


  lecture := @lectureRec;

  with lecture^ do
    begin

      action                         := gActionDeCompilationDemandee;
      nombreErreurs                  := 0;
      nombreLignesTropLongues        := 0;
      nombreDeclarationsIndues       := 0;
      enCoursDeLecture               := kPrologue;
      doitEtrePrelinke               := ModuleDoitEtrePrelinke(fileName);
      doitEtreAccelere               := ModuleDoitEtreAccelere(fileName);
      modulesInterface.cardinal      := 0;
      modulesImplementation.cardinal := 0;
      for k := 1 to kNombreMaxModules do
        begin
          modulesInterface.pointeurs[k]      := NIL;
          modulesImplementation.pointeurs[k] := NIL;
        end;
      clauseUsesInterfaceDejaEcrite      := false;
      clauseUsesImplementationDejaEcrite := false;
      unitDefCassioDejaEcrite            := false;
      fonctionsObligatoiresDejaEcrites   := false;
      got_BEGIN_USE_CLAUSE               := false;
      flag_USE_PRELINK                   := false;
      afficheTransitionsDansFichier      := false;

      AjouterModule(moduleName,whichModule);


      if (whichModule = NIL)
        then WritelnDansRapport('ERREUR !! Le module '+moduleName+' n''a pas pu etre ajouté')
        else (* WritelnDansRapport('Le module '+GetNameOfModule(whichModule)+' a été crée'); *) DoNothing;


      if doitEtreAccelere or doitEtrePrelinke then
        begin
          err := CreerDuplicateFile(fileName, duplication);
          if err = NoErr then err := OpenFile(duplication);

          if (err = NoErr) and (action  = K_COMPILER_INTERFACE)
            then err := EmptyFile(duplication);

          err := SetFilePositionAtEnd(duplication);
          // WritelnNumDansRapport('apres EmptyFile pour '+duplication.nomFichier + ', err = ',err);
        end;

      if doitEtreAccelere and (action = K_COMPILER_IMPLEMENTATION) then
        begin
          err := CreerPrelinkFile(fileName, fichierPrelink);
          if err = NoErr then err := OpenFile(fichierPrelink);
          if err = NoErr then err := EmptyFile(fichierPrelink);

          // WritelnNumDansRapport('apres EmptyFile pour '+fichierPrelink.nomFichier + ', err = ',err);
        end;

      if doitEtrePrelinke and (action = K_COMPILER_INTERFACE) then
        begin
          err := CreerExternalDeclarationsFile(fileName, fichierExternalDeclarations);
          if err = NoErr then err := OpenFile(fichierExternalDeclarations);
          if err = NoErr then err := EmptyFile(fichierExternalDeclarations);

          // WritelnNumDansRapport('apres EmptyFile pour '+fichierExternalDeclarations.nomFichier + ', err = ',err);
        end;



      lectureAddr := SInt64(lecture);

      ForEachLineInFileDo(whichFile,VerifierCetteLigneDansLesSources,lectureAddr);

      DisposeStringSet(whichModule^.symbolesImplementation);
      DisposeStringSet(whichModule^.symbolesDejaPrelinkes);
      DisposeATR(whichModule^.symbolesImplementationATR);



      if (nombreLignesTropLongues > 0) then
        begin
          ChangeFontFaceDansRapport(bold);
          WritelnDansRapport('Le fichier '+fileName+' contient '+IntToStr(nombreLignesTropLongues) + ' lignes trop longues');
          TextNormalDansRapport;
          WritelnDansRapport('');
        end;

      if (nombreDeclarationsIndues > 0) then
        begin
          ChangeFontFaceDansRapport(bold);
          WritelnDansRapport('Le fichier '+fileName+' contient '+IntToStr(nombreDeclarationsIndues) + ' declarations de types ou de globales');
          TextNormalDansRapport;
          WritelnDansRapport('');
        end;

      if not((action = K_COMPILER_INTERFACE) and (enCoursDeLecture = kImplementationPrologue)) and
         not((action = K_COMPILER_IMPLEMENTATION) and (enCoursDeLecture = kEpilogue))  then
        begin
          ChangeFontFaceDansRapport(bold);
          WritelnDansRapport('Le fichier '+fileName+' n''est pas arrivé au bout : ' + PartieDeModuleToString(enCoursDeLecture));
          TextNormalDansRapport;
          WritelnDansRapport('');
        end;

      if doitEtreAccelere or doitEtrePrelinke
        then err := CloseFile(duplication);

      if doitEtrePrelinke and (action in [K_COMPILER_INTERFACE])
        then err := CloseFile(fichierExternalDeclarations);


      if doitEtreAccelere and (action in [K_COMPILER_IMPLEMENTATION])
        then err := CloseFile(fichierPrelink);


    end;

end;




function VerifierCeFichierSourceEtRecursion(var fs : fileInfo; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
var nomFichier : String255;
begin
 {$UNUSED pb,path}


 if not(isFolder) then
   begin
     nomFichier := GetName(fs);

     if (gActionDeCompilationDemandee = K_COMPILER_INTERFACE)
       then
         if ModuleDoitEtreAccelere(nomFichier) or
            ModuleDoitEtrePrelinke(nomFichier) then
           begin
             VerifierCeFichierSource(fs);
           end;


    if (gActionDeCompilationDemandee = K_COMPILER_IMPLEMENTATION)
      then
        begin
          if ModuleDoitEtreAccelere(nomFichier) or
             ModuleDoitEtrePrelinke(nomFichier) then
           begin
             VerifierCeFichierSource(fs);
           end;

        end;




   end;

  VerifierCeFichierSourceEtRecursion := false; {ne pas chercher recursivement, sinon mettre := isFolder}
end;


procedure VerifierLesSourcesDeCassio;
var directoryDepart : fileInfo;
    codeErreur : OSErr;
begin

  WritelnDansRapport('');
  WritelnDansRapport('Entrée dans VerifierLesSourcesDeCassio…');
  WritelnDansRapport('');

  (* lecture des interfaces *)

  WritelnDansRapport('');
  WritelnDansRapport('Phase 1 : pre-compilation des interfaces ');
  WritelnDansRapport('');

  gActionDeCompilationDemandee := K_COMPILER_INTERFACE;

  codeErreur := MakeFileInfo(0,0,kPathSourcesDeCassio+ DirectorySeparator ,directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MakeFileInfo(0,0,kPathSourcesDeCassio+ DirectorySeparator +'PNL_Libraries',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MakeFileInfo(0,0,kPathSourcesDeCassio+ DirectorySeparator +'Edmond',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MakeFileInfo(0,0,kPathSourcesDeCassio+ DirectorySeparator +'Zebra_book',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);



  (* lecture des implementations *)

  WritelnDansRapport('');
  WritelnDansRapport('Phase 2 : pre-compilation des implementations ');
  WritelnDansRapport('');


  gActionDeCompilationDemandee := K_COMPILER_IMPLEMENTATION;

  codeErreur := MakeFileInfo(0,0,kPathSourcesDeCassio+ DirectorySeparator ,directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MakeFileInfo(0,0,kPathSourcesDeCassio+ DirectorySeparator +'PNL_Libraries',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MakeFileInfo(0,0,kPathSourcesDeCassio+ DirectorySeparator + 'Edmond',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MakeFileInfo(0,0,kPathSourcesDeCassio+ DirectorySeparator +'Zebra_book',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);


  WritelnDansRapport('');
  WritelnNumDansRapport('Sortie de VerifierLesSourcesDeCassio, codeErreur = ',codeErreur);
end;




END.















