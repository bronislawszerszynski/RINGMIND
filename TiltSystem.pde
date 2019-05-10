float MAX_INCLINATION=80;
float MIN_INCLINATION=1;
float LAMBDA= 3E-5;

class TiltParticle extends Particle {

  float rotation;
  float inclination;
  float initialiseTime;
  float minInclination;

  /**
   * Class Constuctor - Initialises an RingParticle object with a random position in the ring with correct orbital velocity. 
   */
  TiltParticle(float r, float dr, float theta, float dtheta) {
    // Initialise our Orboids.
    super((random(1)*(dr) + r)*Rp, theta + random(1)*dtheta);
    rotation =random(360);
    inclination= randomGaussian()*MAX_INCLINATION;
    minInclination = randomGaussian()* MIN_INCLINATION;
    initialiseTime = millis();
  }
  /**
   * Class Constuctor - Initialises an RingParticle object with a random position in the ring with correct orbital velocity. 
   */
  TiltParticle(float inner, float outer) {
    // Initialise our Orboids.
    super((random(1)*(outer-inner) + inner)*Rp, random(1)*2.0*PI);
    rotation =random(360);
    inclination= randomGaussian()*MAX_INCLINATION;
    minInclination = randomGaussian()* MIN_INCLINATION;
    initialiseTime = millis();
  }

  /**
   * Class Constuctor - Initialises an RingParticle object with a random position in the ring with correct orbital velocity. 
   */
  TiltParticle(float radius) {
    // Initialise ourRingParticle.
    super(radius, random(1)*2.0*PI);
    rotation =random(360);
    inclination= randomGaussian()*MAX_INCLINATION;
    minInclination = randomGaussian()* MIN_INCLINATION;
    initialiseTime = millis();
  }

  float inclination() {
    return inclination* exp(-LAMBDA*(millis()-initialiseTime)) +minInclination ;
  }

  PVector getAcceleration(RingSystem rs) {

    // acceleration due planet in centre of the ring. 
    PVector a_grav = PVector.mult(position.copy().normalize(), -GMp/position.copy().magSq());

    //Acceleration from the Grid Object
    for (Grid x : rs.g) {
      a_grav.add(x.gridAcceleration(this));
    }
    for (Moon m : rs.moons) {
      PVector dist = PVector.sub(m.position, position);
      PVector a = PVector.mult(dist, m.GM/pow(dist.mag(), 3));
      a_grav.add(a);
    }
    return a_grav;
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------

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
