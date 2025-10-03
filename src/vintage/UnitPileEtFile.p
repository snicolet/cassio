UNIT UnitPileEtFile;



{ Gestion de piles et de files de SInt32: c'est la meme chose,
  donc on implemente tout avec une structure de donnees qui
  est a la fois une pile et une file}

INTERFACE







 USES UnitDefCassio;





{Creation/destruction}
function AllocatePile(tailleDemandee : SInt32; var ok : boolean) : Pile;                                                                                                            ATTRIBUTE_NAME('AllocatePile')
procedure DisposePile(var whichPile : Pile);                                                                                                                                        ATTRIBUTE_NAME('DisposePile')
procedure ViderPile(var whichPile : Pile);                                                                                                                                          ATTRIBUTE_NAME('ViderPile')
procedure ViderFile(var whichPile : Pile);                                                                                                                                          ATTRIBUTE_NAME('ViderFile')

{Tests}
function PileEstVide(whichPile : Pile) : boolean;                                                                                                                                   ATTRIBUTE_NAME('PileEstVide')
function FileEstVide(whichPile : Pile) : boolean;                                                                                                                                   ATTRIBUTE_NAME('FileEstVide')
function PileEstPleine(whichPile : Pile) : boolean;                                                                                                                                 ATTRIBUTE_NAME('PileEstPleine')
function FileEstPleine(whichPile : Pile) : boolean;                                                                                                                                 ATTRIBUTE_NAME('FileEstPleine')
function EstDansPile(element : SInt32; whichPile : Pile) : boolean;                                                                                                                 ATTRIBUTE_NAME('EstDansPile')
function EstDansFile(element : SInt32; whichPile : Pile) : boolean;                                                                                                                 ATTRIBUTE_NAME('EstDansFile')
function NbElementsDansPile(whichPile : Pile) : SInt32;                                                                                                                             ATTRIBUTE_NAME('NbElementsDansPile')
function NbElementsDansFile(whichPile : Pile) : SInt32;                                                                                                                             ATTRIBUTE_NAME('NbElementsDansFile')

{Ajouts}
procedure Empiler(var whichPile : Pile; element : SInt32; var ok : boolean);                                                                                                        ATTRIBUTE_NAME('Empiler')
procedure Enfiler(var whichPile : Pile; element : SInt32; var ok : boolean);                                                                                                        ATTRIBUTE_NAME('Enfiler')
procedure EmpilerSiPasDansPile(var whichPile : Pile; element : SInt32; var ok : boolean);                                                                                           ATTRIBUTE_NAME('EmpilerSiPasDansPile')
procedure EnfilerSiPasDansFile(var whichPile : Pile; element : SInt32; var ok : boolean);                                                                                           ATTRIBUTE_NAME('EnfilerSiPasDansFile')


{Acces non destructifs}
function GetElementDeQueue(whichPile : Pile) : SInt32;                                                                                                                              ATTRIBUTE_NAME('GetElementDeQueue')
function GetElementDeTete(whichPile : Pile) : SInt32;                                                                                                                               ATTRIBUTE_NAME('GetElementDeTete')

{Acces destructifs}
function Depiler(var whichPile : Pile; var ok : boolean) : SInt32;                                                                                                                  ATTRIBUTE_NAME('Depiler')
function Defiler(var whichPile : Pile; var ok : boolean) : SInt32;                                                                                                                  ATTRIBUTE_NAME('Defiler')

{Test de l'unit�}
procedure TestPilesEtFiles;                                                                                                                                                         ATTRIBUTE_NAME('TestPilesEtFiles')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    MyStrings, UnitServicesMemoire, UnitRapport ;
{$ELSEC}
    {$I prelink/PileEtFile.lk}
{$ENDC}


{END_USE_CLAUSE}











function AllocatePile(tailleDemandee : SInt32; var ok : boolean) : Pile;
var result : Pile;
    theSize : SInt32;
begin
  with result do
    begin
      tete := 0;
      queue := 0;
      theSize := sizeof(SInt32)*(tailleDemandee+1);
      if theSize >= 12  {on refuse de creer une pile de un element ou moins}
        then
          begin
            data := LongintArrayHdl(AllocateMemoryHdl(theSize));
            if data <> NIL
              then taille := tailleDemandee+1
              else taille := 0;
          end
        else
          begin
            taille := 0;
            data := NIL;
          end;
    end;
  ok := result.data <> NIL;
  AllocatePile := result;
end;

procedure DisposePile(var whichPile : Pile);
begin
  with whichPile do
    begin
      taille := 0;
      tete := 0;
      queue := 0;
      if data <> NIL then
        begin
          DisposeMemoryHdl(Handle(data));
          data := NIL;
        end;
    end;
end;

procedure ViderPile(var whichPile : Pile);
begin
  with whichPile do
    begin
      tete := 0;
      queue := 0;
    end;
end;

procedure ViderFile(var whichPile : Pile);
begin
  ViderPile(whichPile);
end;


function PileEstVide(whichPile : Pile) : boolean;
begin
  PileEstVide := (whichPile.tete = whichPile.queue) | (whichPile.data = NIL);
end;

function FileEstVide(whichPile : Pile) : boolean;
begin
  FileEstVide := PileEstVide(whichPile);
end;

function PileEstPleine(whichPile : Pile) : boolean;
begin
  with whichPile do
    PileEstPleine := (tete+1 = queue) | ((tete = taille-1) & (queue = 0));
end;

function FileEstPleine(whichPile : Pile) : boolean;
begin
  FileEstPleine := PileEstPleine(whichPile);
end;

function EstDansPile(element : SInt32; whichPile : Pile) : boolean;
var t : SInt32;
begin
  if PileEstVide(whichPile)
    then
      EstDansPile := false
    else
      with whichPile do
        begin
          t := queue;
          repeat
            inc(t);
            if t >= taille then t := 0;
            if data^^[t] = element then
              begin  { trouve! }
                EstDansPile := true;
                exit(EstDansPile);
              end;
          until t = tete;
          {on a fait tous les elements sans succes}
          EstDansPile := false;
        end;
end;


function EstDansFile(element : SInt32; whichPile : Pile) : boolean;
begin
  EstDansFile := EstDansPile(element,whichPile);
end;

function NbElementsDansPile(whichPile : Pile) : SInt32;
var n : SInt32;
begin
  with whichPile do
    begin
      n := tete - queue;
      if n < 0 then n := n+taille;
      NbElementsDansPile := n;
    end;
end;

function NbElementsDansFile(whichPile : Pile) : SInt32;
begin
  NbElementsDansFile := NbElementsDansPile(whichPile);
end;

procedure AjouterEnTete(var whichPile : Pile; element : SInt32; var ok : boolean);
var aux : SInt32;
begin
  with whichPile do
    begin
      if data = NIL then
        begin
          ok := false;
          exit(AjouterEnTete);
        end;

      aux := tete+1;
      if aux >= taille then aux := 0;
      if aux <> queue
        then
          begin
            ok := true;
            tete := aux;
            data^^[tete] := element;
          end
        else
          begin  {debordement de capacite}
            ok := false;
            WritelnDansRapport('## ALERTE : d�passement de capacit� de pile/file ##');
          end;
    end;
end;

procedure AjouterEnQueue(var whichPile : Pile; element : SInt32; var ok : boolean);
var aux : SInt32;
begin
  with whichPile do
    begin
      if data = NIL then
        begin
          ok := false;
          exit(AjouterEnQueue);
        end;

      aux := queue-1;
      if aux < 0 then aux := taille-1;
      if aux <> tete
        then
          begin
            ok := true;
            data^^[queue] := element;
            queue := aux;
          end
        else
          begin  {debordement de capacite}
            ok := false;
            WritelnDansRapport('## ALERTE : d�passement de capacit� de pile/file ##');
          end;
    end;
end;

procedure Empiler(var whichPile : Pile; element : SInt32; var ok : boolean);
begin
  AjouterEnTete(whichPile,element,ok);
end;

procedure Enfiler(var whichPile : Pile; element : SInt32; var ok : boolean);
begin
  AjouterEnQueue(whichPile,element,ok);
end;

procedure EmpilerSiPasDansPile(var whichPile : Pile; element : SInt32; var ok : boolean);
begin
  if not(EstDansPile(element,whichPile))
    then AjouterEnTete(whichPile,element,ok);
end;

procedure EnfilerSiPasDansFile(var whichPile : Pile; element : SInt32; var ok : boolean);
begin
  if not(EstDansFile(element,whichPile))
    then AjouterEnQueue(whichPile,element,ok);
end;


function GetElementDeQueue(whichPile : Pile) : SInt32;
var aux : SInt32;
begin
  if PileEstVide(whichPile)
    then GetElementDeQueue := -1
    else
      begin
        aux := whichPile.queue+1;
        if aux >= whichPile.taille then aux := 0;
        GetElementDeQueue := whichPile.data^^[aux];
      end;
end;

function GetElementDeTete(whichPile : Pile) : SInt32;
begin
  if PileEstVide(whichPile)
    then GetElementDeTete := -1
    else GetElementDeTete := whichPile.data^^[whichPile.tete];
end;

function RetirerEnTete(var whichPile : Pile; var ok : boolean) : SInt32;
begin
  with whichPile do
    begin
      if (data = NIL) | (tete = queue) then
        begin
          ok := false;
          RetirerEnTete := -1;
          exit(RetirerEnTete);
        end;

      ok := true;
      RetirerEnTete := data^^[tete];

      tete := tete-1;
      if tete < 0 then tete := taille-1;
    end;
end;

function RetirerEnQueue(var whichPile : Pile; var ok : boolean) : SInt32;
begin
  with whichPile do
    begin
      if (data = NIL) | (tete = queue) then  {Pile vide ?}
        begin
          ok := false;
          RetirerEnQueue := -1;
          exit(RetirerEnQueue);
        end;

      ok := true;


      queue := queue+1;
      if queue >= taille then queue := 0;

      RetirerEnQueue := data^^[queue];

    end;
end;


function Depiler(var whichPile : Pile; var ok : boolean) : SInt32;
begin
  Depiler := RetirerEnTete(whichPile,ok);
end;

function Defiler(var whichPile : Pile; var ok : boolean) : SInt32;
begin
  Defiler := RetirerEnQueue(whichPile,ok);
end;


procedure WritePileDansRapport(whichPile : Pile);
begin
  with whichPile do
    begin
      WriteNumDansRapport('queue = ',queue);
      WriteNumDansRapport('  tete = ',tete);
      WriteNumDansRapport('  pile[queue] = ',GetElementDeQueue(whichPile));
      WritelnNumDansRapport('  pile[tete] = ',GetElementDeTete(whichPile));
    end;
end;

procedure TestPilesEtFiles;
var maPile : Pile;
    i,k,t : SInt32;
    ok : boolean;
begin
  maPile := AllocatePile(10,ok);
  WritelnStringAndBoolDansRapport('cr�ation de AllocatePile(10) = ',ok);
  WritePileDansRapport(maPile);


  WritelnDansRapport('test empilement/depilement');
  WritePileDansRapport(maPile);
  for i := 1 to 15 do
    begin
      Empiler(maPile,i,ok);
      WritelnStringAndBoolDansRapport('Empiler '+NumEnString(i)+' => ',ok);
      WritePileDansRapport(maPile);
    end;
  for i := 1 to 15 do
    begin
      t := Depiler(maPile,ok);
      WritelnStringAndBoolDansRapport('Depiler = '+NumEnString(t)+' => ',ok);
      WritePileDansRapport(maPile);
    end;
  WritelnDansRapport('test empilement/defilemnt');
  WritePileDansRapport(maPile);
  for i := 1 to 15 do
    begin
      Empiler(maPile,i,ok);
      WritelnStringAndBoolDansRapport('Empiler '+NumEnString(i)+' => ',ok);
      WritePileDansRapport(maPile);
    end;
  for i := 1 to 15 do
    begin
      t := Defiler(maPile,ok);
      WritelnStringAndBoolDansRapport('Defiler = '+NumEnString(t)+' => ',ok);
      WritePileDansRapport(maPile);
    end;
  WritelnDansRapport('test enfilement/depilemnt');
  WritePileDansRapport(maPile);
  for i := 1 to 15 do
    begin
      Enfiler(maPile,i,ok);
      WritelnStringAndBoolDansRapport('Enfiler '+NumEnString(i)+' => ',ok);
      WritePileDansRapport(maPile);
    end;
  for i := 1 to 15 do
    begin
      t := Depiler(maPile,ok);
      WritelnStringAndBoolDansRapport('Depiler = '+NumEnString(t)+' => ',ok);
      WritePileDansRapport(maPile);
    end;
  WritelnDansRapport('test enfilement/defilemnt');
  WritePileDansRapport(maPile);
  for i := 1 to 15 do
    begin
      Enfiler(maPile,i,ok);
      WritelnStringAndBoolDansRapport('Enfiler '+NumEnString(i)+' => ',ok);
      WritePileDansRapport(maPile);
    end;
  for i := 1 to 15 do
    begin
      t := Defiler(maPile,ok);
      WritelnStringAndBoolDansRapport('Defiler = '+NumEnString(t)+' => ',ok);
      WritePileDansRapport(maPile);
    end;

  ViderPile(maPile);
  WritelnDansRapport('test enfilement/defilemnt');
  WritePileDansRapport(maPile);
  k := 0;
  for i := 1 to 25 do
    begin
      inc(k);
      Empiler(maPile,k,ok);
      WritelnStringAndBoolDansRapport('Empiler '+NumEnString(k)+' => ',ok);
      WritePileDansRapport(maPile);
      inc(k);
      Empiler(maPile,k,ok);
      WritelnStringAndBoolDansRapport('Empiler '+NumEnString(k)+' => ',ok);
      WritePileDansRapport(maPile);
      t := Defiler(maPile,ok);
      WritelnStringAndBoolDansRapport('Defiler = '+NumEnString(t)+' => ',ok);
      WritePileDansRapport(maPile);
    end;


  DisposePile(maPile);
end;


END.
