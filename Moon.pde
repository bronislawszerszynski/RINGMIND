/**Class Moon
 *
 * @author Thomas Cann
 * @author Sam Hinson
 * @version 1.0
 */

// class extension ashley james brown

public interface Alignable {
  
  public boolean isAligned(Alignable other);  //Alignment Threshold
  //public float timeToAlignment(Alignable other); //What units? [s]

}


class Moon extends Particle implements Alignable {

  //Extra Moon Properties
  float GM;
  float radius;
  color c ;
  final float moonSizeScale= 2;

  //id
  int moonID = 0; 

  /**
   *  Class Constuctor - General Moon object with random angle and color. 
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
    c= color(255, 0, 0);

    this.moonID = mnum;
  }

  /**
   *  Class Constuctor - Default Moon object with properties of Mima (loosely). Allowing for Specific Position and Velocity.
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

  /**
   *  Render Method - Renders this object to PGraphics Object with its position and colour.
   */
  void render(PGraphics x) {
    x.push();
    x.translate(width/2, height/2);
    x.ellipseMode(CENTER);
    x.fill(c);
    x.stroke(c);
    x.circle(SCALE*position.x, SCALE*position.y, 2*moonSizeScale*radius*SCALE);
    x.pop();
  }

  boolean isAligned(Alignable other) {
    boolean temp =false;
    Moon otherMoon = (Moon)other;
    float angleThreshold = asin(radians(5));
    if (this.position.copy().normalize().cross(otherMoon.position.copy().normalize()).mag()< angleThreshold){
     temp=true;
    }
    return temp;
  }
}
