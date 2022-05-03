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
#include "task_5.h"

/**************************************************************
 *              FUNCTION PROTOTYPES
 **************************************************************/
void setUpSRRI();
void setUpDDS();

/**************************************************************
 *                      SETUP & LOOP
 **************************************************************/
void setup() {
  Serial.begin(9600);
  totalTime = millis();
  setUpInterrupt();
  setUpSRRI();
  setUpDDS();
  task_1_setup();
  task_2_setup();
  task_3_setup();
}

void loop() {
  // Select scheduler in global.h with CURRENT_SCHEDULER variable
  if (CURRENT_SCHEDULER == RR) {
    task1();
    task2();
    //task3();
    //play_song_2();
    //tick_display();
    //downTick_display();
    delay(1);
  } else if (CURRENT_SCHEDULER == SRRI) {
      for (int i = 0; i < TASK_AMOUNT; i++){
        if (taskArr[i] != NULL && stateTask[i] == READY){
          taskIndex = i;
          //begin task
          stateTask[i] = RUNNING;
          (*taskArr[i])();
    
          if(stateTask[i] == RUNNING){
            stateTask[i] = READY;
          }
        }
      }
  } else if(CURRENT_SCHEDULER == DDS){ 
    for(int i = 0; i < TASK_AMOUNT; i++){
      if(TaskList[i].ftptr != NULL && TaskList[i].state == READY){
        //TaskList[i].times_started++;
        taskIndex = i;
        //begin task
        TaskList[i].state = RUNNING;
        (TaskList[i].ftptr)();

        if(TaskList[i].state == RUNNING){
          TaskList[i].state = READY;
        }
      }
    }
  }

}


/**************************************************************
 *                        FUNCTIONS
 **************************************************************/
void setUpSRRI() {
  for(int i = 0; i < TASK_AMOUNT; i++){
    taskArr[i] = NULL; // set task function pointer to NULL
    sleepTask[i] = -1; // set task time slept to -1
    stateTask[i] = READY; // set task state to READY
    timeTask[i] = 0; // set task run time to 0
  }

  // uncomment a task for it to run in SRRI
  taskArr[0] = task1;
  taskArr[1] = task2;
  taskArr[2] = task3;
  //taskArr[3] = task4;
  //taskArr[4] = task5;

  // last function pointer in taskArr is schedule_sync
  taskArr[TASK_AMOUNT - 1] = schedule_sync; 
}

void setUpDDS() {
  // initialize all TCBstructs
  for(int i = 0; i < TASK_AMOUNT; i++){
    TaskList[i].ftptr = NULL;
    TaskList[i].state = READY;
    TaskList[i].time_slept = -1;
    TaskList[i].times_started = 0;
    TaskList[i].id = i;
    TaskList[i].time_ran = 0;

    TaskList[i].task_name[0]= 'T';
    TaskList[i].task_name[1]= 'a';
    TaskList[i].task_name[2]= 's';
    TaskList[i].task_name[3]= 'k';
    TaskList[i].task_name[4]= i + '0';
    TaskList[i].task_name[5]= '\0';
  }

  // uncomment a task for it to run in DDS
  TaskList[0].ftptr = task1;
  TaskList[1].ftptr = task2;
  //TaskList[2].ftptr = task3;
  //TaskList[3].ftptr = task4;
  TaskList[4].ftptr = task5;
  TaskList[TASK_AMOUNT - 1].ftptr = schedule_sync;
}
