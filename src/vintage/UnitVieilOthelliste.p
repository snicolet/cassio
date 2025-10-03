UNIT UnitVieilOthelliste;

INTERFACE




 USES UnitDefCassio;






procedure InitUnitVieilOthelliste;                                                                                                                                                  ATTRIBUTE_NAME('InitUnitVieilOthelliste')
procedure LibereMemoireVieilOthelliste;                                                                                                                                             ATTRIBUTE_NAME('LibereMemoireVieilOthelliste')

procedure DerouleMaster;                                                                                                                                                            ATTRIBUTE_NAME('DerouleMaster')
procedure DisplayCassioAboutBox;                                                                                                                                                    ATTRIBUTE_NAME('DisplayCassioAboutBox')
{ necessite une ressource de type STR$ à 6 items , d'ID 10014 :
     STR$ 1 = nom du programe
     STR$ 2 = auteur
     STR$ 3 = version
     STR$ 4 = copyright
     STR$ 5 = Adresse
     STR$ 6 = telephone
     STR$ 7 = copyright
     STR$ 8 = suite du précédent
  et une ressource de son d'ID 20000 (par exemple la valse hongroise)
}

procedure DessineAide(quellePage : PagesAide);                                                                                                                                      ATTRIBUTE_NAME('DessineAide')
function NextPageDansAide(current : PagesAide) : PagesAide;                                                                                                                         ATTRIBUTE_NAME('NextPageDansAide')
function PreviousPageDansAide(current : PagesAide) : PagesAide;                                                                                                                     ATTRIBUTE_NAME('PreviousPageDansAide')


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, Sound, MacWindows, QuickdrawText, Fonts, Appearance, Resources, GestaltEqu
    , CFBase
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, MyFileSystemUtils, UnitCarbonisation, UnitListe, UnitSound, UnitDialog, MyStrings
    , UnitEnvirons, UnitFenetres, UnitGeometrie, MyFonts, SNEvents, UnitRapport ;
{$ELSEC}
    ;
    {$I prelink/VieilOthelliste.lk}
{$ENDC}


{END_USE_CLAUSE}












const ValseHongroiseID  = 20000;
      HelpStringsID     = 1000;
      kNombreDeStringsDansRaccourcis = 171;

      kVolumeMusique    = 30;


type StartAnimatedAboutBoxProcPtr                   = procedure (version : CFStringRef; authors : CFStringRef; gradientColor1 : CFStringRef; gradientColor2 : CFStringRef);
     CloseAnimatedAboutBoxProcPtr                   = procedure ;

var myStartAnimatedAboutBoxPtr      : StartAnimatedAboutBoxProcPtr;
    myCloseAnimatedAboutBoxPtr      : CloseAnimatedAboutBoxProcPtr;


procedure InitUnitVieilOthelliste;
begin
  gAideCourante := kAideGenerale;
  gAideTranscriptsDejaPresentee := false;

  myStartAnimatedAboutBoxPtr    := NIL;
  myCloseAnimatedAboutBoxPtr    := NIL;
end;


procedure LibereMemoireVieilOthelliste;
begin
end;


procedure AttendFrappeClavierEtJoueSonEnBoucle(SoundID : SInt16; theChannel : SndChannelPtr);
var event : eventRecord;
begin
 if theChannel <> NIL then
   begin
     FlushChannel(theChannel);
     SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
     PlaySoundAsynchrone(SoundID, kVolumeMusique, theChannel);
     SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
   end;
 FlushEvents(everyEvent,0);
  repeat
    if ((TickCount mod 60) = 0) then
      if (theChannel <> NIL) then
        begin
          FlushChannel(theChannel);
          SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
          PlaySoundAsynchrone(SoundID, kVolumeMusique, theChannel);
          SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
        end;
  until GetNextEvent(KeyDownMask+MDownMask,event);
end;



procedure DerouleMaster;
var unRect,windowRect,unrectBis,rect3,horlogerect : rect;
    Master : PicHandle;
    uneRgn : RgnHandle;
    a,i,vitesse : SInt16;
    tick : SInt32;
    masque : SInt32;
    newPort : CGrafPtr;
    uneFenetre : WindowPtr;
    PosRejoignez,posQuin,posPenloup,posFrancaise : SInt16;
    posTelephoneFede,posEcritPar,posAdresseFede : SInt16;
    compteurPixel : SInt32;
    Ecran512,clic : boolean;
    theChannel : SndChannelPtr;
    EnvoyezLaMusique : boolean;
    ChaineNicolet,ChaineQuin,ChainePenloup : String255;
    ChaineRejoignez,ChaineFFO,ChaineTelephone,ChaineAdresse : String255;
    sortie : boolean;
    err : OSErr;

begin
  BeginDialog;
  {EnvoyezLaMusique := HumCtreHum | gameOver | (nbreCoup = 0);}
  sortie := false;
  EnvoyezLaMusique := true;
  if EnvoyezLaMusique
    then OpenChannel(theChannel)
    else theChannel := NIL;
  clic := false;
  Ecran512 := (GetScreenBounds.right-GetScreenBounds.left = 512);
  if Ecran512
    then
      begin
        SetRect(unRect,-10,0,560,400);
        uneFenetre := MyNewCWindow(NIL,unRect,'',false,kWindowModalDialogProc,FenetreFictiveAvantPlan,false,0);
        SetPortByWindow(uneFenetre);
        BackPat(blackPattern);
        FillRect(unRect,blackPattern);
        ShowWindow(uneFenetre);
        FillRect(unRect,blackPattern);
        newPort := CreateNewPort;
        SetPort(GrafPtr(newPort));
        masque := MDownMask+keyDownMask;
        SetRect(unRect,-10,0,500,300);
        Master := OpenPicture(unRect);
        ClosePicture;
        SetRect(unRect,-200,-200,750,600);
        uneRgn := NewRgn;
        OpenRgn;
        FrameRect(unRect);
        CloseRgn(uneRgn);
        ClipRect(unRect);
      end
    else
      begin
        a := (GetScreenBounds.right-512) div 2;
        i := (GetScreenBounds.bottom-342) div 2 + 14;
        SetRect(unRect,a,i,a+512,i+342);
        windowRect := unRect;
        PondreLaFenetreCommeUneGouttedEau(windowRect,true);
        uneFenetre := MyNewCWindow(NIL,windowRect,'',false,1,FenetreFictiveAvantPlan,false,0);
        SetPortByWindow(uneFenetre);
        BackPat(blackPattern);
        SetRect(unRect,0,0,512,342);
        FillRect(unRect,blackPattern);
        ShowWindow(uneFenetre);
        FillRect(unRect,blackPattern);
        masque := MDownMask+keyDownMask;
        SetRect(unRect,-10,0,500,300);
        Master := OpenPicture(unRect);
        ClosePicture;
        SetRect(unRect,-200,-200,750,600);
        uneRgn := NewRgn;
        OpenRgn;
        FrameRect(unRect);
        CloseRgn(uneRgn);
        ClipRect(unRect);
      end;


  BackPat(blackPattern);
  master := MyGetPicture(137);

  DrawPicture(master, GetPicFrameOfPicture(master));

  unRect := GetPicFrameOfPicture(master);

  unrectBis := unRect;
  OffsetRect(unrectBis,0,-(unRect.bottom-unRect.top));
  if Ecran512 then HideCursor;
  SetRect(rect3,0,-100,512,342);
  DrawPicture(master,unrectBis);

  ChaineRejoignez := ReadStringFromRessource(TextesFederationID,1);
  ChaineFFO := ReadStringFromRessource(TextesFederationID,2);
  ChaineTelephone := ReadStringFromRessource(TextesFederationID,3);
  ChaineAdresse := ReadStringFromRessource(TextesFederationID,4);
  
  ChaineNicolet := ReadStringFromRessource(TextesFederationID,6);
  if (Pos('^0',ChaineNicolet) > 0)
     then ChaineNicolet := ParamStr(ChaineNicolet,VersionDeCassioEnString(),"","","");
  
  ChaineQuin := ReadStringFromRessource(TextesFederationID,7);
  ChainePenloup := ReadStringFromRessource(TextesFederationID,8);

  TextMode(3);
  TextFont(NewYorkID);
  TextSize(24);
  TextFace(underLine + bold);
  posRejoignez := (512-MyStringWidth(ChaineRejoignez)) div 2;

  TextSize(12);
  TextFace(bold);
  posQuin :=       (512-MyStringWidth(ChaineQuin)) div 2;
  posPenloup :=    (512-MyStringWidth(ChainePenloup)) div 2;
  posFrancaise :=  (512-MyStringWidth(ChaineFFO)) div 2;
  posAdresseFede := (512-MyStringWidth(ChaineAdresse)) div 2;
  posTelephoneFede := (512-MyStringWidth(ChaineTelephone)) div 2;


  TextFace( bold + underline );
  TextSize(24);
  posEcritPar :=   (512-MyStringWidth(ChaineNicolet)) div 2;

  if EnvoyezLaMusique
    then AttendFrappeClavierEtJoueSonEnBoucle(ValseHongroiseID,theChannel)
    else AttendFrappeClavier;
  TextMode(3);
  TextFont(NewYorkID);
  TextSize(12);
  vitesse := 2;
  FlushEvents(everyEvent,0);
  SetRect(horlogerect,440,12,515,25);


  compteurPixel := 0;
  tick := TickCount;

REPEAT
  if EnvoyezLaMusique then
    begin
      FlushChannel(theChannel);
      SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
      PlaySoundAsynchrone(ValseHongroiseID, kVolumeMusique, theChannel);
      SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
    end;
  compteurPixel := compteurPixel+Abs(vitesse);

  OffsetRect(unrectbis,0,vitesse);
  {DrawPicture(master,unrectbis);}

  repeat
    if WaitNextEvent(masque,theEvent,0,NIL) then sortie := true;
  until sortie | (TickCount > tick + 4);

  ScrollRect(rect3,0,vitesse,uneRgn);

  err := SetAntiAliasedTextEnabled(false,9);

  if vitesse > 0 then
    begin
      a := unrectbis.bottom-130;
      case a of
        30..53:
         begin
           TextSize(24);
           TextFace( underLine + bold );
           Moveto(posEcritpar,a-30);
           MyDrawString(ChaineNicolet);
         end;
        -7..6:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posQuin,a+7);
           MyDrawString(ChaineQuin);
         end;
         -22..-9:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posPenloup,a+22);
           MyDrawString(ChainePenloup);
         end;
        150..170:
         begin
           TextSize(24);
           TextFace( underLine + bold );
           Moveto(posRejoignez,a-150);
           MyDrawString(ChaineRejoignez);
         end;
         124..136:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posFrancaise,a-124);
           MyDrawString(ChaineFFO);
         end;
         112..123:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posTelephoneFede,a-112);
           MyDrawString(ChaineTelephone);
         end;
         100..111:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posAdresseFede,a-100);
           MyDrawString(ChaineAdresse);
         end;
      end;
    end
  else
    begin
      a := unrectbis.bottom+342+130;
      case a of
        30..53:
         begin
           TextSize(24);
           TextFace( underLine + bold );
           Moveto(posEcritPar,a-30);
           MyDrawString(ChaineNicolet);
         end;
        150..170:
         begin
           TextSize(24);
           TextFace( underLine + bold );
           Moveto(posRejoignez,a-150);
           MyDrawString(ChaineRejoignez);
         end;
         124..136:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posFrancaise,a-124);
           MyDrawString(ChaineFFO);
         end;
         112..123:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posTelephoneFede,a-112);
           MyDrawString(ChaineTelephone);
         end;
         100..111:
         begin
           TextSize(12);
           TextFace(bold);
           Moveto(posAdresseFede,a-100);
           MyDrawString(ChaineAdresse);
         end;
      end;
    end;
  tick := TickCount;


 if compteurPixel >= (GetPicFrameOfPicture(master).bottom - GetPicFrameOfPicture(master).top) then
  begin


    TextFont(gCassioApplicationFont);
    TextSize(gCassioSmallFontSize);
    TextFace(normal);
    CenterString(0,325,512,'Othello® est une marque déposée en France par Mattel™');

    if EnvoyezLaMusique then
      begin
        FlushChannel(theChannel);
        SetSoundVolumeOfChannel(theChannel,kVolumeMusique);
        PlaySoundAsynchrone(ValseHongroiseID, kVolumeMusique, theChannel);
        SetSoundVolumeOfChannel(theChannel,kVolumeMusique);
      end;
    tick := TickCount;
    repeat
      clic := clic or WaitNextEvent(masque,theEvent,0,NIL);
    until (TickCount-tick > 460) or clic;

    SetRect(unrectBis,0,0,unRect.left,unRect.right);

    DrawPicture(master, GetPicFrameOfPicture(master));

    unRect := GetPicFrameOfPicture(master);


    unrectBis := unRect;
    OffsetRect(unrectBis,0,-(unRect.bottom-unRect.top));

    if EnvoyezLaMusique then
      begin
        FlushChannel(theChannel);
        SetSoundVolumeOfChannel(theChannel,kVolumeMusique);
        PlaySoundAsynchrone(ValseHongroiseID, kVolumeMusique, theChannel);
        SetSoundVolumeOfChannel(theChannel,kVolumeMusique);
      end;
    tick := TickCount;
    repeat
      clic := clic or WaitNextEvent(masque,theEvent,0,NIL);
    until (TickCount-tick > 250) or clic;

    TextFont(NewYorkID);
    compteurPixel := 0;
  end;
UNTIL WaitNextEvent(masque,theEvent,0,NIL) or clic or sortie;

 if EnvoyezLaMusique
    then AttendFrappeClavierEtJoueSonEnBoucle(ValseHongroiseID,theChannel)
    else AttendFrappeClavier;
 if EnvoyezLaMusique then
   begin
     QuietChannel(theChannel);
     CloseChannel(theChannel);
     HUnlockSoundRessource(ValseHongroiseID);
   end;
 ReleaseResource(Handle(master));
 if ecran512 then DisposePort(newPort);
 ShowCursor;
 DrawMenuBar;
 DisposeWindow(unefenetre);
 EndDialog;
 if not(ecran512) then PondreLaFenetreCommeUneGouttedEau(windowRect,false);

 if gCassioUseQuartzAntialiasing then
   err := SetAntiAliasedTextEnabled(true,9);

end;


procedure DisplayCassioAboutBoxPourVieuxMacs;
{ necessite une ressource de type STR$ à 6 items , d'ID 10014 :
     STR$ 1 = nom du programe
     STR$ 2 = auteur
     STR$ 3 = version
     STR$ 4 = copyright
     STR$ 5 = Adresse
     STR$ 6 = telephone
     STR$ 7 = copyright
     STR$ 8 = suite du précédent
}
const strlistID = 10014;
var   oldport : grafPtr;
      wp : WindowPtr;
      windowRect : rect;
      i : SInt16;
      messages : array[1..6] of String255;
      theChannel : SndChannelPtr;
      EnvoyezLaMusique : boolean;
begin
  BeginDialog;
  {EnvoyezLaMusique := HumCtreHum or gameOver or (nbreCoup = 0);}
  EnvoyezLaMusique := true;
  if EnvoyezLaMusique
    then OpenChannel(theChannel)
    else theChannel := NIL;


  for i := 1 to 6 do
    messages[i] := ReadStringFromRessource(strlistID,i);

  { Cas particulier de la chaine de version : on remplace eventuellment ^0 par
    le numero de version courant }
  if (Pos('^0',messages[3]) > 0)
    then messages[3] := ParamStr(messages[3],VersionDeCassioEnString,"","","");

  windowRect := GetScreenBounds;
  InsetRect(windowRect,(windowRect.right-windowRect.left-300) div 2,(windowRect.bottom-windowRect.top-180) div 2);
  PondreLaFenetreCommeUneGouttedEau(windowRect,true);
  wp := MyNewCWindow(NIL,windowRect,'',true,kWindowModalDialogProc{altdboxproc},FenetreFictiveAvantPlan,false,0);

  if wp <> NIL then
  with GetWindowPortRect(wp) do
  begin
    GetPort(oldport);
    SetPortByWindow(wp);

    TextFont(systemFont);
    TextSize(0);
    TextFace(bold);
    CenterString(0,30,right,messages[1]);


    TextFont(GenevaID);
    TextSize(9);
    TextFace(normal);
    CenterString(0,60,right,messages[2]);
    CenterString(0,90,right,messages[3]);
    CenterString(0,bottom-50,right,messages[4]);
    CenterString(0,bottom-35,right,messages[5]);
    CenterString(0,bottom-20,right,messages[6]);

    while Button do
      begin
        ShareTimeWithOtherProcesses(2);
        if EnvoyezLaMusique then
          begin
            FlushChannel(theChannel);
            SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
            PlaySoundAsynchrone(ValseHongroiseID, kVolumeMusique, theChannel);
            SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
          end;
      end;
    while not(Button) do
      begin
        ShareTimeWithOtherProcesses(2);
        if EnvoyezLaMusique then
          begin
            FlushChannel(theChannel);
            SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
            PlaySoundAsynchrone(ValseHongroiseID, kVolumeMusique, theChannel);
            SetSoundVolumeOfChannel(theChannel, kVolumeMusique);
          end;
      end;
    FlushEvents(MDownmask+MupMask,0);
    if EnvoyezLaMusique then
      begin
        QuietChannel(theChannel);
        CloseChannel(theChannel);
        HUnlockSoundRessource(ValseHongroiseID);
      end;

    DisposeWindow(wp);
    SetPort(oldport);
    EndDialog;
    PondreLaFenetreCommeUneGouttedEau(windowRect,false);
  end;

end;




procedure DisplayCassioAboutBoxAvecCoreAnimation;
{ necessite une ressource de type STR$ à 6 items , d'ID 10014 :
     STR$ 1 = nom du programe    // UNUSED !
     STR$ 2 = auteur
     STR$ 3 = version
     STR$ 4 = copyright          // UNUSED !
     STR$ 5 = Adresse            // UNUSED !
     STR$ 6 = telephone          // UNUSED !
     STR$ 7 = copyright          // UNUSED !
     STR$ 8 = suite du précédent // UNUSED !
}
const strlistID = 10014;
var version, authors : CFStringRef;
    colorGradient1, colorGradient2 : CFStringREf;
    versionChainePascal, authorsChainePascal : String255;
begin

  myStartAnimatedAboutBoxPtr    := NIL;
  myCloseAnimatedAboutBoxPtr    := NIL;

  myStartAnimatedAboutBoxPtr    := StartAnimatedAboutBoxProcPtr(GetFunctionPointerFromPrivateBundle('SplashScreenBundle.bundle','StartAnimatedAboutBox'));
  myCloseAnimatedAboutBoxPtr    := CloseAnimatedAboutBoxProcPtr(GetFunctionPointerFromPrivateBundle('SplashScreenBundle.bundle','CloseAnimatedAboutBox'));

  if myStartAnimatedAboutBoxPtr <> NIL
    then
      begin


        versionChainePascal := ReadStringFromRessource(strlistID,3);
        authorsChainePascal := ReadStringFromRessource(strlistID,2);


        { Cas particulier de la chaine de version : on remplace eventuellement ^0 par
          le numero de version courant }
        if (Pos('^0',versionChainePascal) > 0)
          then versionChainePascal := ParamStr(versionChainePascal,VersionDeCassioEnString,"","","");


        version        := MakeCFSTR(versionChainePascal);
        authors        := MakeCFSTR(authorsChainePascal);
        colorGradient1 := MakeCFSTR('');
        colorGradient2 := MakeCFSTR('');


        myStartAnimatedAboutBoxPtr(version, authors, colorGradient1, colorGradient2);

        CFRelease(CFTypeRef(version));
        CFRelease(CFTypeRef(authors));
        CFRelease(CFTypeRef(colorGradient1));
        CFRelease(CFTypeRef(colorGradient2));

        myCloseAnimatedAboutBoxPtr;

      end
    else WritelnDansRapport('myStartAnimatedAboutBoxPtr = NIL');

end;
 


procedure DisplayCassioAboutBox;
var animationEstPresente : boolean;
    err : OSStatus;
    response : SInt32;
begin

{ La boite About Cassio animée necessite le Mac OS X 10.5
  au minimum (pour Core Animation) et un Mac Intel }

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
   err := Gestalt(gestaltSystemVersion, response);
   animationEstPresente :=   (err = noErr) 
                           & (response >= $00001050) 
                           & (response <= $00001070) 
                           & CassioEstUnBundleApplicatif;
  {$ELSEC}
   Discard2(err,response);
   animationEstPresente := false;
  {$ENDC}
   
   if animationEstPresente
     then DisplayCassioAboutBoxAvecCoreAnimation
     else DisplayCassioAboutBoxPourVieuxMacs;
   

end;




procedure DessineHelpDialogue;
var windowRect : rect;
    a,i,b : SInt16;
    newPort : CGrafPtr;
    uneFenetre : WindowPtr;
    Ecran512 : boolean;
    invite,s1,s2 : String255;
    theChannel : SndChannelPtr;
    EnvoyezLaMusique : boolean;
    err : OSErr;

 procedure EcritInviteRaccourcis;
 begin
   TextSize(gCassioSmallFontSize);
   TextFont(gCassioApplicationFont);
   TextFace(bold);
   b := 16;
   CenterString(0,b,512,invite);
   b := 40;
   ShareTimeWithOtherProcesses(2);
 end;


begin
  err := SetAntiAliasedTextEnabled(false,9);

  BeginDialog;
  {EnvoyezLaMusique := HumCtreHum or gameOver or (nbreCoup = 0);}
  EnvoyezLaMusique := true;
  if EnvoyezLaMusique
    then OpenChannel(theChannel)
    else theChannel := NIL;
  Ecran512 := (GetScreenBounds.right-GetScreenBounds.left = 512);
  if Ecran512
    then
      begin
        SetRect(windowRect,-10,0,560,400);
        uneFenetre := MyNewCWindow(NIL,windowRect,'',false,0,FenetreFictiveAvantPlan,false,0);
        SetPortByWindow(uneFenetre);
        ShowWindow(uneFenetre);
        newPort := CreateNewPort;
        SetPort(GrafPtr(newPort))
      end
    else
      begin
        a := (GetScreenBounds.right-512) div 2;
        i := (GetScreenBounds.bottom-342) div 2 + 14;
        SetRect(windowRect,a,i,a+512,i+342);
        PondreLaFenetreCommeUneGouttedEau(windowRect,true);
        uneFenetre := MyNewCWindow(NIL,windowRect,'',false,1,FenetreFictiveAvantPlan,false,0);
        SetPortByWindow(uneFenetre);
        ShowWindow(uneFenetre);
      end;


  invite := ReadStringFromRessource(HelpStringsID,1);
  EcritInviteRaccourcis;

  i := 1;
  repeat
    s1 := ReadStringFromRessource(HelpStringsID,i*2);
    s2 := ReadStringFromRessource(HelpStringsID,i*2+1);

    if (s1 <> '\newpage') and (s2 <> '\newpage') then
      if (s1 <> '') or (s2 <> '') then
        begin
          if s2 = ''
            then
              begin
                TextFace(bold);
                WriteStringAt(s1,10,b);
              end
            else
              begin
                TextFace(bold);
                WriteStringAt(s1,38,b);
                TextFace(normal);
                WriteStringAt(s2,194,b);
              end;
        end;

    b := b+12;
    i := i+1;

    if (s1 = '\newpage') or (s2 = '\newpage') or
       ((b > 355) and (i <= (kNombreDeStringsDansRaccourcis div 2))) then
      begin
        ShareTimeWithOtherProcesses(2);
        if EnvoyezLaMusique
			    then AttendFrappeClavierEtJoueSonEnBoucle(ValseHongroiseID,theChannel)
			    else AttendFrappeClavier;
        SetPortByWindow(uneFenetre);
        MyEraseRect(QDGetPortBound);
        MyEraseRectWithColor(QDGetPortBound,OrangeCmd,blackPattern,'');
        EcritInviteRaccourcis;
        ShareTimeWithOtherProcesses(2);
      end;

  until (i > (kNombreDeStringsDansRaccourcis div 2));

  if EnvoyezLaMusique
    then AttendFrappeClavierEtJoueSonEnBoucle(ValseHongroiseID,theChannel)
    else AttendFrappeClavier;

  if EnvoyezLaMusique then
   begin
     QuietChannel(theChannel);
     CloseChannel(theChannel);
     HUnlockSoundRessource(ValseHongroiseID);
   end;

  if ecran512 then DisposePort(newPort);
  ShowCursor;
  DrawMenuBar;
  DisposeWindow(unefenetre);
  EndDialog;
  if not(ecran512) then PondreLaFenetreCommeUneGouttedEau(windowRect,false);

  if gCassioUseQuartzAntialiasing then
    err := SetAntiAliasedTextEnabled(true,9);
end;



procedure DessineAide(quellePage : PagesAide);
var i,b : SInt32;
    invite,s1,s2 : String255;
    oldPort : grafPtr;
    err : OSErr;
    compteurDePage : PagesAide;

 procedure EcritInviteAide;
 var theRect : rect;
 begin
   theRect := QDGetPortBound;
   InSetRect(theRect,-10,-10);
   if DrawThemeWindowListViewHeader(theRect,kThemeStateActive) = NoErr then DoNothing;
   TextSize(gCassioSmallFontSize);
   TextFont(gCassioApplicationFont);
   TextFace(bold);
   TextMode(1);
   b := 16;
   invite := ReadStringFromRessource(HelpStringsID,1);
   invite := invite + ' ('+NumEnString(1+ord(compteurDePage))+'/'+NumEnString(1+ord(kAideTranscripts))+')';
   err := SetAntiAliasedTextEnabled(false,9);
   CenterString(0,b,512,invite);
   b := 40;
 end;


begin

  if windowAideOpen & (wAidePtr <> NIL) then
    begin

      GetPort(oldPort);
      SetPortByWindow(wAidePtr);

      err := SetAntiAliasedTextEnabled(false,9);

      compteurDePage := kAideGenerale;
      EcritInviteAide;

      i := 1;
      repeat
        s1 := ReadStringFromRessource(HelpStringsID,i*2);
        s2 := ReadStringFromRessource(HelpStringsID,i*2+1);

        if (compteurDePage = quellePage) then
          begin
            if (s1 <> '\newpage') and (s2 <> '\newpage') then
              if (s1 <> '') or (s2 <> '') then
                begin
                  if s2 = ''
                    then
                      begin
                        TextFace(bold);
                        WriteStringAtWithoutErase(s1,10,b);
                      end
                    else
                      begin
                        TextFace(bold);
                        WriteStringAtWithoutErase(s1,38,b);
                        TextFace(normal);
                        WriteStringAtWithoutErase(s2,194,b);
                      end;
                end;
          end;

        b := b+12;
        i := i+1;

        if (s1 = '\newpage') or (s2 = '\newpage') or
           ((b > 565) and (i <= (kNombreDeStringsDansRaccourcis div 2))) then
          begin
            inc(compteurDePage);
            if (compteurDePage <= quellePage) then
              begin
    			      SetPortByWindow(wAidePtr);
                EcritInviteAide;
              end;

          end;

      until (i > (kNombreDeStringsDansRaccourcis div 2));

      ShowCursor;
      DrawMenuBar;

      if gCassioUseQuartzAntialiasing then
        err := SetAntiAliasedTextEnabled(true,9);

      SetPort(oldPort);

    end;
end;


function NextPageDansAide(current : PagesAide) : PagesAide;
begin
  if current = kAideTranscripts
    then NextPageDansAide := kAideGenerale
    else NextPageDansAide := succ(current);
end;


function PreviousPageDansAide(current : PagesAide) : PagesAide;
begin
  if current = kAideGenerale
    then PreviousPageDansAide := kAideTranscripts
    else PreviousPageDansAide := pred(current);
end;




end.






