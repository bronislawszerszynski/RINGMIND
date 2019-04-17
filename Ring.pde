/**Class Ring
 * @author Thomas Cann
 * @version 1.0
 */

//class extension ashley james brown


class Ring {

  //render variables
  private int maxRenderedParticle;
  Material material = null;

  //id
  int ringID = 0;

  //
  ArrayList<RingParticle> particles;
  float r_inner, r_outer;
  color c;


  /**
   *  Class Constuctor - General need passing all the values. 
   */
  Ring(int rnum, float Inner, float Outer, int n_particles) {
    this.ringID = rnum;
    particles = new ArrayList<RingParticle>();
    for (int i = 0; i < n_particles; i++) {
      particles.add(new RingParticle(Inner, Outer));
    }
    //set a default but overwritable by methods below for each ring and depends on state
    maxRenderedParticle = n_particles;
  }
  
  
    //--- new render methods setter and getter

  int getMaxRenderedParticle() {
    return maxRenderedParticle;
  }

  void setMaxRenderedParticle(int newMax) {
     maxRenderedParticle = min(particles.size(),newMax);
  }
  
  
  
  
  
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
