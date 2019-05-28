/**
 * Class Moon
 *
 * @author Thomas Cann
 * @author Sam Hinson
 * @author ashley james brown
 */

class Moon extends Particle implements Alignable {

  // int moonID = 0;
  float GM;
  float radius;
  color c ;
  final float moonSizeScale= 2;
  ArrayList<Resonance> r;

  /**
   *  Class Constuctor - General Moon object with random angle. 
   */
  Moon(float Gm, float radius, float orb_radius, color c) {
    super(orb_radius);
    this.GM=Gm;
    this.radius=radius;
    this.c= c; 
    r= new ArrayList<Resonance>();

    //   this.moonID = mnum;
  }
  /**
   *  Class Constuctor - General Moon object with random angle. 
   */
  Moon(float Gm, float radius, float orb_radius) {
    super(orb_radius);
    this.GM=Gm;
    this.radius=radius;
    c= color(random(255), random(255), random(255));
    r= new ArrayList<Resonance>();
    //  this.moonID = mnum;
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

  /**
   *Display Method - Renders this object to screen displaying its position and colour.
   */
  void display() {
    push();
    translate(width/2, height/2);
    ellipseMode(CENTER);
    fill(c);
    stroke(c);
    circle(SCALE*position.x, SCALE*position.y, 2*moonSizeScale*radius*SCALE);
    pop();
  }

  /**Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
   * @param rs RingSystem Object
   * @return current acceleration of this moon due to rest of RingSystem. 
   */
  PVector getAcceleration(RingSystem rs) {

    // acceleration due planet in centre of the ring. 
    PVector a_grav = PVector.mult(position.copy().normalize(), -GMp/position.copy().magSq());

    // acceleration due the moons on this particle.
    for (Moon m : rs.moons) {
      if (m != this) {
        PVector dist = PVector.sub(m.position, position);
        PVector a = PVector.mult(dist, m.GM/pow(dist.mag(), 3));
        a_grav.add(a);
      }
    }

    return a_grav;
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
    return dAngle/(dOmega*simToRealTimeRatio);
  }

  /** Method to calculate the Keplerian orbital angular frequency (using Kepler's 3rd law).
   *@param r Radial position (semi-major axis) to calculate the period [m].
   *@return The angular frequency [radians/s].
   */
  float kepler_omega(Moon m) {
    return sqrt(GMp/(pow(m.position.mag(), 3.0)));
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

  void addResonance(float Q) {
    Resonance R = new Resonance(Q, this);
    r.add(R);
  }
}

/**Interface Alignable - template for checking if different objects types of objects align. 
 * @author Thomas Cann
 */
public interface Alignable {
  public boolean isAligned(Alignable other); //Alignment Threshold
  //public float timeToAlignment(Alignable other); //What units? [s]
}

public class Resonance {

  float Q;
  float rGap;
  float Effect;
  float rMax;
  float bellMag = 100;
  float bellWidth = 0.001913069;

  Resonance(float Q, Moon m) {
    this.Q = Q;
    calcRGap(m);
    //calcEffect(m);
    calcRmax();
  }

  void calcRGap(Moon m) {
    rGap = m.position.mag()*pow(Q, (-2.0/3.0));
  }
  //void calcEffect(Moon m) {
  //  //Accleration at gap ( Gravitational force due to moon at ring gap --> moonmass/(rmoon -rgap)^2 multiplied by a constant
  //}

  float calcAccleration(float x) {

    // a proportional to GM pow(Q, ?) 
    return bellMag*exp( -sq(x) /(Q*bellWidth)) + 1;
  }

  void calcRmax() {
    // Bell Curve/ Effect curve gets to f(0)= 1 ---> f(RMax)=0.01
    rMax = rGap + sqrt((-bellWidth*log(0.01/bellMag))/Q);
  }
}

//public class ResonantMoon extends Moon {

//  ArrayList<Resonance> r;

//  ResonantMoon() {
//    super();
//    r = new ArrayList();
//  }

//  void addResonance(float Q) {
//    R = new Resonance(Q, this);
//  }
//}
