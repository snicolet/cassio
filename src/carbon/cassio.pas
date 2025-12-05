program cassio;

// usage : compile with FreePascal using the following command
//    fpc -Mobjfpc -Sh -ocassio.exe cassio.pas
//    fpc -Mobjfpc -Sh -ocassio.exe cassio.pas 2>&-        (to suppress link warnings)
//    fpc -Mobjfpc -Sh -k"-macosx_version_min 10.13" -ocassio.exe cassio.pas


uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  Classes,
  SysUtils,
  Process,
  Connect,
  BasicTypes,
  QuickdrawTypes,
  QuickDraw,
  QuickdrawCommunications; 


// global variables
var carbon     : Task;



// FormatTimer(N, duration) returns a string with timing information.
// parameters : N = number of function calls
//              duration = time in milliseconds
function FormatTimer(N, duration : SInt64) : AnsiString;
begin
    if duration <= 0 
        then result := format('time = %dms  :  ', [duration])
        else result := format('%d calls/sec  :  ', [1000 * N div duration]);
end;

// MainLoop is our main loop for Cassio
procedure MainLoop();
var
   s           : AnsiString;
   counter     : SInt64;
   tick, start : SInt64;
   loc         : Point;
   k, r, N     : SInt64;
   rapport     : WindowPtr;
   behind      : WindowPtr;
   oldPort     : grafPtr;
begin
    rapport := MakeWindow();
    tick := Tickcount();
    
    counter := -1;
	repeat
	   counter := counter + 1;

	   ReadTaskOutput(carbon);

	   // test 1 : send a bunch of dummy "hello" commands, all at the same time
	   if (counter = 0) then
	   begin
	      SendCommand('init');
	      for k := 1 to 9 do
	         SendCommand('hello ' + IntToStr(k));
	   end;

	   // test 2 : send a bunch of dummy "hola" commands, at 1ms intervals
	   if (counter >= 0) and (counter < 10) then
	   begin
	      s := 'hola ' + IntToStr(counter) ;
          SendCommand(s);
       end;

       // sleep(n) yields time to the operating system, where n is in milliseconds
       // with sleep(0)  : Cassio uses about 100% of one processor
       // with sleep(1)  : Cassio uses about 2.4% of one processor
       // with sleep(10) : Cassio uses about 0.1% of one precessor
       // See also the FpNanoSleep() function
       sleep(1);

       //writeln('blah : ', Tickcount(), ' ', Tickcount() - tick);

       if false and (Tickcount() > 300) and (Tickcount() - tick >= 6) then
       begin
          tick := Tickcount();
          start := Milliseconds;
          N := 100;
          for k := 1 to N do
             loc := GetMouse2();
          writeln( FormatTimer(N, Milliseconds() - start) );
          //if (abs(loc.h) < 0) then
             writeln(loc.h, ' ' , loc.v);
       end;

       if false and (Tickcount() > 300) and (Tickcount() - tick >= 5) then
       begin
          tick := Tickcount();
          loc := GetMouse();
          if (abs(loc.h) < 0) then
             writeln(loc.h, ' ' , loc.v);
       end;

       if false and (Tickcount() > 300) and (Tickcount() - tick >= 300) then
       begin
          tick := Tickcount();
          start := Milliseconds;
          N := 100;
          for k := 1 to N do
             r := QDRandom();

          writeln(FormatTimer(N, Milliseconds() - start), '  r = ', r);
       end;
       
       if false and (Tickcount() > 300) and (Tickcount() - tick >= 300) then
       begin
          tick := Tickcount();
          start := Milliseconds;
          N := 10000;
          for k := 1 to N do
             s := QDEcho('''Il est 4 heures et la cloche sonne''');

          writeln(FormatTimer(N, Milliseconds() - start), '  s = ', s);
       end;

       if false and (Tickcount() = 630) then
       begin
          s := OpenFileDialog('Choisissez un fichier', '', 'Images (*.png *.jpg *.jpeg)');
          writeln(s);
       end;

       if  (Tickcount() = 300) and (rapport = None) then
       begin
          rapport := NewWindow(MakeRect(200,300,400,700), 'Liste de parties', true, behind, true);
       end;
       
       if  (Tickcount() = 600) and (rapport <> None) then
       begin
          GetPort(oldPort);
          SetPort(rapport);
          SetPort(oldPort);
       end;

    until QuickdrawServerHasQuit() or (Milliseconds() > 300000);
end;



// Main()
begin
    //Halt();

    LogDebugInfo('Bienvenue dans Cassio !');
	LogDebugInfo('Milliseconds is ' + IntToStr(Milliseconds()));

	InitQuickdraw(carbon);

	sleep(200);

    try
        MainLoop();
    except
      on E: Exception do
         Writeln('An exception was raised: ' + E.Message);
    end;

	ReleaseQuickDraw;

end.


