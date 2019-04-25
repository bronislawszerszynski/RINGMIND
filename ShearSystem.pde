Boolean Moonlet = false;
Boolean Self_Grav = false;
Boolean Collisions =true;
Boolean A1 =true;
Boolean A2 =true;
Boolean Guides = false;
Boolean Reset =true;

final float SG = 6.67408e-11; //Shear Gravitational Constant

ShearingBox s;

//-------------------------------------

//Simulation dimensions [m]
int Lx = 1000;       //Extent of simulation box along planet-point line [m].
int Ly = 2000;       //Extent of simulation box along orbit [m].
//Initialises Simulation Constants
final float SGM = 3.793e16;   //Shear Gravitational parameter for the central body, defaults to Saturn  GM = 3.793e16.
final float r0 = 130000e3;   //Central position in the ring [m]. Defaults to 130000 km.
//Ring Particle Properties
final float particle_rho = 900.0;  //Density of a ring particle [kg/m^3].
final float particle_a = 0.01;     //Minimum size of a ring particle [m].
final float particle_b = 10.0;     //Maximum size of a ring particle [m].
final float particle_lambda = 5;   //Power law index for the size distribution [dimensionless].
final float particle_D =1.0/( exp(-particle_lambda*particle_a) -exp(-particle_lambda*particle_b));
final float particle_C =particle_D * exp(-particle_lambda*particle_a);
//Ring Moonlet Properties
float moonlet_r = 50.0;            //Radius of the moonlet [m].
final float moonlet_density = 1000.0; //Density of the moonlet [kg/m]
float moonlet_GM = SG*(4.0*PI/3.0)*pow(moonlet_r, 3.0)*moonlet_density; //Standard gravitational parameter.
//
final float Omega0 = sqrt(SGM/(pow(r0, 3.0))); //The Keplerian orbital angular frequency (using Kepler's 3rd law). [radians/s]
final float S0 = -1.5*Omega0; //"The Keplerian shear. Equal to -(3/2)Omega for a Keplerian orbit or -rdOmega/dr. [radians/s]



float num_particles = 50000; //if not using table we can use more than 1000

float scale =10.0; //Makes Particles Visible

//Simulation Time step [s]
float dt =100; //Rough Time Set to be able to see affects. 

//----------------------------------------------------------------

class ShearingBox {

  Material material = null;

  ArrayList<ShearParticle> Sparticles;  // ArrayList for all "Particles" in Shearing Box
  ArrayList<ShearParticle>[][] grid;   // Grid of ArrayLists
  int scl = 5;                    // Size of each grid cell (in Simulation) [m]
  int cols, rows;                 // Total coluns and rows

  /**CONSTUCTOR Shearing Box 
   */
  ShearingBox() {
    //Initialise our ShearingBox Object.
    Sparticles = new ArrayList<ShearParticle>(); 
    cols = Ly/scl;
    rows = Lx/scl;

    // Initialize grid as 2D array of empty ArrayLists
    grid = new ArrayList[cols+1][rows+1];
    for (int i = 0; i < cols+1; i++) {
      for (int j = 0; j < rows+1; j++) {
        grid[i][j] = new ArrayList<ShearParticle>();
      }
    }
    //println(Omega0+ " " + S0);

    random_start();
   // initTable();
  }


  void initTable() {
    if (Reset) {
      //for (Particle x : particles) {
      //  // Zero acceleration to start
      //  x.Reset();
      //}

      Table table; 
      table = loadTable("./files/shearoutput.csv");//"input.csv"

      Sparticles.clear();

      for (int i = 0; i < table.getRowCount(); i++) {
        ShearParticle temp = new ShearParticle();
        temp.position.x= table.getFloat(i, 0);
        temp.position.y= table.getFloat(i, 1);
        temp.position.z= table.getFloat(i, 2);
        temp.velocity.x= table.getFloat(i, 3);
        temp.velocity.y= table.getFloat(i, 4);
        temp.velocity.z= table.getFloat(i, 5);
        temp.acceleration.x= table.getFloat(i, 6);
        temp.acceleration.y= table.getFloat(i, 7);
        temp.acceleration.z= table.getFloat(i, 8);
        Sparticles.add(temp);
      }

      Reset =false;
    }
  }

  /** 
   */
  void display() {
    push();
    translate(width/2, height/2);
    fill(255);
    if (Moonlet) {
      circle(0, 0, moonlet_r);
    }

    for (ShearParticle x : Sparticles) {
      // Zero acceleration to start
      x.display();
    }


    pop();
  }

  /** Method to update position
   */
  void update() {
    for (ShearParticle sp : Sparticles) {
      sp.highlight = false;
    }

    step_verlet();
    //if ( frameCount %100 == 0) {
    //  saveTable(particlesToTable(), "/files/output.csv");
    //}
    //   if (Collisions) {

    //  grid_update();
    //}
  }


  Table particlesToTable() {
    Table tempTable = new Table();

    for (int j=0; j<9; j++) {
      tempTable.addColumn();
    }

    for (ShearParticle sp : Sparticles) {
      TableRow newRow =tempTable.addRow();
      newRow.setFloat(0, sp.position.x);
      newRow.setFloat(1, sp.position.y);
      newRow.setFloat(2, sp.position.z);
      newRow.setFloat(3, sp.velocity.x);
      newRow.setFloat(4, sp.velocity.y);
      newRow.setFloat(5, sp.velocity.z);
      newRow.setFloat(6, sp.acceleration.x);
      newRow.setFloat(7, sp.acceleration.y);
      newRow.setFloat(8, sp.acceleration.z);
    }



    return tempTable;
  }



  /** Take a step using the Velocity Verlet (Leapfrog) ODE integration algorithm.
   *   TODO: Check Algorithm is correct.
   */
  void step_verlet() {

    //Calculate first approximation for acceleration
    for (ShearParticle x : Sparticles) {
      // Zero acceleration to start
      x.set_getAcceleration(this);
    }

    // Integrate to get approximation for new position and velocity
    for (ShearParticle x : Sparticles) {
      // Zero acceleration to start
      x.updatePosition();
    }



    //Calculate Second Approximation to the acceleration.
    for (ShearParticle x : Sparticles) {
      // Zero acceleration to start
      x.updateVelocity(x.getAcceleration(this));
    }

    //Have any particles left the simulation box, or collided with the moonlet?
    //If so, remove and replace them.
    for (ShearParticle x : Sparticles) {
      if (particle_outBox(x)) {
        x.Reset();
      }
      if (Moonlet) {
        if (particle_inMoonlet(x)) {
          x.Reset();
        }
      }
    }
  }


  /** Method to boolean if Particle is out of ShearingBox.
   *@param x  A Particle to inject.
   *@return True if out of Shearing Box
   */
  boolean particle_outBox(ShearParticle x) {
    if ((x.position.x >Lx/2)||(x.position.x<-Lx/2)||(x.position.y<-Ly/2)||(x.position.y>Ly/2)) {
      return true;
    } else {
      return false;
    }
  }
  /** Method to boolean if Particle is out of ShearingBox.
   *@param x  A Particle to inject.
   *@return True if out of Shearing Box
   */
  boolean particle_inMoonlet(ShearParticle x) {
    if ((x.position.mag() < moonlet_r)) {
      //moonlet_r +=x.radius*0.1; 
      //moonlet_GM += x.GM;
      return true;
    } else {
      return false;
    }
  }
  /** Method to inject a number of Particle object into Shearing Box.
   *@param n  Number of Particle to inject.
   */
  void random_inject(float n) {
    //particles.add(new Moonlet());
    for (int i = 0; i < n; i++) {
      Sparticles.add(new ShearParticle());
    }
  }

  /** Method to Initialise the simulation with a random set of starting particles at the edges (in y).
   */
  void random_start() {
    random_inject(num_particles);
  }

  /** Method to calculate the Keplerian orbital period (using Kepler's 3rd law).
   *@param r  Radial position (semi-major axis) to calculate the period [m].
   *@return   The period [s].
   */
  float kepler_period(float r) {
    return 2.0*PI*sqrt((pow(r, 3.0))/SGM);
  }

  /** Method to calculate the Keplerian orbital angular frequency (using Kepler's 3rd law).
   *@param r  Radial position (semi-major axis) to calculate the period [m].
   *@return   The angular frequency [radians/s].
   */
  float kepler_omega(float r) {
    return sqrt(SGM/(pow(r, 3.0)));
  }

  /** Method to calculate the Keplerian orbital speed.
   *@param r  Radial position (semi-major axis) to calculate the period [m].
   *@return   The speed [m/s].
   */
  float kepler_speed(float r) {
    return sqrt(SGM/r);
  }

  /** Method to calculate the Keplerian shear. Equal to -(3/2)Omega for a Keplerian orbit or -rdOmega/dr.
   *@param r Radial position (semi-major axis) to calculate the period [m]. 
   *@return Shear [radians/s].
   */
  float kepler_shear(float r) {
    return -1.5*kepler_omega(r);
  }

  void grid_update() {

    // Every time through draw clear all the lists
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        grid[i][j].clear();
      }
    }

    // Register every Thing object in the grid according to it's position
    for (ShearParticle sp : Sparticles) {

      int x = (int(sp.position.x) +Lx/2)/ scl;   //
      int y = (int(sp.position.y) +Ly/2)/scl;     //

      //println("y: " + y + "x: " + x);

      grid[y][x].add(sp);
      // as well as its 8 neighbors 

      //for (int n = -1; n <= 1; n++) {
      //  for (int m = -1; m <= 1; m++) {
      //    if (x+n >= 0 && x+n < cols && y+m >= 0 && y+m< rows) grid[x+n][y+m].add(t);
      //  }
      //}
    }



    // Run through the Grid
    for (int i = 0; i < cols; i++) {
      //line(i*scl,0,i*scl,height);
      for (int j = 0; j < rows; j++) {
        //line(0,j*scl,width,j*scl);

        // For every list in the grid
        ArrayList<ShearParticle> temp = grid[i][j];
        // Check every Particle 
        for (ShearParticle p : temp) {
          // Against every other Particle in the grid
          for (ShearParticle other : temp) {
            // As long as its not the same one
            if (other != p) {



              // Check to see if they are touching
              // (We could do many other things here besides just intersection tests, such
              // as apply forces, etc.)
              float dis = dist(p.position.x, p.position.y, other.position.x, other.position.y);
              if (dis < p.radius + other.radius) {               
                collision(p, other);
              }
            }
          }
        }

        fill(temp.size()*30, temp.size()*10, 0);
        rect(i*scl, j*scl, scl, scl);
      }
    }
  }

  /** Collision between 2 Particle Objects
   *   TODO: Check Algorithm is correct.
   */
  void collision(ShearParticle p, ShearParticle other) {
    println("collision");

    // Get distances between the balls components
    PVector distanceVect = PVector.sub(p.position, other.position);

    // Calculate magnitude of the vector separating the balls
    float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    float minDistance = p.radius + other.radius;

    if (distanceVectMag < minDistance) {
      float distanceCorrection = (minDistance-distanceVectMag)/2.0;
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.position.x += correctionVector.x;
      other.position.y += correctionVector.y;
      p.position.x -= correctionVector.x;
      p.position.y -= correctionVector.y;

      // get angle of distanceVect
      float theta  = distanceVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      /* this ball's position is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       bTemp[0].position.x and bTemp[0].position.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * p.velocity.x + sine * p.velocity.y;
      vTemp[0].y  = cosine * p.velocity.y - sine * p.velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated velocity for b[0]
      vFinal[0].x = ((p.m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (p.m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - p.m) * vTemp[1].x + 2 * p.m * vTemp[0].x) / (p.m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = p.position.x + bFinal[1].x;
      other.position.y = p.position.y + bFinal[1].y;

      p.position.x += bFinal[0].x;
      p.position.y += bFinal[0].y;

      // update velocities
      p.velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      p.velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    }
  }
}



//------------------------------------- SHEAR PARTICLE -------------------------------------------------------


class ShearParticle {


  PVector position; //position vector
  //position.x;    //Position of Particle along planet-point line relative to moonlet [m].
  //position.y;    //Position of Particle along along orbit relative to moonlet [m].
  PVector velocity; //velocity vector
  PVector acceleration; //accleration vector


  //ShearParticle Properties
  float radius;
  float SPGM;
  float m;

  boolean highlight= false;



  /**CONSTUCTOR Particle
   */
  ShearParticle() {
    //Initialise default Particle Object.
    position = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
    //
    position.x= (random(1)-0.5)*Lx;
    //
    if (position.x >0) {
      position.y = -Ly/2;
    } else if (position.x ==0) {
      position.y =0; //Think about this !!
    } else {
      position.y = Ly/2;
    }
    //  
    velocity.x = 0;
    velocity.y = 1.5 * Omega0 * position.x;
    //
    this.radius = - log((particle_C-random(1.0))/particle_D)/particle_lambda;
    this.SPGM = SG* (4.0*PI/3.0)*pow(radius, 3.0)*particle_rho;
    m= PI*pow(radius, 3.0)*4.0/3.0;
  }


  /**Method to Display Particle
   */
  void display() {
    push();
    if (!highlight) {
      fill(255, 0, 0);
      stroke(255, 0, 0);
    } else { 
      fill( 0);
      stroke(0);
    }
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
    //ellipse(-y*width/Ly,-x*height/Lx,20, 20); //Debugging
    //println(radius);
    //displayPosition(position,1,color(255,0,0));
    if (Guides) {
      translate(-position.y*width/Ly, -position.x*height/Lx);
      circle(0, 0, 2*scale*radius*width/Ly);
      displayPVector(velocity, 1000, color(0, 255, 0));
      displayPVector(acceleration, 1000000, color(0, 0, 255));
    } else {
      ellipse(-position.y*width/Ly, -position.x*height/Lx, 2*scale*radius*width/Ly, 2*scale*radius*height/Lx);
    }
    pop();
  }
  void displayPosition(PVector v, float scale, color c) {
    stroke(c);
    line(0, 0, -v.y*scale*width/Ly, -v.x*scale*height/Lx);
  } 
  void displayPVector(PVector v, float scale, color c) {
    stroke(c);
    line(0, 0, -v.y*scale, -v.x*scale);
  }


  /**
   *  Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   */
  PVector getAcceleration(ShearingBox sb) {

    // acceleration due planet in centre of the ring. 
    PVector a_grav = new PVector();

    if (A1) {
      a_grav.x += 2.0*Omega0*S0*position.x;
    }
    if (A2) {
      a_grav.x += 2.0*Omega0*velocity.y;
      a_grav.y += -2.0*Omega0*velocity.x;
    }
    if (Moonlet) {
      float moonlet_GMr3 = moonlet_GM/pow(position.mag(), 3.0);
      a_grav.x += -moonlet_GMr3*position.x;
      a_grav.y += -moonlet_GMr3*position.y;
    }

    if (Self_Grav) {
      for (ShearParticle p : sb.Sparticles) {
        if (p!=this) {
          PVector distanceVect = PVector.sub(position.copy(), p.position.copy());

          // Calculate magnitude of the vector separating the balls
          float distanceVectMag = distanceVect.mag();
          if (distanceVectMag > radius+p.radius) {
            distanceVect = distanceVect.mult(p.SPGM /pow(distanceVectMag, 3));
            a_grav.x+= -distanceVect.x ;
            a_grav.y+=-distanceVect.y;
          }
        }
      }
    }
    //PVector.mult(position.copy().normalize(), -GMp/position.copy().magSq())

    return a_grav;
  }

  /**
   *
   */
  void set_getAcceleration(ShearingBox sb) {
    acceleration = getAcceleration(sb);
  }

  /**
   *
   */
  void updatePosition() {
    position.add(velocity.copy().mult(dt)).add(acceleration.copy().mult(0.5*sq(dt)));
  }

  /**
   *    Updates the velocity of this Ring Particle (Based on Velocity Verlet) using 2 accelerations.  
   */
  void updateVelocity(PVector a) {
    this.velocity.add(PVector.add(acceleration.copy(), a).mult(0.5 *dt));
  }

  ///** Computes self-gravity terms and adds them to an existing acceleration vector.
  // */
  //void calculate_self_grav(ShearingBox sb) {   

  //  for (Particle x : sb.particles) {
  //        // Against every other Particle in the grid
  //        for (Particle other : sb.particles) {
  //          // As long as its not the same one
  //          if (other != x) {
  //          //Adding Self Gravity
  //            //x.update_acceleration(other);
  //          }
  //        }
  //      }
  //}

  ///**Method to Update Particle
  // */
  //void update_position() {
  //  //Updates postions
  //  position.x += velocity.x*dt+ 0.5 *acceleration.x*pow(dt, 2);
  //  position.y += velocity.y*dt+ 0.5 *acceleration.y*pow(dt, 2);
  //}
  //void update_velocity() {
  //  //Updates velocities
  //  velocity.x += acceleration.x*dt;
  //  velocity.y += acceleration.y*dt;
  //}
  ///** Method to update the acceleration on this particle due to Moonlet (TODO Extend Particle into Moonlet and ShearParticle)
  // */
  //void update_acceleration() {
  //  float moonlet_GMr3 = moonlet_GM/pow(position.mag(), 3);
  //  acceleration.x+=2*Omega0*S0*position.x+2*Omega0*velocity.y-moonlet_GMr3*position.x;
  //  acceleration.y+=-2*Omega0*velocity.x-moonlet_GMr3*position.y;
  //}
  ///** Method to update the acceleration on this particle due to Moonlet (TODO Extend Particle into Moonlet and ShearParticle)
  // */
  //void update_acceleration(Particle other) {
  //  PVector distanceVect = PVector.sub(position.copy(), other.position.copy());
  //  // Calculate magnitude of the vector separating the balls
  //  float distanceVectMag = distanceVect.mag();
  //  distanceVect = distanceVect.mult(other.GM /pow(distanceVectMag, 3));
  //  acceleration.x+= distanceVect.x ;
  //  acceleration.y+=-distanceVect.y;
  //}

  void Reset() {
    acceleration.x=0;
    acceleration.y=0;
    //
    position.x= (random(1)-0.5)*Lx;
    //
    if (position.x >0) {
      position.y = -Ly/2;
    } else if (position.x ==0) {
      position.y =0; //Think about this !!
    } else {
      position.y = Ly/2;
    }
    //  
    velocity.x = 0;
    velocity.y = 1.5 * Omega0 * position.x;
    //
    this.radius = - log((particle_C-random(1))/particle_D)/particle_lambda;
    this.SPGM = SG* (4*PI/3)*pow(radius, 3)*particle_rho;
  }
}

//TODO

///**CONSTUCTOR Particle
//* @param rho 
//* @param a  Minimum size of a ring particle [m].
//* @param b  Maximum size of a ring particle [m].
//* @param lambda ower law index for the size distribution [dimensionless].
//* @param D 
//* @param C
//*/
//Particle(float rho, float a, float b, float lambda){
//  //Initialise a Particle Object.
//  this.rho =rho;
//  this.a = a;
//  this.b = b;
//  this.lambda = lambda;
//  this.D=1.0/( exp(-this.lambda*this.a) -exp(-this.lambda*this.b));
//  this.C= this.D * exp(-this.lambda*this.a);  
//}

//    /**CONSTUCTOR Particle
//*/
//Particle(){
//  //Initialise default Particle Object.
//  this(1000.0,0.95,1.05,1e-6);

//}

//-----------------------------------------MOONLET---------------------------------------------------------------

class Moonlet extends ShearParticle {

  Moonlet() {
    position = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
    this.radius = moonlet_r ;
    this.SPGM = moonlet_GM;
    m= PI*pow(radius, 3.0)*4.0/3.0;
  }
}
