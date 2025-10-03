UNIT UnitTore;

INTERFACE







 USES UnitDefCassio;

function PeutJouerIciTore(couleur,a : SInt32; var plat : plateauOthello) : boolean;                                                                                                 ATTRIBUTE_NAME('PeutJouerIciTore')
function DoitPasserTore(coul : SInt32; var plat : plateauOthello) : boolean;                                                                                                        ATTRIBUTE_NAME('DoitPasserTore')
procedure CarteMoveTore(coul : SInt32; const plat : plateauOthello; var carte : plBool; var mobilite : SInt32);                                                                     ATTRIBUTE_NAME('CarteMoveTore')
function ModifPlatTore(a,coul : SInt32; var jeu : plateauOthello; var nbbl,nbno : SInt32) : boolean;                                                                                ATTRIBUTE_NAME('ModifPlatTore')
function EvaluationTore({var plat : plateauOthello;}coul,nbBlc,nbNr : SInt32) : SInt32;                                                                                             ATTRIBUTE_NAME('EvaluationTore')


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesMemoire ;
{$ELSEC}
    {$I prelink/Tore.lk}
{$ENDC}


{END_USE_CLAUSE}












function PeutJouerIciTore(couleur,a : SInt32; var plat : plateauOthello) : boolean;
var x,dx,t,Xcase,Ycase : SInt32;
    pionEnnemi : SInt32;
    aux : boolean;
begin
 PeutJouerIciTore := false;
 if plat[a] = pionVide
   then begin
   pionEnnemi := -couleur;
   for t := 1 to 8 do
     begin
       dx := dirPrise[t];
       aux := false;
       x := a+dx;
       if plat[x] = PionInterdit then
           begin
             Xcase := x mod 10;
             Ycase := x div 10;
             if Xcase = 0
                then x := x+8
                else if Xcase = 9 then x := x-8;
             if Ycase = 0
                then x := x+80
                else if Ycase = 9 then x := x-80;
           end;
       while (plat[x] = pionEnnemi) do
         begin
           aux := true;
           x := x+dx;
           if plat[x] = PionInterdit then
           begin
             Xcase := x mod 10;
             Ycase := x div 10;
             if Xcase = 0
                then x := x+8
                else if Xcase = 9 then x := x-8;
             if Ycase = 0
                then x := x+80
                else if Ycase = 9 then x := x-80;
           end;
         end;
       if (plat[x] = couleur) and aux then
       begin
         PeutJouerIciTore := true;
         exit(PeutJouerIciTore)
       end;
    end;
  end;
end;

function DoitPasserTore(coul : SInt32; var plat : plateauOthello) : boolean;
var x,t : SInt32;
begin
   DoitPasserTore := true;
   for t := 1 to 64 do
   begin
    x := othellier[t];
     if plat[x] = pionVide then
     if PeutJouerIciTore(coul,x,plat) then
       begin
         DoitPasserTore := false;
         exit(DoitPasserTore);
       end;
   end;
end;


{ CarteMoveTore etablit les endroits où une couleur peut jouer
 et place le resultat dans carte}
procedure CarteMoveTore(coul : SInt32; const plat : plateauOthello; var carte : plBool; var mobilite : SInt32);
var x,t : SInt32;
    jeu : plateauOthello;
begin
   jeu := plat;
   MemoryFillChar(@carte,sizeof(carte),chr(0));
   mobilite := 0;
   if (coul <> pionVide) then
     for t := 1 to 64 do
       begin
         x := othellier[t];
         if jeu[x] = pionVide then
         begin
            carte[x] := PeutJouerIciTore(coul,x,jeu);
            if carte[x] then inc(mobilite);
         end;
       end;
end;


function ModifPlatTore(a,coul : SInt32; var jeu : plateauOthello; var nbbl,nbno : SInt32) : boolean;
var x,dx,t,nbprise,jeuDeX : SInt32;
    pionEnnemi,compteur,XCase,Ycase : SInt32;
    modifie : boolean;
    retournement : array[0..8] of boolean;
begin
   MemoryFillChar(@retournement,sizeof(retournement),chr(0));
   modifie := false;
   nbprise := 0;
   pionEnnemi := -coul;
   if jeu[a] = pionVide then
   begin
   for t := 1 to 8 do
     begin
         dx := dirPrise[t];
         compteur := 0;
         x := a+dx;
         if jeu[x] = PionInterdit then
           begin
             Xcase := x mod 10;
             Ycase := x div 10;
             if Xcase = 0
                then x := x+8
                else if Xcase = 9 then x := x-8;
             if Ycase = 0
                then x := x+80
                else if Ycase = 9 then x := x-80;
           end;
         jeudeX := jeu[x];
         while jeudeX = pionEnnemi do
            begin
               inc(compteur);
               x := x+dx;
               jeudeX := jeu[x];
               if jeuDeX = PionInterdit then
                 begin
                   Xcase := x mod 10;
                   Ycase := x div 10;
                   if Xcase = 0
                      then x := x+8
                      else if Xcase = 9 then x := x-8;
                   if Ycase = 0
                      then x := x+80
                      else if Ycase = 9 then x := x-80;
                   jeudeX := jeu[x];
                 end;
            end;
         if (jeu[x] = coul) and (compteur <> 0) then
         begin
            modifie := true;
            retournement[t] := true;
            nbprise := nbprise+compteur;
         end;
      end;
   if modifie then
     begin
       inc(nbreNoeudsGeneresMilieu);
       jeu[a] := coul;
       if coul = pionNoir {valeurtact etabli pour Noir}
         then begin
             nbNo := nbNo+nbprise+1;
             nbbl := nbbl-nbprise;
           end
         else begin
             nbNo := nbNo-nbprise;
             nbbl := nbbl+nbprise+1;
           end;
       for t := 1 to 8 do
         if retournement[t] then
           begin
            dx := dirPrise[t];
            x := a+dx;
            if jeu[x] = PionInterdit then
                begin
                  Xcase := x mod 10;
                  Ycase := x div 10;
                  if Xcase = 0
                     then x := x+8
                     else if Xcase = 9 then x := x-8;
                  if Ycase = 0
                     then x := x+80
                     else if Ycase = 9 then x := x-80;
                end;
            repeat
              jeu[x] := coul;
              x := x+dx;
              if jeu[x] = PionInterdit then
                begin
                  Xcase := x mod 10;
                  Ycase := x div 10;
                  if Xcase = 0
                     then x := x+8
                     else if Xcase = 9 then x := x-8;
                  if Ycase = 0
                     then x := x+80
                     else if Ycase = 9 then x := x-80;
                end;
            until jeu[x] <> pionennemi;
           end;
     end;
   end;
  ModifPlatTore := modifie;
end;

function EvaluationTore({var plat : plateauOthello;}coul,nbBlc,nbNr : SInt32) : SInt32;
begin
  if phaseDeLaPartie >= phaseFinale
   then
     begin
      if coul = pionBlanc
        then EvaluationTore := nbBlc-nbNr
        else EvaluationTore := nbNr-nbBlc;
     end
    else
     begin
       if coul = pionNoir
        then EvaluationTore := nbBlc-nbNr
        else EvaluationTore := nbNr-nbBlc;
       if (coul = pionNoir) and (nbNr = 0) then EvaluationTore := -1000;
       if (coul = pionBlanc) and (nbBlc = 0) then EvaluationTore := -1000;
     end
end;


END.
