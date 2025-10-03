UNIT UnitBitboardTypes;


INTERFACE







USES MacTypes,UnitOth0;





type

  bitboard =
    record
      g_my_bits_low : UInt32;
      g_my_bits_high : UInt32;
      g_opp_bits_low : UInt32;
      g_opp_bits_high : UInt32;
    end;

  demi_bitboard =
    record
      high : UInt32;
      low : UInt32;
    end;

  t_othellierBitboard_descr =
      array[0..99] of
		    record
		      isLow : boolean;
		      isHigh : boolean;
		      constanteHexa : UInt32;
		    end;


   listeCoupsAvecBitboard = array[0..99] of
      		                      record
      		                        the_move     : SInt32;
      		                        the_parity   : SInt32;
      		                        the_score    : SInt32;
      		                        the_position : bitboard;
      		                      end;


const
     kBitVientDePasser = $80000000;
     kNeVientDePasserDePasserMask = $7FFFFFFF;    { doit valoir $FFFFFFFF - kBitVientDePasser }

var
  othellierBitboardDescr : t_othellierBitboard_descr;


type
   BitboardHash = ^BitboardHashRec;

   (*
   BitboardHashRec = packed record
                             lower         : SInt8;
                             upper         : SInt8;
                             stored_move   : SInt8;
                             empties       : SInt8;
                             lock_my_low   : UInt32;
                             lock_my_high  : UInt32;
                             lock_opp_low  : UInt32;
                             lock_opp_high : UInt32;
                           end;
    *)

    loweruppermoveemptiesRec = packed record
                                  case SInt16 of
                                     0 :
                                       (
                                       lower         : SInt8;
                                       upper         : SInt8;
                                       stored_move   : SInt8;
                                       empties       : SInt8;
                                       );
                                     1 :
                                       (
                                       toutensemble : UInt32;
                                       )
                               end;
    (* Le meme type que l'ancien BitboardHashRec, mais ou on peut acceder
       aux quatre premiers champs comme un seul entier de 32 bits. *)
    BitboardHashRec =
                           packed record
                             loweruppermoveempties : loweruppermoveemptiesRec;
                             lock_my_low   : UInt32;
                             lock_my_high  : UInt32;
                             lock_opp_low  : UInt32;
                             lock_opp_high : UInt32;
                           end;


    BitboardHashEntry = ^BitboardHashEntryRec;
    BitboardHashEntryRec = record
                             deepest : BitboardHashRec;
                             newest : BitboardHashRec;
                           end;

    BitboardHashTable = ^BitboardHashTableRec;
    BitboardHashTableRec =
                        record
                          hash_mask  : UInt32;
                          hash_entry : array[0..0] of BitboardHashEntryRec;
                        end;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}


















END.
