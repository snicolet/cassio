UNIT UnitCassioSounds;



INTERFACE







 USES UnitDefCassio;


procedure InitUnitCassioSounds;
procedure LibereMemoireUnitCassioSounds;

procedure PlayZamfirSound(const fonctionAppelante : String255);
procedure PlayPosePionSound;
procedure PlayRetournementDePionSound;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacMemory, Resources, Sound
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitSound ;
{$ELSEC}
    ;
    {$I prelink/CassioSounds.lk}
{$ENDC}


{END_USE_CLAUSE}










const
  ZamfirID = 1350;



var
  SoundChannelPosePion : SndChannelPtr;
  SoundChannelRetournementPion : SndChannelPtr;
  PosePionSound : SndListHandle;
  RetournementPionSound : SndListHandle;




procedure InitUnitCassioSounds;
begin

  OpenChannel(SoundChannelPosePion);
  OpenChannel(SoundChannelRetournementPion);
  FlushChannel(SoundChannelPosePion);
  FlushChannel(SoundChannelRetournementPion);

  {on baisse le niveau sur les canaux de retournement de pion}
  SetSoundVolumeOfChannel(SoundChannelPosePion, kVolumeSonDesCoups);
  SetSoundVolumeOfChannel(SoundChannelRetournementPion, kVolumeSonDesCoups);

  PosePionSound := NIL;
  RetournementPionSound := NIL;

  //PosePionSound := SndListHandle(GetResource(MY_FOUR_CHAR_CODE('snd '), kSonTickID));
  //RetournementPionSound := SndListHandle(GetResource(MY_FOUR_CHAR_CODE('snd '), kSonTockID));

  PosePionSound := SndListHandle(GetResource(MY_FOUR_CHAR_CODE('snd '), kSonBlopID));
  //RetournementPionSound := SndListHandle(GetResource(MY_FOUR_CHAR_CODE('snd '), kSonBlipID));


  if (PosePionSound <> NIL) then HLockHi(Handle(PosePionSound));
  if (RetournementPionSound <> NIL) then HLockHi(Handle(RetournementPionSound));

end;


procedure LibereMemoireUnitCassioSounds;
begin
end;



procedure PlayZamfirSound(const fonctionAppelante : String255);
var theChannel : SndChannelPtr;
    err : SInt16;
	  sndInPlay: Handle;
	  sndInPlayState: SInt8;
begin
  {$unused fonctionAppelante}

  {on remplace PlaySoundSynchrone(ZamfirID) par le code suivant, qui a l'avantage
   de moduler le volume du son stocke en ressource, qui etait trop fort}

  if avecSon and not(gameOver) and not(analyseRetrograde.enCours) and not(enTournoi and (phaseDeLaPartie >= phaseFinale)) then
    begin

      OpenChannel(theChannel);

      sndInPlay := GetResource(MY_FOUR_CHAR_CODE('snd '), ZamfirID);
      if sndInPlay <> NIL then
        begin
          HLockHi(sndInPlay);
          sndInPlayState := HGetState(sndInPlay);

          SetSoundVolumeOfChannel(theChannel, kVolumeSonDesCoups);
          err := SndPlay(theChannel, SndListHandle(sndInPlay), false);
          SetSoundVolumeOfChannel(theChannel, kVolumeSonDesCoups);

          HUnlock(sndInPlay);
          ReleaseResource(sndInPlay);
        end;

      CloseChannel(theChannel);

    end;
end;

procedure PlayPosePionSound;
var err : SInt16;
begin
  if PosePionSound <> NIL then
    begin
      QuietChannel(SoundChannelPosePion);
      SetSoundVolumeOfChannel(SoundChannelPosePion, kVolumeSonDesCoups);
      err := SndPlay(SoundChannelPosePion, PosePionSound, enTournoi);
      SetSoundVolumeOfChannel(SoundChannelPosePion, kVolumeSonDesCoups);
    end;
end;


procedure PlayRetournementDePionSound;
var err : SInt16;
begin
  if RetournementPionSound <> NIL then
    begin
      QuietChannel(SoundChannelRetournementPion);
      SetSoundVolumeOfChannel(SoundChannelRetournementPion, kVolumeSonDesCoups);
      err := SndPlay(SoundChannelRetournementPion, RetournementPionSound, false);
      SetSoundVolumeOfChannel(SoundChannelRetournementPion, kVolumeSonDesCoups);
    end;
end;


END.
