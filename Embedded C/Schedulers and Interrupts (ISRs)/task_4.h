/* University of Washington
 * ECE/CSE 474,  2/25/2022
 *
 *   Brian Dallaire
 *   Erik Michel
 *
 *   Lab 3: Schedulers and Interupts
 *
 */

#ifndef TASK_4_H
#define TASK_4_H

#include "globals.h"

/**************************************************************
 *              FUNCTION PROTOTYPES
 **************************************************************/

/*
 * @brief task that plays alternating tones every second, for 5 seconds,
 * while displaying the frequency of the tone being played, and pauses audio
 * for 4 seconds while displaying the amount of time left until audio resumes
 * via 7-seg display
 */
void task4();

/*
 * @brief function used to decrease values appearing on 7-seg display, beginning
 * at 4 seconds worth of time
 */
void countDown();


/*
 * @brief function that facilitates process of displaying the current frequency 
 * being output from the speaker
 * 
 * @param OCRnX_val: current OCR4A value to be converted to a frequency
 */
void freq_display(int index);









#endif
