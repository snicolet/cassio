UNIT UnitPagesABR;



INTERFACE








 USES UnitDefCassio;




procedure InitUnitPagesDeABR;
procedure DisposeToutesLesPagesDeABR;


function PeutCreerNouvellePageABR : boolean;
function TrouvePlaceDansPageDeABR(var nroPage,nroIndex : SInt32) : boolean;
procedure LocaliserABRDansSaPage(G : ABR; var nroDePage,nroIndex : SInt32);


function NewABRPaginee : ABR;
procedure DisposeABRPaginee(x : ABR);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesDialogs, UnitServicesMemoire, UnitRapport ;
{$ELSEC}
    {$I prelink/PagesABR.lk}
{$ENDC}


{END_USE_CLAUSE}










const TailleABRBuffer = 500;
type ABRArray = array[1..TailleABRBuffer] of ABRRec;
     ABRBuffer = ^ABRArray;
     PageDeABR =  record
                         buffer : ABRBuffer;
                         libre  : {packed} array[0..TailleABRBuffer] of boolean;
                         premierEmplacementVide : SInt16;
                         dernierEmplacementVide : SInt16;
                         nbEmplacementVides     : SInt16;
                       end;
     PageDeABRPtr = ^PageDeABR;


const nbPagesDeABR = 100000;
var ReserveDeABR : array [1..nbPagesDeABR] of PageDeABRPtr;
    dernierePageABRCree : SInt32;
    pageABRRenvoyeeParDerniereLocalisation : SInt32;
    pageABRRenvoyeeParDerniereCreation : SInt32;


procedure InitUnitPagesDeABR;
var i : SInt32;
begin
  for i := 1 to nbPagesDeABR do
	  begin
	    ReserveDeABR[i] := NIL;
	  end;
	dernierePageABRCree := 0;
	pageABRRenvoyeeParDerniereLocalisation := 1;
	pageABRRenvoyeeParDerniereCreation := 1;
	if PeutCreerNouvellePageABR then DoNothing;
	if PeutCreerNouvellePageABR then DoNothing;
	if PeutCreerNouvellePageABR then DoNothing;
	if PeutCreerNouvellePageABR then DoNothing;
end;


procedure DisposeToutesLesPagesDeABR;
begin
  {
  for i := 1 to nbPagesDeABR do
	  if ReserveDeABR[i] <> NIL then
	    begin
	      DisposeMemoryPtr(Ptr(ReserveDeABR[i]^.buffer));
	      ReserveDeABR[i]^.buffer := NIL;
	      DisposeMemoryPtr(Ptr(ReserveDeABR[i]));
	      ReserveDeABR[i] := NIL;
	    end;
	dernierePageABRCree := 0;
	pageABRRenvoyeeParDerniereLocalisation := 1;
	pageABRRenvoyeeParDerniereCreation := 1;
	}
end;



function PeutCreerNouvellePageABR : boolean;
var i : SInt32;
begin

  if dernierePageABRCree >= nbPagesDeABR then
    begin
      AlerteSimple('le nombre de pages de ABR est trop petit dans PeutCreerNouvellePageABR!! Prévenez Stéphane');
      PeutCreerNouvellePageABR := false;
      exit(PeutCreerNouvellePageABR);
    end;


  inc(dernierePageABRCree);
  ReserveDeABR[dernierePageABRCree] := PageDeABRPtr(AllocateMemoryPtr(sizeof(PageDeABR)));

  if ReserveDeABR[dernierePageABRCree] = NIL then
    begin
      AlerteSimple('plus de place en memoire pour creer une page de ABR dans PeutCreerNouvellePageABR!! Prévenez Stéphane');
      PeutCreerNouvellePageABR := false;
      exit(PeutCreerNouvellePageABR);
    end;

  with ReserveDeABR[dernierePageABRCree]^ do
    begin
      buffer := ABRBuffer(AllocateMemoryPtr(sizeof(ABRArray)+20));
      if buffer = NIL then
        begin
          AlerteSimple('plus de place en memoire pour creer un buffer de ABR dans PeutCreerNouvellePageABR !! Prévenez Stéphane');
          PeutCreerNouvellePageABR := false;
          exit(PeutCreerNouvellePageABR);
        end;


      PeutCreerNouvellePageABR := true;

      for i := 1 to TailleABRBuffer do
        libre[i] := true;
      premierEmplacementVide := 1;
      dernierEmplacementVide := TailleABRBuffer;
      nbEmplacementVides    := TailleABRBuffer;
    end;

  {
  WritelnDansRapport('Création d''une nouvelle page de ABR');
  WritelnNumDansRapport('soldeCreationABR = ',soldeCreationABR);
  SysBeep(0);
  AttendFrappeClavier;
  }

end;


function TrouvePlaceDansPageDeABR(var nroPage,nroIndex : SInt32) : boolean;
var n,i,k : SInt32;
begin
  if (dernierePageABRCree <= 0) and not(PeutCreerNouvellePageABR) then
    begin
      TrouvePlaceDansPageDeABR := false;
      nroPage := -1;
      nroIndex := -1;
      exit(TrouvePlaceDansPageDeABR);
    end;

  {
  for n := 1 to dernierePageABRCree do
    begin
    if ReserveDeABR[n] <> NIL then
      with ReserveDeABR[n]^ do
        begin
          WritelnDansRapport('Reserve['+IntToStr(n)+'] est OK');
          WritelnNumDansRapport('nbEmplacementVides = ',nbEmplacementVides);
          WritelnNumDansRapport('premierEmplacementVide = ',premierEmplacementVide);
          WritelnNumDansRapport('dernierEmplacementVide = ',dernierEmplacementVide);
          WritelnNumDansRapport('soldeCreationABR = ',soldeCreationABR);
         end;
     if dernierePageABRCree >= 2 then AttendFrappeClavier;
     end;
  }

  for k := 0 to (dernierePageABRCree div 2) do
    begin
      {un coup en montant...}
      n := pageABRRenvoyeeParDerniereCreation + k;
      if (n > dernierePageABRCree) then n := n - dernierePageABRCree else
      if (n < 1) then n := n + dernierePageABRCree;
      if ReserveDeABR[n] <> NIL then
        with ReserveDeABR[n]^ do
          if (buffer <> NIL) and (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeABR := true;
                  nroPage := n;
                  nroIndex := i;
                  pageABRRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeABR);
                end;

      {un coup en descendant...}
      n := pageABRRenvoyeeParDerniereCreation - k - 1;
      if (n > dernierePageABRCree) then n := n - dernierePageABRCree else
      if (n < 1) then n := n + dernierePageABRCree;
      if ReserveDeABR[n] <> NIL then
        with ReserveDeABR[n]^ do
          if (buffer <> NIL) and (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeABR := true;
                  nroPage := n;
                  nroIndex := i;
                  pageABRRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeABR);
                end;
    end;

  {pas de place vide trouvee : on demande la creation d'une nouvelle page}
  if PeutCreerNouvellePageABR
    then
	    begin
	      TrouvePlaceDansPageDeABR := true;
	      nroPage := dernierePageABRCree;
	      nroIndex := 1;
	      pageABRRenvoyeeParDerniereCreation := dernierePageABRCree;
	    end
    else
      begin
	      TrouvePlaceDansPageDeABR := false;
	      nroPage := -1;
	      nroIndex := -1;
	    end
end;



procedure LocaliserABRDansSaPage(G : ABR; var nroDePage,nroIndex : SInt32);
var i,k : SInt32;
    baseAddress : SInt32;
begin
  if G = NIL then
    begin
      nroDePage := 0;
      nroIndex := 0;
      {WritelnDansRapport('appel de LocaliserABRDansSaPage(NIL)');}
      exit(LocaliserABRDansSaPage);
    end;


  for k := 0 to (dernierePageABRCree div 2) do
    begin
      {un coup en montant...}
      i := pageABRRenvoyeeParDerniereLocalisation + k;
      if (i > dernierePageABRCree) then i := i - dernierePageABRCree else
      if (i < 1) then i := i + dernierePageABRCree;
	    if ReserveDeABR[i] <> NIL then
	      with ReserveDeABR[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(G) >= baseAddress) and (SInt32(G) <= baseAddress+(TailleABRBuffer-1)*sizeof(ABRRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(G)-baseAddress) div sizeof(ABRRec);
	              pageABRRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserABRDansSaPage);
	            end;
	      end;

	    {un coup en descendant...}
      i := pageABRRenvoyeeParDerniereLocalisation - k - 1;
      if (i > dernierePageABRCree) then i := i - dernierePageABRCree else
      if (i < 1) then i := i + dernierePageABRCree;
	    if ReserveDeABR[i] <> NIL then
	      with ReserveDeABR[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(G) >= baseAddress) and (SInt32(G) <= baseAddress+(TailleABRBuffer-1)*sizeof(ABRRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(G)-baseAddress) div sizeof(ABRRec);
	              pageABRRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserABRDansSaPage);
	            end;
	      end;
	  end;

  {non trouve ! ce n'est pas normal !}
  nroDePage := -1;
  nroIndex := -1;
  AlerteSimple('Erreur dans LocaliserABRDansSaPage !! Prévenez Stéphane');
end;


function NewABRPaginee : ABR;
var numeroDePage,IndexDansPage : SInt32;
begin
  if TrouvePlaceDansPageDeABR(numeroDePage,IndexDansPage)
    then
      begin
        {WritelnDansRapport('creation de ABR('+IntToStr(numeroDePage)+','+IntToStr(IndexDansPage)+')');
        WritelnDansRapport('');}
        with ReserveDeABR[numeroDePage]^ do
          begin
            NewABRPaginee := ABR(@buffer^[IndexDansPage]);
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
			              until libre[premierEmplacementVide] or (premierEmplacementVide >= dernierEmplacementVide) or (premierEmplacementVide > TailleABRBuffer);
                  if IndexDansPage = dernierEmplacementVide then
			              repeat
			                dec(dernierEmplacementVide);
			              until libre[dernierEmplacementVide] or (dernierEmplacementVide <= premierEmplacementVide) or (dernierEmplacementVide < 1);
                end;
          end
      end
    else
      begin
        NewABRPaginee := NIL;
      end;
end;


procedure DisposeABRPaginee(x : ABR);
var nroDePage,nroIndex : SInt32;
begin


  {WritelnNumDansRapport('appel de DisposeABRPaginee pour @',SInt32(G));}

  LocaliserABRDansSaPage(x,nroDePage,nroIndex);


  if (nroDePage >= 1) and (nroDePage <= nbPagesDeABR) and
     (nroIndex  >= 1) and (nroIndex  <= TailleABRBuffer) and
     (ReserveDeABR[nroDePage] <> NIL) then
    with ReserveDeABR[nroDePage]^ do
      begin

        {WritelnDansRapport('destruction de ABR('+IntToStr(nroDePage)+','+IntToStr(nroIndex)+')');}

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
