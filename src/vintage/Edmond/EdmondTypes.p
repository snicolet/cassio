Unit EdmondTypes;


INTERFACE


USES MacTypes, UnitOth0;


// dans l'eval d'Edmond, stage = numero du dernier coup joue
const 
    Edmond_stage_MIN = 16;
    Edmond_stage_MAX = 56;
    


// tables de Cassio : il y en a deux fois moins (car on ne distingue pas BLACK/WHITE)
//                    et elles sont un peu moins precises (valeurs sur 16 bits au lieu 
//                    de 32 bits) que celles de Edmond  
var 
    Edmond_DIAG_5_stub : array[0..64] of IntegerArrayPtr;
    Edmond_DIAG_6_stub : array[0..64] of IntegerArrayPtr;
    Edmond_DIAG_7_stub : array[0..64] of IntegerArrayPtr;
    Edmond_DIAG_8_stub : array[0..64] of IntegerArrayPtr;
    Edmond_HV_4_stub : array[0..64] of IntegerArrayPtr;
    Edmond_HV_3_stub : array[0..64] of IntegerArrayPtr;
    Edmond_HV_2_stub : array[0..64] of IntegerArrayPtr;
    Edmond_EDGE_6_4_stub : array[0..64] of IntegerArrayPtr;
    Edmond_CORNER_2x5_stub : array[0..64] of IntegerArrayPtr;
    Edmond_CORNER_11_stub : array[0..64] of IntegerArrayPtr;
    Edmond_EDGE_2XC_stub : array[0..64] of IntegerArrayPtr;
    
    Edmond_DIAG_5 : array[0..64] of IntegerArrayPtr;
    Edmond_DIAG_6 : array[0..64] of IntegerArrayPtr;
    Edmond_DIAG_7 : array[0..64] of IntegerArrayPtr;
    Edmond_DIAG_8 : array[0..64] of IntegerArrayPtr;
    Edmond_HV_4 : array[0..64] of IntegerArrayPtr;
    Edmond_HV_3 : array[0..64] of IntegerArrayPtr;
    Edmond_HV_2 : array[0..64] of IntegerArrayPtr;
    Edmond_EDGE_6_4 : array[0..64] of IntegerArrayPtr; 
    Edmond_CORNER_2x5 : array[0..64] of IntegerArrayPtr;
    Edmond_CORNER_11 : array[0..64] of IntegerArrayPtr;
    Edmond_EDGE_2XC : array[0..64] of IntegerArrayPtr;
    

var diag_5a : SInt32;
		diag_5b : SInt32;
		diag_5c : SInt32;
		diag_5d : SInt32;

		diag_6a : SInt32;
		diag_6b : SInt32;
		diag_6c : SInt32;
		diag_6d : SInt32;

		diag_7a : SInt32;
		diag_7b : SInt32;
		diag_7c : SInt32;
		diag_7d : SInt32;

		diag_8a : SInt32;
		diag_8b : SInt32;
		reverved_a : SInt32;
		reverved_b : SInt32;

		hv_4a : SInt32;
		hv_4b : SInt32;
		hv_4c : SInt32;
		hv_4d : SInt32;

		hv_3a : SInt32;
		hv_3b : SInt32;
		hv_3c : SInt32;
		hv_3d : SInt32;

		hv_2a : SInt32;
		hv_2b : SInt32;
		hv_2c : SInt32;
		hv_2d : SInt32;

		corner2x5a : SInt32;
		corner2x5b : SInt32;
		corner2x5c : SInt32;
		corner2x5d : SInt32;
		corner2x5e : SInt32;
		corner2x5f : SInt32;
		corner2x5g : SInt32;
		corner2x5h : SInt32;

		edge64a : SInt32;
		edge64b : SInt32;
		edge64c : SInt32;
		edge64d : SInt32;

		corner11a : SInt32;
		corner11b : SInt32;
		corner11c : SInt32;
		corner11d : SInt32;

		edge2XCa : SInt32;
		edge2XCb : SInt32;
		edge2XCc : SInt32;
		edge2XCd : SInt32;


IMPLEMENTATION


END.