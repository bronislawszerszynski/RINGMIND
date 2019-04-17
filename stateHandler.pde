// can decide on these as we go along

enum State {
  initState, 
    introState, 
    ringmindState, 
    makingState, 
    chaosState, 
    orbitalState, 
    shearState, 
    followState, 
    posiedState, 
    ringmoonState, 
    tuningState, 
    outroState, 

    fadetoblack, 
    fadeup,
    nocamlock
};


// brons scenarios from script


/*

 intro - distant view of ring
 ringmind - move in clsoer to view moon and ring
 making - reinit rindmind with particles not in plane, possibly just one 'ring' where they are all over the place but spinning
 chaos - gravity, chaos, all sorts going on
 orbital - initialised new 
 shear - zoom to aboe top down position to watch teh shear on one ring
 follow - the trickest one to do following a paricle particle in the ring
 poised - above top down zoomed out view
 ringmoon - gaps and waves and zoomed out
 tuning - the ring sound, lets just focus on a ring
 outro - what is a ringmind lets return back to the beginning.
 
 */


State systemState;

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

// scneario class - aka scene but cant use scene as its inbuilt into proscene

abstract class Scenario {
  void updatePhysics() {
  }

  abstract boolean transitionTo(float t);

  void update(int t) {
  }

  void postRender(int t) {
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------



void setupStates() {

  //here wa can create the scenarios of each type.
}


//---------------------------------------------------------------------------------------------------

// evaluate what state determine time and then transition to the next state


void evaluateScenario() {

  int t =millis();

  switch(systemState) {
  case initState:

    break;

  case introState:
    break;

  case ringmindState:
    break;

  case makingState:
    break;

  case chaosState:
    break;

  case orbitalState:
    break;

  case shearState:
    break;

  case followState:
    break;

  case posiedState:
    break;

  case ringmoonState:
    break;

  case tuningState:
    break;

  case outroState:
    break;

  case fadetoblack:
    break;

  case fadeup:
    break;
    
    case nocamlock:
    break;
  }
}



// update scenario method so depending on whcih scenario do different things and render differently etc
// basically like a void draw for each scneario and we switch to its one depending on what scene we in.

void updateCurrentScene(int t) {

// now regardless of scene do this

  // Display all of the objects to screen using the renderer.
  if(useAdditiveBlend){
    blendMode(ADD);
  } else {
    blendMode(NORMAL);
  }
  
  
  
 switch(systemState) {
  case initState:
    for (Ring r : Saturn.rings) {
      r.setMaxRenderedParticle(50000); //per ring max number allowed is default 50,000
    }
    //overwrite default and chose this material to begin with for all rings
    Saturn.rings.get(0).material = RingMat1; 
    
    //when all camerasa are correct lock them to the scene
   //initCamera();
    
    break;

  case introState:
    break;

  case ringmindState: 
     
     
   
    break;

  case makingState:
    break;

  case chaosState:
    break;

  case orbitalState:
    break;

  case shearState:
    break;

  case followState:
    break;

  case posiedState:
    break;

  case ringmoonState:
    break;

  case tuningState:
    break;

  case outroState:
    break;

  case fadetoblack:
    // check all rings
    for (Ring r : Saturn.rings) {
      if (r.material.partAlpha>=1) {
        r.material.partAlpha -=0.5;
      }
    }

    break;

  case fadeup:
    // check all rings
    for (Ring r : Saturn.rings) {
      if (r.material.partAlpha<=255) {
        r.material.partAlpha +=0.5;
      }
    }

    break;
    
    case nocamlock:
    //no camera settings locked down. meaning when we finish our path1-3 we stay where we end ratehr than jump back to where we were before we triggerd it. this depends on brons scenes
    break;
  }




  // renderOffScreenOnPGraphics(); // this fills the diffuse texture
  // renderOffScreenOnPGraphics2(); // this is the keyhole overlay
  renderOffScreenOnPGraphicsClean();


  //default render must stay
  rsRenderer.withMoon = drawMoons;
  rsRenderer.ringNumber = ringCnt;
  rsRenderContext.mat.diffTexture = pg;
  rsRenderer.render(Saturn, rsRenderContext,1); //1 for points
  
  // test for something funky
  if (useFilters){
   applyFilters();
  }
}
