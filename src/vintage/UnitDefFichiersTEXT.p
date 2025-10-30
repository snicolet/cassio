UNIT UnitDefFichiersTEXT;


INTERFACE

USES Files, StringTypes, UnitDefLongString;


TYPE

     fileInfo = FSSpec;   // FSSpec is Mac OS specific
     

     {FIXME : on risque de perturber InfosFichiersNouveauFormat dans le
              fichier UnitDefNouveauFormat (tableau trop gros)
              si on rajoute des gros champs ˆ basicfile... }
     basicfile =
          record
            nomFichier : String255;              {private}
            uniqueID : SInt32;                   {private}
            parID : SInt32;                      {private}
            refNum : SInt16;                     {private}
            vRefNum : SInt16;                    {private}
            ressourceForkRefNum : SInt32;        {private}
            dataForkOuvertCorrectement : SInt32; {private}
            rsrcForkOuvertCorrectement : SInt32; {private}
            info : fileInfo;                     {private}
            bufferLecture : record               {private}
                              bufferLecture      : PackedArrayOfCharPtr;  {private}
                              debutDuBuffer      : SInt32;    {private}
                              positionDansBuffer : SInt32;    {private}
                              tailleDuFichier    : SInt32;    {private}
                              tailleDuBuffer     : SInt32;    {private}
                              positionTeteFichier: SInt32;    {private}
                              doitUtiliserBuffer : boolean;   {private}
                            end;
          end;


     {type fonctionnel pour ForEachLineInFileDo}
     LineOfFileProc = procedure(var ligne : LongString; var theFic : basicfile; var result : SInt32);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}








END.
