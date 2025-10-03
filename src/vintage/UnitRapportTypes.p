UNIT UnitRapportTypes;


INTERFACE

 USES UnitDefCassio , Controls , TSMTE , TextServices , TextEdit;



type RapportRec =
				record                       { un document }
					theWindow                  : WindowPtr;      { sa fenêtre }
					hScroller                  : ControlHandle;  { ascenseur horizontal }
					vScroller                  : ControlHandle;  { ascenseur vertical }
					theText                    : TEHandle;       { texte édité }
					changed                    : Boolean;        { vrai si texte modifié }
					fileName                   : String255;      { nom du fichier }
					docTSMTERecHandle          : TSMTERecHandle; { pour rentrer du japonais avec le Text service Manager }
					docTSMDoc                  : TSMDocumentID;  { numero du document géré par le TSM }
					prochaineAlerteRemplissage : SInt32;         { taille max du texte de rapport avant l'alerte de remplissage}
					autoVidageDuRapport        : boolean;        { est a true si le rapport doit se vider sans alerte prealable}
					deroulementAutomatique     : boolean;        { est a true si on change l'affichage pour suivre le point d'insertion}
					ecritToutDansRapportLog    : boolean;        { a true, on ecrit aussi dans le fichier "rapport.log"}
				end;


var rapport : RapportRec;


const  maxTextEditSize = MAXINT_16BITS;     { taille maxi d'un enregistrement d'édition }
       hUnit = 7;                           { unité de défilement horizontal (colonne) du texte }
       vUnit = 12;
       TEdecalage = 1;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}












END.
