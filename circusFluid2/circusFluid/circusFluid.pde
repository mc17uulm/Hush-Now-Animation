/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/29833*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/* 
 Circus Fluid
 Made by Jared "BlueThen" C. on June 5th, 2011.
 Updated June 7th, 2011 (Commenting, refactoring, coloring changes)
 
 www.bluethen.com
 www.twitter.com/BlueThen
 www.openprocessing.org/portal/?userID=3044
 www.hawkee.com/profile/37047/
 
 Feel free to email me feedback, criticism, advice, job offers at:
 bluethen (@) gmail.com
 */

import ddf.minim.*;
import ddf.minim.analysis.*;

// Variables for the timeStep
float y, x, px, py;

// staerke des drops
float force;

// Groeße der Pixel
int pixelSize = 4;

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


// The grid for fluid solving
GridSolver grid;

Minim minim;
AudioPlayer song;
BeatDetect beat;

void setup () {
  size(800, 600, P2D);
  colorMode(HSB, 255);
  noStroke();

  force = 25000;

  x = width/2;
  y = height/2;
  px = width/2;
  py = height/2;

  // grid = new GridSolver(integer cellWidth)
  grid = new GridSolver(pixelSize);

  minim = new Minim(this);
  song = minim.loadFile("hush.mp3", 512);
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  
  songPlaying = false;
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
    grid.solve(fixedDeltaTimeSeconds * timeScale);
  }


  /*
  * drop alle x sekunden
   
   if(counter == beat_drop){
   drop();
   counter = 0;
   }
   */

  grid.draw();
  guitarDrops();
  //println(frameRate);
  
  
  grid.speed = map(song.mix.level(), 0, 1, 19, 29.5); //oder so ähnlich
  
  fill(0);
  text(timeScale, 20, 20);
  text(grid.speed, 20, 40);
  
}

//////////////// FUNCTIONS ////////////////

void drag () {
  // The ripple size will be determined by mouse speed
  float force = dist(x, y, px, py) * 255;

  /* This is bresenham's line algorithm
   http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
   Instead of plotting points for a line, we create a ripple for each pixel between the
   last cursor pos and the current cursor pos 
   */
  float dx = abs(x - px);
  float dy = abs(y - py);
  float sx;
  float sy;
  if (px < x)
    sx = 1;
  else
    sx = -1;
  if (py < y)
    sy = 1;
  else
    sy = -1;
  float err = dx - dy;
  float x0 = px;
  float x1 = x;
  float y0 = py;
  float y1 = y;
  while ( (x0 != x1) || (y0 != y1)) {
    // Make sure the coordinate is within the window
    if (((int)(x0 / grid.cellSize) < grid.density.length) && ((int)(y0 / grid.cellSize) < grid.density[0].length) &&
      ((int)(x0 / grid.cellSize) > 0) && ((int)(y0 / grid.cellSize) > 0))
      grid.velocity[(int)(x0 / grid.cellSize)][(int)(y0 / grid.cellSize)] += force;
    float e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      x0 = x0 + sx;
    }
    if (e2 < dx) {
      err = err + dx;
      y0 = y0 + sy;
    }
  }
}

// If the user clicks instead of drags the mouse, we create a ripple at one spot.
void drop () {
  if (((int)(x / grid.cellSize) < grid.density.length) && ((int)(y / grid.cellSize) < grid.density[0].length) &&
    ((int)(x / grid.cellSize) > 0) && ((int)(y / grid.cellSize) > 0)) {
    grid.velocity[(int)(x / grid.cellSize)][(int)(y / grid.cellSize)] += force;
  }
}



//drop mit abgegriffenen werten
void guitarDrops() {
  force = abs(400000*song.mix.get(500)) + 10000*song.mix.level();
  if (force > 50000) {
    drop();
    //evtl. grid.speed mit veraendern, um staerkeren effekt zu bekommen?
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
    grid.speed = 21.25;
  }
  if (key == '2') {
    grid.speed = 20;
  }
  if (key == '1') {
    grid.speed = 19;
  }

  if (key == ' ' && songPlaying) {
    song.pause();
    songPlaying = false;
  } else if (key == ' ' && !songPlaying) {
    song.play();
    songPlaying = true;
  }
}

