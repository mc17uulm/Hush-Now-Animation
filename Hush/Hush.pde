/*
 -- HushNow-Animation --
 by Luis Beaucamp, Tim Stenzel, Marco Combosch - 2015
 
 Credits:
   Circus Fluid - Water Simulation used from BlueThen unter CC 2.0 License
   Made by Jared "BlueThen" C. on June 5th, 2011.
   Updated June 7th, 2011 (Commenting, refactoring, coloring changes)
 
 */

import processing.opengl.*;
import javax.media.opengl.*;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

ControlP5 gui;

Textlabel head;
Textlabel labelA;
ColorPicker cp;

Slider hSlider;
Slider sSlider;
Slider bSlider;
Slider pixelSlider;

int h = 0;
int s = 0;
int b = 0;

/*float flowerNum; 
int flowerBackgroundColor = 0;

float flowerW = 150;
float flowerH = 150;*/

PFont hendrix;
// Variables for the timeStep
float y, x, px, py;

// staerke des drops
float force;

// Groeße der Pixel
int pixel = 5;

// Anzahl der Frames zwischen zwei drops
int beat_drop = 20;
int counter = 0;

long previousTime;
long currentTime;
float timeScale = 1; // Play with this to slow down or speed up the fluid (the higher, the faster)
final int fixedDeltaTime = (int)(10 / timeScale);
float fixedDeltaTimeSeconds = (float)fixedDeltaTime / 1000;
float leftOverDeltaTime = 0;

boolean songPlaying;


int[] beats = {
  10050, 10460, 11040, 11217, 
  11539, 11770, 12116, 12566, 12638, 
  24524, 24795, 25100
};


// The drop for fluid solving
Drop drop;

// Audio stuff
Minim minim;
AudioPlayer song;
AudioInput in;
BeatDetect beat;

boolean sketchFullScreen(){
  return true;
}

void setup () {
  size(displayWidth, displayHeight, OPENGL);
  if(frame != null){
    frame.setResizable(true);
  }
  colorMode(RGB, 0, 0, 0);
  noStroke();
  
  gui = new ControlP5(this);
  
  Terminal t = new Terminal();
  startGUI();
  
  minim = new Minim(this);
 // in = minim.getLineIn();
  song = minim.loadFile("hush.mp3", 512);
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  
  songPlaying = false;
}

class Terminal{
  
  Terminal(){
     hendrix = loadFont("hendrix.vlw");
  }
}

void draw () {

  //beat.detect(song.mix);

  /******** Physics ********/
  // time related stuff
  counter++;

  // Calculate amount of time since last frame (Delta means "change in")
  currentTime = millis();
  long deltaTimeMS = (long)((currentTime - previousTime));
  previousTime = currentTime; // reset previousTime

    // timeStepAmt will be how many of our fixedDeltaTimes we need to make up for the passed time since last frame. 
  int timeStepAmt = (int)(((float)deltaTimeMS + leftOverDeltaTime) / (float)(fixedDeltaTime));

  // If we have any left over time left, add it to the leftOverDeltaTime.
  leftOverDeltaTime += deltaTimeMS - (timeStepAmt * (float)fixedDeltaTime); 

  if (timeStepAmt > 15) {
    timeStepAmt = 15; // too much accumulation can freeze the program!
  }
  

  // Update physics
  for (int iteration = 1; iteration <= timeStepAmt; iteration++) {
    drop.solve(fixedDeltaTimeSeconds * timeScale);
  }


  /*
  * drop alle x sekunden
   
   if(counter == beat_drop){
   drop();
   counter = 0;
   }
   */

  drop.draw();
  guitarDrops();
  //println(frameRate);
  
  
  drop.speed = map(song.mix.level(), 0, 1, 19, 29.5); //oder so ähnlich
  
  fill(0);
  /*text(timeScale, 20, 20);
  text(drop.speed, 20, 40);*/
  
}

void drop () {
  if (((int)(x / drop.cellSize) < drop.density.length) && ((int)(y / drop.cellSize) < drop.density[0].length) &&
    ((int)(x / drop.cellSize) > 0) && ((int)(y / drop.cellSize) > 0)) {
    drop.velocity[(int)(x / drop.cellSize)][(int)(y / drop.cellSize)] += force;
  }
}



//drop mit abgegriffenen werten
void guitarDrops() {
  force = abs(400000*song.mix.get(500)) + 10000*song.mix.level();
  if (force > 35000) {
    drop();
    //evtl. drop.speed mit veraendern, um staerkeren effekt zu bekommen?
  }
}


void keyPressed() {
  
  if (key == CODED) {
    if (keyCode == UP) {
      timeScale += 0.005;
    }
    if (keyCode == DOWN) {
      timeScale -= 0.005;
    }
  }
  
  if (key == '3') {
    drop.speed = 21.25;
  }
  if (key == '2') {
    drop.speed = 20;
  }
  if (key == '1') {
    drop.speed = 19;
  }

  if (key == ' ' && songPlaying) {
    song.pause();
    songPlaying = false;
  } else if (key == ' ' && !songPlaying) {
    song.play();
    songPlaying = true;
  }
}

void startGUI(){
  
  color hsb;
  colorMode(HSB, h, s, b);
  hsb = color(h, s, b);
    
  /*rect(850, 100, flowerW+1, flowerH+1);
  translate(flowerW/2, flowerH/2);
    for (int i = 0; i < 360; i+=2) {
      
      float angle = sin(i+flowerNum)*50;
      
      float x = sin(radians(i))*(150+angle);
      float y = cos(radians(i))*(150+angle);
      float x2 = sin(radians(i))*(100+angle);
      float y2 = cos(radians(i))*(100+angle);
      
      stroke(h, s, b);
      fill(h, s, b);
      ellipse(x, y, angle/5, angle/5);
      ellipse(y2, x2, 5, 5);
      line(x, y, x2, y2);
    }
    flowerNum+=0.01;
    */
  
  head = gui.addTextlabel("headlabel")
    .setText("Jimmy Hendrix - Hush Now")
    .setPosition(100,50)
    .setColorValue(0xffffffff)
    .setFont(hendrix)
    ;
    
  labelA = gui.addTextlabel("labelA")
    .setText("Settings: ")
    .setPosition(850, 350)
    .setColorValue(0xffffffff)
    .setFont(createFont("arial", 20))
   ; 
    
  
  gui.addButton("Start")
    .setValue(0)
    .setPosition(750, 600)
    .setSize(100, 25)
    ;

  hSlider = gui.addSlider("h")
    .setPosition(800, 390)
    .setSize(200, 25)
    .setRange(1, 359)
    .setValue(176)
    ;
    
  bSlider = gui.addSlider("b")
    .setPosition(800, 470)
    .setSize(200, 25)
    .setRange(0, 99)
    .setValue(49)
    ;
    
  sSlider = gui.addSlider("s")
    .setPosition(800, 430)
    .setSize(200, 25)
    .setRange(0, 99)
    .setValue(48)
    ;
    
  pixelSlider = gui.addSlider("pixel")
    .setPosition(800, 510)
    .setSize(200, 25)
    .setRange(1, 7)
    .setValue(5)
    .setNumberOfTickMarks(7)
    ;
} 

void h(int theColor){
  h = theColor;
}

void b(int theColor){
  b = theColor;
}

void s(int theColor){
  s = theColor;
}

void pixel(int thePixel){
  pixel = thePixel;
  //println(pixel);
}

public void Start(int theValue){
  force = 25000;
// Updated upstream

  x = width/2;
  y = height/2;
  
  x = width/2;    //fuer mittelpunkt bestimmen
  y = height/2;    // fuer mittelpunkt bestimmen
// Stashed changes
  px = width/2;
  py = height/2;

  drop = new Drop(pixel);
  song.play();
  enableGUI();
  colorMode(HSB, h, s, b);
} 

void enableGUI(){
  gui.controller("Start").setVisible(false);
  head.setVisible(false);
  labelA.setVisible(false);
  hSlider.setVisible(false);
  sSlider.setVisible(false);
  bSlider.setVisible(false);
  pixelSlider.setVisible(false);
}
