UNIT UnitDefTranscript;



INTERFACE

USES
   UnitDefABR, StringTypes, UnitOth0;

const kTaillePileTranscripts = 200;   { On pourra faire 200 annulations }

      kGauche = 1;
      kDroite = 2;

      kTranscriptChiffreTropGrand      = 1;
      kTranscriptCoupsDupliques        = 2;
      kTranscriptVientDeCreerUnDoublon = 4;
      kTranscriptCoupsIsoles           = 8;
      kTranscriptCoupIllegal           = 16;
      kTranscriptCoupManquant          = 32;


type Transcript =
        record
          chiffres : packed array[0..99,kGauche..kDroite] of SInt8;
          curseur : record
                      square,lateralisation : SInt16;
                    end;
        end;


     AnalyseDeTranscript =  record
                               globalTranscriptError : SInt32;
                               derniereCaseTapee : SInt16;
                               nbDoublons : SInt16;
                               nbCoupsIsoles : SInt16;
                               nbCoupsManquants : SInt16;
                               numeroPremierCoupManquant : SInt16;
                               numeroDernierCoupPresent : SInt16;
                               numeroPremierCoupIllegal : SInt16;
                               numeroPremierDoublon : SInt16;
                               numeroPremierCoupIsole : SInt16;
                               cases :
                                 array[0..200] of
                                   record
                                     cardinal : SInt32;
                                     liste : array[0..64] of SInt16;
                                     typeErreur : SInt32;
                                   end;
                               erreursDansCetteCase : array[11..88] of SInt32;
                               plusLonguePartieLegale : String255;
                               nombreCoupsPossibles : SInt16;
                               nombreCasesRemplies : SInt16;
                               partieTerminee : boolean;
                               tousLesCoupsSontLegaux : boolean;
                               scorePartieComplete : SInt16;  {nb de pions de noirs - nb de pions blancs}
                             end;

     AnalyseDeTranscriptPtr = ^AnalyseDeTranscript;


     GenreCorrection = (EffacementCase,EchangeCases,AucuneCorrection,IncrementAndSet,Renumeroter);


     ActionDeCorrection = record
                            genre : GenreCorrection;
                            square1,square2 : SInt32;
                            arg1,arg2 : SInt32;
                          end;


   TranscriptSet = record
                       cardinal : SInt32;
                       arbre : ABR;
                     end;



const
  kNbJoueursMenuSaisie = 140;  {attention! Doit etre un multiple de 35, ou alors changer UnitPrefs}
  kNbTournoisMenuSaisie = 140;

var
  gInfosSaisiePartie :
    record
      tableDerniersJoueurs : array[1..kNbJoueursMenuSaisie] of SInt32;
      tableDerniersTournois : array[1..kNbTournoisMenuSaisie] of SInt32;
      derniereAnnee : SInt32;
      dernierJoueurNoir : SInt32;
      dernierJoueurBlanc : SInt32;
      dernierTournoi : SInt32;
      derniereDistribution : SInt32;
      enregistrementAutomatique : boolean;

      picture : PicHandle;
      parametresOthellier : ParamDiagRec;
      positionEtCoupSaisieStr : String255;
    end;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}










END.
