UNIT SNMenus;


INTERFACE


 USES UnitDefCassio, Menus;



  function MyGetMenu(resourceID : SInt16) : MenuRef;
	procedure MyLockMenu(theMenu : MenuRef);
  procedure MyUnlockMenu(theMenu : MenuRef);
	procedure TerminateMenu(var theMenu : MenuRef; provientDUneResource : boolean);

	procedure MyGetMenuItemText( theMenu : MenuRef; item : MenuItemIndex; var itemString : String255 );
  procedure MySetMenuItemText( theMenu : MenuRef; item : MenuItemIndex; const itemString : String255 );
  procedure MyInsertMenuItem( theMenu: MenuRef; const itemString: String255; afterItem: MenuItemIndex );

  procedure MyAppendMenu( menu: MenuRef; const data: String255 );

	function InMenuCmdSet(item : SInt16; commands : menuCmdSet) : boolean;
	procedure EnableMenu(mh : MenuRef; commands : menuCmdSet);
	procedure DisableMenu(mh : MenuRef; commands : menuCmdSet);
	procedure FixEditMenu(enablecommands : boolean);
	procedure CloseDAwindow;
	function GetAppleMenu : MenuRef;
	function GetFileMenu : MenuRef;
	function GetEditMenu : MenuRef;
	procedure SetAppleMenu(whichMenu : MenuRef);
  procedure SetFileMenu(whichMenu : MenuRef);
  procedure SetEditMenu(whichMenu : MenuRef);

  procedure DoAppleMenuCommands(cmdnumber : SInt16);
	procedure AjouteEspacesItemsMenu(theMenu : MenuRef; nbEspaces : SInt16);
  procedure EnleveEspacesDeDroiteItemsMenu(theMenu : MenuRef);
	function EventPopUpItem(theMenu : MenuRef; var numItem : SInt16; menuRect : Rect; drawChoice, checkChoice : Boolean) : boolean;
	function EventPopUpItemInDialog(dp : DialogPtr; menuTitleItem : SInt16; theMenu : MenuRef; var numItem : SInt16; menuRect : Rect; drawChoice, checkChoice : Boolean) : boolean;
	procedure DrawPUItem(theMenu : MenuRef; item : SInt16; loc : Rect; drawMark : boolean);
	function NewMenuFlottant(whichID : SInt32; whichrect : Rect; whichItem : SInt16) : MenuFlottantRec;
	procedure SetItemMenuFlottant(var whichMenuFlottant : MenuFlottantRec; whichItem : SInt16; var change : boolean);
  procedure SetFontMenuFlottant(var whichMenuFlottant : MenuFlottantRec; fontID : SInt16; fontSize : UInt16);
  procedure CheckOnlyThisItem(var whichMenuFlottant : MenuFlottantRec; whichItem : SInt16);
  procedure EffaceMenuFlottant(var whichMenuFlottant : MenuFlottantRec);
  procedure CalculateMenuFlottantSize(var whichMenuFlottant : MenuFlottantRec);
  procedure DrawPUItemMenuFlottant(var whichMenuFlottant : MenuFlottantRec; drawMark : boolean);
  procedure CalculateMenuFlottantControl(var whichMenuFlottant : MenuFlottantRec; whichWindow : WindowPtr);
	procedure InstalleMenuFlottant(var whichMenuFlottant : MenuFlottantRec; whichWindow : WindowPtr);
	procedure DesinstalleMenuFlottant(var whichMenuFlottant : MenuFlottantRec);
	function EventPopUpItemMenuFlottant(var whichMenuFlottant : MenuFlottantRec; drawChoice, checkChoiceBefore,checkChoiceAfter : Boolean) : boolean;

	procedure EnableAppleMenuForDialog(nombreItemsAGriser : SInt16);

	procedure DisplayAboutBox;








IMPLEMENTATION


{BEGIN_USE_CLAUSE}

{$DEFINEC USE_PRELINK true}

USES
    ToolUtils, MacWindows, QuickdrawText, Fonts
{$IFC NOT(USE_PRELINK)}
    , UnitCarbonisation, MyStrings, MyQuickDraw
    , MyFonts, SNEvents ;
{$ELSEC}
    ;
    {$I prelink/SNMenus.lk}
{$ENDC}


{END_USE_CLAUSE}









function MyFenetreFictiveAvantPlan : WindowPtr;
begin
  MyFenetreFictiveAvantPlan := MAKE_MEMORY_POINTER(-1);
end;


procedure EnableAppleMenuForDialog;
	var
		i : SInt16;
begin
	if applemenu <> NIL then
		begin
			MyEnableItem(applemenu, 0);
			for i := 1 to nombreItemsAGriser do
				MyDisableItem(applemenu, i);
		end;
end;


procedure DoAppleMenuCommands;
	var
		DAName : String255;
		result : SInt16;    {ignore}
begin {$UNUSED DAName, result}
	if cmdNumber = aboutCmd then
		DisplayAboutBox
	else
		begin
		end;
end;


procedure TerminateMenu(var theMenu : MenuRef; provientDUneResource : boolean);
begin {$UNUSED provientDUneResource}
  if (theMenu <> NIL) then
    begin
      DisposeMenu(theMenu);
      theMenu := NIL;
    end;
end;

procedure MyLockMenu(theMenu : MenuRef);
begin {$UNUSED theMenu}
end;

procedure MyUnlockMenu(theMenu : MenuRef);
begin {$UNUSED theMenu}
end;

function MyGetMenu(resourceID : SInt16) : MenuRef;
begin
  MyGetMenu := GetMenu(resourceID);
end;


procedure MyGetMenuItemText( theMenu : MenuRef; item : MenuItemIndex; var itemString : String255 );
var s : str255;
begin
  GetMenuItemText(theMenu, item, s);
  itemString := MyStr255ToString(s);
end;


procedure MySetMenuItemText( theMenu : MenuRef; item : MenuItemIndex; const itemString : String255 );
begin
  SetMenuItemText(theMenu, item, StringToStr255(itemString));
end;


procedure MyInsertMenuItem( theMenu: MenuRef; const itemString: String255; afterItem: MenuItemIndex );
begin
  InsertMenuItem(theMenu, StringToStr255(itemString), afterItem);
end;


procedure MyAppendMenu( menu: MenuRef; const data: String255 );
begin
  AppendMenu(menu, StringToStr255(data));
end;


procedure AjouteEspacesItemsMenu(theMenu : MenuRef; nbEspaces : SInt16);
var i,n : SInt16;
    s : String255;
begin
  InitUnitMacExtras(false);

  if (theMenu <> NIL) then
    for i := 1 to MyCountMenuItems(theMenu) do
      begin
        MyGetMenuItemText(theMenu,i,s);
        s := EnleveEspacesDeDroite(s);
        for n := 1 to nbEspaces do
          s := Concat(s,CharToString(' '));
        MySetMenuItemText(theMenu,i,s);
      end;
end;

procedure EnleveEspacesDeDroiteItemsMenu(theMenu : MenuRef);
var i,nbEspacesEnleves : SInt16;
    s : String255;
begin
  if (theMenu <> NIL) then
    for i := 1 to MyCountMenuItems(theMenu) do
      begin
        MyGetMenuItemText(theMenu,i,s);
        EnleveEtCompteEspacesDeDroite(s,nbEspacesEnleves);
        if (nbEspacesEnleves > 0) then
          MySetMenuItemText(theMenu,i,s);
      end;
end;



function EventPopUpItem(theMenu : MenuRef; var numItem : SInt16; menuRect : Rect; drawChoice, checkChoice : Boolean) : boolean;
	var
		r : Rect;
		c : SInt16;
		choice : SInt32;
		ps : PenState;
		alreadyInList : Boolean;
		{savedState : SInt8;}
begin
	GetPenState(ps);
	PenNormal;

	{if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant MyLockMenu');}

	MyLockMenu(theMenu);

	{if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant GetMenuHandle');}

	alreadyInList := (GetMenuHandle(GetMenuID(theMenu)) <> NIL);

	{if unit_MacExtras_debuggage then WritelnStringAndBoolDansRapport('dans EventPopUpItem : alreadyInList = ',alreadyInList);}

	if not alreadyInList then
		InsertMenu(theMenu, -1);
	r := menuRect;
	LocalToGlobal(r.topLeft);
	c := numItem;
	if checkChoice then
		MyCheckItem(theMenu, c, True);

  {if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant MyUnlockMenu');}

  MyUnlockMenu(theMenu);

  {if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant AjouteEspacesItemsMenu');}

  {if not(gIsRunningUnderMacOSX) then}
    AjouteEspacesItemsMenu(theMenu,1);

  {if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant PopUpMenuSelect');
  if unit_MacExtras_debuggage then WritelnNumDansRapport('  Éavant PopUpMenuSelect , theMenu = ',SInt32(theMenu));
  if unit_MacExtras_debuggage then WritelnNumDansRapport('  Éavant PopUpMenuSelect , r.top = ',r.top);
  if unit_MacExtras_debuggage then WritelnNumDansRapport('  Éavant PopUpMenuSelect , r.left = ',r.left);
  if unit_MacExtras_debuggage then WritelnNumDansRapport('  Éavant PopUpMenuSelect , numItem = ',numItem);}

	choice := PopUpMenuSelect(theMenu, r.top, r.left, numItem);

	{if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant EnleveEspacesDeDroiteItemsMenu');}

	EnleveEspacesDeDroiteItemsMenu(theMenu);

	{if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant HLockState');}

	MyLockMenu(theMenu);

	{if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant MyCheckItem');}

	if checkChoice then
		MyCheckItem(theMenu, c, False);

  {if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant if HiWord(choice) = theMenu^^.menuId');}

	if (HiWord(choice) = GetMenuID(theMenu)) and (LoWord(choice) <> 0)
	  then
	    begin
	      {if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant EventPopUpItem := true');}
	      numItem := LoWord(choice);
	      EventPopUpItem := true;
	    end
	  else
	    begin
	      {if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant EventPopUpItem := false');}
	      EventPopUpItem := false;
	    end;

	{if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant DrawPUItem');}

	if drawChoice then
		DrawPUItem(theMenu, numItem, menuRect, true);

  {if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : avant DeleteMenu');}

	if not alreadyInList then
		DeleteMenu(GetMenuID(theMenu));

	MyUnlockMenu(theMenu);

	SetPenState(ps);

	{if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItem : sortie');}

end;


function EventPopUpItemInDialog(dp : DialogPtr; menuTitleItem : SInt16; theMenu : MenuRef; var numItem : SInt16; menuRect : Rect; drawChoice, checkChoice : Boolean) : boolean;
	var
		itemType : SInt16;
		itemHandle : handle;
		titleRect : rect;
begin
	GetDialogItem(dp, menuTitleItem, itemType, itemHandle, titleRect);
	EventPopUpItemInDialog := EventPopUpItem(theMenu, numItem, menuRect, drawChoice, checkchoice);
end;


procedure DrawPUItem(theMenu : MenuRef; item : SInt16; loc : Rect; drawMark : boolean);
var theMenuID : SInt16;
    currentPort : grafPtr;
    myControl : ControlHandle;
    menuFontID : SInt16;
    menuFontSize : UInt16;
begin  {$UNUSED drawMark}
  GetPort(currentPort);
  if (theMenu <> NIL) and (currentPort <> NIL) then
    begin
      theMenuID := GetMenuID(theMenu);
      CalcMenuSize(theMenu);
			loc.right := loc.left + GetMenuWidth(theMenu) + 7;
			loc.bottom := loc.top + 19;
			OffsetRect(loc,-1,0);

      if (GetMenuFont(theMenu,menuFontID,menuFontSize) = NoErr) and
         ((menuFontSize <> 0) or (menuFontID <> 0))
			  then
			    begin
			      TextFont(menuFontID);
		        TextSize(menuFontSize);
		        myControl := NewControl(GetWindowFromPort(CGrafPtr(currentPort)),loc,StringToStr255(''),false,popupTitleRightJust,theMenuID,0,popupMenuProc + $0008,0);
			    end
			  else
			    begin
			      myControl := NewControl(GetWindowFromPort(CGrafPtr(currentPort)),loc,StringToStr255(''),false,popupTitleRightJust,theMenuID,0,popupMenuProc,0);
			    end;

      OffsetRect(loc,1,0);
      if myControl <> NIL then
        begin
          {SysBeep(0); attendfrappeclavier;}
          SetControlValue(myControl,item);
          ShowControl(myControl);
          InsetRect(loc,-3,-3);
          if SetControlVisibility(myControl,false,false) = NoErr then DoNothing;
          SizeControl(myControl,0,0);
          DisposeControl(myControl);
          ValidRect(loc);
        end;
    end;
end;



function NewMenuFlottant(whichID : SInt32; whichrect : Rect; whichItem : SInt16) : MenuFlottantRec;
	var
		aux : MenuFlottantRec;
begin
	with aux do
		begin
			theID := whichID;
			theMenu := NIL;
			theControl := NIL;
			theWindow := NIL;
			theRect := whichRect;
			theMenuWidth := 0;
			theMenuFontID := 0;
		  theMenuFontSize := 0;
			theItem := whichItem;
			checkedItems := [];
			provientDUneResource := false;
			installe := false;
		end;
	NewMenuFlottant := aux;
end;

procedure SetItemMenuFlottant(var whichMenuFlottant : MenuFlottantRec; whichItem : SInt16; var change : boolean);
var oldItem : SInt16;
begin
  with whichMenuFlottant do
    begin
		  oldItem := theItem;
		  if oldItem <> whichItem then
		    begin
		      theItem := whichItem;
		      change := true;
		    end;
		  if theControl <> NIL then SetControlValue(theControl,theItem);
    end;
end;

procedure SetFontMenuFlottant(var whichMenuFlottant : MenuFlottantRec; fontID : SInt16; fontSize : UInt16);
begin
  whichMenuFlottant.theMenuFontID   := fontID;
  whichMenuFlottant.theMenuFontSize := fontSize;
end;

procedure EffaceMenuFlottant(var whichMenuFlottant : MenuFlottantRec);
var unRect : rect;
begin
  unRect := whichMenuFlottant.theRect;
	InsetRect(unRect,-5,-3);
	OffSetRect(unRect,4,1);
	MyEraseRect(unRect);
end;

procedure CalculateMenuFlottantSize(var whichMenuFlottant : MenuFlottantRec);
begin
  with whichMenuFlottant do
    if (theMenu <> NIL) then
      begin
        CalcMenuSize(theMenu);
        theMenuWidth := GetMenuWidth(theMenu) + 5;
      end;
end;

procedure DrawPUItemMenuFlottant(var whichMenuFlottant : MenuFlottantRec; drawMark : boolean);
var oldPort : grafPtr;
begin
  with whichMenuFlottant do
    if theMenu <> NIL then
	    begin
	      if (theWindow = NIL) or (theControl = NIL)
	        then
	          DrawPUItem(theMenu, theItem, theRect, drawMark)
	        else
	          begin
	            GetPort(oldPort);
	            SetPortByWindow(theWindow);

	            if SetControlVisibility(theControl,true,true) = NoErr then DoNothing;
	            Draw1Control(theControl);
	            SetPort(oldPort);
	          end;
			end;
end;

procedure CalculateMenuFlottantControl(var whichMenuFlottant : MenuFlottantRec; whichWindow : WindowPtr);
var theMenuID : SInt16;
    myRect : rect;
begin

  InitUnitMacExtras(false);

  with whichMenuFlottant do
    if (whichWindow <> NIL) and (theMenu <> NIL) then
		  begin
		    theWindow := whichWindow;

		    theMenuID := GetMenuID(theMenu);
		    myRect := theRect;
		    myRect.right := myRect.left + theMenuWidth + 2;
				myRect.bottom := myRect.top + 19;
				OffsetRect(myRect,-1,-1);

				if ((theMenuFontSize <> 0) or (theMenuFontID <> 0))
			  then
			    begin
			      TextFont(theMenuFontID);
		        TextSize(theMenuFontSize);
		        theControl := NewControl(whichWindow,myRect,StringToStr255(''),false,popupTitleRightJust,theMenuID,0,popupMenuProc + $0008,0);
			    end
			  else
			    begin
			      theControl := NewControl(whichWindow,myRect,StringToStr255(''),false,popupTitleRightJust,theMenuID,0,popupMenuProc,0);
			    end;

	      if theControl <> NIL then
	        begin
	          SetControlValue(theControl,theItem);
	        end;
		  end;
end;

procedure InstalleMenuFlottant(var whichMenuFlottant : MenuFlottantRec; whichWindow : WindowPtr);
var err : OSStatus;
begin
	with whichMenuFlottant do
		begin
			theMenu := MyGetMenu(theID);
			if theMenu <> NIL then
			  begin
			    provientDUneResource := true;
			    installe := true;
			    EnleveEspacesDeDroiteItemsMenu(theMenu);

			    if (theMenuFontID <> 0) or (theMenuFontSize <> 0) then
			      err := SetMenuFont(theMenu,theMenuFontID,theMenuFontSize);

			    InsertMenu(theMenu, -1);
			    CalculateMenuFlottantSize(whichMenuFlottant);
			    CalculateMenuFlottantControl(whichMenuFlottant,whichWindow);
			  end;
		end;
end;


procedure DesinstalleMenuFlottant(var whichMenuFlottant : MenuFlottantRec);
begin
	with whichMenuFlottant do
	  begin
	    if installe and (theMenu <> NIL) then
				begin
				  if not(installe) then
				    TraceLog('WARNING : desinstallation d''un menu non installe !');
				  DeleteMenu(theID);
				  TerminateMenu(theMenu,provientDUneResource);
				end;
			if theControl <> NIL then
			  begin
			    if SetControlVisibility(theControl,false,false) = NoErr then DoNothing;
			    DisposeControl(theControl);
			    theControl := NIL;
			  end;
	 end;
end;

function EventPopUpItemMenuFlottant(var whichMenuFlottant : MenuFlottantRec; drawChoice, checkChoiceBefore,checkChoiceAfter : Boolean) : boolean;
var result : boolean;
begin
  {if unit_MacExtras_debuggage then WritelnDansRapport('entree dans EventPopUpItemMenuFlottant');}
	with whichMenuFlottant do
		begin
		  {if unit_MacExtras_debuggage then WritelnDansRapport('dans EventPopUpItemMenuFlottant : avant EventPopUpItem');}
			result := EventPopUpItem(theMenu, theItem, theRect, drawChoice, checkChoiceBefore);
			if result and (theItem > 0) and (theControl <> NIL) then SetControlValue(theControl,theItem);
			if checkChoiceAfter and result and (theItem > 0) and (theItem < 127) then
				begin
				  if theItem in checkedItems then
						begin
							checkedItems := checkedItems - [theItem];
							MyCheckItem(theMenu, theItem, False);
						end
					else
						begin
							checkedItems := checkedItems + [theItem];
							MyCheckItem(theMenu, theItem, true);
						end;
				end;
		  EventPopUpItemMenuFlottant := result;
		end;
  {if unit_MacExtras_debuggage then WritelnDansRapport('sortie de EventPopUpItemMenuFlottant');}
end;

procedure CheckOnlyThisItem(var whichMenuFlottant : MenuFlottantRec; whichItem : SInt16);
var i : SInt16;
begin
  with whichMenuFlottant do
    begin
      for i := 1 to MyCountMenuItems(theMenu) do
        if (i = whichItem)
          then MyCheckItem(theMenu,i,true)
          else MyCheckItem(theMenu,i,false);
      checkedItems := [whichItem];
    end;
end;





procedure DisplayAboutBox;
{ necessite une ressource de type STR$ ˆ 6 items , d'ID 1 :}
{     STR$ 1 = nom du programe}
{     STR$ 2 = auteur}
{     STR$ 3 = version}
{     STR$ 4 = copyright}
{     STR$ 5 = Adresse}
{     STR$ 6 = telephone}
{     STR$ 7 = copyright}
{     STR$ 8 = suite du prŽcŽdent}
{}
	const
		strlistID = 1;
		ValseHongroiseID = 20000;
	var
		oldport : GrafPtr;
		wp : WindowPtr;
		wr : rect;
		i : SInt16;
		messages : array[1..6] of String255;
  (* theChannel : SndChannelPtr; *)
begin
(*OpenChannel(theChannel); *)
	for i := 1 to 6 do
		messages[i] := ReadStringFromRessource( strlistID, i);

	wr := GetScreenBounds;
	InsetRect(wr,(wr.right - wr.left - 300) div 2,(wr.bottom - wr.top - 180) div 2);
	wp := MyNewCWindow(NIL, wr, '', true, altdboxproc, MyFenetreFictiveAvantPlan, false, 0);

	if wp <> NIL then
		with GetWindowPortRect(wp) do
			begin
				GetPort(oldport);
				SetPortByWindow(wp);

				TextFont(systemFont);
				TextSize(0);
				CenterString(0, 30, right, messages[1]);

				TextFont(GenevaID);
				TextSize(9);
				CenterString(0, 60, right, messages[2]);
				CenterString(0, 90, right, messages[3]);
				CenterString(0, bottom - 50, right, messages[4]);
				CenterString(0, bottom - 35, right, messages[5]);
				CenterString(0, bottom - 20, right, messages[6]);

				while Button do
					begin
					  ShareTimeWithOtherProcesses(2);
				(*	FlushChannel(theChannel);
						PlaySoundAsynchrone(ValseHongroiseID, kVolumeSonDesCoups, theChannel);  *)
					end;
				while not(Button) do
					begin
					  ShareTimeWithOtherProcesses(2);
			(*		FlushChannel(theChannel);
						PlaySoundAsynchrone(ValseHongroiseID, kVolumeSonDesCoups, theChannel); *)
					end;
				FlushEvents(MDownmask + MupMask, 0);

				DisposeWindow(wp);
				SetPort(oldport);
	(*		QuietChannel(theChannel);
				CloseChannel(theChannel); *)
			end;
end;




function InMenuCmdSet(item : SInt16; commands : menuCmdSet) : boolean;
begin
  InMenuCmdSet := (item in commands);
end;

procedure EnableMenu(mh : MenuRef; commands : menuCmdSet);
	var
		thecommand : 1..maxmenucmds;
begin
	for thecommand := 1 to maxmenucmds do
		if thecommand in commands then
			MyEnableItem(mh, thecommand);
end;

procedure DisableMenu(mh : MenuRef; commands : menuCmdSet);
	var
		thecommand : 1..maxmenucmds;
begin
	for thecommand := 1 to maxmenucmds do
		if thecommand in commands then
			MyDisableItem(mh, thecommand);
end;

procedure FixEditMenu(enablecommands : boolean);
	var
		editset : menuCmdSet;
begin
	editset := [UndoCmd, CutCmd, CopyCmd, PasteCmd, ClearCmd];
	if enablecommands then
		EnableMenu(editmenu, editset)
	else
		DisableMenu(editmenu, editset);
end;


procedure CloseDAwindow;
begin
end;

function GetAppleMenu : MenuRef;
begin
  GetAppleMenu := applemenu;
end;

function GetFileMenu : MenuRef;
begin
  GetFileMenu := filemenu;
end;

function GetEditMenu : MenuRef;
begin
  GetEditMenu := editmenu;
end;

procedure SetAppleMenu(whichMenu : MenuRef);
begin
  applemenu := whichMenu;
end;

procedure SetFileMenu(whichMenu : MenuRef);
begin
  filemenu := whichMenu;
end;

procedure SetEditMenu(whichMenu : MenuRef);
begin
  editmenu := whichMenu;
end;


END.













































