UNIT UnitPagesDeSymboles;



INTERFACE




 USES UnitDefCassio;





procedure InitUnitPagesDeSymbole;                                                                                                                                                   ATTRIBUTE_NAME('InitUnitPagesDeSymbole')
procedure DisposeToutesLesPagesDeSymbole;                                                                                                                                           ATTRIBUTE_NAME('DisposeToutesLesPagesDeSymbole')


function PeutCreerNouvellePageSymbole : boolean;                                                                                                                                    ATTRIBUTE_NAME('PeutCreerNouvellePageSymbole')
function TrouvePlaceDansPageDeSymbole(var nroPage,nroIndex : SInt32) : boolean;                                                                                                     ATTRIBUTE_NAME('TrouvePlaceDansPageDeSymbole')
procedure LocaliserSymboleDansSaPage(Sym : Symbole; var nroDePage,nroIndex : SInt32);                                                                                               ATTRIBUTE_NAME('LocaliserSymboleDansSaPage')


function NewSymbolePaginee : Symbole;                                                                                                                                               ATTRIBUTE_NAME('NewSymbolePaginee')
procedure DisposeSymbolePaginee(Sym : Symbole);                                                                                                                                     ATTRIBUTE_NAME('DisposeSymbolePaginee')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesDialogs, UnitServicesMemoire, UnitRapport ;
{$ELSEC}
    {$I prelink/PagesDeSymboles.lk}
{$ENDC}


{END_USE_CLAUSE}










const TailleSymboleBuffer = 100;
type SymboleArray = array[1..TailleSymboleBuffer] of SymboleRec;
     SymboleBuffer = ^SymboleArray;
     PageDeSymbole =  record
                         buffer : SymboleBuffer;
                         libre  : {packed} array[0..TailleSymboleBuffer] of boolean;
                         premierEmplacementVide : SInt16;
                         dernierEmplacementVide : SInt16;
                         nbEmplacementVides     : SInt16;
                       end;
     PageDeSymbolePtr = ^PageDeSymbole;


const nbPagesDeSymbole = 10000;
var ReserveDeSymbole : array [1..nbPagesDeSymbole] of PageDeSymbolePtr;
    dernierePageSymboleCree : SInt32;
    pageSymboleRenvoyeeParDerniereLocalisation : SInt32;
    pageSymboleRenvoyeeParDerniereCreation : SInt32;


procedure InitUnitPagesDeSymbole;
var i : SInt32;
begin
  for i := 1 to nbPagesDeSymbole do
	  begin
	    ReserveDeSymbole[i] := NIL;
	  end;
	dernierePageSymboleCree := 0;
	pageSymboleRenvoyeeParDerniereLocalisation := 1;
	pageSymboleRenvoyeeParDerniereCreation := 1;
	(*
	if PeutCreerNouvellePageSymbole then DoNothing;
	if PeutCreerNouvellePageSymbole then DoNothing;
	if PeutCreerNouvellePageSymbole then DoNothing;
	if PeutCreerNouvellePageSymbole then DoNothing;
	*)
end;


procedure DisposeToutesLesPagesDeSymbole;
begin
  {
  for i := 1 to nbPagesDeSymbole do
	  if ReserveDeSymbole[i] <> NIL then
	    begin
	      DisposeMemoryPtr(Ptr(ReserveDeSymbole[i]^.buffer));
	      ReserveDeSymbole[i]^.buffer := NIL;
	      DisposeMemoryPtr(Ptr(ReserveDeSymbole[i]));
	      ReserveDeSymbole[i] := NIL;
	    end;
	dernierePageSymboleCree := 0;
	pageSymboleRenvoyeeParDerniereLocalisation := 1;
	pageSymboleRenvoyeeParDerniereCreation := 1;
	}
end;



function PeutCreerNouvellePageSymbole : boolean;
var i : SInt32;
begin

  if dernierePageSymboleCree >= nbPagesDeSymbole then
    begin
      AlerteSimple('le nombre de pages de Symbole est trop petit dans PeutCreerNouvellePageSymbole!! Prévenez Stéphane');
      PeutCreerNouvellePageSymbole := false;
      exit(PeutCreerNouvellePageSymbole);
    end;


  inc(dernierePageSymboleCree);
  ReserveDeSymbole[dernierePageSymboleCree] := PageDeSymbolePtr(AllocateMemoryPtr(sizeof(PageDeSymbole)));

  if ReserveDeSymbole[dernierePageSymboleCree] = NIL then
    begin
      AlerteSimple('plus de place en memoire pour creer une page de Symbole dans PeutCreerNouvellePageSymbole!! Prévenez Stéphane');
      PeutCreerNouvellePageSymbole := false;
      exit(PeutCreerNouvellePageSymbole);
    end;

  with ReserveDeSymbole[dernierePageSymboleCree]^ do
    begin
      buffer := SymboleBuffer(AllocateMemoryPtr(sizeof(SymboleArray)+20));
      if buffer = NIL then
        begin
          AlerteSimple('plus de place en memoire pour creer un buffer de Symbole dans PeutCreerNouvellePageSymbole !! Prévenez Stéphane');
          PeutCreerNouvellePageSymbole := false;
          exit(PeutCreerNouvellePageSymbole);
        end;


      PeutCreerNouvellePageSymbole := true;

      for i := 1 to TailleSymboleBuffer do
        libre[i] := true;
      premierEmplacementVide := 1;
      dernierEmplacementVide := TailleSymboleBuffer;
      nbEmplacementVides    := TailleSymboleBuffer;
    end;

  {
  WritelnDansRapport('Création d''une nouvelle page de Symbole');
  WritelnNumDansRapport('soldeCreationSymbole = ',soldeCreationSymbole);
  SysBeep(0);
  AttendFrappeClavier;
  }

end;


function TrouvePlaceDansPageDeSymbole(var nroPage,nroIndex : SInt32) : boolean;
var n,i,k : SInt32;
begin
  if (dernierePageSymboleCree <= 0) & not(PeutCreerNouvellePageSymbole)  then
    begin
      TrouvePlaceDansPageDeSymbole := false;
      nroPage := -1;
      nroIndex := -1;
      exit(TrouvePlaceDansPageDeSymbole);
    end;

  {
  for n := 1 to dernierePageSymboleCree do
    begin
    if ReserveDeSymbole[n] <> NIL then
      with ReserveDeSymbole[n]^ do
        begin
          WritelnDansRapport('Reserve['+NumEnString(n)+'] est OK');
          WritelnNumDansRapport('nbEmplacementVides = ',nbEmplacementVides);
          WritelnNumDansRapport('premierEmplacementVide = ',premierEmplacementVide);
          WritelnNumDansRapport('dernierEmplacementVide = ',dernierEmplacementVide);
          WritelnNumDansRapport('soldeCreationSymbole = ',soldeCreationSymbole);
         end;
     if dernierePageSymboleCree >= 2 then AttendFrappeClavier;
     end;
  }

  for k := 0 to (dernierePageSymboleCree div 2) do
    begin
      {un coup en montant...}
      n := pageSymboleRenvoyeeParDerniereCreation + k;
      if (n > dernierePageSymboleCree) then n := n - dernierePageSymboleCree else
      if (n < 1) then n := n + dernierePageSymboleCree;
      if ReserveDeSymbole[n] <> NIL then
        with ReserveDeSymbole[n]^ do
          if (buffer <> NIL) & (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeSymbole := true;
                  nroPage := n;
                  nroIndex := i;
                  pageSymboleRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeSymbole);
                end;

      {un coup en descendant...}
      n := pageSymboleRenvoyeeParDerniereCreation - k - 1;
      if (n > dernierePageSymboleCree) then n := n - dernierePageSymboleCree else
      if (n < 1) then n := n + dernierePageSymboleCree;
      if ReserveDeSymbole[n] <> NIL then
        with ReserveDeSymbole[n]^ do
          if (buffer <> NIL) & (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeSymbole := true;
                  nroPage := n;
                  nroIndex := i;
                  pageSymboleRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeSymbole);
                end;
    end;

  {pas de place vide trouvee : on demande la creation d'une nouvelle page}
  if PeutCreerNouvellePageSymbole
    then
	    begin
	      TrouvePlaceDansPageDeSymbole := true;
	      nroPage := dernierePageSymboleCree;
	      nroIndex := 1;
	      pageSymboleRenvoyeeParDerniereCreation := dernierePageSymboleCree;
	    end
    else
      begin
	      TrouvePlaceDansPageDeSymbole := false;
	      nroPage := -1;
	      nroIndex := -1;
	    end
end;



procedure LocaliserSymboleDansSaPage(Sym : Symbole; var nroDePage,nroIndex : SInt32);
var i,k : SInt32;
    baseAddress : SInt32;
begin
  if Sym = NIL then
    begin
      nroDePage := 0;
      nroIndex := 0;
      {WritelnDansRapport('appel de LocaliserSymboleDansSaPage(NIL)');}
      exit(LocaliserSymboleDansSaPage);
    end;


  for k := 0 to (dernierePageSymboleCree div 2) do
    begin
      {un coup en montant...}
      i := pageSymboleRenvoyeeParDerniereLocalisation + k;
      if (i > dernierePageSymboleCree) then i := i - dernierePageSymboleCree else
      if (i < 1) then i := i + dernierePageSymboleCree;
	    if ReserveDeSymbole[i] <> NIL then
	      with ReserveDeSymbole[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(Sym) >= baseAddress) & (SInt32(Sym) <= baseAddress+(TailleSymboleBuffer-1)*sizeof(SymboleRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(Sym)-baseAddress) div sizeof(SymboleRec);
	              pageSymboleRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserSymboleDansSaPage);
	            end;
	      end;

	    {un coup en descendant...}
      i := pageSymboleRenvoyeeParDerniereLocalisation - k - 1;
      if (i > dernierePageSymboleCree) then i := i - dernierePageSymboleCree else
      if (i < 1) then i := i + dernierePageSymboleCree;
	    if ReserveDeSymbole[i] <> NIL then
	      with ReserveDeSymbole[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(Sym) >= baseAddress) & (SInt32(Sym) <= baseAddress+(TailleSymboleBuffer-1)*sizeof(SymboleRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(Sym)-baseAddress) div sizeof(SymboleRec);
	              pageSymboleRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserSymboleDansSaPage);
	            end;
	      end;
	  end;

  {non trouve ! ce n'est pas normal !}
  nroDePage := -1;
  nroIndex := -1;
  AlerteSimple('Erreur dans LocaliserSymboleDansSaPage !! Prévenez Stéphane');
end;


function NewSymbolePaginee : Symbole;
var numeroDePage,IndexDansPage : SInt32;
begin
  if TrouvePlaceDansPageDeSymbole(numeroDePage,IndexDansPage)
    then
      begin
        {WritelnDansRapport('creation de Symbole('+NumEnString(numeroDePage)+','+NumEnString(IndexDansPage)+')');
        WritelnDansRapport('');}
        with ReserveDeSymbole[numeroDePage]^ do
          begin
            NewSymbolePaginee := Symbole(@buffer^[IndexDansPage]);
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
			              until libre[premierEmplacementVide] | (premierEmplacementVide >= dernierEmplacementVide) | (premierEmplacementVide > TailleSymboleBuffer);
                  if IndexDansPage = dernierEmplacementVide then
			              repeat
			                dec(dernierEmplacementVide);
			              until libre[dernierEmplacementVide] | (dernierEmplacementVide <= premierEmplacementVide) | (dernierEmplacementVide < 1);
                end;
          end
      end
    else
      begin
        NewSymbolePaginee := NIL;
      end;
end;


procedure DisposeSymbolePaginee(Sym : Symbole);
var nroDePage,nroIndex : SInt32;
begin


  {WritelnNumDansRapport('appel de DisposeSymbolePaginee pour @',SInt32(Sym));}

  LocaliserSymboleDansSaPage(Sym,nroDePage,nroIndex);


  if (nroDePage >= 1) & (nroDePage <= nbPagesDeSymbole) &
     (nroIndex  >= 1) & (nroIndex  <= TailleSymboleBuffer) &
     (ReserveDeSymbole[nroDePage] <> NIL) then
    with ReserveDeSymbole[nroDePage]^ do
      begin

        {WritelnDansRapport('destruction de Symbole('+NumEnString(nroDePage)+','+NumEnString(nroIndex)+')');}

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
