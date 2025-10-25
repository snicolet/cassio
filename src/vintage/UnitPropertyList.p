UNIT UnitPropertyList;


INTERFACE







 USES UnitDefCassio;





{fonctions d'initialisation et de fin de programme}
procedure InitUnitPropertyList;
procedure LibereMemoireUnitPropertyList;

{creation et destruction de PropertyList}
function NewPropertyList : PropertyList;
procedure DisposePropertyList(var L : PropertyList);
procedure CompacterPropertyList(var L : PropertyList);
function DuplicatePropertyList(var L : PropertyList) : PropertyList;
function ReverseOfPropertyList(var L : PropertyList) : PropertyList;


{fonctions d'acces à une PropertyList}
function HeadOfPropertyList(L : PropertyList) : PropertyPtr;
function TailOfPropertyList(L : PropertyList) : PropertyList;
function CalculatePropertyTypes(L : PropertyList) : SetOfPropertyTypes;
function ExtractPropertiesOfTypes(whichTypes : SetOfPropertyTypes; L : PropertyList) : PropertyList;


{Ajout et retrait d'un ou de plusieurs element(s) à une PropertyList}
function CreateOneElementPropertyList(prop : Property) : PropertyList;
procedure AddPropertyToList(prop : Property; var L : PropertyList);
procedure AddPropertyToListSansDuplication(prop : Property; var L : PropertyList);
procedure AddScorePropertyToListSansDuplication(prop : Property; var L : PropertyList);
procedure AddPropertyInFrontOfList(prop : Property; var L : PropertyList);
procedure AddPropertyInFrontOfListSansDuplication(prop : Property; var L : PropertyList);
procedure InsertPropInListAfter(prop : Property; var L : PropertyList; afterWhat : PropertyPtr);
procedure OverWritePropertyToList(prop : Property; var L : PropertyList; var changed : boolean);
procedure DeletePropertyFromList(prop : Property; var L : PropertyList);
procedure DeletePropertiesOfThisTypeInList(whichType : SInt16; var L : PropertyList);
procedure DeletePropertiesOfTheseTypesInList(whichTypes : SetOfPropertyTypes; var L : PropertyList);
procedure ReplaceHeadOfPropertyList(prop : Property; var L : PropertyList);
procedure ConcatPropertyLists(var L1 : PropertyList; L2 : PropertyList; override,nePasDupliquer : SetOfPropertyTypes);


{iterateurs sur les PropertyList}
function MapPropertyList(L : PropertyList; f : PropertyToPropertyFunc) : PropertyList;
procedure ForEachPropertyOfTheseTypesDo(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProc);
procedure ForEachPropertyOfTheseTypesDoAvecResult(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProcAvecResult; var result : SInt32);
procedure ForEachPropertyOfTheseTypesDoAvecPropEtResult(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProcAvecPropEtResult; var prop : Property; var result : SInt32);
procedure ForEachPropertyInListDo(L : PropertyList ; DoWhat : PropertyProc);
procedure ForEachPropertyInListDoAvecResult(L : PropertyList ; DoWhat : PropertyProcAvecResult; var result : SInt32);
procedure ForEachPropertyInListDoAvecPropEtResult(L : PropertyList ; DoWhat : PropertyProcAvecPropEtResult; var prop : Property; var result : SInt32);


{fonctions de recherche dans une PropertyList}
function PropertyListEstVide(L : PropertyList) : boolean;
function PropertyListLength(L : PropertyList) : SInt32;
function ExistsInPropertyList(prop : Property; L : PropertyList) : boolean;
function NbOccurencesInPropertyList(prop : Property; L : PropertyList) : SInt16;
function TypePresentDansPropertyList(whichTypes : SetOfPropertyTypes; L : PropertyList) : boolean;
function PropertyListHasNoMoreThanTheseTypes(whichTypes : SetOfPropertyTypes; L : PropertyList) : boolean;
function GetTypesOfPropertyOnthatSquare(whichSquare : SInt16; L : PropertyList) : SetOfPropertyTypes;
function ExtractListOfPropertyOnThatSquare(whichSquare : SInt16; L : PropertyList) : PropertyList;


{fonctions de selection}
function SelectFirstPropertyOfTypes(whichTypes : SetOfPropertyTypes; L : PropertyList) : PropertyPtr;
function SelectInPropertList(L : PropertyList; choice : PropertyPredicate; var result : SInt32) : PropertyPtr;


{fonctions d'ecriture de PropertyList dans le rapport}
procedure WritePropertyListDansRapport(var L : PropertyList);
procedure WritelnPropertyListDansRapport(var L : PropertyList);
procedure WriteStringAndPropertyListDansRapport(s : String255; L : PropertyList);
procedure WritelnStringAndPropertyListDansRapport(s : String255; L : PropertyList);


{fonctions d'affichage à l'ecran}
procedure EcritLettresSurOthellierDesCasesDeLaListe(L : PropertyList);
procedure EffaceCasesDeLaListe(L : PropertyList);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesDialogs, UnitRapport, UnitScannerUtils, UnitProperties, UnitPagesDePropertyList, SNEvents ;
{$ELSEC}
    {$I prelink/PropertyList.lk}
{$ENDC}


{END_USE_CLAUSE}










const nbMaxNiveauxRecursionExtraction = 10;

var InfosAccumulateurPropertyTypes :
       record
         niveauRecursion : SInt16;
         accumulateur    : array[1..5] of SetOfPropertyTypes;
       end;

    InfosExtraction :
       record
         niveauRecursion : SInt16;
         table : array[1..nbMaxNiveauxRecursionExtraction] of
                   record
                     SetOfSelectedTypes : SetOfPropertyTypes;
                     ListeExtraite      : PropertyList;
                   end;
       end;

procedure InitUnitPropertyList;
var i : SInt16;
begin
  with InfosAccumulateurPropertyTypes do
    begin
      niveauRecursion := 0;
      for i := 1 to 5 do accumulateur[i] := [];
    end;

  with InfosExtraction do
    begin
		  niveauRecursion := 0;
		  for i := 1 to nbMaxNiveauxRecursionExtraction do
		    begin
		      table[i].SetOfSelectedTypes := [];
		      table[i].ListeExtraite     := NIL;
		    end;
	  end;


	InitUnitPagesDePropertyList;
end;





procedure LibereMemoireUnitPropertyList;
var i : SInt16;
begin
  with InfosExtraction do
    for i := 1 to nbMaxNiveauxRecursionExtraction do
      if table[i].ListeExtraite <> NIL then
        DisposePropertyList(table[i].ListeExtraite);

  DisposeToutesLesPagesDePropertyList;
end;





function NewPropertyList : PropertyList;
var aux : PropertyList;
begin
  inc(soldeCreationPropertyList);

  {aux := PropertyList(AllocateMemoryPtrClear(sizeof(PropertyListRec)));}
  aux := NewPropertyListPaginee;

  if aux <> NIL then
    begin
      aux^.head := MakeEmptyProperty;
      aux^.tail := NIL;
    end;
  NewPropertyList := aux;
end;

procedure DisposePropertyList(var L : PropertyList);
var L2 : PropertyList;
begin
  while (L <> NIL) do
    begin
      DisposePropertyStuff(L^.head);
      ViderProperty(L^.head);

      L2 := L^.tail;

      {DisposeMemoryPtr(Ptr(L));}
      DisposePropertyListPaginee(L);
      L := NIL;
      dec(soldeCreationPropertyList);

      L := L2;

    end;
end;

procedure CompacterPropertyList(var L : PropertyList);
var L1,L2 : PropertyList;
begin

  while (L <> NIL) and PropertyEstVide(L^.head) do
    begin
      dec(SoldeCreationProperties);
     {WriteStringAndPropertyDansRapport('destruction (dans compacterListe (1)) de ',L^.head);
      WritelnNumDansRapport('   => solde = ',SoldeCreationProperties);  }

      L1 := L^.tail;

      DisposePropertyListPaginee(L);
      dec(soldeCreationPropertyList);

      L := L1;
    end;

  if (L = NIL) then exit(CompacterPropertyList);

  L1 := L;
  L2 := L1^.tail;

  while (L2 <> NIL) do
    begin
      if PropertyEstVide(L2^.head)
        then
          begin
            dec(SoldeCreationProperties);
           {WriteStringAndPropertyDansRapport('destruction (dans compacterListe (2)) de ',L^.head);
            WritelnNumDansRapport('   => solde = ',SoldeCreationProperties);  }

            L1^.tail := L2^.tail;

            DisposePropertyListPaginee(L2);
            dec(soldeCreationPropertyList);

            L2 := L1^.tail;
          end
        else
          begin
            L1 := L2;
            L2 := L2^.tail;
          end;
    end;
end;

function HeadOfPropertyList(L : PropertyList) : PropertyPtr;
begin
  if (L = NIL) or PropertyEstVide(L^.head)
    then HeadOfPropertyList := NIL
    else HeadOfPropertyList := @L^.head;
end;

function TailOfPropertyList(L : PropertyList) : PropertyList;
begin
  if (L = NIL)
    then TailOfPropertyList := NIL
    else TailOfPropertyList := L^.tail;
end;


procedure AccumulePropertyType(var prop : Property);
begin
  with InfosAccumulateurPropertyTypes do
    accumulateur[niveauRecursion] := accumulateur[niveauRecursion]+[prop.genre];
end;

function CalculatePropertyTypes(L : PropertyList) : SetOfPropertyTypes;
begin
  with InfosAccumulateurPropertyTypes do
    begin
      inc(niveauRecursion);
      accumulateur[niveauRecursion] := [];
      ForEachPropertyInListDo(L,AccumulePropertyType);
      CalculatePropertyTypes := accumulateur[niveauRecursion];
      dec(niveauRecursion);
    end;
end;


function PropertyListEstVide(L : PropertyList) : boolean;
begin
  PropertyListEstVide := (L = NIL);
end;

function PropertyListLength(L : PropertyList) : SInt32;
begin
  if (L = NIL) or (L = L^.tail)
    then PropertyListLength := 0
    else PropertyListLength := 1 + PropertyListLength(L^.tail);
end;


function CreateOneElementPropertyList(prop : Property) : PropertyList;
var aux : PropertyList;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in CreateOneElementPropertyList, prévenez Stéphane !');
      CreateOneElementPropertyList := CreateOneElementPropertyList(MakeEmptyProperty);
      exit(CreateOneElementPropertyList);
    end;

  aux := NewPropertyList;
  if aux <> NIL then
    begin
      dec(SoldeCreationProperties);
   {   WritelnDansRapport('NON car on decremente dans CreateOneElementPropertyList !!!');  }
      aux^.head := DuplicateProperty(prop);
      aux^.tail := NIL;
    end;
  CreateOneElementPropertyList := aux;
end;

procedure AddPropertyToListIter(prop : Property; var L : PropertyList);
var L2 : PropertyList;
begin
  if not(PropertyEstVide(prop)) then
    begin
		  if (L = NIL)
		    then L := CreateOneElementPropertyList(prop)
		    else
		      begin
		        L2 := L;
		        while (L2^.tail <> NIL) do
		          L2 := L2^.tail;
		        L2^.tail := CreateOneElementPropertyList(prop);
		      end;
     end;
end;

procedure AddPropertyToList(prop : Property; var L : PropertyList);
var aux : PropertyPtr;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in AddPropertyToList, prévenez Stéphane !');
      exit(AddPropertyToList);
    end;

  CompacterPropertyList(L);
  if not(PropertyEstVide(prop)) then
    begin
		  { gestion speciale pour les proprietes dont l'argument est un ensemble de case :
		    s'il existe deja une propriete du meme type dans la liste, on ne rajoute pas
		    une nouvelle propriete de ce type, on fait plutot l'union des deux ensembles }
		  if (prop.stockage = StockageEnEnsembleDeCases) then
		    begin
		      aux := SelectFirstPropertyOfTypes([prop.genre],L);
		      if aux <> NIL then
		        begin
		          UnionPackedSquareSetOfProperty(aux^,GetPackedSquareSetOfProperty(prop));
		          exit(AddPropertyToList);
		        end;
		    end;

		  { cas normal }
		  AddPropertyToListIter(prop,L);
	  end;
end;

procedure AddPropertyToListSansDuplication(prop : Property; var L : PropertyList);
var aux : PropertyPtr;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in AddPropertyToListSansDuplication, prévenez Stéphane !');
      exit(AddPropertyToListSansDuplication);
    end;

  CompacterPropertyList(L);
  if not(PropertyEstVide(prop)) then
    begin
		  { gestion speciale pour les proprietes dont l'argument est un ensemble de case :
		    s'il existe deja une propriete du meme type dans la liste, on ne rajoute pas
		    une nouvelle propriete de ce type, on fait plutot l'union des deux ensembles }
		  if (prop.stockage = StockageEnEnsembleDeCases) then
		    begin
		      aux := SelectFirstPropertyOfTypes([prop.genre],L);
		      if aux <> NIL then
		        begin
		          UnionPackedSquareSetOfProperty(aux^,GetPackedSquareSetOfProperty(prop));
		          exit(AddPropertyToListSansDuplication);
		        end;
		    end;


		  { gestion speciale pour les propietes stockees en triple }
		  if (prop.stockage = StockageEnTriple) and
		     (prop.genre in [CheckMarkProp,GoodForBlackProp,GoodForWhiteProp,TesujiProp,BadMoveProp,DrawMarkProp,UnclearPositionProp]) then
		    begin
		      aux := SelectFirstPropertyOfTypes([prop.genre],L);
		      if aux <> NIL then DeletePropertyFromList(aux^,L);
		    end;


		  { cas normal }
		  aux := SelectFirstPropertyOfTypes([prop.genre],L);
		  if (aux = NIL) or not(SameProperties(aux^,prop)) then
		    AddPropertyToListIter(prop,L);
	  end;
end;

procedure AddScorePropertyToListSansDuplication(prop : Property; var L : PropertyList);
var aux : PropertyPtr;
    theColor,theSign,theValue : SInt16;
    bidon : SInt16;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in AddScorePropertyToListSansDuplication, prévenez Stéphane !');
      exit(AddScorePropertyToListSansDuplication);
    end;

  if not(PropertyEstVide(prop)) then
    begin
      case prop.genre of
        NodeValueProp :
          begin
            GetOthelloValueOfProperty(prop,theColor,theSign,theValue,bidon);
            if theSign < 0 then theValue := -theValue;

            { Si on ajoute de l'information de score exact,
            { il faut détruire l'info gagnant/perdant éventuelle, moins précise}
            if ((theColor = pionNoir)  and (theValue >= 2)) or
               ((theColor = pionBlanc) and (theValue <= -2)) then
              begin
                DeletePropertiesOfTheseTypesInList([GoodForBlackProp],L);
                aux := SelectFirstPropertyOfTypes([NodeValueProp],L);
                if (aux <> NIL) and CetteCouleurAAuMoinsUnGainDansProperty(pionNoir,aux^)
                  then DeletePropertyFromList(aux^,L);
              end;

            if ((theColor = pionBlanc) and (theValue >= 2)) or
               ((theColor = pionNoir)  and (theValue <= -2)) then
              begin
                DeletePropertiesOfTheseTypesInList([GoodForWhiteProp],L);
                aux := SelectFirstPropertyOfTypes([NodeValueProp],L);
                if (aux <> NIL) and CetteCouleurAAuMoinsUnGainDansProperty(pionBlanc,aux^)
                  then DeletePropertyFromList(aux^,L);
              end;

            DeletePropertiesOfTheseTypesInList([DrawMarkProp],L);
          end;
        GoodForBlackProp :
          begin
            aux := SelectFirstPropertyOfTypes([NodeValueProp],L);
            if (aux <> NIL) then
              begin
                GetOthelloValueOfProperty(aux^,theColor,theSign,theValue,bidon);
                if theSign < 0 then theValue := -theValue;

                { Si on sait deja le score exact et qu'on veut ajouter une info }
                { de gagnant/perdant, ce n'est pas la peine…}
                if ((theColor = pionNoir)  and (theValue >= 2)) or
                   ((theColor = pionBlanc) and (theValue <= -2)) then
                  exit(AddScorePropertyToListSansDuplication);

                { On prefere marquer le gain Noir avec une propriete GoodForBlackProp}
                if ((theColor = pionNoir)  and (theValue = +1)) or
                   ((theColor = pionBlanc) and (theValue = -1)) then
                  DeletePropertyFromList(aux^,L);

                DeletePropertiesOfTheseTypesInList([DrawMarkProp],L);
              end;
          end;
        GoodForWhiteProp :
          begin
            aux := SelectFirstPropertyOfTypes([NodeValueProp],L);
            if (aux <> NIL) then
              begin
                GetOthelloValueOfProperty(aux^,theColor,theSign,theValue,bidon);
                if theSign < 0 then theValue := -theValue;

                { Si on sait deja le score exact et qu'on veut ajouter une info }
                { de gagnant/perdant, ce n'est pas la peine…}
                if ((theColor = pionBlanc) and (theValue >= 2 )) or
                   ((theColor = pionNoir)  and (theValue <= -2)) then
                  exit(AddScorePropertyToListSansDuplication);

                { On prefere marquer le gain Noir avec une propriete GoodForWhiteProp}
                if ((theColor = pionNoir)  and (theValue = -1)) or
                   ((theColor = pionBlanc) and (theValue = +1)) then
                  DeletePropertyFromList(aux^,L);

                DeletePropertiesOfTheseTypesInList([DrawMarkProp],L);
              end;
          end;
        ZebraBookProp :
          begin
            DeletePropertiesOfTheseTypesInList([ZebraBookProp],L);
          end;
      end;  {case}


      AddPropertyInFrontOfListSansDuplication(prop,L);
      {AddPropertyToListSansDuplication(prop,L);}
	  end;
end;



procedure AddPropertyInFrontOfList(prop : Property; var L : PropertyList);
var aux : PropertyPtr;
    ListeAux : PropertyList;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in AddPropertyInFrontOfList, prévenez Stéphane !');
      exit(AddPropertyInFrontOfList);
    end;

  CompacterPropertyList(L);
  if not(PropertyEstVide(prop)) then
    begin
		  { gestion speciale pour les proprietes dont l'argument est un ensemble de case :
		    s'il existe deja une propriete du meme type dans la liste, on ne rajoute pas
		    une nouvelle propriete de ce type, on fait plutot l'union des deux ensembles }
		  if (prop.stockage = StockageEnEnsembleDeCases) then
		    begin
		      aux := SelectFirstPropertyOfTypes([prop.genre],L);
		      if aux <> NIL then
		        begin
		          UnionPackedSquareSetOfProperty(aux^,GetPackedSquareSetOfProperty(prop));
		          exit(AddPropertyInFrontOfList);
		        end;
		    end;

		  { cas normal }
		  if (L = NIL)
		    then
		       L := CreateOneElementPropertyList(prop)
		    else
		      begin
		        ListeAux := CreateOneElementPropertyList(prop);
		        ListeAux^.tail := L;
		        L := ListeAux;
		      end;
	  end;
end;


procedure AddPropertyInFrontOfListSansDuplication(prop : Property; var L : PropertyList);
var aux : PropertyPtr;
    ListeAux : PropertyList;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in AddPropertyInFrontOfListSansDuplication, prévenez Stéphane !');
      exit(AddPropertyInFrontOfListSansDuplication);
    end;

  CompacterPropertyList(L);
  if not(PropertyEstVide(prop)) then
    begin
		  { gestion speciale pour les proprietes dont l'argument est un ensemble de case :
		    s'il existe deja une propriete du meme type dans la liste, on ne rajoute pas
		    une nouvelle propriete de ce type, on fait plutot l'union des deux ensembles }
		  if (prop.stockage = StockageEnEnsembleDeCases) then
		    begin
		      aux := SelectFirstPropertyOfTypes([prop.genre],L);
		      if aux <> NIL then
		        begin
		          UnionPackedSquareSetOfProperty(aux^,GetPackedSquareSetOfProperty(prop));
		          exit(AddPropertyInFrontOfListSansDuplication);
		        end;
		    end;


		  { gestion speciale pour les propietes stockees en triple }
		  if (prop.stockage = StockageEnTriple) and
		     (prop.genre in [CheckMarkProp,GoodForBlackProp,GoodForWhiteProp,TesujiProp,BadMoveProp,DrawMarkProp,UnclearPositionProp]) then
		    begin
		      aux := SelectFirstPropertyOfTypes([prop.genre],L);
		      if aux <> NIL then DeletePropertyFromList(aux^,L);
		    end;


		  { cas normal }
		  aux := SelectFirstPropertyOfTypes([prop.genre],L);

		  if (aux = NIL) or not(SameProperties(aux^,prop)) then
		    begin
		      if (L = NIL)
    		    then
    		       begin
    		         L := CreateOneElementPropertyList(prop);
    		       end
    		    else
    		      begin
    		        ListeAux := CreateOneElementPropertyList(prop);
    		        if ListeAux <> NIL then
    		          begin
    		            ListeAux^.tail := L;
    		            L := ListeAux;
    		          end;
    		      end;
		    end;
	  end;
end;


procedure InsertPropInListAfter(prop : Property; var L : PropertyList; afterWhat : PropertyPtr);
var trouve : boolean;
    L1 : PropertyList;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in InsertPropInListAfter, prévenez Stéphane !');
      exit(InsertPropInListAfter);
    end;

  if (afterWhat = NIL)
    then
      AddPropertyToList(prop,L)
    else
      begin
        CompacterPropertyList(L);
			  if not(PropertyEstVide(prop)) then
			    begin
			      L1 := L;
			      trouve := false;
			      while (L1 <> NIL) do
			        begin
			          {trouve, au sens de l'egalite des pointeurs ?}
			          if (afterWhat = @L1^.head) then
			            begin
			              AddPropertyInFrontOfList(prop,L1^.tail);
			              exit(InsertPropInListAfter);
			            end;
			          L1 := L1^.tail;
			        end;
			      {pas trouve : ajouter a la fin}
			      AddPropertyToList(prop,L);
			    end;
			end;
end;


procedure ForEachPropertyOfTheseTypesDoIter(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProc);
begin
  if (L <> NIL) then
    begin
      if not(PropertyEstVide(L^.head)) and (L^.head.genre in whichTypes) then   {on fait l'action}
        DoWhat(L^.head);
      if L^.tail <> NIL then
        if (L^.tail = L)
          then
            begin
              AlerteSimple('boucle infinie dans ForEachPropertyOfTheseTypesDoIter !! Prévenez Stéphane !');
              exit(ForEachPropertyOfTheseTypesDoIter);
            end
          else               {on fait l'appel recursif}
              ForEachPropertyOfTheseTypesDoIter(L^.tail,whichTypes,DoWhat);
    end;
end;


procedure ForEachPropertyOfTheseTypesDo(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProc);
begin
  ForEachPropertyOfTheseTypesDoIter(L,whichTypes,DoWhat);
end;


procedure ForEachPropertyOfTheseTypesDoIterAvecResult(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProcAvecResult; var result : SInt32);
var continuer : boolean;
begin
  if (L <> NIL) then
    begin
      continuer := true;
      if not(PropertyEstVide(L^.head)) and (L^.head.genre in whichTypes) then   {on fait l'action}
        DoWhat(L^.head,result,continuer);
      if continuer and (L^.tail <> NIL) then
        begin
	        if (L^.tail = L)
	          then
	            begin
	              AlerteSimple('boucle infinie dans ForEachPropertyOfTheseTypesDoIterAvecResult !! Prévenez Stéphane !');
	              exit(ForEachPropertyOfTheseTypesDoIterAvecResult);
	            end
	          else               {on fait l'appel recursif}
	            ForEachPropertyOfTheseTypesDoIterAvecResult(L^.tail,whichTypes,DoWhat,result);
	     end;
    end;
end;

procedure ForEachPropertyOfTheseTypesDoAvecResult(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProcAvecResult; var result : SInt32);
begin
  ForEachPropertyOfTheseTypesDoIterAvecResult(L,whichTypes,DoWhat,result);
end;



procedure ForEachPropertyOfTheseTypesDoIterAvecPropEtResult(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProcAvecPropEtResult; var prop : Property; var result : SInt32);
var continuer : boolean;
begin
  if (L <> NIL) then
    begin
      continuer := true;
      if not(PropertyEstVide(L^.head)) and (L^.head.genre in whichTypes) then   {on fait l'action}
        DoWhat(L^.head,prop,result,continuer);
      if continuer and (L^.tail <> NIL) then
        begin
          if (L^.tail = L)
            then
              begin
                AlerteSimple('boucle infinie dans ForEachPropertyOfTheseTypesDoIterAvecPropEtResult !! Prévenez Stéphane !');
                exit(ForEachPropertyOfTheseTypesDoIterAvecPropEtResult);
              end
            else               {on fait l'appel recursif}
              ForEachPropertyOfTheseTypesDoIterAvecPropEtResult(L^.tail,whichTypes,DoWhat,prop,result);
       end;
    end;
end;


procedure ForEachPropertyOfTheseTypesDoAvecPropEtResult(L : PropertyList; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProcAvecPropEtResult; var prop : Property; var result : SInt32);
begin
  ForEachPropertyOfTheseTypesDoIterAvecPropEtResult(L,whichTypes,DoWhat,prop,result);
end;




procedure ForEachPropertyInListDoIter(L : PropertyList ; DoWhat : PropertyProc);
begin
  if (L <> NIL) then
    begin
      if not(PropertyEstVide(L^.head)) then   {on fait l'action}
        DoWhat(L^.head);
      if L^.tail <> NIL then
        if (L^.tail = L)
          then
            begin
              AlerteSimple('boucle infinie dans ForEachPropertyInListDoIter !! Prévenez Stéphane !');
              exit(ForEachPropertyInListDoIter);
            end
          else               {on fait l'appel recursif}
              ForEachPropertyInListDoIter(L^.tail,DoWhat);
    end;
end;

procedure ForEachPropertyInListDo(L : PropertyList ; DoWhat : PropertyProc);
begin
  ForEachPropertyInListDoIter(L,DoWhat);
end;


procedure ForEachPropertyInListDoIterAvecResult(L : PropertyList ; DoWhat : PropertyProcAvecResult; var result : SInt32);
var continuer : boolean;
begin
  if (L <> NIL) then
    begin
      continuer := true;
      if not(PropertyEstVide(L^.head)) then   {on fait l'action}
        DoWhat(L^.head,result,continuer);
      if continuer and (L^.tail <> NIL) then
        begin
	        if (L^.tail = L)
	          then
	            begin
	              AlerteSimple('boucle infinie dans ForEachPropertyInListDoIterAvecResult !! Prévenez Stéphane !');
	              exit(ForEachPropertyInListDoIterAvecResult);
	            end
	          else               {on fait l'appel recursif}
	            ForEachPropertyInListDoIterAvecResult(L^.tail,DoWhat,result);
	     end;
    end;
end;

procedure ForEachPropertyInListDoAvecResult(L : PropertyList ; DoWhat : PropertyProcAvecResult; var result : SInt32);
begin
  ForEachPropertyInListDoIterAvecResult(L,DoWhat,result);
end;



procedure ForEachPropertyInListDoIterAvecPropEtResult(L : PropertyList ; DoWhat : PropertyProcAvecPropEtResult; var prop : Property; var result : SInt32);
var continuer : boolean;
begin
  if (L <> NIL) then
    begin
      continuer := true;
      if not(PropertyEstVide(L^.head)) then   {on fait l'action}
        DoWhat(L^.head,prop,result,continuer);
      if continuer and (L^.tail <> NIL) then
        begin
          if (L^.tail = L)
            then
              begin
                AlerteSimple('boucle infinie dans ForEachPropertyInListDoIterAvecPropEtResult !! Prévenez Stéphane !');
                exit(ForEachPropertyInListDoIterAvecPropEtResult);
              end
            else               {on fait l'appel recursif}
              ForEachPropertyInListDoIterAvecPropEtResult(L^.tail,DoWhat,prop,result);
       end;
    end;
end;


procedure ForEachPropertyInListDoAvecPropEtResult(L : PropertyList ; DoWhat : PropertyProcAvecPropEtResult; var prop : Property; var result : SInt32);
begin
  ForEachPropertyInListDoIterAvecPropEtResult(L,DoWhat,prop,result);
end;


function MapPropertyListIter(L : PropertyList; f : PropertyToPropertyFunc) : PropertyList;
var aux : PropertyList;
begin
  if (L = NIL)
    then
      MapPropertyListIter := NIL
    else
      begin
        aux := NewPropertyList;
			  if not(PropertyEstVide(L^.head))
			     then CopyProperty(f(L^.head),aux^.head)
			     else ViderProperty(aux^.head);
			  if L^.tail <> NIL then aux^.tail := MapPropertyListIter(L^.tail,f);
			  MapPropertyListIter := aux;
    end;
end;

function MapPropertyList(L : PropertyList; f : PropertyToPropertyFunc) : PropertyList;
var aux : PropertyList;
begin
  aux := MapPropertyListIter(L,f);
  CompacterPropertyList(aux);
  MapPropertyList := aux;
end;


function DuplicatePropertyList(var L : PropertyList) : PropertyList;
var aux : PropertyList;
begin
  CompacterPropertyList(L);

  if (L = NIL)
    then DuplicatePropertyList := NIL
    else
      begin
        SoldeCreationProperties := SoldeCreationProperties - PropertyListLength(L);
        aux := MapPropertyList(L,DuplicateProperty);
        DuplicatePropertyList := aux;
      end;
end;


function ReverseOfPropertyList(var L : PropertyList) : PropertyList;
var result,L1 : PropertyList;
begin
  if (L = NIL)
    then ReverseOfPropertyList := NIL
    else
      begin
        result := NIL;
        L1 := L;
        while (L1 <> NIL) do
          begin
            AddPropertyInFrontOfList(L1^.head,result);
            if L1^.tail = L1 then
              begin
                AlerteSimple('boucle infinie dans ReverseOfPropertyList !! Prévenez Stéphane');
                exit(ReverseOfPropertyList);
              end;
            L1 := L1^.tail;
          end;
        CompacterPropertyList(result);
        ReverseOfPropertyList := result;
      end;
end;


procedure ExtractPropertyIfGoodType(var prop : Property);
begin
  with InfosExtraction do
    if prop.genre in table[niveauRecursion].SetOfSelectedTypes then
      begin
        {WritelnStringAndPropertyDansRapport('ajout de la propriete suivante à ListeExtraite',prop);}
        AddPropertyToList(prop,table[niveauRecursion].ListeExtraite);
      end;
end;


function ExtractPropertiesOfTypes(whichTypes : SetOfPropertyTypes; L : PropertyList) : PropertyList;
begin
  if (L = NIL) then
    begin
      ExtractPropertiesOfTypes := NIL;
      exit(ExtractPropertiesOfTypes);
    end;

  with infosExtraction do
    begin
      inc(niveauRecursion);
      with table[niveauRecursion] do
        begin
		      if ListeExtraite <> NIL then DisposePropertyList(ListeExtraite);
		      ListeExtraite := NewPropertyList;
		      SetOfSelectedTypes := whichTypes;
		      if (ListeExtraite <> NIL) then
		        ForEachPropertyInListDo(L,ExtractPropertyIfGoodType);
		      ExtractPropertiesOfTypes := DuplicatePropertyList(ListeExtraite);
		      if ListeExtraite <> NIL then DisposePropertyList(ListeExtraite);
		    end;
      dec(niveauRecursion);
    end;
end;

procedure ComparePourNbOccurences(var theElement,elementATrouver : Property; var result : SInt32; var continuer : boolean);
begin
  {$UNUSED continuer}
  if SameProperties(theElement,elementATrouver) then inc(result);
end;

procedure ComparePourExists(var theElement,elementATrouver : Property; var result : SInt32; var continuer : boolean);
begin
  if SameProperties(theElement,elementATrouver) then
    begin
      result := 1;
      continuer := false;
    end;
end;



function ExistsInPropertyList(prop : Property; L : PropertyList) : boolean;
var aux : PropertyPtr;
    result : SInt32;
begin
  if (L = NIL) then
    begin
      ExistsInPropertyList := false;
      exit(ExistsInPropertyList);
    end;


  { gestion speciale pour les proprietes dont l'argument est un ensemble de cases :
    s'il existe deja une propriete du meme type dans la liste, il suffit de tester
    l'inclusion de l'ensemble à trouver dans l'ensemble present dans la liste}
  if (prop.stockage = StockageEnEnsembleDeCases) then
    begin
      aux := SelectFirstPropertyOfTypes([prop.genre],L);
      if aux = NIL
        then ExistsInPropertyList := false
        else ExistsInPropertyList := (GetPackedSquareSetOfProperty(prop).private <= GetPackedSquareSetOfProperty(aux^).private);
      exit(ExistsInPropertyList);
    end;

  { cas normal }
  result := 0;
  ForEachPropertyInListDoAvecPropEtResult(L,ComparePourExists,prop,result);
  ExistsInPropertyList := (result >= 1);
end;


function NbOccurencesInPropertyList(prop : Property; L : PropertyList) : SInt16;
var aux : PropertyPtr;
    nbOccurences : SInt32;
begin

  if (L = NIL) then
    begin
      NbOccurencesInPropertyList := 0;
      exit(NbOccurencesInPropertyList);
    end;

  { gestion speciale pour les proprietes dont l'argument est un ensemble de cases :
    s'il existe deja une propriete du meme type dans la liste, il suffit de tester
    l'inclusion de l'ensemble à trouver dans l'ensemble present dans la liste}
  if (prop.stockage = StockageEnEnsembleDeCases) then
    begin
      aux := SelectFirstPropertyOfTypes([prop.genre],L);
      if (aux <> NIL) and (GetPackedSquareSetOfProperty(prop).private <= GetPackedSquareSetOfProperty(aux^).private)
        then NbOccurencesInPropertyList := 1
        else NbOccurencesInPropertyList := 0;
      exit(NbOccurencesInPropertyList);
    end;

  { cas normal }
  nbOccurences := 0;
  ForEachPropertyInListDoAvecPropEtResult(L,ComparePourNbOccurences,prop,nbOccurences);
  nbOccurencesInPropertyList := nbOccurences;
end;



function TypePresentDansPropertyList(whichTypes : SetOfPropertyTypes; L : PropertyList) : boolean;
var ensembleTypes : SetOfPropertyTypes;
begin
  if (L = NIL)
    then TypePresentDansPropertyList := false
    else
      begin
        ensembleTypes := CalculatePropertyTypes(L);
        TypePresentDansPropertyList := (whichTypes <= ensembleTypes);
      end;
end;

function PropertyListHasNoMoreThanTheseTypes(whichTypes : SetOfPropertyTypes; L : PropertyList) : boolean;
var typesPresents : SetOfPropertyTypes;
begin
  typesPresents := CalculatePropertyTypes(L);
  PropertyListHasNoMoreThanTheseTypes := (typesPresents <= whichTypes);
end;


function GetTypesOfPropertyOnthatSquare(whichSquare : SInt16; L : PropertyList) : SetOfPropertyTypes;
var result : SetOfPropertyTypes;
    aux : Property;
    auxSquare,auxSquare2 : SInt16;
    septCaracteres : String255;
begin
  result := [];
  if (L <> NIL) and (whichSquare >= 11) and (whichSquare <= 88) then
    begin
      while L <> NIL do
        begin
          aux := L^.head;
          if not(PropertyEstVide(aux)) then
             case aux.stockage of
               StockageEnCaseOthello      :
				          if GetOthelloSquareOfProperty(aux) = whichSquare then
				            result := result + [aux.genre];
				       StockageEnCaseOthelloAlpha :
				          if StringEnCoup(GetStringInfoOfProperty(aux)) = whichSquare then
				            result := result + [aux.genre];
				       StockageEnEnsembleDeCases  :
				          if whichSquare in GetSquareSetOfProperty(aux) then
				            result := result + [aux.genre];
				       StockageEnSeptCaracteres   :
				           begin
				             GetSquareAndSeptCaracteresOfProperty(aux,auxSquare,septCaracteres);
				             if auxSquare = whichSquare then
				               result := result + [aux.genre];
				           end;
				       StockageEnCoupleCases:
							     begin
							       GetSquareCoupleOfProperty(aux,auxSquare,auxSquare2);
							       if (auxSquare = whichSquare) or (auxSquare2 = whichSquare) then
				               result := result + [aux.genre];
							     end;
             end;  {case}
          if L^.tail = L then
            begin
              AlerteSimple('Boucle infinie dans GetTypesOfPropertyOnthatSquare !! Prévenez Stéphane');
              GetTypesOfPropertyOnthatSquare := result;
              exit(GetTypesOfPropertyOnthatSquare);
            end;
          L := L^.tail;
        end;
    end;
  GetTypesOfPropertyOnthatSquare := result;
end;


function ExtractListOfPropertyOnThatSquare(whichSquare : SInt16; L : PropertyList) : PropertyList;
var result : PropertyList;
    aux : Property;
    auxSquare,auxSquare2 : SInt16;
    septCaracteres : String255;
    myProp : Property;
begin
  if (L = NIL) or (whichSquare < 11) or (whichSquare > 88) then
    begin
      ExtractListOfPropertyOnThatSquare := NIL;
      exit(ExtractListOfPropertyOnThatSquare);
    end;

  result := NewPropertyList;
  while L <> NIL do
    begin
      aux := L^.head;
      if not(PropertyEstVide(aux)) then
         case aux.stockage of
           StockageEnCaseOthello      :
		          if GetOthelloSquareOfProperty(aux) = whichSquare then AddPropertyToList(aux,result);
		       StockageEnCaseOthelloAlpha :
		          if StringEnCoup(GetStringInfoOfProperty(aux)) = whichSquare then AddPropertyToList(aux,result);
		       StockageEnEnsembleDeCases  :
		          if whichSquare in GetSquareSetOfProperty(aux) then
		            begin
		              myProp := MakeSquareSetProperty(aux.genre,[whichSquare]);
		              AddPropertyToList(myProp,result);
		              DisposePropertyStuff(myProp);
		            end;
		       StockageEnSeptCaracteres   :
		           begin
		             GetSquareAndSeptCaracteresOfProperty(aux,auxSquare,septCaracteres);
		             if auxSquare = whichSquare then AddPropertyToList(aux,result);
		           end;
		       StockageEnCoupleCases:
				       begin
				         GetSquareCoupleOfProperty(aux,auxSquare,auxSquare2);
							   if (auxSquare = whichSquare) or (auxSquare2 = whichSquare) then
				            AddPropertyToList(aux,result);
				       end;
         end;  {case}
      if L^.tail = L then
        begin
          AlerteSimple('Boucle infinie dans ExtractListOfPropertyOnThatSquare !! Prévenez Stéphane');
          ExtractListOfPropertyOnThatSquare := result;
          exit(ExtractListOfPropertyOnThatSquare);
        end;
      L := L^.tail;
    end;
  CompacterPropertyList(result);
  ExtractListOfPropertyOnThatSquare := result;
end;


function SelectFirstPropertyOfTypes(whichTypes : SetOfPropertyTypes; L : PropertyList) : PropertyPtr;
begin
  while (L <> NIL) do
    begin
      if (L^.head.genre in whichTypes) then
        begin
          SelectFirstPropertyOfTypes := @L^.head;
          exit(SelectFirstPropertyOfTypes);
        end;
      L := L^.tail;
    end;
   SelectFirstPropertyOfTypes := NIL;
end;


function SelectInPropertList(L : PropertyList; choice : PropertyPredicate; var result : SInt32) : PropertyPtr;
begin
  if (L <> NIL) then
    begin
      if choice(L^.head,result) then
        begin
          SelectInPropertList := @L^.head;
          exit(SelectInPropertList);
        end;
      if (L^.tail <> NIL) and (L^.tail <> L) then
        begin
          SelectInPropertList := SelectInPropertList(L^.tail,choice,result);
          exit(SelectInPropertList);
        end;
    end;
   SelectInPropertList := NIL;
end;


procedure OverWritePropertyToList(prop : Property; var L : PropertyList; var changed : boolean);
var aux : PropertyPtr;
begin
  changed := false;

  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in OverWritePropertyToList, prévenez Stéphane !');
      exit(OverWritePropertyToList);
    end;

  if not(PropertyEstVide(prop)) then
    begin
      aux := SelectFirstPropertyOfTypes([prop.genre],L);
      if (aux = NIL)
        then
          begin
            AddPropertyToList(prop,L);
            changed := true;
          end
        else
          begin
            if not(SameProperties(aux^,prop)) then
              begin
                if TypeCastingPourCeStockage(prop.stockage)
	                then
	                  CopyProperty(prop,aux^)
	                else
	                  begin
	                    DeletePropertiesOfThisTypeInList(prop.genre,L);
                      AddPropertyToList(prop,L);
	                  end;
	              changed := true;
	            end;
          end;
    end;
end;


procedure DeletePropertyFromListIter(prop : Property; var L : PropertyList);
begin
  if (L <> NIL) then
    begin
      if not(PropertyEstVide(L^.head)) and SameProperties(L^.head,prop) then
        begin
          DisposePropertyStuff(L^.head);
    {      WritelnDansRapport('NON !!');  }
          ViderProperty(L^.head);
          inc(SoldeCreationProperties);  {car en fait on ne l'a pas encore detruite, on l'a seulement videe}
        end;
      if L^.tail <> NIL then
        if (L^.tail = L)
          then
            begin
              AlerteSimple('boucle infinie dans DeletePropertyFromListIter !! Prévenez Stéphane !');
              exit(DeletePropertyFromListIter);
            end
          else         {appel recursif dans la queue}
            DeletePropertyFromListIter(prop,L^.tail);
    end;
end;

procedure DeletePropertyFromList(prop : Property; var L : PropertyList);
var aux : PropertyPtr;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in DeletePropertyFromList, prévenez Stéphane !');
      exit(DeletePropertyFromList);
    end;

  CompacterPropertyList(L);
  if (L = NIL) then exit(DeletePropertyFromList);

  { gestion speciale pour les proprietes dont l'argument est un ensemble de cases :
    s'il existe deja une propriete du meme type dans la liste, on ne detruit pas
    forcement la propriete de ce type, on fait plutot la difference des deux
    ensembles; et si cette difference est vide, on detruit alors la propriete}
  if (prop.stockage = StockageEnEnsembleDeCases) then
    begin
      aux := SelectFirstPropertyOfTypes([prop.genre],L);
      if aux <> NIL then
        begin
          DiffPackedSquareSetOfProperty(aux^,GetPackedSquareSetOfProperty(prop));
          if ( GetPackedSquareSetOfProperty(aux^).private <= [] )   {vide ?}
            then
              begin
                DisposePropertyStuff(aux^);
                inc(SoldeCreationProperties);  {car en fait on ne l'a pas encore detruite}
     {           WritelnDansRapport('NON !!');  }
                ViderProperty(aux^);
                CompacterPropertyList(L);
              end;
        end;
      exit(DeletePropertyFromList);
    end;

  { cas normal }
  DeletePropertyFromListIter(prop,L);
  CompacterPropertyList(L);
end;

procedure DeletePropertiesOfThisTypeInList(whichType : SInt16; var L : PropertyList);
var aux : PropertyPtr;
begin
  if (L <> NIL) then
    begin
	    aux := SelectFirstPropertyOfTypes([whichType],L);
	    if aux <> NIL then DeletePropertyFromList(aux^,L);
	  end;
	{on fait une deuxième passe pour etre sûr}
	if (L <> NIL) then
    begin
	    aux := SelectFirstPropertyOfTypes([whichType],L);
	    if aux <> NIL then DeletePropertyFromList(aux^,L);
	  end;
end;

procedure DeletePropertiesOfTheseTypesInList(whichTypes : SetOfPropertyTypes; var L : PropertyList);
var aux : PropertyPtr;
    i : SInt16;
begin
  if (whichTypes <= []) then  {ensemble vide ?}
    exit(DeletePropertiesOfTheseTypesInList);

  if (L <> NIL) then
     for i := 0 to nbMaxOfPropertyTypes do
       if (i in whichTypes) then
	        begin
	          aux := SelectFirstPropertyOfTypes([i],L);
	          if aux <> NIL then DeletePropertyFromList(aux^,L);
	        end;

	{on fait une deuxième passe pour etre sûr}
	if (L <> NIL) then
     for i := 0 to nbMaxOfPropertyTypes do
       if (i in whichTypes) then
	        begin
	          aux := SelectFirstPropertyOfTypes([i],L);
	          if aux <> NIL then DeletePropertyFromList(aux^,L);
	        end;
end;

procedure ReplaceHeadOfPropertyList(prop : Property; var L : PropertyList);
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in ReplaceHeadOfPropertyList, prévenez Stéphane !');
      exit(ReplaceHeadOfPropertyList);
    end;

  CompacterPropertyList(L);
  if (L <> NIL) then
    begin
      DisposePropertyStuff(L^.head);
      CopyProperty(prop,L^.head);
    end;
end;

{ ajoute dans L1 les éléments de L2 non déjà dans L1 }
procedure ConcatPropertyLists(var L1 : PropertyList; L2 : PropertyList; override,nePasDupliquer : SetOfPropertyTypes);
var ListAux2 : PropertyList;
    aux : Property;
    typesDansL1 : SetOfPropertyTypes;
    changed : boolean;
begin

 {WritelnDansRapport('entree dans ConcatPropertyLists…');
  WritelnStringAndPropertyListDansRapport('L1 = ',L1);
  WritelnStringAndPropertyListDansRapport('L2 = ',L2);
  WritelnDansRapport('');}


  if (L2 = NIL) then exit(ConcatPropertyLists);
  if (L1 = NIL) then
    begin
      L1 := DuplicatePropertyList(L2);
      exit(ConcatPropertyLists);
    end;

  typesDansL1 := CalculatePropertyTypes(L1);

  ListAux2 := L2;
  repeat

    aux := ListAux2^.head;
    if not(PropertyEstVide(aux)) then
      begin


        if (aux.genre in nePasDupliquer) and
           ((nePasDupliquer * typesDansL1) <> [])  { * = set intersection}
          then
            begin
              if InPropertyTypes(aux.genre,[NodeValueProp,GoodForBlackProp,GoodForWhiteProp])
                then AddScorePropertyToListSansDuplication(aux,L1)
                else AddPropertyToListSansDuplication(aux,L1);
              typesDansL1 := typesDansL1 + [aux.genre];
            end
          else
            begin
              if not(aux.genre in typesDansL1)
			          then
			            begin
			              AddPropertyToList(aux,L1);
			              typesDansL1 := typesDansL1 + [aux.genre];
			            end
			          else
			            begin
			              if not(ExistsInPropertyList(aux,L1)) then
			                if (aux.genre in override)
			                  then OverWritePropertyToList(aux,L1,changed)
			                  else AddPropertyToList(aux,L1);
			            end;
            end;
      end;

    if (ListAux2^.tail = ListAux2) then
      begin
        AlerteSimple('boucle infinie sur ListeAux2 dans ConcatPropertyLists !! Prévenez Stéphane');
        exit(ConcatPropertyLists);
      end;
    ListAux2 := ListAux2^.tail;
  until (ListAux2 = NIL);
end;


procedure WritePropertyListDansRapport(var L : PropertyList);
var L1 : PropertyList;
begin
  if L = NIL
    then
      WriteDansRapport('NIL')
    else
      begin
        WriteDansRapport('{');

        L1 := L;
        repeat
          WritePropertyDansRapport(L1^.head);
          L1 := L1^.tail;
        until (L1 = NIL);

        WriteDansRapport('}');
      end;
end;

procedure WritelnPropertyListDansRapport(var L : PropertyList);
begin
  WritePropertyListDansRapport(L);
  WritelnDansRapport('');
end;


procedure WriteStringAndPropertyListDansRapport(s : String255; L : PropertyList);
begin
  WriteDansRapport(s);
  WritePropertyListDansRapport(L);
end;

procedure WritelnStringAndPropertyListDansRapport(s : String255; L : PropertyList);
begin
  WriteDansRapport(s);
  WritelnPropertyListDansRapport(L);
end;


procedure EcritLettresSurOthellierDesCasesDeLaListe(L : PropertyList);
var codeAsciiPremiereLettre : SInt32;
begin
  codeAsciiPremiereLettre := ord('a');
  ForEachPropertyInListDoAvecResult(L,DessineLettreOnPropertySquare,codeAsciiPremiereLettre);
end;

procedure EffaceCasesDeLaListe(L : PropertyList);
begin
  ForEachPropertyInListDo(L,EffacerPropertySquare);
end;


end.
