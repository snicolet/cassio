UNIT UnitZooAvecArbre;


INTERFACE


USES UnitDefCassio;



{ initialisation de l'unite }
procedure InitUnitZooInterfaceAvecArbre;
procedure LibereMemoireUnitZooInterfaceAvecArbre;
procedure SetValeurStandardLiaisonArbreZoo;


{ flag indiquant si Cassio doit utiliser le zoo }
procedure SetCassioUtiliseLeZoo(newValue : boolean; oldValue : BooleanPtr);
function CassioUtiliseLeZoo : boolean;


{ reception des calculs effectues par le zoo }
procedure RecevoirUnResultatDuZoo(ligne : LongString);


{ liste des calculs que nous avons demandés au zoo }
function NombreDeResultatsEnAttenteSurLeZoo : SInt32;
function AjouterDansLaListeDesRequetesDuZoo(var searchParams : MakeEndgameSearchParamRec) : boolean;
procedure MarquerLaRequeteDuZooCommeEtantCalculee(const searchParam : MakeEndgameSearchParamRec; const whichSuite : String255);
procedure MarquerLaRequeteDuZooCommeEtantEnCharge(const searchParam : MakeEndgameSearchParamRec);
procedure MarquerLaRequeteDuZooCommeNEtantPlusEnCharge(const searchParam : MakeEndgameSearchParamRec);
procedure RetirerDeLaListeDesRequetesDuZoo(whichHash : UInt64);


{ fonctions d'acces à la liste }
function FindSlotLibreDansListeDesRequetesDuZoo(var index : SInt32) : boolean;
function FindHashDansListeDesRequetesDuZoo(whichHash : UInt64; var index : SInt32) : boolean;
function GetScoreOfRequeteDuZoo(whichHash : UInt64) : SInt32;
function GetStatutOfRequeteDuZoo(whichHash : UInt64) : SInt32;
function GetProfOfRequeteDuZoo(whichHash : UInt64) : SInt32;
function GetTimeTakenOfRequeteDuZoo(whichHash : UInt64) : double;


{ date (timestamp unix du serveur free) du dernier resultat calculé par le zoo }
function GetLastTimestampOfResultSurLeZoo : String255;
procedure SetLastTimestampOfResultSurLeZoo(timeStamp : String255);
procedure UpdateTimestampOfLastResultDuZoo(timeStamp : String255);


{ Liaison alpha-beta <--> Zoo }
procedure CopierListeDesCoupsPourLeZoo(prof,nbCoups,couleur,hashCassio : SInt32; const liste : listeVides; const position : plateauOthello; alpha, beta : SInt32);
procedure DetruireListeDesCoupsPourLeZoo(prof : SInt32);
procedure EnvoyerCeFilsAuZoo(prof,whichMove,alpha,beta,deltaFinal : SInt32);
procedure RetirerCeFilsDuZoo(prof,whichMove : SInt32);
procedure CassioPrendEnChargeLuiMemeCeFilsDuZoo(prof,whichMove : SInt32);
procedure SetValeurZooDeCeFils(prof,whichMove,whichScore,bestSuite : SInt32; timeTaken : double);
function GetValeurZooDeCeFils(prof,whichMove : SInt32; var bestSuite : SInt32; var timeTaken : double) : SInt32;
function GetNombreDeFilsParallelisesPourCetteProf(prof : SInt32) : SInt32;
function FindFilsAvecCeHash(prof : SInt32; hash : UInt64; var numeroFils : SInt32) : boolean;
function PasseApresCeFilsDuZoo(const paramsDuFils : MakeEndgameSearchParamRec) : boolean;
function MakeSearchParamsPourCeFilsDuZoo(prof,alpha,beta,deltaFinal : SInt32; var thePos : PositionEtTraitRec; var params : MakeEndgameSearchParamRec) : boolean;
function GetPositionApresCeFilsDuZoo(prof,whichMove : SInt32; var posResultante : PositionEtTraitRec) : boolean;
procedure NettoyerInfosDuZooPourCetteProf(prof : SInt32);


{ Trace d'execution de l'algo de finale }
procedure ResetTraceExecutionFinale;
procedure RecordTraceExecutionFinale(prof, hashCassio, coup : SInt32);
procedure EffacerTraceExecutionFinale(prof : SInt32);
function PositionEstDansLaTraceExecutionFinale(prof, hashCassio : SInt32) : boolean;
function CeFilsEstDansLaTraceExecutionFinale(profPere, hashCassioDuPere, coupFils : SInt32) : boolean;
procedure AjouterDansLaListeDesTracesExecutionAStopper(prof : SInt32);
procedure RetirerDeLaListeDesTracesExecutionAStopper(hashFils : SInt32);
procedure RetirerDeLaListeDesTracesExecutionAStopperParNumeroArret(numeroArret : SInt32);
function DoitStopperExecutionDeCeSousArbre(prof : SInt32) : boolean;
function OnVientDeStoperExecutionDeCeFils(profPere,coupFils : SInt32; var numeroArret : SInt32) : boolean;
function HashCassioEstDansLesTracesExecutionAStopper(whichHash : SInt32; var whichProf : SInt32) : boolean;


{ Les "grosses" requetes (celles de priorite > 100) }




IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{$DEFINEC USE_PRELINK true}

USES
    Sound, OSUtils
{$IFC NOT(USE_PRELINK)}
    , MyStrings, UnitRapport, UnitZoo, UnitRapportImplementation, UnitSolve, MyMathUtils
    , UnitLongString, UnitPositionEtTrait, UnitScannerUtils, UnitEngine ;
{$ELSEC}
    ;
    {$I prelink/ZooAvecArbre.lk}
{$ENDC}


{END_USE_CLAUSE}









const kNbreMaxDeJobsSurLeZoo = 100;



var gLastTimestampOfResultsSurLeZoo : record
                                           stamp : String255;
                                           tickReception : SInt32;
                                         end;


    gListeDesJobsDuZoo : record
                                 nbJobsDemandes       : SInt32;
                                 dernierIndexUtilise  : SInt32;
                                 statut               : array[1..kNbreMaxDeJobsSurLeZoo] of SInt32;
                                 hash                 : array[1..kNbreMaxDeJobsSurLeZoo] of UInt64;
                                 score                : array[1..kNbreMaxDeJobsSurLeZoo] of SInt32;
                                 suite                : array[1..kNbreMaxDeJobsSurLeZoo] of String255;
                                 parametres           : array[1..kNbreMaxDeJobsSurLeZoo] of MakeEndgameSearchParamRec;
                              end;

    gTraceExecutionDeFinale : record
                                theTrace : array[0..64] of record
                                                             hashCassio : SInt32;
                                                             coup       : SInt32;
                                                           end;
                                arrets : record
                                           cardinal : SInt32;
                                           descr : array[0..64] of
                                                     record
                                                       hashDuPere        : SInt32;  // hash du pere dont on doit arreter le fils
                                                       hashCassio        : SInt32;  // hash du fils a arreter
                                                       profDuFils        : SInt32;  // profondeur du fils a arreter
                                                       coupDuFils        : SInt32;  // coup du fils a arreter
                                                       estUneCoupureBeta : boolean;
                                                     end;
                                         end;
                              end;


procedure SetValeurStandardLiaisonArbreZoo;
begin
  with liaisonArbreZoo do
    begin

      profMinUtilisationZoo              := 64;  {was 21}
      profMaxUtilisationZoo              := 64;

      tempsMinimalPourEnvoyerAuZoo      :=  2.0;       {trois secondes}
      tempsMaximalPourEnvoyerAuZoo      := 300.0;      {cent quatre-vingt secondes est bien ?}

      margePourParallelismeAlphaSpeculatif  := 600;    {on considere que quand eval <= alpha - 6.0 , on a une coupure alpha presque sure }
      margePourParallelismeHeuristique      := 500;    {on parellelisera moins facilement les coups dont (eval <= alpha - mu - 5.00) ou (eval >= beta + mu + 5.00) }

      occupationPourParallelismeAlpha2      := 25;
    end;
end;



procedure InitUnitZooInterfaceAvecArbre;
var k,vides : SInt32;
begin
  SetLastTimestampOfResultSurLeZoo('0');

  with gListeDesJobsDuZoo do
    begin
      nbJobsDemandes      := 0;
      dernierIndexUtilise := 1;
      for k := 1 to kNbreMaxDeJobsSurLeZoo do
        begin
          SetHashValueDuZoo(hash[k] , k_ZOO_NOT_INITIALIZED_VALUE);
          statut[k] := k_ZOO_NOT_INITIALIZED_VALUE;
          score[k]  := k_ZOO_NOT_INITIALIZED_VALUE;
          suite[k]  := '';
        end;
    end;


  with liaisonArbreZoo do
    begin

      SetValeurStandardLiaisonArbreZoo;


      nbTotalPositionsEnvoyees              := 0;
      gNombreDeCoupuresAlphaPresquesSures   := 0;
      gNombreDeCoupuresAlphaReussies        := 0;
      gNombreDeMauvaisesParallelisation     := 0;
      gNombreDeParallelisationEnRetard      := 0;
      gNombreDeParallelisationVerifiees     := 0;


      for vides := 0 to 64 do
        with infosNoeuds[vides] do
          begin
            longueurListe           := 0;
            nbCoupsEnvoyesAuZoo := 0;
            trait                   := pionVide;
            hashCassioDuPere        := k_ZOO_NOT_INITIALIZED_VALUE;

            for k := 1 to 64 do
              begin
                coupsFils[k].coup       := 0;
                coupsFils[k].theVal     := k_ZOO_NOT_INITIALIZED_VALUE;
                bestDef[k]              := 0;
                SetHashValueDuZoo(hashRequete[k] , k_ZOO_NOT_INITIALIZED_VALUE);
                hashCassioDesFils[k]    := k_ZOO_NOT_INITIALIZED_VALUE;
                timeUsed[k]             := -1.0;
              end;

          end;
    end;

  with gTraceExecutionDeFinale do
    begin
      for vides := 0 to 64 do
        begin
          theTrace[vides].hashCassio := -1;
          theTrace[vides].coup       := -1;
        end;

      with arrets do
        begin
          cardinal := 0;
          for k := 0 to 64 do
            begin
              descr[k].hashCassio        := -1;
              descr[k].hashDuPere        := -1;
              descr[k].profDuFils        := -1;
              descr[k].coupDuFils        := -1;
              descr[k].estUneCoupureBeta := false;
            end;
        end;
    end;

end;


procedure LibereMemoireUnitZooInterfaceAvecArbre;
begin
end;


procedure SetCassioUtiliseLeZoo(newValue : boolean; oldValue : BooleanPtr);
begin
  if oldValue <> NIL then
    oldValue^ := (liaisonArbreZoo.profMinUtilisationZoo <= 64);

  if newValue
    then liaisonArbreZoo.profMinUtilisationZoo := 21
    else liaisonArbreZoo.profMinUtilisationZoo := 1000;
end;


function CassioUtiliseLeZoo : boolean;
begin
  CassioUtiliseLeZoo := CassioDoitRentrerEnContactAvecLeZoo and (liaisonArbreZoo.profMinUtilisationZoo <= 64);
end;



function FindSlotLibreDansListeDesRequetesDuZoo(var index : SInt32) : boolean;
var k : SInt32;
begin

 with gListeDesJobsDuZoo do
   begin

      // on cherche d'abord un emplacement vierge

      for k := 1 to kNbreMaxDeJobsSurLeZoo do
        if (gListeDesJobsDuZoo.statut[k] = k_ZOO_NOT_INITIALIZED_VALUE) then
          begin
            index               := k;
            dernierIndexUtilise := k;
            FindSlotLibreDansListeDesRequetesDuZoo := true;
            exit(FindSlotLibreDansListeDesRequetesDuZoo);
          end;

      // puis eventuellement un resultat déjà calculé à écraser

      for k := 1 to kNbreMaxDeJobsSurLeZoo do
        if (gListeDesJobsDuZoo.statut[k] = k_ZOO_VALUE_IS_CALCULATED) then
          begin
            index               := k;
            dernierIndexUtilise := k;
            FindSlotLibreDansListeDesRequetesDuZoo := true;
            exit(FindSlotLibreDansListeDesRequetesDuZoo);
          end;

   end;


  // echec !

  FindSlotLibreDansListeDesRequetesDuZoo := false;
  index := -1;
end;


function FindHashDansListeDesRequetesDuZoo(whichHash : UInt64; var index : SInt32) : boolean;
var k,t : SInt32;
begin
  with gListeDesJobsDuZoo do
    begin

      { cherchons d'abord si le hash n'est pas a la position "dernierIndexUtilise" }

      if Same64Bits(hash[dernierIndexUtilise] , whichHash) then
        begin
          FindHashDansListeDesRequetesDuZoo := true;
          index := dernierIndexUtilise;
          exit(FindHashDansListeDesRequetesDuZoo);
        end;


      { non : il faut donc chercher... }

      for t := 1 to (kNbreMaxDeJobsSurLeZoo div 2) do
        begin

          { un coup en montant... }

          k := dernierIndexUtilise + t;
          if (k > kNbreMaxDeJobsSurLeZoo) then k := k - kNbreMaxDeJobsSurLeZoo else
          if (k < 1)                         then k := k + kNbreMaxDeJobsSurLeZoo;

          if Same64Bits(hash[k] , whichHash) then
            begin
              FindHashDansListeDesRequetesDuZoo := true;
              dernierIndexUtilise := k;
              index               := k;
              exit(FindHashDansListeDesRequetesDuZoo);
            end;


          { un coup en descendant... }

          k := dernierIndexUtilise - t;
          if (k > kNbreMaxDeJobsSurLeZoo) then k := k - kNbreMaxDeJobsSurLeZoo else
          if (k < 1)                         then k := k + kNbreMaxDeJobsSurLeZoo;

          if Same64Bits(hash[k] , whichHash) then
            begin
              FindHashDansListeDesRequetesDuZoo := true;
              dernierIndexUtilise := k;
              index               := k;
              exit(FindHashDansListeDesRequetesDuZoo);
            end;

        end;
    end;

  FindHashDansListeDesRequetesDuZoo := false;
  index := -1;
end;


function GetScoreOfRequeteDuZoo(whichHash : UInt64) : SInt32;
var index : SInt32;
begin
  if FindHashDansListeDesRequetesDuZoo(whichHash, index)
    then GetScoreOfRequeteDuZoo := gListeDesJobsDuZoo.score[index]
    else GetScoreOfRequeteDuZoo := k_ZOO_NOT_INITIALIZED_VALUE;
end;


function GetStatutOfRequeteDuZoo(whichHash : UInt64) : SInt32;
var index : SInt32;
begin
  if FindHashDansListeDesRequetesDuZoo(whichHash, index)
    then GetStatutOfRequeteDuZoo := gListeDesJobsDuZoo.statut[index]
    else GetStatutOfRequeteDuZoo := k_ZOO_NOT_INITIALIZED_VALUE;
end;


function GetProfOfRequeteDuZoo(whichHash : UInt64) : SInt32;
var index : SInt32;
begin
  if FindHashDansListeDesRequetesDuZoo(whichHash, index)
    then GetProfOfRequeteDuZoo := gListeDesJobsDuZoo.parametres[index].inProfondeurFinale
    else GetProfOfRequeteDuZoo := k_ZOO_NOT_INITIALIZED_VALUE;
end;


function GetTimeTakenOfRequeteDuZoo(whichHash : UInt64) : double;
var index : SInt32;
begin
  if FindHashDansListeDesRequetesDuZoo(whichHash, index)
    then GetTimeTakenOfRequeteDuZoo := gListeDesJobsDuZoo.parametres[index].outResult.outTimeTakenFinale
    else GetTimeTakenOfRequeteDuZoo := k_ZOO_NOT_INITIALIZED_VALUE;
end;


function AjouterDansLaListeDesRequetesDuZoo(var searchParams : MakeEndgameSearchParamRec) : boolean;
var urlParams : String255;
    requete : LongString;
    index : SInt32;
begin
  AjouterDansLaListeDesRequetesDuZoo := false;

  if (searchParams.inProfondeurFinale > 0) and
     (searchParams.inCouleurFinale <> pionVide) then
    with gListeDesJobsDuZoo do
      begin

        AjouterDansLaListeDesRequetesDuZoo := true;

        urlParams := '';
        EncoderSearchParamsPourURL(searchParams, urlParams, 'AjouterDansLaListeDesRequetesDuZoo');

        {WritelnDansRapport('dans AjouterDansLaListeDesRequetesDuZoo, urlParams = '+urlParams);}

        if FindHashDansListeDesRequetesDuZoo(searchParams.inHashValue, index)
          then
            begin
              if statut[index] = k_ZOO_NOT_INITIALIZED_VALUE
                then WritelnDansRapport('ASSERT : dans AjouterDansLaListeDesRequetesDuZoo, position trouvée mais mal initialisée');

              if statut[index] = k_ZOO_EN_ATTENTE_DE_RESULTAT
                then WritelnDansRapport('WARNING : dans AjouterDansLaListeDesRequetesDuZoo, position déjà envoyée au zoo et en attente de résultat');

              if statut[index] = k_ZOO_VALUE_IS_CALCULATED
                then WritelnDansRapport('WARNING : je connais le résultat dans AjouterDansLaListeDesRequetesDuZoo, alors je ne fais rien');
            end
          else
            begin
              if FindSlotLibreDansListeDesRequetesDuZoo(index)
                then
                  begin

                    statut[index]        := k_ZOO_EN_ATTENTE_DE_RESULTAT;
                    hash[index]          := searchParams.inHashValue;
                    score[index]         := k_ZOO_NOT_INITIALIZED_VALUE;
                    suite[index]         := '';
                    parametres[index]    := searchParams;


                    // lancer le job !

                    (* if (NombreDeResultatsEnAttenteSurLeZoo > 0)
                      then
                        begin
                          requete := MakeLongString(GetZooURL + '?action=ADD_AND_GET_RESULTS&' + urlParams + '&date=' + GetLastTimestampOfResultSurLeZoo);

                          SetDateDerniereEcouteDeResultatsDuZoo(tickCount);
                        end
                      else
                     *)
                        requete := MakeLongString(GetZooURL + '?action=ADD&' + urlParams);

                    EnvoyerUneRequeteAuZoo(requete);

                    inc(nbJobsDemandes);

                    {WritelnNumDansRapport('nbJobsDemandes = ',nbJobsDemandes);}
                  end
                else
                  begin
                    WritelnDansRapportSansRepeter('ASSERT : dans Cassio, plus de slot libre pour AjouterDansLaListeDesRequetesDuZoo');
                    AjouterDansLaListeDesRequetesDuZoo := false;
                  end;
            end;
     end;
end;


procedure MarquerLaRequeteDuZooCommeEtantCalculee(const searchParam : MakeEndgameSearchParamRec; const whichSuite : String255);
var index,numeroFils, profPere : SInt32;
    myScore, bestMove : SInt32;
    coupDuFils : SInt32;
    pos : plateauOthello;
    timeTaken : double;
begin
  Discard(pos);

  if FindHashDansListeDesRequetesDuZoo(searchParam.inHashValue,index)
    then
      begin
        with gListeDesJobsDuZoo do
          begin
            if statut[index] <> k_ZOO_VALUE_IS_CALCULATED then
              begin

                if (statut[index] <> k_ZOO_EN_ATTENTE_DE_RESULTAT) and
                   (statut[index] <> k_ZOO_POSITION_PRISE_EN_CHARGE) then
                  begin
                    WriteDansRapport('ASSERT :   (statut <> k_ZOO_EN_ATTENTE_DE_RESULTAT) and (statut <> k_ZOO_POSITION_PRISE_EN_CHARGE) dans MarquerLaRequeteDuZooCommeEtantCalculee , statut = ');
                    case statut[index] of
                       k_ZOO_NOT_INITIALIZED_VALUE    : WritelnDansRapport('k_ZOO_NOT_INITIALIZED_VALUE');
                       k_ZOO_VALUE_IS_CALCULATED      : WritelnDansRapport('k_ZOO_VALUE_IS_CALCULATED');
                       k_ZOO_EN_ATTENTE_DE_RESULTAT   : WritelnDansRapport('k_ZOO_EN_ATTENTE_DE_RESULTAT');
                       k_ZOO_POSITION_PRISE_EN_CHARGE : WritelnDansRapport('k_ZOO_POSITION_PRISE_EN_CHARGE');
                       otherwise                         WritelnNumDansRapport('valeur inconnue  ',statut[index]);
                     end; {case}
                  end;


                statut[index] := k_ZOO_VALUE_IS_CALCULATED;
                score[index]  := searchParam.outResult.outScoreFinale;
                suite[index]  := whichSuite;
                CopySearchResults(searchParam.outResult, parametres[index].outResult);

                dec(nbJobsDemandes);

                (*
                BeginRapportPourZoo;
                WritelnDansRapport('');
                WriteTickOperationPourLeZooDansRapport;
                WritelnDansRapport('Je viens de recevoir une réponse du zoo : ');
                ChangeFontFaceDansRapport(normal);
                pos := searchParam.inPositionPourFinale;
                WritelnPositionEtTraitDansRapport(pos,searchParam.inCouleurFinale);
                WritelnFenetreAlphaBetaDansRapport(searchParam.inAlphaFinale,searchParam.inBetaFinale);
                WriteNumDansRapport('whichScore = ',searchParam.outScoreFinale);
                WriteStringAndCoupDansRapport(', coupanddef = ',searchParam.outBestMoveFinale);
                WritelnStringAndCoupDansRapport('',searchParam.outBestDefenseFinale);
                WritelnDansRapport(', suite = '+searchParam.outLineFinale);
                WritelnNumDansRapport('whichHash = ',whichHash);
                WritelnDansRapport('');
                EndRapportPourZoo;
                *)

                {WritelnNumDansRapport('nbJobsDemandes = ',nbJobsDemandes);}

                profPere := searchParam.inProfondeurFinale + 1;
                bestMove := searchParam.outResult.outBestMoveFinale;

                if PasseApresCeFilsDuZoo(searchParam)
                  then myScore  :=  searchParam.outResult.outScoreFinale
                  else myScore  := -searchParam.outResult.outScoreFinale;

                timeTaken := searchParam.outResult.outTimeTakenFinale;


                if FindFilsAvecCeHash(profPere, searchParam.inHashValue, numeroFils)
                  then
                    begin
                      {WritelnDansRapport('COOL : Je dois mettre une valeur dans l''arbre');}

                      with liaisonArbreZoo.infosNoeuds[profPere] do
                        begin

                          if (myScore >= -64) and (myScore <= 64) then
                            begin
                              {WritelnNumDansRapport('Je mets le score suivant : ',myScore);
                              WritelnStringAndCoupDansRapport('coup : ',coupsFils[numeroFils].coup);
                              WritelnStringAndCoupDansRapport('defense : ',bestMove);}

                              coupDuFils := coupsFils[numeroFils].coup;

                              SetValeurZooDeCeFils(profPere, coupDuFils, myScore, bestMove, timeTaken);


                              if myScore >= betaInitial then
                                WritelnNumDansRapport('coupure beta à profondeur (NOT IMPLEMENTED)',profPere);

                              if CeFilsEstDansLaTraceExecutionFinale(profPere, hashCassioDuPere, coupDuFils) then
                                begin
                                  WriteNumDansRapport('p = ',profPere);
                                  WritelnDansRapport('  BINGO ! Le sous arbre retourné par le zoo ('+CoupEnStringEnMajuscules(coupsFils[numeroFils].coup)+') est celui que nous calculions');

                                  // on arrete ce fils
                                  AjouterDansLaListeDesTracesExecutionAStopper(profPere - 1);
                                end;

                            end;
                        end;

                    end
                  else
                    (*
                    WritelnDansRapport('WARNING : not(FindFilsAvecCeHash) dans MarquerLaRequeteDuZooCommeEtantCalculee !!');
                    *)

              end;
          end;
      end
    else
      begin
        {WritelnDansRapport('ASSERT : not(FindHashDansListeDesRequetesDuZoo) dans MarquerLaRequeteDuZooCommeEtantCalculee !!');}
      end;
end;



procedure MarquerLaRequeteDuZooCommeEtantEnCharge(const searchParam : MakeEndgameSearchParamRec);
var index,numeroFils, profPere : SInt32;
    valeurConnue, bestMove : SInt32;
    pos : plateauOthello;
    timeTaken : double;
begin
  Discard(pos);

  if FindHashDansListeDesRequetesDuZoo(searchParam.inHashValue,index)
    then
      begin
        with gListeDesJobsDuZoo do
          begin
            if (statut[index] <> k_ZOO_POSITION_PRISE_EN_CHARGE) then
              begin

                if statut[index] <> k_ZOO_EN_ATTENTE_DE_RESULTAT then
                  begin
                    WriteDansRapport('WARNING :   statut <> k_ZOO_EN_ATTENTE_DE_RESULTAT  dans MarquerLaRequeteDuZooCommeEtantEnCharge,  statut = ');
                    case statut[index] of
                       k_ZOO_NOT_INITIALIZED_VALUE    : WritelnDansRapport('k_ZOO_NOT_INITIALIZED_VALUE');
                       k_ZOO_VALUE_IS_CALCULATED      : WritelnDansRapport('k_ZOO_VALUE_IS_CALCULATED');
                       k_ZOO_EN_ATTENTE_DE_RESULTAT   : WritelnDansRapport('k_ZOO_EN_ATTENTE_DE_RESULTAT');
                       k_ZOO_POSITION_PRISE_EN_CHARGE : WritelnDansRapport('k_ZOO_POSITION_PRISE_EN_CHARGE');
                       otherwise                         WritelnNumDansRapport('valeur inconnue  ',statut[index]);
                     end; {case}
                  end;

                if statut[index] <> k_ZOO_VALUE_IS_CALCULATED then
                  begin

                    statut[index] := k_ZOO_POSITION_PRISE_EN_CHARGE;

                    (*
                    BeginRapportPourZoo;
                    WritelnDansRapport('');
                    WriteTickOperationPourLeZooDansRapport;
                    WritelnDansRapport('La position suivante est prise en charge par le zoo : ');
                    ChangeFontFaceDansRapport(normal);
                    pos := searchParam.inPositionPourFinale;
                    WritelnPositionEtTraitDansRapport(pos,searchParam.inCouleurFinale);
                    WritelnFenetreAlphaBetaDansRapport(searchParam.inAlphaFinale,searchParam.inBetaFinale);
                    WritelnNumDansRapport('whichHash = ',whichHash);
                    WritelnDansRapport('');
                    EndRapportPourZoo;
                    *)

                    {WritelnNumDansRapport('nbJobsDemandes = ',nbJobsDemandes);}


                    profPere := searchParam.inProfondeurFinale + 1;

                    if FindFilsAvecCeHash(profPere ,searchParam.inHashValue, numeroFils)
                      then
                        begin
                          {WritelnDansRapport('COOL : Je dois marquer une position comme etant en charge dans l''arbre');}

                          with liaisonArbreZoo.infosNoeuds[profPere] do
                            begin
                              valeurConnue := GetValeurZooDeCeFils(profPere, coupsFils[numeroFils].coup,bestMove,timeTaken);

                              if (valeurConnue < -64) or (valeurConnue > 64) then
                                SetValeurZooDeCeFils(profPere, coupsFils[numeroFils].coup, k_ZOO_POSITION_PRISE_EN_CHARGE, -1, -1.0);
                            end;

                        end
                      else
                        (*
                        WritelnDansRapport('WARNING : not(FindFilsAvecCeHash) dans MarquerLaRequeteDuZooCommeEtantEnCharge !!');
                        *)

                  end;

              end;
          end;
      end
    else
      begin
        {WritelnDansRapport('ASSERT : not(FindHashDansListeDesRequetesDuZoo) dans MarquerLaRequeteDuZooCommeEtantEnCharge !!');}
      end;
end;



procedure MarquerLaRequeteDuZooCommeNEtantPlusEnCharge(const searchParam : MakeEndgameSearchParamRec);
var index,numeroFils, profPere : SInt32;
    valeurConnue, bestMove : SInt32;
    pos : plateauOthello;
    timeTaken : double;
begin
  Discard(pos);

  if FindHashDansListeDesRequetesDuZoo(searchParam.inHashValue,index)
    then
      begin
        with gListeDesJobsDuZoo do
          begin
            if (statut[index] <> k_ZOO_EN_ATTENTE_DE_RESULTAT) then
              begin

                if statut[index] <> k_ZOO_POSITION_PRISE_EN_CHARGE then
                   begin
                     WriteDansRapport('WARNING :   statut <> k_ZOO_POSITION_PRISE_EN_CHARGE  dans MarquerLaRequeteDuZooCommeNEtantPlusEnCharge,  statut = ');
                     case statut[index] of
                       k_ZOO_NOT_INITIALIZED_VALUE    : WritelnDansRapport('k_ZOO_NOT_INITIALIZED_VALUE');
                       k_ZOO_VALUE_IS_CALCULATED      : WritelnDansRapport('k_ZOO_VALUE_IS_CALCULATED');
                       k_ZOO_EN_ATTENTE_DE_RESULTAT   : WritelnDansRapport('k_ZOO_EN_ATTENTE_DE_RESULTAT');
                       k_ZOO_POSITION_PRISE_EN_CHARGE : WritelnDansRapport('k_ZOO_POSITION_PRISE_EN_CHARGE');
                       otherwise                         WritelnNumDansRapport('valeur inconnue  ',statut[index]);
                     end; {case}
                   end;

                if statut[index] <> k_ZOO_VALUE_IS_CALCULATED then
                  begin

                    statut[index] := k_ZOO_EN_ATTENTE_DE_RESULTAT;

                    (*
                    BeginRapportPourZoo;
                    WritelnDansRapport('');
                    WriteTickOperationPourLeZooDansRapport;
                    WritelnDansRapport('Ah, le zoo ne prend plus en charge la position suivante : ');
                    ChangeFontFaceDansRapport(normal);
                    pos := searchParam.inPositionPourFinale;
                    WritelnPositionEtTraitDansRapport(pos,searchParam.inCouleurFinale);
                    WritelnFenetreAlphaBetaDansRapport(searchParam.inAlphaFinale,searchParam.inBetaFinale);
                    WritelnNumDansRapport('whichHash = ',whichHash);
                    WritelnDansRapport('');
                    EndRapportPourZoo;
                    *)

                    {WritelnNumDansRapport('nbJobsDemandes = ',nbJobsDemandes);}

                    profPere := searchParam.inProfondeurFinale + 1;


                    if FindFilsAvecCeHash(profPere, searchParam.inHashValue, numeroFils)
                      then
                        begin
                          {WritelnDansRapport('COOL : cette position dans l''arbre n''est plus prise en charge par le zoo');}

                          with liaisonArbreZoo.infosNoeuds[profPere] do
                            begin
                              valeurConnue := GetValeurZooDeCeFils(profPere, coupsFils[numeroFils].coup,bestMove,timeTaken);

                              if (valeurConnue < -64) or (valeurConnue > 64) then
                                SetValeurZooDeCeFils(profPere, coupsFils[numeroFils].coup, k_ZOO_EN_ATTENTE_DE_RESULTAT, -1, -1.0);
                            end;

                        end
                      else
                        (*
                        WritelnDansRapport('WARNING : not(FindFilsAvecCeHash) dans MarquerLaRequeteDuZooCommeNEtantPlusEnCharge !!');
                        *)

                  end;

              end;
          end;
      end
    else
      begin
        {WritelnDansRapport('ASSERT : not(FindHashDansListeDesRequetesDuZoo) dans MarquerLaRequeteDuZooCommeNEtantPlusEnCharge !!');}
      end;
end;



procedure RetirerDeLaListeDesRequetesDuZoo(whichHash : UInt64);
var index : SInt32;
begin
  if FindHashDansListeDesRequetesDuZoo(whichHash,index)
    then
      begin
        with gListeDesJobsDuZoo do
          begin

            if (statut[index] = k_ZOO_NOT_INITIALIZED_VALUE) then
              WritelnDansRapport('ASSERT :   (statut = k_ZOO_NOT_INITIALIZED_VALUE)  dans RetirerDeLaListeDesRequetesDuZoo !! ');

            if (statut[index] = k_ZOO_EN_ATTENTE_DE_RESULTAT) or (statut[index] = k_ZOO_POSITION_PRISE_EN_CHARGE) then
              begin
                dec(nbJobsDemandes);
                {WritelnNumDansRapport('nbJobsDemandes = ',nbJobsDemandes);}
              end;

            statut[index] := k_ZOO_NOT_INITIALIZED_VALUE;
            SetHashValueDuZoo(hash[index] , k_ZOO_NOT_INITIALIZED_VALUE);
            score[index]  := k_ZOO_NOT_INITIALIZED_VALUE;
            suite[index]  := '';
          end;
      end
    else
      begin
        WritelnDansRapport('ASSERT : not(FindHashDansListeDesRequetesDuZoo) dans RetirerDeLaListeDesRequetesDuZoo !!');
      end;
end;




function NombreDeResultatsEnAttenteSurLeZoo : SInt32;
begin
  NombreDeResultatsEnAttenteSurLeZoo := gListeDesJobsDuZoo.nbJobsDemandes;
end;


function GetLastTimestampOfResultSurLeZoo : String255;
begin
  GetLastTimestampOfResultSurLeZoo := gLastTimestampOfResultsSurLeZoo.stamp;
end;


procedure SetLastTimestampOfResultSurLeZoo(timeStamp : String255);
begin
  gLastTimestampOfResultsSurLeZoo.stamp         := timeStamp;
  gLastTimestampOfResultsSurLeZoo.tickReception := TickCount;
end;


procedure UpdateTimestampOfLastResultDuZoo(timeStamp : String255);
var aux : SInt32;
    s : STring255;
begin
  with gLastTimestampOfResultsSurLeZoo do
    begin
      if timestamp > stamp
        then
          SetLastTimestampOfResultSurLeZoo(timeStamp)
        else
          if (timeStamp = stamp) and (TickCount >= tickReception + 150) then
            begin

              // on incremente les secondes du timestamp UNIX
              s := RightOfString(timeStamp,2);
              aux := ChaineEnLongint(s) + 1;
              if aux < 10
                then s := '0'+IntToStr(aux)
                else s := IntToStr(aux);
              RightAssignP(timeStamp,2,s);


              SetLastTimestampOfResultSurLeZoo(timeStamp);
              {WritelnDansRapport('resetting the stamp to '+GetLastTimestampOfResultSurLeZoo);}
            end;
    end;
end;


procedure RecevoirUnResultatDuZoo(ligne : LongString);
var suite,timestamp,action : String255;
    params : MakeEndgameSearchParamRec;
begin

  // ligne := ReplaceStringOnce('<br>OK','',ligne);
  // ligne := ReplaceStringOnce('NO NEW RESULT','',ligne);

  // EnleveEspacesDeGaucheSurPlace(ligne);  // FIXEME : TEST THIS !!

  if LongStringIsEmpty(ligne) or LongStringBeginsWith('NO NEW RESULT', ligne)
    then exit(RecevoirUnResultatDuZoo);

  if PeutParserUnResultatDuZoo(ligne,params,action,suite,timestamp)
    then
      begin
        if (action = 'CALCULATED')   then MarquerLaRequeteDuZooCommeEtantCalculee(params,suite) else
        if (action = 'INCHARGE')     then MarquerLaRequeteDuZooCommeEtantEnCharge(params) else
        if (action = 'COULDNTSOLVE') then MarquerLaRequeteDuZooCommeNEtantPlusEnCharge(params) else
        if (action = 'PREFETCHED')   then MarquerLaRequeteDuZooCommeNEtantPlusEnCharge(params)
          else WritelnDansRapport('ASSERT : action inconnue dans RecevoirUnResultatDuZoo !');

        UpdateTimestampOfLastResultDuZoo(timeStamp);
      end
    else
      begin
        if (action = 'DELETED')
          then DoNothing
          else
            begin
              WritelnDansRapport('ASSERT : not(PeutParserUnResultatDuZoo) dans RecevoirUnResultatDuZoo !!!');
              WriteDansRapport('ligne = ');
              WritelnLongStringDansRapport(ligne);
            end;
      end;
end;



procedure CopierListeDesCoupsPourLeZoo(prof,nbCoups,couleur,hashCassio : SInt32; const liste : listeVides; const position : plateauOthello; alpha, beta : SInt32);
var i : SInt32;
begin
  if (prof >= 0) and (prof <= 64) then
  with liaisonArbreZoo.infosNoeuds[prof] do
    begin
      longueurListe    := nbCoups;
      trait            := couleur;
      positionPere     := position;
      hashCassioDuPere := hashCassio;
      alphaInitial     := alpha;
      betaInitial      := beta;

      for i := 1 to longueurListe do
        begin
          coupsFils[i].coup      := liste[i];
          coupsFils[i].theVal    := k_ZOO_NOT_INITIALIZED_VALUE;
          bestDef[i]             := 0;
          SetHashValueDuZoo(hashRequete[i] , k_ZOO_NOT_INITIALIZED_VALUE);
          hashCassioDesFils[i]   := BXOR(hashCassio , (IndiceHash^^[-couleur,liste[i]]));
          timeUsed[i]            := -1.0;
        end;
    end;
end;


function GetPositionApresCeFilsDuZoo(prof,whichMove : SInt32; var posResultante : PositionEtTraitRec) : boolean;
begin
  GetPositionApresCeFilsDuZoo := false;
  if (prof >= 0) and (prof <= 64) then
    with liaisonArbreZoo.infosNoeuds[prof] do
      begin

        posResultante := MakePositionEtTrait(positionPere,trait);

        if GetTraitOfPosition(posResultante) = trait
          then
            begin
              if UpdatePositionEtTrait(posResultante,whichMove)
                then GetPositionApresCeFilsDuZoo := true
                else WritelnDansRapport('ASSERT : not(UpdatePositionEtTrait()) dans GetPositionApresCeFilsDuZoo');
            end
          else
            begin
              WritelnDansRapport('ASSERT : GetTraitOfPosition() <> trait dans GetPositionApresCeFilsDuZoo');
            end;
      end;
end;


function FindFilsAvecCeHash(prof : SInt32; hash : UInt64; var numeroFils : SInt32) : boolean;
var k : SInt32;
begin

  if (prof >= 1) and (prof <= 64) then
    with liaisonArbreZoo.infosNoeuds[prof] do
      begin
        for k := 1 to longueurListe do
          if Same64Bits(hashRequete[k] , hash) then
            begin
              FindFilsAvecCeHash := true;
              numeroFils := k;
              exit(FindFilsAvecCeHash);
            end;
      end;

  FindFilsAvecCeHash := false;
  numeroFils := -1;
end;


function PasseApresCeFilsDuZoo(const paramsDuFils : MakeEndgameSearchParamRec) : boolean;
var profDuPere : SInt32;
begin
  profDuPere := paramsDuFils.inProfondeurFinale + 1;  {profondeur du pere}

  if (profDuPere < 0) and (profDuPere > 64)
    then PasseApresCeFilsDuZoo := false
    else PasseApresCeFilsDuZoo := (paramsDuFils.inCouleurFinale = liaisonArbreZoo.infosNoeuds[profDuPere].trait)
end;


function MakeSearchParamsPourCeFilsDuZoo(prof,alpha,beta,deltaFinal : SInt32; var thePos : PositionEtTraitRec; var params : MakeEndgameSearchParamRec) : boolean;
begin

  MakeSearchParamsPourCeFilsDuZoo := true;

  with params do
    begin
      if (alpha >= -1) and (beta <= 1)
        then inTypeCalculFinale                   := ReflGagnant
        else inTypeCalculFinale                   := ReflParfait;

      inCouleurFinale                      := GetTraitOfPosition(thePos);
      inNbreBlancsFinale                   := NbPionsDeCetteCouleurDansPosition(pionBlanc,thePos.position);
      inNbreNoirsFinale                    := NbPionsDeCetteCouleurDansPosition(pionNoir,thePos.position);
      inProfondeurFinale                   := 64 - inNbreNoirsFinale - inNbreBlancsFinale;

      (*
      WritelnDansRapport('Je traite le fils suivant dans MakeSearchParamsPourCeFilsDuZoo : ');
      WritelnPositionEtTraitDansRapport(thePos.position,GetTraitOfPosition(thePos));
      WritelnDansRapport('');
      *)


      if not(PasseApresCeFilsDuZoo(params))
        then
          begin
            // le trait s'inverse : c'est normal (pas de passe)
            inAlphaFinale                        := -beta;
            inBetaFinale                         := -alpha;

            {WritelnDansRapport('OK : trait s''inverse dans MakeSearchParamsPourCeFilsDuZoo');}
          end
        else
          begin
            // il semble y avoir un passe
            inAlphaFinale                        := alpha;
            inBetaFinale                         := beta;
            MakeSearchParamsPourCeFilsDuZoo := false;

            WritelnDansRapport('WARNING : passe dans MakeSearchParamsPourCeFilsDuZoo');
          end;

      inMuMinimumFinale                    := 0;
      inMuMaximumFinale                    := deltaFinal;
      inPrecisionFinale                    := MuStringEnPrecisionEngine('0,'+IntToStr(deltaFinal));
      inPrioriteFinale                     := 0;
      inGameTreeNodeFinale                 := NIL;
      inPositionPourFinale                 := thePos.position;
      inMessageHandleFinale                := NIL;
      inCommentairesDansRapportFinale      := false;
      inMettreLeScoreDansLaCourbeFinale    := false;
      inMettreLaSuiteDansLaPartie          := false;
      inDoitAbsolumentRamenerLaSuiteFinale := false;
      inDoitAbsolumentRamenerUnScoreFinale := true;
      SetHashValueDuZoo(inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);
      ViderSearchResults(outResult);

      CalculateHashOfSearchParams(params);


      if (inProfondeurFinale <> (prof - 1)) then
        begin
          MakeSearchParamsPourCeFilsDuZoo := false;

          WritelnDansRapport('ASSERT : inProfondeurFinale <> (prof - 1)  dans MakeSearchParamsPourCeFilsDuZoo');
          WritelnNumDansRapport('prof = ',prof);
          WritelnNumDansRapport('inProfondeurFinale = ',inProfondeurFinale);
        end;

    end;

end;


procedure EnvoyerCeFilsAuZoo(prof,whichMove,alpha,beta,deltaFinal : SInt32);
var k,valeur : SInt32;
    thePos : PositionEtTraitRec;
    params : MakeEndgameSearchParamRec;
begin

  if (prof < 0) and (prof > 64) then
    begin
      WritelnNumDansRapport('ASSERT : prof out of bounds dans EnvoyerCeFilsAuZoo,  prof = ',prof);
      exit(EnvoyerCeFilsAuZoo);
    end;

  if (whichMove < 11) and (whichMove > 88) then
    begin
      WritelnNumDansRapport('ASSERT : whichMove impossible dans EnvoyerCeFilsAuZoo  , whichMove = ',whichMove);
      exit(EnvoyerCeFilsAuZoo);
    end;


  with liaisonArbreZoo.infosNoeuds[prof] do
    begin
      for k := 1 to longueurListe do
        if (coupsFils[k].coup = whichMove) then  {trouvé !}
          begin

            valeur := coupsFils[k].theVal;

            if valeur <> k_ZOO_NOT_INITIALIZED_VALUE then
              WritelnNumDansRapport('ASSERT : valeur <> k_ZOO_NOT_INITIALIZED_VALUE dans EnvoyerCeFilsAuZoo,  valeur = ',valeur);


            if GetPositionApresCeFilsDuZoo(prof,whichMove,thePos) then
              begin

                if MakeSearchParamsPourCeFilsDuZoo(prof,alpha,beta,deltaFinal,thePos,params) and
                   AjouterDansLaListeDesRequetesDuZoo(params) then
                  begin

                    hashRequete[k]      := params.inHashValue;
                    coupsFils[k].theVal := k_ZOO_EN_ATTENTE_DE_RESULTAT;

                    (*
                    WriteNumDansRapport('// à prof ',prof);
                    WriteNumDansRapport(', hashPere = ',hashCassioDuPere);
                    WriteStringAndCoupDansRapport(', coup = ',whichMove);
                    WriteNumDansRapport(', hashRequete = ',hashRequete[k]);
                    WritelnNumDansRapport(' hashFils = ',hashCassioDesFils[k]);
                    *)

                    inc(nbCoupsEnvoyesAuZoo);
                    inc(liaisonArbreZoo.nbTotalPositionsEnvoyees);
                  end;
              end;

            exit(EnvoyerCeFilsAuZoo);
          end;

      WritelnDansRapport('ASSERT dans EnvoyerCeFilsAuZoo : should never happen !');
      WritelnNumDansRapport('prof = ', prof);
      WritelnNumDansRapport('whichMove = ', whichMove);
    end;
end;


function GetValeurZooDeCeFils(prof,whichMove : SInt32; var bestSuite : SInt32; var timeTaken : double) : SInt32;
var k : SInt32;
begin
  GetValeurZooDeCeFils := k_ZOO_NOT_INITIALIZED_VALUE;

  if (prof >= 0) and (prof <= 64) then
    with liaisonArbreZoo.infosNoeuds[prof] do
      begin
        if (longueurListe > 0) then
          for k := 1 to longueurListe do
            if coupsFils[k].coup = whichMove then  {trouvé !}
              begin

                bestSuite               := bestDef[k];
                GetValeurZooDeCeFils := coupsFils[k].theVal;
                timeTaken               := timeUsed[k];

                exit(GetValeurZooDeCeFils);
              end;
      end;
end;


procedure SetValeurZooDeCeFils(prof,whichMove,whichScore,bestSuite : SInt32; timeTaken : double);
var k : SInt32;
begin
  if (prof >= 0) and (prof <= 64) then
    with liaisonArbreZoo.infosNoeuds[prof] do
      begin
        if (longueurListe > 0) then
          for k := 1 to longueurListe do
            if coupsFils[k].coup = whichMove then  {trouvé !}
              begin

                coupsFils[k].theVal     := whichScore;
                bestDef[k]              := bestSuite;
                timeUsed[k]             := timeTaken;

                exit(SetValeurZooDeCeFils);
              end;
      end;
end;


procedure RetirerCeFilsDuZoo(prof,whichMove : SInt32);
var k : SInt32;
begin

  if (prof < 0) and (prof > 64) then
    begin
      WritelnNumDansRapport('ASSERT : prof out of bounds dans RetirerCeFilsDuZoo,  prof = ',prof);
      exit(RetirerCeFilsDuZoo);
    end;

  if (whichMove < 11) and (whichMove > 88) then
    begin
      WritelnNumDansRapport('ASSERT : whichMove impossible dans RetirerCeFilsDuZoo  , whichMove = ',whichMove);
      exit(RetirerCeFilsDuZoo);
    end;

  (*
  WriteNumDansRapport('p = ',prof);
  WritelnStringAndCoupDansRapport(', j''essaye de retirer ce fils du zoo : ',whichMove);
  *)

  with liaisonArbreZoo do
    begin
       if (prof >= 0) and (prof <= 64) and
          (prof >= profMinUtilisationZoo) and (prof <= profMaxUtilisationZoo) then
          with infosNoeuds[prof] do
            begin

              for k := 1 to longueurListe do
                if (coupsFils[k].coup = whichMove) and  { trouvé ! }
                   (coupsFils[k].theVal <> k_ZOO_NOT_INITIALIZED_VALUE) then
                  begin

                    EnvoyerUneRequetePourArreterUnCalculDuZoo(hashRequete[k]);
                    RetirerDeLaListeDesRequetesDuZoo(hashRequete[k]);

                    (*
                    WriteNumDansRapport('p = ',prof);
                    WritelnStringAndCoupDansRapport(', requete envoyée pour retirer le fils ',whichMove);
                    *)

                    coupsFils[k].theVal   := k_ZOO_NOT_INITIALIZED_VALUE;
                    bestDef[k]            := 0;
                    timeUsed[k]           := -1.0;

                    dec(nbCoupsEnvoyesAuZoo);

                    exit(RetirerCeFilsDuZoo);
                  end;

            end
    end;
end;


procedure CassioPrendEnChargeLuiMemeCeFilsDuZoo(prof,whichMove : SInt32);
var k : SInt32;
    s : String255;
begin

  if (prof < 0) and (prof > 64) then
    begin
      WritelnNumDansRapport('ASSERT : prof out of bounds dans CassioPrendEnChargeLuiMemeCeFilsDuZoo,  prof = ',prof);
      exit(CassioPrendEnChargeLuiMemeCeFilsDuZoo);
    end;

  if (whichMove < 11) and (whichMove > 88) then
    begin
      WritelnNumDansRapport('ASSERT : whichMove impossible dans CassioPrendEnChargeLuiMemeCeFilsDuZoo  , whichMove = ',whichMove);
      exit(CassioPrendEnChargeLuiMemeCeFilsDuZoo);
    end;

  {
  WriteNumDansRapport('p = ',prof);
  WritelnStringAndCoupDansRapport(', je prends moi-meme ce fils le zoo : ',whichMove);
  }

  with liaisonArbreZoo do
    begin
       if (prof >= 0) and (prof <= 64) and
          (prof >= profMinUtilisationZoo) and (prof <= profMaxUtilisationZoo) then
          with infosNoeuds[prof] do
            begin

              for k := 1 to longueurListe do
                if (coupsFils[k].coup = whichMove) and  { trouvé ! }
                   (coupsFils[k].theVal = k_ZOO_EN_ATTENTE_DE_RESULTAT) then
                  begin

                    s := '&hash=' + UInt64ToHexa(hashRequete[k]);

                    EnvoyerUneRequetePourPrendreMoiMemeUnCalculDuZoo(s);


                    {WriteNumDansRapport('p = ',prof);
                    WritelnStringAndCoupDansRapport(', requete envoyée pour prendre en charge mon fils ',whichMove);
                    }

                    exit(CassioPrendEnChargeLuiMemeCeFilsDuZoo);

                  end;

            end
    end;
end;




procedure DetruireListeDesCoupsPourLeZoo(prof : SInt32);
var k : SInt32;
begin

  with liaisonArbreZoo do
    begin
       if (prof >= 0) and (prof <= 64) and
          (prof >= profMinUtilisationZoo) and (prof <= profMaxUtilisationZoo) then
          with infosNoeuds[prof] do
            begin

              for k := 1 to longueurListe do
                begin
                  coupsFils[k].coup     := 0;
                  coupsFils[k].theVal   := k_ZOO_NOT_INITIALIZED_VALUE;
                  bestDef[k]            := 0;
                  SetHashValueDuZoo(hashRequete[k] , k_ZOO_NOT_INITIALIZED_VALUE);
                  hashCassioDesFils[k]  := k_ZOO_NOT_INITIALIZED_VALUE;
                  timeUsed[k]           := -1.0;
                end;

              longueurListe           := 0;
              nbCoupsEnvoyesAuZoo := 0;
              trait                   := pionVide;
              hashCassioDuPere        := k_ZOO_NOT_INITIALIZED_VALUE;

            end;
    end;

end;


procedure NettoyerInfosDuZooPourCetteProf(prof : SInt32);
var k,nbFilsToDelete : SInt32;
    s : String255;
begin


  with liaisonArbreZoo do
    begin
       if (prof >= 0) and (prof <= 64) and
          (prof >= profMinUtilisationZoo) and (prof <= profMaxUtilisationZoo) then
          with infosNoeuds[prof] do
            begin


              // premiere chose a faire : envoyer au zoo une requete groupee
              // pour arreter tous les fils dont on attend une reponse du zoo

              nbFilsToDelete := 0;
              s := '';
              for k := 1 to longueurListe do
                if (coupsFils[k].theVal <> k_ZOO_NOT_INITIALIZED_VALUE) then
                  begin
                    inc(nbFilsToDelete);
                    if (nbFilsToDelete = 1)
                      then s := s + '&hash='                                 + UInt64ToHexa(hashRequete[k])
                      else s := s + '&h' + IntToStr(nbFilsToDelete) + '=' + UInt64ToHexa(hashRequete[k]);

                    if (nbFilsToDelete >= 11) then
                      begin
                        EnvoyerUneRequetePourArreterDesCalculsDuZoo(s);
                        nbFilsToDelete := 0;
                        s := '';
                      end;

                    RetirerDeLaListeDesRequetesDuZoo(hashRequete[k]);
                  end;

              if (nbFilsToDelete > 0) then
                begin
                  EnvoyerUneRequetePourArreterDesCalculsDuZoo(s);
                  nbFilsToDelete := 0;
                  s := '';
                end;


              // deuxieme chose a faire : detruire la liste de ce noeud dans les infos
              // de liaison arbre <-> Zoo

              DetruireListeDesCoupsPourLeZoo(prof);

            end;
    end;


end;


function ListeDesCoupsEstDejaDansLesInfosDuZooPourCetteProf(prof : SInt32) : boolean;
begin

  Discard(prof);

  WritelnDansRapport('FIXME : ListeDesCoupsEstDejaDansLesInfosDuZooPourCetteProf is not implemented');

  ListeDesCoupsEstDejaDansLesInfosDuZooPourCetteProf := false;
end;


function GetNombreDeFilsParallelisesPourCetteProf(prof : SInt32) : SInt32;
begin

  GetNombreDeFilsParallelisesPourCetteProf := 0;

  with liaisonArbreZoo do
    if (prof >= 0) and (prof <= 64) and
       (prof >= profMinUtilisationZoo) and (prof <= profMaxUtilisationZoo)
      then GetNombreDeFilsParallelisesPourCetteProf := infosNoeuds[prof].nbCoupsEnvoyesAuZoo;

end;



procedure ResetTraceExecutionFinale;
var vides : SInt32;
begin
  for vides := 0 to 64 do
    begin
      gTraceExecutionDeFinale.theTrace[vides].hashCassio := -1;
      gTraceExecutionDeFinale.theTrace[vides].coup       := -1;
    end;
end;


procedure RecordTraceExecutionFinale(prof, hashCassio, coup : SInt32);
begin
  if (prof >= 0) and (prof <= 64)
    then
      begin
        gTraceExecutionDeFinale.theTrace[prof].hashCassio := hashCassio;
        gTraceExecutionDeFinale.theTrace[prof].coup       := coup;
      end
    else WritelnNumDansRapport('ASSERT : prof out of bound dans RecordTraceExecutionFinale,  prof = ',prof);
end;


procedure EffacerTraceExecutionFinale(prof : SInt32);
begin
  RecordTraceExecutionFinale(prof, -1, -1);
end;


function PositionEstDansLaTraceExecutionFinale(prof, hashCassio : SInt32) : boolean;
begin
   if (prof >= 0) and (prof <= 64)
     then
       PositionEstDansLaTraceExecutionFinale := (hashCassio = gTraceExecutionDeFinale.theTrace[prof].hashCassio)
     else
       begin
         WritelnNumDansRapport('ASSERT : prof out of bound dans PositionEstDansLaTraceExecutionFinale,  prof = ',prof);
         PositionEstDansLaTraceExecutionFinale := false;
       end;
end;



function CeFilsEstDansLaTraceExecutionFinale(profPere, hashCassioDuPere, coupFils : SInt32) : boolean;
begin
   if (profPere >= 1) and (profPere <= 64)
     then
       CeFilsEstDansLaTraceExecutionFinale := (gTraceExecutionDeFinale.theTrace[profPere].hashCassio = hashCassioDuPere) and
                                              (gTraceExecutionDeFinale.theTrace[profPere - 1].coup   = coupFils)
     else
       begin
         WritelnNumDansRapport('ASSERT : profPere out of bound dans CeFilsEstDansLaTraceExecutionFinale,  profPere = ',profPere);
         CeFilsEstDansLaTraceExecutionFinale := false;
       end;
end;


function HashCassioEstDansLesTracesExecutionAStopper(whichHash : SInt32; var whichProf : SInt32) : boolean;
var k : SInt32;
begin

  if (whichHash >= 0) then
    with gTraceExecutionDeFinale.arrets do
      begin
        for k := 1 to cardinal do
          if descr[k].hashCassio = whichHash then  {trouvé !}
            begin
              whichProf := descr[k].profDuFils;
              HashCassioEstDansLesTracesExecutionAStopper := true;
              exit(HashCassioEstDansLesTracesExecutionAStopper);
            end;
      end;

  HashCassioEstDansLesTracesExecutionAStopper := false;
  whichProf := -1;
end;


function DoitStopperExecutionDeCeSousArbre(prof : SInt32) : boolean;
var k,hash : SInt32;
    profStoppee : SInt32;
    doitAfficher : boolean;
    traceTraversee : boolean;
begin

  if (gTraceExecutionDeFinale.arrets.cardinal <= 0) then
    begin
      DoitStopperExecutionDeCeSousArbre := false;
      exit(DoitStopperExecutionDeCeSousArbre);
    end;

  traceTraversee := false;
  doitAfficher := false;

  for k := prof to 64 do
    begin
      hash := gTraceExecutionDeFinale.theTrace[k].hashCassio;

      if hash >= 0
        then
          begin
            traceTraversee := true;
            if HashCassioEstDansLesTracesExecutionAStopper(hash,profStoppee) then
              begin
                {WriteNumDansRapport('p = ',prof);
                WritelnNumDansRapport(' : arret demandé à prof ',k);
                }
                DoitStopperExecutionDeCeSousArbre := true;
                exit(DoitStopperExecutionDeCeSousArbre);
              end;
          end
        else
          begin
            if traceTraversee then
              begin
                doitAfficher := true;
                DoitStopperExecutionDeCeSousArbre := false;
                exit(DoitStopperExecutionDeCeSousArbre);
              end;
          end;
    end;

  if doitAfficher or (gTraceExecutionDeFinale.arrets.cardinal > 0) then
    begin

      for k := 1 to gTraceExecutionDeFinale.arrets.cardinal do
        begin
          WritelnNumDansRapport('descr[k].hashCassio = ',gTraceExecutionDeFinale.arrets.descr[k].hashCassio);
          WritelnNumDansRapport('descr[k].hashDuPere = ',gTraceExecutionDeFinale.arrets.descr[k].hashDuPere);
          WritelnNumDansRapport('descr[k].profDuFils = ',gTraceExecutionDeFinale.arrets.descr[k].profDuFils);
          WritelnStringAndCoupDansRapport('descr[k].coupDuFils = ',gTraceExecutionDeFinale.arrets.descr[k].coupDuFils);
          WritelnDansRapport('');
        end;

      WritelnNumDansRapport('prof = ',prof);

      for k := 0 to 64 do
        begin
          hash := gTraceExecutionDeFinale.theTrace[k].hashCassio;

          WriteNumDansRapport('p = ',k);
          WriteNumDansRapport(' trace = ',hash);
          WritelnStringAndBoolDansRapport(' stop = ',HashCassioEstDansLesTracesExecutionAStopper(hash,profStoppee));

        end;
      WritelnDansRapport('');
    end;

  DoitStopperExecutionDeCeSousArbre := false;
end;



function OnVientDeStoperExecutionDeCeFils(profPere,coupFils : SInt32; var numeroArret : SInt32) : boolean;
var hashPere, k : SInt32;
begin
  if (profPere >= 1) and (profPere <= 64) and (coupFils >= 11) and (coupFils <= 88) then
    with gTraceExecutionDeFinale do
      begin
        hashPere := theTrace[profPere].hashCassio;

        for k := 1 to arrets.cardinal do
          begin
            if (arrets.descr[k].hashDuPere = hashPere) and
               (arrets.descr[k].profDuFils = profPere - 1) and
               (arrets.descr[k].coupDuFils = coupFils) then
              begin
                OnVientDeStoperExecutionDeCeFils := true;
                numeroArret := k;
                exit(OnVientDeStoperExecutionDeCeFils);
              end;
          end;
      end;

  OnVientDeStoperExecutionDeCeFils := false;
  numeroArret := -1;
end;





procedure RetirerDeLaListeDesTracesExecutionAStopperParNumeroArret(numeroArret : SInt32);
var j : SInt32;
begin
  with gTraceExecutionDeFinale.arrets do
    if (numeroArret >= 1) and (numeroArret <= cardinal) then
      begin

        for j := numeroArret + 1 to cardinal do
          begin
            descr[j - 1].hashCassio        := descr[j].hashCassio;
            descr[j - 1].hashDuPere        := descr[j].hashDuPere;
            descr[j - 1].profDuFils        := descr[j].profDuFils;
            descr[j - 1].coupDuFils        := descr[j].coupDuFils;
            descr[j - 1].estUneCoupureBeta := descr[j].estUneCoupureBeta;
          end;

        descr[cardinal].hashCassio         := -1;
        descr[cardinal].hashDuPere         := -1;
        descr[cardinal].profDuFils         := -1;
        descr[cardinal].coupDuFils         := -1;
        descr[cardinal].estUneCoupureBeta  := false;

        dec(cardinal);
      end;
end;


procedure RetirerDeLaListeDesTracesExecutionAStopper(hashFils : SInt32);
var k : SInt32;
begin
  if (hashFils >= 0) then
    with gTraceExecutionDeFinale.arrets do
      begin
        for k := 1 to cardinal do
          if descr[k].hashCassio = hashFils then  {trouvé !}
            begin
              RetirerDeLaListeDesTracesExecutionAStopperParNumeroArret(k);
              exit(RetirerDeLaListeDesTracesExecutionAStopper);
            end;
      end;
end;


procedure AjouterDansLaListeDesTracesExecutionAStopper(prof : SInt32);
var hashCassioAArreter : SInt32;
    hashCassioDuPere : SInt32;
    coupFils : SInt32;
    foo : SInt32;
begin

  {WritelnNumDansRapport('       Je dois arreter les calculs jusqu''a la profondeur (du fils) ',prof);}

  if (prof < 0) or (prof > 64) then
    exit(AjouterDansLaListeDesTracesExecutionAStopper);

  with gTraceExecutionDeFinale.arrets do
    begin
      if (cardinal < 64) then
        begin
          hashCassioDuPere   := gTraceExecutionDeFinale.theTrace[prof + 1].hashCassio;
          hashCassioAArreter := gTraceExecutionDeFinale.theTrace[prof].hashCassio;
          coupFils           := gTraceExecutionDeFinale.theTrace[prof].coup;

          if (hashCassioAArreter >= 0) then
            if not(HashCassioEstDansLesTracesExecutionAStopper(hashCassioAArreter,foo)) then
              begin
                inc(cardinal);

                descr[cardinal].hashDuPere := hashCassioDuPere;
                descr[cardinal].hashCassio := hashCassioAArreter;
                descr[cardinal].profDuFils := prof;
                descr[cardinal].coupDuFils := coupFils;

                {WritelnNumDansRapport('gTraceExecutionDeFinale.arrets.cardinal = ',gTraceExecutionDeFinale.arrets.cardinal);}

              end;
        end;
    end;
end;





END.



(*

coeffs a tester :

  a) margePourParallelismeAlphaSpeculatif (distance a alpha dans InitialiserInfosPourLeZooDeCeNoeud)

  b) tempsMinimalPourEnvoyerAuZoo

  c) tempsMaximalPourEnvoyerAuZoo

  d) facteur de dilatation dans VerifierLeParallelismeDuZoo

  e) profMinUtilisationZoo

  f) occupationPourParallelismeAlpha2

  g) autres deltas de finale (sans mu = 11 ? sans mu = 17 ? sans mu = 4 ?)

  h) profMinUtilisationZoo

  i) margePourParallelismeHeuristique

  k) appel recursif dans EssayerDeParalliserCesFilsSurLeZoo


*)

































