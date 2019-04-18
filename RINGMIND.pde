/**Class RingSystemProcessing 
 * A gravitational simulation in a Cartesian coordinate system.
 *
 * @author Thomas Cann
 * @author Sam Hinson
 * @version 2.0
 */


/*
interaction design and audio visual system 
 @author ashley james brown march-may.2019
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
import codeanticode.syphon.*;
SyphonServer server;


// render variables
boolean drawMoons = true;
boolean useAdditiveBlend = false;
boolean useTrace = false;
boolean useFilters = false;
int traceAmount=70;

int ringCnt = 10; // how many rings to render

// Basic parameters
float h_stepsize;

//Dynamic Timestep variables
float simToRealTimeRatio = 3600.0/1.0;   // 3600.0/1.0 --> 1hour/second
final float maxTimeStep = 20* simToRealTimeRatio / 30;
float totalSimTime =0.0;                       // Tracks length of time simulation has be running


Boolean Running = true;
Boolean Display = true;
Boolean Add = false;
Boolean clear = false;
Boolean Shearing = false; // for when we switch from ringsystem to shearsystem

//Initialising Objects
RingSystem Saturn;

//Render System
RingSystemRenderer rsRenderer;
RenderContext rsRenderContext;
PGraphics pg;
PShader offscreenShader;



//----------------------------------------------------------------------------------------------------------------------------------------

// default overlay render using shader

void renderOffScreenOnPGraphics() {
  pg.beginDraw();
  pg.shader(offscreenShader);
  offscreenShader.set("resolution", float(pg.width), float(pg.height));
  offscreenShader.set("time", float(millis()));
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();
}


//a little keyhole example
void renderOffScreenOnPGraphics2() {
  pg.beginDraw();
  pg.background(0, 0, 0);
  //pg.stroke(255);
  //pg.fill(255);
  //pg.strokeWeight(100);
  //pg. line(0,0,pg.wdith,pg.height);

  pg.ellipse(mouseX, mouseY, 200, 200);
  pg.endDraw();
}

void renderOffScreenOnPGraphicsClean() {
  pg.beginDraw();
  pg.background(255, 255, 255); //no shader diffuse texture over the top
  pg.endDraw();
}




//--------------------------------------------------------------------------------------------------------------------------------------------


void settings() {
  //dont need fullscreen if using syphon and madmapper
  //  fullScreen(P£D, 1);
  size (1920, 800, P3D); //3840,2160 still runs 60fps just takeas few seconds to load but tbh might as well make it 4k via madmappers algorithms
  smooth(); //noSmooth();
}


//--------------------------------------------------------------------------------------------------------------------------------------------


void setup() {

  //windows comment out this
  server = new SyphonServer(this, "ringmindSyphon");

  setupOSC();

  randomSeed(3);

  //init with = rings 1,  moons 2
  Saturn = new RingSystem(1, 2);

  // --------- renderer sety
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

  //setup proscene camera and eye viewports etc
  initScene();

  //if we want a planet in the middle
  initSaturn();

  //instantaite the scenarios so they are avialble for the state system to handle
  setupStates();

  //which state shall we begin with
  systemState = State.initState; 

  //extra materials we can apply to the rings
  createMaterials();

  //postfx
  setupFX();
  loadFilters(); //test for potnetial aesthetics
  // osc sound engine init
  transmitAllRingsOSC();
  transmitAllMoonsOSC();
  
  s = new ShearingBox();
  
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

  if (inThirdPerson && scene.avatar()==null) {
    inThirdPerson = false;
    adjustFrameRate();
  } else if (!inThirdPerson && scene.avatar()!=null) {
    inThirdPerson = true;
    adjustFrameRate();
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
  
  if (Shearing){
    s.update();
   // s.display();
  }
  
  //*************Update and Render Frame******************
  thread("update"); //my imac needs this threading or it all slows down computing the physics
  //update();
  
  //calls the render and anything specific to each scene state
 updateCurrentScene(millis()); 

  titleText(); //debug info on frame title

  triggered = scene.timer().trigggered();
  if (triggered) {
    voyager.update();
    voyager.display();
  }

  //******************************************************


 if (Shearing){
   totalSimTime += dt;
 } else {
  totalSimTime +=h_stepsize;
 }
  //******************************************************

  //windows comment out this

  //if we need to use multiple screens then lets sent it to madmapper and map it.
  server.sendScreen();
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

  //hold down d and then these other sfor your debug modes. some may not work as commented out
  if (key=='d') {
    if (key ==' ') {
      if (Running) {
        Running =false;
      } else {
        Running = true;
      }
    } else if (key =='h') {
      if (Display) {
        Display =false;
      } else {
        Display = true;
      }
    } else if (key =='a') {
      if (Add) {
        Add =false;
      } else {
        println("test");
        Add = true;
      }
    } else if (key=='c') {
      if (clear) {
        clear=false;
      } else {
        clear =true;
      }
    }
  }


  if (key == 'M') {
    //moons redner better now, just if we wish to remove them from the visuals
    drawMoons = !drawMoons;
  } else if (key=='O') {
    transmitAllRingsOSC();
  } else if (key=='7') {
    //create a new system.
    Saturn = new RingSystem(2, 2); 
    //new materials for every ring
    for (Ring r : Saturn.rings) {
      r.material = RingMat3;
    }
    Saturn.rings.get(2).material = RingMat2;
    Saturn.rings.get(5).material = RingMat1;

    camera6();
    // test options
    // slowdown
    simToRealTimeRatio = 360.0/1.0;
    // change moon mass to see what it does
    Saturn.moons.get(0).GM =2.529477495e13;
  } else if (key=='z') {
    //change system state to fadeout
    systemState= State.fadetoblack; //fadeout all particles
  } else if (key=='x') {
    systemState= State.fadeup; //fade up all particles
  } else if (key=='c') {
    //if any screen frame translations ahve happened this will jump :-/ hmm. otherwise its a nice zoom to fit
    scene.camera().interpolateToFitScene();
  } else if (key=='v') {
    camera1();
  } else if (key=='b') {
    camera2();
  } else if (key=='n') {
    camera3();
  } else if (key=='m') {
    camera9();
  } else if (key=='h') {
    camera10();
  } else if (key=='P') {
    saveFrame("./screenshots/ringmind_screen-###.jpg");
  } else if (key=='R') {

    //nope not the right way to follow an object. too jerky. maybe we need to rotate around a point instead. check proscene
    Moon m2 = Saturn.moons.get(0);
    //camera1();
    scene.camera().lookAt(new Vec(SCALE*m2.position.x, SCALE*m2.position.y, 2*m2.radius*SCALE));
  } else if (key == 'A') {
    useAdditiveBlend = !useAdditiveBlend;
  } else if (key == 'T') {
    useTrace = !useTrace;
  } else if (key=='F') {
    useFilters=!useFilters;
  } else if (key=='y') {
    scene.eyeFrame().translateX(new DOF1Event(-5));
  } else if (key==' ') {    
    if ( scene.avatar() == null && lastAvatar != null)
      scene.setAvatar(lastAvatar);
    else
      lastAvatar = scene.resetAvatar();
  } else if (key=='V') {
    //simToRealTimeRatio = 360.0/1.0;
    //voyager follow the moon
    systemState= State.followState;
  } else if (key=='0'){
    initCamera();
  }
}



public void keyReleased() {
  //if (key == '1') state = cam.getState();
  //if (key == '2') cam.setState(state, 10000);

  if (key=='S') {
    scene.saveConfig(); //outputs the camera path to a json file.
  }
}
