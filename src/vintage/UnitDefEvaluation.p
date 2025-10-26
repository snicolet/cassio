UNIT UnitDefEvaluation;


INTERFACE


USES UnitOth0,UnitDefAlgebreLineaire;


type VectNewEval =
       record
         Edges2X : array[0..kNbMaxGameStage] of PointMultidimensionnel;
         Pattern : array[0..kNbPatternsDansEvalDeCassio,0..kNbMaxGameStage] of PointMultidimensionnel;
         Mobilite : PointMultidimensionnel;
         FrontiereDiscs : PointMultidimensionnel;
         FrontiereSquares : PointMultidimensionnel;
         FrontiereNonLineaire : PointMultidimensionnel;
       end;


var descriptionVecteurEval :
      record
        nbTablesDifferentes : SInt32;
        table : array[0..100] of
                record
                  sorte : SInt32;
                  longueurPattern : SInt32;
                  numeroPattern : SInt32;
                  stage : SInt32;
                end;
       end;

const kPatternLigne  = 1;
      kEdge2X        = 2;
      kCorner13      = 3;


type VectNewEvalInteger =
       record
         Edges2X : array[0..kNbMaxGameStage] of PointMultidimensionnelInteger;
         Pattern : array[0..kNbPatternsDansEvalDeCassio,0..kNbMaxGameStage] of PointMultidimensionnelInteger;
         Mobilite : PointMultidimensionnelInteger;
         FrontiereDiscs : PointMultidimensionnelInteger;
         FrontiereSquares : PointMultidimensionnelInteger;
         FrontiereNonLineaire : PointMultidimensionnelInteger;
       end;


CONST QuantumDiscretisation = 100;
      MoitieQuantum = 50;  {doit etre la moitie du precedent}



var verboseMinimisationChi2 : boolean;
    nbPartiesDansOccurences : SInt32;
    occurences : VectNewEval;
    vecteurEvaluation : VectNewEval;
    vecteurEvaluationInteger : VectNewEvalInteger;

    memoireAlloueeConjugateGradientChi2 : boolean;
    vecteursConjugateGradientChi2 :
      record
        g,h,xi : VectNewEval;
      end;

    memoireAlloueeFonctionLigneChi2 : boolean;
    vecteursFonctionLigneChi2 :
      record
        P,dir : VectNewEval;
      end;

    memoireAlloueeTriEvaluation : boolean;
    vecteurTriEval :
      record
        rapportOccurence,rank : VectNewEval;
      end;

TYPE
     {le type suivant defini une valeur de retour minimax dont la representation
      est privee : on ne doit y acceder que par les fonctions d'acces}

     SearchResult = record
                       minimax        : SInt32;
                       proofNumber    : double;
                       disproofNumber : double;
                    end;

     SearchWindow = record
                      alpha : SearchResult;
                      beta : SearchResult;
                    end;




type   AmeliorationsAlphaRec =
            record
              cardinal : SInt32;
              liste : array[1..64] of
                      record
                        coup : SInt32;
                        val : SInt32;
                        alphaAvant : SInt32;
                      end;
				    end;




type t_table_BlocsDeCoin = array[-3280..3280] of  SInt16;  {6560 = 3^8-1}
     tableBlocsDeCoinPtr =  ^t_table_BlocsDeCoin;
var  valeurBlocsDeCoin : tableBlocsDeCoinPtr;

    { les puissances de 3 et leurs opposees }
    { puiss3 : array[0..20] of SInt16;  }
    { puiss3 est déjà déclaré dans UnitOth0  }
    { puiss3[i] = 3^(i-1)  , sauf puiss3[0] = 0}

    coul1 : array[pionNoir..pionBlanc] of SInt16;
    coul3 : array[pionNoir..pionBlanc] of SInt16;
    coul9 : array[pionNoir..pionBlanc] of SInt16;
    coul27 : array[pionNoir..pionBlanc] of SInt16;
    coul81 : array[pionNoir..pionBlanc] of SInt16;
    coul243 : array[pionNoir..pionBlanc] of SInt16;
    coul729 : array[pionNoir..pionBlanc] of SInt16;
    coul2187 : array[pionNoir..pionBlanc] of SInt16;

    coulm1 : array[pionNoir..pionBlanc] of SInt16;
    coulm3 : array[pionNoir..pionBlanc] of SInt16;
    coulm9 : array[pionNoir..pionBlanc] of SInt16;
    coulm27 : array[pionNoir..pionBlanc] of SInt16;
    coulm81 : array[pionNoir..pionBlanc] of SInt16;
    coulm243 : array[pionNoir..pionBlanc] of SInt16;
    coulm729 : array[pionNoir..pionBlanc] of SInt16;
    coulm2187 : array[pionNoir..pionBlanc] of SInt16;


var equ_codage : array['0'..'2'] of SInt16;




	const independammentDuTrait = 1;
	      traitImportant = 2;
	      caseCritiqueSurLeBordPourAlphaBetaLocal = 3;
	type t_code_pattern = String255;
	var equ_bord : array['0'..'2'] of SInt32;

  type t_liste_assoc_bord =
         array[0..kTaille_Max_Index_Bords_AB_Local] of
                      record
                         case SInt16 of
                           0:(
                              QuelBord : SInt32;
                              QuelleCaseCritiqueSurLeBord : SInt32;
                             );
                           1:(
                              WhichEdge : SInt32;
                              Frequence : SInt32;
                             )
                       end;

  var longueur_liste_assoc_turbulence_bord_AB_local : SInt32;
      liste_assoc_turbulence_bord_AB_local,
      essai_bord_AB_local,
      coupure_bord_AB_local : t_liste_assoc_bord;


type SquareOrderType = (ordreDesCasesDeJeanCristopheWeil,ordreDesCasesDeCassio);




const ProfMaxDansTableOfMoveRecordsLists = 50;

type ListOfMoveRecordsPtr = ^ListOfMoveRecords;
     ListOfMoveRecordsHdl = ^ListOfMoveRecordsPtr;


var tableOfMoveRecordsLists :
       array[0..ProfMaxDansTableOfMoveRecordsLists] of
         record
           list : ListOfMoveRecordsHdl;
           cardinal : SInt16;
           utilisee : boolean;
         end;

const
  kNoFlag                 = 0;
  kPeutDetruireArbreDeJeu = 1;


CONST
  kProfMinimalePourSuiteDansRapport = 13;

IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.
