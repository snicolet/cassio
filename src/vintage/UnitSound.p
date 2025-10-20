UNIT UnitSound;


INTERFACE







 USES UnitDefCassio , Sound;



   procedure OpenChannel(var theChannel : SndChannelPtr);
   procedure CloseChannel(var theChannel : SndChannelPtr);
   procedure FlushChannel(var theChannel : SndChannelPtr);
   procedure QuietChannel(var theChannel : SndChannelPtr);
   procedure HUnlockSoundRessource(SoundID : SInt16);

   procedure PlaySoundSynchrone(soundID, volume : SInt16);
   procedure PlaySoundAsynchrone(soundID, volume : SInt16; theChannel : SndChannelPtr);

   procedure SetSoundVolumeOfChannel(theChannel : SndChannelPtr; volume : SInt32);

{

  procedure SetSoundVol (level : SInt16);
  procedure GetSoundVol (var level : SInt16);
  procedure StartSound (synthRec: Ptr; numBytes: SInt32; completionRtn: ProcPtr);
  procedure StopSound;
  function SoundDone: BOOLEAN;
}





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacMemory, QuickDraw, Events, MacWindows, Dialogs, Fonts, Files, TextEdit
    , Devices, Scrap, ToolUtils, OSUtils, Menus, Resources, Controls, Processes
    , AppleEvents
{$IFC NOT(USE_PRELINK)}
    , UnitServicesMemoire ;
{$ELSEC}
    ;
    {$I prelink/Sound.lk}
{$ENDC}


{END_USE_CLAUSE}














 procedure OpenChannel(var theChannel : SndChannelPtr);
  begin
    theChannel := NIL;
    if SndNewChannel(theChannel,sampledSynth,initStereo,NIL) <> NoErr then DoNothing;
  end;

 procedure CloseChannel(var theChannel : SndChannelPtr);
   begin
     if SndDisposeChannel(theChannel,true) <> NoErr then DoNothing;
   end;

 procedure FlushChannel(var theChannel : SndChannelPtr);
 var sc : SndCommand;
  begin
    sc.cmd := flushCmd;
    if SndDoImmediate(theChannel,sc) = NoErr then DoNothing;
  end;

 procedure QuietChannel(var theChannel : SndChannelPtr);
 var sc : SndCommand;
  begin
    sc.cmd := flushCmd;
    if SndDoImmediate(theChannel,sc) = NoErr then DoNothing;
    sc.cmd := quietCmd;
    if SndDoImmediate(theChannel,sc) = NoErr then DoNothing;
  end;

 procedure HUnlockSoundRessource(SoundID : SInt16);
	var MySoundHandle : handle;
	begin
	  MySoundHandle := GetResource(MY_FOUR_CHAR_CODE('snd '), SoundID);
	  if MySoundHandle <> NIL then
	     begin
	       HUnlock(MySoundHandle);
	       ReleaseResource(MySoundHandle);
	     end;
	end;


procedure PlaySoundSynchrone(soundID, volume : SInt16);
var
  err : SInt16;
  sndInPlay : Handle;
  sndInPlayState : SInt8;
  theChannel : SndChannelPtr;
begin
  sndInPlay := GetResource(MY_FOUR_CHAR_CODE('snd '), soundID);
  if sndInPlay <> NIL then
    begin
      HLockHi(sndInPlay);
      sndInPlayState := HGetState(sndInPlay);

      OpenChannel(theChannel);

      SetSoundVolumeOfChannel(theChannel, volume);

      err := SndPlay(theChannel, SndListHandle(sndInPlay), false);

      SetSoundVolumeOfChannel(theChannel, volume);

      QuietChannel(theChannel);
      CloseChannel(theChannel);

      HUnlock(sndInPlay);
      ReleaseResource(sndInPlay);
    end;
end;


procedure PlaySoundAsynchrone(soundID, volume : SInt16; theChannel : SndChannelPtr);
var
  err : SInt16;
  sndInPlay : Handle;
  sndInPlayState : SInt8;
begin
  sndInPlay := GetResource(MY_FOUR_CHAR_CODE('snd '), soundID);
  if sndInPlay <> NIL then
    begin
      HLockHi(sndInPlay);
      sndInPlayState := HGetState(sndInPlay);
      SetSoundVolumeOfChannel(theChannel, volume);
      err := SndPlay(theChannel, SndListHandle(sndInPlay), true);
      SetSoundVolumeOfChannel(theChannel, volume);
    end;
end;


{ SetSoundVolumeOfChannel
  Changement du volume, sur une echelle allant de 0 ˆ 512. (256 = volume normal)
  }
procedure SetSoundVolumeOfChannel(theChannel : SndChannelPtr; volume : SInt32);
var theCmd : SndCommand;
begin

  theCmd.param1 := 0;
  theCmd.param2 := volume + volume*65536;  {droite et gauche}
  theCmd.cmd := volumeCmd;

  if SndDoImmediate(theChannel,theCmd) = noErr then DoNothing;
end;



end.

