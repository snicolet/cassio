UNIT SNEvents;



INTERFACE


 USES UnitDefCassio , QuickDraw;



  function EstUnDoubleClic(myEvent : eventRecord; attendClicSuivant : boolean) : boolean;                                                                                           ATTRIBUTE_NAME('EstUnDoubleClic')
  procedure ShareTimeWithOtherProcesses(quantity : SInt32);                                                                                                                         ATTRIBUTE_NAME('ShareTimeWithOtherProcesses')

	procedure AttendFrappeClavier;                                                                                                                                                     ATTRIBUTE_NAME('AttendFrappeClavier')
	procedure AttendFrappeClavierOuSouris(var isKeyEvent : boolean);                                                                                                                   ATTRIBUTE_NAME('AttendFrappeClavierOuSouris')
	function EscapeDansQueue : boolean;                                                                                                                                                ATTRIBUTE_NAME('EscapeDansQueue')

  function CreerCaractereAvecOption(c : char) : char;   {si c = T, CreerCaractereAvecOption(c) = option-T = ™   etc.}                                                               ATTRIBUTE_NAME('CreerCaractereAvecOption')
	function QuelCaractereDeControle(c : char; enMajuscule : boolean) : char;                                                                                                          ATTRIBUTE_NAME('QuelCaractereDeControle')
	procedure EmuleToucheCommandeParControleDansEvent(var myEvent : eventRecord);                                                                                                      ATTRIBUTE_NAME('EmuleToucheCommandeParControleDansEvent')
	function DirtyKey (ch : char) : boolean;                                                                                                                                           ATTRIBUTE_NAME('DirtyKey')


	procedure Pause;                                                                                                                                                                   ATTRIBUTE_NAME('Pause')





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    ToolUtils, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitGestionDuTemps ;
{$ELSEC}
    ;
    {$I prelink/SNEvents.lk}
{$ENDC}


{END_USE_CLAUSE}







function EstUnDoubleClic(myEvent : eventRecord; attendClicSuivant : boolean) : boolean;
var test : boolean;
    NextEvent : eventRecord;
    arretAttente : SInt32;
begin
  with myEvent do
    begin
      test := (Abs(EmplacementDernierClic.h-where.h) <= 3) &
            (Abs(EmplacementDernierClic.v-where.v) <= 3) &
            ((when-instantDernierClic) <= GetDblTime);
      EstUnDoubleClic := test;
    end;
  if not(test) then
     begin
       EmplacementDernierClic := myEvent.where;
       instantDernierClic := myEvent.when;
       if attendClicSuivant then
         begin
           arretAttente := instantDernierClic + GetDblTime;
           repeat
           until (TickCount >= arretAttente) | EventAvail(mDownMask,NextEvent);
         end;
       if EventAvail(mDownMask,NextEvent) then
         begin
           test := (Abs(EmplacementDernierClic.h-NextEvent.where.h) <= 2) &
                 (Abs(EmplacementDernierClic.v-NextEvent.where.v) <= 2) &
                 ((NextEvent.when-instantDernierClic) <= GetDblTime);
           if test then
             begin
               if GetNextEvent(mDownMask,NextEvent) then DoNothing;
               EstUnDoubleClic := true;
             end;
         end;
     end;
end;






procedure Pause;
begin
	while Button do DoNothing;
	while not Button do DoNothing;
	FlushEvents(MDownmask + MupMask, 0);
end;




procedure ShareTimeWithOtherProcesses(quantity : SInt32);
var bidbool : boolean;
    bidEvent : eventRecord;
begin
  bidbool := WaitNextEvent(0,bidEvent,quantity,NIL);
end;






function EscapeDansQueue : boolean;
	var
		myLocalEvent : eventrecord;
begin
	EscapeDansQueue := false;
	if EventAvail(KeyDownMask+AutoKey, myLocalEvent) then
		begin
			if BAnd(myLocalEvent.message, charCodeMask) = EscapeKey then   {27 = escape}
				begin
					EscapeDansQueue := true;
					exit(EscapeDansQueue);
				end;

			if BAnd(myLocalEvent.modifiers, cmdKey) <> 0 then        {commande-point}
				if BAnd(myLocalEvent.message, charCodeMask) = ord('.') then
					begin
						EscapeDansQueue := true;
						exit(EscapeDansQueue);
					end;

		  if BAnd(myLocalEvent.modifiers, cmdKey) <> 0 then        {commande-q}
				if BAnd(myLocalEvent.message, charCodeMask) = ord('q') then
					begin
						EscapeDansQueue := true;
						exit(EscapeDansQueue);
					end;

			if BAnd(myLocalEvent.modifiers, cmdKey) <> 0 then        {commande-Q}
				if BAnd(myLocalEvent.message, charCodeMask) = ord('Q') then
					begin
						EscapeDansQueue := true;
						exit(EscapeDansQueue);
					end;
		end;
end;





procedure AttendFrappeClavier;
	var isKeyEvent : boolean;
		  event : eventRecord;
		  theChar : char;
begin
	FlushEvents(everyEvent, 0);

	repeat
	until GetNextEvent(KeyDownMask + MDownMask, event);

	isKeyEvent := (event.what = keyDown) | (event.what = autoKey);
	theChar := chr(BAnd(event.message,charCodemask));

	if (theChar = 'q') | (theChar = 'Q') then
	  begin
	    Quitter := true;
	    LanceInterruptionSimple('AttendFrappeClavier');
	  end;

	FlushEvents(everyEvent, 0);
end;

procedure AttendFrappeClavierOuSouris(var isKeyEvent : boolean);
	var theChar : char;
		  event : eventRecord;
begin
	FlushEvents(everyEvent, 0);

	repeat
	until GetNextEvent(KeyDownMask + MDownMask, event);

	isKeyEvent := (event.what = keyDown) | (event.what = autoKey);
	theChar := chr(BAnd(event.message,charCodemask));

	if (theChar = 'q') | (theChar = 'Q') then
	  begin
	    Quitter := true;
	    LanceInterruptionSimple('AttendFrappeClavier');
	  end;

	FlushEvents(everyEvent, 0);
end;



function QuelCaractereDeControle(c : char; enMajuscule : boolean) : char;  { si c =  ^H, QuelCaractereDeControle(c) = H  etc.}
	var
		codeAscii : SInt16;
begin
	codeAscii := ord(c);
	if (codeAscii < 1) | (codeAscii > 26) then
		QuelCaractereDeControle := c
	else if enMajuscule then
		QuelCaractereDeControle := chr(codeAscii + ord('A') - 1)
	else
		QuelCaractereDeControle := chr(codeAscii + ord('a') - 1);
end;


function CreerCaractereAvecOption(c : char) : char;   {si c = T, CreerCaractereAvecOption(c) = option-T = ™   etc.}
begin
	case c of
		'a' :
			CreerCaractereAvecOption := 'æ';
		'b' :
			CreerCaractereAvecOption := 'ß';
		'c' :
			CreerCaractereAvecOption := '©';
		'd' :
			CreerCaractereAvecOption := '∂';
		'e' :
			CreerCaractereAvecOption := 'ê';
		'f' :
			CreerCaractereAvecOption := 'ƒ';
		'g' :
			CreerCaractereAvecOption := 'ﬁ';
		'h' :
			CreerCaractereAvecOption := 'Ì';
		'i' :
			CreerCaractereAvecOption := 'î';
		'j' :
			CreerCaractereAvecOption := 'Ï';
		'k' :
			CreerCaractereAvecOption := 'È';
		'l' :
			CreerCaractereAvecOption := '¬';
		'm' :
			CreerCaractereAvecOption := 'µ';
		'n' :
			CreerCaractereAvecOption := '~';
		'o' :
			CreerCaractereAvecOption := 'œ';
		'p' :
			CreerCaractereAvecOption := 'π';
		'q' :
			CreerCaractereAvecOption := '‡';
		'r' :
			CreerCaractereAvecOption := '®';
		's' :
			CreerCaractereAvecOption := 'Ò';
		't' :
			CreerCaractereAvecOption := '†';
		'u' :
			CreerCaractereAvecOption := 'º';
		'v' :
			CreerCaractereAvecOption := '◊';
		'w' :
			CreerCaractereAvecOption := '‹';
		'x' :
			CreerCaractereAvecOption := '≈';
		'y' :
			CreerCaractereAvecOption := 'Ú';
		'z' :
			CreerCaractereAvecOption := 'Â';
		'A' :
			CreerCaractereAvecOption := 'Æ';
		'B' :
			CreerCaractereAvecOption := '∫';
		'C' :
			CreerCaractereAvecOption := '¢';
		'D' :
			CreerCaractereAvecOption := '∆';
		'E' :
			CreerCaractereAvecOption := 'Ê';
		'F' :
			CreerCaractereAvecOption := '·';
		'G' :
			CreerCaractereAvecOption := 'ﬂ';
		'H' :
			CreerCaractereAvecOption := 'Î';
		'I' :
			CreerCaractereAvecOption := 'ï';
		'J' :
			CreerCaractereAvecOption := 'Í';
		'K' :
			CreerCaractereAvecOption := 'Ë';
		'L' :
			CreerCaractereAvecOption := '|';
		'M' :
			CreerCaractereAvecOption := 'Ó';
		'N' :
			CreerCaractereAvecOption := 'ı';
		'O' :
			CreerCaractereAvecOption := 'Œ';
		'P' :
			CreerCaractereAvecOption := '∏';
		'Q' :
			CreerCaractereAvecOption := 'Ω';
		'R' :
			CreerCaractereAvecOption := '€';
		'S' :
			CreerCaractereAvecOption := '∑';
		'T' :
			CreerCaractereAvecOption := '™';
		'U' :
			CreerCaractereAvecOption := 'ª';
		'V' :
			CreerCaractereAvecOption := '√';
		'W' :
			CreerCaractereAvecOption := '›';
		'X' :
			CreerCaractereAvecOption := '⁄';
		'Y' :
			CreerCaractereAvecOption := 'Ÿ';
		'Z' :
			CreerCaractereAvecOption := 'Å';
		otherwise
			CreerCaractereAvecOption := c;
	end; {case}
end;


procedure EmuleToucheCommandeParControleDansEvent(var myEvent : eventrecord);  {émulation de la pomme avec la touche ctrl}
	var
		option, shift, verouillage : boolean;
		ch, aux : char;
begin
	if (BAnd(myEvent.modifiers, controlKey) <> 0) & (BAnd(myEvent.modifiers, cmdKey) = 0) then
		begin
			shift := BAnd(myEvent.modifiers, shiftKey) <> 0;
			verouillage := BAnd(myEvent.modifiers, alphaLock) <> 0;
			option := BAnd(myEvent.modifiers, optionKey) <> 0;

      {modification de l'evenement}
			myEvent.modifiers := BitXor(myEvent.modifiers, controlKey);
			myEvent.modifiers := BitXor(myEvent.modifiers, cmdKey);

			if (myEvent.what = keyDown) | (myEvent.what = autoKey) | (myEvent.what = keyUp) then
				begin
					ch := chr(BAnd(myEvent.message, charCodeMask));
					aux := QuelCaractereDeControle(ch, shift | verouillage);
					if option & (((aux >= 'a') & (aux <= 'z')) | ((aux >= 'A') & (aux <= 'Z'))) then
						aux := CreerCaractereAvecOption(aux);

					myEvent.message := BitAnd(myEvent.message, BitNot(charCodeMask));
					myEvent.message := BitOr(myEvent.message, ord(aux));
				end;

		end;
end;



function DirtyKey (ch : char) : boolean;
	begin
		DirtyKey := not (ord(ch) in [homeChar, endChar, helpChar, pageUpChar, pageDownChar, leftArrowChar, rightArrowChar, upArrowChar, downArrowChar]);
	end;




END.
