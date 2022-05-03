/* University of Washington
 * ECE/CSE 474,  2/25/2022
 *
 *   Brian Dallaire
 *   Erik Michel
 *
 *   Lab 3: Schedulers and Interupts
 *
 */

#include "task_1.h"

/**************************************************************
 *              MACRO INITIALIZATIONS
 **************************************************************/ 
#define LED_PIN (1<<PC3) // Arduino pin 34, Blue LED
#define LED_ON_TIME    250   // time in ms that LED is ON
#define LED_OFF_TIME   750   // time in ms that LED is OFF
#define TASK_TIME      1000  // time in ms needed to complete a full task cycle

#define LED_PIN 1<<PC3 // Arduino pin 34, Blue LED

/**************************************************************
 *              VARIABLE DECLARATIONS
 **************************************************************/
unsigned long task_Elapsed_1 = 0; //!< elapsed time of current task cycle in RR scheduler



/**************************************************************
 *                        FUNCTIONS
 **************************************************************/
void task1() {
  if (CURRENT_SCHEDULER == RR) {
    totalTime = millis();
    unsigned long task_Elapsed_1 = totalTime % TASK_TIME; 
    if (task_Elapsed_1 <= LED_ON_TIME) {
      PORTC = bitsOff(PORTC, LED_PIN);
    } else if (task_Elapsed_1 <= TASK_TIME) {
      PORTC = bitsOn(PORTC, LED_PIN);
    }
  } else if (CURRENT_SCHEDULER == SRRI){
      //Serial.println(timeTask[taskIndex]);
      if(timeTask[taskIndex] < LED_ON_TIME){
        PORTC = bitsOff(PORTC, LED_PIN);
        sleepUpdate(LED_ON_TIME);
        return;
      }
    
      if(timeTask[taskIndex] < LED_OFF_TIME){
        PORTC = bitsOn(PORTC, LED_PIN);
        sleepUpdate(LED_OFF_TIME);
        return;
      }
    
      if(timeTask[taskIndex] >= LED_ON_TIME + LED_OFF_TIME){
        timeTask[taskIndex] = ZERO;
      }
  } else if (CURRENT_SCHEDULER == DDS){
    if(TaskList[taskIndex].time_ran < LED_ON_TIME){
      PORTC = bitsOff(PORTC, LED_PIN);
      sleepUpdate(LED_ON_TIME);
      return;
    }
  
    if(TaskList[taskIndex].time_ran < LED_OFF_TIME){
      PORTC = bitsOn(PORTC, LED_PIN);
      sleepUpdate(LED_OFF_TIME);
      return;
    }
  
    if( TaskList[taskIndex].time_ran >= LED_ON_TIME + LED_OFF_TIME){
      TaskList[taskIndex].time_ran = ZERO;
    }
  } 
  return;
}

void task_1_setup() {
  DDRC = bitsOn(DDRC, LED_PIN);
}
