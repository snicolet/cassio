UNIT UnitModes;


INTERFACE


USES UnitDefCassio;

function CassioIsInBackground : boolean;
function CassioEstEnModeSolitaire : boolean;
function CassioEstEnModeAnalyse : boolean;
function AuMoinsUneZoneDeTexteEnModeEntree : boolean;
function CassioEstEnTrainDePlaquerUnSolitaire : boolean;
procedure SetCassioEstEnTrainDePlaquerUnSolitaire(flag : boolean);


{ des fonctions pour prendre des decisions sur le type de calcul a lancer, ou d'interrution a lancer, etc. }
procedure GetConfigurationCouranteDeCassio(var config : ConfigurationCassioRec);
procedure ChangeConfiguration(var config : ConfigurationCassioRec; const message : String255; value : SInt32);
function TypeDeCalculLanceParCassioDansCetteConfiguration(var config : ConfigurationCassioRec) : SInt32;
procedure UpdateConfigurationDeCassio;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitGestionDuTemps, UnitFenetres, UnitServicesRapport, UnitRapportWindow, UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/Modes.lk}
{$ENDC}


{END_USE_CLAUSE}




procedure DoDemandeChangeCouleur;  EXTERNAL_NAME('DoDemandeChangeCouleur');



var gCassioEstEnTrainDePlaquerUnSolitaire : boolean;


function CassioEstEnTrainDePlaquerUnSolitaire : boolean;
begin
  CassioEstEnTrainDePlaquerUnSolitaire := gCassioEstEnTrainDePlaquerUnSolitaire;
end;

procedure SetCassioEstEnTrainDePlaquerUnSolitaire(flag : boolean);
begin
  gCassioEstEnTrainDePlaquerUnSolitaire := flag;
end;

function CassioIsInBackground : boolean;
begin
  CassioIsInBackground := inBackGround;
end;

function CassioEstEnModeSolitaire : boolean;
begin
  CassioEstEnModeSolitaire := (CommentaireSolitaire^^ <> '');
end;

function CassioEstEnModeAnalyse : boolean;
begin
  CassioEstEnModeAnalyse := (GetCadence = minutes10000000) &
                            not(analyseRetrograde.enCours) &
                            (CommentaireSolitaire^^ = '') &
                            (not(CassioEstEnTrainDePlaquerUnSolitaire)) &
                            not(enTournoi);
end;



function AuMoinsUneZoneDeTexteEnModeEntree : boolean;
var fenetrePremierPlan : WindowPtr;
begin
  fenetrePremierPlan := FrontWindowSaufPalette;
  if (EnTraitementDeTexte & FenetreRapportEstOuverte & (EstLaFenetreDuRapport(fenetrePremierPlan))) |
     (arbreDeJeu.enModeEdition & arbreDeJeu.windowOpen & (fenetrePremierPlan = GetArbreDeJeuWindow)) |
     ((BoiteDeSousCritereActive <> 0) & windowListeOpen & (fenetrePremierPlan = wListePtr))
     then AuMoinsUneZoneDeTexteEnModeEntree := true
     else AuMoinsUneZoneDeTexteEnModeEntree := false;
end;



procedure UpdateConfigurationDeCassio;
begin

  (* ATTENTION : BIEN PENSER A MODIFIER AUSSI TypeDeCalculLanceParCassioDansCetteConfiguration
                 SI ON CHANGE QUELQUE CHOSE DANS CETTE ROUTINE  !!
  *)

  if CassioEstEnModeAnalyse &
    (AQuiDeJouer <> couleurMacintosh) &
     not(gameOver | Quitter) & (nbreCoup > 0) then
    begin
      DoDemandeChangeCouleur;
      EffectueTacheInterrompante(interruptionReflexion);
    end;

  InvalidateAnalyseDeFinaleSiNecessaire(kNormal);

  if (interruptionReflexion <> pasdinterruption) then
    EffectueTacheInterrompante(interruptionReflexion);
end;



procedure GetConfigurationCouranteDeCassio(var config : ConfigurationCassioRec);
begin
  with config do
    begin
      interruption                    := interruptionReflexion;
      nombreDeCoupsJoues              := nbreCoup;
      niveauDeJeuInstantane           := NiveauJeuInstantane;
      trait                           := AQuiDeJouer;
      couleurDeCassio                 := couleurMacintosh;
      partieEstFinie                  := gameOver;
      humainContreHumain              := HumCtreHum;
      jeuEstInstantane                := jeuInstantane;
      CassioDoitQuitter               := Quitter;
      positionEstFeerique             := positionFeerique;
      CassioVaDepasserSonTemps        := vaDepasserTemps;
      sansReflexionSurTempsAdversaire := not(CassioDoitReflechirSurLeTempsAdverse);
      laReponseEstPrete               := reponsePrete;
      enModeAnalyse                   := CassioEstEnModeAnalyse;
      attenteAnalyseDeFinaleActivee   := AttenteAnalyseDeFinaleEstActive;
      attenteEnPosCourante            := AttenteAnalyseDeFinaleDansPositionCourante;
    end;
end;


procedure ChangeConfiguration(var config : ConfigurationCassioRec; const message : String255; value : SInt32);
begin
  with config do
    begin
      if message = ''                       then  DoNothing                                else
      if message = 'SET_INTERRUPTION'       then  interruption                    := value else
      if message = 'SET_NBRECOUP'           then  nombreDeCoupsJoues              := value else
      if message = 'SET_NIVEAU'             then  niveauDeJeuInstantane           := value else
      if message = 'SET_AQUIDEJOUER'        then  trait                           := value else
      if message = 'SET_COULEURMAC'         then  couleurDeCassio                 := value else
      if message = 'SET_GAMEOVER'           then  partieEstFinie                  := (value <> 0) else
      if message = 'SET_HUMCTREHUM'         then  humainContreHumain              := (value <> 0) else
      if message = 'SET_JEUINSTANTANE'      then  jeuEstInstantane                := (value <> 0) else
      if message = 'SET_QUITTER'            then  CassioDoitQuitter               := (value <> 0) else
      if message = 'SET_FEERIQUE'           then  positionEstFeerique             := (value <> 0) else
      if message = 'SET_VADEPASSERTEMPS'    then  CassioVaDepasserSonTemps        := (value <> 0) else
      if message = 'SET_REPONSEPRETE'       then  sansReflexionSurTempsAdversaire := (value <> 0) else
      if message = 'SET_NBRECOUP'           then  laReponseEstPrete               := (value <> 0) else
      if message = 'SET_ANALYSE'            then  enModeAnalyse                   := (value <> 0) else
      if message = 'SET_ATTENTEFINALE'      then  attenteAnalyseDeFinaleActivee   := (value <> 0) else
      if message = 'SET_ATTENTEPOSCOURANTE' then  attenteEnPosCourante            := (value <> 0)

      else WritelnDansRapport('ASSERT !! message non compris dans ChangeConfigurationDeCassio');
    end;
end;

function TypeDeCalculLanceParCassioDansCetteConfiguration(var config : ConfigurationCassioRec) : SInt32;
var mode : InvalidateMode;
begin
  TypeDeCalculLanceParCassioDansCetteConfiguration := k_AUCUN_CALCUL;

  with config do
    begin

     (* ATTENTION : il faut faire les memes manip sur la config virtuelle que
                    sur les variables globales dans la fonction ci-dessus
                    "UpdateConfigurationDeCassio" (qui est, elle, appelee
                    par la boucle principale de Cassio). C'est la seule
                    facon que notre fonction soit exacte et "devine" bien le
                    futur etat des variables lorsque Cassio sera dans sa
                    boucle principale
     *)



     { algo de UpdateConfigurationDeCassio }

     if enModeAnalyse & (trait <> couleurDeCassio) &
        not(partieEstFinie | CassioDoitQuitter) & (nombreDeCoupsJoues > 0)
       then couleurDeCassio := -couleurDeCassio;



     { algo de InvalidateAnalyseDeFinaleSiNecessaire(kNormal) }

     mode := kNormal;
     if attenteAnalyseDeFinaleActivee | (mode = kForceInvalidate) then
      begin
        if (mode = kForceInvalidate) | humainContreHumain | (trait <> couleurDeCassio) |
           not(enModeAnalyse) | not(attenteEnPosCourante)
            then attenteAnalyseDeFinaleActivee := false;
      end;


     { et voici l'algo principale pour choisir le type de type de calcul de Cassio }

     if interruption = pasdinterruption then
      if not(partieEstFinie) &
         not(humainContreHumain) &
         not(CassioDoitQuitter) &
         not((nombreDeCoupsJoues <= 0) & enModeAnalyse & not(positionEstFeerique)) then
        begin
          if (trait = couleurDeCassio)
            then
              begin
                if not(attenteAnalyseDeFinaleActivee) then
                  begin
	                  if (nombreDeCoupsJoues = 0) & not(positionEstFeerique)
	                    then TypeDeCalculLanceParCassioDansCetteConfiguration := k_PREMIER_COUP_MAC
	                    else TypeDeCalculLanceParCassioDansCetteConfiguration := k_JEU_MAC;
	                end;
              end
            else
              begin
                if CassioDoitReflechirSurLeTempsAdverseDansCetteConfiguration(config) &
                   not(sansReflexionSurTempsAdversaire | enModeAnalyse) &
                   not(laReponseEstPrete) &
                   (nombreDeCoupsJoues >= 1)
                  then TypeDeCalculLanceParCassioDansCetteConfiguration := k_JEU_MAC;
              end;
        end;
    end;
end;



END.
