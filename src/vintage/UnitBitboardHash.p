UNIT UnitBitboardHash;



INTERFACE







 USES UnitDefCassio, UnitDefParallelisme;








procedure InitUnitBitboardHash;
procedure LibereMemoireUnitBitboardHash;
function BITBOARD_HASH_TABLE_OK(hash_table : BitboardHashTable) : boolean;

procedure AllocateAllBitboardHashTables;
procedure BitboardHashAllocate(var hash_table : BitboardHashTable; n_bits : SInt32);
procedure BitboardHashClear(hash_table : BitboardHashTable);
procedure BitboardHashDispose(var hash_table : BitboardHashTable);

procedure BitboardHashUpdate(hash_table : BitboardHashTable; hash_index : UInt32; pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32; board_empties : SInt32; alpha,beta,score,move : SInt32);
function BitboardHashGet(hash_table : BitboardHashTable; pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32; var hash_index : UInt32; var hash_info : loweruppermoveemptiesRec) : BitboardHash;
function GetEndgameValuesInBitboardHashTableForThisPosition(hash_table : BitboardHashTable; theBitboard : bitboard; trait : SInt32; var valMinPourNoir,valMaxPourNoir,bestMove : SInt32) : boolean;
function GetEndgameValuesInAllBitboardHashTables(var plat : PositionEtTraitRec; var valMinPourNoir,valMaxPourNoir,bestMove : SInt32) : boolean;


function NumberOfBitHashMutexLocksInUse : SInt32;
procedure ChangeHashRandomization;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSAtomic_glue
{$IFC NOT(USE_PRELINK)}
    , UnitServicesMemoire, UnitRapport, UnitBitboardMobilite, UnitParallelisme, MyMathUtils, UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/BitboardHash.lk}
{$ENDC}


{END_USE_CLAUSE}












(* infinite score: a huge value unreachable as a score and fitting in a char *)
const INF_SCORE = 127;


var gHashRandomization : UInt32;


procedure InitUnitBitboardHash;
var k : SInt32;
begin

  for k := 0 to kNombreDeTableHachageBitboard - 1 do
    gBitboardHashTable[k] := NIL;

  AllocateAllBitboardHashTables;


end;


procedure LibereMemoireUnitBitboardHash;
var k : SInt32;
begin
  for k := 0 to kNombreDeTableHachageBitboard - 1 do
    if (gBitboardHashTable[k] <> NIL) then
      BitboardHashDispose(gBitboardHashTable[k]);
end;


function BITBOARD_HASH_TABLE_OK(hash_table : BitboardHashTable) : boolean;
begin
  BITBOARD_HASH_TABLE_OK := (hash_table <> NIL);
end;


procedure AllocateAllBitboardHashTables;
var k : SInt32;
begin
  if gIsRunningUnderMacOSX
    then
      begin
        for k := 0 to kNombreDeTableHachageBitboard - 1 do
          BitboardHashAllocate(gBitboardHashTable[k],21)   {Attention : deja 80 megaoctets par thread :-( }
      end
    else
      begin
        BitboardHashAllocate(gBitboardHashTable[0],16);  {Attention : 2.5 megaoctets         }
      end;
end;



procedure BitboardHashAllocate(var hash_table : BitboardHashTable; n_bits : SInt32);
var size_in_bytes : UInt32;
    nb_slots,i : UInt32;
begin
  if (hash_table <> NIL)
    then BitboardHashDispose(hash_table);

  nb_slots := 1;
  for i := 1 to n_bits do
    nb_slots := nb_slots * 2;

  size_in_bytes := SizeOf(BitboardHashEntryRec) * (nb_slots + 16);
  hash_table := BitboardHashTable(AllocateMemoryPtrClear(size_in_bytes));

  if hash_table <> NIL then
    begin
      hash_table^.hash_mask := nb_slots - 1;

      (*
      WritelnNumDansRapport('hash_table^.hash_mask = ',hash_table^.hash_mask);
      WritelnNumDansRapport('size_in_bytes = ',size_in_bytes);
      *)

    end;
end;


procedure BitboardHashClear(hash_table : BitboardHashTable);
var i : SInt32;
    init_entry : BitboardHashEntryRec;
begin
  if BITBOARD_HASH_TABLE_OK(hash_table) then
    with hash_table^ do
    begin
      with init_entry do
        begin
          deepest.loweruppermoveempties.lower         := -INF_SCORE;
          deepest.loweruppermoveempties.upper         :=  INF_SCORE;
          deepest.loweruppermoveempties.stored_move   := 0;
          deepest.loweruppermoveempties.empties       := 0;
          deepest.lock_my_low   := 0;
          deepest.lock_my_high  := 0;
          deepest.lock_opp_low  := 0;
          deepest.lock_opp_high := 0;

          newest := deepest;
        end;
      for i := 0 to hash_mask do
        hash_entry[i] := init_entry;
    end;
end;


procedure BitboardHashDispose(var hash_table : BitboardHashTable);
begin
	if (hash_table <> NIL) then
	  DisposeMemoryPtr(Ptr(hash_table));
end;


procedure BitboardHashUpdate(hash_table : BitboardHashTable; hash_index : UInt32;
                             pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
                             board_empties : SInt32; alpha,beta,score,move : SInt32);
var my_hash_entry : BitboardHashEntry;
    deepest,newest : BitboardHash;
    infosDansDeepest : loweruppermoveemptiesRec;
    infosDansNewest : loweruppermoveemptiesRec;
begin

  if (hash_table <> NIL) then
    begin

      (* get the hash table entry *)

      my_hash_entry := @hash_table^.hash_entry[hash_index];
      deepest       := @my_hash_entry^.deepest;
      newest        := @my_hash_entry^.newest;


      (* try to update deepest entry *)
      with deepest^ do
    	  begin
    	    // read all the packed (lower,upper,stored_move,empties) info from deepest^
    	    infosDansDeepest := loweruppermoveempties;

    	    if ((lock_my_low   XOR infosDansDeepest.toutensemble) = pos_my_bits_low)  and
    	       ((lock_my_high  XOR infosDansDeepest.toutensemble) = pos_my_bits_high) and
    	       ((lock_opp_low  XOR infosDansDeepest.toutensemble) = pos_opp_bits_low) and
    	       ((lock_opp_high XOR infosDansDeepest.toutensemble) = pos_opp_bits_high) then
        	  begin
          		if (score < beta)  and (score < infosDansDeepest.upper) then infosDansDeepest.upper := score;
          		if (score > alpha) and (score > infosDansDeepest.lower) then infosDansDeepest.lower := score;
          		infosDansDeepest.stored_move := move;

          		// store the updated (lower,upper,stored_move,empties) info deepest^
          		lock_my_low           := pos_my_bits_low   XOR infosDansDeepest.toutensemble;
    	        lock_my_high          := pos_my_bits_high  XOR infosDansDeepest.toutensemble;
    	        lock_opp_low          := pos_opp_bits_low  XOR infosDansDeepest.toutensemble;
    	        lock_opp_high         := pos_opp_bits_high XOR infosDansDeepest.toutensemble;
          		loweruppermoveempties := infosDansDeepest;

          		exit(BitboardHashUpdate);
            end;
        end;

    	(* else try to update newest entry *)
    	with newest^ do
    	  begin
    	    // read all the packed (lower,upper,stored_move,empties) info from newest^
    	    infosDansNewest := loweruppermoveempties;

    	    if ((lock_my_low   XOR infosDansNewest.toutensemble) = pos_my_bits_low)  and
    	       ((lock_my_high  XOR infosDansNewest.toutensemble) = pos_my_bits_high) and
    	       ((lock_opp_low  XOR infosDansNewest.toutensemble) = pos_opp_bits_low) and
    	       ((lock_opp_high XOR infosDansNewest.toutensemble) = pos_opp_bits_high) then
        	  begin
          		if (score < beta)  and (score < infosDansNewest.upper) then infosDansNewest.upper := score;
          		if (score > alpha) and (score > infosDansNewest.lower) then infosDansNewest.lower := score;
          		infosDansNewest.stored_move := move;

          		// store the updated (lower,upper,stored_move,empties) info newest^
          		lock_my_low           := pos_my_bits_low   XOR infosDansNewest.toutensemble;
  	          lock_my_high          := pos_my_bits_high  XOR infosDansNewest.toutensemble;
  	          lock_opp_low          := pos_opp_bits_low  XOR infosDansNewest.toutensemble;
  	          lock_opp_high         := pos_opp_bits_high XOR infosDansNewest.toutensemble;
          		loweruppermoveempties := infosDansNewest;

          		exit(BitboardHashUpdate);
            end;
        end;

    	(* else try to add to deepest entry *)
      if (infosDansDeepest.empties < board_empties) then
        with deepest^ do
      	  begin
        		if (infosDansNewest.empties < infosDansDeepest.empties)
        		  then newest^ := deepest^;

        		// create the packed (lower,upper,stored_move,empties) info
        		infosDansDeepest.empties       := board_empties;
        		infosDansDeepest.stored_move   := move;
        		infosDansDeepest.lower         := -INF_SCORE;
        		infosDansDeepest.upper         := +INF_SCORE;
        		if (score < beta)  then infosDansDeepest.upper := score;
        		if (score > alpha) then infosDansDeepest.lower := score;

        		// write the deepest entry
        		lock_my_low           := pos_my_bits_low   XOR infosDansDeepest.toutensemble;
    	      lock_my_high          := pos_my_bits_high  XOR infosDansDeepest.toutensemble;
    	      lock_opp_low          := pos_opp_bits_low  XOR infosDansDeepest.toutensemble;
    	      lock_opp_high         := pos_opp_bits_high XOR infosDansDeepest.toutensemble;
    	      loweruppermoveempties := infosDansDeepest;


          end else

    	(* else add to newest entry *)
    	with newest^ do
      	begin

      	  // create the packed (lower,upper,stored_move,empties) info
      		infosDansNewest.empties       := board_empties;
      		infosDansNewest.stored_move   := move;
      		infosDansNewest.lower         := -INF_SCORE;
      		infosDansNewest.upper         := +INF_SCORE;
      		if (score < beta)  then infosDansNewest.upper := score;
      		if (score > alpha) then infosDansNewest.lower := score;

      		// write the newest entry
      		lock_my_low           := pos_my_bits_low   XOR infosDansNewest.toutensemble;
  	      lock_my_high          := pos_my_bits_high  XOR infosDansNewest.toutensemble;
  	      lock_opp_low          := pos_opp_bits_low  XOR infosDansNewest.toutensemble;
  	      lock_opp_high         := pos_opp_bits_high XOR infosDansNewest.toutensemble;
  	      loweruppermoveempties := infosDansNewest;
      	end;


  end;

end;


function BitboardHashGet(hash_table : BitboardHashTable; pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32; var hash_index : UInt32; var hash_info : loweruppermoveemptiesRec) : BitboardHash;
var my_hash_entry : BitboardHashEntry;
    info_dans_hash : loweruppermoveemptiesRec;
begin

  if (hash_table <> NIL) then
    with hash_table^ do
      begin

        (* calculate the hash index and get the hash table entry *)
        hash_index := ((pos_my_bits_low * pos_opp_bits_high) + (pos_my_bits_high + pos_opp_bits_low)) and hash_mask;

        my_hash_entry := @hash_entry[hash_index];

        (* check deepest entry *)
        with my_hash_entry^.deepest do
      	  begin
      	    info_dans_hash := loweruppermoveempties;

      	    if ((lock_my_low   XOR info_dans_hash.toutensemble) = pos_my_bits_low)  and
      	       ((lock_my_high  XOR info_dans_hash.toutensemble) = pos_my_bits_high) and
      	       ((lock_opp_low  XOR info_dans_hash.toutensemble) = pos_opp_bits_low) and
      	       ((lock_opp_high XOR info_dans_hash.toutensemble) = pos_opp_bits_high) then
              	 begin
              	   hash_info       := info_dans_hash;
              	   BitboardHashGet := @hash_entry[hash_index].deepest;
              	   exit(BitboardHashGet);
              	 end;
          end;

        (* check newest entry *)
        with my_hash_entry^.newest do
          begin
            info_dans_hash := loweruppermoveempties;

            if ((lock_my_low   XOR info_dans_hash.toutensemble) = pos_my_bits_low)  and
      	       ((lock_my_high  XOR info_dans_hash.toutensemble) = pos_my_bits_high) and
      	       ((lock_opp_low  XOR info_dans_hash.toutensemble) = pos_opp_bits_low) and
      	       ((lock_opp_high XOR info_dans_hash.toutensemble) = pos_opp_bits_high) then
                	begin
                	  hash_info       := info_dans_hash;
                	  BitboardHashGet := @hash_entry[hash_index].newest;
                	  exit(BitboardHashGet);
                	end;
           end;

      end;

  BitboardHashGet := NIL;
end;


function GetEndgameValuesInBitboardHashTableForThisPosition(hash_table : BitboardHashTable; theBitboard : bitboard; trait : SInt32; var valMinPourNoir,valMaxPourNoir,bestMove : SInt32) : boolean;
var hash : BitboardHash;
    hash_index : UInt32;
    info_dans_hash : loweruppermoveemptiesRec;
begin

  GetEndgameValuesInBitboardHashTableForThisPosition := false;


  with theBitboard do
    begin
      hash := BitboardHashGet(hash_table,g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,hash_index,info_dans_hash);
    	if (hash <> NIL) then
    	  with hash^ do
      	  begin
      	    GetEndgameValuesInBitboardHashTableForThisPosition := true;
      	    if trait = pionBlanc
      	      then
      	        begin
      	          valMinPourNoir := -info_dans_hash.upper;
      	          valMaxPourNoir := -info_dans_hash.lower;
      	        end
      	      else
      	        begin
      	          valMinPourNoir := info_dans_hash.lower;
      	          valMaxPourNoir := info_dans_hash.upper;
      	        end;
      		  bestmove := info_dans_hash.stored_move;
      		end;
    end;

end;


function GetEndgameValuesInAllBitboardHashTables(var plat : PositionEtTraitRec; var valMinPourNoir,valMaxPourNoir,bestMove : SInt32) : boolean;
var k : SInt32;
    theBitboard : bitboard;
    trait : SInt32;
begin

  theBitboard := PositionEtTraitToBitboard(plat);
  trait := GetTraitOfPosition(plat);

  for k := 0 to kNombreDeTableHachageBitboard - 1 do
    if GetEndgameValuesInBitboardHashTableForThisPosition(gBitboardHashTable[k],theBitboard,trait,valMinPourNoir,valMaxPourNoir,bestMove) then
      begin
        GetEndgameValuesInAllBitboardHashTables := true;
        exit(GetEndgameValuesInAllBitboardHashTables);
      end;

  GetEndgameValuesInAllBitboardHashTables := false;

end;



function NumberOfBitHashMutexLocksInUse : SInt32;
var i, counter : SInt32;
begin

  counter := 0;

  for i := 0 to kNombreMutexAccesBitboard*16 do
    if (ATOMIC_COMPARE_AND_SWAP_32(1,1,gMutexAccesBitboardHash[i]) <> 0)
      then inc(counter);

  NumberOfBitHashMutexLocksInUse := counter;

end;





procedure ChangeHashRandomization;
begin
  gHashRandomization := Random32();
end;





////////////   Remarque (12/05/2009) :
////////////
////////////   Cassio utilise desormais l'astuce du XOR de Robert Hyatt pour gerer les tables de
////////////   hachage en bitboard sans verrouillage pour le multiprocessing (cf sa page web a l'URL
////////////   http://www.cis.uab.edu/hyatt/hashing.html )
////////////
////////////   Si on ne veut pas utiliser cette astuce, il faut :
////////////   1) remplacer partout dans le code les appels BitboardHashGet par FIND_IN_BITBOARD_HASH_AND_GET_LOCK
////////////   2) enlever les commentaires des lignes qui commencent par RELEASE_BITBOARD...
////////////   3) utiliser les macros et les fonctions suivante, qui remplacent les fonctions de l'implementation ci-dessus


//  {$DEFINEC FIND_IN_BITBOARD_HASH_AND_GET_LOCK  BitboardHashGet }
//  {$DEFINEC GET_BITBOARD_HASH_LOCK(index)  (not(CassioUtiliseLeMultiprocessing) or (ATOMIC_COMPARE_AND_SWAP_32(0,1,gMutexAccesBitboardHash[(index and kMutexAccesBitboardMask) * 16]) <> 0)) }
//  {$DEFINEC RELEASE_BITBOARD_HASH_LOCK_BARRIER(index)  begin if CassioUtiliseLeMultiprocessing then begin OS_MEMORY_BARRIER; gMutexAccesBitboardHash[(index and kMutexAccesBitboardMask) * 16] := 0; end; end }
//  {$DEFINEC RELEASE_BITBOARD_HASH_LOCK(index)  begin if CassioUtiliseLeMultiprocessing then begin gMutexAccesBitboardHash[(index and kMutexAccesBitboardMask) * 16] := 0; end; end }

{
function BitboardHashGet(hash_table : BitboardHashTable; pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32; var hash_index : UInt32; var hash_info : loweruppermoveemptiesRec) : BitboardHash;
var my_hash_entry : BitboardHashEntry;
    info_dans_hash : loweruppermoveemptiesRec;
begin

  if (hash_table <> NIL) then
    with hash_table^ do
      begin

        (* calculate the hash index and get the hash table entry *)
        hash_index := ((pos_my_bits_low * pos_opp_bits_high) + (pos_my_bits_high + pos_opp_bits_low)) and hash_mask;



        if GET_BITBOARD_HASH_LOCK(hash_index) then
          begin

           if CassioUtiliseLeMultiprocessing then OS_MEMORY_BARRIER;

            my_hash_entry := @hash_entry[hash_index];

            (* check deepest entry *)
            with my_hash_entry^.deepest do
          	  begin
          	    info_dans_hash := loweruppermoveempties;

          	    if (lock_my_low   = pos_my_bits_low)  and
          	       (lock_my_high  = pos_my_bits_high) and
          	       (lock_opp_low  = pos_opp_bits_low) and
          	       (lock_opp_high = pos_opp_bits_high) then
                  	 begin
                  	   hash_info       := info_dans_hash;
                  	   BitboardHashGet := @hash_entry[hash_index].deepest;
                  	   exit(BitboardHashGet);
                  	 end;

              end;

            (* check newest entry *)
            with my_hash_entry^.newest do
              begin
                info_dans_hash := loweruppermoveempties;

                if (lock_my_low   = pos_my_bits_low)  and
            	     (lock_my_high  = pos_my_bits_high) and
            	     (lock_opp_low  = pos_opp_bits_low) and
            	     (lock_opp_high = pos_opp_bits_high) then
                    	begin
                    	  hash_info       := info_dans_hash;
                    	  BitboardHashGet := @hash_entry[hash_index].newest;
                    	  exit(BitboardHashGet);
                    	end;
               end;

            RELEASE_BITBOARD_HASH_LOCK(hash_index);
          end;



      end;

  BitboardHashGet := NIL;
end;


procedure BitboardHashUpdate(hash_table : BitboardHashTable; hash_index : UInt32;
                             pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
                             board_empties : SInt32; alpha,beta,score,move : SInt32);
var my_hash_entry : BitboardHashEntry;
    deepest,newest : BitboardHash;
    infosDansDeepest : loweruppermoveemptiesRec;
    infosDansNewest : loweruppermoveemptiesRec;
begin

  if (hash_table <> NIL) then
    begin

      (* get the hash table entry *)

      if GET_BITBOARD_HASH_LOCK(hash_index) then
        begin

          if CassioUtiliseLeMultiprocessing then OS_MEMORY_BARRIER;

          my_hash_entry := @hash_table^.hash_entry[hash_index];
          deepest       := @my_hash_entry^.deepest;
          newest        := @my_hash_entry^.newest;

          (* try to update deepest entry *)
          with deepest^ do
        	  begin
        	    // read all the packed (lower,upper,stored_move,empties) info from deepest^
        	    infosDansDeepest := loweruppermoveempties;

        	    if (lock_my_low   = pos_my_bits_low)  and
        	       (lock_my_high  = pos_my_bits_high) and
        	       (lock_opp_low  = pos_opp_bits_low) and
        	       (lock_opp_high = pos_opp_bits_high) then
            	  begin
              		if (score < beta)  and (score < infosDansDeepest.upper) then infosDansDeepest.upper := score;
              		if (score > alpha) and (score > infosDansDeepest.lower) then infosDansDeepest.lower := score;
              		infosDansDeepest.stored_move := move;

              		// stored the updated (lower,upper,stored_move,empties) info into deepest^
              		loweruppermoveempties := infosDansDeepest;

              		RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
              		exit(BitboardHashUpdate);
                end;
            end;

        	(* else try to update newest entry *)
        	with newest^ do
        	  begin
        	    // read all the packed (lower,upper,stored_move,empties) info from newest^
        	    infosDansNewest := loweruppermoveempties;

        	    if (lock_my_low   = pos_my_bits_low)  and
        	       (lock_my_high  = pos_my_bits_high) and
        	       (lock_opp_low  = pos_opp_bits_low) and
        	       (lock_opp_high = pos_opp_bits_high) then
            	  begin
              		if (score < beta)  and (score < infosDansNewest.upper) then infosDansNewest.upper := score;
              		if (score > alpha) and (score > infosDansNewest.lower) then infosDansNewest.lower := score;
              		infosDansNewest.stored_move := move;

              		// stored the updated (lower,upper,stored_move,empties) info into newest^
              		loweruppermoveempties := infosDansNewest;

              		RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
              		exit(BitboardHashUpdate);
                end;
            end;

        	(* else try to add to deepest entry *)
          if (infosDansDeepest.empties < board_empties) then
            with deepest^ do
          	  begin
            		if (infosDansNewest.empties < infosDansDeepest.empties)
            		  then newest^ := deepest^;

            		// create the packed (lower,upper,stored_move,empties) info
            		infosDansDeepest.empties       := board_empties;
            		infosDansDeepest.stored_move   := move;
            		infosDansDeepest.lower         := -INF_SCORE;
            		infosDansDeepest.upper         := +INF_SCORE;
            		if (score < beta)  then infosDansDeepest.upper := score;
            		if (score > alpha) then infosDansDeepest.lower := score;

            		// write the deepest entry
            		lock_my_low           := pos_my_bits_low;
        	      lock_my_high          := pos_my_bits_high;
        	      lock_opp_low          := pos_opp_bits_low;
        	      lock_opp_high         := pos_opp_bits_high;
        	      loweruppermoveempties := infosDansDeepest;



              end else

        	(* else add to newest entry *)
        	with newest^ do
          	begin

          	  // create the packed (lower,upper,stored_move,empties) info
          		infosDansNewest.empties       := board_empties;
          		infosDansNewest.stored_move   := move;
          		infosDansNewest.lower         := -INF_SCORE;
          		infosDansNewest.upper         := +INF_SCORE;
          		if (score < beta)  then infosDansNewest.upper := score;
          		if (score > alpha) then infosDansNewest.lower := score;

          		// write the newest entry
          		lock_my_low           := pos_my_bits_low;
      	      lock_my_high          := pos_my_bits_high;
      	      lock_opp_low          := pos_opp_bits_low;
      	      lock_opp_high         := pos_opp_bits_high;
      	      loweruppermoveempties := infosDansNewest;
          	end;

         RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
       end;






  end;

end;


function GetEndgameValuesInBitboardHashTableForThisPosition(hash_table : BitboardHashTable; theBitboard : bitboard; trait : SInt32; var valMinPourNoir,valMaxPourNoir,bestMove : SInt32) : boolean;
var hash : BitboardHash;
    hash_index : UInt32;
    info_dans_hash : loweruppermoveemptiesRec;
begin

  GetEndgameValuesInBitboardHashTableForThisPosition := false;

  with theBitboard do
    begin
      hash := FIND_IN_BITBOARD_HASH_AND_GET_LOCK(hash_table,g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,hash_index,info_dans_hash);
    	if (hash <> NIL) then
    	  with hash^ do
      	  begin
      	    GetEndgameValuesInBitboardHashTableForThisPosition := true;
      	    if trait = pionBlanc
      	      then
      	        begin
      	          valMinPourNoir := -info_dans_hash.upper;
      	          valMaxPourNoir := -info_dans_hash.lower;
      	        end
      	      else
      	        begin
      	          valMinPourNoir := info_dans_hash.lower;
      	          valMaxPourNoir := info_dans_hash.upper;
      	        end;
      		  bestmove := info_dans_hash.stored_move;
      		  RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
      		end;
    end;

end;

}



END.































































