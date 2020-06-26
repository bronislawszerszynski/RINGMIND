import java.awt.Rectangle;

//Grid Default Variables 
float R_MIN = 1;                   //[Planetary Radi] 
float R_MAX = 5;                   //[Planetary Radi] 
float GRID_DELTA_R = 0.1;          //[Planetary Radi]  
float GRID_DELTA_THETA = 1;        //[Degrees]
float GRID_DRAG_CONSTANT = 5E-7;   //[s^{2}]
float GRID_DRAG_PROBABILITY = 1E4 ;//[[Planetary Radi^{2}.s]

/**Class Grid - polar spatial subdivision using density of particles, average velocity and center of mass to probabliticly model collisions. 
 * @author Thomas Cann
 * @author Sam Hinson
 */
class Grid {

  //Grid Variables
  protected float dr, dtheta, r_min, r_max;  
  protected int sizeTheta, sizeR;  
  protected float drag_c, drag_p;  //Constants for Drag Rule. 
  protected int grid[][];          //Grid to hold the number of particle in each cell
  protected float gridNorm[][];    //Grid to hold Normalised Number Density of Particles in Cell (# Particles in Cell / ( Area and Total # Particles in Simulation)). [(1/(m^2)]
  protected PVector gridV[][];     //Grid to hold the average velocity of cell. [ms^-1,ms^-1,ms^-1]
  protected PVector gridCofM[][];  //Grid to hold centroid value for cell.[m,m,m]

  //Optimisation Variables
  private float minSize = 4*(sq(r_min *radians(dtheta)/2)+sq(dr)); //Based on the minimum grid size.

  /**
   *  Grid Constuctor - General need passing all the values. 
   */
  Grid(float r_min, float r_max, float grid_dr, float grid_dtheta, float drag_c, float drag_p) {
    this.dr = grid_dr;
    this.dtheta = grid_dtheta;
    this.r_min = r_min;
    this.r_max = r_max;
    this.sizeTheta =int(360/this.dtheta);               //Size of 1st Dimension of Grid Arrays
    this.sizeR = int((this.r_max-this.r_min)/this.dr);  //Size of 2nd Dimension of Grid Arrays
    this.grid = new int[sizeTheta][sizeR];
    this.gridNorm = new float[sizeTheta][sizeR];
    this.gridV = new PVector[sizeTheta][sizeR];
    this.gridCofM = new PVector[sizeTheta][sizeR];
    this.drag_c= drag_c; 
    this.drag_p= drag_p; 
    reset();
  }

  /**
   *  Grid Constuctor - Taking in a value for r_min and r_max and drag constants but all the other values from global variables. 
   */
  Grid(float r_min, float r_max ,float drag_c, float drag_p) {
    this(r_min, r_max, GRID_DELTA_R, GRID_DELTA_THETA, drag_c, drag_p);
  }
  /** 
   * Sets all the values in the arrays to zero. Called at start of Update Method.
   */
  void reset() {
    for (int i = 0; i < int(360/dtheta); i++) {
      for (int j = 0; j < int((r_max-r_min)/dr); j++) {
        grid[i][j] = 0;
        gridNorm[i][j] = 0;
        gridV[i][j]= new PVector();
        gridCofM[i][j]= new PVector();
      }
    }
  }

  /**
   * Returns the angle of the particle between 0 and 2PI measured from horizontal right from clockwise.
   *
   * @param   p  a particle with a position vector. 
   * @return  angle  
   */
  float angle(Particle p) {
    return (atan2(p.position.y, p.position.x)+TAU)%(TAU);
  }

  /**
   * Returns the index of which angular bin a particle belongs to. 
   *
   * @param   p  a particle with a position vector. 
   * @return  i index of grid [between 0 and 360/dr]   
   */
  int i(Particle p) {
    return i(angle(p));
  }

  /**
   * Returns the index of which angular bin a particle belongs to. 
   *
   * @param   angle between 0 and 2PI measured from horizontal right from clockwise . 
   * @return  i index of grid [between 0 and 360/dr]  
   */
  int i(float angle) {
    return floor(degrees(angle)/dtheta);
  }

  /**
   * Returns angle of the centre of the cell (from horizontal, upward, clockwise)
   * @param i angular index of grid [between 0 and 360/dr]
   * @return angle of the centre of the cell
   */
  float angleCell(int i) {
    return radians(dtheta*(i+0.5));
  }

  /**
   *    Calculates the difference in angle between a particle and the centre of its cell
   */
  float angleDiff(Particle p) {
    return angleCell(i(p))-angle(p);
  }

  /**
   * Returns the index of which radial bin a particle belongs to.
   *
   * @param p a particle with a position vector.
   * @return j index of grid[between 0 and ring thickness / dr]
   */
  int j(Particle p) {
    return j(p.position.mag());
  }

  /**
   * Returns the index of which radial bin a particle belongs to.
   *
   * @param radius 
   * @return j index of grid[between 0 and ring thickness / dr]
   */
  int j(float radius) {
    return floor((radius/System.Rp - r_min)/dr);
  }

  /**
   * Returns radius of the centre of a cell (from x=0 and y=0)
   * @param j  index of grid[between 0 and ring thickness / dr]
   * @return 
   */
  float radiusCell(int j) {
    return System.Rp*(r_min + dr*(j+0.5));
  }

  float radialScaling(Particle p) {
    return sqrt(radiusCell(j(p))/p.position.mag());
  }

  /**
   * Check to see if the Particle is in the grid .
   *
   * @param p a particle with a position vector.
   * @return
   */
  boolean validij(Particle p) {
    return validij(i(p), j(p));
  }

  boolean validij(int i, int j ) {
    boolean check = false;
    if (i< sizeTheta && i>=0  ) {
      if (j < int((r_max-r_min)/dr)  && j>=0) {
        check = true;
      }
    }
    return check;
  }

  /**
   * Returns a vector from the centre of RingSystem to the centre of a specific angular and radial bin.
   * @param i angular index of grid [between 0 and 360/dr]
   * @param j radial index of grid[between 0 and ring thickness / dr]
   * @return 
   */
  PVector centreofCell(int i, int j ) {
    float r = radiusCell(j);  
    float angle = angleCell(i);
    return new PVector(r*cos(angle), r*sin(angle));
  }

  /**
   * Returns a vector representing the keplerian velocity of the centre of a specific angular and radial bin. 
   * @param i angular index of grid [between 0 and 360/dr]
   * @param j radial index of grid[between 0 and ring thickness / dr]
   * @return 
   */
  PVector keplerianVelocityCell(int i, int j) {
    float r = radiusCell(j);  
    float angle = angleCell(i);
    return new PVector(sqrt(System.GMp/(r))*sin(angle), -sqrt(System.GMp/(r))*cos(angle));
  }

  /**
   * Acceleration on a particle due to average values in a grid.  
   * @param Particle p a particle with a position vector.
   * @return  
   */
  PVector gridAcceleration(Particle p, float dt) {

    PVector a_grid = new PVector();
    if (validij(p)) {
      //Fluid Drag Force / Collisions - acceleration to align to particle the average velocity of the cell. 
      a_grid.add(dragAcceleration(p, dt));

      // Self Gravity   
      //a_grid.add(selfGravAcceleration(p));
    }
    return a_grid;
  }

  /**
   * Drag Acceleration on a particle due to difference between particle velocity and average velocity of the grid cell (taking into account the number of particles in the cell).  
   *
   * @param Particle p 
   * @return 
   */
  PVector dragAcceleration(Particle p, float dt) {

    // Collisions - acceleration due drag (based on number of particles in grid cell).
    PVector a_drag = new PVector();

    //Find which cell the particle is in.
    int i = i(p);
    int j = j(p);

    float r = 1-exp(-(gridNorm[i][j]*drag_p)/dt);
    if ( random(1)< r) {

      float a, nn;
      a_drag = PVector.sub(gridV[i][j].copy().rotate(angleDiff(p)).mult(radialScaling(p)), p.velocity.copy()); 
      a =  a_drag.magSq();   
      a_drag.normalize();
      nn = gridNorm[i][j];
      a_drag.mult(drag_c*a*nn);
    }
    return a_drag;
  }

  /** Attraction between particles and nearby grid cells.
   * @param Particle p 
   * @return 
   */

  PVector selfGravAcceleration(Particle p ) {

    //Find which cell the particle is in.
    int x = i(p);
    int y = j(p);

    PVector a_selfgrav = new PVector();

    float r = 0.5;
    if (random(1) < r) {

      float a, d; // Strength of the attraction number of particles in the cell. 
      d=1E8;

      int size = 6; //Size of Neighbourhood

      // Loop over (nearest) neighbours. As defined by Size. 

      for ( int i = x-size; i <= x+size; i++) {
        for ( int j = y-size; j <= y+size; j++) {
          if (validij(i, j)) {
            float n = gridNorm[i][j];
            PVector dist = PVector.sub(gridCofM[i][j].copy(), p.position);
            a = dist.magSq();
            if (a< minSize) {
              a_selfgrav.add(PVector.mult(dist.normalize(), n*d/minSize));
            } else {
              a_selfgrav.add(PVector.mult(dist.normalize(), n*d/a));
            }
          }
        }
      }
    }
    return a_selfgrav;
  }
  
  /**
   * Loops through all the particles adding relevant properties to  grids. Will allow generalised rules to be applied to particles.
   *
   * @param rs a collection of particles represent a planetary ring system. 
   */
  void update(System s) {

    //Reset all the grid values.
    reset();

    if ( s instanceof RingSystem) {

      RingSystem rs = (RingSystem)s;

      //Loop through all the particles trying to add them to the grid.
      for (Ring x : rs.rings) {
        for (RingParticle r : x.particles) {
          int i = i(r);
          int j = j(r);
          if (validij(i, j)) {
            grid[i][j] +=1;
            PVector v = new PVector(r.velocity.x, r.velocity.y);
            v.rotate(-angleDiff(r)).mult(1/radialScaling(r));
            gridV[i][j].add(v);
            gridCofM[i][j].add(r.position);
          }
        }
      }

      int total =0 ;
      for (int i = 0; i < int(360/dtheta); i++) {
        for (int j = 0; j < int((r_max-r_min)/dr); j++) {
          total += grid[i][j];
          if (grid[i][j] !=0) {
            gridCofM[i][j].div(grid[i][j]);
          } else {
            gridCofM[i][j].set(0.0, 0.0, 0.0);
          }
        }
      }




      //  //Looping through all the grid cell combining properties to calculate normalised values and average values from total values.
      for (int i = 0; i < int(360/dtheta); i++) {
        for (int j = 0; j < int((r_max-r_min)/dr); j++) {

          gridNorm[i][j] = grid[i][j]/((r_min+j*dr+dr/2)*dr*radians(dtheta)*total);


          if (grid[i][j] !=0) {
            gridV[i][j].div(grid[i][j]);
          } else {
            gridV[i][j].set(0.0, 0.0, 0.0);
          }
        }
      }
    }
  }

  /**
   * Returns a Table Object from a 2D array containing Int data type.
   *
   * @param grid a 2D array of values. 
   */
  Table gridToTable(int grid[][]) {
    Table tempTable = new Table();

    for (int j=0; j<grid.length; j++) {
      tempTable.addColumn();
    }

    for (int i=0; i<grid[0].length; i++) {
      TableRow newRow =tempTable.addRow();
      for (int j=0; j<grid.length; j++) {
        newRow.setInt(j, grid[j][i]);
      }
    }

    return tempTable;
  }

  /**
   * Returns a Table Object from a 2D array containing float data type.
   *
   * @param grid a 2D array of values. 
   */
  Table gridToTable(float grid[][]) {
    Table tempTable = new Table();

    for (int j=0; j<grid.length; j++) {
      tempTable.addColumn();
    }

    for (int i=0; i<grid[0].length; i++) {
      TableRow newRow =tempTable.addRow();
      for (int j=0; j<grid.length; j++) {
        newRow.setFloat(j, grid[j][i]);
      }
    }

    return tempTable;
  }

  /**
   * Returns a Table Object from a 2D array containing PVector objects.
   *
   * @param grid a 2D array of values.
   * @return Table Object with 
   */
  Table gridToTable(PVector grid[][]) {
    Table tempTable = new Table();

    for (int j=0; j<grid.length; j++) {
      tempTable.addColumn();
    }

    for (int i=0; i<grid[0].length; i++) {
      TableRow newRow =tempTable.addRow();
      for (int j=0; j<grid.length; j++) {
        newRow.setFloat(j, grid[j][i].mag());
      }
    }

    return tempTable;
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
////// Grid for the ShearSystem  ///////

//Shear grid is a standard grid system used for particle collision detection - this would be best moved over to the Quad tree as it will likely be fasted and then we won't need 2 grids
class ShearGrid{
int dx, dy; //Dimensions of 1 grid cell
int sGrid[][];

ArrayList<ShearParticle> CellParticles[][];
float sGridNorm[][];
int sizeX, sizeY;  //# of cells 
int Lx, Ly;

ShearGrid(ShearSystem ss){

  this.Lx = ss.Lx;
  this.Ly = ss.Ly;
  sizeX = 10;
  sizeY = 10;
  dx = ss.Lx/sizeX;
  dy = ss.Ly/sizeY;

  this.sGrid = new int[sizeX][sizeY];
  this.sGridNorm = new float[sizeX][sizeY];
  this.CellParticles = new ArrayList[sizeX][sizeY];
  reset();

}
int Getj(Particle p){
    Float jPosition = Ly/2 - p.position.y;
    int j = floor(jPosition/dy);
  return j;
}
int Geti(Particle p){
    Float iPosition = Lx/2 - p.position.x;
    int i = floor(iPosition/dx);
  return i;
}
  
  boolean validij(int i, int j ) {
    boolean check = false;
    if (i< sizeX && i>=0  ) {
      if (j < sizeY && j>=0) {
        check = true;
      }
    }
    return check;
  }
  
   void reset() {
    for (int i = 0; i < sizeX; i++) {
      for (int j = 0; j < sizeY; j++) {
        sGrid[i][j] = 0;
        sGridNorm[i][j] = 0;
        this.CellParticles[i][j] = new ArrayList();

      }
    }
  }
  
  //Draws new grid putting particles in the correct cell and assigning an index
 void Update(ShearSystem ss){ 
   reset();
  
   for (Particle p : ss.particles) {
          int i = Geti(p);
          int j = Getj(p);
          if (validij(i, j)) {
            sGrid[i][j] +=1;
          }
   }  
 }
 
 void FillGrid(ShearSystem ss){
 
   for (Particle p : ss.particles) {
     ShearParticle sp = (ShearParticle)p;
            int i = Geti(p);
            int j = Getj(p);
            if (validij(i, j)) {
              CellParticles[i][j].add(sp);        
            }
     }
 }
 
 
  //Runs through the grid cells and checks for particle collisions between itself and adjacent cells with no repitition
 void CollisionCheck(){
    for(int i=0; i < sizeX; i++){
      for(int j=0; j< sizeY; j++){
          int n = CellParticles[i][j].size();
          for(int x=0; x < n; x++){
            ShearParticle A = CellParticles[i][j].get(x);     
            for(int y=x+1; y<n; y++){     
             ShearParticle B = CellParticles[i][j].get(y);
             A.CollisionCheckB(B);
             
            }
            // Checks for collisions in the 3 neighboring cells directly bellow and diagonally left and right
               for(int j2 = j-1; j2 <= j+1; j2++){
                 if(validij(i+1,j2)){
                  int n2 = CellParticles[i+1][j2].size();
                  for(int z=0; z<n2; z++){     
                     ShearParticle C = CellParticles[i+1][j2].get(z);
                    A.CollisionCheckB(C);
                  }
                }
             }
             // Checks for collsions in the neighboring cell to the right
             if(validij(i,j+1)){
                  int n3 = CellParticles[i][j+1].size();
                  for(int k=0; k<n3; k++){     
                     ShearParticle D = CellParticles[i][j+1].get(k);
                     A.CollisionCheckB(D);

                  }
                }
             }
          }
       }
    }   
}
//-------------------- QuadTree----------------------------------------------------------------------------------------------------------------------------------------------------------

//Much better grid system than above, collision detection would be best moved here

class QuadTree{
     int MaxObjects = 1;
     int MaxLevels = 100;
     int Level;
     ArrayList<ShearParticle> Objects;
     ArrayList<ShearParticle> NodeObjects;
     Rectangle bounds; 
     QuadTree[] nodes;
     float M;
     PVector CofM;
     
      QuadTree(int pLevel, Rectangle pBounds){
       Level = pLevel;
       Objects = new ArrayList();
       NodeObjects = new ArrayList();
       bounds = pBounds;
       nodes = new QuadTree[4];
       this.M = 0;
       this.CofM = new PVector();
      }
      
     //Clears the particles from the tree
void ClearTree(){
      Objects.clear();
      M = 0;
      CofM = new PVector();
      for (int i = 0; i < nodes.length ; i++){
        if(nodes[i] != null){
          //nodes[i].clear();
          nodes[i] = null;
        }
      }
} 
    //Splits a node in 4 equal children and reasigns the particles into these 4 nodes
void SplitTree(){
       
      int SubWidth = (int)bounds.getWidth()/2;
      int SubHeight = (int)bounds.getHeight()/2;
      int x = (int)bounds.getX();
      int y = (int)bounds.getY();
      
      //These seem a bit backwards becasue of our coordinate system
      
       nodes[0] = new QuadTree(Level+1, new Rectangle(x, y, SubWidth, SubHeight));
       nodes[1] = new QuadTree(Level+1, new Rectangle(x, y - SubHeight, SubWidth, SubHeight));
       nodes[2] = new QuadTree(Level+1, new Rectangle(x - SubWidth, y, SubWidth, SubHeight));
       nodes[3] = new QuadTree(Level+1, new Rectangle(x - SubWidth, y - SubHeight, SubWidth, SubHeight));  
    }
      
    int GetIndex(Particle p){
      int Index = -1;
      double XMidPoint = bounds.getX() - (bounds.getWidth()/2);
      double YMidPoint = bounds.getY() - (bounds.getHeight()/2);
      
      boolean TopHalf = p.position.x > XMidPoint;
      boolean LeftHalf = p.position.y > YMidPoint;
      
      if(TopHalf){
        if(LeftHalf){
          Index = 0;
        }else{
          Index = 1;
        } 
      }else if(LeftHalf){
        Index = 2;  
      }else{
        Index = 3;
      }
      
      return Index;
  }
  //Places a particle into the correct node, if a node is full the  the node is split and all particles asigned to child nodes 
void Insert(ShearParticle p){
  
  if(nodes[0] != null){
        int Index = GetIndex(p);
        if(Index != -1){
          nodes[Index].Insert(p);
          
          return;
        }
      }
    
      Objects.add(p);
      
      if(Objects.size() > MaxObjects && Level < MaxLevels){
        if(nodes[0] == null){
        SplitTree();
        }
        int i = 0;
        while(i < Objects.size()){
          int Index = GetIndex(Objects.get(i));
          if(Index != -1){
            nodes[Index].Insert(Objects.remove(i));
          }else{ i++;
          }  
        }
      }
}

    //Retreives the node of a specific particle
ArrayList RetrieveNode(ArrayList ReturnObjects){
     for(int i = 0; i < 4 ; i++){
         if(nodes[0] != null){
            nodes[i].RetrieveNode(ReturnObjects);
         }
     }
  
    ReturnObjects.addAll(Objects);
  return ReturnObjects;
}

//Calculates the centre of mass of each node
void TreeCofM(){
    NodeObjects.clear();
    RetrieveNode(NodeObjects);
  
    M = 0;
    float CofM_X = 0;
    float CofM_Y = 0;
    float CofM_Z = 0;
    for(ShearParticle p : NodeObjects){
     M += p.m;
     CofM_X += p.m*p.position.x;
     CofM_Y += p.m*p.position.y;
     CofM_Z += p.m*p.position.z;
  }
    if(M >0){
      CofM.x = CofM_X/M;
      CofM.y = CofM_Y/M;  
      CofM.z = CofM_Z/M;
    }else{
      CofM.set(0,0,0);
    }

    if(nodes[0] != null){
      for(int i = 0; i < 4; i++){
        nodes[i].TreeCofM();
      }
    }
}
  // Calculates the gravitational force an a particle
  // if a nodes centre of mass is sufficiently far away then it is assumed to be 1 object, objects closer to the particle are individually considered
  //http://arborjs.org/docs/barnes-hut
  //Done exactly as the website above
  PVector SelfGrav(ShearParticle p){
       
      
        PVector a_grav = new PVector();
        int n = NodeObjects.size();
                
        if(n == 0){
          return a_grav;
        }else if(n == 1){
          if(NodeObjects.get(0) == p){
          return a_grav;
          }else{
            ShearParticle B = NodeObjects.get(0);
            PVector dVect = B.position.copy().sub(p.position.copy());
            if(dVect.mag() > 5){
              PVector a = dVect.mult(p.SG*B.m/(pow(dVect.mag(),3)));
              a_grav.add(a);
              return a_grav;
            }else{
              return a_grav;
            }
          }     
        }else{
          double s = bounds.getWidth();  
          PVector dVect = CofM.copy().sub(p.position.copy());
          float d = dVect.mag();
          if(nodes[0] != null){
            if(s/d < 1){
              PVector a = dVect.mult(p.SG*M/(pow(dVect.mag(),3)));
              a_grav.add(a);
              return a_grav;
            }else{
              for(int i = 0; i < 4; i++){
              PVector a = nodes[i].SelfGrav(p);
              a_grav.add(a);
              }
            return a_grav;
            }        
          }else{
            return a_grav;
          }
         }
}






}
