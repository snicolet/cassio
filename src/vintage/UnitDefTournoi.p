Unit UnitDefTournoi;


INTERFACE

USES UnitOth0;


const kNombreMaxJoueursDansLeTournoi        = 127;

const ENTRE_DEVIATIONS              = 1;
      ENTRE_ENGINES                 = 2;

type OuvertureRec =
       record
         ouverturesAleatoires       : boolean;
         nbCoupsImposes             : SInt32;
         nbCoupsIdentiques          : SInt32;
         longueurOuvertureAleatoire : SInt32;
         premiersCoups              : array[0..65] of SInt32;
         ouvertureEquilibree        : PackedThorGame;
       end;


type TournoiSettingsRec = record
                            niveau1        : SInt32;
                            niveau2        : SInt32;
                            tempsParPartie : SInt32;  // en secondes
                          end;

type ToutesRondesRec = record
                          typeTournoi                    : SInt32;   // ENTRE_ENGINES ou ENTRE_DEVIATIONS
                          nbParticipants                 : SInt32;
                          nbToursDuTournoi               : SInt32;   // simple toutes-ronde, ou double toutes-rondes, etc...
                          nbPartiesParMatch              : SInt32;
                          numeroRonde                    : SInt32;
                          settings                       : TournoiSettingsRec;
                          indexParticipant               : array[0..kNombreMaxJoueursDansLeTournoi] of SInt32;
                          nroEngineParticipant           : array[0..kNombreMaxJoueursDansLeTournoi] of SInt32;
                          scoreParticipant               : array[0..kNombreMaxJoueursDansLeTournoi] of double;
                          tableauTouteRonde              : array[0..kNombreMaxJoueursDansLeTournoi] of SInt32;
                          ouverture                      : OuvertureRec;
                          ouverturesDejaJouees           : StringSet;
                          nomTournoi                     : String255;
                          doitSauvegarderPartieDansListe : boolean;
                       end;


type  MatchTournoiRec =
                record

                  fanny : array[1..2] of SInt32;
                  scoreCumule : array[1..2] of SInt32;
                  nbreDePionsPartiePrecedente : array[pionNoir..pionBlanc] of SInt32;

                  partiePrecedente : String255;
                  partieActuelle : String255;

                  typeDeMatch : SInt32;  // ENTRE_ENGINES ou ENTRE_DEVIATIONS

                  niveau1 : SInt32;
                  niveau2 : SInt32;

                  tempsParPartie : SInt32;

                  joueur1 : SInt32;
                  joueur2 : SInt32;

                  ouverture : OuvertureRec;
                  nbParties : SInt32;

                  avecAttenteEntreParties : boolean;
                  avecSauvegardePartieDansListe : boolean;

                end;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}













end.
