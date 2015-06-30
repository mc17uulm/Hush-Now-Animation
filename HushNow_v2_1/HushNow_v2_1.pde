import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
AudioPlayer song;
BeatDetect beat;

PImage peace;
int peaceAlpha;

SoloGit soloGit;
PVector pvSG;

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

  /////// SOLO GUITAR ///////
  color red1 = color (255, 10, 100);
  color red2 = color (230, 10, 60);
  color red3 = color (170, 10, 40); 
  color red4 = color (100, 10, 20);

  pvSG = new PVector(width/2, height/2);
  soloGit = new SoloGit (pvSG, 200, red1, red2, red3, red4);

  /////// DRUM PADS ///////
  //color red = color(255,50,50);
  color red = color(173, 3, 32);
  //color green = color(0,204,0);
  color green = color(110, 2, 20);
  //color blue = color(0,204,255);
  color blue = color(250, 4, 46);
  //color yellow = color(255,230,0);
  color yellow = color(212, 3, 39);

  pvUL = new PVector(width/4, height/4);
  pvUR = new PVector(3*width/4, height/4);
  pvLL = new PVector(width/4, 3*height/4);
  pvLR = new PVector(3*width/4, 3*height/4);

  drumUL = new Drum(pvUL, width/2, height/2, green);
  drumUR = new Drum(pvUR, width/2, height/2, red);
  drumLL = new Drum(pvLL, width/2, height/2, yellow);
  drumLR = new Drum(pvLR, width/2, height/2, blue);

  //  manchmal hängt es bei mir (luis) am anfang extrem,
  //  und nach 1-2 sek ist es normal. das hier mit dem skip behebt es fuer mich 
  song.skip(5000);
  song.skip(-5000);

  song.play();
  songPlaying = true;
}


void draw () {
  beat.detect(song.mix);
  background(0);

  //show peace sign at the end
  if (song.position() > 65000) {
    showPeace();
  } else {
    //for stability
    peaceAlpha = 0;
  }
  
  // display drums
  drumUL.display();
  drumUR.display();
  drumLL.display();
  drumLR.display();
  
  /////// ALL THE BEATS ///////
  beat(10050, drumUL, 30);
  beat(10460, drumUR, 30);
  beat(11040, drumLR, 30);
  beat(11217, drumLL, 30);

  beat(11539, drumUL, 30);
  beat(11770, drumUR, 30);
  beat(12116, drumLR, 30);
  beat(12466, drumLL, 24);
  beat(12466, drumUR, 24);
  beat(12638, drumUL, 24);
  beat(12638, drumLR, 24);
  
  
  beat(24524, drumLL, 12);
  beat(24524, drumUR, 12);
  beat(24795, drumLL, 12);
  beat(24795, drumUR, 12);
  beat(25100, drumLR, 24);
  beat(25100, drumUL, 24);
  


  //run the solo guitar code
  soloGit.run();

  //the line that displays the position in the track
  stroke(230);
  strokeWeight(2);
  fill(230);
  float lineX = map(song.position(), 0, song.length(), 0, width);   
  line(lineX, height, lineX, height-15);
}




//////////////////////////////////////////
//////////////// METHODS ////////////////

void beat (int songPos, Drum dr, int strength) {
  if (song.position() > songPos && song.position() < songPos+130) {
    dr.beat(strength);
  } else if (song.position() >= songPos+130 && song.position() < songPos+170) {
    dr.growing = true;
    dr.sizeX = width/2;
    dr.sizeY = height/2;
    dr.fillAlpha = 150;
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

