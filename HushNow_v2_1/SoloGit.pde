class SoloGit {
  PVector pos, speed;
  int size;
  color col1, col2, col3, col4;
  float speedX, speedY;

  SoloGit(PVector pos, int size, color col1, color col2, color col3, color col4) {
    this.pos = pos;
    speed = new PVector(0,0);
    this.size = size;
    this.col1 = col1;
    this.col2 = col2;
    this.col3 = col3;
    this.col4 = col4;
  }

  void run() {
    move();
    display();
  }

  void display() {
    //TODO: restliche kreise einfuegen, und die farben aus den parametern nehmen
    stroke(250, 50, 50, 200);
    fill(250, 50, 50, 150);
    ellipse(pos.x, pos.y, size * (2 + song.mix.get(500)), size * (2 + song.mix.level()));
  }
  
  //this moves the guitar circle randomly
  void move() {
    speed.set(random(-1,1),random(-1,1));
    speed.mult(10*song.mix.get(500));
    pos.add(speed);
  }
}

