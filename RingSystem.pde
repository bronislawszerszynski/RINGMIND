/**Class RingSystem collection of Rings, Ringlets and Gaps for a planetary ring system. 
 *
 * @author Thomas Cann
 * @author Sam Hinson
 */

//Simulation
RingSystem Saturn;

int N_PARTICLES = 10000; 
float G = 6.67408E-11;       // Gravitational Constant 6.67408E-11[m^3 kg^-1 s^-2] change 6.67408E-9;
float grid2value = 1E-8;




// What are the minimum and maximum extents in r for initialisation
float R_MIN = 1;
float R_MAX = 5;

final float GMp = 3.7931187e16;    // Gravitational parameter (Saturn)
final float Rp = 60268e3;          // Length scale (1 Saturn radius) [m]
final float SCALE = 100/Rp;        // Converts from [m] to [pixel] with planetary radius (in pixels) equal to the numerator. Size of a pixel represents approximately 600km.

/**
 *
 */
class RingSystem {

  ArrayList<Particle> totalParticles;
  ArrayList<TiltParticle> totalTParticles;
  ArrayList<Ring> rings;
  ArrayList<Moon> moons;
  ArrayList<Grid> g;
  float r_min, r_max;


  //pass them in instead
  int ring_index =6;
  int moon_index =0;

  boolean[][] Aligned;

  /**
   *  Class Constuctor - General need passing all the values. 
   */
  RingSystem(int ringIndex, int moonIndex, boolean type) {

    g = new ArrayList<Grid>();

    r_min= R_MIN;
    r_max= R_MAX;

    totalParticles = new ArrayList<Particle>();
    totalTParticles = new ArrayList<TiltParticle>();
    rings = new ArrayList<Ring>();
    moons = new ArrayList<Moon>();

    this.ring_index = ringIndex;
    this.moon_index = moonIndex;

    if (type==true) {
      println("making normal ring system");
      initialise();
    } else {
      println("making tilt RingSystem");
      initiliaseTilt();
    }


    this.Aligned = new boolean[moons.size()+1][moons.size()+1];
    //println(moons.size());
    for (int i =0; i<moons.size(); i++) {
      for (int j =0; j<=moons.size(); j++) {
        this.Aligned[i][j]=false;
      }
    }

    //***********************************************
  }

  void initiliaseTilt() {

    //g.add( new Grid(1.0, 5.0, 1E-8, 1E4));
    //g.add( new Grid(2.5, 5.0, 1E-7, 1E3));

    initialiseMoons();
    initialiseRings();

    totalTParticles.clear();

    for (Ring r : rings) {
      for (TiltParticle p : r.Tparticles) {
        totalTParticles.add(p);
      }
    }
    //for (Moon m : moons) {
    //  totalTParticles.add(m);
    //}
  }

  //-----------------------------------------------

  void initialise() {

    //g.add( new Grid(1.0, 5.0, 1E-8, 1E4));
    //g.add( new Grid(2.5, 5.0, 1E-7, 1E3));
    initialiseMoons();
    initialiseRings();
    totalParticles.clear();
    for (Ring r : rings) {
      for (RingParticle p : r.particles) {
        totalParticles.add(p);
      }
    }
    for (Moon m : moons) {
      totalParticles.add(m);
    }
  }

  //*********************Initialise Moons*********************

  void initialiseMoons() {
    moons.clear();


    switch(moon_index) {

      case(1):
      //no moons
      break;

      case(2):
      //Adding All 18 Moons
      for (int i = 0; i < 18; i++) {
        addMoon(i, moons);
      }
      break;

      case(3):
      // Adding Specific Moons ( e.g. Mima, Enceladus, Tethys, ... )
      addMoon(5, moons); //add the first 5 moons
      //addMoon(7, moons);
      //addMoon(9, moons);
      //addMoon(12, moons);
      //addMoon(14, moons);
      break;

      case(4):
      // Inner smaller moons
      addMoon(19, moons);
      addMoon(20, moons);
      addMoon(21, moons);
      addMoon(22, moons);
      addMoon(23, moons);
      // Larger outer moons
      addMoon(24, moons);
      addMoon(25, moons);
      addMoon(26, moons);
      addMoon(27, moons);
      addMoon(28, moons);
      break;

    default:
      break;
    }
  }

  void initialiseRings() {
    //***********Initialise Rings********************* 
    rings.clear();
    switch(ring_index) {
    case 1:
      //Generic Disc of Particles
      rings.add(new Ring(0, 1.1, 4.9, N_PARTICLES));

      calcDensity();
      break;

    case 2:
      //Saturn Ring Data (Source: Nasa Saturn Factsheet) [in Saturn radii]
      // D Ring: Inner 1.110 Outer 1.236
      rings.add(new Ring(0, 1.110, 1.236, N_PARTICLES/10));
      // C Ring: Inner 1.239 Outer 1.527
      rings.add(new Ring(1, 1.239, 1.527, N_PARTICLES/10));
      // B Ring: Inner 1.527 Outer 1.951
      rings.add(new Ring(2, 1.527, 1.951, N_PARTICLES/10));
      // A Ring: Inner 2.027 Outer 2.269
      rings.add(new Ring(3, 2.027, 2.269, N_PARTICLES/2));
      // F Ring: Inner 2.320 Outer *
      rings.add(new Ring(4, 2.320, 2.321, N_PARTICLES/10));
      // G Ring: Inner 2.754 Outer 2.874
      rings.add(new Ring(5, 2.754, 2.874, N_PARTICLES/10));
      // E Ring: Inner 2.987 Outer 7.964
      //rings.add(new Ring(2.987, 7.964, 1000));

      //Gaps/Ringlet Data
      // Titan Ringlet 1.292
      // Maxwell Gap 1.452
      // Encke Gap 2.265
      // Keeler Gap 2.265

      calcDensity();
      break;

    case 3:
      importFromFile("output.csv");

      calcDensity();
      break;

    case 4:
      rings.add(new Ring(0, 1, 3, 0));
      //rings.get(0).particles.add(new RingParticle(2, 0, 0, 0));

      calcDensity();
      break;

    case 5:
      //2 Discs of Particles
      rings.add(new Ring(0, 1.1, 2.9, N_PARTICLES/2));
      rings.add(new Ring(1, 4.5, 4.7, N_PARTICLES/2));

      calcDensity();
      break;

    case 6:
      //Square
      importFromFile("Square.csv");

      calcDensity();
      break;  

    case 9:
      //tilted
      println("adding tilted ring");
      rings.add(new Ring(1.1, 4.9, N_PARTICLES));
      println("tilt ring added.... no density calculated");
      break;

    case 10:
      // main RINGMIND
      g.add(new Grid(1.0, 3.4, 1E-8, 1E4));
      g.add(new Grid(3.4, 5.0, 1E-8, 1E4)); //switch 1E-8 and go to 2E-7
      //g.add(new Grid(3.4, 5.0, 2E7, 1E4)); //switch 1E-8 and go to 2E-7
      rings.add(new Ring(0, 1.110, 1.236, N_PARTICLES/12)); //inner ring
      rings.add(new Ring(1, 1.611, 2.175, N_PARTICLES/4)); //propeller ring
      rings.add(new Ring(2, 2.185, 2.6, N_PARTICLES/4));  //propeller ring
      rings.add(new Ring(3, 2.794, 2.795, N_PARTICLES/6)); //narrow ring
      rings.add(new Ring(4, 2.920, 2.921, N_PARTICLES/6)); //narrow ring
      rings.add(new Ring(5, 3.5, 3.8, N_PARTICLES/3)); //clumping ring

      calcDensity();
      break;

    case 11:
      // main RINGMIND
      g.add(new Grid(1.0, 3.4, 1E-8, 1E4));
      g.add(new Grid(3.4, 5.0, 9E-7, 1E4)); //switch 1E-8 and go to 2E-7
      //g.add(new Grid(3.4, 5.0, 2E7, 1E4)); //switch 1E-8 and go to 2E-7
      rings.add(new Ring(0, 1.110, 1.236, N_PARTICLES/12)); //inner ring
      rings.add(new Ring(1, 1.611, 2.175, N_PARTICLES/4)); //propeller ring
      rings.add(new Ring(2, 2.185, 2.6, N_PARTICLES/4));  //propeller ring
      rings.add(new Ring(3, 2.794, 2.795, N_PARTICLES/6)); //narrow ring
      rings.add(new Ring(4, 2.920, 2.921, N_PARTICLES/6)); //narrow ring
      rings.add(new Ring(5, 3.5, 3.8, N_PARTICLES/3)); //clumping ring

      calcDensity();
      break;

    case 12:

      rings.add(new Ring(1, 5.0, 5.2, 22500));
      rings.get(0).particles.clear();
      addParticlesFromTable("outputParticles.csv");
      break;

    case 13:
      rings.add(new Ring(1, 5.0, 5.2, 22500));
      // rings.get(0).particles.clear();
      //addParticlesFromTable("outputParticles.csv");
      // rings.add(new Ring(1,5.0,5.2,1000));
      break;

    default:
      rings.add(new Ring(0, 1, 3, 0));
      break;
    }
  }

  void calcDensity() {
    for (int i =0; i<rings.size(); i++) {
      rings.get(i).density = rings.get(i).density()/rings.get(0).density();
    }
  }

  void addParticlesFromTable(String Filename) {
    Table table; 
    table = loadTable("./files/"+Filename);//output.csv");//"input.csv"

    //particles.clear();

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
      rings.get(1).particles.add(temp);
      totalParticles.add(temp);
    }
  }

  void importFromFile(String filename) {
    rings.add(new Ring(0, 1, 3, 0));
    Table table; 
    table = loadTable("./files/" + filename);//"input.csv"
    //println(table.getRowCount()+" "+ table.getColumnCount());
    ArrayList<RingParticle> tempParticles = new ArrayList<RingParticle>();
    for (int i = 0; i < table.getRowCount(); i++) {
      for (int j = 0; j < table.getColumnCount(); j++) {

        for (int x=0; x<table.getInt(i, j); x++) {
          tempParticles.add(new RingParticle(r_min+GRID_DELTA_R*i, GRID_DELTA_R, radians(GRID_DELTA_THETA*-j-180), radians(GRID_DELTA_THETA)));
        }
      }
    }
    rings.get(0).particles=tempParticles;
  }

  /**
   *  Updates object for one time step of simulation taking into account the position of one moon.
   */
  void update() {

    for (Particle p : totalParticles) {
      p.set_getAcceleration(this);
    }
    for (Particle p : totalParticles) {
      p.updatePosition();
    }
    for (Grid x : g) {
      x.update(this);
    }

    for (Grid x : g) {
      x.display(this);
    }
    for (Particle p : totalParticles) {
      p.updateVelocity(p.getAcceleration(this));
    }
    ////Output TABLE 
    //if ((frameCount)%50 ==0) {
    //  saveTable(g.get(0).gridToTable(g.get(0).grid), "./files/output.csv");
    //}
    // moon alignment only with moon 1


    if (MoonAlignment) {
      // for (int i =0; i<(moons.size()-1); i++) {
      for (int i =0; i<1; i++) {
        for (int j = i+1; j<(moons.size()); j++) {
          boolean isAligned =moons.get(i).isAligned(moons.get(j));
          // println(this.Aligned[0][0]);//test[i][j]);
          if ( Aligned[i][j] != isAligned && isAligned == true ) {
            Aligned[i][j] =true; 
            // println(i+" "+j+" "+abs(moons.get(i).timeToAlignment(moons.get(j))));
            //osc moon alignment
            oscMoonAlignment(j, moons.get(i).timeToAlignment(moons.get(j)));
          } else if ( Aligned[i][j] != isAligned && isAligned == false) {
            Aligned[i][j] =false;
          }
        }
      }
    }
  }//end update

  void tiltupdate() {
    for (TiltParticle p : totalTParticles) {
      p.set_getAcceleration(this);
    }
    for (TiltParticle p : totalTParticles) {
      p.updatePosition();
    }
    for (Grid x : g) {
      x.tiltupdate(this);
    }
    for (TiltParticle p : totalTParticles) {
      p.updateVelocity(p.getAcceleration(this));
    }
  }

  /**
   *
   */
  void display() {
    push();
    translate(width/2, height/2);
    strokeWeight(2);
    stroke(255);
    for (Ring r : rings) {
      for (RingParticle p : r.particles) {

        point(SCALE*p.position.x, SCALE*p.position.y);
      }
    }
    strokeWeight(4);
    stroke(255, 0, 0);
    for (Moon m : moons) {
      point(SCALE*m.position.x, SCALE*m.position.y);
    }

    guidelines();

    //for (Particle p : totalParticles) {
    //  if (p instanceof RingParticle) {
    //    strokeWeight(2);
    //    stroke(255);
    //    point(SCALE*p.position.x, SCALE*p.position.y);
    //  } else if ( p instanceof Moon) {
    //    strokeWeight(4);
    //    stroke(255, 0, 0);
    //    point(SCALE*p.position.x, SCALE*p.position.y);
    //  }
    //}
    pop();

    for (Grid x : g) {
      x.display(this);
    }
  }

  //guidelines round edge of rings and planet.
  void guidelines() {
    strokeWeight(1);
    stroke(255, 165, 0);
    noFill();
    circle(0, 0, 2*R_MAX*SCALE*Rp);
    circle(0, 0, 2*R_MIN*SCALE*Rp);
    fill(255, 165, 0);
    circle(0, 0, 2.0*SCALE*Rp);
  }

  /**
   *
   */
  void render(PGraphics x) {
    for (Ring r : rings) {
      //r.render(x);
    }
    for (Moon m : moons) {
      m.render(x);
    }
  }


  /**
   *
   */
  void addMoon(int i, ArrayList<Moon> m) {

    //Source: Nasa Saturn Factsheet

    switch(i) {
    case 0:
      // Pan Mass 5e15 [kg] Radius 1.7e4 [m] Orbital Radius 133.583e6 [m]
      m.add(new Moon(0, G*5e15, 1.7e4, 133.5832e6));
      break;
    case 1:
      // Daphnis Mass 1e14 [kg] Radius 4.3e3 [m] Orbital Radius 136.5e6 [m]
      m.add(new Moon(1, G*1e14, 4.3e3, 136.5e6));
      break;
    case 2:
      // Atlas Mass 7e15 [kg] Radius 2e4 [m] Orbital Radius 137.67e6 [m]
      m.add(new Moon(2, G*7e15, 2.4e4, 137.67e6));
      break;
    case 3:
      // Promethieus Mass 1.6e17 [kg] Radius 6.8e4 [m] Orbital Radius 139.353e6 [m]
      m.add(new Moon(3, G*1.6e17, 6.8e4, 139.353e6));
      break;
    case 4:
      // Pandora Mass 1.4e17 [kg] Radius 5.2e4 [m] Orbital Radius 141.7e6 [m]
      m.add(new Moon(4, G*1.4e17, 5.2e4, 141.7e6));
      break;
    case 5:
      // Epimetheus Mass 5.3e17 [kg] Radius 6.5e4 [m] Orbital Radius 151.422e6 [m]
      m.add(new Moon(5, G*5.3e17, 6.5e4, 151.422e6, color(0, 255, 0)));
      break;
    case 6:
      // Janus Mass 1.9e18 [kg] Radius 1.02e5 [m] Orbital Radius 151.472e6 [m]
      m.add(new Moon(6, G*1.9e18, 1.02e5, 151.472e6));
      break;
    case 7: 
      // Mimas Mass 3.7e19 [kg] Radius 2.08e5 [m] Obital Radius 185.52e6 [m]
      m.add(new Moon(7, G*3.7e19, 2.08e5, 185.52e6));
      break;
    case 8:
      // Enceladus Mass 1.08e20 [kg] Radius 2.57e5 [m] Obital Radius 238.02e6 [m]
      m.add(new Moon(8, G*1.08e20, 2.57e5, 238.02e6));
      break;
    case 9:
      // Tethys Mass 6.18e20 [kg] Radius 5.38e5 [m] Orbital Radius 294.66e6 [m]
      m.add(new Moon(9, G*6.18e20, 5.38e5, 294.66e6));
      break;
    case 10:
      // Calypso Mass 4e15 [kg] Radius 1.5e4 [m] Orbital Radius 294.66e6 [m]
      m.add(new Moon(10, G*4e15, 1.5e4, 294.66e6));
      break;
    case 11:
      // Telesto Mass 7e15 [kg] Radius 1.6e4 [m] Orbital Radius 294.66e6 [m]
      m.add(new Moon(11, G*7e15, 1.6e4, 294.66e6));
      break;
    case 12:
      // Dione Mass 1.1e21 [kg] Radius 5.63e5 [m] Orbital Radius 377.4e6 [m]
      m.add(new Moon(12, G*1.1e21, 5.63e5, 377.4e6));
      break;
    case 13:
      // Helele Mass 3e16 [kg] Radius 2.2e4 [m] Orbital Radius 377.4e6[m]
      m.add(new Moon(13, G*3e16, 2.2e4, 377.4e6));
      break;
    case 14:
      // Rhea Mass 2.31e21 [kg] Radius 7.65e5 [m] Orbital Radius 527.04e6 [m]
      m.add(new Moon(14, G*2.31e21, 7.65e5, 527.4e6));
      break;
    case 15:
      // Titan Mass 1.3455e23 [kg] Radius 2.575e6 [m] Orbital Radius 1221.83e6 [m]
      m.add(new Moon(15, G*1.34455e23, 2.57e6, 1221.83e6));
      break;
    case 16:
      // Hyperion Mass 5.6e18 [kg] Radius 1.8e5 [m] Orbital Radius 1481.1e6 [m]
      m.add(new Moon(16, G*5.6e18, 1.8e5, 1481.1e6));
      break;
    case 17:
      // Iapetus Mass 1.81e21 [kg] Radius 7.46e5 [m] Orbital Radius 3561.3e6 [m]
      m.add(new Moon(17, G*1.81e21, 7.46e5, 3561.3e6));
      break;
    case 18:
      // Pheobe Mass 8.3e18 [kg] Radius 1.09e5 [m] Orbital Radius 12944e6 [m] 
      m.add(new Moon(18, G*8.3e18, 1.09e5, 12994e6));
      break;
    case 19:
      m.add(new Moon(19, G*3.7e18, 1.77e6, 1.373657091*Rp));    
      break;
    case 20:
      m.add(new Moon(20, G*1.5e20, 2.66e6, 2.180544711*Rp));
      break;
    case 21:
      m.add(new Moon(21, G*9.0e18, 9.90e5, 2.857321894*Rp));
      break;
    case 22:
      m.add(new Moon(22, G*3.7e19, 1.32e6, 3.226611418*Rp));
      break;
    case 23:
      m.add(new Moon(23, G*3.7e19, 4.08e6, 4.0165977*Rp));
      break;
    case 24:
      m.add(new Moon(24, G*2.31e21, 1.65e7, 8.75091259*Rp));  //Rhea
      break;
    case 25:
      m.add(new Moon(25, G*4.9e20, 6.85e7, 16.49*Rp));  
      break;
    case 26:
      m.add(new Moon(26, G*1.34455e23, 8.57e7, 20.27327*Rp));  
      break;
    case 27:
      m.add(new Moon(27, G*3.7e22, 2.08e8, 34.23*Rp));
      break;
    case 28:
      m.add(new Moon(28, G*1.81e21, 7.46e7, 49.09*Rp));
      break;
    }
  }
}

//***********************************************************************//

/**
 * Class Ring
 * @author Thomas Cann
 * @author ashley james brown
 */


class Ring {
  //render variables
  private int maxRenderedParticle;
  Material material = null;
  //ring variables
  int ringID = 0;//id
  ArrayList<TiltParticle> Tparticles;
  ArrayList<RingParticle> particles;
  float r_inner, r_outer, Omega0, density;
  color c;

  /**
   *  Class Constuctor - General need passing all the values. 
   */
  Ring(int rnum, float Inner, float Outer, int n_particles) {
    this.ringID = rnum;
    this.r_inner = Inner;
    this.r_outer = Outer;

    particles = new ArrayList<RingParticle>();
    for (int i = 0; i < n_particles; i++) {
      particles.add(new RingParticle(Inner, Outer));
    }

    Omega0 = kepler_omega((Inner + Outer)/2.0);

    //set a default but overwritable by methods below for each ring and depends on state
    maxRenderedParticle = n_particles;

    // this.density = density();
  }

  //tilted ring doesnt have an ID
  Ring(float Inner, float Outer, int n_particles) {
    Tparticles = new ArrayList<TiltParticle>();

    this.r_inner = Inner;
    this.r_outer = Outer;

    for (int i = 0; i < n_particles; i++) {
      Tparticles.add(new TiltParticle(Inner, Outer));
    }

    this.Omega0 = kepler_omega((Inner + Outer)/2.0); 

    //set a default but overwritable by methods below for each ring and depends on state
    //maxRenderedParticle = n_particles;
  }

  //--- new render methods setter and getter

  int getMaxRenderedParticle() {
    return maxRenderedParticle;
  }

  void setMaxRenderedParticle(int newMax) {
    maxRenderedParticle = min(particles.size(), newMax);
  }

  /** Method to calculate the Keplerian orbital angular frequency (using Kepler's 3rd law).
   *@param r Radial position (semi-major axis) to calculate the period [m].
   *@return The angular frequency [radians/s].
   */
  float kepler_omega(float r) {
    return sqrt(1/(pow(r, 3.0)));
  }

  /** Method to calculate the density of particles in ring.
   *@return denstiy [N/A].
   */
  float density() {
    return particles.size() /(PI *(sq(r_outer) - sq(r_inner)));
  }
}
