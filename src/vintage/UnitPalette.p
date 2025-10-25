UNIT UnitPalette;


INTERFACE


 USES UnitDefCassio;


const BWPalettePictID = 133;
      BWSablierDeboutPictID = 134;
      BWSablierRenversePictID = 135;
      BWSonPictID = 136;

      CPalettePictID = 138;

procedure FlashCasePalette(nroaction : SInt16);
procedure DessineCasePaletteCouleur(nroAction : SInt16; enfoncee : boolean);
procedure DessineIconesChangeantes;
procedure DessinePalette;

procedure GetRectDansPalette(action : SInt16; var RectAction : rect);
procedure DrawColorPICT(pictID : SInt16; inRect : rect);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    QuickDraw, Sound, Resources, OSUtils
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitCarbonisation ;
{$ELSEC}
    ;
    {$I prelink/Palette.lk}
{$ENDC}


{END_USE_CLAUSE}













procedure GetRectDansPalette(action : SInt16; var RectAction : rect);
var oldport : grafPtr;
    i,j : SInt16;
begin
  if windowPaletteOpen and (wPalettePtr <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wPalettePtr);
      i := ((action-1) mod 9)+1;
      j := ((action-1) div 9)+1;
      SetRect(RectAction,(i-1)*largeurCasePalette,
                         (j-1)*hauteurCasePalette,
                         i*largeurCasePalette -1,
                         j*HauteurCasePalette -1);
      LocalToGlobal(RectAction.topleft);
      LocalToGlobal(RectAction.botright);
      SetPort(oldport);
    end;
end;


function PictIDPalette(nroAction : SInt16; enfoncee : boolean) : SInt16;
begin
  case nroAction of
    PaletteRetourDebut    : if enfoncee then PictIDPalette := 158 else PictIDPalette := 139;
    PaletteDoubleBack     : if enfoncee then PictIDPalette := 159 else PictIDPalette := 140;
    PaletteBack           : if enfoncee then PictIDPalette := 160 else PictIDPalette := 141;
    PaletteForward        : if enfoncee then PictIDPalette := 161 else PictIDPalette := 142;
    PaletteDoubleForward  : if enfoncee then PictIDPalette := 162 else PictIDPalette := 143;
    PaletteAllerFin       : if enfoncee then PictIDPalette := 163 else PictIDPalette := 144;
    PaletteCoupPartieSel  : if enfoncee then PictIDPalette := 164 else PictIDPalette := 145;
    PaletteCouleur        : {if HumCtreHum
                              then if enfoncee then PictIDPalette := 167 else PictIDPalette := 148
                              else }
                                if couleurMacintosh = pionBlanc
                                  then if enfoncee then PictIDPalette := 182 else PictIDPalette := 180
                                  else if enfoncee then PictIDPalette := 183 else PictIDPalette := 181;
    PaletteSablier        : if HumCtreHum
                              then if enfoncee then PictIDPalette := 169 else PictIDPalette := 150
                              else if enfoncee then PictIDPalette := 168 else PictIDPalette := 149;
    PaletteInterrogation  : if enfoncee then PictIDPalette := 170 else PictIDPalette := 151;
    PaletteHorloge        : if enfoncee then PictIDPalette := 171 else PictIDPalette := 152;
    PaletteDiagramme      : if enfoncee then PictIDPalette := 173 else PictIDPalette := 154;
    PaletteBase           : if enfoncee then PictIDPalette := 174 else PictIDPalette := 155;
    PaletteSon            : if avecSon
                              then if enfoncee then PictIDPalette := 179 else PictIDPalette := 178
                              else if enfoncee then PictIDPalette := 172 else PictIDPalette := 153;
    PaletteCourbe         : if enfoncee then PictIDPalette := 175 else PictIDPalette := 156;
    PaletteStatistique    : if enfoncee then PictIDPalette := 176 else PictIDPalette := 157;
    PaletteReflexion      : if enfoncee then PictIDPalette := 165 else PictIDPalette := 146;
    PaletteListe          : if enfoncee then PictIDPalette := 166 else PictIDPalette := 147;

  end;
end;




procedure FlashCasePalette(nroaction : SInt16);
  const attente = 8;
  var tick : SInt32;
      unRect : rect;
      oldPort : grafPtr;
      CaseXPalette,CaseYPalette : SInt16;
      UnePicture : PicHandle;

begin
  GetPort(oldPort);
  SetPortByWindow(wPalettePtr);
  CaseXPalette := (nroaction-1) mod 9 + 1;
  CaseYPalette := (nroaction-1) div 9 + 1;
  if gBlackAndWhite
    then
      begin
        SetRect(unRect,(CaseXPalette-1)*largeurCasePalette,
                       (CaseYPalette-1)*hauteurCasePalette,
                        CaseXPalette*largeurCasePalette -1,
                        CaseYPalette*HauteurCasePalette -1);
        InvertRect(unRect);
        tick := TickCount;
        while TickCount-tick < attente do DoNothing;
        InvertRect(unRect);
      end
    else
      begin
        UnePicture := MyGetPicture(PictIDPalette(nroAction,true));
        unRect := GetPicFrameOfPicture(UnePicture);
        OffsetRect(unRect,LargeurCasePalette*(CaseXPalette-1)-1,HauteurCasePalette*(CaseYPalette-1)-1);
        DrawPicture(UnePicture,unRect);
        ReleaseResource(Handle(UnePicture));
        tick := TickCount;
        while TickCount-tick < attente do DoNothing;
        UnePicture := MyGetPicture(PictIDPalette(nroAction,false));
        DrawPicture(UnePicture,unRect);
        ReleaseResource(Handle(UnePicture));
      end;
  SetPort(oldPort);
end;

procedure DessineCasePaletteCouleur(nroAction : SInt16; enfoncee : boolean);
var unRect : rect;
    oldPort : grafPtr;
    CaseXPalette,CaseYPalette : SInt16;
    UnePicture : PicHandle;
begin
  GetPort(oldPort);
  SetPortByWindow(wPalettePtr);
  CaseXPalette := (nroaction-1) mod 9 + 1;
  CaseYPalette := (nroaction-1) div 9 + 1;
  UnePicture := MyGetPicture(PictIDPalette(nroAction,enfoncee));
  unRect := GetPicFrameOfPicture(UnePicture);
  OffsetRect(unRect,LargeurCasePalette*(CaseXPalette-1)-1,HauteurCasePalette*(CaseYPalette-1)-1);
  DrawPicture(UnePicture,unRect);
  ReleaseResource(Handle(UnePicture));
  SetPort(oldPort);
end;










procedure DrawColorPICT(pictID : SInt16; inRect : rect);
var UnePicture : PicHandle;
begin
  UnePicture := MyGetPicture(pictID);
  DrawPicture(UnePicture,inRect);
  ReleaseResource(Handle(UnePicture));
end;

procedure DessineIconesChangeantes;
var unRect : rect;
    UnePicture : PicHandle;
    oldPort : grafPtr;
    rayon,a,b : SInt16;
begin
  if windowPaletteOpen and (wPalettePtr <> NIL) then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPalettePtr);
      rayon := 6;
      a := LargeurCasePalette div 2 ;
      b := HauteurCasePalette+HauteurCasePalette div 2;
      SetRect(unRect,a-rayon,b-rayon,a+rayon,b+rayon);
      if not(gBlackAndWhite)
        then
          DessineCasePaletteCouleur(PaletteCouleur,false)
        else
          if couleurMacintosh = pionNoir
            then FillOval(unRect,blackPattern)
            else
               begin
                 FrameOval(unRect);
                 InsetRect(unRect,1,1);
                 EraseOval(unRect);
               end;

      if HumCtreHum
       then
        begin
          SablierDessineEstRenverse := true;
          if gBlackAndWhite
            then
              begin
                UnePicture := MyGetPicture(BWSablierRenversePictID);
                unRect := GetPicFrameOfPicture(UnePicture);
                OffsetRect(unRect,LargeurCasePalette,HauteurCasePalette);
                DrawPicture(UnePicture,unRect);
                ReleaseResource(Handle(UnePicture));
              end
            else
              DessineCasePaletteCouleur(PaletteSablier,false);
        end
       else
        begin
          if gBlackAndWhite
            then
              begin
                SablierDessineEstRenverse := false;
                UnePicture := MyGetPicture(BWSablierDeboutPictID);
                unRect := GetPicFrameOfPicture(UnePicture);
                OffsetRect(unRect,LargeurCasePalette,HauteurCasePalette);
                DrawPicture(UnePicture,unRect);
                ReleaseResource(Handle(UnePicture));
              end
            else
              DessineCasePaletteCouleur(PaletteSablier,false);
        end;

      if not(gBlackAndWhite)
        then DessineCasePaletteCouleur(PaletteSon,false)
        else
         if avecSon
          then
           begin
             UnePicture := MyGetPicture(BWSonPictID);
             unRect := GetPicFrameOfPicture(UnePicture);
             OffsetRect(unRect,4*LargeurCasePalette+LargeurCasePalette div 2+1,HauteurCasePalette+2);
             DrawPicture(UnePicture,unRect);
             ReleaseResource(Handle(UnePicture));
           end
          else
           begin
             SetRect(unRect,4*LargeurCasePalette+LargeurCasePalette div 2+1,HauteurCasePalette+2,
                            5*LargeurCasePalette-2,HauteurCasePalette+16);
             MyEraseRect(unRect);
             MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
           end;

      SetPort(oldPort);
    end;
end;

procedure DessinePalette;
var oldPort : grafPtr;
    structRect : rect;
    palettePicture : PicHandle;
begin
  if windowPaletteOpen and (wPalettePtr <> NIL) then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPalettePtr);

      if gBlackAndWhite
        then palettePicture := MyGetPicture(BWPalettePictID)
        else palettePicture := MyGetPicture(CPalettePictID);
      structRect := GetPicFrameOfPicture(palettePicture);
      OffsetRect(structRect,-1,-1);
      DrawPicture(palettePicture,structRect);
      ReleaseResource(Handle(palettePicture));

      DessineIconesChangeantes;


      {bidbool := WaitNextEvent(EveryEvent,theEvent,2,NIL);
      FlushWindow(wPalettePtr);
      Sysbeep(0);
      Attendfrappeclavier;}

      ValidRect(GetWindowPortRect(wPalettePtr));
      SetPort(oldPort);
    end;
end;




END.
