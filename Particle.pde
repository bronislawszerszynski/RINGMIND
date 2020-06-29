//<Particle Tab>// //<>// //<>//
//Contains:
//-Classes(Particle, RingParticle, Moon, ResonantParticle, ResonantMoon, Resonance, TiltParticle, ShearingParticle, Moonlet
//-Interfaces(Alignable)
//-Methods(Particle I/O)

/**Class Particle
 * @author Thomas Cann
 * @author Sam Hinson
 */
import java.util.Random;

abstract class Particle {

  PVector position; // Position float x1, x2, x3; 
  PVector velocity; // Velocity float v1, v2, v3;
  PVector acceleration;  //Update all constructors!
  int Index = 0;

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
   *  Class Constuctor - passing in values of position and velocity. 
   */
  Particle(float x1_, float x2_, float x3_, float v1_, float v2_, float v3_) {
    //default position
    this.position = new PVector(x1_, x2_, x3_);
    //default velocity
    this.velocity = new PVector(v1_, v2_, v3_);
    this.acceleration = new PVector();
  }

  /**
   *  Class Constuctor -passing in PVectors of position and velocity. 
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
    this(r*cos(phi), r*sin(phi), 0, sqrt(System.GMp/(r))*sin(phi), -sqrt(System.GMp/(r))*cos(phi), 0);
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

  /**Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   * @param rs
   * @return acceleration on the particle PVector[m.s^-2,m.s^-2,m.s^-2]
   */
  PVector getAcceleration(System s) {
    PVector a_grav = new PVector();

    // acceleration due planet in centre of the ring. 
    a_grav = PVector.mult(position.copy().normalize(), -System.GMp/position.copy().magSq());

    //Acceleration from the Grid Object
    if (s.g != null) {
      for (Grid x : s.g) {
        a_grav.add(x.gridAcceleration(this, s.dt));
      }
    }
    return a_grav;
  }

  /** Calculates the acceleration on this particle (based on its current position) (Overrides value of acceleration stored by particle)
   * @param rs
   */
  void set_getAcceleration(System s) {
    acceleration = getAcceleration(s);
  }

  /** 
   *  Update Position of particle based of Velocity and Acceleration. 
   */
  void updatePosition(float dt) {

    position.add(velocity.copy().mult(dt)).add(acceleration.copy().mult(0.5*sq(dt)));
  }

  /**
   * Updates the velocity of this Particle (Based on Velocity Verlet) using 2 accelerations. 
   * @param a current acceleration of particle
   */
  void updateVelocity(PVector a, float dt) {

    velocity.add(PVector.add(acceleration.copy(), a).mult(0.5 *dt));
  }

  abstract Particle clone();
}

//---------------------------------------------------------------------------------------------------------------------------------------------------//

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
    super((random(1)*(dr) + r)*System.Rp, theta + random(1)*dtheta);
  }
  /**
   *  Class Constuctor - Initialises an RingParticle object with a random position in the ring with correct orbital velocity. 
   */
  RingParticle(float inner, float outer) {
    // Initialise our Orboids.
    super((random(1)*(outer-inner) + inner)*System.Rp, random(1)*2.0*PI);
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

  ///**Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
  // * @param s RingmindSystem
  // * @return PVector [ms^(-2)] 
  // */
  //PVector getAcceleration(RingmindSystem s) {

  //  // acceleration due planet in centre of the ring. 
  //  PVector a_grav = PVector.mult(position.copy().normalize(), -System.GMp/position.copy().magSq());

  //  //Acceleration from the Grid Object
  //  for (Grid x : s.rs.g) {
  //    a_grav.add(x.gridAcceleration(this, s.dt));
  //  }
  //  for (Particle p : s.ms.particles) {
  //    Moon m =(Moon)p;
  //    PVector dist = PVector.sub(m.position, position);
  //    PVector a = PVector.mult(dist, m.GM/pow(dist.mag(), 3));
  //    a_grav.add(a);
  //  }
  //  return a_grav;
  //}

  /**Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   * @param s System
   * @return PVector [ms^(-2)] 
   */
  @Override PVector getAcceleration(System s) {

    PVector a_grav;
    if (s instanceof RingmindSystem) {
      //println("test");
      RingmindSystem rms = (RingmindSystem)s;
      // acceleration due planet in centre of the ring. 
      a_grav = PVector.mult(position.copy().normalize(), -System.GMp/position.copy().magSq());

      //Acceleration from the Grid Object
      for (Grid x : rms.rs.g) {
        a_grav.add(x.gridAcceleration(this, s.dt));
      }

      for (Particle p : rms.ms.particles) {
        if (p instanceof Moon) {
          Moon m = (Moon)p;
          PVector dist = PVector.sub(m.position, position);
          PVector a = PVector.mult(dist, m.GM/pow(dist.mag(), 3));
          a_grav.add(a);
        }
      }
    } else {
      a_grav =super.getAcceleration(s);
    }

    return a_grav;
  }

  /**
   *  Clone Method - Return New Object with same properties.
   * @return particle object a deep copy of this. 
   */
  @Override Particle clone() {
    Particle p = new RingParticle(); 
    p.position= this.position.copy();
    p.velocity = this.velocity.copy();
    return p;
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------//

/**Class Moon
 *
 * @author Thomas Cann
 * @author Sam Hinson
 */

class Moon extends Particle implements Alignable {

  float GM;
  float radius;
  color c ;
  final float moonSizeScale= 2;

  /**
   *  Class Constuctor - General Moon object with random angle. 
   */
  Moon(float Gm, float radius, float orb_radius, color c) {
    super(orb_radius);
    this.GM=Gm;
    this.radius=radius;
    this.c= c;
  }
  /**
   *  Class Constuctor - General Moon object with random angle. 
   */
  Moon(float Gm, float radius, float orb_radius) {
    super(orb_radius);
    this.GM=Gm;
    this.radius=radius;
    c= color(random(255), random(255), random(255));
  }
  /**
   *  Class Constuctor - Default Moon object with properties of Mima (loosely). 
   */
  Moon(PVector p, PVector v) {
    //Mima (Source: Nasa Saturn Factsheet)
    //GM - 2.529477495E9 [m^3 s^-2]
    //Radius - 2E5 [m]
    //Obital Radius - 185.52E6 [m]

    this(2.529477495e13, 400e3, 185.52e6);
    this.position.x = p.x;
    this.position.y = p.y;
    this.position.z = p.z;
    this.velocity.x = v.x;
    this.velocity.y = v.y;
    this.velocity.z = v.z;
  }
  Moon() {
    super();
    this.GM=0;
    this.radius=0;
    c= color(0, 0, 255);
  }

  /**
   *Display Method - Renders this object to screen displaying its position and colour.
   */
  @Deprecated void display() {
    push();
    translate(width/2, height/2);
    ellipseMode(CENTER);
    fill(c);
    stroke(c);
    circle(System.SCALE*position.x, System.SCALE*position.y, 2*moonSizeScale*radius*System.SCALE);
    pop();
  }  

  /**Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   * @param System Object
   * @return current acceleration of this moon due to rest of System [ms^(-2)] . 
   */
  PVector getAcceleration(RingmindSystem s) {

    // acceleration due planet in centre of the ring. 
    PVector a_grav = PVector.mult(position.copy().normalize(), -System.GMp/position.copy().magSq());

    // acceleration due the moons on this particle.
    for (Particle p : s.ms.particles) {
      if (p instanceof Moon) {
        Moon m = (Moon)p;
        if (m != this) {
          PVector dist = PVector.sub(m.position, position);
          PVector a = PVector.mult(dist, m.GM/pow(dist.mag(), 3));
          a_grav.add(a);
        }
      }
    }

    return a_grav;
  }

  /**Clone Method - Return New Object with same properties.
   * @return particle object a deep copy of this. 
   */
  @Override Particle clone() {
    Moon p = new Moon(); 
    p.position= this.position.copy();
    p.velocity = this.velocity.copy();
    p.GM = this.GM;
    p.radius = this.radius;
    p.c= this.c;
    return p;
  }

  /**Returns a boolean of true when 2 alignable object are within angular threshold
   * @param Object that implements Alignable.
   * @return Returns true when 2 alignable object are within angular threshold.
   */
  boolean isAligned(Alignable other) {
    boolean temp =false;
    Moon otherMoon = (Moon)other;
    float dAngle = this.position.heading() - otherMoon.position.heading();

    float angleThreshold = radians(1);
    if ( abs(dAngle) < angleThreshold) { //abs(dAngle) % PI could be used to have alignments on either side of the planet!
      temp =true;
    } 
    return temp;
  }

  /** Time taken for two Alignale objects to align. 
   * @param Object that implements Alignable.
   * @return time taken for two Alignale objects to align. 
   */
  float timeToAlignment(Alignable other) {
    Moon otherMoon = (Moon)other;
    float dAngle = this.position.heading() - otherMoon.position.heading();
    float dOmega = kepler_omega(this)-kepler_omega(otherMoon);
    return dAngle/(dOmega*s.simToRealTimeRatio);
  }

  /** Method to calculate the Keplerian orbital angular frequency (using Kepler's 3rd law).
   *@param r Radial position (semi-major axis) to calculate the period [m].
   *@return The angular frequency [radians/s].
   */
  float kepler_omega(Moon m) {
    return sqrt(System.GMp/(pow(m.position.mag(), 3.0)));
  }


  /**Method to get the angle in degrees of the moon
   * @param m Moon Object.
   * @return [degrees].
   */
  float moonAngle(Moon m) {
    PVector center = new PVector(0, 0, 0);
    PVector mm = new PVector(m.position.x, m.position.y, 0);
    return degrees(PVector.angleBetween(center, mm));
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------//

/**Interface Alignable - template for checking if different objects types of objects align. 
 * @author Thomas Cann
 */
public interface Alignable {
  public boolean isAligned(Alignable other); //Alignment Threshold
  //public float timeToAlignment(Alignable other); //What units? [s]
}

//---------------------------------------------------------------------------------------------------------------------------------------------------//
/**Class ResonantParticle - Removes Gravity interaction and used information in Resonance class to thin rings.  
 * @author Thomas Cann
 */
public class ResonantParticle extends RingParticle {

  /**
   * TODO
   */
  ResonantParticle(float inner, float outer) {
    super(inner, outer);
  }

  /**
   *  Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   */
  @Override PVector getAcceleration(System s) {

    ResonantSystem rs = (ResonantSystem)s;
    //// acceleration due to planet in centre of the ring. 
    PVector a_grav = PVector.mult(position.copy().normalize(), -System.GMp/position.copy().magSq());

    for (Particle mr : rs.ms.particles) {
      //for all resonances of the moon 
      ResonantMoon m = (ResonantMoon)mr;

      PVector dist = PVector.sub(m.position, position);
      PVector a = PVector.mult(dist, m.GM/pow(dist.mag(), 3));

      if (m.r != null) {
        for (Resonance R : m.r) {
          float x = position.mag()/60268e3;
          //Check if Particle >Rgap ?&& <Rmax
          //println(x+" "+R.rGap+ " "+ R.rMax);
          if (x>R.rGap && x<R.rMax) {
            //Calcuaculate and Apply if it is !
            //println(R.calcAccleration(x-R.rGap));
            a.mult(R.calcAccleration(x-R.rGap));
          }
        }
      } else {
        println("No Resonances ");
      }
      a_grav.add(a);
    }

    return a_grav;
  }
}



/**Class ResonantMoon - Removes Gravity interaction and used information in Resonance class to thin rings.  
 * @author Thomas Cann
 */
public class ResonantMoon extends Moon {

  ArrayList<Resonance> r;

  /**
   *  Class Constuctor - Create Resonant Moon object with empty arraylist to store Resonances. 
   */
  ResonantMoon(float Gm, float radius, float orb_radius) {
    super(Gm, radius, orb_radius);
    r = new ArrayList<Resonance>();
  }

  /**Method to add a Resonance to arraylsit.
   * @param Q ratio [t_moon/t_particle].
   */
  void addResonance(float Q) {
    r.add(new Resonance(Q, this));
  }
}

/**Class Resonance - Orbital Resonance / Limdblad Resonance information.  
 * @author Thomas Cann
 */
public class Resonance {

  float Q;                         //ratio [t_moon/t_particle]
  float rGap;                      //inner most radius of gap. [Planetary Radi](Hard Edge)
  float rMax;                      //outer most radius of gap. [Planetary Radi](Soft Edge)
  float bellMag = 1e5;             //Strength of Clearing Force [m.s^-2]
  float bellWidth = 0.001913069;   //Width of Clearing Force [Planetary Radi ^2]
  //float Effect;                  //Scale of strength Force based on Gravitational force due to moon at ring gap --> moonmass/(rmoon -rgap)^2 multiplied by a constant

  /**
   *  Class Constuctor - Calculates Resonance properties based of Q and Moon.
   */
  Resonance(float Q, Moon m) {
    this.Q = Q;
    calcRGap(m);
    //calcEffect(m);
    calcRmax();
  }

  /** Method to calculate inner radius at which gap should form.
   *  @param m Moon Object which resonance is based off.  
   */
  void calcRGap(Moon m) {
    rGap = (m.position.mag()*pow(Q, (-2.0/3.0)))/60268e3;
  }

  /** Method to calculate inner radius at which gap should form.
   *  @param x radius from centre planet[Planetary Radi]
   *  @return acceleration[m.s^-2]
   */
  float calcAccleration(float x) {
    return bellMag*exp( -sq(x) /(Q*bellWidth)) + 1; // a proportional to GM pow(Q, ?)
  }

  /**
   *  Method to calculate a radius at which stop applying gap force. Magnitude of force is 1/100 of max.
   *  Bell/Effect curve ==> f(0)= 1 ---> f(RMax)=0.01
   */
  void calcRmax() {
    //
    rMax = rGap + sqrt((-bellWidth*log(0.01/bellMag))/Q);
  }

  //TODO
  //void calcEffect(Moon m) {
  //  //Accleration at gap ( Gravitational force due to moon at ring gap --> moonmass/(rmoon -rgap)^2 multiplied by a constant
  //}
}




//---------------------------------------------------------------------------------------------------------------------------------------------------//

/** Class TiltParticle
 */
class TiltParticle extends RingParticle {

  float inclination;        //Rotation round x axis [degrees].
  float rotation;           //Rotation round z axis [degrees].
  float minInclination;     //minimum inclination of particle [degrees].
  float lambda;             //exponential decay constant [milliseconds^{-1}].
  float initialiseTime;     //time when particle is initialised [milliseconds].

  /** 
   * Class Constuctor - Initialises an TiltParticle object with a random position in the ring with correct orbital velocity. 
   */
  TiltParticle(float inner, float outer, float max_inclination, float min_inclination, float lambda) {
    super(inner, outer);
    this.inclination= randomGaussian()*max_inclination;
    this.rotation =random(360);
    this.minInclination = randomGaussian()* min_inclination;
    this.lambda= lambda;
    this.initialiseTime = millis();
  }

  /** Method to exponential decrease inclination with after since initialisation.
   *  @return  curretn angle to incline plane[degrees]
   */
  float inclination() {
    return inclination* exp(-lambda*(millis()-initialiseTime)) +minInclination ;
  }

  /**Method rotates a Tilt Particle Simulated Position. Around x-axis by inclination() the around z-axis by rotation.   
   *@param p TiltParticle object
   *@return RotatedPosition PVector[m,m,m]
   */
  PVector displayRotate(TiltParticle p) {
    PVector temp = p.position.copy();
    float angle = radians(p.inclination());
    float cosi = cos(angle);
    float sini = sin(angle);
    temp.y = cosi * p.position.y - sini * p.position.z;
    temp.z = cosi * p.position.z + sini * p.position.y;
    PVector temp1 = temp.copy();
    float cosa = cos(radians(p.rotation));
    float sina = sin(radians(p.rotation));
    temp.x = cosa * temp1.x - sina * temp1.y;
    temp.y = cosa * temp1.y + sina * temp1.x;
    return temp;
  }
  /**Method rotates this Tilt Particle Simulated Position. Around x-axis by inclination() the around z-axis by rotation. 
   *@return RotatedPosition PVector[m,m,m]
   */
  PVector displayRotate() {
    return displayRotate(this);
  }
}

//------------------------------------- SHEAR PARTICLE -------------------------------------------------------

class ShearParticle extends Particle {

  //position.x;    //Position of Particle along planet-point line relative to moonlet [m].
  //position.y;    //Position of Particle along along orbit relative to moonlet [m].

  final float SG = 6.67408e-11; //Shear Gravitational Constant
  //ShearParticle Initialisation Properties
  final float particle_rho = 1000.0;  //Density of a ring particle [kg/m^3].
  final float particle_a = 3;     //Minimum size of a ring particle [m].
  final float particle_b = 30.0;     //Maximum size of a ring particle [m].
  final float particle_lambda = 0.6;   //Power law index for the size distribution [dimensionless].
  final float particle_D =1.0/( exp(-particle_lambda*particle_a) -exp(-particle_lambda*particle_b));
  final float particle_C =particle_D * exp(-particle_lambda*particle_a);

  PVector InitPosition = new PVector();

  //ShearParticle Properties
  float InitRadius;
  float radius;

  // Modifies the minimum radius and range of radii each particle can have
  float m;

  boolean highlight= false;

  /**CONSTUCTOR Particle
   */
  ShearParticle(ShearSystem s) {
    //Initialise default Particle Object.
    position = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
    //
    position.y = (random(1)-0.5)*s.Ly;  
    if(HalfRing){
       position.x = -(random(1))*s.Lx/2;
    }else{
      position.x = (random(1)-0.5)*s.Lx;
    }
    
    

    if (RingGap) {
      boolean InGap = true;
      do {
        if(HalfRing){
          position.x = -(random(1))*s.Lx/2;
        }else{
          position.x = (random(1)-0.5)*s.Lx;
        }
        position.y = (random(1)-0.5)*s.Ly;  


        if (position.x > -s.GapWidth/2 && position.x < s.GapWidth/2) {
          InGap = true;
        } else {
          InGap = false;
        }
      } while (InGap == true);
    }
    InitPosition = position.copy();
    
    if(Toggle3D){
    position.z = random(300) - 150;
    }
    
    velocity.x = 0;
    velocity.y = 1.5 * s.Omega0 * position.x;
    this.InitRadius = (-log((particle_C-random(1.0))/particle_D)/particle_lambda);
    this.radius = InitRadius;
    this.m = (4*PI/3)*pow(radius, 3)*particle_rho;
  }

  ShearParticle() {
    //
    position = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
    //
    this.InitRadius = (-log((particle_C-random(1.0))/particle_D)/particle_lambda);
    this.radius = InitRadius;
    this.m = (4*PI/3)*pow(radius, 3)*particle_rho;
  }

  /**Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   * @param sb Shearing Box
   * @return accleration of this particles due to ShearingBox
   */
  @Override PVector getAcceleration(System s) {
    ShearSystem ss = (ShearSystem)s;
    // acceleration due planet in centre of the ring. 
    PVector a_grav = new PVector();
    //Shear forces on particles
    if (ss.A) {
      a_grav.x += -(2.0*ss.Omega0*ss.S0*position.x);
      a_grav.x += -(2.0*ss.Omega0*velocity.y);
      a_grav.y += (2.0*ss.Omega0*velocity.x);
    }
    //Gravitational attraction of the moonlet
    if (Moonlet) {
      PVector distanceVect = PVector.sub(position.copy(), ss.moonlet.position.copy());
      float distanceVectMag = distanceVect.mag();
      float moonMass = (4.0*PI/3.0)*pow(ss.moonlet.radius, 3.0)*ss.moonlet.moonlet_density;

      //if (distanceVectMag > radius+ss.moonlet.radius) {
      if(distanceVectMag > radius + ss.moonlet.radius){  
        distanceVect = distanceVect.mult((SG*moonMass)/pow(distanceVectMag, 3));
        a_grav.x+= -distanceVect.x ;
        a_grav.y+= -distanceVect.y;
        a_grav.z+= -distanceVect.z;

      }
    }
        //aproximate forces acting ona particle due to other particles
    if (ss.SelfGrav) {
        PVector SGrav = new PVector();
        SGrav = ss.QT.SelfGrav(this);
        a_grav.x += SGrav.x;
        a_grav.y += SGrav.y;      
        a_grav.z += SGrav.z;
    }
    return a_grav;
  }

  /** Reset
   * @param s 
   */
  void Reset(ShearSystem s) {
    acceleration = new PVector();
    
    
    //This section below is for introducing particles acording to their velocites (introduce faster particles more often etc)
    // there is 100% a better way to do this but never had chance to improve it, it does work but it's not the fastest when resetting a high volume of particles
    
    // Splits each half (top/bottom) into k number of orbital heights
    int k=1000;

    boolean InGap = true;
    do {
      Random r = new Random();

      // First, generate a number from 1 to T_k
      int triangularK = k * (k + 1) / 2;

      int x = r.nextInt(triangularK) + 1;

      // Next, figure out which bucket x fits into, bounded by
      // triangular numbers by taking the triangular root    
      // We're dealing strictly with positive integers, so we can
      // safely ignore the - part of the +/- in the triangular root equation
      double triangularRoot = (Math.sqrt(8 * x + 1) - 1) / 2;

      int n = (int) Math.ceil(triangularRoot);  
      // n has a linear distubution from 0 to k , k being the most likely outcome
      // normanlise n --> k = 1
      float XWeight = float(n)/k;  

      if(HalfRing){
        position.x= (-XWeight*s.Lx/2);
        position.y = s.Ly/2;
      }else{
        //50/50 chance of particle spawning in top or bottom half
        int Coinflip = int(random(2));
        if (Coinflip == 0) {
          position.x = XWeight*s.Lx/2;
          position.y = -s.Ly/2;
        }
        if (Coinflip == 1) {
          position.x= (-XWeight*s.Lx/2);
          position.y = s.Ly/2;
        }
      }
        if (RingGap == true) {
          if (position.x > -s.GapWidth/2 && position.x < s.GapWidth/2) {
            InGap = true;
          } else {
            InGap = false;
          }
        } else {
          InGap =false;
        }
        
  } while (InGap == true);
    
    InitPosition = position.copy();
    velocity.x = 0;
    velocity.y = 1.5 * s.Omega0 * position.x;
    
    if(Toggle3D){
    position.z = random(300) - 150;
    velocity.z = 0;
    }
    //
    this.InitRadius = (-log((particle_C-random(1.0))/particle_D)/particle_lambda);
    this.radius = InitRadius;
    this.m = (4*PI/3)*pow(radius, 3)*particle_rho;
  }

  /**Clone Method - Return New Object with same properties.
   * @return particle object a deep copy of this. 
   */
  Particle clone() {
    ShearParticle p = new ShearParticle(); 
    p.position= this.position.copy();
    p.velocity = this.velocity.copy();
    p.acceleration = this.acceleration.copy();
    return p;
  }

  // Checks if a particle has entered the moonlet radius in this timestep, if so the particle is pushed back outside the moonlet radius and deflected off.
  void MoonletCollisionCheck(ShearSystem ss) {
    float EM = 1;
    PVector distVect = PVector.sub(position.copy(), ss.moonlet.position.copy());
    PVector distVectNorm = (distVect.copy()).normalize();
    PVector Tangent = new PVector();
    float distVectMag = distVect.copy().mag();

    if (distVectMag < (ss.moonlet.radius + radius)) {
      float CorrectionMag = (ss.moonlet.radius+radius) - distVectMag;
      PVector CorrectionVect = (distVectNorm.copy()).mult(CorrectionMag);
      position.add(CorrectionVect);
      Tangent = (distVectNorm.copy()).rotate(PI/2);
      float Theta = PVector.angleBetween(Tangent, velocity);
      if (Theta > PI/2) {
        Theta = PI - Theta;
        velocity = (velocity.rotate(2*Theta)).mult(EM);     //Inelastic
      } else {
        velocity = (velocity.rotate(-2*Theta)).mult(EM);     //Inelastic
      }
    }
  }
  
  // Exactly the same as above but in 3D
  //There may be a simpler/faster way to do this in 3D but I had to split the caculations into XY, XZ, YZ planes
  void MoonletCollision3D(ShearSystem ss){
      float EM = 0.90;
    PVector distVect = PVector.sub(position.copy(), ss.moonlet.position.copy());
    PVector Norm = (distVect.copy()).normalize();
    float distVectMag = distVect.copy().mag();
    float moonRadius = ss.moonlet.radius;
    if (distVectMag < (moonRadius + radius+3)) {
      float CorrectionMag = (moonRadius+radius+5) - distVectMag;
      PVector CorrectionVect = (Norm.copy()).mult(CorrectionMag);
      position.add(CorrectionVect);
      PVector XYVelocity = new PVector();
      PVector XZVelocity = new PVector();
      PVector YZVelocity = new PVector();
      PVector XYNorm = new PVector();
      PVector XZNorm = new PVector();
      PVector YZNorm = new PVector();
      PVector TangentXY = new PVector();
      PVector TangentXZ = new PVector();      
      PVector TangentYZ = new PVector();      
      XYVelocity.set(velocity.x, velocity.y);
      XZVelocity.set(velocity.x, velocity.z);
      YZVelocity.set(velocity.y, velocity.z);
      XYNorm.set(Norm.x,Norm.y);
      XZNorm.set(Norm.x,Norm.z);
      YZNorm.set(Norm.y,Norm.z);

      TangentXY = (XYNorm.copy()).rotate(PI/2);
      TangentXZ = (XZNorm.copy()).rotate(PI/2);
      TangentYZ = (YZNorm.copy()).rotate(PI/2);
      
      
      float ThetaXY = PVector.angleBetween(TangentXY, XYVelocity);
      float ThetaXZ = PVector.angleBetween(TangentXZ, XZVelocity);
      float ThetaYZ = PVector.angleBetween(TangentYZ, YZVelocity);
      
      if (ThetaXY > PI/2) {
        ThetaXY = PI - ThetaXY;
        XYVelocity = (XYVelocity.rotate(2*ThetaXY)).mult(EM);   
      } else {
        XYVelocity = (XYVelocity.rotate(-2*ThetaXY)).mult(EM);  
      }
      
      if (ThetaXZ > PI/2) {
        ThetaXZ = PI - ThetaXZ;
        XZVelocity = (XZVelocity.rotate(2*ThetaXZ)).mult(EM);   
      } else {
        XZVelocity = (XZVelocity.rotate(-2*ThetaXZ)).mult(EM);  
      }
     
      if (ThetaYZ > PI/2) {
        ThetaYZ = PI - ThetaYZ;
        YZVelocity = (YZVelocity.rotate(2*ThetaYZ)).mult(EM);   
      } else {
        YZVelocity = (YZVelocity.rotate(-2*ThetaYZ)).mult(EM);  
      }
       
      float Vx = (XYVelocity.x + XZVelocity.x)/2;
      float Vy = (XYVelocity.y + YZVelocity.x)/2;
      float Vz = (XZVelocity.y + YZVelocity.y)/2;
      
      velocity.set(Vx, Vy, Vz);
    }
  }
  
  
   //Collisions detection for 2 particles using a combination of the moonlet method above and Chris Arridge's quadratic equation idea
   //Seems to work pretty well
void CollisionCheckB(ShearParticle B) {
    PVector distVect = PVector.sub(position.copy(), B.position.copy());
    PVector RelVelocity = PVector.sub(velocity.copy(), B.velocity.copy());

    if (distVect.mag() < radius + B.radius) {
    float CorrectionMag = ((radius + B.radius + 2) - distVect.mag())/2.0;
    PVector d = distVect.copy();
    PVector CorrectionVect = d.normalize().mult(CorrectionMag);
    position.add(CorrectionVect);
    B.position.sub(CorrectionVect);
    }else{
    
        float x_0 = distVect.x;
        float y_0 = distVect.y;
        float z_0 = distVect.z;
        float V_x = RelVelocity.x;
        float V_y = RelVelocity.y;
        float V_z = RelVelocity.z;
        float R = radius + B.radius;
    
        float Discriminant = sq(2*((x_0*V_x)+(y_0*V_y)+(z_0*V_z))) - 4*(sq(V_x) + sq(V_y) + sq(V_z))*(sq(x_0) + sq(y_0) + sq(z_0) - sq(R));
        if (Discriminant > 0) {   
          float T1 =   (-2*((x_0*V_x)+(y_0*V_y)+(z_0*V_z)) - sqrt(Discriminant))/(2*(sq(V_x) + sq(V_y) + sq(V_z)));
          float T2 =   (-2*((x_0*V_x)+(y_0*V_y)+(z_0*V_z)) + sqrt(Discriminant))/(2*(sq(V_x) + sq(V_y) + sq(V_z)));
          float Delta_T = 0;
    
          if (T1 < T2) {
            Delta_T = T1;
          }
          if (T2 < T1) {
            Delta_T = T2;
          }
          if (Delta_T < s.dt && Delta_T > 0) {    
            float M = m + B.m;
            //These are often above 1 and cause chaos
            //This needs an upper of 1
            float e1 = pow((velocity.mag()/B.velocity.mag()),-0.234);
            float e2 = pow((B.velocity.mag()/velocity.mag()),-0.234);
            if(e1 > 1){
              e1 = 1;
            }
            if(e2 > 1){
              e2 = 1;
            }
         
         
            float x1 = e1*(velocity.x*(m - B.m) + 2*B.m*B.velocity.x)/M;
            float y1 = e1*(velocity.y*(m - B.m) + 2*B.m*B.velocity.y)/M;
            float z1 = e1*(velocity.z*(m - B.m) + 2*B.m*B.velocity.z)/M;
            float x2 = e2*(B.velocity.x*(B.m - m) + 2*m*velocity.x)/M;
            float y2 = e2*(B.velocity.y*(B.m - m) + 2*m*velocity.y)/M;
            float z2 = e2*(B.velocity.z*(B.m - m) + 2*m*velocity.z)/M;

            velocity.set(x1, y1, z1);
            B.velocity.set(x2, y2, z2);
          }
        }
    }
   
  }
}
//-----------------------------------------MOONLET---------------------------------------------------------------

class Moonlet extends ShearParticle {

  //Ring Moonlet Properties
  //float moonlet_r = 150.0;         //Radius of the moonlet [m].
  float moonlet_r = cp5.getController("Moon Radius").getValue();
  float moonlet_density = 1000.0; //Density of the moonlet [kg/m^3]

  Moonlet() {
    position = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
    this.radius = moonlet_r ;
    this.m = (4.0*PI/3.0)*pow(moonlet_r, 3.0)*moonlet_density;

    position.x = 0;          // Change the starting position of the moonlet
    position.y = 0;
    position.z = 0;
  }

  // Makes the moonlet bob up and down based on simulation time
  PVector DynamicMoon(ShearSystem s) {
    float Hours = s.totalSystemTime/3600.0;
    position.x = 200*cos(Hours*PI/2);  
    return position;
  }
  
  //Calculates the shear forces on the moonlet when it is moved off of its orbit
  PVector getShear(ShearSystem ss){
  PVector Shear = new PVector();
   if (ss.A) {
      Shear.x += -(2.0*ss.Omega0*ss.S0*position.x);
      Shear.x += -(2.0*ss.Omega0*velocity.y);
      Shear.y += (2.0*ss.Omega0*velocity.x);
    }
  return Shear;
  }
  
  
}
//-----------------------------------------Particle I/O--------------------------------------------------------------

/** Method addParticlesFromTable
 * @param s
 * @param filename
 */
void addParticlesFromTable(System s, String filename) {
  Table table; 
  table = loadTable("./files/"+filename);  // Example Filenames  "output.csv" "input.csv"

  if (s instanceof RingSystem) {
    RingSystem rs=(RingSystem)s;
    for (int i = 0; i < table.getRowCount(); i++) {
      RingParticle temp = new RingParticle();
      temp.position.x= table.getFloat(i, 0);
      temp.position.y= table.getFloat(i, 1);
      temp.position.z= table.getFloat(i, 2);
      temp.velocity.x= table.getFloat(i, 3);
      temp.velocity.y= table.getFloat(i, 4);
      temp.velocity.z= table.getFloat(i, 5);
      temp.acceleration.x= table.getFloat(i, 6);
      temp.acceleration.y= table.getFloat(i, 7);
      temp.acceleration.z= table.getFloat(i, 8);
      rs.rings.get(0).addParticle(temp);              //TODO needed for added particles to be rendered. Streamline.98
      rs.particles.add(temp);                         //TODO needed for added particles to be updated.
    }
  } else if (s instanceof RingmindSystem) {
    if (s instanceof ResonantSystem) {
    } else {
      RingmindSystem rs=(RingmindSystem)s;

      addParticlesFromTable(rs.rs, filename);
    }
  } else if (s instanceof ShearSystem) {
    s.particles.clear();
    ShearSystem ss=(ShearSystem)s;

    for (int i = 0; i < table.getRowCount(); i++) {
      ShearParticle temp = new ShearParticle(ss);
      temp.position.x= table.getFloat(i, 0);
      temp.position.y= table.getFloat(i, 1);
      temp.position.z= table.getFloat(i, 2);
      temp.velocity.x= table.getFloat(i, 3);
      temp.velocity.y= table.getFloat(i, 4);
      temp.velocity.z= table.getFloat(i, 5);
      temp.acceleration.x= table.getFloat(i, 6);
      temp.acceleration.y= table.getFloat(i, 7);
      temp.acceleration.z= table.getFloat(i, 8);
      s.particles.add(temp);
    }
  }
}

/** Method importFromFileToGrid
 * @param s 
 * @param filename
 */
void importFromFileToGrid(System s, String filename) {

  Table table; 
  table = loadTable("./files/" + filename); //DEBUG println(table.getRowCount()+" "+ table.getColumnCount());

  //Check that there is a ArrayList of Grid objects and it is not empty.


  //If Statement to depending on System.
  if (s instanceof RingSystem) {

    //If Multiple Grids will always use Index 0. 
    int index =0;
    RingSystem rs = (RingSystem)s;
    if (rs.g != null && !rs.g.isEmpty()) {
      rs.rings.add(new Ring( 1, 3, 0));
      ArrayList<RingParticle> tempParticles = new ArrayList<RingParticle>();
      for (int i = 0; i < table.getRowCount(); i++) {
        for (int j = 0; j < table.getColumnCount(); j++) {
          for (int x=0; x<table.getInt(i, j); x++) {
            tempParticles.add(new RingParticle(rs.g.get(index).r_min+GRID_DELTA_R*i, GRID_DELTA_R, radians(GRID_DELTA_THETA*-j-180), radians(GRID_DELTA_THETA)));
          }
        }
      }
      rs.rings.get(0).particles=tempParticles;
    }
  }
}

//---------------------------------------------------------------------------------------------------------------
