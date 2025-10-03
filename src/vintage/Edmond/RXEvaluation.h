/*
 *  RXEvaluation.h
 *  Roxane
 *
 *  Created by Bruno Causse on 06/08/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef RXEVALUATION_H
#define RXEVALUATION_H

#include <iostream>

#include "RXConstantes.h"

class RXEvaluation {

	friend class RXBBPatterns;
	
	static int* BLACK_DIAG_5[61];
	static int* WHITE_DIAG_5[61];

	static int* BLACK_DIAG_6[61];
	static int* WHITE_DIAG_6[61];
	
	static int* BLACK_DIAG_7[61];
	static int* WHITE_DIAG_7[61];

	static int* BLACK_DIAG_8[61];
	static int* WHITE_DIAG_8[61];
	
	static int* BLACK_HV_4[61];
	static int* WHITE_HV_4[61];

	static int* BLACK_HV_3[61];
	static int* WHITE_HV_3[61];

	static int* BLACK_HV_2[61];
	static int* WHITE_HV_2[61];
	
	static int* BLACK_EDGE_6_4[61];
	static int* WHITE_EDGE_6_4[61];

	static int* BLACK_CORNER_2x5[61];
	static int* WHITE_CORNER_2x5[61];

	static int* BLACK_CORNER_11[61];
	static int* WHITE_CORNER_11[61];

	static int* BLACK_EDGE_2XC[61];
	static int* WHITE_EDGE_2XC[61];

	public :
	
		static void load();

};


#endif