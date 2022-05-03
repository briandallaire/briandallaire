/* University of Washington
 * ECE/CSE 474,  2/25/2022
 *
 *   Brian Dallaire
 *   Erik Michel
 *
 *   Lab 3: Schedulers and Interupts
 *
 */
 
#include "task_2.h"
/**************************************************************
 *              MACRO INITIALIZATIONS
 **************************************************************/
#define SPEAK_PIN (1<<PH3)    // Arduino pin 6, 8-Ohm speaker

#define COM_BIT   (1<<COM4A0) // Compare output mode bit
#define PRESC_BIT (1<<CS42)   // Prescaler bit
#define WGM_BIT   (1<<WGM42)  // Waveform generation bit

#define D4 106 // 293Hz
#define E4 79  // 329Hz
#define C4 119 // 261Hz
#define C3 239 // 130hz
#define G3 158 // 196Hz

#define TONE_DURATION 1000 // time in ms that each melody[] tone plays for CANT BE LESS THAN 1000
#define SILENT_TIME 4000

#define SONG_TIME   (melodySize*TONE_DURATION)
#define TASK_TIME   (SONG_TIME+SILENT_TIME) // time song takes + 4000ms (4s) delay

#define TONE_AMOUNT 5


/**************************************************************
 *              VARIABLE DECLARATIONS
 **************************************************************/
  // array of tones that form Close Encounters Theme song
int melody[TONE_AMOUNT] = {D4, E4, C4, C3, G3};
int melodySize = sizeof(melody)/sizeof(melody[ZERO]); // amount of elements in melody[] array

int i = ZERO;
int index = ZERO;

unsigned long prevTime = ZERO; // useful for keeping track of time interval passed
unsigned long task_Elapsed_2 = ZERO;

int sound_disable = 0;

/**************************************************************
 *                        FUNCTIONS
 **************************************************************/
void task2() {
  if (CURRENT_SCHEDULER == RR) {
    task_Elapsed_2 = totalTime % TASK_TIME;
    if (task_Elapsed_2 < SONG_TIME) {
      sound_disable = ZERO;
      sound_player();
    } else if (task_Elapsed_2 > SONG_TIME && task_Elapsed_2 <= TASK_TIME) {
      sound_disable = 1;
      sound_player();
    }
  } else if(CURRENT_SCHEDULER == SRRI){
      // play all the tones
      for(int i = 0; i < 5; i++){
        unsigned long highTime = TONE_DURATION * ((unsigned long) i + 1);
        if(timeTask[taskIndex] < highTime){
          TCCR4A = bitsOn(TCCR4A, COM_BIT);
          //TCCR4A |= (1<<COM4A0);
          updateFreq(melody[i]);
          sleepUpdate(TONE_DURATION);
          return;
        }
      }
    
      // stop playing for 4 seconds
      if(timeTask[taskIndex] < TASK_TIME){
        TCCR4A = bitsOff(TCCR4A, COM_BIT);
        sleepUpdate(SILENT_TIME);
        return;
      }

      // reset task time to zero
      if(timeTask[taskIndex] >= TASK_TIME){
        timeTask[taskIndex] = ZERO;
      }
  } else if(CURRENT_SCHEDULER == DDS){
      // go through tones array
      for(int i = 0; i < 5; i++){
        unsigned long playTime = TONE_DURATION * ((unsigned long) i + 1);
        if(TaskList[taskIndex].time_ran < playTime){
          TCCR4A |= (1<<COM4A0);
          updateFreq(melody[i]);
          sleepUpdate(TONE_DURATION);
          return;
        }
      }
    
      // stop playing for 4 seconds
      if(TaskList[taskIndex].time_ran < TASK_TIME){
        TCCR4A &= !(1<<COM4A0);
        sleepUpdate(SILENT_TIME);
        return;
      }

      // reset the time when a task has completed a full cycle and 
      // increment times_started by 1
      if(TaskList[taskIndex].time_ran >= TASK_TIME){
        TaskList[taskIndex].times_started++;
        TaskList[taskIndex].time_ran = ZERO;
      }
  }
}

void sound_player() {
  if (totalTime - prevTime >= TONE_DURATION) {
    prevTime = totalTime;
    i++;
    
    index = i%5;  // for tones[] array

    while(TCNT4>0) {} // wait for Timer Counter 4 to toggle

    if (!sound_disable) {
      TCCR4A = bitsOn(TCCR4A, COM_BIT);TCCR4A |= (1<<COM4A0);  // enable toggling on compare match
      OCR4A = melody[index];   // update output compare register value
    } else { 
      TCCR4A &= !(1<<COM4A0); // enable normal port operation, OC4A disconnected
      i = -1;
    }
    
  }
}

void updateFreq(int C) {
  OCR4A = C;
}

void task_2_setup() {
  DDRH = bitsOn(DDRH, SPEAK_PIN); // Turning on speaker pin
  PRR1 = ZERO; // Set Power Reduction Register to 0 (power on)
  TCCR4A = ZERO; // Set all bits of Timer/Counter 4 Control Register A to zero
  TCCR4B = ZERO; // Set all bits of Timer/Counter 4 Control Register B to zero

  OCR4A = melody[index];
    // ===== TIMER/COUNTER 4 CONTROL REGISTER A =====
    // Compare Output Mode: Toggle OC4A on compare match
  TCCR4A = bitsOn(TCCR4A, COM_BIT); 
                                       
    // ===== TIMER/COUNTER 4 CONTROL REGISTER B =====
    // Prescaler: clk/256 | Waveform generation mode: CTC
  TCCR4B = bitsOn(TCCR4B, PRESC_BIT);
  TCCR4B = bitsOn(TCCR4B, WGM_BIT);
}
