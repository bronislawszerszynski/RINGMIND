/**
 * Class RingSystemProcessing 
 * A gravitational simulation in a Cartesian coordinate system.
 */

/*
 * Physics Coding by Lancaster University Physics Graduates.
 * @author Thomas Cann
 * @author Sam Hinson
 *
 * Interaction design and audio visual system 
 * @author ashley james brown march-may.2019 
 */


///////////////
//           //
//           //
// RINGMIND  //
//           //
//           //
///////////////


//syphon system to send to other applications

//windows need to comment out these lines and in teh setup and draw
//import codeanticode.syphon.*;
//SyphonServer server;


// render variables
boolean drawMoons = true;
boolean useAdditiveBlend = false;
boolean useTrace = false;
boolean useFilters = false;
int traceAmount=70;
int ringCnt = 10; // how many rings to render

Boolean Add;
Boolean clear;
Boolean Shearing = false; // for when we switch from ringsystem to shearsystem
Boolean Tilting = false; // for when we switch to titl system
Boolean Connecting = false;
Boolean MoonAlignment = false; // for when we want to send moon alignment info to tony and we need to not thread the system.
Boolean Threading = false;
Boolean Finale=false;

//Dynamic Timestep variables
float h_stepsize; 
//float dt; 
float simToRealTimeRatio = 3600.0/1.0;   // 3600.0/1.0 --> 1hour/second
final float maxTimeStep = 20* simToRealTimeRatio / 30;
float totalSimTime =0.0;                       // Tracks length of time simulation has be running

//Initialising Objects

//Simulation
RingSystem Saturn;

//Render System
RingSystemRenderer rsRenderer;
RenderContext rsRenderContext;
PGraphics pg;
PShader offscreenShader;

//--------------------------------------------------------------------------------------------------------------------------------------------

void settings() {


  //fullScreen(P3D, 1);
  size (1920, 800, P3D);

  smooth(); //noSmooth();
}

//--------------------------------------------------------------------------------------------------------------------------------------------

void setup() {

  //windows comment out this
  //server = new SyphonServer(this, "ringmindSyphon");

  setupOSC();

  randomSeed(3);


  // --------------renderer setup------------------
  rsRenderer = new RingSystemRenderer();
  rsRenderer.withMoon = false;
  rsRenderContext = new RenderContext();
  rsRenderContext.pgfx = this;
  rsRenderContext.shader = loadShader("texfrag.glsl", "texvert.glsl");
  rsRenderContext.mat.spriteTexture = loadImage("partsmall.png");
  pg = createGraphics(1024, 1024, P3D);
  rsRenderContext.mat.diffTexture = pg;
  rsRenderContext.mat.strokeColor = 255;
  offscreenShader = loadShader("cloudy.glsl");

  background(0);

  //setup pros cene camera and eye viewports etc
  initScene();

  //which state shall we begin with
  systemState = State.initState; 

  //instantaite the scenarios so they are avialble for the state system to handle
  setupStates();

  //extra materials we can apply to the rings
  createMaterials();
  applyBasicMaterials();

  loadFilters(); //test for potnetial aesthetics

  //osc sound engine init data
  //oscRingDensity(Saturn);
  //oscRingRotationRate(Saturn);
  sendOSC(Saturn);
}


//--------------------------------------------------------------------------------------------------------------------------------------------





void draw() {

  if (useTrace) {
    scene.beginScreenDrawing();
    fill(0, traceAmount);
    rect(0, 0, width, height);
    scene.endScreenDrawing();
  } else {
    background(0);
  }



  //*************time step******************
  if (simToRealTimeRatio/frameRate < maxTimeStep) {
    h_stepsize= simToRealTimeRatio/frameRate;
    dt= simToRealTimeRatio/frameRate;
  } else {
    h_stepsize= maxTimeStep;
    dt= maxTimeStep;
    println("At Maximum Time Step");
  }

  //*************Update and Render Frame******************

  //Updates properties of all objects.

  //if (Running) {
  //  update();
  //}

  ////Display all of the objects to screen.
  //if (Display) {
  //display();
  //}


  //*************Update and Render Frame******************

  if (Shearing) {
    s.update();
    // s.display();
  } else if (Tilting) {
    Saturn.tiltupdate();
  } else if (MoonAlignment) {
    Saturn.update();
  } else if (Connecting) {
    Saturn.update();
    //thread("update");
  } else if (Threading) {
    thread("update");
  } else {
    //thread("update"); //my imac needs this threading or it all slows down computing the physics
    Saturn.update();
  }



  //calls the render and anything specific to each scene state
  updateCurrentScene(millis()); 

  titleText(); //debug info on frame title



  //******************************************************

  if (Shearing) {
    totalSimTime += dt;
  } else {
    totalSimTime +=h_stepsize;
  }
  //******************************************************

  //windows comment out this

  //if we need to use multiple screens then lets sent it to madmapper and map it.
  //server.sendScreen();
}


void update() {
  Saturn.update();
}

void display() {
  background(0);
  Saturn.display();
}


//Display FrameRate and Time data to bar along bottom of screen
void fps() {
  surface.setTitle("Framerate: " + int(frameRate) + "     Time Elapsed[Seconds]: " + int(millis()/1000.0) + "     Simulation Time Elapsed[hours]: " + int(totalSimTime/3600.0)); //Set the frame title to the frame rate
}





//---------------------------- MOUSE -----------------------------------------------------------------------

public void mouseReleased() {
  //lets debug print all the camera stuff to help figure out what data we need for each scene
  println("****** camera debug info ******");
  println();
  println("camera orientation");
  Rotation r = scene.camera().frame().orientation();
  r.print();
  println();
  println("camera position");
  println(scene.camera().position());
  println();
  println("view direction");
  println(scene.camera().viewDirection());
  println();

  //the translate is missing ? what is the number i need argh
}


//--------------------------- INTERACTION KEYS -------------------------------------------------------------------


void keyPressed() {

  if (key==' ') {
  } else if (key=='1') {
    //Proscene - Camera Route #1
  } else if (key=='2') {
    //Proscene - Camera Route #2
  } else if (key=='3') {
    //Proscene - Camera Route #3
  } else if (key=='4') {
    //
  } else if (key=='5') {
    //
  } else if (key=='6') {
    //
  } else if (key=='7') {
    //
  } else if (key=='8') {
    //
  } else if (key=='9') {
    //TiltSystem
    systemState= State.chaosState;
    setupStates();
  } else if (key=='0') {
    initCamera();
  } else if (key=='O') {
    oscRingDensity(Saturn);
    oscRingRotationRate(Saturn);
  } else if (key=='z') {
    systemState= State.fadetoblack; //fadeout all particles from everything
  } else if (key=='Z') {
  } else if (key=='x') {
    systemState= State.fadeup; //fade up all particles
  } else if (key=='X') {
  } else if (key=='c') {
    scene.camera().interpolateToFitScene(); //if any screen frame translations ahve happened this will jump :-/ hmm. otherwise its a nice zoom to fit
  } else if (key=='C') {
  } else if (key=='v') {
    camera1();
  } else if (key=='V') {
  } else if (key=='b') {
    camera2();
  } else if (key=='B') {
  } else if (key=='n') {
    camera3();
  } else if (key=='N') {
  } else if (key=='h') {
    camera10();
  } else if (key=='P') {
    saveFrame("./screenshots/ringmind_screen-###.jpg");
  } else if (key=='r') {
  } else if (key == 'A') {
    useAdditiveBlend = !useAdditiveBlend;
  } else if (key == 'T') {
    useTrace = !useTrace;
  } else if (key=='F') {
    useFilters=!useFilters;
  } else if (key=='M') {
    //turn on this alogorithm to send tony the data
    MoonAlignment = !MoonAlignment;
  } else if (key=='m') {
    Moonlet = true;
  } else if (key=='C') {
  } else if (key=='G') {
  } else if (key=='p') {
  } else if (key=='d') {
    traceAmount=190;
  } else if (key=='Y') {


    Threading=false;
    Tilting=false;
    Shearing=false;
    //zoomedCamera();
    initCamera();
    Saturn = new RingSystem(13, 0, true);

    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat5;
    }
  } else if (key=='y') {

    Saturn.rings.add(new Ring(1, 1, 3, 0));
    Saturn.addParticlesFromTable("outputParticles.csv");
    Saturn.rings.get(1).setMaxRenderedParticle(Saturn.rings.get(1).particles.size());

    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat5;
    }
  } else if (key=='D') {
    Threading=false;
    Tilting=false;
    Shearing=false;

    Saturn.rings.remove(0);

    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat5;
    }
  } else if (key=='N') {
    Saturn.rings.get(0).material = RingMat1;
    Saturn.rings.get(1).material = RingMat3; //same as below
    Saturn.rings.get(2).material = RingMat3;
    Saturn.rings.get(3).material = RingMat1;
    Saturn.rings.get(4).material = RingMat1;
    Saturn.rings.get(5).material = RingMat5;

    closerCamera();
    Connecting=false; 
    Shearing=false;
    Tilting=false;
    // useAdditiveBlend=true;
    useFilters=false;

    sendOSC(Saturn);
  }
}


//-------------------------------
public void keyReleased() {
  //if you edit the camera pathways be sure to save them !!!!
  if (key=='S') {
    scene.saveConfig(); //outputs the camera path to a json file.
    println("camera pathways saved");
  }
}

//----------------------------

//    //reinit plus some options
//    G=6.67408E-9;
//    Saturn = new RingSystem(11, 4, true);
//    applyBasicMaterials();

//    //new materials for every ring
//    for (Ring r : Saturn.rings) {
//      r.material = RingMat3;
//    }

//    for (Moon m : Saturn.moons) {
//      m.radius = 5;
//    }

//    camera10();
//    useAdditiveBlend=true;
//    useTrace=false;
//    Threading=false;
//    Shearing=false;
//    Tilting=false;
//    //fade us back up or press x to do it manually
//    systemState= State.fadeup;

//------------------------------------
