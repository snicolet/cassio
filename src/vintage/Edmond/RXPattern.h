/*
 *  RXPattern.h
 *  Roxane
 *
 *  Created by Bruno Causse on 20/09/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef RXPATTERN_H
#define RXPATTERN_H

class RXPattern {

	public:
	//data 128 bytes (align)
	
		unsigned short diag_5a;
		unsigned short diag_5b;
		unsigned short diag_5c;
		unsigned short diag_5d;

		unsigned short diag_6a;
		unsigned short diag_6b;
		unsigned short diag_6c;
		unsigned short diag_6d;

		unsigned short diag_7a;
		unsigned short diag_7b;
		unsigned short diag_7c;
		unsigned short diag_7d;

		unsigned short diag_8a;
		unsigned short diag_8b;
		unsigned short reverved_a;
		unsigned short reverved_b;

		unsigned short hv_4a;
		unsigned short hv_4b;
		unsigned short hv_4c;
		unsigned short hv_4d;

		unsigned short hv_3a;
		unsigned short hv_3b;
		unsigned short hv_3c;
		unsigned short hv_3d;

		unsigned short hv_2a;
		unsigned short hv_2b;
		unsigned short hv_2c;
		unsigned short hv_2d;

		unsigned short corner2x5a;
		unsigned short corner2x5b;
		unsigned short corner2x5c;
		unsigned short corner2x5d;
		unsigned short corner2x5e;
		unsigned short corner2x5f;
		unsigned short corner2x5g;
		unsigned short corner2x5h;

		unsigned short edge64a;
		unsigned short edge64b;
		unsigned short edge64c;
		unsigned short edge64d;

		unsigned int corner11a;
		unsigned int corner11b;
		unsigned int corner11c;
		unsigned int corner11d;

		unsigned int edge2XCa;
		unsigned int edge2XCb;
		unsigned int edge2XCc;
		unsigned int edge2XCd;

		unsigned int reverved_1;
		unsigned int reverved_2;
		unsigned int reverved_3;
		unsigned int reverved_4;
		

	//set Black disc
		 void set_BLACK_A1();  void set_BLACK_B1();  void set_BLACK_C1();  void set_BLACK_D1();  void set_BLACK_E1();  void set_BLACK_F1();  void set_BLACK_G1();  void set_BLACK_H1();
		 void set_BLACK_A2();  void set_BLACK_B2();  void set_BLACK_C2();  void set_BLACK_D2();  void set_BLACK_E2();  void set_BLACK_F2();  void set_BLACK_G2();  void set_BLACK_H2();
		 void set_BLACK_A3();  void set_BLACK_B3();  void set_BLACK_C3();  void set_BLACK_D3();  void set_BLACK_E3();  void set_BLACK_F3();  void set_BLACK_G3();  void set_BLACK_H3();
		 void set_BLACK_A4();  void set_BLACK_B4();  void set_BLACK_C4();  void set_BLACK_D4();  void set_BLACK_E4();  void set_BLACK_F4();  void set_BLACK_G4();  void set_BLACK_H4();
		 void set_BLACK_A5();  void set_BLACK_B5();  void set_BLACK_C5();  void set_BLACK_D5();  void set_BLACK_E5();  void set_BLACK_F5();  void set_BLACK_G5();  void set_BLACK_H5();
		 void set_BLACK_A6();  void set_BLACK_B6();  void set_BLACK_C6();  void set_BLACK_D6();  void set_BLACK_E6();  void set_BLACK_F6();  void set_BLACK_G6();  void set_BLACK_H6();
		 void set_BLACK_A7();  void set_BLACK_B7();  void set_BLACK_C7();  void set_BLACK_D7();  void set_BLACK_E7();  void set_BLACK_F7();  void set_BLACK_G7();  void set_BLACK_H7();
		 void set_BLACK_A8();  void set_BLACK_B8();  void set_BLACK_C8();  void set_BLACK_D8();  void set_BLACK_E8();  void set_BLACK_F8();  void set_BLACK_G8();  void set_BLACK_H8();

	//set White disc
		 void set_WHITE_A1();  void set_WHITE_B1();  void set_WHITE_C1();  void set_WHITE_D1();  void set_WHITE_E1();  void set_WHITE_F1();  void set_WHITE_G1();  void set_WHITE_H1();
		 void set_WHITE_A2();  void set_WHITE_B2();  void set_WHITE_C2();  void set_WHITE_D2();  void set_WHITE_E2();  void set_WHITE_F2();  void set_WHITE_G2();  void set_WHITE_H2();
		 void set_WHITE_A3();  void set_WHITE_B3();  void set_WHITE_C3();  void set_WHITE_D3();  void set_WHITE_E3();  void set_WHITE_F3();  void set_WHITE_G3();  void set_WHITE_H3();
		 void set_WHITE_A4();  void set_WHITE_B4();  void set_WHITE_C4();  void set_WHITE_D4();  void set_WHITE_E4();  void set_WHITE_F4();  void set_WHITE_G4();  void set_WHITE_H4();
		 void set_WHITE_A5();  void set_WHITE_B5();  void set_WHITE_C5();  void set_WHITE_D5();  void set_WHITE_E5();  void set_WHITE_F5();  void set_WHITE_G5();  void set_WHITE_H5();
		 void set_WHITE_A6();  void set_WHITE_B6();  void set_WHITE_C6();  void set_WHITE_D6();  void set_WHITE_E6();  void set_WHITE_F6();  void set_WHITE_G6();  void set_WHITE_H6();
		 void set_WHITE_A7();  void set_WHITE_B7();  void set_WHITE_C7();  void set_WHITE_D7();  void set_WHITE_E7();  void set_WHITE_F7();  void set_WHITE_G7();  void set_WHITE_H7();
		 void set_WHITE_A8();  void set_WHITE_B8();  void set_WHITE_C8();  void set_WHITE_D8();  void set_WHITE_E8();  void set_WHITE_F8();  void set_WHITE_G8();  void set_WHITE_H8();

	//flip Black disc
								void flip_BLACK_B1();  void flip_BLACK_C1();  void flip_BLACK_D1();  void flip_BLACK_E1();  void flip_BLACK_F1();  void flip_BLACK_G1();
		 void flip_BLACK_A2();  void flip_BLACK_B2();  void flip_BLACK_C2();  void flip_BLACK_D2();  void flip_BLACK_E2();  void flip_BLACK_F2();  void flip_BLACK_G2();  void flip_BLACK_H2();
		 void flip_BLACK_A3();  void flip_BLACK_B3();  void flip_BLACK_C3();  void flip_BLACK_D3();  void flip_BLACK_E3();  void flip_BLACK_F3();  void flip_BLACK_G3();  void flip_BLACK_H3();
		 void flip_BLACK_A4();  void flip_BLACK_B4();  void flip_BLACK_C4();  void flip_BLACK_D4();  void flip_BLACK_E4();  void flip_BLACK_F4();  void flip_BLACK_G4();  void flip_BLACK_H4();
		 void flip_BLACK_A5();  void flip_BLACK_B5();  void flip_BLACK_C5();  void flip_BLACK_D5();  void flip_BLACK_E5();  void flip_BLACK_F5();  void flip_BLACK_G5();  void flip_BLACK_H5();
		 void flip_BLACK_A6();  void flip_BLACK_B6();  void flip_BLACK_C6();  void flip_BLACK_D6();  void flip_BLACK_E6();  void flip_BLACK_F6();  void flip_BLACK_G6();  void flip_BLACK_H6();
		 void flip_BLACK_A7();  void flip_BLACK_B7();  void flip_BLACK_C7();  void flip_BLACK_D7();  void flip_BLACK_E7();  void flip_BLACK_F7();  void flip_BLACK_G7();  void flip_BLACK_H7();
								void flip_BLACK_B8();  void flip_BLACK_C8();  void flip_BLACK_D8();  void flip_BLACK_E8();  void flip_BLACK_F8();  void flip_BLACK_G8();

	//flip White disc
								void flip_WHITE_B1();  void flip_WHITE_C1();  void flip_WHITE_D1();  void flip_WHITE_E1();  void flip_WHITE_F1();  void flip_WHITE_G1();
		 void flip_WHITE_A2();  void flip_WHITE_B2();  void flip_WHITE_C2();  void flip_WHITE_D2();  void flip_WHITE_E2();  void flip_WHITE_F2();  void flip_WHITE_G2();  void flip_WHITE_H2();
		 void flip_WHITE_A3();  void flip_WHITE_B3();  void flip_WHITE_C3();  void flip_WHITE_D3();  void flip_WHITE_E3();  void flip_WHITE_F3();  void flip_WHITE_G3();  void flip_WHITE_H3();
		 void flip_WHITE_A4();  void flip_WHITE_B4();  void flip_WHITE_C4();  void flip_WHITE_D4();  void flip_WHITE_E4();  void flip_WHITE_F4();  void flip_WHITE_G4();  void flip_WHITE_H4();
		 void flip_WHITE_A5();  void flip_WHITE_B5();  void flip_WHITE_C5();  void flip_WHITE_D5();  void flip_WHITE_E5();  void flip_WHITE_F5();  void flip_WHITE_G5();  void flip_WHITE_H5();
		 void flip_WHITE_A6();  void flip_WHITE_B6();  void flip_WHITE_C6();  void flip_WHITE_D6();  void flip_WHITE_E6();  void flip_WHITE_F6();  void flip_WHITE_G6();  void flip_WHITE_H6();
		 void flip_WHITE_A7();  void flip_WHITE_B7();  void flip_WHITE_C7();  void flip_WHITE_D7();  void flip_WHITE_E7();  void flip_WHITE_F7();  void flip_WHITE_G7();  void flip_WHITE_H7();
								void flip_WHITE_B8();  void flip_WHITE_C8();  void flip_WHITE_D8();  void flip_WHITE_E8();  void flip_WHITE_F8();  void flip_WHITE_G8();
		
		void clear();
	
};
	
inline void RXPattern::clear() {

		diag_5a = 0;
		diag_5b = 0;
		diag_5c = 0;
		diag_5d = 0;

		diag_6a = 0;
		diag_6b = 0;
		diag_6c = 0;
		diag_6d = 0;

		diag_7a = 0;
		diag_7b = 0;
		diag_7c = 0;
		diag_7d = 0;

		diag_8a = 0;
		diag_8b = 0;

		hv_4a = 0;
		hv_4b = 0;
		hv_4c = 0;
		hv_4d = 0;

		hv_3a = 0;
		hv_3b = 0;
		hv_3c = 0;
		hv_3d = 0;

		hv_2a = 0;
		hv_2b = 0;
		hv_2c = 0;
		hv_2d = 0;

		corner2x5a = 0;
		corner2x5b = 0;
		corner2x5c = 0;
		corner2x5d = 0;
		corner2x5e = 0;
		corner2x5f = 0;
		corner2x5g = 0;
		corner2x5h = 0;

		edge64a = 0;
		edge64b = 0;
		edge64c = 0;
		edge64d = 0;

		corner11a = 0;
		corner11b = 0;
		corner11c = 0;
		corner11d = 0;

		edge2XCa = 0;
		edge2XCb = 0;
		edge2XCc = 0;
		edge2XCd = 0;

}

//set Black disc

inline void RXPattern::set_BLACK_A1() {diag_8a  +=    1; corner11a +=   1; corner2x5a +=     1; corner2x5e +=     1; edge2XCa  +=     9; edge2XCd  += 19683;}
inline void RXPattern::set_BLACK_B1() {hv_2a +=    1; diag_7a  +=   1; corner11a  +=     3; corner2x5a +=     3; corner2x5e += 19683; edge2XCa  +=    27; edge64a +=      9; edge2XCd +=  59049;}
inline void RXPattern::set_BLACK_C1() {hv_3a +=    1; diag_6a  +=   1; corner11a  +=     9; corner2x5a +=     9; edge2XCa  +=    81; edge64a  +=    27;}
inline void RXPattern::set_BLACK_D1() {hv_4a +=    1; diag_5a  +=   1; corner11a  +=    27; corner2x5a +=    27; edge2XCa  +=   243; corner2x5f +=    81; edge64a +=     81;}
inline void RXPattern::set_BLACK_E1() {hv_4b += 2187; diag_5d  +=  81; corner2x5a +=    81; corner2x5f +=    27; edge2XCa  +=   729; corner11b  +=  2187; edge64a +=    243;}
inline void RXPattern::set_BLACK_F1() {hv_3b += 2187; diag_6d  += 243; corner11b  +=  6561; corner2x5f +=     9; edge2XCa  +=  2187; edge64a  +=   729;}
inline void RXPattern::set_BLACK_G1() {hv_2b += 2187; diag_7d  += 729; corner11b  += 19683; corner2x5b += 19683; corner2x5f +=     3; edge2XCa  +=  6561; edge64a +=   2187; edge2XCb +=      3;}
inline void RXPattern::set_BLACK_H1() {diag_8b  += 2187; corner11b +=   1; corner2x5b +=     1; corner2x5f +=     1; edge2XCa  += 19683; edge2XCb  +=     9;}

inline void RXPattern::set_BLACK_A2() {hv_2c += 2187; diag_7c  += 729; corner11a  += 19683; corner2x5a += 19683; corner2x5e +=     3; edge2XCd  +=  6561; edge64d +=   2187; edge2XCa +=      3;}
inline void RXPattern::set_BLACK_B2() {hv_2a +=    3; hv_2c += 729; diag_8a   +=     3; corner11a  += 59049; corner2x5a +=  6561; corner2x5e +=  6561; edge2XCa +=      1; edge2XCd += 177147;}
inline void RXPattern::set_BLACK_C2() {hv_3a +=    3; hv_2c += 243; diag_7a   +=     3; corner11a  +=    81; corner2x5a +=  2187; edge64a  +=     3;}
inline void RXPattern::set_BLACK_D2() {hv_4a +=    3; hv_2c +=  81; diag_6a   +=     3; diag_5d   +=    27; corner2x5a +=   729; corner2x5f +=   243; edge64a +=      1;}
inline void RXPattern::set_BLACK_E2() {hv_4b +=  729; hv_2c +=  27; diag_6d   +=    81; diag_5a   +=     3; corner2x5a +=   243; corner2x5f +=   729; edge64a +=  19683;}
inline void RXPattern::set_BLACK_F2() {hv_3b +=  729; hv_2c +=   9; diag_7d   +=   243; corner11b  +=   729; corner2x5f +=  2187; edge64a  +=  6561;}
inline void RXPattern::set_BLACK_G2() {hv_2b +=  729; hv_2c +=   3; diag_8b   +=   729; corner11b  += 59049; corner2x5b +=  6561; corner2x5f +=  6561; edge2XCa += 177147; edge2XCb +=      1;}
inline void RXPattern::set_BLACK_H2() {hv_2c +=    1; diag_7b  +=   1; corner11b  +=     3; corner2x5b +=     3; corner2x5f += 19683; edge2XCb  +=    27; edge64b +=      9; edge2XCa +=  59049;}

inline void RXPattern::set_BLACK_A3() {hv_3c += 2187; diag_6c  += 243; corner11a  += 6561; corner2x5e  +=     9; edge2XCd  +=  2187; edge64d  +=   729;}
inline void RXPattern::set_BLACK_B3() {hv_2a +=    9; hv_3c += 729; diag_7c   +=  243; corner11a   +=   729; corner2x5e +=  2187; edge64d  +=  6561;}
inline void RXPattern::set_BLACK_C3() {hv_3a +=    9; hv_3c += 243; diag_8a   +=    9; diag_5d    +=     9; corner11a  +=   243;}
inline void RXPattern::set_BLACK_D3() {hv_4a +=    9; hv_3c +=  81; diag_7a   +=    9; diag_6d    +=    27;}
inline void RXPattern::set_BLACK_E3() {hv_4b +=  243; hv_3c +=  27; diag_7d   +=   81; diag_6a    +=     9;}
inline void RXPattern::set_BLACK_F3() {hv_3b +=  243; hv_3c +=   9; diag_8b   +=  243; diag_5a    +=     9; corner11b  +=   243;}
inline void RXPattern::set_BLACK_G3() {hv_2b +=  243; hv_3c +=   3; diag_7b   +=    3; corner11b   +=    81; corner2x5b +=  2187; edge64b  +=     3;}
inline void RXPattern::set_BLACK_H3() {hv_3c +=    1; diag_6b  +=   1; corner11b  +=    9; corner2x5b  +=     9; edge2XCb  +=    81; edge64b  +=    27;}

inline void RXPattern::set_BLACK_A4() {hv_4c += 2187; diag_5c  +=  81; corner2x5e +=   27; edge2XCd   +=   729; corner11a  +=  2187; corner2x5d +=    81; edge64d +=    243;}
inline void RXPattern::set_BLACK_B4() {hv_2a +=   27; hv_4c += 729; diag_6c   +=   81; diag_5d    +=     3; corner2x5e +=   729; corner2x5d +=   243; edge64d +=  19683;}
inline void RXPattern::set_BLACK_C4() {hv_3a +=   27; hv_4c += 243; diag_7c   +=   81; diag_6d    +=     9;}
inline void RXPattern::set_BLACK_D4() {hv_4a +=   27; hv_4c +=  81; diag_8a   +=   27; diag_7d    +=    27;}
inline void RXPattern::set_BLACK_E4() {hv_4b +=   81; hv_4c +=  27; diag_8b   +=   81; diag_7a    +=    27;}
inline void RXPattern::set_BLACK_F4() {hv_3b +=   81; hv_4c +=   9; diag_7b   +=    9; diag_6a    +=    27;}
inline void RXPattern::set_BLACK_G4() {hv_2b +=   81; hv_4c +=   3; diag_6b   +=    3; diag_5a    +=    27; corner2x5b +=   729; corner2x5g +=   243; edge64b +=      1;}
inline void RXPattern::set_BLACK_H4() {hv_4c +=    1; diag_5b  +=   1; corner2x5b +=   27; corner2x5g  +=    81; edge2XCb  +=   243; corner11b  +=    27; edge64b +=     81;}

inline void RXPattern::set_BLACK_A5() {hv_4d +=    1; diag_5d  +=   1; corner2x5d +=   27; edge2XCd   +=   243; corner11d  +=    27; corner2x5e +=    81; edge64d +=     81;}
inline void RXPattern::set_BLACK_B5() {hv_2a +=   81; hv_4d +=   3; diag_6d   +=    3; diag_5c    +=    27; corner2x5d +=   729; corner2x5e +=   243; edge64d +=      1;}
inline void RXPattern::set_BLACK_C5() {hv_3a +=   81; hv_4d +=   9; diag_7d   +=    9; diag_6c    +=    27;}
inline void RXPattern::set_BLACK_D5() {hv_4a +=   81; hv_4d +=  27; diag_8b   +=   27; diag_7c    +=    27;}
inline void RXPattern::set_BLACK_E5() {hv_4b +=   27; hv_4d +=  81; diag_8a   +=   81; diag_7b    +=    27;}
inline void RXPattern::set_BLACK_F5() {hv_3b +=   27; hv_4d += 243; diag_7a   +=   81; diag_6b    +=     9;}
inline void RXPattern::set_BLACK_G5() {hv_2b +=   27; hv_4d += 729; diag_6a   +=   81; diag_5b    +=     3; corner2x5g +=   729; corner2x5b +=   243; edge64b +=  19683;}
inline void RXPattern::set_BLACK_H5() {hv_4d += 2187; diag_5a  +=  81; corner2x5g +=   27; edge2XCb   +=   729; corner11c  +=  2187; corner2x5b +=    81; edge64b +=    243;}

inline void RXPattern::set_BLACK_A6() {hv_3d +=    1; diag_6d  +=   1; corner11d  +=    9; corner2x5d  +=     9; edge2XCd  +=    81; edge64d  +=    27;}
inline void RXPattern::set_BLACK_B6() {hv_2a +=  243; hv_3d +=   3; diag_7d   +=    3; corner11d   +=    81; corner2x5d +=  2187; edge64d  +=     3;}
inline void RXPattern::set_BLACK_C6() {hv_3a +=  243; hv_3d +=   9; diag_8b   +=    9; diag_5c    +=     9; corner11d  +=   243;}
inline void RXPattern::set_BLACK_D6() {hv_4a +=  243; hv_3d +=  27; diag_7b   +=   81; diag_6c    +=     9;}
inline void RXPattern::set_BLACK_E6() {hv_4b +=    9; hv_3d +=  81; diag_7c   +=    9; diag_6b    +=    27;}
inline void RXPattern::set_BLACK_F6() {hv_3b +=    9; hv_3d += 243; diag_8a   +=  243; diag_5b    +=     9; corner11c  +=   243;}
inline void RXPattern::set_BLACK_G6() {hv_2b +=    9; hv_3d += 729; diag_7a   +=  243; corner11c   +=   729; corner2x5g +=  2187; edge64b  +=  6561;}
inline void RXPattern::set_BLACK_H6() {hv_3d += 2187; diag_6a  += 243; corner11c  += 6561; corner2x5g  +=     9; edge2XCb  +=  2187; edge64b  +=   729;}

inline void RXPattern::set_BLACK_A7() {hv_2d +=    1; diag_7d  +=   1; corner11d  +=     3; corner2x5d +=     3; corner2x5h += 19683; edge2XCd  +=    27; edge64d +=      9; edge2XCc +=  59049;}
inline void RXPattern::set_BLACK_B7() {hv_2a +=  729; hv_2d +=   3; diag_8b   +=     3; corner11d  += 59049; corner2x5d +=  6561; corner2x5h +=  6561; edge2XCc += 177147; edge2XCd +=      1;}
inline void RXPattern::set_BLACK_C7() {hv_3a +=  729; hv_2d +=   9; diag_7b   +=   243; corner11d  +=   729; corner2x5h +=  2187; edge64c  +=  6561;}
inline void RXPattern::set_BLACK_D7() {hv_4a +=  729; hv_2d +=  27; diag_6b   +=    81; diag_5c   +=     3; corner2x5c +=   243; corner2x5h +=   729; edge64c +=  19683;}
inline void RXPattern::set_BLACK_E7() {hv_4b +=    3; hv_2d +=  81; diag_6c   +=     3; diag_5b   +=    27; corner2x5c +=   729; corner2x5h +=   243; edge64c +=      1;}
inline void RXPattern::set_BLACK_F7() {hv_3b +=    3; hv_2d += 243; diag_7c   +=     3; corner11c  +=    81; corner2x5c +=  2187; edge64c  +=     3; }
inline void RXPattern::set_BLACK_G7() {hv_2b +=    3; hv_2d += 729; diag_8a   +=   729; corner11c  += 59049; corner2x5c +=  6561; corner2x5g +=  6561; edge2XCb += 177147; edge2XCc +=      1;}
inline void RXPattern::set_BLACK_H7() {hv_2d += 2187; diag_7a  += 729; corner11c  += 19683; corner2x5c += 19683; corner2x5g +=     3; edge2XCb  +=  6561; edge64b +=   2187; edge2XCc +=      3;}

inline void RXPattern::set_BLACK_A8() {diag_8b  +=    1; corner11d +=   1; corner2x5d +=     1; corner2x5h +=     1; edge2XCc  += 19683; edge2XCd  +=     9;}
inline void RXPattern::set_BLACK_B8() {hv_2a += 2187; diag_7b  += 729; corner11d  += 19683; corner2x5d += 19683; corner2x5h +=     3; edge2XCc  +=  6561; edge64c +=   2187; edge2XCd +=      3;}
inline void RXPattern::set_BLACK_C8() {hv_3a += 2187; diag_6b  += 243; corner11d  +=  6561; corner2x5h +=     9; edge2XCc  +=  2187; edge64c  +=   729;}
inline void RXPattern::set_BLACK_D8() {hv_4a += 2187; diag_5b  +=  81; corner2x5c +=    81; corner2x5h +=    27; edge2XCc  +=   729; corner11d  +=  2187; edge64c +=    243;}
inline void RXPattern::set_BLACK_E8() {hv_4b +=    1; diag_5c  +=   1; corner11c  +=    27; corner2x5c +=    27; edge2XCc  +=   243; corner2x5h +=    81; edge64c +=     81;}
inline void RXPattern::set_BLACK_F8() {hv_3b +=    1; diag_6c  +=   1; corner11c  +=     9; corner2x5c +=     9; edge2XCc  +=    81; edge64c  +=    27;}
inline void RXPattern::set_BLACK_G8() {hv_2b +=    1; diag_7c  +=   1; corner11c  +=     3; corner2x5c +=     3; corner2x5g += 19683; edge2XCc  +=    27; edge64c +=      9; edge2XCb +=  59049;}
inline void RXPattern::set_BLACK_H8() {diag_8a  += 2187; corner11c +=   1; corner2x5c +=     1; corner2x5g +=     1; edge2XCb  += 19683; edge2XCc  +=     9;}

//set White disc

inline void RXPattern::set_WHITE_A1() {diag_8a  +=    2; corner11a +=    2; corner2x5a +=     2; corner2x5e +=      2; edge2XCa  +=    18; edge2XCd  += 39366;}
inline void RXPattern::set_WHITE_B1() {hv_2a +=    2; diag_7a  +=    2; corner11a  +=     6; corner2x5a +=      6; corner2x5e += 39366; edge2XCa  +=    54; edge64a +=     18; edge2XCd += 118098;}
inline void RXPattern::set_WHITE_C1() {hv_3a +=    2; diag_6a  +=    2; corner11a  +=    18; corner2x5a +=     18; edge2XCa  +=   162; edge64a  +=    54;}
inline void RXPattern::set_WHITE_D1() {hv_4a +=    2; diag_5a  +=    2; corner11a  +=    54; corner2x5a +=     54; edge2XCa  +=   486; corner2x5f +=   162; edge64a +=    162;}
inline void RXPattern::set_WHITE_E1() {hv_4b += 4374; diag_5d  +=  162; corner2x5a +=   162; corner2x5f +=     54; edge2XCa  +=  1458; corner11b  +=  4374; edge64a +=    486;}
inline void RXPattern::set_WHITE_F1() {hv_3b += 4374; diag_6d  +=  486; corner11b  += 13122; corner2x5f +=     18; edge2XCa  +=  4374; edge64a  +=  1458;}
inline void RXPattern::set_WHITE_G1() {hv_2b += 4374; diag_7d  += 1458; corner11b  += 39366; corner2x5b +=  39366; corner2x5f +=     6; edge2XCa  += 13122; edge64a +=   4374; edge2XCb +=      6;}
inline void RXPattern::set_WHITE_H1() {diag_8b  += 4374; corner11b +=    2; corner2x5b +=     2; corner2x5f +=      2; edge2XCa  += 39366; edge2XCb  +=    18;}

inline void RXPattern::set_WHITE_A2() {hv_2c += 4374; diag_7c  += 1458; corner11a  += 39366; corner2x5a +=  39366; corner2x5e +=     6; edge2XCd  += 13122; edge64d +=   4374; edge2XCa +=      6;}
inline void RXPattern::set_WHITE_B2() {hv_2a +=    6; hv_2c += 1458; diag_8a   +=     6; corner11a  += 118098; corner2x5a += 13122; corner2x5e += 13122; edge2XCa +=      2; edge2XCd += 354294;}
inline void RXPattern::set_WHITE_C2() {hv_3a +=    6; hv_2c +=  486; diag_7a   +=     6; corner11a  +=    162; corner2x5a +=  4374; edge64a  +=     6;}
inline void RXPattern::set_WHITE_D2() {hv_4a +=    6; hv_2c +=  162; diag_6a   +=     6; diag_5d   +=     54; corner2x5a +=  1458; corner2x5f +=   486; edge64a +=      2;}
inline void RXPattern::set_WHITE_E2() {hv_4b += 1458; hv_2c +=   54; diag_6d   +=   162; diag_5a   +=      6; corner2x5a +=   486; corner2x5f +=  1458; edge64a +=  39366;}
inline void RXPattern::set_WHITE_F2() {hv_3b += 1458; hv_2c +=   18; diag_7d   +=   486; corner11b  +=   1458; corner2x5f +=  4374; edge64a  += 13122;}
inline void RXPattern::set_WHITE_G2() {hv_2b += 1458; hv_2c +=    6; diag_8b   +=  1458; corner11b  += 118098; corner2x5b += 13122; corner2x5f += 13122; edge2XCa += 354294; edge2XCb +=      2;}
inline void RXPattern::set_WHITE_H2() {hv_2c +=    2; diag_7b  +=    2; corner11b  +=     6; corner2x5b +=      6; corner2x5f += 39366; edge2XCb  +=    54; edge64b +=     18; edge2XCa += 118098;}

inline void RXPattern::set_WHITE_A3() {hv_3c += 4374; diag_6c  +=  486; corner11a  += 13122; corner2x5e +=     18; edge2XCd  +=  4374; edge64d  +=  1458;}
inline void RXPattern::set_WHITE_B3() {hv_2a +=   18; hv_3c += 1458; diag_7c   +=   486; corner11a  +=   1458; corner2x5e +=  4374; edge64d  += 13122;}
inline void RXPattern::set_WHITE_C3() {hv_3a +=   18; hv_3c +=  486; diag_8a   +=    18; diag_5d   +=     18; corner11a  +=   486;}
inline void RXPattern::set_WHITE_D3() {hv_4a +=   18; hv_3c +=  162; diag_7a   +=    18; diag_6d   +=     54;}
inline void RXPattern::set_WHITE_E3() {hv_4b +=  486; hv_3c +=   54; diag_7d   +=   162; diag_6a   +=     18;}
inline void RXPattern::set_WHITE_F3() {hv_3b +=  486; hv_3c +=   18; diag_8b   +=   486; diag_5a   +=     18; corner11b  +=   486;}
inline void RXPattern::set_WHITE_G3() {hv_2b +=  486; hv_3c +=    6; diag_7b   +=     6; corner11b  +=    162; corner2x5b +=  4374; edge64b  +=     6;}
inline void RXPattern::set_WHITE_H3() {hv_3c +=    2; diag_6b  +=    2; corner11b  +=    18; corner2x5b +=     18; edge2XCb  +=   162; edge64b  +=    54;}

inline void RXPattern::set_WHITE_A4() {hv_4c += 4374; diag_5c  +=  162; corner2x5e +=    54; edge2XCd  +=   1458; corner11a  +=  4374; corner2x5d +=   162; edge64d +=    486;}
inline void RXPattern::set_WHITE_B4() {hv_2a +=   54; hv_4c += 1458; diag_6c   +=   162; diag_5d   +=      6; corner2x5e +=  1458; corner2x5d +=   486; edge64d +=  39366;}
inline void RXPattern::set_WHITE_C4() {hv_3a +=   54; hv_4c +=  486; diag_7c   +=   162; diag_6d   +=     18;}
inline void RXPattern::set_WHITE_D4() {hv_4a +=   54; hv_4c +=  162; diag_8a   +=    54; diag_7d   +=     54;}
inline void RXPattern::set_WHITE_E4() {hv_4b +=  162; hv_4c +=   54; diag_8b   +=   162; diag_7a   +=     54;}
inline void RXPattern::set_WHITE_F4() {hv_3b +=  162; hv_4c +=   18; diag_7b   +=    18; diag_6a   +=     54;}
inline void RXPattern::set_WHITE_G4() {hv_2b +=  162; hv_4c +=    6; diag_6b   +=     6; diag_5a   +=     54; corner2x5b +=  1458; corner2x5g +=   486; edge64b +=      2;}
inline void RXPattern::set_WHITE_H4() {hv_4c +=    2; diag_5b  +=    2; corner2x5b +=    54; corner2x5g +=    162; edge2XCb  +=   486; corner11b  +=    54; edge64b +=    162;}

inline void RXPattern::set_WHITE_A5() {hv_4d +=    2; diag_5d  +=    2; corner2x5d +=    54; edge2XCd  +=    486; corner11d  +=    54; corner2x5e +=   162; edge64d +=    162;}
inline void RXPattern::set_WHITE_B5() {hv_2a +=  162; hv_4d +=    6; diag_6d   +=     6; diag_5c   +=     54; corner2x5d +=  1458; corner2x5e +=   486; edge64d +=      2;}
inline void RXPattern::set_WHITE_C5() {hv_3a +=  162; hv_4d +=   18; diag_7d   +=    18; diag_6c   +=     54;}
inline void RXPattern::set_WHITE_D5() {hv_4a +=  162; hv_4d +=   54; diag_8b   +=    54; diag_7c   +=     54;}
inline void RXPattern::set_WHITE_E5() {hv_4b +=   54; hv_4d +=  162; diag_8a   +=   162; diag_7b   +=     54;}
inline void RXPattern::set_WHITE_F5() {hv_3b +=   54; hv_4d +=  486; diag_7a   +=   162; diag_6b   +=     18;}
inline void RXPattern::set_WHITE_G5() {hv_2b +=   54; hv_4d += 1458; diag_6a   +=   162; diag_5b   +=      6; corner2x5g +=  1458; corner2x5b +=   486; edge64b +=  39366;}
inline void RXPattern::set_WHITE_H5() {hv_4d += 4374; diag_5a  +=  162; corner2x5g +=    54; edge2XCb  +=   1458; corner11c  +=  4374; corner2x5b +=   162; edge64b +=    486;}

inline void RXPattern::set_WHITE_A6() {hv_3d +=    2; diag_6d  +=    2; corner11d  +=    18; corner2x5d +=     18; edge2XCd  +=   162; edge64d  +=    54;}
inline void RXPattern::set_WHITE_B6() {hv_2a +=  486; hv_3d +=    6; diag_7d   +=     6; corner11d  +=    162; corner2x5d +=  4374; edge64d  +=     6;}
inline void RXPattern::set_WHITE_C6() {hv_3a +=  486; hv_3d +=   18; diag_8b   +=    18; diag_5c   +=     18; corner11d  +=   486;}
inline void RXPattern::set_WHITE_D6() {hv_4a +=  486; hv_3d +=   54; diag_7b   +=   162; diag_6c   +=     18;}
inline void RXPattern::set_WHITE_E6() {hv_4b +=   18; hv_3d +=  162; diag_7c   +=    18; diag_6b   +=     54;}
inline void RXPattern::set_WHITE_F6() {hv_3b +=   18; hv_3d +=  486; diag_8a   +=   486; diag_5b   +=     18; corner11c  +=   486;}
inline void RXPattern::set_WHITE_G6() {hv_2b +=   18; hv_3d += 1458; diag_7a   +=   486; corner11c  +=   1458; corner2x5g +=  4374; edge64b  += 13122;}
inline void RXPattern::set_WHITE_H6() {hv_3d += 4374; diag_6a  +=  486; corner11c  += 13122; corner2x5g +=     18; edge2XCb  +=  4374; edge64b  +=  1458;}

inline void RXPattern::set_WHITE_A7() {hv_2d +=    2; diag_7d  +=    2; corner11d  +=     6; corner2x5d +=      6; corner2x5h += 39366; edge2XCd  +=    54; edge64d +=     18; edge2XCc += 118098;}
inline void RXPattern::set_WHITE_B7() {hv_2a += 1458; hv_2d +=    6; diag_8b   +=     6; corner11d  += 118098; corner2x5d += 13122; corner2x5h += 13122; edge2XCc += 354294; edge2XCd +=      2;}
inline void RXPattern::set_WHITE_C7() {hv_3a += 1458; hv_2d +=   18; diag_7b   +=   486; corner11d  +=   1458; corner2x5h +=  4374; edge64c  += 13122;}
inline void RXPattern::set_WHITE_D7() {hv_4a += 1458; hv_2d +=   54; diag_6b   +=   162; diag_5c   +=      6; corner2x5c +=   486; corner2x5h +=  1458; edge64c +=  39366;}
inline void RXPattern::set_WHITE_E7() {hv_4b +=    6; hv_2d +=  162; diag_6c   +=     6; diag_5b   +=     54; corner2x5c +=  1458; corner2x5h +=   486; edge64c +=      2;}
inline void RXPattern::set_WHITE_F7() {hv_3b +=    6; hv_2d +=  486; diag_7c   +=     6; corner11c  +=    162; corner2x5c +=  4374; edge64c  +=     6; }
inline void RXPattern::set_WHITE_G7() {hv_2b +=    6; hv_2d += 1458; diag_8a   +=  1458; corner11c  += 118098; corner2x5c += 13122; corner2x5g += 13122; edge2XCb += 354294; edge2XCc +=      2;}
inline void RXPattern::set_WHITE_H7() {hv_2d += 4374; diag_7a  += 1458; corner11c  += 39366; corner2x5c +=  39366; corner2x5g +=     6; edge2XCb  += 13122; edge64b +=   4374; edge2XCc +=      6;}

inline void RXPattern::set_WHITE_A8() {diag_8b  +=    2; corner11d +=    2; corner2x5d +=     2; corner2x5h +=      2; edge2XCc  += 39366; edge2XCd  +=    18;}
inline void RXPattern::set_WHITE_B8() {hv_2a += 4374; diag_7b  += 1458; corner11d  += 39366; corner2x5d +=  39366; corner2x5h +=     6; edge2XCc  += 13122; edge64c +=   4374; edge2XCd +=      6;}
inline void RXPattern::set_WHITE_C8() {hv_3a += 4374; diag_6b  +=  486; corner11d  += 13122; corner2x5h +=     18; edge2XCc  +=  4374; edge64c  +=  1458;}
inline void RXPattern::set_WHITE_D8() {hv_4a += 4374; diag_5b  +=  162; corner2x5c +=   162; corner2x5h +=     54; edge2XCc  +=  1458; corner11d  +=  4374; edge64c +=    486;}
inline void RXPattern::set_WHITE_E8() {hv_4b +=    2; diag_5c  +=    2; corner11c  +=    54; corner2x5c +=     54; edge2XCc  +=   486; corner2x5h +=   162; edge64c +=    162;}
inline void RXPattern::set_WHITE_F8() {hv_3b +=    2; diag_6c  +=    2; corner11c  +=    18; corner2x5c +=     18; edge2XCc  +=   162; edge64c  +=    54;}
inline void RXPattern::set_WHITE_G8() {hv_2b +=    2; diag_7c  +=    2; corner11c  +=     6; corner2x5c +=      6; corner2x5g += 39366; edge2XCc  +=    54; edge64c +=     18; edge2XCb += 118098;}
inline void RXPattern::set_WHITE_H8() {diag_8a  += 4374; corner11c +=    2; corner2x5c +=     2; corner2x5g +=      2; edge2XCb  += 39366; edge2XCc  +=    18;}

//Flip Black disc

inline void RXPattern::flip_BLACK_B1() {hv_2a -=    1; diag_7a  -=   1; corner11a  -=     3; corner2x5a -=     3; corner2x5e -= 19683; edge2XCa  -=    27; edge64a -=      9; edge2XCd -=  59049;}
inline void RXPattern::flip_BLACK_C1() {hv_3a -=    1; diag_6a  -=   1; corner11a  -=     9; corner2x5a -=     9; edge2XCa  -=    81; edge64a  -=    27;}
inline void RXPattern::flip_BLACK_D1() {hv_4a -=    1; diag_5a  -=   1; corner11a  -=    27; corner2x5a -=    27; edge2XCa  -=   243; corner2x5f -=    81; edge64a -=     81;}
inline void RXPattern::flip_BLACK_E1() {hv_4b -= 2187; diag_5d  -=  81; corner2x5a -=    81; corner2x5f -=    27; edge2XCa  -=   729; corner11b  -=  2187; edge64a -=    243;}
inline void RXPattern::flip_BLACK_F1() {hv_3b -= 2187; diag_6d  -= 243; corner11b  -=  6561; corner2x5f -=     9; edge2XCa  -=  2187; edge64a  -=   729;}
inline void RXPattern::flip_BLACK_G1() {hv_2b -= 2187; diag_7d  -= 729; corner11b  -= 19683; corner2x5b -= 19683; corner2x5f -=     3; edge2XCa  -=  6561; edge64a -=   2187; edge2XCb -=      3;}

inline void RXPattern::flip_BLACK_A2() {hv_2c -= 2187; diag_7c  -= 729; corner11a  -= 19683; corner2x5a -= 19683; corner2x5e -=     3; edge2XCd  -=  6561; edge64d -=   2187; edge2XCa -=      3;}
inline void RXPattern::flip_BLACK_B2() {hv_2a -=    3; hv_2c -= 729; diag_8a   -=     3; corner11a  -= 59049; corner2x5a -=  6561; corner2x5e -=  6561; edge2XCa -=      1; edge2XCd -= 177147;}
inline void RXPattern::flip_BLACK_C2() {hv_3a -=    3; hv_2c -= 243; diag_7a   -=     3; corner11a  -=    81; corner2x5a -=  2187; edge64a  -=     3;}
inline void RXPattern::flip_BLACK_D2() {hv_4a -=    3; hv_2c -=  81; diag_6a   -=     3; diag_5d   -=    27; corner2x5a -=   729; corner2x5f -=   243; edge64a -=      1;}
inline void RXPattern::flip_BLACK_E2() {hv_4b -=  729; hv_2c -=  27; diag_6d   -=    81; diag_5a   -=     3; corner2x5a -=   243; corner2x5f -=   729; edge64a -=  19683;}
inline void RXPattern::flip_BLACK_F2() {hv_3b -=  729; hv_2c -=   9; diag_7d   -=   243; corner11b  -=   729; corner2x5f -=  2187; edge64a  -=  6561;}
inline void RXPattern::flip_BLACK_G2() {hv_2b -=  729; hv_2c -=   3; diag_8b   -=   729; corner11b  -= 59049; corner2x5b -=  6561; corner2x5f -=  6561; edge2XCa -= 177147; edge2XCb -=      1;}
inline void RXPattern::flip_BLACK_H2() {hv_2c -=    1; diag_7b  -=   1; corner11b  -=     3; corner2x5b -=     3; corner2x5f -= 19683; edge2XCb  -=    27; edge64b -=      9; edge2XCa -=  59049;}

inline void RXPattern::flip_BLACK_A3() {hv_3c -= 2187; diag_6c  -= 243; corner11a  -= 6561; corner2x5e  -=     9; edge2XCd  -=  2187; edge64d  -=   729;}
inline void RXPattern::flip_BLACK_B3() {hv_2a -=    9; hv_3c -= 729; diag_7c   -=  243; corner11a   -=   729; corner2x5e -=  2187; edge64d  -=  6561;}
inline void RXPattern::flip_BLACK_C3() {hv_3a -=    9; hv_3c -= 243; diag_8a   -=    9; diag_5d    -=     9; corner11a  -=   243;}
inline void RXPattern::flip_BLACK_D3() {hv_4a -=    9; hv_3c -=  81; diag_7a   -=    9; diag_6d    -=    27;}
inline void RXPattern::flip_BLACK_E3() {hv_4b -=  243; hv_3c -=  27; diag_7d   -=   81; diag_6a    -=     9;}
inline void RXPattern::flip_BLACK_F3() {hv_3b -=  243; hv_3c -=   9; diag_8b   -=  243; diag_5a    -=     9; corner11b  -=   243;}
inline void RXPattern::flip_BLACK_G3() {hv_2b -=  243; hv_3c -=   3; diag_7b   -=    3; corner11b   -=    81; corner2x5b -=  2187; edge64b  -=     3;}
inline void RXPattern::flip_BLACK_H3() {hv_3c -=    1; diag_6b  -=   1; corner11b  -=    9; corner2x5b  -=     9; edge2XCb  -=    81; edge64b  -=    27;}

inline void RXPattern::flip_BLACK_A4() {hv_4c -= 2187; diag_5c  -=  81; corner2x5e -=   27; edge2XCd   -=   729; corner11a  -=  2187; corner2x5d -=    81; edge64d -=    243;}
inline void RXPattern::flip_BLACK_B4() {hv_2a -=   27; hv_4c -= 729; diag_6c   -=   81; diag_5d    -=     3; corner2x5e -=   729; corner2x5d -=   243; edge64d -=  19683;}
inline void RXPattern::flip_BLACK_C4() {hv_3a -=   27; hv_4c -= 243; diag_7c   -=   81; diag_6d    -=     9;}
inline void RXPattern::flip_BLACK_D4() {hv_4a -=   27; hv_4c -=  81; diag_8a   -=   27; diag_7d    -=    27;}
inline void RXPattern::flip_BLACK_E4() {hv_4b -=   81; hv_4c -=  27; diag_8b   -=   81; diag_7a    -=    27;}
inline void RXPattern::flip_BLACK_F4() {hv_3b -=   81; hv_4c -=   9; diag_7b   -=    9; diag_6a    -=    27;}
inline void RXPattern::flip_BLACK_G4() {hv_2b -=   81; hv_4c -=   3; diag_6b   -=    3; diag_5a    -=    27; corner2x5b -=   729; corner2x5g -=   243; edge64b -=      1;}
inline void RXPattern::flip_BLACK_H4() {hv_4c -=    1; diag_5b  -=   1; corner2x5b -=   27; corner2x5g  -=    81; edge2XCb  -=   243; corner11b  -=    27; edge64b -=     81;}

inline void RXPattern::flip_BLACK_A5() {hv_4d -=    1; diag_5d  -=   1; corner2x5d -=   27; edge2XCd   -=   243; corner11d  -=    27; corner2x5e -=    81; edge64d -=     81;}
inline void RXPattern::flip_BLACK_B5() {hv_2a -=   81; hv_4d -=   3; diag_6d   -=    3; diag_5c    -=    27; corner2x5d -=   729; corner2x5e -=   243; edge64d -=      1;}
inline void RXPattern::flip_BLACK_C5() {hv_3a -=   81; hv_4d -=   9; diag_7d   -=    9; diag_6c    -=    27;}
inline void RXPattern::flip_BLACK_D5() {hv_4a -=   81; hv_4d -=  27; diag_8b   -=   27; diag_7c    -=    27;}
inline void RXPattern::flip_BLACK_E5() {hv_4b -=   27; hv_4d -=  81; diag_8a   -=   81; diag_7b    -=    27;}
inline void RXPattern::flip_BLACK_F5() {hv_3b -=   27; hv_4d -= 243; diag_7a   -=   81; diag_6b    -=     9;}
inline void RXPattern::flip_BLACK_G5() {hv_2b -=   27; hv_4d -= 729; diag_6a   -=   81; diag_5b    -=     3; corner2x5g -=   729; corner2x5b -=   243; edge64b -=  19683;}
inline void RXPattern::flip_BLACK_H5() {hv_4d -= 2187; diag_5a  -=  81; corner2x5g -=   27; edge2XCb   -=   729; corner11c  -=  2187; corner2x5b -=    81; edge64b -=    243;}

inline void RXPattern::flip_BLACK_A6() {hv_3d -=    1; diag_6d  -=   1; corner11d  -=    9; corner2x5d  -=     9; edge2XCd  -=    81; edge64d  -=    27;}
inline void RXPattern::flip_BLACK_B6() {hv_2a -=  243; hv_3d -=   3; diag_7d   -=    3; corner11d   -=    81; corner2x5d -=  2187; edge64d  -=     3;}
inline void RXPattern::flip_BLACK_C6() {hv_3a -=  243; hv_3d -=   9; diag_8b   -=    9; diag_5c    -=     9; corner11d  -=   243;}
inline void RXPattern::flip_BLACK_D6() {hv_4a -=  243; hv_3d -=  27; diag_7b   -=   81; diag_6c    -=     9;}
inline void RXPattern::flip_BLACK_E6() {hv_4b -=    9; hv_3d -=  81; diag_7c   -=    9; diag_6b    -=    27;}
inline void RXPattern::flip_BLACK_F6() {hv_3b -=    9; hv_3d -= 243; diag_8a   -=  243; diag_5b    -=     9; corner11c  -=   243;}
inline void RXPattern::flip_BLACK_G6() {hv_2b -=    9; hv_3d -= 729; diag_7a   -=  243; corner11c   -=   729; corner2x5g -=  2187; edge64b  -=  6561;}
inline void RXPattern::flip_BLACK_H6() {hv_3d -= 2187; diag_6a  -= 243; corner11c  -= 6561; corner2x5g  -=     9; edge2XCb  -=  2187; edge64b  -=   729;}

inline void RXPattern::flip_BLACK_A7() {hv_2d -=    1; diag_7d  -=   1; corner11d  -=     3; corner2x5d -=     3; corner2x5h -= 19683; edge2XCd  -=    27; edge64d -=      9; edge2XCc -=  59049;}
inline void RXPattern::flip_BLACK_B7() {hv_2a -=  729; hv_2d -=   3; diag_8b   -=     3; corner11d  -= 59049; corner2x5d -=  6561; corner2x5h -=  6561; edge2XCc -= 177147; edge2XCd -=      1;}
inline void RXPattern::flip_BLACK_C7() {hv_3a -=  729; hv_2d -=   9; diag_7b   -=   243; corner11d  -=   729; corner2x5h -=  2187; edge64c  -=  6561;}
inline void RXPattern::flip_BLACK_D7() {hv_4a -=  729; hv_2d -=  27; diag_6b   -=    81; diag_5c   -=     3; corner2x5c -=   243; corner2x5h -=   729; edge64c -=  19683;}
inline void RXPattern::flip_BLACK_E7() {hv_4b -=    3; hv_2d -=  81; diag_6c   -=     3; diag_5b   -=    27; corner2x5c -=   729; corner2x5h -=   243; edge64c -=      1;}
inline void RXPattern::flip_BLACK_F7() {hv_3b -=    3; hv_2d -= 243; diag_7c   -=     3; corner11c  -=    81; corner2x5c -=  2187; edge64c  -=     3; }
inline void RXPattern::flip_BLACK_G7() {hv_2b -=    3; hv_2d -= 729; diag_8a   -=   729; corner11c  -= 59049; corner2x5c -=  6561; corner2x5g -=  6561; edge2XCb -= 177147; edge2XCc -=      1;}
inline void RXPattern::flip_BLACK_H7() {hv_2d -= 2187; diag_7a  -= 729; corner11c  -= 19683; corner2x5c -= 19683; corner2x5g -=     3; edge2XCb  -=  6561; edge64b -=   2187; edge2XCc -=      3;}

inline void RXPattern::flip_BLACK_B8() {hv_2a -= 2187; diag_7b  -= 729; corner11d  -= 19683; corner2x5d -= 19683; corner2x5h -=     3; edge2XCc  -=  6561; edge64c -=   2187; edge2XCd -=      3;}
inline void RXPattern::flip_BLACK_C8() {hv_3a -= 2187; diag_6b  -= 243; corner11d  -=  6561; corner2x5h -=     9; edge2XCc  -=  2187; edge64c  -=   729;}
inline void RXPattern::flip_BLACK_D8() {hv_4a -= 2187; diag_5b  -=  81; corner2x5c -=    81; corner2x5h -=    27; edge2XCc  -=   729; corner11d  -=  2187; edge64c -=    243;}
inline void RXPattern::flip_BLACK_E8() {hv_4b -=    1; diag_5c  -=   1; corner11c  -=    27; corner2x5c -=    27; edge2XCc  -=   243; corner2x5h -=    81; edge64c -=     81;}
inline void RXPattern::flip_BLACK_F8() {hv_3b -=    1; diag_6c  -=   1; corner11c  -=     9; corner2x5c -=     9; edge2XCc  -=    81; edge64c  -=    27;}
inline void RXPattern::flip_BLACK_G8() {hv_2b -=    1; diag_7c  -=   1; corner11c  -=     3; corner2x5c -=     3; corner2x5g -= 19683; edge2XCc  -=    27; edge64c -=      9; edge2XCb -=  59049;}

//Flip White disc

inline void RXPattern::flip_WHITE_B1() {hv_2a +=    1; diag_7a  +=   1; corner11a  +=     3; corner2x5a +=     3; corner2x5e += 19683; edge2XCa  +=    27; edge64a +=      9; edge2XCd +=  59049;}
inline void RXPattern::flip_WHITE_C1() {hv_3a +=    1; diag_6a  +=   1; corner11a  +=     9; corner2x5a +=     9; edge2XCa  +=    81; edge64a  +=    27;}
inline void RXPattern::flip_WHITE_D1() {hv_4a +=    1; diag_5a  +=   1; corner11a  +=    27; corner2x5a +=    27; edge2XCa  +=   243; corner2x5f +=    81; edge64a +=     81;}
inline void RXPattern::flip_WHITE_E1() {hv_4b += 2187; diag_5d  +=  81; corner2x5a +=    81; corner2x5f +=    27; edge2XCa  +=   729; corner11b  +=  2187; edge64a +=    243;}
inline void RXPattern::flip_WHITE_F1() {hv_3b += 2187; diag_6d  += 243; corner11b  +=  6561; corner2x5f +=     9; edge2XCa  +=  2187; edge64a  +=   729;}
inline void RXPattern::flip_WHITE_G1() {hv_2b += 2187; diag_7d  += 729; corner11b  += 19683; corner2x5b += 19683; corner2x5f +=     3; edge2XCa  +=  6561; edge64a +=   2187; edge2XCb +=      3;}

inline void RXPattern::flip_WHITE_A2() {hv_2c += 2187; diag_7c  += 729; corner11a  += 19683; corner2x5a += 19683; corner2x5e +=     3; edge2XCd  +=  6561; edge64d +=   2187; edge2XCa +=      3;}
inline void RXPattern::flip_WHITE_B2() {hv_2a +=    3; hv_2c += 729; diag_8a   +=     3; corner11a  += 59049; corner2x5a +=  6561; corner2x5e +=  6561; edge2XCa +=      1; edge2XCd += 177147;}
inline void RXPattern::flip_WHITE_C2() {hv_3a +=    3; hv_2c += 243; diag_7a   +=     3; corner11a  +=    81; corner2x5a +=  2187; edge64a  +=     3;}
inline void RXPattern::flip_WHITE_D2() {hv_4a +=    3; hv_2c +=  81; diag_6a   +=     3; diag_5d   +=    27; corner2x5a +=   729; corner2x5f +=   243; edge64a +=      1;}
inline void RXPattern::flip_WHITE_E2() {hv_4b +=  729; hv_2c +=  27; diag_6d   +=    81; diag_5a   +=     3; corner2x5a +=   243; corner2x5f +=   729; edge64a +=  19683;}
inline void RXPattern::flip_WHITE_F2() {hv_3b +=  729; hv_2c +=   9; diag_7d   +=   243; corner11b  +=   729; corner2x5f +=  2187; edge64a  +=  6561;}
inline void RXPattern::flip_WHITE_G2() {hv_2b +=  729; hv_2c +=   3; diag_8b   +=   729; corner11b  += 59049; corner2x5b +=  6561; corner2x5f +=  6561; edge2XCa += 177147; edge2XCb +=      1;}
inline void RXPattern::flip_WHITE_H2() {hv_2c +=    1; diag_7b  +=   1; corner11b  +=     3; corner2x5b +=     3; corner2x5f += 19683; edge2XCb  +=    27; edge64b +=      9; edge2XCa +=  59049;}

inline void RXPattern::flip_WHITE_A3() {hv_3c += 2187; diag_6c  += 243; corner11a  += 6561; corner2x5e  +=     9; edge2XCd  +=  2187; edge64d  +=   729;}
inline void RXPattern::flip_WHITE_B3() {hv_2a +=    9; hv_3c += 729; diag_7c   +=  243; corner11a   +=   729; corner2x5e +=  2187; edge64d  +=  6561;}
inline void RXPattern::flip_WHITE_C3() {hv_3a +=    9; hv_3c += 243; diag_8a   +=    9; diag_5d    +=     9; corner11a  +=   243;}
inline void RXPattern::flip_WHITE_D3() {hv_4a +=    9; hv_3c +=  81; diag_7a   +=    9; diag_6d    +=    27;}
inline void RXPattern::flip_WHITE_E3() {hv_4b +=  243; hv_3c +=  27; diag_7d   +=   81; diag_6a    +=     9;}
inline void RXPattern::flip_WHITE_F3() {hv_3b +=  243; hv_3c +=   9; diag_8b   +=  243; diag_5a    +=     9; corner11b  +=   243;}
inline void RXPattern::flip_WHITE_G3() {hv_2b +=  243; hv_3c +=   3; diag_7b   +=    3; corner11b   +=    81; corner2x5b +=  2187; edge64b  +=     3;}
inline void RXPattern::flip_WHITE_H3() {hv_3c +=    1; diag_6b  +=   1; corner11b  +=    9; corner2x5b  +=     9; edge2XCb  +=    81; edge64b  +=    27;}

inline void RXPattern::flip_WHITE_A4() {hv_4c += 2187; diag_5c  +=  81; corner2x5e +=   27; edge2XCd   +=   729; corner11a  +=  2187; corner2x5d +=    81; edge64d +=    243;}
inline void RXPattern::flip_WHITE_B4() {hv_2a +=   27; hv_4c += 729; diag_6c   +=   81; diag_5d    +=     3; corner2x5e +=   729; corner2x5d +=   243; edge64d +=  19683;}
inline void RXPattern::flip_WHITE_C4() {hv_3a +=   27; hv_4c += 243; diag_7c   +=   81; diag_6d    +=     9;}
inline void RXPattern::flip_WHITE_D4() {hv_4a +=   27; hv_4c +=  81; diag_8a   +=   27; diag_7d    +=    27;}
inline void RXPattern::flip_WHITE_E4() {hv_4b +=   81; hv_4c +=  27; diag_8b   +=   81; diag_7a    +=    27;}
inline void RXPattern::flip_WHITE_F4() {hv_3b +=   81; hv_4c +=   9; diag_7b   +=    9; diag_6a    +=    27;}
inline void RXPattern::flip_WHITE_G4() {hv_2b +=   81; hv_4c +=   3; diag_6b   +=    3; diag_5a    +=    27; corner2x5b +=   729; corner2x5g +=   243; edge64b +=      1;}
inline void RXPattern::flip_WHITE_H4() {hv_4c +=    1; diag_5b  +=   1; corner2x5b +=   27; corner2x5g  +=    81; edge2XCb  +=   243; corner11b  +=    27; edge64b +=     81;}

inline void RXPattern::flip_WHITE_A5() {hv_4d +=    1; diag_5d  +=   1; corner2x5d +=   27; edge2XCd   +=   243; corner11d  +=    27; corner2x5e +=    81; edge64d +=     81;}
inline void RXPattern::flip_WHITE_B5() {hv_2a +=   81; hv_4d +=   3; diag_6d   +=    3; diag_5c    +=    27; corner2x5d +=   729; corner2x5e +=   243; edge64d +=      1;}
inline void RXPattern::flip_WHITE_C5() {hv_3a +=   81; hv_4d +=   9; diag_7d   +=    9; diag_6c    +=    27;}
inline void RXPattern::flip_WHITE_D5() {hv_4a +=   81; hv_4d +=  27; diag_8b   +=   27; diag_7c    +=    27;}
inline void RXPattern::flip_WHITE_E5() {hv_4b +=   27; hv_4d +=  81; diag_8a   +=   81; diag_7b    +=    27;}
inline void RXPattern::flip_WHITE_F5() {hv_3b +=   27; hv_4d += 243; diag_7a   +=   81; diag_6b    +=     9;}
inline void RXPattern::flip_WHITE_G5() {hv_2b +=   27; hv_4d += 729; diag_6a   +=   81; diag_5b    +=     3; corner2x5g +=   729; corner2x5b +=   243; edge64b +=  19683;}
inline void RXPattern::flip_WHITE_H5() {hv_4d += 2187; diag_5a  +=  81; corner2x5g +=   27; edge2XCb   +=   729; corner11c  +=  2187; corner2x5b +=    81; edge64b +=    243;}

inline void RXPattern::flip_WHITE_A6() {hv_3d +=    1; diag_6d  +=   1; corner11d  +=    9; corner2x5d  +=     9; edge2XCd  +=    81; edge64d  +=    27;}
inline void RXPattern::flip_WHITE_B6() {hv_2a +=  243; hv_3d +=   3; diag_7d   +=    3; corner11d   +=    81; corner2x5d +=  2187; edge64d  +=     3;}
inline void RXPattern::flip_WHITE_C6() {hv_3a +=  243; hv_3d +=   9; diag_8b   +=    9; diag_5c    +=     9; corner11d  +=   243;}
inline void RXPattern::flip_WHITE_D6() {hv_4a +=  243; hv_3d +=  27; diag_7b   +=   81; diag_6c    +=     9;}
inline void RXPattern::flip_WHITE_E6() {hv_4b +=    9; hv_3d +=  81; diag_7c   +=    9; diag_6b    +=    27;}
inline void RXPattern::flip_WHITE_F6() {hv_3b +=    9; hv_3d += 243; diag_8a   +=  243; diag_5b    +=     9; corner11c  +=   243;}
inline void RXPattern::flip_WHITE_G6() {hv_2b +=    9; hv_3d += 729; diag_7a   +=  243; corner11c   +=   729; corner2x5g +=  2187; edge64b  +=  6561;}
inline void RXPattern::flip_WHITE_H6() {hv_3d += 2187; diag_6a  += 243; corner11c  += 6561; corner2x5g  +=     9; edge2XCb  +=  2187; edge64b  +=   729;}

inline void RXPattern::flip_WHITE_A7() {hv_2d +=    1; diag_7d  +=   1; corner11d  +=     3; corner2x5d +=     3; corner2x5h += 19683; edge2XCd  +=    27; edge64d +=      9; edge2XCc +=  59049;}
inline void RXPattern::flip_WHITE_B7() {hv_2a +=  729; hv_2d +=   3; diag_8b   +=     3; corner11d  += 59049; corner2x5d +=  6561; corner2x5h +=  6561; edge2XCc += 177147; edge2XCd +=      1;}
inline void RXPattern::flip_WHITE_C7() {hv_3a +=  729; hv_2d +=   9; diag_7b   +=   243; corner11d  +=   729; corner2x5h +=  2187; edge64c  +=  6561;}
inline void RXPattern::flip_WHITE_D7() {hv_4a +=  729; hv_2d +=  27; diag_6b   +=    81; diag_5c   +=     3; corner2x5c +=   243; corner2x5h +=   729; edge64c +=  19683;}
inline void RXPattern::flip_WHITE_E7() {hv_4b +=    3; hv_2d +=  81; diag_6c   +=     3; diag_5b   +=    27; corner2x5c +=   729; corner2x5h +=   243; edge64c +=      1;}
inline void RXPattern::flip_WHITE_F7() {hv_3b +=    3; hv_2d += 243; diag_7c   +=     3; corner11c  +=    81; corner2x5c +=  2187; edge64c  +=     3; }
inline void RXPattern::flip_WHITE_G7() {hv_2b +=    3; hv_2d += 729; diag_8a   +=   729; corner11c  += 59049; corner2x5c +=  6561; corner2x5g +=  6561; edge2XCb += 177147; edge2XCc +=      1;}
inline void RXPattern::flip_WHITE_H7() {hv_2d += 2187; diag_7a  += 729; corner11c  += 19683; corner2x5c += 19683; corner2x5g +=     3; edge2XCb  +=  6561; edge64b +=   2187; edge2XCc +=      3;}

inline void RXPattern::flip_WHITE_B8() {hv_2a += 2187; diag_7b  += 729; corner11d  += 19683; corner2x5d += 19683; corner2x5h +=     3; edge2XCc  +=  6561; edge64c +=   2187; edge2XCd +=      3;}
inline void RXPattern::flip_WHITE_C8() {hv_3a += 2187; diag_6b  += 243; corner11d  +=  6561; corner2x5h +=     9; edge2XCc  +=  2187; edge64c  +=   729;}
inline void RXPattern::flip_WHITE_D8() {hv_4a += 2187; diag_5b  +=  81; corner2x5c +=    81; corner2x5h +=    27; edge2XCc  +=   729; corner11d  +=  2187; edge64c +=    243;}
inline void RXPattern::flip_WHITE_E8() {hv_4b +=    1; diag_5c  +=   1; corner11c  +=    27; corner2x5c +=    27; edge2XCc  +=   243; corner2x5h +=    81; edge64c +=     81;}
inline void RXPattern::flip_WHITE_F8() {hv_3b +=    1; diag_6c  +=   1; corner11c  +=     9; corner2x5c +=     9; edge2XCc  +=    81; edge64c  +=    27;}
inline void RXPattern::flip_WHITE_G8() {hv_2b +=    1; diag_7c  +=   1; corner11c  +=     3; corner2x5c +=     3; corner2x5g += 19683; edge2XCc  +=    27; edge64c +=      9; edge2XCb +=  59049;}

#endif