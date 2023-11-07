import processing.serial.*;
import controlP5.*;
import static processing.core.PApplet.*;

Serial myadiPort;
ControlP5 guip5;   //controlP5 object 
PImage picture;

int Joint1Slider = 0;
int Joint2Slider = 0;
int Joint3Slider = 0;
int Joint4Slider = 0;
int Joint1JogValue = 0;
int Joint2JogValue = 0;
int Joint3JogValue = 0;
int Joint4JogValue = 0;
int speedSlider = 0;
int gripperValue = 180;
int gripperAdd = 180;
int Count= 0;

int saveStatus = 0;
int runStatus = 0;

int slider1Previous = 0;
int slider2Previous = 0;
int slider3Previous = 0;
int sliderzPrevious = 0;
int gripperValuePrevious = 0;
int speedSliderPrevious = 0;

boolean activeIK = false;
float theta1,theta2,phi,z;

String[] positions = new String[100];
String data;

void setup() 
{
  //picture = loadImage("wimir.png");
  size(960,800); // length and with of the display window in pixels
  myadiPort = new Serial(this, "COM4" , 115200 );
  guip5 = new ControlP5(this);
  // creation of a new font object named pfont using the built-in 'creatfont()'
  PFont pfont = createFont("Arial",25,true); // uses true or false for smooth/no-smooth
  // creation of a new controlfont object named font based on the existing pfont object
  ControlFont font = new ControlFont(pfont,22);
  ControlFont font2 = new ControlFont(pfont,25);
  
// Joint 1 controls
  guip5.addSlider("Joint1Slider")
       .setPosition(110,190)
       .setSize(270,30)
       .setRange(0,180)
       .setColorLabel(#FF0000)
       .setFont(font)
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("Joint1JogMinus")
       .setPosition(110,238)
       .setSize(90,40)
       .setFont(font)
       .setCaptionLabel("Jog-")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("Joint1JogPlus")
       .setPosition(290,238)
       .setSize(90,40)
       .setFont(font)
       .setCaptionLabel("JOG+")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addNumberbox("Joint1JogValue")
       .setPosition(215,243)
       .setSize(60,30)
       .setRange(0,180)
       .setFont(font)
       .setMultiplier(0.1)
       .setValue(1)
       .setDirection(Controller.HORIZONTAL) // CHANGES the control direction to left/right
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
// joint 2 Controls
  guip5.addSlider("Joint2Slider")
       .setPosition(110,315)
       .setSize(270,30)
       .setRange(0,180)
       .setColorLabel(#FF0000)
       .setFont(font)
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("Joint2JogMinus")
       .setPosition(110,363)
       .setSize(90,40)
       .setFont(font)
       .setCaptionLabel("JOG-")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("Joint2JogPlus")
       .setPosition(290,363)
       .setSize(90,40)
       .setFont(font)
       .setCaptionLabel("JOG+")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addNumberbox("Joint2JogValue")
       .setPosition(215,368)
       .setSize(60,30)
       .setRange(0,180)
       .setFont(font)
       .setMultiplier(0.1)
       .setValue(1)
       .setDirection(Controller.HORIZONTAL)
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
// Joint 3 Controls 
  guip5.addSlider("Joint3Slider")
       .setPosition(110,440)
       .setSize(270,30)
       .setRange(0,180)
       .setColorLabel(#FF0000)
       .setFont(font)
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("Joint3JogMInus")
       .setPosition(110,493)
       .setSize(90,40)
       .setFont(font)
       .setCaptionLabel("JOG-")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("Joint3JogPlus")
       .setPosition(290,493)
       .setSize(90,40)
       .setFont(font)
       .setCaptionLabel("JOG+")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addNumberbox("Joint3JogValue")
       .setPosition(215,493)
       .setSize(60,30)
       .setRange(0,180)
       .setMultiplier(0.1)
       .setValue(1)
       .setDirection(Controller.HORIZONTAL)
       .setFont(font)
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
// joint 4 controls 
  guip5.addSlider("Joint4Slider")
       .setPosition(110,565)
       .setSize(270,30)
       .setRange(0,180)
       .setColorLabel(#FF0000)
       .setFont(font)
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("Joint4JogMinus")
       .setPosition(110,618)
       .setSize(90,40)
       .setFont(font)
       .setCaptionLabel("JOG-")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("Joint4JogPlus")
       .setPosition(290,618)
       .setSize(90,40)
       .setFont(font)
       .setCaptionLabel("JOG+")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addNumberbox("Joint4JogValue")
       .setPosition(215,618)
       .setSize(60,30)
       .setRange(0,180)
       .setFont(font)
       .setMultiplier(0.1)
       .setValue(1)
       .setCaptionLabel("")
       .setDirection(Controller.HORIZONTAL)
       .setColorForeground(color(255,0,0));
       ;
// operational controls 
  guip5.addButton("Mov")
       .setPosition(570,650)
       .setSize(240,45)
       .setFont(font)
       .setCaptionLabel("Move To Position")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("SavePosition")
       .setPosition(470,520)
       .setSize(215,50)
       .setFont(font2)
       .setCaptionLabel("Save Position")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("run")
       .setPosition(725,520)
       .setSize(215,50)
       .setFont(font2)
       .setCaptionLabel("Run Program")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("update")
       .setPosition(760,590)
       .setSize(150,40)
       .setFont(font)
       .setCaptionLabel("Update")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addButton("ClearSavedData")
       .setPosition(490,590)
       .setSize(135,40)
       .setFont(font)
       .setCaptionLabel("Clear")
       .setColorForeground(color(255,0,0));
       ;
  guip5.addSlider("speedSlider")
       .setPosition(470,445)
       .setSize(180,30)
       .setRange(1,255)
       .setColorLabel(#FF0000)
       .setFont(font)
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
      
  guip5.addSlider("gripperValue")
       .setPosition(725,445)
       .setSize(190,30)
       .setRange(0,180)
       .setValue(90)
       .setColorLabel(#FF0000)
       .setFont(font)
       .setCaptionLabel("")
       .setColorForeground(color(255,0,0));
       ;
}

void draw() {
  background( #FFFFFF); // black background 
  float scale_factor = 2.0;
  //image(picture, 450, 190,picture.width * scale_factor,picture.height * scale_factor);
  textSize(26);
  fill(255,0,0);
  textSize(80);
  text("Industrial Robot Control", 80, 100);
  // sets the fill color of text to any desired shade,
  fill(0,0,0);
  textSize(45);
  text("J1",35,250);
  text("J2",35,375);
  text("J3",35,500);
  text("J4",35,625);
  textSize(22);
  text("Speed",530,425);
  text("Gripper",785,425);
  
  fill(gripperValue);
  fill(speedSlider);
  fill(Joint4Slider);
  fill(Joint3Slider);
  fill(Joint2Slider);
  fill(Joint1Slider);
  //fill(Joint1JogValue);
  //fill(Joint2JogValue);
  //fill(Joint3JogValue);
  //fill(Joint4JogValue);
  
  updateData();
  saveStatus = 0 ; // keep variable 0 , so when the button is pressed variable becomes 1 which intructs the arduino code to save
  
  if (Count >0 ) {
    text(positions[Count-1], 480, 755);
    text("Last saved position: No."+(Count-1), 350, 725);
  } else {
    text("Last saved position:", 350, 725);
    text("None", 480, 755);
  }
  
  
}
// the function below handles events triggered by GUI elements , the Event is is an object of type ControlEvent
void controlEvent(ControlEvent theEvent) { 
  // checkes if the event is associated with any of the controllers 
  if (theEvent.isController()) { 
    println(theEvent.getController().getName());
  }
}

public void Joint1JogMinus() {
  int obtained = round(guip5.getController("Joint1Slider").getValue());
  obtained = obtained - Joint1JogValue;
  guip5.getController("Joint1Slider").setValue(obtained);
}

public void Joint1JogPlus() {
  int obtained = round(guip5.getController("Joint1Slider").getValue());
  obtained = obtained + Joint1JogValue;
  guip5.getController("Joint1Slider").setValue(obtained);
}

public void Joint2JogMinus() {
  int obtained = round(guip5.getController("Joint2Slider").getValue());
  obtained = obtained - Joint2JogValue;
  guip5.getController("Joint2Slider").setValue(obtained);
}

public void Joint2JogPlus() {
  int obtained = round(guip5.getController("Joint2Slider").getValue());
  obtained = obtained + Joint2JogValue;
  guip5.getController("Joint2Slider").setValue(obtained);
}

public void Joint3JogMinus() {
  int obtained = round(guip5.getController("Joint3Slider").getValue());
  obtained = obtained - Joint3JogValue;
  guip5.getController("Joint3Slider").setValue(obtained);
}

public void Joint3JogPlus() {
  int obtained = round(guip5.getController("Joint3Slider").getValue());
  obtained = obtained + Joint3JogValue;
  guip5.getController("Joint3Slider").setValue(obtained);
}

public void Joint4JogMinus() {
  int obtained = round(guip5.getController("Joint4Slider").getValue());
  obtained = obtained - Joint4JogValue;
  guip5.getController("Joint4Slider").setValue(obtained);
}

public void Joint4JogPlus() {
  int obtained = round(guip5.getController("Joint4Slider").getValue());
  obtained = obtained + Joint4JogValue;
  guip5.getController("Joint4Slider").setValue(obtained);
}

public void mov() {
  myadiPort.write(data);
  println(data);
}

public void SavePosition() {
  // save the positions of joint 1 joint 2 joint 3 joint 4 in the array
  positions[Count] = "J1="+str(round(guip5.getController("Joint1Slider").getValue()))
                 +"; J2="+str(round(guip5.getController("Joint2Slider").getValue()))
                 +"; J3="+str(round(guip5.getController("Joint3Slider").getValue()))
                 +"; J4="+str(round(guip5.getController("Joint4Slider").getValue()))
                 +"; J5="+str(round(guip5.getController("gripperValue").getValue()));
  Count++;
  saveStatus = 1;
  updateData();
  myadiPort.write(data);
  println(data);
}

public void run() {
  if (runStatus == 0) {
    guip5.getController("run").setCaptionLabel("STOP");
    guip5.getController("run").setColorLabel(#00FF00);
    
    runStatus = 1; 
  }else if (runStatus == 1 ) {
    runStatus = 0;
    guip5.getController("run").setCaptionLabel("RUN Program");
    guip5.getController("run").setColorLabel(255); 
  }
  updateData();
  myadiPort.write(data);
}
public void update() {
  myadiPort.write(data);
}

public void ClearSavedData() {
  saveStatus = 2; // clears all steps / programs
  updateData();
  // sends data to the microprocessor 
  myadiPort.write(data);
  //prints messages to the console so that user can see how much data is being cleared
  println("Clear: "+data);
  Count = 0;
  saveStatus = 0; 
}

public void updateData() {
  // convertion of saveStatus value to a string 
  data = str(saveStatus)
    +","+str(runStatus)
    // get the current value from the specified slider and rounds it off to the nearest integer and converts to a string 
    +","+str(round(guip5.getController("Joint1Slider").getValue()))
    +","+str(round(guip5.getController("Joint2Slider").getValue()))
    +","+str(round(guip5.getController("Joint3Slider").getValue()))
    +","+str(round(guip5.getController("Joint4Slider").getValue()))
    +","+str(round(guip5.getController("gripperValue").getValue()))
    +","+str(round(guip5.getController("speedSlider").getValue())); 
}
