//Kulvinder Lotay
//Arduino Uno Sonar Device main configuration

//Define constants for the locations of connected pins
//Please ensure that the pin values below correspond with your Arduino setup

const int trigPin = 10;
const int echoPin = 9;
const int beepPin = 8;
const int scalingFactor = 10; //This is multiplied with the distance information in order to form a time interval for the beeping on the beeping device


//Define program variables
long duration = 0; //This will hold the duration of the measurement
int distance = 0; //This variable will hold the distance from an object
long i = 1; //A counter used for distance checking intervals (used in the delay_check_distance function)
long maxtime = 1000; //This is used to compare with the the value of i to determine whether or not the measurement has exceeded the max time limit we have set (1000 milliseconds in this case)
long time2 = 0; //Used to store time in milliseconds before distance measurement
long time1 = 0; //Used to store time in milliseconds after distance measurement


//Initialize the device (pins)
void setup() {
  // put your setup code here, to run once:
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(beepPin, OUTPUT);
  Serial.begin(9600);

}

//This function calculates and logs the distance measured
void log_distance(){
  //Take time before distance measurement
  time1 = millis();

  //Reset trigger pin
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  //Activate the trigger pin on the HR-S04 ultrasonic sensor
  digitalWrite(trigPin, HIGH);
  //Send out pulses for a time of 10 milliseconds
  delayMicroseconds(10);
  //Reset the trigger interface
  digitalWrite(trigPin, LOW);

  //Take a note of the duration the sound wave has taken to propagate back to the ultrasonic sensor
  duration = pulseIn(echoPin, HIGH);
  //calculate the distance based on the collected data. We also know the speed of sound at .034 cm/microsecond, and the relationship t (time) = d (distance) / v (speed)
  //given that, by rearranging for d (distance), we get (d = t * .034)
  //since the sensor sends out a sound wave and waits for it to return, the distance it has travelled will be twice the actual distance of the area, so we must divide by 2
  //our final calculation for distance is:
  distance = duration * .034/2;


  //We take a time measurement after the distance measurement
  time2 = millis();
  //We then calculate the max time based on the distance, which we will use to determine the frequency of beeps
  //The choice for scalingFactor is user-defined, and in this case we use 10, but any value may be used, keeping in mind it will affect the overall frequency of beeps
  maxtime = scalingFactor * distance;
}

//Check distance while comparing for max time
void delay_check_distance(){
  i = 1;
  while(1){
    if(i%60 == 0){
      log_distance();
    }
    delay(1);
    ++i;
    if(i >= maxtime){
      break;
    }
  }
}

//This function determines the beeping functionality
void beep(){
  digitalWrite(beepPin, HIGH);
  delay(90);
  log_distance();
  //We compare the two time measurements of before and after distance measurement, and use taht to define how the beeping will occur
  if(time2 - time1 < 30){
    delay(60-(time2-time1));
  }

  //Reset beeping module
  digitalWrite(beepPin, LOW);
}

void loop() {
  // put your main code here, to run repeatedly:

  beep();
  delayandcheckdistance();

  //If you wish to only view the distance in cm through the Arduino IDE serial interface, the below descriptions may be applicable
  //Serial.print("Distance: ");
  Serial.println(distance);
  //Serial.println(" cm");
  
}
