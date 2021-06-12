program cassio;

// compile with FreePascal using the commands:
//    fpc -Mobjfpc -ocassio.exe cassio.pas


uses  
  Classes, 
  SysUtils, 
  LauncherTask;



begin
	
	
	writeln('Bienvenue dans Cassio !');
	
	
	runTask('./carbon.py');
	
end.


