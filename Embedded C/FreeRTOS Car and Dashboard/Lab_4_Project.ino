/** @file Lab_4_Project.ino
 */

/* University of Washington
 * ECE/CSE 474,  3/16/2022
 *
 *   Brian Dallaire
 *   Erik Michel
 *
 *   Lab 4: freeRTOS and Final Project
 *
 */
#include <Arduino_FreeRTOS.h>
#include <LiquidCrystal.h>
#include <Stepper.h>
#include <SPI.h>
#include <MFRC522.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define BAUD_RATE 19200
#define BIT_2 (1 << 2)
#define CAR_ON 1
#define CAR_OFF 0

// LCD Defines
#define LCDCOLUMNS 16
#define LCDROWS 2
#define TOPROW 0
#define BOTROW 1
#define COL0 0
#define COL6 6
#define COL7 7
#define COL9 9
#define COL13 13
#define DISPLAY_SPEED min(200, ((speed_level - 512) / 2.56))
#define GAS_PERCENTAGE (int)((water_level / 130.0)* 100)
#define HALF_TANK 50

// Stepper Motor Defines
#define IDLE_SPEED 10
#define STEP_FORWARD 10
#define STEP_REVERSE -10
#define NEUTRAL_SPEED 512

// Change RFID Tag UID here
#define UID_0 0x4A
#define UID_1 0x76
#define UID_2 0x53
#define UID_3 0xBF

// Task Delays
#define DELAY_20 20
#define DELAY_25 25
#define DELAY_100 100
#define DELAY_150 150
#define DELAY_500 500


// create LCD display object with corresponding pins
const int rs = 12, en = 11, d0 = 10, d1 = 8, d2 = 7, d3 = 6, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d0, d1, d2, d3, d4, d5, d6, d7);

// create stepper motor object with corresponding pins
const int STEP_RATE = 32, IN1 = 34, IN2 = 38, IN3 = 36, IN4 = 40; 
Stepper motor(STEP_RATE, IN1, IN2, IN3, IN4);

// create RFID module object with corresponding pins
const int SS_PIN = 53, RST_PIN = 9;
MFRC522 rfid(SS_PIN, RST_PIN);



// global variables for dashboard
int speed_level, water_level, new_speed;
int car_on = CAR_OFF;

// Declare tasks
void TaskThumbStick( void *pvParameters );
void TaskWaterSensor( void *pvParameters );
void TaskStepperMotor( void *pvParameters );
void TaskRFIDKey ( void *pvParameters );

// the setup function runs once when you press reset or power the board
void setup() {
  
  // initialize serial communication at 9600 bits per second:
  Serial.begin(BAUD_RATE);
  
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB, on LEONARDO, MICRO, YUN, and other 32u4 based boards.
  } 
  DDRA |= BIT_2;                  // Init Water Sensor (pin 24 +)
  lcd.begin(LCDCOLUMNS, LCDROWS); // Init LCD display
  SPI.begin();                    // Init SPI bus
  rfid.PCD_Init();                // Init MFRC522

  xTaskCreate(
    TaskThumbStick
    ,  "ThumbStick"
    ,  850 // Stack size
    ,  NULL
    ,  3  // Priority
    ,  NULL );
  xTaskCreate(
    TaskWaterSensor
    ,  "WaterSensor"
    ,  650 // Stack size
    ,  NULL
    ,  1  // Priority
    ,  NULL );
  xTaskCreate(
    TaskStepperMotor
    ,  "StepperMotor"
    ,  600 // Stack size
    ,  NULL
    ,  2 // Priority
    ,  NULL );
  xTaskCreate(
    TaskRFIDKey
    ,  "RFIDKey"
    ,  4500 // Stack size
    ,  NULL
    ,  2 // Priority
    ,  NULL );

  vTaskStartScheduler();
}

void loop()
{
  // Empty. Things are done in Tasks.
}

/*--------------------------------------------------*/
/*---------------------- Tasks ---------------------*/
/*--------------------------------------------------*/

/**
 * Task for monitoring Arduino pin connected to x-component
 * of Joystick and updating speed value to be displayed on LCD.
 * 
 * Uses analogRead() to read analog data from Joytick. Updates
 * the global variable new_speed based on this analog data.
 * Updates the LCD accordingly.
 * 
 */
void TaskThumbStick(void *pvParameters)  // This is a task.
{
  for (;;)
  {
    vTaskDelay(DELAY_100/portTICK_PERIOD_MS);  // 0.5 sec in between reads for stability
    speed_level = analogRead(A7);  /// modify for your input pin!
    new_speed = (int)((abs(speed_level - 512)) - 96);
    updateLCD();
  }
}

/**
 * Enables use of the water sensor and stores water sensor analog
 * data in a variable water_level.
 * 
 */
void TaskWaterSensor(void *pvParameters)
{
    for(;;)
    {
      vTaskDelay(DELAY_150/portTICK_PERIOD_MS);
      PORTA |= BIT_2;    // turn the sensor ON
      vTaskDelay(DELAY_20/portTICK_PERIOD_MS);
      water_level = analogRead(A0);
      PORTA &= !(BIT_2); // turn the sensor OFF
      updateLCD();
    }
}

/**
 * Once car_on variable is ON (1), motor functions are activated
 * through this task and are controlled by new_speed and speed_level
 * global variables.
 * 
 */
void TaskStepperMotor(void *pvParameters)
{
  for(;;)
  {
    vTaskDelay(DELAY_25/portTICK_PERIOD_MS);
    if (car_on) {
      motor.setSpeed((new_speed < IDLE_SPEED) ? IDLE_SPEED : new_speed);
      motor.step(((speed_level - NEUTRAL_SPEED) > 0) ? STEP_FORWARD : STEP_REVERSE);
    }
  }
}

/**
 * Enables RFID sensor functions.
 * 
 * Continously checks if an RFID tag is being presented, reads
 * the value of a given RFID card, and checks if the RFID card
 * code matches the accepted internal value. Upon a match, the
 * car_on variable is set to 1 and other functions/tasksa are
 * enabled.
 * 
 */
void TaskRFIDKey ( void *pvParameters )
{
  for(;;)
  {
    vTaskDelay(DELAY_500/portTICK_PERIOD_MS);
    Serial.println(car_on);
    updateLCD();
    if (car_on == CAR_ON) {
      vTaskSuspend(NULL);
    }
    if (rfid.PICC_IsNewCardPresent() &&
        rfid.PICC_ReadCardSerial()&&
        rfid.uid.uidByte[0] == UID_0 && 
        rfid.uid.uidByte[1] == UID_1 && 
        rfid.uid.uidByte[2] == UID_2 && 
        rfid.uid.uidByte[3] == UID_3) {
        car_on = CAR_ON;
    }
  }
}

/*--------------------------------------------------*/
/*---------------- Helper Functions ----------------*/
/*--------------------------------------------------*/

/**
 * Enables two operational states for the LCD display module.
 * 
 * The first state is before an accepted RFID tag has been 
 * detected by the RFID sensor module, or !car_on. The second 
 * state is after an accepted RFID tag has been detected by the
 * RFID sensor module, or car_on == 1. When car_on == 1, 'speed'
 * data is displayed along with a 'gas' level given by the amount
 * of liquid detected by the water sensor.
 * 
 */
void updateLCD() {
  if (!car_on) {
    lcd.clear();
    lcd.print("Use key to");
    lcd.setCursor(COL0,BOTROW);
    lcd.print("turn car on");  
  } else {
    lcd.clear();
    lcd.print("Speed: ");
    lcd.setCursor(COL7,TOPROW);
    lcd.print(DISPLAY_SPEED);
    lcd.setCursor(COL13, TOPROW);
    lcd.print("mph");
    lcd.setCursor(COL0,BOTROW);
    lcd.print("Gas%: ");
    lcd.setCursor(COL6,BOTROW);
    lcd.print(GAS_PERCENTAGE);
    if (GAS_PERCENTAGE < HALF_TANK) {
      lcd.setCursor(COL9, BOTROW);
      lcd.print("GET GAS");
    }
  }
}
