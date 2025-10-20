UNIT UnitPagesDeModules;



INTERFACE




 USES UnitDefCassio;



procedure InitUnitPagesDeModule;
procedure DisposeToutesLesPagesDeModule;


function PeutCreerNouvellePageModule : boolean;
function TrouvePlaceDansPageDeModule(var nroPage,nroIndex : SInt32) : boolean;
procedure LocaliserModuleDansSaPage(theModule : Module; var nroDePage,nroIndex : SInt32);


function NewModulePaginee : Module;
procedure DisposeModulePaginee(theModule : Module);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesDialogs, UnitServicesMemoire, UnitRapport, MyStrings ;
{$ELSEC}
    {$I prelink/PagesDeModules.lk}
{$ENDC}


{END_USE_CLAUSE}












const TailleModuleBuffer = 500;
type ModuleArray = array[1..TailleModuleBuffer] of ModuleRec;
     ModuleBuffer = ^ModuleArray;
     PageDeModule =  record
                         buffer : ModuleBuffer;
                         libre  : {packed} array[0..TailleModuleBuffer] of boolean;
                         premierEmplacementVide : SInt16;
                         dernierEmplacementVide : SInt16;
                         nbEmplacementVides     : SInt16;
                       end;
     PageDeModulePtr = ^PageDeModule;


const nbPagesDeModule = 10000;
var ReserveDeModule : array [1..nbPagesDeModule] of PageDeModulePtr;
    dernierePageModuleCree : SInt32;
    pageModuleRenvoyeeParDerniereLocalisation : SInt32;
    pageModuleRenvoyeeParDerniereCreation : SInt32;


procedure InitUnitPagesDeModule;
var i : SInt32;
begin
  for i := 1 to nbPagesDeModule do
	  begin
	    ReserveDeModule[i] := NIL;
	  end;
	dernierePageModuleCree := 0;
	pageModuleRenvoyeeParDerniereLocalisation := 1;
	pageModuleRenvoyeeParDerniereCreation := 1;
	(*
	if PeutCreerNouvellePageModule then DoNothing;
	if PeutCreerNouvellePageModule then DoNothing;
	if PeutCreerNouvellePageModule then DoNothing;
	if PeutCreerNouvellePageModule then DoNothing;
	*)
end;


procedure DisposeToutesLesPagesDeModule;
begin
  {
  for i := 1 to nbPagesDeModule do
	  if ReserveDeModule[i] <> NIL then
	    begin
	      DisposeMemoryPtr(Ptr(ReserveDeModule[i]^.buffer));
	      ReserveDeModule[i]^.buffer := NIL;
	      DisposeMemoryPtr(Ptr(ReserveDeModule[i]));
	      ReserveDeModule[i] := NIL;
	    end;
	dernierePageModuleCree := 0;
	pageModuleRenvoyeeParDerniereLocalisation := 1;
	pageModuleRenvoyeeParDerniereCreation := 1;
	}
end;



function PeutCreerNouvellePageModule : boolean;
var i : SInt32;
begin

  if dernierePageModuleCree >= nbPagesDeModule then
    begin
      AlerteSimple('le nombre de pages de Module est trop petit dans PeutCreerNouvellePageModule!! Prévenez Stéphane');
      PeutCreerNouvellePageModule := false;
      exit(PeutCreerNouvellePageModule);
    end;


  inc(dernierePageModuleCree);
  ReserveDeModule[dernierePageModuleCree] := PageDeModulePtr(AllocateMemoryPtr(sizeof(PageDeModule)));

  if ReserveDeModule[dernierePageModuleCree] = NIL then
    begin
      AlerteSimple('plus de place en memoire pour creer une page de Module dans PeutCreerNouvellePageModule!! Prévenez Stéphane');
      PeutCreerNouvellePageModule := false;
      exit(PeutCreerNouvellePageModule);
    end;

  with ReserveDeModule[dernierePageModuleCree]^ do
    begin
      buffer := ModuleBuffer(AllocateMemoryPtr(sizeof(ModuleArray)+20));
      if buffer = NIL then
        begin
          AlerteSimple('plus de place en memoire pour creer un buffer de Module dans PeutCreerNouvellePageModule !! Prévenez Stéphane');
          PeutCreerNouvellePageModule := false;
          exit(PeutCreerNouvellePageModule);
        end;


      PeutCreerNouvellePageModule := true;

      for i := 1 to TailleModuleBuffer do
        libre[i] := true;
      premierEmplacementVide := 1;
      dernierEmplacementVide := TailleModuleBuffer;
      nbEmplacementVides    := TailleModuleBuffer;
    end;

  {
  WritelnDansRapport('Création d''une nouvelle page de Module');
  WritelnNumDansRapport('soldeCreationModule = ',soldeCreationModule);
  SysBeep(0);
  AttendFrappeClavier;
  }

end;


function TrouvePlaceDansPageDeModule(var nroPage,nroIndex : SInt32) : boolean;
var n,i,k : SInt32;
begin
  if (dernierePageModuleCree <= 0) & not(PeutCreerNouvellePageModule) then
    begin
      TrouvePlaceDansPageDeModule := false;
      nroPage := -1;
      nroIndex := -1;
      exit(TrouvePlaceDansPageDeModule);
    end;

  {
  for n := 1 to dernierePageModuleCree do
    begin
    if ReserveDeModule[n] <> NIL then
      with ReserveDeModule[n]^ do
        begin
          WritelnDansRapport('Reserve['+NumEnString(n)+'] est OK');
          WritelnNumDansRapport('nbEmplacementVides = ',nbEmplacementVides);
          WritelnNumDansRapport('premierEmplacementVide = ',premierEmplacementVide);
          WritelnNumDansRapport('dernierEmplacementVide = ',dernierEmplacementVide);
          WritelnNumDansRapport('soldeCreationModule = ',soldeCreationModule);
         end;
     if dernierePageModuleCree >= 2 then AttendFrappeClavier;
     end;
  }

  for k := 0 to (dernierePageModuleCree div 2) do
    begin
      {un coup en montant...}
      n := pageModuleRenvoyeeParDerniereCreation + k;
      if (n > dernierePageModuleCree) then n := n - dernierePageModuleCree else
      if (n < 1) then n := n + dernierePageModuleCree;
      if ReserveDeModule[n] <> NIL then
        with ReserveDeModule[n]^ do
          if (buffer <> NIL) & (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeModule := true;
                  nroPage := n;
                  nroIndex := i;
                  pageModuleRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeModule);
                end;

      {un coup en descendant...}
      n := pageModuleRenvoyeeParDerniereCreation - k - 1;
      if (n > dernierePageModuleCree) then n := n - dernierePageModuleCree else
      if (n < 1) then n := n + dernierePageModuleCree;
      if ReserveDeModule[n] <> NIL then
        with ReserveDeModule[n]^ do
          if (buffer <> NIL) & (nbEmplacementVides > 0) then
            for i := premierEmplacementVide to dernierEmplacementVide do
              if libre[i] then
                begin
                  TrouvePlaceDansPageDeModule := true;
                  nroPage := n;
                  nroIndex := i;
                  pageModuleRenvoyeeParDerniereCreation := n;
                  exit(TrouvePlaceDansPageDeModule);
                end;
    end;

  {pas de place vide trouvee : on demande la creation d'une nouvelle page}
  if PeutCreerNouvellePageModule
    then
	    begin
	      TrouvePlaceDansPageDeModule := true;
	      nroPage := dernierePageModuleCree;
	      nroIndex := 1;
	      pageModuleRenvoyeeParDerniereCreation := dernierePageModuleCree;
	    end
    else
      begin
	      TrouvePlaceDansPageDeModule := false;
	      nroPage := -1;
	      nroIndex := -1;
	    end
end;



procedure LocaliserModuleDansSaPage(theModule : Module; var nroDePage,nroIndex : SInt32);
var i,k : SInt32;
    baseAddress : SInt32;
begin
  if theModule = NIL then
    begin
      nroDePage := 0;
      nroIndex := 0;
      {WritelnDansRapport('appel de LocaliserModuleDansSaPage(NIL)');}
      exit(LocaliserModuleDansSaPage);
    end;


  for k := 0 to (dernierePageModuleCree div 2) do
    begin
      {un coup en montant...}
      i := pageModuleRenvoyeeParDerniereLocalisation + k;
      if (i > dernierePageModuleCree) then i := i - dernierePageModuleCree else
      if (i < 1) then i := i + dernierePageModuleCree;
	    if ReserveDeModule[i] <> NIL then
	      with ReserveDeModule[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(theModule) >= baseAddress) & (SInt32(theModule) <= baseAddress+(TailleModuleBuffer-1)*sizeof(ModuleRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(theModule)-baseAddress) div sizeof(ModuleRec);
	              pageModuleRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserModuleDansSaPage);
	            end;
	      end;

	    {un coup en descendant...}
      i := pageModuleRenvoyeeParDerniereLocalisation - k - 1;
      if (i > dernierePageModuleCree) then i := i - dernierePageModuleCree else
      if (i < 1) then i := i + dernierePageModuleCree;
	    if ReserveDeModule[i] <> NIL then
	      with ReserveDeModule[i]^ do
	      begin
	        baseAddress := SInt32(buffer);
	        if (SInt32(theModule) >= baseAddress) & (SInt32(theModule) <= baseAddress+(TailleModuleBuffer-1)*sizeof(ModuleRec))
	          then
	            begin
	              nroDePage := i;
	              nroIndex := 1 + (SInt32(theModule)-baseAddress) div sizeof(ModuleRec);
	              pageModuleRenvoyeeParDerniereLocalisation := i;
	              exit(LocaliserModuleDansSaPage);
	            end;
	      end;
	  end;

  {non trouve ! ce n'est pas normal !}
  nroDePage := -1;
  nroIndex := -1;
  AlerteSimple('Erreur dans LocaliserModuleDansSaPage !! Prévenez Stéphane');
end;


function NewModulePaginee : Module;
var numeroDePage,IndexDansPage : SInt32;
begin
  if TrouvePlaceDansPageDeModule(numeroDePage,IndexDansPage)
    then
      begin
        {WritelnDansRapport('creation de Module('+NumEnString(numeroDePage)+','+NumEnString(IndexDansPage)+')');
        WritelnDansRapport('');}

        with ReserveDeModule[numeroDePage]^ do
          begin
            NewModulePaginee := Module(@buffer^[IndexDansPage]);
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
			              until libre[premierEmplacementVide] | (premierEmplacementVide >= dernierEmplacementVide) | (premierEmplacementVide > TailleModuleBuffer);
                  if IndexDansPage = dernierEmplacementVide then
			              repeat
			                dec(dernierEmplacementVide);
			              until libre[dernierEmplacementVide] | (dernierEmplacementVide <= premierEmplacementVide) | (dernierEmplacementVide < 1);
                end;
          end
      end
    else
      begin
        NewModulePaginee := NIL;
      end;
end;


procedure DisposeModulePaginee(theModule : Module);
var nroDePage,nroIndex : SInt32;
begin


  {WritelnNumDansRapport('appel de DisposeModulePaginee pour @',SInt32(theModule));}

  LocaliserModuleDansSaPage(theModule,nroDePage,nroIndex);


  if (nroDePage >= 1) & (nroDePage <= nbPagesDeModule) &
     (nroIndex  >= 1) & (nroIndex  <= TailleModuleBuffer) &
     (ReserveDeModule[nroDePage] <> NIL) then
    with ReserveDeModule[nroDePage]^ do
      begin

        {WritelnDansRapport('destruction de Module('+NumEnString(nroDePage)+','+NumEnString(nroIndex)+')');}

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
