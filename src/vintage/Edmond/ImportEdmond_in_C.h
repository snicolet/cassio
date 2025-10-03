/*
 *  ImportEdmond_in_C.h
 *  Roxane
 *
 *  Created by Bruno Causse on 06/08/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef RXEVALUATION_H
#define RXEVALUATION_H




	
	static int* BLACK_DIAG_5[64];
	static int* WHITE_DIAG_5[64];

	static int* BLACK_DIAG_6[64];
	static int* WHITE_DIAG_6[64];
	
	static int* BLACK_DIAG_7[64];
	static int* WHITE_DIAG_7[64];

	static int* BLACK_DIAG_8[64];
	static int* WHITE_DIAG_8[64];
	
	static int* BLACK_HV_4[64];
	static int* WHITE_HV_4[64];

	static int* BLACK_HV_3[64];
	static int* WHITE_HV_3[64];

	static int* BLACK_HV_2[64];
	static int* WHITE_HV_2[64];
	
	static int* BLACK_EDGE_6_4[64];
	static int* WHITE_EDGE_6_4[64];

	static int* BLACK_CORNER_2x5[64];
	static int* WHITE_CORNER_2x5[64];

	static int* BLACK_CORNER_11[64];
	static int* WHITE_CORNER_11[64];

	static int* BLACK_EDGE_2XC[64];
	static int* WHITE_EDGE_2XC[64];

	
  pascal void edmond_load_coefficients( char *file_name );
  pascal void edmond_release_coefficients();
  
  pascal int* edmond_get_black_diag_5_pointer(int stage);
  pascal int* edmond_get_white_diag_5_pointer(int stage);
  
  pascal int* edmond_get_black_diag_6_pointer(int stage);
  pascal int* edmond_get_white_diag_6_pointer(int stage);
  
  pascal int* edmond_get_black_diag_7_pointer(int stage);
  pascal int* edmond_get_white_diag_7_pointer(int stage);
  
  pascal int* edmond_get_black_diag_8_pointer(int stage);
  pascal int* edmond_get_white_diag_8_pointer(int stage);
  
  pascal int* edmond_get_black_hv_4_pointer(int stage);
  pascal int* edmond_get_white_hv_4_pointer(int stage);
  
  pascal int* edmond_get_black_hv_3_pointer(int stage);
  pascal int* edmond_get_white_hv_3_pointer(int stage);
  
  pascal int* edmond_get_black_hv_2_pointer(int stage);
  pascal int* edmond_get_white_hv_2_pointer(int stage);
  
  pascal int* edmond_get_black_edge_6_4_pointer(int stage);
  pascal int* edmond_get_white_edge_6_4_pointer(int stage);
  
  pascal int* edmond_get_black_corner_2x5_pointer(int stage);
  pascal int* edmond_get_white_corner_2x5_pointer(int stage);
  
  pascal int* edmond_get_black_corner_11_pointer(int stage);
  pascal int* edmond_get_white_corner_11_pointer(int stage);
  
  pascal int* edmond_get_black_edge_2XC_pointer(int stage);
  pascal int* edmond_get_white_edge_2XC_pointer(int stage);

  
  
  
  /* interface avec Cassio */
  
  pascal int size_of_float_in_c();
  pascal int size_of_int_in_c();
  
  



#endif

