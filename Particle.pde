/**Class RingParticle
 * @author Thomas Cann
 * @author Sam Hinson
 * @version 1.0
 */
class RingParticle extends Particle {

  /**
   *  Class Constuctor - Initialises an RingParticle object with a random position in the ring with correct orbital velocity. 
   */
  RingParticle(float r, float dr, float theta, float dtheta) {
    // Initialise our Orboids.
    super((random(1)*(dr) + r)*Rp, theta + random(1)*dtheta);
  }
  /**
   *  Class Constuctor - Initialises an RingParticle object with a random position in the ring with correct orbital velocity. 
   */
  RingParticle(float inner, float outer) {
    // Initialise our Orboids.
    super((random(1)*(outer-inner) + inner)*Rp, random(1)*2.0*PI);
  }

  /**
   *  Class Constuctor - Initialises an RingParticle object with a random position in the ring with correct orbital velocity. 
   */
  RingParticle(float radius) {
    // Initialise ourRingParticle.
    super(radius, random(1)*2.0*PI);
  }

  RingParticle() {
    super();
  }

  /**
   *  Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   */
  PVector getAcceleration(RingSystem rs) {

    // acceleration due to planet in centre of the ring. 
    PVector a_grav = PVector.mult(position.copy().normalize(), -GMp/position.copy().magSq());

    //Acceleration from the Grid Object
    for (Grid x : rs.g) {
      a_grav.add(x.gridAcceleration(this));
    }
    for (Moon m : rs.moons) {
      //for all resonances of the moon 

      PVector dist = PVector.sub(m.position, position);
      PVector a = PVector.mult(dist, m.GM/pow(dist.mag(), 3));
       
      if (m.r != null){
      for (Resonance R : m.r) {

        float x = position.mag()/60268e3;
        //Check if Particle >Rgap ?&& <Rmax
        //println(x+" "+R.rGap+ " "+ R.rMax);
        if (x>R.rGap && x<R.rMax) {
          //Calcuaculate and Apply if it is !
          //println(R.calcAccleration(x-R.rGap));
          a.mult(R.calcAccleration(x-R.rGap));
        }
      }}else{
        println("No Resonances ");
        
      }
      a_grav.add(a);
    }

    return a_grav;
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------//

/**Class Particle
 *
 * @author Thomas Cann
 * @author Sam Hinson
 */

abstract class Particle {

  PVector position; // Position float x1, x2, x3; 
  PVector velocity; // Velocity float v1, v2, v3;
  PVector acceleration;  //Update all constructors!

  /**
   *  Class Constuctor - General need passing all the values. 
   */
  Particle(float x1_, float x2_, float x3_, float v1_, float v2_, float v3_, float a1_, float a2_, float a3_) {
    //default position
    this.position = new PVector(x1_, x2_, x3_);
    //default velocity
    this.velocity = new PVector(v1_, v2_, v3_);
    this.acceleration = new PVector(a1_, a2_, a3_);
  }

  /**
   *  Class Constuctor - General need passing all the values. 
   */
  Particle(float x1_, float x2_, float x3_, float v1_, float v2_, float v3_) {
    //default position
    this.position = new PVector(x1_, x2_, x3_);
    //default velocity
    this.velocity = new PVector(v1_, v2_, v3_);
    this.acceleration = new PVector();
  }

  /**
   *  Class Constuctor - General need passing all the values. 
   */
  Particle(PVector position_, PVector velocity_) {
    //default position
    this.position = position_.copy();
    //default velocity
    this.velocity = velocity_.copy();
  }

  /**
   *  Class Constuctor - Initialises an Orboid object with a random position in the ring with correct orbital velocity. 
   */
  Particle(float r, float phi) {
    this(r*cos(phi), r*sin(phi), 0, sqrt(GMp/(r))*sin(phi), -sqrt(GMp/(r))*cos(phi), 0);
  }

  /**
   *  Class Constuctor - Initialises an RingParticle object with a random position in the ring with correct orbital velocity. 
   */
  Particle(float radius) {
    // Initialise ourRingParticle.
    this(radius, random(1)*2.0*PI); //random(1)
  }

  /**
   *  Class Constuctor - Initialises an Particle object with zero position and velocity. 
   */
  Particle() {
    this(0, 0, 0, 0, 0, 0);
  }

  /**
   * Display Method - Renders this object to screen displaying its position and colour.
   */
  void display() {
  }

  /**
   * Render Method - Renders this object to PGraphics Object. 
   */
  void render(PGraphics x) {
  }

  ///**
  // *  Clone Method - Return New Object with same properties.
  // * @return particle object a deep copy of this. 
  // */
  //Particle clone() {
  //  Particle p = new Particle(); //Cannot make instances of interfaces or Abstract Class  (Particle is an abstract class).
  //  p.position= this.position.copy();
  //  p.velocity = this.velocity.copy();
  //  return p;
  //}

  /**Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   * @param rs
   * @return acceleration on the particle PVector[m.s^-2,m.s^-2,m.s^-2]
   */
  PVector getAcceleration(RingSystem rs) {

    // acceleration due planet in centre of the ring. 
    PVector a_grav = PVector.mult(position.copy().normalize(), -GMp/position.copy().magSq());

    //Acceleration from the Grid Object
    for (Grid x : rs.g) {
      a_grav.add(x.gridAcceleration(this));
    }

    return a_grav;
  }

  /** Calculates the acceleration on this particle (based on its current position) (Overrides value of acceleration stored by particle)
   * @param rs
   */
  void set_getAcceleration(RingSystem rs) {
    acceleration = getAcceleration(rs);
  }

  /** 
   *  Update Position of particle based of Velocity and Acceleration. 
   */
  void updatePosition() {
    position.add(velocity.copy().mult(dt)).add(acceleration.copy().mult(0.5*sq(dt)));
  }

  /**
   * Updates the velocity of this Particle (Based on Velocity Verlet) using 2 accelerations. 
   * @param a current acceleration of particle
   */
  void updateVelocity(PVector a) {
    this.velocity.add(PVector.add(acceleration.copy(), a).mult(0.5 *dt));
  }

  /**
   *  Updates object for one time step of simulation.
   */
  void update() {
    // acceleration functions

    PVector a_grav = PVector.mult(position.copy().normalize(), -GMp/position.copy().magSq());

    PVector tempPosition = PVector.add(position.copy(), velocity.copy().mult(dt)).add(a_grav.copy().mult(0.5*sq(dt)));

    PVector a_grav1 = PVector.mult(tempPosition.copy().normalize(), -GMp/tempPosition.copy().magSq());

    this.velocity.add(PVector.add(a_grav, a_grav1).mult(0.5 *dt));
    this.position = tempPosition;
  }
}
