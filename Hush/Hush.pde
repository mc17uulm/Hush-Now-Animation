/**
 * Hush Now Animation - Jimmy Hendrix 
 * by Luis Beaucamp, Tim Stenzel and Marco Combosch
 * made 2015
 *
 * Credits:
 *   Wateranimation by:
 *     Jared "BlueThen" C. on June 5th, 2011
 *     Updated June 7th, 2011
 *     Circus Fluid
 */

// Groeße der Pixel
int pixelSize = 5;
int oldPixelSize = 5;

// Koordinaten für dropDrums
float drumX, drumY;

// Gibt Seite des Drops an
int dropCounter = 0;

import processing.opengl.*;
import javax.media.opengl.*;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

ControlP5 gui;

Textlabel head;
Textlabel labelA;
Textlabel presets;
ColorPicker cp;

Slider pixelSlider;
Slider hueSlider;
Slider variationSlider;

Toggle pastellYesNo;
Toggle lineInYesNo;

Button startButton;
Button rottoene;
Button regenbogen;
Button orangetoene;

int farbschema = 127;
int breite_des_spektrums = 127;

//pastellversion oder normale version?
boolean pastell_version = false;

//dieser boolean wird vom toggle geaendert
boolean line_in_version = false;

//dieser boolean ist intern und wird durch line_in_version bestimmt
boolean listenLineIn = false;

PFont hendrix;

boolean guiVisible = true;

boolean showStats = false;

// boolean startDraw = false;


// Variablen für den Drop
float y, x;

// staerke des drops
float force;

// Anzahl der Frames zwischen zwei drops
int beat_drop = 20;
int counter = 0;

long previousTime;
long currentTime;
float timeScale = 1; // Geschwindigkeit der Flüßigkeit verändern (je Höher, desto schneller)

final int fixedDeltaTime = (int)(10 / timeScale);
float fixedDeltaTimeSeconds = (float)fixedDeltaTime / 1000;
float leftOverDeltaTime = 0;

boolean songPlaying;

int beatIndex = 0;

int[] beats = {
  10050, 10460, 11040, 11217, 
  11539, 11770, 12116, 12566, 12638, 
  24524, 24795, 25100
};

Drop drop;

// Audio stuff
Minim minim;
AudioPlayer song;
AudioInput in;
BeatDetect beat;

boolean sketchFullScreen() {
  return true;
}

void setup () {
  size(displayWidth, displayHeight, OPENGL);
  if (frame != null) {
    frame.setResizable(true);
  }
  noStroke();

  gui = new ControlP5(this); 
  Terminal t = new Terminal();
  startGUI();

  force = 25000;

  x = width/2;    //fuer mittelpunkt bestimmen
  y = height/2;    // fuer mittelpunkt bestimmen

  drop = new Drop(pixelSize);
  
  minim = new Minim(this);
  in = minim.getLineIn();
  song = minim.loadFile("hush.mp3", 512);
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());

  songPlaying = false;
}

class Terminal {

  Terminal() {
    hendrix = loadFont("hendrix.vlw");
  }
}

void makeDrums(){
  // Wähle einen Wertebereich aus, damit Drum auch erkannt wird
  int pos = beats[beatIndex];
  int border1 = pos - 100;
  int border2 = pos + 100;
  
  if((song.position() >= border1) && (song.position() <= border2)){
    
    makeDrums(dropCounter);
    dropCounter++;
    
    // Ändert die Ecke des jeweiligen DrumDrops
    if(dropCounter == 4){
      dropCounter = 0;
    }
    
    // Muss an endgültiged DrumArray angepasst werden
    if(beatIndex < 10){
      beatIndex++;
    }
  }
}

void makeDrums(int i){
    // Entscheidet wo der Drop gemacht wird: 0 = Norden; 1 = Westen; 2 = Süden; 3 = Osten;
    switch(i){
      case 0:   drumX = displayWidth/2;
                drumY = 0;
                println("0: DrumX: " + drumX + " DrumY: " + drumY);
                break;
      case 1:   drumX = 0;
                drumY = displayHeight/2;
                println("1: DrumX: " + drumX + " DrumY: " + drumY);
                break;
      case 2:   drumX = (displayWidth/2);
                drumY = displayHeight;
                println("3: DrumX: " + drumX + " DrumY: " + drumY);
                break;
      case 3:   drumX = displayWidth;
                drumY = (displayHeight/2);
                println("2: DrumX: " + drumX + " DrumY: " + drumY);
                break;
    }
    dropDrums();
}

void draw () {

  //beat.detect(song.mix);
  //if(startDraw){
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
  
    drop.draw();
    guitarDrops();
    makeDrums();
    //println(frameRate);
  
    // line in oder track?
    if (listenLineIn) {
      drop.speed = map(in.mix.level(), 0, 1, 20, 25);
      lineInDrops();
    } else {
      // speed einstellen anhand der lautstärke des tracks
      drop.speed = map(song.mix.level(), 0, 1, 19, 29);
      guitarDrops();
    }
  //}
  
    if (showStats) {
      fill(0);
      text(timeScale, 20, 20);
      text(drop.speed, 20, 40);
    }
}

void drop () {
  if (((int)(x / drop.cellSize) < drop.density.length) && ((int)(y / drop.cellSize) < drop.density[0].length) &&
    ((int)(x / drop.cellSize) > 0) && ((int)(y / drop.cellSize) > 0)) {
    drop.velocity[(int)(x / drop.cellSize)][(int)(y / drop.cellSize)] += force * 0.90;
  }
}

void dropDrums(){
  //&&((int)(drumY / drop.cellSize) < drop.density[0].length)
   if (((int)(drumX / drop.cellSize) < drop.density.length) &&((int)(drumY / drop.cellSize) < drop.density[0].length) ){
    drop.velocity[(int)(drumX / drop.cellSize)][(int)(drumY / drop.cellSize)] += force; 
  } else{
    drop.velocity[(int)(drumX / drop.cellSize) - 1][(int)(drumY / drop.cellSize) - 1] += force;
  }
}

//drop mit gitarren Werten
void guitarDrops() {
  force = abs(400000*song.mix.get(500)) + 10000*song.mix.level();
  if (force > 35000) {
    drop();
  }
}
//drop mit lineIn Werten
void lineInDrops() {
  force = abs(400000*in.mix.get(500)) + 100000*in.mix.level();
  if (force > 5000) {
    drop();
  }
}

void startGUI() {  
  
  head = gui.addTextlabel("headlabel")
    .setText("Jimi Hendrix - Hush Now")
      .setPosition(100, 50)
        .setColorValue(0xffffffff)
          //    .setFont(hendrix)
          .setFont(createFont("arial", 50))
            ;

  presets = gui.addTextlabel("presets")
    .setText("Presets:  ")
      .setPosition(600, 350)
        .setColorValue(0xffffffff)
          .setFont(createFont("arial", 25))
            ;  

  startButton = gui.addButton("Start")
    .setValue(0)
      .setPosition(100, 600)
        .setSize(100, 25)
          .setVisible(true)
            ;

  rottoene = gui.addButton("rottoene")
    .setValue(0)
      .setPosition(600, 450)
        .setSize(100, 25)
          .setVisible(true)
            ;

  regenbogen = gui.addButton("regenbogen")
    .setValue(0)
      .setPosition(600, 400)
        .setSize(100, 25)
          .setVisible(true)
            ;

  orangetoene = gui.addButton("orangetoene")
    .setValue(0)
      .setPosition(600, 500)
        .setSize(100, 25)
          .setVisible(true)
            ;

  hueSlider = gui.addSlider("farbschema")
    .setPosition(100, 390)
      .setSize(200, 25)
        .setRange(1, 255)
          .setValue(127)
            ;

  variationSlider = gui.addSlider("breite_des_spektrums")
    .setPosition(100, 430)
      .setSize(200, 25)
        .setRange(0, 255)
          .setValue(127)
            ;

  pastellYesNo = gui.addToggle("pastell_version")
    .setPosition(100, 520)
      .setState(false)
        .setSize(20, 20)
          ;

  lineInYesNo = gui.addToggle("line_in_version")
    .setPosition(200, 520)
      .setState(false)
        .setSize(20, 20)
          ;

  pixelSlider = gui.addSlider("pixel")
    .setPosition(100, 470)
      .setSize(200, 25)
        .setRange(1, 7)
          .setValue(5)
            .setNumberOfTickMarks(7)
              ;

  head.setVisible(true);
  presets.setVisible(true);
} 

/*
void h(int theColor){
 h = theColor;
 }
 
 void b(int theColor){
 b = theColor;
 }
 
 void s(int theColor){
 s = theColor;
 }
 */
void pixel(int thePixel){
 pixelSize = thePixel;
 println(pixelSize);
 }

public void rottoene() {
  hueSlider.setValue(255);
  variationSlider.setValue(30);
}

public void orangetoene() {
  hueSlider.setValue(28); 
  variationSlider.setValue(15);
}

public void regenbogen() {
  hueSlider.setValue(127); 
  variationSlider.setValue(127);
}

public void Start(int theValue) {
  colorMode(HSB, 255);
  disableGUI();
  
  // if the user changes the pixelSize
  if (pixelSize != oldPixelSize) {
    drop = new Drop(pixelSize);
    oldPixelSize = pixelSize;
  }
  //startDraw = true;
  // dont play the song if the user chose the lineIn version
  if (line_in_version) {
    timeScale = 1.035;
    listenLineIn = true;
  } else {
    listenLineIn = false;
    song.play();
    songPlaying = true;
  }
} 

void disableGUI() {
  head.setVisible(false);
  presets.setVisible(false);
  hueSlider.setVisible(false);
  variationSlider.setVisible(false);
  startButton.setVisible(false);
  rottoene.setVisible(false);
  regenbogen.setVisible(false);
  orangetoene.setVisible(false);
  pixelSlider.setVisible(false);
  pastellYesNo.setVisible(false);
  lineInYesNo.setVisible(false);
  guiVisible = false;
}

void enableGUI() {
  head.setVisible(true);
  presets.setVisible(true);
  hueSlider.setVisible(true);
  variationSlider.setVisible(true);
  startButton.setVisible(true);
  rottoene.setVisible(true);
  regenbogen.setVisible(true);
  orangetoene.setVisible(true);
  pixelSlider.setVisible(true);
  pastellYesNo.setVisible(true);
  lineInYesNo.setVisible(true);
  guiVisible = true;
}


void keyPressed() {

  if (key == CODED) {
    if (keyCode == UP && timeScale <= 1.035) {
      timeScale += 0.005;
    }
    if (keyCode == DOWN && timeScale >= 0.5) {
      timeScale -= 0.005;
    }
  }

  if (key == ' ' && songPlaying) {
    song.pause();
    songPlaying = false;
  } else if (key == ' ' && !songPlaying && !guiVisible) {
    song.play();
    songPlaying = true;
  }

  if (key == 'x') {
    song.pause();
    song.rewind();
    songPlaying = false;
    listenLineIn = false;
    enableGUI();
  }

  if (key == 's') {
    saveFrame("hushNow_######.png");
  }

  //um die zahlen oben links mal kurz einzublenden
  if (key == 'i') {
    showStats = !showStats;
  }
}

