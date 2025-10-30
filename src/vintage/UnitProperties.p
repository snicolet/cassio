UNIT UnitProperties;



INTERFACE







 USES UnitDefCassio;



{initialisation et destruction de l'unité}
procedure InitUnitProperties;
procedure LibereMemoireUnitProperties;


{fonction de Creation et de Destruction de proprietes}
function NewPropertyPtr : PropertyPtr;
procedure DisposePropertyStuff(var p : Property);
procedure DisposePropertyPtr(var p : PropertyPtr);
function SameProperties(prop1,prop2 : Property) : boolean;
function PropertyEstVide(prop : Property) : boolean;
function PropertyEstValide(prop : Property) : boolean;
procedure ViderProperty(var prop : Property);
function DuplicateProperty(prop : Property) : Property;
procedure CopyProperty(source : Property; var dest : Property);
function TypeCastingPourCeStockage(stockage : SInt16) : boolean;


{fonctions de fabrication de proprietes sur les types de base}
function MakeEmptyProperty : Property;
function MakeProperty(QuelGenre : SInt16; QuelleTaille : Size; quellesInfos : Ptr; quelStockage : SInt16) : Property;
function MakeLongintProperty(whichType : SInt16; whichLong : SInt32) : Property;
function MakeRealProperty(whichType : SInt16; whichReal : double) : Property;
function MakeStringProperty(whichType : SInt16; whichString : String255) : Property;
function MakeOthelloSquareProperty(whichType : SInt16; whichSquare : SInt16) : Property;
function MakeOthelloSquareAlphaProperty(whichType : SInt16; whichSquare : SInt16) : Property;
function MakeSquareSetProperty(whichType : SInt16; whichSet : SquareSet) : Property;
function MakeSeptCaracteresProperty(whichType : SInt16; whichSquare : SInt16; whichCaracteres : String255) : Property;
function MakeTripleProperty(whichType : SInt16; whichTriple : Triple) : Property;
function MakeBooleanProperty(whichType : SInt16; whichBoolean : boolean) : Property;
function MakeCharProperty(whichType : SInt16; whichChar : char) : Property;
function MakeArgumentVideProperty(whichType : SInt16) : Property;
function MakeValeurOthelloProperty(whichType : SInt16; whichColor,whichSign : SInt16; whichIntegerValue,centiemes : SInt16) : Property;
function MakeTexteProperty(whichType : SInt16; texte : Ptr; longueur : SInt32) : Property;
function MakeCoupleLongintProperty(whichType : SInt16; whichLongint1,whichLongint2 : SInt32) : Property;
function MakePointeurPropertyProperty(whichType : SInt16; node : GameTree; adresse : PropertyPtr; affRect : rect) : Property;
function MakeSquareCoupleProperty(whichType : SInt16; whichSquare1,whichSquare2 : SInt16) : Property;
function MakeScoringProperty(quelGenreDeReflexion,scorePourNoir : SInt32) : Property;
function MakeQuintupletProperty(whichType : SInt16; whichLong : SInt32; b0,b1,b2,b3 : SInt8) : Property;


{fonctions d'acces aux infos des proprietes sur les types de base}
function GetLongintInfoOfProperty(prop : Property) : SInt32;
function GetRealInfoOfProperty(prop : Property) : double;
function GetStringInfoOfProperty(prop : Property) : String255;
function GetOthelloSquareOfProperty(prop : Property) : SInt16;
function GetOthelloSquareOfPropertyAlpha(prop : Property) : SInt16;
function GetSquareSetOfProperty(prop : Property) : SquareSet;
function GetPackedSquareSetOfProperty(prop : Property) : PackedSquareSet;
procedure GetSquareAndSeptCaracteresOfProperty(prop : Property; var square : SInt16; var septChar : String255);
function GetTripleOfProperty(prop : Property) : Triple;
function GetBooleanOfProperty(prop : Property) : boolean;
function GetCharOfProperty(prop : Property) : char;
procedure GetOthelloValueOfProperty(prop : Property; var whichColor,whichSign,whichIntegerValue,centiemes : SInt16);
function CetteCouleurAAuMoinsUnGainDansProperty(couleur : SInt16; prop : Property) : boolean;
procedure GetTexteOfProperty(prop : Property; var texte : Ptr; var longueur : SInt32);
function GetCouleurOfMoveProperty(prop : Property) : SInt32;
procedure GetCoupleLongintOfProperty(prop : Property; var longint1,longint2 : SInt32);
procedure GetPointeurPropertyOfProperty(prop : Property; var node : GameTree; var adresse : PropertyPtr; var affRect : rect);
function GetPossesseurOfPointeurPropertyProperty(prop : Property) : GameTree;
function GetPropertyPtrOfProperty(prop : Property) : PropertyPtr;
function GetRectangleAffichageOfProperty(prop : Property) : rect;
procedure GetSquareCoupleOfProperty(prop : Property; var square1,square2 : SInt16);
procedure GetQuintupletOfProperty(prop : Property; var theLong : SInt32; var b0,b1,b2,b3 : SInt8);


{fonctions de changement de l'info d'une propriete}
procedure SetLongintInfoOfProperty(var prop : Property; n : SInt32);
procedure SetRealInfoOfProperty(var prop : Property; r : double);
procedure SetStringInfoOfProperty(var prop : Property; s : String255);
procedure SetOthelloSquareOfProperty(var prop : Property; coup : SInt16);
procedure SetOthelloSquareOfPropertyAlpha(var prop : Property; coup : SInt16);
procedure SetSquareSetOfProperty(var prop : Property; ensemble : SquareSet);
procedure SetPackedSquareSetOfProperty(var prop : Property; ensemble : PackedSquareSet);
procedure AddSquareToSquareSetOfProperty(var prop : Property; square : SInt16);
procedure UnionSquareSetOfProperty(var prop : Property; ensemble : SquareSet);
procedure DiffSquareSetOfProperty(var prop : Property; ensemble : SquareSet);
procedure AddSquareToPackedSquareSetOfProperty(var prop : Property; square : SInt16);
procedure UnionPackedSquareSetOfProperty(var prop : Property; ensemble : PackedSquareSet);
procedure DiffPackedSquareSetOfProperty(var prop : Property; ensemble : PackedSquareSet);
procedure SetSquareAndSeptCaracteresOfProperty(var prop : Property; whichSquare : SInt16; whichCaracteres : String255);
procedure SetTripleOfProperty(var prop : Property; t : Triple);
procedure SetBooleanOfProperty(var prop : Property; whichBoolean : boolean);
procedure SetCharOfProperty(var prop : Property; whichChar : char);
procedure SetOthelloValueOfProperty(var prop : Property; whichColor,whichSign : SInt16; whichIntegerValue,centiemes : SInt16);
procedure SetTexteOfProperty(var prop : Property; texte : Ptr; longueur : SInt32);
procedure AddTexteToProperty(var prop : Property; texte : Ptr; longueur : SInt32);
procedure AddStringToTexteProperty(var prop : Property; s : String255);
procedure SetPossesseurOfPointeurPropertyProperty(var prop : Property; noeud : GameTree);
procedure SetPropertyPtrOfProperty(var prop : Property; adresse : PropertyPtr);
procedure SetRectangleAffichageOfProperty(var prop : Property; whichRect : rect);
procedure SetCoupleLongintInfoOfProperty(var prop : Property; whichLongint1,whichLongint2 : SInt32);
procedure SetSquareCoupleOfProperty(var prop : Property; square1,square2 : SInt16);
procedure SetQuintupletOfProperty(var prop : Property; whichLong : SInt32; b0,b1,b2,b3 : SInt8);


{fonction d'ecriture de proprietes dans le rapport}
procedure WritePropertyDansRapport(var prop : Property);
procedure WritelnPropertyDansRapport(var prop : Property);
procedure WriteStringAndPropertyDansRapport(s : String255; var prop : Property);
procedure WritelnStringAndPropertyDansRapport(s : String255; var prop : Property);
procedure WritelnSoldesCreationsPropertiesDansRapport(prefixe : String255);


{fonctions de traductions}
function PropertyTypeToString(whichType : SInt16) : String255;
function PropertyValueToString(prop : Property) : String255;
function PropertyToString(prop : Property) : String255;
function MakePropertyFromString(s : String255) : Property;
function StringToPropertyGenre(s : String255) : SInt16;
function MakeTriple(n : SInt32) : Triple;


{fonctions d'affichage à l'ecran}
procedure DessineLettreOnPropertySquare(var prop : Property; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
procedure EffacerPropertySquare(var prop : Property);


{fonction de symetrie/rotation}
procedure EffectueSymetrieOnProperty(var prop : Property; var axeSymetrie : SInt32; var continuer : boolean);


{fonctions diverses}
function AllPropertyTypes : SetOfPropertyTypes;
function InPropertyTypes(whichGenre : SInt16; whichSet : SetOfPropertyTypes) : boolean;






IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, fp
{$IFC NOT(USE_PRELINK)}
    , UnitStrategie, UnitRapport, UnitNormalisation, UnitScannerUtils, UnitSquareSet, MyStrings
    , UnitServicesMemoire, MyMathUtils, UnitGeometrie, UnitAffichagePlateau, UnitSmartGameBoard, UnitFichierAbstrait ;
{$ELSEC}
    ;
    {$I prelink/Properties.lk}
{$ENDC}


{END_USE_CLAUSE}












procedure InitUnitProperties;
begin
end;

procedure LibereMemoireUnitProperties;
begin
end;


procedure WritelnSoldesCreationsPropertiesDansRapport(prefixe : String255);
begin
  WritelnNumDansRapport(prefixe+'SoldeCreationProperties = ',SoldeCreationProperties);
  WritelnNumDansRapport(prefixe+'SoldeCreationPropertyList = ',SoldeCreationPropertyList);
  WritelnNumDansRapport(prefixe+'SoldeCreationGameTree = ',SoldeCreationGameTree);
  WritelnNumDansRapport(prefixe+'SoldeCreationGameTreeList = ',SoldeCreationGameTreeList);
end;


function NewPropertyPtr : PropertyPtr;
var aux : PropertyPtr;
begin
  aux := PropertyPtr(AllocateMemoryPtrClear(sizeof(Property)));
  if aux <> NIL then aux^ := MakeEmptyProperty;
  NewPropertyPtr := aux;
end;


procedure DisposePropertyStuff(var p : Property);
begin
  dec(SoldeCreationProperties);
  {WriteStringAndPropertyDansRapport('destruction de ',p);
  WritelnNumDansRapport('   => solde = ',SoldeCreationProperties);}

  with p do
   if (stockage = StockageEnLongint)         or    {type casting sur le Ptr ou la taille ? }
      (stockage = StockageEnCaseOthello)     or
      (stockage = StockageEnEnsembleDeCases) or
      (stockage = StockageEnSeptCaracteres)  or
      (stockage = StockageEnTriple)          or
      (stockage = StockageEnBooleen)         or
      (stockage = StockageEnChar)            or
      (stockage = StockageArgumentVide)      or
      (stockage = StockageEnValeurOthello)   or
      (stockage = StockageEnCoupleLongint)   or
      (stockage = StockageEnCoupleCases)     or
      (stockage = StockageEnQuintuplet)
      then
        begin
          info := NIL;
          taille := 0;
        end
      else
        begin
          if (info <> NIL) then DisposeMemoryPtr(info);
          info := NIL;
          taille := 0;
        end;
end;


procedure DisposePropertyPtr(var p : PropertyPtr);
begin
  if p <> NIL then
    begin
      DisposePropertyStuff(p^);
      DisposeMemoryPtr(Ptr(p));
      p := NIL;
    end;
end;

function SameProperties(prop1,prop2 : Property) : boolean;
type longintPtr =  ^SInt32;
var  p1,p2 : longintPtr;
     compteur,borne : SInt32;
begin
  if (prop1.genre = prop2.genre) and (prop1.stockage = prop2.stockage) and (prop1.taille = prop2.taille) then
     begin
       { gestion speciale pour les proprietes dont ou on a fait du type casting :
         il suffit de verifier que  prop1.taille = prop2.taille (deja fait) et
         que prop1.info = prop2.info }
       if (prop1.stockage = StockageEnLongint)         or    {type casting sur le Ptr ou la taille ? }
          (prop1.stockage = StockageEnCaseOthello)     or
          (prop1.stockage = StockageEnEnsembleDeCases) or
          (prop1.stockage = StockageEnSeptCaracteres)  or
          (prop1.stockage = StockageEnTriple)          or
          (prop1.stockage = StockageEnBooleen)         or
          (prop1.stockage = StockageEnChar)            or
          (prop1.stockage = StockageArgumentVide)      or
          (prop1.stockage = StockageEnValeurOthello)   or
          (prop1.stockage = StockageEnCoupleLongint)   or
          (prop1.stockage = StockageEnCoupleCases)     or
          (prop1.stockage = StockageEnQuintuplet)      then
          begin
            SameProperties := (prop1.info = prop2.info) and (prop1.taille = prop2.taille);
            exit;
          end;

       p1 := longintPtr(prop1.info);
       p2 := longintPtr(prop2.info);
       compteur := 0;
       borne := ((prop1.taille+3) div 4);
       repeat
         if ( p1^ <> p2^ ) then
           begin
             SameProperties := false;
             exit;
           end;
         p1 := longintPtr(SInt32(p1)+4);
         p2 := longintPtr(SInt32(p2)+4);
         inc(compteur);
       until (compteur >= borne);
       SameProperties := true;
       exit;
     end;
  SameProperties := false;
end;


function PropertyEstVide(prop : Property) : boolean;
begin
  with prop do
    PropertyEstVide := (genre = UnknowProp) and (taille = 0) and (info = NIL) and (stockage = StockageInconnu);
end;


function PropertyEstValide(prop : Property) : boolean;
begin
  // Attention, PropertyEstValide doit renvoyer true pour une property vide
  // (celles renvoyee par MakeEmptyProperty), sinon CreateOneElementPropertyList
  // risque de boucler et il faut (au moins) changer CreateOneElementPropertyList...
  with prop do
    PropertyEstValide := (genre >= UnknowProp) and (genre <= nbMaxOfPropertyTypes);
end;


procedure ViderProperty(var prop : Property);
begin
  with prop do
   begin
     taille   := 0;
     info     := NIL;
     genre    := UnknowProp;
     stockage := StockageInconnu;
   end;
end;


procedure CopyProperty(source : Property; var dest : Property);
begin
  dest.taille   := source.taille;
  dest.info     := source.info;
  dest.genre    := source.genre;
  dest.stockage := source.stockage;
end;

function TypeCastingPourCeStockage(stockage : SInt16) : boolean;
begin
  TypeCastingPourCeStockage  :=
     (stockage = StockageEnLongint)            or     {type casting sur le Ptr ou la taille ? }
     (stockage = StockageEnCaseOthello)        or
     (stockage = StockageEnEnsembleDeCases)    or
     (stockage = StockageEnSeptCaracteres)     or
     (stockage = StockageEnTriple)             or
     (stockage = StockageEnBooleen)            or
     (stockage = StockageEnChar)               or
     (stockage = StockageArgumentVide)         or
     (stockage = StockageEnValeurOthello)      or
     (stockage = StockageEnCoupleLongint)      or
     (stockage = StockageEnCoupleCases)        or
     (stockage = StockageEnQuintuplet);
end;

function DuplicateProperty(prop : Property) : Property;
var aux : Property;
begin
  if (prop.stockage = StockageEnLongint)            or     {type casting sur le Ptr ou la taille ? }
     (prop.stockage = StockageEnCaseOthello)        or
     (prop.stockage = StockageEnEnsembleDeCases)    or
     (prop.stockage = StockageEnSeptCaracteres)     or
     (prop.stockage = StockageEnTriple)             or
     (prop.stockage = StockageEnBooleen)            or
     (prop.stockage = StockageEnChar)               or
     (prop.stockage = StockageArgumentVide)         or
     (prop.stockage = StockageEnValeurOthello)      or
     (prop.stockage = StockageEnCoupleLongint)      or
     (prop.stockage = StockageEnCoupleCases)        or
     (prop.stockage = StockageEnQuintuplet)
    then
      begin

        CopyProperty(prop,aux);

        inc(SoldeCreationProperties);
        {WriteStringAndPropertyDansRapport('duplication de ',aux);
        WritelnNumDansRapport('   => solde = ',SoldeCreationProperties); }
      end
    else
      begin
			  if (prop.info = NIL) or (prop.taille <= 0)
			    then aux := MakeEmptyProperty
			    else
			      begin
				      with aux do
						    begin
						      genre   := prop.genre;
						      taille  := prop.taille;
						      stockage := prop.stockage;
						      info := AllocateMemoryPtrClear(((taille+3) div 4)*4);
						      if (info <> NIL) then MoveMemory(prop.info,info,taille);
						    end;
						 inc(SoldeCreationProperties);
             {WriteStringAndPropertyDansRapport('duplication de ',aux);
             WritelnNumDansRapport('   => solde = ',SoldeCreationProperties); }
					end;
		  end;
  DuplicateProperty := aux;
end;


function MakeEmptyProperty : Property;
var aux : Property;
begin

  aux.taille := 0;
  aux.info := NIL;
  aux.genre := UnknowProp;
  aux.stockage := StockageInconnu;

  MakeEmptyProperty := aux;

  inc(SoldeCreationProperties);
  {WriteStringAndPropertyDansRapport('creation de ',aux);
  WritelnNumDansRapport('   => solde = ',SoldeCreationProperties); }
end;


function MakeProperty(QuelGenre : SInt16; QuelleTaille : Size; quellesInfos : Ptr; quelStockage : SInt16) : Property;
var aux : Property;
begin

  with aux do
    begin
      taille := QuelleTaille;
      if taille <= 0
        then
          info := NIL
        else
          begin
            info  := AllocateMemoryPtrClear(((QuelleTaille+3) div 4)*4);
            if info <> NIL then MoveMemory(QuellesInfos,info,QuelleTaille);
          end;
      genre := QuelGenre;
      stockage := QuelStockage;
    end;
  MakeProperty := aux;

  inc(SoldeCreationProperties);
  {WriteStringAndPropertyDansRapport('creation de ',aux);
  WritelnNumDansRapport('   => solde = ',SoldeCreationProperties);}
end;

function MakeLongintProperty(whichType : SInt16; whichLong : SInt32) : Property;
var aux : Property;
begin

  with aux do
    begin
      taille := WhichLong;     {attention : type casting}
      info  := NIL;
      genre := whichType;
      stockage := StockageEnLongint;
    end;
  MakeLongintProperty := aux;

  inc(SoldeCreationProperties);
  {WriteStringAndPropertyDansRapport('creation de ',aux);
   WritelnNumDansRapport('   => solde = ',SoldeCreationProperties); }
end;

function MakeCoupleLongintProperty(whichType : SInt16; whichLongint1,whichLongint2 : SInt32) : Property;
var aux : Property;
begin

  with aux do
    begin
      taille  := whichLongint1;          {attention : type casting}
      info    := Ptr(whichLongint2);     {attention : type casting}
      genre   := whichType;
      stockage := StockageEnCoupleLongint;
    end;
  MakeCoupleLongintProperty := aux;

  inc(SoldeCreationProperties);
  {WriteStringAndPropertyDansRapport('creation de ',aux);
   WritelnNumDansRapport('   => solde = ',SoldeCreationProperties); }
end;

function MakeSquareCoupleProperty(whichType : SInt16; whichSquare1,whichSquare2 : SInt16) : Property;
var aux : Property;
begin
  if (whichSquare1 < 11) or (whichSquare1 > 88) or
     (whichSquare2 < 11) or (whichSquare2 > 88)
    then aux := MakeEmptyProperty
    else
      begin
        if (whichType = LineProp) and (whichSquare1 > whichSquare2)  {on ordonne les LineProp...}
          then aux := MakeCoupleLongintProperty(whichType,whichSquare2,whichSquare1)
          else aux := MakeCoupleLongintProperty(whichType,whichSquare1,whichSquare2);
        aux.stockage := StockageEnCoupleCases;
      end;
  MakeSquareCoupleProperty := aux;
end;

function MakePointeurPropertyProperty(whichType : SInt16; node : GameTree; adresse : PropertyPtr; affRect : rect) : Property;
var infosProperty : PropertyLocalisation;
begin
  with infosProperty do
    begin
      possesseur     := node;
      adresseMemoire := adresse;
      rectAffichage := affRect;
      MakePointeurPropertyProperty := MakeProperty(whichType,sizeof(infosProperty),@infosProperty,StockageEnPtrProperty);
    end;
end;

function MakeRealProperty(whichType : SInt16; whichReal : double) : Property;
var r : double;
begin
  r := whichReal;
  MakeRealProperty := MakeProperty(whichType,sizeof(double),@whichReal,StockageEnReal);
end;


function MakeStringProperty(whichType : SInt16; whichString : String255) : Property;
var whichTaille : SInt32;
    aux : Property;
begin
  if whichString = ''
    then
      begin

        with aux do
			    begin
			      taille := 0;         {attention : type casting}
			      info  := NIL;
			      genre := whichType;
			      stockage := StockageEnStr255;
			    end;
			  MakeStringProperty := aux;

			  inc(SoldeCreationProperties);
        {WriteStringAndPropertyDansRapport('creation de (chaine vide)',aux);
        WritelnNumDansRapport('   => solde = ',SoldeCreationProperties);  }

      end
    else
      begin
        whichTaille := LENGTH_OF_STRING(WhichString);
        MakeStringProperty := MakeProperty(whichType,whichTaille,@WhichString[1],StockageEnStr255);
      end;
end;

function MakeOthelloSquareProperty(whichType : SInt16; whichSquare : SInt16) : Property;
var aux : Property;
begin
  if (whichSquare < 11) or (whichSquare > 88)
    then aux := MakeEmptyProperty
    else
      begin
        aux := MakeLongintProperty(whichType,whichSquare);
        aux.stockage := StockageEnCaseOthello;
      end;
  MakeOthelloSquareProperty := aux;
end;

function MakeOthelloSquareAlphaProperty(whichType : SInt16; whichSquare : SInt16) : Property;
var s : String255;
    aux : Property;
begin
  if (whichSquare < 11) or (whichSquare > 88)
    then aux := MakeEmptyProperty
    else
      begin
        s := CoupEnStringEnMinuscules(whichSquare);
        aux := MakeStringProperty(whichType,s);
        aux.stockage := StockageEnCaseOthelloAlpha;
      end;
  MakeOthelloSquareAlphaProperty := aux;
end;

function MakeSquareSetProperty(whichType : SInt16; whichSet : SquareSet) : Property;
var ensembleCompacte : PackedSquareSet;
    aux : Property;
begin
  ensembleCompacte := PackSquareSet(whichSet);

  with aux do
    begin
      MoveMemory(@ensembleCompacte,@taille,8);  {attention : type casting}
      genre := whichType;
      stockage := StockageEnEnsembleDeCases;
    end;
  MakeSquareSetProperty := aux;

  inc(SoldeCreationProperties);
  {WriteStringAndPropertyDansRapport('creation de ',aux);
   WritelnNumDansRapport('   => solde = ',SoldeCreationProperties);  }
end;

function MakeSeptCaracteresProperty(whichType : SInt16; whichSquare : SInt16; whichCaracteres : String255) : Property;
type HuitOctetsRec = packed array[0..7] of UInt8;
var len,i : SInt16;
    aux : Property;
    mesHuitOctets : HuitOctetsRec;
begin
  len := LENGTH_OF_STRING(whichCaracteres);
  if len > 7 then len := 7;
  for i := len + 1 to 7 do
    whichCaracteres[i] := chr(0);

  for i := 1 to 7 do
    mesHuitOctets[i] := ord(whichCaracteres[i]);
  mesHuitOctets[0] := whichSquare;

  with aux do
    begin
      MoveMemory(@mesHuitOctets,@taille,8);  {attention : type casting}
      genre := whichType;
      stockage := StockageEnSeptCaracteres;
    end;
  MakeSeptCaracteresProperty := aux;

  inc(SoldeCreationProperties);
  {WriteStringAndPropertyDansRapport('creation de ',aux);
   WritelnNumDansRapport('   => solde = ',SoldeCreationProperties);  }
end;

function MakeTripleProperty(whichType : SInt16; whichTriple : Triple) : Property;
var aux : Property;
begin
  aux := MakeLongintProperty(whichType,whichTriple.nbTriples);
  aux.stockage := StockageEnTriple;
  MakeTripleProperty := aux;
end;

function MakeBooleanProperty(whichType : SInt16; whichBoolean : boolean) : Property;
var aux : Property;
begin
  if whichBoolean
    then aux := MakeLongintProperty(whichType,1)
    else aux := MakeLongintProperty(whichType,0);
  aux.stockage := StockageEnBooleen;
  MakeBooleanProperty := aux;
end;

function MakeCharProperty(whichType : SInt16; whichChar : char) : Property;
var aux : Property;
begin
  aux := MakeLongintProperty(whichType,ord(whichChar));
  aux.stockage := StockageEnChar;
  MakeCharProperty := aux;
end;

function MakeArgumentVideProperty(whichType : SInt16) : Property;
var aux : Property;
begin
  aux := MakeLongintProperty(whichType,0);
  aux.stockage := StockageArgumentVide;
  MakeArgumentVideProperty := aux;
end;

function MakeValeurOthelloProperty(whichType : SInt16; whichColor,whichSign : SInt16; whichIntegerValue,centiemes : SInt16) : Property;
var aux : Property;
    c : char;
    s1,s2 : String255;
begin

  if (whichIntegerValue = 0) and (centiemes = 0)
    then whichSign := +1;

  c := 'D';
  if whichColor = pionNoir then
    if whichSign >= 0
      then c := 'B'
      else c := 'b';
	if whichColor = pionBlanc then
	  if whichSign >= 0
      then c := 'W'
      else c := 'w';

  if whichIntegerValue < 0 then
    begin
      SysBeep(0);
      WritelnDansRapport('ERREUR : whichIntegerValue < 0 dans MakeValeurOthelloProperty !!');
      whichIntegerValue := -whichIntegerValue;
    end;

  if (whichIntegerValue >= 0) and (whichIntegerValue <= 999)
    then s1 := IntToStr(whichIntegerValue)
    else s1 := '0';

  if (centiemes <= 0) or (centiemes >= 100) then s2 := '.00' else
  if (centiemes >= 0) and (centiemes <= 9)   then s2 := Concat('.0',IntToStr(centiemes)) else
  if (centiemes  >= 10) and (centiemes <= 99)  then s2 := Concat('.',IntToStr(centiemes));

  {
  WriteNumDansRapport('signe = ',whichSign);
  WriteNumDansRapport(', int = ',whichIntegerValue);
  WriteNumDansRapport(', cent = ',centiemes);
  WritelnDansRapport('  => '+ CharToString(c)+s1+s2);
  }

  s1 := s1 + s2;
  aux := MakeSeptCaracteresProperty(whichType,ord(c),s1);
  aux.stockage := StockageEnValeurOthello;
  MakeValeurOthelloProperty := aux;
end;


function MakeTexteProperty(whichType : SInt16; texte : Ptr; longueur : SInt32) : Property;
begin
  if longueur < 0 then longueur := 0;
  MakeTexteProperty := MakeProperty(whichType,longueur,texte,StockageEnTexte);
end;

function MakeScoringProperty(quelGenreDeReflexion,scorePourNoir : SInt32) : Property;
var scoreProperty : Property;
begin

  if ((scorePourNoir < -64) or (scorePourNoir > 64)) and
     not(GenreDeReflexionInSet(quelGenreDeReflexion,[ReflMilieu,ReflRetrogradeMilieu,ReflMilieuExhaustif,ReflZebraBookEval,ReflZebraBookEvalSansDoutePerdant,ReflZebraBookEvalSansDouteGagnant])) then
    begin
      WritelnDansRapport('ERREUR : scorePourNoir = '+IntToStr(scorePourNoir)+' dans MakeScoringProperty(ReflParfait), prévenez Stéphane !');
      Sysbeep(0);
      MakeScoringProperty := MakeEmptyProperty;
      exit;
    end;

  case quelGenreDeReflexion of
    ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif :
      begin
        if (scorePourNoir >= 0)
          then scoreProperty := MakeValeurOthelloProperty(NodeValueProp,pionNoir,+1,scorePourNoir,0)
          else scoreProperty := MakeValeurOthelloProperty(NodeValueProp,pionBlanc,+1,-scorePourNoir,0);

        if odd(scorePourNoir) then
          begin
            Sysbeep(0);
            WritelnNumDansRapport('BIZARRE : score impair dans MakeScoringProperty {1}, scorePourNoir = ',scorePourNoir);
          end;

        if (scorePourNoir > 64) or (scorePourNoir < -64) then
          begin
            Sysbeep(0);
            WritelnNumDansRapport('ASSERT : score out of range dans MakeScoringProperty {2}, scorePourNoir = ',scorePourNoir);
          end;

      end;
    ReflGagnant,ReflRetrogradeGagnant,ReflParfaitExhaustPhaseGagnant, ReflGagnantExhaustif:
      begin
        if (scorePourNoir > 0) then scoreProperty := MakeTripleProperty(GoodForBlackProp,MakeTriple(1)) else
        if (scorePourNoir < 0) then scoreProperty := MakeTripleProperty(GoodForWhiteProp,MakeTriple(1)) else
        if (scorePourNoir = 0) then scoreProperty := MakeValeurOthelloProperty(NodeValueProp,pionNoir,+1,0,0);

        if (scorePourNoir > 64) or (scorePourNoir < -64) then
          begin
            Sysbeep(0);
            WritelnNumDansRapport('ASSERT : score out of range dans MakeScoringProperty {4}, scorePourNoir = ',scorePourNoir);
          end;
      end;
    ReflMilieu,ReflRetrogradeMilieu,ReflMilieuExhaustif :
      begin
        if (scorePourNoir >= 0)
          then scoreProperty := MakeValeurOthelloProperty(ComputerEvaluationProp,pionNoir, +1,scorePourNoir div 100,scorePourNoir mod 100)
          else scoreProperty := MakeValeurOthelloProperty(ComputerEvaluationProp,pionBlanc,+1,(-scorePourNoir) div 100,(-scorePourNoir) mod 100);
      end;
    ReflZebraBookEval :
      begin
        if (scorePourNoir >= 0)
          then scoreProperty := MakeValeurOthelloProperty(ZebraBookProp,pionNoir, +1,scorePourNoir div 100,scorePourNoir mod 100)
          else scoreProperty := MakeValeurOthelloProperty(ZebraBookProp,pionBlanc,+1,(-scorePourNoir) div 100,(-scorePourNoir) mod 100);
      end;
    ReflZebraBookEvalSansDoutePerdant :
      begin
        if (scorePourNoir >= 0)
          then scoreProperty := MakeValeurOthelloProperty(ZebraBookProp,pionNoir, +1,scorePourNoir div 100,scorePourNoir mod 100)
          else scoreProperty := MakeValeurOthelloProperty(ZebraBookProp,pionBlanc,+1,(-scorePourNoir) div 100,(-scorePourNoir) mod 100);
      end;
    ReflZebraBookEvalSansDouteGagnant :
      begin
        if (scorePourNoir >= 0)
          then scoreProperty := MakeValeurOthelloProperty(ZebraBookProp,pionNoir, +1,scorePourNoir div 100,scorePourNoir mod 100)
          else scoreProperty := MakeValeurOthelloProperty(ZebraBookProp,pionBlanc,+1,(-scorePourNoir) div 100,(-scorePourNoir) mod 100);
      end;
    otherwise
      scoreProperty := MakeEmptyProperty;
  end; {case}
  MakeScoringProperty := scoreProperty;
end;

function MakeQuintupletProperty(whichType : SInt16; whichLong : SInt32; b0,b1,b2,b3 : SInt8) : Property;
var theQuintuplet : InfoQuintuplet;
    aux : Property;
begin
  with theQuintuplet do
    begin
      theLong           := whichLong;
      theSignedBytes[0] := b0;
      theSignedBytes[1] := b1;
      theSignedBytes[2] := b2;
      theSignedBytes[3] := b3;


      with aux do
		    begin
		      MoveMemory(@theQuintuplet,@taille,8);  {attention : type casting}
		      genre := whichType;
		      stockage := StockageEnQuintuplet;
		    end;
		  MakeQuintupletProperty := aux;

		  inc(SoldeCreationProperties);
		  WritelnNumDansRapport('sizeof(theQuintuplet) = ',sizeof(theQuintuplet));
		  WriteStringAndPropertyDansRapport('creation de ',aux);
      WritelnNumDansRapport('   => solde = ',SoldeCreationProperties);
    end;
end;




function GetLongintInfoOfProperty(prop : Property) : SInt32;
begin
  GetLongintInfoOfProperty := prop.taille;  {attention : type casting, cf MakeLongintProperty}
end;

function GetRealInfoOfProperty(prop : Property) : double;
type ExtendedPtr =  ^double;
var aux : ExtendedPtr;
begin
 if (prop.info <> NIL)
   then
      begin
        aux := ExtendedPtr(prop.info);
        GetRealInfoOfProperty := aux^;
      end
   else
     GetRealInfoOfProperty := -1.0;
end;

function GetStringInfoOfProperty(prop : Property) : String255;
var s : String255;
    longueur : SInt32;
begin
  GetStringInfoOfProperty := '';
  if prop.info <> NIL then
    begin
      s := '';
      longueur := prop.taille;
      if longueur < 0 then longueur := 0;
      if longueur > 255 then longueur := 255;
      if (longueur > 0) then
        begin
          MoveMemory(prop.info,@s[1],prop.taille);
          SET_LENGTH_OF_STRING(s,longueur);
        end;
      GetStringInfoOfProperty := s;
    end;
end;

function GetOthelloSquareOfProperty(prop : Property) : SInt16;
begin
  GetOthelloSquareOfProperty := GetLongintInfoOfProperty(prop);
end;

function GetOthelloSquareOfPropertyAlpha(prop : Property) : SInt16;
begin
  GetOthelloSquareOfPropertyAlpha := StringEnCoup(GetStringInfoOfProperty(prop));
end;

function GetSquareSetOfProperty(prop : Property) : SquareSet;
var aux : PackedSquareSet;
begin
  if (prop.stockage = StockageEnEnsembleDeCases)
    then
      begin
        MoveMemory(@prop.taille,@aux,8);   {type casting}
        GetSquareSetOfProperty := UnpackSquareSet(aux);
      end
    else
      GetSquareSetOfProperty := [];
end;

function GetPackedSquareSetOfProperty(prop : Property) : PackedSquareSet;
var aux : PackedSquareSet;
begin
  if (prop.stockage = StockageEnEnsembleDeCases)
    then MoveMemory(@prop.taille,@aux,8)   {type casting}
    else aux.private := [];
  GetPackedSquareSetOfProperty := aux;
end;

procedure GetSquareAndSeptCaracteresOfProperty(prop : Property; var square : SInt16; var septChar : String255);
type HuitOctetsRec = packed Array[0..7] of UInt8;
var i : SInt16;
    mesHuitOctets : HuitOctetsRec;
begin
  if (prop.stockage = StockageEnSeptCaracteres)
    then
      begin
        MoveMemory(@prop.taille,@mesHuitOctets,8);   {type casting}

        square := ord(mesHuitOctets[0]);

        septChar := '';
        for i := 1 to 7 do
          if mesHuitOctets[i] <> 0 then septChar := Concat(septChar,chr(mesHuitOctets[i]));
      end
    else
      begin
        square := 0;
        septChar := '';
      end;
end;

function GetTripleOfProperty(prop : Property) : Triple;
var aux : Triple;
begin
  aux.nbTriples := GetLongintInfoOfProperty(prop);
  GetTripleOfProperty := aux;
end;

function GetBooleanOfProperty(prop : Property) : boolean;
var aux : SInt32;
begin
  aux := GetLongintInfoOfProperty(prop);
  GetBooleanOfProperty := (aux <> 0);
end;

function GetCharOfProperty(prop : Property) : char;
var aux : SInt32;
begin
  aux := GetLongintInfoOfProperty(prop);
  if (aux >= 0) and (aux <= 255)
    then GetCharOfProperty := chr(aux)
    else GetCharOfProperty := chr(0);
end;

procedure GetOthelloValueOfProperty(prop : Property; var whichColor,whichSign,whichIntegerValue,centiemes : SInt16);
var theChar,oldStockage : SInt16;
    valueString : String255;
    realValue : double;
    s : String255;
begin
  oldStockage := prop.stockage;
  prop.stockage := StockageEnSeptCaracteres;
  GetSquareAndSeptCaracteresOfProperty(prop,theChar,valueString);
  prop.stockage := oldStockage;

  whichColor := pionVide;
  if (chr(theChar) = 'B') or (chr(theChar) = 'b') then whichColor := pionNoir else
  if (chr(theChar) = 'W') or (chr(theChar) = 'w') then whichColor := pionBlanc;

  whichSign := +1;
  if (chr(theChar) = 'b') or (chr(theChar) = 'w') then whichSign := -1 else
  if (chr(theChar) = 'B') or (chr(theChar) = 'W') then whichSign := +1;

  s := valueString;
  realValue := StringSimpleEnReel(s);
  whichIntegerValue := Trunc(realValue);
  centiemes := Trunc(100*(realValue-1.0*whichIntegerValue )+0.499);

end;

function CetteCouleurAAuMoinsUnGainDansProperty(couleur : SInt16; prop : Property) : boolean;
var couleurDansProp,signe : SInt16;
    scoreEntierDansProp,centiemesDansProp : SInt16;
    scoreMinPourNoir,scoreMaxPourNoir : SInt16;
begin
  CetteCouleurAAuMoinsUnGainDansProperty := false;

  if not(PropertyEstVide(prop)) then
    begin
      scoreMinPourNoir := -64;
      scoreMaxPourNoir := +64;

      case prop.genre of
        NodeValueProp :
          begin
            GetOthelloValueOfProperty(prop,couleurDansProp,signe,scoreEntierDansProp,centiemesDansProp);

            if (scoreEntierDansProp = 0) and (centiemesDansProp = 0)
             then
               begin
                 scoreMinPourNoir := 0;
                 scoreMaxPourNoir := 0;
               end
             else
               begin
                 case couleurDansProp of
                   pionNoir  :
                     if signe >= 0
                       then
                         begin
                           scoreMinPourNoir :=  scoreEntierDansProp;
                           scoreMaxPourNoir :=  scoreEntierDansProp;
                         end
                       else
                         begin
                           scoreMinPourNoir :=  - scoreEntierDansProp;
                           scoreMaxPourNoir :=  - scoreEntierDansProp;
                         end;
                   pionBlanc :
                     if signe >= 0
                       then
                         begin
                           scoreMinPourNoir :=  - scoreEntierDansProp;
                           scoreMaxPourNoir :=  - scoreEntierDansProp;
                         end
                       else
                         begin
                           scoreMinPourNoir :=  scoreEntierDansProp;
                           scoreMaxPourNoir :=  scoreEntierDansProp;
                         end
                   otherwise  {defaut : comme noir}
                     if signe >= 0
                       then
                         begin
                           scoreMinPourNoir :=  scoreEntierDansProp;
                           scoreMaxPourNoir :=  scoreEntierDansProp;
                         end
                       else
                         begin
                           scoreMinPourNoir :=  - scoreEntierDansProp;
                           scoreMaxPourNoir :=  - scoreEntierDansProp;
                         end;
                 end;{case}

                 { cas speciaux venant des properties V[B+] et V[W+] }
                 if (scoreMinPourNoir = 1) and (scoreMaxPourNoir = 1) then
                   begin
                     scoreMinPourNoir := 2;
                     scoreMaxPourNoir := 64;
                   end;
                 if (scoreMinPourNoir = -1) and (scoreMaxPourNoir = -1) then
                   begin
                     scoreMinPourNoir := -64;
                     scoreMaxPourNoir := -2;
                   end;
	             end;
          end;
        GoodForBlackProp :
          begin
            scoreMinPourNoir := 2;
            scoreMaxPourNoir := 64;
          end;
        GoodForWhiteProp :
          begin
            scoreMinPourNoir := -64;
            scoreMaxPourNoir := -2;
          end;
      end; {case}

      CetteCouleurAAuMoinsUnGainDansProperty := ((couleur = pionNoir)  and (scoreMinPourNoir >= 1)) or
                                                ((couleur = pionBlanc) and (scoreMaxPourNoir <= -1));
    end;
end;


procedure GetTexteOfProperty(prop : Property; var texte : Ptr; var longueur : SInt32);
begin
  if prop.stockage = StockageEnTexte then
    begin
      longueur := prop.taille;
      texte := prop.info;
    end;
end;

function GetCouleurOfMoveProperty(prop : Property) : SInt32;
begin
  case prop.genre of
    BlackMoveProp : GetCouleurOfMoveProperty := pionNoir;
    WhiteMoveProp : GetCouleurOfMoveProperty := pionBlanc;
    otherwise       GetCouleurOfMoveProperty := pionVide;
  end; {case}
end;

procedure GetCoupleLongintOfProperty(prop : Property; var longint1,longint2 : SInt32);
begin
  if (prop.stockage = StockageEnCoupleLongint)
    then
      begin
        longint1 := prop.taille;    {attention : type casting}
        longint2 := SInt32(prop.info);
      end
    else
      begin
        longint1 := -1;
        longint2 := -1;
      end;
end;

procedure GetSquareCoupleOfProperty(prop : Property; var square1,square2 : SInt16);
var oldStockage : SInt16;
    aux1,aux2 : SInt32;
begin
  oldStockage := prop.stockage;
  prop.stockage := StockageEnCoupleLongint;
  GetCoupleLongintOfProperty(prop,aux1,aux2);
  prop.stockage := oldStockage;

  square1 := aux1;
  square2 := aux2;
end;

procedure GetQuintupletOfProperty(prop : Property; var theLong : SInt32; var b0,b1,b2,b3 : SInt8);
var theQuintuplet : InfoQuintuplet;
begin
  if (prop.stockage = StockageEnQuintuplet)
    then
      begin
        MoveMemory(@prop.taille,@theQuintuplet,8);   {type casting}
        theLong := theQuintuplet.theLong;
        b0      := theQuintuplet.theSignedBytes[0];
        b1      := theQuintuplet.theSignedBytes[1];
        b2      := theQuintuplet.theSignedBytes[2];
        b3      := theQuintuplet.theSignedBytes[3];
      end
    else
      begin
        theLong := 0;
        b0 := 0;
        b1 := 0;
        b2 := 0;
        b3 := 0;
      end;
end;


procedure GetPointeurPropertyOfProperty(prop : Property; var node : GameTree; var adresse : PropertyPtr; var affRect : rect);
type PropertyLocalisationPtr =  ^PropertyLocalisation;
var infosProperty : PropertyLocalisationPtr;
begin
  if (prop.stockage = StockageEnPtrProperty) and (prop.info <> NIL)
    then
	    begin
	      infosProperty := PropertyLocalisationPtr(prop.info);
	      node    := infosProperty^.possesseur;
	      adresse := infosProperty^.adresseMemoire;
	      affRect := infosProperty^.rectAffichage;
	    end
	  else
	    begin
	      node    := NIL;
	      adresse := NIL;
	      SetRect(affRect,0,0,0,0);
	    end;
end;

function GetPossesseurOfPointeurPropertyProperty(prop : Property) : GameTree;
type PropertyLocalisationPtr =  ^PropertyLocalisation;
var infosProperty : PropertyLocalisationPtr;
begin
  if (prop.stockage = StockageEnPtrProperty) and (prop.info <> NIL)
    then
	    begin
	      infosProperty := PropertyLocalisationPtr(prop.info);
	      GetPossesseurOfPointeurPropertyProperty := infosProperty^.possesseur;
	    end
	  else
	    GetPossesseurOfPointeurPropertyProperty := NIL;
end;

function GetPropertyPtrOfProperty(prop : Property) : PropertyPtr;
type PropertyLocalisationPtr =  ^PropertyLocalisation;
var infosProperty : PropertyLocalisationPtr;
begin
  if (prop.stockage = StockageEnPtrProperty) and (prop.info <> NIL)
    then
	    begin
	      infosProperty := PropertyLocalisationPtr(prop.info);
	      GetPropertyPtrOfProperty := infosProperty^.adresseMemoire;
	    end
	  else
	    GetPropertyPtrOfProperty := NIL;
end;

function GetRectangleAffichageOfProperty(prop : Property) : rect;
type PropertyLocalisationPtr =  ^PropertyLocalisation;
var infosProperty : PropertyLocalisationPtr;
begin
  if (prop.stockage = StockageEnPtrProperty) and (prop.info <> NIL)
    then
	    begin
	      infosProperty := PropertyLocalisationPtr(prop.info);
	      GetRectangleAffichageOfProperty := infosProperty^.rectAffichage;
	    end
	  else
	    GetRectangleAffichageOfProperty := MakeRect(0,0,0,0);
end;

procedure SetLongintInfoOfProperty(var prop : Property; n : SInt32);
begin
  prop.taille := n;
end;

procedure SetRealInfoOfProperty(var prop : Property; r : double);
begin
  with prop do
    if (stockage = StockageEnReal) then
	    begin
	      taille := sizeof(double);
	      if info <> NIL then MoveMemory(@r,info,taille);
	    end;
end;

procedure SetStringInfoOfProperty(var prop : Property; s : String255);
begin
  with prop do
    begin
      if info <> NIL then
        begin
          DisposeMemoryPtr(info);
          info := NIL;
        end;
      if s = ''
        then
          begin
            taille := 0;
            info := NIL;
          end
        else
          begin
            taille := LENGTH_OF_STRING(s);
            info  := AllocateMemoryPtrClear(((taille+3) div 4)*4);
			      if info <> NIL then MoveMemory(@s[1],info,taille);
			    end;
    end;
end;

procedure SetOthelloSquareOfProperty(var prop : Property; coup : SInt16);
begin
  SetLongintInfoOfProperty(prop,coup);
end;

procedure SetOthelloSquareOfPropertyAlpha(var prop : Property; coup : SInt16);
var oldText, newText : String255;
    k : SInt32;
begin
  oldText := GetStringInfoOfProperty(prop);

  k := Pos(':',oldText);
  if (k > 0)
    then newText := CoupEnStringEnMinuscules(coup) + ':' + TPCopy(oldText, k + 1, 255)
    else newText := CoupEnStringEnMinuscules(coup) + ':' + oldText;

  SetStringInfoOfProperty(prop,newText);
end;

procedure SetSquareSetOfProperty(var prop : Property; ensemble : SquareSet);
var aux : PackedSquareSet;
begin
  if (prop.stockage = StockageEnEnsembleDeCases) then
    begin
      aux := PackSquareSet(ensemble);
      MoveMemory(@aux,@prop.taille,8);  {type casting}
    end;
end;

procedure SetPackedSquareSetOfProperty(var prop : Property; ensemble : PackedSquareSet);
begin
  if (prop.stockage = StockageEnEnsembleDeCases) then
    begin
      MoveMemory(@ensemble.private,@prop.taille,8);  {type casting}
    end;
end;

procedure AddSquareToSquareSetOfProperty(var prop : Property; square : SInt16);
begin
  SetSquareSetOfProperty(prop,GetSquareSetOfProperty(prop)+[square]);
end;

procedure UnionSquareSetOfProperty(var prop : Property; ensemble : SquareSet);
begin
  SetSquareSetOfProperty(prop,GetSquareSetOfProperty(prop)+ensemble);
end;

procedure DiffSquareSetOfProperty(var prop : Property; ensemble : SquareSet);
begin
  SetSquareSetOfProperty(prop,GetSquareSetOfProperty(prop)-ensemble);
end;

procedure AddSquareToPackedSquareSetOfProperty(var prop : Property; square : SInt16);
var aux : PackedSquareSet;
begin
  aux := GetPackedSquareSetOfProperty(prop);
  aux.private := aux.private+[(square div 10)*8+(square mod 10)-9];
  SetPackedSquareSetOfProperty(prop,aux);
end;

procedure UnionPackedSquareSetOfProperty(var prop : Property; ensemble : PackedSquareSet);
begin
  SetPackedSquareSetOfProperty(prop,UnionOfPackedSquareSet(GetPackedSquareSetOfProperty(prop),ensemble));
end;

procedure DiffPackedSquareSetOfProperty(var prop : Property; ensemble : PackedSquareSet);
begin
  SetPackedSquareSetOfProperty(prop,DiffOfPackedSquareSet(GetPackedSquareSetOfProperty(prop),ensemble));
end;

procedure SetSquareAndSeptCaracteresOfProperty(var prop : Property; whichSquare : SInt16; whichCaracteres : String255);
type HuitOctetsRec = packed array[0..7] of UInt8;
var len,i : SInt16;
    mesHuitOctets : HuitOctetsRec;
begin
  if (prop.stockage = StockageEnSeptCaracteres) then
    begin
      len := LENGTH_OF_STRING(whichCaracteres);
      if len > 7 then len := 7;
      for i := len+1 to 7 do
        whichCaracteres[i] := chr(0);

      for i := 1 to 7 do
        mesHuitOctets[i] := ord(whichCaracteres[i]);
      mesHuitOctets[0] := whichSquare;

      MoveMemory(@mesHuitOctets,@prop.taille,8);    {type casting}
    end;
end;

procedure SetTripleOfProperty(var prop : Property; t : Triple);
begin
   SetLongintInfoOfProperty(prop,t.nbTriples);
end;

procedure SetBooleanOfProperty(var prop : Property; whichBoolean : boolean);
begin
  if whichBoolean
    then SetLongintInfoOfProperty(prop,1)
    else SetLongintInfoOfProperty(prop,0);
end;

procedure SetCharOfProperty(var prop : Property; whichChar : char);
begin
  SetLongintInfoOfProperty(prop,ord(whichChar));
end;

procedure SetOthelloValueOfProperty(var prop : Property; whichColor,whichSign : SInt16; whichIntegerValue,centiemes : SInt16);
var c : char;
    s1,s2 : String255;
    oldStockage : SInt16;
begin

  if (whichIntegerValue = 0) and (centiemes = 0)
    then whichSign := +1;

  c := 'D';
  if whichColor = pionNoir then
    if whichSign >= 0
      then c := 'B'
      else c := 'b';
	if whichColor = pionBlanc then
	  if whichSign >= 0
      then c := 'W'
      else c := 'w';

  if whichIntegerValue < 0 then
    begin
      SysBeep(0);
      WritelnDansRapport('ERREUR : whichIntegerValue < 0 dans SetOthelloValueOfProperty !!');
      whichIntegerValue := -whichIntegerValue;
    end;

  if (whichIntegerValue >= 0) and (whichIntegerValue <= 999)
    then s1 := IntToStr(whichIntegerValue)
    else s1 := '0';

  if (centiemes <= 0) or (centiemes >= 100) then s2 := '.00' else
  if (centiemes  >= 1)  and (centiemes <= 9)   then s2 := Concat('.0',IntToStr(centiemes)) else
  if (centiemes  >= 10) and (centiemes <= 99)  then s2 := Concat('.',IntToStr(centiemes));

  oldStockage := prop.stockage;
  prop.stockage := StockageEnSeptCaracteres;
  s1 := s1 + s2;
  SetSquareAndSeptCaracteresOfProperty(prop,ord(c),s1);
  prop.stockage := oldStockage;
end;


procedure SetTexteOfProperty(var prop : Property; texte : Ptr; longueur : SInt32);
begin
  if prop.stockage = StockageEnTexte then
    begin
      prop.taille := 0;
      if prop.info <> NIL then
        begin
          DisposeMemoryPtr(prop.info);
          prop.info := NIL;
        end;
      prop := MakeTexteProperty(prop.genre,texte,longueur);
      dec(SoldeCreationProperties);   {car en fait il s'agit d'un remplacement}
    end;
end;


procedure AddTexteToProperty(var prop : Property; texte : Ptr; longueur : SInt32);
var oldTaille,newTaille : SInt32;
    newSpace : Ptr;
begin
  if (prop.stockage = StockageEnTexte) and (longueur > 0) then
    begin
      if (prop.taille <= 0) or (prop.info = NIL)
        then SetTexteOfProperty(prop,texte,longueur)
        else
          begin
            oldTaille := prop.taille;
            newTaille := oldTaille+longueur;
            newSpace := AllocateMemoryPtr(((newTaille+3) div 4)*4);
            if newSpace <> NIL then
              begin
                MoveMemory(prop.info,newSpace,oldTaille);
                MoveMemory(texte,POINTER_ADD(newSpace , oldTaille),longueur);
                DisposeMemoryPtr(prop.info);
                prop.info := newSpace;
                prop.taille := newTaille;
              end;
          end;
    end;
end;

procedure AddStringToTexteProperty(var prop : Property; s : String255);
begin
  AddTexteToProperty(prop,@s[1],LENGTH_OF_STRING(s));
end;

procedure SetPossesseurOfPointeurPropertyProperty(var prop : Property; noeud : GameTree);
type PropertyLocalisationPtr =  ^PropertyLocalisation;
var infosProperty : PropertyLocalisationPtr;
begin
  if (prop.stockage = StockageEnPtrProperty) and (prop.info <> NIL)
    then
	    begin
	      infosProperty := PropertyLocalisationPtr(prop.info);
	      infosProperty^.possesseur := noeud;
	    end;
end;

procedure SetPropertyPtrOfProperty(var prop : Property; adresse : PropertyPtr);
type PropertyLocalisationPtr =  ^PropertyLocalisation;
var infosProperty : PropertyLocalisationPtr;
begin
  if (prop.stockage = StockageEnPtrProperty) and (prop.info <> NIL)
    then
	    begin
	      infosProperty := PropertyLocalisationPtr(prop.info);
	      infosProperty^.adresseMemoire := adresse;
	    end;
end;

procedure SetRectangleAffichageOfProperty(var prop : Property; whichRect : rect);
type PropertyLocalisationPtr =  ^PropertyLocalisation;
var infosProperty : PropertyLocalisationPtr;
begin
  if (prop.stockage = StockageEnPtrProperty) and (prop.info <> NIL)
    then
	    begin
	      infosProperty := PropertyLocalisationPtr(prop.info);
	      infosProperty^.rectAffichage := whichRect;
	    end;
end;

procedure SetCoupleLongintInfoOfProperty(var prop : Property; whichLongint1,whichLongint2 : SInt32);
begin
  if (prop.genre = LineProp) and (whichLongint1 > whichLongint2)  {on ordonne les LineProp...}
    then
      begin
        prop.taille  := whichLongint2;          {attention : type casting}
        prop.info    := Ptr(whichLongint1);     {attention : type casting}
      end
    else  {cas normal}
      begin
	      prop.taille  := whichLongint1;          {attention : type casting}
        prop.info    := Ptr(whichLongint2);     {attention : type casting}
      end
end;

procedure SetSquareCoupleOfProperty(var prop : Property; square1,square2 : SInt16);
begin
  SetCoupleLongintInfoOfProperty(prop,square1,square2);
end;

procedure SetQuintupletOfProperty(var prop : Property; whichLong : SInt32; b0,b1,b2,b3 : SInt8);
var theQuintuplet : InfoQuintuplet;
begin
  if (prop.stockage = StockageEnQuintuplet) then
	  with theQuintuplet do
	    begin
	      theLong           := whichLong;
	      theSignedBytes[0] := b0;
	      theSignedBytes[1] := b1;
	      theSignedBytes[2] := b2;
	      theSignedBytes[3] := b3;

	      MoveMemory(@theQuintuplet,@prop.taille,8);    {type casting}
	    end;
end;

procedure WritePropertyDansRapport(var prop : Property);
var s : String255;
    textePtr : Ptr;
    longueurTexte : SInt32;
begin
   {
   WritelnNumDansRapport('prop.genre = ',prop.genre);
   WritelnNumDansRapport('prop.stockage = ',prop.stockage);
   WritelnNumDansRapport('prop.taille = ',prop.taille);
   WritelnNumDansRapport('prop.data = ',SInt32(prop.info));
   }

   if PropertyEstVide(prop)
     then WriteDansRapport('PropVide')
     else
       begin
         if prop.stockage = StockageEnTexte
           then
             begin
               s := PropertyTypeToString(prop.genre);
               WriteDansRapport(s+'[');
					     GetTexteOfProperty(prop,textePtr,longueurTexte);
					     InsereTexteDansRapport(textePtr,longueurTexte);
					     WriteDansRapport(']');
             end
           else
             begin
               s := PropertyToString(prop);
               WriteDansRapport(s);
             end;
       end;
end;


(* Attention : cette fonction est **LENTE** et non utilisable pendant la lecture SGF,
   qui n'est pas reentrante ! Ecrire une version plus efficace si on a besoin d'une
   utilisation massive... *)
function MakePropertyFromString(s : String255) : Property;
var myZone : FichierAbstrait;
    theProp : Property;
begin

  if (Pos('[', s) > 0) and (Pos(']', s) > 0) and not(LectureSmartGameBoardEnCours)
    then
      begin
        myZone := MakeFichierAbstraitFromString(s);
        BeginLectureSmartGameBoard(myZone);
        LectureSmartGameBoard.reportErrors := false;
        theProp := LitProperty;
        EndLectureSmartGameBoard;
        DisposeFichierAbstrait(myZone);

        MakePropertyFromString := theProp;
      end
    else
      begin
        MakePropertyFromString := MakeEmptyProperty;
      end;
end;


procedure WritelnPropertyDansRapport(var prop : Property);
begin
  WritePropertyDansRapport(prop);
  WritelnDansRapport('');
end;

procedure WriteStringAndPropertyDansRapport(s : String255; var prop : Property);
begin
  WriteDansRapport(s);
  WritePropertyDansRapport(prop);
end;

procedure WritelnStringAndPropertyDansRapport(s : String255; var prop : Property);
begin
  WriteDansRapport(s);
  WritelnPropertyDansRapport(prop);
end;


function StringToPropertyGenre(s : String255) : SInt16;
begin

  StringToPropertyGenre := UnknowProp;

  if s = 'B'     then StringToPropertyGenre := BlackMoveProp                 else
  if s = 'W'     then StringToPropertyGenre := WhiteMoveProp                 else
  if s = 'C'     then StringToPropertyGenre := CommentProp                   else
  if s = 'N'     then StringToPropertyGenre := NodeNameProp                  else
  if s = 'V'     then StringToPropertyGenre := NodeValueProp                 else
  if s = 'CH'    then StringToPropertyGenre := CheckMarkProp                 else
  if s = 'GB'    then StringToPropertyGenre := GoodForBlackProp              else
  if s = 'GW'    then StringToPropertyGenre := GoodForWhiteProp              else
  if s = 'TE'    then StringToPropertyGenre := TesujiProp                    else
  if s = 'BM'    then StringToPropertyGenre := BadMoveProp                   else
  if s = 'BL'    then StringToPropertyGenre := TimeLeftBlackProp             else
  if s = 'WL'    then StringToPropertyGenre := TimeLeftWhiteProp             else
  if s = 'FG'    then StringToPropertyGenre := FigureProp                    else
  if s = 'AB'    then StringToPropertyGenre := AddBlackStoneProp             else
  if s = 'AW'    then StringToPropertyGenre := AddWhiteStoneProp             else
  if s = 'AE'    then StringToPropertyGenre := RemoveStoneProp               else
  if s = 'PL'    then StringToPropertyGenre := PlayerToPlayFirstProp         else
  if s = 'GN'    then StringToPropertyGenre := GameNameProp                  else
  if s = 'GC'    then StringToPropertyGenre := GameCommentProp               else
  if s = 'EV'    then StringToPropertyGenre := EventProp                     else
  if s = 'PC'    then StringToPropertyGenre := PlaceProp                     else
  if s = 'RO'    then StringToPropertyGenre := RoundProp                     else
  if s = 'DT'    then StringToPropertyGenre := DateProp                      else
  if s = 'PB'    then StringToPropertyGenre := BlackPlayerNameProp           else
  if s = 'PW'    then StringToPropertyGenre := WhitePlayerNameProp           else
  if s = 'RE'    then StringToPropertyGenre := ResultProp                    else
  if s = 'US'    then StringToPropertyGenre := UserProp                      else
  if s = 'TM'    then StringToPropertyGenre := TimeLimitByPlayerProp         else
  if s = 'SO'    then StringToPropertyGenre := SourceProp                    else
  if s = 'GM'    then StringToPropertyGenre := GameNumberIDProp              else
  if s = 'SZ'    then StringToPropertyGenre := BoardSizeProp                 else
  if s = 'VW'    then StringToPropertyGenre := PartialViewProp               else
  if s = 'BS'    then StringToPropertyGenre := BlackSpeciesProp              else
  if s = 'WS'    then StringToPropertyGenre := WhiteSpeciesProp              else
  if s = 'EL'    then StringToPropertyGenre := ComputerEvaluationProp        else
  if s = 'EX'    then StringToPropertyGenre := ExpectedNextMoveProp          else
  if s = 'SL'    then StringToPropertyGenre := SelectedPointsProp            else
  if s = 'M'     then StringToPropertyGenre := MarkedPointsProp              else
  if s = 'MA'    then StringToPropertyGenre := MarkedPointsProp              else
  if s = 'L'     then StringToPropertyGenre := LabelOnPointsProp             else
  if s = 'LB'    then StringToPropertyGenre := LabelOnPointsProp             else
  if s = 'BR'    then StringToPropertyGenre := BlackRankProp                 else
  if s = 'WR'    then StringToPropertyGenre := WhiteRankProp                 else
  if s = 'HA'    then StringToPropertyGenre := HandicapProp                  else
  if s = 'KM'    then StringToPropertyGenre := KomiProp                      else
  if s = 'TB'    then StringToPropertyGenre := BlackTerritoryProp            else
  if s = 'TW'    then StringToPropertyGenre := WhiteTerritoryProp            else
  if s = 'SC'    then StringToPropertyGenre := SecureStonesProp              else
  if s = 'RG'    then StringToPropertyGenre := RegionOfTheBoardProp          else
  if s = 'PE'    then StringToPropertyGenre := PerfectScoreProp              else
  if s = 'OS'    then StringToPropertyGenre := OptimalScoreProp              else
  if s = 'OE'    then StringToPropertyGenre := EmptiesForOptimalScoreProp    else

  {propriétés non définies dans la thèse de Kierulf, mais dont je suis "sûr"}
  if s = 'WT'    then StringToPropertyGenre := WhiteTeamProp                 else
  if s = 'BT'    then StringToPropertyGenre := BlackTeamProp                 else
  if s = 'ON'    then StringToPropertyGenre := OpeningNameProp               else
  if s = 'FF'    then StringToPropertyGenre := FileFormatProp                else
  if s = 'F'     then StringToPropertyGenre := FlippedProp                   else
  if s = 'DM'    then StringToPropertyGenre := DrawMarkProp                  else
  if s = 'IT'    then StringToPropertyGenre := InterestingMoveProp           else
  if s = 'DO'    then StringToPropertyGenre := DubiousMoveProp               else
  if s = 'DE'    then StringToPropertyGenre := DepthProp                     else
  if s = 'UC'    then StringToPropertyGenre := UnclearPositionProp           else


  {propriétés definies par Cassio, old way}
  if s = 'dw'    then StringToPropertyGenre := DeltaWhiteProp                else
  if s = 'db'    then StringToPropertyGenre := DeltaBlackProp                else
  if s = 'lw'    then StringToPropertyGenre := LosangeWhiteProp              else
  if s = 'lb'    then StringToPropertyGenre := LosangeBlackProp              else
  if s = 'le'    then StringToPropertyGenre := LosangeProp                   else
  if s = 'cw'    then StringToPropertyGenre := CarreWhiteProp                else
  if s = 'cb'    then StringToPropertyGenre := CarreBlackProp                else
  if s = 'ce'    then StringToPropertyGenre := CarreProp                     else
  if s = 'st'    then StringToPropertyGenre := EtoileProp                    else
  if s = 'pw'    then StringToPropertyGenre := PetitCercleWhiteProp          else
  if s = 'pb'    then StringToPropertyGenre := PetitCercleBlackProp          else
  if s = 'rp'    then StringToPropertyGenre := RapportProp                   else
  {propriétés definies par Cassio, better way (uppercase)}
  if s = 'DW'    then StringToPropertyGenre := DeltaWhiteProp                else
  if s = 'DB'    then StringToPropertyGenre := DeltaBlackProp                else
  if s = 'TR'    then StringToPropertyGenre := DeltaProp                     else
  if s = 'FW'    then StringToPropertyGenre := LosangeWhiteProp              else
  if s = 'FB'    then StringToPropertyGenre := LosangeBlackProp              else
  if s = 'RG'    then StringToPropertyGenre := LosangeProp                   else
  if s = 'SQ'    then StringToPropertyGenre := CarreProp                     else
  if s = 'SR'    then StringToPropertyGenre := EtoileProp                    else
  if s = 'CW'    then StringToPropertyGenre := PetitCercleWhiteProp          else
  if s = 'CB'    then StringToPropertyGenre := PetitCercleBlackProp          else
  if s = 'CR'    then StringToPropertyGenre := PetitCercleProp               else
  if s = 'IN'    then StringToPropertyGenre := TranspositionProp             else
  if s = 'RP'    then StringToPropertyGenre := RapportProp                   else
  if s = 'VN'    then StringToPropertyGenre := ValueMinProp                  else
  if s = 'VX'    then StringToPropertyGenre := ValueMaxProp                  else
  if s = 'TT'    then StringToPropertyGenre := TimeTakenProp                 else
  if s = 'SI'    then StringToPropertyGenre := SigmaProp                     else
  if s = 'WZ'    then StringToPropertyGenre := ZebraBookProp                 else
  if s = 'XT'    then StringToPropertyGenre := ExoticMoveProp                else

  {proprietes de SGF FF[4]}
  if s = 'HO'    then StringToPropertyGenre := HotSpotProp                   else
  if s = 'PD'    then StringToPropertyGenre := PDProp                        else
  if s = 'AP'    then StringToPropertyGenre := ApplicationProp               else
  if s = 'CA'    then StringToPropertyGenre := CharSetProp                   else
  if s = 'ST'    then StringToPropertyGenre := StyleOfDisplayProp            else
  if s = 'DD'    then StringToPropertyGenre := DimPointsProp                 else
  if s = 'CP'    then StringToPropertyGenre := CopyrightProp                 else
  if s = 'AN'    then StringToPropertyGenre := AnnotatorProp                 else
  if s = 'AR'    then StringToPropertyGenre := ArrowProp                     else
  if s = 'LN'    then StringToPropertyGenre := LineProp                      ;

end;


function PropertyTypeToString(whichType : SInt16) : String255;
begin
  case whichType of
    BlackMoveProp              : PropertyTypeToString := 'B';
    WhiteMoveProp              : PropertyTypeToString := 'W';
    CommentProp                : PropertyTypeToString := 'C';
    NodeNameProp               : PropertyTypeToString := 'N';
    NodeValueProp              : PropertyTypeToString := 'V';
    CheckMarkProp              : PropertyTypeToString := 'CH';
    GoodForBlackProp           : PropertyTypeToString := 'GB';
    GoodForWhiteProp 	         : PropertyTypeToString := 'GW';
    TesujiProp                 : PropertyTypeToString := 'TE';
    BadMoveProp                : PropertyTypeToString := 'BM';
    TimeLeftBlackProp          : PropertyTypeToString := 'BL';
    TimeLeftWhiteProp          : PropertyTypeToString := 'WL';
    FigureProp                 : PropertyTypeToString := 'FG';
    AddBlackStoneProp          : PropertyTypeToString := 'AB';
    AddWhiteStoneProp          : PropertyTypeToString := 'AW';
    RemoveStoneProp            : PropertyTypeToString := 'AE';
    PlayerToPlayFirstProp      : PropertyTypeToString := 'PL';
    GameNameProp               : PropertyTypeToString := 'GN';
    GameCommentProp            : PropertyTypeToString := 'GC';
    EventProp                  : PropertyTypeToString := 'EV';
    RoundProp                  : PropertyTypeToString := 'RO';
    DateProp                   : PropertyTypeToString := 'DT';
    PlaceProp                  : PropertyTypeToString := 'PC';
    BlackPlayerNameProp        : PropertyTypeToString := 'PB';
    WhitePlayerNameProp        : PropertyTypeToString := 'PW';
    ResultProp                 : PropertyTypeToString := 'RE';
    UserProp                   : PropertyTypeToString := 'US';
    TimeLimitByPlayerProp      : PropertyTypeToString := 'TM';
    SourceProp                 : PropertyTypeToString := 'SO';
    GameNumberIDProp           : PropertyTypeToString := 'GM';  {Go = 1, Othello = 2, chess = 3, Nine Men's Morris = 5}

    BoardSizeProp              : PropertyTypeToString := 'SZ';
    PartialViewProp            : PropertyTypeToString := 'VW';
    BlackSpeciesProp           : PropertyTypeToString := 'BS';  {human = 0, modem = -1, computer > 0}
    WhiteSpeciesProp           : PropertyTypeToString := 'WS';  {human = 0, modem = -1, computer > 0}
    ComputerEvaluationProp     : PropertyTypeToString := 'EL';
    ExpectedNextMoveProp       : PropertyTypeToString := 'EX';

    SelectedPointsProp         : PropertyTypeToString := 'SL';
    MarkedPointsProp           : PropertyTypeToString := 'MA';
   {MarkedPointsProp           : PropertyTypeToString := 'M';}  {obsolete in FF[4]}
    LabelOnPointsProp          : PropertyTypeToString := 'LB';
   {LabelOnPointsProp          : PropertyTypeToString := 'L';}  {obsolete in FF[4]}
    ArrowProp                  : PropertyTypeToString := 'AR';
    LineProp                   : PropertyTypeToString := 'LN';

    BlackRankProp              : PropertyTypeToString := 'BR';
    WhiteRankProp              : PropertyTypeToString := 'WR';
    HandicapProp               : PropertyTypeToString := 'HA';
    KomiProp                   : PropertyTypeToString := 'KM';

    BlackTerritoryProp         : PropertyTypeToString := 'TB';
    WhiteTerritoryProp         : PropertyTypeToString := 'TW';
    SecureStonesProp           : PropertyTypeToString := 'SC';
    RegionOfTheBoardProp       : PropertyTypeToString := 'RG';

    PerfectScoreProp           : PropertyTypeToString := 'PE';
    OptimalScoreProp           : PropertyTypeToString := 'OS';
    EmptiesForOptimalScoreProp : PropertyTypeToString := 'OE';

    {propriétés non définies dans la thèse de Kierulf, mais dont je suis "sûr"}
    WhiteTeamProp              : PropertyTypeToString := 'WT';
    BlackTeamProp              : PropertyTypeToString := 'BT';
    OpeningNameProp            : PropertyTypeToString := 'ON';
    FileFormatProp             : PropertyTypeToString := 'FF';
    FlippedProp                : PropertyTypeToString := 'F';
    DrawMarkProp               : PropertyTypeToString := 'DM';
    InterestingMoveProp        : PropertyTypeToString := 'IT';
    DubiousMoveProp            : PropertyTypeToString := 'DO';
    DepthProp                  : PropertyTypeToString := 'DE';
    UnclearPositionProp        : PropertyTypeToString := 'UC';

    {propriétés tres utiles pour Cassio}
    DeltaWhiteProp             : PropertyTypeToString := 'DW';
    DeltaBlackProp             : PropertyTypeToString := 'DB';
    DeltaProp                  : PropertyTypeToString := 'TR';
    LosangeWhiteProp           : PropertyTypeToString := 'FW';
    LosangeBlackProp           : PropertyTypeToString := 'FB';
   {LosangeProp                : PropertyTypeToString := 'RG';   obsoletes car on
    CarreWhiteProp             : PropertyTypeToString := 'TW';   préfère utiliser les
    CarreBlackProp             : PropertyTypeToString := 'TB';   propriétés de FF[4]}
    CarreProp                  : PropertyTypeToString := 'SQ';
    EtoileProp                 : PropertyTypeToString := 'SR';
    PetitCercleWhiteProp       : PropertyTypeToString := 'CW';
    PetitCercleBlackProp       : PropertyTypeToString := 'CB';
    PetitCercleProp            : PropertyTypeToString := 'CR';
    TranspositionProp          : PropertyTypeToString := 'IN';
    RapportProp                : PropertyTypeToString := 'rp';
    BlackPassProp              : PropertyTypeToString := 'B';
    WhitePassProp              : PropertyTypeToString := 'W';
    ValueMinProp               : PropertyTypeToString := 'VN';
    ValueMaxProp               : PropertyTypeToString := 'VX';
    SigmaProp                  : PropertyTypeToString := 'SI';
    TimeTakenProp              : PropertyTypeToString := 'TT';
    ExoticMoveProp             : PropertyTypeToString := 'XT';

    {propriétés de SGF FF[4]}
    HotSpotProp                : PropertyTypeToString := 'HO';
    PDProp                     : PropertyTypeToString := 'PD';
    ApplicationProp            : PropertyTypeToString := 'AP';
    CharSetProp                : PropertyTypeToString := 'CA';
    StyleOfDisplayProp         : PropertyTypeToString := 'ST';
    DimPointsProp              : PropertyTypeToString := 'DD';
    CopyrightProp              : PropertyTypeToString := 'CP';
    AnnotatorProp              : PropertyTypeToString := 'AN';


    {autres proprietes, internes}
    MarquageProp               : PropertyTypeToString := 'mq';  {property speciale de marquage temporaire}
    VerbatimProp               : PropertyTypeToString := 'vr';  {property pour remettre exactement dans le fichier ce qu'on y a lu}
    PointeurPropertyProp       : PropertyTypeToString := 'pp';  {property pour stocker un Ptr sur le noeud, l'adresse et le rectangle d'affichage d'une autre property}
    ZebraBookProp              : PropertyTypeToString := 'WZ';  {property pour afficher les valeurs du book de Zebra}



    otherwise                    PropertyTypeToString := '??';
  end {case}
end;


function PropertyValueToString(prop : Property) : String255;
var s,s1 : String255;
    septCaracteres : String255;
    whichSquare : SInt16;
    whichTriple : Triple;
    theColor,theSign : SInt16;
    theIntValue,theCentiemes : SInt16;
    longint1,longint2 : SInt32;
    whichSquare1,whichSquare2 : SInt16;
    node : GameTree;
    adresse : PropertyPtr;
    affRect : rect;
begin
  if not(PropertyEstVide(prop)) then
    begin
      case prop.stockage of
        StockageInconnu            : s := '[stockage inconnu !!]';
        StockageEnLongint          : s := Concat('[',IntToStr(GetLongintInfoOfProperty(prop)),']');
        StockageEnCoupleLongint    : begin
                                       GetCoupleLongintOfProperty(prop,longint1,longint2);
                                       s := Concat('[(',IntToStr(longint1),',',IntToStr(longint2),')]');
                                     end;
        StockageEnReal             : s := Concat('[',ReelEnStringAvecDecimales(GetRealInfoOfProperty(prop),6),']');
        StockageEnStr255           : s := Concat('[',GetStringInfoOfProperty(prop),']');
        StockageEnCaseOthello      : begin
                                       whichSquare := GetOthelloSquareOfProperty(prop);
                                       if whichSquare = CoupSpecialPourPasse
                                         then s := '[tt]'
                                         else s := Concat('[',CoupEnStringEnMinuscules(whichSquare),']');
                                     end;
        StockageEnCaseOthelloAlpha : s := Concat('[',GetStringInfoOfProperty(prop),']');
        StockageEnEnsembleDeCases  : s := PackedSquareSetEnString(GetPackedSquareSetOfProperty(prop));
        StockageEnCoupleCases      : begin
                                       GetSquareCoupleOfProperty(prop,whichSquare1,whichSquare2);
                                       s := Concat('[',CoupEnStringEnMinuscules(whichSquare1),':',CoupEnStringEnMinuscules(whichSquare2),']');
                                     end;
        StockageEnTexte            : s := '[texte > 255 octets !!!]';
        StockageEnSeptCaracteres   : begin
                                       GetSquareAndSeptCaracteresOfProperty(prop,whichSquare,septCaracteres);
                                       s := Concat('[',CoupEnStringEnMinuscules(whichSquare),',',septCaracteres,']');
                                     end;
        StockageEnTriple           : begin
                                       whichTriple := GetTripleOfProperty(prop);
                                       s := Concat('[',IntToStr(whichTriple.nbTriples),']');
                                     end;
        StockageEnBooleen          : if GetBooleanOfProperty(prop)
                                       then s := '[true]'
                                       else s := '[false]';
        StockageEnChar             : s := Concat('[',GetCharOfProperty(prop),']');
        StockageArgumentVide       : if (prop.genre = BlackPassProp) or (prop.genre = WhitePassProp)
                                       then s := '[tt]'
                                       else s := '[]';
        StockageEnValeurOthello    : begin
                                       GetOthelloValueOfProperty(prop,theColor,theSign,theIntValue,theCentiemes);
                                       if (theIntValue = 0) and (theCentiemes = 0)
                                         then s := '[0]'
                                         else
                                           begin
			                                       case theColor of
			                                         pionNoir  : s := '[B';
			                                         pionBlanc : s := '[W';
			                                         otherwise   s := '[';
			                                       end;{case}

			                                       if (theIntValue >= 0)
			                                         then
			                                           if (theSign >= 0)
			                                             then s := Concat(s,'+',IntToStr(theIntValue))
			                                             else s := Concat(s,'-',IntToStr(theIntValue))
			                                         else
			                                           if (theSign >= 0)
			                                             then s := Concat(s,'-',IntToStr(-theIntValue))
			                                             else s := Concat(s,'+',IntToStr(-theIntValue));

			                                       {toujours ecrire la partie decimale}
			                                       if (theCentiemes > 0) or (prop.genre = ComputerEvaluationProp) or (prop.genre = ZebraBookProp) then
			                                         begin
					                                       s1 := IntToStr(theCentiemes);
					                                       if (theCentiemes <= 9)
					                                         then s := Concat(s,'.0',s1)
					                                         else s := Concat(s,'.',s1);
					                                     end;

			                                       s := s + ']';
			                                    end;
                                     end;
        StockageEnPtrProperty      : begin
                                       node := GetPossesseurOfPointeurPropertyProperty(prop);
                                       adresse := GetPropertyPtrOfProperty(prop);
                                       affRect := GetRectangleAffichageOfProperty(prop);
                                       s := '[';
                                       if node = NIL
                                         then s := s + 'NIL,'
                                         else s := s + '@'+IntToStr(SInt32(node))+',';
                                       if adresse = NIL
                                         then s := s + 'NIL,'
                                         else s := s + '@'+IntToStr(SInt32(adresse))+',';
                                       s := s + '('+IntToStr(affRect.left)+','+
                                                IntToStr(affRect.top)+','+
                                                IntToStr(affRect.right)+','+
                                                IntToStr(affRect.bottom)+')]';
                                     end;
        StockageAutre              : s := '[stockage autre !!]';
        otherwise                    s := '[?????]';
      end {case}
    end;
  PropertyValueToString := s;
end;

function PropertyToString(prop : Property) : String255;
var s : String255;
begin
  s := Concat(PropertyTypeToString(prop.genre),PropertyValueToString(prop));
  PropertyToString := s;
end;

function MakeTriple(n : SInt32) : Triple;
var aux : Triple;
begin
  aux.nbTriples := n;
  MakeTriple := aux;
end;


procedure DessineLettreOnPropertySquare(var prop : Property; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
var whichSquare,whichSquare2 : SInt16;
    septCaracteres : String255;
    s : String255;
begin
  if not(PropertyEstVide(prop)) then
    case prop.stockage of
       StockageEnCaseOthello      :
           begin
             whichSquare := GetOthelloSquareOfProperty(prop);
             case prop.genre of
               WhiteMoveProp : if not(gCouleurOthellier.estTresClaire)
                                 then DessineLettreBlancheOnSquare(whichSquare,codeAsciiDeLaLettre,continuer)
                                 else DessineLettreNoireOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
               BlackMoveProp : DessineLettreNoireOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
               otherwise       DessineLettreOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
             end;
           end;
       StockageEnCaseOthelloAlpha :
           begin
             whichSquare := StringEnCoup(GetStringInfoOfProperty(prop));
             case prop.genre of
               WhiteMoveProp : if not(gCouleurOthellier.estTresClaire)
                                 then DessineLettreBlancheOnSquare(whichSquare,codeAsciiDeLaLettre,continuer)
                                 else DessineLettreNoireOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
               BlackMoveProp : DessineLettreNoireOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
               otherwise       DessineLettreOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
             end;
           end;
       StockageEnEnsembleDeCases  :
           begin
             ForEachSquareInPackedSetDoAvecResult(GetPackedSquareSetOfProperty(prop),DessineLettreOnSquare,codeAsciiDeLaLettre);
           end;
       StockageEnSeptCaracteres   :
           begin
             GetSquareAndSeptCaracteresOfProperty(prop,whichSquare,septCaracteres);
             s := septCaracteres;
             DessineStringOnSquare(whichSquare,0,s,continuer);
           end;
       StockageEnCoupleCases:
				    begin
				      GetSquareCoupleOfProperty(prop,whichSquare,whichSquare2);
				      DessineLettreOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
				      DessineLettreOnSquare(whichSquare2,codeAsciiDeLaLettre,continuer);
				    end;
       otherwise ;
    end; {case}
end;

procedure EffacerPropertySquare(var prop : Property);
var whichSquare,whichSquare2 : SInt16;
    septCaracteres : String255;
    bidbool : boolean;
begin
  if not(PropertyEstVide(prop)) then
    case prop.stockage of
       StockageEnCaseOthello      :
           begin
             whichSquare := GetOthelloSquareOfProperty(prop);
             EffacerSquare(whichSquare,bidbool);
           end;
       StockageEnCaseOthelloAlpha :
           begin
             whichSquare := StringEnCoup(GetStringInfoOfProperty(prop));
             EffacerSquare(whichSquare,bidbool);
           end;
       StockageEnStr255 :
           begin
             whichSquare := StringEnCoup(GetStringInfoOfProperty(prop));
             EffacerSquare(whichSquare,bidbool);
           end;
       StockageEnEnsembleDeCases  :
           begin
             ForEachSquareInPackedSetDo(GetPackedSquareSetOfProperty(prop),EffacerSquare);
           end;
       StockageEnSeptCaracteres   :
           begin
             GetSquareAndSeptCaracteresOfProperty(prop,whichSquare,septCaracteres);
             EffacerSquare(whichSquare,bidbool);
           end;
       StockageEnCoupleCases:
				    begin
				      GetSquareCoupleOfProperty(prop,whichSquare,whichSquare2);
				      EffacerSquare(whichSquare,bidbool);
				      EffacerSquare(whichSquare2,bidbool);
				    end;
       otherwise ;
    end; {case}
end;

procedure EffectueSymetrieOnProperty(var prop : Property; var axeSymetrie : SInt32; var continuer : boolean);
var whichSquare,whichSquare2 : SInt16;
    septCaracteres : String255;
    ensembleDeCases : SquareSet;
begin
  {$UNUSED continuer}
  if not(PropertyEstVide(prop)) then
    case prop.stockage of
       StockageEnCaseOthello      :
           begin
             whichSquare := GetOthelloSquareOfProperty(prop);
             SetOthelloSquareOfProperty(prop,CaseSymetrique(whichSquare,axeSymetrie));
           end;
       StockageEnCaseOthelloAlpha :
           begin
             whichSquare := StringEnCoup(GetStringInfoOfProperty(prop));
             SetOthelloSquareOfPropertyAlpha(prop,CaseSymetrique(whichSquare,axeSymetrie));
           end;
       StockageEnEnsembleDeCases  :
           begin
             ensembleDeCases := GetSquareSetOfProperty(prop);
             ensembleDeCases := MapOnSquareSetAvecParam(ensembleDeCases,CaseSymetrique,axeSymetrie);
             SetSquareSetOfProperty(prop,ensembleDeCases);
           end;
       StockageEnSeptCaracteres   :
           begin
             GetSquareAndSeptCaracteresOfProperty(prop,whichSquare,septCaracteres);
             whichSquare := CaseSymetrique(whichSquare,axeSymetrie);
             SetSquareAndSeptCaracteresOfProperty(prop,whichSquare,septCaracteres);
           end;
       StockageEnCoupleCases:
				    begin
				      GetSquareCoupleOfProperty(prop,whichSquare,whichSquare2);
              whichSquare  := CaseSymetrique(whichSquare, axeSymetrie);
              whichSquare2 := CaseSymetrique(whichSquare2,axeSymetrie);
              SetSquareCoupleOfProperty(prop,whichSquare,whichSquare2);
				    end;
       otherwise ;
    end; {case}
end;


function AllPropertyTypes : SetOfPropertyTypes;
var result : SetOfPropertyTypes;
    i : SInt32;
begin
  result := [];
  for i := 0 to nbMaxOfPropertyTypes do
    result := result + [i];
  AllPropertyTypes := result;
end;

function InPropertyTypes(whichGenre : SInt16; whichSet : SetOfPropertyTypes) : boolean;
begin
  InPropertyTypes := whichGenre in whichSet;
end;



end.
