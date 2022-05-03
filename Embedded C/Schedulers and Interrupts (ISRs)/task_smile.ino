/* University of Washington
 * ECE/CSE 474,  2/25/2022
 *
 *   Brian Dallaire
 *   Erik Michel
 *
 *   Lab 3: Schedulers and Interupts
 *
 */

#include "globals.h"
#include "task_smile.h"
/**************************************************************
 *              MACRO INITIALIZATIONS
 **************************************************************/
#define REFRESH_TIME 20 // time taken to update 7-seg display fully



/**************************************************************
 *                        FUNCTIONS
 **************************************************************/
void displaySmile() {
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 2 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 0) {
    LED_clear(); // clear all LED's

    // turn on digit 4 and apply proper segments
    dig4_on();
    R1_on();
    M_on();
    L2_on();

    // turn off digit all others digits
    dig3_off();
    dig2_off();
    dig1_off();
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 5 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 2) {
    dig4_off(); // turn off digit 4
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 7 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 5) {
    LED_clear(); // clear all LED's
    
    // turn on digit 3 and apply proper segments for smile
    dig3_on();
    T_on();
    B_on();
    
    // turn off digit all others digits
    dig4_off();
    dig2_off();
    dig1_off(); 
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 10 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 7) {
    dig3_off(); // turn off digit 3
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 12 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 10) {
    LED_clear(); // clear all LED's
    
    // turn on digit 3 and apply proper segments for smile
    dig2_on();
    T_on();
    B_on();

    // turn off digit all others digits
    dig4_off();
    dig3_off();
    dig1_off();
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 15 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 12) {
    dig2_off(); // turn off digit 2
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 17 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 15) {
    LED_clear(); // clear all LED's

    // turn on digit 3 and apply proper segments for smile
    dig1_on();
    L1_on();
    M_on();
    R2_on();

    // turn off digit all others digits
    dig4_off();
    dig3_off();
    dig2_off();
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 20 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 17) {
    dig1_off(); // turn off digit 1
  } 
}
