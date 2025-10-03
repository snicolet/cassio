/*
 *  RXBBPatterns.h
 *  Roxane
 *
 *  Created by Bruno Causse on 31/07/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef RXBBPATTERN_H
#define RXBBPATTERN_H

#include "RXConstantes.h"
#include "RXBitBoard.h"
#include "RXPattern.h"
#include "RXEvaluation.h"


class RXBBPatterns {

	friend class RXRoxane;
	friend class RXEngine;
							  
	void set_BLACK(const int pos);
	void set_WHITE(const int pos);
															
	RXBitBoard board;
	RXPattern* pattern;

	public :
	
		RXBBPatterns();
		
		RXBBPatterns& operator=(const RXBBPatterns& src);
		
		~RXBBPatterns() {
			delete[] pattern;
		}
		
		void build(const std::string& init);

		void do_move(const RXMove& move);
		void undo_move(const RXMove& move);
				
		// move functions
		#define func(pos)	bool generate_patterns_BLACK_##pos(RXMove& move) const; \
							bool generate_patterns_WHITE_##pos(RXMove& move) const; \
							void update_patterns_BLACK_##pos(RXMove& move) const; \
							void update_patterns_WHITE_##pos(RXMove& move) const;
							
		func(A1); func(B1); func(C1); func(D1); func(E1); func(F1); func(G1); func(H1);
		func(A2); func(B2); func(C2); func(D2); func(E2); func(F2); func(G2); func(H2);
		func(A3); func(B3); func(C3); func(D3); func(E3); func(F3); func(G3); func(H3);
		func(A4); func(B4); func(C4);					  func(F4); func(G4); func(H4);
		func(A5); func(B5); func(C5);					  func(F5); func(G5); func(H5);
		func(A6); func(B6); func(C6); func(D6); func(E6); func(F6); func(G6); func(H6);
		func(A7); func(B7); func(C7); func(D7); func(E7); func(F7); func(G7); func(H7);
		func(A8); func(B8); func(C8); func(D8); func(E8); func(F8); func(G8); func(H8);
		#undef func


		bool (RXBBPatterns::*generate_patterns[64][2])(RXMove& move) const;
		void init_generate_patterns();

		void (RXBBPatterns::*update_patterns[64][2])(RXMove& move) const;
		void init_update_patterns();
		
		double get_n_nodes() const { return board.get_n_nodes(); }
		int get_n_empties() const { return board.n_empties; }

		int final_score() const;
		int get_score();
		int get_score(RXMove& move);

		/* DEBUG */
		friend std::ostream& operator<<(std::ostream& os, RXBBPatterns& sBoard);
		
};


inline void RXBBPatterns::do_move(const RXMove& move) {
	board.do_move(move);
	pattern = move.pattern;
}

inline void RXBBPatterns::undo_move(const RXMove& move) {
	pattern = move.undo_pattern;
	board.undo_move(move);
}


inline int RXBBPatterns::final_score() const {
	int score = board.final_score();
	if(score<0)
		return (-INF_SCORE+1) + (score + 64*VALUE_DISC);
	return (INF_SCORE-1) + (score-64*VALUE_DISC);
}


inline int RXBBPatterns::get_score() {
	
	const int stage = 60-board.n_empties;
	
	const unsigned long long filled = (board.discs[BLACK] | board.discs[WHITE]);
	
	int eval;
	const int* value;
	const int* value_b;
	
	if(board.player == BLACK) {
		
		value = RXEvaluation::BLACK_DIAG_5[stage];
		eval  = value[pattern->diag_5a];
		eval += value[pattern->diag_5b];
		eval += value[pattern->diag_5c];
		eval += value[pattern->diag_5d];
		
		value = RXEvaluation::BLACK_DIAG_6[stage];
		eval += value[pattern->diag_6a];
		eval += value[pattern->diag_6b];
		eval += value[pattern->diag_6c];
		eval += value[pattern->diag_6d];

		value = RXEvaluation::BLACK_DIAG_7[stage];
		eval += value[pattern->diag_7a];
		eval += value[pattern->diag_7b];
		eval += value[pattern->diag_7c];
		eval += value[pattern->diag_7d];

		value = RXEvaluation::BLACK_DIAG_8[stage];
		eval += value[pattern->diag_8a];
		eval += value[pattern->diag_8b];

		value = RXEvaluation::BLACK_HV_4[stage];
		eval += value[pattern->hv_4a];
		eval += value[pattern->hv_4b];
		eval += value[pattern->hv_4c];
		eval += value[pattern->hv_4d];

		value = RXEvaluation::BLACK_HV_3[stage];
		eval += value[pattern->hv_3a];
		eval += value[pattern->hv_3b];
		eval += value[pattern->hv_3c];
		eval += value[pattern->hv_3d];

		value = RXEvaluation::BLACK_HV_2[stage];
		eval += value[pattern->hv_2a];
		eval += value[pattern->hv_2b];
		eval += value[pattern->hv_2c];
		eval += value[pattern->hv_2d];

		value = RXEvaluation::BLACK_CORNER_11[stage];
		eval += value[pattern->corner11a];
		eval += value[pattern->corner11b];
		eval += value[pattern->corner11c];
		eval += value[pattern->corner11d];
		
		value = RXEvaluation::BLACK_CORNER_2x5[stage];
		eval += value[pattern->corner2x5a];
		eval += value[pattern->corner2x5b];
		eval += value[pattern->corner2x5c];
		eval += value[pattern->corner2x5d];
		eval += value[pattern->corner2x5e];
		eval += value[pattern->corner2x5f];
		eval += value[pattern->corner2x5g];
		eval += value[pattern->corner2x5h];
		
		value = RXEvaluation::BLACK_EDGE_2XC[stage];
		value_b = RXEvaluation::BLACK_EDGE_6_4[stage];
		if(filled & 0x8142000000000000ULL)	//A1 H1 B2 G2
			eval += value[pattern->edge2XCa];
		else
			eval += value_b[pattern->edge64a];

		if(filled & 0x0102000000000201ULL) //H1 G2 G7 H8
			eval += value[pattern->edge2XCb];
		else
			eval += value_b[pattern->edge64b];

		if(filled & 0x0000000000004281ULL)	//B7 G7 A8 H8
			eval += value[pattern->edge2XCc];
		else
			eval += value_b[pattern->edge64c];

		if(filled & 0x8040000000004080ULL)	//A1 B2 B7 A8
			eval += value[pattern->edge2XCd];
		else
			eval += value_b[pattern->edge64d];
	
	} else {

		value = RXEvaluation::WHITE_DIAG_5[stage];
		eval  = value[pattern->diag_5a];
		eval += value[pattern->diag_5b];
		eval += value[pattern->diag_5c];
		eval += value[pattern->diag_5d];
		
		value = RXEvaluation::WHITE_DIAG_6[stage];
		eval += value[pattern->diag_6a];
		eval += value[pattern->diag_6b];
		eval += value[pattern->diag_6c];
		eval += value[pattern->diag_6d];

		value = RXEvaluation::WHITE_DIAG_7[stage];
		eval += value[pattern->diag_7a];
		eval += value[pattern->diag_7b];
		eval += value[pattern->diag_7c];
		eval += value[pattern->diag_7d];

		value = RXEvaluation::WHITE_DIAG_8[stage];
		eval += value[pattern->diag_8a];
		eval += value[pattern->diag_8b];

		value = RXEvaluation::WHITE_HV_4[stage];
		eval += value[pattern->hv_4a];
		eval += value[pattern->hv_4b];
		eval += value[pattern->hv_4c];
		eval += value[pattern->hv_4d];

		value = RXEvaluation::WHITE_HV_3[stage];
		eval += value[pattern->hv_3a];
		eval += value[pattern->hv_3b];
		eval += value[pattern->hv_3c];
		eval += value[pattern->hv_3d];

		value = RXEvaluation::WHITE_HV_2[stage];
		eval += value[pattern->hv_2a];
		eval += value[pattern->hv_2b];
		eval += value[pattern->hv_2c];
		eval += value[pattern->hv_2d];

		value = RXEvaluation::WHITE_CORNER_11[stage];
		eval += value[pattern->corner11a];
		eval += value[pattern->corner11b];
		eval += value[pattern->corner11c];
		eval += value[pattern->corner11d];
		
		value = RXEvaluation::WHITE_CORNER_2x5[stage];
		eval += value[pattern->corner2x5a];
		eval += value[pattern->corner2x5b];
		eval += value[pattern->corner2x5c];
		eval += value[pattern->corner2x5d];
		eval += value[pattern->corner2x5e];
		eval += value[pattern->corner2x5f];
		eval += value[pattern->corner2x5g];
		eval += value[pattern->corner2x5h];
		
		value = RXEvaluation::WHITE_EDGE_2XC[stage];
		value_b = RXEvaluation::WHITE_EDGE_6_4[stage];
		if(filled & 0x8142000000000000ULL)	//A1 H1 B2 G2
			eval += value[pattern->edge2XCa];
		else
			eval += value_b[pattern->edge64a];

		if(filled & 0x0102000000000201ULL) //H1 G2 G7 H8
			eval += value[pattern->edge2XCb];
		else
			eval += value_b[pattern->edge64b];

		if(filled & 0x0000000000004281ULL)	//B7 G7 A8 H8
			eval += value[pattern->edge2XCc];
		else
			eval += value_b[pattern->edge64c];

		if(filled & 0x8040000000004080ULL)	//A1 B2 B7 A8
			eval += value[pattern->edge2XCd];
		else
			eval += value_b[pattern->edge64d];
	}
	
	return eval>>4; //div 16
}


inline int RXBBPatterns::get_score(RXMove& move) {

	const RXPattern* const p = move.pattern;
	
	const int stage = 61-board.n_empties;
	
	const unsigned long long filled = (board.discs[BLACK] | board.discs[WHITE] | move.square);
	
	int eval;
	const int* value;
	const int* value_b;
	
	if(board.player == WHITE) {
		
		value = RXEvaluation::BLACK_DIAG_5[stage];
		eval  = value[p->diag_5a];
		eval += value[p->diag_5b];
		eval += value[p->diag_5c];
		eval += value[p->diag_5d];
		
		value = RXEvaluation::BLACK_DIAG_6[stage];
		eval += value[p->diag_6a];
		eval += value[p->diag_6b];
		eval += value[p->diag_6c];
		eval += value[p->diag_6d];

		value = RXEvaluation::BLACK_DIAG_7[stage];
		eval += value[p->diag_7a];
		eval += value[p->diag_7b];
		eval += value[p->diag_7c];
		eval += value[p->diag_7d];

		value = RXEvaluation::BLACK_DIAG_8[stage];
		eval += value[p->diag_8a];
		eval += value[p->diag_8b];

		value = RXEvaluation::BLACK_HV_4[stage];
		eval += value[p->hv_4a];
		eval += value[p->hv_4b];
		eval += value[p->hv_4c];
		eval += value[p->hv_4d];

		value = RXEvaluation::BLACK_HV_3[stage];
		eval += value[p->hv_3a];
		eval += value[p->hv_3b];
		eval += value[p->hv_3c];
		eval += value[p->hv_3d];

		value = RXEvaluation::BLACK_HV_2[stage];
		eval += value[p->hv_2a];
		eval += value[p->hv_2b];
		eval += value[p->hv_2c];
		eval += value[p->hv_2d];

		value = RXEvaluation::BLACK_CORNER_11[stage];
		eval += value[p->corner11a];
		eval += value[p->corner11b];
		eval += value[p->corner11c];
		eval += value[p->corner11d];
		
		value = RXEvaluation::BLACK_CORNER_2x5[stage];
		eval += value[p->corner2x5a];
		eval += value[p->corner2x5b];
		eval += value[p->corner2x5c];
		eval += value[p->corner2x5d];
		eval += value[p->corner2x5e];
		eval += value[p->corner2x5f];
		eval += value[p->corner2x5g];
		eval += value[p->corner2x5h];
		
		value = RXEvaluation::BLACK_EDGE_2XC[stage];
		value_b = RXEvaluation::BLACK_EDGE_6_4[stage];
		if(filled & 0x8142000000000000ULL)	//A1 H1 B2 G2
			eval += value[p->edge2XCa];
		else
			eval += value_b[p->edge64a];

		if(filled & 0x0102000000000201ULL) //H1 G2 G7 H8
			eval += value[p->edge2XCb];
		else
			eval += value_b[p->edge64b];

		if(filled & 0x0000000000004281ULL)	//B7 G7 A8 H8
			eval += value[p->edge2XCc];
		else
			eval += value_b[p->edge64c];

		if(filled & 0x8040000000004080ULL)	//A1 B2 B7 A8
			eval += value[p->edge2XCd];
		else
			eval += value_b[p->edge64d];
	
	} else {

		value = RXEvaluation::WHITE_DIAG_5[stage];
		eval  = value[p->diag_5a];
		eval += value[p->diag_5b];
		eval += value[p->diag_5c];
		eval += value[p->diag_5d];
		
		value = RXEvaluation::WHITE_DIAG_6[stage];
		eval += value[p->diag_6a];
		eval += value[p->diag_6b];
		eval += value[p->diag_6c];
		eval += value[p->diag_6d];

		value = RXEvaluation::WHITE_DIAG_7[stage];
		eval += value[p->diag_7a];
		eval += value[p->diag_7b];
		eval += value[p->diag_7c];
		eval += value[p->diag_7d];

		value = RXEvaluation::WHITE_DIAG_8[stage];
		eval += value[p->diag_8a];
		eval += value[p->diag_8b];

		value = RXEvaluation::WHITE_HV_4[stage];
		eval += value[p->hv_4a];
		eval += value[p->hv_4b];
		eval += value[p->hv_4c];
		eval += value[p->hv_4d];

		value = RXEvaluation::WHITE_HV_3[stage];
		eval += value[p->hv_3a];
		eval += value[p->hv_3b];
		eval += value[p->hv_3c];
		eval += value[p->hv_3d];

		value = RXEvaluation::WHITE_HV_2[stage];
		eval += value[p->hv_2a];
		eval += value[p->hv_2b];
		eval += value[p->hv_2c];
		eval += value[p->hv_2d];

		value = RXEvaluation::WHITE_CORNER_11[stage];
		eval += value[p->corner11a];
		eval += value[p->corner11b];
		eval += value[p->corner11c];
		eval += value[p->corner11d];
		
		value = RXEvaluation::WHITE_CORNER_2x5[stage];
		eval += value[p->corner2x5a];
		eval += value[p->corner2x5b];
		eval += value[p->corner2x5c];
		eval += value[p->corner2x5d];
		eval += value[p->corner2x5e];
		eval += value[p->corner2x5f];
		eval += value[p->corner2x5g];
		eval += value[p->corner2x5h];
		
		value = RXEvaluation::WHITE_EDGE_2XC[stage];
		value_b = RXEvaluation::WHITE_EDGE_6_4[stage];
		if(filled & 0x8142000000000000ULL)	//A1 H1 B2 G2
			eval += value[p->edge2XCa];
		else
			eval += value_b[p->edge64a];

		if(filled & 0x0102000000000201ULL) //H1 G2 G7 H8
			eval += value[p->edge2XCb];
		else
			eval += value_b[p->edge64b];

		if(filled & 0x0000000000004281ULL)	//B7 G7 A8 H8
			eval += value[p->edge2XCc];
		else
			eval += value_b[p->edge64c];

		if(filled & 0x8040000000004080ULL)	//A1 B2 B7 A8
			eval += value[p->edge2XCd];
		else
			eval += value_b[p->edge64d];
	}
	
	return eval>>4; //div 16
}


#endif