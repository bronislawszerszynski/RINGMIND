//--------------------------------------------------------------------------------------------------------


void createShip() {
  voyager = new Ship(scene, new PVector(0, 0, 0));
  
  scene.startAnimation();
}

void adjustFrameRate() {
  if (scene.avatar() != null)
    frameRate(1000/scene.animationPeriod());
  else
    frameRate(120);
  if (scene.animationStarted())
    scene.restartAnimation();
}



Trackable lastAvatar;

boolean triggered;
boolean changedMode;
boolean inThirdPerson;

Ship voyager;


//------------------------------------------------------------------------------------------------------------
class Ship {

  Scene scene;
  InteractiveFrame frame;
  PVector pos, vel;
  Quat q;

  Ship(Scene scn, PVector inPos) {
    scene = scn;
    pos = new PVector();
    pos.set(inPos);
    vel = new PVector(0, 0, 0);
    // q = new Quat(0,0,0,1);

    frame = new InteractiveFrame(scene);
     
    frame.setPosition(new Vec(pos.x, pos.y, pos.z)); 
   
    //angle
    frame.setTrackingEyeAzimuth(0);
   // frame.setTrackingEyeAzimuth(PApplet.QUARTER_PI); // this must be the z
    // frame.setTrackingEyeAzimuth(-PApplet.HALF_PI); // this must be the z
    //frame.setTrackingEyeInclination(PApplet.PI*(4/5));
    
    //inclination
    //frame.setTrackingEyeInclination(PApplet.HALF_PI*(4/5));  // this must be the y
    frame.setTrackingEyeInclination(-PApplet.QUARTER_PI);
   // frame.setTrackingEyeInclination(0);
   
    //zoom back a bit from the object so we can see it
    frame.setTrackingEyeDistance(scene.radius()/10);
  }

  void update() {
    frame.setPosition(new Vec(pos.x, pos.y, pos.z));
  }

  void display() {
    
    //this doesnt work
    q = Quat.multiply(new Quat( new Vec(0, 1, 0), PApplet.atan2(-vel.z, vel.x)), 
    new Quat( new Vec(0, 0, 1), PApplet.asin(vel.y / vel.mag())) );    
    frame.setRotation(q);

    pushMatrix();
    // Multiply matrix to get in the frame coordinate system.
    frame.applyTransformation();

    if (frame.grabsInput()) {
      if (!isAvatar()) {
        scene.setAvatar(frame);
      }
    }

    //beginShape(POINTS);
    fill(255, 0, 255);
    translate(pos.x, pos.y, pos.z);
    sphere(12);
    //endShape();
    popMatrix();
  }

  // check if this ships frame is the avatar
  boolean isAvatar() {
    return scene.avatar() == null ? false : scene.avatar().equals(frame) ? true : false;
  }


  void updatePos(PVector newp) {
    pos.set(newp);
  }
}
