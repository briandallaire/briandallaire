/* University of Washington
 * ECE/CSE 474,  2/25/2022
 *
 *   Brian Dallaire
 *   Erik Michel
 *
 *   Lab 3: Schedulers and Interupts
 *
 */

#ifndef TASK_3_H
#define TASK_3_H

#include "globals.h"

/**************************************************************
 *              FUNCTION PROTOTYPES
 **************************************************************/
/*
 * @brief updates function pointer of each digit (1-4) struct that
 * determines which number is to be displayed on which digit of the 
 * 7-seg display
 * 
 * @param timeVal: time value to be converted into digits on the 7-seg display
 */
void digitUpdater(unsigned long timeVal);


/*
 * @brief task that makes 7-seg display count up by 1 unit every 100ms
 */
void task3();

/*
 * @brief sets up digital outputs for seg-7 display using port manipulation
 */
void task_3_setup();

/*
 * @defgroup digit_control
 * @brief functions for controlling digits being on or off through port manipulation
 * 
 * @{
 */
void dig4_on();
void dig4_off();

void dig3_on();
void dig3_off();

void dig2_on();
void dig2_off();

void dig1_on();
void dig1_off();
/*
 * @} // end of digit_control 
 */


/*
 * @defgroup segment_control 
 * @brief functions for enabling/disabling LED segments of the 7-segment display
 * @{
 */
void L1_on();
void L1_off();

void L2_on();
void L2_off();

void B_on();
void B_off();

void R1_on();
void R1_off();

void R2_on();
void R2_off();

void T_on();
void T_off();

void M_on();
void M_off();
/*
 * @} // end of segment_control
 */


/*
 * @defgroup number_display 
 * @brief functions for setting digit segments to display a given value
 * @{
 */
void LED_clear();
void LED_0();
void LED_1();
void LED_2();
void LED_3();
void LED_4();
void LED_5();
void LED_6();
void LED_7();
void LED_8();
void LED_9();
/*
 * @} // end of number_display
 */

/*
 * @brief determines how many digits will be needed to display a value on the 7-seg display
 * 
 * @param val: value to be checked to see how many digits are needed to display on 7-seg
 * 
 * @return a value in the range 0-4 that is the number of digits needed to display input val
 */
int digitAmt(int val);

struct digit; //!< struct for easily setting desired output for each 7-seg digit

#endif
