UNIT UnitPagesDeGameTreeList;



INTERFACE







 USES UnitDefCassio;


procedure InitUnitPagesDeGameTreeList;
procedure DisposeToutesLesPagesDeGameTreeList;


function PeutCreerNouvellePageGameTreeList : boolean;
function TrouvePlaceDansPageDeGameTreeList(var nroPage,nroIndex : SInt32) : boolean;
procedure LocaliserGameTreeListDansSaPage(L : GameTreeList; var nroDePage,nroIndex : SInt32);


function NewGameTreeListPaginee : GameTreeList;
procedure DisposeGameTreeListPaginee(L : GameTreeList);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitNewGeneral, UnitServicesDialogs, UnitServicesMemoire ;
{$ELSEC}
    {$I prelink/PagesDeGameTreeList.lk}
{$ENDC}


{END_USE_CLAUSE}










const TailleGameTreeListBuffer = 500;
type GameTreeListArray = array[1..TailleGameTreeListBuffer] of GameTreeListRec;
     GameTreeListBuffer = ^GameTreeListArray;
     PageDeGameTreeList =  record
                             buffer : GameTreeListBuffer;
                             libre  : {packed} array[0..TailleGameTreeListBuffer] of boolean;
                             premierEmplacementVide : SInt16;
                             dernierEmplacementVide : SInt16;
                             nbEmplacementVides     : SInt16;
                           end;
     PageDeGameTreeListPtr = ^PageDeGameTreeList;


const nbPagesDeGameTreeList = 100000;
var ReserveDeGameTreeList : array [1..nbPagesDeGameTreeList] of PageDeGameTreeListPtr;
    dernierePageGameTreeListCree : SInt32;
    pageGameTreeListRenvoyeeParDerniereLocalisation : SInt32;
    pageGameTreeListRenvoyeeParDerniereCreation : SInt32;


procedure InitUnitPagesDeGameTreeList;
var i : SInt32;
begin
  for i := 1 to nbPagesDeGameTreeList do
	  begin
	    ReserveDeGameTreeList[i] := NIL;
	  end;
	dernierePageGameTreeListCree := 0;
	pageGameTreeListRenvoyeeParDerniereLocalisation := 1;
	pageGameTreeListRenvoyeeParDerniereCreation := 1;
	if PeutCreerNouvellePageGameTreeList then DoNothing;
	if not(CassioEnEnvironnementMemoireLimite) then
	  begin
	    if PeutCreerNouvellePageGameTreeList then DoNothing;
			if PeutCreerNouvellePageGameTreeList then DoNothing;
			if PeutCreerNouvellePageGameTreeList then DoNothing;
	  end;
end;


procedure DisposeToutesLesPagesDeGameTreeList;
begin
  {
  for i := 1 to nbPagesDeGameTreeList do
	  if ReserveDeGameTreeList[i] <> NIL then
	    begin
	      DisposeMemoryPtr(Ptr(ReserveDeGameTreeList[i]^.buffer));
	      ReserveDeGameTreeList[i]^.buffer := NIL;
	      DisposeMemoryPtr(Ptr(ReserveDeGameTreeList[i]));
	      ReserveDeGameTreeList[i] := NIL;
	    end;
	dernierePageGameTreeListCree := 0;
	pageGameTreeListRenvoyeeParDerniereLocalisation := 1;
	pageGameTreeListRenvoyeeParDerniereCreation := 1;
	}
end;



function PeutCreerNouvellePageGameTreeList : boolean;
var i : SInt32;
begin

  if dernierePageGameTreeListCree >= nbPagesDeGameTreeList then
    begin
      AlerteSimple('le nombre de pages de GameTreeList est trop petit dans PeutCreerNouvellePageGameTreeList!! Prévenez Stéphane');
      PeutCreerNouvellePageGameTreeList := false;
      exit(PeutCreerNouvellePageGameTreeList);
    end;


  inc(dernierePageGameTreeListCree);
  ReserveDeGameTreeList[dernierePageGameTreeListCree] := PageDeGameTreeListPtr(AllocateMemoryPtr(sizeof(PageDeGameTreeList)));

  if ReserveDeGameTreeList[dernierePageGameTreeListCree] = NIL then
    begin
      AlerteSimple('plus de place en memoire pour creer une page de GameTreeList dans PeutCreerNouvellePageGameTreeList!! Prévenez Stéphane');
      PeutCreerNouvellePageGameTreeList := false;
      exit(PeutCreerNouvellePageGameTreeList);
    end;

  with ReserveDeGameTreeList[dernierePageGameTreeListCree]^ do
    begin
      buffer := GameTreeListBuffer(AllocateMemoryPtr(sizeof(GameTreeListArray)+20));
      if buffer = NIL then
        begin
          AlerteSimple('plus de place en memoire pour creer un buffer de GameTreeList dans PeutCreerNouvellePageGameTreeList !! Prévenez Stéphane');
          PeutCreerNouvellePageGameTreeList := false;
          exit(PeutCreerNouvellePageGameTreeList);
        end;


      PeutCreerNouvellePageGameTreeList := true;

      for i := 1 to TailleGameTreeListBuffer do
        libre[i] := true;
      premierEmplacementVide := 1;
      dernierEmplacementVide := TailleGameTreeListBuffer;
      nbEmplacementVides    := TailleGameTreeListBuffer;
    end;

  {
  WritelnDansRapport('Création d''une nouvelle page de GameTreeList');
  WritelnNumDansRapport('soldeCreationGameTreeList = ',soldeCreationGameTreeList);
  SysBeep(0);
  AttendFrappeClavier;
  }

end;


function TrouvePlaceDansPageDeGameTreeList(var nroPage,nroIndex : SInt32) : boolean;
var n,i,k : SInt32;
begin
  if (dernierePageGameTreeListCree <= 0) and not(PeutCreerNouvellePageGameTreeList)  then
    begin
      TrouvePlaceDansPageDeGameTreeList := false;
      nroPage := -1;
      nroIndex := -1;
      exit(TrouvePlaceDansPageDeGameTreeList);
    end;

  {
  for n := 1 to dernierePageGameTreeListCree do
    begin
    if ReserveDeGameTreeList[n] <> NIL then
      with ReserveDeGameTreeList[n]^ do
        begin
          WritelnDansRapport('Reserve['+NumEnString(n)+'] est OK');
          WritelnNumDansRapport('nbEmplacementVides = ',nbEmplacementVides);
          WritelnNumDansRapport('premierEmplacementVide = ',premierEmplacementVide);
          WritelnNumDansRapport('dernierEmplacementVide = ',dernierEmplacementVide);
          WritelnNumDansRapport('soldeCreationGameTreeList = ',soldeCreationGameTreeList);
         end;
     if dernierePageGameTreeListCree >= 2 then AttendFrappeClavier;
     end;
  }

  for k := 0 to (dernierePageGameTreeListCree div 2) do
    begin
      {un coup en montant...}
      n := pageGameTreeListRenvoyeeParDerniereCreation + k;
      if (n > dernierePageGameTreeListCree) then n := n - dernierePageGameTreeListCree else
      if (n < 1) then n := n + dernierePageGameTreeListCree;
      if ReserveDeGameTreeList[n] <> NIL then
        with ReserveDeGameTreeList[n]^ do
          if (buffer <> NIL) and (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeGameTreeList := true;
                  nroPage := n;
                  nroIndex := i;
                  pageGameTreeListRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeGameTreeList);
                end;

      {un coup en descendant...}
      n := pageGameTreeListRenvoyeeParDerniereCreation - k - 1;
      if (n > dernierePageGameTreeListCree) then n := n - dernierePageGameTreeListCree else
      if (n < 1) then n := n + dernierePageGameTreeListCree;
      if ReserveDeGameTreeList[n] <> NIL then
        with ReserveDeGameTreeList[n]^ do
          if (buffer <> NIL) and (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeGameTreeList := true;
                  nroPage := n;
                  nroIndex := i;
                  pageGameTreeListRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeGameTreeList);
                end;

    end;


  {pas de place vide trouvee : on demande la creation d'une nouvelle page}
  if PeutCreerNouvellePageGameTreeList
    then
	    begin
	      TrouvePlaceDansPageDeGameTreeList := true;
	      nroPage := dernierePageGameTreeListCree;
	      nroIndex := 1;
	      pageGameTreeListRenvoyeeParDerniereCreation := dernierePageGameTreeListCree;
	    end
    else
      begin
	      TrouvePlaceDansPageDeGameTreeList := false;
	      nroPage := -1;
	      nroIndex := -1;
	    end
end;



procedure LocaliserGameTreeListDansSaPage(L : GameTreeList; var nroDePage,nroIndex : SInt32);
var i,k : SInt32;
    baseAddress : SInt32;
begin
  if L = NIL then
    begin
      nroDePage := 0;
      nroIndex := 0;
      {WritelnDansRapport('appel de LocaliserGameTreeListDansSaPage(NIL)');}
      exit(LocaliserGameTreeListDansSaPage);
    end;

  for k := 0 to (dernierePageGameTreeListCree div 2) do
    begin
      {un coup en montant...}
      i := pageGameTreeListRenvoyeeParDerniereLocalisation + k;
      if (i > dernierePageGameTreeListCree) then i := i - dernierePageGameTreeListCree else
      if (i < 1) then i := i + dernierePageGameTreeListCree;
	    if ReserveDeGameTreeList[i] <> NIL then
	      with ReserveDeGameTreeList[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(L) >= baseAddress) and (SInt32(L) <= baseAddress+(TailleGameTreeListBuffer-1)*sizeof(GameTreeListRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(L)-baseAddress) div sizeof(GameTreeListRec);
	              pageGameTreeListRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserGameTreeListDansSaPage);
	            end;
	      end;

	    {un coup en descendant...}
      i := pageGameTreeListRenvoyeeParDerniereLocalisation - k - 1;
      if (i > dernierePageGameTreeListCree) then i := i - dernierePageGameTreeListCree else
      if (i < 1) then i := i + dernierePageGameTreeListCree;
	    if ReserveDeGameTreeList[i] <> NIL then
	      with ReserveDeGameTreeList[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(L) >= baseAddress) and (SInt32(L) <= baseAddress+(TailleGameTreeListBuffer-1)*sizeof(GameTreeListRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(L)-baseAddress) div sizeof(GameTreeListRec);
	              pageGameTreeListRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserGameTreeListDansSaPage);
	            end;
	      end;
	  end;

  {non trouve ! ce n'est pas normal !}
  nroDePage := -1;
  nroIndex := -1;
  AlerteSimple('Erreur dans LocaliserGameTreeListDansSaPage !! Prévenez Stéphane');
end;


function NewGameTreeListPaginee : GameTreeList;
var numeroDePage,IndexDansPage : SInt32;
begin
  if TrouvePlaceDansPageDeGameTreeList(numeroDePage,IndexDansPage)
    then
      begin
        {WritelnDansRapport('creation de GameTreeList('+NumEnString(numeroDePage)+','+NumEnString(IndexDansPage)+')');
        WritelnDansRapport('');}
        with ReserveDeGameTreeList[numeroDePage]^ do
          begin
            NewGameTreeListPaginee := GameTreeList(@buffer^[IndexDansPage]);
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
			              until libre[premierEmplacementVide] or (premierEmplacementVide >= dernierEmplacementVide) or (premierEmplacementVide > TailleGameTreeListBuffer);
                  if IndexDansPage = dernierEmplacementVide then
			              repeat
			                dec(dernierEmplacementVide);
			              until libre[dernierEmplacementVide] or (dernierEmplacementVide <= premierEmplacementVide) or (dernierEmplacementVide < 1);
                end;
          end
      end
    else
      begin
        NewGameTreeListPaginee := NIL;
      end;
end;


procedure DisposeGameTreeListPaginee(L : GameTreeList);
var nroDePage,nroIndex : SInt32;
begin


  {WritelnNumDansRapport('appel de DisposeGameTreeListPaginee pour @',SInt32(L));}


  LocaliserGameTreeListDansSaPage(L,nroDePage,nroIndex);


  if (nroDePage >= 1) and (nroDePage <= nbPagesDeGameTreeList) and
     (nroIndex  >= 1) and (nroIndex  <= TailleGameTreeListBuffer) and
     (ReserveDeGameTreeList[nroDePage] <> NIL) then
    with ReserveDeGameTreeList[nroDePage]^ do
      begin


        {WritelnDansRapport('destruction de GameTreeList('+NumEnString(nroDePage)+','+NumEnString(nroIndex)+')');}


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
