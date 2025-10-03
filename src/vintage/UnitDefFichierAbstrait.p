UNIT  UnitDefFichierAbstrait;


INTERFACE


USES MacTypes;



const BadFichierAbstrait         = 0;  { indique un fichier abstrait non initialise, ou vide }
      FichierAbstraitEstFichier  = 1;
      FichierAbstraitEstPointeur = 2;
      FichierAbstraitReserved    = 3;




type FichierAbstraitPtr = Ptr;

     EntreesSortieFichierAbstraitProc = function(theAbstractFilePtr : FichierAbstraitPtr; text : Ptr; fromPos : SInt32; var nbOctets : SInt32) : OSErr;
     FichierAbstraitProc              = function(theAbstractFilePtr : FichierAbstraitPtr) : OSErr;
     FichierAbstraitLongintProc       = function(theAbstractFilePtr : FichierAbstraitPtr; var param : SInt32) : OSErr;



     FichierAbstrait =
      record
        infos                  : Ptr;      { pointeur sur un fichier ou un adresse memoire (privé) }
        tailleMaximalePossible : SInt32;   { taille maximale possible }
        nbOctetsOccupes        : SInt32;   { taille occupee dans le fichier abstrait }
        position               : SInt32;   { position du pointeur d'ecriture dans le fichier abstrait }
        genre                  : SInt32;   { kFichierAbstraitEstFichier ou kZoneMoireEstPointeur }
        refCon                 : SInt32;   { a la disposition de l'application pour stocker ce qu'elle veut }
        zoneType               : OSType;
        zoneCreator            : OSType;
        Ecrire                 : EntreesSortieFichierAbstraitProc; { fonction d'ecriture (privée) }
        Lire                   : EntreesSortieFichierAbstraitProc; { fonction de lecture (privee) }
        Clear                  : FichierAbstraitProc;              { effacement du fichier (privée) }
        Fermer                 : FichierAbstraitProc;              { fonction de fermeture (privée) }
        SetPosition            : FichierAbstraitLongintProc;       { deplacement du marqueur }
      end;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}












END.
