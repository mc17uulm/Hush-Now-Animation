class SoloGit {
  PVector pos, speed;
  int size;
  color col1, col2, col3, col4;
  float speedX, speedY;

  SoloGit(PVector pos, int size, color col1, color col2, color col3, color col4) {
    this.pos = pos;
    speed = new PVector(0, 0);
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
    stroke(col1, 200);
    fill(col1, 150);
    ellipse(pos.x, pos.y, size * (2 + song.mix.get(500)), size * (2 + song.mix.level()));

    stroke(col2, 200);
    fill(col2, 150);
    ellipse(pos.x, pos.y, (size/1.3) * (2 + song.mix.get(500)), (size/1.3) * (2 + song.mix.level()));

    stroke(col3, 200);
    fill(col3, 150);
    ellipse(pos.x, pos.y, (size/2) * (2 + song.mix.get(500)), (size/2) * (2 + song.mix.level()));

    stroke(col4, 200);
    fill(col4, 150);
    ellipse(pos.x, pos.y, (size/4) * (2 + song.mix.get(500)), (size/4) * (2 + song.mix.level()));
    
  }

  //this moves the guitar circle randomly
  void move() {
    speed.set(random(-1, 1), random(-1, 1));
    speed.mult(10*song.mix.get(500));
    pos.add(speed);
  }
  
  void grow (int speed) {
    size += speed;
  }
  
  void shrink (int speed) {
    size -= speed;
  }
  
}

