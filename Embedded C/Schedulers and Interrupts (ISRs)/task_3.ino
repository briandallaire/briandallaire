/* University of Washington
 * ECE/CSE 474,  2/25/2022
 *
 *   Brian Dallaire
 *   Erik Michel
 *
 *   Lab 3: Schedulers and Interupts
 *
 */
 
#include "task_3.h"

/**************************************************************
 *              MACRO INITIALIZATIONS
 **************************************************************/
#define SEG_1       (1<<PA0) // Pin 22
#define SEG_2       (1<<PA1) // Pin 23
#define SEG_3       (1<<PA2) // Pin 24
#define SEG_4       (1<<PA3) // Pin 25
#define SEG_5       (1<<PA4) // Pin 26
#define SEG_6_DIG4  (1<<PA5) // Pin 27

#define SEG_7       (1<<PG1) // Pin 40
#define SEG_8_DIG3  (1<<PG0) // Pin 41

#define SEG_9_DIG2  (1<<PL7) // Pin 42
#define SEG_10      (1<<PL6) // Pin 43
#define SEG_11      (1<<PL5) // Pin 44
#define SEG_12_DIG1 (1<<PL4) // Pin 45

#define LED_PIN (1<<PL1) // Arduino pin 48, Blue LED

typedef struct digit {
  void (*dispNum)();//= *fptr[arrIndex];
} digit;

/**************************************************************
 *              VARIABLE DECLARATIONS
 **************************************************************/
unsigned long prevTime_3 = 0; // useful for keeping track of time interval passed

unsigned long prevTime_test= 0;

unsigned long t_track = 0;


long int freq = 0;
struct digit;
int value = 0;
digit DIG1, DIG2, DIG3, DIG4;

void (*fptr[10])() = {LED_0, LED_1, LED_2, LED_3, LED_4, LED_5, LED_6, LED_7, LED_8, LED_9};

/**************************************************************
 *                        FUNCTIONS
 **************************************************************/
void task3() {
  if (CURRENT_SCHEDULER == RR) {
    digitUpdater(totalTime/100);
    if ((totalTime - prevTime_3) <= 2) {
      LED_clear();
      dig4_on();
      DIG4.dispNum();
      
      dig3_off();
      dig2_off();
      dig1_off();
    } else if ((totalTime - prevTime_3) <= 5) {
      //LED_clear();
      dig4_off();
    } else if ((totalTime - prevTime_3) <= 7) {
      LED_clear();
      dig3_on();
      DIG3.dispNum();
      dig4_off();
      
      dig2_off();
      dig1_off(); 
    } else if ((totalTime - prevTime_3) <= 10) {
      //LED_clear();
      dig3_off();
    } else if ((totalTime - prevTime_3) <= 12) {
      LED_clear();
      dig2_on();
      DIG2.dispNum();
      
      dig4_off();
      dig3_off();
      dig1_off();
    } else if ((totalTime - prevTime_3) <= 15) {
      //LED_clear();
      dig2_off();
    } else if ((totalTime - prevTime_3) <= 17) {
      LED_clear();
      dig1_on();
      DIG1.dispNum();
      
      dig4_off();
      dig3_off();
      dig2_off();
    } else if ((totalTime - prevTime_3) <= 20) {
      //LED_clear();
      dig1_off();
    } else {
      prevTime_3 = totalTime;
    }
  } else if (CURRENT_SCHEDULER == SRRI) {
    digitUpdater(timeTask[taskIndex]/100);
    if (timeTask[taskIndex] % 20 < 2 && timeTask[taskIndex] % 20 >= 0) {
      LED_clear();
      dig4_on();
      DIG4.dispNum();
      
      dig3_off();
      dig2_off();
      dig1_off();
      //sleepUpdate();
    } 
    if (timeTask[taskIndex] % 20 < 5 && timeTask[taskIndex] % 20 >= 2) {
      //LED_clear();
      dig4_off();
      //sleepUpdate(5);
    } 
    if (timeTask[taskIndex] % 20 < 7 && timeTask[taskIndex] % 20 >= 5) {
      LED_clear();
      dig3_on();
      DIG3.dispNum();
      
      dig4_off();
      dig2_off();
      dig1_off(); 
      //sleepUpdate(8);
    } 
    if (timeTask[taskIndex] % 20 < 10 && timeTask[taskIndex] % 20 >= 7) {
      //LED_clear();
      dig3_off();
      //sleepUpdate(5);
    } 
    if (timeTask[taskIndex] % 20 < 12 && timeTask[taskIndex] % 20 >= 10) {
      LED_clear();
      dig2_on();
      DIG2.dispNum();
      
      dig4_off();
      dig3_off();
      dig1_off();
      //sleepUpdate(12);
    } 
    if (timeTask[taskIndex] % 20 < 15 && timeTask[taskIndex] % 20 >= 12) {
      //LED_clear();
      dig2_off();
      //sleepUpdate(5);
    } 
    if (timeTask[taskIndex] % 20 < 17 && timeTask[taskIndex] % 20 >= 15) {
      LED_clear();
      dig1_on();
      DIG1.dispNum();
      
      dig4_off();
      dig3_off();
      dig2_off();
      //sleepUpdate(17);
    } 
    if (timeTask[taskIndex] % 20 < 20 && timeTask[taskIndex] % 20 >= 17) {
      //LED_clear();
      dig1_off();
      //sleepUpdate(20);
    } 
    
//    if (timeTask[taskIndex] >= 60000) {
//       timeTask[taskIndex] = 0;
//    }
  }
}

void digitUpdater(unsigned long timeVal) {
  int numSize = digitAmt(timeVal);

  if (numSize == 1) {
    DIG4.dispNum = *fptr[timeVal % 10];
    DIG3.dispNum = *fptr[(timeVal % 100) / 10];
    DIG2.dispNum = *fptr[(timeVal % 1000) / 100];
    DIG1.dispNum = *fptr[(timeVal % 10000) / 1000];
  } else if (numSize == 2) {
    DIG4.dispNum = *fptr[timeVal % 10];
    DIG3.dispNum = *fptr[(timeVal % 100) / 10];
    DIG2.dispNum = *fptr[(timeVal % 1000) / 100];
    DIG1.dispNum = *fptr[(timeVal % 10000) / 1000];
  } else if (numSize == 3) {
    DIG4.dispNum = *fptr[timeVal % 10];
    DIG3.dispNum = *fptr[(timeVal % 100) / 10];
    DIG2.dispNum = *fptr[(timeVal % 1000) / 100];
    DIG1.dispNum = *fptr[(timeVal % 10000) / 1000];
  } else if (numSize == 4) {
    DIG4.dispNum = *fptr[timeVal % 10];
    DIG3.dispNum = *fptr[(timeVal % 100) / 10];
    DIG2.dispNum = *fptr[(timeVal % 1000) / 100];
    DIG1.dispNum = *fptr[(timeVal % 10000) / 1000];
  }
}

void task_3_setup() {
  DDRA = 0;
  DDRA = bitsOn(DDRA, SEG_1);
  DDRA = bitsOn(DDRA, SEG_2);
  DDRA = bitsOn(DDRA, SEG_3);
  DDRA = bitsOn(DDRA, SEG_4);
  DDRA = bitsOn(DDRA, SEG_5);
  DDRA = bitsOn(DDRA, SEG_6_DIG4);

  DDRG = 0;
  DDRG = bitsOn(DDRG, SEG_7);
  DDRG = bitsOn(DDRG, SEG_8_DIG3);

  DDRL = 0;
  DDRL = bitsOn(DDRL, SEG_9_DIG2);
  DDRL = bitsOn(DDRL, SEG_10);
  DDRL = bitsOn(DDRL, SEG_11);
  DDRL = bitsOn(DDRL, SEG_12_DIG1);

  DIG1.dispNum = *fptr[0];
  DIG2.dispNum = *fptr[0];
  DIG3.dispNum = *fptr[0];
  DIG4.dispNum = *fptr[0];
}

void dig4_off() {
  PORTA = bitsOn(PORTA, SEG_6_DIG4);
}
void dig4_on() {
  PORTA = bitsOff(PORTA, SEG_6_DIG4);
}

void dig3_off() {
  PORTG = bitsOn(PORTG, SEG_8_DIG3);
}
void dig3_on() {
  PORTG = bitsOff(PORTG, SEG_8_DIG3);
}

void dig2_off() {
  PORTL = bitsOn(PORTL, SEG_9_DIG2);
}
void dig2_on() {
  PORTL = bitsOff(PORTL, SEG_9_DIG2);
}

void dig1_off() {
  PORTL = bitsOn(PORTL, SEG_12_DIG1);
}
void dig1_on() {
  PORTL = bitsOff(PORTL, SEG_12_DIG1);
}



void L1_on() {
  PORTL = bitsOn(PORTL, SEG_10);
}
void L1_off() {
  PORTL = bitsOff(PORTL, SEG_10);
}

void L2_on() {
  PORTA = bitsOn(PORTA, SEG_1);
}
void L2_off() {
  PORTA = bitsOff(PORTA, SEG_1);
}

void B_on() {
  PORTA = bitsOn(PORTA, SEG_2);
}
void B_off() {
  PORTA = bitsOff(PORTA, SEG_2);
}

void R1_on() {
  PORTG = bitsOn(PORTG, SEG_7);
}
void R1_off() {
  PORTG = bitsOff(PORTG, SEG_7);
}

void R2_on() {
  PORTA = bitsOn(PORTA, SEG_4);
}
void R2_off() {
  PORTA = bitsOff(PORTA, SEG_4);
}

void T_on() {
  PORTL = bitsOn(PORTL, SEG_11);
}
void T_off() {
  PORTL = bitsOff(PORTL, SEG_11);
}

void M_on() {
  PORTA = bitsOn(PORTA, SEG_5);
}
void M_off() {
  PORTA = bitsOff(PORTA, SEG_5);
}



void LED_clear() {
  T_off();
  R2_off();
  R1_off();
  B_off();
  L2_off();
  L1_off();
  M_off();  
}

void LED_0() {
  T_on();
  R2_on();
  R1_on();
  B_on();
  L2_on();
  L1_on();
}

void LED_1() {
  R2_on();
  R1_on();
}

void LED_2() {
  T_on();
  R1_on();
  M_on();
  L2_on();
  B_on();
}

void LED_3() {
  T_on();
  R1_on();
  M_on();
  R2_on();
  B_on();
}

void LED_4() {
  L1_on();
  M_on();
  R1_on();
  R2_on();
}

void LED_5() {
  T_on();
  L1_on();
  M_on();
  R2_on();
  B_on();
}

void LED_6() {
  T_on();
  L1_on();
  L2_on();
  B_on();
  R2_on();
  M_on();
}

void LED_7() {
  T_on();
  R2_on();
  R1_on();
}

void LED_8() {
  T_on();
  R2_on();
  R1_on();
  M_on();
  B_on();
  L2_on();
  L1_on();
}

void LED_9() {
  T_on();
  L1_on();
  M_on();
  R2_on();
  R1_on();
}

int digitAmt(int val) {
  if (val == 0) {
    return 0;
  } else if (val/10 == 0) {
    return 1;
  } else if (val/100 == 0) {
    return 2;
  } else if (val/1000 == 0) {
    return 3;
  } else if (val/10000 == 0) {
    return 4;
  }
}






/**************************************************************
 *            FUNCTION GRAVEYARD [DO NOT UNCOMMENT]
 **************************************************************/
//void downTick_display() {
//  unsigned long taskElapsed = totalTime % 9000;
//  
//  digitUpdater(ahead/100);
//  if ((totalTime - prevTime_3) <= 2) {
//    LED_clear();
//    dig4_on();
//    DIG4.dispNum();
//    
//    dig3_off();
//    dig2_off();
//    dig1_off();
//  } else if ((totalTime - prevTime_3) <= 5) {
//    //LED_clear();
//    dig4_off();
//  } else if ((totalTime - prevTime_3) <= 7) {
//    LED_clear();
//    dig3_on();
//    DIG3.dispNum();
//    dig4_off();
//    
//    dig2_off();
//    dig1_off(); 
//  } else if ((totalTime - prevTime_3) <= 10) {
//    //LED_clear();
//    dig3_off();
//  } else if ((totalTime - prevTime_3) <= 12) {
//    LED_clear();
//    dig2_on();
//    DIG2.dispNum();
//    
//    dig4_off();
//    dig3_off();
//    dig1_off();
//  } else if ((totalTime - prevTime_3) <= 15) {
//    //LED_clear();
//    dig2_off();
//  } else if ((totalTime - prevTime_3) <= 17) {
//    LED_clear();
//    dig1_on();
//    DIG1.dispNum();
//    
//    dig4_off();
//    dig3_off();
//    dig2_off();
//  } else if ((totalTime - prevTime_3) <= 20) {
//    //LED_clear();
//    dig1_off();
//  } else {
//    prevTime_3 = totalTime;
//  }
//
//  if (taskElapsed >= 5000) {
//    if (ahead >= 0) {
//      //ahead -= 1;
//      ahead = (9000 - taskElapsed); 
//  //    Serial.print("taskElapsed: "); Serial.print(taskElapsed); Serial.print(" | "); Serial.print("ahead: ");
//  //    Serial.print(ahead); Serial.print(" | "); Serial.print("difference: "); 
//  //    Serial.println(4000 - taskElapsed);
//    } else {
//      ahead = 4000;
//    }
//  }
//}
