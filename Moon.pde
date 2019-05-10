/**
 * Class Moon
 *
 * @author Thomas Cann
 * @author Sam Hinson
 * @author ashley james brown
 */



class Moon extends Particle implements Alignable {

  int moonID = 0;
  float GM;
  float radius;
  color c ;

  final float moonSizeScale= 2;
  


  /**
   *  Class Constuctor - General Moon object with random angle. 
   */
  Moon(int mnum, float Gm, float radius, float orb_radius, color c) {
    super(orb_radius);
    this.GM=Gm;
    this.radius=radius;
    this.c= c; 

    this.moonID = mnum;
  }
  /**
   *  Class Constuctor - General Moon object with random angle. 
   */
  Moon(int mnum, float Gm, float radius, float orb_radius) {
    super(orb_radius);
    this.GM=Gm;
    this.radius=radius;
    c= color(random(255), random(255), random(255));

    this.moonID = mnum;
  }
  /**
   *  Class Constuctor - Default Moon object with properties of Mima (loosely). 
   */
  Moon(PVector p, PVector v) {
    //Mima (Source: Nasa Saturn Factsheet)
    //GM - 2.529477495E9 [m^3 s^-2]
    //Radius - 2E5 [m]
    //Obital Radius - 185.52E6 [m]

    this(0, 2.529477495e13, 400e3, 185.52e6);
    this.position.x = p.x;
    this.position.y = p.y;
    this.position.z = p.z;
    this.velocity.x = v.x;
    this.velocity.y = v.y;
    this.velocity.z = v.z;
  }


  /**
   *  Display Method - Renders this object to screen displaying its position and colour.
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
  //  void render(PGraphics x) {
  //  x.push();
  //  x.translate(width/2, height/2);
  //  x.ellipseMode(CENTER);
  //  x.fill(c);
  //  x.stroke(c);
  //  x.circle(scale*position.x, scale*position.y, 2*moonSizeScale*radius*scale);
  //  x.pop();
  //}


  /**
   *  Calculates the acceleration on this particle (based on its current position) (Does not override value of acceleration of particle)
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


// moon 360 position is missing.

  boolean isAligned(Alignable other) {
    boolean temp =false;
    Moon otherMoon = (Moon)other;
    float dAngle = this.position.heading() - otherMoon.position.heading();
    
    float angleThreshold = radians(1);
    if ( abs(dAngle) < angleThreshold) {//% PI
      temp =true;
      //if(dAngle >0){
      //}
      //alignment test
      //println(otherMoon.moonID + " aligned with "+ this.moonID);
      //this.c= color(0, 0, 255);
      //otherMoon.c= color(0, 0, 255);
    } 
    return temp;
  }

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
  
  
  //method to get the angle in degrees of the moon
  
  float moonAngle(Moon m){
    PVector center = new PVector(0,0,0);
    PVector mm = new PVector(m.position.x,m.position.y,0);
    return degrees(PVector.angleBetween(center,mm));
  } 
}

public interface Alignable {
  public boolean isAligned(Alignable other); //Alignment Threshold
  //public float timeToAlignment(Alignable other); //What units? [s]
}


//void initMoonWeight() {
//  Saturn.moons.get(0).moonWeight=1.77e6*SCALE;
//  Saturn.moons.get(1).moonWeight=2.66e6*SCALE;
//  Saturn.moons.get(2).moonWeight=9.90e5*SCALE;
//  Saturn.moons.get(3).moonWeight=(1.32e6*SCALE)/2;
//  Saturn.moons.get(4).moonWeight=4.08e6*SCALE;
//  Saturn.moons.get(5).moonWeight=(1.65e7*SCALE)/4;
//  Saturn.moons.get(6).moonWeight=(6.85e7*SCALE)/4;
//  Saturn.moons.get(7).moonWeight=(8.57e7*SCALE)/8;
//  Saturn.moons.get(8).moonWeight=(2.08e8*SCALE)/8;
//  Saturn.moons.get(9).moonWeight=(7.46e7*SCALE)/6;
//}

    //for (Moon m : Saturn.moons) {
    //  m.moonWeight = 1;
    //}

    //Saturn.moons.get(0).moonWeight=1;
    //Saturn.moons.get(1).moonWeight=1;
    //Saturn.moons.get(2).moonWeight=2;
    //Saturn.moons.get(3).moonWeight=2;
    //Saturn.moons.get(4).moonWeight=3;
    //Saturn.moons.get(5).moonWeight=3;
    //Saturn.moons.get(6).moonWeight=4;
    //Saturn.moons.get(7).moonWeight=4;
    //Saturn.moons.get(8).moonWeight=5;
    //Saturn.moons.get(9).moonWeight=5;
    
    //Saturn.moons.get(0).moonWeight=1.77e6*SCALE;
    //Saturn.moons.get(1).moonWeight=2.66e6*SCALE;
    //Saturn.moons.get(2).moonWeight=9.90e5*SCALE;
    //Saturn.moons.get(3).moonWeight=(1.32e6*SCALE)/2;
    //Saturn.moons.get(4).moonWeight=4.08e6*SCALE;
    //Saturn.moons.get(5).moonWeight=1.65e7*SCALE;
    //Saturn.moons.get(6).moonWeight=(6.85e7*SCALE)/4;
    //Saturn.moons.get(7).moonWeight=(8.57e7*SCALE)/4;
    //Saturn.moons.get(8).moonWeight=(2.08e8*SCALE)/4;
    //Saturn.moons.get(9).moonWeight=(7.46e7*SCALE)/4;
    
    
//    Saturn.moons.get(0).moonWeight=1.77e6*SCALE;
//    Saturn.moons.get(1).moonWeight=2.66e6*SCALE;
//    Saturn.moons.get(2).moonWeight=9.90e5*SCALE;
//    Saturn.moons.get(3).moonWeight=(1.32e6*SCALE)/2;
//    Saturn.moons.get(4).moonWeight=4.08e6*SCALE;
//    Saturn.moons.get(5).moonWeight=1.65e7*SCALE;
//    Saturn.moons.get(6).moonWeight=(6.85e7*SCALE)/4;
//    Saturn.moons.get(7).moonWeight=(8.57e7*SCALE)/4;
//    Saturn.moons.get(8).moonWeight=(2.08e8*SCALE)/4;
//    Saturn.moons.get(9).moonWeight=(7.46e7*SCALE)/4;

//    Saturn.moons.get(0).moonWeight=1.77e6*SCALE;
//    Saturn.moons.get(1).moonWeight=2.66e6*SCALE;
//    Saturn.moons.get(2).moonWeight=9.90e5*SCALE;
//    Saturn.moons.get(3).moonWeight=(1.32e6*SCALE)/2;
//    Saturn.moons.get(4).moonWeight=4.08e6*SCALE;
//    Saturn.moons.get(5).moonWeight=1.65e7*SCALE;
//    Saturn.moons.get(6).moonWeight=(6.85e7*SCALE)/4;
//    Saturn.moons.get(7).moonWeight=(8.57e7*SCALE)/4;
//    Saturn.moons.get(8).moonWeight=(2.08e8*SCALE)/4;
//    Saturn.moons.get(9).moonWeight=(7.46e7*SCALE)/4;
