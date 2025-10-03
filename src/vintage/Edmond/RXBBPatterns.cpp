/*
 *  RXBBPatterns.cpp
 *  Roxane
 *
 *  Created by Bruno Causse on 31/07/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "RXBBPatterns.h"
#include <string>

#include "RXEvaluation.h"

std::ostream& operator<<(std::ostream& os, RXBBPatterns& sBoard) {
	
	os << sBoard.board << "Evaluation : " << std::setprecision(2) << ((float)sBoard.get_score()/VALUE_DISC) << std::endl;
		
	return os;

}

RXBBPatterns::RXBBPatterns() {

	init_generate_patterns();
	init_update_patterns();

	pattern = new RXPattern();

	pattern->set_WHITE_D4();
	pattern->set_BLACK_E4();
	pattern->set_BLACK_D5();
	pattern->set_WHITE_E5();
	
}

RXBBPatterns& RXBBPatterns::operator=(const RXBBPatterns& src) {

	if(this != &src) {
	
		board = src.board;
	
		memcpy(pattern, src.pattern, sizeof(RXPattern));
	}
	
	return *this;
}

void RXBBPatterns::build(const std::string& init) {

	board.build(init);
	
		pattern->clear();
		
	for(int square = H8; square != PASS; square++) {
	
		unsigned long long pos = 1ULL<<square;
		
		if(board.discs[BLACK] & pos)
			set_BLACK(square);
		else if(board.discs[WHITE] & pos)
			set_WHITE(square);
	}
}

void RXBBPatterns::set_BLACK(const int pos) {

	RXPattern* const p = pattern;

	switch(pos) {
	
		case A1:
			p->set_BLACK_A1();
		break;

		case B1:
			p->set_BLACK_B1();
		break;

		case C1:
			p->set_BLACK_C1();
		break;

		case D1:
			p->set_BLACK_D1();
		break;

		case E1:
			p->set_BLACK_E1();
		break;

		case F1:
			p->set_BLACK_F1();
		break;

		case G1:
			p->set_BLACK_G1();
		break;
		
		case H1:
			p->set_BLACK_H1();
		break;

		case A2:
			p->set_BLACK_A2();
		break;

		case B2:
			p->set_BLACK_B2();
		break;

		case C2:
			p->set_BLACK_C2();
		break;

		case D2:
			p->set_BLACK_D2();
		break;

		case E2:
			p->set_BLACK_E2();
		break;

		case F2:
			p->set_BLACK_F2();
		break;

		case G2:
			p->set_BLACK_G2();
		break;
		
		case H2:
			p->set_BLACK_H2();
		break;
		
		case A3:
			p->set_BLACK_A3();
		break;

		case B3:
			p->set_BLACK_B3();
		break;

		case C3:
			p->set_BLACK_C3();
		break;

		case D3:
			p->set_BLACK_D3();
		break;

		case E3:
			p->set_BLACK_E3();
		break;

		case F3:
			p->set_BLACK_F3();
		break;

		case G3:
			p->set_BLACK_G3();
		break;
		
		case H3:
			p->set_BLACK_H3();
		break;
		
		case A4:
			p->set_BLACK_A4();
		break;

		case B4:
			p->set_BLACK_B4();
		break;

		case C4:
			p->set_BLACK_C4();
		break;

		case D4:
			p->set_BLACK_D4();
		break;

		case E4:
			p->set_BLACK_E4();
		break;

		case F4:
			p->set_BLACK_F4();
		break;

		case G4:
			p->set_BLACK_G4();
		break;
		
		case H4:
			p->set_BLACK_H4();
		break;
		
		case A5:
			p->set_BLACK_A5();
		break;

		case B5:
			p->set_BLACK_B5();
		break;

		case C5:
			p->set_BLACK_C5();
		break;

		case D5:
			p->set_BLACK_D5();
		break;

		case E5:
			p->set_BLACK_E5();
		break;

		case F5:
			p->set_BLACK_F5();
		break;

		case G5:
			p->set_BLACK_G5();
		break;
		
		case H5:
			p->set_BLACK_H5();
		break;

		case A6:
			p->set_BLACK_A6();
		break;

		case B6:
			p->set_BLACK_B6();
		break;

		case C6:
			p->set_BLACK_C6();
		break;

		case D6:
			p->set_BLACK_D6();
		break;

		case E6:
			p->set_BLACK_E6();
		break;

		case F6:
			p->set_BLACK_F6();
		break;

		case G6:
			p->set_BLACK_G6();
		break;
		
		case H6:
			p->set_BLACK_H6();
		break;

		case A7:
			p->set_BLACK_A7();
		break;

		case B7:
			p->set_BLACK_B7();
		break;

		case C7:
			p->set_BLACK_C7();
		break;

		case D7:
			p->set_BLACK_D7();
		break;

		case E7:
			p->set_BLACK_E7();
		break;

		case F7:
			p->set_BLACK_F7();
		break;

		case G7:
			p->set_BLACK_G7();
		break;
		
		case H7:
			p->set_BLACK_H7();
		break;

		case A8:
			p->set_BLACK_A8();
		break;

		case B8:
			p->set_BLACK_B8();
		break;

		case C8:
			p->set_BLACK_C8();
		break;

		case D8:
			p->set_BLACK_D8();
		break;

		case E8:
			p->set_BLACK_E8();
		break;

		case F8:
			p->set_BLACK_F8();
		break;

		case G8:
			p->set_BLACK_G8();
		break;
		
		case H8:
			p->set_BLACK_H8();
		break;
	}
}

void RXBBPatterns::set_WHITE(const int pos) {

	RXPattern* const p = pattern;

	switch(pos) {
	
		case A1:
			p->set_WHITE_A1();
		break;

		case B1:
			p->set_WHITE_B1();
		break;

		case C1:
			p->set_WHITE_C1();
		break;

		case D1:
			p->set_WHITE_D1();
		break;

		case E1:
			p->set_WHITE_E1();
		break;

		case F1:
			p->set_WHITE_F1();
		break;

		case G1:
			p->set_WHITE_G1();
		break;
		
		case H1:
			p->set_WHITE_H1();
		break;

		case A2:
			p->set_WHITE_A2();
		break;

		case B2:
			p->set_WHITE_B2();
		break;

		case C2:
			p->set_WHITE_C2();
		break;

		case D2:
			p->set_WHITE_D2();
		break;

		case E2:
			p->set_WHITE_E2();
		break;

		case F2:
			p->set_WHITE_F2();
		break;

		case G2:
			p->set_WHITE_G2();
		break;
		
		case H2:
			p->set_WHITE_H2();
		break;
		
		case A3:
			p->set_WHITE_A3();
		break;

		case B3:
			p->set_WHITE_B3();
		break;

		case C3:
			p->set_WHITE_C3();
		break;

		case D3:
			p->set_WHITE_D3();
		break;

		case E3:
			p->set_WHITE_E3();
		break;

		case F3:
			p->set_WHITE_F3();
		break;

		case G3:
			p->set_WHITE_G3();
		break;
		
		case H3:
			p->set_WHITE_H3();
		break;
		
		case A4:
			p->set_WHITE_A4();
		break;

		case B4:
			p->set_WHITE_B4();
		break;

		case C4:
			p->set_WHITE_C4();
		break;

		case D4:
			p->set_WHITE_D4();
		break;

		case E4:
			p->set_WHITE_E4();
		break;

		case F4:
			p->set_WHITE_F4();
		break;

		case G4:
			p->set_WHITE_G4();
		break;
		
		case H4:
			p->set_WHITE_H4();
		break;
		
		case A5:
			p->set_WHITE_A5();
		break;

		case B5:
			p->set_WHITE_B5();
		break;

		case C5:
			p->set_WHITE_C5();
		break;

		case D5:
			p->set_WHITE_D5();
		break;

		case E5:
			p->set_WHITE_E5();
		break;

		case F5:
			p->set_WHITE_F5();
		break;

		case G5:
			p->set_WHITE_G5();
		break;
		
		case H5:
			p->set_WHITE_H5();
		break;

		case A6:
			p->set_WHITE_A6();
		break;

		case B6:
			p->set_WHITE_B6();
		break;

		case C6:
			p->set_WHITE_C6();
		break;

		case D6:
			p->set_WHITE_D6();
		break;

		case E6:
			p->set_WHITE_E6();
		break;

		case F6:
			p->set_WHITE_F6();
		break;

		case G6:
			p->set_WHITE_G6();
		break;
		
		case H6:
			p->set_WHITE_H6();
		break;

		case A7:
			p->set_WHITE_A7();
		break;

		case B7:
			p->set_WHITE_B7();
		break;

		case C7:
			p->set_WHITE_C7();
		break;

		case D7:
			p->set_WHITE_D7();
		break;

		case E7:
			p->set_WHITE_E7();
		break;

		case F7:
			p->set_WHITE_F7();
		break;

		case G7:
			p->set_WHITE_G7();
		break;
		
		case H7:
			p->set_WHITE_H7();
		break;

		case A8:
			p->set_WHITE_A8();
		break;

		case B8:
			p->set_WHITE_B8();
		break;

		case C8:
			p->set_WHITE_C8();
		break;

		case D8:
			p->set_WHITE_D8();
		break;

		case E8:
			p->set_WHITE_E8();
		break;

		case F8:
			p->set_WHITE_F8();
		break;

		case G8:
			p->set_WHITE_G8();
		break;
		
		case H8:
			p->set_WHITE_H8();
		break;
	}
}

void RXBBPatterns::update_patterns_BLACK_A1(RXMove& move) const {

	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_A1();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0040201008040200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040201008040200ULL:
				p->flip_BLACK_G7();
			case 0X0040201008040000ULL:
				p->flip_BLACK_F6();
			case 0X0040201008000000ULL:
				p->flip_BLACK_E5();
			case 0X0040201000000000ULL:
				p->flip_BLACK_D4();
			case 0X0040200000000000ULL:
				p->flip_BLACK_C3();
			default :
				p->flip_BLACK_B2();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0080808080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808080808000ULL:
				p->flip_BLACK_A7();
			case 0X0080808080800000ULL:
				p->flip_BLACK_A6();
			case 0X0080808080000000ULL:
				p->flip_BLACK_A5();
			case 0X0080808000000000ULL:
				p->flip_BLACK_A4();
			case 0X0080800000000000ULL:
				p->flip_BLACK_A3();
			default :
				p->flip_BLACK_A2();
		}


	/* direction _E */
	flipped = move.flipped & 0X7E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7E00000000000000ULL:
				p->flip_BLACK_G1();
			case 0X7C00000000000000ULL:
				p->flip_BLACK_F1();
			case 0X7800000000000000ULL:
				p->flip_BLACK_E1();
			case 0X7000000000000000ULL:
				p->flip_BLACK_D1();
			case 0X6000000000000000ULL:
				p->flip_BLACK_C1();
			default :
				p->flip_BLACK_B1();
		}


}

void RXBBPatterns::update_patterns_BLACK_B1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_B1();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0020100804020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020100804020000ULL:
				p->flip_BLACK_G6();
			case 0X0020100804000000ULL:
				p->flip_BLACK_F5();
			case 0X0020100800000000ULL:
				p->flip_BLACK_E4();
			case 0X0020100000000000ULL:
				p->flip_BLACK_D3();
			default :
				p->flip_BLACK_C2();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0040404040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404040404000ULL:
				p->flip_BLACK_B7();
			case 0X0040404040400000ULL:
				p->flip_BLACK_B6();
			case 0X0040404040000000ULL:
				p->flip_BLACK_B5();
			case 0X0040404000000000ULL:
				p->flip_BLACK_B4();
			case 0X0040400000000000ULL:
				p->flip_BLACK_B3();
			default :
				p->flip_BLACK_B2();
		}


	/* direction _E */
	flipped = move.flipped & 0X3E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X3E00000000000000ULL:
				p->flip_BLACK_G1();
			case 0X3C00000000000000ULL:
				p->flip_BLACK_F1();
			case 0X3800000000000000ULL:
				p->flip_BLACK_E1();
			case 0X3000000000000000ULL:
				p->flip_BLACK_D1();
			default :
				p->flip_BLACK_C1();
		}


}

void RXBBPatterns::update_patterns_BLACK_C1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_C1();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0020202020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202020202000ULL:
				p->flip_BLACK_C7();
			case 0X0020202020200000ULL:
				p->flip_BLACK_C6();
			case 0X0020202020000000ULL:
				p->flip_BLACK_C5();
			case 0X0020202000000000ULL:
				p->flip_BLACK_C4();
			case 0X0020200000000000ULL:
				p->flip_BLACK_C3();
			default :
				p->flip_BLACK_C2();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0010080402000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010080402000000ULL:
				p->flip_BLACK_G5();
			case 0X0010080400000000ULL:
				p->flip_BLACK_F4();
			case 0X0010080000000000ULL:
				p->flip_BLACK_E3();
			default :
				p->flip_BLACK_D2();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_BLACK_B2();

	/* direction _E */
	flipped = move.flipped & 0X1E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X1E00000000000000ULL:
				p->flip_BLACK_G1();
			case 0X1C00000000000000ULL:
				p->flip_BLACK_F1();
			case 0X1800000000000000ULL:
				p->flip_BLACK_E1();
			default :
				p->flip_BLACK_D1();
		}


	/* direction _W */
	flipped = move.flipped & 0X4000000000000000ULL;
	if(flipped)
		p->flip_BLACK_B1();

}

void RXBBPatterns::update_patterns_BLACK_D1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_D1();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0010101010101000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010101010101000ULL:
				p->flip_BLACK_D7();
			case 0X0010101010100000ULL:
				p->flip_BLACK_D6();
			case 0X0010101010000000ULL:
				p->flip_BLACK_D5();
			case 0X0010101000000000ULL:
				p->flip_BLACK_D4();
			case 0X0010100000000000ULL:
				p->flip_BLACK_D3();
			default :
				p->flip_BLACK_D2();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0008040200000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008040200000000ULL:
				p->flip_BLACK_G4();
			case 0X0008040000000000ULL:
				p->flip_BLACK_F3();
			default :
				p->flip_BLACK_E2();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0020400000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020400000000000ULL:
				p->flip_BLACK_B3();
			default :
				p->flip_BLACK_C2();
		}


	/* direction _E */
	flipped = move.flipped & 0X0E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0E00000000000000ULL:
				p->flip_BLACK_G1();
			case 0X0C00000000000000ULL:
				p->flip_BLACK_F1();
			default :
				p->flip_BLACK_E1();
		}


	/* direction _W */
	flipped = move.flipped & 0X6000000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X6000000000000000ULL:
				p->flip_BLACK_B1();
			default :
				p->flip_BLACK_C1();
		}


}

void RXBBPatterns::update_patterns_BLACK_E1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_E1();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0008080808080800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008080808080800ULL:
				p->flip_BLACK_E7();
			case 0X0008080808080000ULL:
				p->flip_BLACK_E6();
			case 0X0008080808000000ULL:
				p->flip_BLACK_E5();
			case 0X0008080800000000ULL:
				p->flip_BLACK_E4();
			case 0X0008080000000000ULL:
				p->flip_BLACK_E3();
			default :
				p->flip_BLACK_E2();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0004020000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004020000000000ULL:
				p->flip_BLACK_G3();
			default :
				p->flip_BLACK_F2();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0010204000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010204000000000ULL:
				p->flip_BLACK_B4();
			case 0X0010200000000000ULL:
				p->flip_BLACK_C3();
			default :
				p->flip_BLACK_D2();
		}


	/* direction _E */
	flipped = move.flipped & 0X0600000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0600000000000000ULL:
				p->flip_BLACK_G1();
			default :
				p->flip_BLACK_F1();
		}


	/* direction _W */
	flipped = move.flipped & 0X7000000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7000000000000000ULL:
				p->flip_BLACK_B1();
			case 0X3000000000000000ULL:
				p->flip_BLACK_C1();
			default :
				p->flip_BLACK_D1();
		}


}

void RXBBPatterns::update_patterns_BLACK_F1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_F1();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0004040404040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040404040400ULL:
				p->flip_BLACK_F7();
			case 0X0004040404040000ULL:
				p->flip_BLACK_F6();
			case 0X0004040404000000ULL:
				p->flip_BLACK_F5();
			case 0X0004040400000000ULL:
				p->flip_BLACK_F4();
			case 0X0004040000000000ULL:
				p->flip_BLACK_F3();
			default :
				p->flip_BLACK_F2();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_BLACK_G2();

	/* direction _SW */
	flipped = move.flipped & 0X0008102040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008102040000000ULL:
				p->flip_BLACK_B5();
			case 0X0008102000000000ULL:
				p->flip_BLACK_C4();
			case 0X0008100000000000ULL:
				p->flip_BLACK_D3();
			default :
				p->flip_BLACK_E2();
		}


	/* direction _E */
	flipped = move.flipped & 0X0200000000000000ULL;
	if(flipped)
		p->flip_BLACK_G1();

	/* direction _W */
	flipped = move.flipped & 0X7800000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7800000000000000ULL:
				p->flip_BLACK_B1();
			case 0X3800000000000000ULL:
				p->flip_BLACK_C1();
			case 0X1800000000000000ULL:
				p->flip_BLACK_D1();
			default :
				p->flip_BLACK_E1();
		}


}

void RXBBPatterns::update_patterns_BLACK_G1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_G1();

	/* direction _SW */
	unsigned long long flipped = move.flipped & 0X0004081020400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004081020400000ULL:
				p->flip_BLACK_B6();
			case 0X0004081020000000ULL:
				p->flip_BLACK_C5();
			case 0X0004081000000000ULL:
				p->flip_BLACK_D4();
			case 0X0004080000000000ULL:
				p->flip_BLACK_E3();
			default :
				p->flip_BLACK_F2();
		}


	/* direction _W */
	flipped = move.flipped & 0X7C00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7C00000000000000ULL:
				p->flip_BLACK_B1();
			case 0X3C00000000000000ULL:
				p->flip_BLACK_C1();
			case 0X1C00000000000000ULL:
				p->flip_BLACK_D1();
			case 0X0C00000000000000ULL:
				p->flip_BLACK_E1();
			default :
				p->flip_BLACK_F1();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0002020202020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020202020200ULL:
				p->flip_BLACK_G7();
			case 0X0002020202020000ULL:
				p->flip_BLACK_G6();
			case 0X0002020202000000ULL:
				p->flip_BLACK_G5();
			case 0X0002020200000000ULL:
				p->flip_BLACK_G4();
			case 0X0002020000000000ULL:
				p->flip_BLACK_G3();
			default :
				p->flip_BLACK_G2();
		}


}

void RXBBPatterns::update_patterns_BLACK_H1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_H1();

	/* direction _SW */
	unsigned long long flipped = move.flipped & 0X0002040810204000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002040810204000ULL:
				p->flip_BLACK_B7();
			case 0X0002040810200000ULL:
				p->flip_BLACK_C6();
			case 0X0002040810000000ULL:
				p->flip_BLACK_D5();
			case 0X0002040800000000ULL:
				p->flip_BLACK_E4();
			case 0X0002040000000000ULL:
				p->flip_BLACK_F3();
			default :
				p->flip_BLACK_G2();
		}


	/* direction _W */
	flipped = move.flipped & 0X7E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7E00000000000000ULL:
				p->flip_BLACK_B1();
			case 0X3E00000000000000ULL:
				p->flip_BLACK_C1();
			case 0X1E00000000000000ULL:
				p->flip_BLACK_D1();
			case 0X0E00000000000000ULL:
				p->flip_BLACK_E1();
			case 0X0600000000000000ULL:
				p->flip_BLACK_F1();
			default :
				p->flip_BLACK_G1();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0001010101010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010101010100ULL:
				p->flip_BLACK_H7();
			case 0X0001010101010000ULL:
				p->flip_BLACK_H6();
			case 0X0001010101000000ULL:
				p->flip_BLACK_H5();
			case 0X0001010100000000ULL:
				p->flip_BLACK_H4();
			case 0X0001010000000000ULL:
				p->flip_BLACK_H3();
			default :
				p->flip_BLACK_H2();
		}


}

void RXBBPatterns::update_patterns_BLACK_A2(RXMove& move) const {


	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_A2();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000402010080400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000402010080400ULL:
				p->flip_BLACK_F7();
			case 0X0000402010080000ULL:
				p->flip_BLACK_E6();
			case 0X0000402010000000ULL:
				p->flip_BLACK_D5();
			case 0X0000402000000000ULL:
				p->flip_BLACK_C4();
			default :
				p->flip_BLACK_B3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000808080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000808080808000ULL:
				p->flip_BLACK_A7();
			case 0X0000808080800000ULL:
				p->flip_BLACK_A6();
			case 0X0000808080000000ULL:
				p->flip_BLACK_A5();
			case 0X0000808000000000ULL:
				p->flip_BLACK_A4();
			default :
				p->flip_BLACK_A3();
		}


	/* direction _E */
	flipped = move.flipped & 0X007E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X007E000000000000ULL:
				p->flip_BLACK_G2();
			case 0X007C000000000000ULL:
				p->flip_BLACK_F2();
			case 0X0078000000000000ULL:
				p->flip_BLACK_E2();
			case 0X0070000000000000ULL:
				p->flip_BLACK_D2();
			case 0X0060000000000000ULL:
				p->flip_BLACK_C2();
			default :
				p->flip_BLACK_B2();
		}


}

void RXBBPatterns::update_patterns_BLACK_B2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_B2();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000201008040200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000201008040200ULL:
				p->flip_BLACK_G7();
			case 0X0000201008040000ULL:
				p->flip_BLACK_F6();
			case 0X0000201008000000ULL:
				p->flip_BLACK_E5();
			case 0X0000201000000000ULL:
				p->flip_BLACK_D4();
			default :
				p->flip_BLACK_C3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000404040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000404040404000ULL:
				p->flip_BLACK_B7();
			case 0X0000404040400000ULL:
				p->flip_BLACK_B6();
			case 0X0000404040000000ULL:
				p->flip_BLACK_B5();
			case 0X0000404000000000ULL:
				p->flip_BLACK_B4();
			default :
				p->flip_BLACK_B3();
		}


	/* direction _E */
	flipped = move.flipped & 0X003E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X003E000000000000ULL:
				p->flip_BLACK_G2();
			case 0X003C000000000000ULL:
				p->flip_BLACK_F2();
			case 0X0038000000000000ULL:
				p->flip_BLACK_E2();
			case 0X0030000000000000ULL:
				p->flip_BLACK_D2();
			default :
				p->flip_BLACK_C2();
		}


}

void RXBBPatterns::update_patterns_BLACK_C2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_C2();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0000202020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000202020202000ULL:
				p->flip_BLACK_C7();
			case 0X0000202020200000ULL:
				p->flip_BLACK_C6();
			case 0X0000202020000000ULL:
				p->flip_BLACK_C5();
			case 0X0000202000000000ULL:
				p->flip_BLACK_C4();
			default :
				p->flip_BLACK_C3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000100804020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000100804020000ULL:
				p->flip_BLACK_G6();
			case 0X0000100804000000ULL:
				p->flip_BLACK_F5();
			case 0X0000100800000000ULL:
				p->flip_BLACK_E4();
			default :
				p->flip_BLACK_D3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000400000000000ULL;
	if(flipped)
		p->flip_BLACK_B3();

	/* direction _E */
	flipped = move.flipped & 0X001E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X001E000000000000ULL:
				p->flip_BLACK_G2();
			case 0X001C000000000000ULL:
				p->flip_BLACK_F2();
			case 0X0018000000000000ULL:
				p->flip_BLACK_E2();
			default :
				p->flip_BLACK_D2();
		}


	/* direction _W */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_BLACK_B2();

}

void RXBBPatterns::update_patterns_BLACK_D2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_D2();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0000101010101000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000101010101000ULL:
				p->flip_BLACK_D7();
			case 0X0000101010100000ULL:
				p->flip_BLACK_D6();
			case 0X0000101010000000ULL:
				p->flip_BLACK_D5();
			case 0X0000101000000000ULL:
				p->flip_BLACK_D4();
			default :
				p->flip_BLACK_D3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000080402000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000080402000000ULL:
				p->flip_BLACK_G5();
			case 0X0000080400000000ULL:
				p->flip_BLACK_F4();
			default :
				p->flip_BLACK_E3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000204000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000204000000000ULL:
				p->flip_BLACK_B4();
			default :
				p->flip_BLACK_C3();
		}


	/* direction _E */
	flipped = move.flipped & 0X000E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000E000000000000ULL:
				p->flip_BLACK_G2();
			case 0X000C000000000000ULL:
				p->flip_BLACK_F2();
			default :
				p->flip_BLACK_E2();
		}


	/* direction _W */
	flipped = move.flipped & 0X0060000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0060000000000000ULL:
				p->flip_BLACK_B2();
			default :
				p->flip_BLACK_C2();
		}


}

void RXBBPatterns::update_patterns_BLACK_E2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_E2();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0000080808080800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000080808080800ULL:
				p->flip_BLACK_E7();
			case 0X0000080808080000ULL:
				p->flip_BLACK_E6();
			case 0X0000080808000000ULL:
				p->flip_BLACK_E5();
			case 0X0000080800000000ULL:
				p->flip_BLACK_E4();
			default :
				p->flip_BLACK_E3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000040200000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000040200000000ULL:
				p->flip_BLACK_G4();
			default :
				p->flip_BLACK_F3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000102040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000102040000000ULL:
				p->flip_BLACK_B5();
			case 0X0000102000000000ULL:
				p->flip_BLACK_C4();
			default :
				p->flip_BLACK_D3();
		}


	/* direction _E */
	flipped = move.flipped & 0X0006000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0006000000000000ULL:
				p->flip_BLACK_G2();
			default :
				p->flip_BLACK_F2();
		}


	/* direction _W */
	flipped = move.flipped & 0X0070000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0070000000000000ULL:
				p->flip_BLACK_B2();
			case 0X0030000000000000ULL:
				p->flip_BLACK_C2();
			default :
				p->flip_BLACK_D2();
		}


}

void RXBBPatterns::update_patterns_BLACK_F2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_F2();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0000040404040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000040404040400ULL:
				p->flip_BLACK_F7();
			case 0X0000040404040000ULL:
				p->flip_BLACK_F6();
			case 0X0000040404000000ULL:
				p->flip_BLACK_F5();
			case 0X0000040400000000ULL:
				p->flip_BLACK_F4();
			default :
				p->flip_BLACK_F3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000020000000000ULL;
	if(flipped)
		p->flip_BLACK_G3();

	/* direction _SW */
	flipped = move.flipped & 0X0000081020400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000081020400000ULL:
				p->flip_BLACK_B6();
			case 0X0000081020000000ULL:
				p->flip_BLACK_C5();
			case 0X0000081000000000ULL:
				p->flip_BLACK_D4();
			default :
				p->flip_BLACK_E3();
		}


	/* direction _E */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_BLACK_G2();

	/* direction _W */
	flipped = move.flipped & 0X0078000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0078000000000000ULL:
				p->flip_BLACK_B2();
			case 0X0038000000000000ULL:
				p->flip_BLACK_C2();
			case 0X0018000000000000ULL:
				p->flip_BLACK_D2();
			default :
				p->flip_BLACK_E2();
		}


}

void RXBBPatterns::update_patterns_BLACK_G2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_G2();

	/* direction _SW */
	unsigned long long flipped = move.flipped & 0X0000040810204000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000040810204000ULL:
				p->flip_BLACK_B7();
			case 0X0000040810200000ULL:
				p->flip_BLACK_C6();
			case 0X0000040810000000ULL:
				p->flip_BLACK_D5();
			case 0X0000040800000000ULL:
				p->flip_BLACK_E4();
			default :
				p->flip_BLACK_F3();
		}


	/* direction _W */
	flipped = move.flipped & 0X007C000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X007C000000000000ULL:
				p->flip_BLACK_B2();
			case 0X003C000000000000ULL:
				p->flip_BLACK_C2();
			case 0X001C000000000000ULL:
				p->flip_BLACK_D2();
			case 0X000C000000000000ULL:
				p->flip_BLACK_E2();
			default :
				p->flip_BLACK_F2();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000020202020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020202020200ULL:
				p->flip_BLACK_G7();
			case 0X0000020202020000ULL:
				p->flip_BLACK_G6();
			case 0X0000020202000000ULL:
				p->flip_BLACK_G5();
			case 0X0000020200000000ULL:
				p->flip_BLACK_G4();
			default :
				p->flip_BLACK_G3();
		}


}

void RXBBPatterns::update_patterns_BLACK_H2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_H2();

	/* direction _SW */
	unsigned long long flipped = move.flipped & 0X0000020408102000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020408102000ULL:
				p->flip_BLACK_C7();
			case 0X0000020408100000ULL:
				p->flip_BLACK_D6();
			case 0X0000020408000000ULL:
				p->flip_BLACK_E5();
			case 0X0000020400000000ULL:
				p->flip_BLACK_F4();
			default :
				p->flip_BLACK_G3();
		}


	/* direction _W */
	flipped = move.flipped & 0X007E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X007E000000000000ULL:
				p->flip_BLACK_B2();
			case 0X003E000000000000ULL:
				p->flip_BLACK_C2();
			case 0X001E000000000000ULL:
				p->flip_BLACK_D2();
			case 0X000E000000000000ULL:
				p->flip_BLACK_E2();
			case 0X0006000000000000ULL:
				p->flip_BLACK_F2();
			default :
				p->flip_BLACK_G2();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000010101010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000010101010100ULL:
				p->flip_BLACK_H7();
			case 0X0000010101010000ULL:
				p->flip_BLACK_H6();
			case 0X0000010101000000ULL:
				p->flip_BLACK_H5();
			case 0X0000010100000000ULL:
				p->flip_BLACK_H4();
			default :
				p->flip_BLACK_H3();
		}


}

void RXBBPatterns::update_patterns_BLACK_A3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_A3();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X00007E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00007E0000000000ULL:
				p->flip_BLACK_G3();
			case 0X00007C0000000000ULL:
				p->flip_BLACK_F3();
			case 0X0000780000000000ULL:
				p->flip_BLACK_E3();
			case 0X0000700000000000ULL:
				p->flip_BLACK_D3();
			case 0X0000600000000000ULL:
				p->flip_BLACK_C3();
			default :
				p->flip_BLACK_B3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_BLACK_B2();

	/* direction _SE */
	flipped = move.flipped & 0X0000004020100800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004020100800ULL:
				p->flip_BLACK_E7();
			case 0X0000004020100000ULL:
				p->flip_BLACK_D6();
			case 0X0000004020000000ULL:
				p->flip_BLACK_C5();
			default :
				p->flip_BLACK_B4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080000000000000ULL;
	if(flipped)
		p->flip_BLACK_A2();

	/* direction S_ */
	flipped = move.flipped & 0X0000008080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000008080808000ULL:
				p->flip_BLACK_A7();
			case 0X0000008080800000ULL:
				p->flip_BLACK_A6();
			case 0X0000008080000000ULL:
				p->flip_BLACK_A5();
			default :
				p->flip_BLACK_A4();
		}


}

void RXBBPatterns::update_patterns_BLACK_B3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_B3();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X00003E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00003E0000000000ULL:
				p->flip_BLACK_G3();
			case 0X00003C0000000000ULL:
				p->flip_BLACK_F3();
			case 0X0000380000000000ULL:
				p->flip_BLACK_E3();
			case 0X0000300000000000ULL:
				p->flip_BLACK_D3();
			default :
				p->flip_BLACK_C3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0020000000000000ULL;
	if(flipped)
		p->flip_BLACK_C2();

	/* direction _SE */
	flipped = move.flipped & 0X0000002010080400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000002010080400ULL:
				p->flip_BLACK_F7();
			case 0X0000002010080000ULL:
				p->flip_BLACK_E6();
			case 0X0000002010000000ULL:
				p->flip_BLACK_D5();
			default :
				p->flip_BLACK_C4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_BLACK_B2();

	/* direction S_ */
	flipped = move.flipped & 0X0000004040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004040404000ULL:
				p->flip_BLACK_B7();
			case 0X0000004040400000ULL:
				p->flip_BLACK_B6();
			case 0X0000004040000000ULL:
				p->flip_BLACK_B5();
			default :
				p->flip_BLACK_B4();
		}


}

void RXBBPatterns::update_patterns_BLACK_C3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_C3();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000001008040200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000001008040200ULL:
				p->flip_BLACK_G7();
			case 0X0000001008040000ULL:
				p->flip_BLACK_F6();
			case 0X0000001008000000ULL:
				p->flip_BLACK_E5();
			default :
				p->flip_BLACK_D4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000002020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000002020202000ULL:
				p->flip_BLACK_C7();
			case 0X0000002020200000ULL:
				p->flip_BLACK_C6();
			case 0X0000002020000000ULL:
				p->flip_BLACK_C5();
			default :
				p->flip_BLACK_C4();
		}


	/* direction _E */
	flipped = move.flipped & 0X00001E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00001E0000000000ULL:
				p->flip_BLACK_G3();
			case 0X00001C0000000000ULL:
				p->flip_BLACK_F3();
			case 0X0000180000000000ULL:
				p->flip_BLACK_E3();
			default :
				p->flip_BLACK_D3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0010000000000000ULL;
	if(flipped)
		p->flip_BLACK_D2();

	/* direction _N */
	flipped = move.flipped & 0X0020000000000000ULL;
	if(flipped)
		p->flip_BLACK_C2();

	/* direction NW */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_BLACK_B2();

	/* direction _SW */
	flipped = move.flipped & 0X0000004000000000ULL;
	if(flipped)
		p->flip_BLACK_B4();

	/* direction _W */
	flipped = move.flipped & 0X0000400000000000ULL;
	if(flipped)
		p->flip_BLACK_B3();

}

void RXBBPatterns::update_patterns_BLACK_D3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_D3();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000804020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000804020000ULL:
				p->flip_BLACK_G6();
			case 0X0000000804000000ULL:
				p->flip_BLACK_F5();
			default :
				p->flip_BLACK_E4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000001010101000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000001010101000ULL:
				p->flip_BLACK_D7();
			case 0X0000001010100000ULL:
				p->flip_BLACK_D6();
			case 0X0000001010000000ULL:
				p->flip_BLACK_D5();
			default :
				p->flip_BLACK_D4();
		}


	/* direction _E */
	flipped = move.flipped & 0X00000E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000E0000000000ULL:
				p->flip_BLACK_G3();
			case 0X00000C0000000000ULL:
				p->flip_BLACK_F3();
			default :
				p->flip_BLACK_E3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0008000000000000ULL;
	if(flipped)
		p->flip_BLACK_E2();

	/* direction _N */
	flipped = move.flipped & 0X0010000000000000ULL;
	if(flipped)
		p->flip_BLACK_D2();

	/* direction NW */
	flipped = move.flipped & 0X0020000000000000ULL;
	if(flipped)
		p->flip_BLACK_C2();

	/* direction _SW */
	flipped = move.flipped & 0X0000002040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000002040000000ULL:
				p->flip_BLACK_B5();
			default :
				p->flip_BLACK_C4();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000600000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000600000000000ULL:
				p->flip_BLACK_B3();
			default :
				p->flip_BLACK_C3();
		}


}

void RXBBPatterns::update_patterns_BLACK_E3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_E3();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000402000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000402000000ULL:
				p->flip_BLACK_G5();
			default :
				p->flip_BLACK_F4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000808080800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000808080800ULL:
				p->flip_BLACK_E7();
			case 0X0000000808080000ULL:
				p->flip_BLACK_E6();
			case 0X0000000808000000ULL:
				p->flip_BLACK_E5();
			default :
				p->flip_BLACK_E4();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000060000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000060000000000ULL:
				p->flip_BLACK_G3();
			default :
				p->flip_BLACK_F3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0004000000000000ULL;
	if(flipped)
		p->flip_BLACK_F2();

	/* direction _N */
	flipped = move.flipped & 0X0008000000000000ULL;
	if(flipped)
		p->flip_BLACK_E2();

	/* direction NW */
	flipped = move.flipped & 0X0010000000000000ULL;
	if(flipped)
		p->flip_BLACK_D2();

	/* direction _SW */
	flipped = move.flipped & 0X0000001020400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000001020400000ULL:
				p->flip_BLACK_B6();
			case 0X0000001020000000ULL:
				p->flip_BLACK_C5();
			default :
				p->flip_BLACK_D4();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000700000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000700000000000ULL:
				p->flip_BLACK_B3();
			case 0X0000300000000000ULL:
				p->flip_BLACK_C3();
			default :
				p->flip_BLACK_D3();
		}


}

void RXBBPatterns::update_patterns_BLACK_F3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_F3();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000200000000ULL;
	if(flipped)
		p->flip_BLACK_G4();

	/* direction S_ */
	flipped = move.flipped & 0X0000000404040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000404040400ULL:
				p->flip_BLACK_F7();
			case 0X0000000404040000ULL:
				p->flip_BLACK_F6();
			case 0X0000000404000000ULL:
				p->flip_BLACK_F5();
			default :
				p->flip_BLACK_F4();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000020000000000ULL;
	if(flipped)
		p->flip_BLACK_G3();

	/* direction NE */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_BLACK_G2();

	/* direction _N */
	flipped = move.flipped & 0X0004000000000000ULL;
	if(flipped)
		p->flip_BLACK_F2();

	/* direction NW */
	flipped = move.flipped & 0X0008000000000000ULL;
	if(flipped)
		p->flip_BLACK_E2();

	/* direction _SW */
	flipped = move.flipped & 0X0000000810204000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000810204000ULL:
				p->flip_BLACK_B7();
			case 0X0000000810200000ULL:
				p->flip_BLACK_C6();
			case 0X0000000810000000ULL:
				p->flip_BLACK_D5();
			default :
				p->flip_BLACK_E4();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000780000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000780000000000ULL:
				p->flip_BLACK_B3();
			case 0X0000380000000000ULL:
				p->flip_BLACK_C3();
			case 0X0000180000000000ULL:
				p->flip_BLACK_D3();
			default :
				p->flip_BLACK_E3();
		}


}

void RXBBPatterns::update_patterns_BLACK_G3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_G3();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X00007C0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00007C0000000000ULL:
				p->flip_BLACK_B3();
			case 0X00003C0000000000ULL:
				p->flip_BLACK_C3();
			case 0X00001C0000000000ULL:
				p->flip_BLACK_D3();
			case 0X00000C0000000000ULL:
				p->flip_BLACK_E3();
			default :
				p->flip_BLACK_F3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000408102000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000408102000ULL:
				p->flip_BLACK_C7();
			case 0X0000000408100000ULL:
				p->flip_BLACK_D6();
			case 0X0000000408000000ULL:
				p->flip_BLACK_E5();
			default :
				p->flip_BLACK_F4();
		}


	/* direction NW */
	flipped = move.flipped & 0X0004000000000000ULL;
	if(flipped)
		p->flip_BLACK_F2();

	/* direction S_ */
	flipped = move.flipped & 0X0000000202020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000202020200ULL:
				p->flip_BLACK_G7();
			case 0X0000000202020000ULL:
				p->flip_BLACK_G6();
			case 0X0000000202000000ULL:
				p->flip_BLACK_G5();
			default :
				p->flip_BLACK_G4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_BLACK_G2();

}

void RXBBPatterns::update_patterns_BLACK_H3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_H3();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X00007E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00007E0000000000ULL:
				p->flip_BLACK_B3();
			case 0X00003E0000000000ULL:
				p->flip_BLACK_C3();
			case 0X00001E0000000000ULL:
				p->flip_BLACK_D3();
			case 0X00000E0000000000ULL:
				p->flip_BLACK_E3();
			case 0X0000060000000000ULL:
				p->flip_BLACK_F3();
			default :
				p->flip_BLACK_G3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000204081000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000204081000ULL:
				p->flip_BLACK_D7();
			case 0X0000000204080000ULL:
				p->flip_BLACK_E6();
			case 0X0000000204000000ULL:
				p->flip_BLACK_F5();
			default :
				p->flip_BLACK_G4();
		}


	/* direction NW */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_BLACK_G2();

	/* direction S_ */
	flipped = move.flipped & 0X0000000101010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000101010100ULL:
				p->flip_BLACK_H7();
			case 0X0000000101010000ULL:
				p->flip_BLACK_H6();
			case 0X0000000101000000ULL:
				p->flip_BLACK_H5();
			default :
				p->flip_BLACK_H4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001000000000000ULL;
	if(flipped)
		p->flip_BLACK_H2();

}

void RXBBPatterns::update_patterns_BLACK_A4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_A4();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X0000007E00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000007E00000000ULL:
				p->flip_BLACK_G4();
			case 0X0000007C00000000ULL:
				p->flip_BLACK_F4();
			case 0X0000007800000000ULL:
				p->flip_BLACK_E4();
			case 0X0000007000000000ULL:
				p->flip_BLACK_D4();
			case 0X0000006000000000ULL:
				p->flip_BLACK_C4();
			default :
				p->flip_BLACK_B4();
		}


	/* direction NE */
	flipped = move.flipped & 0X0020400000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020400000000000ULL:
				p->flip_BLACK_C2();
			default :
				p->flip_BLACK_B3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000040201000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000040201000ULL:
				p->flip_BLACK_D7();
			case 0X0000000040200000ULL:
				p->flip_BLACK_C6();
			default :
				p->flip_BLACK_B5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080800000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080800000000000ULL:
				p->flip_BLACK_A2();
			default :
				p->flip_BLACK_A3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000080808000ULL:
				p->flip_BLACK_A7();
			case 0X0000000080800000ULL:
				p->flip_BLACK_A6();
			default :
				p->flip_BLACK_A5();
		}


}

void RXBBPatterns::update_patterns_BLACK_B4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_B4();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X0000003E00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000003E00000000ULL:
				p->flip_BLACK_G4();
			case 0X0000003C00000000ULL:
				p->flip_BLACK_F4();
			case 0X0000003800000000ULL:
				p->flip_BLACK_E4();
			case 0X0000003000000000ULL:
				p->flip_BLACK_D4();
			default :
				p->flip_BLACK_C4();
		}


	/* direction NE */
	flipped = move.flipped & 0X0010200000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010200000000000ULL:
				p->flip_BLACK_D2();
			default :
				p->flip_BLACK_C3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000020100800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000020100800ULL:
				p->flip_BLACK_E7();
			case 0X0000000020100000ULL:
				p->flip_BLACK_D6();
			default :
				p->flip_BLACK_C5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040400000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040400000000000ULL:
				p->flip_BLACK_B2();
			default :
				p->flip_BLACK_B3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000040404000ULL:
				p->flip_BLACK_B7();
			case 0X0000000040400000ULL:
				p->flip_BLACK_B6();
			default :
				p->flip_BLACK_B5();
		}


}

void RXBBPatterns::update_patterns_BLACK_C4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_C4();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000010080400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000010080400ULL:
				p->flip_BLACK_F7();
			case 0X0000000010080000ULL:
				p->flip_BLACK_E6();
			default :
				p->flip_BLACK_D5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000020202000ULL:
				p->flip_BLACK_C7();
			case 0X0000000020200000ULL:
				p->flip_BLACK_C6();
			default :
				p->flip_BLACK_C5();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000001E00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000001E00000000ULL:
				p->flip_BLACK_G4();
			case 0X0000001C00000000ULL:
				p->flip_BLACK_F4();
			case 0X0000001800000000ULL:
				p->flip_BLACK_E4();
			default :
				p->flip_BLACK_D4();
		}


	/* direction NE */
	flipped = move.flipped & 0X0008100000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008100000000000ULL:
				p->flip_BLACK_E2();
			default :
				p->flip_BLACK_D3();
		}


	/* direction _N */
	flipped = move.flipped & 0X0020200000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020200000000000ULL:
				p->flip_BLACK_C2();
			default :
				p->flip_BLACK_C3();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000400000000000ULL;
	if(flipped)
		p->flip_BLACK_B3();

	/* direction _SW */
	flipped = move.flipped & 0X0000000040000000ULL;
	if(flipped)
		p->flip_BLACK_B5();

	/* direction _W */
	flipped = move.flipped & 0X0000004000000000ULL;
	if(flipped)
		p->flip_BLACK_B4();

}

void RXBBPatterns::update_patterns_BLACK_F4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_F4();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000002000000ULL;
	if(flipped)
		p->flip_BLACK_G5();

	/* direction S_ */
	flipped = move.flipped & 0X0000000004040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000004040400ULL:
				p->flip_BLACK_F7();
			case 0X0000000004040000ULL:
				p->flip_BLACK_F6();
			default :
				p->flip_BLACK_F5();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000200000000ULL;
	if(flipped)
		p->flip_BLACK_G4();

	/* direction NE */
	flipped = move.flipped & 0X0000020000000000ULL;
	if(flipped)
		p->flip_BLACK_G3();

	/* direction _N */
	flipped = move.flipped & 0X0004040000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040000000000ULL:
				p->flip_BLACK_F2();
			default :
				p->flip_BLACK_F3();
		}


	/* direction NW */
	flipped = move.flipped & 0X0010080000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010080000000000ULL:
				p->flip_BLACK_D2();
			default :
				p->flip_BLACK_E3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000008102000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000008102000ULL:
				p->flip_BLACK_C7();
			case 0X0000000008100000ULL:
				p->flip_BLACK_D6();
			default :
				p->flip_BLACK_E5();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000007800000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000007800000000ULL:
				p->flip_BLACK_B4();
			case 0X0000003800000000ULL:
				p->flip_BLACK_C4();
			case 0X0000001800000000ULL:
				p->flip_BLACK_D4();
			default :
				p->flip_BLACK_E4();
		}


}

void RXBBPatterns::update_patterns_BLACK_G4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_G4();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X0000007C00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000007C00000000ULL:
				p->flip_BLACK_B4();
			case 0X0000003C00000000ULL:
				p->flip_BLACK_C4();
			case 0X0000001C00000000ULL:
				p->flip_BLACK_D4();
			case 0X0000000C00000000ULL:
				p->flip_BLACK_E4();
			default :
				p->flip_BLACK_F4();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000004081000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000004081000ULL:
				p->flip_BLACK_D7();
			case 0X0000000004080000ULL:
				p->flip_BLACK_E6();
			default :
				p->flip_BLACK_F5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0008040000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008040000000000ULL:
				p->flip_BLACK_E2();
			default :
				p->flip_BLACK_F3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000002020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000002020200ULL:
				p->flip_BLACK_G7();
			case 0X0000000002020000ULL:
				p->flip_BLACK_G6();
			default :
				p->flip_BLACK_G5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002020000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020000000000ULL:
				p->flip_BLACK_G2();
			default :
				p->flip_BLACK_G3();
		}


}

void RXBBPatterns::update_patterns_BLACK_H4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_H4();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X0000007E00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000007E00000000ULL:
				p->flip_BLACK_B4();
			case 0X0000003E00000000ULL:
				p->flip_BLACK_C4();
			case 0X0000001E00000000ULL:
				p->flip_BLACK_D4();
			case 0X0000000E00000000ULL:
				p->flip_BLACK_E4();
			case 0X0000000600000000ULL:
				p->flip_BLACK_F4();
			default :
				p->flip_BLACK_G4();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000002040800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000002040800ULL:
				p->flip_BLACK_E7();
			case 0X0000000002040000ULL:
				p->flip_BLACK_F6();
			default :
				p->flip_BLACK_G5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0004020000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004020000000000ULL:
				p->flip_BLACK_F2();
			default :
				p->flip_BLACK_G3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000001010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000001010100ULL:
				p->flip_BLACK_H7();
			case 0X0000000001010000ULL:
				p->flip_BLACK_H6();
			default :
				p->flip_BLACK_H5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001010000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010000000000ULL:
				p->flip_BLACK_H2();
			default :
				p->flip_BLACK_H3();
		}


}

void RXBBPatterns::update_patterns_BLACK_A5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_A5();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X000000007E000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000007E000000ULL:
				p->flip_BLACK_G5();
			case 0X000000007C000000ULL:
				p->flip_BLACK_F5();
			case 0X0000000078000000ULL:
				p->flip_BLACK_E5();
			case 0X0000000070000000ULL:
				p->flip_BLACK_D5();
			case 0X0000000060000000ULL:
				p->flip_BLACK_C5();
			default :
				p->flip_BLACK_B5();
		}


	/* direction NE */
	flipped = move.flipped & 0X0010204000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010204000000000ULL:
				p->flip_BLACK_D2();
			case 0X0000204000000000ULL:
				p->flip_BLACK_C3();
			default :
				p->flip_BLACK_B4();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000000402000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000402000ULL:
				p->flip_BLACK_C7();
			default :
				p->flip_BLACK_B6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080808000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808000000000ULL:
				p->flip_BLACK_A2();
			case 0X0000808000000000ULL:
				p->flip_BLACK_A3();
			default :
				p->flip_BLACK_A4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000808000ULL:
				p->flip_BLACK_A7();
			default :
				p->flip_BLACK_A6();
		}


}

void RXBBPatterns::update_patterns_BLACK_B5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_B5();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X000000003E000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000003E000000ULL:
				p->flip_BLACK_G5();
			case 0X000000003C000000ULL:
				p->flip_BLACK_F5();
			case 0X0000000038000000ULL:
				p->flip_BLACK_E5();
			case 0X0000000030000000ULL:
				p->flip_BLACK_D5();
			default :
				p->flip_BLACK_C5();
		}


	/* direction NE */
	flipped = move.flipped & 0X0008102000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008102000000000ULL:
				p->flip_BLACK_E2();
			case 0X0000102000000000ULL:
				p->flip_BLACK_D3();
			default :
				p->flip_BLACK_C4();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000000201000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000201000ULL:
				p->flip_BLACK_D7();
			default :
				p->flip_BLACK_C6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040404000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404000000000ULL:
				p->flip_BLACK_B2();
			case 0X0000404000000000ULL:
				p->flip_BLACK_B3();
			default :
				p->flip_BLACK_B4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000404000ULL:
				p->flip_BLACK_B7();
			default :
				p->flip_BLACK_B6();
		}


}

void RXBBPatterns::update_patterns_BLACK_C5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_C5();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000100800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000100800ULL:
				p->flip_BLACK_E7();
			default :
				p->flip_BLACK_D6();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000202000ULL:
				p->flip_BLACK_C7();
			default :
				p->flip_BLACK_C6();
		}


	/* direction _E */
	flipped = move.flipped & 0X000000001E000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000001E000000ULL:
				p->flip_BLACK_G5();
			case 0X000000001C000000ULL:
				p->flip_BLACK_F5();
			case 0X0000000018000000ULL:
				p->flip_BLACK_E5();
			default :
				p->flip_BLACK_D5();
		}


	/* direction NE */
	flipped = move.flipped & 0X0004081000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004081000000000ULL:
				p->flip_BLACK_F2();
			case 0X0000081000000000ULL:
				p->flip_BLACK_E3();
			default :
				p->flip_BLACK_D4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0020202000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202000000000ULL:
				p->flip_BLACK_C2();
			case 0X0000202000000000ULL:
				p->flip_BLACK_C3();
			default :
				p->flip_BLACK_C4();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000004000000000ULL;
	if(flipped)
		p->flip_BLACK_B4();

	/* direction _SW */
	flipped = move.flipped & 0X0000000000400000ULL;
	if(flipped)
		p->flip_BLACK_B6();

	/* direction _W */
	flipped = move.flipped & 0X0000000040000000ULL;
	if(flipped)
		p->flip_BLACK_B5();

}

void RXBBPatterns::update_patterns_BLACK_F5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_F5();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000020000ULL;
	if(flipped)
		p->flip_BLACK_G6();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000040400ULL:
				p->flip_BLACK_F7();
			default :
				p->flip_BLACK_F6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000002000000ULL;
	if(flipped)
		p->flip_BLACK_G5();

	/* direction NE */
	flipped = move.flipped & 0X0000000200000000ULL;
	if(flipped)
		p->flip_BLACK_G4();

	/* direction _N */
	flipped = move.flipped & 0X0004040400000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040400000000ULL:
				p->flip_BLACK_F2();
			case 0X0000040400000000ULL:
				p->flip_BLACK_F3();
			default :
				p->flip_BLACK_F4();
		}


	/* direction NW */
	flipped = move.flipped & 0X0020100800000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020100800000000ULL:
				p->flip_BLACK_C2();
			case 0X0000100800000000ULL:
				p->flip_BLACK_D3();
			default :
				p->flip_BLACK_E4();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000081000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000081000ULL:
				p->flip_BLACK_D7();
			default :
				p->flip_BLACK_E6();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000078000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000078000000ULL:
				p->flip_BLACK_B5();
			case 0X0000000038000000ULL:
				p->flip_BLACK_C5();
			case 0X0000000018000000ULL:
				p->flip_BLACK_D5();
			default :
				p->flip_BLACK_E5();
		}


}

void RXBBPatterns::update_patterns_BLACK_G5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_G5();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X000000007C000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000007C000000ULL:
				p->flip_BLACK_B5();
			case 0X000000003C000000ULL:
				p->flip_BLACK_C5();
			case 0X000000001C000000ULL:
				p->flip_BLACK_D5();
			case 0X000000000C000000ULL:
				p->flip_BLACK_E5();
			default :
				p->flip_BLACK_F5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000040800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000040800ULL:
				p->flip_BLACK_E7();
			default :
				p->flip_BLACK_F6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0010080400000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010080400000000ULL:
				p->flip_BLACK_D2();
			case 0X0000080400000000ULL:
				p->flip_BLACK_E3();
			default :
				p->flip_BLACK_F4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000020200ULL:
				p->flip_BLACK_G7();
			default :
				p->flip_BLACK_G6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002020200000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020200000000ULL:
				p->flip_BLACK_G2();
			case 0X0000020200000000ULL:
				p->flip_BLACK_G3();
			default :
				p->flip_BLACK_G4();
		}


}

void RXBBPatterns::update_patterns_BLACK_H5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_H5();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X000000007E000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000007E000000ULL:
				p->flip_BLACK_B5();
			case 0X000000003E000000ULL:
				p->flip_BLACK_C5();
			case 0X000000001E000000ULL:
				p->flip_BLACK_D5();
			case 0X000000000E000000ULL:
				p->flip_BLACK_E5();
			case 0X0000000006000000ULL:
				p->flip_BLACK_F5();
			default :
				p->flip_BLACK_G5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000020400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000020400ULL:
				p->flip_BLACK_F7();
			default :
				p->flip_BLACK_G6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0008040200000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008040200000000ULL:
				p->flip_BLACK_E2();
			case 0X0000040200000000ULL:
				p->flip_BLACK_F3();
			default :
				p->flip_BLACK_G4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000010100ULL:
				p->flip_BLACK_H7();
			default :
				p->flip_BLACK_H6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001010100000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010100000000ULL:
				p->flip_BLACK_H2();
			case 0X0000010100000000ULL:
				p->flip_BLACK_H3();
			default :
				p->flip_BLACK_H4();
		}


}

void RXBBPatterns::update_patterns_BLACK_A6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_A6();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X00000000007E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000007E0000ULL:
				p->flip_BLACK_G6();
			case 0X00000000007C0000ULL:
				p->flip_BLACK_F6();
			case 0X0000000000780000ULL:
				p->flip_BLACK_E6();
			case 0X0000000000700000ULL:
				p->flip_BLACK_D6();
			case 0X0000000000600000ULL:
				p->flip_BLACK_C6();
			default :
				p->flip_BLACK_B6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0008102040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008102040000000ULL:
				p->flip_BLACK_E2();
			case 0X0000102040000000ULL:
				p->flip_BLACK_D3();
			case 0X0000002040000000ULL:
				p->flip_BLACK_C4();
			default :
				p->flip_BLACK_B5();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_BLACK_B7();

	/* direction _N */
	flipped = move.flipped & 0X0080808080000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808080000000ULL:
				p->flip_BLACK_A2();
			case 0X0000808080000000ULL:
				p->flip_BLACK_A3();
			case 0X0000008080000000ULL:
				p->flip_BLACK_A4();
			default :
				p->flip_BLACK_A5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000008000ULL;
	if(flipped)
		p->flip_BLACK_A7();

}

void RXBBPatterns::update_patterns_BLACK_B6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_B6();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X00000000003E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000003E0000ULL:
				p->flip_BLACK_G6();
			case 0X00000000003C0000ULL:
				p->flip_BLACK_F6();
			case 0X0000000000380000ULL:
				p->flip_BLACK_E6();
			case 0X0000000000300000ULL:
				p->flip_BLACK_D6();
			default :
				p->flip_BLACK_C6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0004081020000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004081020000000ULL:
				p->flip_BLACK_F2();
			case 0X0000081020000000ULL:
				p->flip_BLACK_E3();
			case 0X0000001020000000ULL:
				p->flip_BLACK_D4();
			default :
				p->flip_BLACK_C5();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000000002000ULL;
	if(flipped)
		p->flip_BLACK_C7();

	/* direction _N */
	flipped = move.flipped & 0X0040404040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404040000000ULL:
				p->flip_BLACK_B2();
			case 0X0000404040000000ULL:
				p->flip_BLACK_B3();
			case 0X0000004040000000ULL:
				p->flip_BLACK_B4();
			default :
				p->flip_BLACK_B5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_BLACK_B7();

}

void RXBBPatterns::update_patterns_BLACK_C6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_C6();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000001000ULL;
	if(flipped)
		p->flip_BLACK_D7();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000002000ULL;
	if(flipped)
		p->flip_BLACK_C7();

	/* direction _E */
	flipped = move.flipped & 0X00000000001E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000001E0000ULL:
				p->flip_BLACK_G6();
			case 0X00000000001C0000ULL:
				p->flip_BLACK_F6();
			case 0X0000000000180000ULL:
				p->flip_BLACK_E6();
			default :
				p->flip_BLACK_D6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0002040810000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002040810000000ULL:
				p->flip_BLACK_G2();
			case 0X0000040810000000ULL:
				p->flip_BLACK_F3();
			case 0X0000000810000000ULL:
				p->flip_BLACK_E4();
			default :
				p->flip_BLACK_D5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0020202020000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202020000000ULL:
				p->flip_BLACK_C2();
			case 0X0000202020000000ULL:
				p->flip_BLACK_C3();
			case 0X0000002020000000ULL:
				p->flip_BLACK_C4();
			default :
				p->flip_BLACK_C5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000040000000ULL;
	if(flipped)
		p->flip_BLACK_B5();

	/* direction _SW */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_BLACK_B7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000400000ULL;
	if(flipped)
		p->flip_BLACK_B6();

}

void RXBBPatterns::update_patterns_BLACK_D6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_D6();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000000800ULL;
	if(flipped)
		p->flip_BLACK_E7();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000001000ULL;
	if(flipped)
		p->flip_BLACK_D7();

	/* direction _E */
	flipped = move.flipped & 0X00000000000E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000000E0000ULL:
				p->flip_BLACK_G6();
			case 0X00000000000C0000ULL:
				p->flip_BLACK_F6();
			default :
				p->flip_BLACK_E6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000020408000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020408000000ULL:
				p->flip_BLACK_G3();
			case 0X0000000408000000ULL:
				p->flip_BLACK_F4();
			default :
				p->flip_BLACK_E5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0010101010000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010101010000000ULL:
				p->flip_BLACK_D2();
			case 0X0000101010000000ULL:
				p->flip_BLACK_D3();
			case 0X0000001010000000ULL:
				p->flip_BLACK_D4();
			default :
				p->flip_BLACK_D5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000004020000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004020000000ULL:
				p->flip_BLACK_B4();
			default :
				p->flip_BLACK_C5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000002000ULL;
	if(flipped)
		p->flip_BLACK_C7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000600000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000600000ULL:
				p->flip_BLACK_B6();
			default :
				p->flip_BLACK_C6();
		}


}

void RXBBPatterns::update_patterns_BLACK_E6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_E6();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000000400ULL;
	if(flipped)
		p->flip_BLACK_F7();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000000800ULL;
	if(flipped)
		p->flip_BLACK_E7();

	/* direction _E */
	flipped = move.flipped & 0X0000000000060000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000060000ULL:
				p->flip_BLACK_G6();
			default :
				p->flip_BLACK_F6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000204000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000204000000ULL:
				p->flip_BLACK_G4();
			default :
				p->flip_BLACK_F5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0008080808000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008080808000000ULL:
				p->flip_BLACK_E2();
			case 0X0000080808000000ULL:
				p->flip_BLACK_E3();
			case 0X0000000808000000ULL:
				p->flip_BLACK_E4();
			default :
				p->flip_BLACK_E5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000402010000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000402010000000ULL:
				p->flip_BLACK_B3();
			case 0X0000002010000000ULL:
				p->flip_BLACK_C4();
			default :
				p->flip_BLACK_D5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000001000ULL;
	if(flipped)
		p->flip_BLACK_D7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000700000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000700000ULL:
				p->flip_BLACK_B6();
			case 0X0000000000300000ULL:
				p->flip_BLACK_C6();
			default :
				p->flip_BLACK_D6();
		}


}

void RXBBPatterns::update_patterns_BLACK_F6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_F6();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_BLACK_G7();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000000400ULL;
	if(flipped)
		p->flip_BLACK_F7();

	/* direction _E */
	flipped = move.flipped & 0X0000000000020000ULL;
	if(flipped)
		p->flip_BLACK_G6();

	/* direction NE */
	flipped = move.flipped & 0X0000000002000000ULL;
	if(flipped)
		p->flip_BLACK_G5();

	/* direction _N */
	flipped = move.flipped & 0X0004040404000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040404000000ULL:
				p->flip_BLACK_F2();
			case 0X0000040404000000ULL:
				p->flip_BLACK_F3();
			case 0X0000000404000000ULL:
				p->flip_BLACK_F4();
			default :
				p->flip_BLACK_F5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0040201008000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040201008000000ULL:
				p->flip_BLACK_B2();
			case 0X0000201008000000ULL:
				p->flip_BLACK_C3();
			case 0X0000001008000000ULL:
				p->flip_BLACK_D4();
			default :
				p->flip_BLACK_E5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000000800ULL;
	if(flipped)
		p->flip_BLACK_E7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000780000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000780000ULL:
				p->flip_BLACK_B6();
			case 0X0000000000380000ULL:
				p->flip_BLACK_C6();
			case 0X0000000000180000ULL:
				p->flip_BLACK_D6();
			default :
				p->flip_BLACK_E6();
		}


}

void RXBBPatterns::update_patterns_BLACK_G6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_G6();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X00000000007C0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000007C0000ULL:
				p->flip_BLACK_B6();
			case 0X00000000003C0000ULL:
				p->flip_BLACK_C6();
			case 0X00000000001C0000ULL:
				p->flip_BLACK_D6();
			case 0X00000000000C0000ULL:
				p->flip_BLACK_E6();
			default :
				p->flip_BLACK_F6();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000000400ULL;
	if(flipped)
		p->flip_BLACK_F7();

	/* direction NW */
	flipped = move.flipped & 0X0020100804000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020100804000000ULL:
				p->flip_BLACK_C2();
			case 0X0000100804000000ULL:
				p->flip_BLACK_D3();
			case 0X0000000804000000ULL:
				p->flip_BLACK_E4();
			default :
				p->flip_BLACK_F5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_BLACK_G7();

	/* direction _N */
	flipped = move.flipped & 0X0002020202000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020202000000ULL:
				p->flip_BLACK_G2();
			case 0X0000020202000000ULL:
				p->flip_BLACK_G3();
			case 0X0000000202000000ULL:
				p->flip_BLACK_G4();
			default :
				p->flip_BLACK_G5();
		}


}

void RXBBPatterns::update_patterns_BLACK_H6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_H6();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X00000000007E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000007E0000ULL:
				p->flip_BLACK_B6();
			case 0X00000000003E0000ULL:
				p->flip_BLACK_C6();
			case 0X00000000001E0000ULL:
				p->flip_BLACK_D6();
			case 0X00000000000E0000ULL:
				p->flip_BLACK_E6();
			case 0X0000000000060000ULL:
				p->flip_BLACK_F6();
			default :
				p->flip_BLACK_G6();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_BLACK_G7();

	/* direction NW */
	flipped = move.flipped & 0X0010080402000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010080402000000ULL:
				p->flip_BLACK_D2();
			case 0X0000080402000000ULL:
				p->flip_BLACK_E3();
			case 0X0000000402000000ULL:
				p->flip_BLACK_F4();
			default :
				p->flip_BLACK_G5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000000100ULL;
	if(flipped)
		p->flip_BLACK_H7();

	/* direction _N */
	flipped = move.flipped & 0X0001010101000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010101000000ULL:
				p->flip_BLACK_H2();
			case 0X0000010101000000ULL:
				p->flip_BLACK_H3();
			case 0X0000000101000000ULL:
				p->flip_BLACK_H4();
			default :
				p->flip_BLACK_H5();
		}


}

void RXBBPatterns::update_patterns_BLACK_A7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_A7();

	/* direction NE */
	unsigned long long flipped = move.flipped & 0X0004081020400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004081020400000ULL:
				p->flip_BLACK_F2();
			case 0X0000081020400000ULL:
				p->flip_BLACK_E3();
			case 0X0000001020400000ULL:
				p->flip_BLACK_D4();
			case 0X0000000020400000ULL:
				p->flip_BLACK_C5();
			default :
				p->flip_BLACK_B6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080808080800000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808080800000ULL:
				p->flip_BLACK_A2();
			case 0X0000808080800000ULL:
				p->flip_BLACK_A3();
			case 0X0000008080800000ULL:
				p->flip_BLACK_A4();
			case 0X0000000080800000ULL:
				p->flip_BLACK_A5();
			default :
				p->flip_BLACK_A6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000007E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007E00ULL:
				p->flip_BLACK_G7();
			case 0X0000000000007C00ULL:
				p->flip_BLACK_F7();
			case 0X0000000000007800ULL:
				p->flip_BLACK_E7();
			case 0X0000000000007000ULL:
				p->flip_BLACK_D7();
			case 0X0000000000006000ULL:
				p->flip_BLACK_C7();
			default :
				p->flip_BLACK_B7();
		}


}

void RXBBPatterns::update_patterns_BLACK_B7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_B7();

	/* direction NE */
	unsigned long long flipped = move.flipped & 0X0002040810200000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002040810200000ULL:
				p->flip_BLACK_G2();
			case 0X0000040810200000ULL:
				p->flip_BLACK_F3();
			case 0X0000000810200000ULL:
				p->flip_BLACK_E4();
			case 0X0000000010200000ULL:
				p->flip_BLACK_D5();
			default :
				p->flip_BLACK_C6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040404040400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404040400000ULL:
				p->flip_BLACK_B2();
			case 0X0000404040400000ULL:
				p->flip_BLACK_B3();
			case 0X0000004040400000ULL:
				p->flip_BLACK_B4();
			case 0X0000000040400000ULL:
				p->flip_BLACK_B5();
			default :
				p->flip_BLACK_B6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000003E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000003E00ULL:
				p->flip_BLACK_G7();
			case 0X0000000000003C00ULL:
				p->flip_BLACK_F7();
			case 0X0000000000003800ULL:
				p->flip_BLACK_E7();
			case 0X0000000000003000ULL:
				p->flip_BLACK_D7();
			default :
				p->flip_BLACK_C7();
		}


}

void RXBBPatterns::update_patterns_BLACK_C7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_C7();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0020202020200000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202020200000ULL:
				p->flip_BLACK_C2();
			case 0X0000202020200000ULL:
				p->flip_BLACK_C3();
			case 0X0000002020200000ULL:
				p->flip_BLACK_C4();
			case 0X0000000020200000ULL:
				p->flip_BLACK_C5();
			default :
				p->flip_BLACK_C6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000020408100000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020408100000ULL:
				p->flip_BLACK_G3();
			case 0X0000000408100000ULL:
				p->flip_BLACK_F4();
			case 0X0000000008100000ULL:
				p->flip_BLACK_E5();
			default :
				p->flip_BLACK_D6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000000400000ULL;
	if(flipped)
		p->flip_BLACK_B6();

	/* direction _E */
	flipped = move.flipped & 0X0000000000001E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000001E00ULL:
				p->flip_BLACK_G7();
			case 0X0000000000001C00ULL:
				p->flip_BLACK_F7();
			case 0X0000000000001800ULL:
				p->flip_BLACK_E7();
			default :
				p->flip_BLACK_D7();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_BLACK_B7();

}

void RXBBPatterns::update_patterns_BLACK_D7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_D7();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0010101010100000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010101010100000ULL:
				p->flip_BLACK_D2();
			case 0X0000101010100000ULL:
				p->flip_BLACK_D3();
			case 0X0000001010100000ULL:
				p->flip_BLACK_D4();
			case 0X0000000010100000ULL:
				p->flip_BLACK_D5();
			default :
				p->flip_BLACK_D6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000204080000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000204080000ULL:
				p->flip_BLACK_G4();
			case 0X0000000004080000ULL:
				p->flip_BLACK_F5();
			default :
				p->flip_BLACK_E6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000040200000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000040200000ULL:
				p->flip_BLACK_B5();
			default :
				p->flip_BLACK_C6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000E00ULL:
				p->flip_BLACK_G7();
			case 0X0000000000000C00ULL:
				p->flip_BLACK_F7();
			default :
				p->flip_BLACK_E7();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000006000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000006000ULL:
				p->flip_BLACK_B7();
			default :
				p->flip_BLACK_C7();
		}


}

void RXBBPatterns::update_patterns_BLACK_E7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_E7();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0008080808080000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008080808080000ULL:
				p->flip_BLACK_E2();
			case 0X0000080808080000ULL:
				p->flip_BLACK_E3();
			case 0X0000000808080000ULL:
				p->flip_BLACK_E4();
			case 0X0000000008080000ULL:
				p->flip_BLACK_E5();
			default :
				p->flip_BLACK_E6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000002040000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000002040000ULL:
				p->flip_BLACK_G5();
			default :
				p->flip_BLACK_F6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000004020100000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004020100000ULL:
				p->flip_BLACK_B4();
			case 0X0000000020100000ULL:
				p->flip_BLACK_C5();
			default :
				p->flip_BLACK_D6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000600ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000600ULL:
				p->flip_BLACK_G7();
			default :
				p->flip_BLACK_F7();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000007000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007000ULL:
				p->flip_BLACK_B7();
			case 0X0000000000003000ULL:
				p->flip_BLACK_C7();
			default :
				p->flip_BLACK_D7();
		}


}

void RXBBPatterns::update_patterns_BLACK_F7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_F7();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0004040404040000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040404040000ULL:
				p->flip_BLACK_F2();
			case 0X0000040404040000ULL:
				p->flip_BLACK_F3();
			case 0X0000000404040000ULL:
				p->flip_BLACK_F4();
			case 0X0000000004040000ULL:
				p->flip_BLACK_F5();
			default :
				p->flip_BLACK_F6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000000020000ULL;
	if(flipped)
		p->flip_BLACK_G6();

	/* direction NW */
	flipped = move.flipped & 0X0000402010080000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000402010080000ULL:
				p->flip_BLACK_B3();
			case 0X0000002010080000ULL:
				p->flip_BLACK_C4();
			case 0X0000000010080000ULL:
				p->flip_BLACK_D5();
			default :
				p->flip_BLACK_E6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_BLACK_G7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000007800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007800ULL:
				p->flip_BLACK_B7();
			case 0X0000000000003800ULL:
				p->flip_BLACK_C7();
			case 0X0000000000001800ULL:
				p->flip_BLACK_D7();
			default :
				p->flip_BLACK_E7();
		}


}

void RXBBPatterns::update_patterns_BLACK_G7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_G7();

	/* direction NW */
	unsigned long long flipped = move.flipped & 0X0040201008040000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040201008040000ULL:
				p->flip_BLACK_B2();
			case 0X0000201008040000ULL:
				p->flip_BLACK_C3();
			case 0X0000001008040000ULL:
				p->flip_BLACK_D4();
			case 0X0000000008040000ULL:
				p->flip_BLACK_E5();
			default :
				p->flip_BLACK_F6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002020202020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020202020000ULL:
				p->flip_BLACK_G2();
			case 0X0000020202020000ULL:
				p->flip_BLACK_G3();
			case 0X0000000202020000ULL:
				p->flip_BLACK_G4();
			case 0X0000000002020000ULL:
				p->flip_BLACK_G5();
			default :
				p->flip_BLACK_G6();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000007C00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007C00ULL:
				p->flip_BLACK_B7();
			case 0X0000000000003C00ULL:
				p->flip_BLACK_C7();
			case 0X0000000000001C00ULL:
				p->flip_BLACK_D7();
			case 0X0000000000000C00ULL:
				p->flip_BLACK_E7();
			default :
				p->flip_BLACK_F7();
		}


}

void RXBBPatterns::update_patterns_BLACK_H7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_H7();

	/* direction NW */
	unsigned long long flipped = move.flipped & 0X0020100804020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020100804020000ULL:
				p->flip_BLACK_C2();
			case 0X0000100804020000ULL:
				p->flip_BLACK_D3();
			case 0X0000000804020000ULL:
				p->flip_BLACK_E4();
			case 0X0000000004020000ULL:
				p->flip_BLACK_F5();
			default :
				p->flip_BLACK_G6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001010101010000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010101010000ULL:
				p->flip_BLACK_H2();
			case 0X0000010101010000ULL:
				p->flip_BLACK_H3();
			case 0X0000000101010000ULL:
				p->flip_BLACK_H4();
			case 0X0000000001010000ULL:
				p->flip_BLACK_H5();
			default :
				p->flip_BLACK_H6();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000007E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007E00ULL:
				p->flip_BLACK_B7();
			case 0X0000000000003E00ULL:
				p->flip_BLACK_C7();
			case 0X0000000000001E00ULL:
				p->flip_BLACK_D7();
			case 0X0000000000000E00ULL:
				p->flip_BLACK_E7();
			case 0X0000000000000600ULL:
				p->flip_BLACK_F7();
			default :
				p->flip_BLACK_G7();
		}


}

void RXBBPatterns::update_patterns_BLACK_A8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_A8();

	/* direction NE */
	unsigned long long flipped = move.flipped & 0X0002040810204000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002040810204000ULL:
				p->flip_BLACK_G2();
			case 0X0000040810204000ULL:
				p->flip_BLACK_F3();
			case 0X0000000810204000ULL:
				p->flip_BLACK_E4();
			case 0X0000000010204000ULL:
				p->flip_BLACK_D5();
			case 0X0000000000204000ULL:
				p->flip_BLACK_C6();
			default :
				p->flip_BLACK_B7();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080808080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808080808000ULL:
				p->flip_BLACK_A2();
			case 0X0000808080808000ULL:
				p->flip_BLACK_A3();
			case 0X0000008080808000ULL:
				p->flip_BLACK_A4();
			case 0X0000000080808000ULL:
				p->flip_BLACK_A5();
			case 0X0000000000808000ULL:
				p->flip_BLACK_A6();
			default :
				p->flip_BLACK_A7();
		}


	/* direction _E */
	flipped = move.flipped & 0X000000000000007EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000007EULL:
				p->flip_BLACK_G8();
			case 0X000000000000007CULL:
				p->flip_BLACK_F8();
			case 0X0000000000000078ULL:
				p->flip_BLACK_E8();
			case 0X0000000000000070ULL:
				p->flip_BLACK_D8();
			case 0X0000000000000060ULL:
				p->flip_BLACK_C8();
			default :
				p->flip_BLACK_B8();
		}


}

void RXBBPatterns::update_patterns_BLACK_B8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_B8();

	/* direction NE */
	unsigned long long flipped = move.flipped & 0X0000020408102000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020408102000ULL:
				p->flip_BLACK_G3();
			case 0X0000000408102000ULL:
				p->flip_BLACK_F4();
			case 0X0000000008102000ULL:
				p->flip_BLACK_E5();
			case 0X0000000000102000ULL:
				p->flip_BLACK_D6();
			default :
				p->flip_BLACK_C7();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040404040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404040404000ULL:
				p->flip_BLACK_B2();
			case 0X0000404040404000ULL:
				p->flip_BLACK_B3();
			case 0X0000004040404000ULL:
				p->flip_BLACK_B4();
			case 0X0000000040404000ULL:
				p->flip_BLACK_B5();
			case 0X0000000000404000ULL:
				p->flip_BLACK_B6();
			default :
				p->flip_BLACK_B7();
		}


	/* direction _E */
	flipped = move.flipped & 0X000000000000003EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000003EULL:
				p->flip_BLACK_G8();
			case 0X000000000000003CULL:
				p->flip_BLACK_F8();
			case 0X0000000000000038ULL:
				p->flip_BLACK_E8();
			case 0X0000000000000030ULL:
				p->flip_BLACK_D8();
			default :
				p->flip_BLACK_C8();
		}


}

void RXBBPatterns::update_patterns_BLACK_C8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_C8();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0020202020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202020202000ULL:
				p->flip_BLACK_C2();
			case 0X0000202020202000ULL:
				p->flip_BLACK_C3();
			case 0X0000002020202000ULL:
				p->flip_BLACK_C4();
			case 0X0000000020202000ULL:
				p->flip_BLACK_C5();
			case 0X0000000000202000ULL:
				p->flip_BLACK_C6();
			default :
				p->flip_BLACK_C7();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000204081000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000204081000ULL:
				p->flip_BLACK_G4();
			case 0X0000000004081000ULL:
				p->flip_BLACK_F5();
			case 0X0000000000081000ULL:
				p->flip_BLACK_E6();
			default :
				p->flip_BLACK_D7();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_BLACK_B7();

	/* direction _E */
	flipped = move.flipped & 0X000000000000001EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000001EULL:
				p->flip_BLACK_G8();
			case 0X000000000000001CULL:
				p->flip_BLACK_F8();
			case 0X0000000000000018ULL:
				p->flip_BLACK_E8();
			default :
				p->flip_BLACK_D8();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000000040ULL;
	if(flipped)
		p->flip_BLACK_B8();

}

void RXBBPatterns::update_patterns_BLACK_D8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_D8();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0010101010101000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010101010101000ULL:
				p->flip_BLACK_D2();
			case 0X0000101010101000ULL:
				p->flip_BLACK_D3();
			case 0X0000001010101000ULL:
				p->flip_BLACK_D4();
			case 0X0000000010101000ULL:
				p->flip_BLACK_D5();
			case 0X0000000000101000ULL:
				p->flip_BLACK_D6();
			default :
				p->flip_BLACK_D7();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000002040800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000002040800ULL:
				p->flip_BLACK_G5();
			case 0X0000000000040800ULL:
				p->flip_BLACK_F6();
			default :
				p->flip_BLACK_E7();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000000402000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000402000ULL:
				p->flip_BLACK_B6();
			default :
				p->flip_BLACK_C7();
		}


	/* direction _E */
	flipped = move.flipped & 0X000000000000000EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000000EULL:
				p->flip_BLACK_G8();
			case 0X000000000000000CULL:
				p->flip_BLACK_F8();
			default :
				p->flip_BLACK_E8();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000000060ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000060ULL:
				p->flip_BLACK_B8();
			default :
				p->flip_BLACK_C8();
		}


}

void RXBBPatterns::update_patterns_BLACK_E8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_E8();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0008080808080800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008080808080800ULL:
				p->flip_BLACK_E2();
			case 0X0000080808080800ULL:
				p->flip_BLACK_E3();
			case 0X0000000808080800ULL:
				p->flip_BLACK_E4();
			case 0X0000000008080800ULL:
				p->flip_BLACK_E5();
			case 0X0000000000080800ULL:
				p->flip_BLACK_E6();
			default :
				p->flip_BLACK_E7();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000000020400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000020400ULL:
				p->flip_BLACK_G6();
			default :
				p->flip_BLACK_F7();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000040201000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000040201000ULL:
				p->flip_BLACK_B5();
			case 0X0000000000201000ULL:
				p->flip_BLACK_C6();
			default :
				p->flip_BLACK_D7();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000006ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000006ULL:
				p->flip_BLACK_G8();
			default :
				p->flip_BLACK_F8();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000000070ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000070ULL:
				p->flip_BLACK_B8();
			case 0X0000000000000030ULL:
				p->flip_BLACK_C8();
			default :
				p->flip_BLACK_D8();
		}


}

void RXBBPatterns::update_patterns_BLACK_F8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_F8();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0004040404040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040404040400ULL:
				p->flip_BLACK_F2();
			case 0X0000040404040400ULL:
				p->flip_BLACK_F3();
			case 0X0000000404040400ULL:
				p->flip_BLACK_F4();
			case 0X0000000004040400ULL:
				p->flip_BLACK_F5();
			case 0X0000000000040400ULL:
				p->flip_BLACK_F6();
			default :
				p->flip_BLACK_F7();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_BLACK_G7();

	/* direction NW */
	flipped = move.flipped & 0X0000004020100800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004020100800ULL:
				p->flip_BLACK_B4();
			case 0X0000000020100800ULL:
				p->flip_BLACK_C5();
			case 0X0000000000100800ULL:
				p->flip_BLACK_D6();
			default :
				p->flip_BLACK_E7();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000002ULL;
	if(flipped)
		p->flip_BLACK_G8();

	/* direction _W */
	flipped = move.flipped & 0X0000000000000078ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000078ULL:
				p->flip_BLACK_B8();
			case 0X0000000000000038ULL:
				p->flip_BLACK_C8();
			case 0X0000000000000018ULL:
				p->flip_BLACK_D8();
			default :
				p->flip_BLACK_E8();
		}


}

void RXBBPatterns::update_patterns_BLACK_G8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_G8();

	/* direction NW */
	unsigned long long flipped = move.flipped & 0X0000402010080400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000402010080400ULL:
				p->flip_BLACK_B3();
			case 0X0000002010080400ULL:
				p->flip_BLACK_C4();
			case 0X0000000010080400ULL:
				p->flip_BLACK_D5();
			case 0X0000000000080400ULL:
				p->flip_BLACK_E6();
			default :
				p->flip_BLACK_F7();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002020202020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020202020200ULL:
				p->flip_BLACK_G2();
			case 0X0000020202020200ULL:
				p->flip_BLACK_G3();
			case 0X0000000202020200ULL:
				p->flip_BLACK_G4();
			case 0X0000000002020200ULL:
				p->flip_BLACK_G5();
			case 0X0000000000020200ULL:
				p->flip_BLACK_G6();
			default :
				p->flip_BLACK_G7();
		}


	/* direction _W */
	flipped = move.flipped & 0X000000000000007CULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000007CULL:
				p->flip_BLACK_B8();
			case 0X000000000000003CULL:
				p->flip_BLACK_C8();
			case 0X000000000000001CULL:
				p->flip_BLACK_D8();
			case 0X000000000000000CULL:
				p->flip_BLACK_E8();
			default :
				p->flip_BLACK_F8();
		}


}

void RXBBPatterns::update_patterns_BLACK_H8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_BLACK_H8();

	/* direction NW */
	unsigned long long flipped = move.flipped & 0X0040201008040200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040201008040200ULL:
				p->flip_BLACK_B2();
			case 0X0000201008040200ULL:
				p->flip_BLACK_C3();
			case 0X0000001008040200ULL:
				p->flip_BLACK_D4();
			case 0X0000000008040200ULL:
				p->flip_BLACK_E5();
			case 0X0000000000040200ULL:
				p->flip_BLACK_F6();
			default :
				p->flip_BLACK_G7();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001010101010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010101010100ULL:
				p->flip_BLACK_H2();
			case 0X0000010101010100ULL:
				p->flip_BLACK_H3();
			case 0X0000000101010100ULL:
				p->flip_BLACK_H4();
			case 0X0000000001010100ULL:
				p->flip_BLACK_H5();
			case 0X0000000000010100ULL:
				p->flip_BLACK_H6();
			default :
				p->flip_BLACK_H7();
		}


	/* direction _W */
	flipped = move.flipped & 0X000000000000007EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000007EULL:
				p->flip_BLACK_B8();
			case 0X000000000000003EULL:
				p->flip_BLACK_C8();
			case 0X000000000000001EULL:
				p->flip_BLACK_D8();
			case 0X000000000000000EULL:
				p->flip_BLACK_E8();
			case 0X0000000000000006ULL:
				p->flip_BLACK_F8();
			default :
				p->flip_BLACK_G8();
		}


}



void RXBBPatterns::update_patterns_WHITE_A1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_A1();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0040201008040200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040201008040200ULL:
				p->flip_WHITE_G7();
			case 0X0040201008040000ULL:
				p->flip_WHITE_F6();
			case 0X0040201008000000ULL:
				p->flip_WHITE_E5();
			case 0X0040201000000000ULL:
				p->flip_WHITE_D4();
			case 0X0040200000000000ULL:
				p->flip_WHITE_C3();
			default :
				p->flip_WHITE_B2();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0080808080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808080808000ULL:
				p->flip_WHITE_A7();
			case 0X0080808080800000ULL:
				p->flip_WHITE_A6();
			case 0X0080808080000000ULL:
				p->flip_WHITE_A5();
			case 0X0080808000000000ULL:
				p->flip_WHITE_A4();
			case 0X0080800000000000ULL:
				p->flip_WHITE_A3();
			default :
				p->flip_WHITE_A2();
		}


	/* direction _E */
	flipped = move.flipped & 0X7E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7E00000000000000ULL:
				p->flip_WHITE_G1();
			case 0X7C00000000000000ULL:
				p->flip_WHITE_F1();
			case 0X7800000000000000ULL:
				p->flip_WHITE_E1();
			case 0X7000000000000000ULL:
				p->flip_WHITE_D1();
			case 0X6000000000000000ULL:
				p->flip_WHITE_C1();
			default :
				p->flip_WHITE_B1();
		}


}

void RXBBPatterns::update_patterns_WHITE_B1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_B1();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0020100804020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020100804020000ULL:
				p->flip_WHITE_G6();
			case 0X0020100804000000ULL:
				p->flip_WHITE_F5();
			case 0X0020100800000000ULL:
				p->flip_WHITE_E4();
			case 0X0020100000000000ULL:
				p->flip_WHITE_D3();
			default :
				p->flip_WHITE_C2();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0040404040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404040404000ULL:
				p->flip_WHITE_B7();
			case 0X0040404040400000ULL:
				p->flip_WHITE_B6();
			case 0X0040404040000000ULL:
				p->flip_WHITE_B5();
			case 0X0040404000000000ULL:
				p->flip_WHITE_B4();
			case 0X0040400000000000ULL:
				p->flip_WHITE_B3();
			default :
				p->flip_WHITE_B2();
		}


	/* direction _E */
	flipped = move.flipped & 0X3E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X3E00000000000000ULL:
				p->flip_WHITE_G1();
			case 0X3C00000000000000ULL:
				p->flip_WHITE_F1();
			case 0X3800000000000000ULL:
				p->flip_WHITE_E1();
			case 0X3000000000000000ULL:
				p->flip_WHITE_D1();
			default :
				p->flip_WHITE_C1();
		}


}

void RXBBPatterns::update_patterns_WHITE_C1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_C1();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0020202020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202020202000ULL:
				p->flip_WHITE_C7();
			case 0X0020202020200000ULL:
				p->flip_WHITE_C6();
			case 0X0020202020000000ULL:
				p->flip_WHITE_C5();
			case 0X0020202000000000ULL:
				p->flip_WHITE_C4();
			case 0X0020200000000000ULL:
				p->flip_WHITE_C3();
			default :
				p->flip_WHITE_C2();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0010080402000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010080402000000ULL:
				p->flip_WHITE_G5();
			case 0X0010080400000000ULL:
				p->flip_WHITE_F4();
			case 0X0010080000000000ULL:
				p->flip_WHITE_E3();
			default :
				p->flip_WHITE_D2();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_WHITE_B2();

	/* direction _E */
	flipped = move.flipped & 0X1E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X1E00000000000000ULL:
				p->flip_WHITE_G1();
			case 0X1C00000000000000ULL:
				p->flip_WHITE_F1();
			case 0X1800000000000000ULL:
				p->flip_WHITE_E1();
			default :
				p->flip_WHITE_D1();
		}


	/* direction _W */
	flipped = move.flipped & 0X4000000000000000ULL;
	if(flipped)
		p->flip_WHITE_B1();

}

void RXBBPatterns::update_patterns_WHITE_D1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_D1();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0010101010101000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010101010101000ULL:
				p->flip_WHITE_D7();
			case 0X0010101010100000ULL:
				p->flip_WHITE_D6();
			case 0X0010101010000000ULL:
				p->flip_WHITE_D5();
			case 0X0010101000000000ULL:
				p->flip_WHITE_D4();
			case 0X0010100000000000ULL:
				p->flip_WHITE_D3();
			default :
				p->flip_WHITE_D2();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0008040200000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008040200000000ULL:
				p->flip_WHITE_G4();
			case 0X0008040000000000ULL:
				p->flip_WHITE_F3();
			default :
				p->flip_WHITE_E2();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0020400000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020400000000000ULL:
				p->flip_WHITE_B3();
			default :
				p->flip_WHITE_C2();
		}


	/* direction _E */
	flipped = move.flipped & 0X0E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0E00000000000000ULL:
				p->flip_WHITE_G1();
			case 0X0C00000000000000ULL:
				p->flip_WHITE_F1();
			default :
				p->flip_WHITE_E1();
		}


	/* direction _W */
	flipped = move.flipped & 0X6000000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X6000000000000000ULL:
				p->flip_WHITE_B1();
			default :
				p->flip_WHITE_C1();
		}


}

void RXBBPatterns::update_patterns_WHITE_E1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_E1();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0008080808080800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008080808080800ULL:
				p->flip_WHITE_E7();
			case 0X0008080808080000ULL:
				p->flip_WHITE_E6();
			case 0X0008080808000000ULL:
				p->flip_WHITE_E5();
			case 0X0008080800000000ULL:
				p->flip_WHITE_E4();
			case 0X0008080000000000ULL:
				p->flip_WHITE_E3();
			default :
				p->flip_WHITE_E2();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0004020000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004020000000000ULL:
				p->flip_WHITE_G3();
			default :
				p->flip_WHITE_F2();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0010204000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010204000000000ULL:
				p->flip_WHITE_B4();
			case 0X0010200000000000ULL:
				p->flip_WHITE_C3();
			default :
				p->flip_WHITE_D2();
		}


	/* direction _E */
	flipped = move.flipped & 0X0600000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0600000000000000ULL:
				p->flip_WHITE_G1();
			default :
				p->flip_WHITE_F1();
		}


	/* direction _W */
	flipped = move.flipped & 0X7000000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7000000000000000ULL:
				p->flip_WHITE_B1();
			case 0X3000000000000000ULL:
				p->flip_WHITE_C1();
			default :
				p->flip_WHITE_D1();
		}


}

void RXBBPatterns::update_patterns_WHITE_F1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_F1();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0004040404040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040404040400ULL:
				p->flip_WHITE_F7();
			case 0X0004040404040000ULL:
				p->flip_WHITE_F6();
			case 0X0004040404000000ULL:
				p->flip_WHITE_F5();
			case 0X0004040400000000ULL:
				p->flip_WHITE_F4();
			case 0X0004040000000000ULL:
				p->flip_WHITE_F3();
			default :
				p->flip_WHITE_F2();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_WHITE_G2();

	/* direction _SW */
	flipped = move.flipped & 0X0008102040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008102040000000ULL:
				p->flip_WHITE_B5();
			case 0X0008102000000000ULL:
				p->flip_WHITE_C4();
			case 0X0008100000000000ULL:
				p->flip_WHITE_D3();
			default :
				p->flip_WHITE_E2();
		}


	/* direction _E */
	flipped = move.flipped & 0X0200000000000000ULL;
	if(flipped)
		p->flip_WHITE_G1();

	/* direction _W */
	flipped = move.flipped & 0X7800000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7800000000000000ULL:
				p->flip_WHITE_B1();
			case 0X3800000000000000ULL:
				p->flip_WHITE_C1();
			case 0X1800000000000000ULL:
				p->flip_WHITE_D1();
			default :
				p->flip_WHITE_E1();
		}


}

void RXBBPatterns::update_patterns_WHITE_G1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_G1();

	/* direction _SW */
	unsigned long long flipped = move.flipped & 0X0004081020400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004081020400000ULL:
				p->flip_WHITE_B6();
			case 0X0004081020000000ULL:
				p->flip_WHITE_C5();
			case 0X0004081000000000ULL:
				p->flip_WHITE_D4();
			case 0X0004080000000000ULL:
				p->flip_WHITE_E3();
			default :
				p->flip_WHITE_F2();
		}


	/* direction _W */
	flipped = move.flipped & 0X7C00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7C00000000000000ULL:
				p->flip_WHITE_B1();
			case 0X3C00000000000000ULL:
				p->flip_WHITE_C1();
			case 0X1C00000000000000ULL:
				p->flip_WHITE_D1();
			case 0X0C00000000000000ULL:
				p->flip_WHITE_E1();
			default :
				p->flip_WHITE_F1();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0002020202020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020202020200ULL:
				p->flip_WHITE_G7();
			case 0X0002020202020000ULL:
				p->flip_WHITE_G6();
			case 0X0002020202000000ULL:
				p->flip_WHITE_G5();
			case 0X0002020200000000ULL:
				p->flip_WHITE_G4();
			case 0X0002020000000000ULL:
				p->flip_WHITE_G3();
			default :
				p->flip_WHITE_G2();
		}


}

void RXBBPatterns::update_patterns_WHITE_H1(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_H1();

	/* direction _SW */
	unsigned long long flipped = move.flipped & 0X0002040810204000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002040810204000ULL:
				p->flip_WHITE_B7();
			case 0X0002040810200000ULL:
				p->flip_WHITE_C6();
			case 0X0002040810000000ULL:
				p->flip_WHITE_D5();
			case 0X0002040800000000ULL:
				p->flip_WHITE_E4();
			case 0X0002040000000000ULL:
				p->flip_WHITE_F3();
			default :
				p->flip_WHITE_G2();
		}


	/* direction _W */
	flipped = move.flipped & 0X7E00000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X7E00000000000000ULL:
				p->flip_WHITE_B1();
			case 0X3E00000000000000ULL:
				p->flip_WHITE_C1();
			case 0X1E00000000000000ULL:
				p->flip_WHITE_D1();
			case 0X0E00000000000000ULL:
				p->flip_WHITE_E1();
			case 0X0600000000000000ULL:
				p->flip_WHITE_F1();
			default :
				p->flip_WHITE_G1();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0001010101010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010101010100ULL:
				p->flip_WHITE_H7();
			case 0X0001010101010000ULL:
				p->flip_WHITE_H6();
			case 0X0001010101000000ULL:
				p->flip_WHITE_H5();
			case 0X0001010100000000ULL:
				p->flip_WHITE_H4();
			case 0X0001010000000000ULL:
				p->flip_WHITE_H3();
			default :
				p->flip_WHITE_H2();
		}


}

void RXBBPatterns::update_patterns_WHITE_A2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_A2();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000402010080400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000402010080400ULL:
				p->flip_WHITE_F7();
			case 0X0000402010080000ULL:
				p->flip_WHITE_E6();
			case 0X0000402010000000ULL:
				p->flip_WHITE_D5();
			case 0X0000402000000000ULL:
				p->flip_WHITE_C4();
			default :
				p->flip_WHITE_B3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000808080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000808080808000ULL:
				p->flip_WHITE_A7();
			case 0X0000808080800000ULL:
				p->flip_WHITE_A6();
			case 0X0000808080000000ULL:
				p->flip_WHITE_A5();
			case 0X0000808000000000ULL:
				p->flip_WHITE_A4();
			default :
				p->flip_WHITE_A3();
		}


	/* direction _E */
	flipped = move.flipped & 0X007E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X007E000000000000ULL:
				p->flip_WHITE_G2();
			case 0X007C000000000000ULL:
				p->flip_WHITE_F2();
			case 0X0078000000000000ULL:
				p->flip_WHITE_E2();
			case 0X0070000000000000ULL:
				p->flip_WHITE_D2();
			case 0X0060000000000000ULL:
				p->flip_WHITE_C2();
			default :
				p->flip_WHITE_B2();
		}


}

void RXBBPatterns::update_patterns_WHITE_B2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_B2();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000201008040200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000201008040200ULL:
				p->flip_WHITE_G7();
			case 0X0000201008040000ULL:
				p->flip_WHITE_F6();
			case 0X0000201008000000ULL:
				p->flip_WHITE_E5();
			case 0X0000201000000000ULL:
				p->flip_WHITE_D4();
			default :
				p->flip_WHITE_C3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000404040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000404040404000ULL:
				p->flip_WHITE_B7();
			case 0X0000404040400000ULL:
				p->flip_WHITE_B6();
			case 0X0000404040000000ULL:
				p->flip_WHITE_B5();
			case 0X0000404000000000ULL:
				p->flip_WHITE_B4();
			default :
				p->flip_WHITE_B3();
		}


	/* direction _E */
	flipped = move.flipped & 0X003E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X003E000000000000ULL:
				p->flip_WHITE_G2();
			case 0X003C000000000000ULL:
				p->flip_WHITE_F2();
			case 0X0038000000000000ULL:
				p->flip_WHITE_E2();
			case 0X0030000000000000ULL:
				p->flip_WHITE_D2();
			default :
				p->flip_WHITE_C2();
		}


}

void RXBBPatterns::update_patterns_WHITE_C2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_C2();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0000202020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000202020202000ULL:
				p->flip_WHITE_C7();
			case 0X0000202020200000ULL:
				p->flip_WHITE_C6();
			case 0X0000202020000000ULL:
				p->flip_WHITE_C5();
			case 0X0000202000000000ULL:
				p->flip_WHITE_C4();
			default :
				p->flip_WHITE_C3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000100804020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000100804020000ULL:
				p->flip_WHITE_G6();
			case 0X0000100804000000ULL:
				p->flip_WHITE_F5();
			case 0X0000100800000000ULL:
				p->flip_WHITE_E4();
			default :
				p->flip_WHITE_D3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000400000000000ULL;
	if(flipped)
		p->flip_WHITE_B3();

	/* direction _E */
	flipped = move.flipped & 0X001E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X001E000000000000ULL:
				p->flip_WHITE_G2();
			case 0X001C000000000000ULL:
				p->flip_WHITE_F2();
			case 0X0018000000000000ULL:
				p->flip_WHITE_E2();
			default :
				p->flip_WHITE_D2();
		}


	/* direction _W */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_WHITE_B2();

}

void RXBBPatterns::update_patterns_WHITE_D2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_D2();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0000101010101000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000101010101000ULL:
				p->flip_WHITE_D7();
			case 0X0000101010100000ULL:
				p->flip_WHITE_D6();
			case 0X0000101010000000ULL:
				p->flip_WHITE_D5();
			case 0X0000101000000000ULL:
				p->flip_WHITE_D4();
			default :
				p->flip_WHITE_D3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000080402000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000080402000000ULL:
				p->flip_WHITE_G5();
			case 0X0000080400000000ULL:
				p->flip_WHITE_F4();
			default :
				p->flip_WHITE_E3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000204000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000204000000000ULL:
				p->flip_WHITE_B4();
			default :
				p->flip_WHITE_C3();
		}


	/* direction _E */
	flipped = move.flipped & 0X000E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000E000000000000ULL:
				p->flip_WHITE_G2();
			case 0X000C000000000000ULL:
				p->flip_WHITE_F2();
			default :
				p->flip_WHITE_E2();
		}


	/* direction _W */
	flipped = move.flipped & 0X0060000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0060000000000000ULL:
				p->flip_WHITE_B2();
			default :
				p->flip_WHITE_C2();
		}


}

void RXBBPatterns::update_patterns_WHITE_E2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_E2();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0000080808080800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000080808080800ULL:
				p->flip_WHITE_E7();
			case 0X0000080808080000ULL:
				p->flip_WHITE_E6();
			case 0X0000080808000000ULL:
				p->flip_WHITE_E5();
			case 0X0000080800000000ULL:
				p->flip_WHITE_E4();
			default :
				p->flip_WHITE_E3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000040200000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000040200000000ULL:
				p->flip_WHITE_G4();
			default :
				p->flip_WHITE_F3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000102040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000102040000000ULL:
				p->flip_WHITE_B5();
			case 0X0000102000000000ULL:
				p->flip_WHITE_C4();
			default :
				p->flip_WHITE_D3();
		}


	/* direction _E */
	flipped = move.flipped & 0X0006000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0006000000000000ULL:
				p->flip_WHITE_G2();
			default :
				p->flip_WHITE_F2();
		}


	/* direction _W */
	flipped = move.flipped & 0X0070000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0070000000000000ULL:
				p->flip_WHITE_B2();
			case 0X0030000000000000ULL:
				p->flip_WHITE_C2();
			default :
				p->flip_WHITE_D2();
		}


}

void RXBBPatterns::update_patterns_WHITE_F2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_F2();

	/* direction S_ */
	unsigned long long flipped = move.flipped & 0X0000040404040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000040404040400ULL:
				p->flip_WHITE_F7();
			case 0X0000040404040000ULL:
				p->flip_WHITE_F6();
			case 0X0000040404000000ULL:
				p->flip_WHITE_F5();
			case 0X0000040400000000ULL:
				p->flip_WHITE_F4();
			default :
				p->flip_WHITE_F3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000020000000000ULL;
	if(flipped)
		p->flip_WHITE_G3();

	/* direction _SW */
	flipped = move.flipped & 0X0000081020400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000081020400000ULL:
				p->flip_WHITE_B6();
			case 0X0000081020000000ULL:
				p->flip_WHITE_C5();
			case 0X0000081000000000ULL:
				p->flip_WHITE_D4();
			default :
				p->flip_WHITE_E3();
		}


	/* direction _E */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_WHITE_G2();

	/* direction _W */
	flipped = move.flipped & 0X0078000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0078000000000000ULL:
				p->flip_WHITE_B2();
			case 0X0038000000000000ULL:
				p->flip_WHITE_C2();
			case 0X0018000000000000ULL:
				p->flip_WHITE_D2();
			default :
				p->flip_WHITE_E2();
		}


}

void RXBBPatterns::update_patterns_WHITE_G2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_G2();

	/* direction _SW */
	unsigned long long flipped = move.flipped & 0X0000040810204000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000040810204000ULL:
				p->flip_WHITE_B7();
			case 0X0000040810200000ULL:
				p->flip_WHITE_C6();
			case 0X0000040810000000ULL:
				p->flip_WHITE_D5();
			case 0X0000040800000000ULL:
				p->flip_WHITE_E4();
			default :
				p->flip_WHITE_F3();
		}


	/* direction _W */
	flipped = move.flipped & 0X007C000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X007C000000000000ULL:
				p->flip_WHITE_B2();
			case 0X003C000000000000ULL:
				p->flip_WHITE_C2();
			case 0X001C000000000000ULL:
				p->flip_WHITE_D2();
			case 0X000C000000000000ULL:
				p->flip_WHITE_E2();
			default :
				p->flip_WHITE_F2();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000020202020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020202020200ULL:
				p->flip_WHITE_G7();
			case 0X0000020202020000ULL:
				p->flip_WHITE_G6();
			case 0X0000020202000000ULL:
				p->flip_WHITE_G5();
			case 0X0000020200000000ULL:
				p->flip_WHITE_G4();
			default :
				p->flip_WHITE_G3();
		}


}

void RXBBPatterns::update_patterns_WHITE_H2(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_H2();

	/* direction _SW */
	unsigned long long flipped = move.flipped & 0X0000020408102000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020408102000ULL:
				p->flip_WHITE_C7();
			case 0X0000020408100000ULL:
				p->flip_WHITE_D6();
			case 0X0000020408000000ULL:
				p->flip_WHITE_E5();
			case 0X0000020400000000ULL:
				p->flip_WHITE_F4();
			default :
				p->flip_WHITE_G3();
		}


	/* direction _W */
	flipped = move.flipped & 0X007E000000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X007E000000000000ULL:
				p->flip_WHITE_B2();
			case 0X003E000000000000ULL:
				p->flip_WHITE_C2();
			case 0X001E000000000000ULL:
				p->flip_WHITE_D2();
			case 0X000E000000000000ULL:
				p->flip_WHITE_E2();
			case 0X0006000000000000ULL:
				p->flip_WHITE_F2();
			default :
				p->flip_WHITE_G2();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000010101010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000010101010100ULL:
				p->flip_WHITE_H7();
			case 0X0000010101010000ULL:
				p->flip_WHITE_H6();
			case 0X0000010101000000ULL:
				p->flip_WHITE_H5();
			case 0X0000010100000000ULL:
				p->flip_WHITE_H4();
			default :
				p->flip_WHITE_H3();
		}


}

void RXBBPatterns::update_patterns_WHITE_A3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_A3();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X00007E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00007E0000000000ULL:
				p->flip_WHITE_G3();
			case 0X00007C0000000000ULL:
				p->flip_WHITE_F3();
			case 0X0000780000000000ULL:
				p->flip_WHITE_E3();
			case 0X0000700000000000ULL:
				p->flip_WHITE_D3();
			case 0X0000600000000000ULL:
				p->flip_WHITE_C3();
			default :
				p->flip_WHITE_B3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_WHITE_B2();

	/* direction _SE */
	flipped = move.flipped & 0X0000004020100800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004020100800ULL:
				p->flip_WHITE_E7();
			case 0X0000004020100000ULL:
				p->flip_WHITE_D6();
			case 0X0000004020000000ULL:
				p->flip_WHITE_C5();
			default :
				p->flip_WHITE_B4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080000000000000ULL;
	if(flipped)
		p->flip_WHITE_A2();

	/* direction S_ */
	flipped = move.flipped & 0X0000008080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000008080808000ULL:
				p->flip_WHITE_A7();
			case 0X0000008080800000ULL:
				p->flip_WHITE_A6();
			case 0X0000008080000000ULL:
				p->flip_WHITE_A5();
			default :
				p->flip_WHITE_A4();
		}


}

void RXBBPatterns::update_patterns_WHITE_B3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_B3();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X00003E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00003E0000000000ULL:
				p->flip_WHITE_G3();
			case 0X00003C0000000000ULL:
				p->flip_WHITE_F3();
			case 0X0000380000000000ULL:
				p->flip_WHITE_E3();
			case 0X0000300000000000ULL:
				p->flip_WHITE_D3();
			default :
				p->flip_WHITE_C3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0020000000000000ULL;
	if(flipped)
		p->flip_WHITE_C2();

	/* direction _SE */
	flipped = move.flipped & 0X0000002010080400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000002010080400ULL:
				p->flip_WHITE_F7();
			case 0X0000002010080000ULL:
				p->flip_WHITE_E6();
			case 0X0000002010000000ULL:
				p->flip_WHITE_D5();
			default :
				p->flip_WHITE_C4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_WHITE_B2();

	/* direction S_ */
	flipped = move.flipped & 0X0000004040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004040404000ULL:
				p->flip_WHITE_B7();
			case 0X0000004040400000ULL:
				p->flip_WHITE_B6();
			case 0X0000004040000000ULL:
				p->flip_WHITE_B5();
			default :
				p->flip_WHITE_B4();
		}


}

void RXBBPatterns::update_patterns_WHITE_C3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_C3();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000001008040200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000001008040200ULL:
				p->flip_WHITE_G7();
			case 0X0000001008040000ULL:
				p->flip_WHITE_F6();
			case 0X0000001008000000ULL:
				p->flip_WHITE_E5();
			default :
				p->flip_WHITE_D4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000002020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000002020202000ULL:
				p->flip_WHITE_C7();
			case 0X0000002020200000ULL:
				p->flip_WHITE_C6();
			case 0X0000002020000000ULL:
				p->flip_WHITE_C5();
			default :
				p->flip_WHITE_C4();
		}


	/* direction _E */
	flipped = move.flipped & 0X00001E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00001E0000000000ULL:
				p->flip_WHITE_G3();
			case 0X00001C0000000000ULL:
				p->flip_WHITE_F3();
			case 0X0000180000000000ULL:
				p->flip_WHITE_E3();
			default :
				p->flip_WHITE_D3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0010000000000000ULL;
	if(flipped)
		p->flip_WHITE_D2();

	/* direction _N */
	flipped = move.flipped & 0X0020000000000000ULL;
	if(flipped)
		p->flip_WHITE_C2();

	/* direction NW */
	flipped = move.flipped & 0X0040000000000000ULL;
	if(flipped)
		p->flip_WHITE_B2();

	/* direction _SW */
	flipped = move.flipped & 0X0000004000000000ULL;
	if(flipped)
		p->flip_WHITE_B4();

	/* direction _W */
	flipped = move.flipped & 0X0000400000000000ULL;
	if(flipped)
		p->flip_WHITE_B3();

}

void RXBBPatterns::update_patterns_WHITE_D3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_D3();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000804020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000804020000ULL:
				p->flip_WHITE_G6();
			case 0X0000000804000000ULL:
				p->flip_WHITE_F5();
			default :
				p->flip_WHITE_E4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000001010101000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000001010101000ULL:
				p->flip_WHITE_D7();
			case 0X0000001010100000ULL:
				p->flip_WHITE_D6();
			case 0X0000001010000000ULL:
				p->flip_WHITE_D5();
			default :
				p->flip_WHITE_D4();
		}


	/* direction _E */
	flipped = move.flipped & 0X00000E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000E0000000000ULL:
				p->flip_WHITE_G3();
			case 0X00000C0000000000ULL:
				p->flip_WHITE_F3();
			default :
				p->flip_WHITE_E3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0008000000000000ULL;
	if(flipped)
		p->flip_WHITE_E2();

	/* direction _N */
	flipped = move.flipped & 0X0010000000000000ULL;
	if(flipped)
		p->flip_WHITE_D2();

	/* direction NW */
	flipped = move.flipped & 0X0020000000000000ULL;
	if(flipped)
		p->flip_WHITE_C2();

	/* direction _SW */
	flipped = move.flipped & 0X0000002040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000002040000000ULL:
				p->flip_WHITE_B5();
			default :
				p->flip_WHITE_C4();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000600000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000600000000000ULL:
				p->flip_WHITE_B3();
			default :
				p->flip_WHITE_C3();
		}


}

void RXBBPatterns::update_patterns_WHITE_E3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_E3();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000402000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000402000000ULL:
				p->flip_WHITE_G5();
			default :
				p->flip_WHITE_F4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000808080800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000808080800ULL:
				p->flip_WHITE_E7();
			case 0X0000000808080000ULL:
				p->flip_WHITE_E6();
			case 0X0000000808000000ULL:
				p->flip_WHITE_E5();
			default :
				p->flip_WHITE_E4();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000060000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000060000000000ULL:
				p->flip_WHITE_G3();
			default :
				p->flip_WHITE_F3();
		}


	/* direction NE */
	flipped = move.flipped & 0X0004000000000000ULL;
	if(flipped)
		p->flip_WHITE_F2();

	/* direction _N */
	flipped = move.flipped & 0X0008000000000000ULL;
	if(flipped)
		p->flip_WHITE_E2();

	/* direction NW */
	flipped = move.flipped & 0X0010000000000000ULL;
	if(flipped)
		p->flip_WHITE_D2();

	/* direction _SW */
	flipped = move.flipped & 0X0000001020400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000001020400000ULL:
				p->flip_WHITE_B6();
			case 0X0000001020000000ULL:
				p->flip_WHITE_C5();
			default :
				p->flip_WHITE_D4();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000700000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000700000000000ULL:
				p->flip_WHITE_B3();
			case 0X0000300000000000ULL:
				p->flip_WHITE_C3();
			default :
				p->flip_WHITE_D3();
		}


}

void RXBBPatterns::update_patterns_WHITE_F3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_F3();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000200000000ULL;
	if(flipped)
		p->flip_WHITE_G4();

	/* direction S_ */
	flipped = move.flipped & 0X0000000404040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000404040400ULL:
				p->flip_WHITE_F7();
			case 0X0000000404040000ULL:
				p->flip_WHITE_F6();
			case 0X0000000404000000ULL:
				p->flip_WHITE_F5();
			default :
				p->flip_WHITE_F4();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000020000000000ULL;
	if(flipped)
		p->flip_WHITE_G3();

	/* direction NE */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_WHITE_G2();

	/* direction _N */
	flipped = move.flipped & 0X0004000000000000ULL;
	if(flipped)
		p->flip_WHITE_F2();

	/* direction NW */
	flipped = move.flipped & 0X0008000000000000ULL;
	if(flipped)
		p->flip_WHITE_E2();

	/* direction _SW */
	flipped = move.flipped & 0X0000000810204000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000810204000ULL:
				p->flip_WHITE_B7();
			case 0X0000000810200000ULL:
				p->flip_WHITE_C6();
			case 0X0000000810000000ULL:
				p->flip_WHITE_D5();
			default :
				p->flip_WHITE_E4();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000780000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000780000000000ULL:
				p->flip_WHITE_B3();
			case 0X0000380000000000ULL:
				p->flip_WHITE_C3();
			case 0X0000180000000000ULL:
				p->flip_WHITE_D3();
			default :
				p->flip_WHITE_E3();
		}


}

void RXBBPatterns::update_patterns_WHITE_G3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_G3();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X00007C0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00007C0000000000ULL:
				p->flip_WHITE_B3();
			case 0X00003C0000000000ULL:
				p->flip_WHITE_C3();
			case 0X00001C0000000000ULL:
				p->flip_WHITE_D3();
			case 0X00000C0000000000ULL:
				p->flip_WHITE_E3();
			default :
				p->flip_WHITE_F3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000408102000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000408102000ULL:
				p->flip_WHITE_C7();
			case 0X0000000408100000ULL:
				p->flip_WHITE_D6();
			case 0X0000000408000000ULL:
				p->flip_WHITE_E5();
			default :
				p->flip_WHITE_F4();
		}


	/* direction NW */
	flipped = move.flipped & 0X0004000000000000ULL;
	if(flipped)
		p->flip_WHITE_F2();

	/* direction S_ */
	flipped = move.flipped & 0X0000000202020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000202020200ULL:
				p->flip_WHITE_G7();
			case 0X0000000202020000ULL:
				p->flip_WHITE_G6();
			case 0X0000000202000000ULL:
				p->flip_WHITE_G5();
			default :
				p->flip_WHITE_G4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_WHITE_G2();

}

void RXBBPatterns::update_patterns_WHITE_H3(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_H3();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X00007E0000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00007E0000000000ULL:
				p->flip_WHITE_B3();
			case 0X00003E0000000000ULL:
				p->flip_WHITE_C3();
			case 0X00001E0000000000ULL:
				p->flip_WHITE_D3();
			case 0X00000E0000000000ULL:
				p->flip_WHITE_E3();
			case 0X0000060000000000ULL:
				p->flip_WHITE_F3();
			default :
				p->flip_WHITE_G3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000204081000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000204081000ULL:
				p->flip_WHITE_D7();
			case 0X0000000204080000ULL:
				p->flip_WHITE_E6();
			case 0X0000000204000000ULL:
				p->flip_WHITE_F5();
			default :
				p->flip_WHITE_G4();
		}


	/* direction NW */
	flipped = move.flipped & 0X0002000000000000ULL;
	if(flipped)
		p->flip_WHITE_G2();

	/* direction S_ */
	flipped = move.flipped & 0X0000000101010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000101010100ULL:
				p->flip_WHITE_H7();
			case 0X0000000101010000ULL:
				p->flip_WHITE_H6();
			case 0X0000000101000000ULL:
				p->flip_WHITE_H5();
			default :
				p->flip_WHITE_H4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001000000000000ULL;
	if(flipped)
		p->flip_WHITE_H2();

}

void RXBBPatterns::update_patterns_WHITE_A4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_A4();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X0000007E00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000007E00000000ULL:
				p->flip_WHITE_G4();
			case 0X0000007C00000000ULL:
				p->flip_WHITE_F4();
			case 0X0000007800000000ULL:
				p->flip_WHITE_E4();
			case 0X0000007000000000ULL:
				p->flip_WHITE_D4();
			case 0X0000006000000000ULL:
				p->flip_WHITE_C4();
			default :
				p->flip_WHITE_B4();
		}


	/* direction NE */
	flipped = move.flipped & 0X0020400000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020400000000000ULL:
				p->flip_WHITE_C2();
			default :
				p->flip_WHITE_B3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000040201000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000040201000ULL:
				p->flip_WHITE_D7();
			case 0X0000000040200000ULL:
				p->flip_WHITE_C6();
			default :
				p->flip_WHITE_B5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080800000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080800000000000ULL:
				p->flip_WHITE_A2();
			default :
				p->flip_WHITE_A3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000080808000ULL:
				p->flip_WHITE_A7();
			case 0X0000000080800000ULL:
				p->flip_WHITE_A6();
			default :
				p->flip_WHITE_A5();
		}


}

void RXBBPatterns::update_patterns_WHITE_B4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_B4();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X0000003E00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000003E00000000ULL:
				p->flip_WHITE_G4();
			case 0X0000003C00000000ULL:
				p->flip_WHITE_F4();
			case 0X0000003800000000ULL:
				p->flip_WHITE_E4();
			case 0X0000003000000000ULL:
				p->flip_WHITE_D4();
			default :
				p->flip_WHITE_C4();
		}


	/* direction NE */
	flipped = move.flipped & 0X0010200000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010200000000000ULL:
				p->flip_WHITE_D2();
			default :
				p->flip_WHITE_C3();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000020100800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000020100800ULL:
				p->flip_WHITE_E7();
			case 0X0000000020100000ULL:
				p->flip_WHITE_D6();
			default :
				p->flip_WHITE_C5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040400000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040400000000000ULL:
				p->flip_WHITE_B2();
			default :
				p->flip_WHITE_B3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000040404000ULL:
				p->flip_WHITE_B7();
			case 0X0000000040400000ULL:
				p->flip_WHITE_B6();
			default :
				p->flip_WHITE_B5();
		}


}

void RXBBPatterns::update_patterns_WHITE_C4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_C4();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000010080400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000010080400ULL:
				p->flip_WHITE_F7();
			case 0X0000000010080000ULL:
				p->flip_WHITE_E6();
			default :
				p->flip_WHITE_D5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000020202000ULL:
				p->flip_WHITE_C7();
			case 0X0000000020200000ULL:
				p->flip_WHITE_C6();
			default :
				p->flip_WHITE_C5();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000001E00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000001E00000000ULL:
				p->flip_WHITE_G4();
			case 0X0000001C00000000ULL:
				p->flip_WHITE_F4();
			case 0X0000001800000000ULL:
				p->flip_WHITE_E4();
			default :
				p->flip_WHITE_D4();
		}


	/* direction NE */
	flipped = move.flipped & 0X0008100000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008100000000000ULL:
				p->flip_WHITE_E2();
			default :
				p->flip_WHITE_D3();
		}


	/* direction _N */
	flipped = move.flipped & 0X0020200000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020200000000000ULL:
				p->flip_WHITE_C2();
			default :
				p->flip_WHITE_C3();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000400000000000ULL;
	if(flipped)
		p->flip_WHITE_B3();

	/* direction _SW */
	flipped = move.flipped & 0X0000000040000000ULL;
	if(flipped)
		p->flip_WHITE_B5();

	/* direction _W */
	flipped = move.flipped & 0X0000004000000000ULL;
	if(flipped)
		p->flip_WHITE_B4();

}

void RXBBPatterns::update_patterns_WHITE_F4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_F4();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000002000000ULL;
	if(flipped)
		p->flip_WHITE_G5();

	/* direction S_ */
	flipped = move.flipped & 0X0000000004040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000004040400ULL:
				p->flip_WHITE_F7();
			case 0X0000000004040000ULL:
				p->flip_WHITE_F6();
			default :
				p->flip_WHITE_F5();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000200000000ULL;
	if(flipped)
		p->flip_WHITE_G4();

	/* direction NE */
	flipped = move.flipped & 0X0000020000000000ULL;
	if(flipped)
		p->flip_WHITE_G3();

	/* direction _N */
	flipped = move.flipped & 0X0004040000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040000000000ULL:
				p->flip_WHITE_F2();
			default :
				p->flip_WHITE_F3();
		}


	/* direction NW */
	flipped = move.flipped & 0X0010080000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010080000000000ULL:
				p->flip_WHITE_D2();
			default :
				p->flip_WHITE_E3();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000008102000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000008102000ULL:
				p->flip_WHITE_C7();
			case 0X0000000008100000ULL:
				p->flip_WHITE_D6();
			default :
				p->flip_WHITE_E5();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000007800000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000007800000000ULL:
				p->flip_WHITE_B4();
			case 0X0000003800000000ULL:
				p->flip_WHITE_C4();
			case 0X0000001800000000ULL:
				p->flip_WHITE_D4();
			default :
				p->flip_WHITE_E4();
		}


}

void RXBBPatterns::update_patterns_WHITE_G4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_G4();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X0000007C00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000007C00000000ULL:
				p->flip_WHITE_B4();
			case 0X0000003C00000000ULL:
				p->flip_WHITE_C4();
			case 0X0000001C00000000ULL:
				p->flip_WHITE_D4();
			case 0X0000000C00000000ULL:
				p->flip_WHITE_E4();
			default :
				p->flip_WHITE_F4();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000004081000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000004081000ULL:
				p->flip_WHITE_D7();
			case 0X0000000004080000ULL:
				p->flip_WHITE_E6();
			default :
				p->flip_WHITE_F5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0008040000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008040000000000ULL:
				p->flip_WHITE_E2();
			default :
				p->flip_WHITE_F3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000002020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000002020200ULL:
				p->flip_WHITE_G7();
			case 0X0000000002020000ULL:
				p->flip_WHITE_G6();
			default :
				p->flip_WHITE_G5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002020000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020000000000ULL:
				p->flip_WHITE_G2();
			default :
				p->flip_WHITE_G3();
		}


}

void RXBBPatterns::update_patterns_WHITE_H4(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_H4();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X0000007E00000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000007E00000000ULL:
				p->flip_WHITE_B4();
			case 0X0000003E00000000ULL:
				p->flip_WHITE_C4();
			case 0X0000001E00000000ULL:
				p->flip_WHITE_D4();
			case 0X0000000E00000000ULL:
				p->flip_WHITE_E4();
			case 0X0000000600000000ULL:
				p->flip_WHITE_F4();
			default :
				p->flip_WHITE_G4();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000002040800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000002040800ULL:
				p->flip_WHITE_E7();
			case 0X0000000002040000ULL:
				p->flip_WHITE_F6();
			default :
				p->flip_WHITE_G5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0004020000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004020000000000ULL:
				p->flip_WHITE_F2();
			default :
				p->flip_WHITE_G3();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000001010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000001010100ULL:
				p->flip_WHITE_H7();
			case 0X0000000001010000ULL:
				p->flip_WHITE_H6();
			default :
				p->flip_WHITE_H5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001010000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010000000000ULL:
				p->flip_WHITE_H2();
			default :
				p->flip_WHITE_H3();
		}


}

void RXBBPatterns::update_patterns_WHITE_A5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_A5();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X000000007E000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000007E000000ULL:
				p->flip_WHITE_G5();
			case 0X000000007C000000ULL:
				p->flip_WHITE_F5();
			case 0X0000000078000000ULL:
				p->flip_WHITE_E5();
			case 0X0000000070000000ULL:
				p->flip_WHITE_D5();
			case 0X0000000060000000ULL:
				p->flip_WHITE_C5();
			default :
				p->flip_WHITE_B5();
		}


	/* direction NE */
	flipped = move.flipped & 0X0010204000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010204000000000ULL:
				p->flip_WHITE_D2();
			case 0X0000204000000000ULL:
				p->flip_WHITE_C3();
			default :
				p->flip_WHITE_B4();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000000402000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000402000ULL:
				p->flip_WHITE_C7();
			default :
				p->flip_WHITE_B6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080808000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808000000000ULL:
				p->flip_WHITE_A2();
			case 0X0000808000000000ULL:
				p->flip_WHITE_A3();
			default :
				p->flip_WHITE_A4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000808000ULL:
				p->flip_WHITE_A7();
			default :
				p->flip_WHITE_A6();
		}


}

void RXBBPatterns::update_patterns_WHITE_B5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_B5();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X000000003E000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000003E000000ULL:
				p->flip_WHITE_G5();
			case 0X000000003C000000ULL:
				p->flip_WHITE_F5();
			case 0X0000000038000000ULL:
				p->flip_WHITE_E5();
			case 0X0000000030000000ULL:
				p->flip_WHITE_D5();
			default :
				p->flip_WHITE_C5();
		}


	/* direction NE */
	flipped = move.flipped & 0X0008102000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008102000000000ULL:
				p->flip_WHITE_E2();
			case 0X0000102000000000ULL:
				p->flip_WHITE_D3();
			default :
				p->flip_WHITE_C4();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000000201000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000201000ULL:
				p->flip_WHITE_D7();
			default :
				p->flip_WHITE_C6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040404000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404000000000ULL:
				p->flip_WHITE_B2();
			case 0X0000404000000000ULL:
				p->flip_WHITE_B3();
			default :
				p->flip_WHITE_B4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000404000ULL:
				p->flip_WHITE_B7();
			default :
				p->flip_WHITE_B6();
		}


}

void RXBBPatterns::update_patterns_WHITE_C5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_C5();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000100800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000100800ULL:
				p->flip_WHITE_E7();
			default :
				p->flip_WHITE_D6();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000202000ULL:
				p->flip_WHITE_C7();
			default :
				p->flip_WHITE_C6();
		}


	/* direction _E */
	flipped = move.flipped & 0X000000001E000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000001E000000ULL:
				p->flip_WHITE_G5();
			case 0X000000001C000000ULL:
				p->flip_WHITE_F5();
			case 0X0000000018000000ULL:
				p->flip_WHITE_E5();
			default :
				p->flip_WHITE_D5();
		}


	/* direction NE */
	flipped = move.flipped & 0X0004081000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004081000000000ULL:
				p->flip_WHITE_F2();
			case 0X0000081000000000ULL:
				p->flip_WHITE_E3();
			default :
				p->flip_WHITE_D4();
		}


	/* direction _N */
	flipped = move.flipped & 0X0020202000000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202000000000ULL:
				p->flip_WHITE_C2();
			case 0X0000202000000000ULL:
				p->flip_WHITE_C3();
			default :
				p->flip_WHITE_C4();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000004000000000ULL;
	if(flipped)
		p->flip_WHITE_B4();

	/* direction _SW */
	flipped = move.flipped & 0X0000000000400000ULL;
	if(flipped)
		p->flip_WHITE_B6();

	/* direction _W */
	flipped = move.flipped & 0X0000000040000000ULL;
	if(flipped)
		p->flip_WHITE_B5();

}

void RXBBPatterns::update_patterns_WHITE_F5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_F5();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000020000ULL;
	if(flipped)
		p->flip_WHITE_G6();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000040400ULL:
				p->flip_WHITE_F7();
			default :
				p->flip_WHITE_F6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000002000000ULL;
	if(flipped)
		p->flip_WHITE_G5();

	/* direction NE */
	flipped = move.flipped & 0X0000000200000000ULL;
	if(flipped)
		p->flip_WHITE_G4();

	/* direction _N */
	flipped = move.flipped & 0X0004040400000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040400000000ULL:
				p->flip_WHITE_F2();
			case 0X0000040400000000ULL:
				p->flip_WHITE_F3();
			default :
				p->flip_WHITE_F4();
		}


	/* direction NW */
	flipped = move.flipped & 0X0020100800000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020100800000000ULL:
				p->flip_WHITE_C2();
			case 0X0000100800000000ULL:
				p->flip_WHITE_D3();
			default :
				p->flip_WHITE_E4();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000081000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000081000ULL:
				p->flip_WHITE_D7();
			default :
				p->flip_WHITE_E6();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000078000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000078000000ULL:
				p->flip_WHITE_B5();
			case 0X0000000038000000ULL:
				p->flip_WHITE_C5();
			case 0X0000000018000000ULL:
				p->flip_WHITE_D5();
			default :
				p->flip_WHITE_E5();
		}


}

void RXBBPatterns::update_patterns_WHITE_G5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_G5();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X000000007C000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000007C000000ULL:
				p->flip_WHITE_B5();
			case 0X000000003C000000ULL:
				p->flip_WHITE_C5();
			case 0X000000001C000000ULL:
				p->flip_WHITE_D5();
			case 0X000000000C000000ULL:
				p->flip_WHITE_E5();
			default :
				p->flip_WHITE_F5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000040800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000040800ULL:
				p->flip_WHITE_E7();
			default :
				p->flip_WHITE_F6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0010080400000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010080400000000ULL:
				p->flip_WHITE_D2();
			case 0X0000080400000000ULL:
				p->flip_WHITE_E3();
			default :
				p->flip_WHITE_F4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000020200ULL:
				p->flip_WHITE_G7();
			default :
				p->flip_WHITE_G6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002020200000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020200000000ULL:
				p->flip_WHITE_G2();
			case 0X0000020200000000ULL:
				p->flip_WHITE_G3();
			default :
				p->flip_WHITE_G4();
		}


}

void RXBBPatterns::update_patterns_WHITE_H5(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_H5();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X000000007E000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X000000007E000000ULL:
				p->flip_WHITE_B5();
			case 0X000000003E000000ULL:
				p->flip_WHITE_C5();
			case 0X000000001E000000ULL:
				p->flip_WHITE_D5();
			case 0X000000000E000000ULL:
				p->flip_WHITE_E5();
			case 0X0000000006000000ULL:
				p->flip_WHITE_F5();
			default :
				p->flip_WHITE_G5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000020400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000020400ULL:
				p->flip_WHITE_F7();
			default :
				p->flip_WHITE_G6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0008040200000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008040200000000ULL:
				p->flip_WHITE_E2();
			case 0X0000040200000000ULL:
				p->flip_WHITE_F3();
			default :
				p->flip_WHITE_G4();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000010100ULL:
				p->flip_WHITE_H7();
			default :
				p->flip_WHITE_H6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001010100000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010100000000ULL:
				p->flip_WHITE_H2();
			case 0X0000010100000000ULL:
				p->flip_WHITE_H3();
			default :
				p->flip_WHITE_H4();
		}


}

void RXBBPatterns::update_patterns_WHITE_A6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_A6();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X00000000007E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000007E0000ULL:
				p->flip_WHITE_G6();
			case 0X00000000007C0000ULL:
				p->flip_WHITE_F6();
			case 0X0000000000780000ULL:
				p->flip_WHITE_E6();
			case 0X0000000000700000ULL:
				p->flip_WHITE_D6();
			case 0X0000000000600000ULL:
				p->flip_WHITE_C6();
			default :
				p->flip_WHITE_B6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0008102040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008102040000000ULL:
				p->flip_WHITE_E2();
			case 0X0000102040000000ULL:
				p->flip_WHITE_D3();
			case 0X0000002040000000ULL:
				p->flip_WHITE_C4();
			default :
				p->flip_WHITE_B5();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_WHITE_B7();

	/* direction _N */
	flipped = move.flipped & 0X0080808080000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808080000000ULL:
				p->flip_WHITE_A2();
			case 0X0000808080000000ULL:
				p->flip_WHITE_A3();
			case 0X0000008080000000ULL:
				p->flip_WHITE_A4();
			default :
				p->flip_WHITE_A5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000008000ULL;
	if(flipped)
		p->flip_WHITE_A7();

}

void RXBBPatterns::update_patterns_WHITE_B6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_B6();

	/* direction _E */
	unsigned long long flipped = move.flipped & 0X00000000003E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000003E0000ULL:
				p->flip_WHITE_G6();
			case 0X00000000003C0000ULL:
				p->flip_WHITE_F6();
			case 0X0000000000380000ULL:
				p->flip_WHITE_E6();
			case 0X0000000000300000ULL:
				p->flip_WHITE_D6();
			default :
				p->flip_WHITE_C6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0004081020000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004081020000000ULL:
				p->flip_WHITE_F2();
			case 0X0000081020000000ULL:
				p->flip_WHITE_E3();
			case 0X0000001020000000ULL:
				p->flip_WHITE_D4();
			default :
				p->flip_WHITE_C5();
		}


	/* direction _SE */
	flipped = move.flipped & 0X0000000000002000ULL;
	if(flipped)
		p->flip_WHITE_C7();

	/* direction _N */
	flipped = move.flipped & 0X0040404040000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404040000000ULL:
				p->flip_WHITE_B2();
			case 0X0000404040000000ULL:
				p->flip_WHITE_B3();
			case 0X0000004040000000ULL:
				p->flip_WHITE_B4();
			default :
				p->flip_WHITE_B5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_WHITE_B7();

}

void RXBBPatterns::update_patterns_WHITE_C6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_C6();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000001000ULL;
	if(flipped)
		p->flip_WHITE_D7();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000002000ULL;
	if(flipped)
		p->flip_WHITE_C7();

	/* direction _E */
	flipped = move.flipped & 0X00000000001E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000001E0000ULL:
				p->flip_WHITE_G6();
			case 0X00000000001C0000ULL:
				p->flip_WHITE_F6();
			case 0X0000000000180000ULL:
				p->flip_WHITE_E6();
			default :
				p->flip_WHITE_D6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0002040810000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002040810000000ULL:
				p->flip_WHITE_G2();
			case 0X0000040810000000ULL:
				p->flip_WHITE_F3();
			case 0X0000000810000000ULL:
				p->flip_WHITE_E4();
			default :
				p->flip_WHITE_D5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0020202020000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202020000000ULL:
				p->flip_WHITE_C2();
			case 0X0000202020000000ULL:
				p->flip_WHITE_C3();
			case 0X0000002020000000ULL:
				p->flip_WHITE_C4();
			default :
				p->flip_WHITE_C5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000040000000ULL;
	if(flipped)
		p->flip_WHITE_B5();

	/* direction _SW */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_WHITE_B7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000400000ULL;
	if(flipped)
		p->flip_WHITE_B6();

}

void RXBBPatterns::update_patterns_WHITE_D6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_D6();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000000800ULL;
	if(flipped)
		p->flip_WHITE_E7();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000001000ULL;
	if(flipped)
		p->flip_WHITE_D7();

	/* direction _E */
	flipped = move.flipped & 0X00000000000E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000000E0000ULL:
				p->flip_WHITE_G6();
			case 0X00000000000C0000ULL:
				p->flip_WHITE_F6();
			default :
				p->flip_WHITE_E6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000020408000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020408000000ULL:
				p->flip_WHITE_G3();
			case 0X0000000408000000ULL:
				p->flip_WHITE_F4();
			default :
				p->flip_WHITE_E5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0010101010000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010101010000000ULL:
				p->flip_WHITE_D2();
			case 0X0000101010000000ULL:
				p->flip_WHITE_D3();
			case 0X0000001010000000ULL:
				p->flip_WHITE_D4();
			default :
				p->flip_WHITE_D5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000004020000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004020000000ULL:
				p->flip_WHITE_B4();
			default :
				p->flip_WHITE_C5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000002000ULL;
	if(flipped)
		p->flip_WHITE_C7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000600000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000600000ULL:
				p->flip_WHITE_B6();
			default :
				p->flip_WHITE_C6();
		}


}

void RXBBPatterns::update_patterns_WHITE_E6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_E6();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000000400ULL;
	if(flipped)
		p->flip_WHITE_F7();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000000800ULL;
	if(flipped)
		p->flip_WHITE_E7();

	/* direction _E */
	flipped = move.flipped & 0X0000000000060000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000060000ULL:
				p->flip_WHITE_G6();
			default :
				p->flip_WHITE_F6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000204000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000204000000ULL:
				p->flip_WHITE_G4();
			default :
				p->flip_WHITE_F5();
		}


	/* direction _N */
	flipped = move.flipped & 0X0008080808000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008080808000000ULL:
				p->flip_WHITE_E2();
			case 0X0000080808000000ULL:
				p->flip_WHITE_E3();
			case 0X0000000808000000ULL:
				p->flip_WHITE_E4();
			default :
				p->flip_WHITE_E5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000402010000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000402010000000ULL:
				p->flip_WHITE_B3();
			case 0X0000002010000000ULL:
				p->flip_WHITE_C4();
			default :
				p->flip_WHITE_D5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000001000ULL;
	if(flipped)
		p->flip_WHITE_D7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000700000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000700000ULL:
				p->flip_WHITE_B6();
			case 0X0000000000300000ULL:
				p->flip_WHITE_C6();
			default :
				p->flip_WHITE_D6();
		}


}

void RXBBPatterns::update_patterns_WHITE_F6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_F6();

	/* direction _SE */
	unsigned long long flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_WHITE_G7();

	/* direction S_ */
	flipped = move.flipped & 0X0000000000000400ULL;
	if(flipped)
		p->flip_WHITE_F7();

	/* direction _E */
	flipped = move.flipped & 0X0000000000020000ULL;
	if(flipped)
		p->flip_WHITE_G6();

	/* direction NE */
	flipped = move.flipped & 0X0000000002000000ULL;
	if(flipped)
		p->flip_WHITE_G5();

	/* direction _N */
	flipped = move.flipped & 0X0004040404000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040404000000ULL:
				p->flip_WHITE_F2();
			case 0X0000040404000000ULL:
				p->flip_WHITE_F3();
			case 0X0000000404000000ULL:
				p->flip_WHITE_F4();
			default :
				p->flip_WHITE_F5();
		}


	/* direction NW */
	flipped = move.flipped & 0X0040201008000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040201008000000ULL:
				p->flip_WHITE_B2();
			case 0X0000201008000000ULL:
				p->flip_WHITE_C3();
			case 0X0000001008000000ULL:
				p->flip_WHITE_D4();
			default :
				p->flip_WHITE_E5();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000000800ULL;
	if(flipped)
		p->flip_WHITE_E7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000780000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000780000ULL:
				p->flip_WHITE_B6();
			case 0X0000000000380000ULL:
				p->flip_WHITE_C6();
			case 0X0000000000180000ULL:
				p->flip_WHITE_D6();
			default :
				p->flip_WHITE_E6();
		}


}

void RXBBPatterns::update_patterns_WHITE_G6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_G6();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X00000000007C0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000007C0000ULL:
				p->flip_WHITE_B6();
			case 0X00000000003C0000ULL:
				p->flip_WHITE_C6();
			case 0X00000000001C0000ULL:
				p->flip_WHITE_D6();
			case 0X00000000000C0000ULL:
				p->flip_WHITE_E6();
			default :
				p->flip_WHITE_F6();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000000400ULL;
	if(flipped)
		p->flip_WHITE_F7();

	/* direction NW */
	flipped = move.flipped & 0X0020100804000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020100804000000ULL:
				p->flip_WHITE_C2();
			case 0X0000100804000000ULL:
				p->flip_WHITE_D3();
			case 0X0000000804000000ULL:
				p->flip_WHITE_E4();
			default :
				p->flip_WHITE_F5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_WHITE_G7();

	/* direction _N */
	flipped = move.flipped & 0X0002020202000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020202000000ULL:
				p->flip_WHITE_G2();
			case 0X0000020202000000ULL:
				p->flip_WHITE_G3();
			case 0X0000000202000000ULL:
				p->flip_WHITE_G4();
			default :
				p->flip_WHITE_G5();
		}


}

void RXBBPatterns::update_patterns_WHITE_H6(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_H6();

	/* direction _W */
	unsigned long long flipped = move.flipped & 0X00000000007E0000ULL;
	if(flipped)
		switch(flipped) {
			case 0X00000000007E0000ULL:
				p->flip_WHITE_B6();
			case 0X00000000003E0000ULL:
				p->flip_WHITE_C6();
			case 0X00000000001E0000ULL:
				p->flip_WHITE_D6();
			case 0X00000000000E0000ULL:
				p->flip_WHITE_E6();
			case 0X0000000000060000ULL:
				p->flip_WHITE_F6();
			default :
				p->flip_WHITE_G6();
		}


	/* direction _SW */
	flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_WHITE_G7();

	/* direction NW */
	flipped = move.flipped & 0X0010080402000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010080402000000ULL:
				p->flip_WHITE_D2();
			case 0X0000080402000000ULL:
				p->flip_WHITE_E3();
			case 0X0000000402000000ULL:
				p->flip_WHITE_F4();
			default :
				p->flip_WHITE_G5();
		}


	/* direction S_ */
	flipped = move.flipped & 0X0000000000000100ULL;
	if(flipped)
		p->flip_WHITE_H7();

	/* direction _N */
	flipped = move.flipped & 0X0001010101000000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010101000000ULL:
				p->flip_WHITE_H2();
			case 0X0000010101000000ULL:
				p->flip_WHITE_H3();
			case 0X0000000101000000ULL:
				p->flip_WHITE_H4();
			default :
				p->flip_WHITE_H5();
		}


}

void RXBBPatterns::update_patterns_WHITE_A7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_A7();

	/* direction NE */
	unsigned long long flipped = move.flipped & 0X0004081020400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004081020400000ULL:
				p->flip_WHITE_F2();
			case 0X0000081020400000ULL:
				p->flip_WHITE_E3();
			case 0X0000001020400000ULL:
				p->flip_WHITE_D4();
			case 0X0000000020400000ULL:
				p->flip_WHITE_C5();
			default :
				p->flip_WHITE_B6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080808080800000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808080800000ULL:
				p->flip_WHITE_A2();
			case 0X0000808080800000ULL:
				p->flip_WHITE_A3();
			case 0X0000008080800000ULL:
				p->flip_WHITE_A4();
			case 0X0000000080800000ULL:
				p->flip_WHITE_A5();
			default :
				p->flip_WHITE_A6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000007E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007E00ULL:
				p->flip_WHITE_G7();
			case 0X0000000000007C00ULL:
				p->flip_WHITE_F7();
			case 0X0000000000007800ULL:
				p->flip_WHITE_E7();
			case 0X0000000000007000ULL:
				p->flip_WHITE_D7();
			case 0X0000000000006000ULL:
				p->flip_WHITE_C7();
			default :
				p->flip_WHITE_B7();
		}


}

void RXBBPatterns::update_patterns_WHITE_B7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_B7();

	/* direction NE */
	unsigned long long flipped = move.flipped & 0X0002040810200000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002040810200000ULL:
				p->flip_WHITE_G2();
			case 0X0000040810200000ULL:
				p->flip_WHITE_F3();
			case 0X0000000810200000ULL:
				p->flip_WHITE_E4();
			case 0X0000000010200000ULL:
				p->flip_WHITE_D5();
			default :
				p->flip_WHITE_C6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040404040400000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404040400000ULL:
				p->flip_WHITE_B2();
			case 0X0000404040400000ULL:
				p->flip_WHITE_B3();
			case 0X0000004040400000ULL:
				p->flip_WHITE_B4();
			case 0X0000000040400000ULL:
				p->flip_WHITE_B5();
			default :
				p->flip_WHITE_B6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000003E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000003E00ULL:
				p->flip_WHITE_G7();
			case 0X0000000000003C00ULL:
				p->flip_WHITE_F7();
			case 0X0000000000003800ULL:
				p->flip_WHITE_E7();
			case 0X0000000000003000ULL:
				p->flip_WHITE_D7();
			default :
				p->flip_WHITE_C7();
		}


}

void RXBBPatterns::update_patterns_WHITE_C7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_C7();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0020202020200000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202020200000ULL:
				p->flip_WHITE_C2();
			case 0X0000202020200000ULL:
				p->flip_WHITE_C3();
			case 0X0000002020200000ULL:
				p->flip_WHITE_C4();
			case 0X0000000020200000ULL:
				p->flip_WHITE_C5();
			default :
				p->flip_WHITE_C6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000020408100000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020408100000ULL:
				p->flip_WHITE_G3();
			case 0X0000000408100000ULL:
				p->flip_WHITE_F4();
			case 0X0000000008100000ULL:
				p->flip_WHITE_E5();
			default :
				p->flip_WHITE_D6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000000400000ULL;
	if(flipped)
		p->flip_WHITE_B6();

	/* direction _E */
	flipped = move.flipped & 0X0000000000001E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000001E00ULL:
				p->flip_WHITE_G7();
			case 0X0000000000001C00ULL:
				p->flip_WHITE_F7();
			case 0X0000000000001800ULL:
				p->flip_WHITE_E7();
			default :
				p->flip_WHITE_D7();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_WHITE_B7();

}

void RXBBPatterns::update_patterns_WHITE_D7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_D7();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0010101010100000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010101010100000ULL:
				p->flip_WHITE_D2();
			case 0X0000101010100000ULL:
				p->flip_WHITE_D3();
			case 0X0000001010100000ULL:
				p->flip_WHITE_D4();
			case 0X0000000010100000ULL:
				p->flip_WHITE_D5();
			default :
				p->flip_WHITE_D6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000204080000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000204080000ULL:
				p->flip_WHITE_G4();
			case 0X0000000004080000ULL:
				p->flip_WHITE_F5();
			default :
				p->flip_WHITE_E6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000040200000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000040200000ULL:
				p->flip_WHITE_B5();
			default :
				p->flip_WHITE_C6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000E00ULL:
				p->flip_WHITE_G7();
			case 0X0000000000000C00ULL:
				p->flip_WHITE_F7();
			default :
				p->flip_WHITE_E7();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000006000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000006000ULL:
				p->flip_WHITE_B7();
			default :
				p->flip_WHITE_C7();
		}


}

void RXBBPatterns::update_patterns_WHITE_E7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_E7();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0008080808080000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008080808080000ULL:
				p->flip_WHITE_E2();
			case 0X0000080808080000ULL:
				p->flip_WHITE_E3();
			case 0X0000000808080000ULL:
				p->flip_WHITE_E4();
			case 0X0000000008080000ULL:
				p->flip_WHITE_E5();
			default :
				p->flip_WHITE_E6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000002040000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000002040000ULL:
				p->flip_WHITE_G5();
			default :
				p->flip_WHITE_F6();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000004020100000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004020100000ULL:
				p->flip_WHITE_B4();
			case 0X0000000020100000ULL:
				p->flip_WHITE_C5();
			default :
				p->flip_WHITE_D6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000600ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000600ULL:
				p->flip_WHITE_G7();
			default :
				p->flip_WHITE_F7();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000007000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007000ULL:
				p->flip_WHITE_B7();
			case 0X0000000000003000ULL:
				p->flip_WHITE_C7();
			default :
				p->flip_WHITE_D7();
		}


}

void RXBBPatterns::update_patterns_WHITE_F7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_F7();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0004040404040000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040404040000ULL:
				p->flip_WHITE_F2();
			case 0X0000040404040000ULL:
				p->flip_WHITE_F3();
			case 0X0000000404040000ULL:
				p->flip_WHITE_F4();
			case 0X0000000004040000ULL:
				p->flip_WHITE_F5();
			default :
				p->flip_WHITE_F6();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000000020000ULL;
	if(flipped)
		p->flip_WHITE_G6();

	/* direction NW */
	flipped = move.flipped & 0X0000402010080000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000402010080000ULL:
				p->flip_WHITE_B3();
			case 0X0000002010080000ULL:
				p->flip_WHITE_C4();
			case 0X0000000010080000ULL:
				p->flip_WHITE_D5();
			default :
				p->flip_WHITE_E6();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_WHITE_G7();

	/* direction _W */
	flipped = move.flipped & 0X0000000000007800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007800ULL:
				p->flip_WHITE_B7();
			case 0X0000000000003800ULL:
				p->flip_WHITE_C7();
			case 0X0000000000001800ULL:
				p->flip_WHITE_D7();
			default :
				p->flip_WHITE_E7();
		}


}

void RXBBPatterns::update_patterns_WHITE_G7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_G7();

	/* direction NW */
	unsigned long long flipped = move.flipped & 0X0040201008040000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040201008040000ULL:
				p->flip_WHITE_B2();
			case 0X0000201008040000ULL:
				p->flip_WHITE_C3();
			case 0X0000001008040000ULL:
				p->flip_WHITE_D4();
			case 0X0000000008040000ULL:
				p->flip_WHITE_E5();
			default :
				p->flip_WHITE_F6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002020202020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020202020000ULL:
				p->flip_WHITE_G2();
			case 0X0000020202020000ULL:
				p->flip_WHITE_G3();
			case 0X0000000202020000ULL:
				p->flip_WHITE_G4();
			case 0X0000000002020000ULL:
				p->flip_WHITE_G5();
			default :
				p->flip_WHITE_G6();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000007C00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007C00ULL:
				p->flip_WHITE_B7();
			case 0X0000000000003C00ULL:
				p->flip_WHITE_C7();
			case 0X0000000000001C00ULL:
				p->flip_WHITE_D7();
			case 0X0000000000000C00ULL:
				p->flip_WHITE_E7();
			default :
				p->flip_WHITE_F7();
		}


}

void RXBBPatterns::update_patterns_WHITE_H7(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_H7();

	/* direction NW */
	unsigned long long flipped = move.flipped & 0X0020100804020000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020100804020000ULL:
				p->flip_WHITE_C2();
			case 0X0000100804020000ULL:
				p->flip_WHITE_D3();
			case 0X0000000804020000ULL:
				p->flip_WHITE_E4();
			case 0X0000000004020000ULL:
				p->flip_WHITE_F5();
			default :
				p->flip_WHITE_G6();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001010101010000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010101010000ULL:
				p->flip_WHITE_H2();
			case 0X0000010101010000ULL:
				p->flip_WHITE_H3();
			case 0X0000000101010000ULL:
				p->flip_WHITE_H4();
			case 0X0000000001010000ULL:
				p->flip_WHITE_H5();
			default :
				p->flip_WHITE_H6();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000007E00ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000007E00ULL:
				p->flip_WHITE_B7();
			case 0X0000000000003E00ULL:
				p->flip_WHITE_C7();
			case 0X0000000000001E00ULL:
				p->flip_WHITE_D7();
			case 0X0000000000000E00ULL:
				p->flip_WHITE_E7();
			case 0X0000000000000600ULL:
				p->flip_WHITE_F7();
			default :
				p->flip_WHITE_G7();
		}


}

void RXBBPatterns::update_patterns_WHITE_A8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_A8();

	/* direction NE */
	unsigned long long flipped = move.flipped & 0X0002040810204000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002040810204000ULL:
				p->flip_WHITE_G2();
			case 0X0000040810204000ULL:
				p->flip_WHITE_F3();
			case 0X0000000810204000ULL:
				p->flip_WHITE_E4();
			case 0X0000000010204000ULL:
				p->flip_WHITE_D5();
			case 0X0000000000204000ULL:
				p->flip_WHITE_C6();
			default :
				p->flip_WHITE_B7();
		}


	/* direction _N */
	flipped = move.flipped & 0X0080808080808000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0080808080808000ULL:
				p->flip_WHITE_A2();
			case 0X0000808080808000ULL:
				p->flip_WHITE_A3();
			case 0X0000008080808000ULL:
				p->flip_WHITE_A4();
			case 0X0000000080808000ULL:
				p->flip_WHITE_A5();
			case 0X0000000000808000ULL:
				p->flip_WHITE_A6();
			default :
				p->flip_WHITE_A7();
		}


	/* direction _E */
	flipped = move.flipped & 0X000000000000007EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000007EULL:
				p->flip_WHITE_G8();
			case 0X000000000000007CULL:
				p->flip_WHITE_F8();
			case 0X0000000000000078ULL:
				p->flip_WHITE_E8();
			case 0X0000000000000070ULL:
				p->flip_WHITE_D8();
			case 0X0000000000000060ULL:
				p->flip_WHITE_C8();
			default :
				p->flip_WHITE_B8();
		}


}

void RXBBPatterns::update_patterns_WHITE_B8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_B8();

	/* direction NE */
	unsigned long long flipped = move.flipped & 0X0000020408102000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000020408102000ULL:
				p->flip_WHITE_G3();
			case 0X0000000408102000ULL:
				p->flip_WHITE_F4();
			case 0X0000000008102000ULL:
				p->flip_WHITE_E5();
			case 0X0000000000102000ULL:
				p->flip_WHITE_D6();
			default :
				p->flip_WHITE_C7();
		}


	/* direction _N */
	flipped = move.flipped & 0X0040404040404000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040404040404000ULL:
				p->flip_WHITE_B2();
			case 0X0000404040404000ULL:
				p->flip_WHITE_B3();
			case 0X0000004040404000ULL:
				p->flip_WHITE_B4();
			case 0X0000000040404000ULL:
				p->flip_WHITE_B5();
			case 0X0000000000404000ULL:
				p->flip_WHITE_B6();
			default :
				p->flip_WHITE_B7();
		}


	/* direction _E */
	flipped = move.flipped & 0X000000000000003EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000003EULL:
				p->flip_WHITE_G8();
			case 0X000000000000003CULL:
				p->flip_WHITE_F8();
			case 0X0000000000000038ULL:
				p->flip_WHITE_E8();
			case 0X0000000000000030ULL:
				p->flip_WHITE_D8();
			default :
				p->flip_WHITE_C8();
		}


}

void RXBBPatterns::update_patterns_WHITE_C8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_C8();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0020202020202000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0020202020202000ULL:
				p->flip_WHITE_C2();
			case 0X0000202020202000ULL:
				p->flip_WHITE_C3();
			case 0X0000002020202000ULL:
				p->flip_WHITE_C4();
			case 0X0000000020202000ULL:
				p->flip_WHITE_C5();
			case 0X0000000000202000ULL:
				p->flip_WHITE_C6();
			default :
				p->flip_WHITE_C7();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000204081000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000204081000ULL:
				p->flip_WHITE_G4();
			case 0X0000000004081000ULL:
				p->flip_WHITE_F5();
			case 0X0000000000081000ULL:
				p->flip_WHITE_E6();
			default :
				p->flip_WHITE_D7();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000000004000ULL;
	if(flipped)
		p->flip_WHITE_B7();

	/* direction _E */
	flipped = move.flipped & 0X000000000000001EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000001EULL:
				p->flip_WHITE_G8();
			case 0X000000000000001CULL:
				p->flip_WHITE_F8();
			case 0X0000000000000018ULL:
				p->flip_WHITE_E8();
			default :
				p->flip_WHITE_D8();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000000040ULL;
	if(flipped)
		p->flip_WHITE_B8();

}

void RXBBPatterns::update_patterns_WHITE_D8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_D8();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0010101010101000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0010101010101000ULL:
				p->flip_WHITE_D2();
			case 0X0000101010101000ULL:
				p->flip_WHITE_D3();
			case 0X0000001010101000ULL:
				p->flip_WHITE_D4();
			case 0X0000000010101000ULL:
				p->flip_WHITE_D5();
			case 0X0000000000101000ULL:
				p->flip_WHITE_D6();
			default :
				p->flip_WHITE_D7();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000002040800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000002040800ULL:
				p->flip_WHITE_G5();
			case 0X0000000000040800ULL:
				p->flip_WHITE_F6();
			default :
				p->flip_WHITE_E7();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000000402000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000402000ULL:
				p->flip_WHITE_B6();
			default :
				p->flip_WHITE_C7();
		}


	/* direction _E */
	flipped = move.flipped & 0X000000000000000EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000000EULL:
				p->flip_WHITE_G8();
			case 0X000000000000000CULL:
				p->flip_WHITE_F8();
			default :
				p->flip_WHITE_E8();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000000060ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000060ULL:
				p->flip_WHITE_B8();
			default :
				p->flip_WHITE_C8();
		}


}

void RXBBPatterns::update_patterns_WHITE_E8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_E8();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0008080808080800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0008080808080800ULL:
				p->flip_WHITE_E2();
			case 0X0000080808080800ULL:
				p->flip_WHITE_E3();
			case 0X0000000808080800ULL:
				p->flip_WHITE_E4();
			case 0X0000000008080800ULL:
				p->flip_WHITE_E5();
			case 0X0000000000080800ULL:
				p->flip_WHITE_E6();
			default :
				p->flip_WHITE_E7();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000000020400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000020400ULL:
				p->flip_WHITE_G6();
			default :
				p->flip_WHITE_F7();
		}


	/* direction NW */
	flipped = move.flipped & 0X0000000040201000ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000040201000ULL:
				p->flip_WHITE_B5();
			case 0X0000000000201000ULL:
				p->flip_WHITE_C6();
			default :
				p->flip_WHITE_D7();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000006ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000006ULL:
				p->flip_WHITE_G8();
			default :
				p->flip_WHITE_F8();
		}


	/* direction _W */
	flipped = move.flipped & 0X0000000000000070ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000070ULL:
				p->flip_WHITE_B8();
			case 0X0000000000000030ULL:
				p->flip_WHITE_C8();
			default :
				p->flip_WHITE_D8();
		}


}

void RXBBPatterns::update_patterns_WHITE_F8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_F8();

	/* direction _N */
	unsigned long long flipped = move.flipped & 0X0004040404040400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0004040404040400ULL:
				p->flip_WHITE_F2();
			case 0X0000040404040400ULL:
				p->flip_WHITE_F3();
			case 0X0000000404040400ULL:
				p->flip_WHITE_F4();
			case 0X0000000004040400ULL:
				p->flip_WHITE_F5();
			case 0X0000000000040400ULL:
				p->flip_WHITE_F6();
			default :
				p->flip_WHITE_F7();
		}


	/* direction NE */
	flipped = move.flipped & 0X0000000000000200ULL;
	if(flipped)
		p->flip_WHITE_G7();

	/* direction NW */
	flipped = move.flipped & 0X0000004020100800ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000004020100800ULL:
				p->flip_WHITE_B4();
			case 0X0000000020100800ULL:
				p->flip_WHITE_C5();
			case 0X0000000000100800ULL:
				p->flip_WHITE_D6();
			default :
				p->flip_WHITE_E7();
		}


	/* direction _E */
	flipped = move.flipped & 0X0000000000000002ULL;
	if(flipped)
		p->flip_WHITE_G8();

	/* direction _W */
	flipped = move.flipped & 0X0000000000000078ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000000000000078ULL:
				p->flip_WHITE_B8();
			case 0X0000000000000038ULL:
				p->flip_WHITE_C8();
			case 0X0000000000000018ULL:
				p->flip_WHITE_D8();
			default :
				p->flip_WHITE_E8();
		}


}

void RXBBPatterns::update_patterns_WHITE_G8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_G8();

	/* direction NW */
	unsigned long long flipped = move.flipped & 0X0000402010080400ULL;
	if(flipped)
		switch(flipped) {
			case 0X0000402010080400ULL:
				p->flip_WHITE_B3();
			case 0X0000002010080400ULL:
				p->flip_WHITE_C4();
			case 0X0000000010080400ULL:
				p->flip_WHITE_D5();
			case 0X0000000000080400ULL:
				p->flip_WHITE_E6();
			default :
				p->flip_WHITE_F7();
		}


	/* direction _N */
	flipped = move.flipped & 0X0002020202020200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0002020202020200ULL:
				p->flip_WHITE_G2();
			case 0X0000020202020200ULL:
				p->flip_WHITE_G3();
			case 0X0000000202020200ULL:
				p->flip_WHITE_G4();
			case 0X0000000002020200ULL:
				p->flip_WHITE_G5();
			case 0X0000000000020200ULL:
				p->flip_WHITE_G6();
			default :
				p->flip_WHITE_G7();
		}


	/* direction _W */
	flipped = move.flipped & 0X000000000000007CULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000007CULL:
				p->flip_WHITE_B8();
			case 0X000000000000003CULL:
				p->flip_WHITE_C8();
			case 0X000000000000001CULL:
				p->flip_WHITE_D8();
			case 0X000000000000000CULL:
				p->flip_WHITE_E8();
			default :
				p->flip_WHITE_F8();
		}


}

void RXBBPatterns::update_patterns_WHITE_H8(RXMove& move) const {

	
	RXPattern* const p = move.pattern;
	move.undo_pattern = pattern;

	memcpy(p, pattern, sizeof(RXPattern));

	p->set_WHITE_H8();

	/* direction NW */
	unsigned long long flipped = move.flipped & 0X0040201008040200ULL;
	if(flipped)
		switch(flipped) {
			case 0X0040201008040200ULL:
				p->flip_WHITE_B2();
			case 0X0000201008040200ULL:
				p->flip_WHITE_C3();
			case 0X0000001008040200ULL:
				p->flip_WHITE_D4();
			case 0X0000000008040200ULL:
				p->flip_WHITE_E5();
			case 0X0000000000040200ULL:
				p->flip_WHITE_F6();
			default :
				p->flip_WHITE_G7();
		}


	/* direction _N */
	flipped = move.flipped & 0X0001010101010100ULL;
	if(flipped)
		switch(flipped) {
			case 0X0001010101010100ULL:
				p->flip_WHITE_H2();
			case 0X0000010101010100ULL:
				p->flip_WHITE_H3();
			case 0X0000000101010100ULL:
				p->flip_WHITE_H4();
			case 0X0000000001010100ULL:
				p->flip_WHITE_H5();
			case 0X0000000000010100ULL:
				p->flip_WHITE_H6();
			default :
				p->flip_WHITE_H7();
		}


	/* direction _W */
	flipped = move.flipped & 0X000000000000007EULL;
	if(flipped)
		switch(flipped) {
			case 0X000000000000007EULL:
				p->flip_WHITE_B8();
			case 0X000000000000003EULL:
				p->flip_WHITE_C8();
			case 0X000000000000001EULL:
				p->flip_WHITE_D8();
			case 0X000000000000000EULL:
				p->flip_WHITE_E8();
			case 0X0000000000000006ULL:
				p->flip_WHITE_F8();
			default :
				p->flip_WHITE_G8();
		}


}



void RXBBPatterns::init_update_patterns() {

	update_patterns[A1][BLACK] = &RXBBPatterns::update_patterns_BLACK_A1;
	update_patterns[A2][BLACK] = &RXBBPatterns::update_patterns_BLACK_A2;
	update_patterns[A3][BLACK] = &RXBBPatterns::update_patterns_BLACK_A3;
	update_patterns[A4][BLACK] = &RXBBPatterns::update_patterns_BLACK_A4;
	update_patterns[A5][BLACK] = &RXBBPatterns::update_patterns_BLACK_A5;
	update_patterns[A6][BLACK] = &RXBBPatterns::update_patterns_BLACK_A6;
	update_patterns[A7][BLACK] = &RXBBPatterns::update_patterns_BLACK_A7;
	update_patterns[A8][BLACK] = &RXBBPatterns::update_patterns_BLACK_A8;

	update_patterns[B1][BLACK] = &RXBBPatterns::update_patterns_BLACK_B1;
	update_patterns[B2][BLACK] = &RXBBPatterns::update_patterns_BLACK_B2;
	update_patterns[B3][BLACK] = &RXBBPatterns::update_patterns_BLACK_B3;
	update_patterns[B4][BLACK] = &RXBBPatterns::update_patterns_BLACK_B4;
	update_patterns[B5][BLACK] = &RXBBPatterns::update_patterns_BLACK_B5;
	update_patterns[B6][BLACK] = &RXBBPatterns::update_patterns_BLACK_B6;
	update_patterns[B7][BLACK] = &RXBBPatterns::update_patterns_BLACK_B7;
	update_patterns[B8][BLACK] = &RXBBPatterns::update_patterns_BLACK_B8;
	
	update_patterns[C1][BLACK] = &RXBBPatterns::update_patterns_BLACK_C1;
	update_patterns[C2][BLACK] = &RXBBPatterns::update_patterns_BLACK_C2;
	update_patterns[C3][BLACK] = &RXBBPatterns::update_patterns_BLACK_C3;
	update_patterns[C4][BLACK] = &RXBBPatterns::update_patterns_BLACK_C4;
	update_patterns[C5][BLACK] = &RXBBPatterns::update_patterns_BLACK_C5;
	update_patterns[C6][BLACK] = &RXBBPatterns::update_patterns_BLACK_C6;
	update_patterns[C7][BLACK] = &RXBBPatterns::update_patterns_BLACK_C7;
	update_patterns[C8][BLACK] = &RXBBPatterns::update_patterns_BLACK_C8;
	
	update_patterns[D1][BLACK] = &RXBBPatterns::update_patterns_BLACK_D1;
	update_patterns[D2][BLACK] = &RXBBPatterns::update_patterns_BLACK_D2;
	update_patterns[D3][BLACK] = &RXBBPatterns::update_patterns_BLACK_D3;
	update_patterns[D6][BLACK] = &RXBBPatterns::update_patterns_BLACK_D6;
	update_patterns[D7][BLACK] = &RXBBPatterns::update_patterns_BLACK_D7;
	update_patterns[D8][BLACK] = &RXBBPatterns::update_patterns_BLACK_D8;

	update_patterns[E1][BLACK] = &RXBBPatterns::update_patterns_BLACK_E1;
	update_patterns[E2][BLACK] = &RXBBPatterns::update_patterns_BLACK_E2;
	update_patterns[E3][BLACK] = &RXBBPatterns::update_patterns_BLACK_E3;
	update_patterns[E6][BLACK] = &RXBBPatterns::update_patterns_BLACK_E6;
	update_patterns[E7][BLACK] = &RXBBPatterns::update_patterns_BLACK_E7;
	update_patterns[E8][BLACK] = &RXBBPatterns::update_patterns_BLACK_E8;

	update_patterns[F1][BLACK] = &RXBBPatterns::update_patterns_BLACK_F1;
	update_patterns[F2][BLACK] = &RXBBPatterns::update_patterns_BLACK_F2;
	update_patterns[F3][BLACK] = &RXBBPatterns::update_patterns_BLACK_F3;
	update_patterns[F4][BLACK] = &RXBBPatterns::update_patterns_BLACK_F4;
	update_patterns[F5][BLACK] = &RXBBPatterns::update_patterns_BLACK_F5;
	update_patterns[F6][BLACK] = &RXBBPatterns::update_patterns_BLACK_F6;
	update_patterns[F7][BLACK] = &RXBBPatterns::update_patterns_BLACK_F7;
	update_patterns[F8][BLACK] = &RXBBPatterns::update_patterns_BLACK_F8;

	update_patterns[G1][BLACK] = &RXBBPatterns::update_patterns_BLACK_G1;
	update_patterns[G2][BLACK] = &RXBBPatterns::update_patterns_BLACK_G2;
	update_patterns[G3][BLACK] = &RXBBPatterns::update_patterns_BLACK_G3;
	update_patterns[G4][BLACK] = &RXBBPatterns::update_patterns_BLACK_G4;
	update_patterns[G5][BLACK] = &RXBBPatterns::update_patterns_BLACK_G5;
	update_patterns[G6][BLACK] = &RXBBPatterns::update_patterns_BLACK_G6;
	update_patterns[G7][BLACK] = &RXBBPatterns::update_patterns_BLACK_G7;
	update_patterns[G8][BLACK] = &RXBBPatterns::update_patterns_BLACK_G8;

	update_patterns[H1][BLACK] = &RXBBPatterns::update_patterns_BLACK_H1;
	update_patterns[H2][BLACK] = &RXBBPatterns::update_patterns_BLACK_H2;
	update_patterns[H3][BLACK] = &RXBBPatterns::update_patterns_BLACK_H3;
	update_patterns[H4][BLACK] = &RXBBPatterns::update_patterns_BLACK_H4;
	update_patterns[H5][BLACK] = &RXBBPatterns::update_patterns_BLACK_H5;
	update_patterns[H6][BLACK] = &RXBBPatterns::update_patterns_BLACK_H6;
	update_patterns[H7][BLACK] = &RXBBPatterns::update_patterns_BLACK_H7;
	update_patterns[H8][BLACK] = &RXBBPatterns::update_patterns_BLACK_H8;

	update_patterns[A1][WHITE] = &RXBBPatterns::update_patterns_WHITE_A1;
	update_patterns[A2][WHITE] = &RXBBPatterns::update_patterns_WHITE_A2;
	update_patterns[A3][WHITE] = &RXBBPatterns::update_patterns_WHITE_A3;
	update_patterns[A4][WHITE] = &RXBBPatterns::update_patterns_WHITE_A4;
	update_patterns[A5][WHITE] = &RXBBPatterns::update_patterns_WHITE_A5;
	update_patterns[A6][WHITE] = &RXBBPatterns::update_patterns_WHITE_A6;
	update_patterns[A7][WHITE] = &RXBBPatterns::update_patterns_WHITE_A7;
	update_patterns[A8][WHITE] = &RXBBPatterns::update_patterns_WHITE_A8;

	update_patterns[B1][WHITE] = &RXBBPatterns::update_patterns_WHITE_B1;
	update_patterns[B2][WHITE] = &RXBBPatterns::update_patterns_WHITE_B2;
	update_patterns[B3][WHITE] = &RXBBPatterns::update_patterns_WHITE_B3;
	update_patterns[B4][WHITE] = &RXBBPatterns::update_patterns_WHITE_B4;
	update_patterns[B5][WHITE] = &RXBBPatterns::update_patterns_WHITE_B5;
	update_patterns[B6][WHITE] = &RXBBPatterns::update_patterns_WHITE_B6;
	update_patterns[B7][WHITE] = &RXBBPatterns::update_patterns_WHITE_B7;
	update_patterns[B8][WHITE] = &RXBBPatterns::update_patterns_WHITE_B8;
	
	update_patterns[C1][WHITE] = &RXBBPatterns::update_patterns_WHITE_C1;
	update_patterns[C2][WHITE] = &RXBBPatterns::update_patterns_WHITE_C2;
	update_patterns[C3][WHITE] = &RXBBPatterns::update_patterns_WHITE_C3;
	update_patterns[C4][WHITE] = &RXBBPatterns::update_patterns_WHITE_C4;
	update_patterns[C5][WHITE] = &RXBBPatterns::update_patterns_WHITE_C5;
	update_patterns[C6][WHITE] = &RXBBPatterns::update_patterns_WHITE_C6;
	update_patterns[C7][WHITE] = &RXBBPatterns::update_patterns_WHITE_C7;
	update_patterns[C8][WHITE] = &RXBBPatterns::update_patterns_WHITE_C8;
	
	update_patterns[D1][WHITE] = &RXBBPatterns::update_patterns_WHITE_D1;
	update_patterns[D2][WHITE] = &RXBBPatterns::update_patterns_WHITE_D2;
	update_patterns[D3][WHITE] = &RXBBPatterns::update_patterns_WHITE_D3;
	update_patterns[D6][WHITE] = &RXBBPatterns::update_patterns_WHITE_D6;
	update_patterns[D7][WHITE] = &RXBBPatterns::update_patterns_WHITE_D7;
	update_patterns[D8][WHITE] = &RXBBPatterns::update_patterns_WHITE_D8;

	update_patterns[E1][WHITE] = &RXBBPatterns::update_patterns_WHITE_E1;
	update_patterns[E2][WHITE] = &RXBBPatterns::update_patterns_WHITE_E2;
	update_patterns[E3][WHITE] = &RXBBPatterns::update_patterns_WHITE_E3;
	update_patterns[E6][WHITE] = &RXBBPatterns::update_patterns_WHITE_E6;
	update_patterns[E7][WHITE] = &RXBBPatterns::update_patterns_WHITE_E7;
	update_patterns[E8][WHITE] = &RXBBPatterns::update_patterns_WHITE_E8;

	update_patterns[F1][WHITE] = &RXBBPatterns::update_patterns_WHITE_F1;
	update_patterns[F2][WHITE] = &RXBBPatterns::update_patterns_WHITE_F2;
	update_patterns[F3][WHITE] = &RXBBPatterns::update_patterns_WHITE_F3;
	update_patterns[F4][WHITE] = &RXBBPatterns::update_patterns_WHITE_F4;
	update_patterns[F5][WHITE] = &RXBBPatterns::update_patterns_WHITE_F5;
	update_patterns[F6][WHITE] = &RXBBPatterns::update_patterns_WHITE_F6;
	update_patterns[F7][WHITE] = &RXBBPatterns::update_patterns_WHITE_F7;
	update_patterns[F8][WHITE] = &RXBBPatterns::update_patterns_WHITE_F8;

	update_patterns[G1][WHITE] = &RXBBPatterns::update_patterns_WHITE_G1;
	update_patterns[G2][WHITE] = &RXBBPatterns::update_patterns_WHITE_G2;
	update_patterns[G3][WHITE] = &RXBBPatterns::update_patterns_WHITE_G3;
	update_patterns[G4][WHITE] = &RXBBPatterns::update_patterns_WHITE_G4;
	update_patterns[G5][WHITE] = &RXBBPatterns::update_patterns_WHITE_G5;
	update_patterns[G6][WHITE] = &RXBBPatterns::update_patterns_WHITE_G6;
	update_patterns[G7][WHITE] = &RXBBPatterns::update_patterns_WHITE_G7;
	update_patterns[G8][WHITE] = &RXBBPatterns::update_patterns_WHITE_G8;

	update_patterns[H1][WHITE] = &RXBBPatterns::update_patterns_WHITE_H1;
	update_patterns[H2][WHITE] = &RXBBPatterns::update_patterns_WHITE_H2;
	update_patterns[H3][WHITE] = &RXBBPatterns::update_patterns_WHITE_H3;
	update_patterns[H4][WHITE] = &RXBBPatterns::update_patterns_WHITE_H4;
	update_patterns[H5][WHITE] = &RXBBPatterns::update_patterns_WHITE_H5;
	update_patterns[H6][WHITE] = &RXBBPatterns::update_patterns_WHITE_H6;
	update_patterns[H7][WHITE] = &RXBBPatterns::update_patterns_WHITE_H7;
	update_patterns[H8][WHITE] = &RXBBPatterns::update_patterns_WHITE_H8;

}


