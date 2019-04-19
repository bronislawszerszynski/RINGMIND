/**Class Ring
 * @author Thomas Cann
 * @version 1.0
 */

//class extension ashley james brown


class Ring {

  //Ring Properties
  ArrayList<RingParticle> particles;
  float r_inner, r_outer;
  color c;
  float Omega0;
  float density;

  //render variables
  private int maxRenderedParticle;
  Material material = null;

  //id
  int ringID = 0;

  /**
   *  Class Constuctor - General need passing all the values. 
   */
  Ring(int rnum, float Inner, float Outer, int n_particles) {
    this.ringID = rnum;
    r_inner= Inner;
    r_outer= Outer;
    particles = new ArrayList<RingParticle>();
    for (int i = 0; i < n_particles; i++) {
      particles.add(new RingParticle(Inner, Outer));
    }
    Omega0 = kepler_omega((r_inner +r_outer)/2.0);
    density();
    //set a default but overwritable by methods below for each ring and depends on state
    maxRenderedParticle = n_particles;
  }
  
  float density(){
    density = particles.size() / area();
  return density;
  }
  
  float area(){
  return PI *(sq(r_outer) - sq(r_inner));
  }
  
    /** Method to calculate the Keplerian orbital angular frequency (using Kepler's 3rd law).
   *@param r  Radial position (semi-major axis) to calculate the period [m].
   *@return   The angular frequency [radians/s].
   */
  float kepler_omega(float r) {
    return sqrt(GMp/(pow(r, 3.0)));
  }

  //--- new render methods setter and getter

  int getMaxRenderedParticle() {
    return maxRenderedParticle;
  }

  void setMaxRenderedParticle(int newMax) {
    maxRenderedParticle = min(particles.size(), newMax);
  }

  //Redundant Methods
  //void update(ArrayList<Moon> m) {
  //  for (Particle p : particles) {
  //    p.update();
  //  }
  //}
  //void display() {

  //  for (Particle p : particles) {
  //    p.display();
  //  }
  //}
  //void render(PGraphics x) {
  //  for (Particle p : particles) {
  //    p.render(x);
  //  }
  //}
}
