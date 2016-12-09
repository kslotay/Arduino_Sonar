//Kulvinder Lotay
//Processing code for screen visualization for the Arduino sonar device
//Inspired by the sketch created by ScottC on 10 Nov 2012 at : http://arduinobasics.blogspot.com/


import processing.serial.*;


int total_shapes = 60; // How many squares to display on screen 
int shape_speed = 2; // Speed at which the shapes move to new position - the smaller the value, the faster they will move, with 2 being the minimum

//Global Variables 
//Create an arry of squares based n the Square class
Square[] mySquares = new Square[total_shapes];

//Define variables that will be used
int shapeSize, distance;
String comPortString;
Serial myPort;

//This involves getting the serial data from the Arduino interface
void setup(){
  
  //Check for screen size, and use entire screen for visualization
 size(displayWidth,displayHeight);
 smooth(); // All shapes should be drawn with smooth edges
 
 //Here we calculate the square size to be used, which is then initalized and set up in the Squares array
 shapeSize = (width/total_shapes); 
 for(int i = 0; i<total_shapes; i++){
 mySquares[i]=new Square(int(shapeSize*i),height-40);
 }
 
//Opena serial connection in order to communicate with the Arduino device. The COM port below will correspond to the COM port that the arduino board is connected to
 myPort = new Serial(this, "COM3", 9600);
 myPort.bufferUntil('\n'); // Check for new line, before triggering a new Serial event
}

//This function draws the visualization on screen
void draw(){
 background(0); //Set a black background
 delay(50); //Delay for screen refresh
 drawSquares(); //Draw the pattern of squares
}


//The serial event function that gets input, triggered by the process mentioned above
void serialEvent(Serial cPort){
 comPortString = cPort.readStringUntil('\n');
 if(comPortString != null) {
 comPortString=trim(comPortString);
 
 /* Use the distance received by the Arduino to modify the y position
 of the first square (others will follow). Should match the
 code settings on the Arduino. In this case 200 is the maximum
 distance expected. The distance is then mapped to a value
 between 1 and the height of your screen */
 
 //The information received for the distance allows us to now map the y position of the first square, and the others. A maximum expected distance of 300 is set below, but the settings can be modified to your preference
 distance = int(map(Integer.parseInt(comPortString),1,300,1,height));
 if(distance<0){
 //The sensor returns a negative value for an 'out of range' error. We can simply equivalate that to a distance value of 0
   distance = 0;
   }
 }
}


//This function draws the squares on screen
void drawSquares(){
 //variables for position values
 int newY, oldY, targetY, blueVal, redVal;
 
 //The y position should correspond to the distance
 mySquares[0].setY((height-shapeSize)-distance);
 
 //Update square position/color
 for(int i = total_shapes - 1; i>0; i--){
   //In order to get the visualization effect, the target must be set to the previous square value, pushed forward until the end of the shapes is reached
   targetY=mySquares[i-1].getY();
   oldY=mySquares[i].getY();
 
   if(abs(oldY-targetY)<2){
     newY=targetY;
   }
   else{
   //calculate new square position
     newY=oldY-((oldY-targetY)/shape_speed);
   }
 //Set the new position of the square
 mySquares[i].setY(newY);
 
 //The square colors reflect the closeness to an object, becoming more red for lower distances and vice versa
 blueVal = int(map(newY,0,height,0,255));
 redVal = 255-blueVal;
 fill(redVal,0,blueVal);
 
 //Finally draw the sqyare on the screen
 rect(mySquares[i].getX(), mySquares[i].getY(),shapeSize,shapeSize);
 }
}

//In order to go into fullscreen mode, we must run the following command
boolean goFullScreen() {
 return true;
}

//This is the square class utilized in other sections of the code, with get and set functions for y and x values regarding the position
class Square{
 int xLocation, yLocation;
 
 Square(int xPos, int yPos){
 xLocation = xPos;
 yLocation = yPos;
 }
 
 int getX(){
 return xLocation;
 }
 
 int getY(){
 return yLocation;
 }
 
 void setY(int yPos){
 yLocation = yPos;
 }
}