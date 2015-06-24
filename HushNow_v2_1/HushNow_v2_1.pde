import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioInput in;
AudioPlayer song;
BeatDetect beat;

PImage peace;
int peaceAlpha;

Drum drumUL, drumUR, drumLL, drumLR;
PVector pvUL, pvUR, pvLL, pvLR;

boolean songPlaying;

void setup() {
  size(800, 600);
  minim = new Minim(this);
  song = minim.loadFile("hush.mp3", 512);
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());

  peace = loadImage("peace.png");
  peaceAlpha = 0;

  ////// DRUM PADS ///////
  //color red = color(255,50,50);
  color red = color(196, 3, 10);
  //color green = color(0,204,0);
  color green = color(0, 198, 19);
  //color blue = color(0,204,255);
  color blue = color(0, 122, 221);
  //color yellow = color(255,230,0);
  color yellow = color(226, 210, 0);

  pvUL = new PVector(width/4, height/4);
  pvUR = new PVector(3*width/4, height/4);
  pvLL = new PVector(width/4, 3*height/4);
  pvLR = new PVector(3*width/4, 3*height/4);

  drumUL = new Drum(pvUL, width/2, height/2, red);
  drumUR = new Drum(pvUR, width/2, height/2, green);
  drumLL = new Drum(pvLL, width/2, height/2, blue);
  drumLR = new Drum(pvLR, width/2, height/2, yellow);

  // sehr seltsam, bei mir (luis) hängt es am anfang seit heute extrem,
  // und nach 1-2 sek ist es normal. das hier mit dem skip behebt es fuer mich 
  song.skip(5000);
  song.skip(-5000);
  
  song.play();
  songPlaying = true;
}


void draw () {
  beat.detect(song.mix);
  background(0);

  if (song.position() > 65000) {
    showPeace();
  } else {
    peaceAlpha = 0;
  }

  drumUL.display();
  drumUR.display();
  drumLL.display();
  drumLR.display();

  beat(10050, drumUL);
  beat(10460, drumUR);
  beat(11040, drumLR);
  beat(11217, drumLL);


  /*
  beat(20050, drumUL);
   beat(20460, drumUR);
   beat(21040, drumLR);
   beat(21217, drumLL);
   */

  //the line that displays the position in the track
  stroke(230);
  strokeWeight(2);
  fill(230);
  float lineX = map(song.position(), 0, song.length(), 0, width);   
  line(lineX, height, lineX, height-15);


  // test guitar
  stroke(250, 50, 50, 200);
  fill(250, 50, 50, 150);
  ellipse(width/2, height/2, 50 * (2 + song.mix.get(500)), 50 * (2 + song.mix.level()));
}




//////////////////////////////////////////
//////////////// METHODS ////////////////

void beat (int songPos, Drum dr) {
  if (song.position() > songPos && song.position() < songPos+150) {
    dr.beat();
  } else {
    dr.growing = true;
  }
}

void showPeace() {
  int picSize = min(width, height);
  tint(255, peaceAlpha/2);
  imageMode(CENTER);
  image(peace, width/2, height/2, picSize, picSize);
  if (peaceAlpha < 255) {
    peaceAlpha++;
  }
}


/*
* klappt noch nicht,
 * es darf nicht nach jedem durchlauf
 * eine verschiedene drum angesprochen werden
 *
/*
 Drum randomDrum () {
 Drum returnDrum = null;
 int x = (int)random(0,3.9);
 switch (x) {
 case 0: returnDrum = drumUL;
 System.out.println(x);
 break;
 case 1: returnDrum = drumUR;
 System.out.println(x);
 break;
 case 2: returnDrum = drumLL;
 System.out.println(x);
 break;
 case 3: returnDrum = drumLR;
 System.out.println(x);
 }
 return returnDrum;
 }
 */



//////////////////////////////////////////
//////////////// CONTROLS ////////////////

void keyPressed() {

  /////// GET CURRENT POSITION IN SONG ///////
  if (key == 'p') {
    System.out.println("current position ca.: "+(song.position()-200));
  }

  /////// PLAY,PAUSE ///////
  if (key == ' ' && !songPlaying) {
    loop();
    song.play();
    songPlaying = true;
  } else if (key == ' ' && songPlaying) {
    song.pause();
    noLoop();
    songPlaying = false;
  }

  if (key == CODED) {

    /////// LEFT ///////
    if (keyCode == LEFT) {
      if (song.position() > 5000) {
        song.skip(-5000);
        redraw();
      } else {
        song.rewind();
        redraw();
      }
    }

    if (keyCode == RIGHT && song.position() < song.length()-5000) {  
      song.skip(5000);
      redraw();
    }
  }
}


void mousePressed() {
  int mousePos = (int) map(mouseX, 0, width, 0, song.length());
  song.cue(mousePos);
  redraw();
}


//working, but really slowing down when rewinding with this method
void mouseDragged() {
  int mousePos = (int) map(mouseX, 0, width, 0, song.length());
  if (mousePos % 4 == 0) {
    song.cue(mousePos);
    redraw();
  }
}

