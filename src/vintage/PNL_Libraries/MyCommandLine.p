UNIT MyCommandLine;


INTERFACE







uses MacTypes, StringTypes;

function Get_program_name : String255;
function Get_command_line(program_name : String255) : String255;
function Command_line_param_count : SInt16;
function Get_command_line_parameter(param_number : SInt16) : String255;



IMPLEMENTATION







uses SNEvents,UnitDefFichiersTEXT,MyTypes,MyStrings,Sound,UnitFichiersTEXT;



function GetApplicationName(default : String255) : String255;       EXTERNAL_NAME('GetApplicationName');




const option_extension = '.options';


const last_warning : String255 = 'foo_barr';

procedure Command_line_warning;
var program_name : String255;
begin
  program_name := Get_program_name;
  if program_name <> last_warning then
    begin
      last_warning := program_name;
  	  DisplayMessageInConsole('');
  	  DisplayMessageInConsole('WARNING : You should put a file named "'+program_name+option_extension+'"');
  	  DisplayMessageInConsole('          in the '+program_name+' directory. This file should contain');
  	  DisplayMessageInConsole('          a single Unix-like line, as follows (with the quotes) :');
  	  DisplayMessageInConsole('');
  	  DisplayMessageInConsole('          command_line = "'+program_name+'" [options and parameters]');
  	  DisplayMessageInConsole('');
  	end;
end;


function Get_program_name : String255;
begin
  Get_program_name := GetApplicationName('');
end;


function Get_command_line(program_name : String255) : String255;
var s,s1,s2,s3,result : String255;
    err : OSErr;
    fic : FichierTEXT;
    temp : boolean;
    oldParsingSet : SetOfChar;
begin

  err := FichierTexteExiste(program_name+option_extension,0,fic);
  if err<>NoErr then
    begin
      Command_line_warning;
      Get_command_line := program_name;
      exit(Get_command_line);
    end;

  result := '';
  err := OuvreFichierTexte(fic);
  while (err=0) & not(EOFFichierTexte(fic,err)) & (result = '') do
    begin
      err := ReadlnDansFichierTexte(fic,s);

      temp := GetParsingProtectionWithQuotes;
      oldParsingSet := GetParsingCaracterSet;

      SetParsingProtectionWithQuotes(true);
      SetParsingCaracterSet([' ',tab]);
      if Pos('command_line = ',s) > 0 then Parser2(s,s1,s2,result) else
      if Pos('command_line= ',s) > 0 then Parser(s,s1,result)     else
      if Pos('command-line = ',s) > 0 then Parser2(s,s1,s2,result) else
      if Pos('command line = ',s) > 0 then Parser3(s,s1,s2,s3,result);

      SetParsingProtectionWithQuotes(temp);
      SetParsingCaracterSet(oldParsingSet);
    end;
  err := FermeFichierTexte(fic);

  result := EnleveEspacesDeGauche(result);
  result := EnleveEspacesDeDroite(result);

  if (result = '') then
    begin
      Command_line_warning;
      Get_command_line := program_name;
      exit(Get_command_line);
    end;

  Get_command_line := result;
end;


function Command_line_param_count : SInt16;
var command_line,program_name,s : String255;
    count : SInt16;
    temp : boolean;
begin
  program_name := Get_program_name;
  command_line := Get_command_line(program_name);


  temp := GetParsingProtectionWithQuotes;
  SetParsingProtectionWithQuotes(true);
  count := -1;
  while (command_line<>'') & (count<10000) do
    begin
      Parser(command_line,s,command_line);
      count := count+1;
    end;
  SetParsingProtectionWithQuotes(temp);

  (* error, should never happen *)
  if count >= 10000 then
    begin
      SysBeep(0);
      DisplayMessageInConsole('ERROR in Command_line_param_count : count >= 10000');
    end;

  if count < 0 then
    begin
      Command_line_warning;
      count := 0;
    end;

  Command_line_param_count := count;
end;


function Get_command_line_parameter(param_number : SInt16) : String255;
var program_name,command_line,s : String255;
    i : SInt16;
    temp : boolean;
begin

  program_name := Get_program_name;
  command_line := Get_command_line(program_name);

  if (command_line = '') then
    begin
      Command_line_warning;
      if param_number=0
        then Get_command_line_parameter := program_name
        else Get_command_line_parameter := '';
      exit(Get_command_line_parameter);
    end;

  if param_number < 0 then
    begin
      DisplayMessageInConsole('ERROR in Get_command_line_parameter : param_number < 0');
      Get_command_line_parameter := '';
      exit(Get_command_line_parameter);
    end;


  s := '';
  temp := GetParsingProtectionWithQuotes;
  SetParsingProtectionWithQuotes(true);
  i := -1;
  repeat
    Parser(command_line,s,command_line);
    i := i+1;
  until (i >= param_number) | (command_line='');
  SetParsingProtectionWithQuotes(temp);

  if (command_line = '') & (i<param_number) then
    begin
      DisplayMessageInConsole('ERROR in Get_command_line_parameter : param_number > Command_line_param_count');
      Get_command_line_parameter := '';
      exit(Get_command_line_parameter);
    end;

  Get_command_line_parameter := s;

end;


END.