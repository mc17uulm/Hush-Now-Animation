class Drum {
  
  PVector pos;
  int sizeX, sizeY;
  color col;
  int fillAlpha;
  boolean growing;
  int beatStrength;
  
  Drum(PVector pos, int sizeX, int sizeY, color col) {
    this.pos = pos;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.col = col;
    growing = true;
    fillAlpha = 150;
    beatStrength = 12;
  }
  
  void display () {
    stroke(col,70);
    fill(col,fillAlpha);
    rectMode(CENTER);
    rect(pos.x, pos.y, sizeX, sizeY);
  }
  
  void beat (int strength) {
    beatStrength = strength;
    if (growing) {
      sizeX += beatStrength;
      sizeY += beatStrength;
      fillAlpha += 20;
    } else if (sizeX > width/2){
      sizeX -= beatStrength;
      sizeY -= beatStrength;
      fillAlpha -= 20;
    }
    if (sizeX == (width/2)+(beatStrength*3)) {
      growing = false;
    }
    //for debugging...
    //System.out.println("drum: "+ this.hashCode() + ", sizeX: " + sizeX + ", sizeY: " + sizeY + ",growing: " + growing + ", time: " + song.position());
  }


}
