import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.opengl.*; 
import javax.media.opengl.*; 
import controlP5.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Hush extends PApplet {

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

// Groe\u00dfe der Pixel
int pixelSize = 5;
int oldPixelSize = 5;

int hoeheKreis, breiteKreis;

boolean start = true;

float sensitivity = 1.0f;
int saturation = 255;
int brightness = 260;

// Koordinaten f\u00fcr dropDrums
float drumX, drumY;

// Gibt Seite des Drops an
int dropCounter = 0;







ControlP5 gui;

Textlabel head;
Textlabel labelA;
Textlabel presets;
ColorPicker cp;

Slider pixelSlider;
Slider hueSlider;
Slider saturationSlider;
Slider variationSlider;

Toggle lightYesNo;
Toggle lineInYesNo;

Button startButton;
Button rottoene;
Button regenbogen;
Button orangetoene;
Button randomColors;
Button blautoene;
Button gelb_gruen;
Button no_red;
Button pastell;
Button blackWhite;

int farbschema = 127;
int breite_des_spektrums = 127;

//pastellversion oder normale version?
boolean light_version = false;

//dieser boolean wird vom toggle geaendert
boolean line_in_version = false;

//dieser boolean ist intern und wird durch line_in_version bestimmt
boolean listenLineIn = false;

PFont hendrix;

boolean guiVisible = true;

boolean showStats = false;

// boolean startDraw = false;


// Variablen f\u00fcr den Drop
float y, x;

// staerke des drops
float force;

// Anzahl der Frames zwischen zwei drops
int beat_drop = 20;
int counter = 0;

long previousTime;
long currentTime;
float timeScale = 1; // Geschwindigkeit der Fl\u00fc\u00dfigkeit ver\u00e4ndern (je H\u00f6her, desto schneller)

final int fixedDeltaTime = (int)(10 / timeScale);
float fixedDeltaTimeSeconds = (float)fixedDeltaTime / 1000;
float leftOverDeltaTime = 0;

boolean songPlaying;

int beatIndex = 0;

int[] beats = {
  10050, 10460, 11040, 11217, 11539, 11770, 12116, 12566, 
  12638, 13073, 13769, 14536, 15197, 16045, 16660, 17380, 
  17728, 17984, 18262, 18971, 19516, 20213, 21030, 21757, 
  22372, 23092, 23731, 24524, 24780, 25100, 27210, 27478, 
  27806, 29849, 30186, 30523, 32171, 32334, 32485, 32659, 
  32821, 33112, 33460, 33622, 33913, 34087, 34389, 34679, 
  35039, 45291, 45906, 46750, 47216, 47682, 48530, 49041, 
  49215, 49691, 49888, 50085, 50248, 50485, 51177, 51815,
  52384, 53050, 53720, 54404, 55000, 55600
};

Drop drop;

// Audio stuff
Minim minim;
AudioPlayer song;
AudioInput in;
BeatDetect beat;

public boolean sketchFullScreen() {
  return true;
}

public void setup () {
  size(displayWidth, displayHeight, OPENGL);
  if (frame != null) {
    frame.setResizable(true);
  }
  noStroke();

  drop = new Drop(pixelSize);
  gui = new ControlP5(this); 
  Terminal t = new Terminal();
  startGUI();

  force = 25000;

  x = width/2;    //fuer mittelpunkt bestimmen
  y = height/2;    // fuer mittelpunkt bestimmen

  //drop = new Drop(pixelSize);

  minim = new Minim(this);
  in = minim.getLineIn();
  song = minim.loadFile("hush.mp3", 512);
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());

  songPlaying = false;
  println("Background Color: " + g.backgroundColor);
}

class Terminal {

  Terminal() {
    hendrix = loadFont("hendrix.vlw");
  }
}

public void makeDrums() {
  // W\u00e4hle einen Wertebereich aus, damit Drum auch erkannt wird
  int pos = beats[beatIndex];
  int border1 = pos - 100;
  int border2 = pos + 100;

  if ((song.position() >= border1) && (song.position() <= border2)) {

    makeDrums(dropCounter);
    dropCounter++;

    // \u00c4ndert die Ecke des jeweiligen DrumDrops
    if (dropCounter == 4) {
      dropCounter = 0;
    }

    // Muss an endg\u00fcltiged DrumArray angepasst werden
    if (beatIndex < beats.length - 1) {
      beatIndex++;
    }
  }
}

public void makeDrums(int i) {
  // Entscheidet wo der Drop gemacht wird: 0 = Norden; 1 = Westen; 2 = S\u00fcden; 3 = Osten;
  switch(i) {
  case 0:   
    drumX = displayWidth/2;
    drumY = 0;
    println("0: DrumX: " + drumX + " DrumY: " + drumY);
    break;
  case 1:   
    drumX = 0;
    drumY = displayHeight/2;
    println("1: DrumX: " + drumX + " DrumY: " + drumY);
    break;
  case 2:   
    drumX = (displayWidth/2);
    drumY = displayHeight;
    println("3: DrumX: " + drumX + " DrumY: " + drumY);
    break;
  case 3:   
    drumX = displayWidth;
    drumY = (displayHeight/2);
    println("2: DrumX: " + drumX + " DrumY: " + drumY);
    break;
  }
  dropDrums();
}

public void draw () {

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
  makeDrums();
  //println(frameRate);

  // line in oder track?
  if (listenLineIn) {
    drop.speed = map(in.mix.level(), 0, 1, 20, 25);
    //adjust volume sensitivity
    sensitivity = 1;
    lineInDrops();
  } else {
    // speed einstellen anhand der lautst\u00e4rke des tracks
    //adjust volume sensitivity
    if (song.position() <= 13063) {
      sensitivity = map(song.position(), 0, 13063, 0.1f, 1);
    } else if (song.position() >= 50000) {
      sensitivity = map(song.position(), 50000, song.length(), 1, 1000);
    }
    drop.speed = map(song.mix.level(), 0, 1, 19, 29);
    guitarDrops();
  }
  //}

  if (showStats) {
    fill(0);
    text(timeScale, 20, 20);
    text(drop.speed, 20, 40);
  }
  if(start){
    fill((int)farbschema + (int)breite_des_spektrums * (int)(sin(drop.density[0][0]*0.0004f)) + 20, saturation, 220 + 137 * (int)(sin(drop.velocity[0][0]*0.01f)));
    stroke(farbschema + breite_des_spektrums * sin(drop.density[0][0]*0.0004f) - 70, saturation, 190 + 137 * sin(drop.velocity[0][0]*0.01f));
    strokeWeight(20);
    hoeheKreis = 200;
    breiteKreis = 200;
    ellipse(width*0.8f, height*0.2f, hoeheKreis, breiteKreis);
    line(width*0.8f, (height*0.2f)-(hoeheKreis/2)+10, (width*0.8f), (height*0.2f) + (hoeheKreis/2) - 10);
    line(width*0.8f, (height*0.2f) + 10, (width*0.8f) - (breiteKreis/3) ,(height*0.2f) + (hoeheKreis/3));
    line(width*0.8f, (height*0.2f) + 10, (width*0.8f) + (breiteKreis/3), (height*0.2f) + (hoeheKreis/3));
    noStroke();
  }
  
  //go back to the menu when the song is over
  if (song.position() > 74000) {
    song.pause();
    song.rewind();
    songPlaying = false;
    listenLineIn = false;
    resetParameter();
    enableGUI();
  }
}

public void drop () {
  if (((int)(x / drop.cellSize) < drop.density.length) && ((int)(y / drop.cellSize) < drop.density[0].length) &&
    ((int)(x / drop.cellSize) > 0) && ((int)(y / drop.cellSize) > 0)) {
    drop.velocity[(int)(x / drop.cellSize)][(int)(y / drop.cellSize)] += force * 0.90f;
  }
}

public void dropDrums() {
  force = 100000;
  //&&((int)(drumY / drop.cellSize) < drop.density[0].length)
  if (((int)(drumX / drop.cellSize) < drop.density.length) &&((int)(drumY / drop.cellSize) < drop.density[0].length) ) {
    drop.velocity[(int)(drumX / drop.cellSize)][(int)(drumY / drop.cellSize)] += force;
  } else {
    drop.velocity[(int)(drumX / drop.cellSize) - 1][(int)(drumY / drop.cellSize) - 1] += force;
  }
}

//drop mit gitarren Werten
public void guitarDrops() {
  force = abs(400000*song.mix.get(500)) + sensitivity*10000*song.mix.level();
  if (force > 35000) {
    drop();
  }
}
//drop mit lineIn Werten
public void lineInDrops() {
  force = abs(400000*in.mix.get(500)) + sensitivity*100000*in.mix.level();
  if (force > 5000) {
    drop();
  }
}


///////////////// GUI ////////////////////

public void startGUI() {  
  

  head = gui.addTextlabel("headlabel")
    .setText("Jimi Hendrix - Hush Now")
      .setPosition(width/14, height/16)
        .setColorValue(0xffffffff)
          .setFont(hendrix)
            //.setFont(createFont("arial", 50))
            ;

  startButton = gui.addButton("Start")
    .setValue(0)
      .setPosition((int)(width/14), (int)(height*0.85f))
        .setSize(100, 25)
          .setVisible(true)
            ;
  hueSlider = gui.addSlider("farbschema")
    .setPosition((int)(width/14), (int)(height/2.5f-50))
      .setSize(200, 25)
        .setRange(1, 255)
          .setValue(127)
            ;

  saturationSlider = gui.addSlider("saturation")
    .setPosition((int)(width/14), (int)(height/2.5f))
      .setSize(200, 25)
        .setRange(1, 255)
          .setValue(255)
            ;
  
  variationSlider = gui.addSlider("breite_des_spektrums")
    .setPosition((int)(width/14), (int)(height/2.5f + 50))
      .setSize(200, 25)
        .setRange(0, 255)
          .setValue(127)
            ;

  pixelSlider = gui.addSlider("pixelSize")
    .setPosition((int)(width/14), (int)(height/2.5f + 100))
      .setSize(200, 25)
        .setRange(1, 15)
          .setValue(5)
            .setNumberOfTickMarks(15)
              ;

  lightYesNo = gui.addToggle("light_version")
    .setPosition((int)(width/14), (int)(height/2.5f + 160))
      .setState(false)
        .setSize(20, 20)
          ;

  lineInYesNo = gui.addToggle("line_in_version")
    .setPosition((int)(width/14)+120, (int)(height/2.5f + 160))
      .setState(false)
        .setSize(20, 20)
          ;



  regenbogen = gui.addButton("regenbogen")
    .setValue(0)
      .setPosition((int)(width/2.5f), (int)(height/2.5f))
        .setSize(100, 25)
          .setVisible(true)
            ;

  pastell = gui.addButton("pastell")
    .setValue(0)
      .setPosition((int)(width/2.5f), (int)(height/2.5f)+50)
        .setSize(100, 25)
          .setVisible(true)
            ;

  blackWhite = gui.addButton("schwarz_weiss")
    .setValue(0)
      .setPosition((int)(width/2.5f), (int)(height/2.5f)+100)
        .setSize(100, 25)
          .setVisible(true)
            ;

  rottoene = gui.addButton("rottoene")
    .setValue(0)
      .setPosition((int)(width/2.5f)+250, (int)(height/2.5f)+50)
        .setSize(100, 25)
          .setVisible(true)
            ;

  orangetoene = gui.addButton("orangetoene")
    .setValue(0)
      .setPosition((int)(width/2.5f)+250, (int)(height/2.5f)+100)
        .setSize(100, 25)
          .setVisible(true)
            ;

  randomColors = gui.addButton("random_Colors")
    .setValue(0)
      .setPosition((int)(width/2.5f)+125, (int)(height/2.5f))
        .setSize(100, 25)
          .setVisible(true)
            ;

  blautoene = gui.addButton("blautoene")
    .setValue(0)
      .setPosition((int)(width/2.5f)+125, (int)(height/2.5f)+50)
        .setSize(100, 25)
          .setVisible(true)
            ;

  gelb_gruen = gui.addButton("gelb_gruen")
    .setValue(0)
      .setPosition((int)(width/2.5f)+250, (int)(height/2.5f))
        .setSize(100, 25)
          .setVisible(true)
            ;

  no_red = gui.addButton("no_red")
    .setValue(0)
      .setPosition((int)(width/2.5f)+125, (int)(height/2.5f)+100)
        .setSize(100, 25)
          .setVisible(true)
            ;

  head.setVisible(true);

  //zum schluss einmal den regenbogenknopf "druecken"
  regenbogen();
} 

public void pixelSize(int thePixel) {
  pixelSize = thePixel;
  println(pixelSize);
}

public void rottoene() {
  hueSlider.setValue(255);
  variationSlider.setValue(30);
  saturationSlider.setValue(255);
  brightness = 260;
}

public void orangetoene() {
  hueSlider.setValue(28); 
  variationSlider.setValue(15);
  saturationSlider.setValue(255);
  brightness = 260;
}

public void regenbogen() {
  hueSlider.setValue(127); 
  variationSlider.setValue(127);
  saturationSlider.setValue(255);
  brightness = 260;
}

public void pastell() {
  saturationSlider.setValue(80);
  brightness = 260;
}

public void schwarz_weiss() {
  saturationSlider.setValue(0);
  brightness = 200;
}


public void random_Colors() {
  hueSlider.shuffle();
  variationSlider.shuffle();
  saturationSlider.shuffle();
  brightness = 260;
}

public void blautoene() {
  hueSlider.setValue(145);
  variationSlider.setValue(20);
  saturationSlider.setValue(255);
  brightness = 260;
}

public void gelb_gruen() {
  hueSlider.setValue(47);
  variationSlider.setValue(17);
  saturationSlider.setValue(255);
  brightness = 260;
}

public void no_red() {
  hueSlider.setValue(127);
  variationSlider.setValue(93);
  saturationSlider.setValue(255);
  brightness = 260;
}

public void Start(int theValue) {
  colorMode(HSB, 255);
  disableGUI();
  start = false;

  // if the user changes the pixelSize
  if (pixelSize != oldPixelSize) {
    drop = new Drop(pixelSize);
    oldPixelSize = pixelSize;
  }
  // startDraw = true;
  // dont play the song if the user chose the lineIn version
  if (line_in_version) {
    timeScale = 1.005f;
    listenLineIn = true;
  } else {
    timeScale = 1;
    listenLineIn = false;
    song.play();
    songPlaying = true;
  }
} 

public void disableGUI() {
  head.setVisible(false);
  hueSlider.setVisible(false);
  saturationSlider.setVisible(false);
  variationSlider.setVisible(false);
  startButton.setVisible(false);
  rottoene.setVisible(false);
  regenbogen.setVisible(false);
  pastell.setVisible(false);
  blackWhite.setVisible(false);
  orangetoene.setVisible(false);
  randomColors.setVisible(false);
  blautoene.setVisible(false);
  gelb_gruen.setVisible(false);
  no_red.setVisible(false);
  pixelSlider.setVisible(false);
  lightYesNo.setVisible(false);
  lineInYesNo.setVisible(false);
  guiVisible = false;
}

public void resetParameter() {
  beatIndex = 0;
  start = true;
}

public void enableGUI() {
  head.setVisible(true);
  hueSlider.setVisible(true);
  saturationSlider.setVisible(true);
  variationSlider.setVisible(true);
  startButton.setVisible(true);
  rottoene.setVisible(true);
  regenbogen.setVisible(true);
  pastell.setVisible(true);
  blackWhite.setVisible(true);
  orangetoene.setVisible(true);
  randomColors.setVisible(true);
  blautoene.setVisible(true);
  gelb_gruen.setVisible(true);
  no_red.setVisible(true);
  pixelSlider.setVisible(true);
  lightYesNo.setVisible(true);
  lineInYesNo.setVisible(true);
  guiVisible = true;
}


public void keyPressed() {

  if (key == CODED) {
    if (keyCode == UP && timeScale <= 1.035f) {
      timeScale += 0.005f;
    }
    if (keyCode == DOWN && timeScale >= 0.5f) {
      timeScale -= 0.005f;
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
    resetParameter();
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

// Velocity: How fast each pixel is moving up or down
// Density: How much "fluid" is in each pixel.

// *note* 
// Density isn't conserved as far as I know. 
// Changing the velocity ends up changing the density too.

class Drop {
  int cellSize;

  // Use 2 dimensional arrays to store velocity and density for each pixel.
  // To access, use this: grid[x/cellSize][y/cellSize]
  float [][] velocity;
  float [][] density;
  float [][] oldVelocity;
  float [][] oldDensity;

  float friction = 0.58f;
  float speed = 20;

  /* Constructor */
  Drop (int sizeOfCells) {
    cellSize = sizeOfCells;
    velocity = new float[PApplet.parseInt(width/cellSize)][PApplet.parseInt(height/cellSize)];
    density = new float[PApplet.parseInt(width/cellSize)][PApplet.parseInt(height/cellSize)];
    println("Width: " + width + " Height: " + height); 
    println("Velocity: " + velocity.length + " " + velocity[0].length +  "\nDensity: " + density.length + " " + density[0].length); 
  }

  /* Drawing */
  public void draw () {
    if (light_version) {
      float sFactor = map(saturation, 0, 255, 0, 1);
      for (int x = 0; x < velocity.length; x++) {
        for (int y = 0; y < velocity[x].length; y++) {
          // HIER kommt die zeile, in der man mit der farbe rumspielen kann.
          fill(farbschema + breite_des_spektrums * sin(density[x][y]*0.0004f), sFactor*(200 + 127 * sin(velocity[x][y]*0.01f)), 255);
          rect(x*cellSize, y*cellSize, cellSize, cellSize);
        }
      }
    } else {
      for (int x = 0; x < velocity.length; x++) {
        for (int y = 0; y < velocity[x].length; y++) {
          // HIER kommt die zeile, in der man mit der farbe rumspielen kann.
          fill(farbschema + breite_des_spektrums * sin(density[x][y]*0.0004f), saturation, brightness + 127 * sin(velocity[x][y]*0.01f));
          rect(x*cellSize, y*cellSize, cellSize, cellSize);
        }
      }
    }
  }

  /* "Fluid" Solving
   Based on http://www.cs.ubc.ca/~rbridson/fluidsimulation/GameFluids2007.pdf
   To help understand this better, imagine each pixel as a spring.
   Every spring pulls on springs adjacent to it as it moves up or down (The speed of the pull is the Velocity)
   This pull flows throughout the window, and eventually deteriates due to friction
   */
  public void solve (float timeStep) {
    // Reset oldDensity and oldVelocity
    oldDensity = (float[][])density.clone();  
    oldVelocity = (float[][])velocity.clone();

    for (int x = 0; x < velocity.length; x++) {
      for (int y = 0; y < velocity[x].length; y++) {
        /* Equation for each cell:
         Velocity = oldVelocity + (sum_Of_Adjacent_Old_Densities - oldDensity_Of_Cell * 4) * timeStep * speed)
         Density = oldDensity + Velocity
         Scientists and engineers: Please don't use this to model tsunamis, I'm pretty sure it's not *that* accurate
         */
        velocity[x][y] = friction * oldVelocity[x][y] + ((getAdjacentDensitySum(x, y) - density[x][y] * 4) * timeStep * speed);
        density[x][y] = oldDensity[x][y] + velocity[x][y];
      }
    }
  }

  public float getAdjacentDensitySum (int x, int y) {
    // If the x or y is at the boundary, use the closest available cell
    float sum = 0;
    if (x-1 > 0)
      sum += oldDensity[x-1][y];
    else
      sum += oldDensity[0][y];

    if (x+1 <= oldDensity.length-1)
      sum += (oldDensity[x+1][y]);
    else
      sum += (oldDensity[oldDensity.length-1][y]);

    if (y-1 > 0)
      sum += (oldDensity[x][y-1]);
    else
      sum += (oldDensity[x][0]);

    if (y+1 <= oldDensity[x].length-1)
      sum += (oldDensity[x][y+1]);
    else
      sum += (oldDensity[x][oldDensity[x].length-1]);

    return sum;
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Hush" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
