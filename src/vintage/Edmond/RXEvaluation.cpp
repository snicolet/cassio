/*
 *  RXEvaluation.cpp
 *  Roxane
 *
 *  Created by Bruno Causse on 06/08/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include <fstream>
#include <cmath>

#include "RXEvaluation.h"


int* RXEvaluation::BLACK_DIAG_5[61];
int* RXEvaluation::WHITE_DIAG_5[61];

int* RXEvaluation::BLACK_DIAG_6[61];
int* RXEvaluation::WHITE_DIAG_6[61];

int* RXEvaluation::BLACK_DIAG_7[61];
int* RXEvaluation::WHITE_DIAG_7[61];

int* RXEvaluation::BLACK_DIAG_8[61];
int* RXEvaluation::WHITE_DIAG_8[61];

int* RXEvaluation::BLACK_HV_4[61];
int* RXEvaluation::WHITE_HV_4[61];

int* RXEvaluation::BLACK_HV_3[61];
int* RXEvaluation::WHITE_HV_3[61];

int* RXEvaluation::BLACK_HV_2[61];
int* RXEvaluation::WHITE_HV_2[61];

int* RXEvaluation::BLACK_EDGE_6_4[61];
int* RXEvaluation::WHITE_EDGE_6_4[61];

int* RXEvaluation::BLACK_CORNER_2x5[61];
int* RXEvaluation::WHITE_CORNER_2x5[61];

int* RXEvaluation::BLACK_CORNER_11[61];
int* RXEvaluation::WHITE_CORNER_11[61];

int* RXEvaluation::BLACK_EDGE_2XC[61];
int* RXEvaluation::WHITE_EDGE_2XC[61];

void RXEvaluation::load() {

	const unsigned int START = 16;
	const unsigned int END = 57;
	
	//std::ifstream from("Coefficients.bin", std::ios::binary); //Rostand
	std::ifstream from("../Coefficients.bin", std::ios::binary); //Edmond
	if(from) {

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

		//chargement des données
		float* coeff[61];
		for(int iStage = START; iStage<END; iStage++) {
			coeff[iStage] = new float[n_instances];
			from.read((char*)coeff[iStage], sizeof(float)*n_instances);
		}
		
		// creation des tables
		
		for(int iStage = START; iStage<END; iStage++) {
			
			BLACK_DIAG_5[iStage] = new int[243];
			BLACK_DIAG_6[iStage] = new int[729];
			BLACK_DIAG_7[iStage] = new int[2187];
			BLACK_DIAG_8[iStage] = new int[6561];
			BLACK_HV_4[iStage] = new int[6561];
			BLACK_HV_3[iStage] = new int[6561];
			BLACK_HV_2[iStage] = new int[6561];
			BLACK_EDGE_6_4[iStage] = new int[59049];
			BLACK_CORNER_2x5[iStage] = new int[59049];
			BLACK_CORNER_11[iStage] = new int[177147];
			BLACK_EDGE_2XC[iStage] = new int[531441];

			WHITE_DIAG_5[iStage] = new int[243];
			WHITE_DIAG_6[iStage] = new int[729];
			WHITE_DIAG_7[iStage] = new int[2187];
			WHITE_DIAG_8[iStage] = new int[6561];
			WHITE_HV_4[iStage] = new int[6561];
			WHITE_HV_3[iStage] = new int[6561];
			WHITE_HV_2[iStage] = new int[6561];
			WHITE_EDGE_6_4[iStage] = new int[59049];
			WHITE_CORNER_2x5[iStage] = new int[59049];
			WHITE_CORNER_11[iStage] = new int[177147];
			WHITE_EDGE_2XC[iStage] = new int[531441];
			
		}
	
	// recopie des extremité
	
		//du stage 0 à START
		for(int iStage = 0; iStage<START; iStage++) {

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
		
		//du Stage END à 61
		for(int iStage = END; iStage<61; iStage++) {

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

		
		
		//flag de patterns traités
		bool flag_8[6561];
		bool flag10[59049];
		bool flagD7[2187];
		bool flagD6[729];
		bool flagD5[243];
		bool flagC11[177147];
		bool flag12[531441];

		for(int pos0 = 0; pos0<3; pos0++) {

			for(int pos1 = 0; pos1<3; pos1++) {
				int id2 = pos1 + 3*pos0;
				for(int pos2 = 0; pos2<3; pos2++) {
					int id3 = pos2 + 3*id2;
					for(int pos3 = 0; pos3<3; pos3++) {
						int id4 = pos3 + 3*id3;
						for(int pos4 = 0; pos4<3; pos4++) {
							int id5 = pos4 + 3*id4;
							flagD5[id5] = false;
							for(int pos5 = 0; pos5<3; pos5++) {
								int id6 = pos5 + 3*id5;
								flagD6[id6] = false;
								for(int pos6 = 0; pos6<3; pos6++) {
									int id7 = pos6 + 3*id6;
									flagD7[id7] = false;
									for(int pos7 = 0; pos7<3; pos7++) {
										int id8 = pos7 + 3*id7;
										flag_8[id8] = false;
										for(int pos8 = 0; pos8<3; pos8++) {
											int id9 = pos8 + 3*id8;
											for(int pos9 = 0; pos9<3; pos9++) {
												int idA = pos9 + 3* id9;
												flag10[idA] = false;
												for(int posA = 0; posA<3; posA++) {
													int idB = posA + 3*idA;
													flagC11[idB] = false;
													for(int posB = 0; posB<3; posB++)
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
		 for(int id0 = 0, id0Neg = 0; id0<3; id0Neg = 3 - (++id0)) {

			 for(int id1 = 0, id1Neg = 0; id1<3; id1Neg = 3 - (++id1)) {

				 for(int id2 = 0, id2Neg = 0; id2<3; id2Neg = 3-(++id2)) {
				
					 for(int id3 = 0, id3Neg = 0; id3<3; id3Neg = 3 - (++id3)) {
					 
						//4 squares = Diag4
						int pattern4 = id0 + 3*(id1 + 3*(id2 + 3*id3));
						int sym4 = id3 + 3*(id2 + 3*(id1 + 3*id0));
						int patternNeg4 = id0Neg + 3*(id1Neg + 3*(id2Neg + 3*id3Neg));
						int symNeg4 = id3Neg + 3*(id2Neg + 3*(id1Neg + 3*id0Neg));
						
						 for(int id4 = 0, id4Neg = 0; id4<3; id4Neg = 3 - (++id4)) {
						 
							//5 squares = Diag5
							int pattern5 = pattern4 + 81*id4;
							int sym5 = id4 + 3*sym4 ;
							int patternNeg5 = patternNeg4 + 81*id4Neg;
							int symNeg5 = id4Neg + 3*symNeg4;
							

							if(flagD5[pattern5] == false) {										
								
								for(int iStage = START; iStage<END; iStage++) {
									int bValue = (int)round(coeff[iStage][id_diag_5]*16);
									
									BLACK_DIAG_5[iStage][pattern5] = bValue;
									BLACK_DIAG_5[iStage][sym5] = bValue;

									WHITE_DIAG_5[iStage][patternNeg5] = bValue;
									WHITE_DIAG_5[iStage][symNeg5] = bValue;
								}
								
								id_diag_5++;

								flagD5[sym5] = true;
									
							}

							 for(int id5 = 0, id5Neg = 0; id5<3;id5Neg = 3 - (++id5)) {

								//6 squares = Diag6
								int pattern6 = pattern5 + 243*id5;
								int sym6 = id5 + 3*sym5 ;
								int patternNeg6 = patternNeg5 + 243*id5Neg;
								int symNeg6 = id5Neg + 3*symNeg5;
							
								if(flagD6[pattern6] == false) {										
									
									for(int iStage = START; iStage<END; iStage++) {
										int bValue = (int)round(coeff[iStage][id_diag_6]*16);
										
										BLACK_DIAG_6[iStage][pattern6] = bValue;
										BLACK_DIAG_6[iStage][sym6] = bValue;

										WHITE_DIAG_6[iStage][patternNeg6] = bValue;
										WHITE_DIAG_6[iStage][symNeg6] = bValue;
									}

									id_diag_6++;

									flagD6[sym6] = true;
									
								}

								 for(int id6 = 0, id6Neg = 0; id6<3; id6Neg = 3-(++id6 )) {

									//7 squares = Diag7
									int pattern7 = pattern6 + 729*id6;
									int sym7 = id6 + 3*sym6 ;
									int patternNeg7 = patternNeg6 + 729*id6Neg;
									int symNeg7 = id6Neg + 3*symNeg6;
									

									if(flagD7[pattern7] == false) {										
										
										for(int iStage = START; iStage<END; iStage++) {
											int bValue = (int)round(coeff[iStage][id_diag_7]*16);
											
											BLACK_DIAG_7[iStage][pattern7] = bValue;
											BLACK_DIAG_7[iStage][sym7] = bValue;

											WHITE_DIAG_7[iStage][patternNeg7] = bValue;
											WHITE_DIAG_7[iStage][symNeg7] = bValue;
										}
											
										id_diag_7++;
										
										flagD7[sym7] = true;
										
									}

									 for(int id7 = 0, id7Neg = 0; id7<3; id7Neg = 3-(++id7)) {

										//8 squares = Diag8 + Edge + Hor1 + Hor2 + Hor3
										int pattern8 = pattern7 + 2187*id7;
										int sym8 = id7 + 3*sym7 ;
										int patternNeg8 = patternNeg7 + 2187*id7Neg;
										int symNeg8 = id7Neg + 3*symNeg7;
										

										if(flag_8[pattern8] == false) {										
											
											for(int iStage = START; iStage<END; iStage++) {
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
										
										
										 for(int id8 = 0, id8Neg = 0; id8<3; id8Neg = 3-(++id8 )) {
										 

											//9 squares
											int pattern9 = pattern8 + 6561*id8;
											int sym9 = id8 + 3*sym8;
											int patternNeg9 = patternNeg8 + 6561*id8Neg;
											int symNeg9 = id8Neg + 3*symNeg8;

											 for(int id9 = 0, id9Neg = 0; id9<3; id9Neg = 3-(++id9)) {
											 
												//10 squares
												int pattern10 = pattern9 + 19683*id9;
												int sym10 = id9 + 3*sym9 ;
												int patternNeg10 = patternNeg9 + 19683*id9Neg;
												int symNeg10 = id9Neg + 3*symNeg9;

												if(flag10[pattern10] == false) {
																									
													for(int iStage = START; iStage<END; iStage++) {
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
												for(int iStage = START; iStage<END; iStage++) {
													BLACK_CORNER_2x5[iStage][pattern10] = (int)round(coeff[iStage][id_corner_2x5]*16);

													WHITE_CORNER_2x5[iStage][patternNeg10] = (int)round(coeff[iStage][id_corner_2x5]*16);
												}
												id_corner_2x5++;

												 for(int id10 = 0, id10Neg = 0; id10<3; id10Neg = 3-(++id10)) {

													//11 Squares
													int pattern11 = pattern10 + 59049*id10;
									
													if(flagC11[pattern11] == false) {
																						
														int sym11 = (((((((((id10*3 + id1)*3 + id2)*3 + id3)*3 + id4)*3 + id5)*3 + id6)*3 + id7)*3 + id8)*3 + id9)*3 +id0;
														int patternNeg11 = patternNeg10 + 59049*id10Neg;
														int symNeg11 = (((((((((id10Neg*3 + id1Neg)*3 + id2Neg)*3 + id3Neg)*3 + id4Neg)*3 + id5Neg)*3 + id6Neg)*3 + id7Neg)*3 + id8Neg)*3 + id9Neg)*3 +id0Neg;
														
														for(int iStage = START; iStage<END; iStage++) {
															int bValue = (int)round(coeff[iStage][id_corner_11]*16);
															
															BLACK_CORNER_11[iStage][pattern11] = bValue;
															BLACK_CORNER_11[iStage][sym11] = bValue;
															
															WHITE_CORNER_11[iStage][patternNeg11] = bValue;
															WHITE_CORNER_11[iStage][symNeg11] = bValue;
														}

														id_corner_11++;
														
														flagC11[sym11] = true;
																											
													}

													for(int id11 = 0, id11Neg = 0; id11<3; id11Neg = 3-(++id11)) {
														//12 squares
														int pattern12 = id0 + 3*(id10 + 3*(id1 + 3*(id2 + 3*(id3 + 3*(id4 + 3*(id5 + 3*(id6 + 3*(id7 + 3*(id8 + 3*(id11 + 3*id9))))))))));
																												
														if(flag12[pattern12] == false) {
														
															int sym12 = id9 + 3*(id11 + 3*(id8 + 3*(id7 + 3*(id6 + 3*(id5 + 3*(id4 + 3*(id3 + 3*(id2 + 3*(id1 + 3*(id10 + 3*id0))))))))));
															int patternNeg12 = id0Neg + 3*(id10Neg + 3*(id1Neg + 3*(id2Neg + 3*(id3Neg + 3*(id4Neg + 3*(id5Neg + 3*(id6Neg + 3*(id7Neg + 3*(id8Neg + 3*(id11Neg + 3*id9Neg))))))))));
															int symNeg12 = id9Neg + 3*(id11Neg + 3*(id8Neg + 3*(id7Neg + 3*(id6Neg + 3*(id5Neg + 3*(id4Neg + 3*(id3Neg + 3*(id2Neg + 3*(id1Neg + 3*(id10Neg + 3*id0Neg))))))))));

															for(int iStage = START; iStage<END; iStage++) {
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
		
		//destruction
		for(int iStage = START; iStage<=END; iStage++)
			delete[] coeff[iStage];
		
	}

}

