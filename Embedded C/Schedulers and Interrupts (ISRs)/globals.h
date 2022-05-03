/* University of Washington
 * ECE/CSE 474,  2/25/2022
 *
 *   Brian Dallaire
 *   Erik Michel
 *
 *   Lab 3: Schedulers and Interupts
 *
 */

#ifndef GLOBALS_H
#define GLOBALS_H

/**************************************************************
 *              MACRO INITIALIZATIONS
 **************************************************************/
#define ZERO 0 //!< macro for value zero
  
#define TASK_AMOUNT 10
#define RUNNING   0 //!< state for when a task is running
#define READY     1 //!< state for when a task is ready
#define SLEEPING  2 //!< state for when a task is sleeping
#define DEAD      3 //!< state for when a task is dead

  // states for sFlag 
#define PENDING 0 //!< when waiting for interrupt to be triggered
#define DONE    1 //!< when interrupt is triggered  

  // values to determine which scheduler is being used
#define RR    0 //!< when running the round-robin scheduler
#define SRRI  1 //!< when running the synchronized round-robin with interrupt scheduler
#define DDS   2 //!< when running the data-driven scheduler

#define SILENT_TIME 4000 //!< amount of time speaker is silent

int CURRENT_SCHEDULER = DDS; //!< scheduler selection variable

/**************************************************************
 *              FUNCTION PROTOTYPES
 **************************************************************/

/**
 * @brief turns on bits in a value as specified by a mask provided via the mask input
 * 
 * @param value: the value for which the on-bit mask will be applied
 * @param mask: the on-bit mask being applied
 * 
 * @return the altered value input
 */
int bitsOn(int value, int mask);

/**
 * @brief turns off bits in a value as specified by a mask provided via the mask input
 * 
 * @param value: the value for which the off-bit mask will be applied
 * @param mask: the off-bit mask being applied
 * 
 * @return the altered value input
 */
int bitsOff(int value, int mask);

/**
 * @brief updates sleep times of tasks on interrupt trigger
 */
void schedule_sync();

/**
 * @brief updates sleep times of tasks on interrupt trigger
 * 
 * @param t: amount of time in ms that a task will sleep for
 */
void sleepUpdate(long t);

/*
 * @brief initializes Timer Counter 3 as interrupt via direct register manipulation
 */
void setUpInterrupt();

/*
 * @brief updates running task times and sleeping task times accordingly
 */
void schedule_sync();

/*
 * @brief updates the state of a task to READY and adds task 
 * to the task list array
 * 
 * @param id: id of task to be started
 */
void task_start(void (*task)());

/*
 * @brief updates state of current task to dead and puts function
 * pointer of current task in dead task array
 */
void task__self_quit();

/**************************************************************
 *              VARIABLE DECLARATIONS
 **************************************************************/
unsigned long totalTime = 0; //!< global time variable (tracked in ms)
void (*taskArr[TASK_AMOUNT])(); //!< array of tasks (function pointers)
volatile int taskIndex; //!< index of current task
volatile int stateTask[TASK_AMOUNT]; //!< array containing states of each task
volatile int sleepTask[TASK_AMOUNT]; //!< array containing sleep times of each task
volatile long timeTask[TASK_AMOUNT]; //!< array containing runtime of each task

volatile int sFlag = PENDING; //!< interrupt finish flag

unsigned long ahead = SILENT_TIME; //!< used to enable countdown on 7-seg display
unsigned long ahead_2 = 3000; //!< used to enable countdown on 7-seg display

typedef struct TCBStruct{
  unsigned int time_slept;  //!< task sleeping time
  int state;                //!< current state of task 
  char task_name[21];       //!< task name + \0
  int times_started;        //!< amount of times a task has been started
  long time_ran;            //!< how long the task has ran for
  void (*ftptr)();          //!< function pointer for task
  int id;                   //!< unique id for the task
};

TCBStruct TaskList[TASK_AMOUNT]; //!< array of active tasks 
TCBStruct DeadTasks[TASK_AMOUNT]; //!< array of dead tasks
/**************************************************************
 *                        FUNCTIONS
 **************************************************************/
int bitsOn(int value, int mask) {
  return value |= mask;
}

int bitsOff(int value, int mask) {
  return value &= !mask;
}

ISR(TIMER3_COMPA_vect) {
  sFlag = DONE;
}

void sleepUpdate(long t){
  if(CURRENT_SCHEDULER == SRRI){
    stateTask[taskIndex] = SLEEPING;
    sleepTask[taskIndex] = t;
  }
  return;
}




/**************************************************************
 *                       SRRI FUNCTIONS
 **************************************************************/
void setUpInterrupt(){
  // counter A has interrupts enabled
  TIMSK3 |= (1 << OCIE3A);

  // interrupts enbled
  SREG |= (1<<7);

  TCNT3H = 0;
  
  // settings reset
  TCCR3A = 0;
  TCCR3B = 0;

  OCR3A = 32000;

  // make timer work in CTC mode
  TCCR3A |= (0 << WGM31) | (0 << WGM30);
  TCCR3A |= (0 << COM3A1) | (1 << COM3A0);
  TCCR3B |= (0 << WGM33) | (1 << WGM32);

  // set frequency of timer
  TCCR3B |= (0 << CS32) | (0 << CS31) | (1 << CS30);
}


void schedule_sync() {
  // wait until interrupt 
  while(sFlag == PENDING){
    
  }

  // update task run time and if task is sleeping
  // decrease sleeping time, check if task should  
  // be running, and set task to READY if appropriate
  if(CURRENT_SCHEDULER == SRRI) {
    for(int i = 0; i < TASK_AMOUNT; i++){
      //update time the task has been running for
      timeTask[i] += 2;
      if(stateTask[i] == SLEEPING){
        //update time task has been sleeping for
        sleepTask[i] -= 2;
        if(sleepTask[i] <= 1){
          //task is ready to run once more
          stateTask[i] = READY;
        }
      }
    } 
  } else if(CURRENT_SCHEDULER == DDS) {
      for(int i = 0; i < TASK_AMOUNT; i++){
        TaskList[i].time_ran +=2;
        if(TaskList[i].state == SLEEPING){
          TaskList[i].time_slept -=2;
          if(TaskList[i].time_slept <= 1){
            TaskList[i].state = READY;
          }
        }
      }
  }


  
  sFlag = PENDING;
  return;
}

void task_start(void (*task)()){
  DeadTasks[taskIndex].state = READY;
  TaskList[taskIndex] = DeadTasks[taskIndex];
}

void task_self_quit(){
  TaskList[taskIndex].state = DEAD;
  DeadTasks[taskIndex] = TaskList[taskIndex];
}


 
#endif
