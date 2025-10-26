(*
	File:		UnitCFNetworkHTTP.p


	Disclaimer:	IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
*)



UNIT UnitCFNetworkHTTP;


INTERFACE

{$ifc defined __GPC__ }
   {$definec compile_network_stuff true }
{$elsec }
   {$definec compile_network_stuff true }
{$endc }


USES UnitDefCassio , CFStream, UnitDefFichierAbstrait, UnitDefCFNetworkHTTP;


{ Initialize the unit }
procedure InitUnitCFNetworkHTPP;
procedure LibereMemoireUnitCFNetworkHTPP;
procedure InitReserveZonesTelechargement;


{ gestion du pool des zones memoires utilisees pour les telechargements }
function TrouverSlotLibreDansLaReservePourTelecharger(var numeroSlotLibre : SInt32) : boolean;
function NombreDeSlotsLibresDansLaReservePourTelecharger : SInt32;
procedure LibereSlotDansLaReservePourTelecharger(numeroSlot : SInt32);
function ThisSlotUsesAPermanentConnection(numeroSlot : SInt32) : boolean;


{	DownloadURL : downloads the url in a FichierAbstrait }
procedure DownloadURL(numeroSlot : SInt32; var url : LongString);
procedure DownloadURLToFichierAbstrait(numeroSlot : SInt32; var url : LongString; var whichFichierAbstrait : FichierAbstrait; terminationProc : FichierAbstraitLongintProc);


{ Modifier cette fonction pour utiliser le texte telecharge }
procedure DoSomethingWithBuffer(stream : CFReadStreamRef; buffer : UnivPtr; longueurBuffer : SInt32);


{	We set up a one-shot timer to fire in 5 seconds which will terminate the download. }
{	Every time we get some download activity in our notifier, we tickle the timer }
procedure	ReadStreamClientCallBack(stream : CFReadStreamRef; event : CFStreamEventType ; clientCallBackInfo : UnivPtr);
procedure	NetworkTimeoutTimerProc(inTimer : EventLoopTimerRef ; inUserData : UnivPtr);
procedure CheckStreamEvents;


{ Utility function to terminate the download }
procedure TerminateDownload( var stream : CFReadStreamRef; reason : CFStreamEventType ; nbrBytes : SInt32; error : CFStreamError; fonctionAppelante : String255);


{ reporting network errors }
procedure ReportNetworkError(whichError : CFStreamError);
procedure DumpCFNetwortConstantsToRapport;


{	Connection à un hote, par un numero de port }
function TryOpenPermanentConnection(host : String255; port : UInt16; serializator : EntreesSortieFichierAbstraitProc; termination : FichierAbstraitLongintProc; var numeroSlot : SInt32) : boolean;
function FindPermanentConnectionToHost( var host : String255; port : SInt32; var numeroSlot : SInt32) : boolean;
function SendBytesToPermanentConnection(buffer : Ptr; bufferLength, numeroSlot : SInt32) : boolean;
function SendStringToPermanentConnection(var s : LongString; numeroSlot : SInt32) : boolean;


{ Ouverture d'une URL dans le navigateur par defaut (Safari, Firefox, etc...) }
procedure LSOpenURL (url: String255);


{ gestion de bas niveau des slot de telechargement simultanes HTTP }
(*
function FindFichierAbstraitOfAsynchroneNetworkConnections( var stream : CFReadStreamRef; var numeroSlot : SInt32) : t_LocalFichierAbstraitPtr;
procedure InstallStreamOfAsynchroneNetworkConnections(numeroSlot : SInt32; rStream : CFReadStreamRef; wStream : CFWriteStreamRef; whichFichierAbstrait : t_LocalFichierAbstraitPtr; terminationProc : FichierAbstraitLongintProc);
procedure InstallSerializatorForNetworkConnections(numeroSlot : SInt32; serializator : EntreesSortieFichierAbstraitProc);
procedure RemoveStreamOfSimultaneaousNetworkConnections(stream : CFReadStreamRef; error : CFStreamError);
*)





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    CarbonEventsCore, CFHTTPMessage, CFHTTPStream, CFNumber, CFBase, CFURL, CFString, CFHost
    , CFNetServices, CFFTPStream, CFSocketStream, Sound, OSUtils, CFNetworkglue, CFSocket, LaunchServices

{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyStrings, MyFileSystemUtils, UnitBaseNouveauFormat, SNEvents, UnitFichierAbstrait, UnitGestionDuTemps, UnitZoo
    , UnitLongString ;
{$ELSEC}
    ;
    {$I prelink/CFNetworkHTTP.lk}
{$ENDC}


{END_USE_CLAUSE}








const my_kCFStreamErrorDomainPOSIX               = 1;
      my_kCFStreamErrorDomainMacOSStatus         = 2;
      my_kCFStreamErrorDomainSSL                 = 3;
      my_kCFStreamErrorDomainHTTP                = 4;
      my_kCFStreamErrorDomainSOCKS               = 5;
      my_kCFStreamErrorDomainFTP                 = 6;
      my_kCFStreamErrorDomainNetServices         = 10;
      my_kCFstreamErrorDomainMach                = 11;
      my_kCFStreamErrorDomainNetDB               = 12;
      my_kCFStreamErrorDomainSystemConfiguration = 13;


var

{ HTTP properties }
  my_kCFStreamPropertyHTTPShouldAutoredirect  : CFStringRef;
  my_kCFHTTPVersion1_1                        : CFStringRef;

{ Socket stream properties }
  my_kCFStreamPropertySocketNativeHandle      : CFStringRef;
  my_kCFStreamPropertySocketRemoteHostName    : CFStringRef;
  my_kCFStreamPropertySocketRemotePortNumber  : CFStringRef;

{ Stream properties }
  my_kCFStreamPropertyShouldCloseNativeSocket : CFStringRef;




type t_LocalFichierAbstraitPtr = ^FichierAbstrait;

     NetworkConnectionRec =
                          record
                            theReadStream            : CFReadStreamRef;
                            theWriteStream           : CFWriteStreamRef;
                            theFichierAbstrait       : t_LocalFichierAbstraitPtr;
                            serializator             : EntreesSortieFichierAbstraitProc;
                            termination              : FichierAbstraitLongintProc;
                            messageRef               : CFHTTPMessageRef	;
                            urlRef                   : CFURLRef;
                            lastTickOfCkecking       : SInt32;
                            lastTickOfActivity       : SInt32;
                            url255                   : LongString;
                          end;


var  gListOfFichierAbstraitOfAsynchroneNetworkConnections :
        record
          lastUsedIndex               : SInt32;
          table                       : array[0 .. kNumberOfAsynchroneNetworkConnections] of NetworkConnectionRec;
          lastTickOfCheckStreamEvents : SInt32;
        end;


     gNoStreamError : CFStreamError;


const gUnitCFNetworkHTPPInitialisee : boolean = false;



procedure InitReserveZonesTelechargement;
var k : SInt32;
begin
  { initialisation de la table des zones memoires de telechargement }
  with gReserveZonesPourTelecharger do
    begin
      numeroEnCours := -1;
      for k := 0 to kNumberOfAsynchroneNetworkConnections do
        begin
          with gReserveZonesPourTelecharger.table[k] do
            begin
              fic := NewEmptyFichierAbstrait;
              petitFichierTampon := MakeFichierAbstraitEnMemoire(4096);
              infoNetworkConnection := MakeLongString('');
            end;
        end;
    end;

  with gListOfFichierAbstraitOfAsynchroneNetworkConnections do
    begin
      lastTickOfCheckStreamEvents := TickCount;
      for k := 0 to kNumberOfAsynchroneNetworkConnections do
        begin
          table[k].lastTickOfCkecking := TickCount;
          table[k].lastTickOfActivity := TickCount;
        end;
    end;
end;


procedure LibereMemoireReserveZonesTelechargement;
var k : SInt32;
begin
  { liberation de la table des zones memoires de telechargement }
  with gReserveZonesPourTelecharger do
    begin
      for k := 0 to kNumberOfAsynchroneNetworkConnections do
        begin
          with gReserveZonesPourTelecharger.table[k] do
            begin
              if FichierAbstraitEstCorrect(fic) then DisposeFichierAbstrait(fic);
              if FichierAbstraitEstCorrect(petitFichierTampon) then DisposeFichierAbstrait(petitFichierTampon);
            end;
        end;
    end;
end;



procedure InitUnitCFNetworkHTPP;
var k : SInt32;
begin

  with gListOfFichierAbstraitOfAsynchroneNetworkConnections do
    begin
      lastUsedIndex := 0;

      for k := 0 to kNumberOfAsynchroneNetworkConnections do
        with table[k] do
          begin
            theReadStream          := NIL;
            theWriteStream         := NIL;
            theFichierAbstrait      := NIL;
            serializator           := NIL;
            termination            := NIL;
            messageRef             := NIL;
            urlRef                 := NIL;
          end;
    end;

  gNoStreamError.domain := 0;
  gNoStreamError.error  := 0;

  {$ifc defined __GPC__ }
  my_kCFStreamPropertyHTTPShouldAutoredirect  := kCFStreamPropertyHTTPShouldAutoredirect;
  my_kCFHTTPVersion1_1                        := kCFHTTPVersion1_1;
  my_kCFStreamPropertySocketNativeHandle      := kCFStreamPropertySocketNativeHandle;
  my_kCFStreamPropertySocketRemoteHostName    := kCFStreamPropertySocketRemoteHostName;
  my_kCFStreamPropertySocketRemotePortNumber  := kCFStreamPropertySocketRemotePortNumber;
  my_kCFStreamPropertyShouldCloseNativeSocket := kCFStreamPropertyShouldCloseNativeSocket;

  {$elsec }
  my_kCFStreamPropertyHTTPShouldAutoredirect  := MakeCFSTR('kCFStreamPropertyHTTPShouldAutoredirect');
  my_kCFHTTPVersion1_1                        := MakeCFSTR('HTTP/1.1');
  my_kCFStreamPropertySocketNativeHandle      := MakeCFSTR('kCFStreamPropertySocketNativeHandle');
  my_kCFStreamPropertySocketRemoteHostName    := MakeCFSTR('kCFStreamPropertySocketRemoteHostName');
  my_kCFStreamPropertySocketRemotePortNumber  := MakeCFSTR('kCFStreamPropertySocketRemotePortNumber');
  my_kCFStreamPropertyShouldCloseNativeSocket := MakeCFSTR('kCFStreamPropertyShouldCloseNativeSocket');

  {$endc }


  InitReserveZonesTelechargement;

  gUnitCFNetworkHTPPInitialisee := true;
end;



procedure LibereMemoireUnitCFNetworkHTPP;
var k : SInt32;
begin


  with gListOfFichierAbstraitOfAsynchroneNetworkConnections do
    begin
      lastUsedIndex := 0;

      for k := 0 to kNumberOfAsynchroneNetworkConnections do
        with table[k] do
          begin

            if (theReadStream <> NIL) then
              begin
                CFReadStreamClose( theReadStream );
              	if (theReadStream <> NIL) then CFRelease( CFTypeRef( theReadStream ));
              	theReadStream := NIL;
              end;

            if (theWriteStream <> NIL) then
              begin
                CFWriteStreamClose( theWriteStream );
              	if (theWriteStream <> NIL) then CFRelease( CFTypeRef( theWriteStream ));
              	theWriteStream := NIL;
              end;
          end;
    end;


  {$ifc not(defined __GPC__) }
  if (my_kCFStreamPropertyHTTPShouldAutoredirect <> NIL)  then CFRelease(CFTypeRef(my_kCFStreamPropertyHTTPShouldAutoredirect)) ;
  if (my_kCFHTTPVersion1_1 <> NIL)                        then CFRelease(CFTypeRef(my_kCFHTTPVersion1_1)) ;
  if (my_kCFStreamPropertySocketNativeHandle <> NIL)      then CFRelease(CFTypeRef(my_kCFStreamPropertySocketNativeHandle)) ;
  if (my_kCFStreamPropertySocketRemoteHostName <> NIL)    then CFRelease(CFTypeRef(my_kCFStreamPropertySocketRemoteHostName)) ;
  if (my_kCFStreamPropertySocketRemotePortNumber <> NIL)  then CFRelease(CFTypeRef(my_kCFStreamPropertySocketRemotePortNumber)) ;
  if (my_kCFStreamPropertyShouldCloseNativeSocket <> NIL) then CFRelease(CFTypeRef(my_kCFStreamPropertyShouldCloseNativeSocket)) ;
  {$endc }

  LibereMemoireReserveZonesTelechargement;
end;


function NombreDeSlotsLibresDansLaReservePourTelecharger : SInt32;
var k,somme : SInt32;
begin
  somme := 0;

  with gReserveZonesPourTelecharger do
    for k := 0 to kNumberOfAsynchroneNetworkConnections do
      begin
        if table[k].fic.genre = BadFichierAbstrait then
          inc(somme);
      end;

  NombreDeSlotsLibresDansLaReservePourTelecharger := somme;
end;



function TrouverSlotLibreDansLaReservePourTelecharger(var numeroSlotLibre : SInt32) : boolean;
var k, index : SInt32;
    libres : SInt32;
begin
  TrouverSlotLibreDansLaReservePourTelecharger := false;
  numeroSlotLibre := -1;

  with gReserveZonesPourTelecharger do
    begin
      // inc(numeroEnCours);
      numeroEnCours := 0;


      Discard(libres);

      {
      libres := NombreDeSlotsLibresDansLaReservePourTelecharger;
      if ((libres mod 100) = 0) then
        WritelnNumDansRapport('libres = ',libres);
      }

      {WritelnNumDansRapport('numeroEnCours = ',numeroEnCours);}

      if (numeroEnCours > kNumberOfAsynchroneNetworkConnections) then numeroEnCours := 0;
      if (numeroEnCours < 0) then numeroEnCours := 0;

      for k := 0 to kNumberOfAsynchroneNetworkConnections do
        begin
          index := numeroEnCours + k;

          if index > kNumberOfAsynchroneNetworkConnections then index := index - (kNumberOfAsynchroneNetworkConnections + 1);
          if index < 0                                  then index := index + (kNumberOfAsynchroneNetworkConnections + 1);

          if table[index].fic.genre = BadFichierAbstrait then  {le fichier est-il est vide ?}
            begin
              table[index].fic.genre  := FichierAbstraitReserved;       {comme ça, on le reserve }
              table[index].fic.refCon := index;                         {permettra de connaitre le numero dans gReserveZonesPourTelecharger à partir du fichier }
              table[index].petitFichierTampon.refCon := index; {idem}

              numeroSlotLibre := index;
              TrouverSlotLibreDansLaReservePourTelecharger := true;

              {WritelnNumDansRapport('trouve : numeroSlotLibre = ',numeroSlotLibre);}

              exit(TrouverSlotLibreDansLaReservePourTelecharger);
            end;
        end;
    end;

  WritelnDansRapport('ERROR : number of simultaneous downloads exceeded in TrouverSlotLibreDansLaReservePourTelecharger !');
end;


procedure LibereSlotDansLaReservePourTelecharger(numeroSlot : SInt32);
begin
  if (numeroSlot >= 0) and (numeroSlot <= kNumberOfAsynchroneNetworkConnections) then
    begin
      gReserveZonesPourTelecharger.table[numeroSlot].fic.genre       := BadFichierAbstrait;
      gReserveZonesPourTelecharger.table[numeroSlot].infoNetworkConnection := MakeLongString('');
    end;
end;



function ThisSlotUsesAPermanentConnection(numeroSlot : SInt32) : boolean;
begin
  ThisSlotUsesAPermanentConnection := false;

  if (numeroSlot >= 0) and (numeroSlot <= kNumberOfAsynchroneNetworkConnections) then
    with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot] do
      ThisSlotUsesAPermanentConnection := (theReadStream <> NIL) and
                                          (theWriteStream <> NIL);
end;



procedure ReportNetworkError(whichError : CFStreamError);
begin  {$unused whichError}



  if (whichError.error <> 0) then
    begin

       // An error has occurred !

       // See http://developer.apple.com/documentation/CoreFoundation/Reference/CFStreamConstants/Reference/reference.html#//apple_ref/c/tdef/CFStreamErrorDomain
       // for the list of header files to check for each particular error type


          if (whichError.domain = my_kCFStreamErrorDomainPOSIX) then
            WritelnNumDansRapport('POSIX error (look in sys/errno.h) :  whichError.erro = ',  whichError.error) else

          if (whichError.domain = my_kCFStreamErrorDomainMacOSStatus) then
            WritelnNumDansRapport('MAC OS error (look in MacTypes.h): whichError.error = ',  whichError.error) else

          if (whichError.domain = my_kCFStreamErrorDomainNetDB) then
            WritelnNumDansRapport('NetDB error (look in netdb.h): whichError.error = ',  whichError.error) else

          if (whichError.domain = my_kCFStreamErrorDomainNetServices) then
            WritelnNumDansRapport('NetServices error (look in ????): whichError.error = ',  whichError.error) else

         if (whichError.domain = my_kCFstreamErrorDomainMach) then
            WritelnNumDansRapport('Mach error (look in mach/error.h): whichError.error = ',  whichError.error) else

          if (whichError.domain = my_kCFStreamErrorDomainFTP) then
            WritelnNumDansRapport('FTP error (look inCFFTPStream.h): whichError.error = ',  whichError.error) else

          if (whichError.domain = my_kCFStreamErrorDomainHTTP) then
            WritelnNumDansRapport('HTTP error (look in CFHTTPStream.h ??): whichError.error = ',  whichError.error) else

          if (whichError.domain = my_kCFStreamErrorDomainSOCKS) then
            WritelnNumDansRapport('SOCKS error (look in ????): whichError.error = ',  whichError.error) else

          if (whichError.domain = my_kCFStreamErrorDomainSystemConfiguration) then
            WritelnNumDansRapport('SystemConfiguration error (look in  SystemConfiguration/SystemConfiguration.h): whichError.error = ',  whichError.error) else

          if (whichError.domain = my_kCFStreamErrorDomainSSL) then
            WritelnNumDansRapport('DomainSSL error (look in Security.framework/SecureTransport.h): whichError.error = ',  whichError.error)

          else
            begin

              // Check other domains.

              WritelnNumDansRapport('whichError.domain = ',  whichError.domain);
              WritelnNumDansRapport('Unknow domain error : whichError.error = ',  whichError.error);

            end;

      if whichError.error <> NoErr then
        begin
          (*
          WritelnDansRapport('NETWORK ERROR (err = ['NumEnString(whichError.domain)+':'+NumEnString(whichError.error)+'])');
          *)
          AfficheEtatDuReseau('NETWORK ERROR (err = ['+NumEnString(whichError.domain)+':'+NumEnString(whichError.error)+'])');
        end;

    end;


end;


procedure DumpCFNetwortConstantsToRapport;
var buffer : str255;
begin  {$unused buffer}
  {$ifc defined __GPC__ }
  WritelnNumDansRapport('kCFStreamErrorDomainPOSIX               = ',kCFStreamErrorDomainPOSIX);
  WritelnNumDansRapport('kCFStreamErrorDomainMacOSStatus         = ',kCFStreamErrorDomainMacOSStatus);
  WritelnNumDansRapport('kCFStreamErrorDomainNetDB               = ',kCFStreamErrorDomainNetDB);
  WritelnNumDansRapport('kCFStreamErrorDomainNetServices         = ',kCFStreamErrorDomainNetServices);
  WritelnNumDansRapport('kCFstreamErrorDomainMach                = ',kCFstreamErrorDomainMach);
  WritelnNumDansRapport('kCFStreamErrorDomainFTP                 = ',kCFStreamErrorDomainFTP);
  WritelnNumDansRapport('kCFStreamErrorDomainHTTP                = ',kCFStreamErrorDomainHTTP);
  WritelnNumDansRapport('kCFStreamErrorDomainSOCKS               = ',kCFStreamErrorDomainSOCKS);
  WritelnNumDansRapport('kCFStreamErrorDomainSystemConfiguration = ',kCFStreamErrorDomainSystemConfiguration);
  WritelnNumDansRapport('kCFStreamErrorDomainSSL                 = ',kCFStreamErrorDomainSSL);

  if CFStringGetPascalString(kCFStreamPropertyHTTPShouldAutoredirect, @buffer, 256, 0) then
    WritelnDansRapport('kCFStreamPropertyHTTPShouldAutoredirect = '+MyStr255ToString(buffer));

  if CFStringGetPascalString(kCFHTTPVersion1_1, @buffer, 256, 0) then
    WritelnDansRapport('kCFHTTPVersion1_1 = '+MyStr255ToString(buffer));

  if CFStringGetPascalString(kCFStreamPropertySocketNativeHandle, @buffer, 256, 0) then
    WritelnDansRapport('kCFStreamPropertySocketNativeHandle = '+MyStr255ToString(buffer));

  if CFStringGetPascalString(kCFStreamPropertySocketRemoteHostName, @buffer, 256, 0) then
    WritelnDansRapport('kCFStreamPropertySocketRemoteHostName = '+MyStr255ToString(buffer));

  if CFStringGetPascalString(kCFStreamPropertySocketRemotePortNumber, @buffer, 256, 0) then
    WritelnDansRapport('kCFStreamPropertySocketRemotePortNumber = '+MyStr255ToString(buffer));

  if CFStringGetPascalString(kCFStreamPropertyShouldCloseNativeSocket, @buffer, 256, 0) then
    WritelnDansRapport('kCFStreamPropertyShouldCloseNativeSocket = '+MyStr255ToString(buffer));

  {$endc}
end;




function FindFichierAbstraitOfAsynchroneNetworkConnections( var stream : CFReadStreamRef; var numeroSlot : SInt32) : t_LocalFichierAbstraitPtr;
var k,index : SInt32;
begin

  FindFichierAbstraitOfAsynchroneNetworkConnections := NIL;
  numeroSlot := -1;

  if (stream = NIL) then
    begin
      WritelnDansRapport('ASSERT  !! stream = NIL dans FindFichierAbstraitOfAsynchroneNetworkConnections ');
      exit(FindFichierAbstraitOfAsynchroneNetworkConnections);
    end;


  with gListOfFichierAbstraitOfAsynchroneNetworkConnections do
    for k := 0 to ((kNumberOfAsynchroneNetworkConnections div 2) + 1) do
      begin


        {un coup en montant... }

        index := lastUsedIndex + k;
        if index > kNumberOfAsynchroneNetworkConnections then index := index - (kNumberOfAsynchroneNetworkConnections + 1);
        if index < 0                                  then index := index + (kNumberOfAsynchroneNetworkConnections + 1);

        // WritelnNumDansRapport('index = ',index);

        if table[index].theReadStream = stream then
          begin

            (*
            WritelnDansRapport('');
            WritelnNumDansRapport('theReadStream         = ', SInt32(table[index].theReadStream));
            WritelnNumDansRapport('theFichierAbstrait = ', SInt32(table[index].theFichierAbstrait));
            WritelnNumDansRapport('dans FindFichierAbstraitOfAsynchroneNetworkConnections, stop = ',index);
            WritelnNumDansRapport('@0 : theReadStream     = ', SInt32(table[0].theReadStream));
            WritelnNumDansRapport('@0 : theFichierAbstrait = ', SInt32(table[0].theFichierAbstrait));
            WritelnDansRapport('');
            *)

            lastUsedIndex      := index;
            numeroSlot         := index;
            FindFichierAbstraitOfAsynchroneNetworkConnections := table[index].theFichierAbstrait;

            exit(FindFichierAbstraitOfAsynchroneNetworkConnections);
          end;



        {un coup en descendant... }

        index := lastUsedIndex - k - 1;
        if index > kNumberOfAsynchroneNetworkConnections then index := index - (kNumberOfAsynchroneNetworkConnections + 1);
        if index < 0                                  then index := index + (kNumberOfAsynchroneNetworkConnections + 1);

        // WritelnNumDansRapport('index = ',index);

        if table[index].theReadStream = stream then
          begin

            (*
            WritelnDansRapport('');
            WritelnNumDansRapport('theReadStream         = ', SInt32(table[index].theReadStream));
            WritelnNumDansRapport('theFichierAbstrait = ', SInt32(table[index].theFichierAbstrait));
            WritelnNumDansRapport('dans FindFichierAbstraitOfAsynchroneNetworkConnections, stop = ',index);
            WritelnNumDansRapport('@0 : theReadStream         = ', SInt32(table[0].theReadStream));
            WritelnNumDansRapport('@0 : theFichierAbstrait = ', SInt32(table[0].theFichierAbstrait));
            WritelnDansRapport('');
            *)

            lastUsedIndex      := index;
            numeroSlot         := index;
            FindFichierAbstraitOfAsynchroneNetworkConnections := table[index].theFichierAbstrait;

            exit(FindFichierAbstraitOfAsynchroneNetworkConnections);
          end;
      end;
end;


procedure InstallStreamOfAsynchroneNetworkConnections(numeroSlot : SInt32; rStream : CFReadStreamRef; wStream : CFWriteStreamRef; whichFichierAbstrait : t_LocalFichierAbstraitPtr; terminationProc : FichierAbstraitLongintProc);
begin

  with gListOfFichierAbstraitOfAsynchroneNetworkConnections do
    begin

      if (numeroSlot < 0) or (numeroSlot > kNumberOfAsynchroneNetworkConnections) then
        begin
          WritelnNumDansRapport('ASSERT  !! numeroSlot impossibe dans InstallStreamOfAsynchroneNetworkConnections,  numeroSlot = ',numeroSlot);
          exit(InstallStreamOfAsynchroneNetworkConnections);
        end;

      if (rStream = NIL) then
        begin
          WritelnDansRapport('ASSERT  !! rStream = NIL dans InstallStreamOfAsynchroneNetworkConnections ');
          exit(InstallStreamOfAsynchroneNetworkConnections);
        end;

      if (whichFichierAbstrait = NIL) then
        begin
          WritelnDansRapport('ASSERT  !! whichFichierAbstrait = NIL dans InstallStreamOfAsynchroneNetworkConnections ');
          exit(InstallStreamOfAsynchroneNetworkConnections);
        end;


      if (terminationProc = NIL) then
        begin
          WritelnDansRapport('ASSERT  !! terminationProc = NIL dans InstallStreamOfAsynchroneNetworkConnections ');
          exit(InstallStreamOfAsynchroneNetworkConnections);
        end;


      if (table[numeroSlot].theReadStream <> NIL) and
         (table[numeroSlot].theReadStream <> rStream) then
        begin
          WritelnDansRapport('ASSERT  !! slot non libre (theReadStream) InstallStreamOfAsynchroneNetworkConnections ');
          exit(InstallStreamOfAsynchroneNetworkConnections);
        end;

      if (table[numeroSlot].theWriteStream <> NIL) and
         (table[numeroSlot].theWriteStream <> wStream) then
        begin
          WritelnDansRapport('ASSERT  !! slot non libre (theWriteStream) InstallStreamOfAsynchroneNetworkConnections ');
          exit(InstallStreamOfAsynchroneNetworkConnections);
        end;


      if (table[numeroSlot].theFichierAbstrait <> NIL) and
         (table[numeroSlot].theFichierAbstrait <> whichFichierAbstrait) then
        begin
          WritelnDansRapport('ASSERT  !! slot non libre (theFichierAbstrait) InstallStreamOfAsynchroneNetworkConnections ');
          exit(InstallStreamOfAsynchroneNetworkConnections);
        end;


      if (numeroSlot >= 0) and (numeroSlot <= kNumberOfAsynchroneNetworkConnections) then
        begin

          lastUsedIndex := numeroSlot;

          with table[numeroSlot] do
            begin
              if ((theReadStream = NIL) or (theReadStream = rStream)) and
                 ((theWriteStream = NIL) or (theWriteStream = wStream)) and
                 ((theFichierAbstrait = NIL) or (theFichierAbstrait = whichFichierAbstrait)) then
                begin
                  theReadStream     := rStream;
                  theWriteStream    := wStream;
                  theFichierAbstrait := whichFichierAbstrait;
                  termination       := terminationProc;

                  (*
                  WritelnDansRapport('');
                  WritelnNumDansRapport('theReadStream = ', SInt32(theReadStream));
                  WritelnNumDansRapport('theWriteStream = ', SInt32(theWriteStream));
                  WritelnNumDansRapport('theFichierAbstrait = ', SInt32(theFichierAbstrait));
                  WritelnNumDansRapport('Installing an HTTP download in slot ', numeroSlot);
                  WritelnNumDansRapport('@0 : theReadStream         = ', SInt32(table[0].theReadStream));
                  WritelnNumDansRapport('@0 : theWriteStream         = ', SInt32(table[0].theWriteStream));
                  WritelnNumDansRapport('@0 : theFichierAbstrait = ', SInt32(table[0].theFichierAbstrait));
                  WritelnDansRapport('');
                  *)

                  exit(InstallStreamOfAsynchroneNetworkConnections);
                end;
            end;

        end;

      WritelnDansRapport('ERROR : number of simultaneous downloads exceeded in InstallStreamOfAsynchroneNetworkConnections !');

    end;
end;


procedure InstallSerializatorForNetworkConnections(numeroSlot : SInt32; serializator : EntreesSortieFichierAbstraitProc);
begin

  if (numeroSlot < 0) or (numeroSlot > kNumberOfAsynchroneNetworkConnections) then
    begin
      WritelnNumDansRapport('ASSERT  !! numeroSlot impossibe dans InstallSerializatorForNetworkConnections,  numeroSlot = ',numeroSlot);
      exit(InstallSerializatorForNetworkConnections);
    end;

  gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot].serializator := serializator;

end;


procedure RemoveStreamOfSimultaneaousNetworkConnections(stream : CFReadStreamRef; error : CFStreamError);
 var index : SInt32;
    err : OSErr;
    myTerminaison : FichierAbstraitLongintProc;
    myZone : FichierAbstraitPtr;
begin

  if (stream = NIL) then
    begin
      WritelnDansRapport('ASSERT  !! stream = NIL dans RemoveStreamOfSimultaneaousNetworkConnections ');
      exit(RemoveStreamOfSimultaneaousNetworkConnections);
    end;


  if (FindFichierAbstraitOfAsynchroneNetworkConnections(stream, index) <> NIL) and
     (index >= 0) and (index <= kNumberOfAsynchroneNetworkConnections) then
    begin
      with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[index] do
        begin

          myZone                 := FichierAbstraitPtr(theFichierAbstrait);
          myTerminaison          := termination;


          theReadStream          := NIL;
          theWriteStream         := NIL;
          theFichierAbstrait  := NIL;
          serializator           := NIL;
          termination            := NIL;

          (*
          WritelnNumDansRapport('Removing HTTP download from slot ', index);
          *)

          if (myTerminaison <> NIL) and (myZone <> NIL) then
            begin
              { WritelnDansRapport('J''appelle la fonction de termination');
              WritelnDansRapport(''); }

              err := myTerminaison(myZone, error.error);
            end;

          exit(RemoveStreamOfSimultaneaousNetworkConnections);
        end;
    end;

  WritelnDansRapport('ERROR : stream non trouvee dans RemoveStreamOfSimultaneaousNetworkConnections !');
  WritelnNumDansRapport('stream = ',SInt32(stream));
  WritelnDansRapport('');

end;


procedure DoSomethingWithBuffer(stream : CFReadStreamRef; buffer : UnivPtr; longueurBuffer : SInt32);
var nbOctets : SInt32;
    err : OSErr;
    fichierAbstraitOfStream : t_LocalFichierAbstraitPtr;
    numeroSlot : SInt32;
begin

  (*
  InsereTexteDansRapport(buffer, longueurBuffer);
  WritelnDansRapport('');
  WritelnDansRapport('');
  *)

  fichierAbstraitOfStream := FindFichierAbstraitOfAsynchroneNetworkConnections(stream, numeroSlot);

  if (fichierAbstraitOfStream <> NIL) then
    begin

      if FichierAbstraitEstCorrect(fichierAbstraitOfStream^) then
        with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot] do
          begin

            if serializator <> NIL
              then
                begin

                  // Si on a mis un serialisateur, on l'appelle

                  nbOctets := longueurBuffer;
                  err := serializator(FichierAbstraitPtr(fichierAbstraitOfStream) , buffer, -1, nbOctets);

                end
              else
                begin

                  // l'action par defaut est d'ecrire le buffer lu dans le fichier abstrait, sans le serialiser

                  nbOctets := longueurBuffer;
                  err := EcrireFichierAbstrait(fichierAbstraitOfStream^, -1, buffer, nbOctets);

                  {WritelnNumDansRapport(' err = ',err);}

                  // Write the received bytes in rapport
                  (*
                  WritelnDansRapport('');
                  WritelnNumDansRapport('@',index);
                  InsereTexteDansRapport(buffer, longueurBuffer);
                  WritelnDansRapport('');
                  WritelnDansRapport('');
                  *)

                end;
          end;
    end
    else
      WritelnDansRapport(' ASSERT ! dans DoSomethingWithBuffer, fichierAbstraitOfStream = NIL !!');

  (* WritelnDansRapport(''); *)
end;



procedure DumpStreamAdressesDansRapport;
var k : SInt32;
begin
  for k := 0 to kNumberOfAsynchroneNetworkConnections do
    begin
      WritelnNumDansRapport('@'+NumEnString(k)+' : ',SInt32(gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[k].theReadStream));
    end;
end;



procedure	ReadStreamClientCallBack( stream : CFReadStreamRef; event : CFStreamEventType ; clientCallBackInfo : UnivPtr);
var buffer : packed array[0.. ((30 * 1024)-1)] of UInt8;				//	Create a 30K buffer
	  bytesRead : CFIndex;
    myCFErr : CFStreamError;
    {diagRef : CFNetDiagnosticRef; }
    trouve : boolean;
    numeroSlot : SInt32;
    streamStatus : CFSTreamStatus;
begin


{$ifc compile_network_stuff }


  if (stream = NIL) then
    begin
      WritelnDansRapport('ASSERT : stream = NIL dans ReadStreamClientCallBack !!');
      exit(ReadStreamClientCallBack);
    end;


  trouve := (FindFichierAbstraitOfAsynchroneNetworkConnections(stream, numeroSlot) <> NIL);

  if not(trouve) then
    begin
      WritelnDansRapport('ASSERT : not(trouve) dans ReadStreamClientCallBack !!');

      if clientCallBackInfo <> NIL
        then WritelnLongStringDansRapport(LongStringPtr(clientCallBackInfo)^)
        else WritelnDansRapport('clientCallBackInfo = NIL !');

      case event of
        kCFStreamEventHasBytesAvailable : WritelnDansRapport('event = kCFStreamEventHasBytesAvailable');
        kCFStreamEventEndEncountered    : WritelnDansRapport('event = kCFStreamEventEndEncountered');
        kCFStreamEventErrorOccurred     : WritelnDansRapport('event = kCFStreamEventErrorOccurred');
        otherwise                         WritelnDansRapport('event inconnu !!');

      end; {case}

      WritelnNumDansRapport('stream = ',SInt32(stream));
      DumpStreamAdressesDansRapport;

      WritelnDansRapport('');

      SysBeep(0);

      AttendFrappeClavier;

      exit(ReadStreamClientCallBack);
    end;

  with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot] do
    begin

      lastTickOfActivity := TickCount;

      case event of

        kCFStreamEventHasBytesAvailable:
          begin

            bytesRead := CFReadStreamRead( theReadStream, @buffer, sizeof(buffer) );

            if ( bytesRead > 0 )    // If some bytes were read, wait for the EOF to come.
              then
                begin
    	            DoSomethingWithBuffer(theReadStream, @buffer, bytesRead);
                end
            else
            if ( bytesRead < 0 ) 		// Less than zero is an error
              then
                begin
                  myCFErr.domain := -999;
                  myCFErr.error  := -999;
    			        TerminateDownload( theReadStream , event, bytesRead, myCFErr, 'ReadStreamClientCallBack (1)');
                end
              else	               //	0 assume we are done with the stream
                begin

                  streamStatus := CFReadStreamGetStatus(theReadStream);

                  if (streamStatus = kCFStreamStatusAtEnd) then
                    TerminateDownload( theReadStream , event, bytesRead, gNoStreamError, 'ReadStreamClientCallBack (2)');

                end;

          end;


        kCFStreamEventEndEncountered:
          begin
    		    TerminateDownload( theReadStream , event, 0, gNoStreamError, 'ReadStreamClientCallBack (3)');
    		  end;


        kCFStreamEventErrorOccurred:
          begin

            myCFErr := CFReadStreamGetError( theReadStream );

            (*
            if (FindInLongString('foo.Random16()',url255) <= 0) then
              begin

        		    WritelnDansRapport('kCFStreamEventErrorOccurred');
        		    {
        		    diagRef := CFNetDiagnosticCreateWithStreams(NIL, theReadStream, NIL);
                (void)CFNetDiagnosticDiagnoseProblemInteractively(diagRef);
                }
                ReportNetworkError(myCFErr);

              end;
            *)

    		    TerminateDownload( theReadStream , event, 0, myCFErr, 'ReadStreamClientCallBack (4)');
    		  end;

      end; {case}

    end;

{$endc}
end;





procedure TerminateDownload( var stream : CFReadStreamRef; reason : CFStreamEventType ; nbrBytes : SInt32; error : CFStreamError; fonctionAppelante : String255);
var trouve : boolean;
    streamAdress : CFReadStreamRef;
    numeroSlot : SInt32;
begin

  Discard2(reason, nbrBytes);
  Discard(fonctionAppelante);

{$ifc compile_network_stuff }

  streamAdress := stream;



  (* if (reason <> kCFStreamEventEndEncountered)
    then stream := CFReadStreamRef( CFRetain( CFTypeRef( stream )));

  *)

  trouve := (FindFichierAbstraitOfAsynchroneNetworkConnections( stream, numeroSlot) <> NIL);

  if not(trouve) then
    begin
      WritelnDansRapport('ASSERT : not(trouve) dans TerminateDownload !!');
      exit(TerminateDownload);
    end;

  (*
  WritelnDansRapport('');
  WriteNumDansRapport('Entering TerminateDownload pour numeroSlot = ', numeroSlot);
  WritelnDansRapport('  , fonctionAppelante = ' + fonctionAppelante);
  WritelnNumDansRapport('streamAdress = ', Longint(streamAdress));
  *)


  with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot] do
    begin

      { WritelnDansRapport(' dans TerminateDownload (frappez une touche)'); }

      if (theReadStream <> NIL) then
        begin

        	CFReadStreamClose( theReadStream );
        	if (theReadStream <> NIL) then CFRelease( CFTypeRef( theReadStream ));
        	// theReadStream := NIL;

       end;

     if (theWriteStream <> NIL) then
        begin

        	CFWriteStreamClose( theWriteStream );
        	if (theWriteStream <> NIL) then CFRelease( CFTypeRef( theWriteStream ));
        	// theWriteStream := NIL;

       end;
   end;

 { Do the terminaison with the dowloaded data (like closing the file, etc).
   This will also set the stream pointers to NIL }

 RemoveStreamOfSimultaneaousNetworkConnections(streamAdress, error);



{$endc}
end;





//	We set up a one-shot timer to fire in 5 seconds which will terminate the download.  Every time we
//	get some download activity in our notifier, we tickle the timer
procedure	NetworkTimeoutTimerProc( inTimer : EventLoopTimerRef ; inUserData : UnivPtr);
var myCFErr : CFStreamError;
    whichStream : CFReadStreamRef;
    trouve : boolean;
    numeroSlot : SInt32;
begin  {$UNUSED inTimer }

  {
  WritelnDansRapport('');
  WritelnDansRapport('Network Timeout - NetworkTimeoutTimerProc');
  }


  whichStream := CFReadStreamRef(inUserData);

  (*
  if (whichStream = NIL)
     then WritelnDansRapport('whichStream = NIL')
     else WritelnNumDansRapport('whichStream = ',SInt32(whichStream));


  if (whichStream <> NIL) and CFReadStreamHasBytesAvailable(whichStream)
     then WritelnDansRapport('CFReadStreamHasBytesAvailable(whichStream) = TRUE')
     else WritelnDansRapport('CFReadStreamHasBytesAvailable(whichStream) = FALSE');
  *)


  trouve := (FindFichierAbstraitOfAsynchroneNetworkConnections(whichStream, numeroSlot) <> NIL);

  if not(trouve)
    then
      begin
        WritelnDansRapport('ASSERT : not(trouve) dans NetworkTimeoutTimerProc !!');
        if whichStream = NIL then
           WritelnDansRapport('   car whichStream = NIL !!!  ');
      end
    else
      begin
        if (numeroSlot >= 0) and (numeroSlot <= kNumberOfAsynchroneNetworkConnections)
         then
           with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot] do
             begin
               (*
               WritelnLongStringDansRapport(url255);
               *)
               if (FindStringInLongString(GetZooURL, url255) > 0) and (FindStringInLongString('&retry=1', url255) <= 0)  then
                 begin
                   // WritelnLongStringDansRapport(url255);
                   // WritelnDansRapport('HTTP timeout => retrying');
                   RetryEnvoyerUneRequeteAuZoo(url255);
                 end;
             end
         else
           WritelnNumDansRapport('out of range : numeroSlot = ',numeroSlot);
      end;


  myCFErr.domain := -1000;
  myCFErr.error := -1000;

	TerminateDownload( CFReadStreamRef(inUserData) , kCFStreamEventNone, 0, myCFErr, 'NetworkTimeoutTimerProc');


end;



procedure CheckStreamEvents;
var numeroStream : SInt32;
    streamStatus : CFSTreamStatus;
begin

{$ifc compile_network_stuff }

  if gUnitCFNetworkHTPPInitialisee and not(Quitter) then
    with gListOfFichierAbstraitOfAsynchroneNetworkConnections do
      begin
        if TickCount > lastTickOfCheckStreamEvents then
          begin

            {WritelnNumDansRapport('interv CheckStream = ',TickCount - lastTickOfCheckStreamEvents);}

            for numeroStream := 0 to kNumberOfAsynchroneNetworkConnections do
              with table[numeroStream] do
                begin

                  if (theReadStream <> NIL) and (TickCount > lastTickOfCkecking) then
                    begin

                      { a-t-on des octets sur le flux de lecture ? }
                      if (theReadStream <> NIL) and CFReadStreamHasBytesAvailable(theReadStream) then
                        ReadStreamClientCallBack(theReadStream, kCFStreamEventHasBytesAvailable, @url255);


                      if (theReadStream <> NIL) and CFReadStreamHasBytesAvailable(theReadStream) then
                        ReadStreamClientCallBack(theReadStream, kCFStreamEventHasBytesAvailable, @url255);

                      if (theReadStream <> NIL) and CFReadStreamHasBytesAvailable(theReadStream) then
                        ReadStreamClientCallBack(theReadStream, kCFStreamEventHasBytesAvailable, @url255);


                      if (theReadStream <> NIL) then
                        begin
                          streamStatus := CFReadStreamGetStatus(theReadStream);

                          { est-on arrivé à la fin du flux ? }


                          if (streamStatus = kCFStreamStatusAtEnd) then
                            begin
                              if CFReadStreamHasBytesAvailable(theReadStream) then
                                ReadStreamClientCallBack(theReadStream, kCFStreamEventHasBytesAvailable, @url255);

                              ReadStreamClientCallBack(theReadStream, kCFStreamEventEndEncountered, @url255)
                            end else


                          { ou a-t-on une erreur reseau ? }
                          if (streamStatus = kCFStreamStatusError) then
                            ReadStreamClientCallBack(theReadStream, kCFStreamEventErrorOccurred, @url255);
                       end;

                      if not(ThisSlotUsesAPermanentConnection(numeroStream)) then
                        begin
                          { a-t-on un timeout ? }
                          if ((TickCount - lastTickOfActivity) > 60 * 5)      { 5 secondes }
                            then NetworkTimeoutTimerProc( NIL, UnivPtr(theReadStream));
                        end;

                      lastTickOfCkecking := TickCount;

                    end;

                end;

            lastTickOfCheckStreamEvents := TickCount;
          end;
      end;

  {$endc}
end;


//	DownloadURL, downloads the url.
procedure DownloadURL(numeroSlot : SInt32; var url : LongString);
var
  rawCFString        : CFStringRef	;
	normalizedCFString : CFStringRef	;
	escapedCFString    : CFStringRef	;
	myCFString         : CFStringRef  ;
	buffer             : packed array [0..1023] of char;
	nbOctets           : SInt32;
{$ifc compile_network_stuff} label Bail; {$endc}

begin

{$ifc compile_network_stuff}


  if (numeroSlot < 0) or (numeroSlot > kNumberOfAsynchroneNetworkConnections) then
    begin
      WritelnNumDansRapport('ASSERT dans DownloadURL :   numeroSlot = ',numeroSlot);
      exit(DownloadURL);
    end;



  with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot] do
    begin

      messageRef		 := NIL;
      theReadStream  := NIL;
      theWriteStream := NIL;


      (****************  CREATING THE URL REFERENCE  *************)

    	if ( LengthOfLongString(url) <= 0 ) then
    	  begin
    	    WritelnDansRapport('ERROR !! url = '''' dans DownloadURL...');
    	    exit(DownloadURL);
    	  end;



    	//	If the url doesn't start out with "http", assume the user was lazy and put it in there

    	if not(LongStringBeginsWith('http://', url)) then
    	  AppendToLeftOfLongString('http://', url);

    	url255 := url;

    	if (LengthOfLongString(url) < 12) then goto Bail;


      {WritelnLongStringDansRapport('url = '+url);}


    	//	We first create a CFString in a standard URL format, for instance spaces, " ", become "%20" within the string
    	//	To do this we normalize the URL first, then create the escaped equivalent

    	LongStringToBuffer(url, @buffer[0], nbOctets);

    	rawCFString := CFStringCreateWithBytes ( NIL, @buffer[0], nbOctets, CFStringGetSystemEncoding, false);
    	if ( rawCFString = NIL ) then goto Bail;

    	myCFString := MakeCFSTR('');
    	normalizedCFString	 :=  CFURLCreateStringByReplacingPercentEscapes( NIL, rawCFString, myCFString );
    	if (myCFString <> NIL) then CFRelease( CFTypeRef( myCFString ));

    	if ( normalizedCFString = NIL ) then goto Bail;


    	escapedCFString	 :=  CFURLCreateStringByAddingPercentEscapes( NIL, normalizedCFString, NIL, NIL, kCFStringEncodingUTF8 );
    	if ( escapedCFString = NIL ) then goto Bail;

    	urlRef :=  CFURLCreateWithString( kCFAllocatorDefault, escapedCFString, NIL );

    	if (rawCFString <> NIL)        then CFRelease( CFTypeRef( rawCFString ) );
    	if (normalizedCFString <> NIL) then CFRelease( CFTypeRef( normalizedCFString ) );
    	if (escapedCFString <> NIL)    then CFRelease( CFTypeRef( escapedCFString ) );

    	if ( urlRef = NIL ) then goto Bail;





    	(************   CONNECT !   *****************)



      myCFString := MakeCFSTR('GET');
    	messageRef := CFHTTPMessageCreateRequest( kCFAllocatorDefault, myCFString, urlRef, my_kCFHTTPVersion1_1 );
    	if (myCFString <> NIL) then CFRelease( CFTypeRef( myCFString ));

    	if ( messageRef = NIL ) then goto Bail;

    	// Create the stream for the request.
    	theReadStream	 :=  CFReadStreamCreateForHTTPRequest( kCFAllocatorDefault, messageRef );

    	if ( theReadStream = NIL ) then goto Bail;

    	InstallStreamOfAsynchroneNetworkConnections(numeroSlot, theReadStream, NIL, theFichierAbstrait, termination);
    	InstallSerializatorForNetworkConnections(numeroSlot, NIL);

    	lastTickOfActivity := TickCount;


    	//	There are times when a server checks the User-Agent to match a well known browser.  This is what Safari used at the time the sample was written
    	//CFHTTPMessageSetHeaderFieldValue( messageRef, CFSTR("User-Agent"), CFSTR("Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/125.5.5 (KHTML, like Gecko) Safari/125"));

      if ( CFReadStreamSetProperty(theReadStream, my_kCFStreamPropertyHTTPShouldAutoredirect, CFTypeRef(kCFBooleanTrue)) = false )
    		then goto Bail;


    	// Start the HTTP connection
    	if ( CFReadStreamOpen( theReadStream ) = false )
    	  then goto Bail;

    	{ WritelnNumDansRapport('err = ',err); }

    	if ( messageRef <> NIL )
    	  then CFRelease( CFTypeRef( messageRef ));

    	if ( urlRef <> NIL )
    	  then CFRelease( CFTypeRef( urlRef ));

      exit(DownloadURL);




      (****************   ERROR MANAGMENT   **************)

    Bail :

      WritelnDansRapport('Bail dans DownloadURL !! ');

    	if ( messageRef <> NIL )
    	  then CFRelease( CFTypeRef( messageRef ));

    	if ( theReadStream <> NIL )
        then TerminateDownload( theReadStream , kCFStreamEventNone, 0, gNoStreamError, 'DownloadURL');


   end;

{$endc}
end;


procedure DownloadURLToFichierAbstrait(numeroSlot : SInt32; var url : LongString; var whichFichierAbstrait : FichierAbstrait; terminationProc : FichierAbstraitLongintProc);
begin

  if (numeroSlot >= 0) and (numeroSlot <= kNumberOfAsynchroneNetworkConnections) then
    begin

      with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot] do
        begin

          if FichierAbstraitEstCorrect(whichFichierAbstrait)
            then
              begin
                {WritelnDansRapport('whichFichierAbstrait semble correcte dans DownloadURLToFichierAbstrait');}
                theFichierAbstrait := @whichFichierAbstrait;
                termination       := terminationProc;
              end
            else
              begin
                WritelnDansRapport('whichFichierAbstrait est incorrecte dans DownloadURLToFichierAbstrait');
                theFichierAbstrait := NIL;
                termination       := NIL;
              end;

          DownloadURL(numeroSlot, url);

        end;

      // WritelnDansRapport('sortie de DownloadURLToFichierAbstrait');

    end;

end;


function WaitForConnection(wStream : CFWriteStreamRef ) : boolean;
var i : SInt32;
begin
    // Since in this test app we have nothing better to do, we just poll to check whether
    // the connection has succeeded.  In a GUI app, the better approach would be to return
    // to the RunLoop to service events, and watch for the kCFStreamEventCanAcceptBytes event.
    for i := 1 to 15 do
      begin
        if (CFWriteStreamCanAcceptBytes(wStream)) then
          begin
            WaitForConnection := true;
            exit(WaitForConnection);
          end;

         WritelnDansRapport('"Waiting for connection, clic to advance...');

         AttendFrappeClavier;
      end;

   WaitForConnection := false;
end;


procedure RunEchoOnStreams(rStream : CFReadStreamRef; wStream : CFWriteStreamRef );
var myLine : String255;
    connectWorked : boolean;
    foo : boolean;
    buffer : packed array[0.. ((16 * 1024)-1)] of UInt8;	  // User input buffer.  16K should be enough.
    rStatus, wStatus : CFStreamStatus;
    sent, rcvd, len : CFIndex;
    c : char;
    lineLength : SInt32;
    bytesSent, bytesRead : CFIndex;

label bailOut, closeStreams;

begin

    connectWorked := FALSE;

    // Kill the run loop if stream creation failed.
    if (rStream = NIL) or (wStream = NIL) then
      begin
        goto bailOut;
      end;

    WritelnDansRapport('avant CFReadStreamSetProperty');
    AttendFrappeClavier;


    // Inform the streams to kill the socket when it is done with it.
    // This effects the write stream too since the pair shares the
    // one socket.
    foo := CFReadStreamSetProperty(rStream, my_kCFStreamPropertyShouldCloseNativeSocket, CFTypeRef(kCFBooleanTrue));

        // Try to open the streams.
    if (CFReadStreamOpen(rStream) and CFWriteStreamOpen(wStream) and WaitForConnection(wStream)) then
      begin


        connectWorked := TRUE;

        WritelnDansRapport('Connected. Hit Ctrl-C to quit.');

        REPEAT

            // Continue pumping along while waiting to open
            repeat

              rStatus := CFReadStreamGetStatus(rStream);
              wStatus := CFWriteStreamGetStatus(wStream);

            until ((rStatus <> kCFStreamStatusOpening) and (wStatus <> kCFStreamStatusOpening));



            if (((rStatus = kCFStreamStatusError)  or (wStatus = kCFStreamStatusError))  or
                ((rStatus = kCFStreamStatusClosed) or (wStatus = kCFStreamStatusClosed)) or
                ((rStatus = kCFStreamStatusAtEnd)  or (wStatus = kCFStreamStatusAtEnd))) then
              begin
                WritelnDansRapport('Connection terminated.');
                goto closeStreams;
              end;

            // Read characters off stdin.



            myLine := '?action=PING';

            (*
            WritelnDansRapport('Sending '+myLine + '...');
            AttendFrappeClavier;
            *)

            //  myLine := Concat(myLine, cr);  // add carriage return

            myLine := Concat(myLine, lf);  // add linefeed
            lineLength := LENGTH_OF_STRING(myLine);



            len := 0;
            REPEAT

                c := myLine[len + 1];
                //char c := getchar();

                // This has the unfortunate side effect that prevents the auto-detection
                // that the streams go dead.  The dead streams won't be realized until
                // the write tries to happen.
                buffer[len] := UInt8(c);

                // Keep going.
                inc(len);

            UNTIL (buffer[len - 1] = ord('•')) or (len >= lineLength);


            // Start off with nothing
            sent := 0;
            rcvd := 0;

            // Keep trying to send the data
            while (sent < len) and CFWriteStreamCanAcceptBytes(wStream) do
              begin

                // Try to send
                bytesSent := CFWriteStreamWrite(wStream, @buffer, len - sent);

                // Check to see if an error occurred
                if (bytesSent <= 0) then goto closeStreams;

                sent := sent + bytesSent;

              end;

            // Keep trying to receive the data
            while (rcvd < len) and CFReadStreamHasBytesAvailable(rStream) do
              begin

                // Try to send
                bytesRead := CFReadStreamRead(rStream, @buffer[rcvd], sizeof(buffer) - rcvd);

                // Check to see if an error occurred
                if (bytesRead <= 0) then goto closeStreams;

                rcvd := rcvd + bytesRead;

              end;


            // Write the received bytes in rapport
            (*
            if (rcvd > 0) then
              begin
                WritelnDansRapport('');
                InsereTexteDansRapport(@buffer, rcvd);
                WritelnDansRapport('');
                WritelnDansRapport('');
              end;
            *)

        UNTIL false;


        closeStreams :

        // Close the streams
        CFReadStreamClose(rStream);
        CFWriteStreamClose(wStream);
     end;

bailOut:

    if not(connectWorked) then
        WritelnDansRapport('Connection failed.');

    if (rStream <> NIL) then CFRelease(CFTypeRef(rStream));
    if (wStream <> NIL) then CFRelease(CFTypeRef(wStream));

end;


function TryOpenPermanentConnection(host : String255; port : UInt16; serializator : EntreesSortieFichierAbstraitProc; termination : FichierAbstraitLongintProc; var numeroSlot : SInt32) : boolean;
var rStream : CFReadStreamRef;
    wStream : CFWriteStreamRef;
    hostStr : CFStringRef;
    connectWorked : boolean;
    foo : boolean;
begin

  connectWorked := false;

  if TrouverSlotLibreDansLaReservePourTelecharger(numeroSlot) then
    with gReserveZonesPourTelecharger.table[numeroSlot] do
      begin

        {WritelnDansRapport('apres TrouverSlotLibreDansLaReservePourTelecharger');}

        if FichierAbstraitEstCorrect(petitFichierTampon) then
          begin

            // Empty the memory with which we'll serialize answers
            if ViderFichierAbstrait(petitFichierTampon) = NoErr then
              begin

                // For debugging
                {WritelnDansRapport('Connecting to '+host + ' at port '+ NumEnString(port) + '...');}

                // Create the CoreFoundation string for the host
                hostStr		 :=  CFStringCreateWithPascalString( NIL, StringToStr255(host), CFStringGetSystemEncoding );

                // Create the socket pair to host
                CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, hostStr, port, rStream, wStream);

                // Release the string
                if (hostStr <> NIL) then CFRelease( CFTypeRef( hostStr ) );

                // Inform the streams to kill the socket when it is done with it.
                // This effects the write stream too since the pair shares the
                // one socket.
                foo := CFReadStreamSetProperty(rStream, my_kCFStreamPropertyShouldCloseNativeSocket, CFTypeRef(kCFBooleanTrue));

                // Open the streams for sending and receiving data (this opens the socket)
                if CFReadStreamOpen(rStream) and CFWriteStreamOpen(wStream)
                  then
                    begin

                      // Install the streams and the termination function in our gListOfFichierAbstraitOfAsynchroneNetworkConnections data structure
                      InstallStreamOfAsynchroneNetworkConnections(numeroSlot, rStream, wStream, @petitFichierTampon, termination);

                      // Install the serializator there, too
                      InstallSerializatorForNetworkConnections(numeroSlot, serializator);

                      // Store host and port as string
                      infoNetworkConnection := MakeLongString(host + ':' + NumEnString(port));

                      connectWorked := true;
                    end;
              end;
          end;

        if not(connectWorked) then LibereSlotDansLaReservePourTelecharger(numeroSlot);
      end;

  TryOpenPermanentConnection := connectWorked;
end;


function SendBytesToPermanentConnection(buffer : Ptr; bufferLength, numeroSlot : SInt32) : boolean;
var wStream : CFWriteStreamRef;
    rStream : CFReadStreamRef;
    bytesSent : CFIndex;
    sent : CFIndex;
    texte : PackedArrayOfCharPtr;
    myCFErr : CFStreamError;
begin

  if (bufferLength <= 0) or (buffer = NIL) then
    begin
      WritelnDansRapport('WARNING : (bufferLength <= 0) or (buffer = NIL) dans SendStringToPermanentConnection');
      SendBytesToPermanentConnection := true;
      exit(SendBytesToPermanentConnection);
    end;

  SendBytesToPermanentConnection := false;

  if ThisSlotUsesAPermanentConnection(numeroSlot) then
    with gListOfFichierAbstraitOfAsynchroneNetworkConnections.table[numeroSlot] do
      begin
        rStream := theReadStream;
        wStream := theWriteStream;

        texte := PackedArrayOfCharPtr(buffer);

        lastTickOfActivity := TickCount;

        // Start off with nothing
        sent := 0;

        // Keep trying to send the data
        while (sent < bufferLength) and CFWriteStreamCanAcceptBytes(wStream) do
          begin
            bytesSent := 0;

            // Try to send
            if texte <> NIL then
              bytesSent := CFWriteStreamWrite(wStream, @texte^[sent], bufferLength - sent);

            // Check to see if an error occurred
            if (bytesSent <= 0) then
              begin
                myCFErr.domain := -888;
                myCFErr.error  := -888;
      			    TerminateDownload( theReadStream , kCFStreamEventErrorOccurred, bytesSent, myCFErr, 'SendBytesToPermanentConnection');
      			    exit(SendBytesToPermanentConnection);
      			  end;

            sent := sent + bytesSent;

          end;

        SendBytesToPermanentConnection := (sent >= bufferLength);
      end;
end;


function SendStringToPermanentConnection(var s : LongString; numeroSlot : SInt32) : boolean;
var buffer : packed array [0..1023] of char;
    nbOctets : SInt32;
begin
  if (LengthOfLongString(s) <= 0)
    then
      begin
        WritelnDansRapport('WARNING :  (s = '') dans SendStringToPermanentConnection');
        SendStringToPermanentConnection := true;
      end
    else
      begin
        if (LENGTH_OF_STRING(s.finLigne) <= 0)
          then
            SendStringToPermanentConnection := SendBytesToPermanentConnection(@s.debutLigne[1], LENGTH_OF_STRING(s.debutLigne), numeroSlot)
          else
            begin
              LongStringToBuffer(s, @buffer[0], nbOctets);
              SendStringToPermanentConnection := SendBytesToPermanentConnection(@buffer[0], nbOctets, numeroSlot);

              (*
              WritelnDansRapport('dans SendStringToPermanentConnection : ');
              WritelnNumDansRapport('      nbOctets = ',nbOctets);
              WritelnDansRapport('      buffer[0] = ' + buffer[0] + buffer[1]);
              WriteDansRapport('      s = ');
              WritelnLongStringDansRapport(s);
              WritelnDansRapport('');
              *)

            end;
      end;
end;


function FindPermanentConnectionToHost( var host : String255; port : SInt32; var numeroSlot : SInt32) : boolean;
var k,index : SInt32;
    hostAndPort : LongString;
begin

  FindPermanentConnectionToHost := false;
  numeroSlot := -1;

  if (host = '') then
    begin
      WritelnDansRapport('ASSERT  !! host = '' dans FindPermanentConnectionToHost ');
      exit(FindPermanentConnectionToHost);
    end;

  hostAndPort := MakeLongString(host + ':' + NumEnString(port));

  with gListOfFichierAbstraitOfAsynchroneNetworkConnections do
    for k := 0 to ((kNumberOfAsynchroneNetworkConnections div 2) + 1) do
      begin


        {un coup en montant... }

        index := lastUsedIndex + k;
        if index > kNumberOfAsynchroneNetworkConnections then index := index - (kNumberOfAsynchroneNetworkConnections + 1);
        if index < 0                                  then index := index + (kNumberOfAsynchroneNetworkConnections + 1);

        if (table[index].theReadStream <> NIL) and
           (table[index].theWriteStream <> NIL) and
           SameLongString(gReserveZonesPourTelecharger.table[index].infoNetworkConnection , hostAndPort) then
          begin

            (*
            WritelnDansRapport('');
            WritelnNumDansRapport('theReadStream         = ', SInt32(table[index].theReadStream));
            WritelnNumDansRapport('theFichierAbstrait = ', SInt32(table[index].theFichierAbstrait));
            WritelnNumDansRapport('dans FindPermanentConnectionToHost, stop = ',index);
            WritelnNumDansRapport('@0 : theReadStream     = ', SInt32(table[0].theReadStream));
            WritelnNumDansRapport('@0 : theFichierAbstrait = ', SInt32(table[0].theFichierAbstrait));
            WritelnDansRapport('');
            *)

            lastUsedIndex      := index;
            numeroSlot         := index;
            FindPermanentConnectionToHost := true;

            exit(FindPermanentConnectionToHost);
          end;



        {un coup en descendant... }

        index := lastUsedIndex - k - 1;
        if index > kNumberOfAsynchroneNetworkConnections then index := index - (kNumberOfAsynchroneNetworkConnections + 1);
        if index < 0                                  then index := index + (kNumberOfAsynchroneNetworkConnections + 1);

        if (table[index].theReadStream <> NIL) and
           (table[index].theWriteStream <> NIL) and
           SameLongString(gReserveZonesPourTelecharger.table[index].infoNetworkConnection , hostAndPort) then
          begin

            (*
            WritelnDansRapport('');
            WritelnNumDansRapport('theReadStream         = ', SInt32(table[index].theReadStream));
            WritelnNumDansRapport('theFichierAbstrait = ', SInt32(table[index].theFichierAbstrait));
            WritelnNumDansRapport('dans FindPermanentConnectionToHost, stop = ',index);
            WritelnNumDansRapport('@0 : theReadStream         = ', SInt32(table[0].theReadStream));
            WritelnNumDansRapport('@0 : theFichierAbstrait = ', SInt32(table[0].theFichierAbstrait));
            WritelnDansRapport('');
            *)

            lastUsedIndex      := index;
            numeroSlot         := index;
            FindPermanentConnectionToHost := true;

            exit(FindPermanentConnectionToHost);
          end;
      end;
end;


function CreateSocketSignatureFromDottedAdress(host : String255; port : UInt16; var sig : CFSocketSignature) : boolean;
begin
  Discard3(host, port, sig);

  CreateSocketSignatureFromDottedAdress := false;

{
  // Check for a dotted-quad address, if so skip any host lookups
  // NOT IMPLEMENTED YET !!

    in_addr_t addr = inet_addr(host);
    if (addr <> INADDR_NONE)
      then
        begin

          // Create the streams from numberical host

          struct sockaddr_in sin;
          memset(andsin, 0, sizeof(sin));

          sin.sin_len =  sizeof(sin);
          sin.sin_family = AF_INET;
          sin.sin_addr.s_addr = addr;
          sin.sin_port = htons(port);

          CFDataRef addressData = CFDataCreate(NULL, (UInt8 *)andsin, sizeof(sin));
          sig = ( PF_INET, SOCK_STREAM, IPPROTO_TCP, addressData );
          CreateSocketOnSig(sig);
          CFRelease(addressData);
        end
      else
        begin
          sig := NIL;
          CreateSocketSignatureFromDottedAdress := false;
        end;
  }
end;


procedure LSOpenURL (url: String255);
var
  urlRef: CFURLRef;
  rawCFString        : CFStringRef	;
	normalizedCFString : CFStringRef	;
	escapedCFString    : CFStringRef	;
	myCFString         : CFStringRef  ;
	err                : OSErr;
label Bail;
begin

  {$ifc defined __GPC__  }

  //	We first create a CFString in a standard URL format, for instance spaces, " ", become "%20" within the string
  //	To do this we normalize the URL first, then create the escaped equivalent
	rawCFString		 :=  CFStringCreateWithPascalString( NIL, StringToStr255(url), CFStringGetSystemEncoding );
	if ( rawCFString = NIL ) then goto Bail;

	myCFString := MakeCFSTR('');
	normalizedCFString	 :=  CFURLCreateStringByReplacingPercentEscapes( NIL, rawCFString, myCFString );
	if (myCFString <> NIL) then CFRelease( CFTypeRef( myCFString ));

	if ( normalizedCFString = NIL ) then goto Bail;


	escapedCFString	 :=  CFURLCreateStringByAddingPercentEscapes( NIL, normalizedCFString, NIL, NIL, kCFStringEncodingUTF8 );
	if ( escapedCFString = NIL ) then goto Bail;

	urlRef :=  CFURLCreateWithString( kCFAllocatorDefault, escapedCFString, NIL );

	if (rawCFString <> NIL)        then CFRelease( CFTypeRef( rawCFString ) );
	if (normalizedCFString <> NIL) then CFRelease( CFTypeRef( normalizedCFString ) );
	if (escapedCFString <> NIL)    then CFRelease( CFTypeRef( escapedCFString ) );

	if ( urlRef = NIL ) then goto Bail;


  if urlRef <> nil then
    begin
      err := LSOpenCFURLRef(urlRef, nil);
      CFRelease(CFTypeRef(urlRef));
   end;

  {$elsec}

  // LSOpenCFURLRef pas encore implementé sur la version PowerPC

  Discard3(url,urlRef,rawCFString);
  Discard4(normalizedCFString,escapedCFString,myCFString,err);

  {$endc}

  Bail :
end;




END.




























