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
#include "task_1.h"
#include "task_2.h"
#include "task_3.h"
#include "task_4.h"

int countdown = 0;
int check1 = 0;

void task5() {
  if (TaskList[taskIndex].time_ran >= 18000 && TaskList[taskIndex].time_ran < 21000) {
    TaskList[1].state = DEAD;  
    TaskList[1].time_ran = 0;  
    countDown_2();
  }
  
  if (TaskList[taskIndex].time_ran >= 21000 && TaskList[taskIndex].time_ran < 30000) {
    if (check1 == 0) {
      TaskList[1].state = READY; 
      check1 = 1; 
    }
    if (TaskList[taskIndex].time_ran >= 26000) {
      TaskList[1].state = DEAD; 
    }
  }
  
  if (TaskList[taskIndex].time_ran >= 30000 && TaskList[taskIndex].time_ran < 32000) {
     displaySmile();
  }
}



void countDown_2() {
  unsigned long taskElapsed = TaskList[taskIndex].time_ran % 3000;
  
  digitUpdater(ahead_2/100);
  if (TaskList[taskIndex].time_ran % 20 < 2 && TaskList[taskIndex].time_ran % 20 >= 0) {
    LED_clear(); // clear all LED's
    
    // turn on digit 4 and apply proper segments
    dig4_on();
    DIG4.dispNum();
    
    // turn off digit all others digits
    dig3_off();
    dig2_off();
    dig1_off();
  } 
  if (TaskList[taskIndex].time_ran % 20 < 5 && TaskList[taskIndex].time_ran % 20 >= 2) {
    dig4_off(); // turn off digit 4
  } 
  if (TaskList[taskIndex].time_ran % 20 < 7 && TaskList[taskIndex].time_ran % 20 >= 5) {
    LED_clear(); // clear all LED's
    
    // turn on digit 3 and apply proper segments
    dig3_on();
    DIG3.dispNum();
    
    // turn off digit all others digits
    dig4_off();
    dig2_off();
    dig1_off(); 
  } 
  if (TaskList[taskIndex].time_ran % 20 < 10 && TaskList[taskIndex].time_ran % 20 >= 7) {
    dig3_off(); // turn off digit 3
  } 
  if (TaskList[taskIndex].time_ran % 20 < 12 && TaskList[taskIndex].time_ran % 20 >= 10) {
    LED_clear(); // clear all LED's
    
    // turn on digit 2 and apply proper segments
    dig2_on();
    DIG2.dispNum();
    
    // turn off digit all others digits
    dig4_off();
    dig3_off();
    dig1_off();
  } 
  if (TaskList[taskIndex].time_ran % 20 < 15 && TaskList[taskIndex].time_ran % 20 >= 12) {
    dig2_off(); // turn off digit 2
  } 
  if (TaskList[taskIndex].time_ran % 20 < 17 && TaskList[taskIndex].time_ran % 20 >= 15) {
    LED_clear(); // clear all LED's
    
    // turn on digit 1 and apply proper segments
    dig1_on();
    DIG1.dispNum();
    
    // turn off digit all others digits
    dig4_off();
    dig3_off();
    dig2_off();
  } 
  if (TaskList[taskIndex].time_ran % 20 < 20 && TaskList[taskIndex].time_ran % 20 >= 17) {
    dig1_off(); // turn off digit 1
  } 

  if (taskElapsed >= 0) {
    if (ahead_2 >= 0) {
      ahead_2 = (3000 - taskElapsed); 
    } else {
      countdown = 0;
    }
  }

}
