UNIT UnitSymmetricalMapping;

INTERFACE







 uses UnitDefCassio;



procedure InitUnitSymmetricalMapping;
procedure AlloueMemoireSymmetricalMapping;

function SymmetricalMappingLongSquaresLine(n,length : SInt32) : SInt32;
function SymmetricalMapping8SquaresLine(n : SInt32) : SInt32;
function SymmetricalMapping7SquaresLine(n : SInt32) : SInt32;
function SymmetricalMapping6SquaresLine(n : SInt32) : SInt32;
function SymmetricalMapping5SquaresLine(n : SInt32) : SInt32;
function SymmetricalMapping4SquaresLine(n : SInt32) : SInt32;
function SymmetricalMapping3SquaresLine(n : SInt32) : SInt32;
function SymmetricalMapping2SquaresLine(n : SInt32) : SInt32;
function SymmetricalMappingEdge2X(n : SInt32) : SInt32;
function SymmetricalMapping13SquaresCorner(n : SInt32) : SInt32;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, MacMemory
{$IFC NOT(USE_PRELINK)}
    , UnitNewGeneral, UnitRapport, UnitServicesMemoire ;
{$ELSEC}
    ;
    {$I prelink/SymmetricalMapping.lk}
{$ENDC}


{END_USE_CLAUSE}












type
     tableSymetriqueLignesRec = array[0..8,-3281..3281] of SInt32;
     tableSymetriqueEdge2XRec = array[-29525..29525] of SInt32;
     tableSymetrique13CornerRec = array[-797162..797162] of SInt32;


     tableSymetriqueLignesPtr = ^tableSymetriqueLignesRec;
     tableSymetriqueEdge2XPtr = ^tableSymetriqueEdge2XRec;
     tableSymetrique13CornerPtr = ^tableSymetrique13CornerRec;


const kTailleBufferMapping = 16;
      kSymetrisationNonEncoreCalculee = -130000000;  {ou n'importe quelle valeur > 3^13}

var DernierIndexDansBufferMapping : array[0..kTailleMaximumPattern] of SInt32;
    bufferSymmetricalMapping : array[0..kTailleMaximumPattern,0..50] of
                               record
                                 x,result : SInt32;
                               end;
    SymetrisationLigne : tableSymetriqueLignesPtr;
    SymetrisationEdge2X : tableSymetriqueEdge2XPtr;
    SymetrisationCorner13 : tableSymetrique13CornerPtr;

    nouveauEdge2X,nouveauCorner13 : SInt32;



procedure InitUnitSymmetricalMapping;
var i,j : SInt32;
begin
  for i := 0 to kTailleMaximumPattern do
    DernierIndexDansBufferMapping[i] := 0;
  for i := 0 to kTailleMaximumPattern do
    for j := 0 to 50 do
      begin
        bufferSymmetricalMapping[i,j].x := 0;
        bufferSymmetricalMapping[i,j].result := 0;
      end;

  SymetrisationLigne := NIL;
  SymetrisationEdge2X := NIL;
  SymetrisationCorner13 := NIL;

  nouveauEdge2X := 0;
  nouveauCorner13 := 0;
end;


function SymmetricalMappingLongSquaresLine(n,length : SInt32) : SInt32;
var i,sum,aux,nArrivee : SInt32;
begin
  if n = 0
    then
      SymmetricalMappingLongSquaresLine := 0
    else
      begin
        {memoisation ?}
        if (SymetrisationLigne <> NIL) and (SymetrisationLigne^[length,n] <> kSymetrisationNonEncoreCalculee) then
          begin
            SymmetricalMappingLongSquaresLine := SymetrisationLigne^[length,n];
            exit(SymmetricalMappingLongSquaresLine);
          end;

        nArrivee := n;

        (*
        {on recherche dans le buffer}
        for i := 0 to kTailleBufferMapping do
          begin
            aux := DernierIndexDansBufferMapping[length]-i;
            if aux < 0 then aux := aux+kTailleBufferMapping+1;
            if bufferSymmetricalMapping[aux,length].x = n then
              begin
                SymmetricalMappingLongSquaresLine := bufferSymmetricalMapping[aux,length].result;
                exit(SymmetricalMappingLongSquaresLine);
              end;
          end;
        {dommage, on n'a pas trouve, il faut calculer}
        *)


        n := n+(puiss3[length+1] div 2);
			  sum := 0;
			  for i := length downto 1 do
			    begin
			      aux := (n div puiss3[i]);
			      n := n-aux*puiss3[i];
			      dec(aux);
			      sum := sum+aux*puiss3[length+1-i];
			    end;
			  SymmetricalMappingLongSquaresLine := sum;

			  (*
			  {on ajoute dans le buffer}
			  inc(DernierIndexDansBufferMapping[length]);
			  if (DernierIndexDansBufferMapping[length] < 0) or (DernierIndexDansBufferMapping[length] > kTailleBufferMapping)
			    then DernierIndexDansBufferMapping[length] := 0;
			  aux := DernierIndexDansBufferMapping[length];
			  bufferSymmetricalMapping[aux,length].x     := nArrivee;
			  bufferSymmetricalMapping[aux,length].result := sum;
			  *)

			  {memoisation !}
			  if (SymetrisationLigne <> NIL) then
          begin
            SymetrisationLigne^[length,nArrivee] := sum;
            SymetrisationLigne^[length,-nArrivee] := -sum;
          end;

			end;
end;


function SymmetricalMapping8SquaresLine(n : SInt32) : SInt32;
begin
  if n = 0
    then SymmetricalMapping8SquaresLine := 0
    else SymmetricalMapping8SquaresLine := SymmetricalMappingLongSquaresLine(n,8);
end;

function SymmetricalMapping7SquaresLine(n : SInt32) : SInt32;
begin
  if n = 0
    then SymmetricalMapping7SquaresLine := 0
    else SymmetricalMapping7SquaresLine := SymmetricalMappingLongSquaresLine(n,7);
end;

function SymmetricalMapping6SquaresLine(n : SInt32) : SInt32;
begin
  if n = 0
    then SymmetricalMapping6SquaresLine := 0
    else SymmetricalMapping6SquaresLine := SymmetricalMappingLongSquaresLine(n,6);
end;

function SymmetricalMapping5SquaresLine(n : SInt32) : SInt32;
begin
  if n = 0
    then SymmetricalMapping5SquaresLine := 0
    else SymmetricalMapping5SquaresLine := SymmetricalMappingLongSquaresLine(n,5);
end;

function SymmetricalMapping4SquaresLine(n : SInt32) : SInt32;
begin
  if n = 0
    then SymmetricalMapping4SquaresLine := 0
    else SymmetricalMapping4SquaresLine := SymmetricalMappingLongSquaresLine(n,4);
end;

function SymmetricalMapping3SquaresLine(n : SInt32) : SInt32;
begin
  if n = 0
    then SymmetricalMapping3SquaresLine := 0
    else SymmetricalMapping3SquaresLine := SymmetricalMappingLongSquaresLine(n,3);
end;

function SymmetricalMapping2SquaresLine(n : SInt32) : SInt32;
begin
  if n = 0
    then SymmetricalMapping2SquaresLine := 0
    else SymmetricalMapping2SquaresLine := SymmetricalMappingLongSquaresLine(n,2);
end;


function SymmetricalMappingEdge2X(n : SInt32) : SInt32;
var aux1,aux2,nArrivee,sum : SInt32;
begin
  if n = 0
    then
      SymmetricalMappingEdge2X := 0
    else
      begin
        {memoisation ?}
        if (SymetrisationEdge2X <> NIL) and (SymetrisationEdge2X^[n] <> kSymetrisationNonEncoreCalculee) then
          begin
            SymmetricalMappingEdge2X := SymetrisationEdge2X^[n];
            exit(SymmetricalMappingEdge2X);
          end;

        nArrivee := n;

        (*
        {on recherche dans le buffer}
        for i := 0 to kTailleBufferMapping do
          begin
            aux := DernierIndexDansBufferMapping[10]-i;
            if aux < 0 then aux := aux+kTailleBufferMapping+1;
            if bufferSymmetricalMapping[aux,10].x = n then
              begin
                SymmetricalMappingEdge2X := bufferSymmetricalMapping[aux,10].result;
                exit(SymmetricalMappingEdge2X);
              end;
          end;
        {dommage, on n'a pas trouve, il faut calculer}
        *)


        n := n+(puiss3[11] div 2);
			  aux2 := n div puiss3[10];
			  n := n-aux2*puiss3[10];
			  aux1 := n div puiss3[9];
			  n := n-aux1*puiss3[9];
			  dec(aux1);
			  dec(aux2);
			  n := n-(puiss3[9] div 2);
			  sum := SymmetricalMappingLongSquaresLine(n,8)+(aux1*puiss3[10])+(aux2*puiss3[9]);
			  SymmetricalMappingEdge2X := sum;

			  (*
			  {on ajoute dans le buffer}
			  inc(DernierIndexDansBufferMapping[10]);
			  if (DernierIndexDansBufferMapping[10] < 0) or (DernierIndexDansBufferMapping[10] > kTailleBufferMapping)
			    then DernierIndexDansBufferMapping[10] := 0;
			  aux := DernierIndexDansBufferMapping[10];
			  bufferSymmetricalMapping[aux,10].x     := nArrivee;
			  bufferSymmetricalMapping[aux,10].result := sum;
			  *)

			  {memoisation !}
			  if (SymetrisationEdge2X <> NIL) then
          begin
            SymetrisationEdge2X^[nArrivee] := sum;
            SymetrisationEdge2X^[-nArrivee] := -sum;
          end;

			end;
end;

function SymmetricalMapping13SquaresCorner(n : SInt32) : SInt32;
var aux : array[1..13] of SInt32;
    i,nArrivee,sum : SInt32;
begin
  if n = 0
    then
      SymmetricalMapping13SquaresCorner := 0
    else
      begin

        {memoisation ?}
        if (SymetrisationCorner13 <> NIL) and (SymetrisationCorner13^[n] <> kSymetrisationNonEncoreCalculee) then
          begin
            SymmetricalMapping13SquaresCorner := SymetrisationCorner13^[n];
            exit(SymmetricalMapping13SquaresCorner);
          end;

        nArrivee := n;

        (*
        {on recherche dans le buffer}
        for i := 0 to kTailleBufferMapping do
          begin
            baux := DernierIndexDansBufferMapping[13]-i;
            if baux < 0 then baux := baux+kTailleBufferMapping+1;
            if bufferSymmetricalMapping[baux,13].x = n then
              begin
                SymmetricalMapping13SquaresCorner := bufferSymmetricalMapping[baux,13].result;
                exit(SymmetricalMapping13SquaresCorner);
              end;
          end;
        {dommage, on n'a pas trouve, il faut calculer}
        *)


			  n := n+(puiss3[14] div 2);
			  for i := 13 downto 1 do
			    begin
			      aux[i] := (n div puiss3[i]);
			      n := n-aux[i]*puiss3[i];
			      dec(aux[i]);
			    end;
			  sum := aux[1]*puiss3[1]  + aux[5]*puiss3[2]  + aux[9] *puiss3[3]  + aux[12]*puiss3[4] +
			        aux[2]*puiss3[5]  + aux[6]*puiss3[6]  + aux[10]*puiss3[7]  + aux[13]*puiss3[8] +
			        aux[3]*puiss3[9]  + aux[7]*puiss3[10] + aux[11]*puiss3[11] +
			        aux[4]*puiss3[12] + aux[8]*puiss3[13] ;
			  SymmetricalMapping13SquaresCorner := sum;

			  (*
			  {on ajoute dans le buffer}
			  inc(DernierIndexDansBufferMapping[13]);
			  if (DernierIndexDansBufferMapping[13] < 0) or (DernierIndexDansBufferMapping[13] > kTailleBufferMapping)
			    then DernierIndexDansBufferMapping[13] := 0;
			  baux := DernierIndexDansBufferMapping[13];
			  bufferSymmetricalMapping[baux,13].x     := nArrivee;
			  bufferSymmetricalMapping[baux,13].result := sum;
			  *)

			  {memoisation !}
			  if (SymetrisationCorner13 <> NIL) then
          begin
            SymetrisationCorner13^[nArrivee] := sum;
            SymetrisationCorner13^[-nArrivee] := -sum;
          end;

		  end;
end;


procedure AlloueMemoireSymmetricalMapping;
var grow,tailleDisponible,k,i,count : SInt32;
begin
  grow := 0;
  tailleDisponible := MaxMem(grow)-GetTailleReserveePourLesSegments;
  WritelnNumDansRapport('entrŽe dans AlloueMemoireSymmetricalMapping, tailleDisponible = ',tailleDisponible);
  if tailleDisponible > 8000000
    then
      begin

        count := (3281*2+1)*4*9;
        SymetrisationLigne := tableSymetriqueLignesPtr(AllocateMemoryPtr(count));

        count := (29525*2+1)*4;
        SymetrisationEdge2X := tableSymetriqueEdge2XPtr(AllocateMemoryPtr(count));

        count := (797162*2+1)*4;
        SymetrisationCorner13 := tableSymetrique13CornerPtr(AllocateMemoryPtr(count));


        if SymetrisationLigne <> NIL then
          for i := 0 to 8 do
            for k := -3281 to 3281 do
              SymetrisationLigne^[i,k] := kSymetrisationNonEncoreCalculee;
        if SymetrisationEdge2X <> NIL then
          for k := -29525 to 29525 do
            SymetrisationEdge2X^[k] := kSymetrisationNonEncoreCalculee;
        if SymetrisationCorner13 <> NIL then
          for k := -797162 to 797162 do
            SymetrisationCorner13^[k] := kSymetrisationNonEncoreCalculee;

        grow := 0;
        tailleDisponible := MaxMem(grow)-GetTailleReserveePourLesSegments;
        WritelnNumDansRapport('sortie de AlloueMemoireSymmetricalMapping, tailleDisponible = ',tailleDisponible);
      end;

  if SymetrisationLigne = NIL then SysBeep(0);
  if SymetrisationEdge2X = NIL then SysBeep(0);
  if SymetrisationCorner13 = NIL then SysBeep(0);

end;




END.
