UNIT UnitDefPositionEtTrait;


INTERFACE


USES UnitOth0;


type  PositionEtTraitRec =
        record
          position : plateauOthello;
          lazyTrait : record
                        leTrait : SInt32;
                        traitNaturel : SInt32;
                      end;
        end;


type ProblemePriseDeCoin =
       record
         attaquant                : SInt32;
         defenseur                : SInt32;
         horizon                  : SInt32;
         currentBoard             : PositionEtTraitRec;
         distanceDepart           : SInt32;
         nbCoupsJouesParAttaquant : SInt32;
         solution                 : record
                                      longueur                    : SInt32;
                                      nbCoupsSolutions            : SInt32;
                                      coup                        : array[1..kNbMaxCoupsSolutions] of SInt32;
                                      causeRejet                  : SInt32;
                                      attaquantPasse              : boolean;
                                      estUneDefenseDeCoinTriviale : boolean;
                                    end;
       end;
     ProblemePriseDeCoinPtr = ^ProblemePriseDeCoin;


{constants used in UnitSolve.p}

const kEndgameSolveOnlyWLD                          = 1;
      kEndgameSolveToujoursRamenerLaSuite           = 2;
      kEndgameSolveEcrirePositionDansRapport        = 4;
      kEndgameSolveEcrireInfosTechniquesDansRapport = 8;
      kEndgameSolveCalculateInBackground            = 16;
      kEndgameSolveCalculateInForeground            = 32;
      kEndgameSolveSearchDifficultPositions         = 64;
      kEndgameSolvePassDirectlyToEngine             = 128;


{constants used in UnitPositionEtTrait.p}

const kPartieOK             = 0;
      kPasErreur            = 0;  {synomyme}
      kPartieTropCourte     = 1;
      kPartieIllegale       = 2;
      kPartieIninteressante = 3;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}








END.
