UNIT UnitAccesNouveauFormat;



INTERFACE



 USES UnitDefCassio;




procedure MetPartieDansTableStockageParties(nroReference : SInt32; var partieStr : PackedThorGame);
procedure ExtraitPartieTableStockageParties(nroReference : SInt32; var partieStr : PackedThorGame);
procedure ExtraitCoupTableStockagePartie(nroReference, nroCoup : SInt32; var coup : SInt32);
function GetPartieTableStockageParties(nroReference : SInt32) : PackedThorGame;
function GetNroJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNroJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNroFFOJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNroFFOJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNroTournoiParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNomJoueurNoirParNroRefPartie(nroReference : SInt32) : String255;
function GetNomJoueurBlancParNroRefPartie(nroReference : SInt32) : String255;
function GetNomJoueurNoirSansPrenomParNroRefPartie(nroReference : SInt32) : String255;
function GetNomJoueurBlancSansPrenomParNroRefPartie(nroReference : SInt32) : String255;
function GetNomJoueurNoirCommeDansPappParNroRefPartie(nroReference : SInt32) : String255;
function GetNomJoueurBlancCommeDansPappParNroRefPartie(nroReference : SInt32) : String255;
function GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNomTournoiParNroRefPartie(nroReference : SInt32) : String255;
function GetNomCourtTournoiParNroRefPartie(nroReference : SInt32) : String255;
function GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNumeroJoueurNoirDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNumeroJoueurBlancDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNumeroTournoiDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
function GetAnneePartieParNroRefPartie(nroReference : SInt32) : SInt16;
function GetNomTournoiAvecAnneeParNroRefPartie(nroReference : SInt32; longueurTotaleVoulue : SInt16) : String255;
function GetNomCourtTournoiAvecAnneeParNroRefPartie(nroReference : SInt32; longueurTotaleVoulue : SInt16) : String255;
function GetScoreReelParNroRefPartie(nroReference : SInt32) : SInt16;
function GetScoreTheoriqueParNroRefPartie(nroReference : SInt32) : SInt16;
procedure GetScoresTheoriqueEtReelParNroRefPartie(nroReference : SInt32; var theorique,reel : SInt16);
function GetGainTheoriqueParNroRefPartie(nroReference : SInt32) : String255;
procedure GetGainsTheoriqueEtReelParNroRefPartie(nroReference : SInt32; var gainNoirTheorique,gainNoirReel : SInt32);
function GetPartieRecordParNroRefPartie(nroReference : SInt32) : t_PartieRecNouveauFormat;
function GetNroDistributionParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNomDistributionParNroRefPartie(nroReference : SInt32) : String255;
function HashPartieDansListeParNroRefPartie(numeroRefPartie : SInt32) : SInt32;


procedure SetNroJoueurNoirParNroRefPartie(nroReference : SInt32; nroJoueur : SInt32);
procedure SetNroJoueurBlancParNroRefPartie(nroReference : SInt32; nroJoueur : SInt32);
procedure SetNroTournoiParNroRefPartie(nroReference : SInt32; nroTournoi : SInt32);
procedure SetAnneePartieParNroRefPartie(nroReference : SInt32; annee : SInt16);
procedure SetScoreReelParNroRefPartie(nroReference : SInt32; scoreReel : SInt16);
procedure SetScoreTheoriqueParNroRefPartie(nroReference : SInt32; scoreTheorique : SInt16);
procedure SetPartieRecordParNroRefPartie(nroReference : SInt32; var GameRecord : t_PartieRecNouveauFormat);
procedure SetNroDistributionParNroRefPartie(nroReference : SInt32; nroDistribution : SInt32);


function GetNomJoueur(nroJoueur : SInt32) : String255;
function GetNomJoueurEnMajusculesSansEspace(nroJoueur : SInt32) : String255;
function GetNomJoueurEnMetaphoneSansEspace(nroJoueur : SInt32) : String255;
function GetNomJoueurEnMetaphoneAvecEspaces(nroJoueur : SInt32) : String255;
function GetNomJoueurSansPrenom(nroJoueur : SInt32) : String255;
function GetNomDeFamilleSansDifferencierLesPrenoms(nroJoueur : SInt32) : String255;
function GetNomJoueurCommeDansPapp(nroJoueur : SInt32) : String255;
function GetNomJoueurCommeDansFichierFFODesJoueurs(nroJoueur : SInt32) : String255;
function GetNroOrdreAlphabetiqueJoueur(nroJoueur : SInt32) : SInt32;
function GetNroFFODuJoueur(nroJoueur : SInt32) : SInt32;
function GetNroJoueurDansSonFichier(nroJoueur : SInt32) : SInt32;
function GetAnneePremierePartieDeCeJoueur(nroJoueur : SInt32) : SInt32;
function GetAnneeDernierePartieDeCeJoueur(nroJoueur : SInt32) : SInt32;
function GetNbreAnneesActiviteDeCeJoueur(nroJoueur : SInt32) : SInt32;
function GetDonneesClassementDeCeJoueur(nroJoueur : SInt32) : SInt32;
function GetJoueurEstUnOrdinateur(nroJoueur : SInt32) : boolean;


procedure SetNomJoueur(nroJoueur : SInt32; joueur : String255);
procedure SetNomCourtJoueur(nroJoueur : SInt32; joueur : String255);
procedure SetNroOrdreAlphabetiqueJoueur(nroJoueur : SInt32; nroDansOrdreAlphabetique : SInt32);
procedure SetNroFFODuJoueur(nroJoueur : SInt32; whichNumeroFFO : SInt32);
procedure SetNroDansFichierJoueur(nroJoueur : SInt32; nroDansSonFichier : SInt32);
procedure SetAnneePremierePartieDeCeJoueur(nroJoueur : SInt32; annee : SInt32);
procedure SetAnneeDernierePartieDeCeJoueur(nroJoueur : SInt32; annee : SInt32);
procedure SetDonneesClassementDeCeJoueur(nroJoueur : SInt32; data : SInt32);
procedure SetJoueurEstUnOrdinateur(nroJoueur : SInt32; flag : boolean);


function GetNomTournoi(nroTournoi : SInt32) : String255;
function GetNomCourtTournoi(nroTournoi : SInt32) : String255;
function GetNroOrdreAlphabetiqueTournoi(nroTournoi : SInt32) : SInt32;
function GetNroTournoiDansSonFichier(nroTournoi : SInt32) : SInt32;
procedure SetNomTournoi(nroTournoi : SInt32; tournoi : String255);
procedure SetNomCourtTournoi(nroTournoi : SInt32; tournoi : String255);
procedure SetNroOrdreAlphabetiqueTournoi(nroTournoi : SInt32; nroDansOrdreAlphabetique : SInt32);
procedure SetNroDansFichierTournoi(nroTournoi : SInt32; nroDansSonFichier : SInt32);


function JoueurAUnNomJaponais(nroJoueur : SInt32) : boolean;
function TournoiAUnNomJaponais(nroTournoi : SInt32) : boolean;
function EstUnePartieAvecTournoiJaponais(nroReferencePartie : SInt32) : boolean;
function EstUnePartieAvecJoueurNoirJaponais(nroReferencePartie : SInt32) : boolean;
function EstUnePartieAvecJoueurBlancJaponais(nroReferencePartie : SInt32) : boolean;


function GetNomJaponaisDuJoueur(nroJoueur : SInt32) : String255;
function GetNomJaponaisDuJoueurNoirParNroRefPartie(nroReference : SInt32) : String255;
function GetNomJaponaisDuJoueurBlancParNroRefPartie(nroReference : SInt32) : String255;
function GetNomJaponaisDuTournoi(nroTournoi : SInt32) : String255;
function GetNomJaponaisDuTournoiParNroRefPartie(nroReference : SInt32) : String255;
function GetNomJaponaisDuTournoiAvecAnneeParNroRefPartie(nroReference : SInt32; longueurTotaleVoulue : SInt16) : String255;
procedure SetNomJaponaisDuJoueur(nroJoueur : SInt32; nomJaponais : String255);
procedure SetNomJaponaisDuTournoi(nroTournoi : SInt32; nomJaponais : String255);


function LongueurPlusLongNomDeJoueurDansBase : SInt32;
function NombreJoueursDansBaseOfficielle : SInt32;
procedure SetNombreJoueursDansBaseOfficielle(combien : SInt32);
function NombreTournoisDansBaseOfficielle : SInt32;
procedure SetNombreTournoisDansBaseOfficielle(combien : SInt32);


function FindStringDansMetaphoneSansEspaceDeCeJoueur(var s : String255; nroJoueur : SInt32) : SInt32;
function FindStringDansNomEnMajusculesSansEspaceDeCeJoueur(var s : String255; nroJoueur : SInt32) : SInt32;
function GetHashLexemesDeCeJoueur(nroJoueur : SInt32; lexemes : LongintArrayPtr) : SInt32;
function CalculateHashLexemesDeCeJoueur(nroJoueur : SInt32; lexemes : LongintArrayPtr) : SInt32;

function GetNomUsuelDistribution(nroDistribution : SInt32) : String255;
function GetNameOfDistribution(nroDistribution : SInt32) : String255;
function GetPathOfDistribution(nroDistribution : SInt32) : String255;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesMemoire, UnitRapport, MyStrings, UnitPackedThorGame, MyMathUtils, UnitImportDesNoms, UnitHashing, UnitUtilitaires
    , UnitMetaphone ;
{$ELSEC}
    {$I prelink/AccesNouveauFormat.lk}
{$ENDC}


{END_USE_CLAUSE}






procedure MetPartieDansTableStockageParties(nroReference : SInt32; var partieStr : PackedThorGame);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  MoveMemory(GET_ADRESS_OF_FIRST_MOVE(partieStr),POINTER_ADD(partieArrow , 8),60);
end;

procedure ExtraitPartieTableStockageParties(nroReference : SInt32; var partieStr : PackedThorGame);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  MoveMemory(POINTER_ADD(partieArrow , 8),GET_ADRESS_OF_FIRST_MOVE(partieStr),60);
  SET_LENGTH_OF_PACKED_GAME(partieStr, 60);
end;

function GetPartieTableStockageParties(nroReference : SInt32) : PackedThorGame;
var s : PackedThorGame;
begin
  ExtraitPartieTableStockageParties(nroReference, s);
  GetPartieTableStockageParties := s;
end;

procedure ExtraitCoupTableStockagePartie(nroReference, nroCoup : SInt32; var coup : SInt32);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  coup := partieArrow^.listeCoups[nroCoup];
end;

function GetNroJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNroJoueurNoirParNroRefPartie := partieArrow^.nroJoueurNoir;
end;

function GetNroJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNroJoueurBlancParNroRefPartie := partieArrow^.nroJoueurBlanc;
end;

function GetNroFFOJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNroFFOJoueurNoirParNroRefPartie := GetNroFFODuJoueur(GetNroJoueurDansSonFichier(partieArrow^.nroJoueurNoir));
end;

function GetNroFFOJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNroFFOJoueurBlancParNroRefPartie := GetNroFFODuJoueur(GetNroJoueurDansSonFichier(partieArrow^.nroJoueurBlanc));
end;

procedure SetNroJoueurNoirParNroRefPartie(nroReference : SInt32; nroJoueur : SInt32);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.nroJoueurNoir := nroJoueur;
end;

procedure SetNroJoueurBlancParNroRefPartie(nroReference : SInt32; nroJoueur : SInt32);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.nroJoueurBlanc := nroJoueur;
end;

function GetNomJoueurNoirParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurNoirParNroRefPartie := GetNomJoueur(partieArrow^.nroJoueurNoir);
end;

function GetNomJoueurBlancParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurBlancParNroRefPartie := GetNomJoueur(partieArrow^.nroJoueurBlanc);
end;

function GetNomJoueurNoirSansPrenomParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurNoirSansPrenomParNroRefPartie := GetNomJoueurSansPrenom(partieArrow^.nroJoueurNoir);
end;

function GetNomJoueurBlancSansPrenomParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurBlancSansPrenomParNroRefPartie := GetNomJoueurSansPrenom(partieArrow^.nroJoueurBlanc);
end;

function GetNomJoueurNoirCommeDansPappParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurNoirCommeDansPappParNroRefPartie := GetNomJoueurCommeDansPapp(partieArrow^.nroJoueurNoir);
end;

function GetNomJoueurBlancCommeDansPappParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurBlancCommeDansPappParNroRefPartie := GetNomJoueurCommeDansPapp(partieArrow^.nroJoueurBlanc);
end;

function GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie := GetNroOrdreAlphabetiqueJoueur(partieArrow^.nroJoueurNoir);
end;

function GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie := GetNroOrdreAlphabetiqueJoueur(partieArrow^.nroJoueurBlanc);
end;

function GetNroTournoiParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNroTournoiParNroRefPartie := partieArrow^.nroTournoi;
end;

function GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie := GetNroOrdreAlphabetiqueTournoi(partieArrow^.nroTournoi);
end;

function GetNumeroJoueurNoirDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNumeroJoueurNoirDansFichierParNroRefPartie := GetNroJoueurDansSonFichier(partieArrow^.nroJoueurNoir);
end;


function GetNumeroJoueurBlancDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNumeroJoueurBlancDansFichierParNroRefPartie := GetNroJoueurDansSonFichier(partieArrow^.nroJoueurBlanc);
end;


function GetNumeroTournoiDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNumeroTournoiDansFichierParNroRefPartie := GetNroTournoiDansSonFichier(partieArrow^.nroTournoi);
end;


procedure SetNroTournoiParNroRefPartie(nroReference : SInt32; nroTournoi : SInt32);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.nroTournoi := nroTournoi;
end;

function GetNomTournoiParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomTournoiParNroRefPartie := GetNomTournoi(partieArrow^.nroTournoi);
end;

function GetNomCourtTournoiParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomCourtTournoiParNroRefPartie := GetNomCourtTournoi(partieArrow^.nroTournoi);
end;

procedure SetAnneePartieParNroRefPartie(nroReference : SInt32; annee : SInt16);
begin
  tableAnneeParties^^[nroReference] := annee;
end;

function GetAnneePartieParNroRefPartie(nroReference : SInt32) : SInt16;
begin
  GetAnneePartieParNroRefPartie := tableAnneeParties^^[nroReference];
end;

function GetNomTournoiAvecAnneeParNroRefPartie(nroReference : SInt32; longueurTotaleVoulue : SInt16) : String255;
var s : String255;
    i : SInt16;
begin
  {if (GetNroDistributionParNroRefPartie(nroReference) <> nroDistributionWThor) and
     (GetNroTournoiParNroRefPartie(nroReference) = kNroTournoiDiversesParties)
     then s := GetNomDistributionParNroRefPartie(nroReference)
     else s := GetNomTournoiParNroRefPartie(nroReference);}
  s := GetNomTournoiParNroRefPartie(nroReference);
  for i := 1 to longueurTotaleVoulue-LENGTH_OF_STRING(s)-4 do s := s + ' ';
  GetNomTournoiAvecAnneeParNroRefPartie := s+IntToStr(GetAnneePartieParNroRefPartie(nroReference));
end;

function GetNomCourtTournoiAvecAnneeParNroRefPartie(nroReference : SInt32; longueurTotaleVoulue : SInt16) : String255;
var s : String255;
begin  {$UNUSED longueurTotaleVoulue}
  s := GetNomCourtTournoiParNroRefPartie(nroReference);
  GetNomCourtTournoiAvecAnneeParNroRefPartie := s + '  '+ IntToStr(GetAnneePartieParNroRefPartie(nroReference));
end;

procedure SetScoreReelParNroRefPartie(nroReference : SInt32; scoreReel : SInt16);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.scoreReel := scoreReel;
end;

function GetScoreReelParNroRefPartie(nroReference : SInt32) : SInt16;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetScoreReelParNroRefPartie := partieArrow^.scoreReel;
end;

procedure SetScoreTheoriqueParNroRefPartie(nroReference : SInt32; scoreTheorique : SInt16);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.scoreTheorique := scoreTheorique;
end;

procedure SetPartieRecordParNroRefPartie(nroReference : SInt32; var GameRecord : t_PartieRecNouveauFormat);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  partieArrow^ := GameRecord;
end;

procedure SetNroDistributionParNroRefPartie(nroReference : SInt32; nroDistribution : SInt32);
begin
  tableDistributionDeLaPartie^[nroReference] := nroDistribution;
end;

function GetScoreTheoriqueParNroRefPartie(nroReference : SInt32) : SInt16;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetScoreTheoriqueParNroRefPartie := partieArrow^.scoreTheorique;
end;

procedure GetScoresTheoriqueEtReelParNroRefPartie(nroReference : SInt32; var theorique,reel : SInt16);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  theorique := partieArrow^.scoreTheorique;
  reel      := partieArrow^.scoreReel;
end;


function GetGainTheoriqueParNroRefPartie(nroReference : SInt32) : String255;
var scoreTheorique : SInt16;
    partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  scoreTheorique := partieArrow^.scoreTheorique;
  if scoreTheorique > 32 then GetGainTheoriqueParNroRefPartie := CaracterePourNoir else
  if scoreTheorique < 32 then GetGainTheoriqueParNroRefPartie := CaracterePourBlanc else
  {if scoreTheorique = 32 then} GetGainTheoriqueParNroRefPartie := CaracterePourEgalite;
end;

procedure GetGainsTheoriqueEtReelParNroRefPartie(nroReference : SInt32; var gainNoirTheorique,gainNoirReel : SInt32);
var scoreTheorique,scoreReel : SInt16;
    partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  scoreTheorique := partieArrow^.scoreTheorique;
  scoreReel := partieArrow^.scoreReel;
  if scoreTheorique > 32 then   gainNoirTheorique := 2 else
  if scoreTheorique < 32 then   gainNoirTheorique := 0 else
  {if scoreTheorique = 32 then} gainNoirTheorique := 1;
  if scoreReel > 32 then   gainNoirReel := 2 else
  if scoreReel < 32 then   gainNoirReel := 0 else
  {if scoreReel = 32 then} gainNoirReel := 1;
end;


function GetPartieRecordParNroRefPartie(nroReference : SInt32) : t_PartieRecNouveauFormat;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetPartieRecordParNroRefPartie := partieArrow^;
end;


function GetNroDistributionParNroRefPartie(nroReference : SInt32) : SInt32;
begin
  GetNroDistributionParNroRefPartie := tableDistributionDeLaPartie^[nroReference];
end;


function GetNomDistributionParNroRefPartie(nroReference : SInt32) : String255;
begin
  GetNomDistributionParNroRefPartie := GetNomUsuelDistribution(tableDistributionDeLaPartie^[nroReference]);
end;


function GetNomJoueur(nroJoueur : SInt32) : String255;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
       then
         begin
           JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
           GetNomJoueur := JoueurArrow^.nom;
         end
       else
         GetNomJoueur := '******';
end;


function HashPartieDansListeParNroRefPartie(numeroRefPartie : SInt32) : SInt32;
var aux : SInt32;
    stamp : SInt32;
begin
  stamp := 0;

  aux := GetNroJoueurNoirParNroRefPartie(numeroRefPartie);
  stamp := stamp xor GenericHash(@aux,4);

  aux := GetNroJoueurBlancParNroRefPartie(numeroRefPartie);
  stamp := stamp xor GenericHash(@aux,4);

  aux := GetNroTournoiParNroRefPartie(numeroRefPartie);
  stamp := stamp xor GenericHash(@aux,4);

  aux := GetAnneePartieParNroRefPartie(numeroRefPartie);
  stamp := stamp xor GenericHash(@aux,4);

  ExtraitCoupTableStockagePartie(numeroRefPartie, 40, aux);
  stamp := stamp xor GenericHash(@aux,4);

  if (stamp = 0) then stamp := 1;

  HashPartieDansListeParNroRefPartie := stamp;
end;


function GetNomJoueurEnMajusculesSansEspace(nroJoueur : SInt32) : String255;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
       then
         begin
           JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
           GetNomJoueurEnMajusculesSansEspace := JoueurArrow^.nomEnMajusculesSansEspace;
         end
       else
         GetNomJoueurEnMajusculesSansEspace := '******';
end;


function GetNomJoueurEnMetaphoneAvecEspaces(nroJoueur : SInt32) : String255;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
       then
         begin
           JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
           GetNomJoueurEnMetaphoneAvecEspaces := JoueurArrow^.nomMetaphoneAvecEspaces;  // metaphone avec espaces
         end
       else
         GetNomJoueurEnMetaphoneAvecEspaces := '******';
end;


function GetNomJoueurEnMetaphoneSansEspace(nroJoueur : SInt32) : String255;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin

  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
       then
         begin
           JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
           GetNomJoueurEnMetaphoneSansEspace := JoueurArrow^.nomMetaphoneSansEspace;  // metaphone sans espace
         end
       else
         GetNomJoueurEnMetaphoneSansEspace := '******';

end;


function FindStringDansMetaphoneSansEspaceDeCeJoueur(var s : String255; nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
    len, len2, k, i : SInt32;
label next_char;
begin

  len  := LENGTH_OF_STRING(s);

  with JoueursNouveauFormat do
  if (len > 0) and
     (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
       then
         begin
           JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));

           with JoueurArrow^ do
             begin

               len2 := LENGTH_OF_STRING(nomMetaphoneSansEspace);  // metaphone sans espace

               for i := 0 to (len2 - len) do
                 begin
                   for k := 1 to len do
                     if s[k] <> nomMetaphoneSansEspace[i + k] then goto next_char;

                   // On a trouvé la chaine s en position (i + 1) dans le nomMetaphoneSansEspace du joueur
                   FindStringDansMetaphoneSansEspaceDeCeJoueur := i + 1;
                   exit;

                   // au moins un mismatch : on passe au caractere suivant dans le nomMetaphoneSansEspace du joueur
                   next_char :

                 end;
             end;
         end;

  FindStringDansMetaphoneSansEspaceDeCeJoueur := 0;

end;


function FindStringDansNomEnMajusculesSansEspaceDeCeJoueur(var s : String255; nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
    len, len2, k, i : SInt32;
label next_char;
begin

  len  := LENGTH_OF_STRING(s);

  with JoueursNouveauFormat do
  if (len > 0) and
     (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
       then
         begin
           JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));

           with JoueurArrow^ do
             begin

               len2 := LENGTH_OF_STRING(nomEnMajusculesSansEspace);  // nom en majuscules sans espaces

               for i := 0 to (len2 - len) do
                 begin
                   for k := 1 to len do
                     if s[k] <> nomEnMajusculesSansEspace[i + k] then goto next_char;

                   // On a trouvé la chaine s en position (i + 1) dans le nomEnMajusculesSansEspace du joueur
                   FindStringDansNomEnMajusculesSansEspaceDeCeJoueur := i + 1;
                   exit;

                   // au moins un mismatch : on passe au caractere suivant dans le nomEnMajusculesSansEspace du joueur
                   next_char :

                 end;
             end;
         end;

  FindStringDansNomEnMajusculesSansEspaceDeCeJoueur := 0;

end;


function CalculateHashLexemesDeCeJoueur(nroJoueur : SInt32; lexemes : LongintArrayPtr) : SInt32;
var nomBase : String255;
    nomBaseEnMajusculesAvecEspaces : String255;
    metaphoneBaseAvecEspaces : String255;
begin

  // nom de la base en majuscules avec espaces ?
  nomBase := GetNomJoueur(nroJoueur);
  nomBaseEnMajusculesAvecEspaces := FabriqueNomEnMajusculesAvecEspaces(nomBase);

  // metaphone dans la base avec espaces ?
  metaphoneBaseAvecEspaces := GetNomJoueurEnMetaphoneAvecEspaces(nroJoueur);

  if (nomBase[LENGTH_OF_STRING(nomBase)] = '.') then
    begin
      LeftP(nomBaseEnMajusculesAvecEspaces, LENGTH_OF_STRING(nomBaseEnMajusculesAvecEspaces) - 2);
      LeftP(metaphoneBaseAvecEspaces,       LENGTH_OF_STRING(metaphoneBaseAvecEspaces) - 1);
    end;

  if CassioIsUsingMetaphone
    then CalculateHashLexemesDeCeJoueur := HashLexemes( metaphoneBaseAvecEspaces ,       lexemes)
    else CalculateHashLexemesDeCeJoueur := HashLexemes( nomBaseEnMajusculesAvecEspaces , lexemes);

end;


function GetHashLexemesDeCeJoueur(nroJoueur : SInt32; lexemes : LongintArrayPtr) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
    nbLexemes, k : SInt32;
    usingMetaphone : boolean;
begin

  JoueurArrow := NIL;

  usingMetaphone := CassioIsUsingMetaphone;

  // check if the lexemes for this player have already been calculated and cached
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
       then
         begin
           JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));

           with JoueurArrow^ do
             begin

               // number of cached lexemes
               nbLexemes := hashDesLexemes[0];

               // convention : lexemes without metaphones have a negative count in the cache
               if ((nbLexemes > 0) and usingMetaphone) or
                  ((nbLexemes < 0) and not(usingMetaphone)) then
                    begin
                      for k := 1 to 5 do
                        lexemes^[k] := hashDesLexemes[k];

                      if (nbLexemes > 0)
                        then GetHashLexemesDeCeJoueur :=  nbLexemes
                        else GetHashLexemesDeCeJoueur := -nbLexemes;

                      exit;
                    end;
             end;

         end;

  // the lexemes were not cached, so we have to recalculate them
  nbLexemes := CalculateHashLexemesDeCeJoueur(nroJoueur , lexemes);


  // store the lexemes in the cache, if possible
  if (JoueurArrow <> NIL) and (nbLexemes >= 1) and (nbLexemes <= 5) then
    with JoueurArrow^ do
      begin

        // the lexemes themselves...
        for k := 1 to nbLexemes do
          hashDesLexemes[k] := lexemes^[k];
        for k := (nbLexemes + 1) to 5 do
          hashDesLexemes[k] := 0;

        // ...and the number of lexemes also
        if usingMetaphone
          then hashDesLexemes[0] :=  nbLexemes
          else hashDesLexemes[0] := -nbLexemes;
      end;


  GetHashLexemesDeCeJoueur := nbLexemes;

end;



function GetNomTournoi(nroTournoi : SInt32) : String255;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
      (nroTournoi >= 0) and
      (nroTournoi < nbTournoisNouveauFormat) and
      (listeTournois <> NIL)
        then
          begin
            TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
            GetNomTournoi := TournoiArrow^.nom;
          end
        else
          GetNomTournoi := '******';
end;

function GetNomCourtTournoi(nroTournoi : SInt32) : String255;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
      (nroTournoi >= 0) and
      (nroTournoi < nbTournoisNouveauFormat) and
      (listeTournois <> NIL)
        then
          begin
            TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));

            if (TournoiArrow^.nomCourt <> '')
              then GetNomCourtTournoi := TournoiArrow^.nomCourt
              else
                begin
                  TournoiArrow^.nomCourt := NomCourtDuTournoi(TournoiArrow^.nom);
                  GetNomCourtTournoi := TournoiArrow^.nomCourt;
                end;
          end
        else
          GetNomCourtTournoi := '******';
end;


function GetNomUsuelDistribution(nroDistribution : SInt32) : String255;
begin
  with DistributionsNouveauFormat do
  if (nroDistribution >= 1) and (nroDistribution <= nbDistributions)
    then GetNomUsuelDistribution := distribution[nroDistribution].nomUsuel^
    else GetNomUsuelDistribution := '******';
end;

function GetNameOfDistribution(nroDistribution : SInt32) : String255;
begin
  with DistributionsNouveauFormat do
  if (nroDistribution >= 1) and (nroDistribution <= nbDistributions)
    then GetNameOfDistribution := distribution[nroDistribution].name^
    else GetNameOfDistribution := '******';
end;

function GetPathOfDistribution(nroDistribution : SInt32) : String255;
begin
  with DistributionsNouveauFormat do
  if (nroDistribution >= 1) and (nroDistribution <= nbDistributions)
    then GetPathOfDistribution := distribution[nroDistribution].path^
    else GetPathOfDistribution := '******';
end;

procedure SetNomJoueur(nroJoueur : SInt32; joueur : String255);
var JoueurArrow : JoueursNouveauFormatRecPtr;
    nomMajAvecEspace : String255;
    aux, resultat : String255;
    k : SInt32;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.nom                       := joueur;

         (* calculer les noms normalises *)
         JoueurArrow^.nomEnMajusculesSansEspace := FabriqueNomEnMajusculesSansEspaceSansMetaphone(joueur);
         nomMajAvecEspace                       := FabriqueNomEnMajusculesAvecEspaces(joueur);

         (* calculer le metaphone en gardant les espaces *)
         if (joueur = '???') or (joueur = '')
           then JoueurArrow^.nomMetaphoneAvecEspaces   := nomMajAvecEspace
           else JoueurArrow^.nomMetaphoneAvecEspaces   := FabriqueMetaphoneDesLexemes(nomMajAvecEspace);

         (* calculer le metaphone en supprimant les espaces *)
         aux := JoueurArrow^.nomMetaphoneAvecEspaces;
         resultat := '';
         for k := 1 to LENGTH_OF_STRING(aux) do
           if aux[k] <> ' ' then
             resultat := resultat + aux[k];
         JoueurArrow^.nomMetaphoneSansEspace := resultat;

         (* reintialiser les hash des lexemes du nom *)
         for k := 0 to 5 do
           JoueurArrow^.hashDesLexemes[k] := 0;

         if LENGTH_OF_STRING(joueur) > plusLongNomDeJoueur then plusLongNomDeJoueur := LENGTH_OF_STRING(joueur);
       end;
end;

procedure SetNomCourtJoueur(nroJoueur : SInt32; joueur : String255);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.nomCourt := joueur;
       end;
end;


procedure SetNomTournoi(nroTournoi : SInt32; tournoi : String255);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL) then
       begin
         TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
         TournoiArrow^.nom := tournoi;
       end;
end;

procedure SetNomCourtTournoi(nroTournoi : SInt32; tournoi : String255);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL) then
       begin
         TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
         TournoiArrow^.nomCourt := tournoi;
       end;
end;


function GetNroOrdreAlphabetiqueJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetNroOrdreAlphabetiqueJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetNroOrdreAlphabetiqueJoueur := JoueurArrow^.numeroDansOrdreAlphabetique;
       end;
end;


function GetNroFFODuJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetNroFFODuJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetNroFFODuJoueur := JoueurArrow^.numeroFFO;
       end;
end;


function GetNroJoueurDansSonFichier(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetNroJoueurDansSonFichier := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetNroJoueurDansSonFichier := JoueurArrow^.numeroDansFichierJoueurs;
       end;
end;

function GetAnneePremierePartieDeCeJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetAnneePremierePartieDeCeJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetAnneePremierePartieDeCeJoueur := JoueurArrow^.anneePremierePartie;
       end;
end;

function GetAnneeDernierePartieDeCeJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetAnneeDernierePartieDeCeJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetAnneeDernierePartieDeCeJoueur := JoueurArrow^.anneeDernierePartie;
       end;
end;

function GetDonneesClassementDeCeJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetDonneesClassementDeCeJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetDonneesClassementDeCeJoueur := JoueurArrow^.classementData;
       end;
end;


function LongueurPlusLongNomDeJoueurDansBase : SInt32;
begin
  LongueurPlusLongNomDeJoueurDansBase := JoueursNouveauFormat.plusLongNomDeJoueur;
end;


function NombreJoueursDansBaseOfficielle : SInt32;
begin
  NombreJoueursDansBaseOfficielle := JoueursNouveauFormat.nombreJoueursDansBaseOfficielle;
end;


procedure SetNombreJoueursDansBaseOfficielle(combien : SInt32);
begin
  JoueursNouveauFormat.nombreJoueursDansBaseOfficielle := combien;
end;


function NombreTournoisDansBaseOfficielle : SInt32;
begin
  NombreTournoisDansBaseOfficielle := TournoisNouveauFormat.nombreTournoisDansBaseOfficielle;
end;


procedure SetNombreTournoisDansBaseOfficielle(combien : SInt32);
begin
  TournoisNouveauFormat.nombreTournoisDansBaseOfficielle := combien;
end;


function GetNbreAnneesActiviteDeCeJoueur(nroJoueur : SInt32) : SInt32;
begin
  if GetAnneePremierePartieDeCeJoueur(nroJoueur) > 0
    then GetNbreAnneesActiviteDeCeJoueur := GetAnneeDernierePartieDeCeJoueur(nroJoueur) - GetAnneePremierePartieDeCeJoueur(nroJoueur) + 1
    else GetNbreAnneesActiviteDeCeJoueur := 0;
end;



function GetNroOrdreAlphabetiqueTournoi(nroTournoi : SInt32) : SInt32;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  GetNroOrdreAlphabetiqueTournoi := -1;
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL) then
       begin
         TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
         GetNroOrdreAlphabetiqueTournoi := TournoiArrow^.numeroDansOrdreAlphabetique;
       end;
end;

function GetNroTournoiDansSonFichier(nroTournoi : SInt32) : SInt32;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  GetNroTournoiDansSonFichier := -1;
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL) then
       begin
         TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
         GetNroTournoiDansSonFichier := TournoiArrow^.numeroDansFichierTournois;
       end;
end;


procedure SetNroOrdreAlphabetiqueJoueur(nroJoueur : SInt32; nroDansOrdreAlphabetique : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.numeroDansOrdreAlphabetique := nroDansOrdreAlphabetique;
       end;
end;

procedure SetNroFFODuJoueur(nroJoueur : SInt32; whichNumeroFFO : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.numeroFFO := whichNumeroFFO;
       end;
end;

procedure SetNroOrdreAlphabetiqueTournoi(nroTournoi : SInt32; nroDansOrdreAlphabetique : SInt32);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL) then
       begin
         TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
         TournoiArrow^.numeroDansOrdreAlphabetique := nroDansOrdreAlphabetique;
       end;
end;

procedure SetNroDansFichierJoueur(nroJoueur : SInt32; nroDansSonFichier : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.numeroDansFichierJoueurs := nroDansSonFichier;
       end;
end;

procedure SetAnneePremierePartieDeCeJoueur(nroJoueur : SInt32; annee : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.anneePremierePartie := annee;
       end;
end;

procedure SetAnneeDernierePartieDeCeJoueur(nroJoueur : SInt32; annee : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.anneeDernierePartie := annee;
       end;
end;

procedure SetDonneesClassementDeCeJoueur(nroJoueur : SInt32; data : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.classementData := data;
       end;
end;

function GetJoueurEstUnOrdinateur(nroJoueur : SInt32) : boolean;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetJoueurEstUnOrdinateur := false;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetJoueurEstUnOrdinateur := JoueurArrow^.estUnOrdinateur;
       end;
end;

procedure SetJoueurEstUnOrdinateur(nroJoueur : SInt32; flag : boolean);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.estUnOrdinateur := flag;
       end;
end;


procedure SetNroDansFichierTournoi(nroTournoi : SInt32; nroDansSonFichier : SInt32);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL) then
       begin
         TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
         TournoiArrow^.numeroDansFichierTournois := nroDansSonFichier;
       end;
end;


function JoueurAUnNomJaponais(nroJoueur : SInt32) : boolean;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  JoueurAUnNomJaponais := false;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
    then
      begin
        JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
        JoueurAUnNomJaponais := JoueurArrow^.nomJaponais <> NIL;
      end;
end;

function TournoiAUnNomJaponais(nroTournoi : SInt32) : boolean;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  TournoiAUnNomJaponais := false;
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL)
    then
      begin
        TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
        TournoiAUnNomJaponais := TournoiArrow^.nomJaponais <> NIL;
      end;
end;

function EstUnePartieAvecTournoiJaponais(nroReferencePartie : SInt32) : boolean;
begin
  EstUnePartieAvecTournoiJaponais := TournoiAUnNomJaponais(GetNroTournoiParNroRefPartie(nroReferencePartie));
end;

function EstUnePartieAvecJoueurNoirJaponais(nroReferencePartie : SInt32) : boolean;
var aux : SInt32;
begin
  aux := GetNroJoueurNoirParNroRefPartie(nroReferencePartie);
  EstUnePartieAvecJoueurNoirJaponais := JoueurAUnNomJaponais(aux);
end;

function EstUnePartieAvecJoueurBlancJaponais(nroReferencePartie : SInt32) : boolean;
var aux : SInt32;
begin
  aux := GetNroJoueurBlancParNroRefPartie(nroReferencePartie);
  EstUnePartieAvecJoueurBlancJaponais := JoueurAUnNomJaponais(aux);
end;



function GetNomJaponaisDuJoueur(nroJoueur : SInt32) : String255;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
       then
		     begin
		       JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
		       if JoueurArrow^.nomJaponais <> NIL
		         then GetNomJaponaisDuJoueur := JoueurArrow^.nomJaponais^^
		         else GetNomJaponaisDuJoueur := '******';
		     end
		   else
		     begin
		       GetNomJaponaisDuJoueur := '******';
		     end;
end;

function GetNomJaponaisDuJoueurNoirParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJaponaisDuJoueurNoirParNroRefPartie := GetNomJaponaisDuJoueur(partieArrow^.nroJoueurNoir);
end;

function GetNomJaponaisDuJoueurBlancParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJaponaisDuJoueurBlancParNroRefPartie := GetNomJaponaisDuJoueur(partieArrow^.nroJoueurBlanc);
end;


function GetNomJaponaisDuTournoi(nroTournoi : SInt32) : String255;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL)
    then
      begin
        TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
        if TournoiArrow^.nomJaponais <> NIL
          then GetNomJaponaisDuTournoi := TournoiArrow^.nomJaponais^^
          else GetNomJaponaisDuTournoi := '******';
      end
    else GetNomJaponaisDuTournoi := '******';
end;

function GetNomJaponaisDuTournoiParNroRefPartie(nroReference : SInt32) : String255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := POINTER_ADD(PartiesNouveauFormat.listeParties , nroReference*TaillePartieRecNouveauFormat);
  GetNomJaponaisDuTournoiParNroRefPartie := GetNomJaponaisDuTournoi(partieArrow^.nroTournoi);
end;


function GetNomJaponaisDuTournoiAvecAnneeParNroRefPartie(nroReference : SInt32; longueurTotaleVoulue : SInt16) : String255;
var s : String255;
    i : SInt16;
begin
  s := GetNomJaponaisDuTournoiParNroRefPartie(nroReference);
  for i := 1 to longueurTotaleVoulue-LENGTH_OF_STRING(s)-4 do s := s + ' ';
  GetNomJaponaisDuTournoiAvecAnneeParNroRefPartie := s+IntToStr(GetAnneePartieParNroRefPartie(nroReference));
end;

procedure SetNomJaponaisDuJoueur(nroJoueur : SInt32; nomJaponais : String255);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin

  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
     begin
       JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));
       if (JoueurArrow^.nomJaponais <> NIL) then
         begin
           DisposeMemoryHdl(Handle(JoueurArrow^.nomJaponais));
           JoueurArrow^.nomJaponais := NIL;
         end;
       if nomJaponais <> '' then
         begin
           JoueurArrow^.nomJaponais := String255Hdl(AllocateMemoryHdl(SizeOf(String255)));
           if JoueurArrow^.nomJaponais <> NIL then
             JoueurArrow^.nomJaponais^^ := nomJaponais;
         end;
     end;
end;


procedure SetNomJaponaisDuTournoi(nroTournoi : SInt32; nomJaponais : String255);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) and
     (nroTournoi >= 0) and
     (nroTournoi < nbTournoisNouveauFormat) and
     (listeTournois <> NIL) then
     begin
       TournoiArrow := POINTER_ADD(listeTournois , nroTournoi*sizeof(TournoisNouveauFormatRec));
       if (TournoiArrow^.nomJaponais <> NIL) then
         begin
           DisposeMemoryHdl(Handle(TournoiArrow^.nomJaponais));
           TournoiArrow^.nomJaponais := NIL;
         end;
       if nomJaponais <> '' then
         begin
           TournoiArrow^.nomJaponais := String255Hdl(AllocateMemoryHdl(SizeOf(String255)));
           if TournoiArrow^.nomJaponais <> NIL then
             TournoiArrow^.nomJaponais^^ := nomJaponais;
         end;
     end;
end;


function GetNomJoueurSansPrenom(nroJoueur : SInt32) : String255;
const longueurFratrieCherchee = 15;
var nroAlphabetique : SInt32;
    nroMinAvant,nroMaxApres : SInt32;
    nomJoueur,nomSansPrenom : String255;
    nomJoueurTeste,nomTesteSansPrenom : String255;
    result : String255;
    nomSansPrenomEnMajuscule : String255;
    JoueurArrow : JoueursNouveauFormatRecPtr;
    JoueurArrow2 : JoueursNouveauFormatRecPtr;
    aux,k : SInt32;
    longueur,longueurMax,longueurInitiale,longueurDiscriminante : SInt32;
begin

  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
    then
			begin
			  JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));

        {Le nom court a-t-il deja ete calculé ? si c'est
         le cas, on peut renvoyer directement le resultat}

        nomJoueur := JoueurArrow^.nomCourt;
        if (nomJoueur <> '') then
          begin
            GetNomJoueurSansPrenom := nomJoueur;
            exit;
          end;

			  {Sinon, il faut le calculer a partir du nom avec prenom}
			  nomJoueur := JoueurArrow^.nom;
			  EnlevePrenom(nomJoueur,nomSansPrenom);

			  nomSansPrenomEnMajuscule := nomSansPrenom;
			  nomSansPrenomEnMajuscule := UpperCase(nomSansPrenomEnMajuscule, false);

			  if not(differencierLesFreres) or (Pos('TASTET',nomSansPrenomEnMajuscule) > 0) then
			    begin
			      nomSansPrenom := EnleveEspacesDeDroite(nomSansPrenom);
			      JoueurArrow^.nomCourt := nomSansPrenom;
			      GetNomJoueurSansPrenom := nomSansPrenom;
			      exit;
			    end;

			  longueurMax := LENGTH_OF_STRING(nomJoueur);
			  longueur := LENGTH_OF_STRING(nomSansPrenom);
			  longueurInitiale := longueur;
			  longueurDiscriminante := longueur;

			  {on determine l'intervalle des numeros alphabetiques
			   qui nous interessent pour les comparaisons}
			  nroAlphabetique := GetNroOrdreAlphabetiqueJoueur(nroJoueur);
			  nroMinAvant := Max(0, nroAlphabetique - longueurFratrieCherchee);
			  nroMaxApres := Min(nbJoueursNouveauFormat - 1, nroAlphabetique + longueurFratrieCherchee);


			  JoueurArrow2 := MAKE_MEMORY_POINTER(POINTER_VALUE(listeJoueurs));
			  for k := 0 to nbJoueursNouveauFormat-1 do
			    begin
			      aux := JoueurArrow2^.numeroDansOrdreAlphabetique;

			      if (nroMinAvant <= aux) and (aux <= nroMaxApres) and (k <> nroJoueur) then
			        begin
			          nomJoueurTeste := JoueurArrow2^.nom;
			          EnlevePrenom(nomJoueurTeste,nomTesteSansPrenom);
			          if (nomSansPrenom = nomTesteSansPrenom) and (nomJoueurTeste <> nomJoueur) then
			            begin
			              longueur := longueurInitiale;
			              while (longueur < longueurMax) and
			                    (nomJoueur[longueur] = nomJoueurTeste[longueur]) and
			                    (nomJoueur[longueur] <> '(') and
			                    (nomJoueur[longueur+1] <> '(') do
			                inc(longueur);
			              if longueur > longueurDiscriminante then
			                longueurDiscriminante := longueur;
			              {WritelnDansRapport(nomJoueurTeste);}
			            end;
			        end;

			      JoueurArrow2 := POINTER_ADD(JoueurArrow2 , sizeof(JoueursNouveauFormatRec));
			    end;

			  if longueurDiscriminante = longueurInitiale
			    then
			      begin
			        JoueurArrow^.nomCourt := EnleveEspacesDeDroite(nomSansPrenom);
			        GetNomJoueurSansPrenom := JoueurArrow^.nomCourt;
			      end
			    else
			      begin
			        result := TPCopy(nomJoueur,1,longueurDiscriminante);
			        {WritelnDansRapport('result = '+result);}

			        EnleveEspacesDeDroiteSurPlace(nomJoueur);
			        {WritelnDansRapport('nomJoueur = '+nomJoueur);}

			        if nomJoueur = result
			          then
			            begin
			              {WritelnDansRapport('pas de rajout, on prend le nom complet');}
			              JoueurArrow^.nomCourt := nomJoueur;
			              GetNomJoueurSansPrenom := JoueurArrow^.nomCourt;
			            end
			          else
			            begin
			              {WritelnDansRapport('rajout d''un point apres l''initiale du prenom');}
			              JoueurArrow^.nomCourt := EnleveEspacesDeDroite(result) + '.';
			              GetNomJoueurSansPrenom := JoueurArrow^.nomCourt;
			            end;
			      end;
			end
	 else
	   GetNomJoueurSansPrenom := '******';
end;



function GetNomDeFamilleSansDifferencierLesPrenoms(nroJoueur : SInt32) : String255;
var nomJoueur,nomSansPrenom : String255;
    JoueurArrow : JoueursNouveauFormatRecPtr;
begin

  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (nroJoueur >= 0) and
     (nroJoueur < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL)
    then
			begin
			  JoueurArrow := POINTER_ADD(listeJoueurs , nroJoueur*sizeof(JoueursNouveauFormatRec));

			  nomJoueur := JoueurArrow^.nom;
			  EnlevePrenom(nomJoueur,nomSansPrenom);

			  nomSansPrenom := EnleveEspacesDeDroite(nomSansPrenom);
			  GetNomDeFamilleSansDifferencierLesPrenoms := nomSansPrenom;
			end
	 else
	   GetNomDeFamilleSansDifferencierLesPrenoms := '******';
end;



function GetNomJoueurCommeDansPapp(nroJoueur : SInt32) : String255;
var s1,s2 : String255;
begin
  s1 := GetNomDeFamilleSansDifferencierLesPrenoms(nroJoueur);
  s2 := GetNomJoueur(nroJoueur);
  s2 := StripDiacritics(s2);
  GetNomJoueurCommeDansPapp := UpperCase(s1,false) + RightOfString(s2,LENGTH_OF_STRING(s2)-LENGTH_OF_STRING(s1));
end;


function GetNomJoueurCommeDansFichierFFODesJoueurs(nroJoueur : SInt32) : String255;
var s1,s2 : String255;
begin
  s1 := GetNomDeFamilleSansDifferencierLesPrenoms(nroJoueur);
  s2 := GetNomJoueur(nroJoueur);
  s2 := StripDiacritics(s2);
  GetNomJoueurCommeDansFichierFFODesJoueurs := UpperCase(s1,false) + ',' + RightOfString(s2,LENGTH_OF_STRING(s2)-LENGTH_OF_STRING(s1));
end;




END.



