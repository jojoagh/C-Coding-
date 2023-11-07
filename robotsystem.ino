#include <VarSpeedServo.h>
#include <LiquidCrystal.h>
#include <math.h>

// water system variables and data
const int rs = 0, en = 0, d4 = 0 , d5 = 0 , d6 = 0 , d7 = 0 ;
LiquidCrystal lcd(rs,en,d4,d5,d6,d7);
const int emptytankdistance = 70 ;
const int fulltankdistance = 30 ;
float distance;
float pulse_width;
int Percentage;
int pump;
const int triggerpin = 9;
const int echopin = 10;
const int green = 3;
const int blue = 2;
const int red = 4;

// creating the servo object to control the servo motor 
VarSpeedServo base_motor;
VarSpeedServo base_of_arm_motor;
VarSpeedServo upper_Arm_motor;
VarSpeedServo lower_arm_motor;
VarSpeedServo end_effector_motor;

double theta1, theta2, phi, z;

// current position
int base_motorPos , base_of_arm_motorPos , upper_Arm_motorPos , lower_arm_motorPos ,end_effector_motorPos;
// Previous position
int base_motorPPos , base_of_arm_motorPPos , upper_Arm_motorPPos , lower_arm_motorPPos ,end_effector_motorPPos;
//speed variable
int speed_base_motor;
int speed_base_of_arm_motor;
int speed_upper_Arm_motor;
int speed_lower_arm_motor;
int speed_end_effector_motor;
//acceleration
int Accel_base_motor;
int Accel_base_of_arm_motor;
int Accel_upper_Arm_motor;
int Accel_lower_arm_motor;
int Accel_end_effector_motor;

String content = "";
int data[10];
int SPEED1 = 160;
byte inputValue[5];
int k = 0;

int joint1array[100];
int joint2array[100];
int phiArray[100];
int zArray[100];
int glutankorientation[100];
int Count = 0;

void setup() {
  Serial.begin(115200);
  // configuring water system 
  lcd.begin(16,2);
  lcd.print("Glue level: ");
  lcd.setCursor(0,1);
  lcd.print("Pump: ");
  pinMode(triggerpin, OUTPUT);
  pinMode(echopin, INPUT);
  pinMode(green, OUTPUT);
  pinMode(blue, OUTPUT);
  pinMode(red, OUTPUT);

  // attaches the servo on the defined pin to the respective servo object
  base_motor.attach(8);
  base_of_arm_motor.attach(9);
  upper_Arm_motor.attach(10);
  lower_arm_motor.attach(11);
  end_effector_motor.attach(12);

  homePos();
}

void homePos() {
  // Joel change the angles accordingly later
  base_motorPPos = 180;
  base_motor.write(base_motorPPos,SPEED1);
  base_of_arm_motorPPos =  180;
  base_of_arm_motor.write(base_motorPPos,SPEED1);
  upper_Arm_motorPPos = 180;
  upper_Arm_motor.write(base_motorPPos,SPEED1);
  lower_arm_motorPPos = 180;
  lower_arm_motor.write(base_motorPPos,SPEED1);
  end_effector_motorPPos = 180;
  end_effector_motor.write(base_motorPPos,SPEED1);
  // delay(3000);
}

void measureddistance()
{
  digitalWrite(triggerpin,LOW);
  delayMicroseconds(2);
  digitalWrite(triggerpin,HIGH);
  delayMicroseconds(10);
  digitalWrite(triggerpin,LOW);
  pulse_width = pulseIn(echopin,HIGH);
  distance = ((pulse_width * 0.034 ) / 2);
  // printing results to serial monitor 
  Serial.print("The distance is : ");
  Serial.print(distance);
  Serial.println(" cm ");
  delay(200);
}

void loop() {
  
 measureddistance();
 Percentage = map((int)distance,emptytankdistance,fulltankdistance,0,100);

 //printing the results on the lcd display screen
 lcd.setCursor(12,0);
 lcd.print(Percentage);
 lcd.print("%");

 // printing the results to the serial monitor
 Serial.print("The percentage is : ");
 Serial.print(Percentage);
 Serial.print("%");

 if (Serial.available()) {
   content = Serial.readString(); // read the incoming data from processing 
   // extract the data from the string and put into separate integer variables, the data array
   for(int i = 0 ; i < 10 ; i++ )
   {
     int index = content.indexOf(","); // locate the first ","
     data[i] = atol(content.substring(0,index).c_str()); // extract the number from start to the ","
     content = content.substring(index + 1); // removing the number from the string 
   }
   /*
     data[0] - SAVE button status
     data[1] - RUN button status
     data[2] - Joint 1 angle
     data[3] - Joint 2 angle
     data[4] - Joint 3 angle (phi)
     data[5] - Z position
     data[6] - Glue tank orientation
     data[7] - Speed value
     data[8] - Acceleration value
    */
    // if save button is pressed,store the data into the appropriate arrays
    if (data[0] == 1)
    {
      joint1array[Count] = data[2];
      joint2array[Count] = data[3];
      phiArray[Count] = data[4];
      zArray[Count] = data[5];
      glutankorientation[Count] = data[6];
      Count++;
    }
    // clear data
    if ( data[0] == 2 )
    {
      memset(joint1array,0,sizeof(joint1array));
      memset(joint2array,0,sizeof(joint2array));
      memset(phiArray,0,sizeof(phiArray));
      memset(zArray,0,sizeof(zArray));
      memset(glutankorientation,0,sizeof(glutankorientation));
      Count = 0;
    }
 }
 // if the run button is pressed 
 lcd.setCursor(5,1);
 while(data[1] == 1)
  {
    if ( Percentage > 26 )
   {
     digitalWrite(red, LOW);

     speed_base_motor = data[7];
     speed_base_of_arm_motor = data[7];
     speed_upper_Arm_motor = data[7];
     speed_lower_arm_motor = data[7];
     speed_end_effector_motor = data[7];
    
     // executing the stored pos from the arrays 
     for (int i = 0; i <= Count - 1 ; i++)
     {
       if (data[1] == 0) 
       {
         break;
       }
       base_motor.write(joint1array[i],speed_base_motor,true);
       base_of_arm_motor.write(joint2array[i],speed_base_of_arm_motor,true);
       upper_Arm_motor.write(phiArray[i],speed_upper_Arm_motor,true);
       lower_arm_motor.write(zArray[i],speed_lower_arm_motor,true);
       end_effector_motor.write(glutankorientation[i],speed_end_effector_motor,true);

       // just in case the motor doesnt reach its desired position
       while(base_motor.read() != joint1array[i] || base_of_arm_motor.read() != joint2array[i] || upper_Arm_motor.read() != phiArray[i] || lower_arm_motor.read() != zArray[i] || end_effector_motor.read() != glutankorientation[i]  )
       {
         base_motor.write(joint1array[i]);
         base_of_arm_motor.write(joint2array[i]);
         upper_Arm_motor.write(phiArray[i]);
         lower_arm_motor.write(zArray[i]);
         end_effector_motor.write(glutankorientation[i]);
       }

       if (base_motor.read() == joint1array[0] && base_of_arm_motor.read() == joint2array[0] && upper_Arm_motor.read() == phiArray[0] && lower_arm_motor.read() == zArray[0] && end_effector_motor.read() == glutankorientation[0])
       {
         // when the robot has reached the first position , the pump is switched on
         digitalWrite(green, HIGH);
         lcd.print(" ON ");
       }
       int arraySize = sizeof(joint1array)/sizeof(*joint1array);
       if (base_motor.read() == joint1array[arraySize - 1] && base_of_arm_motor.read() == joint2array[arraySize - 1] && upper_Arm_motor.read() == phiArray[arraySize - 1] && lower_arm_motor.read() == zArray[arraySize - 1] && end_effector_motor.read() == glutankorientation[arraySize - 1])
       {
         // when the robot has reached the last position , the pump is switched off
         digitalWrite(green, LOW);
         lcd.print(" OFF ");
       }

       // checking for change in speed and acceleration or program stop
       if (Serial.available())
       {
         content = Serial.readString(); // read the incoming dat from processing 
         // extract the data from the string into its repective data containers 
         for(int i = 0 ; i < 10 ; i++ )
         {
           int index = content.indexOf(","); // locate the first ","
           data[i] = atol(content.substring(0,index).c_str()); // extracting the number from start to the ","
           content = content.substring(index + 1); // removing the number from the string 
         }
         if (data[1] == 0 )
         {
           break;
         }
        //  //change speed whilist motor is moving 
        //  base_motor.setSpeed(data[7]);
        //  base_of_arm_motor.setSpeed(data[7]);
        //  upper_Arm_motor.setSpeed(data[7]);
        //  lower_arm_motor.setSpeed(data[7]);
        //  end_effector_motor.setSpeed(data[7]);
       }
     }
   }
   else 
    {
      // if the percentage is less than 25 
      lcd.print(" OFF ");
      digitalWrite(green, LOW);
      digitalWrite(red,HIGH);
      Serial.print(" Please refill the glue tank "); 
    }
  }
  base_motorPos = data[2];
  base_of_arm_motorPos = data[3];
  upper_Arm_motorPos = data[4];
  lower_arm_motorPos = data[5];
  end_effector_motorPos = data[6];

  speed_base_motor = data[7];
  speed_base_of_arm_motor = data[7];
  speed_upper_Arm_motor = data[7];
  speed_lower_arm_motor = data[7];
  speed_end_effector_motor = data[7];

  base_motor.write(base_motorPos,speed_base_motor,true);
  base_of_arm_motor.write(base_of_arm_motorPos,speed_base_of_arm_motor,true);
  upper_Arm_motor.write(upper_Arm_motorPos,speed_upper_Arm_motor,true);
  lower_arm_motor.write(lower_arm_motorPos,speed_lower_arm_motor,true);
  end_effector_motor.write(end_effector_motorPos,speed_end_effector_motor,true);

  while(base_motor.read() != base_motorPos || base_of_arm_motor.read() != base_of_arm_motorPos || upper_Arm_motor.read() != upper_Arm_motorPos || lower_arm_motor.read() != lower_arm_motorPos || end_effector_motor.read() != end_effector_motorPos  )
  {
    base_motor.write(base_motorPos);
    base_of_arm_motor.write(base_of_arm_motorPos);
    upper_Arm_motor.write(upper_Arm_motorPos);
    lower_arm_motor.write(lower_arm_motorPos);
    end_effector_motor.write(end_effector_motorPos);
  }
}

void serialFlush() {
  while (Serial.available() > 0) {  //while there are characters in the serial buffer, because Serial.available is >0
    Serial.read();         // get one character
  }
}


