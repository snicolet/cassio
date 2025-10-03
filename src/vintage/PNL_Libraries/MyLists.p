UNIT MyLists;

INTERFACE







 uses
     UnitDefCassio;

{ Some types have been changed to avoid clashing with the list manager }
	type
		listHead = ^listNode;			{ Was listHeadHandle }
		listItem = ^listNode;			{ Was listHandle }
		listNode = record
				head: boolean;
				next: listItem;
				prev: listItem;
				this: Handle;
			end;

	var
		listError: boolean;

	procedure CreateList (var l: listHead);                                                                                                                                            ATTRIBUTE_NAME('CreateList')
	procedure DestroyList (var l: listHead; dispose: boolean);                                                                                                                         ATTRIBUTE_NAME('DestroyList')

	procedure ReturnHead (lh: listHead; var l: listItem);                                                                                                                              ATTRIBUTE_NAME('ReturnHead')
    (* <a> b c / <a> b c / <a> b c / <a> / <a> / <> *)
	procedure ReturnTail (lh: listHead; var l: listItem);                                                                                                                              ATTRIBUTE_NAME('ReturnTail')
    (* a b c <> / a b c <> / a b c <> / a b c <> / a <> / a <> / <> *)

	procedure MoveToHead (var l: listItem);                                                                                                                                            ATTRIBUTE_NAME('MoveToHead')
    (* <a> b c / <a> b c / <a> b c / <a> b c / <a> / <a> / <> *)
	procedure MoveToTail (var l: listItem);                                                                                                                                            ATTRIBUTE_NAME('MoveToTail')
    (* a b c <> / a b c <> / a b c <> / a b c <> / a <> / a <> / <> *)
	procedure MoveToNext (var l: listItem);                                                                                                                                            ATTRIBUTE_NAME('MoveToNext')
    (* a <b> c / a b <c> / a b c <> / error / a <> / error / error *)
	procedure MoveToPrev (var l: listItem);                                                                                                                                            ATTRIBUTE_NAME('MoveToPrev')
    (* error / <a> b c / a <b> c / a b <c> / error / <a> / error *)

	function FindItem (lh: listHead; it: Handle; var l: listItem) : boolean;                                                                                                           ATTRIBUTE_NAME('FindItem')

	procedure AddHead (l: listHead; it: Handle);                                                                                                                                       ATTRIBUTE_NAME('AddHead')
    (* x <a> b c / x a <b> c / x a b <c> / x a b c <> / x <a> / x a <> / x <>*)
	procedure AddTail (l: listHead; it: Handle);                                                                                                                                       ATTRIBUTE_NAME('AddTail')
    (* <a> b c x / a <b> c x / a b <c> x / a b c x <> / <a> x / a x <> / x <>*)
	procedure AddBefore (l: listItem; it: Handle);                                                                                                                                     ATTRIBUTE_NAME('AddBefore')
    (* x <a> b c / a x <b> c / a b x <c> / a b c x <> / x <a> / a x <> / x <>*)
	procedure AddAfter (l: listItem; it: Handle);                                                                                                                                      ATTRIBUTE_NAME('AddAfter')
    (* <a> x b c / a <b> x c / a b <c> x / error / <a> x / error / error *)

	procedure DeleteHead (l: listHead; var it: Handle);                                                                                                                                ATTRIBUTE_NAME('DeleteHead')
    (* <?> b c / <b> c / b <c> / b c <> / <?> / <> / error *)
	procedure DeleteTail (l: listHead; var it: Handle);                                                                                                                                ATTRIBUTE_NAME('DeleteTail')
    (* <a> b / a <b> / a b <?> / a b <> / <?> / <> / error *)
	procedure DeletePrev (l: listItem; var it: Handle);                                                                                                                                ATTRIBUTE_NAME('DeletePrev')
    (* error / <b> c / a <c> / a b <> / error / <> / error *)
	procedure DeleteNext (l: listItem; var it: Handle);                                                                                                                                ATTRIBUTE_NAME('DeleteNext')
    (* <a> c / a <b> / error / error / error / error / error *)
	procedure DeleteItem (var l: listItem; var it: Handle);                                                                                                                            ATTRIBUTE_NAME('DeleteItem')
    (* <b> c / a <c> / a b <> / error / <> / error / error *)

	procedure FetchHead (l: listHead; var it: Handle);                                                                                                                                 ATTRIBUTE_NAME('FetchHead')
    (* a / a / a / a / a / a / error  *)
	procedure FetchTail (l: listHead; var it: Handle);                                                                                                                                 ATTRIBUTE_NAME('FetchTail')
    (* c / c / c / c / a / a / error  *)
	procedure FetchNext (l: listItem; var it: Handle);                                                                                                                                 ATTRIBUTE_NAME('FetchNext')
    (* b / c / error / error / error / error / error *)
	procedure FetchPrev (l: listItem; var it: Handle);                                                                                                                                 ATTRIBUTE_NAME('FetchPrev')
    (* error / a / b / c / error / a / error *)
	procedure Fetch (l: listItem; var it: Handle);                                                                                                                                     ATTRIBUTE_NAME('Fetch')
    (* a / b / c / error / a / error / error *)

	function IsHead (l: listItem) : boolean;                                                                                                                                           ATTRIBUTE_NAME('IsHead')
    (* T / F / F / F / T / F / T *)
	function IsTail (l: listItem) : boolean;                                                                                                                                           ATTRIBUTE_NAME('IsTail')
    (* F / F / F / T / F / T / T *)
	function IsEmpty (l: listHead) : boolean;                                                                                                                                          ATTRIBUTE_NAME('IsEmpty')
    (* F / F / F / F / F / F / T *)

	procedure DisplayList (lh: listHead);                                                                                                                                              ATTRIBUTE_NAME('DisplayList')
   (* To the Text Screen *)
	procedure ValidateList (lh: listHead; maxlen: SInt32);                                                                                                                             ATTRIBUTE_NAME('ValidateList')
	(* Check the list for validity, maxlen is the maximum valid length *)

IMPLEMENTATION







	uses
		MacMemory, MyAssertions;
{ Internal Routines }

	procedure DestroyListPtr (var l:  listItem);
	begin
{    l^^.next := NIL;				These dont do any good }
{    l^^. prev := NIL;			cause DisposHandle }
{    l^^. this := NIL;			destroys the data }
		DisposePtr(Ptr(l));
		l := NIL;
	end;

	procedure CreateListPtr (var l:  listItem);
	begin
		l := listItem(NewPtr(SizeOf(listNode)));
		if l = NIL then begin
			listError := true;
			MyDebugStr('CreateListPtr Failed!');
		end;
	end;

	procedure MoveToStart (var l:  listItem);
		var
			tmp : listItem;
	begin
		if not l^.head then begin
			tmp := l;
			repeat
				l := l^.next;
			until (tmp = l) or l^.head;
			if tmp = l then begin
				listError := true;
			end;
		end;
	end;

	procedure InsertBefore (l:  listItem; var it: Handle);
		var
			tmp : listItem;
	begin
		CreateListPtr(tmp);
		if tmp <> NIL then begin
			tmp^.head := false;
			tmp^.this := it;
			tmp^.next := l;
			tmp^.prev := l^.prev;
			l^.prev^.next := tmp;
			l^.prev := tmp;
		end;
	end;

	procedure DeleteNode (l: listItem; var it: Handle);
	begin
		if l^.head then begin
			listError := true;
		end else begin
			it := l^.this;
			l^.prev^.next := l^.next;
			l^.next^.prev := l^.prev;
			DestroyListPtr(l);
		end;
	end;

	procedure FetchNode (l: listItem; var it: Handle);
	begin
		if l^.head then begin
			listError := true;
		end;
		it := l^.this;
	end;

{ External Routines }

	procedure CreateList (var l: listHead);
	begin
		CreateListPtr(ListItem(l));
		if l <> NIL then begin
			l^.head := true;
			l^.next := listItem(l);
			l^.prev := listItem(l);
			l^.this := NIL;
		end;
	end;

	procedure DestroyList (var l: listHead; dispose: boolean);
		var
			tmp, tmp2: listItem;
	begin
		tmp := l^.next;
		while tmp <> listItem(l) do begin
			tmp2 := tmp;
			tmp := tmp^.next;
			if dispose then begin
				DisposeHandle(tmp2^.this);
			end;
			DestroyListPtr(tmp2);
		end;
		if dispose then begin
			DisposeHandle(l^.this);
		end;
		DestroyListPtr(ListItem(l));
	end;

	procedure ReturnHead (lh: listHead; var l: listItem);
    (* <a> b c / <a> b c / <a> b c / <a> / <a> / <> *)
	begin
		l := lh^.next;
	end;

	procedure ReturnTail (lh: listHead; var l: listItem);
    (* a b c <> / a b c <> / a b c <> / a b c <> / a <> / a <> / <> *)
	begin
		l := listItem(lh);
	end;

	function FindItem (lh: listHead; it: Handle; var l: listItem) : boolean;
	begin
		l := listItem(lh)^.next;
		while (not l^.head) and (it <> l^.this) do begin
			l := l^.next;
		end;
		FindItem := (not l^.head) and (it = l^.this);
	end;

	procedure MoveToHead (var l: listItem);
    (* <a> b c / <a> b c / <a> b c / <a> b c / <a> / <a> / <> *)
	begin
		MoveToStart(l);
		l := l^.next;
	end;

	procedure MoveToTail (var l: listItem);
    (* a b c <> / a b c <> / a b c <> / a b c <> / a <> / a <> / <> *)
	begin
		MoveToStart(l);
	end;

	procedure MoveToNext (var l: listItem);
    (* a <b> c / a b <c> / a b c <> / error / a <> / error / error *)
	begin
		if l^.head then begin
			listError := true;
		end else begin
			l := l^.next;
		end;
	end;

	procedure MoveToPrev (var l: listItem);
    (* error / <a> b c / a <b> c / a b <c> / error / <a> / error *)
	begin
		if l^.prev^.head then begin
			listError := true;
		end else begin
			l := l^.prev;
		end;
	end;

	procedure AddHead (l: listHead; it: Handle);
    (* x <a> b c / x a <b> c / x a b <c> / x a b c <> / x <a> / x a <> / x <>*)
	begin
		InsertBefore(l^.next, it);
	end;

	procedure AddTail (l: listHead; it: Handle);
    (* <a> b c x / a <b> c x / a b <c> x / a b c x <> / <a> x / a x <> / x <>*)
	begin
		InsertBefore(listItem(l), it);
	end;

	procedure AddBefore (l: listItem; it: Handle);
    (* x <a> b c / a x <b> c / a b x <c> / a b c x <> / x <a> / a x <> / x <>*)
	begin
		InsertBefore(l, it);
	end;

	procedure AddAfter (l: listItem; it: Handle);
    (* <a> x b c / a <b> x c / a b <c> x / error / <a> x / error / error *)
	begin
		if l^.head then begin
			listError := true;
		end else begin
			InsertBefore(l^.next, it);
		end;
	end;

	procedure DeleteHead (l: listHead; var it: Handle);
    (* <?> b c / <b> c / b <c> / b c <> / <?> / <> / error *)
	begin
		DeleteNode(l^.next, it);
	end;

	procedure DeleteTail (l: listHead; var it: Handle);
    (* <a> b / a <b> / a b <?> / a b <> / <?> / <> / error *)
	begin
		DeleteNode(l^.prev, it);
	end;

	procedure DeletePrev (l: listItem; var it: Handle);
    (* error / <b> c / a <c> / a b <> / error / <> / error *)
	begin
		DeleteNode(l^.prev, it);
	end;

	procedure DeleteNext (l: listItem; var it: Handle);
    (* <a> c / a <b> / error / error / error / error / error *)
	begin
		if l^.head then begin
			listError := true;
			it := NIL;
		end
		else
			DeleteNode(l^.next, it);
	end;

	procedure DeleteItem (var l: listItem; var it: Handle);
    (* <b> c / a <c> / a b <> / error / <> / error / error *)
		var
			tmp : listItem;
	begin
		if l^.head then begin
			listError := true;
			it := NIL;
		end else begin
			tmp := l^.next;
			DeleteNode(l, it);
			l := tmp;
		end;
	end;

	procedure FetchHead (l: listHead; var it: Handle);
    (* a / a / a / a / a / a / error  *)
	begin
		FetchNode(l^.next, it);
	end;

	procedure FetchTail (l: listHead; var it: Handle);
    (* c / c / c / c / a / a / error  *)
	begin
		FetchNode(l^.prev, it);
	end;

	procedure FetchNext (l: listItem; var it: Handle);
    (* b / c / error / error / error / error / error *)
	begin
		if l^.head then begin
			listError := true;
			it := NIL;
		end
		else
			FetchNode(l^.next, it);
	end;

	procedure FetchPrev (l: listItem; var it: Handle);
    (* error / a / b / c / error / a / error *)
	begin
		FetchNode(l^.prev, it);
	end;

	procedure Fetch (l: listItem; var it: Handle);
    (* a / b / c / error / a / error / error *)
	begin
		FetchNode(l, it);
	end;

	function IsHead (l: listItem) : boolean;
    (* T / F / F / F / T / F / T *)
	begin
		IsHead := l^.prev^.head;
	end;

	function IsTail (l: listItem) : boolean;
    (* F / F / F / T / F / T / T *)
	begin
		IsTail := l^.head;
	end;

	function IsEmpty (l: listHead) : boolean;
    (* F / F / F / F / F / F / T *)
	begin
		IsEmpty := l^.next = listItem(l);
	end;

	procedure DisplayList (lh: listHead);
		var
			l: listItem;
			hhhh: Handle;
	begin
		ReturnHead(lh, l);
		write('(');
		while not IsTail(l) do begin
			Fetch(l, hhhh);
			MoveToNext(l);
			write(SInt32(hhhh));
			if not IsTail(l) then begin
				write(',');
			end;
		end;
		writeln('  )');
	end;

	procedure ValidateList (lh: listHead; maxlen: SInt32);
		var
			item: listItem;
			count: SInt16;
			data: Handle;
	begin
		if lh = NIL then begin
			MyDebugStr('ValidateList: lh = NIL');
		end;
		count := 0;
		ReturnHead(lh, item);
		if item = NIL then begin
			MyDebugStr('ValidateList: first item = NIL');
		end;
		while not IsTail(item) do begin
			Fetch(item, data);
			MoveToNext(item);
			if item = NIL then begin
				MyDebugStr('ValidateList: list item = NIL');
			end;
			count := count + 1;
			if count > maxlen then begin
				MyDebugStr('ValidateList: List too long - probably bad');
				leave;
			end;
		end;
	end;

end.
