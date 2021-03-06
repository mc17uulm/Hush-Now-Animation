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

  float friction = 0.58;
  float speed = 20;

  /* Constructor */
  Drop (int sizeOfCells) {
    cellSize = sizeOfCells;
    velocity = new float[int(width/cellSize)][int(height/cellSize)];
    density = new float[int(width/cellSize)][int(height/cellSize)];
    println("Width: " + width + " Height: " + height); 
    println("Velocity: " + velocity.length + " " + velocity[0].length +  "\nDensity: " + density.length + " " + density[0].length); 
  }

  /* Drawing */
  void draw () {
    if (light_version) {
      float sFactor = map(saturation, 0, 255, 0, 1);
      for (int x = 0; x < velocity.length; x++) {
        for (int y = 0; y < velocity[x].length; y++) {
          // HIER kommt die zeile, in der man mit der farbe rumspielen kann.
          fill(farbschema + breite_des_spektrums * sin(density[x][y]*0.0004), sFactor*(200 + 127 * sin(velocity[x][y]*0.01)), 255);
          rect(x*cellSize, y*cellSize, cellSize, cellSize);
        }
      }
    } else {
      for (int x = 0; x < velocity.length; x++) {
        for (int y = 0; y < velocity[x].length; y++) {
          // HIER kommt die zeile, in der man mit der farbe rumspielen kann.
          fill(farbschema + breite_des_spektrums * sin(density[x][y]*0.0004), saturation, brightness + 127 * sin(velocity[x][y]*0.01));
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
  void solve (float timeStep) {
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

  float getAdjacentDensitySum (int x, int y) {
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

