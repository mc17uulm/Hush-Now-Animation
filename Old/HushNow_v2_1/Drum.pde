//////////////////////////////////////
// macht momentan nur _einen_ beat :( //
//////////////////////////////////////
class Drum {
  
  int intensity = 10;
  
  PVector pos;
  int sizeX, sizeY;
  color col;
  boolean growing;
  
  Drum(PVector pos, int sizeX, int sizeY, color col) {
    this.pos = pos;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.col = col;
    growing = true;
  }
  
  void display () {
    stroke(col,200);
    fill(col,150);
    rectMode(CENTER);
    rect(pos.x, pos.y, sizeX, sizeY);
  }
  
  void beat () {
    if (growing) {
      sizeX += 8;
      sizeY += 8;
    } else if (sizeX > width/2){
      sizeX -= 8;
      sizeY -= 8;
    }
    if (sizeX > (width/2)+20) {
      growing = false;
    }
  }
}
