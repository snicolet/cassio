UNIT MyStripTelnetCodes;

INTERFACE


USES MacTypes,StringTypes;

	const
		T_WILL = chr(251);
		T_WONT = chr(252);
		T_DO = chr(253);
		T_DONT = chr(254);
		T_IAC = chr(255);

	procedure StripTelnetCodes (var s : String255);




IMPLEMENTATION




	const
		nul = chr(0);

	procedure StripTelnetCodes (var s : String255);
		var
			i : SInt16; 
	begin
		i := 1;
		while i < LENGTH_OF_STRING(s) do begin
			case s[i] of
				T_IAC:  begin
					case s[i + 1] of
						T_IAC:  begin
							Delete(s, i, 1);
							i := i + 1;
						end;
						T_WILL, T_WONT, T_DO, T_DONT:  begin
							if i < LENGTH_OF_STRING(s) - 1 then begin
								Delete(s, i, 3);
							end else begin
								leave;
							end;
						end;
						otherwise
							Delete(s, i, 2);
					end;
				end;
				nul: 
					Delete(s, i, 1);
				otherwise
					i := i + 1;
			end;
		end;
	end;

end.