UNIT UnitSearchValues;




INTERFACE







 USES UnitDefCassio;



function MakeSearchResultFromHeuristicValue(midgameValue : SInt32) : SearchResult;                                                                                                  ATTRIBUTE_NAME('MakeSearchResultFromHeuristicValue')
function MakeSearchResultForSolvedPosition(endgameScore : SInt32) : SearchResult;                                                                                                   ATTRIBUTE_NAME('MakeSearchResultForSolvedPosition')
function InitialiseSearchResult : SearchResult;                                                                                                                                     ATTRIBUTE_NAME('InitialiseSearchResult')


procedure SetMinimaxValueInResult(value : SInt32; var myResult : SearchResult);                                                                                                     ATTRIBUTE_NAME('SetMinimaxValueInResult')
procedure SetProofNumberInResult(proof : double_t; var myResult : SearchResult);                                                                                                    ATTRIBUTE_NAME('SetProofNumberInResult')
procedure SetDisproofNumberInResult(disproof : double_t; var myResult : SearchResult);                                                                                              ATTRIBUTE_NAME('SetDisproofNumberInResult')
function GetMinimaxValueOfResult(const myResult : SearchResult) : SInt32;                                                                                                           ATTRIBUTE_NAME('GetMinimaxValueOfResult')
function GetProofNumberOfResult(const myResult : SearchResult) : double_t;                                                                                                          ATTRIBUTE_NAME('GetProofNumberOfResult')
function GetDisproofNumberOfResult(const myResult : SearchResult) : double_t;                                                                                                       ATTRIBUTE_NAME('GetDisproofNumberOfResult')
procedure SetProofAndDisproofNumberFromHeuristicValue(midgameValue : SInt32; var result : SearchResult);                                                                            ATTRIBUTE_NAME('SetProofAndDisproofNumberFromHeuristicValue')


function SearchResultEnMidgameEval(const result : SearchResult) : SInt32;                                                                                                           ATTRIBUTE_NAME('SearchResultEnMidgameEval')
function GetWindowAlphaEnMidgameEval(const window : SearchWindow) : SInt32;                                                                                                         ATTRIBUTE_NAME('GetWindowAlphaEnMidgameEval')
function GetWindowBetaEnMidgameEval(const window : SearchWindow) : SInt32;                                                                                                          ATTRIBUTE_NAME('GetWindowBetaEnMidgameEval')


function DecalerSearchResult(const myResult : SearchResult; midgameDecalage : SInt32) : SearchResult;                                                                               ATTRIBUTE_NAME('DecalerSearchResult')

function MakeSearchWindow(const alpha,beta : SearchResult) : SearchWindow;                                                                                                          ATTRIBUTE_NAME('MakeSearchWindow')
function MakeNullWindow(const v : SearchResult) : SearchWindow;                                                                                                                     ATTRIBUTE_NAME('MakeNullWindow')

function GetWindowAlphaValue(const window : SearchWindow) : SearchResult;                                                                                                           ATTRIBUTE_NAME('GetWindowAlphaValue')
function GetWindowBetaValue(const window : SearchWindow) : SearchResult;                                                                                                            ATTRIBUTE_NAME('GetWindowBetaValue')



function FailSoltInWindow(const result : SearchResult; const window : SearchWindow) : boolean;                                                                                      ATTRIBUTE_NAME('FailSoltInWindow')
function FailHighInWindow(const result : SearchResult; const window : SearchWindow) : boolean;                                                                                      ATTRIBUTE_NAME('FailHighInWindow')
function ResultInsideWindow(const result : SearchResult; const window : SearchWindow) : boolean;                                                                                    ATTRIBUTE_NAME('ResultInsideWindow')
function IsNullWindow(const window : SearchWindow) : boolean;                                                                                                                       ATTRIBUTE_NAME('IsNullWindow')

function AlphaBetaCut(const window : SearchWindow) : boolean;                                                                                                                       ATTRIBUTE_NAME('AlphaBetaCut')

function ReverseResult(const result : SearchResult) : SearchResult;                                                                                                                 ATTRIBUTE_NAME('ReverseResult')
function ReverseWindow(const window : SearchWindow) : SearchWindow;                                                                                                                 ATTRIBUTE_NAME('ReverseWindow')

procedure UpdateSearchResult(var result : SearchResult; const valeurDuFils : SearchResult; var ameliorationMinimax,ameliorationProofNumber : boolean);                              ATTRIBUTE_NAME('UpdateSearchResult')
function UpdateSearchWindow(const value : SearchResult; var window : SearchWindow) : boolean;                                                                                       ATTRIBUTE_NAME('UpdateSearchWindow')


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    Unit_AB_simple ;
{$ELSEC}
    {$I prelink/SearchValues.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure SetMinimaxValueInResult(value : SInt32; var myResult : SearchResult);
begin
  myResult.minimax := value;
end;

function GetMinimaxValueOfResult(const myResult : SearchResult) : SInt32;
begin
  GetMinimaxValueOfResult := myResult.minimax;
end;


procedure SetProofNumberInResult(proof : double_t; var myResult : SearchResult);
begin
  myResult.proofNumber := proof;
end;

procedure SetDisproofNumberInResult(disproof : double_t; var myResult : SearchResult);
begin
  myResult.disproofNumber := disproof;
end;

function GetProofNumberOfResult(const myResult : SearchResult) : double_t;
begin
  GetProofNumberOfResult := myResult.proofNumber;
end;

function GetDisproofNumberOfResult(const myResult : SearchResult) : double_t;
begin
  GetDisproofNumberOfResult := myResult.disproofNumber;
end;


procedure SetProofAndDisproofNumberFromHeuristicValue(midgameValue : SInt32; var result : SearchResult);
var PN,DN : double_t;
begin
  quantumProofNumber            := 0.0;
  exponentialMappingProofNumber := 0.07;

  PN := ProofNumberMapping(midgameValue, 0, exponentialMappingProofNumber);
  DN := ProofNumberMapping(-midgameValue,0, exponentialMappingProofNumber);

  SetProofNumberInResult(PN, result);
  SetDisproofNumberInResult(DN ,result);
end;


function MakeSearchResultFromHeuristicValue(midgameValue : SInt32) : SearchResult;
var result : SearchResult;
begin
  SetMinimaxValueInResult(midgameValue,result);
  SetProofAndDisproofNumberFromHeuristicValue(midgameValue,result);
  MakeSearchResultFromHeuristicValue := result;
end;


function MakeSearchResultForSolvedPosition(endgameScore : SInt32) : SearchResult;
var result : SearchResult;
begin
  SetMinimaxValueInResult(100*endgameScore,result);

  if (endgameScore > 0)
    then
      begin
        SetProofNumberInResult(0.0, result);
        SetDisproofNumberInResult(1e50,result);
      end
    else
  if (endgameScore < 0)
    then
      begin
        SetProofNumberInResult(1e50, result);
        SetDisproofNumberInResult(0.0 ,result);
      end
    else
      begin
        SetProofNumberInResult(1.0, result);
        SetDisproofNumberInResult(1.0,result);
      end;

  MakeSearchResultForSolvedPosition := result;
end;


function InitialiseSearchResult : SearchResult;
var result : SearchResult;
begin
  SetMinimaxValueInResult(-32767,result);

  SetProofNumberInResult(1e50, result);
  SetDisproofNumberInResult(0.0 ,result);

  InitialiseSearchResult := result;
end;

function SearchResultEnMidgameEval(const result : SearchResult) : SInt32;
begin
  SearchResultEnMidgameEval := GetMinimaxValueOfResult(result);
end;

function GetWindowAlphaEnMidgameEval(const window : SearchWindow) : SInt32;
var alpha : SearchResult;
begin
  alpha := GetWindowAlphaValue(window);
  GetWindowAlphaEnMidgameEval := GetMinimaxValueOfResult(alpha);
end;

function GetWindowBetaEnMidgameEval(const window : SearchWindow) : SInt32;
begin
  GetWindowBetaEnMidgameEval := GetMinimaxValueOfResult(GetWindowBetaValue(window));
end;

function DecalerSearchResult(const myResult : SearchResult; midgameDecalage : SInt32) : SearchResult;
var aux : SearchResult;
begin
  SetMinimaxValueInResult(GetMinimaxValueOfResult(myResult) + midgameDecalage,aux);
  DecalerSearchResult := aux;
end;

function MakeSearchWindow(const alpha,beta : SearchResult) : SearchWindow;
var window : SearchWindow;
begin
  window.alpha := alpha;
  window.beta  := beta;
  MakeSearchWindow := window;
end;

function MakeNullWindow(const v : SearchResult) : SearchWindow;
begin
  MakeNullWindow := MakeSearchWindow(MakeSearchResultFromHeuristicValue(GetMinimaxValueOfResult(v)),
                                     MakeSearchResultFromHeuristicValue(GetMinimaxValueOfResult(v)+1));
end;

function GetWindowAlphaValue(const window : SearchWindow) : SearchResult;
begin
  GetWindowAlphaValue := window.alpha;
end;

function GetWindowBetaValue(const window : SearchWindow) : SearchResult;
begin
  GetWindowBetaValue := window.beta;
end;


{renvoie true  sssi  v1 > v2}
function StriclyBetterSearchValue(const v1,v2 : SearchResult) : boolean;
begin
  StriclyBetterSearchValue := GetMinimaxValueOfResult(v1) > GetMinimaxValueOfResult(v2);
end;

{renvoie true  sssi  result <= alpha}
function FailSoltInWindow(const result : SearchResult; const window : SearchWindow) : boolean;
begin
  FailSoltInWindow := not(StriclyBetterSearchValue(result,window.alpha));
end;

{renvoie true  sssi   result >= beta}
function FailHighInWindow(const result : SearchResult; const window : SearchWindow) : boolean;
begin
  FailHighInWindow := not(StriclyBetterSearchValue(window.beta,result));
end;

{renvoie true  sssi   alpha < result < beta}
function ResultInsideWindow(const result : SearchResult; const window : SearchWindow) : boolean;
begin
  ResultInsideWindow := StriclyBetterSearchValue(result, window.alpha) &
                        StriclyBetterSearchValue(window.beta, result);
end;

function IsNullWindow(const window : SearchWindow) : boolean;
begin
  IsNullWindow := ((GetMinimaxValueOfResult(window.beta) - GetMinimaxValueOfResult(window.alpha)) <= 1);
end;

function ReverseResult(const result : SearchResult) : SearchResult;
var aux : SearchResult;
    proofNumber,disproofNumber : double_t;
begin
  SetMinimaxValueInResult(-GetMinimaxValueOfResult(result),aux);

  {swap proof and disproof numbers}
  proofNumber    := GetProofNumberOfResult(result);
  disproofNumber := GetDisproofNumberOfResult(result);
  SetProofNumberInResult(disproofNumber,aux);
  SetDisproofNumberInResult(proofNumber,aux);

  ReverseResult := aux;
end;

function ReverseWindow(const window : SearchWindow) : SearchWindow;
begin
  ReverseWindow := MakeSearchWindow(ReverseResult(GetWindowBetaValue(window)),
                                    ReverseResult(GetWindowAlphaValue(window)));
end;


function AlphaBetaCut(const window : SearchWindow) : boolean;
begin
  AlphaBetaCut := not(StriclyBetterSearchValue(window.beta,window.alpha));
end;

function UpdateSearchWindow(const value : SearchResult; var window : SearchWindow) : boolean;
begin
  UpdateSearchWindow := false;
  if StriclyBetterSearchValue(value,window.alpha) then
    begin
      UpdateSearchWindow := true;
      window.alpha := value;
    end;
end;

procedure UpdateSearchResult(var result : SearchResult; const valeurDuFils : SearchResult; var ameliorationMinimax,ameliorationProofNumber : boolean);
begin
  ameliorationMinimax := false;
  if StriclyBetterSearchValue(valeurDuFils,result) then
    begin
      SetMinimaxValueInResult(GetMinimaxValueOfResult(valeurDuFils),result);
      ameliorationMinimax := true;
    end;

  ameliorationProofNumber := false;
  if GetProofNumberOfResult(valeurDuFils) < GetProofNumberOfResult(result) then
    begin
      SetProofNumberInResult(GetProofNumberOfResult(valeurDuFils),result);
      ameliorationProofNumber := true;
    end;

  SetDisproofNumberInResult(GetDisproofNumberOfResult(result)+GetDisproofNumberOfResult(valeurDuFils),result);
end;


end.
