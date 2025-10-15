UNIT UnitCompilation;


INTERFACE


 USES UnitDefCassio;


{initialisation de l'unite}
procedure InitUnitCompilation;                                                                                                                                                      ATTRIBUTE_NAME('InitUnitCompilation')
procedure LibereMemoireUnitCompilation;                                                                                                                                             ATTRIBUTE_NAME('LibereMemoireUnitCompilation')


{ajout d'un module}
function MakeEmptyModule(const name : String255) : Module;                                                                                                                          ATTRIBUTE_NAME('MakeEmptyModule')
procedure AjouterModule(const name : String255; var nouveauModule : Module);                                                                                                        ATTRIBUTE_NAME('AjouterModule')


{acces aux modules}
function ModuleEstChargeEnMemoire(const nom : String255; var numeroModule : SInt64; var theModule : Module) : boolean;                                                              ATTRIBUTE_NAME('ModuleEstChargeEnMemoire')
function GetModule(const name : String255) : Module;                                                                                                                                ATTRIBUTE_NAME('GetModule')
function GetModuleByNumero(numero : SInt64) : Module;                                                                                                                               ATTRIBUTE_NAME('GetModuleByNumero')
function GetNumeroOfModule(whichModule : Module) : SInt64;                                                                                                                          ATTRIBUTE_NAME('GetNumeroOfModule')
function GetNameOfModule(whichModule : Module) : String255;                                                                                                                         ATTRIBUTE_NAME('GetNameOfModule')


{liaison nom d'unite  < -> module}
function ModuleDoitEtreAccelere(const name : String255) : boolean;                                                                                                                  ATTRIBUTE_NAME('ModuleDoitEtreAccelere')
function ModuleDoitEtrePrelinke(const name : String255) : boolean;                                                                                                                  ATTRIBUTE_NAME('ModuleDoitEtrePrelinke')
function TrouverFichierDansSourcesDeCassio(const nomUnite : String255; var fic : FichierTEXT) : boolean;                                                                            ATTRIBUTE_NAME('TrouverFichierDansSourcesDeCassio')



{ecritures des symboles}
function EcrireSymboleExternalDansFichier(sym : Symbole; var fic : FichierTEXT) : OSErr;                                                                                            ATTRIBUTE_NAME('EcrireSymboleExternalDansFichier')
function EcrireSymboleAttributeDansFichier(sym : Symbole; var fic : FichierTEXT) : OSErr;                                                                                           ATTRIBUTE_NAME('EcrireSymboleAttributeDansFichier')


{verification des sources}
procedure VerifierLongueurDeLaLigneDansLesSources(var ligne : LongString; var lectureAddr : SInt64);                                                                                ATTRIBUTE_NAME('VerifierLongueurDeLaLigneDansLesSources')
procedure VerifierCeFichierSource(const whichFile : FSSpec);                                                                                                                        ATTRIBUTE_NAME('VerifierCeFichierSource')
function VerifierCeFichierSourceEtRecursion(var fs : FSSpec; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;                                                  ATTRIBUTE_NAME('VerifierCeFichierSourceEtRecursion')
procedure VerifierLesSourcesDeCassio;                                                                                                                                               ATTRIBUTE_NAME('VerifierLesSourcesDeCassio')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, UnitDefATR
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyStrings, UnitRapportImplementation, UnitFichiersTEXT, MyFileSystemUtils, SNEvents
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
      fichierExternalDeclarations        : FichierTEXT;
      fichierPrelink                     : FichierTEXT;
      duplication                        : FichierTEXT;
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

  if MemberOfStringSet(LowerCaseStr(nom), numeroModule, gModulesCharges) then
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

  if MemberOfStringSet(LowerCaseStr(nom), adresseSymbole, gSymbolesCharges) then
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
  if (numero >= 1) & (numero <= gTableDesModules.cardinal)
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

            AddStringToSet(LowerCaseStr(name),gTableDesModules.cardinal,gModulesCharges);
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

        if (EnleveEspacesDeGauche(GetDefinitionOfSymbole(aux).debutLigne) <> EnleveEspacesDeGauche(definition.debutLigne)) |
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

        AddStringToSet(LowerCaseStr(name),POINTER_VALUE(aux),gSymbolesCharges);

        if (whichModule <> NIL)
          then AddStringToSet(name,POINTER_VALUE(aux),whichModule^.symbolesInterface)
          else WritelnDansRapport('ERREUR !!! whichModule = NIL dans AjouterSymbole !! ');

        nouveauSymbole := aux;
      end;

end;


function ModuleDoitEtreAccelere(const name : String255) : boolean;
begin
  ModuleDoitEtreAccelere := ((Pos('Unit',name) > 0)  |
                             (Pos('Cassio.p',name) > 0) |
                             (Pos('Main.p',name) > 0) |
                             (Pos('EdmondPatterns.p',name) > 0) |
                             (Pos('EdmondEvaluation.p',name) > 0) |
                             (Pos('ImportEdmond.p',name) > 0) |
                             (Pos('Zebra_to_Cassio.p',name) > 0) |
                             (Pos('SNEvents.p',name) > 0) |
                             (Pos('SNMenus.p',name) > 0) |
                             (Pos('MyFileSystemUtils.p',name) > 0) |
                             (Pos('MyUtils.p',name) > 0) |
                             (Pos('MyFonts.p',name) > 0) |
                             (Pos('MyStrings.p',name) > 0)) &

                             not(Pos('UnitJan', name) > 0) &

                            ( EndsWith(name,'.p') | EndsWith(name,'.pas'));


  (*
  ModuleDoitEtreAccelere := (name = 'UnitDialog.p');

  ModuleDoitEtreAccelere := (name = 'UnitModes.p');
  *)

end;


function ModuleDoitEtrePrelinke(const name : String255) : boolean;
begin

  ModuleDoitEtrePrelinke := ( EndsWith(name,'.p') | EndsWith(name,'.pas')) &


                           ((Pos('Unit', name) = 1) |
                            (Pos('MyAntialiasing', name) = 1) |
                            (Pos('MyAssertions', name) = 1) |
                            (Pos('MyFileSystemUtils', name) = 1) |
                            (Pos('MyEvents', name) = 1) |
                            (Pos('MyFileIDs', name) = 1) |
                            (Pos('MyFonts', name) = 1) |
                            (Pos('MyKeyMapUtils', name) = 1) |
                            (Pos('MyLists', name) = 1) |
                            (Pos('MyLowLevel', name) = 1) |
                            (Pos('MyMathUtils', name) = 1) |
                            (Pos('MyMemory', name) = 1) |
                            (Pos('MyStrings', name) = 1) |
                            (Pos('MyQuickDraw', name) = 1) |
                            (Pos('MyTMSTE', name) = 1) |
                            (Pos('MyUtils', name) = 1) |
                            (Pos('MyNavigationServices', name) = 1) |
                            (Pos('Cassio.p', name) = 1) |
                            (Pos('Zebra_to_Cassio', name) = 1) |
                            (Pos('EdmondPatterns', name) = 1) |
                            (Pos('EdmondEvaluation', name) = 1) |
                            (Pos('ImportEdmond', name) = 1) |
                            (Pos('SN', name) = 1)) &


                            not((Pos('UnitDef', name) > 0) |
                                (Pos('Type', name) > 0)  |
                                (Pos('UnitOth0', name) > 0)  |
                                (Pos('UnitJan', name) > 0) |
                                (Pos('UnitDebuggage', name) > 0) |
                                (Pos('UnitVar', name) > 0));

  (*

  ModuleDoitEtrePrelinke := (name = 'UnitRapport.p') |
                            (name = 'MyMathUtils.p') |
                            (name = 'UnitServicesMemoire.p') |
                            (name = 'MyStrings.p') |
                            (name = 'UnitPagesATR.p') |
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



function TrouverFichierDansSourcesDeCassio(const nomUnite : String255; var fic : FichierTEXT) : boolean;
var err : OSErr;
    path : String255;
begin
  if nomUnite = '' then
    begin
      TrouverFichierDansSourcesDeCassio := false;
      exit(TrouverFichierDansSourcesDeCassio);
    end;

  path := kPathSourcesDeCassio + ':' + nomUnite + '.p';
  err := FichierTexteExiste(path,0,fic);

  if (err <> NoErr) then
    begin
      path := kPathSourcesDeCassio + ':' + nomUnite + '.pas';
      err := FichierTexteExiste(path,0,fic);
    end;

  if (err <> NoErr) then
    begin
      path := kPathSourcesDeCassio + ':PNL_Libraries:' + nomUnite + '.p';
      err := FichierTexteExiste(path,0,fic);
    end;

  if (err <> NoErr) then
    begin
      path := kPathSourcesDeCassio + ':PNL_Libraries:' + nomUnite + '.pas';
      err := FichierTexteExiste(path,0,fic);
    end;

  TrouverFichierDansSourcesDeCassio := (err = NoErr);
end;


function EcrireSymboleExternalDansFichier(sym : Symbole; var fic : FichierTEXT) : OSErr;
var symbolName : String255;
    err : OSErr;
    espaces : String255;
    len : SInt64;
begin
  err := -1;

  if (sym <> NIL) then
    begin

      err := WriteDansFichierTexte(fic, sym^.definition.debutLigne);

      if (sym^.definition.finLigne <> '') &
         (err = NoErr) then
        err := WriteDansFichierTexte(fic, sym^.definition.finLigne);

      if (err = NoErr) then
        begin


          len := LENGTH_OF_STRING(sym^.definition.debutLigne) + LENGTH_OF_STRING(sym^.definition.finLigne);

          espaces := ' ';
          len := len + 1;

          while (len < 180) | ((len mod 90) <> 0) do
            begin
              len := len + 1;
              espaces := espaces + ' ';
            end;

          symbolName := espaces + 'EXTERNAL_NAME(''' + sym^.nom + ''');' + chr(10);  {chr(10) = LF , add a UNIX linefeed !}

          err := WriteDansFichierTexte(fic, symbolName);
        end;


    end;

  EcrireSymboleExternalDansFichier := err;
end;



function EcrireSymboleAttributeDansFichier(sym : Symbole; var fic : FichierTEXT) : OSErr;
var symbolName : String255;
    err : OSErr;
    espaces : String255;
    len : SInt64;
begin
  err := -1;

  if (sym <> NIL) then
    begin

    //  EnleveEspacesDeGaucheSurPlace(sym^.definition.debutLigne);

      err := WriteDansFichierTexte(fic, sym^.definition.debutLigne);

      if (sym^.definition.finLigne <> '') &
         (err = NoErr) then
        err := WriteDansFichierTexte(fic, sym^.definition.finLigne);


      if (err = NoErr) then
        begin
          len := LENGTH_OF_STRING(sym^.definition.debutLigne) + LENGTH_OF_STRING(sym^.definition.finLigne);

          espaces := ' ';
          len := len + 1;

          while (len < 180) | ((len mod 90) <> 0) do
            begin
              len := len + 1;
              espaces := espaces + ' ';
            end;


          symbolName := espaces +'ATTRIBUTE_NAME(''' + sym^.nom + ''')' + chr(10);  {chr(10) = LF , add a UNIX linefeed !}

          err := WriteDansFichierTexte(fic, symbolName);
        end;

    end;

  EcrireSymboleAttributeDansFichier := err;
end;





function FabriquerNameOfPrelinkFile(const moduleName : String255) : String255;
var result : String255;
begin
  result := DeleteSubstringAfterThisChar('.',moduleName,false) + '.lk';
  result := ReplaceStringByStringInString('Unit','',result);
  FabriquerNameOfPrelinkFile := result;
end;

function FabriquerNameOfExternalDeclarationsFile(const moduleName : String255) : String255;
var result : String255;
begin
  result := DeleteSubstringAfterThisChar('.',moduleName,false) + '.ext';
  result := ReplaceStringByStringInString('Unit','',result);
  FabriquerNameOfExternalDeclarationsFile := result;
end;


function FabriquerNameOfDuplicateFile(const moduleName : String255) : String255;
begin
  FabriquerNameOfDuplicateFile := DeleteSubstringAfterThisChar('.',moduleName,false) + '.p';
end;

function GetPathOfTemporaryPrelinkFile(const moduleName : String255) : String255;
begin
  GetPathOfTemporaryPrelinkFile := kPathSourcesDeCassio + ':prelink-temp:' + FabriquerNameOfPrelinkFile(moduleName);
end;


function GetPathOfPrelinkFile(const moduleName : String255) : String255;
begin
  GetPathOfPrelinkFile := kPathSourcesDeCassio + ':prelink:' + FabriquerNameOfPrelinkFile(moduleName);
end;

function GetPathOfDeclarationsFile(const moduleName : String255) : String255;
begin
  GetPathOfDeclarationsFile := kPathSourcesDeCassio + ':declarations:' + FabriquerNameOfExternalDeclarationsFile(moduleName);
end;


function GetPathOfDuplicateFile(const moduleName : String255) : String255;
begin
  GetPathOfDuplicateFile := kPathDuplicatesDesSourcesDeCassio + ':' +  FabriquerNameOfDuplicateFile(moduleName);
end;


function CreerPrelinkFile(const moduleName : String255; var fic : FichierTEXT) : OSErr;
var path : String255;
    err : OSErr;
begin

  path := GetPathOfPrelinkFile(moduleName);

  err := FichierTexteExiste(path,0,fic);

  if (err <> NoErr) then
    err := CreeFichierTexte(path,0,fic);

  if (err = NoErr) then
    SetFileCreatorFichierTexte(fic,MY_FOUR_CHAR_CODE('CWIE'));

  if err <> NoErr then
    WritelnNumDansRapport('dans CreerPrelinkFile, '+moduleName + ' => ',err);

  CreerPrelinkFile := err;
end;


function CreerExternalDeclarationsFile(const moduleName : String255; var fic : FichierTEXT) : OSErr;
var path : String255;
    err : OSErr;
begin

  path := GetPathOfDeclarationsFile(moduleName);

  err := FichierTexteExiste(path,0,fic);

  if (err <> NoErr) then
    err := CreeFichierTexte(path,0,fic);

  if (err = NoErr) then
    SetFileCreatorFichierTexte(fic,MY_FOUR_CHAR_CODE('CWIE'));

  if err <> NoErr then
    WritelnNumDansRapport('dans CreerExternalDeclarationsFile, '+moduleName + ' => ',err);

  CreerExternalDeclarationsFile := err;
end;


function CreerDuplicateFile(const moduleName : String255; var fic : FichierTEXT) : OSErr;
var path : String255;
    err : OSErr;
begin

  path := GetPathOfDuplicateFile(moduleName);

  err := FichierTexteExiste(path,0,fic);

  if (err <> NoErr) then
    err := CreeFichierTexte(path,0,fic);

  if (err = NoErr) then
    SetFileCreatorFichierTexte(fic,MY_FOUR_CHAR_CODE('CWIE'));

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
    if (Pos('function',ligne.debutLigne) > position)  |
       (Pos('FUNCTION',ligne.debutLigne) > position)  |
       (Pos('procedure',ligne.debutLigne) > position) |
       (Pos('PROCEDURE',ligne.debutLigne) > position) then
     begin
       ChangeFontColorDansRapport(RougeCmd);
       WritelnDansRapport(ligne.debutLigne);
       TextNormalDansRapport;
       exit(ParserDefinition);
     end;

  position := Pos('{',ligne.debutLigne);
  if (position > 0) then
    if (Pos('function',ligne.debutLigne) > position)  |
       (Pos('FUNCTION',ligne.debutLigne) > position)  |
       (Pos('procedure',ligne.debutLigne) > position) |
       (Pos('PROCEDURE',ligne.debutLigne) > position) then
     begin
       if (FindStringInLongString('}',ligne) <= 0) then
         begin
           ChangeFontColorDansRapport(RougeCmd);
           WritelnDansRapport(ligne.debutLigne);
           TextNormalDansRapport;
         end;
       exit(ParserDefinition);
     end;

  position := Pos('(*',ligne.debutLigne);
  if (position > 0) then
    if (Pos('function',ligne.debutLigne) > position)  |
       (Pos('FUNCTION',ligne.debutLigne) > position)  |
       (Pos('procedure',ligne.debutLigne) > position) |
       (Pos('PROCEDURE',ligne.debutLigne) > position) then
     begin
       if (FindStringInLongString('*)',ligne) <= 0) then
         begin
           ChangeFontColorDansRapport(RougeCmd);
           WritelnDansRapport(ligne.debutLigne);
           TextNormalDansRapport;
         end;
       exit(ParserDefinition);
     end;


  oldParsingSet := GetParsingCaracterSet;
  SetParsingCaracterSet([' ',tab,'(',';',':']);

  Parser2(ligne.debutLigne,fun_or_proc,nomSymbole,reste);

  SetParsingCaracterSet(oldParsingSet);



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

  if (nomSymbole <> '') & ((definition.debutLigne <> '') | (definition.finLigne <> ''))
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
    fic : FichierTEXT;
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
      exit(AddDeclarationOfThisModuleToATR);
    end;

  err := FichierTexteExiste(fileName, 0, fic);
  if err <> NoErr then
    begin
      WritelnNumDansRapport('apres FichierTexteExiste dans AddDeclarationOfThisModuleToATR, err = ',err);
      exit(AddDeclarationOfThisModuleToATR);
    end;

  err := OuvreFichierTexte(fic);
  if err <> NoErr then
    begin
      WritelnNumDansRapport('apres OuvreFichierTexte dans AddDeclarationOfThisModuleToATR, err = ',err);
      exit(AddDeclarationOfThisModuleToATR);
    end;

  while not(EOFFichierTexte(fic,err)) do
    begin

      err := ReadlnLongStringDansFichierTexte(fic,ligne);

      theSymbole := ParserDefinition(ligne,theModule,wasExternal);

      if (theSymbole = NIL) then
        begin
          WritelnDansRapport('ERREUR !! theSymbole = NIL dans AddDeclarationOfThisModuleToATR');
          leave;
        end;

      InsererDansATR(myATR,theSymbole^.nom);

      AddStringToSet(theSymbole^.nom,SInt64(theSymbole),myStringSet);

    end;

  err := FermeFichierTexte(fic);

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
        exit(UsesClauseADesModulesDevantEtrePrelinke);
      end;
end;


function EstUnModuleDeDefinition(nomModule : String255) : boolean;
begin
  EstUnModuleDeDefinition := false;

  nomModule := LowerCaseStr(nomModule);

  if (nomModule = LowerCaseStr('UnitVarGlobalesFinale')) |
     (nomModule = LowerCaseStr('UnitDefPackedThorGame')) |
     (nomModule = LowerCaseStr('UnitDefCompilation')) |
     (nomModule = LowerCaseStr('UnitDefCouleurs')) |
     (nomModule = LowerCaseStr('UnitDefDialog')) |
     (nomModule = LowerCaseStr('UnitDefEvaluation')) |
     (nomModule = LowerCaseStr('UnitDefEvents')) |
     (nomModule = LowerCaseStr('UnitDefFormatsFichiers')) |
     (nomModule = LowerCaseStr('UnitDefGeneralSort')) |
     (nomModule = LowerCaseStr('UnitDefGraphe')) |
     (nomModule = LowerCaseStr('UnitDefHash')) |
     (nomModule = LowerCaseStr('UnitDefListeCasesVides')) |
     (nomModule = LowerCaseStr('UnitDefMenus')) |
     (nomModule = LowerCaseStr('UnitDefNouveauFormat')) |
     (nomModule = LowerCaseStr('UnitDefParallelisme')) |
     (nomModule = LowerCaseStr('UnitDefSmartGameBoard')) |
     (nomModule = LowerCaseStr('UnitDefTranscript')) |
     (nomModule = LowerCaseStr('Zebra_types')) |
     (nomModule = LowerCaseStr('EdmondTypes')) |
     (nomModule = LowerCaseStr('UnitOth0')) |
     (nomModule = LowerCaseStr('MacTypes')) |
     (nomModule = LowerCaseStr('StringTypes')) |
     (nomModule = LowerCaseStr('UnitDefSet')) |
     (nomModule = LowerCaseStr('UnitBitboardTypes')) |
     (nomModule = LowerCaseStr('MyTypes')) |
     (nomModule = LowerCaseStr('UnitDefSet')) |
     (nomModule = LowerCaseStr('GPCStrings')) |
     (nomModule = LowerCaseStr('UnitDefABR')) |
     (nomModule = LowerCaseStr('UnitDefAlgebreLineaire')) |
     (nomModule = LowerCaseStr('UnitDefABR')) |
     (nomModule = LowerCaseStr('UnitDefCompilation')) |
     (nomModule = LowerCaseStr('UnitDefFichiersTEXT')) |
     (nomModule = LowerCaseStr('UnitDefOthelloGeneralise')) |
     (nomModule = LowerCaseStr('UnitDefGameTree')) |
     (nomModule = LowerCaseStr('UnitDefPositionEtTrait')) |
     (nomModule = LowerCaseStr('UnitDefFichierAbstrait'))
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
          exit(UsesClauseContientDesDefinitionsDeDassio);
        end;
    end;
end;





procedure VerifierCetteLigneDansLesSources(var ligne : LongString; var theFic : FichierTEXT; var lectureAddr : SInt64);
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
                Parser(reste,s,reste);

                (* gérer les macros *)
                if (s = 'FIND_IN_BITBOARD_HASH_AND_GET_LOCK') then s := 'BitboardHashGet';
                if (s = 'SET_LENGTH_OF_STRING') then s := 'MySetStringLength';
                if (s = 'MyStringWidth') then s := 'StringWidthPourGNUPascal';
                if (s = 'MyDrawString') then s := 'DrawStringPourGNUPascal';

                if MemberOfStringSet(s,symboleAddr,whichModule^.symbolesImplementation) &
                  not(MemberOfStringSet(s,aux,whichModule^.symbolesDejaPrelinkes)) then
                  begin
                    theSymbole := Symbole(symboleAddr);

                    {WritelnDansRapport('@'+s);}
                    ShareTimeWithOtherProcesses(0);

                    if doitEtreAccelere & (action in [K_COMPILER_IMPLEMENTATION]) then
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


            oldParsingSet := GetParsingCaracterSet;
            SetParsingCaracterSet([' ',tab,'.',',',';',':','}','{',')','(','-','+','$','@','=','>','<','|','&','[',']','*','/','''','"','^']);


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
                Parser(reste,s,reste);

                (* gérer les macros *)
                if (s = 'FIND_IN_BITBOARD_HASH_AND_GET_LOCK') then s := 'BitboardHashGet';
                if (s = 'SET_LENGTH_OF_STRING') then s := 'MySetStringLength';
                if (s = 'MyStringWidth') then s := 'StringWidthPourGNUPascal';
                if (s = 'MyDrawString') then s := 'DrawStringPourGNUPascal';

                if MemberOfStringSet(s,symboleAddr,whichModule^.symbolesImplementation) &
                   not(MemberOfStringSet(s,aux,whichModule^.symbolesDejaPrelinkes)) then
                  begin
                    theSymbole := Symbole(symboleAddr);

                    {WritelnDansRapport('@'+s);}
                    ShareTimeWithOtherProcesses(0);

                    if doitEtreAccelere & (action in [K_COMPILER_IMPLEMENTATION]) then
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

            SetParsingCaracterSet(oldParsingSet);

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
        if (ligne.finLigne = '') & not(EstUnModuleDeDefinition(GetNameOfModule(whichModule))) then
          begin
            result := '';

            reste := ligne.debutLigne;

            WritelnDansRapport('avant réduction, reste = '+reste);

            for i := 1 to 30 do
              reste := ReplaceStringByStringInString(reste,',',' • ');

            ReplaceCharByCharInString(reste,'•',',');

            reste := ReplaceStringByStringInString(';',' ;',reste);

            WritelnDansRapport('eprès réduction, reste = '+reste);


            while (reste <> '') do
              begin
                Parser(reste,s,reste);

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
              result := ReplaceStringByStringInString(', ,',',',result);
            for i := 1 to 30 do
              result := ReplaceStringByStringInString(', ;',';',result);
            result := ReplaceStringByStringInString(' ;',';',result);

            if (Pos('USES', result) <= 0) & (Pos('uses', result) <= 0)
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
              oldParsingSet := GetParsingCaracterSet;
              SetParsingCaracterSet([' ',tab,',',';']);

              reste := ligne.debutLigne;
              repeat
                Parser(reste,s,reste);

                if (s <> 'USES') & (s <> 'uses') & (s <> '') then
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

              SetParsingCaracterSet(oldParsingSet);
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


            if EstUnModuleDeDefinition(moduleName) &
               not(EstUnModuleDeDefinition(GetNameOfModule(whichModule)))
              then
                begin
                  if not(unitDefCassioDejaEcrite) then
                    begin
                      if (nombreModulesEcrit > 0) then err := WriteDansFichierTexte(duplication,', ');

                      err := WriteDansFichierTexte(duplication,'UnitDefCassio');
                      unitDefCassioDejaEcrite := true;

                      if ((nombreModulesEcrit + 1) mod 8) = 0 then
                           err := WriteDansFichierTexte(duplication,chr(10)+'    ');
                      inc(nombreModulesEcrit);
                    end;
                end
              else

                if not(ModuleDoitEtrePrelinke(fileName)) then
                  begin

                    if (nombreModulesEcrit > 0) then err := WriteDansFichierTexte(duplication,', ');
                    ChangeFontColorDansRapport(VertCmd);

                    err := WriteDansFichierTexte(duplication,moduleName {+ '['+NumEnString(k)+']'});

                    if ((nombreModulesEcrit + 1) mod 8) = 0 then
                       err := WriteDansFichierTexte(duplication,chr(10)+'    ');
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
                if (nombreModulesEcrit > 0) then err := WriteDansFichierTexte(duplication,', ');
                ChangeFontColorDansRapport(RougeCmd);
                err := WriteDansFichierTexte(duplication,moduleName);
                if ((nombreModulesEcrit + 1) mod 8) = 0 then
                   err := WriteDansFichierTexte(duplication,chr(10)+'    ');
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
        if (modulesInterface.cardinal > 0) & not(clauseUsesInterfaceDejaEcrite) &
           (UsesClauseADesModulesDevantEtrePrelinke(modulesInterface) {| UsesClauseContientDesDefinitionsDeDassio(modulesInterface)}) then
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
                if not(ModuleDoitEtrePrelinke(fileName)) &
                   not(EstUnModuleDeDefinition(moduleName)) then
                  begin


                    if ((Pos('{$ENDC',moduleName) <= 0) |
                        (Pos('{$IFC',moduleName) <= 0)  |
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
                if ModuleDoitEtrePrelinke(fileName) &
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
        if doitEtreAccelere &
           not(clauseUsesImplementationDejaEcrite)
          then
            begin
              nombreModulesEcrit := 0;

              if UsesClauseADesModulesDevantEtrePrelinke(modulesImplementation)
                then
                  begin
                    if flag_USE_PRELINK
                      then err := WriteDansFichierTexte(duplication,'{$DEFINEC USE_PRELINK ' + 'true}' + chr(10)+chr(10))
                      else err := WriteDansFichierTexte(duplication,'{$DEFINEC USE_PRELINK ' + 'false}' + chr(10)+chr(10));
                    if NombreDeModulesDevantEtrePrelinkeDansClause(modulesImplementation) = modulesImplementation.cardinal
                      then
                        begin  // il n'a a que des modules prelinkes
                          err := WriteDansFichierTexte(duplication,chr(10)+'{$IFC NOT(USE_PRELINK)}' + chr(10));
                          err := WriteDansFichierTexte(duplication,'USES' + chr(10)+'    ');
                          EcritModulesPrelinkes(modulesImplementation,nombreModulesEcrit);
                          err := WriteDansFichierTexte(duplication,' ;'+chr(10));
                          err := WriteDansFichierTexte(duplication,'{$ELSEC}' + chr(10)+'    ');
                          err := WriteDansFichierTexte(duplication,'{$I prelink/'+FabriquerNameOfPrelinkFile(GetNameOfModule(whichModule))+'}'+chr(10));
                          err := WriteDansFichierTexte(duplication,'{$ENDC}' + chr(10)+chr(10));
                        end
                      else
                        begin  // il y a a la fois des modules normaux et des modules prelinkes
                          ChangeFontFaceDansRapport(bold);
                          err := WriteDansFichierTexte(duplication,'USES' + chr(10)+'    ');
                          EcritModulesNormaux(modulesImplementation,nombreModulesEcrit);
                          if nombreModulesEcrit = 0 then WritelnDansRapport('ERREUR !! nombreModulesEcrit = 0');
                          err := WriteDansFichierTexte(duplication,chr(10)+'{$IFC NOT(USE_PRELINK)}' + chr(10)+'    ');
                          EcritModulesPrelinkes(modulesImplementation,nombreModulesEcrit);
                          err := WriteDansFichierTexte(duplication,' ;'+chr(10));
                          err := WriteDansFichierTexte(duplication,'{$ELSEC}' + chr(10)+'    ;'+chr(10)+'    ');
                          err := WriteDansFichierTexte(duplication,'{$I prelink/'+FabriquerNameOfPrelinkFile(GetNameOfModule(whichModule))+'}'+chr(10));
                          err := WriteDansFichierTexte(duplication,'{$ENDC}' + chr(10)+chr(10));
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
                          err := WriteDansFichierTexte(duplication,'USES' + chr(10)+'    ');
                          EcritModulesNormaux(modulesImplementation,nombreModulesEcrit);
                          err := WriteDansFichierTexte(duplication,';' + chr(10)+'    ');
                        end;
                  end;

              err := WriteDansFichierTexte(duplication,chr(10)+'{END_USE_CLAUSE}'+chr(10)+chr(10));

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
                  if (FindStringInLongString('(',definition) > 0) & (FindStringInLongString(')',definition) <= 0) then
                    begin

                      // La definition s'étend sur plusieurs lignes => traitement special

                      (*
                      ChangeFontFaceDansRapport(bold);
                      ChangeFontColorDansRapport(VertCmd);
                      *)

                      for i := 1 to 100 do
                          definition.debutLigne := ReplaceStringByStringInString('    ',' ',definition.debutLigne);
                      for i := 1 to 100 do
                          definition.debutLigne := ReplaceStringByStringInString('  ',' ',definition.debutLigne);

                      for i := 1 to 100 do
                          definition.debutLigne := ReplaceStringByStringInString(StringOf(tab),' ',definition.debutLigne);
                      for i := 1 to 100 do
                          definition.debutLigne := ReplaceStringByStringInString(StringOf(tab),' ',definition.debutLigne);

                      compteur := 0;

                      repeat

                        err := ReadlnDansFichierTexte(theFic,s);

                        if Pos(' ATT',s) > 0 then s := TPCopy(s,1,Pos(' ATT',s));
                        if Pos(' EXT',s) > 0 then
                          begin
                            s := TPCopy(s,1,Pos(' EXT',s));
                            wasExternal := true;
                          end;


                        s := EnleveEspacesDeGauche(s);
                        s := EnleveEspacesDeDroite(s);

                        for i := 1 to 100 do
                          s := ReplaceStringByStringInString('    ',' ',s);
                        for i := 1 to 100 do
                          s := ReplaceStringByStringInString('  ',' ',s);

                        for i := 1 to 100 do
                          s := ReplaceStringByStringInString(StringOf(tab),' ',s);
                        for i := 1 to 100 do
                          s := ReplaceStringByStringInString(StringOf(tab),' ',s);

                        AppendToLongString(definition,' '+s);
                        inc(compteur);

                      until (FindStringInLongString(')',definition) > 0) | (compteur >= 15);

                      (*
                      WriteDansRapport(definition.debutLigne);
                      WritelnDansRapport(definition.finLigne);

                      TextNormalDansRapport;
                      *)

                    end;  {with theSymbole}

                if doitEtrePrelinke & (action in [K_COMPILER_INTERFACE]) then
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

        if doitEtrePrelinke &
          (((FindStringInLongString('VAR ',ligne) > 0) & (Pos('VAR ',ligne.debutLigne) > 0) & (Pos('VAR ',ligne.debutLigne) <= 10)) |
           ((FindStringInLongString('var ',ligne) > 0) & (Pos('var ',ligne.debutLigne) > 0) & (Pos('var ',ligne.debutLigne) <= 10)) |
           ((FindStringInLongString('TYPE ',ligne) > 0) & (Pos('TYPE ',ligne.debutLigne) > 0) & (Pos('TYPE ',ligne.debutLigne) <= 10)) |
           ((FindStringInLongString('type ',ligne) > 0) & (Pos('type ',ligne.debutLigne) > 0) & (Pos('type ',ligne.debutLigne) <= 10)) |
           ((FindStringInLongString('CONST ',ligne) > 0) & (Pos('CONST ',ligne.debutLigne) > 0) & (Pos('CONST ',ligne.debutLigne) <= 10)) |
           ((FindStringInLongString('const ',ligne) > 0) & (Pos('const ',ligne.debutLigne) > 0) & (Pos('const ',ligne.debutLigne) <= 10)))
           then
             begin
               inc(nombreErreurs);
               inc(nombreDeclarationsIndues);

               WriteDansRapport(ligne.debutLigne);
               WritelnDansRapport(ligne.finLigne);
             end;


        if doitEtrePrelinke &
           ((FindStringInLongString('function ',ligne) > 0) |
            (FindStringInLongString('procedure ',ligne) > 0) |
            (FindStringInLongString('FUNCTION ',ligne) > 0) |
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

    if (FindStringInLongString('BEGIN_USE_CLAUSE',ligne) > 0) |
       (FindStringInLongString('{$DEFINEC USE_PRELINK',ligne) > 0) |
       (FindStringInLongString('{$IFC NOT(USE_PRELINK)',ligne) > 0) |
       (FindStringInLongString('{$ELSEC}',ligne) > 0) |
       (FindStringInLongString('{$I prelink/',ligne) > 0) |
       (FindStringInLongString('{$ENDC}',ligne) > 0) |
       (FindStringInLongString('END_USE_CLAUSE',ligne) > 0)
      then exit(TraiteImplementationUses);


    TraiterUseClause(lecture^.modulesImplementation);
  end;

  procedure TraiteImplementationDeclaration;
  begin
  end;

  procedure CheckPassageInterfacePrologue;
  begin
    if (lecture^.enCoursDeLecture = kInterfacePrologue) then exit(CheckPassageInterfacePrologue);

    if ((FindStringInLongString('INTERFACE ',ligne) > 0) & (FindStringInLongString('INTERFACE ',ligne) < 5)) |
       ((FindStringInLongString('interface ',ligne) > 0) & (FindStringInLongString('interface ',ligne) < 5)) then
       begin
         lecture^.enCoursDeLecture := kInterfacePrologue;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kInterfacePrologue');
       end;
  end;

  procedure CheckPassageInterfaceDeclarations;
  begin
    if (lecture^.enCoursDeLecture = kInterfaceDeclarations) then exit(CheckPassageInterfaceDeclarations);

    if (FindStringInLongString(';',ligne) > 0) |
       (FindStringInLongString('VAR ',ligne) > 0) |
       (FindStringInLongString('var ',ligne) > 0) |
       (FindStringInLongString('TYPE ',ligne) > 0) |
       (FindStringInLongString('type ',ligne) > 0) |
       (FindStringInLongString('CONST ',ligne) > 0) |
       (FindStringInLongString('const ',ligne) > 0) |
       (FindStringInLongString('procedure ',ligne) > 0) |
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
    if (lecture^.enCoursDeLecture = kInterfaceUses) then exit(CheckPassageInterfaceUses);

    if (FindStringInLongString('USES ',ligne) > 0) |
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
    if (lecture^.enCoursDeLecture = kImplementationPrologue) then exit(CheckPassageImplementationPrologue);

    if ((FindStringInLongString('IMPLEMENTATION ',ligne) > 0) & (FindStringInLongString('IMPLEMENTATION ',ligne) < 5)) |
       ((FindStringInLongString('implementation ',ligne) > 0) & (FindStringInLongString('implementation ',ligne) < 5)) then
       begin
         {WritelnDansRapport(ligne.debutLigne);}
         lecture^.enCoursDeLecture := kImplementationPrologue;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kImplementationPrologue');


         if lecture^.action = K_COMPILER_INTERFACE then
           err := SetPositionTeteLectureFinFichierTexte(theFic);

       end;
  end;

  procedure CheckPassageImplementationDeclaration;
  begin
    if (lecture^.enCoursDeLecture = kImplementationDeclarations) then exit(CheckPassageImplementationDeclaration);

    if lecture^.got_BEGIN_USE_CLAUSE
      then
        begin
          if (FindStringInLongString('END_USE_CLAUSE',ligne) > 0) |
             (FindStringInLongString('VAR ',ligne) > 0) |
             (FindStringInLongString('var ',ligne) > 0) |
             (FindStringInLongString('TYPE ',ligne) > 0) |
             (FindStringInLongString('type ',ligne) > 0) |
             (FindStringInLongString('CONST ',ligne) > 0) |
             (FindStringInLongString('const ',ligne) > 0) |
             (FindStringInLongString('procedure ',ligne) > 0) |
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
    if (lecture^.enCoursDeLecture = kImplementationUses) then exit(CheckPassageImplementationUses);

    with lecture^ do
      begin
        if ((FindStringInLongString('BEGIN_USE_CLAUSE',ligne) > 0) & doitEtreAccelere) |
           (FindStringInLongString('USES ',ligne) > 0) |
           (FindStringInLongString('uses ',ligne) > 0) then
           begin
             lecture^.enCoursDeLecture := kImplementationUses;
             if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kImplementationUses');

             if ((FindStringInLongString('BEGIN_USE_CLAUSE',ligne) > 0) & doitEtreAccelere)
                then got_BEGIN_USE_CLAUSE := true;

             TraiteImplementationUses;
             CheckPassageImplementationDeclaration;
           end;
      end;
  end;



  procedure CheckPassageImplementationCode;
  begin
    if (lecture^.enCoursDeLecture = kImplementationCode) then exit(CheckPassageImplementationCode);

    if (FindStringInLongString('VAR ',ligne) > 0) |
       (FindStringInLongString('var ',ligne) > 0) |
       (FindStringInLongString('TYPE ',ligne) > 0) |
       (FindStringInLongString('type ',ligne) > 0) |
       (FindStringInLongString('CONST ',ligne) > 0) |
       (FindStringInLongString('const ',ligne) > 0) |
       ((FindStringInLongString('procedure ',ligne) > 0) & (FindStringInLongString('EXTERNAL_NAME',ligne) <= 0)) |
       ((FindStringInLongString('function ',ligne) > 0) & (FindStringInLongString('EXTERNAL_NAME',ligne) <= 0))    then
       begin
         lecture^.enCoursDeLecture := kImplementationCode;
         if lecture^.afficheTransitionsDansFichier then WritelnDansRapport('  ===>  lecture^.enCoursDeLecture = kImplementationCode');

         ParserLigneDePascal(ligne.debutLigne);
       end;
  end;



  procedure CheckEndOfModule;
  begin
    if (lecture^.enCoursDeLecture = kEpilogue) then exit(CheckEndOfModule);

    if LongStringBeginsWith('END.',ligne) |
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

      if (enCoursDeLecture = kImplementationUses) &
         (action = K_COMPILER_IMPLEMENTATION) &
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
        if ((action = K_COMPILER_INTERFACE) & (enCoursDeLecture < kImplementationPrologue)) |
           ((action = K_COMPILER_IMPLEMENTATION) & (enCoursDeLecture >= kImplementationPrologue)) then
        begin
          if (ligne.finLigne = '') then
             ligne.debutLigne := EnleveEspacesDeDroite(ligne.debutLigne);

          {if action = K_COMPILER_INTERFACE
            then err := WriteDansFichierTexte(duplication, 'K_COMPILER_INTERFACE  =>  ')
            else err := WriteDansFichierTexte(duplication, 'K_COMPILER_IMPLEMENTATION  =>  ');}

          {err := WriteDansFichierTexte(duplication, PartieDeModuleToString(enCoursDeLecture) + '  =>  ');}


          err := WriteDansFichierTexte(duplication, ligne.debutLigne);
          err := WriteDansFichierTexte(duplication, ligne.finLigne);
          err := WriteDansFichierTexte(duplication, chr(10));  // chr(10) = LF, make it UNIX !

          if ((ligne.debutLigne = 'IMPLEMENTATION') | (ligne.debutLigne = 'implementation')) &
             doitEtreAccelere then
            begin
              err := WriteDansFichierTexte(duplication, chr(10)+chr(10)+'{BEGIN_USE_CLAUSE}'+chr(10));
            end;

        end;

    end;

end;



var gActionDeCompilationDemandee : actions_de_compilation;


procedure VerifierCeFichierSource(const whichFile : FSSpec);
var lectureRec : LectureModuleRec;
    lecture : LectureModulePtr;
    lectureAddr : SInt64;
    fileName : String255;
    moduleName : String255;
    err : OSErr;
    k : SInt64;
begin

  fileName := GetNameOfFSSpec(whichFile);
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


      if doitEtreAccelere | doitEtrePrelinke then
        begin
          err := CreerDuplicateFile(fileName, duplication);
          if err = NoErr then err := OuvreFichierTexte(duplication);

          if (err = NoErr) & (action  = K_COMPILER_INTERFACE)
            then err := VideFichierTexte(duplication);

          err := SetPositionTeteLectureFinFichierTexte(duplication);
          // WritelnNumDansRapport('apres VideFichierTexte pour '+duplication.nomFichier + ', err = ',err);
        end;

      if doitEtreAccelere & (action = K_COMPILER_IMPLEMENTATION) then
        begin
          err := CreerPrelinkFile(fileName, fichierPrelink);
          if err = NoErr then err := OuvreFichierTexte(fichierPrelink);
          if err = NoErr then err := VideFichierTexte(fichierPrelink);

          // WritelnNumDansRapport('apres VideFichierTexte pour '+fichierPrelink.nomFichier + ', err = ',err);
        end;

      if doitEtrePrelinke & (action = K_COMPILER_INTERFACE) then
        begin
          err := CreerExternalDeclarationsFile(fileName, fichierExternalDeclarations);
          if err = NoErr then err := OuvreFichierTexte(fichierExternalDeclarations);
          if err = NoErr then err := VideFichierTexte(fichierExternalDeclarations);

          // WritelnNumDansRapport('apres VideFichierTexte pour '+fichierExternalDeclarations.nomFichier + ', err = ',err);
        end;



      lectureAddr := SInt64(lecture);

      ForEachLineInFileDo(whichFile,VerifierCetteLigneDansLesSources,lectureAddr);

      DisposeStringSet(whichModule^.symbolesImplementation);
      DisposeStringSet(whichModule^.symbolesDejaPrelinkes);
      DisposeATR(whichModule^.symbolesImplementationATR);



      if (nombreLignesTropLongues > 0) then
        begin
          ChangeFontFaceDansRapport(bold);
          WritelnDansRapport('Le fichier '+fileName+' contient '+NumEnString(nombreLignesTropLongues) + ' lignes trop longues');
          TextNormalDansRapport;
          WritelnDansRapport('');
        end;

      if (nombreDeclarationsIndues > 0) then
        begin
          ChangeFontFaceDansRapport(bold);
          WritelnDansRapport('Le fichier '+fileName+' contient '+NumEnString(nombreDeclarationsIndues) + ' declarations de types ou de globales');
          TextNormalDansRapport;
          WritelnDansRapport('');
        end;

      if not((action = K_COMPILER_INTERFACE) & (enCoursDeLecture = kImplementationPrologue)) &
         not((action = K_COMPILER_IMPLEMENTATION) & (enCoursDeLecture = kEpilogue))  then
        begin
          ChangeFontFaceDansRapport(bold);
          WritelnDansRapport('Le fichier '+fileName+' n''est pas arrivé au bout : ' + PartieDeModuleToString(enCoursDeLecture));
          TextNormalDansRapport;
          WritelnDansRapport('');
        end;

      if doitEtreAccelere | doitEtrePrelinke
        then err := FermeFichierTexte(duplication);

      if doitEtrePrelinke & (action in [K_COMPILER_INTERFACE])
        then err := FermeFichierTexte(fichierExternalDeclarations);


      if doitEtreAccelere & (action in [K_COMPILER_IMPLEMENTATION])
        then err := FermeFichierTexte(fichierPrelink);


    end;

end;




function VerifierCeFichierSourceEtRecursion(var fs : FSSpec; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
var nomFichier : String255;
begin
 {$UNUSED pb,path}


 if not(isFolder) then
   begin
     nomFichier := GetNameOfFSSpec(fs);

     if (gActionDeCompilationDemandee = K_COMPILER_INTERFACE)
       then
         if ModuleDoitEtreAccelere(nomFichier) |
            ModuleDoitEtrePrelinke(nomFichier) then
           begin
             VerifierCeFichierSource(fs);
           end;


    if (gActionDeCompilationDemandee = K_COMPILER_IMPLEMENTATION)
      then
        begin
          if ModuleDoitEtreAccelere(nomFichier) |
             ModuleDoitEtrePrelinke(nomFichier) then
           begin
             VerifierCeFichierSource(fs);
           end;

        end;




   end;

  VerifierCeFichierSourceEtRecursion := false; {ne pas chercher recursivement, sinon mettre := isFolder}
end;


procedure VerifierLesSourcesDeCassio;
var directoryDepart : FSSpec;
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

  codeErreur := MyFSMakeFSSpec(0,0,kPathSourcesDeCassio+':',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MyFSMakeFSSpec(0,0,kPathSourcesDeCassio+':PNL_Libraries',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MyFSMakeFSSpec(0,0,kPathSourcesDeCassio+':Edmond',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MyFSMakeFSSpec(0,0,kPathSourcesDeCassio+':Zebra_book',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);



  (* lecture des implementations *)

  WritelnDansRapport('');
  WritelnDansRapport('Phase 2 : pre-compilation des implementations ');
  WritelnDansRapport('');


  gActionDeCompilationDemandee := K_COMPILER_IMPLEMENTATION;

  codeErreur := MyFSMakeFSSpec(0,0,kPathSourcesDeCassio+':',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MyFSMakeFSSpec(0,0,kPathSourcesDeCassio+':PNL_Libraries',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MyFSMakeFSSpec(0,0,kPathSourcesDeCassio+':Edmond',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);

  codeErreur := MyFSMakeFSSpec(0,0,kPathSourcesDeCassio+':Zebra_book',directoryDepart);
  if (codeErreur = 0) then codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then codeErreur := ScanDirectory(directoryDepart,VerifierCeFichierSourceEtRecursion);


  WritelnDansRapport('');
  WritelnNumDansRapport('Sortie de VerifierLesSourcesDeCassio, codeErreur = ',codeErreur);
end;




END.















