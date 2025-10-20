/*
 *  ImportEdmond_in_C.c
 *  Roxane
 *
 *  Created by Bruno Causse on 06/08/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */


#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <malloc.h>
#include <time.h>


#include "ImportEdmond_in_C.h"


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


const unsigned int START = 16;
const unsigned int END = 57;


pascal void edmond_load_coefficients( char *file_name ) {

	
	FILE *coeff_file;
	int iStage;
	
	//flag de patterns traites
	int flag_8[6561];
  int flag10[59049];
	int flagD7[2187];
	int flagD6[729];
	int flagD5[243];
	int flagC11[177147];
	int flag12[531441];
	
	//index de boucle
	int pos0;
	int pos1;
	int pos2;
	int pos3;
	int pos4;
	int pos5;
	int pos6;
	int pos7;
	int pos8;
	int pos9;
	int posA;
	int posB;
	
	int id0;
	int id1;
	int id2;
	int id3;
	int id4;
	int id5;
	int id6;
	int id7;
	int id8;
	int id9;
	int id10;
	int id11;
	
	int id0Neg;
	int id1Neg;
	int id2Neg;
	int id3Neg;
	int id4Neg;
	int id5Neg;
	int id6Neg;
	int id7Neg;
	int id8Neg;
	int id9Neg;
	int id10Neg;
	int id11Neg;
	
	
	coeff_file = fopen( file_name, "rb");
	
	if (coeff_file != NULL) {

		//initialisation des index
		int id_diag_5 = 0;
		int id_diag_6 = id_diag_5 + 135;
		int id_diag_7 = id_diag_6 + 378;
		int id_diag_8 = id_diag_7 + 1134;
		
		int id_hv_2 = id_diag_8 + 3321;
		int id_hv_3 = id_hv_2 + 3321;
		int id_hv_4 = id_hv_3 + 3321;
		
		int id_edge_6_4 = id_hv_4 + 3321;
		int id_corner_2x5 = id_edge_6_4 + 29646;
		int id_corner_11 = id_corner_2x5 + 59049;
		int id_edge_2XC = id_corner_11 + 89667;
		
		int n_instances = id_edge_2XC + 266085;
		
		

		//chargement des donnees
		float* coeff[64];
		for( iStage = START; iStage < END; iStage++) {
		
		  //coeff[iStage] = new float[n_instances];
			//from.read((char*)coeff[iStage], sizeof(float)*n_instances);
		
			coeff[iStage] = malloc(sizeof(float)*n_instances);
			fread( (char*)coeff[iStage], sizeof(float)*n_instances, 1 , coeff_file);
			
		}
				
		
		
		// creation des tables
		
		for( iStage = START; iStage < END; iStage++) {
			
			BLACK_DIAG_5[iStage] = malloc(sizeof(int)*243);
			BLACK_DIAG_6[iStage] = malloc(sizeof(int)*729);
			BLACK_DIAG_7[iStage] = malloc(sizeof(int)*2187);
			BLACK_DIAG_8[iStage] = malloc(sizeof(int)*6561);
			BLACK_HV_4[iStage] = malloc(sizeof(int)*6561);
			BLACK_HV_3[iStage] = malloc(sizeof(int)*6561);
			BLACK_HV_2[iStage] = malloc(sizeof(int)*6561);
			BLACK_EDGE_6_4[iStage] = malloc(sizeof(int)*59049);
			BLACK_CORNER_2x5[iStage] = malloc(sizeof(int)*59049);
			BLACK_CORNER_11[iStage] = malloc(sizeof(int)*177147);
			BLACK_EDGE_2XC[iStage] = malloc(sizeof(int)*531441);

			WHITE_DIAG_5[iStage] = malloc(sizeof(int)*243);
			WHITE_DIAG_6[iStage] = malloc(sizeof(int)*729);
			WHITE_DIAG_7[iStage] = malloc(sizeof(int)*2187);
			WHITE_DIAG_8[iStage] = malloc(sizeof(int)*6561);
			WHITE_HV_4[iStage] = malloc(sizeof(int)*6561);
			WHITE_HV_3[iStage] = malloc(sizeof(int)*6561);
			WHITE_HV_2[iStage] = malloc(sizeof(int)*6561);
			WHITE_EDGE_6_4[iStage] = malloc(sizeof(int)*59049);
			WHITE_CORNER_2x5[iStage] = malloc(sizeof(int)*59049);
			WHITE_CORNER_11[iStage] = malloc(sizeof(int)*177147);
			WHITE_EDGE_2XC[iStage] = malloc(sizeof(int)*531441);
			
		}
		
	
	// recopie des extremites
	
		//du stage 0 a START
		for( iStage = 0; iStage < START; iStage++) {

			BLACK_DIAG_5[iStage] = BLACK_DIAG_5[START];
			BLACK_DIAG_6[iStage] = BLACK_DIAG_6[START];
			BLACK_DIAG_7[iStage] = BLACK_DIAG_7[START];
			BLACK_DIAG_8[iStage] = BLACK_DIAG_8[START];
			BLACK_HV_4[iStage] = BLACK_HV_4[START];
			BLACK_HV_3[iStage] = BLACK_HV_3[START];
			BLACK_HV_2[iStage] = BLACK_HV_2[START];
			BLACK_EDGE_6_4[iStage] = BLACK_EDGE_6_4[START];
			BLACK_CORNER_2x5[iStage] = BLACK_CORNER_2x5[START];
			BLACK_CORNER_11[iStage] = BLACK_CORNER_11[START];
			BLACK_EDGE_2XC[iStage] = BLACK_EDGE_2XC[START];

			WHITE_DIAG_5[iStage] = WHITE_DIAG_5[START];
			WHITE_DIAG_6[iStage] = WHITE_DIAG_6[START];
			WHITE_DIAG_7[iStage] = WHITE_DIAG_7[START];
			WHITE_DIAG_8[iStage] = WHITE_DIAG_8[START];
			WHITE_HV_4[iStage] = WHITE_HV_4[START];
			WHITE_HV_3[iStage] = WHITE_HV_3[START];
			WHITE_HV_2[iStage] = WHITE_HV_2[START];
			WHITE_EDGE_6_4[iStage] = WHITE_EDGE_6_4[START];
			WHITE_CORNER_2x5[iStage] = WHITE_CORNER_2x5[START];
			WHITE_CORNER_11[iStage] = WHITE_CORNER_11[START];
			WHITE_EDGE_2XC[iStage] = WHITE_EDGE_2XC[START];
			
			
		}
		
		//du stage END a 64
		for( iStage = END; iStage < 64; iStage++) {

			BLACK_DIAG_5[iStage] = BLACK_DIAG_5[END-1];
			BLACK_DIAG_6[iStage] = BLACK_DIAG_6[END-1];
			BLACK_DIAG_7[iStage] = BLACK_DIAG_7[END-1];
			BLACK_DIAG_8[iStage] = BLACK_DIAG_8[END-1];
			BLACK_HV_4[iStage] = BLACK_HV_4[END-1];
			BLACK_HV_3[iStage] = BLACK_HV_3[END-1];
			BLACK_HV_2[iStage] = BLACK_HV_2[END-1];
			BLACK_EDGE_6_4[iStage] = BLACK_EDGE_6_4[END-1];
			BLACK_CORNER_2x5[iStage] = BLACK_CORNER_2x5[END-1];
			BLACK_CORNER_11[iStage] = BLACK_CORNER_11[END-1];
			BLACK_EDGE_2XC[iStage] = BLACK_EDGE_2XC[END-1];

			WHITE_DIAG_5[iStage] = WHITE_DIAG_5[END-1];
			WHITE_DIAG_6[iStage] = WHITE_DIAG_6[END-1];
			WHITE_DIAG_7[iStage] = WHITE_DIAG_7[END-1];
			WHITE_DIAG_8[iStage] = WHITE_DIAG_8[END-1];
			WHITE_HV_4[iStage] = WHITE_HV_4[END-1];
			WHITE_HV_3[iStage] = WHITE_HV_3[END-1];
			WHITE_HV_2[iStage] = WHITE_HV_2[END-1];
			WHITE_EDGE_6_4[iStage] = WHITE_EDGE_6_4[END-1];
			WHITE_CORNER_2x5[iStage] = WHITE_CORNER_2x5[END-1];
			WHITE_CORNER_11[iStage] = WHITE_CORNER_11[END-1];
			WHITE_EDGE_2XC[iStage] = WHITE_EDGE_2XC[END-1];
			
			
		}

		
		
		//flag de patterns traites
		

		for( pos0 = 0; pos0 < 3; pos0++) {

			for( pos1 = 0; pos1 < 3; pos1++) {
				int id2 = pos1 + 3*pos0;
				for( pos2 = 0; pos2 < 3; pos2++) {
					int id3 = pos2 + 3*id2;
					for( pos3 = 0; pos3 < 3; pos3++) {
						int id4 = pos3 + 3*id3;
						for( pos4 = 0; pos4 < 3; pos4++) {
							int id5 = pos4 + 3*id4;
							flagD5[id5] = false;
							for( pos5 = 0; pos5 < 3; pos5++) {
								int id6 = pos5 + 3*id5;
								flagD6[id6] = false;
								for( pos6 = 0; pos6 < 3; pos6++) {
									int id7 = pos6 + 3*id6;
									flagD7[id7] = false;
									for( pos7 = 0; pos7 < 3; pos7++) {
										int id8 = pos7 + 3*id7;
										flag_8[id8] = false;
										for( pos8 = 0; pos8 < 3; pos8++) {
											int id9 = pos8 + 3*id8;
											for( pos9 = 0; pos9 < 3; pos9++) {
												int idA = pos9 + 3* id9;
												flag10[idA] = false;
												for( posA = 0; posA < 3; posA++) {
													int idB = posA + 3*idA;
													flagC11[idB] = false;
													for( posB = 0; posB < 3; posB++)
														flag12[posB + 3*idB] = false;
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		//remplissage des tables
		 for( id0 = 0, id0Neg = 0; id0 < 3; id0Neg = 3 - (++id0)) {

			 for( id1 = 0, id1Neg = 0; id1 < 3; id1Neg = 3 - (++id1)) {

				 for( id2 = 0, id2Neg = 0; id2 < 3; id2Neg = 3-(++id2)) {
				
					 for( id3 = 0, id3Neg = 0; id3 < 3; id3Neg = 3 - (++id3)) {
					
						//4 squares = Diag4
						int pattern4 = id0 + 3*(id1 + 3*(id2 + 3*id3));
						int sym4 = id3 + 3*(id2 + 3*(id1 + 3*id0));
						int patternNeg4 = id0Neg + 3*(id1Neg + 3*(id2Neg + 3*id3Neg));
						int symNeg4 = id3Neg + 3*(id2Neg + 3*(id1Neg + 3*id0Neg));
						
						 for( id4 = 0, id4Neg = 0; id4 < 3; id4Neg = 3 - (++id4)) {
						
							//5 squares = Diag5
							int pattern5 = pattern4 + 81*id4;
							int sym5 = id4 + 3*sym4 ;
							int patternNeg5 = patternNeg4 + 81*id4Neg;
							int symNeg5 = id4Neg + 3*symNeg4;
							

							if(flagD5[pattern5] == false) {										
								
								for( iStage = START; iStage < END; iStage++) {
									int bValue = (int)round(coeff[iStage][id_diag_5]*16);
									
									BLACK_DIAG_5[iStage][pattern5] = bValue;
									BLACK_DIAG_5[iStage][sym5] = bValue;

									WHITE_DIAG_5[iStage][patternNeg5] = bValue;
									WHITE_DIAG_5[iStage][symNeg5] = bValue;
								}
								
								id_diag_5++;

								flagD5[sym5] = true;
									
							}

							 for( id5 = 0, id5Neg = 0; id5 < 3; id5Neg = 3 - (++id5)) {

								//6 squares = Diag6
								int pattern6 = pattern5 + 243*id5;
								int sym6 = id5 + 3*sym5 ;
								int patternNeg6 = patternNeg5 + 243*id5Neg;
								int symNeg6 = id5Neg + 3*symNeg5;
							
								if(flagD6[pattern6] == false) {										
									
									for( iStage = START; iStage < END; iStage++) {
										int bValue = (int)round(coeff[iStage][id_diag_6]*16);
										
										BLACK_DIAG_6[iStage][pattern6] = bValue;
										BLACK_DIAG_6[iStage][sym6] = bValue;

										WHITE_DIAG_6[iStage][patternNeg6] = bValue;
										WHITE_DIAG_6[iStage][symNeg6] = bValue;
									}

									id_diag_6++;

									flagD6[sym6] = true;
									
								}

								 for( id6 = 0, id6Neg = 0; id6 < 3; id6Neg = 3-(++id6 )) {

									//7 squares = Diag7
									int pattern7 = pattern6 + 729*id6;
									int sym7 = id6 + 3*sym6 ;
									int patternNeg7 = patternNeg6 + 729*id6Neg;
									int symNeg7 = id6Neg + 3*symNeg6;
									

									if(flagD7[pattern7] == false) {										
										
										for( iStage = START; iStage < END; iStage++) {
											int bValue = (int)round(coeff[iStage][id_diag_7]*16);
											
											BLACK_DIAG_7[iStage][pattern7] = bValue;
											BLACK_DIAG_7[iStage][sym7] = bValue;

											WHITE_DIAG_7[iStage][patternNeg7] = bValue;
											WHITE_DIAG_7[iStage][symNeg7] = bValue;
										}
											
										id_diag_7++;
										
										flagD7[sym7] = true;
										
									}

									 for( id7 = 0, id7Neg = 0; id7 < 3; id7Neg = 3-(++id7)) {

										//8 squares = Diag8 + Edge + Hor1 + Hor2 + Hor3
										int pattern8 = pattern7 + 2187*id7;
										int sym8 = id7 + 3*sym7 ;
										int patternNeg8 = patternNeg7 + 2187*id7Neg;
										int symNeg8 = id7Neg + 3*symNeg7;
										

										if(flag_8[pattern8] == false) {										
											
											for( iStage = START; iStage < END; iStage++) {
												//Diag 8
												int bValue = (int)round(coeff[iStage][id_diag_8]*16);
												
												BLACK_DIAG_8[iStage][pattern8] = bValue;
												BLACK_DIAG_8[iStage][sym8] = bValue;

												WHITE_DIAG_8[iStage][patternNeg8] = bValue;
												WHITE_DIAG_8[iStage][symNeg8] = bValue;
												
												//HV2
												bValue = (int)round(coeff[iStage][id_hv_2]*16);
												
												BLACK_HV_2[iStage][pattern8] = bValue;
												BLACK_HV_2[iStage][sym8] = bValue;

												WHITE_HV_2[iStage][patternNeg8] = bValue;
												WHITE_HV_2[iStage][symNeg8] = bValue;
												
												//HV3
												bValue = (int)round(coeff[iStage][id_hv_3]*16);
												
												BLACK_HV_3[iStage][pattern8] = bValue;
												BLACK_HV_3[iStage][sym8] = bValue;

												WHITE_HV_3[iStage][patternNeg8] = bValue;
												WHITE_HV_3[iStage][symNeg8] = bValue;
												
												//HV4
												bValue = (int)round(coeff[iStage][id_hv_4]*16);
												
												BLACK_HV_4[iStage][pattern8] = bValue;
												BLACK_HV_4[iStage][sym8] = bValue;

												WHITE_HV_4[iStage][patternNeg8] = bValue;
												WHITE_HV_4[iStage][symNeg8] = bValue;
											}
											
											id_diag_8++;
											id_hv_2++;
											id_hv_3++;
											id_hv_4++;
											
											flag_8[sym8] = true;
										}
										
										
										 for( id8 = 0, id8Neg = 0; id8 < 3; id8Neg = 3-(++id8 )) {
										

											//9 squares
											int pattern9 = pattern8 + 6561*id8;
											int sym9 = id8 + 3*sym8;
											int patternNeg9 = patternNeg8 + 6561*id8Neg;
											int symNeg9 = id8Neg + 3*symNeg8;

											 for( id9 = 0, id9Neg = 0; id9 < 3; id9Neg = 3-(++id9)) {
											
												//10 squares
												int pattern10 = pattern9 + 19683*id9;
												int sym10 = id9 + 3*sym9 ;
												int patternNeg10 = patternNeg9 + 19683*id9Neg;
												int symNeg10 = id9Neg + 3*symNeg9;

												if(flag10[pattern10] == false) {
																									
													for( iStage = START; iStage < END; iStage++) {
														int bValue = (int)round(coeff[iStage][id_edge_6_4]*16);

														BLACK_EDGE_6_4[iStage][pattern10] = bValue;
														BLACK_EDGE_6_4[iStage][sym10] = bValue;

														WHITE_EDGE_6_4[iStage][patternNeg10] = bValue;
														WHITE_EDGE_6_4[iStage][symNeg10] = bValue;
													}
													
													id_edge_6_4++;
													
													flag10[sym10] = true;													
																										
												}
												
												//C2*5
												for( iStage = START; iStage < END; iStage++) {
													BLACK_CORNER_2x5[iStage][pattern10] = (int)round(coeff[iStage][id_corner_2x5]*16);

													WHITE_CORNER_2x5[iStage][patternNeg10] = (int)round(coeff[iStage][id_corner_2x5]*16);
												}
												id_corner_2x5++;

												 for( id10 = 0, id10Neg = 0; id10 < 3; id10Neg = 3-(++id10)) {

													//11 Squares
													int pattern11 = pattern10 + 59049*id10;
									
													if(flagC11[pattern11] == false) {
																						
														int sym11 = (((((((((id10*3 + id1)*3 + id2)*3 + id3)*3 + id4)*3 + id5)*3 + id6)*3 + id7)*3 + id8)*3 + id9)*3 +id0;
														int patternNeg11 = patternNeg10 + 59049*id10Neg;
														int symNeg11 = (((((((((id10Neg*3 + id1Neg)*3 + id2Neg)*3 + id3Neg)*3 + id4Neg)*3 + id5Neg)*3 + id6Neg)*3 + id7Neg)*3 + id8Neg)*3 + id9Neg)*3 +id0Neg;
														
														for( iStage = START; iStage < END; iStage++) {
															int bValue = (int)round(coeff[iStage][id_corner_11]*16);
															
															BLACK_CORNER_11[iStage][pattern11] = bValue;
															BLACK_CORNER_11[iStage][sym11] = bValue;
															
															WHITE_CORNER_11[iStage][patternNeg11] = bValue;
															WHITE_CORNER_11[iStage][symNeg11] = bValue;
														}

														id_corner_11++;
														
														flagC11[sym11] = true;
																											
													}

													for( id11 = 0, id11Neg = 0; id11 < 3; id11Neg = 3-(++id11)) {
														//12 squares
														int pattern12 = id0 + 3*(id10 + 3*(id1 + 3*(id2 + 3*(id3 + 3*(id4 + 3*(id5 + 3*(id6 + 3*(id7 + 3*(id8 + 3*(id11 + 3*id9))))))))));
																												
														if(flag12[pattern12] == false) {
														
															int sym12 = id9 + 3*(id11 + 3*(id8 + 3*(id7 + 3*(id6 + 3*(id5 + 3*(id4 + 3*(id3 + 3*(id2 + 3*(id1 + 3*(id10 + 3*id0))))))))));
															int patternNeg12 = id0Neg + 3*(id10Neg + 3*(id1Neg + 3*(id2Neg + 3*(id3Neg + 3*(id4Neg + 3*(id5Neg + 3*(id6Neg + 3*(id7Neg + 3*(id8Neg + 3*(id11Neg + 3*id9Neg))))))))));
															int symNeg12 = id9Neg + 3*(id11Neg + 3*(id8Neg + 3*(id7Neg + 3*(id6Neg + 3*(id5Neg + 3*(id4Neg + 3*(id3Neg + 3*(id2Neg + 3*(id1Neg + 3*(id10Neg + 3*id0Neg))))))))));

															for( iStage = START; iStage < END; iStage++) {
																int bValue = (int)round(coeff[iStage][id_edge_2XC]*16);
																
																BLACK_EDGE_2XC[iStage][pattern12] = bValue;
																BLACK_EDGE_2XC[iStage][sym12] = bValue;
																
																WHITE_EDGE_2XC[iStage][patternNeg12] = bValue;
																WHITE_EDGE_2XC[iStage][symNeg12] = bValue;
															}
															
															flag12[sym12] = true;																				
															
															id_edge_2XC++;
														}

													}
													
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		
		
		fclose( coeff_file );
		
		
		//destruction
		for( iStage = START; iStage <= END; iStage++)
			if (coeff[iStage])
			   free(coeff[iStage]);
		
	}

}


pascal void edmond_release_coefficients() {

  int iStage;


  // liberation de la memoire
  for( iStage = START; iStage < END; iStage++) {
			
			if (BLACK_DIAG_5[iStage])     free(BLACK_DIAG_5[iStage]);
			if (BLACK_DIAG_6[iStage])     free(BLACK_DIAG_6[iStage]);
			if (BLACK_DIAG_7[iStage])     free(BLACK_DIAG_7[iStage]);
			if (BLACK_DIAG_8[iStage])     free(BLACK_DIAG_8[iStage]);
			if (BLACK_HV_4[iStage])       free(BLACK_HV_4[iStage]);
			if (BLACK_HV_3[iStage])       free(BLACK_HV_3[iStage]);
			if (BLACK_HV_2[iStage])       free(BLACK_HV_2[iStage]);
			if (BLACK_EDGE_6_4[iStage])   free(BLACK_EDGE_6_4[iStage]);
			if (BLACK_CORNER_2x5[iStage]) free(BLACK_CORNER_2x5[iStage]);
			if (BLACK_CORNER_11[iStage])  free(BLACK_CORNER_11[iStage]);
			if (BLACK_EDGE_2XC[iStage])   free(BLACK_EDGE_2XC[iStage]);
			
			if (WHITE_DIAG_5[iStage])     free(WHITE_DIAG_5[iStage]);
			if (WHITE_DIAG_6[iStage])     free(WHITE_DIAG_6[iStage]);
			if (WHITE_DIAG_7[iStage])     free(WHITE_DIAG_7[iStage]);
			if (WHITE_DIAG_8[iStage])     free(WHITE_DIAG_8[iStage]);
			if (WHITE_HV_4[iStage])       free(WHITE_HV_4[iStage]);
			if (WHITE_HV_3[iStage])       free(WHITE_HV_3[iStage]);
			if (WHITE_HV_2[iStage])       free(WHITE_HV_2[iStage]);
			if (WHITE_EDGE_6_4[iStage])   free(WHITE_EDGE_6_4[iStage]);
			if (WHITE_CORNER_2x5[iStage]) free(WHITE_CORNER_2x5[iStage]);
			if (WHITE_CORNER_11[iStage])  free(WHITE_CORNER_11[iStage]);
			if (WHITE_EDGE_2XC[iStage])   free(WHITE_EDGE_2XC[iStage]);
			
		}


  // effacement des alias de pointeurs
  for( iStage = 0; iStage < 64; iStage++) {

      BLACK_DIAG_5[iStage] = NULL;
			BLACK_DIAG_6[iStage] = NULL;
			BLACK_DIAG_7[iStage] = NULL;
			BLACK_DIAG_8[iStage] = NULL;
			BLACK_HV_4[iStage] = NULL;
			BLACK_HV_3[iStage] = NULL;
			BLACK_HV_2[iStage] = NULL;
			BLACK_EDGE_6_4[iStage] = NULL;
			BLACK_CORNER_2x5[iStage] = NULL;
			BLACK_CORNER_11[iStage] = NULL;
			BLACK_EDGE_2XC[iStage] = NULL;
			
			WHITE_DIAG_5[iStage] = NULL;
			WHITE_DIAG_6[iStage] = NULL;
			WHITE_DIAG_7[iStage] = NULL;
			WHITE_DIAG_8[iStage] = NULL;
			WHITE_HV_4[iStage] = NULL;
			WHITE_HV_3[iStage] = NULL;
			WHITE_HV_2[iStage] = NULL;
			WHITE_EDGE_6_4[iStage] = NULL;
			WHITE_CORNER_2x5[iStage] = NULL;
			WHITE_CORNER_11[iStage] = NULL;
			WHITE_EDGE_2XC[iStage] = NULL;
			
    }

}


/* verification que la taille des types correspond en Pascal et en C */

pascal int size_of_float_in_c()  { return (sizeof(float)); }
pascal int size_of_int_in_c()   { return (sizeof(int)); }


/* export des pointeurs des tables pour pouvoir les utiliser dans Cassio */

pascal int* edmond_get_black_diag_5_pointer(int stage) { return (BLACK_DIAG_5[stage]); }
pascal int* edmond_get_white_diag_5_pointer(int stage) { return (WHITE_DIAG_5[stage]); }

pascal int* edmond_get_black_diag_6_pointer(int stage) { return (BLACK_DIAG_6[stage]); }
pascal int* edmond_get_white_diag_6_pointer(int stage) { return (WHITE_DIAG_6[stage]); }

pascal int* edmond_get_black_diag_7_pointer(int stage) { return (BLACK_DIAG_7[stage]); }
pascal int* edmond_get_white_diag_7_pointer(int stage) { return (WHITE_DIAG_7[stage]); }

pascal int* edmond_get_black_diag_8_pointer(int stage) { return (BLACK_DIAG_8[stage]); }
pascal int* edmond_get_white_diag_8_pointer(int stage) { return (WHITE_DIAG_8[stage]); }

pascal int* edmond_get_black_hv_4_pointer(int stage) { return (BLACK_HV_4[stage]); }
pascal int* edmond_get_white_hv_4_pointer(int stage) { return (WHITE_HV_4[stage]); }

pascal int* edmond_get_black_hv_3_pointer(int stage) { return (BLACK_HV_3[stage]); }
pascal int* edmond_get_white_hv_3_pointer(int stage) { return (WHITE_HV_3[stage]); }

pascal int* edmond_get_black_hv_2_pointer(int stage) { return (BLACK_HV_2[stage]); }
pascal int* edmond_get_white_hv_2_pointer(int stage) { return (WHITE_HV_2[stage]); }

pascal int* edmond_get_black_edge_6_4_pointer(int stage) { return (BLACK_EDGE_6_4[stage]); }
pascal int* edmond_get_white_edge_6_4_pointer(int stage) { return (WHITE_EDGE_6_4[stage]); }

pascal int* edmond_get_black_corner_2x5_pointer(int stage) { return (BLACK_CORNER_2x5[stage]); }
pascal int* edmond_get_white_corner_2x5_pointer(int stage) { return (WHITE_CORNER_2x5[stage]); }

pascal int* edmond_get_black_corner_11_pointer(int stage) { return (BLACK_CORNER_11[stage]); }
pascal int* edmond_get_white_corner_11_pointer(int stage) { return (WHITE_CORNER_11[stage]); }

pascal int* edmond_get_black_edge_2XC_pointer(int stage) { return (BLACK_EDGE_2XC[stage]); }
pascal int* edmond_get_white_edge_2XC_pointer(int stage) { return (WHITE_EDGE_2XC[stage]); }
























