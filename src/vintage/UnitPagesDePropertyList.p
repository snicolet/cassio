UNIT UnitPagesDePropertyList;



INTERFACE







 USES UnitDefCassio;


procedure InitUnitPagesDePropertyList;
procedure DisposeToutesLesPagesDePropertyList;


function PeutCreerNouvellePagePropertyList : boolean;
function TrouvePlaceDansPageDePropertyList(var nroPage,nroIndex : SInt32) : boolean;
procedure LocaliserPropertyListDansSaPage(L : PropertyList; var nroDePage,nroIndex : SInt32);


function NewPropertyListPaginee : PropertyList;
procedure DisposePropertyListPaginee(L : PropertyList);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitNewGeneral, UnitServicesDialogs, UnitRapport, UnitMiniProfiler, UnitServicesMemoire ;
{$ELSEC}
    {$I prelink/PagesDePropertyList.lk}
{$ENDC}


{END_USE_CLAUSE}











const TaillePropertyListBuffer = 500;
type PropertyListArray = array[1..TaillePropertyListBuffer] of PropertyListRec;
     PropertyListBuffer = ^PropertyListArray;
     PageDePropertyList =  record
                             buffer : PropertyListBuffer;
                             libre  : {packed} array[0..TaillePropertyListBuffer] of boolean;
                             premierEmplacementVide : SInt16;
                             dernierEmplacementVide : SInt16;
                             nbEmplacementVides     : SInt16;
                           end;
     PageDePropertyListPtr = ^PageDePropertyList;


const nbPagesDePropertyList = 100000;
var ReserveDePropertyList : array [1..nbPagesDePropertyList] of PageDePropertyListPtr;
    dernierePagePropertyListCree : SInt32;
    pagePropertyListRenvoyeeParDerniereLocalisation : SInt32;
    pagePropertyListRenvoyeeParDerniereCreation : SInt32;



procedure InitUnitPagesDePropertyList;
var i : SInt32;
begin
  for i := 1 to nbPagesDePropertyList do
	  begin
	    ReserveDePropertyList[i] := NIL;
	  end;
	dernierePagePropertyListCree := 0;
	pagePropertyListRenvoyeeParDerniereLocalisation := 1;
	pagePropertyListRenvoyeeParDerniereCreation := 1;
	if PeutCreerNouvellePagePropertyList then DoNothing;
	if not(CassioEnEnvironnementMemoireLimite) then
	  begin
	    if PeutCreerNouvellePagePropertyList then DoNothing;
			if PeutCreerNouvellePagePropertyList then DoNothing;
			if PeutCreerNouvellePagePropertyList then DoNothing;
	  end;
end;


procedure DisposeToutesLesPagesDePropertyList;
begin
  {
  for i := 1 to nbPagesDePropertyList do
	  if ReserveDePropertyList[i] <> NIL then
	    begin
	      DisposeMemoryPtr(Ptr(ReserveDePropertyList[i]^.buffer));
	      ReserveDePropertyList[i]^.buffer := NIL;
	      DisposeMemoryPtr(Ptr(ReserveDePropertyList[i]));
	      ReserveDePropertyList[i] := NIL;
	    end;
	dernierePagePropertyListCree := 0;
	pagePropertyListRenvoyeeParDerniereLocalisation := 1;
	pagePropertyListRenvoyeeParDerniereCreation := 1;
	}
end;



function PeutCreerNouvellePagePropertyList : boolean;
var i : SInt32;
begin

  if dernierePagePropertyListCree >= nbPagesDePropertyList then
    begin
      AlerteSimple('le nombre de pages de PropertyList est trop petit dans PeutCreerNouvellePagePropertyList !! Prévenez Stéphane');
      PeutCreerNouvellePagePropertyList := false;
      exit;
    end;


  inc(dernierePagePropertyListCree);
  ReserveDePropertyList[dernierePagePropertyListCree] := PageDePropertyListPtr(AllocateMemoryPtr(sizeof(PageDePropertyList)));

  if ReserveDePropertyList[dernierePagePropertyListCree] = NIL then
    begin
      AlerteSimple('plus de place en memoire pour creer une page de PropertyList dans PeutCreerNouvellePagePropertyList !! Prévenez Stéphane');
      PeutCreerNouvellePagePropertyList := false;
      exit;
    end;

  with ReserveDePropertyList[dernierePagePropertyListCree]^ do
    begin
      buffer := PropertyListBuffer(AllocateMemoryPtr(sizeof(PropertyListArray)+20));
      if buffer = NIL then
        begin
          AlerteSimple('plus de place en memoire pour creer un buffer de PropertyList dans PeutCreerNouvellePagePropertyList !! Prévenez Stéphane');
          PeutCreerNouvellePagePropertyList := false;
          exit;
        end;


      PeutCreerNouvellePagePropertyList := true;

      for i := 1 to TaillePropertyListBuffer do
        libre[i] := true;
      premierEmplacementVide := 1;
      dernierEmplacementVide := TaillePropertyListBuffer;
      nbEmplacementVides    := TaillePropertyListBuffer;
    end;

  {
  WritelnDansRapport('Création d''une nouvelle page de PropertyList');
  WritelnNumDansRapport('soldeCreationPropertyList = ',soldeCreationPropertyList);
  SysBeep(0);
  AttendFrappeClavier;
  }
end;


function TrouvePlaceDansPageDePropertyList(var nroPage,nroIndex : SInt32) : boolean;
var n,i,k : SInt32;
begin
  if (dernierePagePropertyListCree <= 0) and not(PeutCreerNouvellePagePropertyList)  then
    begin
      TrouvePlaceDansPageDePropertyList := false;
      nroPage := -1;
      nroIndex := -1;
      exit;
    end;

  {if dernierePagePropertyListCree >= 2 then
  for n := 1 to dernierePagePropertyListCree do
    begin
    if ReserveDePropertyList[n] <> NIL then
      with ReserveDePropertyList[n]^ do
        begin
          WritelnDansRapport('Reserve['+IntToStr(n)+'] est OK');
          WritelnNumDansRapport('nbEmplacementVides = ',nbEmplacementVides);
          WritelnNumDansRapport('premierEmplacementVide = ',premierEmplacementVide);
          WritelnNumDansRapport('dernierEmplacementVide = ',dernierEmplacementVide);
          WritelnNumDansRapport('soldeCreationPropertyList = ',soldeCreationPropertyList);
         end;
     if dernierePagePropertyListCree >= 2 then AttendFrappeClavier;
     end;
  }


  for k := 0 to (dernierePagePropertyListCree div 2) do
    begin
      {un coup en montant...}
      n := pagePropertyListRenvoyeeParDerniereCreation + k;
      if (n > dernierePagePropertyListCree) then n := n - dernierePagePropertyListCree else
      if (n < 1) then n := n + dernierePagePropertyListCree;
      if ReserveDePropertyList[n] <> NIL then
        with ReserveDePropertyList[n]^ do
          if (buffer <> NIL) and (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDePropertyList := true;
                  nroPage := n;
                  nroIndex := i;
                  pagePropertyListRenvoyeeParDerniereCreation := n;
                  exit;
                end;

      {un coup en descendant...}
      n := pagePropertyListRenvoyeeParDerniereCreation - k - 1;
      if (n > dernierePagePropertyListCree) then n := n - dernierePagePropertyListCree else
      if (n < 1) then n := n + dernierePagePropertyListCree;
      if ReserveDePropertyList[n] <> NIL then
        with ReserveDePropertyList[n]^ do
          if (buffer <> NIL) and (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDePropertyList := true;
                  nroPage := n;
                  nroIndex := i;
                  pagePropertyListRenvoyeeParDerniereCreation := n;
                  exit;
                end;
    end;

  {pas de place vide trouvee : on demande la creation d'une nouvelle page}
  if PeutCreerNouvellePagePropertyList
    then
	    begin
	      TrouvePlaceDansPageDePropertyList := true;
	      nroPage := dernierePagePropertyListCree;
	      nroIndex := 1;
	      pagePropertyListRenvoyeeParDerniereCreation := dernierePagePropertyListCree;
	    end
    else
      begin
	      TrouvePlaceDansPageDePropertyList := false;
	      nroPage := -1;
	      nroIndex := -1;
	    end;
end;



procedure LocaliserPropertyListDansSaPage(L : PropertyList; var nroDePage,nroIndex : SInt32);
var i,k : SInt32;
    baseAddress : SInt32;
begin
  if L = NIL then
    begin
      nroDePage := 0;
      nroIndex := 0;
      {WritelnDansRapport('appel de LocaliserPropertyListDansSaPage(NIL)');}
      exit;
    end;


  for k := 0 to (dernierePagePropertyListCree div 2) do
    begin
      {un coup en montant...}
      i := pagePropertyListRenvoyeeParDerniereLocalisation + k;
      if (i > dernierePagePropertyListCree) then i := i - dernierePagePropertyListCree else
      if (i < 1) then i := i + dernierePagePropertyListCree;
      if ReserveDePropertyList[i] <> NIL then
	      with ReserveDePropertyList[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(L) >= baseAddress) and (SInt32(L) <= baseAddress + (TaillePropertyListBuffer - 1)*sizeof(PropertyListRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(L) - baseAddress) div sizeof(PropertyListRec);
	              pagePropertyListRenvoyeeParDerniereLocalisation := i;
	              exit;
	            end;
	      end;

      {un coup en descendant...}
      i := pagePropertyListRenvoyeeParDerniereLocalisation - k - 1;
      if (i > dernierePagePropertyListCree) then i := i - dernierePagePropertyListCree else
      if (i < 1) then i := i + dernierePagePropertyListCree;
      if ReserveDePropertyList[i] <> NIL then
	      with ReserveDePropertyList[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(L) >= baseAddress) and (SInt32(L) <= baseAddress + (TaillePropertyListBuffer - 1)*sizeof(PropertyListRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(L) - baseAddress) div sizeof(PropertyListRec);
	              pagePropertyListRenvoyeeParDerniereLocalisation := i;
	              exit;
	            end;
	      end;
	  end;


  {non trouve ! ce n'est pas normal !}
  nroDePage := -1;
  nroIndex := -1;
  AlerteSimple('Erreur dans LocaliserPropertyListDansSaPage !! Prévenez Stéphane');
end;


function NewPropertyListPaginee : PropertyList;
var numeroDePage,IndexDansPage : SInt32;
begin
  if TrouvePlaceDansPageDePropertyList(numeroDePage,IndexDansPage)
    then
      begin
        {WritelnDansRapport('creation de ('+IntToStr(numeroDePage)+','+IntToStr(IndexDansPage)+')');
        WritelnDansRapport('');}
        with ReserveDePropertyList[numeroDePage]^ do
          begin
            NewPropertyListPaginee := PropertyList(@buffer^[IndexDansPage]);
            libre[IndexDansPage] := false;
            dec(nbEmplacementVides);
            if nbEmplacementVides <= 0
              then
                begin
                  premierEmplacementVide := 0;
                  dernierEmplacementVide := 0;
                end
              else
                begin
                  if IndexDansPage = premierEmplacementVide then
			              repeat
			                inc(premierEmplacementVide);
			              until libre[premierEmplacementVide] or (premierEmplacementVide >= dernierEmplacementVide) or (premierEmplacementVide > TaillePropertyListBuffer);
                  if IndexDansPage = dernierEmplacementVide then
			              repeat
			                dec(dernierEmplacementVide);
			              until libre[dernierEmplacementVide] or (dernierEmplacementVide <= premierEmplacementVide) or (dernierEmplacementVide < 1);
                end;
          end
      end
    else
      begin
        NewPropertyListPaginee := NIL;
      end;
end;


procedure DisposePropertyListPaginee(L : PropertyList);
var nroDePage,nroIndex : SInt32;
begin

  {
  WritelnNumDansRapport('appel de DisposePropertyListPaginee pour @',SInt32(L));
  }

  LocaliserPropertyListDansSaPage(L,nroDePage,nroIndex);


  if (nroDePage >= 1) and (nroDePage <= nbPagesDePropertyList) and
     (nroIndex  >= 1) and (nroIndex  <= TaillePropertyListBuffer) and
     (ReserveDePropertyList[nroDePage] <> NIL) then
    with ReserveDePropertyList[nroDePage]^ do
      begin

        {
        WritelnDansRapport('destruction de ('+IntToStr(nroDePage)+','+IntToStr(nroIndex)+')');
        }

        libre[nroIndex] := true;
        if nbEmplacementVides <= 0
          then
            begin
              nbEmplacementVides := 1;
              premierEmplacementVide := nroIndex;
              dernierEmplacementVide := nroIndex;
            end
          else
            begin
              inc(nbEmplacementVides);
              if (nroIndex < premierEmplacementVide) then premierEmplacementVide := nroIndex;
              if (nroIndex > dernierEmplacementVide) then dernierEmplacementVide := nroIndex;
            end;
      end
end;


END.
