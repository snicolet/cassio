UNIT UnitDefSet;


INTERFACE


USES
   UnitDefABR,MyTypes;

TYPE
    StringSet = record
                   cardinal : SInt32;
                   arbre : ABR;
                 end;

    StringMultiset = record
                        theSet                  : StringSet;
                        theChars                : PackedArrayOfCharPtr;
                        fin                     : LongintArrayPtr;
                        occurence               : LongintArrayPtr;
                        totalOccurences         : SInt32;
                        nbreChainesMax          : SInt32;
                        tailleCumuleeChainesMax : SInt32;
                        derniereCaseVideTrouvee : SInt32;
                      end;

    IntegerSet = record
                    cardinal : SInt32;
                    arbre : ABR;
                  end;

    PositionEtTraitSet = record
                            cardinal : SInt32;
                            arbre : ABR;
                          end;


     SquareSet = SET of 0..127;

     {le type suivant defini un ensemble de cases plus compact, mais la representation
      est privee : on ne doit y acceder que par les fonctions d'acces}
     PackedSquareSet = record
                         private : SET of 0..63;
                       end;


     {types fonctionels pour les iterateurs}
     SquareSetIteratorProc = procedure(var whichSquare : SInt16; var continuer : boolean);
     SquareSetIteratorProcAvecResult = procedure(var whichSquare : SInt16; var result : SInt32; var continuer : boolean);
     SquareGivesSquareFunc = function(whichSquare : SInt16) : SInt16;
     SquareGivesSquareFuncAvecParam = function(whichSquare : SInt16; parametre : SInt32) : SInt16;


type Pile = record
              taille : SInt32;
              tete,queue : SInt32;
              data : LongintArrayHdl;
            end;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}








END.
