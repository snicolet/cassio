UNIT UnitDefGraphe;



INTERFACE







USES MacTypes, StringTypes,UnitDefFichiersTEXT;

 type CelluleRec =
       record
         pere : SInt32;                      (* pointeur sur le pere *)
         fils : SInt32;                      (* pointeur sur un fils *)
         frere : SInt32;                     (* liste chainee circulaire des freres *)
         memePosition : SInt32;              (* liste chainee circulaire des positions identiques (pour les interversions) *)
         CoupEtCouleurs : SInt16;            (* Stocke le coup,la couleur de ce coup et le trait resultant *)
         valeurMinimax : SInt16;             (* appartient à {Gain,Nulle,Perte,PasDansArbre,etc.} *)
         numeroDuCoup : SInt16;              (* 1 à 60 *)
         VersionEtProfondeur : SInt16;       (* version appartient à {kCassio,kYapp,etc.}, profondeur de la recherche heuristique appartient à [0..30] *)
         ProofNumberPourNoir : SInt16;       (* quantite de travail pour prouver le gain noir *)
         DisproofNumberPourNoir : SInt16;    (* quantite de travail pour prouver la perte noire ou la nulle *)
         ProofNumberPourBlanc : SInt16;      (* quantite de travail pour prouver le gain blanc *)
         DisProofNumberPourBlanc : SInt16;   (* quantite de travail pour prouver la perte blanche ou la nulle *)
         ValeurDeviantePourNoir : SInt16;    (* appartient à [-6400..+6400] *)
         ValeurDeviantePourBlanc : SInt16;   (* appartient à [-6400..+6400] *)
         EsperanceDeGainPourNoir : SInt16;   (* proba que Noir gagne *)
         EsperanceDeGainPourBlanc : SInt16;  (* proba que Blanc gagne *)
         ValeurHeuristiquePourNoir : SInt16; (* appartient à [-6400..+6400] ; attention : toujours pour les Noirs *)
         flags : SInt16;
       end;

      CelluleListeHeuristiqueRec =    { Attention : doit avoir la meme taille que CelluleRec car on va faire du transtypage !!! }
       record
         pere : SInt32;                      (* pointeur sur le pere *)
         fils : SInt32;                      (* pointeur sur un fils *)
         frere : SInt32;                     (* liste chainee circulaire des freres *)
         memePosition : SInt32;              (* liste chainee circulaire des positions identiques (pour les interversions) *)
         couleur : SInt16;                   (* Stocke la couleur des propositions heuristiques *)
         valeurMinimax : SInt16;             (* appartient à {Gain,Nulle,Perte,PasDansArbre,etc.} *)
         numeroDuCoup : SInt16;              (* 1 à 60 *)
         VersionEtProfondeur : SInt16;       (* version appartient à {kCassio,kYapp,etc.}, profondeur de la recherche heuristique appartient à [0..30] *)
         CoupEtCouleurs12 : SInt16;          (* Stocke le coup,la couleur du coup et le trait resultant des propositions 1 et 2 *)
         ValeurHeuristiquePourNoir1 : SInt16; (* appartient à [-6400..+6400] ; attention : toujours pour les Noirs *)
         ValeurHeuristiquePourNoir2 : SInt16; (* appartient à [-6400..+6400] ; attention : toujours pour les Noirs *)
         CoupEtCouleurs34 : SInt16;          (* Stocke le coup,la couleur du coup et le trait resultant des propositions 3 et 4 *)
         ValeurHeuristiquePourNoir3 : SInt16; (* appartient à [-6400..+6400] ; attention : toujours pour les Noirs *)
         ValeurHeuristiquePourNoir4 : SInt16; (* appartient à [-6400..+6400] ; attention : toujours pour les Noirs *)
         CoupEtCouleurs56 : SInt16;          (* Stocke le coup,la couleur du coup et le trait resultant des propositions 5 et 6 *)
         ValeurHeuristiquePourNoir5 : SInt16; (* appartient à [-6400..+6400] ; attention : toujours pour les Noirs *)
         ValeurHeuristiquePourNoir6 : SInt16; (* appartient à [-6400..+6400] ; attention : toujours pour les Noirs *)
         flags : SInt16;
       end;

type GrapheRec =
       record
         nbCellules : SInt32;
         fic : FichierTEXT;
       end;
     Graphe = ^GrapheRec;

var  nomGrapheApprentissage : String255;
     nomGrapheInterversions : String255;


const kPasDansT = 0;
      kGainDansT = 1;
      kNulleDansT = 2;
      kPerteDansT = 3;
      kPropositionHeuristique = 4;
      kGainAbsolu = 5;
      kNulleAbsolue = 6;
      kPerteAbsolue = 7;

      Noir = -1;
      Blanc = 1;
      Vide = 0;

      {masques pour les flags}
      kPrivateMask = 1;

      {versions des algos}
      kCassio460 = 0;        {Cassio 4.6.0}
      kUnusedVersion1 = 1;
      kUnusedVersion2 = 2;
      kUnusedVersion3 = 3;
      kUnusedVersion4 = 4;
      kUnusedVersion5 = 5;
      kYapp = 6;
      kVersionIndeterminee = 7;
      {profondeur de la recherche heuristique}
      kProfondeurIndeterminee = 31;
      kVersionEtProfondeurIndeterminee = 255;

      kInfiniApprentissage = 32000;
      kMaxProofNumber = 20000;
      kMaxDisproofNumber = kMaxProofNumber;
      valeurIndeterminee = -25500;
      esperanceIndeterminee = -1.0;


      PasDeFils = 0;
      PasDePere = 0;
      PasDeFrere = 0;
      PasDeCommentaire = 0;

      TaileMaxListeDeCoups = 400;
      TailleHeaderGraphe   = 100;
      kLongueurListeInfinie = TaileMaxListeDeCoups - 2;


type { Bug dans dans le compilateur CodeWarrior Pro 1 pour PPC !! On voudrait ecrire :
          EnsembleDeTypes = set of kPasDansT..kPerteAbsolue;
       Mais alors sizeof(EnsembleDeTypes) = 1, et les operations sur les ensembles
       ne donnent pas les resultats voulus (en particulier l'operateur d'appartenance "in"
       ne marche pas. Pour contrer cela on utilise la définition suivante, qui force
       des ensembles a quatre octets}
     EnsembleDeTypes = set of 0..31;

     typePartiePourGraphe = String255;

     ListeDeCellules =
                    record
                        cardinal : SInt32;
                        liste : array [0..TaileMaxListeDeCoups] of record
                                                                 numeroCellule : SInt32;
                                                                 {cellule : CelluleRec;}
                                                               end;
                    end;

     ListeDeCellulesEtDeCoups =
                    record
                        cardinal : SInt32;
                        liste : array [0..TaileMaxListeDeCoups] of record
                                                                 numeroCellule : SInt32;
                                                                 coup : SInt16;
                                                               end;
                    end;

     ListeDeProbas = record
                      cardinal : SInt32;
                      liste : array [0..TaileMaxListeDeCoups] of record
                                                                 coup : SInt16;
                                                                 proba : double_t;
                                                               end;
                    end;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}













END.
