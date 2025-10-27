UNIT UnitTestGraphe;


INTERFACE





procedure TestApprentissage;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, UnitDefCassio
{$IFC NOT(USE_PRELINK)}
    , UnitRapportImplementation, UnitRapport, MyStrings, UnitFenetres, MyMathUtils, UnitEntreesSortiesGraphe
    , UnitRapportWindow, UnitAccesGraphe, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/TestGraphe.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure TestApprentissage;
var cell : CelluleRec;
    i : SInt32;
    fic : Graphe;
    grapheDejaOuvertALArrivee : boolean;
begin
  if not(GrapheApprentissageExiste(nomGrapheApprentissage,fic,grapheDejaOuvertALArrivee))
    then CreeGrapheApprentissage(nomGrapheApprentissage,fic)
    else if FermeGrapheApprentissage(fic) then DoNothing;

  if GrapheApprentissageExiste(nomGrapheApprentissage,fic,grapheDejaOuvertALArrivee) then
    begin

      if not(FenetreRapportEstOuverte) then OuvreFntrRapport(false,true);
      if FenetreRapportEstOuverte then SelectWindowSousPalette(GetRapportWindow);

      debuggage.apprentissage := false;


     {VideGrapheApprentissage(fic);
      CreeCelluleRacine(fic);
      EnleveFausseInterversion(fic,'F5D6C3F4E6F6C6E3','F5F6E6F4C3D6F3C5');
      EnleveFausseInterversion(fic,'F5D6C3F4E6F6C6C5','F5F6E6F4C3D6F3E3');
      EnleveFausseInterversion(fic,'F5F6E6F4E3C5G5F3G4D3G6H4F2G3E2','F5F6E6F4E3C5G5G3G4F3G6D3F2H4E2');
      EnleveFausseInterversion(fic,'F5D6C3D3C4F4F6F3G4G3C5B3C6H4C2','F5D6C3D3C4F4F6F3G4G3C5B3C2H4C6');
     }
      {AjouterToutesLesInterversionsConnues(fic);}

      WritelnDansRapport('Le graphe contient '+IntToStr(NbrePositionsDansGrapheApprentissage(fic))+' positions');

      VerifieIntegriteGraphe(fic);

      for i := 1 to Min(NbrePositionsDansGrapheApprentissage(fic),200) do
        begin
          LitCellule(fic,i,cell);
          AfficheCelluleDansRapport(fic,i,cell);
        end;

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fic) then DoNothing;
    end;
end;


END.
