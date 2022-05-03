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
#include "task_4.h"
#include "task_3.h"

/**************************************************************
 *              MACRO INITIALIZATIONS
 **************************************************************/
#define FREQ_AMOUNT 5
 
#define D4 293
#define E4 329
#define C4 261
#define C3 130
#define G3 196

#define MAX_TIME 9000 // time spent in one cycle of task 2
#define TONES_END 5000 // time in ms when tones stop playing in task 2
#define COUNTDOWN_START 4000 // time at which countdown begins

#define REFRESH_TIME 20 // time taken to update 7-seg display fully

/**************************************************************
 *              VARIABLE DECLARATIONS
 **************************************************************/
int freqs[FREQ_AMOUNT] = {D4, E4, C4, C3, G3}; // array that holds values of frequencies



/**************************************************************
 *                        FUNCTIONS
 **************************************************************/
void task4() {
      // play tones
      for(int i = 0; i < FREQ_AMOUNT; i++){
        unsigned long highTime = TONE_DURATION * ((unsigned long) i + 1);
        if(TaskList[taskIndex].time_ran < highTime){
          TCCR4A |= (1<<COM4A0);
          updateFreq(melody[i]);
          freq_display(i);
          sleepUpdate(TONE_DURATION);
          return;
        }
      }
    
      // stop playingg for 4 seconds
      if(TaskList[taskIndex].time_ran < TASK_TIME){
        TCCR4A &= !(1<<COM4A0);
        countDown();
        sleepUpdate(SILENT_TIME);
        return;
      }

      // after a cycle of task 4 has passed, reset time_ran
      if(TaskList[taskIndex].time_ran >= TASK_TIME){
        TaskList[taskIndex].time_ran = ZERO;
      } 
}

void countDown() {
  // time from 0 to 9000 
  unsigned long taskElapsed = TaskList[taskIndex].time_ran % MAX_TIME;
  
  digitUpdater(ahead/100);
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 2 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 0) {
    LED_clear(); // clear all LED's
    
    // turn on digit 4 and apply proper segments
    dig4_on();
    DIG4.dispNum();

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

    // turn on digit 3 and apply proper segments
    dig3_on();
    DIG3.dispNum();

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

    // turn on digit 2 and apply proper segments
    dig2_on();
    DIG2.dispNum();

    // turn off digit all others digits
    dig4_off();
    dig3_off();
    dig1_off();
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 15 && TaskList[taskIndex].time_ran % 20 >= 12) {
    dig2_off(); // turn off digit 2
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 17 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 15) {
    LED_clear(); // clear all LED's

    // turn on digit 1 and apply proper segments
    dig1_on();
    DIG1.dispNum();

    // turn off digit all others digits
    dig4_off();
    dig3_off();
    dig2_off();
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 20 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 17) {
    dig1_off(); // turn off digit 1
  } 

  if (taskElapsed >= TONES_END) {
    if (ahead >= 0) {
      ahead = (MAX_TIME - taskElapsed); 
    } else {
      ahead = COUNTDOWN_START;
    }
  }

}

void freq_display(int index) {
  freq = freqs[index]; // current frequency to display

  digitUpdater(freq);
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 2 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 0) {
    LED_clear(); // clear all LED's

    // turn on digit 4 and apply proper segments
    dig4_on();
    DIG4.dispNum();

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

    // turn on digit 3 and apply proper segments
    dig3_on();
    DIG3.dispNum();

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

    // turn on digit 2 and apply proper segments
    dig2_on();
    DIG2.dispNum();

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

    // turn on digit 1 and apply proper segments
    dig1_on();
    DIG1.dispNum();

    // turn off digit all others digits
    dig4_off();
    dig3_off();
    dig2_off();
  } 
  if (TaskList[taskIndex].time_ran % REFRESH_TIME < 20 && TaskList[taskIndex].time_ran % REFRESH_TIME >= 17) {
    dig1_off(); // turn off digit 1
  } 
}
