UNIT UnitDefNouveauFormat;



INTERFACE







USES MacTypes,UnitOth0,UnitDefFichiersTEXT,StringTypes,UnitDefATR;


const kFicPartiesNouveauFormat = 1;
      kFicJoueursNouveauFormat = 2;
      kFicTournoisNouveauFormat = 3;
      kFicJoueursCourtsNouveauFormat = 4;
      kFicTournoisCourtsNouveauFormat = 5;
      kFicIndexJoueursNouveauFormat = 6;
      kFicIndexTournoisNouveauFormat = 7;
      kFicIndexJoueursCourtsNouveauFormat = 8;
      kFicIndexTournoisCourtsNouveauFormat = 9;
      kFicIndexPartiesNouveauFormat = 10;
      kFicSolitairesNouveauFormat = 11;
      kUnknownDataNouveauFormat = 1000;


      nbMaxDistributions = 250;  {must be < 255}
      nbMaxFichiersNouveauFormat = 32000;

CONST kChercherSeulementDansBaseOfficielle = 1;
      kChercherDansTousLesFichiersDeJoueurs = 2;


const kWTHOR_JOU = kFicJoueursNouveauFormat;
      kWTHOR_TRN = kFicTournoisNouveauFormat;



type  t_EnTeteNouveauFormat =
        packed record
                 siecleCreation : UInt8;
                 anneeCreation : UInt8;
                 MoisCreation : UInt8;
                 JourCreation : UInt8;
                 NombreEnregistrementsParties : SInt32;             {4 octets,sans signe}
                 NombreEnregistrementsTournoisEtJoueurs : SInt16;   {2 octets,sans signe}
                 AnneeParties : SInt16;                             {2 octets,sans signe}
                 case SInt16 of
                   0 : (
                     TailleDuPlateau           : UInt8; {parametre P1}
		                 EstUnFichierSolitaire     : UInt8; {parametre P2}
		                 ProfondeurCalculTheorique : UInt8; {parametre P3}
		                 reservedByte              : UInt8; {reserved}
		                 );
		               1 :
		                 (
		                 PlaceMemoireIndex     : SInt32;  {4 octets}
		                 )
               end;

     t_JoueurRecNouveauFormat  =
        packed array[1..20] of UInt8;

     t_TournoiRecNouveauFormat =
        packed array[1..26] of UInt8;

     t_PartieRecNouveauFormat  =
        packed record
	        nroTournoi : SInt16;                          { 2 octets }
	        nroJoueurNoir : SInt16;                       { 2 octets }
	        nroJoueurBlanc : SInt16;                      { 2 octets }
	        scoreReel : UInt8;                             { 1 octet }
	        scoreTheorique : UInt8;                        { 1 octet }
	        listeCoups : packed array [1..60] of UInt8;   { 60 octets }
	      end;

	  t_SolitaireRecNouveauFormat =
	      packed record
	        annee : SInt16;                    { 2 octets }
	        nroTournoi : SInt16;               { 2 octets }
	        nroJoueurNoir : SInt32;            { 4 octets }
	        nroJoueurBlanc : SInt32;           { 4 octets }
	        position : PackedOthelloPosition;  { 16 octets }
	        nbVides : UInt8;                    { 1 octet }
	        traitSolitaire : UInt8;             { 1 octet, codage : 1 = Noir, 2 = Blanc }
	        scoreParfait : UInt8;               { score de la solution }
	        solution : UInt8;                   { premier coup de la solution }
	        scoreReel : UInt8;                  { score rŽel de la partie, si disponible (0 sinon) }
	        coup25 : UInt8;                     { coup 25 de la partie dans la base, si disponible (0 sinon) }
	        reserved1 : UInt8;
	        reserved2 : UInt8;
	      end;

   indexArray    = packed array[-10..11] of UInt8;
   indexArrayPtr = ^indexArray;



    DistributionRec =
         record
	         name                            : String255Ptr;
	         path                            : String255Ptr;
	         nomUsuel                        : String255Ptr;
	         typeDonneesDansDistribution     : SInt16;
	         decalageNrosJoueurs             : SInt32;
	         decalageNrosTournois            : SInt32;
	       end;

	  DistributionSet = set of 0..nbMaxDistributions;

    FichierNouveauFormatRec =
         record
           open : boolean;
           nomFichier : String255Ptr;
           pathFichier : String255Ptr;
           refNum : SInt16;
           parID : SInt16;
           vRefNum : SInt16;
           entete : t_EnTeteNouveauFormat;
           typeDonnees : SInt16;
           nroDistribution : SInt16;   { pour les fichiers de parties ou de solitaires ou un index}
           annee : SInt16;             { pour les fichiers de parties ou de solitaires ou un index}
           NroFichierDual : SInt16;    {index associŽ si c'est un fichier de parties, et reciproquement}
           theFichierTEXT : basicfile;
         end;





     PartieNouveauFormatRecPtr = ^t_PartieRecNouveauFormat;
     tablePartiesNouveauFormat = array[0..0] of t_PartieRecNouveauFormat;
     tablePartiesNouveauFormatPtr = ^tablePartiesNouveauFormat;

     JoueursNouveauFormatRecPtr = ^JoueursNouveauFormatRec;
     JoueursNouveauFormatRec = record
                                 nom                         : String255;
                                 nomCourt                    : String255;
                                 nomEnMajusculesSansEspace   : String255;
                                 nomMetaphoneAvecEspaces     : String255;
                                 nomMetaphoneSansEspace      : String255;
                                 numeroDansOrdreAlphabetique : SInt32;
                                 numeroDansFichierJoueurs    : SInt32;
                                 numeroFFO                   : SInt32;
                                 nomJaponais                 : String255Hdl;
                                 anneePremierePartie         : SInt16;
                                 anneeDernierePartie         : SInt16;
                                 classementData              : SInt32;
                                 hashDesLexemes              : array[0..5] of SInt32;
                                 estUnOrdinateur             : boolean;
                               end;
     tableJoueursNouveauFormat = array[0..0] of JoueursNouveauFormatRec;
     tableJoueursNouveauFormatPtr = ^tableJoueursNouveauFormat;

     TournoisNouveauFormatRecPtr = ^TournoisNouveauFormatRec;
     TournoisNouveauFormatRec = record
                                  nom                         : String255;
                                  nomCourt                    : String255;
                                  numeroDansOrdreAlphabetique : SInt32;
                                  numeroDansFichierTournois   : SInt32;
                                  nomJaponais                 : String255Hdl;
                                end;
     tableTournoisNouveauFormat = array[0..0] of TournoisNouveauFormatRec;
     tableTournoisNouveauFormatPtr = ^tableTournoisNouveauFormat;

var
   DistributionsNouveauFormat :
        record
          nbDistributions : SInt16;
          Distribution : array[1..nbMaxDistributions] of DistributionRec;
        end;
   InfosFichiersNouveauFormat :
        record
          nbFichiers : SInt16;
          fichiers : array[1..nbMaxFichiersNouveauFormat] of FichierNouveauFormatRec;
        end;
   IndexNouveauFormat :
        record
          tailleIndex : SInt32;
          indexNoir : indexArrayPtr;
          indexBlanc : indexArrayPtr;
          indexOuverture : indexArrayPtr;
          indexTournoi : indexArrayPtr;
        end;
   PartiesNouveauFormat :
          record
            nbPartiesEnMemoire : SInt32;
            listeParties : tablePartiesNouveauFormatPtr;
          end;
   JoueursNouveauFormat :
	      record
	        nbJoueursNouveauFormat : SInt32;
	        plusLongNomDeJoueur : SInt32;
	        nombreJoueursDansBaseOfficielle : SInt32;
	        listeJoueurs : tableJoueursNouveauFormatPtr;
	        dejaTriesAlphabetiquement : boolean;
	      end;
   TournoisNouveauFormat :
	      record
	        nbTournoisNouveauFormat : SInt32;
	        nombreTournoisDansBaseOfficielle : SInt32;
	        listeTournois : tableTournoisNouveauFormatPtr;
	        dejaTriesAlphabetiquement : boolean;
	      end;

   ChoixDistributions:
        record
          genre : SInt16;
          distributionsALire : DistributionSet;
          nbTotalPartiesDansDistributionsALire : SInt32;
        end;

   nroDistributionWThor : SInt32;

 const TailleEnTeteNouveauFormat = sizeof(t_EnTeteNouveauFormat);             {16 octets}
       TaillePartieRecNouveauFormat = sizeof(t_PartieRecNouveauFormat);       {68 octets}
       TailleJoueurRecNouveauFormat = sizeof(t_JoueurRecNouveauFormat);       {20 octets}
       TailleTournoiRecNouveauFormat = sizeof(t_TournoiRecNouveauFormat);     {26 octets}
       TailleSolitaireRecNouveauFormat = sizeof(t_SolitaireRecNouveauFormat); {36 octets}

       kToutesLesDistributions = -1;
       kAucuneDistribution = -2;
       kQuelquesDistributions = -3;


       {quelques numeros de tournois et de joueursÉ}
       kNroTournoiDiversesParties      = 0;
       kNroTournoiPartiesInternet_1_6  = 57;
       kNroTournoiPartiesInternet_7_12 = 58;
       kNroTournoiPartiesInternet      = 90;
       kNroJoueurInconnu               = 0;
       kNroJoueurKitty                 = 10;
       kNroJoueurLogistello            = 16;
       kNroJoueurCassio                = 147;
       kNroJoueurEdax                  = 1368;
       kNroJoueurCyrano                = 1917;



CONST kFinDuMondeOthellistique = 3971;
      kDebutDuMondeOthellistique = 1971;
      kChangementDeSiecleOthellistique = 71;



{gestion d'un menu flottant des bases}
TYPE menuFlottantBasesRec = record
                              theMenuID : SInt16;
                              menuFlottantBases : MenuRef;
                              menuBasesRect : rect;
                              itemCourantMenuBases : SInt16;
                              nbreItemsAvantListeDesBases : SInt16;
                              tableLiaisonEntreMenuBasesEtNumerosDistrib : array[0..nbMaxDistributions] of SInt16;
                            end;
     filtreDistributionProc = function(numeroDistribution : SInt16) : boolean;


type ThorParRec =
       packed record
                 texte                        : packed array[1..36] of char;       {36 octets}
                 posEtCoups                   : packed array[1..8,1..8] of UInt8;  {64 octets}
                 tempRestant                  : SInt16;                            {2 octets}
                 modeDeJeu                    : SInt16;                            {2 octets}
                 niveauDansThor               : UInt8;                             {1 octet}
                 nbCoupsJouesYComprisPasses   : UInt8;                             {1 octet}
                 nbNoirs                      : UInt8;                             {1 octet}
                 nbBlancs                     : UInt8;                             {1 octet}
                 traitInitial                 : UInt8;                             {1 octet}
                 traitPosFinale               : UInt8;                             {1 octet}
                 suggestionDeThor             : SInt16;                            {2 octets}
              end;


type  t_EnteteSuplementaireSolitaires =
		    record
		      nbSolitairesCetteProf : array[1..64] of SInt32;
		    end;

const TailleEnteteSupplementaireSolitaires = 256;



const
  kPasDeRejet = 0;
  kRejetUnSeulCoupLegal = 1;
  kRejetPerdant = 2;
  kRejetDeuxCoupsGagnants = 3;
  kRejetDeuxCoupsPourFaireNulle = 4;
  kRejetSeulGagnantMaisChoixPlusTard = 5;
  kRejetSeuleNulleMaisChoixPlusTard = 6;
  kRejetGagnantEtChoixPlusTard = 7;
  kRejetNulleEtChoixPlusTard = 8;
  kRejetADejaUnCoin = 9;
  kRejetPeutDejaPrendreUnCoin = 10;
  kRejetSolutionsMultiplesPourPbDeCoin = 11;
  kRejetPasDeSolutionPbDeCoin = 12;


var gImportDesNoms :
      record
        pseudosInconnus            : StringSet;
        pseudosNomsDejaVus         : StringSet;
        pseudosTournoisDejaVus     : StringSet;
        pseudosAyantUnNomReel      : StringSet;
        pseudosSansNomReel         : StringSet;
        nomsReelsARajouterDansBase : StringSet;
        formesPossiblesDesVanDen   : ATR;
      end;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}













END.
