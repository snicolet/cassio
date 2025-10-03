UNIT MyKeyMapUtils;


INTERFACE


 USES UnitDefCassio;

	procedure MyGetKeys(var theKeys : myKeyMap);                                                                                                                                       ATTRIBUTE_NAME('MyGetKeys')
	function ToucheAppuyee(KeyCode : SInt16) : boolean;                                                                                                                                ATTRIBUTE_NAME('ToucheAppuyee')
	function MemesTouchesAppuyees(var keyMap1, keyMap2 : myKeyMap) : boolean;                                                                                                          ATTRIBUTE_NAME('MemesTouchesAppuyees')


IMPLEMENTATION






procedure MyGetKeys(var theKeys : myKeyMap);
	type
		myKeyMapPtr = ^myKeyMap;
	var
		aux : KeyMap;
		aux2 : myKeyMapPtr;
begin
	GetKeys(aux);
	aux2 := myKeyMapPtr(@aux);
	theKeys := aux2^;
end;

function ToucheAppuyee(KeyCode : SInt16) : boolean;
	var
		theKeys : myKeyMap;
		i, j : SInt16;
		b, masque : SInt16;
begin
	MyGetKeys(theKeys);
	i := keyCode div 8;
	j := keyCode mod 8;
	b := theKeys[i];
	masque := BSl(1, j);
	ToucheAppuyee := BAnd(b, masque) <> 0;
end;

function MemesTouchesAppuyees(var keyMap1, keyMap2 : myKeyMap) : boolean;
	var
		i : SInt16;
begin
	for i := 0 to 15 do
		if keyMap1[i] <> keyMap2[i] then
			begin
				MemesTouchesAppuyees := false;
				exit(MemesTouchesAppuyees);
			end;
	MemesTouchesAppuyees := true;
end;



END.
