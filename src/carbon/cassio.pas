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


var
   carbon     : Task;
   s          : ansistring;
   counter    : integer;
   tick       : qword;
   loc        : Point;
   k          : integer;
   r          : SInt64;
   start      : SInt64;


// MainLoop is our main loop for Cassio
procedure MainLoop();
begin
    counter := -1;
	repeat
	   counter := counter + 1;

	   ReadTaskOutput(carbon);

	   // test 1 : send a bunch of dummy "hello" commands, all at the same time
	   if (counter = 0) then
	      for k := 1 to 9 do
	         SendCommand('hello ' + IntToStr(k) , NIL, NIL);

	   // test 2 : send a bunch of dummy "hola" commands, at 1ms intervals
	   if (counter >= 0) and (counter < 10) then
	   begin
	      s := 'hola ' + IntToStr(counter) ;
          SendCommand(s, NIL, NIL);
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
          for k := 1 to 100 do
             loc := GetMouse2();
          writeln('time = ', Milliseconds() - start);
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
          for k := 1 to 1 do
             r := QDRandom();
          writeln('time = ', Milliseconds() - start, '  r = ', r);
       end;
       
       if true and (Tickcount() > 300) and (Tickcount() - tick >= 300) then
       begin
          tick := Tickcount();
          start := Milliseconds;
          for k := 1 to 100 do
             s := QDEcho('Il est 4 heures et la cloche sonnne');
          writeln('time = ', Milliseconds() - start, '  s = ', s);
       end;



       if false and (Tickcount() = 630) then
       begin
          s := OpenFileDialog('Choisissez un fichier', '', 'Images (*.png *.jpg *.jpeg)');
          writeln(s);
       end;

    until false or (Milliseconds() > 300000);
end;



// Main()
begin

    //Halt();

    tick := Tickcount();

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


