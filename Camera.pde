import remixlab.bias.*;
import remixlab.bias.event.*;
import remixlab.dandelion.constraint.*;
import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;
import remixlab.fpstiming.*;
import remixlab.proscene.*;
import remixlab.util.*;

Scene scene;

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

void initScene() {

  scene = new Scene(this);
  // edit the json file for the starting view.
  // turn off the dispose method
  unregisterMethod("dispose", scene); //stops it autosaving the camera from where we last had it ech time and loads our default first bit of data for where we are looking

  scene.eyeFrame().setDamping(0.05); //0 is a little too rigid
  scene.eye().centerScene(); //center the entire scene

  scene.eye().setPosition(new Vec(0, 0, 0)); //center the eye
  scene.camera().lookAt(scene.center()); // point it at 0,0,0

  //load json file with predone camera paths.... 
  scene.loadConfig(); //this also laods how the camera looks when we startup the very beginning but we will overwrite by using the scenes to change that.

  //trun off debug guides
  scene.setGridVisualHint(false);
  scene.setAxesVisualHint(false);

  //must set scene to be big so it redners properly
  scene.setRadius(500); //how big is the scene - bigger means slower to load at startup

  scene.showAll();
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// camera setups

// camera top down looking straight on down on the ring almost 2d from a zoom of 1000
void initCamera() {
  scene.camera().setOrientation(new Quat(0, 0, 0, 1));
  scene.camera().setPosition(new Vec(0, 0, 1000));
  scene.camera().setViewDirection(new Vec (0, 0, -1));
}

void zoomedCamera() {
  scene.camera().setOrientation(new Quat(0, 0, 0, 1));
  scene.camera().setPosition(new Vec(0, 0, 300));
  scene.camera().setViewDirection(new Vec (0, 0, -1));
}

void closerCamera() {
  scene.camera().setOrientation(new Quat(0, 0, 0, 1));
  scene.camera().setPosition(new Vec(0, 0, 670));
  scene.camera().setViewDirection(new Vec (0, 0, -1));
}

void toptiltCamera() {
  scene.camera().setOrientation(new Quat(-0.27797017, -0.8494466, -0.44852334));
  scene.camera().setPosition(new Vec(216.607, 262.6706, -178.04265));
  scene.camera().setViewDirection(new Vec (-0.50023884, -0.6601704, 0.5603001));
}

//zoomed far back distant view of ring system
void camera1() {
  scene.camera().setOrientation(new Quat(-0.95024925, -0.2884153, 0.11765616, 0.9159098));
  scene.camera().setPosition(new Vec(-800, 2100, 1800));
  scene.camera().setViewDirection(new Vec (0.2725, -0.7403, -0.61448));
}

//side tilt from the middle
void camera2() {
  scene.camera().setOrientation(new Quat(-0.9245066, 0.025740312, 0.38029608, 4.032707));
  scene.camera().setPosition(new Vec(-176, -208, 116));
  scene.camera().setViewDirection(new Vec (0.59, 0.703, -0.39));
}

//slightly angled from aboe the ring looking down
void camera3() {
  scene.camera().setOrientation(new Quat(-0.406788, -0.40678796, 0.817953, 1.7704078));
  scene.camera().setPosition(new Vec( -281.5827, 0.0, 212.75641));
  scene.camera().setViewDirection(new Vec ( 0.7974214, -5.960465E-8, -0.60342294));
}

//left side rotated toward the camera straight in view
void camera6() {
  scene.camera().setOrientation(new Quat(0.071595766, -0.99373794, 0.08578421, 1.1399398));
  scene.camera().setPosition(new Vec(-342, -43, 160));
  scene.camera().setViewDirection(new Vec (0.8, 0.11, -0.42));
}

void camera9() {
  scene.camera().setOrientation(new Quat(-0.86009645, -0.5100075, -0.011246648, 1.7854911));
  scene.camera().setPosition(new Vec(-69.61055, 96.30619, -38.591106));
  scene.camera().setViewDirection(new Vec (0.48656437, -0.84730774, 0.21289584));

  //ideally translate for a better view
}

void camera10() {
  scene.camera().setOrientation(new Quat(-0.38721877, -0.87212867, 0.2990871, 2.547316));
  scene.camera().setPosition(new Vec(-85.0407, -32.172462, -231.61795));
  scene.camera().setViewDirection(new Vec (0.41859165, 0.43964458, 0.79466575 ));
}

void cameraChaos(){
scene.camera().setOrientation(new Quat(0.40550593, -0.44041216, -0.80100065, 2.8794248));
  scene.camera().setPosition(new Vec(-525.04645, -798.2069, 295.27277 ));
  scene.camera().setViewDirection(new Vec (0.52437866, 0.79858387, -0.2954503));
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

void titleText() {
  String txt_fps = String.format(getClass().getSimpleName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f] [Time Elapsed in Seconds %d] [Simulation Time Elapsed in Hours %d]", width, height, frameCount, frameRate, int(millis()/1000.0), int(totalSimTime/3600.0) );
  surface.setTitle(txt_fps);
}
