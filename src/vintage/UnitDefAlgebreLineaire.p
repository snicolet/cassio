UNIT UnitDefAlgebreLineaire;


INTERFACE


USES MyTypes;


const dimensionMatrice = 40;

type  RealType         = double_t;  {double precision (8 bytes) on PPC}
      MatriceReels     = record
                            nbLignes   : SInt32;
                            nbColonnes : SInt32;
                            mat        : array[1..dimensionMatrice,1..dimensionMatrice] of RealType;
                         end;
      VecteurBooleens  = record
                           longueur    : SInt32;
                           bool        : array[0..dimensionMatrice] of boolean;
                         end;
      VecteurReels     = record
                           longueur    : SInt32;
                           vec         : array[1..dimensionMatrice] of RealType;
                         end;
      VecteurLongint  = record
                           longueur    : SInt32;
                           val         : array[1..dimensionMatrice] of SInt32;
                         end;




      PointMultidimensionnel = TypeReelArrayPtr;




      PointMultidimensionnelInteger =
                           record
                             taille : SInt32;
                             data : IntegerArrayPtr;
                             alloue : boolean;
                           end;



      FonctionReelle = function(x : TypeReel) : TypeReel;
      DifferentielleReelle = function(x : TypeReel; var dfx : TypeReel) : TypeReel;
      FonctionMultidimensionnelle = function(p : PointMultidimensionnel) : TypeReel;





IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.
